
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 08 02 00 00       	call   800239 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 1c             	sub    $0x1c,%esp
  800040:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800043:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800046:	8d 7d d8             	lea    -0x28(%ebp),%edi
  800049:	eb 5e                	jmp    8000a9 <primeproc+0x76>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  80004b:	83 ec 0c             	sub    $0xc,%esp
  80004e:	85 c0                	test   %eax,%eax
  800050:	ba 00 00 00 00       	mov    $0x0,%edx
  800055:	0f 4e d0             	cmovle %eax,%edx
  800058:	52                   	push   %edx
  800059:	50                   	push   %eax
  80005a:	68 60 28 80 00       	push   $0x802860
  80005f:	6a 15                	push   $0x15
  800061:	68 8f 28 80 00       	push   $0x80288f
  800066:	e8 36 02 00 00       	call   8002a1 <_panic>
		panic("pipe: %e", i);
  80006b:	50                   	push   %eax
  80006c:	68 a5 28 80 00       	push   $0x8028a5
  800071:	6a 1b                	push   $0x1b
  800073:	68 8f 28 80 00       	push   $0x80288f
  800078:	e8 24 02 00 00       	call   8002a1 <_panic>
	if ((id = fork()) < 0)
		panic("fork: %e", id);
  80007d:	50                   	push   %eax
  80007e:	68 ae 28 80 00       	push   $0x8028ae
  800083:	6a 1d                	push   $0x1d
  800085:	68 8f 28 80 00       	push   $0x80288f
  80008a:	e8 12 02 00 00       	call   8002a1 <_panic>
	if (id == 0) {
		close(fd);
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	53                   	push   %ebx
  800093:	e8 4a 13 00 00       	call   8013e2 <close>
		close(pfd[1]);
  800098:	83 c4 04             	add    $0x4,%esp
  80009b:	ff 75 dc             	pushl  -0x24(%ebp)
  80009e:	e8 3f 13 00 00       	call   8013e2 <close>
		fd = pfd[0];
  8000a3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000a6:	83 c4 10             	add    $0x10,%esp
	if ((r = readn(fd, &p, 4)) != 4)
  8000a9:	83 ec 04             	sub    $0x4,%esp
  8000ac:	6a 04                	push   $0x4
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
  8000b0:	e8 02 15 00 00       	call   8015b7 <readn>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	83 f8 04             	cmp    $0x4,%eax
  8000bb:	75 8e                	jne    80004b <primeproc+0x18>
	cprintf("%d\n", p);
  8000bd:	83 ec 08             	sub    $0x8,%esp
  8000c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000c3:	68 a1 28 80 00       	push   $0x8028a1
  8000c8:	e8 bb 02 00 00       	call   800388 <cprintf>
	if ((i=pipe(pfd)) < 0)
  8000cd:	89 3c 24             	mov    %edi,(%esp)
  8000d0:	e8 38 20 00 00       	call   80210d <pipe>
  8000d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000d8:	83 c4 10             	add    $0x10,%esp
  8000db:	85 c0                	test   %eax,%eax
  8000dd:	78 8c                	js     80006b <primeproc+0x38>
	if ((id = fork()) < 0)
  8000df:	e8 aa 0f 00 00       	call   80108e <fork>
  8000e4:	85 c0                	test   %eax,%eax
  8000e6:	78 95                	js     80007d <primeproc+0x4a>
	if (id == 0) {
  8000e8:	74 a5                	je     80008f <primeproc+0x5c>
	}

	close(pfd[0]);
  8000ea:	83 ec 0c             	sub    $0xc,%esp
  8000ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f0:	e8 ed 12 00 00       	call   8013e2 <close>
	wfd = pfd[1];
  8000f5:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f8:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000fb:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000fe:	83 ec 04             	sub    $0x4,%esp
  800101:	6a 04                	push   $0x4
  800103:	56                   	push   %esi
  800104:	53                   	push   %ebx
  800105:	e8 ad 14 00 00       	call   8015b7 <readn>
  80010a:	83 c4 10             	add    $0x10,%esp
  80010d:	83 f8 04             	cmp    $0x4,%eax
  800110:	75 42                	jne    800154 <primeproc+0x121>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
		if (i%p)
  800112:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800115:	99                   	cltd   
  800116:	f7 7d e0             	idivl  -0x20(%ebp)
  800119:	85 d2                	test   %edx,%edx
  80011b:	74 e1                	je     8000fe <primeproc+0xcb>
			if ((r=write(wfd, &i, 4)) != 4)
  80011d:	83 ec 04             	sub    $0x4,%esp
  800120:	6a 04                	push   $0x4
  800122:	56                   	push   %esi
  800123:	57                   	push   %edi
  800124:	e8 d9 14 00 00       	call   801602 <write>
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	83 f8 04             	cmp    $0x4,%eax
  80012f:	74 cd                	je     8000fe <primeproc+0xcb>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800131:	83 ec 08             	sub    $0x8,%esp
  800134:	85 c0                	test   %eax,%eax
  800136:	ba 00 00 00 00       	mov    $0x0,%edx
  80013b:	0f 4e d0             	cmovle %eax,%edx
  80013e:	52                   	push   %edx
  80013f:	50                   	push   %eax
  800140:	ff 75 e0             	pushl  -0x20(%ebp)
  800143:	68 d3 28 80 00       	push   $0x8028d3
  800148:	6a 2e                	push   $0x2e
  80014a:	68 8f 28 80 00       	push   $0x80288f
  80014f:	e8 4d 01 00 00       	call   8002a1 <_panic>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800154:	83 ec 04             	sub    $0x4,%esp
  800157:	85 c0                	test   %eax,%eax
  800159:	ba 00 00 00 00       	mov    $0x0,%edx
  80015e:	0f 4e d0             	cmovle %eax,%edx
  800161:	52                   	push   %edx
  800162:	50                   	push   %eax
  800163:	53                   	push   %ebx
  800164:	ff 75 e0             	pushl  -0x20(%ebp)
  800167:	68 b7 28 80 00       	push   $0x8028b7
  80016c:	6a 2b                	push   $0x2b
  80016e:	68 8f 28 80 00       	push   $0x80288f
  800173:	e8 29 01 00 00       	call   8002a1 <_panic>

00800178 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800178:	f3 0f 1e fb          	endbr32 
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	53                   	push   %ebx
  800180:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800183:	c7 05 00 30 80 00 ed 	movl   $0x8028ed,0x803000
  80018a:	28 80 00 

	if ((i=pipe(p)) < 0)
  80018d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800190:	50                   	push   %eax
  800191:	e8 77 1f 00 00       	call   80210d <pipe>
  800196:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800199:	83 c4 10             	add    $0x10,%esp
  80019c:	85 c0                	test   %eax,%eax
  80019e:	78 21                	js     8001c1 <umain+0x49>
		panic("pipe: %e", i);

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001a0:	e8 e9 0e 00 00       	call   80108e <fork>
  8001a5:	85 c0                	test   %eax,%eax
  8001a7:	78 2a                	js     8001d3 <umain+0x5b>
		panic("fork: %e", id);

	if (id == 0) {
  8001a9:	75 3a                	jne    8001e5 <umain+0x6d>
		close(p[1]);
  8001ab:	83 ec 0c             	sub    $0xc,%esp
  8001ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8001b1:	e8 2c 12 00 00       	call   8013e2 <close>
		primeproc(p[0]);
  8001b6:	83 c4 04             	add    $0x4,%esp
  8001b9:	ff 75 ec             	pushl  -0x14(%ebp)
  8001bc:	e8 72 fe ff ff       	call   800033 <primeproc>
		panic("pipe: %e", i);
  8001c1:	50                   	push   %eax
  8001c2:	68 a5 28 80 00       	push   $0x8028a5
  8001c7:	6a 3a                	push   $0x3a
  8001c9:	68 8f 28 80 00       	push   $0x80288f
  8001ce:	e8 ce 00 00 00       	call   8002a1 <_panic>
		panic("fork: %e", id);
  8001d3:	50                   	push   %eax
  8001d4:	68 ae 28 80 00       	push   $0x8028ae
  8001d9:	6a 3e                	push   $0x3e
  8001db:	68 8f 28 80 00       	push   $0x80288f
  8001e0:	e8 bc 00 00 00       	call   8002a1 <_panic>
	}

	close(p[0]);
  8001e5:	83 ec 0c             	sub    $0xc,%esp
  8001e8:	ff 75 ec             	pushl  -0x14(%ebp)
  8001eb:	e8 f2 11 00 00       	call   8013e2 <close>

	// feed all the integers through
	for (i=2;; i++)
  8001f0:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f7:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001fa:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001fd:	83 ec 04             	sub    $0x4,%esp
  800200:	6a 04                	push   $0x4
  800202:	53                   	push   %ebx
  800203:	ff 75 f0             	pushl  -0x10(%ebp)
  800206:	e8 f7 13 00 00       	call   801602 <write>
  80020b:	83 c4 10             	add    $0x10,%esp
  80020e:	83 f8 04             	cmp    $0x4,%eax
  800211:	75 06                	jne    800219 <umain+0xa1>
	for (i=2;; i++)
  800213:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
  800217:	eb e4                	jmp    8001fd <umain+0x85>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800219:	83 ec 0c             	sub    $0xc,%esp
  80021c:	85 c0                	test   %eax,%eax
  80021e:	ba 00 00 00 00       	mov    $0x0,%edx
  800223:	0f 4e d0             	cmovle %eax,%edx
  800226:	52                   	push   %edx
  800227:	50                   	push   %eax
  800228:	68 f8 28 80 00       	push   $0x8028f8
  80022d:	6a 4a                	push   $0x4a
  80022f:	68 8f 28 80 00       	push   $0x80288f
  800234:	e8 68 00 00 00       	call   8002a1 <_panic>

00800239 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800239:	f3 0f 1e fb          	endbr32 
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	56                   	push   %esi
  800241:	53                   	push   %ebx
  800242:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800245:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800248:	e8 68 0b 00 00       	call   800db5 <sys_getenvid>
  80024d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800252:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800255:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80025a:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80025f:	85 db                	test   %ebx,%ebx
  800261:	7e 07                	jle    80026a <libmain+0x31>
		binaryname = argv[0];
  800263:	8b 06                	mov    (%esi),%eax
  800265:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80026a:	83 ec 08             	sub    $0x8,%esp
  80026d:	56                   	push   %esi
  80026e:	53                   	push   %ebx
  80026f:	e8 04 ff ff ff       	call   800178 <umain>

	// exit gracefully
	exit();
  800274:	e8 0a 00 00 00       	call   800283 <exit>
}
  800279:	83 c4 10             	add    $0x10,%esp
  80027c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80027f:	5b                   	pop    %ebx
  800280:	5e                   	pop    %esi
  800281:	5d                   	pop    %ebp
  800282:	c3                   	ret    

00800283 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800283:	f3 0f 1e fb          	endbr32 
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  80028d:	e8 81 11 00 00       	call   801413 <close_all>
	sys_env_destroy(0);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	6a 00                	push   $0x0
  800297:	e8 f5 0a 00 00       	call   800d91 <sys_env_destroy>
}
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	c9                   	leave  
  8002a0:	c3                   	ret    

008002a1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002a1:	f3 0f 1e fb          	endbr32 
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	56                   	push   %esi
  8002a9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002aa:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002ad:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002b3:	e8 fd 0a 00 00       	call   800db5 <sys_getenvid>
  8002b8:	83 ec 0c             	sub    $0xc,%esp
  8002bb:	ff 75 0c             	pushl  0xc(%ebp)
  8002be:	ff 75 08             	pushl  0x8(%ebp)
  8002c1:	56                   	push   %esi
  8002c2:	50                   	push   %eax
  8002c3:	68 1c 29 80 00       	push   $0x80291c
  8002c8:	e8 bb 00 00 00       	call   800388 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002cd:	83 c4 18             	add    $0x18,%esp
  8002d0:	53                   	push   %ebx
  8002d1:	ff 75 10             	pushl  0x10(%ebp)
  8002d4:	e8 5a 00 00 00       	call   800333 <vcprintf>
	cprintf("\n");
  8002d9:	c7 04 24 a3 28 80 00 	movl   $0x8028a3,(%esp)
  8002e0:	e8 a3 00 00 00       	call   800388 <cprintf>
  8002e5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002e8:	cc                   	int3   
  8002e9:	eb fd                	jmp    8002e8 <_panic+0x47>

008002eb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002eb:	f3 0f 1e fb          	endbr32 
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	53                   	push   %ebx
  8002f3:	83 ec 04             	sub    $0x4,%esp
  8002f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002f9:	8b 13                	mov    (%ebx),%edx
  8002fb:	8d 42 01             	lea    0x1(%edx),%eax
  8002fe:	89 03                	mov    %eax,(%ebx)
  800300:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800303:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800307:	3d ff 00 00 00       	cmp    $0xff,%eax
  80030c:	74 09                	je     800317 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80030e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800312:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800315:	c9                   	leave  
  800316:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800317:	83 ec 08             	sub    $0x8,%esp
  80031a:	68 ff 00 00 00       	push   $0xff
  80031f:	8d 43 08             	lea    0x8(%ebx),%eax
  800322:	50                   	push   %eax
  800323:	e8 24 0a 00 00       	call   800d4c <sys_cputs>
		b->idx = 0;
  800328:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80032e:	83 c4 10             	add    $0x10,%esp
  800331:	eb db                	jmp    80030e <putch+0x23>

00800333 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800333:	f3 0f 1e fb          	endbr32 
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800340:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800347:	00 00 00 
	b.cnt = 0;
  80034a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800351:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800354:	ff 75 0c             	pushl  0xc(%ebp)
  800357:	ff 75 08             	pushl  0x8(%ebp)
  80035a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800360:	50                   	push   %eax
  800361:	68 eb 02 80 00       	push   $0x8002eb
  800366:	e8 20 01 00 00       	call   80048b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80036b:	83 c4 08             	add    $0x8,%esp
  80036e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800374:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80037a:	50                   	push   %eax
  80037b:	e8 cc 09 00 00       	call   800d4c <sys_cputs>

	return b.cnt;
}
  800380:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800386:	c9                   	leave  
  800387:	c3                   	ret    

00800388 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800388:	f3 0f 1e fb          	endbr32 
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800392:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800395:	50                   	push   %eax
  800396:	ff 75 08             	pushl  0x8(%ebp)
  800399:	e8 95 ff ff ff       	call   800333 <vcprintf>
	va_end(ap);

	return cnt;
}
  80039e:	c9                   	leave  
  80039f:	c3                   	ret    

008003a0 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	57                   	push   %edi
  8003a4:	56                   	push   %esi
  8003a5:	53                   	push   %ebx
  8003a6:	83 ec 1c             	sub    $0x1c,%esp
  8003a9:	89 c7                	mov    %eax,%edi
  8003ab:	89 d6                	mov    %edx,%esi
  8003ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b3:	89 d1                	mov    %edx,%ecx
  8003b5:	89 c2                	mov    %eax,%edx
  8003b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  8003c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003cd:	39 c2                	cmp    %eax,%edx
  8003cf:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8003d2:	72 3e                	jb     800412 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003d4:	83 ec 0c             	sub    $0xc,%esp
  8003d7:	ff 75 18             	pushl  0x18(%ebp)
  8003da:	83 eb 01             	sub    $0x1,%ebx
  8003dd:	53                   	push   %ebx
  8003de:	50                   	push   %eax
  8003df:	83 ec 08             	sub    $0x8,%esp
  8003e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8003e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8003eb:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ee:	e8 0d 22 00 00       	call   802600 <__udivdi3>
  8003f3:	83 c4 18             	add    $0x18,%esp
  8003f6:	52                   	push   %edx
  8003f7:	50                   	push   %eax
  8003f8:	89 f2                	mov    %esi,%edx
  8003fa:	89 f8                	mov    %edi,%eax
  8003fc:	e8 9f ff ff ff       	call   8003a0 <printnum>
  800401:	83 c4 20             	add    $0x20,%esp
  800404:	eb 13                	jmp    800419 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800406:	83 ec 08             	sub    $0x8,%esp
  800409:	56                   	push   %esi
  80040a:	ff 75 18             	pushl  0x18(%ebp)
  80040d:	ff d7                	call   *%edi
  80040f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800412:	83 eb 01             	sub    $0x1,%ebx
  800415:	85 db                	test   %ebx,%ebx
  800417:	7f ed                	jg     800406 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800419:	83 ec 08             	sub    $0x8,%esp
  80041c:	56                   	push   %esi
  80041d:	83 ec 04             	sub    $0x4,%esp
  800420:	ff 75 e4             	pushl  -0x1c(%ebp)
  800423:	ff 75 e0             	pushl  -0x20(%ebp)
  800426:	ff 75 dc             	pushl  -0x24(%ebp)
  800429:	ff 75 d8             	pushl  -0x28(%ebp)
  80042c:	e8 df 22 00 00       	call   802710 <__umoddi3>
  800431:	83 c4 14             	add    $0x14,%esp
  800434:	0f be 80 3f 29 80 00 	movsbl 0x80293f(%eax),%eax
  80043b:	50                   	push   %eax
  80043c:	ff d7                	call   *%edi
}
  80043e:	83 c4 10             	add    $0x10,%esp
  800441:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800444:	5b                   	pop    %ebx
  800445:	5e                   	pop    %esi
  800446:	5f                   	pop    %edi
  800447:	5d                   	pop    %ebp
  800448:	c3                   	ret    

00800449 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800449:	f3 0f 1e fb          	endbr32 
  80044d:	55                   	push   %ebp
  80044e:	89 e5                	mov    %esp,%ebp
  800450:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800453:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800457:	8b 10                	mov    (%eax),%edx
  800459:	3b 50 04             	cmp    0x4(%eax),%edx
  80045c:	73 0a                	jae    800468 <sprintputch+0x1f>
		*b->buf++ = ch;
  80045e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800461:	89 08                	mov    %ecx,(%eax)
  800463:	8b 45 08             	mov    0x8(%ebp),%eax
  800466:	88 02                	mov    %al,(%edx)
}
  800468:	5d                   	pop    %ebp
  800469:	c3                   	ret    

0080046a <printfmt>:
{
  80046a:	f3 0f 1e fb          	endbr32 
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800474:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800477:	50                   	push   %eax
  800478:	ff 75 10             	pushl  0x10(%ebp)
  80047b:	ff 75 0c             	pushl  0xc(%ebp)
  80047e:	ff 75 08             	pushl  0x8(%ebp)
  800481:	e8 05 00 00 00       	call   80048b <vprintfmt>
}
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	c9                   	leave  
  80048a:	c3                   	ret    

