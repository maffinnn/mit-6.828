
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 d6 00 00 00       	call   800107 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  800040:	e8 40 10 00 00       	call   801085 <sfork>
  800045:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800048:	85 c0                	test   %eax,%eax
  80004a:	75 74                	jne    8000c0 <umain+0x8d>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80004c:	83 ec 04             	sub    $0x4,%esp
  80004f:	6a 00                	push   $0x0
  800051:	6a 00                	push   $0x0
  800053:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 47 10 00 00       	call   8010a3 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80005c:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  800062:	8b 7b 48             	mov    0x48(%ebx),%edi
  800065:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800068:	a1 08 40 80 00       	mov    0x804008,%eax
  80006d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800070:	e8 c4 0b 00 00       	call   800c39 <sys_getenvid>
  800075:	83 c4 08             	add    $0x8,%esp
  800078:	57                   	push   %edi
  800079:	53                   	push   %ebx
  80007a:	56                   	push   %esi
  80007b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80007e:	50                   	push   %eax
  80007f:	68 70 27 80 00       	push   $0x802770
  800084:	e8 83 01 00 00       	call   80020c <cprintf>
		if (val == 10)
  800089:	a1 08 40 80 00       	mov    0x804008,%eax
  80008e:	83 c4 20             	add    $0x20,%esp
  800091:	83 f8 0a             	cmp    $0xa,%eax
  800094:	74 22                	je     8000b8 <umain+0x85>
			return;
		++val;
  800096:	83 c0 01             	add    $0x1,%eax
  800099:	a3 08 40 80 00       	mov    %eax,0x804008
		ipc_send(who, 0, 0, 0);
  80009e:	6a 00                	push   $0x0
  8000a0:	6a 00                	push   $0x0
  8000a2:	6a 00                	push   $0x0
  8000a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a7:	e8 64 10 00 00       	call   801110 <ipc_send>
		if (val == 10)
  8000ac:	83 c4 10             	add    $0x10,%esp
  8000af:	83 3d 08 40 80 00 0a 	cmpl   $0xa,0x804008
  8000b6:	75 94                	jne    80004c <umain+0x19>
			return;
	}

}
  8000b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  8000c0:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  8000c6:	e8 6e 0b 00 00       	call   800c39 <sys_getenvid>
  8000cb:	83 ec 04             	sub    $0x4,%esp
  8000ce:	53                   	push   %ebx
  8000cf:	50                   	push   %eax
  8000d0:	68 40 27 80 00       	push   $0x802740
  8000d5:	e8 32 01 00 00       	call   80020c <cprintf>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  8000da:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8000dd:	e8 57 0b 00 00       	call   800c39 <sys_getenvid>
  8000e2:	83 c4 0c             	add    $0xc,%esp
  8000e5:	53                   	push   %ebx
  8000e6:	50                   	push   %eax
  8000e7:	68 5a 27 80 00       	push   $0x80275a
  8000ec:	e8 1b 01 00 00       	call   80020c <cprintf>
		ipc_send(who, 0, 0, 0);
  8000f1:	6a 00                	push   $0x0
  8000f3:	6a 00                	push   $0x0
  8000f5:	6a 00                	push   $0x0
  8000f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000fa:	e8 11 10 00 00       	call   801110 <ipc_send>
  8000ff:	83 c4 20             	add    $0x20,%esp
  800102:	e9 45 ff ff ff       	jmp    80004c <umain+0x19>

00800107 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800107:	f3 0f 1e fb          	endbr32 
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	56                   	push   %esi
  80010f:	53                   	push   %ebx
  800110:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800113:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800116:	e8 1e 0b 00 00       	call   800c39 <sys_getenvid>
  80011b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800120:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800123:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800128:	a3 0c 40 80 00       	mov    %eax,0x80400c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012d:	85 db                	test   %ebx,%ebx
  80012f:	7e 07                	jle    800138 <libmain+0x31>
		binaryname = argv[0];
  800131:	8b 06                	mov    (%esi),%eax
  800133:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800138:	83 ec 08             	sub    $0x8,%esp
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
  80013d:	e8 f1 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800142:	e8 0a 00 00 00       	call   800151 <exit>
}
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014d:	5b                   	pop    %ebx
  80014e:	5e                   	pop    %esi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800151:	f3 0f 1e fb          	endbr32 
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  80015b:	e8 39 12 00 00       	call   801399 <close_all>
	sys_env_destroy(0);
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	6a 00                	push   $0x0
  800165:	e8 ab 0a 00 00       	call   800c15 <sys_env_destroy>
}
  80016a:	83 c4 10             	add    $0x10,%esp
  80016d:	c9                   	leave  
  80016e:	c3                   	ret    

0080016f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016f:	f3 0f 1e fb          	endbr32 
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	53                   	push   %ebx
  800177:	83 ec 04             	sub    $0x4,%esp
  80017a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017d:	8b 13                	mov    (%ebx),%edx
  80017f:	8d 42 01             	lea    0x1(%edx),%eax
  800182:	89 03                	mov    %eax,(%ebx)
  800184:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800187:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80018b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800190:	74 09                	je     80019b <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800192:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800196:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800199:	c9                   	leave  
  80019a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80019b:	83 ec 08             	sub    $0x8,%esp
  80019e:	68 ff 00 00 00       	push   $0xff
  8001a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 24 0a 00 00       	call   800bd0 <sys_cputs>
		b->idx = 0;
  8001ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b2:	83 c4 10             	add    $0x10,%esp
  8001b5:	eb db                	jmp    800192 <putch+0x23>

008001b7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b7:	f3 0f 1e fb          	endbr32 
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cb:	00 00 00 
	b.cnt = 0;
  8001ce:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d8:	ff 75 0c             	pushl  0xc(%ebp)
  8001db:	ff 75 08             	pushl  0x8(%ebp)
  8001de:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e4:	50                   	push   %eax
  8001e5:	68 6f 01 80 00       	push   $0x80016f
  8001ea:	e8 20 01 00 00       	call   80030f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ef:	83 c4 08             	add    $0x8,%esp
  8001f2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fe:	50                   	push   %eax
  8001ff:	e8 cc 09 00 00       	call   800bd0 <sys_cputs>

	return b.cnt;
}
  800204:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020c:	f3 0f 1e fb          	endbr32 
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800216:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800219:	50                   	push   %eax
  80021a:	ff 75 08             	pushl  0x8(%ebp)
  80021d:	e8 95 ff ff ff       	call   8001b7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800222:	c9                   	leave  
  800223:	c3                   	ret    

00800224 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	57                   	push   %edi
  800228:	56                   	push   %esi
  800229:	53                   	push   %ebx
  80022a:	83 ec 1c             	sub    $0x1c,%esp
  80022d:	89 c7                	mov    %eax,%edi
  80022f:	89 d6                	mov    %edx,%esi
  800231:	8b 45 08             	mov    0x8(%ebp),%eax
  800234:	8b 55 0c             	mov    0xc(%ebp),%edx
  800237:	89 d1                	mov    %edx,%ecx
  800239:	89 c2                	mov    %eax,%edx
  80023b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800241:	8b 45 10             	mov    0x10(%ebp),%eax
  800244:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800247:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80024a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800251:	39 c2                	cmp    %eax,%edx
  800253:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800256:	72 3e                	jb     800296 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800258:	83 ec 0c             	sub    $0xc,%esp
  80025b:	ff 75 18             	pushl  0x18(%ebp)
  80025e:	83 eb 01             	sub    $0x1,%ebx
  800261:	53                   	push   %ebx
  800262:	50                   	push   %eax
  800263:	83 ec 08             	sub    $0x8,%esp
  800266:	ff 75 e4             	pushl  -0x1c(%ebp)
  800269:	ff 75 e0             	pushl  -0x20(%ebp)
  80026c:	ff 75 dc             	pushl  -0x24(%ebp)
  80026f:	ff 75 d8             	pushl  -0x28(%ebp)
  800272:	e8 59 22 00 00       	call   8024d0 <__udivdi3>
  800277:	83 c4 18             	add    $0x18,%esp
  80027a:	52                   	push   %edx
  80027b:	50                   	push   %eax
  80027c:	89 f2                	mov    %esi,%edx
  80027e:	89 f8                	mov    %edi,%eax
  800280:	e8 9f ff ff ff       	call   800224 <printnum>
  800285:	83 c4 20             	add    $0x20,%esp
  800288:	eb 13                	jmp    80029d <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028a:	83 ec 08             	sub    $0x8,%esp
  80028d:	56                   	push   %esi
  80028e:	ff 75 18             	pushl  0x18(%ebp)
  800291:	ff d7                	call   *%edi
  800293:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800296:	83 eb 01             	sub    $0x1,%ebx
  800299:	85 db                	test   %ebx,%ebx
  80029b:	7f ed                	jg     80028a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029d:	83 ec 08             	sub    $0x8,%esp
  8002a0:	56                   	push   %esi
  8002a1:	83 ec 04             	sub    $0x4,%esp
  8002a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b0:	e8 2b 23 00 00       	call   8025e0 <__umoddi3>
  8002b5:	83 c4 14             	add    $0x14,%esp
  8002b8:	0f be 80 a0 27 80 00 	movsbl 0x8027a0(%eax),%eax
  8002bf:	50                   	push   %eax
  8002c0:	ff d7                	call   *%edi
}
  8002c2:	83 c4 10             	add    $0x10,%esp
  8002c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c8:	5b                   	pop    %ebx
  8002c9:	5e                   	pop    %esi
  8002ca:	5f                   	pop    %edi
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cd:	f3 0f 1e fb          	endbr32 
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e0:	73 0a                	jae    8002ec <sprintputch+0x1f>
		*b->buf++ = ch;
  8002e2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ea:	88 02                	mov    %al,(%edx)
}
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <printfmt>:
{
  8002ee:	f3 0f 1e fb          	endbr32 
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fb:	50                   	push   %eax
  8002fc:	ff 75 10             	pushl  0x10(%ebp)
  8002ff:	ff 75 0c             	pushl  0xc(%ebp)
  800302:	ff 75 08             	pushl  0x8(%ebp)
  800305:	e8 05 00 00 00       	call   80030f <vprintfmt>
}
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <vprintfmt>:
{
  80030f:	f3 0f 1e fb          	endbr32 
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 3c             	sub    $0x3c,%esp
  80031c:	8b 75 08             	mov    0x8(%ebp),%esi
  80031f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800322:	8b 7d 10             	mov    0x10(%ebp),%edi
  800325:	e9 8e 03 00 00       	jmp    8006b8 <vprintfmt+0x3a9>
		padc = ' ';
  80032a:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80032e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800335:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80033c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800343:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800348:	8d 47 01             	lea    0x1(%edi),%eax
  80034b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034e:	0f b6 17             	movzbl (%edi),%edx
  800351:	8d 42 dd             	lea    -0x23(%edx),%eax
  800354:	3c 55                	cmp    $0x55,%al
  800356:	0f 87 df 03 00 00    	ja     80073b <vprintfmt+0x42c>
  80035c:	0f b6 c0             	movzbl %al,%eax
  80035f:	3e ff 24 85 e0 28 80 	notrack jmp *0x8028e0(,%eax,4)
  800366:	00 
  800367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80036a:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80036e:	eb d8                	jmp    800348 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800373:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800377:	eb cf                	jmp    800348 <vprintfmt+0x39>
  800379:	0f b6 d2             	movzbl %dl,%edx
  80037c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80037f:	b8 00 00 00 00       	mov    $0x0,%eax
  800384:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800387:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80038a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80038e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800391:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800394:	83 f9 09             	cmp    $0x9,%ecx
  800397:	77 55                	ja     8003ee <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800399:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  80039c:	eb e9                	jmp    800387 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80039e:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a1:	8b 00                	mov    (%eax),%eax
  8003a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a9:	8d 40 04             	lea    0x4(%eax),%eax
  8003ac:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b6:	79 90                	jns    800348 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003b8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003be:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003c5:	eb 81                	jmp    800348 <vprintfmt+0x39>
  8003c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ca:	85 c0                	test   %eax,%eax
  8003cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d1:	0f 49 d0             	cmovns %eax,%edx
  8003d4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003da:	e9 69 ff ff ff       	jmp    800348 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003e2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003e9:	e9 5a ff ff ff       	jmp    800348 <vprintfmt+0x39>
  8003ee:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f4:	eb bc                	jmp    8003b2 <vprintfmt+0xa3>
			lflag++;
  8003f6:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003fc:	e9 47 ff ff ff       	jmp    800348 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800401:	8b 45 14             	mov    0x14(%ebp),%eax
  800404:	8d 78 04             	lea    0x4(%eax),%edi
  800407:	83 ec 08             	sub    $0x8,%esp
  80040a:	53                   	push   %ebx
  80040b:	ff 30                	pushl  (%eax)
  80040d:	ff d6                	call   *%esi
			break;
  80040f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800412:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800415:	e9 9b 02 00 00       	jmp    8006b5 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80041a:	8b 45 14             	mov    0x14(%ebp),%eax
  80041d:	8d 78 04             	lea    0x4(%eax),%edi
  800420:	8b 00                	mov    (%eax),%eax
  800422:	99                   	cltd   
  800423:	31 d0                	xor    %edx,%eax
  800425:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800427:	83 f8 0f             	cmp    $0xf,%eax
  80042a:	7f 23                	jg     80044f <vprintfmt+0x140>
  80042c:	8b 14 85 40 2a 80 00 	mov    0x802a40(,%eax,4),%edx
  800433:	85 d2                	test   %edx,%edx
  800435:	74 18                	je     80044f <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800437:	52                   	push   %edx
  800438:	68 5d 2c 80 00       	push   $0x802c5d
  80043d:	53                   	push   %ebx
  80043e:	56                   	push   %esi
  80043f:	e8 aa fe ff ff       	call   8002ee <printfmt>
  800444:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800447:	89 7d 14             	mov    %edi,0x14(%ebp)
  80044a:	e9 66 02 00 00       	jmp    8006b5 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80044f:	50                   	push   %eax
  800450:	68 b8 27 80 00       	push   $0x8027b8
  800455:	53                   	push   %ebx
  800456:	56                   	push   %esi
  800457:	e8 92 fe ff ff       	call   8002ee <printfmt>
  80045c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80045f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800462:	e9 4e 02 00 00       	jmp    8006b5 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800467:	8b 45 14             	mov    0x14(%ebp),%eax
  80046a:	83 c0 04             	add    $0x4,%eax
  80046d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800475:	85 d2                	test   %edx,%edx
  800477:	b8 b1 27 80 00       	mov    $0x8027b1,%eax
  80047c:	0f 45 c2             	cmovne %edx,%eax
  80047f:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800482:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800486:	7e 06                	jle    80048e <vprintfmt+0x17f>
  800488:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80048c:	75 0d                	jne    80049b <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800491:	89 c7                	mov    %eax,%edi
  800493:	03 45 e0             	add    -0x20(%ebp),%eax
  800496:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800499:	eb 55                	jmp    8004f0 <vprintfmt+0x1e1>
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a1:	ff 75 cc             	pushl  -0x34(%ebp)
  8004a4:	e8 46 03 00 00       	call   8007ef <strnlen>
  8004a9:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004ac:	29 c2                	sub    %eax,%edx
  8004ae:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004b1:	83 c4 10             	add    $0x10,%esp
  8004b4:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004b6:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bd:	85 ff                	test   %edi,%edi
  8004bf:	7e 11                	jle    8004d2 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	53                   	push   %ebx
  8004c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c8:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	83 ef 01             	sub    $0x1,%edi
  8004cd:	83 c4 10             	add    $0x10,%esp
  8004d0:	eb eb                	jmp    8004bd <vprintfmt+0x1ae>
  8004d2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004d5:	85 d2                	test   %edx,%edx
  8004d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004dc:	0f 49 c2             	cmovns %edx,%eax
  8004df:	29 c2                	sub    %eax,%edx
  8004e1:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004e4:	eb a8                	jmp    80048e <vprintfmt+0x17f>
					putch(ch, putdat);
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	53                   	push   %ebx
  8004ea:	52                   	push   %edx
  8004eb:	ff d6                	call   *%esi
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f3:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f5:	83 c7 01             	add    $0x1,%edi
  8004f8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004fc:	0f be d0             	movsbl %al,%edx
  8004ff:	85 d2                	test   %edx,%edx
  800501:	74 4b                	je     80054e <vprintfmt+0x23f>
  800503:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800507:	78 06                	js     80050f <vprintfmt+0x200>
  800509:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80050d:	78 1e                	js     80052d <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  80050f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800513:	74 d1                	je     8004e6 <vprintfmt+0x1d7>
  800515:	0f be c0             	movsbl %al,%eax
  800518:	83 e8 20             	sub    $0x20,%eax
  80051b:	83 f8 5e             	cmp    $0x5e,%eax
  80051e:	76 c6                	jbe    8004e6 <vprintfmt+0x1d7>
					putch('?', putdat);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	53                   	push   %ebx
  800524:	6a 3f                	push   $0x3f
  800526:	ff d6                	call   *%esi
  800528:	83 c4 10             	add    $0x10,%esp
  80052b:	eb c3                	jmp    8004f0 <vprintfmt+0x1e1>
  80052d:	89 cf                	mov    %ecx,%edi
  80052f:	eb 0e                	jmp    80053f <vprintfmt+0x230>
				putch(' ', putdat);
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	53                   	push   %ebx
  800535:	6a 20                	push   $0x20
  800537:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800539:	83 ef 01             	sub    $0x1,%edi
  80053c:	83 c4 10             	add    $0x10,%esp
  80053f:	85 ff                	test   %edi,%edi
  800541:	7f ee                	jg     800531 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800543:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800546:	89 45 14             	mov    %eax,0x14(%ebp)
  800549:	e9 67 01 00 00       	jmp    8006b5 <vprintfmt+0x3a6>
  80054e:	89 cf                	mov    %ecx,%edi
  800550:	eb ed                	jmp    80053f <vprintfmt+0x230>
	if (lflag >= 2)
  800552:	83 f9 01             	cmp    $0x1,%ecx
  800555:	7f 1b                	jg     800572 <vprintfmt+0x263>
	else if (lflag)
  800557:	85 c9                	test   %ecx,%ecx
  800559:	74 63                	je     8005be <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80055b:	8b 45 14             	mov    0x14(%ebp),%eax
  80055e:	8b 00                	mov    (%eax),%eax
  800560:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800563:	99                   	cltd   
  800564:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 40 04             	lea    0x4(%eax),%eax
  80056d:	89 45 14             	mov    %eax,0x14(%ebp)
  800570:	eb 17                	jmp    800589 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8b 50 04             	mov    0x4(%eax),%edx
  800578:	8b 00                	mov    (%eax),%eax
  80057a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8d 40 08             	lea    0x8(%eax),%eax
  800586:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800589:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80058c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80058f:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800594:	85 c9                	test   %ecx,%ecx
  800596:	0f 89 ff 00 00 00    	jns    80069b <vprintfmt+0x38c>
				putch('-', putdat);
  80059c:	83 ec 08             	sub    $0x8,%esp
  80059f:	53                   	push   %ebx
  8005a0:	6a 2d                	push   $0x2d
  8005a2:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005aa:	f7 da                	neg    %edx
  8005ac:	83 d1 00             	adc    $0x0,%ecx
  8005af:	f7 d9                	neg    %ecx
  8005b1:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005b4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b9:	e9 dd 00 00 00       	jmp    80069b <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8b 00                	mov    (%eax),%eax
  8005c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c6:	99                   	cltd   
  8005c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 40 04             	lea    0x4(%eax),%eax
  8005d0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d3:	eb b4                	jmp    800589 <vprintfmt+0x27a>
	if (lflag >= 2)
  8005d5:	83 f9 01             	cmp    $0x1,%ecx
  8005d8:	7f 1e                	jg     8005f8 <vprintfmt+0x2e9>
	else if (lflag)
  8005da:	85 c9                	test   %ecx,%ecx
  8005dc:	74 32                	je     800610 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8b 10                	mov    (%eax),%edx
  8005e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e8:	8d 40 04             	lea    0x4(%eax),%eax
  8005eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ee:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005f3:	e9 a3 00 00 00       	jmp    80069b <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8b 10                	mov    (%eax),%edx
  8005fd:	8b 48 04             	mov    0x4(%eax),%ecx
  800600:	8d 40 08             	lea    0x8(%eax),%eax
  800603:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800606:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80060b:	e9 8b 00 00 00       	jmp    80069b <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8b 10                	mov    (%eax),%edx
  800615:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061a:	8d 40 04             	lea    0x4(%eax),%eax
  80061d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800620:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800625:	eb 74                	jmp    80069b <vprintfmt+0x38c>
	if (lflag >= 2)
  800627:	83 f9 01             	cmp    $0x1,%ecx
  80062a:	7f 1b                	jg     800647 <vprintfmt+0x338>
	else if (lflag)
  80062c:	85 c9                	test   %ecx,%ecx
  80062e:	74 2c                	je     80065c <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8b 10                	mov    (%eax),%edx
  800635:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063a:	8d 40 04             	lea    0x4(%eax),%eax
  80063d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800640:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800645:	eb 54                	jmp    80069b <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8b 10                	mov    (%eax),%edx
  80064c:	8b 48 04             	mov    0x4(%eax),%ecx
  80064f:	8d 40 08             	lea    0x8(%eax),%eax
  800652:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800655:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  80065a:	eb 3f                	jmp    80069b <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8b 10                	mov    (%eax),%edx
  800661:	b9 00 00 00 00       	mov    $0x0,%ecx
  800666:	8d 40 04             	lea    0x4(%eax),%eax
  800669:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80066c:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800671:	eb 28                	jmp    80069b <vprintfmt+0x38c>
			putch('0', putdat);
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	53                   	push   %ebx
  800677:	6a 30                	push   $0x30
  800679:	ff d6                	call   *%esi
			putch('x', putdat);
  80067b:	83 c4 08             	add    $0x8,%esp
  80067e:	53                   	push   %ebx
  80067f:	6a 78                	push   $0x78
  800681:	ff d6                	call   *%esi
			num = (unsigned long long)
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8b 10                	mov    (%eax),%edx
  800688:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80068d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800690:	8d 40 04             	lea    0x4(%eax),%eax
  800693:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800696:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80069b:	83 ec 0c             	sub    $0xc,%esp
  80069e:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006a2:	57                   	push   %edi
  8006a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a6:	50                   	push   %eax
  8006a7:	51                   	push   %ecx
  8006a8:	52                   	push   %edx
  8006a9:	89 da                	mov    %ebx,%edx
  8006ab:	89 f0                	mov    %esi,%eax
  8006ad:	e8 72 fb ff ff       	call   800224 <printnum>
			break;
  8006b2:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  8006b8:	83 c7 01             	add    $0x1,%edi
  8006bb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006bf:	83 f8 25             	cmp    $0x25,%eax
  8006c2:	0f 84 62 fc ff ff    	je     80032a <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  8006c8:	85 c0                	test   %eax,%eax
  8006ca:	0f 84 8b 00 00 00    	je     80075b <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  8006d0:	83 ec 08             	sub    $0x8,%esp
  8006d3:	53                   	push   %ebx
  8006d4:	50                   	push   %eax
  8006d5:	ff d6                	call   *%esi
  8006d7:	83 c4 10             	add    $0x10,%esp
  8006da:	eb dc                	jmp    8006b8 <vprintfmt+0x3a9>
	if (lflag >= 2)
  8006dc:	83 f9 01             	cmp    $0x1,%ecx
  8006df:	7f 1b                	jg     8006fc <vprintfmt+0x3ed>
	else if (lflag)
  8006e1:	85 c9                	test   %ecx,%ecx
  8006e3:	74 2c                	je     800711 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  8006e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e8:	8b 10                	mov    (%eax),%edx
  8006ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ef:	8d 40 04             	lea    0x4(%eax),%eax
  8006f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f5:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006fa:	eb 9f                	jmp    80069b <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8b 10                	mov    (%eax),%edx
  800701:	8b 48 04             	mov    0x4(%eax),%ecx
  800704:	8d 40 08             	lea    0x8(%eax),%eax
  800707:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80070f:	eb 8a                	jmp    80069b <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800711:	8b 45 14             	mov    0x14(%ebp),%eax
  800714:	8b 10                	mov    (%eax),%edx
  800716:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071b:	8d 40 04             	lea    0x4(%eax),%eax
  80071e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800721:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800726:	e9 70 ff ff ff       	jmp    80069b <vprintfmt+0x38c>
			putch(ch, putdat);
  80072b:	83 ec 08             	sub    $0x8,%esp
  80072e:	53                   	push   %ebx
  80072f:	6a 25                	push   $0x25
  800731:	ff d6                	call   *%esi
			break;
  800733:	83 c4 10             	add    $0x10,%esp
  800736:	e9 7a ff ff ff       	jmp    8006b5 <vprintfmt+0x3a6>
			putch('%', putdat);
  80073b:	83 ec 08             	sub    $0x8,%esp
  80073e:	53                   	push   %ebx
  80073f:	6a 25                	push   $0x25
  800741:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800743:	83 c4 10             	add    $0x10,%esp
  800746:	89 f8                	mov    %edi,%eax
  800748:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80074c:	74 05                	je     800753 <vprintfmt+0x444>
  80074e:	83 e8 01             	sub    $0x1,%eax
  800751:	eb f5                	jmp    800748 <vprintfmt+0x439>
  800753:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800756:	e9 5a ff ff ff       	jmp    8006b5 <vprintfmt+0x3a6>
}
  80075b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80075e:	5b                   	pop    %ebx
  80075f:	5e                   	pop    %esi
  800760:	5f                   	pop    %edi
  800761:	5d                   	pop    %ebp
  800762:	c3                   	ret    

00800763 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800763:	f3 0f 1e fb          	endbr32 
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	83 ec 18             	sub    $0x18,%esp
  80076d:	8b 45 08             	mov    0x8(%ebp),%eax
  800770:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800773:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800776:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80077a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80077d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800784:	85 c0                	test   %eax,%eax
  800786:	74 26                	je     8007ae <vsnprintf+0x4b>
  800788:	85 d2                	test   %edx,%edx
  80078a:	7e 22                	jle    8007ae <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078c:	ff 75 14             	pushl  0x14(%ebp)
  80078f:	ff 75 10             	pushl  0x10(%ebp)
  800792:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800795:	50                   	push   %eax
  800796:	68 cd 02 80 00       	push   $0x8002cd
  80079b:	e8 6f fb ff ff       	call   80030f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a9:	83 c4 10             	add    $0x10,%esp
}
  8007ac:	c9                   	leave  
  8007ad:	c3                   	ret    
		return -E_INVAL;
  8007ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b3:	eb f7                	jmp    8007ac <vsnprintf+0x49>

008007b5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b5:	f3 0f 1e fb          	endbr32 
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  8007bf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c2:	50                   	push   %eax
  8007c3:	ff 75 10             	pushl  0x10(%ebp)
  8007c6:	ff 75 0c             	pushl  0xc(%ebp)
  8007c9:	ff 75 08             	pushl  0x8(%ebp)
  8007cc:	e8 92 ff ff ff       	call   800763 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d1:	c9                   	leave  
  8007d2:	c3                   	ret    

008007d3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d3:	f3 0f 1e fb          	endbr32 
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e6:	74 05                	je     8007ed <strlen+0x1a>
		n++;
  8007e8:	83 c0 01             	add    $0x1,%eax
  8007eb:	eb f5                	jmp    8007e2 <strlen+0xf>
	return n;
}
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ef:	f3 0f 1e fb          	endbr32 
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800801:	39 d0                	cmp    %edx,%eax
  800803:	74 0d                	je     800812 <strnlen+0x23>
  800805:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800809:	74 05                	je     800810 <strnlen+0x21>
		n++;
  80080b:	83 c0 01             	add    $0x1,%eax
  80080e:	eb f1                	jmp    800801 <strnlen+0x12>
  800810:	89 c2                	mov    %eax,%edx
	return n;
}
  800812:	89 d0                	mov    %edx,%eax
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800816:	f3 0f 1e fb          	endbr32 
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	53                   	push   %ebx
  80081e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800821:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800824:	b8 00 00 00 00       	mov    $0x0,%eax
  800829:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80082d:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800830:	83 c0 01             	add    $0x1,%eax
  800833:	84 d2                	test   %dl,%dl
  800835:	75 f2                	jne    800829 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800837:	89 c8                	mov    %ecx,%eax
  800839:	5b                   	pop    %ebx
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80083c:	f3 0f 1e fb          	endbr32 
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	53                   	push   %ebx
  800844:	83 ec 10             	sub    $0x10,%esp
  800847:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80084a:	53                   	push   %ebx
  80084b:	e8 83 ff ff ff       	call   8007d3 <strlen>
  800850:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800853:	ff 75 0c             	pushl  0xc(%ebp)
  800856:	01 d8                	add    %ebx,%eax
  800858:	50                   	push   %eax
  800859:	e8 b8 ff ff ff       	call   800816 <strcpy>
	return dst;
}
  80085e:	89 d8                	mov    %ebx,%eax
  800860:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800863:	c9                   	leave  
  800864:	c3                   	ret    

00800865 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800865:	f3 0f 1e fb          	endbr32 
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	56                   	push   %esi
  80086d:	53                   	push   %ebx
  80086e:	8b 75 08             	mov    0x8(%ebp),%esi
  800871:	8b 55 0c             	mov    0xc(%ebp),%edx
  800874:	89 f3                	mov    %esi,%ebx
  800876:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800879:	89 f0                	mov    %esi,%eax
  80087b:	39 d8                	cmp    %ebx,%eax
  80087d:	74 11                	je     800890 <strncpy+0x2b>
		*dst++ = *src;
  80087f:	83 c0 01             	add    $0x1,%eax
  800882:	0f b6 0a             	movzbl (%edx),%ecx
  800885:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800888:	80 f9 01             	cmp    $0x1,%cl
  80088b:	83 da ff             	sbb    $0xffffffff,%edx
  80088e:	eb eb                	jmp    80087b <strncpy+0x16>
	}
	return ret;
}
  800890:	89 f0                	mov    %esi,%eax
  800892:	5b                   	pop    %ebx
  800893:	5e                   	pop    %esi
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800896:	f3 0f 1e fb          	endbr32 
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	56                   	push   %esi
  80089e:	53                   	push   %ebx
  80089f:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a5:	8b 55 10             	mov    0x10(%ebp),%edx
  8008a8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008aa:	85 d2                	test   %edx,%edx
  8008ac:	74 21                	je     8008cf <strlcpy+0x39>
  8008ae:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008b2:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008b4:	39 c2                	cmp    %eax,%edx
  8008b6:	74 14                	je     8008cc <strlcpy+0x36>
  8008b8:	0f b6 19             	movzbl (%ecx),%ebx
  8008bb:	84 db                	test   %bl,%bl
  8008bd:	74 0b                	je     8008ca <strlcpy+0x34>
			*dst++ = *src++;
  8008bf:	83 c1 01             	add    $0x1,%ecx
  8008c2:	83 c2 01             	add    $0x1,%edx
  8008c5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008c8:	eb ea                	jmp    8008b4 <strlcpy+0x1e>
  8008ca:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008cc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008cf:	29 f0                	sub    %esi,%eax
}
  8008d1:	5b                   	pop    %ebx
  8008d2:	5e                   	pop    %esi
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d5:	f3 0f 1e fb          	endbr32 
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008df:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e2:	0f b6 01             	movzbl (%ecx),%eax
  8008e5:	84 c0                	test   %al,%al
  8008e7:	74 0c                	je     8008f5 <strcmp+0x20>
  8008e9:	3a 02                	cmp    (%edx),%al
  8008eb:	75 08                	jne    8008f5 <strcmp+0x20>
		p++, q++;
  8008ed:	83 c1 01             	add    $0x1,%ecx
  8008f0:	83 c2 01             	add    $0x1,%edx
  8008f3:	eb ed                	jmp    8008e2 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f5:	0f b6 c0             	movzbl %al,%eax
  8008f8:	0f b6 12             	movzbl (%edx),%edx
  8008fb:	29 d0                	sub    %edx,%eax
}
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ff:	f3 0f 1e fb          	endbr32 
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	53                   	push   %ebx
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090d:	89 c3                	mov    %eax,%ebx
  80090f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800912:	eb 06                	jmp    80091a <strncmp+0x1b>
		n--, p++, q++;
  800914:	83 c0 01             	add    $0x1,%eax
  800917:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80091a:	39 d8                	cmp    %ebx,%eax
  80091c:	74 16                	je     800934 <strncmp+0x35>
  80091e:	0f b6 08             	movzbl (%eax),%ecx
  800921:	84 c9                	test   %cl,%cl
  800923:	74 04                	je     800929 <strncmp+0x2a>
  800925:	3a 0a                	cmp    (%edx),%cl
  800927:	74 eb                	je     800914 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800929:	0f b6 00             	movzbl (%eax),%eax
  80092c:	0f b6 12             	movzbl (%edx),%edx
  80092f:	29 d0                	sub    %edx,%eax
}
  800931:	5b                   	pop    %ebx
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    
		return 0;
  800934:	b8 00 00 00 00       	mov    $0x0,%eax
  800939:	eb f6                	jmp    800931 <strncmp+0x32>

0080093b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093b:	f3 0f 1e fb          	endbr32 
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800949:	0f b6 10             	movzbl (%eax),%edx
  80094c:	84 d2                	test   %dl,%dl
  80094e:	74 09                	je     800959 <strchr+0x1e>
		if (*s == c)
  800950:	38 ca                	cmp    %cl,%dl
  800952:	74 0a                	je     80095e <strchr+0x23>
	for (; *s; s++)
  800954:	83 c0 01             	add    $0x1,%eax
  800957:	eb f0                	jmp    800949 <strchr+0xe>
			return (char *) s;
	return 0;
  800959:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800960:	f3 0f 1e fb          	endbr32 
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  80096a:	6a 78                	push   $0x78
  80096c:	ff 75 08             	pushl  0x8(%ebp)
  80096f:	e8 c7 ff ff ff       	call   80093b <strchr>
  800974:	83 c4 10             	add    $0x10,%esp
  800977:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  80097a:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  80097f:	eb 0d                	jmp    80098e <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800981:	c1 e0 04             	shl    $0x4,%eax
  800984:	0f be d2             	movsbl %dl,%edx
  800987:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  80098b:	83 c1 01             	add    $0x1,%ecx
  80098e:	0f b6 11             	movzbl (%ecx),%edx
  800991:	84 d2                	test   %dl,%dl
  800993:	74 11                	je     8009a6 <atox+0x46>
		if (*p>='a'){
  800995:	80 fa 60             	cmp    $0x60,%dl
  800998:	7e e7                	jle    800981 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  80099a:	c1 e0 04             	shl    $0x4,%eax
  80099d:	0f be d2             	movsbl %dl,%edx
  8009a0:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  8009a4:	eb e5                	jmp    80098b <atox+0x2b>
	}

	return v;

}
  8009a6:	c9                   	leave  
  8009a7:	c3                   	ret    

008009a8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009a8:	f3 0f 1e fb          	endbr32 
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009b9:	38 ca                	cmp    %cl,%dl
  8009bb:	74 09                	je     8009c6 <strfind+0x1e>
  8009bd:	84 d2                	test   %dl,%dl
  8009bf:	74 05                	je     8009c6 <strfind+0x1e>
	for (; *s; s++)
  8009c1:	83 c0 01             	add    $0x1,%eax
  8009c4:	eb f0                	jmp    8009b6 <strfind+0xe>
			break;
	return (char *) s;
}
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c8:	f3 0f 1e fb          	endbr32 
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	57                   	push   %edi
  8009d0:	56                   	push   %esi
  8009d1:	53                   	push   %ebx
  8009d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d8:	85 c9                	test   %ecx,%ecx
  8009da:	74 31                	je     800a0d <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009dc:	89 f8                	mov    %edi,%eax
  8009de:	09 c8                	or     %ecx,%eax
  8009e0:	a8 03                	test   $0x3,%al
  8009e2:	75 23                	jne    800a07 <memset+0x3f>
		c &= 0xFF;
  8009e4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e8:	89 d3                	mov    %edx,%ebx
  8009ea:	c1 e3 08             	shl    $0x8,%ebx
  8009ed:	89 d0                	mov    %edx,%eax
  8009ef:	c1 e0 18             	shl    $0x18,%eax
  8009f2:	89 d6                	mov    %edx,%esi
  8009f4:	c1 e6 10             	shl    $0x10,%esi
  8009f7:	09 f0                	or     %esi,%eax
  8009f9:	09 c2                	or     %eax,%edx
  8009fb:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009fd:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a00:	89 d0                	mov    %edx,%eax
  800a02:	fc                   	cld    
  800a03:	f3 ab                	rep stos %eax,%es:(%edi)
  800a05:	eb 06                	jmp    800a0d <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0a:	fc                   	cld    
  800a0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a0d:	89 f8                	mov    %edi,%eax
  800a0f:	5b                   	pop    %ebx
  800a10:	5e                   	pop    %esi
  800a11:	5f                   	pop    %edi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a14:	f3 0f 1e fb          	endbr32 
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	57                   	push   %edi
  800a1c:	56                   	push   %esi
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a23:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a26:	39 c6                	cmp    %eax,%esi
  800a28:	73 32                	jae    800a5c <memmove+0x48>
  800a2a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a2d:	39 c2                	cmp    %eax,%edx
  800a2f:	76 2b                	jbe    800a5c <memmove+0x48>
		s += n;
		d += n;
  800a31:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a34:	89 fe                	mov    %edi,%esi
  800a36:	09 ce                	or     %ecx,%esi
  800a38:	09 d6                	or     %edx,%esi
  800a3a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a40:	75 0e                	jne    800a50 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a42:	83 ef 04             	sub    $0x4,%edi
  800a45:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a48:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a4b:	fd                   	std    
  800a4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4e:	eb 09                	jmp    800a59 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a50:	83 ef 01             	sub    $0x1,%edi
  800a53:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a56:	fd                   	std    
  800a57:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a59:	fc                   	cld    
  800a5a:	eb 1a                	jmp    800a76 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5c:	89 c2                	mov    %eax,%edx
  800a5e:	09 ca                	or     %ecx,%edx
  800a60:	09 f2                	or     %esi,%edx
  800a62:	f6 c2 03             	test   $0x3,%dl
  800a65:	75 0a                	jne    800a71 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a67:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a6a:	89 c7                	mov    %eax,%edi
  800a6c:	fc                   	cld    
  800a6d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6f:	eb 05                	jmp    800a76 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a71:	89 c7                	mov    %eax,%edi
  800a73:	fc                   	cld    
  800a74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a76:	5e                   	pop    %esi
  800a77:	5f                   	pop    %edi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a7a:	f3 0f 1e fb          	endbr32 
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a84:	ff 75 10             	pushl  0x10(%ebp)
  800a87:	ff 75 0c             	pushl  0xc(%ebp)
  800a8a:	ff 75 08             	pushl  0x8(%ebp)
  800a8d:	e8 82 ff ff ff       	call   800a14 <memmove>
}
  800a92:	c9                   	leave  
  800a93:	c3                   	ret    