0080048b <vprintfmt>:
{
  80048b:	f3 0f 1e fb          	endbr32 
  80048f:	55                   	push   %ebp
  800490:	89 e5                	mov    %esp,%ebp
  800492:	57                   	push   %edi
  800493:	56                   	push   %esi
  800494:	53                   	push   %ebx
  800495:	83 ec 3c             	sub    $0x3c,%esp
  800498:	8b 75 08             	mov    0x8(%ebp),%esi
  80049b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80049e:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004a1:	e9 8e 03 00 00       	jmp    800834 <vprintfmt+0x3a9>
		padc = ' ';
  8004a6:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8004aa:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8004b1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8004b8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004bf:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004c4:	8d 47 01             	lea    0x1(%edi),%eax
  8004c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ca:	0f b6 17             	movzbl (%edi),%edx
  8004cd:	8d 42 dd             	lea    -0x23(%edx),%eax
  8004d0:	3c 55                	cmp    $0x55,%al
  8004d2:	0f 87 df 03 00 00    	ja     8008b7 <vprintfmt+0x42c>
  8004d8:	0f b6 c0             	movzbl %al,%eax
  8004db:	3e ff 24 85 80 2a 80 	notrack jmp *0x802a80(,%eax,4)
  8004e2:	00 
  8004e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8004e6:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8004ea:	eb d8                	jmp    8004c4 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ef:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8004f3:	eb cf                	jmp    8004c4 <vprintfmt+0x39>
  8004f5:	0f b6 d2             	movzbl %dl,%edx
  8004f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8004fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800500:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800503:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800506:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80050a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80050d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800510:	83 f9 09             	cmp    $0x9,%ecx
  800513:	77 55                	ja     80056a <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800515:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800518:	eb e9                	jmp    800503 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8b 00                	mov    (%eax),%eax
  80051f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 40 04             	lea    0x4(%eax),%eax
  800528:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80052b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80052e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800532:	79 90                	jns    8004c4 <vprintfmt+0x39>
				width = precision, precision = -1;
  800534:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800537:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80053a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800541:	eb 81                	jmp    8004c4 <vprintfmt+0x39>
  800543:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800546:	85 c0                	test   %eax,%eax
  800548:	ba 00 00 00 00       	mov    $0x0,%edx
  80054d:	0f 49 d0             	cmovns %eax,%edx
  800550:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800553:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800556:	e9 69 ff ff ff       	jmp    8004c4 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80055e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800565:	e9 5a ff ff ff       	jmp    8004c4 <vprintfmt+0x39>
  80056a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80056d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800570:	eb bc                	jmp    80052e <vprintfmt+0xa3>
			lflag++;
  800572:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800575:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800578:	e9 47 ff ff ff       	jmp    8004c4 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8d 78 04             	lea    0x4(%eax),%edi
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	53                   	push   %ebx
  800587:	ff 30                	pushl  (%eax)
  800589:	ff d6                	call   *%esi
			break;
  80058b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80058e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800591:	e9 9b 02 00 00       	jmp    800831 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8d 78 04             	lea    0x4(%eax),%edi
  80059c:	8b 00                	mov    (%eax),%eax
  80059e:	99                   	cltd   
  80059f:	31 d0                	xor    %edx,%eax
  8005a1:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005a3:	83 f8 0f             	cmp    $0xf,%eax
  8005a6:	7f 23                	jg     8005cb <vprintfmt+0x140>
  8005a8:	8b 14 85 e0 2b 80 00 	mov    0x802be0(,%eax,4),%edx
  8005af:	85 d2                	test   %edx,%edx
  8005b1:	74 18                	je     8005cb <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8005b3:	52                   	push   %edx
  8005b4:	68 e5 2d 80 00       	push   $0x802de5
  8005b9:	53                   	push   %ebx
  8005ba:	56                   	push   %esi
  8005bb:	e8 aa fe ff ff       	call   80046a <printfmt>
  8005c0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8005c3:	89 7d 14             	mov    %edi,0x14(%ebp)
  8005c6:	e9 66 02 00 00       	jmp    800831 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  8005cb:	50                   	push   %eax
  8005cc:	68 57 29 80 00       	push   $0x802957
  8005d1:	53                   	push   %ebx
  8005d2:	56                   	push   %esi
  8005d3:	e8 92 fe ff ff       	call   80046a <printfmt>
  8005d8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8005db:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8005de:	e9 4e 02 00 00       	jmp    800831 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	83 c0 04             	add    $0x4,%eax
  8005e9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8005f1:	85 d2                	test   %edx,%edx
  8005f3:	b8 50 29 80 00       	mov    $0x802950,%eax
  8005f8:	0f 45 c2             	cmovne %edx,%eax
  8005fb:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8005fe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800602:	7e 06                	jle    80060a <vprintfmt+0x17f>
  800604:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800608:	75 0d                	jne    800617 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80060a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80060d:	89 c7                	mov    %eax,%edi
  80060f:	03 45 e0             	add    -0x20(%ebp),%eax
  800612:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800615:	eb 55                	jmp    80066c <vprintfmt+0x1e1>
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	ff 75 d8             	pushl  -0x28(%ebp)
  80061d:	ff 75 cc             	pushl  -0x34(%ebp)
  800620:	e8 46 03 00 00       	call   80096b <strnlen>
  800625:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800628:	29 c2                	sub    %eax,%edx
  80062a:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80062d:	83 c4 10             	add    $0x10,%esp
  800630:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800632:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800636:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800639:	85 ff                	test   %edi,%edi
  80063b:	7e 11                	jle    80064e <vprintfmt+0x1c3>
					putch(padc, putdat);
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	53                   	push   %ebx
  800641:	ff 75 e0             	pushl  -0x20(%ebp)
  800644:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800646:	83 ef 01             	sub    $0x1,%edi
  800649:	83 c4 10             	add    $0x10,%esp
  80064c:	eb eb                	jmp    800639 <vprintfmt+0x1ae>
  80064e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800651:	85 d2                	test   %edx,%edx
  800653:	b8 00 00 00 00       	mov    $0x0,%eax
  800658:	0f 49 c2             	cmovns %edx,%eax
  80065b:	29 c2                	sub    %eax,%edx
  80065d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800660:	eb a8                	jmp    80060a <vprintfmt+0x17f>
					putch(ch, putdat);
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	53                   	push   %ebx
  800666:	52                   	push   %edx
  800667:	ff d6                	call   *%esi
  800669:	83 c4 10             	add    $0x10,%esp
  80066c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80066f:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800671:	83 c7 01             	add    $0x1,%edi
  800674:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800678:	0f be d0             	movsbl %al,%edx
  80067b:	85 d2                	test   %edx,%edx
  80067d:	74 4b                	je     8006ca <vprintfmt+0x23f>
  80067f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800683:	78 06                	js     80068b <vprintfmt+0x200>
  800685:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800689:	78 1e                	js     8006a9 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  80068b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80068f:	74 d1                	je     800662 <vprintfmt+0x1d7>
  800691:	0f be c0             	movsbl %al,%eax
  800694:	83 e8 20             	sub    $0x20,%eax
  800697:	83 f8 5e             	cmp    $0x5e,%eax
  80069a:	76 c6                	jbe    800662 <vprintfmt+0x1d7>
					putch('?', putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	6a 3f                	push   $0x3f
  8006a2:	ff d6                	call   *%esi
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	eb c3                	jmp    80066c <vprintfmt+0x1e1>
  8006a9:	89 cf                	mov    %ecx,%edi
  8006ab:	eb 0e                	jmp    8006bb <vprintfmt+0x230>
				putch(' ', putdat);
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	53                   	push   %ebx
  8006b1:	6a 20                	push   $0x20
  8006b3:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8006b5:	83 ef 01             	sub    $0x1,%edi
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	85 ff                	test   %edi,%edi
  8006bd:	7f ee                	jg     8006ad <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8006bf:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8006c2:	89 45 14             	mov    %eax,0x14(%ebp)
  8006c5:	e9 67 01 00 00       	jmp    800831 <vprintfmt+0x3a6>
  8006ca:	89 cf                	mov    %ecx,%edi
  8006cc:	eb ed                	jmp    8006bb <vprintfmt+0x230>
	if (lflag >= 2)
  8006ce:	83 f9 01             	cmp    $0x1,%ecx
  8006d1:	7f 1b                	jg     8006ee <vprintfmt+0x263>
	else if (lflag)
  8006d3:	85 c9                	test   %ecx,%ecx
  8006d5:	74 63                	je     80073a <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	8b 00                	mov    (%eax),%eax
  8006dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006df:	99                   	cltd   
  8006e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8d 40 04             	lea    0x4(%eax),%eax
  8006e9:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ec:	eb 17                	jmp    800705 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8b 50 04             	mov    0x4(%eax),%edx
  8006f4:	8b 00                	mov    (%eax),%eax
  8006f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8d 40 08             	lea    0x8(%eax),%eax
  800702:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800705:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800708:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80070b:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800710:	85 c9                	test   %ecx,%ecx
  800712:	0f 89 ff 00 00 00    	jns    800817 <vprintfmt+0x38c>
				putch('-', putdat);
  800718:	83 ec 08             	sub    $0x8,%esp
  80071b:	53                   	push   %ebx
  80071c:	6a 2d                	push   $0x2d
  80071e:	ff d6                	call   *%esi
				num = -(long long) num;
  800720:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800723:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800726:	f7 da                	neg    %edx
  800728:	83 d1 00             	adc    $0x0,%ecx
  80072b:	f7 d9                	neg    %ecx
  80072d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800730:	b8 0a 00 00 00       	mov    $0xa,%eax
  800735:	e9 dd 00 00 00       	jmp    800817 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  80073a:	8b 45 14             	mov    0x14(%ebp),%eax
  80073d:	8b 00                	mov    (%eax),%eax
  80073f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800742:	99                   	cltd   
  800743:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800746:	8b 45 14             	mov    0x14(%ebp),%eax
  800749:	8d 40 04             	lea    0x4(%eax),%eax
  80074c:	89 45 14             	mov    %eax,0x14(%ebp)
  80074f:	eb b4                	jmp    800705 <vprintfmt+0x27a>
	if (lflag >= 2)
  800751:	83 f9 01             	cmp    $0x1,%ecx
  800754:	7f 1e                	jg     800774 <vprintfmt+0x2e9>
	else if (lflag)
  800756:	85 c9                	test   %ecx,%ecx
  800758:	74 32                	je     80078c <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  80075a:	8b 45 14             	mov    0x14(%ebp),%eax
  80075d:	8b 10                	mov    (%eax),%edx
  80075f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800764:	8d 40 04             	lea    0x4(%eax),%eax
  800767:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80076a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80076f:	e9 a3 00 00 00       	jmp    800817 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8b 10                	mov    (%eax),%edx
  800779:	8b 48 04             	mov    0x4(%eax),%ecx
  80077c:	8d 40 08             	lea    0x8(%eax),%eax
  80077f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800782:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800787:	e9 8b 00 00 00       	jmp    800817 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80078c:	8b 45 14             	mov    0x14(%ebp),%eax
  80078f:	8b 10                	mov    (%eax),%edx
  800791:	b9 00 00 00 00       	mov    $0x0,%ecx
  800796:	8d 40 04             	lea    0x4(%eax),%eax
  800799:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80079c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8007a1:	eb 74                	jmp    800817 <vprintfmt+0x38c>
	if (lflag >= 2)
  8007a3:	83 f9 01             	cmp    $0x1,%ecx
  8007a6:	7f 1b                	jg     8007c3 <vprintfmt+0x338>
	else if (lflag)
  8007a8:	85 c9                	test   %ecx,%ecx
  8007aa:	74 2c                	je     8007d8 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  8007ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8007af:	8b 10                	mov    (%eax),%edx
  8007b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b6:	8d 40 04             	lea    0x4(%eax),%eax
  8007b9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8007bc:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  8007c1:	eb 54                	jmp    800817 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	8b 10                	mov    (%eax),%edx
  8007c8:	8b 48 04             	mov    0x4(%eax),%ecx
  8007cb:	8d 40 08             	lea    0x8(%eax),%eax
  8007ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8007d1:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8007d6:	eb 3f                	jmp    800817 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8007d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007db:	8b 10                	mov    (%eax),%edx
  8007dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007e2:	8d 40 04             	lea    0x4(%eax),%eax
  8007e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8007e8:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8007ed:	eb 28                	jmp    800817 <vprintfmt+0x38c>
			putch('0', putdat);
  8007ef:	83 ec 08             	sub    $0x8,%esp
  8007f2:	53                   	push   %ebx
  8007f3:	6a 30                	push   $0x30
  8007f5:	ff d6                	call   *%esi
			putch('x', putdat);
  8007f7:	83 c4 08             	add    $0x8,%esp
  8007fa:	53                   	push   %ebx
  8007fb:	6a 78                	push   $0x78
  8007fd:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800802:	8b 10                	mov    (%eax),%edx
  800804:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800809:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80080c:	8d 40 04             	lea    0x4(%eax),%eax
  80080f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800812:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800817:	83 ec 0c             	sub    $0xc,%esp
  80081a:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80081e:	57                   	push   %edi
  80081f:	ff 75 e0             	pushl  -0x20(%ebp)
  800822:	50                   	push   %eax
  800823:	51                   	push   %ecx
  800824:	52                   	push   %edx
  800825:	89 da                	mov    %ebx,%edx
  800827:	89 f0                	mov    %esi,%eax
  800829:	e8 72 fb ff ff       	call   8003a0 <printnum>
			break;
  80082e:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800831:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  800834:	83 c7 01             	add    $0x1,%edi
  800837:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80083b:	83 f8 25             	cmp    $0x25,%eax
  80083e:	0f 84 62 fc ff ff    	je     8004a6 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  800844:	85 c0                	test   %eax,%eax
  800846:	0f 84 8b 00 00 00    	je     8008d7 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  80084c:	83 ec 08             	sub    $0x8,%esp
  80084f:	53                   	push   %ebx
  800850:	50                   	push   %eax
  800851:	ff d6                	call   *%esi
  800853:	83 c4 10             	add    $0x10,%esp
  800856:	eb dc                	jmp    800834 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800858:	83 f9 01             	cmp    $0x1,%ecx
  80085b:	7f 1b                	jg     800878 <vprintfmt+0x3ed>
	else if (lflag)
  80085d:	85 c9                	test   %ecx,%ecx
  80085f:	74 2c                	je     80088d <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800861:	8b 45 14             	mov    0x14(%ebp),%eax
  800864:	8b 10                	mov    (%eax),%edx
  800866:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086b:	8d 40 04             	lea    0x4(%eax),%eax
  80086e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800871:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800876:	eb 9f                	jmp    800817 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800878:	8b 45 14             	mov    0x14(%ebp),%eax
  80087b:	8b 10                	mov    (%eax),%edx
  80087d:	8b 48 04             	mov    0x4(%eax),%ecx
  800880:	8d 40 08             	lea    0x8(%eax),%eax
  800883:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800886:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80088b:	eb 8a                	jmp    800817 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80088d:	8b 45 14             	mov    0x14(%ebp),%eax
  800890:	8b 10                	mov    (%eax),%edx
  800892:	b9 00 00 00 00       	mov    $0x0,%ecx
  800897:	8d 40 04             	lea    0x4(%eax),%eax
  80089a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80089d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8008a2:	e9 70 ff ff ff       	jmp    800817 <vprintfmt+0x38c>
			putch(ch, putdat);
  8008a7:	83 ec 08             	sub    $0x8,%esp
  8008aa:	53                   	push   %ebx
  8008ab:	6a 25                	push   $0x25
  8008ad:	ff d6                	call   *%esi
			break;
  8008af:	83 c4 10             	add    $0x10,%esp
  8008b2:	e9 7a ff ff ff       	jmp    800831 <vprintfmt+0x3a6>
			putch('%', putdat);
  8008b7:	83 ec 08             	sub    $0x8,%esp
  8008ba:	53                   	push   %ebx
  8008bb:	6a 25                	push   $0x25
  8008bd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  8008bf:	83 c4 10             	add    $0x10,%esp
  8008c2:	89 f8                	mov    %edi,%eax
  8008c4:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8008c8:	74 05                	je     8008cf <vprintfmt+0x444>
  8008ca:	83 e8 01             	sub    $0x1,%eax
  8008cd:	eb f5                	jmp    8008c4 <vprintfmt+0x439>
  8008cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008d2:	e9 5a ff ff ff       	jmp    800831 <vprintfmt+0x3a6>
}
  8008d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008da:	5b                   	pop    %ebx
  8008db:	5e                   	pop    %esi
  8008dc:	5f                   	pop    %edi
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008df:	f3 0f 1e fb          	endbr32 
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	83 ec 18             	sub    $0x18,%esp
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008f2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008f6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800900:	85 c0                	test   %eax,%eax
  800902:	74 26                	je     80092a <vsnprintf+0x4b>
  800904:	85 d2                	test   %edx,%edx
  800906:	7e 22                	jle    80092a <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800908:	ff 75 14             	pushl  0x14(%ebp)
  80090b:	ff 75 10             	pushl  0x10(%ebp)
  80090e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800911:	50                   	push   %eax
  800912:	68 49 04 80 00       	push   $0x800449
  800917:	e8 6f fb ff ff       	call   80048b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80091c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80091f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800922:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800925:	83 c4 10             	add    $0x10,%esp
}
  800928:	c9                   	leave  
  800929:	c3                   	ret    
		return -E_INVAL;
  80092a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80092f:	eb f7                	jmp    800928 <vsnprintf+0x49>

00800931 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800931:	f3 0f 1e fb          	endbr32 
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  80093b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80093e:	50                   	push   %eax
  80093f:	ff 75 10             	pushl  0x10(%ebp)
  800942:	ff 75 0c             	pushl  0xc(%ebp)
  800945:	ff 75 08             	pushl  0x8(%ebp)
  800948:	e8 92 ff ff ff       	call   8008df <vsnprintf>
	va_end(ap);

	return rc;
}
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    

0080094f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80094f:	f3 0f 1e fb          	endbr32 
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800959:	b8 00 00 00 00       	mov    $0x0,%eax
  80095e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800962:	74 05                	je     800969 <strlen+0x1a>
		n++;
  800964:	83 c0 01             	add    $0x1,%eax
  800967:	eb f5                	jmp    80095e <strlen+0xf>
	return n;
}
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80096b:	f3 0f 1e fb          	endbr32 
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800975:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800978:	b8 00 00 00 00       	mov    $0x0,%eax
  80097d:	39 d0                	cmp    %edx,%eax
  80097f:	74 0d                	je     80098e <strnlen+0x23>
  800981:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800985:	74 05                	je     80098c <strnlen+0x21>
		n++;
  800987:	83 c0 01             	add    $0x1,%eax
  80098a:	eb f1                	jmp    80097d <strnlen+0x12>
  80098c:	89 c2                	mov    %eax,%edx
	return n;
}
  80098e:	89 d0                	mov    %edx,%eax
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800992:	f3 0f 1e fb          	endbr32 
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	53                   	push   %ebx
  80099a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a5:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8009a9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8009ac:	83 c0 01             	add    $0x1,%eax
  8009af:	84 d2                	test   %dl,%dl
  8009b1:	75 f2                	jne    8009a5 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8009b3:	89 c8                	mov    %ecx,%eax
  8009b5:	5b                   	pop    %ebx
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009b8:	f3 0f 1e fb          	endbr32 
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	53                   	push   %ebx
  8009c0:	83 ec 10             	sub    $0x10,%esp
  8009c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009c6:	53                   	push   %ebx
  8009c7:	e8 83 ff ff ff       	call   80094f <strlen>
  8009cc:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8009cf:	ff 75 0c             	pushl  0xc(%ebp)
  8009d2:	01 d8                	add    %ebx,%eax
  8009d4:	50                   	push   %eax
  8009d5:	e8 b8 ff ff ff       	call   800992 <strcpy>
	return dst;
}
  8009da:	89 d8                	mov    %ebx,%eax
  8009dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009df:	c9                   	leave  
  8009e0:	c3                   	ret    

008009e1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009e1:	f3 0f 1e fb          	endbr32 
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	56                   	push   %esi
  8009e9:	53                   	push   %ebx
  8009ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f0:	89 f3                	mov    %esi,%ebx
  8009f2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f5:	89 f0                	mov    %esi,%eax
  8009f7:	39 d8                	cmp    %ebx,%eax
  8009f9:	74 11                	je     800a0c <strncpy+0x2b>
		*dst++ = *src;
  8009fb:	83 c0 01             	add    $0x1,%eax
  8009fe:	0f b6 0a             	movzbl (%edx),%ecx
  800a01:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a04:	80 f9 01             	cmp    $0x1,%cl
  800a07:	83 da ff             	sbb    $0xffffffff,%edx
  800a0a:	eb eb                	jmp    8009f7 <strncpy+0x16>
	}
	return ret;
}
  800a0c:	89 f0                	mov    %esi,%eax
  800a0e:	5b                   	pop    %ebx
  800a0f:	5e                   	pop    %esi
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a12:	f3 0f 1e fb          	endbr32 
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	56                   	push   %esi
  800a1a:	53                   	push   %ebx
  800a1b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a21:	8b 55 10             	mov    0x10(%ebp),%edx
  800a24:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a26:	85 d2                	test   %edx,%edx
  800a28:	74 21                	je     800a4b <strlcpy+0x39>
  800a2a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a2e:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800a30:	39 c2                	cmp    %eax,%edx
  800a32:	74 14                	je     800a48 <strlcpy+0x36>
  800a34:	0f b6 19             	movzbl (%ecx),%ebx
  800a37:	84 db                	test   %bl,%bl
  800a39:	74 0b                	je     800a46 <strlcpy+0x34>
			*dst++ = *src++;
  800a3b:	83 c1 01             	add    $0x1,%ecx
  800a3e:	83 c2 01             	add    $0x1,%edx
  800a41:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a44:	eb ea                	jmp    800a30 <strlcpy+0x1e>
  800a46:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a48:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a4b:	29 f0                	sub    %esi,%eax
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a51:	f3 0f 1e fb          	endbr32 
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a5e:	0f b6 01             	movzbl (%ecx),%eax
  800a61:	84 c0                	test   %al,%al
  800a63:	74 0c                	je     800a71 <strcmp+0x20>
  800a65:	3a 02                	cmp    (%edx),%al
  800a67:	75 08                	jne    800a71 <strcmp+0x20>
		p++, q++;
  800a69:	83 c1 01             	add    $0x1,%ecx
  800a6c:	83 c2 01             	add    $0x1,%edx
  800a6f:	eb ed                	jmp    800a5e <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a71:	0f b6 c0             	movzbl %al,%eax
  800a74:	0f b6 12             	movzbl (%edx),%edx
  800a77:	29 d0                	sub    %edx,%eax
}
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a7b:	f3 0f 1e fb          	endbr32 
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	53                   	push   %ebx
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a89:	89 c3                	mov    %eax,%ebx
  800a8b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a8e:	eb 06                	jmp    800a96 <strncmp+0x1b>
		n--, p++, q++;
  800a90:	83 c0 01             	add    $0x1,%eax
  800a93:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a96:	39 d8                	cmp    %ebx,%eax
  800a98:	74 16                	je     800ab0 <strncmp+0x35>
  800a9a:	0f b6 08             	movzbl (%eax),%ecx
  800a9d:	84 c9                	test   %cl,%cl
  800a9f:	74 04                	je     800aa5 <strncmp+0x2a>
  800aa1:	3a 0a                	cmp    (%edx),%cl
  800aa3:	74 eb                	je     800a90 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa5:	0f b6 00             	movzbl (%eax),%eax
  800aa8:	0f b6 12             	movzbl (%edx),%edx
  800aab:	29 d0                	sub    %edx,%eax
}
  800aad:	5b                   	pop    %ebx
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    
		return 0;
  800ab0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab5:	eb f6                	jmp    800aad <strncmp+0x32>