00800a94 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a94:	f3 0f 1e fb          	endbr32 
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
  800a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa3:	89 c6                	mov    %eax,%esi
  800aa5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa8:	39 f0                	cmp    %esi,%eax
  800aaa:	74 1c                	je     800ac8 <memcmp+0x34>
		if (*s1 != *s2)
  800aac:	0f b6 08             	movzbl (%eax),%ecx
  800aaf:	0f b6 1a             	movzbl (%edx),%ebx
  800ab2:	38 d9                	cmp    %bl,%cl
  800ab4:	75 08                	jne    800abe <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ab6:	83 c0 01             	add    $0x1,%eax
  800ab9:	83 c2 01             	add    $0x1,%edx
  800abc:	eb ea                	jmp    800aa8 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800abe:	0f b6 c1             	movzbl %cl,%eax
  800ac1:	0f b6 db             	movzbl %bl,%ebx
  800ac4:	29 d8                	sub    %ebx,%eax
  800ac6:	eb 05                	jmp    800acd <memcmp+0x39>
	}

	return 0;
  800ac8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad1:	f3 0f 1e fb          	endbr32 
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  800adb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ade:	89 c2                	mov    %eax,%edx
  800ae0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae3:	39 d0                	cmp    %edx,%eax
  800ae5:	73 09                	jae    800af0 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae7:	38 08                	cmp    %cl,(%eax)
  800ae9:	74 05                	je     800af0 <memfind+0x1f>
	for (; s < ends; s++)
  800aeb:	83 c0 01             	add    $0x1,%eax
  800aee:	eb f3                	jmp    800ae3 <memfind+0x12>
			break;
	return (void *) s;
}
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af2:	f3 0f 1e fb          	endbr32 
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
  800afc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b02:	eb 03                	jmp    800b07 <strtol+0x15>
		s++;
  800b04:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b07:	0f b6 01             	movzbl (%ecx),%eax
  800b0a:	3c 20                	cmp    $0x20,%al
  800b0c:	74 f6                	je     800b04 <strtol+0x12>
  800b0e:	3c 09                	cmp    $0x9,%al
  800b10:	74 f2                	je     800b04 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b12:	3c 2b                	cmp    $0x2b,%al
  800b14:	74 2a                	je     800b40 <strtol+0x4e>
	int neg = 0;
  800b16:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b1b:	3c 2d                	cmp    $0x2d,%al
  800b1d:	74 2b                	je     800b4a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b25:	75 0f                	jne    800b36 <strtol+0x44>
  800b27:	80 39 30             	cmpb   $0x30,(%ecx)
  800b2a:	74 28                	je     800b54 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b2c:	85 db                	test   %ebx,%ebx
  800b2e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b33:	0f 44 d8             	cmove  %eax,%ebx
  800b36:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b3e:	eb 46                	jmp    800b86 <strtol+0x94>
		s++;
  800b40:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b43:	bf 00 00 00 00       	mov    $0x0,%edi
  800b48:	eb d5                	jmp    800b1f <strtol+0x2d>
		s++, neg = 1;
  800b4a:	83 c1 01             	add    $0x1,%ecx
  800b4d:	bf 01 00 00 00       	mov    $0x1,%edi
  800b52:	eb cb                	jmp    800b1f <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b54:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b58:	74 0e                	je     800b68 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b5a:	85 db                	test   %ebx,%ebx
  800b5c:	75 d8                	jne    800b36 <strtol+0x44>
		s++, base = 8;
  800b5e:	83 c1 01             	add    $0x1,%ecx
  800b61:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b66:	eb ce                	jmp    800b36 <strtol+0x44>
		s += 2, base = 16;
  800b68:	83 c1 02             	add    $0x2,%ecx
  800b6b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b70:	eb c4                	jmp    800b36 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b72:	0f be d2             	movsbl %dl,%edx
  800b75:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b78:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b7b:	7d 3a                	jge    800bb7 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b7d:	83 c1 01             	add    $0x1,%ecx
  800b80:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b84:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b86:	0f b6 11             	movzbl (%ecx),%edx
  800b89:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b8c:	89 f3                	mov    %esi,%ebx
  800b8e:	80 fb 09             	cmp    $0x9,%bl
  800b91:	76 df                	jbe    800b72 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b93:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b96:	89 f3                	mov    %esi,%ebx
  800b98:	80 fb 19             	cmp    $0x19,%bl
  800b9b:	77 08                	ja     800ba5 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b9d:	0f be d2             	movsbl %dl,%edx
  800ba0:	83 ea 57             	sub    $0x57,%edx
  800ba3:	eb d3                	jmp    800b78 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ba5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ba8:	89 f3                	mov    %esi,%ebx
  800baa:	80 fb 19             	cmp    $0x19,%bl
  800bad:	77 08                	ja     800bb7 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800baf:	0f be d2             	movsbl %dl,%edx
  800bb2:	83 ea 37             	sub    $0x37,%edx
  800bb5:	eb c1                	jmp    800b78 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bb7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbb:	74 05                	je     800bc2 <strtol+0xd0>
		*endptr = (char *) s;
  800bbd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bc2:	89 c2                	mov    %eax,%edx
  800bc4:	f7 da                	neg    %edx
  800bc6:	85 ff                	test   %edi,%edi
  800bc8:	0f 45 c2             	cmovne %edx,%eax
}
  800bcb:	5b                   	pop    %ebx
  800bcc:	5e                   	pop    %esi
  800bcd:	5f                   	pop    %edi
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    

00800bd0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bd0:	f3 0f 1e fb          	endbr32 
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bda:	b8 00 00 00 00       	mov    $0x0,%eax
  800bdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800be2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be5:	89 c3                	mov    %eax,%ebx
  800be7:	89 c7                	mov    %eax,%edi
  800be9:	89 c6                	mov    %eax,%esi
  800beb:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf2:	f3 0f 1e fb          	endbr32 
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bfc:	ba 00 00 00 00       	mov    $0x0,%edx
  800c01:	b8 01 00 00 00       	mov    $0x1,%eax
  800c06:	89 d1                	mov    %edx,%ecx
  800c08:	89 d3                	mov    %edx,%ebx
  800c0a:	89 d7                	mov    %edx,%edi
  800c0c:	89 d6                	mov    %edx,%esi
  800c0e:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c15:	f3 0f 1e fb          	endbr32 
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c1f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c24:	8b 55 08             	mov    0x8(%ebp),%edx
  800c27:	b8 03 00 00 00       	mov    $0x3,%eax
  800c2c:	89 cb                	mov    %ecx,%ebx
  800c2e:	89 cf                	mov    %ecx,%edi
  800c30:	89 ce                	mov    %ecx,%esi
  800c32:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c39:	f3 0f 1e fb          	endbr32 
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c43:	ba 00 00 00 00       	mov    $0x0,%edx
  800c48:	b8 02 00 00 00       	mov    $0x2,%eax
  800c4d:	89 d1                	mov    %edx,%ecx
  800c4f:	89 d3                	mov    %edx,%ebx
  800c51:	89 d7                	mov    %edx,%edi
  800c53:	89 d6                	mov    %edx,%esi
  800c55:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <sys_yield>:

void
sys_yield(void)
{
  800c5c:	f3 0f 1e fb          	endbr32 
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c66:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c70:	89 d1                	mov    %edx,%ecx
  800c72:	89 d3                	mov    %edx,%ebx
  800c74:	89 d7                	mov    %edx,%edi
  800c76:	89 d6                	mov    %edx,%esi
  800c78:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c7f:	f3 0f 1e fb          	endbr32 
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c89:	be 00 00 00 00       	mov    $0x0,%esi
  800c8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c94:	b8 04 00 00 00       	mov    $0x4,%eax
  800c99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9c:	89 f7                	mov    %esi,%edi
  800c9e:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca5:	f3 0f 1e fb          	endbr32 
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
	asm volatile("int %1\n"
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb5:	b8 05 00 00 00       	mov    $0x5,%eax
  800cba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc0:	8b 75 18             	mov    0x18(%ebp),%esi
  800cc3:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cca:	f3 0f 1e fb          	endbr32 
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdf:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce4:	89 df                	mov    %ebx,%edi
  800ce6:	89 de                	mov    %ebx,%esi
  800ce8:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cef:	f3 0f 1e fb          	endbr32 
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	57                   	push   %edi
  800cf7:	56                   	push   %esi
  800cf8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cf9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800d01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d04:	b8 08 00 00 00       	mov    $0x8,%eax
  800d09:	89 df                	mov    %ebx,%edi
  800d0b:	89 de                	mov    %ebx,%esi
  800d0d:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d14:	f3 0f 1e fb          	endbr32 
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	57                   	push   %edi
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d29:	b8 09 00 00 00       	mov    $0x9,%eax
  800d2e:	89 df                	mov    %ebx,%edi
  800d30:	89 de                	mov    %ebx,%esi
  800d32:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d39:	f3 0f 1e fb          	endbr32 
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d48:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d53:	89 df                	mov    %ebx,%edi
  800d55:	89 de                	mov    %ebx,%esi
  800d57:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d5e:	f3 0f 1e fb          	endbr32 
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d73:	be 00 00 00 00       	mov    $0x0,%esi
  800d78:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d7e:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d85:	f3 0f 1e fb          	endbr32 
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d94:	8b 55 08             	mov    0x8(%ebp),%edx
  800d97:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d9c:	89 cb                	mov    %ecx,%ebx
  800d9e:	89 cf                	mov    %ecx,%edi
  800da0:	89 ce                	mov    %ecx,%esi
  800da2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800da9:	f3 0f 1e fb          	endbr32 
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800db3:	ba 00 00 00 00       	mov    $0x0,%edx
  800db8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dbd:	89 d1                	mov    %edx,%ecx
  800dbf:	89 d3                	mov    %edx,%ebx
  800dc1:	89 d7                	mov    %edx,%edi
  800dc3:	89 d6                	mov    %edx,%esi
  800dc5:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800dcc:	f3 0f 1e fb          	endbr32 
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de1:	b8 0f 00 00 00       	mov    $0xf,%eax
  800de6:	89 df                	mov    %ebx,%edi
  800de8:	89 de                	mov    %ebx,%esi
  800dea:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800dec:	5b                   	pop    %ebx
  800ded:	5e                   	pop    %esi
  800dee:	5f                   	pop    %edi
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    

00800df1 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800df1:	f3 0f 1e fb          	endbr32 
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	57                   	push   %edi
  800df9:	56                   	push   %esi
  800dfa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e00:	8b 55 08             	mov    0x8(%ebp),%edx
  800e03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e06:	b8 10 00 00 00       	mov    $0x10,%eax
  800e0b:	89 df                	mov    %ebx,%edi
  800e0d:	89 de                	mov    %ebx,%esi
  800e0f:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <pgfault>:
// map in our own private writable copy.
//
extern int cnt;
static void
pgfault(struct UTrapframe *utf)
{
  800e16:	f3 0f 1e fb          	endbr32 
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	53                   	push   %ebx
  800e1e:	83 ec 04             	sub    $0x4,%esp
  800e21:	8b 45 08             	mov    0x8(%ebp),%eax
	// cprintf("[%08x] called pgfault\n", sys_getenvid());
	void *addr = (void *) utf->utf_fault_va;
  800e24:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err&FEC_WR)&&(uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_COW))){
  800e26:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e2a:	0f 84 9a 00 00 00    	je     800eca <pgfault+0xb4>
  800e30:	89 d8                	mov    %ebx,%eax
  800e32:	c1 e8 16             	shr    $0x16,%eax
  800e35:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e3c:	a8 01                	test   $0x1,%al
  800e3e:	0f 84 86 00 00 00    	je     800eca <pgfault+0xb4>
  800e44:	89 d8                	mov    %ebx,%eax
  800e46:	c1 e8 0c             	shr    $0xc,%eax
  800e49:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e50:	f6 c2 01             	test   $0x1,%dl
  800e53:	74 75                	je     800eca <pgfault+0xb4>
  800e55:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e5c:	f6 c4 08             	test   $0x8,%ah
  800e5f:	74 69                	je     800eca <pgfault+0xb4>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 在PFTEMP这里给一个物理地址的mapping 相当于store一个物理地址
	if((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W))<0){
  800e61:	83 ec 04             	sub    $0x4,%esp
  800e64:	6a 07                	push   $0x7
  800e66:	68 00 f0 7f 00       	push   $0x7ff000
  800e6b:	6a 00                	push   $0x0
  800e6d:	e8 0d fe ff ff       	call   800c7f <sys_page_alloc>
  800e72:	83 c4 10             	add    $0x10,%esp
  800e75:	85 c0                	test   %eax,%eax
  800e77:	78 63                	js     800edc <pgfault+0xc6>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e79:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// 先复制addr里的content
	memcpy((void*)PFTEMP, addr, PGSIZE);
  800e7f:	83 ec 04             	sub    $0x4,%esp
  800e82:	68 00 10 00 00       	push   $0x1000
  800e87:	53                   	push   %ebx
  800e88:	68 00 f0 7f 00       	push   $0x7ff000
  800e8d:	e8 e8 fb ff ff       	call   800a7a <memcpy>
	// 在remap addr到PFTEMP位置 即addr与PFTEMP指向同一个物理内存
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))<0){
  800e92:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e99:	53                   	push   %ebx
  800e9a:	6a 00                	push   $0x0
  800e9c:	68 00 f0 7f 00       	push   $0x7ff000
  800ea1:	6a 00                	push   $0x0
  800ea3:	e8 fd fd ff ff       	call   800ca5 <sys_page_map>
  800ea8:	83 c4 20             	add    $0x20,%esp
  800eab:	85 c0                	test   %eax,%eax
  800ead:	78 3f                	js     800eee <pgfault+0xd8>
		panic("pgfault: sys_page_map failed due to %e\n", r);
	}
	if ((r = sys_page_unmap(0, (void*)PFTEMP))<0){
  800eaf:	83 ec 08             	sub    $0x8,%esp
  800eb2:	68 00 f0 7f 00       	push   $0x7ff000
  800eb7:	6a 00                	push   $0x0
  800eb9:	e8 0c fe ff ff       	call   800cca <sys_page_unmap>
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	85 c0                	test   %eax,%eax
  800ec3:	78 3b                	js     800f00 <pgfault+0xea>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
	}
	
	
}
  800ec5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec8:	c9                   	leave  
  800ec9:	c3                   	ret    
		panic("pgfault: page access at %08x is not a write to a copy-on-write\n", addr);
  800eca:	53                   	push   %ebx
  800ecb:	68 a0 2a 80 00       	push   $0x802aa0
  800ed0:	6a 20                	push   $0x20
  800ed2:	68 5e 2b 80 00       	push   $0x802b5e
  800ed7:	e8 d1 14 00 00       	call   8023ad <_panic>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
  800edc:	50                   	push   %eax
  800edd:	68 e0 2a 80 00       	push   $0x802ae0
  800ee2:	6a 2c                	push   $0x2c
  800ee4:	68 5e 2b 80 00       	push   $0x802b5e
  800ee9:	e8 bf 14 00 00       	call   8023ad <_panic>
		panic("pgfault: sys_page_map failed due to %e\n", r);
  800eee:	50                   	push   %eax
  800eef:	68 0c 2b 80 00       	push   $0x802b0c
  800ef4:	6a 33                	push   $0x33
  800ef6:	68 5e 2b 80 00       	push   $0x802b5e
  800efb:	e8 ad 14 00 00       	call   8023ad <_panic>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
  800f00:	50                   	push   %eax
  800f01:	68 34 2b 80 00       	push   $0x802b34
  800f06:	6a 36                	push   $0x36
  800f08:	68 5e 2b 80 00       	push   $0x802b5e
  800f0d:	e8 9b 14 00 00       	call   8023ad <_panic>

00800f12 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f12:	f3 0f 1e fb          	endbr32 
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	57                   	push   %edi
  800f1a:	56                   	push   %esi
  800f1b:	53                   	push   %ebx
  800f1c:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[%08x] called fork\n", sys_getenvid());
	int r; uintptr_t addr;
	set_pgfault_handler(pgfault);
  800f1f:	68 16 0e 80 00       	push   $0x800e16
  800f24:	e8 ce 14 00 00       	call   8023f7 <set_pgfault_handler>
*/
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f29:	b8 07 00 00 00       	mov    $0x7,%eax
  800f2e:	cd 30                	int    $0x30
  800f30:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();
		
	if (envid<0){
  800f33:	83 c4 10             	add    $0x10,%esp
  800f36:	85 c0                	test   %eax,%eax
  800f38:	78 29                	js     800f63 <fork+0x51>
  800f3a:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	// duplicate parent address space
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  800f3c:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid==0){
  800f41:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f45:	75 60                	jne    800fa7 <fork+0x95>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f47:	e8 ed fc ff ff       	call   800c39 <sys_getenvid>
  800f4c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f51:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f54:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f59:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  800f5e:	e9 14 01 00 00       	jmp    801077 <fork+0x165>
		panic("fork: sys_exofork error %e\n", envid);
  800f63:	50                   	push   %eax
  800f64:	68 69 2b 80 00       	push   $0x802b69
  800f69:	68 90 00 00 00       	push   $0x90
  800f6e:	68 5e 2b 80 00       	push   $0x802b5e
  800f73:	e8 35 14 00 00       	call   8023ad <_panic>
		r = sys_page_map(0, addr, envid, addr, (uvpt[pn]&PTE_SYSCALL));
  800f78:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f7f:	83 ec 0c             	sub    $0xc,%esp
  800f82:	25 07 0e 00 00       	and    $0xe07,%eax
  800f87:	50                   	push   %eax
  800f88:	56                   	push   %esi
  800f89:	57                   	push   %edi
  800f8a:	56                   	push   %esi
  800f8b:	6a 00                	push   $0x0
  800f8d:	e8 13 fd ff ff       	call   800ca5 <sys_page_map>
  800f92:	83 c4 20             	add    $0x20,%esp
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  800f95:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f9b:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fa1:	0f 84 95 00 00 00    	je     80103c <fork+0x12a>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  800fa7:	89 d8                	mov    %ebx,%eax
  800fa9:	c1 e8 16             	shr    $0x16,%eax
  800fac:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fb3:	a8 01                	test   $0x1,%al
  800fb5:	74 de                	je     800f95 <fork+0x83>
  800fb7:	89 d8                	mov    %ebx,%eax
  800fb9:	c1 e8 0c             	shr    $0xc,%eax
  800fbc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fc3:	f6 c2 01             	test   $0x1,%dl
  800fc6:	74 cd                	je     800f95 <fork+0x83>
	void* addr = (void*)(pn*PGSIZE);
  800fc8:	89 c6                	mov    %eax,%esi
  800fca:	c1 e6 0c             	shl    $0xc,%esi
	if (uvpt[pn]&PTE_SHARE){
  800fcd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd4:	f6 c6 04             	test   $0x4,%dh
  800fd7:	75 9f                	jne    800f78 <fork+0x66>
		if (uvpt[pn]&PTE_W||uvpt[pn]&PTE_COW){
  800fd9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe0:	f6 c2 02             	test   $0x2,%dl
  800fe3:	75 0c                	jne    800ff1 <fork+0xdf>
  800fe5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fec:	f6 c4 08             	test   $0x8,%ah
  800fef:	74 34                	je     801025 <fork+0x113>
			r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P); // not writable
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	68 05 08 00 00       	push   $0x805
  800ff9:	56                   	push   %esi
  800ffa:	57                   	push   %edi
  800ffb:	56                   	push   %esi
  800ffc:	6a 00                	push   $0x0
  800ffe:	e8 a2 fc ff ff       	call   800ca5 <sys_page_map>
			if (r<0) return r;
  801003:	83 c4 20             	add    $0x20,%esp
  801006:	85 c0                	test   %eax,%eax
  801008:	78 8b                	js     800f95 <fork+0x83>
			r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P); // not writable
  80100a:	83 ec 0c             	sub    $0xc,%esp
  80100d:	68 05 08 00 00       	push   $0x805
  801012:	56                   	push   %esi
  801013:	6a 00                	push   $0x0
  801015:	56                   	push   %esi
  801016:	6a 00                	push   $0x0
  801018:	e8 88 fc ff ff       	call   800ca5 <sys_page_map>
  80101d:	83 c4 20             	add    $0x20,%esp
  801020:	e9 70 ff ff ff       	jmp    800f95 <fork+0x83>
			if ((r=sys_page_map(0, addr, envid, addr, PTE_P|PTE_U)<0))// read only
  801025:	83 ec 0c             	sub    $0xc,%esp
  801028:	6a 05                	push   $0x5
  80102a:	56                   	push   %esi
  80102b:	57                   	push   %edi
  80102c:	56                   	push   %esi
  80102d:	6a 00                	push   $0x0
  80102f:	e8 71 fc ff ff       	call   800ca5 <sys_page_map>
  801034:	83 c4 20             	add    $0x20,%esp
  801037:	e9 59 ff ff ff       	jmp    800f95 <fork+0x83>
			duppage(envid, PGNUM(addr));
		}
	}
	// allocate user exception stack
	// cprintf("alloc user expection stack\n");
	if ((r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_W|PTE_U))<0)
  80103c:	83 ec 04             	sub    $0x4,%esp
  80103f:	6a 07                	push   $0x7
  801041:	68 00 f0 bf ee       	push   $0xeebff000
  801046:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801049:	56                   	push   %esi
  80104a:	e8 30 fc ff ff       	call   800c7f <sys_page_alloc>
  80104f:	83 c4 10             	add    $0x10,%esp
  801052:	85 c0                	test   %eax,%eax
  801054:	78 2b                	js     801081 <fork+0x16f>
		return r;
	
	extern void* _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801056:	83 ec 08             	sub    $0x8,%esp
  801059:	68 6a 24 80 00       	push   $0x80246a
  80105e:	56                   	push   %esi
  80105f:	e8 d5 fc ff ff       	call   800d39 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE))<0)
  801064:	83 c4 08             	add    $0x8,%esp
  801067:	6a 02                	push   $0x2
  801069:	56                   	push   %esi
  80106a:	e8 80 fc ff ff       	call   800cef <sys_env_set_status>
  80106f:	83 c4 10             	add    $0x10,%esp
		return r;
  801072:	85 c0                	test   %eax,%eax
  801074:	0f 48 f8             	cmovs  %eax,%edi

	return envid;
	
}
  801077:	89 f8                	mov    %edi,%eax
  801079:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107c:	5b                   	pop    %ebx
  80107d:	5e                   	pop    %esi
  80107e:	5f                   	pop    %edi
  80107f:	5d                   	pop    %ebp
  801080:	c3                   	ret    
		return r;
  801081:	89 c7                	mov    %eax,%edi
  801083:	eb f2                	jmp    801077 <fork+0x165>