00800ab7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ab7:	f3 0f 1e fb          	endbr32 
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac5:	0f b6 10             	movzbl (%eax),%edx
  800ac8:	84 d2                	test   %dl,%dl
  800aca:	74 09                	je     800ad5 <strchr+0x1e>
		if (*s == c)
  800acc:	38 ca                	cmp    %cl,%dl
  800ace:	74 0a                	je     800ada <strchr+0x23>
	for (; *s; s++)
  800ad0:	83 c0 01             	add    $0x1,%eax
  800ad3:	eb f0                	jmp    800ac5 <strchr+0xe>
			return (char *) s;
	return 0;
  800ad5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800adc:	f3 0f 1e fb          	endbr32 
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800ae6:	6a 78                	push   $0x78
  800ae8:	ff 75 08             	pushl  0x8(%ebp)
  800aeb:	e8 c7 ff ff ff       	call   800ab7 <strchr>
  800af0:	83 c4 10             	add    $0x10,%esp
  800af3:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  800af6:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800afb:	eb 0d                	jmp    800b0a <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800afd:	c1 e0 04             	shl    $0x4,%eax
  800b00:	0f be d2             	movsbl %dl,%edx
  800b03:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800b07:	83 c1 01             	add    $0x1,%ecx
  800b0a:	0f b6 11             	movzbl (%ecx),%edx
  800b0d:	84 d2                	test   %dl,%dl
  800b0f:	74 11                	je     800b22 <atox+0x46>
		if (*p>='a'){
  800b11:	80 fa 60             	cmp    $0x60,%dl
  800b14:	7e e7                	jle    800afd <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800b16:	c1 e0 04             	shl    $0x4,%eax
  800b19:	0f be d2             	movsbl %dl,%edx
  800b1c:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800b20:	eb e5                	jmp    800b07 <atox+0x2b>
	}

	return v;

}
  800b22:	c9                   	leave  
  800b23:	c3                   	ret    

00800b24 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b24:	f3 0f 1e fb          	endbr32 
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b32:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b35:	38 ca                	cmp    %cl,%dl
  800b37:	74 09                	je     800b42 <strfind+0x1e>
  800b39:	84 d2                	test   %dl,%dl
  800b3b:	74 05                	je     800b42 <strfind+0x1e>
	for (; *s; s++)
  800b3d:	83 c0 01             	add    $0x1,%eax
  800b40:	eb f0                	jmp    800b32 <strfind+0xe>
			break;
	return (char *) s;
}
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b44:	f3 0f 1e fb          	endbr32 
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
  800b4e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b51:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b54:	85 c9                	test   %ecx,%ecx
  800b56:	74 31                	je     800b89 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b58:	89 f8                	mov    %edi,%eax
  800b5a:	09 c8                	or     %ecx,%eax
  800b5c:	a8 03                	test   $0x3,%al
  800b5e:	75 23                	jne    800b83 <memset+0x3f>
		c &= 0xFF;
  800b60:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b64:	89 d3                	mov    %edx,%ebx
  800b66:	c1 e3 08             	shl    $0x8,%ebx
  800b69:	89 d0                	mov    %edx,%eax
  800b6b:	c1 e0 18             	shl    $0x18,%eax
  800b6e:	89 d6                	mov    %edx,%esi
  800b70:	c1 e6 10             	shl    $0x10,%esi
  800b73:	09 f0                	or     %esi,%eax
  800b75:	09 c2                	or     %eax,%edx
  800b77:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b79:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b7c:	89 d0                	mov    %edx,%eax
  800b7e:	fc                   	cld    
  800b7f:	f3 ab                	rep stos %eax,%es:(%edi)
  800b81:	eb 06                	jmp    800b89 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b86:	fc                   	cld    
  800b87:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b89:	89 f8                	mov    %edi,%eax
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b90:	f3 0f 1e fb          	endbr32 
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ba2:	39 c6                	cmp    %eax,%esi
  800ba4:	73 32                	jae    800bd8 <memmove+0x48>
  800ba6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ba9:	39 c2                	cmp    %eax,%edx
  800bab:	76 2b                	jbe    800bd8 <memmove+0x48>
		s += n;
		d += n;
  800bad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb0:	89 fe                	mov    %edi,%esi
  800bb2:	09 ce                	or     %ecx,%esi
  800bb4:	09 d6                	or     %edx,%esi
  800bb6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bbc:	75 0e                	jne    800bcc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bbe:	83 ef 04             	sub    $0x4,%edi
  800bc1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bc4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800bc7:	fd                   	std    
  800bc8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bca:	eb 09                	jmp    800bd5 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bcc:	83 ef 01             	sub    $0x1,%edi
  800bcf:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bd2:	fd                   	std    
  800bd3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bd5:	fc                   	cld    
  800bd6:	eb 1a                	jmp    800bf2 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd8:	89 c2                	mov    %eax,%edx
  800bda:	09 ca                	or     %ecx,%edx
  800bdc:	09 f2                	or     %esi,%edx
  800bde:	f6 c2 03             	test   $0x3,%dl
  800be1:	75 0a                	jne    800bed <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800be3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800be6:	89 c7                	mov    %eax,%edi
  800be8:	fc                   	cld    
  800be9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800beb:	eb 05                	jmp    800bf2 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800bed:	89 c7                	mov    %eax,%edi
  800bef:	fc                   	cld    
  800bf0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bf6:	f3 0f 1e fb          	endbr32 
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c00:	ff 75 10             	pushl  0x10(%ebp)
  800c03:	ff 75 0c             	pushl  0xc(%ebp)
  800c06:	ff 75 08             	pushl  0x8(%ebp)
  800c09:	e8 82 ff ff ff       	call   800b90 <memmove>
}
  800c0e:	c9                   	leave  
  800c0f:	c3                   	ret    

00800c10 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c10:	f3 0f 1e fb          	endbr32 
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1f:	89 c6                	mov    %eax,%esi
  800c21:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c24:	39 f0                	cmp    %esi,%eax
  800c26:	74 1c                	je     800c44 <memcmp+0x34>
		if (*s1 != *s2)
  800c28:	0f b6 08             	movzbl (%eax),%ecx
  800c2b:	0f b6 1a             	movzbl (%edx),%ebx
  800c2e:	38 d9                	cmp    %bl,%cl
  800c30:	75 08                	jne    800c3a <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c32:	83 c0 01             	add    $0x1,%eax
  800c35:	83 c2 01             	add    $0x1,%edx
  800c38:	eb ea                	jmp    800c24 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800c3a:	0f b6 c1             	movzbl %cl,%eax
  800c3d:	0f b6 db             	movzbl %bl,%ebx
  800c40:	29 d8                	sub    %ebx,%eax
  800c42:	eb 05                	jmp    800c49 <memcmp+0x39>
	}

	return 0;
  800c44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c49:	5b                   	pop    %ebx
  800c4a:	5e                   	pop    %esi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c4d:	f3 0f 1e fb          	endbr32 
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	8b 45 08             	mov    0x8(%ebp),%eax
  800c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c5a:	89 c2                	mov    %eax,%edx
  800c5c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c5f:	39 d0                	cmp    %edx,%eax
  800c61:	73 09                	jae    800c6c <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c63:	38 08                	cmp    %cl,(%eax)
  800c65:	74 05                	je     800c6c <memfind+0x1f>
	for (; s < ends; s++)
  800c67:	83 c0 01             	add    $0x1,%eax
  800c6a:	eb f3                	jmp    800c5f <memfind+0x12>
			break;
	return (void *) s;
}
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c6e:	f3 0f 1e fb          	endbr32 
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	57                   	push   %edi
  800c76:	56                   	push   %esi
  800c77:	53                   	push   %ebx
  800c78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c7e:	eb 03                	jmp    800c83 <strtol+0x15>
		s++;
  800c80:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c83:	0f b6 01             	movzbl (%ecx),%eax
  800c86:	3c 20                	cmp    $0x20,%al
  800c88:	74 f6                	je     800c80 <strtol+0x12>
  800c8a:	3c 09                	cmp    $0x9,%al
  800c8c:	74 f2                	je     800c80 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800c8e:	3c 2b                	cmp    $0x2b,%al
  800c90:	74 2a                	je     800cbc <strtol+0x4e>
	int neg = 0;
  800c92:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c97:	3c 2d                	cmp    $0x2d,%al
  800c99:	74 2b                	je     800cc6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c9b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ca1:	75 0f                	jne    800cb2 <strtol+0x44>
  800ca3:	80 39 30             	cmpb   $0x30,(%ecx)
  800ca6:	74 28                	je     800cd0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ca8:	85 db                	test   %ebx,%ebx
  800caa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800caf:	0f 44 d8             	cmove  %eax,%ebx
  800cb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800cba:	eb 46                	jmp    800d02 <strtol+0x94>
		s++;
  800cbc:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800cbf:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc4:	eb d5                	jmp    800c9b <strtol+0x2d>
		s++, neg = 1;
  800cc6:	83 c1 01             	add    $0x1,%ecx
  800cc9:	bf 01 00 00 00       	mov    $0x1,%edi
  800cce:	eb cb                	jmp    800c9b <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cd0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cd4:	74 0e                	je     800ce4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800cd6:	85 db                	test   %ebx,%ebx
  800cd8:	75 d8                	jne    800cb2 <strtol+0x44>
		s++, base = 8;
  800cda:	83 c1 01             	add    $0x1,%ecx
  800cdd:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ce2:	eb ce                	jmp    800cb2 <strtol+0x44>
		s += 2, base = 16;
  800ce4:	83 c1 02             	add    $0x2,%ecx
  800ce7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cec:	eb c4                	jmp    800cb2 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800cee:	0f be d2             	movsbl %dl,%edx
  800cf1:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cf4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cf7:	7d 3a                	jge    800d33 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800cf9:	83 c1 01             	add    $0x1,%ecx
  800cfc:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d00:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d02:	0f b6 11             	movzbl (%ecx),%edx
  800d05:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d08:	89 f3                	mov    %esi,%ebx
  800d0a:	80 fb 09             	cmp    $0x9,%bl
  800d0d:	76 df                	jbe    800cee <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800d0f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d12:	89 f3                	mov    %esi,%ebx
  800d14:	80 fb 19             	cmp    $0x19,%bl
  800d17:	77 08                	ja     800d21 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d19:	0f be d2             	movsbl %dl,%edx
  800d1c:	83 ea 57             	sub    $0x57,%edx
  800d1f:	eb d3                	jmp    800cf4 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800d21:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d24:	89 f3                	mov    %esi,%ebx
  800d26:	80 fb 19             	cmp    $0x19,%bl
  800d29:	77 08                	ja     800d33 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d2b:	0f be d2             	movsbl %dl,%edx
  800d2e:	83 ea 37             	sub    $0x37,%edx
  800d31:	eb c1                	jmp    800cf4 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d33:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d37:	74 05                	je     800d3e <strtol+0xd0>
		*endptr = (char *) s;
  800d39:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d3c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d3e:	89 c2                	mov    %eax,%edx
  800d40:	f7 da                	neg    %edx
  800d42:	85 ff                	test   %edi,%edi
  800d44:	0f 45 c2             	cmovne %edx,%eax
}
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d4c:	f3 0f 1e fb          	endbr32 
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d56:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d61:	89 c3                	mov    %eax,%ebx
  800d63:	89 c7                	mov    %eax,%edi
  800d65:	89 c6                	mov    %eax,%esi
  800d67:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <sys_cgetc>:

int
sys_cgetc(void)
{
  800d6e:	f3 0f 1e fb          	endbr32 
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d78:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7d:	b8 01 00 00 00       	mov    $0x1,%eax
  800d82:	89 d1                	mov    %edx,%ecx
  800d84:	89 d3                	mov    %edx,%ebx
  800d86:	89 d7                	mov    %edx,%edi
  800d88:	89 d6                	mov    %edx,%esi
  800d8a:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d91:	f3 0f 1e fb          	endbr32 
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d9b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da0:	8b 55 08             	mov    0x8(%ebp),%edx
  800da3:	b8 03 00 00 00       	mov    $0x3,%eax
  800da8:	89 cb                	mov    %ecx,%ebx
  800daa:	89 cf                	mov    %ecx,%edi
  800dac:	89 ce                	mov    %ecx,%esi
  800dae:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800db5:	f3 0f 1e fb          	endbr32 
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
  800dbc:	57                   	push   %edi
  800dbd:	56                   	push   %esi
  800dbe:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dbf:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc4:	b8 02 00 00 00       	mov    $0x2,%eax
  800dc9:	89 d1                	mov    %edx,%ecx
  800dcb:	89 d3                	mov    %edx,%ebx
  800dcd:	89 d7                	mov    %edx,%edi
  800dcf:	89 d6                	mov    %edx,%esi
  800dd1:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    

00800dd8 <sys_yield>:

void
sys_yield(void)
{
  800dd8:	f3 0f 1e fb          	endbr32 
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	57                   	push   %edi
  800de0:	56                   	push   %esi
  800de1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800de2:	ba 00 00 00 00       	mov    $0x0,%edx
  800de7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dec:	89 d1                	mov    %edx,%ecx
  800dee:	89 d3                	mov    %edx,%ebx
  800df0:	89 d7                	mov    %edx,%edi
  800df2:	89 d6                	mov    %edx,%esi
  800df4:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800df6:	5b                   	pop    %ebx
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dfb:	f3 0f 1e fb          	endbr32 
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	57                   	push   %edi
  800e03:	56                   	push   %esi
  800e04:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e05:	be 00 00 00 00       	mov    $0x0,%esi
  800e0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e10:	b8 04 00 00 00       	mov    $0x4,%eax
  800e15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e18:	89 f7                	mov    %esi,%edi
  800e1a:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e1c:	5b                   	pop    %ebx
  800e1d:	5e                   	pop    %esi
  800e1e:	5f                   	pop    %edi
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e21:	f3 0f 1e fb          	endbr32 
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e31:	b8 05 00 00 00       	mov    $0x5,%eax
  800e36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e39:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e3c:	8b 75 18             	mov    0x18(%ebp),%esi
  800e3f:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e41:	5b                   	pop    %ebx
  800e42:	5e                   	pop    %esi
  800e43:	5f                   	pop    %edi
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e46:	f3 0f 1e fb          	endbr32 
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	57                   	push   %edi
  800e4e:	56                   	push   %esi
  800e4f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e55:	8b 55 08             	mov    0x8(%ebp),%edx
  800e58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5b:	b8 06 00 00 00       	mov    $0x6,%eax
  800e60:	89 df                	mov    %ebx,%edi
  800e62:	89 de                	mov    %ebx,%esi
  800e64:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e66:	5b                   	pop    %ebx
  800e67:	5e                   	pop    %esi
  800e68:	5f                   	pop    %edi
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e6b:	f3 0f 1e fb          	endbr32 
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	57                   	push   %edi
  800e73:	56                   	push   %esi
  800e74:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e80:	b8 08 00 00 00       	mov    $0x8,%eax
  800e85:	89 df                	mov    %ebx,%edi
  800e87:	89 de                	mov    %ebx,%esi
  800e89:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e8b:	5b                   	pop    %ebx
  800e8c:	5e                   	pop    %esi
  800e8d:	5f                   	pop    %edi
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e90:	f3 0f 1e fb          	endbr32 
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	57                   	push   %edi
  800e98:	56                   	push   %esi
  800e99:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea5:	b8 09 00 00 00       	mov    $0x9,%eax
  800eaa:	89 df                	mov    %ebx,%edi
  800eac:	89 de                	mov    %ebx,%esi
  800eae:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eb0:	5b                   	pop    %ebx
  800eb1:	5e                   	pop    %esi
  800eb2:	5f                   	pop    %edi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    

00800eb5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800eb5:	f3 0f 1e fb          	endbr32 
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	57                   	push   %edi
  800ebd:	56                   	push   %esi
  800ebe:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ebf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eca:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ecf:	89 df                	mov    %ebx,%edi
  800ed1:	89 de                	mov    %ebx,%esi
  800ed3:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ed5:	5b                   	pop    %ebx
  800ed6:	5e                   	pop    %esi
  800ed7:	5f                   	pop    %edi
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eda:	f3 0f 1e fb          	endbr32 
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	57                   	push   %edi
  800ee2:	56                   	push   %esi
  800ee3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ee4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eea:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eef:	be 00 00 00 00       	mov    $0x0,%esi
  800ef4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800efa:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800efc:	5b                   	pop    %ebx
  800efd:	5e                   	pop    %esi
  800efe:	5f                   	pop    %edi
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    

00800f01 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f01:	f3 0f 1e fb          	endbr32 
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	57                   	push   %edi
  800f09:	56                   	push   %esi
  800f0a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f0b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f10:	8b 55 08             	mov    0x8(%ebp),%edx
  800f13:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f18:	89 cb                	mov    %ecx,%ebx
  800f1a:	89 cf                	mov    %ecx,%edi
  800f1c:	89 ce                	mov    %ecx,%esi
  800f1e:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f20:	5b                   	pop    %ebx
  800f21:	5e                   	pop    %esi
  800f22:	5f                   	pop    %edi
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    

00800f25 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f25:	f3 0f 1e fb          	endbr32 
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	57                   	push   %edi
  800f2d:	56                   	push   %esi
  800f2e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f34:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f39:	89 d1                	mov    %edx,%ecx
  800f3b:	89 d3                	mov    %edx,%ebx
  800f3d:	89 d7                	mov    %edx,%edi
  800f3f:	89 d6                	mov    %edx,%esi
  800f41:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f43:	5b                   	pop    %ebx
  800f44:	5e                   	pop    %esi
  800f45:	5f                   	pop    %edi
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    

00800f48 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800f48:	f3 0f 1e fb          	endbr32 
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	57                   	push   %edi
  800f50:	56                   	push   %esi
  800f51:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f57:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f62:	89 df                	mov    %ebx,%edi
  800f64:	89 de                	mov    %ebx,%esi
  800f66:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800f68:	5b                   	pop    %ebx
  800f69:	5e                   	pop    %esi
  800f6a:	5f                   	pop    %edi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    

00800f6d <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800f6d:	f3 0f 1e fb          	endbr32 
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	57                   	push   %edi
  800f75:	56                   	push   %esi
  800f76:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f82:	b8 10 00 00 00       	mov    $0x10,%eax
  800f87:	89 df                	mov    %ebx,%edi
  800f89:	89 de                	mov    %ebx,%esi
  800f8b:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800f8d:	5b                   	pop    %ebx
  800f8e:	5e                   	pop    %esi
  800f8f:	5f                   	pop    %edi
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    

00800f92 <pgfault>:
// map in our own private writable copy.
//
extern int cnt;
static void
pgfault(struct UTrapframe *utf)
{
  800f92:	f3 0f 1e fb          	endbr32 
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	53                   	push   %ebx
  800f9a:	83 ec 04             	sub    $0x4,%esp
  800f9d:	8b 45 08             	mov    0x8(%ebp),%eax
	// cprintf("[%08x] called pgfault\n", sys_getenvid());
	void *addr = (void *) utf->utf_fault_va;
  800fa0:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err&FEC_WR)&&(uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_COW))){
  800fa2:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fa6:	0f 84 9a 00 00 00    	je     801046 <pgfault+0xb4>
  800fac:	89 d8                	mov    %ebx,%eax
  800fae:	c1 e8 16             	shr    $0x16,%eax
  800fb1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fb8:	a8 01                	test   $0x1,%al
  800fba:	0f 84 86 00 00 00    	je     801046 <pgfault+0xb4>
  800fc0:	89 d8                	mov    %ebx,%eax
  800fc2:	c1 e8 0c             	shr    $0xc,%eax
  800fc5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fcc:	f6 c2 01             	test   $0x1,%dl
  800fcf:	74 75                	je     801046 <pgfault+0xb4>
  800fd1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fd8:	f6 c4 08             	test   $0x8,%ah
  800fdb:	74 69                	je     801046 <pgfault+0xb4>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 在PFTEMP这里给一个物理地址的mapping 相当于store一个物理地址
	if((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W))<0){
  800fdd:	83 ec 04             	sub    $0x4,%esp
  800fe0:	6a 07                	push   $0x7
  800fe2:	68 00 f0 7f 00       	push   $0x7ff000
  800fe7:	6a 00                	push   $0x0
  800fe9:	e8 0d fe ff ff       	call   800dfb <sys_page_alloc>
  800fee:	83 c4 10             	add    $0x10,%esp
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	78 63                	js     801058 <pgfault+0xc6>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800ff5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// 先复制addr里的content
	memcpy((void*)PFTEMP, addr, PGSIZE);
  800ffb:	83 ec 04             	sub    $0x4,%esp
  800ffe:	68 00 10 00 00       	push   $0x1000
  801003:	53                   	push   %ebx
  801004:	68 00 f0 7f 00       	push   $0x7ff000
  801009:	e8 e8 fb ff ff       	call   800bf6 <memcpy>
	// 在remap addr到PFTEMP位置 即addr与PFTEMP指向同一个物理内存
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))<0){
  80100e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801015:	53                   	push   %ebx
  801016:	6a 00                	push   $0x0
  801018:	68 00 f0 7f 00       	push   $0x7ff000
  80101d:	6a 00                	push   $0x0
  80101f:	e8 fd fd ff ff       	call   800e21 <sys_page_map>
  801024:	83 c4 20             	add    $0x20,%esp
  801027:	85 c0                	test   %eax,%eax
  801029:	78 3f                	js     80106a <pgfault+0xd8>
		panic("pgfault: sys_page_map failed due to %e\n", r);
	}
	if ((r = sys_page_unmap(0, (void*)PFTEMP))<0){
  80102b:	83 ec 08             	sub    $0x8,%esp
  80102e:	68 00 f0 7f 00       	push   $0x7ff000
  801033:	6a 00                	push   $0x0
  801035:	e8 0c fe ff ff       	call   800e46 <sys_page_unmap>
  80103a:	83 c4 10             	add    $0x10,%esp
  80103d:	85 c0                	test   %eax,%eax
  80103f:	78 3b                	js     80107c <pgfault+0xea>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
	}
	
	
}
  801041:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801044:	c9                   	leave  
  801045:	c3                   	ret    
		panic("pgfault: page access at %08x is not a write to a copy-on-write\n", addr);
  801046:	53                   	push   %ebx
  801047:	68 40 2c 80 00       	push   $0x802c40
  80104c:	6a 20                	push   $0x20
  80104e:	68 fe 2c 80 00       	push   $0x802cfe
  801053:	e8 49 f2 ff ff       	call   8002a1 <_panic>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
  801058:	50                   	push   %eax
  801059:	68 80 2c 80 00       	push   $0x802c80
  80105e:	6a 2c                	push   $0x2c
  801060:	68 fe 2c 80 00       	push   $0x802cfe
  801065:	e8 37 f2 ff ff       	call   8002a1 <_panic>
		panic("pgfault: sys_page_map failed due to %e\n", r);
  80106a:	50                   	push   %eax
  80106b:	68 ac 2c 80 00       	push   $0x802cac
  801070:	6a 33                	push   $0x33
  801072:	68 fe 2c 80 00       	push   $0x802cfe
  801077:	e8 25 f2 ff ff       	call   8002a1 <_panic>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
  80107c:	50                   	push   %eax
  80107d:	68 d4 2c 80 00       	push   $0x802cd4
  801082:	6a 36                	push   $0x36
  801084:	68 fe 2c 80 00       	push   $0x802cfe
  801089:	e8 13 f2 ff ff       	call   8002a1 <_panic>