00801085 <sfork>:

// Challenge(not sure yet)
int
sfork(void)
{
  801085:	f3 0f 1e fb          	endbr32 
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80108f:	68 85 2b 80 00       	push   $0x802b85
  801094:	68 b2 00 00 00       	push   $0xb2
  801099:	68 5e 2b 80 00       	push   $0x802b5e
  80109e:	e8 0a 13 00 00       	call   8023ad <_panic>

008010a3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010a3:	f3 0f 1e fb          	endbr32 
  8010a7:	55                   	push   %ebp
  8010a8:	89 e5                	mov    %esp,%ebp
  8010aa:	56                   	push   %esi
  8010ab:	53                   	push   %ebx
  8010ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8010af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  8010b5:	85 c0                	test   %eax,%eax
  8010b7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8010bc:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  8010bf:	83 ec 0c             	sub    $0xc,%esp
  8010c2:	50                   	push   %eax
  8010c3:	e8 bd fc ff ff       	call   800d85 <sys_ipc_recv>
  8010c8:	83 c4 10             	add    $0x10,%esp
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	75 2b                	jne    8010fa <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  8010cf:	85 f6                	test   %esi,%esi
  8010d1:	74 0a                	je     8010dd <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  8010d3:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8010d8:	8b 40 74             	mov    0x74(%eax),%eax
  8010db:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  8010dd:	85 db                	test   %ebx,%ebx
  8010df:	74 0a                	je     8010eb <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  8010e1:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8010e6:	8b 40 78             	mov    0x78(%eax),%eax
  8010e9:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  8010eb:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8010f0:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010f6:	5b                   	pop    %ebx
  8010f7:	5e                   	pop    %esi
  8010f8:	5d                   	pop    %ebp
  8010f9:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  8010fa:	85 f6                	test   %esi,%esi
  8010fc:	74 06                	je     801104 <ipc_recv+0x61>
  8010fe:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801104:	85 db                	test   %ebx,%ebx
  801106:	74 eb                	je     8010f3 <ipc_recv+0x50>
  801108:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80110e:	eb e3                	jmp    8010f3 <ipc_recv+0x50>

00801110 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801110:	f3 0f 1e fb          	endbr32 
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	57                   	push   %edi
  801118:	56                   	push   %esi
  801119:	53                   	push   %ebx
  80111a:	83 ec 0c             	sub    $0xc,%esp
  80111d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801120:	8b 75 0c             	mov    0xc(%ebp),%esi
  801123:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  801126:	85 db                	test   %ebx,%ebx
  801128:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80112d:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  801130:	ff 75 14             	pushl  0x14(%ebp)
  801133:	53                   	push   %ebx
  801134:	56                   	push   %esi
  801135:	57                   	push   %edi
  801136:	e8 23 fc ff ff       	call   800d5e <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  80113b:	83 c4 10             	add    $0x10,%esp
  80113e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801141:	75 07                	jne    80114a <ipc_send+0x3a>
			sys_yield();
  801143:	e8 14 fb ff ff       	call   800c5c <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  801148:	eb e6                	jmp    801130 <ipc_send+0x20>
		}
		else if (ret == 0)
  80114a:	85 c0                	test   %eax,%eax
  80114c:	75 08                	jne    801156 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  80114e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801151:	5b                   	pop    %ebx
  801152:	5e                   	pop    %esi
  801153:	5f                   	pop    %edi
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  801156:	50                   	push   %eax
  801157:	68 9b 2b 80 00       	push   $0x802b9b
  80115c:	6a 48                	push   $0x48
  80115e:	68 a9 2b 80 00       	push   $0x802ba9
  801163:	e8 45 12 00 00       	call   8023ad <_panic>

00801168 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801168:	f3 0f 1e fb          	endbr32 
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801172:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801177:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80117a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801180:	8b 52 50             	mov    0x50(%edx),%edx
  801183:	39 ca                	cmp    %ecx,%edx
  801185:	74 11                	je     801198 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801187:	83 c0 01             	add    $0x1,%eax
  80118a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80118f:	75 e6                	jne    801177 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801191:	b8 00 00 00 00       	mov    $0x0,%eax
  801196:	eb 0b                	jmp    8011a3 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801198:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80119b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011a0:	8b 40 48             	mov    0x48(%eax),%eax
}
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    

008011a5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011a5:	f3 0f 1e fb          	endbr32 
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8011af:	05 00 00 00 30       	add    $0x30000000,%eax
  8011b4:	c1 e8 0c             	shr    $0xc,%eax
}
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    

008011b9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011b9:	f3 0f 1e fb          	endbr32 
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c3:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011cd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011d2:	5d                   	pop    %ebp
  8011d3:	c3                   	ret    

008011d4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011d4:	f3 0f 1e fb          	endbr32 
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011e0:	89 c2                	mov    %eax,%edx
  8011e2:	c1 ea 16             	shr    $0x16,%edx
  8011e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ec:	f6 c2 01             	test   $0x1,%dl
  8011ef:	74 2d                	je     80121e <fd_alloc+0x4a>
  8011f1:	89 c2                	mov    %eax,%edx
  8011f3:	c1 ea 0c             	shr    $0xc,%edx
  8011f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011fd:	f6 c2 01             	test   $0x1,%dl
  801200:	74 1c                	je     80121e <fd_alloc+0x4a>
  801202:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801207:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80120c:	75 d2                	jne    8011e0 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  80120e:	8b 45 08             	mov    0x8(%ebp),%eax
  801211:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801217:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80121c:	eb 0a                	jmp    801228 <fd_alloc+0x54>
			*fd_store = fd;
  80121e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801221:	89 01                	mov    %eax,(%ecx)
			return 0;
  801223:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801228:	5d                   	pop    %ebp
  801229:	c3                   	ret    

0080122a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80122a:	f3 0f 1e fb          	endbr32 
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801234:	83 f8 1f             	cmp    $0x1f,%eax
  801237:	77 30                	ja     801269 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801239:	c1 e0 0c             	shl    $0xc,%eax
  80123c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801241:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801247:	f6 c2 01             	test   $0x1,%dl
  80124a:	74 24                	je     801270 <fd_lookup+0x46>
  80124c:	89 c2                	mov    %eax,%edx
  80124e:	c1 ea 0c             	shr    $0xc,%edx
  801251:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801258:	f6 c2 01             	test   $0x1,%dl
  80125b:	74 1a                	je     801277 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80125d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801260:	89 02                	mov    %eax,(%edx)
	return 0;
  801262:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801267:	5d                   	pop    %ebp
  801268:	c3                   	ret    
		return -E_INVAL;
  801269:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126e:	eb f7                	jmp    801267 <fd_lookup+0x3d>
		return -E_INVAL;
  801270:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801275:	eb f0                	jmp    801267 <fd_lookup+0x3d>
  801277:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127c:	eb e9                	jmp    801267 <fd_lookup+0x3d>

0080127e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80127e:	f3 0f 1e fb          	endbr32 
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	83 ec 08             	sub    $0x8,%esp
  801288:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  80128b:	ba 00 00 00 00       	mov    $0x0,%edx
  801290:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  801295:	39 08                	cmp    %ecx,(%eax)
  801297:	74 38                	je     8012d1 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  801299:	83 c2 01             	add    $0x1,%edx
  80129c:	8b 04 95 30 2c 80 00 	mov    0x802c30(,%edx,4),%eax
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	75 ee                	jne    801295 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012a7:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8012ac:	8b 40 48             	mov    0x48(%eax),%eax
  8012af:	83 ec 04             	sub    $0x4,%esp
  8012b2:	51                   	push   %ecx
  8012b3:	50                   	push   %eax
  8012b4:	68 b4 2b 80 00       	push   $0x802bb4
  8012b9:	e8 4e ef ff ff       	call   80020c <cprintf>
	*dev = 0;
  8012be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012c7:	83 c4 10             	add    $0x10,%esp
  8012ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012cf:	c9                   	leave  
  8012d0:	c3                   	ret    
			*dev = devtab[i];
  8012d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012db:	eb f2                	jmp    8012cf <dev_lookup+0x51>

008012dd <fd_close>:
{
  8012dd:	f3 0f 1e fb          	endbr32 
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	57                   	push   %edi
  8012e5:	56                   	push   %esi
  8012e6:	53                   	push   %ebx
  8012e7:	83 ec 24             	sub    $0x24,%esp
  8012ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ed:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012f3:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012f4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012fa:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012fd:	50                   	push   %eax
  8012fe:	e8 27 ff ff ff       	call   80122a <fd_lookup>
  801303:	89 c3                	mov    %eax,%ebx
  801305:	83 c4 10             	add    $0x10,%esp
  801308:	85 c0                	test   %eax,%eax
  80130a:	78 05                	js     801311 <fd_close+0x34>
	    || fd != fd2)
  80130c:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80130f:	74 16                	je     801327 <fd_close+0x4a>
		return (must_exist ? r : 0);
  801311:	89 f8                	mov    %edi,%eax
  801313:	84 c0                	test   %al,%al
  801315:	b8 00 00 00 00       	mov    $0x0,%eax
  80131a:	0f 44 d8             	cmove  %eax,%ebx
}
  80131d:	89 d8                	mov    %ebx,%eax
  80131f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801322:	5b                   	pop    %ebx
  801323:	5e                   	pop    %esi
  801324:	5f                   	pop    %edi
  801325:	5d                   	pop    %ebp
  801326:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801327:	83 ec 08             	sub    $0x8,%esp
  80132a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80132d:	50                   	push   %eax
  80132e:	ff 36                	pushl  (%esi)
  801330:	e8 49 ff ff ff       	call   80127e <dev_lookup>
  801335:	89 c3                	mov    %eax,%ebx
  801337:	83 c4 10             	add    $0x10,%esp
  80133a:	85 c0                	test   %eax,%eax
  80133c:	78 1a                	js     801358 <fd_close+0x7b>
		if (dev->dev_close)
  80133e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801341:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801344:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801349:	85 c0                	test   %eax,%eax
  80134b:	74 0b                	je     801358 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80134d:	83 ec 0c             	sub    $0xc,%esp
  801350:	56                   	push   %esi
  801351:	ff d0                	call   *%eax
  801353:	89 c3                	mov    %eax,%ebx
  801355:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801358:	83 ec 08             	sub    $0x8,%esp
  80135b:	56                   	push   %esi
  80135c:	6a 00                	push   $0x0
  80135e:	e8 67 f9 ff ff       	call   800cca <sys_page_unmap>
	return r;
  801363:	83 c4 10             	add    $0x10,%esp
  801366:	eb b5                	jmp    80131d <fd_close+0x40>

00801368 <close>:

int
close(int fdnum)
{
  801368:	f3 0f 1e fb          	endbr32 
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801372:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801375:	50                   	push   %eax
  801376:	ff 75 08             	pushl  0x8(%ebp)
  801379:	e8 ac fe ff ff       	call   80122a <fd_lookup>
  80137e:	83 c4 10             	add    $0x10,%esp
  801381:	85 c0                	test   %eax,%eax
  801383:	79 02                	jns    801387 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801385:	c9                   	leave  
  801386:	c3                   	ret    
		return fd_close(fd, 1);
  801387:	83 ec 08             	sub    $0x8,%esp
  80138a:	6a 01                	push   $0x1
  80138c:	ff 75 f4             	pushl  -0xc(%ebp)
  80138f:	e8 49 ff ff ff       	call   8012dd <fd_close>
  801394:	83 c4 10             	add    $0x10,%esp
  801397:	eb ec                	jmp    801385 <close+0x1d>

00801399 <close_all>:

void
close_all(void)
{
  801399:	f3 0f 1e fb          	endbr32 
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	53                   	push   %ebx
  8013a1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013a9:	83 ec 0c             	sub    $0xc,%esp
  8013ac:	53                   	push   %ebx
  8013ad:	e8 b6 ff ff ff       	call   801368 <close>
	for (i = 0; i < MAXFD; i++)
  8013b2:	83 c3 01             	add    $0x1,%ebx
  8013b5:	83 c4 10             	add    $0x10,%esp
  8013b8:	83 fb 20             	cmp    $0x20,%ebx
  8013bb:	75 ec                	jne    8013a9 <close_all+0x10>
}
  8013bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c0:	c9                   	leave  
  8013c1:	c3                   	ret    

008013c2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013c2:	f3 0f 1e fb          	endbr32 
  8013c6:	55                   	push   %ebp
  8013c7:	89 e5                	mov    %esp,%ebp
  8013c9:	57                   	push   %edi
  8013ca:	56                   	push   %esi
  8013cb:	53                   	push   %ebx
  8013cc:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013cf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d2:	50                   	push   %eax
  8013d3:	ff 75 08             	pushl  0x8(%ebp)
  8013d6:	e8 4f fe ff ff       	call   80122a <fd_lookup>
  8013db:	89 c3                	mov    %eax,%ebx
  8013dd:	83 c4 10             	add    $0x10,%esp
  8013e0:	85 c0                	test   %eax,%eax
  8013e2:	0f 88 81 00 00 00    	js     801469 <dup+0xa7>
		return r;
	close(newfdnum);
  8013e8:	83 ec 0c             	sub    $0xc,%esp
  8013eb:	ff 75 0c             	pushl  0xc(%ebp)
  8013ee:	e8 75 ff ff ff       	call   801368 <close>

	newfd = INDEX2FD(newfdnum);
  8013f3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013f6:	c1 e6 0c             	shl    $0xc,%esi
  8013f9:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013ff:	83 c4 04             	add    $0x4,%esp
  801402:	ff 75 e4             	pushl  -0x1c(%ebp)
  801405:	e8 af fd ff ff       	call   8011b9 <fd2data>
  80140a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80140c:	89 34 24             	mov    %esi,(%esp)
  80140f:	e8 a5 fd ff ff       	call   8011b9 <fd2data>
  801414:	83 c4 10             	add    $0x10,%esp
  801417:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801419:	89 d8                	mov    %ebx,%eax
  80141b:	c1 e8 16             	shr    $0x16,%eax
  80141e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801425:	a8 01                	test   $0x1,%al
  801427:	74 11                	je     80143a <dup+0x78>
  801429:	89 d8                	mov    %ebx,%eax
  80142b:	c1 e8 0c             	shr    $0xc,%eax
  80142e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801435:	f6 c2 01             	test   $0x1,%dl
  801438:	75 39                	jne    801473 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80143a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80143d:	89 d0                	mov    %edx,%eax
  80143f:	c1 e8 0c             	shr    $0xc,%eax
  801442:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801449:	83 ec 0c             	sub    $0xc,%esp
  80144c:	25 07 0e 00 00       	and    $0xe07,%eax
  801451:	50                   	push   %eax
  801452:	56                   	push   %esi
  801453:	6a 00                	push   $0x0
  801455:	52                   	push   %edx
  801456:	6a 00                	push   $0x0
  801458:	e8 48 f8 ff ff       	call   800ca5 <sys_page_map>
  80145d:	89 c3                	mov    %eax,%ebx
  80145f:	83 c4 20             	add    $0x20,%esp
  801462:	85 c0                	test   %eax,%eax
  801464:	78 31                	js     801497 <dup+0xd5>
		goto err;

	return newfdnum;
  801466:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801469:	89 d8                	mov    %ebx,%eax
  80146b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80146e:	5b                   	pop    %ebx
  80146f:	5e                   	pop    %esi
  801470:	5f                   	pop    %edi
  801471:	5d                   	pop    %ebp
  801472:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801473:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80147a:	83 ec 0c             	sub    $0xc,%esp
  80147d:	25 07 0e 00 00       	and    $0xe07,%eax
  801482:	50                   	push   %eax
  801483:	57                   	push   %edi
  801484:	6a 00                	push   $0x0
  801486:	53                   	push   %ebx
  801487:	6a 00                	push   $0x0
  801489:	e8 17 f8 ff ff       	call   800ca5 <sys_page_map>
  80148e:	89 c3                	mov    %eax,%ebx
  801490:	83 c4 20             	add    $0x20,%esp
  801493:	85 c0                	test   %eax,%eax
  801495:	79 a3                	jns    80143a <dup+0x78>
	sys_page_unmap(0, newfd);
  801497:	83 ec 08             	sub    $0x8,%esp
  80149a:	56                   	push   %esi
  80149b:	6a 00                	push   $0x0
  80149d:	e8 28 f8 ff ff       	call   800cca <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014a2:	83 c4 08             	add    $0x8,%esp
  8014a5:	57                   	push   %edi
  8014a6:	6a 00                	push   $0x0
  8014a8:	e8 1d f8 ff ff       	call   800cca <sys_page_unmap>
	return r;
  8014ad:	83 c4 10             	add    $0x10,%esp
  8014b0:	eb b7                	jmp    801469 <dup+0xa7>

008014b2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014b2:	f3 0f 1e fb          	endbr32 
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	53                   	push   %ebx
  8014ba:	83 ec 1c             	sub    $0x1c,%esp
  8014bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c3:	50                   	push   %eax
  8014c4:	53                   	push   %ebx
  8014c5:	e8 60 fd ff ff       	call   80122a <fd_lookup>
  8014ca:	83 c4 10             	add    $0x10,%esp
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	78 3f                	js     801510 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d1:	83 ec 08             	sub    $0x8,%esp
  8014d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d7:	50                   	push   %eax
  8014d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014db:	ff 30                	pushl  (%eax)
  8014dd:	e8 9c fd ff ff       	call   80127e <dev_lookup>
  8014e2:	83 c4 10             	add    $0x10,%esp
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	78 27                	js     801510 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ec:	8b 42 08             	mov    0x8(%edx),%eax
  8014ef:	83 e0 03             	and    $0x3,%eax
  8014f2:	83 f8 01             	cmp    $0x1,%eax
  8014f5:	74 1e                	je     801515 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fa:	8b 40 08             	mov    0x8(%eax),%eax
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	74 35                	je     801536 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801501:	83 ec 04             	sub    $0x4,%esp
  801504:	ff 75 10             	pushl  0x10(%ebp)
  801507:	ff 75 0c             	pushl  0xc(%ebp)
  80150a:	52                   	push   %edx
  80150b:	ff d0                	call   *%eax
  80150d:	83 c4 10             	add    $0x10,%esp
}
  801510:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801513:	c9                   	leave  
  801514:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801515:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80151a:	8b 40 48             	mov    0x48(%eax),%eax
  80151d:	83 ec 04             	sub    $0x4,%esp
  801520:	53                   	push   %ebx
  801521:	50                   	push   %eax
  801522:	68 f5 2b 80 00       	push   $0x802bf5
  801527:	e8 e0 ec ff ff       	call   80020c <cprintf>
		return -E_INVAL;
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801534:	eb da                	jmp    801510 <read+0x5e>
		return -E_NOT_SUPP;
  801536:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80153b:	eb d3                	jmp    801510 <read+0x5e>

0080153d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80153d:	f3 0f 1e fb          	endbr32 
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	57                   	push   %edi
  801545:	56                   	push   %esi
  801546:	53                   	push   %ebx
  801547:	83 ec 0c             	sub    $0xc,%esp
  80154a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80154d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801550:	bb 00 00 00 00       	mov    $0x0,%ebx
  801555:	eb 02                	jmp    801559 <readn+0x1c>
  801557:	01 c3                	add    %eax,%ebx
  801559:	39 f3                	cmp    %esi,%ebx
  80155b:	73 21                	jae    80157e <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80155d:	83 ec 04             	sub    $0x4,%esp
  801560:	89 f0                	mov    %esi,%eax
  801562:	29 d8                	sub    %ebx,%eax
  801564:	50                   	push   %eax
  801565:	89 d8                	mov    %ebx,%eax
  801567:	03 45 0c             	add    0xc(%ebp),%eax
  80156a:	50                   	push   %eax
  80156b:	57                   	push   %edi
  80156c:	e8 41 ff ff ff       	call   8014b2 <read>
		if (m < 0)
  801571:	83 c4 10             	add    $0x10,%esp
  801574:	85 c0                	test   %eax,%eax
  801576:	78 04                	js     80157c <readn+0x3f>
			return m;
		if (m == 0)
  801578:	75 dd                	jne    801557 <readn+0x1a>
  80157a:	eb 02                	jmp    80157e <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80157c:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80157e:	89 d8                	mov    %ebx,%eax
  801580:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801583:	5b                   	pop    %ebx
  801584:	5e                   	pop    %esi
  801585:	5f                   	pop    %edi
  801586:	5d                   	pop    %ebp
  801587:	c3                   	ret    

00801588 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801588:	f3 0f 1e fb          	endbr32 
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	53                   	push   %ebx
  801590:	83 ec 1c             	sub    $0x1c,%esp
  801593:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801596:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801599:	50                   	push   %eax
  80159a:	53                   	push   %ebx
  80159b:	e8 8a fc ff ff       	call   80122a <fd_lookup>
  8015a0:	83 c4 10             	add    $0x10,%esp
  8015a3:	85 c0                	test   %eax,%eax
  8015a5:	78 3a                	js     8015e1 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a7:	83 ec 08             	sub    $0x8,%esp
  8015aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ad:	50                   	push   %eax
  8015ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b1:	ff 30                	pushl  (%eax)
  8015b3:	e8 c6 fc ff ff       	call   80127e <dev_lookup>
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	78 22                	js     8015e1 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015c6:	74 1e                	je     8015e6 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015cb:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ce:	85 d2                	test   %edx,%edx
  8015d0:	74 35                	je     801607 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015d2:	83 ec 04             	sub    $0x4,%esp
  8015d5:	ff 75 10             	pushl  0x10(%ebp)
  8015d8:	ff 75 0c             	pushl  0xc(%ebp)
  8015db:	50                   	push   %eax
  8015dc:	ff d2                	call   *%edx
  8015de:	83 c4 10             	add    $0x10,%esp
}
  8015e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e4:	c9                   	leave  
  8015e5:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015e6:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8015eb:	8b 40 48             	mov    0x48(%eax),%eax
  8015ee:	83 ec 04             	sub    $0x4,%esp
  8015f1:	53                   	push   %ebx
  8015f2:	50                   	push   %eax
  8015f3:	68 11 2c 80 00       	push   $0x802c11
  8015f8:	e8 0f ec ff ff       	call   80020c <cprintf>
		return -E_INVAL;
  8015fd:	83 c4 10             	add    $0x10,%esp
  801600:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801605:	eb da                	jmp    8015e1 <write+0x59>
		return -E_NOT_SUPP;
  801607:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80160c:	eb d3                	jmp    8015e1 <write+0x59>

0080160e <seek>:

int
seek(int fdnum, off_t offset)
{
  80160e:	f3 0f 1e fb          	endbr32 
  801612:	55                   	push   %ebp
  801613:	89 e5                	mov    %esp,%ebp
  801615:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801618:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161b:	50                   	push   %eax
  80161c:	ff 75 08             	pushl  0x8(%ebp)
  80161f:	e8 06 fc ff ff       	call   80122a <fd_lookup>
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	85 c0                	test   %eax,%eax
  801629:	78 0e                	js     801639 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80162b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80162e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801631:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801634:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801639:	c9                   	leave  
  80163a:	c3                   	ret    

0080163b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80163b:	f3 0f 1e fb          	endbr32 
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	53                   	push   %ebx
  801643:	83 ec 1c             	sub    $0x1c,%esp
  801646:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801649:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164c:	50                   	push   %eax
  80164d:	53                   	push   %ebx
  80164e:	e8 d7 fb ff ff       	call   80122a <fd_lookup>
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	85 c0                	test   %eax,%eax
  801658:	78 37                	js     801691 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165a:	83 ec 08             	sub    $0x8,%esp
  80165d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801660:	50                   	push   %eax
  801661:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801664:	ff 30                	pushl  (%eax)
  801666:	e8 13 fc ff ff       	call   80127e <dev_lookup>
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	85 c0                	test   %eax,%eax
  801670:	78 1f                	js     801691 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801672:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801675:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801679:	74 1b                	je     801696 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80167b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80167e:	8b 52 18             	mov    0x18(%edx),%edx
  801681:	85 d2                	test   %edx,%edx
  801683:	74 32                	je     8016b7 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801685:	83 ec 08             	sub    $0x8,%esp
  801688:	ff 75 0c             	pushl  0xc(%ebp)
  80168b:	50                   	push   %eax
  80168c:	ff d2                	call   *%edx
  80168e:	83 c4 10             	add    $0x10,%esp
}
  801691:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801694:	c9                   	leave  
  801695:	c3                   	ret    
			thisenv->env_id, fdnum);
  801696:	a1 0c 40 80 00       	mov    0x80400c,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80169b:	8b 40 48             	mov    0x48(%eax),%eax
  80169e:	83 ec 04             	sub    $0x4,%esp
  8016a1:	53                   	push   %ebx
  8016a2:	50                   	push   %eax
  8016a3:	68 d4 2b 80 00       	push   $0x802bd4
  8016a8:	e8 5f eb ff ff       	call   80020c <cprintf>
		return -E_INVAL;
  8016ad:	83 c4 10             	add    $0x10,%esp
  8016b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016b5:	eb da                	jmp    801691 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8016b7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016bc:	eb d3                	jmp    801691 <ftruncate+0x56>

008016be <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016be:	f3 0f 1e fb          	endbr32 
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	53                   	push   %ebx
  8016c6:	83 ec 1c             	sub    $0x1c,%esp
  8016c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016cf:	50                   	push   %eax
  8016d0:	ff 75 08             	pushl  0x8(%ebp)
  8016d3:	e8 52 fb ff ff       	call   80122a <fd_lookup>
  8016d8:	83 c4 10             	add    $0x10,%esp
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	78 4b                	js     80172a <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016df:	83 ec 08             	sub    $0x8,%esp
  8016e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e5:	50                   	push   %eax
  8016e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e9:	ff 30                	pushl  (%eax)
  8016eb:	e8 8e fb ff ff       	call   80127e <dev_lookup>
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	78 33                	js     80172a <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8016f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016fa:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016fe:	74 2f                	je     80172f <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801700:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801703:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80170a:	00 00 00 
	stat->st_isdir = 0;
  80170d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801714:	00 00 00 
	stat->st_dev = dev;
  801717:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80171d:	83 ec 08             	sub    $0x8,%esp
  801720:	53                   	push   %ebx
  801721:	ff 75 f0             	pushl  -0x10(%ebp)
  801724:	ff 50 14             	call   *0x14(%eax)
  801727:	83 c4 10             	add    $0x10,%esp
}
  80172a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172d:	c9                   	leave  
  80172e:	c3                   	ret    
		return -E_NOT_SUPP;
  80172f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801734:	eb f4                	jmp    80172a <fstat+0x6c>

00801736 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801736:	f3 0f 1e fb          	endbr32 
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	56                   	push   %esi
  80173e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80173f:	83 ec 08             	sub    $0x8,%esp
  801742:	6a 00                	push   $0x0
  801744:	ff 75 08             	pushl  0x8(%ebp)
  801747:	e8 01 02 00 00       	call   80194d <open>
  80174c:	89 c3                	mov    %eax,%ebx
  80174e:	83 c4 10             	add    $0x10,%esp
  801751:	85 c0                	test   %eax,%eax
  801753:	78 1b                	js     801770 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801755:	83 ec 08             	sub    $0x8,%esp
  801758:	ff 75 0c             	pushl  0xc(%ebp)
  80175b:	50                   	push   %eax
  80175c:	e8 5d ff ff ff       	call   8016be <fstat>
  801761:	89 c6                	mov    %eax,%esi
	close(fd);
  801763:	89 1c 24             	mov    %ebx,(%esp)
  801766:	e8 fd fb ff ff       	call   801368 <close>
	return r;
  80176b:	83 c4 10             	add    $0x10,%esp
  80176e:	89 f3                	mov    %esi,%ebx
}
  801770:	89 d8                	mov    %ebx,%eax
  801772:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801775:	5b                   	pop    %ebx
  801776:	5e                   	pop    %esi
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    

00801779 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	56                   	push   %esi
  80177d:	53                   	push   %ebx
  80177e:	89 c6                	mov    %eax,%esi
  801780:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801782:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801789:	74 27                	je     8017b2 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80178b:	6a 07                	push   $0x7
  80178d:	68 00 50 80 00       	push   $0x805000
  801792:	56                   	push   %esi
  801793:	ff 35 00 40 80 00    	pushl  0x804000
  801799:	e8 72 f9 ff ff       	call   801110 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80179e:	83 c4 0c             	add    $0xc,%esp
  8017a1:	6a 00                	push   $0x0
  8017a3:	53                   	push   %ebx
  8017a4:	6a 00                	push   $0x0
  8017a6:	e8 f8 f8 ff ff       	call   8010a3 <ipc_recv>
}
  8017ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ae:	5b                   	pop    %ebx
  8017af:	5e                   	pop    %esi
  8017b0:	5d                   	pop    %ebp
  8017b1:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017b2:	83 ec 0c             	sub    $0xc,%esp
  8017b5:	6a 01                	push   $0x1
  8017b7:	e8 ac f9 ff ff       	call   801168 <ipc_find_env>
  8017bc:	a3 00 40 80 00       	mov    %eax,0x804000
  8017c1:	83 c4 10             	add    $0x10,%esp
  8017c4:	eb c5                	jmp    80178b <fsipc+0x12>

008017c6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017c6:	f3 0f 1e fb          	endbr32 
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017de:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e8:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ed:	e8 87 ff ff ff       	call   801779 <fsipc>
}
  8017f2:	c9                   	leave  
  8017f3:	c3                   	ret    

008017f4 <devfile_flush>:
{
  8017f4:	f3 0f 1e fb          	endbr32 
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801801:	8b 40 0c             	mov    0xc(%eax),%eax
  801804:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801809:	ba 00 00 00 00       	mov    $0x0,%edx
  80180e:	b8 06 00 00 00       	mov    $0x6,%eax
  801813:	e8 61 ff ff ff       	call   801779 <fsipc>
}
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <devfile_stat>:
{
  80181a:	f3 0f 1e fb          	endbr32 
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	53                   	push   %ebx
  801822:	83 ec 04             	sub    $0x4,%esp
  801825:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801828:	8b 45 08             	mov    0x8(%ebp),%eax
  80182b:	8b 40 0c             	mov    0xc(%eax),%eax
  80182e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801833:	ba 00 00 00 00       	mov    $0x0,%edx
  801838:	b8 05 00 00 00       	mov    $0x5,%eax
  80183d:	e8 37 ff ff ff       	call   801779 <fsipc>
  801842:	85 c0                	test   %eax,%eax
  801844:	78 2c                	js     801872 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801846:	83 ec 08             	sub    $0x8,%esp
  801849:	68 00 50 80 00       	push   $0x805000
  80184e:	53                   	push   %ebx
  80184f:	e8 c2 ef ff ff       	call   800816 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801854:	a1 80 50 80 00       	mov    0x805080,%eax
  801859:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80185f:	a1 84 50 80 00       	mov    0x805084,%eax
  801864:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80186a:	83 c4 10             	add    $0x10,%esp
  80186d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801872:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801875:	c9                   	leave  
  801876:	c3                   	ret    

00801877 <devfile_write>:
{
  801877:	f3 0f 1e fb          	endbr32 
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	83 ec 0c             	sub    $0xc,%esp
  801881:	8b 45 10             	mov    0x10(%ebp),%eax
  801884:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801889:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80188e:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801891:	8b 55 08             	mov    0x8(%ebp),%edx
  801894:	8b 52 0c             	mov    0xc(%edx),%edx
  801897:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80189d:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018a2:	50                   	push   %eax
  8018a3:	ff 75 0c             	pushl  0xc(%ebp)
  8018a6:	68 08 50 80 00       	push   $0x805008
  8018ab:	e8 64 f1 ff ff       	call   800a14 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b5:	b8 04 00 00 00       	mov    $0x4,%eax
  8018ba:	e8 ba fe ff ff       	call   801779 <fsipc>
}
  8018bf:	c9                   	leave  
  8018c0:	c3                   	ret    

008018c1 <devfile_read>:
{
  8018c1:	f3 0f 1e fb          	endbr32 
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	56                   	push   %esi
  8018c9:	53                   	push   %ebx
  8018ca:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018d8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018de:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e3:	b8 03 00 00 00       	mov    $0x3,%eax
  8018e8:	e8 8c fe ff ff       	call   801779 <fsipc>
  8018ed:	89 c3                	mov    %eax,%ebx
  8018ef:	85 c0                	test   %eax,%eax
  8018f1:	78 1f                	js     801912 <devfile_read+0x51>
	assert(r <= n);
  8018f3:	39 f0                	cmp    %esi,%eax
  8018f5:	77 24                	ja     80191b <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8018f7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018fc:	7f 36                	jg     801934 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018fe:	83 ec 04             	sub    $0x4,%esp
  801901:	50                   	push   %eax
  801902:	68 00 50 80 00       	push   $0x805000
  801907:	ff 75 0c             	pushl  0xc(%ebp)
  80190a:	e8 05 f1 ff ff       	call   800a14 <memmove>
	return r;
  80190f:	83 c4 10             	add    $0x10,%esp
}
  801912:	89 d8                	mov    %ebx,%eax
  801914:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801917:	5b                   	pop    %ebx
  801918:	5e                   	pop    %esi
  801919:	5d                   	pop    %ebp
  80191a:	c3                   	ret    
	assert(r <= n);
  80191b:	68 44 2c 80 00       	push   $0x802c44
  801920:	68 4b 2c 80 00       	push   $0x802c4b
  801925:	68 8c 00 00 00       	push   $0x8c
  80192a:	68 60 2c 80 00       	push   $0x802c60
  80192f:	e8 79 0a 00 00       	call   8023ad <_panic>
	assert(r <= PGSIZE);
  801934:	68 6b 2c 80 00       	push   $0x802c6b
  801939:	68 4b 2c 80 00       	push   $0x802c4b
  80193e:	68 8d 00 00 00       	push   $0x8d
  801943:	68 60 2c 80 00       	push   $0x802c60
  801948:	e8 60 0a 00 00       	call   8023ad <_panic>

0080194d <open>:
{
  80194d:	f3 0f 1e fb          	endbr32 
  801951:	55                   	push   %ebp
  801952:	89 e5                	mov    %esp,%ebp
  801954:	56                   	push   %esi
  801955:	53                   	push   %ebx
  801956:	83 ec 1c             	sub    $0x1c,%esp
  801959:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80195c:	56                   	push   %esi
  80195d:	e8 71 ee ff ff       	call   8007d3 <strlen>
  801962:	83 c4 10             	add    $0x10,%esp
  801965:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80196a:	7f 6c                	jg     8019d8 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80196c:	83 ec 0c             	sub    $0xc,%esp
  80196f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801972:	50                   	push   %eax
  801973:	e8 5c f8 ff ff       	call   8011d4 <fd_alloc>
  801978:	89 c3                	mov    %eax,%ebx
  80197a:	83 c4 10             	add    $0x10,%esp
  80197d:	85 c0                	test   %eax,%eax
  80197f:	78 3c                	js     8019bd <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801981:	83 ec 08             	sub    $0x8,%esp
  801984:	56                   	push   %esi
  801985:	68 00 50 80 00       	push   $0x805000
  80198a:	e8 87 ee ff ff       	call   800816 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80198f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801992:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801997:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80199a:	b8 01 00 00 00       	mov    $0x1,%eax
  80199f:	e8 d5 fd ff ff       	call   801779 <fsipc>
  8019a4:	89 c3                	mov    %eax,%ebx
  8019a6:	83 c4 10             	add    $0x10,%esp
  8019a9:	85 c0                	test   %eax,%eax
  8019ab:	78 19                	js     8019c6 <open+0x79>
	return fd2num(fd);
  8019ad:	83 ec 0c             	sub    $0xc,%esp
  8019b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b3:	e8 ed f7 ff ff       	call   8011a5 <fd2num>
  8019b8:	89 c3                	mov    %eax,%ebx
  8019ba:	83 c4 10             	add    $0x10,%esp
}
  8019bd:	89 d8                	mov    %ebx,%eax
  8019bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c2:	5b                   	pop    %ebx
  8019c3:	5e                   	pop    %esi
  8019c4:	5d                   	pop    %ebp
  8019c5:	c3                   	ret    
		fd_close(fd, 0);
  8019c6:	83 ec 08             	sub    $0x8,%esp
  8019c9:	6a 00                	push   $0x0
  8019cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ce:	e8 0a f9 ff ff       	call   8012dd <fd_close>
		return r;
  8019d3:	83 c4 10             	add    $0x10,%esp
  8019d6:	eb e5                	jmp    8019bd <open+0x70>
		return -E_BAD_PATH;
  8019d8:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019dd:	eb de                	jmp    8019bd <open+0x70>

008019df <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019df:	f3 0f 1e fb          	endbr32 
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ee:	b8 08 00 00 00       	mov    $0x8,%eax
  8019f3:	e8 81 fd ff ff       	call   801779 <fsipc>
}
  8019f8:	c9                   	leave  
  8019f9:	c3                   	ret    

008019fa <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019fa:	f3 0f 1e fb          	endbr32 
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a04:	68 d7 2c 80 00       	push   $0x802cd7
  801a09:	ff 75 0c             	pushl  0xc(%ebp)
  801a0c:	e8 05 ee ff ff       	call   800816 <strcpy>
	return 0;
}
  801a11:	b8 00 00 00 00       	mov    $0x0,%eax
  801a16:	c9                   	leave  
  801a17:	c3                   	ret    