0080108e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80108e:	f3 0f 1e fb          	endbr32 
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	57                   	push   %edi
  801096:	56                   	push   %esi
  801097:	53                   	push   %ebx
  801098:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[%08x] called fork\n", sys_getenvid());
	int r; uintptr_t addr;
	set_pgfault_handler(pgfault);
  80109b:	68 92 0f 80 00       	push   $0x800f92
  8010a0:	e8 82 13 00 00       	call   802427 <set_pgfault_handler>
*/
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010a5:	b8 07 00 00 00       	mov    $0x7,%eax
  8010aa:	cd 30                	int    $0x30
  8010ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();
		
	if (envid<0){
  8010af:	83 c4 10             	add    $0x10,%esp
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	78 29                	js     8010df <fork+0x51>
  8010b6:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	// duplicate parent address space
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  8010b8:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid==0){
  8010bd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8010c1:	75 60                	jne    801123 <fork+0x95>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010c3:	e8 ed fc ff ff       	call   800db5 <sys_getenvid>
  8010c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010d5:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  8010da:	e9 14 01 00 00       	jmp    8011f3 <fork+0x165>
		panic("fork: sys_exofork error %e\n", envid);
  8010df:	50                   	push   %eax
  8010e0:	68 09 2d 80 00       	push   $0x802d09
  8010e5:	68 90 00 00 00       	push   $0x90
  8010ea:	68 fe 2c 80 00       	push   $0x802cfe
  8010ef:	e8 ad f1 ff ff       	call   8002a1 <_panic>
		r = sys_page_map(0, addr, envid, addr, (uvpt[pn]&PTE_SYSCALL));
  8010f4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010fb:	83 ec 0c             	sub    $0xc,%esp
  8010fe:	25 07 0e 00 00       	and    $0xe07,%eax
  801103:	50                   	push   %eax
  801104:	56                   	push   %esi
  801105:	57                   	push   %edi
  801106:	56                   	push   %esi
  801107:	6a 00                	push   $0x0
  801109:	e8 13 fd ff ff       	call   800e21 <sys_page_map>
  80110e:	83 c4 20             	add    $0x20,%esp
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  801111:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801117:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80111d:	0f 84 95 00 00 00    	je     8011b8 <fork+0x12a>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  801123:	89 d8                	mov    %ebx,%eax
  801125:	c1 e8 16             	shr    $0x16,%eax
  801128:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80112f:	a8 01                	test   $0x1,%al
  801131:	74 de                	je     801111 <fork+0x83>
  801133:	89 d8                	mov    %ebx,%eax
  801135:	c1 e8 0c             	shr    $0xc,%eax
  801138:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80113f:	f6 c2 01             	test   $0x1,%dl
  801142:	74 cd                	je     801111 <fork+0x83>
	void* addr = (void*)(pn*PGSIZE);
  801144:	89 c6                	mov    %eax,%esi
  801146:	c1 e6 0c             	shl    $0xc,%esi
	if (uvpt[pn]&PTE_SHARE){
  801149:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801150:	f6 c6 04             	test   $0x4,%dh
  801153:	75 9f                	jne    8010f4 <fork+0x66>
		if (uvpt[pn]&PTE_W||uvpt[pn]&PTE_COW){
  801155:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80115c:	f6 c2 02             	test   $0x2,%dl
  80115f:	75 0c                	jne    80116d <fork+0xdf>
  801161:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801168:	f6 c4 08             	test   $0x8,%ah
  80116b:	74 34                	je     8011a1 <fork+0x113>
			r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P); // not writable
  80116d:	83 ec 0c             	sub    $0xc,%esp
  801170:	68 05 08 00 00       	push   $0x805
  801175:	56                   	push   %esi
  801176:	57                   	push   %edi
  801177:	56                   	push   %esi
  801178:	6a 00                	push   $0x0
  80117a:	e8 a2 fc ff ff       	call   800e21 <sys_page_map>
			if (r<0) return r;
  80117f:	83 c4 20             	add    $0x20,%esp
  801182:	85 c0                	test   %eax,%eax
  801184:	78 8b                	js     801111 <fork+0x83>
			r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P); // not writable
  801186:	83 ec 0c             	sub    $0xc,%esp
  801189:	68 05 08 00 00       	push   $0x805
  80118e:	56                   	push   %esi
  80118f:	6a 00                	push   $0x0
  801191:	56                   	push   %esi
  801192:	6a 00                	push   $0x0
  801194:	e8 88 fc ff ff       	call   800e21 <sys_page_map>
  801199:	83 c4 20             	add    $0x20,%esp
  80119c:	e9 70 ff ff ff       	jmp    801111 <fork+0x83>
			if ((r=sys_page_map(0, addr, envid, addr, PTE_P|PTE_U)<0))// read only
  8011a1:	83 ec 0c             	sub    $0xc,%esp
  8011a4:	6a 05                	push   $0x5
  8011a6:	56                   	push   %esi
  8011a7:	57                   	push   %edi
  8011a8:	56                   	push   %esi
  8011a9:	6a 00                	push   $0x0
  8011ab:	e8 71 fc ff ff       	call   800e21 <sys_page_map>
  8011b0:	83 c4 20             	add    $0x20,%esp
  8011b3:	e9 59 ff ff ff       	jmp    801111 <fork+0x83>
			duppage(envid, PGNUM(addr));
		}
	}
	// allocate user exception stack
	// cprintf("alloc user expection stack\n");
	if ((r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_W|PTE_U))<0)
  8011b8:	83 ec 04             	sub    $0x4,%esp
  8011bb:	6a 07                	push   $0x7
  8011bd:	68 00 f0 bf ee       	push   $0xeebff000
  8011c2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8011c5:	56                   	push   %esi
  8011c6:	e8 30 fc ff ff       	call   800dfb <sys_page_alloc>
  8011cb:	83 c4 10             	add    $0x10,%esp
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	78 2b                	js     8011fd <fork+0x16f>
		return r;
	
	extern void* _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8011d2:	83 ec 08             	sub    $0x8,%esp
  8011d5:	68 9a 24 80 00       	push   $0x80249a
  8011da:	56                   	push   %esi
  8011db:	e8 d5 fc ff ff       	call   800eb5 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE))<0)
  8011e0:	83 c4 08             	add    $0x8,%esp
  8011e3:	6a 02                	push   $0x2
  8011e5:	56                   	push   %esi
  8011e6:	e8 80 fc ff ff       	call   800e6b <sys_env_set_status>
  8011eb:	83 c4 10             	add    $0x10,%esp
		return r;
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	0f 48 f8             	cmovs  %eax,%edi

	return envid;
	
}
  8011f3:	89 f8                	mov    %edi,%eax
  8011f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f8:	5b                   	pop    %ebx
  8011f9:	5e                   	pop    %esi
  8011fa:	5f                   	pop    %edi
  8011fb:	5d                   	pop    %ebp
  8011fc:	c3                   	ret    
		return r;
  8011fd:	89 c7                	mov    %eax,%edi
  8011ff:	eb f2                	jmp    8011f3 <fork+0x165>

00801201 <sfork>:

// Challenge(not sure yet)
int
sfork(void)
{
  801201:	f3 0f 1e fb          	endbr32 
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80120b:	68 25 2d 80 00       	push   $0x802d25
  801210:	68 b2 00 00 00       	push   $0xb2
  801215:	68 fe 2c 80 00       	push   $0x802cfe
  80121a:	e8 82 f0 ff ff       	call   8002a1 <_panic>

0080121f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80121f:	f3 0f 1e fb          	endbr32 
  801223:	55                   	push   %ebp
  801224:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801226:	8b 45 08             	mov    0x8(%ebp),%eax
  801229:	05 00 00 00 30       	add    $0x30000000,%eax
  80122e:	c1 e8 0c             	shr    $0xc,%eax
}
  801231:	5d                   	pop    %ebp
  801232:	c3                   	ret    

00801233 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801233:	f3 0f 1e fb          	endbr32 
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80123a:	8b 45 08             	mov    0x8(%ebp),%eax
  80123d:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801242:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801247:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80124c:	5d                   	pop    %ebp
  80124d:	c3                   	ret    

0080124e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80124e:	f3 0f 1e fb          	endbr32 
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80125a:	89 c2                	mov    %eax,%edx
  80125c:	c1 ea 16             	shr    $0x16,%edx
  80125f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801266:	f6 c2 01             	test   $0x1,%dl
  801269:	74 2d                	je     801298 <fd_alloc+0x4a>
  80126b:	89 c2                	mov    %eax,%edx
  80126d:	c1 ea 0c             	shr    $0xc,%edx
  801270:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801277:	f6 c2 01             	test   $0x1,%dl
  80127a:	74 1c                	je     801298 <fd_alloc+0x4a>
  80127c:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801281:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801286:	75 d2                	jne    80125a <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  801288:	8b 45 08             	mov    0x8(%ebp),%eax
  80128b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801291:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801296:	eb 0a                	jmp    8012a2 <fd_alloc+0x54>
			*fd_store = fd;
  801298:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80129b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80129d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012a2:	5d                   	pop    %ebp
  8012a3:	c3                   	ret    

008012a4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012a4:	f3 0f 1e fb          	endbr32 
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012ae:	83 f8 1f             	cmp    $0x1f,%eax
  8012b1:	77 30                	ja     8012e3 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012b3:	c1 e0 0c             	shl    $0xc,%eax
  8012b6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012bb:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8012c1:	f6 c2 01             	test   $0x1,%dl
  8012c4:	74 24                	je     8012ea <fd_lookup+0x46>
  8012c6:	89 c2                	mov    %eax,%edx
  8012c8:	c1 ea 0c             	shr    $0xc,%edx
  8012cb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012d2:	f6 c2 01             	test   $0x1,%dl
  8012d5:	74 1a                	je     8012f1 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012da:	89 02                	mov    %eax,(%edx)
	return 0;
  8012dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012e1:	5d                   	pop    %ebp
  8012e2:	c3                   	ret    
		return -E_INVAL;
  8012e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e8:	eb f7                	jmp    8012e1 <fd_lookup+0x3d>
		return -E_INVAL;
  8012ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ef:	eb f0                	jmp    8012e1 <fd_lookup+0x3d>
  8012f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f6:	eb e9                	jmp    8012e1 <fd_lookup+0x3d>

008012f8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012f8:	f3 0f 1e fb          	endbr32 
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	83 ec 08             	sub    $0x8,%esp
  801302:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801305:	ba 00 00 00 00       	mov    $0x0,%edx
  80130a:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  80130f:	39 08                	cmp    %ecx,(%eax)
  801311:	74 38                	je     80134b <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  801313:	83 c2 01             	add    $0x1,%edx
  801316:	8b 04 95 b8 2d 80 00 	mov    0x802db8(,%edx,4),%eax
  80131d:	85 c0                	test   %eax,%eax
  80131f:	75 ee                	jne    80130f <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801321:	a1 08 40 80 00       	mov    0x804008,%eax
  801326:	8b 40 48             	mov    0x48(%eax),%eax
  801329:	83 ec 04             	sub    $0x4,%esp
  80132c:	51                   	push   %ecx
  80132d:	50                   	push   %eax
  80132e:	68 3c 2d 80 00       	push   $0x802d3c
  801333:	e8 50 f0 ff ff       	call   800388 <cprintf>
	*dev = 0;
  801338:	8b 45 0c             	mov    0xc(%ebp),%eax
  80133b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801341:	83 c4 10             	add    $0x10,%esp
  801344:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801349:	c9                   	leave  
  80134a:	c3                   	ret    
			*dev = devtab[i];
  80134b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80134e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801350:	b8 00 00 00 00       	mov    $0x0,%eax
  801355:	eb f2                	jmp    801349 <dev_lookup+0x51>

00801357 <fd_close>:
{
  801357:	f3 0f 1e fb          	endbr32 
  80135b:	55                   	push   %ebp
  80135c:	89 e5                	mov    %esp,%ebp
  80135e:	57                   	push   %edi
  80135f:	56                   	push   %esi
  801360:	53                   	push   %ebx
  801361:	83 ec 24             	sub    $0x24,%esp
  801364:	8b 75 08             	mov    0x8(%ebp),%esi
  801367:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80136a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80136d:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80136e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801374:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801377:	50                   	push   %eax
  801378:	e8 27 ff ff ff       	call   8012a4 <fd_lookup>
  80137d:	89 c3                	mov    %eax,%ebx
  80137f:	83 c4 10             	add    $0x10,%esp
  801382:	85 c0                	test   %eax,%eax
  801384:	78 05                	js     80138b <fd_close+0x34>
	    || fd != fd2)
  801386:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801389:	74 16                	je     8013a1 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80138b:	89 f8                	mov    %edi,%eax
  80138d:	84 c0                	test   %al,%al
  80138f:	b8 00 00 00 00       	mov    $0x0,%eax
  801394:	0f 44 d8             	cmove  %eax,%ebx
}
  801397:	89 d8                	mov    %ebx,%eax
  801399:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80139c:	5b                   	pop    %ebx
  80139d:	5e                   	pop    %esi
  80139e:	5f                   	pop    %edi
  80139f:	5d                   	pop    %ebp
  8013a0:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013a1:	83 ec 08             	sub    $0x8,%esp
  8013a4:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013a7:	50                   	push   %eax
  8013a8:	ff 36                	pushl  (%esi)
  8013aa:	e8 49 ff ff ff       	call   8012f8 <dev_lookup>
  8013af:	89 c3                	mov    %eax,%ebx
  8013b1:	83 c4 10             	add    $0x10,%esp
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	78 1a                	js     8013d2 <fd_close+0x7b>
		if (dev->dev_close)
  8013b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013bb:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8013be:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	74 0b                	je     8013d2 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8013c7:	83 ec 0c             	sub    $0xc,%esp
  8013ca:	56                   	push   %esi
  8013cb:	ff d0                	call   *%eax
  8013cd:	89 c3                	mov    %eax,%ebx
  8013cf:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8013d2:	83 ec 08             	sub    $0x8,%esp
  8013d5:	56                   	push   %esi
  8013d6:	6a 00                	push   $0x0
  8013d8:	e8 69 fa ff ff       	call   800e46 <sys_page_unmap>
	return r;
  8013dd:	83 c4 10             	add    $0x10,%esp
  8013e0:	eb b5                	jmp    801397 <fd_close+0x40>

008013e2 <close>:

int
close(int fdnum)
{
  8013e2:	f3 0f 1e fb          	endbr32 
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ef:	50                   	push   %eax
  8013f0:	ff 75 08             	pushl  0x8(%ebp)
  8013f3:	e8 ac fe ff ff       	call   8012a4 <fd_lookup>
  8013f8:	83 c4 10             	add    $0x10,%esp
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	79 02                	jns    801401 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8013ff:	c9                   	leave  
  801400:	c3                   	ret    
		return fd_close(fd, 1);
  801401:	83 ec 08             	sub    $0x8,%esp
  801404:	6a 01                	push   $0x1
  801406:	ff 75 f4             	pushl  -0xc(%ebp)
  801409:	e8 49 ff ff ff       	call   801357 <fd_close>
  80140e:	83 c4 10             	add    $0x10,%esp
  801411:	eb ec                	jmp    8013ff <close+0x1d>

00801413 <close_all>:

void
close_all(void)
{
  801413:	f3 0f 1e fb          	endbr32 
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	53                   	push   %ebx
  80141b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80141e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801423:	83 ec 0c             	sub    $0xc,%esp
  801426:	53                   	push   %ebx
  801427:	e8 b6 ff ff ff       	call   8013e2 <close>
	for (i = 0; i < MAXFD; i++)
  80142c:	83 c3 01             	add    $0x1,%ebx
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	83 fb 20             	cmp    $0x20,%ebx
  801435:	75 ec                	jne    801423 <close_all+0x10>
}
  801437:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143a:	c9                   	leave  
  80143b:	c3                   	ret    

0080143c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80143c:	f3 0f 1e fb          	endbr32 
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	57                   	push   %edi
  801444:	56                   	push   %esi
  801445:	53                   	push   %ebx
  801446:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801449:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80144c:	50                   	push   %eax
  80144d:	ff 75 08             	pushl  0x8(%ebp)
  801450:	e8 4f fe ff ff       	call   8012a4 <fd_lookup>
  801455:	89 c3                	mov    %eax,%ebx
  801457:	83 c4 10             	add    $0x10,%esp
  80145a:	85 c0                	test   %eax,%eax
  80145c:	0f 88 81 00 00 00    	js     8014e3 <dup+0xa7>
		return r;
	close(newfdnum);
  801462:	83 ec 0c             	sub    $0xc,%esp
  801465:	ff 75 0c             	pushl  0xc(%ebp)
  801468:	e8 75 ff ff ff       	call   8013e2 <close>

	newfd = INDEX2FD(newfdnum);
  80146d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801470:	c1 e6 0c             	shl    $0xc,%esi
  801473:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801479:	83 c4 04             	add    $0x4,%esp
  80147c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80147f:	e8 af fd ff ff       	call   801233 <fd2data>
  801484:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801486:	89 34 24             	mov    %esi,(%esp)
  801489:	e8 a5 fd ff ff       	call   801233 <fd2data>
  80148e:	83 c4 10             	add    $0x10,%esp
  801491:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801493:	89 d8                	mov    %ebx,%eax
  801495:	c1 e8 16             	shr    $0x16,%eax
  801498:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80149f:	a8 01                	test   $0x1,%al
  8014a1:	74 11                	je     8014b4 <dup+0x78>
  8014a3:	89 d8                	mov    %ebx,%eax
  8014a5:	c1 e8 0c             	shr    $0xc,%eax
  8014a8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014af:	f6 c2 01             	test   $0x1,%dl
  8014b2:	75 39                	jne    8014ed <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014b7:	89 d0                	mov    %edx,%eax
  8014b9:	c1 e8 0c             	shr    $0xc,%eax
  8014bc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c3:	83 ec 0c             	sub    $0xc,%esp
  8014c6:	25 07 0e 00 00       	and    $0xe07,%eax
  8014cb:	50                   	push   %eax
  8014cc:	56                   	push   %esi
  8014cd:	6a 00                	push   $0x0
  8014cf:	52                   	push   %edx
  8014d0:	6a 00                	push   $0x0
  8014d2:	e8 4a f9 ff ff       	call   800e21 <sys_page_map>
  8014d7:	89 c3                	mov    %eax,%ebx
  8014d9:	83 c4 20             	add    $0x20,%esp
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	78 31                	js     801511 <dup+0xd5>
		goto err;

	return newfdnum;
  8014e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014e3:	89 d8                	mov    %ebx,%eax
  8014e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e8:	5b                   	pop    %ebx
  8014e9:	5e                   	pop    %esi
  8014ea:	5f                   	pop    %edi
  8014eb:	5d                   	pop    %ebp
  8014ec:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014f4:	83 ec 0c             	sub    $0xc,%esp
  8014f7:	25 07 0e 00 00       	and    $0xe07,%eax
  8014fc:	50                   	push   %eax
  8014fd:	57                   	push   %edi
  8014fe:	6a 00                	push   $0x0
  801500:	53                   	push   %ebx
  801501:	6a 00                	push   $0x0
  801503:	e8 19 f9 ff ff       	call   800e21 <sys_page_map>
  801508:	89 c3                	mov    %eax,%ebx
  80150a:	83 c4 20             	add    $0x20,%esp
  80150d:	85 c0                	test   %eax,%eax
  80150f:	79 a3                	jns    8014b4 <dup+0x78>
	sys_page_unmap(0, newfd);
  801511:	83 ec 08             	sub    $0x8,%esp
  801514:	56                   	push   %esi
  801515:	6a 00                	push   $0x0
  801517:	e8 2a f9 ff ff       	call   800e46 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80151c:	83 c4 08             	add    $0x8,%esp
  80151f:	57                   	push   %edi
  801520:	6a 00                	push   $0x0
  801522:	e8 1f f9 ff ff       	call   800e46 <sys_page_unmap>
	return r;
  801527:	83 c4 10             	add    $0x10,%esp
  80152a:	eb b7                	jmp    8014e3 <dup+0xa7>

0080152c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80152c:	f3 0f 1e fb          	endbr32 
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	53                   	push   %ebx
  801534:	83 ec 1c             	sub    $0x1c,%esp
  801537:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153d:	50                   	push   %eax
  80153e:	53                   	push   %ebx
  80153f:	e8 60 fd ff ff       	call   8012a4 <fd_lookup>
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	85 c0                	test   %eax,%eax
  801549:	78 3f                	js     80158a <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154b:	83 ec 08             	sub    $0x8,%esp
  80154e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801551:	50                   	push   %eax
  801552:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801555:	ff 30                	pushl  (%eax)
  801557:	e8 9c fd ff ff       	call   8012f8 <dev_lookup>
  80155c:	83 c4 10             	add    $0x10,%esp
  80155f:	85 c0                	test   %eax,%eax
  801561:	78 27                	js     80158a <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801563:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801566:	8b 42 08             	mov    0x8(%edx),%eax
  801569:	83 e0 03             	and    $0x3,%eax
  80156c:	83 f8 01             	cmp    $0x1,%eax
  80156f:	74 1e                	je     80158f <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801571:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801574:	8b 40 08             	mov    0x8(%eax),%eax
  801577:	85 c0                	test   %eax,%eax
  801579:	74 35                	je     8015b0 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80157b:	83 ec 04             	sub    $0x4,%esp
  80157e:	ff 75 10             	pushl  0x10(%ebp)
  801581:	ff 75 0c             	pushl  0xc(%ebp)
  801584:	52                   	push   %edx
  801585:	ff d0                	call   *%eax
  801587:	83 c4 10             	add    $0x10,%esp
}
  80158a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158d:	c9                   	leave  
  80158e:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80158f:	a1 08 40 80 00       	mov    0x804008,%eax
  801594:	8b 40 48             	mov    0x48(%eax),%eax
  801597:	83 ec 04             	sub    $0x4,%esp
  80159a:	53                   	push   %ebx
  80159b:	50                   	push   %eax
  80159c:	68 7d 2d 80 00       	push   $0x802d7d
  8015a1:	e8 e2 ed ff ff       	call   800388 <cprintf>
		return -E_INVAL;
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ae:	eb da                	jmp    80158a <read+0x5e>
		return -E_NOT_SUPP;
  8015b0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015b5:	eb d3                	jmp    80158a <read+0x5e>