00801a18 <devsock_close>:
{
  801a18:	f3 0f 1e fb          	endbr32 
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	53                   	push   %ebx
  801a20:	83 ec 10             	sub    $0x10,%esp
  801a23:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a26:	53                   	push   %ebx
  801a27:	e8 62 0a 00 00       	call   80248e <pageref>
  801a2c:	89 c2                	mov    %eax,%edx
  801a2e:	83 c4 10             	add    $0x10,%esp
		return 0;
  801a31:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801a36:	83 fa 01             	cmp    $0x1,%edx
  801a39:	74 05                	je     801a40 <devsock_close+0x28>
}
  801a3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3e:	c9                   	leave  
  801a3f:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801a40:	83 ec 0c             	sub    $0xc,%esp
  801a43:	ff 73 0c             	pushl  0xc(%ebx)
  801a46:	e8 e3 02 00 00       	call   801d2e <nsipc_close>
  801a4b:	83 c4 10             	add    $0x10,%esp
  801a4e:	eb eb                	jmp    801a3b <devsock_close+0x23>

00801a50 <devsock_write>:
{
  801a50:	f3 0f 1e fb          	endbr32 
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a5a:	6a 00                	push   $0x0
  801a5c:	ff 75 10             	pushl  0x10(%ebp)
  801a5f:	ff 75 0c             	pushl  0xc(%ebp)
  801a62:	8b 45 08             	mov    0x8(%ebp),%eax
  801a65:	ff 70 0c             	pushl  0xc(%eax)
  801a68:	e8 b5 03 00 00       	call   801e22 <nsipc_send>
}
  801a6d:	c9                   	leave  
  801a6e:	c3                   	ret    

00801a6f <devsock_read>:
{
  801a6f:	f3 0f 1e fb          	endbr32 
  801a73:	55                   	push   %ebp
  801a74:	89 e5                	mov    %esp,%ebp
  801a76:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a79:	6a 00                	push   $0x0
  801a7b:	ff 75 10             	pushl  0x10(%ebp)
  801a7e:	ff 75 0c             	pushl  0xc(%ebp)
  801a81:	8b 45 08             	mov    0x8(%ebp),%eax
  801a84:	ff 70 0c             	pushl  0xc(%eax)
  801a87:	e8 1f 03 00 00       	call   801dab <nsipc_recv>
}
  801a8c:	c9                   	leave  
  801a8d:	c3                   	ret    

00801a8e <fd2sockid>:
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a94:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a97:	52                   	push   %edx
  801a98:	50                   	push   %eax
  801a99:	e8 8c f7 ff ff       	call   80122a <fd_lookup>
  801a9e:	83 c4 10             	add    $0x10,%esp
  801aa1:	85 c0                	test   %eax,%eax
  801aa3:	78 10                	js     801ab5 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa8:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  801aae:	39 08                	cmp    %ecx,(%eax)
  801ab0:	75 05                	jne    801ab7 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801ab2:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801ab5:	c9                   	leave  
  801ab6:	c3                   	ret    
		return -E_NOT_SUPP;
  801ab7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801abc:	eb f7                	jmp    801ab5 <fd2sockid+0x27>

00801abe <alloc_sockfd>:
{
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	56                   	push   %esi
  801ac2:	53                   	push   %ebx
  801ac3:	83 ec 1c             	sub    $0x1c,%esp
  801ac6:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801ac8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801acb:	50                   	push   %eax
  801acc:	e8 03 f7 ff ff       	call   8011d4 <fd_alloc>
  801ad1:	89 c3                	mov    %eax,%ebx
  801ad3:	83 c4 10             	add    $0x10,%esp
  801ad6:	85 c0                	test   %eax,%eax
  801ad8:	78 43                	js     801b1d <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ada:	83 ec 04             	sub    $0x4,%esp
  801add:	68 07 04 00 00       	push   $0x407
  801ae2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae5:	6a 00                	push   $0x0
  801ae7:	e8 93 f1 ff ff       	call   800c7f <sys_page_alloc>
  801aec:	89 c3                	mov    %eax,%ebx
  801aee:	83 c4 10             	add    $0x10,%esp
  801af1:	85 c0                	test   %eax,%eax
  801af3:	78 28                	js     801b1d <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af8:	8b 15 60 30 80 00    	mov    0x803060,%edx
  801afe:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b03:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b0a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b0d:	83 ec 0c             	sub    $0xc,%esp
  801b10:	50                   	push   %eax
  801b11:	e8 8f f6 ff ff       	call   8011a5 <fd2num>
  801b16:	89 c3                	mov    %eax,%ebx
  801b18:	83 c4 10             	add    $0x10,%esp
  801b1b:	eb 0c                	jmp    801b29 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801b1d:	83 ec 0c             	sub    $0xc,%esp
  801b20:	56                   	push   %esi
  801b21:	e8 08 02 00 00       	call   801d2e <nsipc_close>
		return r;
  801b26:	83 c4 10             	add    $0x10,%esp
}
  801b29:	89 d8                	mov    %ebx,%eax
  801b2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2e:	5b                   	pop    %ebx
  801b2f:	5e                   	pop    %esi
  801b30:	5d                   	pop    %ebp
  801b31:	c3                   	ret    

00801b32 <accept>:
{
  801b32:	f3 0f 1e fb          	endbr32 
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3f:	e8 4a ff ff ff       	call   801a8e <fd2sockid>
  801b44:	85 c0                	test   %eax,%eax
  801b46:	78 1b                	js     801b63 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b48:	83 ec 04             	sub    $0x4,%esp
  801b4b:	ff 75 10             	pushl  0x10(%ebp)
  801b4e:	ff 75 0c             	pushl  0xc(%ebp)
  801b51:	50                   	push   %eax
  801b52:	e8 22 01 00 00       	call   801c79 <nsipc_accept>
  801b57:	83 c4 10             	add    $0x10,%esp
  801b5a:	85 c0                	test   %eax,%eax
  801b5c:	78 05                	js     801b63 <accept+0x31>
	return alloc_sockfd(r);
  801b5e:	e8 5b ff ff ff       	call   801abe <alloc_sockfd>
}
  801b63:	c9                   	leave  
  801b64:	c3                   	ret    

00801b65 <bind>:
{
  801b65:	f3 0f 1e fb          	endbr32 
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b72:	e8 17 ff ff ff       	call   801a8e <fd2sockid>
  801b77:	85 c0                	test   %eax,%eax
  801b79:	78 12                	js     801b8d <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801b7b:	83 ec 04             	sub    $0x4,%esp
  801b7e:	ff 75 10             	pushl  0x10(%ebp)
  801b81:	ff 75 0c             	pushl  0xc(%ebp)
  801b84:	50                   	push   %eax
  801b85:	e8 45 01 00 00       	call   801ccf <nsipc_bind>
  801b8a:	83 c4 10             	add    $0x10,%esp
}
  801b8d:	c9                   	leave  
  801b8e:	c3                   	ret    

00801b8f <shutdown>:
{
  801b8f:	f3 0f 1e fb          	endbr32 
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b99:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9c:	e8 ed fe ff ff       	call   801a8e <fd2sockid>
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	78 0f                	js     801bb4 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801ba5:	83 ec 08             	sub    $0x8,%esp
  801ba8:	ff 75 0c             	pushl  0xc(%ebp)
  801bab:	50                   	push   %eax
  801bac:	e8 57 01 00 00       	call   801d08 <nsipc_shutdown>
  801bb1:	83 c4 10             	add    $0x10,%esp
}
  801bb4:	c9                   	leave  
  801bb5:	c3                   	ret    

00801bb6 <connect>:
{
  801bb6:	f3 0f 1e fb          	endbr32 
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
  801bbd:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc3:	e8 c6 fe ff ff       	call   801a8e <fd2sockid>
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	78 12                	js     801bde <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801bcc:	83 ec 04             	sub    $0x4,%esp
  801bcf:	ff 75 10             	pushl  0x10(%ebp)
  801bd2:	ff 75 0c             	pushl  0xc(%ebp)
  801bd5:	50                   	push   %eax
  801bd6:	e8 71 01 00 00       	call   801d4c <nsipc_connect>
  801bdb:	83 c4 10             	add    $0x10,%esp
}
  801bde:	c9                   	leave  
  801bdf:	c3                   	ret    

00801be0 <listen>:
{
  801be0:	f3 0f 1e fb          	endbr32 
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bea:	8b 45 08             	mov    0x8(%ebp),%eax
  801bed:	e8 9c fe ff ff       	call   801a8e <fd2sockid>
  801bf2:	85 c0                	test   %eax,%eax
  801bf4:	78 0f                	js     801c05 <listen+0x25>
	return nsipc_listen(r, backlog);
  801bf6:	83 ec 08             	sub    $0x8,%esp
  801bf9:	ff 75 0c             	pushl  0xc(%ebp)
  801bfc:	50                   	push   %eax
  801bfd:	e8 83 01 00 00       	call   801d85 <nsipc_listen>
  801c02:	83 c4 10             	add    $0x10,%esp
}
  801c05:	c9                   	leave  
  801c06:	c3                   	ret    

00801c07 <socket>:

int
socket(int domain, int type, int protocol)
{
  801c07:	f3 0f 1e fb          	endbr32 
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c11:	ff 75 10             	pushl  0x10(%ebp)
  801c14:	ff 75 0c             	pushl  0xc(%ebp)
  801c17:	ff 75 08             	pushl  0x8(%ebp)
  801c1a:	e8 65 02 00 00       	call   801e84 <nsipc_socket>
  801c1f:	83 c4 10             	add    $0x10,%esp
  801c22:	85 c0                	test   %eax,%eax
  801c24:	78 05                	js     801c2b <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801c26:	e8 93 fe ff ff       	call   801abe <alloc_sockfd>
}
  801c2b:	c9                   	leave  
  801c2c:	c3                   	ret    

00801c2d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c2d:	55                   	push   %ebp
  801c2e:	89 e5                	mov    %esp,%ebp
  801c30:	53                   	push   %ebx
  801c31:	83 ec 04             	sub    $0x4,%esp
  801c34:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c36:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c3d:	74 26                	je     801c65 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c3f:	6a 07                	push   $0x7
  801c41:	68 00 60 80 00       	push   $0x806000
  801c46:	53                   	push   %ebx
  801c47:	ff 35 04 40 80 00    	pushl  0x804004
  801c4d:	e8 be f4 ff ff       	call   801110 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c52:	83 c4 0c             	add    $0xc,%esp
  801c55:	6a 00                	push   $0x0
  801c57:	6a 00                	push   $0x0
  801c59:	6a 00                	push   $0x0
  801c5b:	e8 43 f4 ff ff       	call   8010a3 <ipc_recv>
}
  801c60:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c63:	c9                   	leave  
  801c64:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c65:	83 ec 0c             	sub    $0xc,%esp
  801c68:	6a 02                	push   $0x2
  801c6a:	e8 f9 f4 ff ff       	call   801168 <ipc_find_env>
  801c6f:	a3 04 40 80 00       	mov    %eax,0x804004
  801c74:	83 c4 10             	add    $0x10,%esp
  801c77:	eb c6                	jmp    801c3f <nsipc+0x12>

00801c79 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c79:	f3 0f 1e fb          	endbr32 
  801c7d:	55                   	push   %ebp
  801c7e:	89 e5                	mov    %esp,%ebp
  801c80:	56                   	push   %esi
  801c81:	53                   	push   %ebx
  801c82:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c85:	8b 45 08             	mov    0x8(%ebp),%eax
  801c88:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c8d:	8b 06                	mov    (%esi),%eax
  801c8f:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c94:	b8 01 00 00 00       	mov    $0x1,%eax
  801c99:	e8 8f ff ff ff       	call   801c2d <nsipc>
  801c9e:	89 c3                	mov    %eax,%ebx
  801ca0:	85 c0                	test   %eax,%eax
  801ca2:	79 09                	jns    801cad <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801ca4:	89 d8                	mov    %ebx,%eax
  801ca6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ca9:	5b                   	pop    %ebx
  801caa:	5e                   	pop    %esi
  801cab:	5d                   	pop    %ebp
  801cac:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cad:	83 ec 04             	sub    $0x4,%esp
  801cb0:	ff 35 10 60 80 00    	pushl  0x806010
  801cb6:	68 00 60 80 00       	push   $0x806000
  801cbb:	ff 75 0c             	pushl  0xc(%ebp)
  801cbe:	e8 51 ed ff ff       	call   800a14 <memmove>
		*addrlen = ret->ret_addrlen;
  801cc3:	a1 10 60 80 00       	mov    0x806010,%eax
  801cc8:	89 06                	mov    %eax,(%esi)
  801cca:	83 c4 10             	add    $0x10,%esp
	return r;
  801ccd:	eb d5                	jmp    801ca4 <nsipc_accept+0x2b>

00801ccf <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ccf:	f3 0f 1e fb          	endbr32 
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	53                   	push   %ebx
  801cd7:	83 ec 08             	sub    $0x8,%esp
  801cda:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801cdd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ce5:	53                   	push   %ebx
  801ce6:	ff 75 0c             	pushl  0xc(%ebp)
  801ce9:	68 04 60 80 00       	push   $0x806004
  801cee:	e8 21 ed ff ff       	call   800a14 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801cf3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801cf9:	b8 02 00 00 00       	mov    $0x2,%eax
  801cfe:	e8 2a ff ff ff       	call   801c2d <nsipc>
}
  801d03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d06:	c9                   	leave  
  801d07:	c3                   	ret    

00801d08 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d08:	f3 0f 1e fb          	endbr32 
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d12:	8b 45 08             	mov    0x8(%ebp),%eax
  801d15:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d22:	b8 03 00 00 00       	mov    $0x3,%eax
  801d27:	e8 01 ff ff ff       	call   801c2d <nsipc>
}
  801d2c:	c9                   	leave  
  801d2d:	c3                   	ret    

00801d2e <nsipc_close>:

int
nsipc_close(int s)
{
  801d2e:	f3 0f 1e fb          	endbr32 
  801d32:	55                   	push   %ebp
  801d33:	89 e5                	mov    %esp,%ebp
  801d35:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d38:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d40:	b8 04 00 00 00       	mov    $0x4,%eax
  801d45:	e8 e3 fe ff ff       	call   801c2d <nsipc>
}
  801d4a:	c9                   	leave  
  801d4b:	c3                   	ret    

00801d4c <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d4c:	f3 0f 1e fb          	endbr32 
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	53                   	push   %ebx
  801d54:	83 ec 08             	sub    $0x8,%esp
  801d57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d62:	53                   	push   %ebx
  801d63:	ff 75 0c             	pushl  0xc(%ebp)
  801d66:	68 04 60 80 00       	push   $0x806004
  801d6b:	e8 a4 ec ff ff       	call   800a14 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d70:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d76:	b8 05 00 00 00       	mov    $0x5,%eax
  801d7b:	e8 ad fe ff ff       	call   801c2d <nsipc>
}
  801d80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d83:	c9                   	leave  
  801d84:	c3                   	ret    

00801d85 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d85:	f3 0f 1e fb          	endbr32 
  801d89:	55                   	push   %ebp
  801d8a:	89 e5                	mov    %esp,%ebp
  801d8c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d92:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d97:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d9f:	b8 06 00 00 00       	mov    $0x6,%eax
  801da4:	e8 84 fe ff ff       	call   801c2d <nsipc>
}
  801da9:	c9                   	leave  
  801daa:	c3                   	ret    

00801dab <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801dab:	f3 0f 1e fb          	endbr32 
  801daf:	55                   	push   %ebp
  801db0:	89 e5                	mov    %esp,%ebp
  801db2:	56                   	push   %esi
  801db3:	53                   	push   %ebx
  801db4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801db7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dba:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801dbf:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801dc5:	8b 45 14             	mov    0x14(%ebp),%eax
  801dc8:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801dcd:	b8 07 00 00 00       	mov    $0x7,%eax
  801dd2:	e8 56 fe ff ff       	call   801c2d <nsipc>
  801dd7:	89 c3                	mov    %eax,%ebx
  801dd9:	85 c0                	test   %eax,%eax
  801ddb:	78 26                	js     801e03 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801ddd:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801de3:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801de8:	0f 4e c6             	cmovle %esi,%eax
  801deb:	39 c3                	cmp    %eax,%ebx
  801ded:	7f 1d                	jg     801e0c <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801def:	83 ec 04             	sub    $0x4,%esp
  801df2:	53                   	push   %ebx
  801df3:	68 00 60 80 00       	push   $0x806000
  801df8:	ff 75 0c             	pushl  0xc(%ebp)
  801dfb:	e8 14 ec ff ff       	call   800a14 <memmove>
  801e00:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e03:	89 d8                	mov    %ebx,%eax
  801e05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e08:	5b                   	pop    %ebx
  801e09:	5e                   	pop    %esi
  801e0a:	5d                   	pop    %ebp
  801e0b:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801e0c:	68 e3 2c 80 00       	push   $0x802ce3
  801e11:	68 4b 2c 80 00       	push   $0x802c4b
  801e16:	6a 62                	push   $0x62
  801e18:	68 f8 2c 80 00       	push   $0x802cf8
  801e1d:	e8 8b 05 00 00       	call   8023ad <_panic>

00801e22 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e22:	f3 0f 1e fb          	endbr32 
  801e26:	55                   	push   %ebp
  801e27:	89 e5                	mov    %esp,%ebp
  801e29:	53                   	push   %ebx
  801e2a:	83 ec 04             	sub    $0x4,%esp
  801e2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e30:	8b 45 08             	mov    0x8(%ebp),%eax
  801e33:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e38:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e3e:	7f 2e                	jg     801e6e <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e40:	83 ec 04             	sub    $0x4,%esp
  801e43:	53                   	push   %ebx
  801e44:	ff 75 0c             	pushl  0xc(%ebp)
  801e47:	68 0c 60 80 00       	push   $0x80600c
  801e4c:	e8 c3 eb ff ff       	call   800a14 <memmove>
	nsipcbuf.send.req_size = size;
  801e51:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e57:	8b 45 14             	mov    0x14(%ebp),%eax
  801e5a:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e5f:	b8 08 00 00 00       	mov    $0x8,%eax
  801e64:	e8 c4 fd ff ff       	call   801c2d <nsipc>
}
  801e69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e6c:	c9                   	leave  
  801e6d:	c3                   	ret    
	assert(size < 1600);
  801e6e:	68 04 2d 80 00       	push   $0x802d04
  801e73:	68 4b 2c 80 00       	push   $0x802c4b
  801e78:	6a 6d                	push   $0x6d
  801e7a:	68 f8 2c 80 00       	push   $0x802cf8
  801e7f:	e8 29 05 00 00       	call   8023ad <_panic>

00801e84 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e84:	f3 0f 1e fb          	endbr32 
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e91:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e96:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e99:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e9e:	8b 45 10             	mov    0x10(%ebp),%eax
  801ea1:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ea6:	b8 09 00 00 00       	mov    $0x9,%eax
  801eab:	e8 7d fd ff ff       	call   801c2d <nsipc>
}
  801eb0:	c9                   	leave  
  801eb1:	c3                   	ret    

00801eb2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801eb2:	f3 0f 1e fb          	endbr32 
  801eb6:	55                   	push   %ebp
  801eb7:	89 e5                	mov    %esp,%ebp
  801eb9:	56                   	push   %esi
  801eba:	53                   	push   %ebx
  801ebb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ebe:	83 ec 0c             	sub    $0xc,%esp
  801ec1:	ff 75 08             	pushl  0x8(%ebp)
  801ec4:	e8 f0 f2 ff ff       	call   8011b9 <fd2data>
  801ec9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ecb:	83 c4 08             	add    $0x8,%esp
  801ece:	68 10 2d 80 00       	push   $0x802d10
  801ed3:	53                   	push   %ebx
  801ed4:	e8 3d e9 ff ff       	call   800816 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ed9:	8b 46 04             	mov    0x4(%esi),%eax
  801edc:	2b 06                	sub    (%esi),%eax
  801ede:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ee4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801eeb:	00 00 00 
	stat->st_dev = &devpipe;
  801eee:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801ef5:	30 80 00 
	return 0;
}
  801ef8:	b8 00 00 00 00       	mov    $0x0,%eax
  801efd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f00:	5b                   	pop    %ebx
  801f01:	5e                   	pop    %esi
  801f02:	5d                   	pop    %ebp
  801f03:	c3                   	ret    

00801f04 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f04:	f3 0f 1e fb          	endbr32 
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	53                   	push   %ebx
  801f0c:	83 ec 0c             	sub    $0xc,%esp
  801f0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f12:	53                   	push   %ebx
  801f13:	6a 00                	push   $0x0
  801f15:	e8 b0 ed ff ff       	call   800cca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f1a:	89 1c 24             	mov    %ebx,(%esp)
  801f1d:	e8 97 f2 ff ff       	call   8011b9 <fd2data>
  801f22:	83 c4 08             	add    $0x8,%esp
  801f25:	50                   	push   %eax
  801f26:	6a 00                	push   $0x0
  801f28:	e8 9d ed ff ff       	call   800cca <sys_page_unmap>
}
  801f2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f30:	c9                   	leave  
  801f31:	c3                   	ret    

00801f32 <_pipeisclosed>:
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	57                   	push   %edi
  801f36:	56                   	push   %esi
  801f37:	53                   	push   %ebx
  801f38:	83 ec 1c             	sub    $0x1c,%esp
  801f3b:	89 c7                	mov    %eax,%edi
  801f3d:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801f3f:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801f44:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f47:	83 ec 0c             	sub    $0xc,%esp
  801f4a:	57                   	push   %edi
  801f4b:	e8 3e 05 00 00       	call   80248e <pageref>
  801f50:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f53:	89 34 24             	mov    %esi,(%esp)
  801f56:	e8 33 05 00 00       	call   80248e <pageref>
		nn = thisenv->env_runs;
  801f5b:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801f61:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f64:	83 c4 10             	add    $0x10,%esp
  801f67:	39 cb                	cmp    %ecx,%ebx
  801f69:	74 1b                	je     801f86 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801f6b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f6e:	75 cf                	jne    801f3f <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f70:	8b 42 58             	mov    0x58(%edx),%eax
  801f73:	6a 01                	push   $0x1
  801f75:	50                   	push   %eax
  801f76:	53                   	push   %ebx
  801f77:	68 17 2d 80 00       	push   $0x802d17
  801f7c:	e8 8b e2 ff ff       	call   80020c <cprintf>
  801f81:	83 c4 10             	add    $0x10,%esp
  801f84:	eb b9                	jmp    801f3f <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801f86:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f89:	0f 94 c0             	sete   %al
  801f8c:	0f b6 c0             	movzbl %al,%eax
}
  801f8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f92:	5b                   	pop    %ebx
  801f93:	5e                   	pop    %esi
  801f94:	5f                   	pop    %edi
  801f95:	5d                   	pop    %ebp
  801f96:	c3                   	ret    

00801f97 <devpipe_write>:
{
  801f97:	f3 0f 1e fb          	endbr32 
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	57                   	push   %edi
  801f9f:	56                   	push   %esi
  801fa0:	53                   	push   %ebx
  801fa1:	83 ec 28             	sub    $0x28,%esp
  801fa4:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801fa7:	56                   	push   %esi
  801fa8:	e8 0c f2 ff ff       	call   8011b9 <fd2data>
  801fad:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801faf:	83 c4 10             	add    $0x10,%esp
  801fb2:	bf 00 00 00 00       	mov    $0x0,%edi
  801fb7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fba:	74 4f                	je     80200b <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fbc:	8b 43 04             	mov    0x4(%ebx),%eax
  801fbf:	8b 0b                	mov    (%ebx),%ecx
  801fc1:	8d 51 20             	lea    0x20(%ecx),%edx
  801fc4:	39 d0                	cmp    %edx,%eax
  801fc6:	72 14                	jb     801fdc <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801fc8:	89 da                	mov    %ebx,%edx
  801fca:	89 f0                	mov    %esi,%eax
  801fcc:	e8 61 ff ff ff       	call   801f32 <_pipeisclosed>
  801fd1:	85 c0                	test   %eax,%eax
  801fd3:	75 3b                	jne    802010 <devpipe_write+0x79>
			sys_yield();
  801fd5:	e8 82 ec ff ff       	call   800c5c <sys_yield>
  801fda:	eb e0                	jmp    801fbc <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fdf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fe3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fe6:	89 c2                	mov    %eax,%edx
  801fe8:	c1 fa 1f             	sar    $0x1f,%edx
  801feb:	89 d1                	mov    %edx,%ecx
  801fed:	c1 e9 1b             	shr    $0x1b,%ecx
  801ff0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ff3:	83 e2 1f             	and    $0x1f,%edx
  801ff6:	29 ca                	sub    %ecx,%edx
  801ff8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ffc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802000:	83 c0 01             	add    $0x1,%eax
  802003:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802006:	83 c7 01             	add    $0x1,%edi
  802009:	eb ac                	jmp    801fb7 <devpipe_write+0x20>
	return i;
  80200b:	8b 45 10             	mov    0x10(%ebp),%eax
  80200e:	eb 05                	jmp    802015 <devpipe_write+0x7e>
				return 0;
  802010:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802015:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802018:	5b                   	pop    %ebx
  802019:	5e                   	pop    %esi
  80201a:	5f                   	pop    %edi
  80201b:	5d                   	pop    %ebp
  80201c:	c3                   	ret    

0080201d <devpipe_read>:
{
  80201d:	f3 0f 1e fb          	endbr32 
  802021:	55                   	push   %ebp
  802022:	89 e5                	mov    %esp,%ebp
  802024:	57                   	push   %edi
  802025:	56                   	push   %esi
  802026:	53                   	push   %ebx
  802027:	83 ec 18             	sub    $0x18,%esp
  80202a:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80202d:	57                   	push   %edi
  80202e:	e8 86 f1 ff ff       	call   8011b9 <fd2data>
  802033:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802035:	83 c4 10             	add    $0x10,%esp
  802038:	be 00 00 00 00       	mov    $0x0,%esi
  80203d:	3b 75 10             	cmp    0x10(%ebp),%esi
  802040:	75 14                	jne    802056 <devpipe_read+0x39>
	return i;
  802042:	8b 45 10             	mov    0x10(%ebp),%eax
  802045:	eb 02                	jmp    802049 <devpipe_read+0x2c>
				return i;
  802047:	89 f0                	mov    %esi,%eax
}
  802049:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80204c:	5b                   	pop    %ebx
  80204d:	5e                   	pop    %esi
  80204e:	5f                   	pop    %edi
  80204f:	5d                   	pop    %ebp
  802050:	c3                   	ret    
			sys_yield();
  802051:	e8 06 ec ff ff       	call   800c5c <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802056:	8b 03                	mov    (%ebx),%eax
  802058:	3b 43 04             	cmp    0x4(%ebx),%eax
  80205b:	75 18                	jne    802075 <devpipe_read+0x58>
			if (i > 0)
  80205d:	85 f6                	test   %esi,%esi
  80205f:	75 e6                	jne    802047 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  802061:	89 da                	mov    %ebx,%edx
  802063:	89 f8                	mov    %edi,%eax
  802065:	e8 c8 fe ff ff       	call   801f32 <_pipeisclosed>
  80206a:	85 c0                	test   %eax,%eax
  80206c:	74 e3                	je     802051 <devpipe_read+0x34>
				return 0;
  80206e:	b8 00 00 00 00       	mov    $0x0,%eax
  802073:	eb d4                	jmp    802049 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802075:	99                   	cltd   
  802076:	c1 ea 1b             	shr    $0x1b,%edx
  802079:	01 d0                	add    %edx,%eax
  80207b:	83 e0 1f             	and    $0x1f,%eax
  80207e:	29 d0                	sub    %edx,%eax
  802080:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802085:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802088:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80208b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80208e:	83 c6 01             	add    $0x1,%esi
  802091:	eb aa                	jmp    80203d <devpipe_read+0x20>

00802093 <pipe>:
{
  802093:	f3 0f 1e fb          	endbr32 
  802097:	55                   	push   %ebp
  802098:	89 e5                	mov    %esp,%ebp
  80209a:	56                   	push   %esi
  80209b:	53                   	push   %ebx
  80209c:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80209f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a2:	50                   	push   %eax
  8020a3:	e8 2c f1 ff ff       	call   8011d4 <fd_alloc>
  8020a8:	89 c3                	mov    %eax,%ebx
  8020aa:	83 c4 10             	add    $0x10,%esp
  8020ad:	85 c0                	test   %eax,%eax
  8020af:	0f 88 23 01 00 00    	js     8021d8 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020b5:	83 ec 04             	sub    $0x4,%esp
  8020b8:	68 07 04 00 00       	push   $0x407
  8020bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8020c0:	6a 00                	push   $0x0
  8020c2:	e8 b8 eb ff ff       	call   800c7f <sys_page_alloc>
  8020c7:	89 c3                	mov    %eax,%ebx
  8020c9:	83 c4 10             	add    $0x10,%esp
  8020cc:	85 c0                	test   %eax,%eax
  8020ce:	0f 88 04 01 00 00    	js     8021d8 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8020d4:	83 ec 0c             	sub    $0xc,%esp
  8020d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020da:	50                   	push   %eax
  8020db:	e8 f4 f0 ff ff       	call   8011d4 <fd_alloc>
  8020e0:	89 c3                	mov    %eax,%ebx
  8020e2:	83 c4 10             	add    $0x10,%esp
  8020e5:	85 c0                	test   %eax,%eax
  8020e7:	0f 88 db 00 00 00    	js     8021c8 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ed:	83 ec 04             	sub    $0x4,%esp
  8020f0:	68 07 04 00 00       	push   $0x407
  8020f5:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f8:	6a 00                	push   $0x0
  8020fa:	e8 80 eb ff ff       	call   800c7f <sys_page_alloc>
  8020ff:	89 c3                	mov    %eax,%ebx
  802101:	83 c4 10             	add    $0x10,%esp
  802104:	85 c0                	test   %eax,%eax
  802106:	0f 88 bc 00 00 00    	js     8021c8 <pipe+0x135>
	va = fd2data(fd0);
  80210c:	83 ec 0c             	sub    $0xc,%esp
  80210f:	ff 75 f4             	pushl  -0xc(%ebp)
  802112:	e8 a2 f0 ff ff       	call   8011b9 <fd2data>
  802117:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802119:	83 c4 0c             	add    $0xc,%esp
  80211c:	68 07 04 00 00       	push   $0x407
  802121:	50                   	push   %eax
  802122:	6a 00                	push   $0x0
  802124:	e8 56 eb ff ff       	call   800c7f <sys_page_alloc>
  802129:	89 c3                	mov    %eax,%ebx
  80212b:	83 c4 10             	add    $0x10,%esp
  80212e:	85 c0                	test   %eax,%eax
  802130:	0f 88 82 00 00 00    	js     8021b8 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802136:	83 ec 0c             	sub    $0xc,%esp
  802139:	ff 75 f0             	pushl  -0x10(%ebp)
  80213c:	e8 78 f0 ff ff       	call   8011b9 <fd2data>
  802141:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802148:	50                   	push   %eax
  802149:	6a 00                	push   $0x0
  80214b:	56                   	push   %esi
  80214c:	6a 00                	push   $0x0
  80214e:	e8 52 eb ff ff       	call   800ca5 <sys_page_map>
  802153:	89 c3                	mov    %eax,%ebx
  802155:	83 c4 20             	add    $0x20,%esp
  802158:	85 c0                	test   %eax,%eax
  80215a:	78 4e                	js     8021aa <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  80215c:	a1 7c 30 80 00       	mov    0x80307c,%eax
  802161:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802164:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802166:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802169:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802170:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802173:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802175:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802178:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80217f:	83 ec 0c             	sub    $0xc,%esp
  802182:	ff 75 f4             	pushl  -0xc(%ebp)
  802185:	e8 1b f0 ff ff       	call   8011a5 <fd2num>
  80218a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80218d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80218f:	83 c4 04             	add    $0x4,%esp
  802192:	ff 75 f0             	pushl  -0x10(%ebp)
  802195:	e8 0b f0 ff ff       	call   8011a5 <fd2num>
  80219a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80219d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021a0:	83 c4 10             	add    $0x10,%esp
  8021a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021a8:	eb 2e                	jmp    8021d8 <pipe+0x145>
	sys_page_unmap(0, va);
  8021aa:	83 ec 08             	sub    $0x8,%esp
  8021ad:	56                   	push   %esi
  8021ae:	6a 00                	push   $0x0
  8021b0:	e8 15 eb ff ff       	call   800cca <sys_page_unmap>
  8021b5:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8021b8:	83 ec 08             	sub    $0x8,%esp
  8021bb:	ff 75 f0             	pushl  -0x10(%ebp)
  8021be:	6a 00                	push   $0x0
  8021c0:	e8 05 eb ff ff       	call   800cca <sys_page_unmap>
  8021c5:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8021c8:	83 ec 08             	sub    $0x8,%esp
  8021cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8021ce:	6a 00                	push   $0x0
  8021d0:	e8 f5 ea ff ff       	call   800cca <sys_page_unmap>
  8021d5:	83 c4 10             	add    $0x10,%esp
}
  8021d8:	89 d8                	mov    %ebx,%eax
  8021da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5d                   	pop    %ebp
  8021e0:	c3                   	ret    

008021e1 <pipeisclosed>:
{
  8021e1:	f3 0f 1e fb          	endbr32 
  8021e5:	55                   	push   %ebp
  8021e6:	89 e5                	mov    %esp,%ebp
  8021e8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ee:	50                   	push   %eax
  8021ef:	ff 75 08             	pushl  0x8(%ebp)
  8021f2:	e8 33 f0 ff ff       	call   80122a <fd_lookup>
  8021f7:	83 c4 10             	add    $0x10,%esp
  8021fa:	85 c0                	test   %eax,%eax
  8021fc:	78 18                	js     802216 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  8021fe:	83 ec 0c             	sub    $0xc,%esp
  802201:	ff 75 f4             	pushl  -0xc(%ebp)
  802204:	e8 b0 ef ff ff       	call   8011b9 <fd2data>
  802209:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80220b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220e:	e8 1f fd ff ff       	call   801f32 <_pipeisclosed>
  802213:	83 c4 10             	add    $0x10,%esp
}
  802216:	c9                   	leave  
  802217:	c3                   	ret    

00802218 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802218:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  80221c:	b8 00 00 00 00       	mov    $0x0,%eax
  802221:	c3                   	ret    

00802222 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802222:	f3 0f 1e fb          	endbr32 
  802226:	55                   	push   %ebp
  802227:	89 e5                	mov    %esp,%ebp
  802229:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80222c:	68 2f 2d 80 00       	push   $0x802d2f
  802231:	ff 75 0c             	pushl  0xc(%ebp)
  802234:	e8 dd e5 ff ff       	call   800816 <strcpy>
	return 0;
}
  802239:	b8 00 00 00 00       	mov    $0x0,%eax
  80223e:	c9                   	leave  
  80223f:	c3                   	ret    

00802240 <devcons_write>:
{
  802240:	f3 0f 1e fb          	endbr32 
  802244:	55                   	push   %ebp
  802245:	89 e5                	mov    %esp,%ebp
  802247:	57                   	push   %edi
  802248:	56                   	push   %esi
  802249:	53                   	push   %ebx
  80224a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802250:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802255:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80225b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80225e:	73 31                	jae    802291 <devcons_write+0x51>
		m = n - tot;
  802260:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802263:	29 f3                	sub    %esi,%ebx
  802265:	83 fb 7f             	cmp    $0x7f,%ebx
  802268:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80226d:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802270:	83 ec 04             	sub    $0x4,%esp
  802273:	53                   	push   %ebx
  802274:	89 f0                	mov    %esi,%eax
  802276:	03 45 0c             	add    0xc(%ebp),%eax
  802279:	50                   	push   %eax
  80227a:	57                   	push   %edi
  80227b:	e8 94 e7 ff ff       	call   800a14 <memmove>
		sys_cputs(buf, m);
  802280:	83 c4 08             	add    $0x8,%esp
  802283:	53                   	push   %ebx
  802284:	57                   	push   %edi
  802285:	e8 46 e9 ff ff       	call   800bd0 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80228a:	01 de                	add    %ebx,%esi
  80228c:	83 c4 10             	add    $0x10,%esp
  80228f:	eb ca                	jmp    80225b <devcons_write+0x1b>
}
  802291:	89 f0                	mov    %esi,%eax
  802293:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802296:	5b                   	pop    %ebx
  802297:	5e                   	pop    %esi
  802298:	5f                   	pop    %edi
  802299:	5d                   	pop    %ebp
  80229a:	c3                   	ret    