008015b7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015b7:	f3 0f 1e fb          	endbr32 
  8015bb:	55                   	push   %ebp
  8015bc:	89 e5                	mov    %esp,%ebp
  8015be:	57                   	push   %edi
  8015bf:	56                   	push   %esi
  8015c0:	53                   	push   %ebx
  8015c1:	83 ec 0c             	sub    $0xc,%esp
  8015c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015c7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015cf:	eb 02                	jmp    8015d3 <readn+0x1c>
  8015d1:	01 c3                	add    %eax,%ebx
  8015d3:	39 f3                	cmp    %esi,%ebx
  8015d5:	73 21                	jae    8015f8 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015d7:	83 ec 04             	sub    $0x4,%esp
  8015da:	89 f0                	mov    %esi,%eax
  8015dc:	29 d8                	sub    %ebx,%eax
  8015de:	50                   	push   %eax
  8015df:	89 d8                	mov    %ebx,%eax
  8015e1:	03 45 0c             	add    0xc(%ebp),%eax
  8015e4:	50                   	push   %eax
  8015e5:	57                   	push   %edi
  8015e6:	e8 41 ff ff ff       	call   80152c <read>
		if (m < 0)
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	78 04                	js     8015f6 <readn+0x3f>
			return m;
		if (m == 0)
  8015f2:	75 dd                	jne    8015d1 <readn+0x1a>
  8015f4:	eb 02                	jmp    8015f8 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015f6:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8015f8:	89 d8                	mov    %ebx,%eax
  8015fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015fd:	5b                   	pop    %ebx
  8015fe:	5e                   	pop    %esi
  8015ff:	5f                   	pop    %edi
  801600:	5d                   	pop    %ebp
  801601:	c3                   	ret    

00801602 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801602:	f3 0f 1e fb          	endbr32 
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
  801609:	53                   	push   %ebx
  80160a:	83 ec 1c             	sub    $0x1c,%esp
  80160d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801610:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801613:	50                   	push   %eax
  801614:	53                   	push   %ebx
  801615:	e8 8a fc ff ff       	call   8012a4 <fd_lookup>
  80161a:	83 c4 10             	add    $0x10,%esp
  80161d:	85 c0                	test   %eax,%eax
  80161f:	78 3a                	js     80165b <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801621:	83 ec 08             	sub    $0x8,%esp
  801624:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801627:	50                   	push   %eax
  801628:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162b:	ff 30                	pushl  (%eax)
  80162d:	e8 c6 fc ff ff       	call   8012f8 <dev_lookup>
  801632:	83 c4 10             	add    $0x10,%esp
  801635:	85 c0                	test   %eax,%eax
  801637:	78 22                	js     80165b <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801639:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801640:	74 1e                	je     801660 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801642:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801645:	8b 52 0c             	mov    0xc(%edx),%edx
  801648:	85 d2                	test   %edx,%edx
  80164a:	74 35                	je     801681 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80164c:	83 ec 04             	sub    $0x4,%esp
  80164f:	ff 75 10             	pushl  0x10(%ebp)
  801652:	ff 75 0c             	pushl  0xc(%ebp)
  801655:	50                   	push   %eax
  801656:	ff d2                	call   *%edx
  801658:	83 c4 10             	add    $0x10,%esp
}
  80165b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165e:	c9                   	leave  
  80165f:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801660:	a1 08 40 80 00       	mov    0x804008,%eax
  801665:	8b 40 48             	mov    0x48(%eax),%eax
  801668:	83 ec 04             	sub    $0x4,%esp
  80166b:	53                   	push   %ebx
  80166c:	50                   	push   %eax
  80166d:	68 99 2d 80 00       	push   $0x802d99
  801672:	e8 11 ed ff ff       	call   800388 <cprintf>
		return -E_INVAL;
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80167f:	eb da                	jmp    80165b <write+0x59>
		return -E_NOT_SUPP;
  801681:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801686:	eb d3                	jmp    80165b <write+0x59>

00801688 <seek>:

int
seek(int fdnum, off_t offset)
{
  801688:	f3 0f 1e fb          	endbr32 
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801692:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801695:	50                   	push   %eax
  801696:	ff 75 08             	pushl  0x8(%ebp)
  801699:	e8 06 fc ff ff       	call   8012a4 <fd_lookup>
  80169e:	83 c4 10             	add    $0x10,%esp
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	78 0e                	js     8016b3 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8016a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ab:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016b3:	c9                   	leave  
  8016b4:	c3                   	ret    

008016b5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016b5:	f3 0f 1e fb          	endbr32 
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	53                   	push   %ebx
  8016bd:	83 ec 1c             	sub    $0x1c,%esp
  8016c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c6:	50                   	push   %eax
  8016c7:	53                   	push   %ebx
  8016c8:	e8 d7 fb ff ff       	call   8012a4 <fd_lookup>
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	85 c0                	test   %eax,%eax
  8016d2:	78 37                	js     80170b <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d4:	83 ec 08             	sub    $0x8,%esp
  8016d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016da:	50                   	push   %eax
  8016db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016de:	ff 30                	pushl  (%eax)
  8016e0:	e8 13 fc ff ff       	call   8012f8 <dev_lookup>
  8016e5:	83 c4 10             	add    $0x10,%esp
  8016e8:	85 c0                	test   %eax,%eax
  8016ea:	78 1f                	js     80170b <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ef:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016f3:	74 1b                	je     801710 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8016f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f8:	8b 52 18             	mov    0x18(%edx),%edx
  8016fb:	85 d2                	test   %edx,%edx
  8016fd:	74 32                	je     801731 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016ff:	83 ec 08             	sub    $0x8,%esp
  801702:	ff 75 0c             	pushl  0xc(%ebp)
  801705:	50                   	push   %eax
  801706:	ff d2                	call   *%edx
  801708:	83 c4 10             	add    $0x10,%esp
}
  80170b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170e:	c9                   	leave  
  80170f:	c3                   	ret    
			thisenv->env_id, fdnum);
  801710:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801715:	8b 40 48             	mov    0x48(%eax),%eax
  801718:	83 ec 04             	sub    $0x4,%esp
  80171b:	53                   	push   %ebx
  80171c:	50                   	push   %eax
  80171d:	68 5c 2d 80 00       	push   $0x802d5c
  801722:	e8 61 ec ff ff       	call   800388 <cprintf>
		return -E_INVAL;
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80172f:	eb da                	jmp    80170b <ftruncate+0x56>
		return -E_NOT_SUPP;
  801731:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801736:	eb d3                	jmp    80170b <ftruncate+0x56>

00801738 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801738:	f3 0f 1e fb          	endbr32 
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	53                   	push   %ebx
  801740:	83 ec 1c             	sub    $0x1c,%esp
  801743:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801746:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801749:	50                   	push   %eax
  80174a:	ff 75 08             	pushl  0x8(%ebp)
  80174d:	e8 52 fb ff ff       	call   8012a4 <fd_lookup>
  801752:	83 c4 10             	add    $0x10,%esp
  801755:	85 c0                	test   %eax,%eax
  801757:	78 4b                	js     8017a4 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801759:	83 ec 08             	sub    $0x8,%esp
  80175c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175f:	50                   	push   %eax
  801760:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801763:	ff 30                	pushl  (%eax)
  801765:	e8 8e fb ff ff       	call   8012f8 <dev_lookup>
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	85 c0                	test   %eax,%eax
  80176f:	78 33                	js     8017a4 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801771:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801774:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801778:	74 2f                	je     8017a9 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80177a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80177d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801784:	00 00 00 
	stat->st_isdir = 0;
  801787:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80178e:	00 00 00 
	stat->st_dev = dev;
  801791:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801797:	83 ec 08             	sub    $0x8,%esp
  80179a:	53                   	push   %ebx
  80179b:	ff 75 f0             	pushl  -0x10(%ebp)
  80179e:	ff 50 14             	call   *0x14(%eax)
  8017a1:	83 c4 10             	add    $0x10,%esp
}
  8017a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a7:	c9                   	leave  
  8017a8:	c3                   	ret    
		return -E_NOT_SUPP;
  8017a9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017ae:	eb f4                	jmp    8017a4 <fstat+0x6c>

008017b0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017b0:	f3 0f 1e fb          	endbr32 
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	56                   	push   %esi
  8017b8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017b9:	83 ec 08             	sub    $0x8,%esp
  8017bc:	6a 00                	push   $0x0
  8017be:	ff 75 08             	pushl  0x8(%ebp)
  8017c1:	e8 01 02 00 00       	call   8019c7 <open>
  8017c6:	89 c3                	mov    %eax,%ebx
  8017c8:	83 c4 10             	add    $0x10,%esp
  8017cb:	85 c0                	test   %eax,%eax
  8017cd:	78 1b                	js     8017ea <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8017cf:	83 ec 08             	sub    $0x8,%esp
  8017d2:	ff 75 0c             	pushl  0xc(%ebp)
  8017d5:	50                   	push   %eax
  8017d6:	e8 5d ff ff ff       	call   801738 <fstat>
  8017db:	89 c6                	mov    %eax,%esi
	close(fd);
  8017dd:	89 1c 24             	mov    %ebx,(%esp)
  8017e0:	e8 fd fb ff ff       	call   8013e2 <close>
	return r;
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	89 f3                	mov    %esi,%ebx
}
  8017ea:	89 d8                	mov    %ebx,%eax
  8017ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ef:	5b                   	pop    %ebx
  8017f0:	5e                   	pop    %esi
  8017f1:	5d                   	pop    %ebp
  8017f2:	c3                   	ret    

008017f3 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	56                   	push   %esi
  8017f7:	53                   	push   %ebx
  8017f8:	89 c6                	mov    %eax,%esi
  8017fa:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017fc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801803:	74 27                	je     80182c <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801805:	6a 07                	push   $0x7
  801807:	68 00 50 80 00       	push   $0x805000
  80180c:	56                   	push   %esi
  80180d:	ff 35 00 40 80 00    	pushl  0x804000
  801813:	e8 13 0d 00 00       	call   80252b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801818:	83 c4 0c             	add    $0xc,%esp
  80181b:	6a 00                	push   $0x0
  80181d:	53                   	push   %ebx
  80181e:	6a 00                	push   $0x0
  801820:	e8 99 0c 00 00       	call   8024be <ipc_recv>
}
  801825:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801828:	5b                   	pop    %ebx
  801829:	5e                   	pop    %esi
  80182a:	5d                   	pop    %ebp
  80182b:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80182c:	83 ec 0c             	sub    $0xc,%esp
  80182f:	6a 01                	push   $0x1
  801831:	e8 4d 0d 00 00       	call   802583 <ipc_find_env>
  801836:	a3 00 40 80 00       	mov    %eax,0x804000
  80183b:	83 c4 10             	add    $0x10,%esp
  80183e:	eb c5                	jmp    801805 <fsipc+0x12>

00801840 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801840:	f3 0f 1e fb          	endbr32 
  801844:	55                   	push   %ebp
  801845:	89 e5                	mov    %esp,%ebp
  801847:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80184a:	8b 45 08             	mov    0x8(%ebp),%eax
  80184d:	8b 40 0c             	mov    0xc(%eax),%eax
  801850:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801855:	8b 45 0c             	mov    0xc(%ebp),%eax
  801858:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80185d:	ba 00 00 00 00       	mov    $0x0,%edx
  801862:	b8 02 00 00 00       	mov    $0x2,%eax
  801867:	e8 87 ff ff ff       	call   8017f3 <fsipc>
}
  80186c:	c9                   	leave  
  80186d:	c3                   	ret    

0080186e <devfile_flush>:
{
  80186e:	f3 0f 1e fb          	endbr32 
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801878:	8b 45 08             	mov    0x8(%ebp),%eax
  80187b:	8b 40 0c             	mov    0xc(%eax),%eax
  80187e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801883:	ba 00 00 00 00       	mov    $0x0,%edx
  801888:	b8 06 00 00 00       	mov    $0x6,%eax
  80188d:	e8 61 ff ff ff       	call   8017f3 <fsipc>
}
  801892:	c9                   	leave  
  801893:	c3                   	ret    

00801894 <devfile_stat>:
{
  801894:	f3 0f 1e fb          	endbr32 
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	53                   	push   %ebx
  80189c:	83 ec 04             	sub    $0x4,%esp
  80189f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8018b7:	e8 37 ff ff ff       	call   8017f3 <fsipc>
  8018bc:	85 c0                	test   %eax,%eax
  8018be:	78 2c                	js     8018ec <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018c0:	83 ec 08             	sub    $0x8,%esp
  8018c3:	68 00 50 80 00       	push   $0x805000
  8018c8:	53                   	push   %ebx
  8018c9:	e8 c4 f0 ff ff       	call   800992 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018ce:	a1 80 50 80 00       	mov    0x805080,%eax
  8018d3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018d9:	a1 84 50 80 00       	mov    0x805084,%eax
  8018de:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018e4:	83 c4 10             	add    $0x10,%esp
  8018e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ef:	c9                   	leave  
  8018f0:	c3                   	ret    

008018f1 <devfile_write>:
{
  8018f1:	f3 0f 1e fb          	endbr32 
  8018f5:	55                   	push   %ebp
  8018f6:	89 e5                	mov    %esp,%ebp
  8018f8:	83 ec 0c             	sub    $0xc,%esp
  8018fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8018fe:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801903:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801908:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80190b:	8b 55 08             	mov    0x8(%ebp),%edx
  80190e:	8b 52 0c             	mov    0xc(%edx),%edx
  801911:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801917:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80191c:	50                   	push   %eax
  80191d:	ff 75 0c             	pushl  0xc(%ebp)
  801920:	68 08 50 80 00       	push   $0x805008
  801925:	e8 66 f2 ff ff       	call   800b90 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80192a:	ba 00 00 00 00       	mov    $0x0,%edx
  80192f:	b8 04 00 00 00       	mov    $0x4,%eax
  801934:	e8 ba fe ff ff       	call   8017f3 <fsipc>
}
  801939:	c9                   	leave  
  80193a:	c3                   	ret    

0080193b <devfile_read>:
{
  80193b:	f3 0f 1e fb          	endbr32 
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	56                   	push   %esi
  801943:	53                   	push   %ebx
  801944:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801947:	8b 45 08             	mov    0x8(%ebp),%eax
  80194a:	8b 40 0c             	mov    0xc(%eax),%eax
  80194d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801952:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801958:	ba 00 00 00 00       	mov    $0x0,%edx
  80195d:	b8 03 00 00 00       	mov    $0x3,%eax
  801962:	e8 8c fe ff ff       	call   8017f3 <fsipc>
  801967:	89 c3                	mov    %eax,%ebx
  801969:	85 c0                	test   %eax,%eax
  80196b:	78 1f                	js     80198c <devfile_read+0x51>
	assert(r <= n);
  80196d:	39 f0                	cmp    %esi,%eax
  80196f:	77 24                	ja     801995 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801971:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801976:	7f 36                	jg     8019ae <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801978:	83 ec 04             	sub    $0x4,%esp
  80197b:	50                   	push   %eax
  80197c:	68 00 50 80 00       	push   $0x805000
  801981:	ff 75 0c             	pushl  0xc(%ebp)
  801984:	e8 07 f2 ff ff       	call   800b90 <memmove>
	return r;
  801989:	83 c4 10             	add    $0x10,%esp
}
  80198c:	89 d8                	mov    %ebx,%eax
  80198e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801991:	5b                   	pop    %ebx
  801992:	5e                   	pop    %esi
  801993:	5d                   	pop    %ebp
  801994:	c3                   	ret    
	assert(r <= n);
  801995:	68 cc 2d 80 00       	push   $0x802dcc
  80199a:	68 d3 2d 80 00       	push   $0x802dd3
  80199f:	68 8c 00 00 00       	push   $0x8c
  8019a4:	68 e8 2d 80 00       	push   $0x802de8
  8019a9:	e8 f3 e8 ff ff       	call   8002a1 <_panic>
	assert(r <= PGSIZE);
  8019ae:	68 f3 2d 80 00       	push   $0x802df3
  8019b3:	68 d3 2d 80 00       	push   $0x802dd3
  8019b8:	68 8d 00 00 00       	push   $0x8d
  8019bd:	68 e8 2d 80 00       	push   $0x802de8
  8019c2:	e8 da e8 ff ff       	call   8002a1 <_panic>

008019c7 <open>:
{
  8019c7:	f3 0f 1e fb          	endbr32 
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	56                   	push   %esi
  8019cf:	53                   	push   %ebx
  8019d0:	83 ec 1c             	sub    $0x1c,%esp
  8019d3:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8019d6:	56                   	push   %esi
  8019d7:	e8 73 ef ff ff       	call   80094f <strlen>
  8019dc:	83 c4 10             	add    $0x10,%esp
  8019df:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019e4:	7f 6c                	jg     801a52 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8019e6:	83 ec 0c             	sub    $0xc,%esp
  8019e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ec:	50                   	push   %eax
  8019ed:	e8 5c f8 ff ff       	call   80124e <fd_alloc>
  8019f2:	89 c3                	mov    %eax,%ebx
  8019f4:	83 c4 10             	add    $0x10,%esp
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	78 3c                	js     801a37 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8019fb:	83 ec 08             	sub    $0x8,%esp
  8019fe:	56                   	push   %esi
  8019ff:	68 00 50 80 00       	push   $0x805000
  801a04:	e8 89 ef ff ff       	call   800992 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a09:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0c:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a11:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a14:	b8 01 00 00 00       	mov    $0x1,%eax
  801a19:	e8 d5 fd ff ff       	call   8017f3 <fsipc>
  801a1e:	89 c3                	mov    %eax,%ebx
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	85 c0                	test   %eax,%eax
  801a25:	78 19                	js     801a40 <open+0x79>
	return fd2num(fd);
  801a27:	83 ec 0c             	sub    $0xc,%esp
  801a2a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a2d:	e8 ed f7 ff ff       	call   80121f <fd2num>
  801a32:	89 c3                	mov    %eax,%ebx
  801a34:	83 c4 10             	add    $0x10,%esp
}
  801a37:	89 d8                	mov    %ebx,%eax
  801a39:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a3c:	5b                   	pop    %ebx
  801a3d:	5e                   	pop    %esi
  801a3e:	5d                   	pop    %ebp
  801a3f:	c3                   	ret    
		fd_close(fd, 0);
  801a40:	83 ec 08             	sub    $0x8,%esp
  801a43:	6a 00                	push   $0x0
  801a45:	ff 75 f4             	pushl  -0xc(%ebp)
  801a48:	e8 0a f9 ff ff       	call   801357 <fd_close>
		return r;
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	eb e5                	jmp    801a37 <open+0x70>
		return -E_BAD_PATH;
  801a52:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a57:	eb de                	jmp    801a37 <open+0x70>

00801a59 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a59:	f3 0f 1e fb          	endbr32 
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a63:	ba 00 00 00 00       	mov    $0x0,%edx
  801a68:	b8 08 00 00 00       	mov    $0x8,%eax
  801a6d:	e8 81 fd ff ff       	call   8017f3 <fsipc>
}
  801a72:	c9                   	leave  
  801a73:	c3                   	ret    