0080229b <devcons_read>:
{
  80229b:	f3 0f 1e fb          	endbr32 
  80229f:	55                   	push   %ebp
  8022a0:	89 e5                	mov    %esp,%ebp
  8022a2:	83 ec 08             	sub    $0x8,%esp
  8022a5:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8022aa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022ae:	74 21                	je     8022d1 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8022b0:	e8 3d e9 ff ff       	call   800bf2 <sys_cgetc>
  8022b5:	85 c0                	test   %eax,%eax
  8022b7:	75 07                	jne    8022c0 <devcons_read+0x25>
		sys_yield();
  8022b9:	e8 9e e9 ff ff       	call   800c5c <sys_yield>
  8022be:	eb f0                	jmp    8022b0 <devcons_read+0x15>
	if (c < 0)
  8022c0:	78 0f                	js     8022d1 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8022c2:	83 f8 04             	cmp    $0x4,%eax
  8022c5:	74 0c                	je     8022d3 <devcons_read+0x38>
	*(char*)vbuf = c;
  8022c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022ca:	88 02                	mov    %al,(%edx)
	return 1;
  8022cc:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8022d1:	c9                   	leave  
  8022d2:	c3                   	ret    
		return 0;
  8022d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8022d8:	eb f7                	jmp    8022d1 <devcons_read+0x36>

008022da <cputchar>:
{
  8022da:	f3 0f 1e fb          	endbr32 
  8022de:	55                   	push   %ebp
  8022df:	89 e5                	mov    %esp,%ebp
  8022e1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e7:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8022ea:	6a 01                	push   $0x1
  8022ec:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022ef:	50                   	push   %eax
  8022f0:	e8 db e8 ff ff       	call   800bd0 <sys_cputs>
}
  8022f5:	83 c4 10             	add    $0x10,%esp
  8022f8:	c9                   	leave  
  8022f9:	c3                   	ret    

008022fa <getchar>:
{
  8022fa:	f3 0f 1e fb          	endbr32 
  8022fe:	55                   	push   %ebp
  8022ff:	89 e5                	mov    %esp,%ebp
  802301:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802304:	6a 01                	push   $0x1
  802306:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802309:	50                   	push   %eax
  80230a:	6a 00                	push   $0x0
  80230c:	e8 a1 f1 ff ff       	call   8014b2 <read>
	if (r < 0)
  802311:	83 c4 10             	add    $0x10,%esp
  802314:	85 c0                	test   %eax,%eax
  802316:	78 06                	js     80231e <getchar+0x24>
	if (r < 1)
  802318:	74 06                	je     802320 <getchar+0x26>
	return c;
  80231a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80231e:	c9                   	leave  
  80231f:	c3                   	ret    
		return -E_EOF;
  802320:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802325:	eb f7                	jmp    80231e <getchar+0x24>

00802327 <iscons>:
{
  802327:	f3 0f 1e fb          	endbr32 
  80232b:	55                   	push   %ebp
  80232c:	89 e5                	mov    %esp,%ebp
  80232e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802331:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802334:	50                   	push   %eax
  802335:	ff 75 08             	pushl  0x8(%ebp)
  802338:	e8 ed ee ff ff       	call   80122a <fd_lookup>
  80233d:	83 c4 10             	add    $0x10,%esp
  802340:	85 c0                	test   %eax,%eax
  802342:	78 11                	js     802355 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  802344:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802347:	8b 15 98 30 80 00    	mov    0x803098,%edx
  80234d:	39 10                	cmp    %edx,(%eax)
  80234f:	0f 94 c0             	sete   %al
  802352:	0f b6 c0             	movzbl %al,%eax
}
  802355:	c9                   	leave  
  802356:	c3                   	ret    

00802357 <opencons>:
{
  802357:	f3 0f 1e fb          	endbr32 
  80235b:	55                   	push   %ebp
  80235c:	89 e5                	mov    %esp,%ebp
  80235e:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802361:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802364:	50                   	push   %eax
  802365:	e8 6a ee ff ff       	call   8011d4 <fd_alloc>
  80236a:	83 c4 10             	add    $0x10,%esp
  80236d:	85 c0                	test   %eax,%eax
  80236f:	78 3a                	js     8023ab <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802371:	83 ec 04             	sub    $0x4,%esp
  802374:	68 07 04 00 00       	push   $0x407
  802379:	ff 75 f4             	pushl  -0xc(%ebp)
  80237c:	6a 00                	push   $0x0
  80237e:	e8 fc e8 ff ff       	call   800c7f <sys_page_alloc>
  802383:	83 c4 10             	add    $0x10,%esp
  802386:	85 c0                	test   %eax,%eax
  802388:	78 21                	js     8023ab <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80238a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80238d:	8b 15 98 30 80 00    	mov    0x803098,%edx
  802393:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802395:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802398:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80239f:	83 ec 0c             	sub    $0xc,%esp
  8023a2:	50                   	push   %eax
  8023a3:	e8 fd ed ff ff       	call   8011a5 <fd2num>
  8023a8:	83 c4 10             	add    $0x10,%esp
}
  8023ab:	c9                   	leave  
  8023ac:	c3                   	ret    

008023ad <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8023ad:	f3 0f 1e fb          	endbr32 
  8023b1:	55                   	push   %ebp
  8023b2:	89 e5                	mov    %esp,%ebp
  8023b4:	56                   	push   %esi
  8023b5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8023b6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8023b9:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8023bf:	e8 75 e8 ff ff       	call   800c39 <sys_getenvid>
  8023c4:	83 ec 0c             	sub    $0xc,%esp
  8023c7:	ff 75 0c             	pushl  0xc(%ebp)
  8023ca:	ff 75 08             	pushl  0x8(%ebp)
  8023cd:	56                   	push   %esi
  8023ce:	50                   	push   %eax
  8023cf:	68 3c 2d 80 00       	push   $0x802d3c
  8023d4:	e8 33 de ff ff       	call   80020c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8023d9:	83 c4 18             	add    $0x18,%esp
  8023dc:	53                   	push   %ebx
  8023dd:	ff 75 10             	pushl  0x10(%ebp)
  8023e0:	e8 d2 dd ff ff       	call   8001b7 <vcprintf>
	cprintf("\n");
  8023e5:	c7 04 24 28 2d 80 00 	movl   $0x802d28,(%esp)
  8023ec:	e8 1b de ff ff       	call   80020c <cprintf>
  8023f1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8023f4:	cc                   	int3   
  8023f5:	eb fd                	jmp    8023f4 <_panic+0x47>

008023f7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023f7:	f3 0f 1e fb          	endbr32 
  8023fb:	55                   	push   %ebp
  8023fc:	89 e5                	mov    %esp,%ebp
  8023fe:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802401:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802408:	74 0a                	je     802414 <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80240a:	8b 45 08             	mov    0x8(%ebp),%eax
  80240d:	a3 00 70 80 00       	mov    %eax,0x807000

}
  802412:	c9                   	leave  
  802413:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  802414:	83 ec 04             	sub    $0x4,%esp
  802417:	6a 07                	push   $0x7
  802419:	68 00 f0 bf ee       	push   $0xeebff000
  80241e:	6a 00                	push   $0x0
  802420:	e8 5a e8 ff ff       	call   800c7f <sys_page_alloc>
  802425:	83 c4 10             	add    $0x10,%esp
  802428:	85 c0                	test   %eax,%eax
  80242a:	78 2a                	js     802456 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  80242c:	83 ec 08             	sub    $0x8,%esp
  80242f:	68 6a 24 80 00       	push   $0x80246a
  802434:	6a 00                	push   $0x0
  802436:	e8 fe e8 ff ff       	call   800d39 <sys_env_set_pgfault_upcall>
  80243b:	83 c4 10             	add    $0x10,%esp
  80243e:	85 c0                	test   %eax,%eax
  802440:	79 c8                	jns    80240a <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  802442:	83 ec 04             	sub    $0x4,%esp
  802445:	68 8c 2d 80 00       	push   $0x802d8c
  80244a:	6a 2c                	push   $0x2c
  80244c:	68 c2 2d 80 00       	push   $0x802dc2
  802451:	e8 57 ff ff ff       	call   8023ad <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  802456:	83 ec 04             	sub    $0x4,%esp
  802459:	68 60 2d 80 00       	push   $0x802d60
  80245e:	6a 22                	push   $0x22
  802460:	68 c2 2d 80 00       	push   $0x802dc2
  802465:	e8 43 ff ff ff       	call   8023ad <_panic>

0080246a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80246a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80246b:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax   			// 间接寻址
  802470:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802472:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  802475:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  802479:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  80247e:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  802482:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  802484:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  802487:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  802488:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  80248b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  80248c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  80248d:	c3                   	ret    

0080248e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80248e:	f3 0f 1e fb          	endbr32 
  802492:	55                   	push   %ebp
  802493:	89 e5                	mov    %esp,%ebp
  802495:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802498:	89 c2                	mov    %eax,%edx
  80249a:	c1 ea 16             	shr    $0x16,%edx
  80249d:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8024a4:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8024a9:	f6 c1 01             	test   $0x1,%cl
  8024ac:	74 1c                	je     8024ca <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8024ae:	c1 e8 0c             	shr    $0xc,%eax
  8024b1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8024b8:	a8 01                	test   $0x1,%al
  8024ba:	74 0e                	je     8024ca <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024bc:	c1 e8 0c             	shr    $0xc,%eax
  8024bf:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8024c6:	ef 
  8024c7:	0f b7 d2             	movzwl %dx,%edx
}
  8024ca:	89 d0                	mov    %edx,%eax
  8024cc:	5d                   	pop    %ebp
  8024cd:	c3                   	ret    
  8024ce:	66 90                	xchg   %ax,%ax

008024d0 <__udivdi3>:
  8024d0:	f3 0f 1e fb          	endbr32 
  8024d4:	55                   	push   %ebp
  8024d5:	57                   	push   %edi
  8024d6:	56                   	push   %esi
  8024d7:	53                   	push   %ebx
  8024d8:	83 ec 1c             	sub    $0x1c,%esp
  8024db:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8024df:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8024e3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024e7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8024eb:	85 d2                	test   %edx,%edx
  8024ed:	75 19                	jne    802508 <__udivdi3+0x38>
  8024ef:	39 f3                	cmp    %esi,%ebx
  8024f1:	76 4d                	jbe    802540 <__udivdi3+0x70>
  8024f3:	31 ff                	xor    %edi,%edi
  8024f5:	89 e8                	mov    %ebp,%eax
  8024f7:	89 f2                	mov    %esi,%edx
  8024f9:	f7 f3                	div    %ebx
  8024fb:	89 fa                	mov    %edi,%edx
  8024fd:	83 c4 1c             	add    $0x1c,%esp
  802500:	5b                   	pop    %ebx
  802501:	5e                   	pop    %esi
  802502:	5f                   	pop    %edi
  802503:	5d                   	pop    %ebp
  802504:	c3                   	ret    
  802505:	8d 76 00             	lea    0x0(%esi),%esi
  802508:	39 f2                	cmp    %esi,%edx
  80250a:	76 14                	jbe    802520 <__udivdi3+0x50>
  80250c:	31 ff                	xor    %edi,%edi
  80250e:	31 c0                	xor    %eax,%eax
  802510:	89 fa                	mov    %edi,%edx
  802512:	83 c4 1c             	add    $0x1c,%esp
  802515:	5b                   	pop    %ebx
  802516:	5e                   	pop    %esi
  802517:	5f                   	pop    %edi
  802518:	5d                   	pop    %ebp
  802519:	c3                   	ret    
  80251a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802520:	0f bd fa             	bsr    %edx,%edi
  802523:	83 f7 1f             	xor    $0x1f,%edi
  802526:	75 48                	jne    802570 <__udivdi3+0xa0>
  802528:	39 f2                	cmp    %esi,%edx
  80252a:	72 06                	jb     802532 <__udivdi3+0x62>
  80252c:	31 c0                	xor    %eax,%eax
  80252e:	39 eb                	cmp    %ebp,%ebx
  802530:	77 de                	ja     802510 <__udivdi3+0x40>
  802532:	b8 01 00 00 00       	mov    $0x1,%eax
  802537:	eb d7                	jmp    802510 <__udivdi3+0x40>
  802539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802540:	89 d9                	mov    %ebx,%ecx
  802542:	85 db                	test   %ebx,%ebx
  802544:	75 0b                	jne    802551 <__udivdi3+0x81>
  802546:	b8 01 00 00 00       	mov    $0x1,%eax
  80254b:	31 d2                	xor    %edx,%edx
  80254d:	f7 f3                	div    %ebx
  80254f:	89 c1                	mov    %eax,%ecx
  802551:	31 d2                	xor    %edx,%edx
  802553:	89 f0                	mov    %esi,%eax
  802555:	f7 f1                	div    %ecx
  802557:	89 c6                	mov    %eax,%esi
  802559:	89 e8                	mov    %ebp,%eax
  80255b:	89 f7                	mov    %esi,%edi
  80255d:	f7 f1                	div    %ecx
  80255f:	89 fa                	mov    %edi,%edx
  802561:	83 c4 1c             	add    $0x1c,%esp
  802564:	5b                   	pop    %ebx
  802565:	5e                   	pop    %esi
  802566:	5f                   	pop    %edi
  802567:	5d                   	pop    %ebp
  802568:	c3                   	ret    
  802569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802570:	89 f9                	mov    %edi,%ecx
  802572:	b8 20 00 00 00       	mov    $0x20,%eax
  802577:	29 f8                	sub    %edi,%eax
  802579:	d3 e2                	shl    %cl,%edx
  80257b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80257f:	89 c1                	mov    %eax,%ecx
  802581:	89 da                	mov    %ebx,%edx
  802583:	d3 ea                	shr    %cl,%edx
  802585:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802589:	09 d1                	or     %edx,%ecx
  80258b:	89 f2                	mov    %esi,%edx
  80258d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802591:	89 f9                	mov    %edi,%ecx
  802593:	d3 e3                	shl    %cl,%ebx
  802595:	89 c1                	mov    %eax,%ecx
  802597:	d3 ea                	shr    %cl,%edx
  802599:	89 f9                	mov    %edi,%ecx
  80259b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80259f:	89 eb                	mov    %ebp,%ebx
  8025a1:	d3 e6                	shl    %cl,%esi
  8025a3:	89 c1                	mov    %eax,%ecx
  8025a5:	d3 eb                	shr    %cl,%ebx
  8025a7:	09 de                	or     %ebx,%esi
  8025a9:	89 f0                	mov    %esi,%eax
  8025ab:	f7 74 24 08          	divl   0x8(%esp)
  8025af:	89 d6                	mov    %edx,%esi
  8025b1:	89 c3                	mov    %eax,%ebx
  8025b3:	f7 64 24 0c          	mull   0xc(%esp)
  8025b7:	39 d6                	cmp    %edx,%esi
  8025b9:	72 15                	jb     8025d0 <__udivdi3+0x100>
  8025bb:	89 f9                	mov    %edi,%ecx
  8025bd:	d3 e5                	shl    %cl,%ebp
  8025bf:	39 c5                	cmp    %eax,%ebp
  8025c1:	73 04                	jae    8025c7 <__udivdi3+0xf7>
  8025c3:	39 d6                	cmp    %edx,%esi
  8025c5:	74 09                	je     8025d0 <__udivdi3+0x100>
  8025c7:	89 d8                	mov    %ebx,%eax
  8025c9:	31 ff                	xor    %edi,%edi
  8025cb:	e9 40 ff ff ff       	jmp    802510 <__udivdi3+0x40>
  8025d0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8025d3:	31 ff                	xor    %edi,%edi
  8025d5:	e9 36 ff ff ff       	jmp    802510 <__udivdi3+0x40>
  8025da:	66 90                	xchg   %ax,%ax
  8025dc:	66 90                	xchg   %ax,%ax
  8025de:	66 90                	xchg   %ax,%ax

008025e0 <__umoddi3>:
  8025e0:	f3 0f 1e fb          	endbr32 
  8025e4:	55                   	push   %ebp
  8025e5:	57                   	push   %edi
  8025e6:	56                   	push   %esi
  8025e7:	53                   	push   %ebx
  8025e8:	83 ec 1c             	sub    $0x1c,%esp
  8025eb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8025ef:	8b 74 24 30          	mov    0x30(%esp),%esi
  8025f3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8025f7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025fb:	85 c0                	test   %eax,%eax
  8025fd:	75 19                	jne    802618 <__umoddi3+0x38>
  8025ff:	39 df                	cmp    %ebx,%edi
  802601:	76 5d                	jbe    802660 <__umoddi3+0x80>
  802603:	89 f0                	mov    %esi,%eax
  802605:	89 da                	mov    %ebx,%edx
  802607:	f7 f7                	div    %edi
  802609:	89 d0                	mov    %edx,%eax
  80260b:	31 d2                	xor    %edx,%edx
  80260d:	83 c4 1c             	add    $0x1c,%esp
  802610:	5b                   	pop    %ebx
  802611:	5e                   	pop    %esi
  802612:	5f                   	pop    %edi
  802613:	5d                   	pop    %ebp
  802614:	c3                   	ret    
  802615:	8d 76 00             	lea    0x0(%esi),%esi
  802618:	89 f2                	mov    %esi,%edx
  80261a:	39 d8                	cmp    %ebx,%eax
  80261c:	76 12                	jbe    802630 <__umoddi3+0x50>
  80261e:	89 f0                	mov    %esi,%eax
  802620:	89 da                	mov    %ebx,%edx
  802622:	83 c4 1c             	add    $0x1c,%esp
  802625:	5b                   	pop    %ebx
  802626:	5e                   	pop    %esi
  802627:	5f                   	pop    %edi
  802628:	5d                   	pop    %ebp
  802629:	c3                   	ret    
  80262a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802630:	0f bd e8             	bsr    %eax,%ebp
  802633:	83 f5 1f             	xor    $0x1f,%ebp
  802636:	75 50                	jne    802688 <__umoddi3+0xa8>
  802638:	39 d8                	cmp    %ebx,%eax
  80263a:	0f 82 e0 00 00 00    	jb     802720 <__umoddi3+0x140>
  802640:	89 d9                	mov    %ebx,%ecx
  802642:	39 f7                	cmp    %esi,%edi
  802644:	0f 86 d6 00 00 00    	jbe    802720 <__umoddi3+0x140>
  80264a:	89 d0                	mov    %edx,%eax
  80264c:	89 ca                	mov    %ecx,%edx
  80264e:	83 c4 1c             	add    $0x1c,%esp
  802651:	5b                   	pop    %ebx
  802652:	5e                   	pop    %esi
  802653:	5f                   	pop    %edi
  802654:	5d                   	pop    %ebp
  802655:	c3                   	ret    
  802656:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80265d:	8d 76 00             	lea    0x0(%esi),%esi
  802660:	89 fd                	mov    %edi,%ebp
  802662:	85 ff                	test   %edi,%edi
  802664:	75 0b                	jne    802671 <__umoddi3+0x91>
  802666:	b8 01 00 00 00       	mov    $0x1,%eax
  80266b:	31 d2                	xor    %edx,%edx
  80266d:	f7 f7                	div    %edi
  80266f:	89 c5                	mov    %eax,%ebp
  802671:	89 d8                	mov    %ebx,%eax
  802673:	31 d2                	xor    %edx,%edx
  802675:	f7 f5                	div    %ebp
  802677:	89 f0                	mov    %esi,%eax
  802679:	f7 f5                	div    %ebp
  80267b:	89 d0                	mov    %edx,%eax
  80267d:	31 d2                	xor    %edx,%edx
  80267f:	eb 8c                	jmp    80260d <__umoddi3+0x2d>
  802681:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802688:	89 e9                	mov    %ebp,%ecx
  80268a:	ba 20 00 00 00       	mov    $0x20,%edx
  80268f:	29 ea                	sub    %ebp,%edx
  802691:	d3 e0                	shl    %cl,%eax
  802693:	89 44 24 08          	mov    %eax,0x8(%esp)
  802697:	89 d1                	mov    %edx,%ecx
  802699:	89 f8                	mov    %edi,%eax
  80269b:	d3 e8                	shr    %cl,%eax
  80269d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8026a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026a5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026a9:	09 c1                	or     %eax,%ecx
  8026ab:	89 d8                	mov    %ebx,%eax
  8026ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026b1:	89 e9                	mov    %ebp,%ecx
  8026b3:	d3 e7                	shl    %cl,%edi
  8026b5:	89 d1                	mov    %edx,%ecx
  8026b7:	d3 e8                	shr    %cl,%eax
  8026b9:	89 e9                	mov    %ebp,%ecx
  8026bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8026bf:	d3 e3                	shl    %cl,%ebx
  8026c1:	89 c7                	mov    %eax,%edi
  8026c3:	89 d1                	mov    %edx,%ecx
  8026c5:	89 f0                	mov    %esi,%eax
  8026c7:	d3 e8                	shr    %cl,%eax
  8026c9:	89 e9                	mov    %ebp,%ecx
  8026cb:	89 fa                	mov    %edi,%edx
  8026cd:	d3 e6                	shl    %cl,%esi
  8026cf:	09 d8                	or     %ebx,%eax
  8026d1:	f7 74 24 08          	divl   0x8(%esp)
  8026d5:	89 d1                	mov    %edx,%ecx
  8026d7:	89 f3                	mov    %esi,%ebx
  8026d9:	f7 64 24 0c          	mull   0xc(%esp)
  8026dd:	89 c6                	mov    %eax,%esi
  8026df:	89 d7                	mov    %edx,%edi
  8026e1:	39 d1                	cmp    %edx,%ecx
  8026e3:	72 06                	jb     8026eb <__umoddi3+0x10b>
  8026e5:	75 10                	jne    8026f7 <__umoddi3+0x117>
  8026e7:	39 c3                	cmp    %eax,%ebx
  8026e9:	73 0c                	jae    8026f7 <__umoddi3+0x117>
  8026eb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8026ef:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8026f3:	89 d7                	mov    %edx,%edi
  8026f5:	89 c6                	mov    %eax,%esi
  8026f7:	89 ca                	mov    %ecx,%edx
  8026f9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8026fe:	29 f3                	sub    %esi,%ebx
  802700:	19 fa                	sbb    %edi,%edx
  802702:	89 d0                	mov    %edx,%eax
  802704:	d3 e0                	shl    %cl,%eax
  802706:	89 e9                	mov    %ebp,%ecx
  802708:	d3 eb                	shr    %cl,%ebx
  80270a:	d3 ea                	shr    %cl,%edx
  80270c:	09 d8                	or     %ebx,%eax
  80270e:	83 c4 1c             	add    $0x1c,%esp
  802711:	5b                   	pop    %ebx
  802712:	5e                   	pop    %esi
  802713:	5f                   	pop    %edi
  802714:	5d                   	pop    %ebp
  802715:	c3                   	ret    
  802716:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80271d:	8d 76 00             	lea    0x0(%esi),%esi
  802720:	29 fe                	sub    %edi,%esi
  802722:	19 c3                	sbb    %eax,%ebx
  802724:	89 f2                	mov    %esi,%edx
  802726:	89 d9                	mov    %ebx,%ecx
  802728:	e9 1d ff ff ff       	jmp    80264a <__umoddi3+0x6a>