00801a74 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a74:	f3 0f 1e fb          	endbr32 
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a7e:	68 5f 2e 80 00       	push   $0x802e5f
  801a83:	ff 75 0c             	pushl  0xc(%ebp)
  801a86:	e8 07 ef ff ff       	call   800992 <strcpy>
	return 0;
}
  801a8b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a90:	c9                   	leave  
  801a91:	c3                   	ret    

00801a92 <devsock_close>:
{
  801a92:	f3 0f 1e fb          	endbr32 
  801a96:	55                   	push   %ebp
  801a97:	89 e5                	mov    %esp,%ebp
  801a99:	53                   	push   %ebx
  801a9a:	83 ec 10             	sub    $0x10,%esp
  801a9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801aa0:	53                   	push   %ebx
  801aa1:	e8 1a 0b 00 00       	call   8025c0 <pageref>
  801aa6:	89 c2                	mov    %eax,%edx
  801aa8:	83 c4 10             	add    $0x10,%esp
		return 0;
  801aab:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801ab0:	83 fa 01             	cmp    $0x1,%edx
  801ab3:	74 05                	je     801aba <devsock_close+0x28>
}
  801ab5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab8:	c9                   	leave  
  801ab9:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801aba:	83 ec 0c             	sub    $0xc,%esp
  801abd:	ff 73 0c             	pushl  0xc(%ebx)
  801ac0:	e8 e3 02 00 00       	call   801da8 <nsipc_close>
  801ac5:	83 c4 10             	add    $0x10,%esp
  801ac8:	eb eb                	jmp    801ab5 <devsock_close+0x23>

00801aca <devsock_write>:
{
  801aca:	f3 0f 1e fb          	endbr32 
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ad4:	6a 00                	push   $0x0
  801ad6:	ff 75 10             	pushl  0x10(%ebp)
  801ad9:	ff 75 0c             	pushl  0xc(%ebp)
  801adc:	8b 45 08             	mov    0x8(%ebp),%eax
  801adf:	ff 70 0c             	pushl  0xc(%eax)
  801ae2:	e8 b5 03 00 00       	call   801e9c <nsipc_send>
}
  801ae7:	c9                   	leave  
  801ae8:	c3                   	ret    

00801ae9 <devsock_read>:
{
  801ae9:	f3 0f 1e fb          	endbr32 
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801af3:	6a 00                	push   $0x0
  801af5:	ff 75 10             	pushl  0x10(%ebp)
  801af8:	ff 75 0c             	pushl  0xc(%ebp)
  801afb:	8b 45 08             	mov    0x8(%ebp),%eax
  801afe:	ff 70 0c             	pushl  0xc(%eax)
  801b01:	e8 1f 03 00 00       	call   801e25 <nsipc_recv>
}
  801b06:	c9                   	leave  
  801b07:	c3                   	ret    

00801b08 <fd2sockid>:
{
  801b08:	55                   	push   %ebp
  801b09:	89 e5                	mov    %esp,%ebp
  801b0b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b0e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b11:	52                   	push   %edx
  801b12:	50                   	push   %eax
  801b13:	e8 8c f7 ff ff       	call   8012a4 <fd_lookup>
  801b18:	83 c4 10             	add    $0x10,%esp
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	78 10                	js     801b2f <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b22:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  801b28:	39 08                	cmp    %ecx,(%eax)
  801b2a:	75 05                	jne    801b31 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801b2c:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801b2f:	c9                   	leave  
  801b30:	c3                   	ret    
		return -E_NOT_SUPP;
  801b31:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b36:	eb f7                	jmp    801b2f <fd2sockid+0x27>

00801b38 <alloc_sockfd>:
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	56                   	push   %esi
  801b3c:	53                   	push   %ebx
  801b3d:	83 ec 1c             	sub    $0x1c,%esp
  801b40:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801b42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b45:	50                   	push   %eax
  801b46:	e8 03 f7 ff ff       	call   80124e <fd_alloc>
  801b4b:	89 c3                	mov    %eax,%ebx
  801b4d:	83 c4 10             	add    $0x10,%esp
  801b50:	85 c0                	test   %eax,%eax
  801b52:	78 43                	js     801b97 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b54:	83 ec 04             	sub    $0x4,%esp
  801b57:	68 07 04 00 00       	push   $0x407
  801b5c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b5f:	6a 00                	push   $0x0
  801b61:	e8 95 f2 ff ff       	call   800dfb <sys_page_alloc>
  801b66:	89 c3                	mov    %eax,%ebx
  801b68:	83 c4 10             	add    $0x10,%esp
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	78 28                	js     801b97 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b72:	8b 15 60 30 80 00    	mov    0x803060,%edx
  801b78:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b84:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b87:	83 ec 0c             	sub    $0xc,%esp
  801b8a:	50                   	push   %eax
  801b8b:	e8 8f f6 ff ff       	call   80121f <fd2num>
  801b90:	89 c3                	mov    %eax,%ebx
  801b92:	83 c4 10             	add    $0x10,%esp
  801b95:	eb 0c                	jmp    801ba3 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801b97:	83 ec 0c             	sub    $0xc,%esp
  801b9a:	56                   	push   %esi
  801b9b:	e8 08 02 00 00       	call   801da8 <nsipc_close>
		return r;
  801ba0:	83 c4 10             	add    $0x10,%esp
}
  801ba3:	89 d8                	mov    %ebx,%eax
  801ba5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ba8:	5b                   	pop    %ebx
  801ba9:	5e                   	pop    %esi
  801baa:	5d                   	pop    %ebp
  801bab:	c3                   	ret    

00801bac <accept>:
{
  801bac:	f3 0f 1e fb          	endbr32 
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb9:	e8 4a ff ff ff       	call   801b08 <fd2sockid>
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	78 1b                	js     801bdd <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bc2:	83 ec 04             	sub    $0x4,%esp
  801bc5:	ff 75 10             	pushl  0x10(%ebp)
  801bc8:	ff 75 0c             	pushl  0xc(%ebp)
  801bcb:	50                   	push   %eax
  801bcc:	e8 22 01 00 00       	call   801cf3 <nsipc_accept>
  801bd1:	83 c4 10             	add    $0x10,%esp
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	78 05                	js     801bdd <accept+0x31>
	return alloc_sockfd(r);
  801bd8:	e8 5b ff ff ff       	call   801b38 <alloc_sockfd>
}
  801bdd:	c9                   	leave  
  801bde:	c3                   	ret    

00801bdf <bind>:
{
  801bdf:	f3 0f 1e fb          	endbr32 
  801be3:	55                   	push   %ebp
  801be4:	89 e5                	mov    %esp,%ebp
  801be6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801be9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bec:	e8 17 ff ff ff       	call   801b08 <fd2sockid>
  801bf1:	85 c0                	test   %eax,%eax
  801bf3:	78 12                	js     801c07 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801bf5:	83 ec 04             	sub    $0x4,%esp
  801bf8:	ff 75 10             	pushl  0x10(%ebp)
  801bfb:	ff 75 0c             	pushl  0xc(%ebp)
  801bfe:	50                   	push   %eax
  801bff:	e8 45 01 00 00       	call   801d49 <nsipc_bind>
  801c04:	83 c4 10             	add    $0x10,%esp
}
  801c07:	c9                   	leave  
  801c08:	c3                   	ret    

00801c09 <shutdown>:
{
  801c09:	f3 0f 1e fb          	endbr32 
  801c0d:	55                   	push   %ebp
  801c0e:	89 e5                	mov    %esp,%ebp
  801c10:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c13:	8b 45 08             	mov    0x8(%ebp),%eax
  801c16:	e8 ed fe ff ff       	call   801b08 <fd2sockid>
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	78 0f                	js     801c2e <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801c1f:	83 ec 08             	sub    $0x8,%esp
  801c22:	ff 75 0c             	pushl  0xc(%ebp)
  801c25:	50                   	push   %eax
  801c26:	e8 57 01 00 00       	call   801d82 <nsipc_shutdown>
  801c2b:	83 c4 10             	add    $0x10,%esp
}
  801c2e:	c9                   	leave  
  801c2f:	c3                   	ret    

00801c30 <connect>:
{
  801c30:	f3 0f 1e fb          	endbr32 
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3d:	e8 c6 fe ff ff       	call   801b08 <fd2sockid>
  801c42:	85 c0                	test   %eax,%eax
  801c44:	78 12                	js     801c58 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801c46:	83 ec 04             	sub    $0x4,%esp
  801c49:	ff 75 10             	pushl  0x10(%ebp)
  801c4c:	ff 75 0c             	pushl  0xc(%ebp)
  801c4f:	50                   	push   %eax
  801c50:	e8 71 01 00 00       	call   801dc6 <nsipc_connect>
  801c55:	83 c4 10             	add    $0x10,%esp
}
  801c58:	c9                   	leave  
  801c59:	c3                   	ret    

00801c5a <listen>:
{
  801c5a:	f3 0f 1e fb          	endbr32 
  801c5e:	55                   	push   %ebp
  801c5f:	89 e5                	mov    %esp,%ebp
  801c61:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c64:	8b 45 08             	mov    0x8(%ebp),%eax
  801c67:	e8 9c fe ff ff       	call   801b08 <fd2sockid>
  801c6c:	85 c0                	test   %eax,%eax
  801c6e:	78 0f                	js     801c7f <listen+0x25>
	return nsipc_listen(r, backlog);
  801c70:	83 ec 08             	sub    $0x8,%esp
  801c73:	ff 75 0c             	pushl  0xc(%ebp)
  801c76:	50                   	push   %eax
  801c77:	e8 83 01 00 00       	call   801dff <nsipc_listen>
  801c7c:	83 c4 10             	add    $0x10,%esp
}
  801c7f:	c9                   	leave  
  801c80:	c3                   	ret    

00801c81 <socket>:

int
socket(int domain, int type, int protocol)
{
  801c81:	f3 0f 1e fb          	endbr32 
  801c85:	55                   	push   %ebp
  801c86:	89 e5                	mov    %esp,%ebp
  801c88:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c8b:	ff 75 10             	pushl  0x10(%ebp)
  801c8e:	ff 75 0c             	pushl  0xc(%ebp)
  801c91:	ff 75 08             	pushl  0x8(%ebp)
  801c94:	e8 65 02 00 00       	call   801efe <nsipc_socket>
  801c99:	83 c4 10             	add    $0x10,%esp
  801c9c:	85 c0                	test   %eax,%eax
  801c9e:	78 05                	js     801ca5 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801ca0:	e8 93 fe ff ff       	call   801b38 <alloc_sockfd>
}
  801ca5:	c9                   	leave  
  801ca6:	c3                   	ret    

00801ca7 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	53                   	push   %ebx
  801cab:	83 ec 04             	sub    $0x4,%esp
  801cae:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801cb0:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801cb7:	74 26                	je     801cdf <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801cb9:	6a 07                	push   $0x7
  801cbb:	68 00 60 80 00       	push   $0x806000
  801cc0:	53                   	push   %ebx
  801cc1:	ff 35 04 40 80 00    	pushl  0x804004
  801cc7:	e8 5f 08 00 00       	call   80252b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ccc:	83 c4 0c             	add    $0xc,%esp
  801ccf:	6a 00                	push   $0x0
  801cd1:	6a 00                	push   $0x0
  801cd3:	6a 00                	push   $0x0
  801cd5:	e8 e4 07 00 00       	call   8024be <ipc_recv>
}
  801cda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cdd:	c9                   	leave  
  801cde:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801cdf:	83 ec 0c             	sub    $0xc,%esp
  801ce2:	6a 02                	push   $0x2
  801ce4:	e8 9a 08 00 00       	call   802583 <ipc_find_env>
  801ce9:	a3 04 40 80 00       	mov    %eax,0x804004
  801cee:	83 c4 10             	add    $0x10,%esp
  801cf1:	eb c6                	jmp    801cb9 <nsipc+0x12>

00801cf3 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cf3:	f3 0f 1e fb          	endbr32 
  801cf7:	55                   	push   %ebp
  801cf8:	89 e5                	mov    %esp,%ebp
  801cfa:	56                   	push   %esi
  801cfb:	53                   	push   %ebx
  801cfc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801cff:	8b 45 08             	mov    0x8(%ebp),%eax
  801d02:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d07:	8b 06                	mov    (%esi),%eax
  801d09:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d0e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d13:	e8 8f ff ff ff       	call   801ca7 <nsipc>
  801d18:	89 c3                	mov    %eax,%ebx
  801d1a:	85 c0                	test   %eax,%eax
  801d1c:	79 09                	jns    801d27 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801d1e:	89 d8                	mov    %ebx,%eax
  801d20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d23:	5b                   	pop    %ebx
  801d24:	5e                   	pop    %esi
  801d25:	5d                   	pop    %ebp
  801d26:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d27:	83 ec 04             	sub    $0x4,%esp
  801d2a:	ff 35 10 60 80 00    	pushl  0x806010
  801d30:	68 00 60 80 00       	push   $0x806000
  801d35:	ff 75 0c             	pushl  0xc(%ebp)
  801d38:	e8 53 ee ff ff       	call   800b90 <memmove>
		*addrlen = ret->ret_addrlen;
  801d3d:	a1 10 60 80 00       	mov    0x806010,%eax
  801d42:	89 06                	mov    %eax,(%esi)
  801d44:	83 c4 10             	add    $0x10,%esp
	return r;
  801d47:	eb d5                	jmp    801d1e <nsipc_accept+0x2b>

00801d49 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d49:	f3 0f 1e fb          	endbr32 
  801d4d:	55                   	push   %ebp
  801d4e:	89 e5                	mov    %esp,%ebp
  801d50:	53                   	push   %ebx
  801d51:	83 ec 08             	sub    $0x8,%esp
  801d54:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d57:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5a:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d5f:	53                   	push   %ebx
  801d60:	ff 75 0c             	pushl  0xc(%ebp)
  801d63:	68 04 60 80 00       	push   $0x806004
  801d68:	e8 23 ee ff ff       	call   800b90 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d6d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d73:	b8 02 00 00 00       	mov    $0x2,%eax
  801d78:	e8 2a ff ff ff       	call   801ca7 <nsipc>
}
  801d7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d80:	c9                   	leave  
  801d81:	c3                   	ret    

00801d82 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d82:	f3 0f 1e fb          	endbr32 
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
  801d89:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d97:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d9c:	b8 03 00 00 00       	mov    $0x3,%eax
  801da1:	e8 01 ff ff ff       	call   801ca7 <nsipc>
}
  801da6:	c9                   	leave  
  801da7:	c3                   	ret    

00801da8 <nsipc_close>:

int
nsipc_close(int s)
{
  801da8:	f3 0f 1e fb          	endbr32 
  801dac:	55                   	push   %ebp
  801dad:	89 e5                	mov    %esp,%ebp
  801daf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801db2:	8b 45 08             	mov    0x8(%ebp),%eax
  801db5:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801dba:	b8 04 00 00 00       	mov    $0x4,%eax
  801dbf:	e8 e3 fe ff ff       	call   801ca7 <nsipc>
}
  801dc4:	c9                   	leave  
  801dc5:	c3                   	ret    

00801dc6 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801dc6:	f3 0f 1e fb          	endbr32 
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
  801dcd:	53                   	push   %ebx
  801dce:	83 ec 08             	sub    $0x8,%esp
  801dd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801dd4:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ddc:	53                   	push   %ebx
  801ddd:	ff 75 0c             	pushl  0xc(%ebp)
  801de0:	68 04 60 80 00       	push   $0x806004
  801de5:	e8 a6 ed ff ff       	call   800b90 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801dea:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801df0:	b8 05 00 00 00       	mov    $0x5,%eax
  801df5:	e8 ad fe ff ff       	call   801ca7 <nsipc>
}
  801dfa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dfd:	c9                   	leave  
  801dfe:	c3                   	ret    

00801dff <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801dff:	f3 0f 1e fb          	endbr32 
  801e03:	55                   	push   %ebp
  801e04:	89 e5                	mov    %esp,%ebp
  801e06:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e09:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e11:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e14:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e19:	b8 06 00 00 00       	mov    $0x6,%eax
  801e1e:	e8 84 fe ff ff       	call   801ca7 <nsipc>
}
  801e23:	c9                   	leave  
  801e24:	c3                   	ret    

00801e25 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e25:	f3 0f 1e fb          	endbr32 
  801e29:	55                   	push   %ebp
  801e2a:	89 e5                	mov    %esp,%ebp
  801e2c:	56                   	push   %esi
  801e2d:	53                   	push   %ebx
  801e2e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e31:	8b 45 08             	mov    0x8(%ebp),%eax
  801e34:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e39:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e3f:	8b 45 14             	mov    0x14(%ebp),%eax
  801e42:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e47:	b8 07 00 00 00       	mov    $0x7,%eax
  801e4c:	e8 56 fe ff ff       	call   801ca7 <nsipc>
  801e51:	89 c3                	mov    %eax,%ebx
  801e53:	85 c0                	test   %eax,%eax
  801e55:	78 26                	js     801e7d <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801e57:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801e5d:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801e62:	0f 4e c6             	cmovle %esi,%eax
  801e65:	39 c3                	cmp    %eax,%ebx
  801e67:	7f 1d                	jg     801e86 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e69:	83 ec 04             	sub    $0x4,%esp
  801e6c:	53                   	push   %ebx
  801e6d:	68 00 60 80 00       	push   $0x806000
  801e72:	ff 75 0c             	pushl  0xc(%ebp)
  801e75:	e8 16 ed ff ff       	call   800b90 <memmove>
  801e7a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e7d:	89 d8                	mov    %ebx,%eax
  801e7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e82:	5b                   	pop    %ebx
  801e83:	5e                   	pop    %esi
  801e84:	5d                   	pop    %ebp
  801e85:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801e86:	68 6b 2e 80 00       	push   $0x802e6b
  801e8b:	68 d3 2d 80 00       	push   $0x802dd3
  801e90:	6a 62                	push   $0x62
  801e92:	68 80 2e 80 00       	push   $0x802e80
  801e97:	e8 05 e4 ff ff       	call   8002a1 <_panic>

00801e9c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e9c:	f3 0f 1e fb          	endbr32 
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
  801ea3:	53                   	push   %ebx
  801ea4:	83 ec 04             	sub    $0x4,%esp
  801ea7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801eaa:	8b 45 08             	mov    0x8(%ebp),%eax
  801ead:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801eb2:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801eb8:	7f 2e                	jg     801ee8 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801eba:	83 ec 04             	sub    $0x4,%esp
  801ebd:	53                   	push   %ebx
  801ebe:	ff 75 0c             	pushl  0xc(%ebp)
  801ec1:	68 0c 60 80 00       	push   $0x80600c
  801ec6:	e8 c5 ec ff ff       	call   800b90 <memmove>
	nsipcbuf.send.req_size = size;
  801ecb:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ed1:	8b 45 14             	mov    0x14(%ebp),%eax
  801ed4:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ed9:	b8 08 00 00 00       	mov    $0x8,%eax
  801ede:	e8 c4 fd ff ff       	call   801ca7 <nsipc>
}
  801ee3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ee6:	c9                   	leave  
  801ee7:	c3                   	ret    
	assert(size < 1600);
  801ee8:	68 8c 2e 80 00       	push   $0x802e8c
  801eed:	68 d3 2d 80 00       	push   $0x802dd3
  801ef2:	6a 6d                	push   $0x6d
  801ef4:	68 80 2e 80 00       	push   $0x802e80
  801ef9:	e8 a3 e3 ff ff       	call   8002a1 <_panic>

00801efe <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801efe:	f3 0f 1e fb          	endbr32 
  801f02:	55                   	push   %ebp
  801f03:	89 e5                	mov    %esp,%ebp
  801f05:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f08:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801f10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f13:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f18:	8b 45 10             	mov    0x10(%ebp),%eax
  801f1b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801f20:	b8 09 00 00 00       	mov    $0x9,%eax
  801f25:	e8 7d fd ff ff       	call   801ca7 <nsipc>
}
  801f2a:	c9                   	leave  
  801f2b:	c3                   	ret    

00801f2c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f2c:	f3 0f 1e fb          	endbr32 
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	56                   	push   %esi
  801f34:	53                   	push   %ebx
  801f35:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f38:	83 ec 0c             	sub    $0xc,%esp
  801f3b:	ff 75 08             	pushl  0x8(%ebp)
  801f3e:	e8 f0 f2 ff ff       	call   801233 <fd2data>
  801f43:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f45:	83 c4 08             	add    $0x8,%esp
  801f48:	68 98 2e 80 00       	push   $0x802e98
  801f4d:	53                   	push   %ebx
  801f4e:	e8 3f ea ff ff       	call   800992 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f53:	8b 46 04             	mov    0x4(%esi),%eax
  801f56:	2b 06                	sub    (%esi),%eax
  801f58:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f5e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f65:	00 00 00 
	stat->st_dev = &devpipe;
  801f68:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801f6f:	30 80 00 
	return 0;
}
  801f72:	b8 00 00 00 00       	mov    $0x0,%eax
  801f77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f7a:	5b                   	pop    %ebx
  801f7b:	5e                   	pop    %esi
  801f7c:	5d                   	pop    %ebp
  801f7d:	c3                   	ret    

00801f7e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f7e:	f3 0f 1e fb          	endbr32 
  801f82:	55                   	push   %ebp
  801f83:	89 e5                	mov    %esp,%ebp
  801f85:	53                   	push   %ebx
  801f86:	83 ec 0c             	sub    $0xc,%esp
  801f89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f8c:	53                   	push   %ebx
  801f8d:	6a 00                	push   $0x0
  801f8f:	e8 b2 ee ff ff       	call   800e46 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f94:	89 1c 24             	mov    %ebx,(%esp)
  801f97:	e8 97 f2 ff ff       	call   801233 <fd2data>
  801f9c:	83 c4 08             	add    $0x8,%esp
  801f9f:	50                   	push   %eax
  801fa0:	6a 00                	push   $0x0
  801fa2:	e8 9f ee ff ff       	call   800e46 <sys_page_unmap>
}
  801fa7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801faa:	c9                   	leave  
  801fab:	c3                   	ret    

00801fac <_pipeisclosed>:
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	57                   	push   %edi
  801fb0:	56                   	push   %esi
  801fb1:	53                   	push   %ebx
  801fb2:	83 ec 1c             	sub    $0x1c,%esp
  801fb5:	89 c7                	mov    %eax,%edi
  801fb7:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801fb9:	a1 08 40 80 00       	mov    0x804008,%eax
  801fbe:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801fc1:	83 ec 0c             	sub    $0xc,%esp
  801fc4:	57                   	push   %edi
  801fc5:	e8 f6 05 00 00       	call   8025c0 <pageref>
  801fca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801fcd:	89 34 24             	mov    %esi,(%esp)
  801fd0:	e8 eb 05 00 00       	call   8025c0 <pageref>
		nn = thisenv->env_runs;
  801fd5:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801fdb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fde:	83 c4 10             	add    $0x10,%esp
  801fe1:	39 cb                	cmp    %ecx,%ebx
  801fe3:	74 1b                	je     802000 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801fe5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801fe8:	75 cf                	jne    801fb9 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fea:	8b 42 58             	mov    0x58(%edx),%eax
  801fed:	6a 01                	push   $0x1
  801fef:	50                   	push   %eax
  801ff0:	53                   	push   %ebx
  801ff1:	68 9f 2e 80 00       	push   $0x802e9f
  801ff6:	e8 8d e3 ff ff       	call   800388 <cprintf>
  801ffb:	83 c4 10             	add    $0x10,%esp
  801ffe:	eb b9                	jmp    801fb9 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  802000:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802003:	0f 94 c0             	sete   %al
  802006:	0f b6 c0             	movzbl %al,%eax
}
  802009:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80200c:	5b                   	pop    %ebx
  80200d:	5e                   	pop    %esi
  80200e:	5f                   	pop    %edi
  80200f:	5d                   	pop    %ebp
  802010:	c3                   	ret    

00802011 <devpipe_write>:
{
  802011:	f3 0f 1e fb          	endbr32 
  802015:	55                   	push   %ebp
  802016:	89 e5                	mov    %esp,%ebp
  802018:	57                   	push   %edi
  802019:	56                   	push   %esi
  80201a:	53                   	push   %ebx
  80201b:	83 ec 28             	sub    $0x28,%esp
  80201e:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802021:	56                   	push   %esi
  802022:	e8 0c f2 ff ff       	call   801233 <fd2data>
  802027:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802029:	83 c4 10             	add    $0x10,%esp
  80202c:	bf 00 00 00 00       	mov    $0x0,%edi
  802031:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802034:	74 4f                	je     802085 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802036:	8b 43 04             	mov    0x4(%ebx),%eax
  802039:	8b 0b                	mov    (%ebx),%ecx
  80203b:	8d 51 20             	lea    0x20(%ecx),%edx
  80203e:	39 d0                	cmp    %edx,%eax
  802040:	72 14                	jb     802056 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  802042:	89 da                	mov    %ebx,%edx
  802044:	89 f0                	mov    %esi,%eax
  802046:	e8 61 ff ff ff       	call   801fac <_pipeisclosed>
  80204b:	85 c0                	test   %eax,%eax
  80204d:	75 3b                	jne    80208a <devpipe_write+0x79>
			sys_yield();
  80204f:	e8 84 ed ff ff       	call   800dd8 <sys_yield>
  802054:	eb e0                	jmp    802036 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802056:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802059:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80205d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802060:	89 c2                	mov    %eax,%edx
  802062:	c1 fa 1f             	sar    $0x1f,%edx
  802065:	89 d1                	mov    %edx,%ecx
  802067:	c1 e9 1b             	shr    $0x1b,%ecx
  80206a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80206d:	83 e2 1f             	and    $0x1f,%edx
  802070:	29 ca                	sub    %ecx,%edx
  802072:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802076:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80207a:	83 c0 01             	add    $0x1,%eax
  80207d:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802080:	83 c7 01             	add    $0x1,%edi
  802083:	eb ac                	jmp    802031 <devpipe_write+0x20>
	return i;
  802085:	8b 45 10             	mov    0x10(%ebp),%eax
  802088:	eb 05                	jmp    80208f <devpipe_write+0x7e>
				return 0;
  80208a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80208f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802092:	5b                   	pop    %ebx
  802093:	5e                   	pop    %esi
  802094:	5f                   	pop    %edi
  802095:	5d                   	pop    %ebp
  802096:	c3                   	ret    

00802097 <devpipe_read>:
{
  802097:	f3 0f 1e fb          	endbr32 
  80209b:	55                   	push   %ebp
  80209c:	89 e5                	mov    %esp,%ebp
  80209e:	57                   	push   %edi
  80209f:	56                   	push   %esi
  8020a0:	53                   	push   %ebx
  8020a1:	83 ec 18             	sub    $0x18,%esp
  8020a4:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8020a7:	57                   	push   %edi
  8020a8:	e8 86 f1 ff ff       	call   801233 <fd2data>
  8020ad:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8020af:	83 c4 10             	add    $0x10,%esp
  8020b2:	be 00 00 00 00       	mov    $0x0,%esi
  8020b7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020ba:	75 14                	jne    8020d0 <devpipe_read+0x39>
	return i;
  8020bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8020bf:	eb 02                	jmp    8020c3 <devpipe_read+0x2c>
				return i;
  8020c1:	89 f0                	mov    %esi,%eax
}
  8020c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020c6:	5b                   	pop    %ebx
  8020c7:	5e                   	pop    %esi
  8020c8:	5f                   	pop    %edi
  8020c9:	5d                   	pop    %ebp
  8020ca:	c3                   	ret    
			sys_yield();
  8020cb:	e8 08 ed ff ff       	call   800dd8 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8020d0:	8b 03                	mov    (%ebx),%eax
  8020d2:	3b 43 04             	cmp    0x4(%ebx),%eax
  8020d5:	75 18                	jne    8020ef <devpipe_read+0x58>
			if (i > 0)
  8020d7:	85 f6                	test   %esi,%esi
  8020d9:	75 e6                	jne    8020c1 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8020db:	89 da                	mov    %ebx,%edx
  8020dd:	89 f8                	mov    %edi,%eax
  8020df:	e8 c8 fe ff ff       	call   801fac <_pipeisclosed>
  8020e4:	85 c0                	test   %eax,%eax
  8020e6:	74 e3                	je     8020cb <devpipe_read+0x34>
				return 0;
  8020e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8020ed:	eb d4                	jmp    8020c3 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020ef:	99                   	cltd   
  8020f0:	c1 ea 1b             	shr    $0x1b,%edx
  8020f3:	01 d0                	add    %edx,%eax
  8020f5:	83 e0 1f             	and    $0x1f,%eax
  8020f8:	29 d0                	sub    %edx,%eax
  8020fa:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8020ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802102:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802105:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802108:	83 c6 01             	add    $0x1,%esi
  80210b:	eb aa                	jmp    8020b7 <devpipe_read+0x20>

0080210d <pipe>:
{
  80210d:	f3 0f 1e fb          	endbr32 
  802111:	55                   	push   %ebp
  802112:	89 e5                	mov    %esp,%ebp
  802114:	56                   	push   %esi
  802115:	53                   	push   %ebx
  802116:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802119:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80211c:	50                   	push   %eax
  80211d:	e8 2c f1 ff ff       	call   80124e <fd_alloc>
  802122:	89 c3                	mov    %eax,%ebx
  802124:	83 c4 10             	add    $0x10,%esp
  802127:	85 c0                	test   %eax,%eax
  802129:	0f 88 23 01 00 00    	js     802252 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80212f:	83 ec 04             	sub    $0x4,%esp
  802132:	68 07 04 00 00       	push   $0x407
  802137:	ff 75 f4             	pushl  -0xc(%ebp)
  80213a:	6a 00                	push   $0x0
  80213c:	e8 ba ec ff ff       	call   800dfb <sys_page_alloc>
  802141:	89 c3                	mov    %eax,%ebx
  802143:	83 c4 10             	add    $0x10,%esp
  802146:	85 c0                	test   %eax,%eax
  802148:	0f 88 04 01 00 00    	js     802252 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  80214e:	83 ec 0c             	sub    $0xc,%esp
  802151:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802154:	50                   	push   %eax
  802155:	e8 f4 f0 ff ff       	call   80124e <fd_alloc>
  80215a:	89 c3                	mov    %eax,%ebx
  80215c:	83 c4 10             	add    $0x10,%esp
  80215f:	85 c0                	test   %eax,%eax
  802161:	0f 88 db 00 00 00    	js     802242 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802167:	83 ec 04             	sub    $0x4,%esp
  80216a:	68 07 04 00 00       	push   $0x407
  80216f:	ff 75 f0             	pushl  -0x10(%ebp)
  802172:	6a 00                	push   $0x0
  802174:	e8 82 ec ff ff       	call   800dfb <sys_page_alloc>
  802179:	89 c3                	mov    %eax,%ebx
  80217b:	83 c4 10             	add    $0x10,%esp
  80217e:	85 c0                	test   %eax,%eax
  802180:	0f 88 bc 00 00 00    	js     802242 <pipe+0x135>
	va = fd2data(fd0);
  802186:	83 ec 0c             	sub    $0xc,%esp
  802189:	ff 75 f4             	pushl  -0xc(%ebp)
  80218c:	e8 a2 f0 ff ff       	call   801233 <fd2data>
  802191:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802193:	83 c4 0c             	add    $0xc,%esp
  802196:	68 07 04 00 00       	push   $0x407
  80219b:	50                   	push   %eax
  80219c:	6a 00                	push   $0x0
  80219e:	e8 58 ec ff ff       	call   800dfb <sys_page_alloc>
  8021a3:	89 c3                	mov    %eax,%ebx
  8021a5:	83 c4 10             	add    $0x10,%esp
  8021a8:	85 c0                	test   %eax,%eax
  8021aa:	0f 88 82 00 00 00    	js     802232 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021b0:	83 ec 0c             	sub    $0xc,%esp
  8021b3:	ff 75 f0             	pushl  -0x10(%ebp)
  8021b6:	e8 78 f0 ff ff       	call   801233 <fd2data>
  8021bb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021c2:	50                   	push   %eax
  8021c3:	6a 00                	push   $0x0
  8021c5:	56                   	push   %esi
  8021c6:	6a 00                	push   $0x0
  8021c8:	e8 54 ec ff ff       	call   800e21 <sys_page_map>
  8021cd:	89 c3                	mov    %eax,%ebx
  8021cf:	83 c4 20             	add    $0x20,%esp
  8021d2:	85 c0                	test   %eax,%eax
  8021d4:	78 4e                	js     802224 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8021d6:	a1 7c 30 80 00       	mov    0x80307c,%eax
  8021db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021de:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8021e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021e3:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8021ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021ed:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8021ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021f2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8021f9:	83 ec 0c             	sub    $0xc,%esp
  8021fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8021ff:	e8 1b f0 ff ff       	call   80121f <fd2num>
  802204:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802207:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802209:	83 c4 04             	add    $0x4,%esp
  80220c:	ff 75 f0             	pushl  -0x10(%ebp)
  80220f:	e8 0b f0 ff ff       	call   80121f <fd2num>
  802214:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802217:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80221a:	83 c4 10             	add    $0x10,%esp
  80221d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802222:	eb 2e                	jmp    802252 <pipe+0x145>
	sys_page_unmap(0, va);
  802224:	83 ec 08             	sub    $0x8,%esp
  802227:	56                   	push   %esi
  802228:	6a 00                	push   $0x0
  80222a:	e8 17 ec ff ff       	call   800e46 <sys_page_unmap>
  80222f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802232:	83 ec 08             	sub    $0x8,%esp
  802235:	ff 75 f0             	pushl  -0x10(%ebp)
  802238:	6a 00                	push   $0x0
  80223a:	e8 07 ec ff ff       	call   800e46 <sys_page_unmap>
  80223f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802242:	83 ec 08             	sub    $0x8,%esp
  802245:	ff 75 f4             	pushl  -0xc(%ebp)
  802248:	6a 00                	push   $0x0
  80224a:	e8 f7 eb ff ff       	call   800e46 <sys_page_unmap>
  80224f:	83 c4 10             	add    $0x10,%esp
}
  802252:	89 d8                	mov    %ebx,%eax
  802254:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802257:	5b                   	pop    %ebx
  802258:	5e                   	pop    %esi
  802259:	5d                   	pop    %ebp
  80225a:	c3                   	ret    

0080225b <pipeisclosed>:
{
  80225b:	f3 0f 1e fb          	endbr32 
  80225f:	55                   	push   %ebp
  802260:	89 e5                	mov    %esp,%ebp
  802262:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802265:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802268:	50                   	push   %eax
  802269:	ff 75 08             	pushl  0x8(%ebp)
  80226c:	e8 33 f0 ff ff       	call   8012a4 <fd_lookup>
  802271:	83 c4 10             	add    $0x10,%esp
  802274:	85 c0                	test   %eax,%eax
  802276:	78 18                	js     802290 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  802278:	83 ec 0c             	sub    $0xc,%esp
  80227b:	ff 75 f4             	pushl  -0xc(%ebp)
  80227e:	e8 b0 ef ff ff       	call   801233 <fd2data>
  802283:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802285:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802288:	e8 1f fd ff ff       	call   801fac <_pipeisclosed>
  80228d:	83 c4 10             	add    $0x10,%esp
}
  802290:	c9                   	leave  
  802291:	c3                   	ret    

00802292 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802292:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  802296:	b8 00 00 00 00       	mov    $0x0,%eax
  80229b:	c3                   	ret    

0080229c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80229c:	f3 0f 1e fb          	endbr32 
  8022a0:	55                   	push   %ebp
  8022a1:	89 e5                	mov    %esp,%ebp
  8022a3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022a6:	68 b2 2e 80 00       	push   $0x802eb2
  8022ab:	ff 75 0c             	pushl  0xc(%ebp)
  8022ae:	e8 df e6 ff ff       	call   800992 <strcpy>
	return 0;
}
  8022b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8022b8:	c9                   	leave  
  8022b9:	c3                   	ret    

008022ba <devcons_write>:
{
  8022ba:	f3 0f 1e fb          	endbr32 
  8022be:	55                   	push   %ebp
  8022bf:	89 e5                	mov    %esp,%ebp
  8022c1:	57                   	push   %edi
  8022c2:	56                   	push   %esi
  8022c3:	53                   	push   %ebx
  8022c4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8022ca:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8022cf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8022d5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022d8:	73 31                	jae    80230b <devcons_write+0x51>
		m = n - tot;
  8022da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022dd:	29 f3                	sub    %esi,%ebx
  8022df:	83 fb 7f             	cmp    $0x7f,%ebx
  8022e2:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8022e7:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8022ea:	83 ec 04             	sub    $0x4,%esp
  8022ed:	53                   	push   %ebx
  8022ee:	89 f0                	mov    %esi,%eax
  8022f0:	03 45 0c             	add    0xc(%ebp),%eax
  8022f3:	50                   	push   %eax
  8022f4:	57                   	push   %edi
  8022f5:	e8 96 e8 ff ff       	call   800b90 <memmove>
		sys_cputs(buf, m);
  8022fa:	83 c4 08             	add    $0x8,%esp
  8022fd:	53                   	push   %ebx
  8022fe:	57                   	push   %edi
  8022ff:	e8 48 ea ff ff       	call   800d4c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802304:	01 de                	add    %ebx,%esi
  802306:	83 c4 10             	add    $0x10,%esp
  802309:	eb ca                	jmp    8022d5 <devcons_write+0x1b>
}
  80230b:	89 f0                	mov    %esi,%eax
  80230d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802310:	5b                   	pop    %ebx
  802311:	5e                   	pop    %esi
  802312:	5f                   	pop    %edi
  802313:	5d                   	pop    %ebp
  802314:	c3                   	ret    

00802315 <devcons_read>:
{
  802315:	f3 0f 1e fb          	endbr32 
  802319:	55                   	push   %ebp
  80231a:	89 e5                	mov    %esp,%ebp
  80231c:	83 ec 08             	sub    $0x8,%esp
  80231f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802324:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802328:	74 21                	je     80234b <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  80232a:	e8 3f ea ff ff       	call   800d6e <sys_cgetc>
  80232f:	85 c0                	test   %eax,%eax
  802331:	75 07                	jne    80233a <devcons_read+0x25>
		sys_yield();
  802333:	e8 a0 ea ff ff       	call   800dd8 <sys_yield>
  802338:	eb f0                	jmp    80232a <devcons_read+0x15>
	if (c < 0)
  80233a:	78 0f                	js     80234b <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  80233c:	83 f8 04             	cmp    $0x4,%eax
  80233f:	74 0c                	je     80234d <devcons_read+0x38>
	*(char*)vbuf = c;
  802341:	8b 55 0c             	mov    0xc(%ebp),%edx
  802344:	88 02                	mov    %al,(%edx)
	return 1;
  802346:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80234b:	c9                   	leave  
  80234c:	c3                   	ret    
		return 0;
  80234d:	b8 00 00 00 00       	mov    $0x0,%eax
  802352:	eb f7                	jmp    80234b <devcons_read+0x36>

00802354 <cputchar>:
{
  802354:	f3 0f 1e fb          	endbr32 
  802358:	55                   	push   %ebp
  802359:	89 e5                	mov    %esp,%ebp
  80235b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80235e:	8b 45 08             	mov    0x8(%ebp),%eax
  802361:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802364:	6a 01                	push   $0x1
  802366:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802369:	50                   	push   %eax
  80236a:	e8 dd e9 ff ff       	call   800d4c <sys_cputs>
}
  80236f:	83 c4 10             	add    $0x10,%esp
  802372:	c9                   	leave  
  802373:	c3                   	ret    

00802374 <getchar>:
{
  802374:	f3 0f 1e fb          	endbr32 
  802378:	55                   	push   %ebp
  802379:	89 e5                	mov    %esp,%ebp
  80237b:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80237e:	6a 01                	push   $0x1
  802380:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802383:	50                   	push   %eax
  802384:	6a 00                	push   $0x0
  802386:	e8 a1 f1 ff ff       	call   80152c <read>
	if (r < 0)
  80238b:	83 c4 10             	add    $0x10,%esp
  80238e:	85 c0                	test   %eax,%eax
  802390:	78 06                	js     802398 <getchar+0x24>
	if (r < 1)
  802392:	74 06                	je     80239a <getchar+0x26>
	return c;
  802394:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802398:	c9                   	leave  
  802399:	c3                   	ret    
		return -E_EOF;
  80239a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80239f:	eb f7                	jmp    802398 <getchar+0x24>

008023a1 <iscons>:
{
  8023a1:	f3 0f 1e fb          	endbr32 
  8023a5:	55                   	push   %ebp
  8023a6:	89 e5                	mov    %esp,%ebp
  8023a8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023ae:	50                   	push   %eax
  8023af:	ff 75 08             	pushl  0x8(%ebp)
  8023b2:	e8 ed ee ff ff       	call   8012a4 <fd_lookup>
  8023b7:	83 c4 10             	add    $0x10,%esp
  8023ba:	85 c0                	test   %eax,%eax
  8023bc:	78 11                	js     8023cf <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8023be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023c1:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8023c7:	39 10                	cmp    %edx,(%eax)
  8023c9:	0f 94 c0             	sete   %al
  8023cc:	0f b6 c0             	movzbl %al,%eax
}
  8023cf:	c9                   	leave  
  8023d0:	c3                   	ret    

008023d1 <opencons>:
{
  8023d1:	f3 0f 1e fb          	endbr32 
  8023d5:	55                   	push   %ebp
  8023d6:	89 e5                	mov    %esp,%ebp
  8023d8:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8023db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023de:	50                   	push   %eax
  8023df:	e8 6a ee ff ff       	call   80124e <fd_alloc>
  8023e4:	83 c4 10             	add    $0x10,%esp
  8023e7:	85 c0                	test   %eax,%eax
  8023e9:	78 3a                	js     802425 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023eb:	83 ec 04             	sub    $0x4,%esp
  8023ee:	68 07 04 00 00       	push   $0x407
  8023f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8023f6:	6a 00                	push   $0x0
  8023f8:	e8 fe e9 ff ff       	call   800dfb <sys_page_alloc>
  8023fd:	83 c4 10             	add    $0x10,%esp
  802400:	85 c0                	test   %eax,%eax
  802402:	78 21                	js     802425 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  802404:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802407:	8b 15 98 30 80 00    	mov    0x803098,%edx
  80240d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80240f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802412:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802419:	83 ec 0c             	sub    $0xc,%esp
  80241c:	50                   	push   %eax
  80241d:	e8 fd ed ff ff       	call   80121f <fd2num>
  802422:	83 c4 10             	add    $0x10,%esp
}
  802425:	c9                   	leave  
  802426:	c3                   	ret    

00802427 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802427:	f3 0f 1e fb          	endbr32 
  80242b:	55                   	push   %ebp
  80242c:	89 e5                	mov    %esp,%ebp
  80242e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802431:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802438:	74 0a                	je     802444 <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80243a:	8b 45 08             	mov    0x8(%ebp),%eax
  80243d:	a3 00 70 80 00       	mov    %eax,0x807000

}
  802442:	c9                   	leave  
  802443:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  802444:	83 ec 04             	sub    $0x4,%esp
  802447:	6a 07                	push   $0x7
  802449:	68 00 f0 bf ee       	push   $0xeebff000
  80244e:	6a 00                	push   $0x0
  802450:	e8 a6 e9 ff ff       	call   800dfb <sys_page_alloc>
  802455:	83 c4 10             	add    $0x10,%esp
  802458:	85 c0                	test   %eax,%eax
  80245a:	78 2a                	js     802486 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  80245c:	83 ec 08             	sub    $0x8,%esp
  80245f:	68 9a 24 80 00       	push   $0x80249a
  802464:	6a 00                	push   $0x0
  802466:	e8 4a ea ff ff       	call   800eb5 <sys_env_set_pgfault_upcall>
  80246b:	83 c4 10             	add    $0x10,%esp
  80246e:	85 c0                	test   %eax,%eax
  802470:	79 c8                	jns    80243a <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  802472:	83 ec 04             	sub    $0x4,%esp
  802475:	68 ec 2e 80 00       	push   $0x802eec
  80247a:	6a 2c                	push   $0x2c
  80247c:	68 22 2f 80 00       	push   $0x802f22
  802481:	e8 1b de ff ff       	call   8002a1 <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  802486:	83 ec 04             	sub    $0x4,%esp
  802489:	68 c0 2e 80 00       	push   $0x802ec0
  80248e:	6a 22                	push   $0x22
  802490:	68 22 2f 80 00       	push   $0x802f22
  802495:	e8 07 de ff ff       	call   8002a1 <_panic>

0080249a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80249a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80249b:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax   			// 间接寻址
  8024a0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8024a2:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  8024a5:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  8024a9:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  8024ae:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  8024b2:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  8024b4:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  8024b7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  8024b8:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  8024bb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  8024bc:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  8024bd:	c3                   	ret    

008024be <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024be:	f3 0f 1e fb          	endbr32 
  8024c2:	55                   	push   %ebp
  8024c3:	89 e5                	mov    %esp,%ebp
  8024c5:	56                   	push   %esi
  8024c6:	53                   	push   %ebx
  8024c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8024ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  8024d0:	85 c0                	test   %eax,%eax
  8024d2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8024d7:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  8024da:	83 ec 0c             	sub    $0xc,%esp
  8024dd:	50                   	push   %eax
  8024de:	e8 1e ea ff ff       	call   800f01 <sys_ipc_recv>
  8024e3:	83 c4 10             	add    $0x10,%esp
  8024e6:	85 c0                	test   %eax,%eax
  8024e8:	75 2b                	jne    802515 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  8024ea:	85 f6                	test   %esi,%esi
  8024ec:	74 0a                	je     8024f8 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  8024ee:	a1 08 40 80 00       	mov    0x804008,%eax
  8024f3:	8b 40 74             	mov    0x74(%eax),%eax
  8024f6:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  8024f8:	85 db                	test   %ebx,%ebx
  8024fa:	74 0a                	je     802506 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  8024fc:	a1 08 40 80 00       	mov    0x804008,%eax
  802501:	8b 40 78             	mov    0x78(%eax),%eax
  802504:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  802506:	a1 08 40 80 00       	mov    0x804008,%eax
  80250b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80250e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802511:	5b                   	pop    %ebx
  802512:	5e                   	pop    %esi
  802513:	5d                   	pop    %ebp
  802514:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  802515:	85 f6                	test   %esi,%esi
  802517:	74 06                	je     80251f <ipc_recv+0x61>
  802519:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  80251f:	85 db                	test   %ebx,%ebx
  802521:	74 eb                	je     80250e <ipc_recv+0x50>
  802523:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802529:	eb e3                	jmp    80250e <ipc_recv+0x50>

0080252b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80252b:	f3 0f 1e fb          	endbr32 
  80252f:	55                   	push   %ebp
  802530:	89 e5                	mov    %esp,%ebp
  802532:	57                   	push   %edi
  802533:	56                   	push   %esi
  802534:	53                   	push   %ebx
  802535:	83 ec 0c             	sub    $0xc,%esp
  802538:	8b 7d 08             	mov    0x8(%ebp),%edi
  80253b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80253e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  802541:	85 db                	test   %ebx,%ebx
  802543:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802548:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  80254b:	ff 75 14             	pushl  0x14(%ebp)
  80254e:	53                   	push   %ebx
  80254f:	56                   	push   %esi
  802550:	57                   	push   %edi
  802551:	e8 84 e9 ff ff       	call   800eda <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  802556:	83 c4 10             	add    $0x10,%esp
  802559:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80255c:	75 07                	jne    802565 <ipc_send+0x3a>
			sys_yield();
  80255e:	e8 75 e8 ff ff       	call   800dd8 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802563:	eb e6                	jmp    80254b <ipc_send+0x20>
		}
		else if (ret == 0)
  802565:	85 c0                	test   %eax,%eax
  802567:	75 08                	jne    802571 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  802569:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80256c:	5b                   	pop    %ebx
  80256d:	5e                   	pop    %esi
  80256e:	5f                   	pop    %edi
  80256f:	5d                   	pop    %ebp
  802570:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802571:	50                   	push   %eax
  802572:	68 30 2f 80 00       	push   $0x802f30
  802577:	6a 48                	push   $0x48
  802579:	68 3e 2f 80 00       	push   $0x802f3e
  80257e:	e8 1e dd ff ff       	call   8002a1 <_panic>

00802583 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802583:	f3 0f 1e fb          	endbr32 
  802587:	55                   	push   %ebp
  802588:	89 e5                	mov    %esp,%ebp
  80258a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80258d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802592:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802595:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80259b:	8b 52 50             	mov    0x50(%edx),%edx
  80259e:	39 ca                	cmp    %ecx,%edx
  8025a0:	74 11                	je     8025b3 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8025a2:	83 c0 01             	add    $0x1,%eax
  8025a5:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025aa:	75 e6                	jne    802592 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8025ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8025b1:	eb 0b                	jmp    8025be <ipc_find_env+0x3b>
			return envs[i].env_id;
  8025b3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025b6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025bb:	8b 40 48             	mov    0x48(%eax),%eax
}
  8025be:	5d                   	pop    %ebp
  8025bf:	c3                   	ret    

008025c0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025c0:	f3 0f 1e fb          	endbr32 
  8025c4:	55                   	push   %ebp
  8025c5:	89 e5                	mov    %esp,%ebp
  8025c7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025ca:	89 c2                	mov    %eax,%edx
  8025cc:	c1 ea 16             	shr    $0x16,%edx
  8025cf:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8025d6:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8025db:	f6 c1 01             	test   $0x1,%cl
  8025de:	74 1c                	je     8025fc <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8025e0:	c1 e8 0c             	shr    $0xc,%eax
  8025e3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8025ea:	a8 01                	test   $0x1,%al
  8025ec:	74 0e                	je     8025fc <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025ee:	c1 e8 0c             	shr    $0xc,%eax
  8025f1:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8025f8:	ef 
  8025f9:	0f b7 d2             	movzwl %dx,%edx
}
  8025fc:	89 d0                	mov    %edx,%eax
  8025fe:	5d                   	pop    %ebp
  8025ff:	c3                   	ret    

00802600 <__udivdi3>:
  802600:	f3 0f 1e fb          	endbr32 
  802604:	55                   	push   %ebp
  802605:	57                   	push   %edi
  802606:	56                   	push   %esi
  802607:	53                   	push   %ebx
  802608:	83 ec 1c             	sub    $0x1c,%esp
  80260b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80260f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802613:	8b 74 24 34          	mov    0x34(%esp),%esi
  802617:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80261b:	85 d2                	test   %edx,%edx
  80261d:	75 19                	jne    802638 <__udivdi3+0x38>
  80261f:	39 f3                	cmp    %esi,%ebx
  802621:	76 4d                	jbe    802670 <__udivdi3+0x70>
  802623:	31 ff                	xor    %edi,%edi
  802625:	89 e8                	mov    %ebp,%eax
  802627:	89 f2                	mov    %esi,%edx
  802629:	f7 f3                	div    %ebx
  80262b:	89 fa                	mov    %edi,%edx
  80262d:	83 c4 1c             	add    $0x1c,%esp
  802630:	5b                   	pop    %ebx
  802631:	5e                   	pop    %esi
  802632:	5f                   	pop    %edi
  802633:	5d                   	pop    %ebp
  802634:	c3                   	ret    
  802635:	8d 76 00             	lea    0x0(%esi),%esi
  802638:	39 f2                	cmp    %esi,%edx
  80263a:	76 14                	jbe    802650 <__udivdi3+0x50>
  80263c:	31 ff                	xor    %edi,%edi
  80263e:	31 c0                	xor    %eax,%eax
  802640:	89 fa                	mov    %edi,%edx
  802642:	83 c4 1c             	add    $0x1c,%esp
  802645:	5b                   	pop    %ebx
  802646:	5e                   	pop    %esi
  802647:	5f                   	pop    %edi
  802648:	5d                   	pop    %ebp
  802649:	c3                   	ret    
  80264a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802650:	0f bd fa             	bsr    %edx,%edi
  802653:	83 f7 1f             	xor    $0x1f,%edi
  802656:	75 48                	jne    8026a0 <__udivdi3+0xa0>
  802658:	39 f2                	cmp    %esi,%edx
  80265a:	72 06                	jb     802662 <__udivdi3+0x62>
  80265c:	31 c0                	xor    %eax,%eax
  80265e:	39 eb                	cmp    %ebp,%ebx
  802660:	77 de                	ja     802640 <__udivdi3+0x40>
  802662:	b8 01 00 00 00       	mov    $0x1,%eax
  802667:	eb d7                	jmp    802640 <__udivdi3+0x40>
  802669:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802670:	89 d9                	mov    %ebx,%ecx
  802672:	85 db                	test   %ebx,%ebx
  802674:	75 0b                	jne    802681 <__udivdi3+0x81>
  802676:	b8 01 00 00 00       	mov    $0x1,%eax
  80267b:	31 d2                	xor    %edx,%edx
  80267d:	f7 f3                	div    %ebx
  80267f:	89 c1                	mov    %eax,%ecx
  802681:	31 d2                	xor    %edx,%edx
  802683:	89 f0                	mov    %esi,%eax
  802685:	f7 f1                	div    %ecx
  802687:	89 c6                	mov    %eax,%esi
  802689:	89 e8                	mov    %ebp,%eax
  80268b:	89 f7                	mov    %esi,%edi
  80268d:	f7 f1                	div    %ecx
  80268f:	89 fa                	mov    %edi,%edx
  802691:	83 c4 1c             	add    $0x1c,%esp
  802694:	5b                   	pop    %ebx
  802695:	5e                   	pop    %esi
  802696:	5f                   	pop    %edi
  802697:	5d                   	pop    %ebp
  802698:	c3                   	ret    
  802699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	89 f9                	mov    %edi,%ecx
  8026a2:	b8 20 00 00 00       	mov    $0x20,%eax
  8026a7:	29 f8                	sub    %edi,%eax
  8026a9:	d3 e2                	shl    %cl,%edx
  8026ab:	89 54 24 08          	mov    %edx,0x8(%esp)
  8026af:	89 c1                	mov    %eax,%ecx
  8026b1:	89 da                	mov    %ebx,%edx
  8026b3:	d3 ea                	shr    %cl,%edx
  8026b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8026b9:	09 d1                	or     %edx,%ecx
  8026bb:	89 f2                	mov    %esi,%edx
  8026bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026c1:	89 f9                	mov    %edi,%ecx
  8026c3:	d3 e3                	shl    %cl,%ebx
  8026c5:	89 c1                	mov    %eax,%ecx
  8026c7:	d3 ea                	shr    %cl,%edx
  8026c9:	89 f9                	mov    %edi,%ecx
  8026cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8026cf:	89 eb                	mov    %ebp,%ebx
  8026d1:	d3 e6                	shl    %cl,%esi
  8026d3:	89 c1                	mov    %eax,%ecx
  8026d5:	d3 eb                	shr    %cl,%ebx
  8026d7:	09 de                	or     %ebx,%esi
  8026d9:	89 f0                	mov    %esi,%eax
  8026db:	f7 74 24 08          	divl   0x8(%esp)
  8026df:	89 d6                	mov    %edx,%esi
  8026e1:	89 c3                	mov    %eax,%ebx
  8026e3:	f7 64 24 0c          	mull   0xc(%esp)
  8026e7:	39 d6                	cmp    %edx,%esi
  8026e9:	72 15                	jb     802700 <__udivdi3+0x100>
  8026eb:	89 f9                	mov    %edi,%ecx
  8026ed:	d3 e5                	shl    %cl,%ebp
  8026ef:	39 c5                	cmp    %eax,%ebp
  8026f1:	73 04                	jae    8026f7 <__udivdi3+0xf7>
  8026f3:	39 d6                	cmp    %edx,%esi
  8026f5:	74 09                	je     802700 <__udivdi3+0x100>
  8026f7:	89 d8                	mov    %ebx,%eax
  8026f9:	31 ff                	xor    %edi,%edi
  8026fb:	e9 40 ff ff ff       	jmp    802640 <__udivdi3+0x40>
  802700:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802703:	31 ff                	xor    %edi,%edi
  802705:	e9 36 ff ff ff       	jmp    802640 <__udivdi3+0x40>
  80270a:	66 90                	xchg   %ax,%ax
  80270c:	66 90                	xchg   %ax,%ax
  80270e:	66 90                	xchg   %ax,%ax

00802710 <__umoddi3>:
  802710:	f3 0f 1e fb          	endbr32 
  802714:	55                   	push   %ebp
  802715:	57                   	push   %edi
  802716:	56                   	push   %esi
  802717:	53                   	push   %ebx
  802718:	83 ec 1c             	sub    $0x1c,%esp
  80271b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80271f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802723:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802727:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80272b:	85 c0                	test   %eax,%eax
  80272d:	75 19                	jne    802748 <__umoddi3+0x38>
  80272f:	39 df                	cmp    %ebx,%edi
  802731:	76 5d                	jbe    802790 <__umoddi3+0x80>
  802733:	89 f0                	mov    %esi,%eax
  802735:	89 da                	mov    %ebx,%edx
  802737:	f7 f7                	div    %edi
  802739:	89 d0                	mov    %edx,%eax
  80273b:	31 d2                	xor    %edx,%edx
  80273d:	83 c4 1c             	add    $0x1c,%esp
  802740:	5b                   	pop    %ebx
  802741:	5e                   	pop    %esi
  802742:	5f                   	pop    %edi
  802743:	5d                   	pop    %ebp
  802744:	c3                   	ret    
  802745:	8d 76 00             	lea    0x0(%esi),%esi
  802748:	89 f2                	mov    %esi,%edx
  80274a:	39 d8                	cmp    %ebx,%eax
  80274c:	76 12                	jbe    802760 <__umoddi3+0x50>
  80274e:	89 f0                	mov    %esi,%eax
  802750:	89 da                	mov    %ebx,%edx
  802752:	83 c4 1c             	add    $0x1c,%esp
  802755:	5b                   	pop    %ebx
  802756:	5e                   	pop    %esi
  802757:	5f                   	pop    %edi
  802758:	5d                   	pop    %ebp
  802759:	c3                   	ret    
  80275a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802760:	0f bd e8             	bsr    %eax,%ebp
  802763:	83 f5 1f             	xor    $0x1f,%ebp
  802766:	75 50                	jne    8027b8 <__umoddi3+0xa8>
  802768:	39 d8                	cmp    %ebx,%eax
  80276a:	0f 82 e0 00 00 00    	jb     802850 <__umoddi3+0x140>
  802770:	89 d9                	mov    %ebx,%ecx
  802772:	39 f7                	cmp    %esi,%edi
  802774:	0f 86 d6 00 00 00    	jbe    802850 <__umoddi3+0x140>
  80277a:	89 d0                	mov    %edx,%eax
  80277c:	89 ca                	mov    %ecx,%edx
  80277e:	83 c4 1c             	add    $0x1c,%esp
  802781:	5b                   	pop    %ebx
  802782:	5e                   	pop    %esi
  802783:	5f                   	pop    %edi
  802784:	5d                   	pop    %ebp
  802785:	c3                   	ret    
  802786:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80278d:	8d 76 00             	lea    0x0(%esi),%esi
  802790:	89 fd                	mov    %edi,%ebp
  802792:	85 ff                	test   %edi,%edi
  802794:	75 0b                	jne    8027a1 <__umoddi3+0x91>
  802796:	b8 01 00 00 00       	mov    $0x1,%eax
  80279b:	31 d2                	xor    %edx,%edx
  80279d:	f7 f7                	div    %edi
  80279f:	89 c5                	mov    %eax,%ebp
  8027a1:	89 d8                	mov    %ebx,%eax
  8027a3:	31 d2                	xor    %edx,%edx
  8027a5:	f7 f5                	div    %ebp
  8027a7:	89 f0                	mov    %esi,%eax
  8027a9:	f7 f5                	div    %ebp
  8027ab:	89 d0                	mov    %edx,%eax
  8027ad:	31 d2                	xor    %edx,%edx
  8027af:	eb 8c                	jmp    80273d <__umoddi3+0x2d>
  8027b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027b8:	89 e9                	mov    %ebp,%ecx
  8027ba:	ba 20 00 00 00       	mov    $0x20,%edx
  8027bf:	29 ea                	sub    %ebp,%edx
  8027c1:	d3 e0                	shl    %cl,%eax
  8027c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8027c7:	89 d1                	mov    %edx,%ecx
  8027c9:	89 f8                	mov    %edi,%eax
  8027cb:	d3 e8                	shr    %cl,%eax
  8027cd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8027d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027d5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8027d9:	09 c1                	or     %eax,%ecx
  8027db:	89 d8                	mov    %ebx,%eax
  8027dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027e1:	89 e9                	mov    %ebp,%ecx
  8027e3:	d3 e7                	shl    %cl,%edi
  8027e5:	89 d1                	mov    %edx,%ecx
  8027e7:	d3 e8                	shr    %cl,%eax
  8027e9:	89 e9                	mov    %ebp,%ecx
  8027eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8027ef:	d3 e3                	shl    %cl,%ebx
  8027f1:	89 c7                	mov    %eax,%edi
  8027f3:	89 d1                	mov    %edx,%ecx
  8027f5:	89 f0                	mov    %esi,%eax
  8027f7:	d3 e8                	shr    %cl,%eax
  8027f9:	89 e9                	mov    %ebp,%ecx
  8027fb:	89 fa                	mov    %edi,%edx
  8027fd:	d3 e6                	shl    %cl,%esi
  8027ff:	09 d8                	or     %ebx,%eax
  802801:	f7 74 24 08          	divl   0x8(%esp)
  802805:	89 d1                	mov    %edx,%ecx
  802807:	89 f3                	mov    %esi,%ebx
  802809:	f7 64 24 0c          	mull   0xc(%esp)
  80280d:	89 c6                	mov    %eax,%esi
  80280f:	89 d7                	mov    %edx,%edi
  802811:	39 d1                	cmp    %edx,%ecx
  802813:	72 06                	jb     80281b <__umoddi3+0x10b>
  802815:	75 10                	jne    802827 <__umoddi3+0x117>
  802817:	39 c3                	cmp    %eax,%ebx
  802819:	73 0c                	jae    802827 <__umoddi3+0x117>
  80281b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80281f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802823:	89 d7                	mov    %edx,%edi
  802825:	89 c6                	mov    %eax,%esi
  802827:	89 ca                	mov    %ecx,%edx
  802829:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80282e:	29 f3                	sub    %esi,%ebx
  802830:	19 fa                	sbb    %edi,%edx
  802832:	89 d0                	mov    %edx,%eax
  802834:	d3 e0                	shl    %cl,%eax
  802836:	89 e9                	mov    %ebp,%ecx
  802838:	d3 eb                	shr    %cl,%ebx
  80283a:	d3 ea                	shr    %cl,%edx
  80283c:	09 d8                	or     %ebx,%eax
  80283e:	83 c4 1c             	add    $0x1c,%esp
  802841:	5b                   	pop    %ebx
  802842:	5e                   	pop    %esi
  802843:	5f                   	pop    %edi
  802844:	5d                   	pop    %ebp
  802845:	c3                   	ret    
  802846:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80284d:	8d 76 00             	lea    0x0(%esi),%esi
  802850:	29 fe                	sub    %edi,%esi
  802852:	19 c3                	sbb    %eax,%ebx
  802854:	89 f2                	mov    %esi,%edx
  802856:	89 d9                	mov    %ebx,%ecx
  802858:	e9 1d ff ff ff       	jmp    80277a <__umoddi3+0x6a>
