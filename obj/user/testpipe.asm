
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 a5 02 00 00       	call   8002d6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
  80003c:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003f:	c7 05 04 40 80 00 60 	movl   $0x802960,0x804004
  800046:	29 80 00 

	if ((i = pipe(p)) < 0)
  800049:	8d 45 8c             	lea    -0x74(%ebp),%eax
  80004c:	50                   	push   %eax
  80004d:	e8 58 21 00 00       	call   8021aa <pipe>
  800052:	89 c6                	mov    %eax,%esi
  800054:	83 c4 10             	add    $0x10,%esp
  800057:	85 c0                	test   %eax,%eax
  800059:	0f 88 1b 01 00 00    	js     80017a <umain+0x147>
		panic("pipe: %e", i);

	if ((pid = fork()) < 0)
  80005f:	e8 c7 10 00 00       	call   80112b <fork>
  800064:	89 c3                	mov    %eax,%ebx
  800066:	85 c0                	test   %eax,%eax
  800068:	0f 88 1e 01 00 00    	js     80018c <umain+0x159>
		panic("fork: %e", i);

	if (pid == 0) {
  80006e:	0f 85 56 01 00 00    	jne    8001ca <umain+0x197>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  800074:	a1 08 50 80 00       	mov    0x805008,%eax
  800079:	8b 40 48             	mov    0x48(%eax),%eax
  80007c:	83 ec 04             	sub    $0x4,%esp
  80007f:	ff 75 90             	pushl  -0x70(%ebp)
  800082:	50                   	push   %eax
  800083:	68 8e 29 80 00       	push   $0x80298e
  800088:	e8 98 03 00 00       	call   800425 <cprintf>
		close(p[1]);
  80008d:	83 c4 04             	add    $0x4,%esp
  800090:	ff 75 90             	pushl  -0x70(%ebp)
  800093:	e8 e7 13 00 00       	call   80147f <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  800098:	a1 08 50 80 00       	mov    0x805008,%eax
  80009d:	8b 40 48             	mov    0x48(%eax),%eax
  8000a0:	83 c4 0c             	add    $0xc,%esp
  8000a3:	ff 75 8c             	pushl  -0x74(%ebp)
  8000a6:	50                   	push   %eax
  8000a7:	68 ab 29 80 00       	push   $0x8029ab
  8000ac:	e8 74 03 00 00       	call   800425 <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000b1:	83 c4 0c             	add    $0xc,%esp
  8000b4:	6a 63                	push   $0x63
  8000b6:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000b9:	50                   	push   %eax
  8000ba:	ff 75 8c             	pushl  -0x74(%ebp)
  8000bd:	e8 92 15 00 00       	call   801654 <readn>
  8000c2:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000c4:	83 c4 10             	add    $0x10,%esp
  8000c7:	85 c0                	test   %eax,%eax
  8000c9:	0f 88 cf 00 00 00    	js     80019e <umain+0x16b>
			panic("read: %e", i);
		buf[i] = 0;
  8000cf:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	ff 35 00 40 80 00    	pushl  0x804000
  8000dd:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000e0:	50                   	push   %eax
  8000e1:	e8 08 0a 00 00       	call   800aee <strcmp>
  8000e6:	83 c4 10             	add    $0x10,%esp
  8000e9:	85 c0                	test   %eax,%eax
  8000eb:	0f 85 bf 00 00 00    	jne    8001b0 <umain+0x17d>
			cprintf("\npipe read closed properly\n");
  8000f1:	83 ec 0c             	sub    $0xc,%esp
  8000f4:	68 d1 29 80 00       	push   $0x8029d1
  8000f9:	e8 27 03 00 00       	call   800425 <cprintf>
  8000fe:	83 c4 10             	add    $0x10,%esp
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
		exit();
  800101:	e8 1a 02 00 00       	call   800320 <exit>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
			panic("write: %e", i);
		close(p[1]);
	}
	wait(pid);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	53                   	push   %ebx
  80010a:	e8 20 22 00 00       	call   80232f <wait>

	binaryname = "pipewriteeof";
  80010f:	c7 05 04 40 80 00 27 	movl   $0x802a27,0x804004
  800116:	2a 80 00 
	if ((i = pipe(p)) < 0)
  800119:	8d 45 8c             	lea    -0x74(%ebp),%eax
  80011c:	89 04 24             	mov    %eax,(%esp)
  80011f:	e8 86 20 00 00       	call   8021aa <pipe>
  800124:	89 c6                	mov    %eax,%esi
  800126:	83 c4 10             	add    $0x10,%esp
  800129:	85 c0                	test   %eax,%eax
  80012b:	0f 88 32 01 00 00    	js     800263 <umain+0x230>
		panic("pipe: %e", i);

	if ((pid = fork()) < 0)
  800131:	e8 f5 0f 00 00       	call   80112b <fork>
  800136:	89 c3                	mov    %eax,%ebx
  800138:	85 c0                	test   %eax,%eax
  80013a:	0f 88 35 01 00 00    	js     800275 <umain+0x242>
		panic("fork: %e", i);

	if (pid == 0) {
  800140:	0f 84 41 01 00 00    	je     800287 <umain+0x254>
				break;
		}
		cprintf("\npipe write closed properly\n");
		exit();
	}
	close(p[0]);
  800146:	83 ec 0c             	sub    $0xc,%esp
  800149:	ff 75 8c             	pushl  -0x74(%ebp)
  80014c:	e8 2e 13 00 00       	call   80147f <close>
	close(p[1]);
  800151:	83 c4 04             	add    $0x4,%esp
  800154:	ff 75 90             	pushl  -0x70(%ebp)
  800157:	e8 23 13 00 00       	call   80147f <close>
	wait(pid);
  80015c:	89 1c 24             	mov    %ebx,(%esp)
  80015f:	e8 cb 21 00 00       	call   80232f <wait>

	cprintf("pipe tests passed\n");
  800164:	c7 04 24 55 2a 80 00 	movl   $0x802a55,(%esp)
  80016b:	e8 b5 02 00 00       	call   800425 <cprintf>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    
		panic("pipe: %e", i);
  80017a:	50                   	push   %eax
  80017b:	68 6c 29 80 00       	push   $0x80296c
  800180:	6a 0e                	push   $0xe
  800182:	68 75 29 80 00       	push   $0x802975
  800187:	e8 b2 01 00 00       	call   80033e <_panic>
		panic("fork: %e", i);
  80018c:	56                   	push   %esi
  80018d:	68 85 29 80 00       	push   $0x802985
  800192:	6a 11                	push   $0x11
  800194:	68 75 29 80 00       	push   $0x802975
  800199:	e8 a0 01 00 00       	call   80033e <_panic>
			panic("read: %e", i);
  80019e:	50                   	push   %eax
  80019f:	68 c8 29 80 00       	push   $0x8029c8
  8001a4:	6a 19                	push   $0x19
  8001a6:	68 75 29 80 00       	push   $0x802975
  8001ab:	e8 8e 01 00 00       	call   80033e <_panic>
			cprintf("\ngot %d bytes: %s\n", i, buf);
  8001b0:	83 ec 04             	sub    $0x4,%esp
  8001b3:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8001b6:	50                   	push   %eax
  8001b7:	56                   	push   %esi
  8001b8:	68 ed 29 80 00       	push   $0x8029ed
  8001bd:	e8 63 02 00 00       	call   800425 <cprintf>
  8001c2:	83 c4 10             	add    $0x10,%esp
  8001c5:	e9 37 ff ff ff       	jmp    800101 <umain+0xce>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  8001ca:	a1 08 50 80 00       	mov    0x805008,%eax
  8001cf:	8b 40 48             	mov    0x48(%eax),%eax
  8001d2:	83 ec 04             	sub    $0x4,%esp
  8001d5:	ff 75 8c             	pushl  -0x74(%ebp)
  8001d8:	50                   	push   %eax
  8001d9:	68 8e 29 80 00       	push   $0x80298e
  8001de:	e8 42 02 00 00       	call   800425 <cprintf>
		close(p[0]);
  8001e3:	83 c4 04             	add    $0x4,%esp
  8001e6:	ff 75 8c             	pushl  -0x74(%ebp)
  8001e9:	e8 91 12 00 00       	call   80147f <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  8001ee:	a1 08 50 80 00       	mov    0x805008,%eax
  8001f3:	8b 40 48             	mov    0x48(%eax),%eax
  8001f6:	83 c4 0c             	add    $0xc,%esp
  8001f9:	ff 75 90             	pushl  -0x70(%ebp)
  8001fc:	50                   	push   %eax
  8001fd:	68 00 2a 80 00       	push   $0x802a00
  800202:	e8 1e 02 00 00       	call   800425 <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800207:	83 c4 04             	add    $0x4,%esp
  80020a:	ff 35 00 40 80 00    	pushl  0x804000
  800210:	e8 d7 07 00 00       	call   8009ec <strlen>
  800215:	83 c4 0c             	add    $0xc,%esp
  800218:	50                   	push   %eax
  800219:	ff 35 00 40 80 00    	pushl  0x804000
  80021f:	ff 75 90             	pushl  -0x70(%ebp)
  800222:	e8 78 14 00 00       	call   80169f <write>
  800227:	89 c6                	mov    %eax,%esi
  800229:	83 c4 04             	add    $0x4,%esp
  80022c:	ff 35 00 40 80 00    	pushl  0x804000
  800232:	e8 b5 07 00 00       	call   8009ec <strlen>
  800237:	83 c4 10             	add    $0x10,%esp
  80023a:	39 f0                	cmp    %esi,%eax
  80023c:	75 13                	jne    800251 <umain+0x21e>
		close(p[1]);
  80023e:	83 ec 0c             	sub    $0xc,%esp
  800241:	ff 75 90             	pushl  -0x70(%ebp)
  800244:	e8 36 12 00 00       	call   80147f <close>
  800249:	83 c4 10             	add    $0x10,%esp
  80024c:	e9 b5 fe ff ff       	jmp    800106 <umain+0xd3>
			panic("write: %e", i);
  800251:	56                   	push   %esi
  800252:	68 1d 2a 80 00       	push   $0x802a1d
  800257:	6a 25                	push   $0x25
  800259:	68 75 29 80 00       	push   $0x802975
  80025e:	e8 db 00 00 00       	call   80033e <_panic>
		panic("pipe: %e", i);
  800263:	50                   	push   %eax
  800264:	68 6c 29 80 00       	push   $0x80296c
  800269:	6a 2c                	push   $0x2c
  80026b:	68 75 29 80 00       	push   $0x802975
  800270:	e8 c9 00 00 00       	call   80033e <_panic>
		panic("fork: %e", i);
  800275:	56                   	push   %esi
  800276:	68 85 29 80 00       	push   $0x802985
  80027b:	6a 2f                	push   $0x2f
  80027d:	68 75 29 80 00       	push   $0x802975
  800282:	e8 b7 00 00 00       	call   80033e <_panic>
		close(p[0]);
  800287:	83 ec 0c             	sub    $0xc,%esp
  80028a:	ff 75 8c             	pushl  -0x74(%ebp)
  80028d:	e8 ed 11 00 00       	call   80147f <close>
  800292:	83 c4 10             	add    $0x10,%esp
			cprintf(".");
  800295:	83 ec 0c             	sub    $0xc,%esp
  800298:	68 34 2a 80 00       	push   $0x802a34
  80029d:	e8 83 01 00 00       	call   800425 <cprintf>
			if (write(p[1], "x", 1) != 1)
  8002a2:	83 c4 0c             	add    $0xc,%esp
  8002a5:	6a 01                	push   $0x1
  8002a7:	68 36 2a 80 00       	push   $0x802a36
  8002ac:	ff 75 90             	pushl  -0x70(%ebp)
  8002af:	e8 eb 13 00 00       	call   80169f <write>
  8002b4:	83 c4 10             	add    $0x10,%esp
  8002b7:	83 f8 01             	cmp    $0x1,%eax
  8002ba:	74 d9                	je     800295 <umain+0x262>
		cprintf("\npipe write closed properly\n");
  8002bc:	83 ec 0c             	sub    $0xc,%esp
  8002bf:	68 38 2a 80 00       	push   $0x802a38
  8002c4:	e8 5c 01 00 00       	call   800425 <cprintf>
		exit();
  8002c9:	e8 52 00 00 00       	call   800320 <exit>
  8002ce:	83 c4 10             	add    $0x10,%esp
  8002d1:	e9 70 fe ff ff       	jmp    800146 <umain+0x113>

008002d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002d6:	f3 0f 1e fb          	endbr32 
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	56                   	push   %esi
  8002de:	53                   	push   %ebx
  8002df:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002e2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002e5:	e8 68 0b 00 00       	call   800e52 <sys_getenvid>
  8002ea:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002ef:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002f2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002f7:	a3 08 50 80 00       	mov    %eax,0x805008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002fc:	85 db                	test   %ebx,%ebx
  8002fe:	7e 07                	jle    800307 <libmain+0x31>
		binaryname = argv[0];
  800300:	8b 06                	mov    (%esi),%eax
  800302:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	e8 22 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800311:	e8 0a 00 00 00       	call   800320 <exit>
}
  800316:	83 c4 10             	add    $0x10,%esp
  800319:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80031c:	5b                   	pop    %ebx
  80031d:	5e                   	pop    %esi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800320:	f3 0f 1e fb          	endbr32 
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  80032a:	e8 81 11 00 00       	call   8014b0 <close_all>
	sys_env_destroy(0);
  80032f:	83 ec 0c             	sub    $0xc,%esp
  800332:	6a 00                	push   $0x0
  800334:	e8 f5 0a 00 00       	call   800e2e <sys_env_destroy>
}
  800339:	83 c4 10             	add    $0x10,%esp
  80033c:	c9                   	leave  
  80033d:	c3                   	ret    

0080033e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80033e:	f3 0f 1e fb          	endbr32 
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	56                   	push   %esi
  800346:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800347:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80034a:	8b 35 04 40 80 00    	mov    0x804004,%esi
  800350:	e8 fd 0a 00 00       	call   800e52 <sys_getenvid>
  800355:	83 ec 0c             	sub    $0xc,%esp
  800358:	ff 75 0c             	pushl  0xc(%ebp)
  80035b:	ff 75 08             	pushl  0x8(%ebp)
  80035e:	56                   	push   %esi
  80035f:	50                   	push   %eax
  800360:	68 b8 2a 80 00       	push   $0x802ab8
  800365:	e8 bb 00 00 00       	call   800425 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80036a:	83 c4 18             	add    $0x18,%esp
  80036d:	53                   	push   %ebx
  80036e:	ff 75 10             	pushl  0x10(%ebp)
  800371:	e8 5a 00 00 00       	call   8003d0 <vcprintf>
	cprintf("\n");
  800376:	c7 04 24 a9 29 80 00 	movl   $0x8029a9,(%esp)
  80037d:	e8 a3 00 00 00       	call   800425 <cprintf>
  800382:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800385:	cc                   	int3   
  800386:	eb fd                	jmp    800385 <_panic+0x47>

00800388 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800388:	f3 0f 1e fb          	endbr32 
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	53                   	push   %ebx
  800390:	83 ec 04             	sub    $0x4,%esp
  800393:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800396:	8b 13                	mov    (%ebx),%edx
  800398:	8d 42 01             	lea    0x1(%edx),%eax
  80039b:	89 03                	mov    %eax,(%ebx)
  80039d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003a4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a9:	74 09                	je     8003b4 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003ab:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003b2:	c9                   	leave  
  8003b3:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003b4:	83 ec 08             	sub    $0x8,%esp
  8003b7:	68 ff 00 00 00       	push   $0xff
  8003bc:	8d 43 08             	lea    0x8(%ebx),%eax
  8003bf:	50                   	push   %eax
  8003c0:	e8 24 0a 00 00       	call   800de9 <sys_cputs>
		b->idx = 0;
  8003c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003cb:	83 c4 10             	add    $0x10,%esp
  8003ce:	eb db                	jmp    8003ab <putch+0x23>

008003d0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003d0:	f3 0f 1e fb          	endbr32 
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
  8003d7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003dd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003e4:	00 00 00 
	b.cnt = 0;
  8003e7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ee:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003f1:	ff 75 0c             	pushl  0xc(%ebp)
  8003f4:	ff 75 08             	pushl  0x8(%ebp)
  8003f7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003fd:	50                   	push   %eax
  8003fe:	68 88 03 80 00       	push   $0x800388
  800403:	e8 20 01 00 00       	call   800528 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800408:	83 c4 08             	add    $0x8,%esp
  80040b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800411:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800417:	50                   	push   %eax
  800418:	e8 cc 09 00 00       	call   800de9 <sys_cputs>

	return b.cnt;
}
  80041d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800423:	c9                   	leave  
  800424:	c3                   	ret    

00800425 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800425:	f3 0f 1e fb          	endbr32 
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80042f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800432:	50                   	push   %eax
  800433:	ff 75 08             	pushl  0x8(%ebp)
  800436:	e8 95 ff ff ff       	call   8003d0 <vcprintf>
	va_end(ap);

	return cnt;
}
  80043b:	c9                   	leave  
  80043c:	c3                   	ret    

0080043d <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80043d:	55                   	push   %ebp
  80043e:	89 e5                	mov    %esp,%ebp
  800440:	57                   	push   %edi
  800441:	56                   	push   %esi
  800442:	53                   	push   %ebx
  800443:	83 ec 1c             	sub    $0x1c,%esp
  800446:	89 c7                	mov    %eax,%edi
  800448:	89 d6                	mov    %edx,%esi
  80044a:	8b 45 08             	mov    0x8(%ebp),%eax
  80044d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800450:	89 d1                	mov    %edx,%ecx
  800452:	89 c2                	mov    %eax,%edx
  800454:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800457:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80045a:	8b 45 10             	mov    0x10(%ebp),%eax
  80045d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800460:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800463:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80046a:	39 c2                	cmp    %eax,%edx
  80046c:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80046f:	72 3e                	jb     8004af <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800471:	83 ec 0c             	sub    $0xc,%esp
  800474:	ff 75 18             	pushl  0x18(%ebp)
  800477:	83 eb 01             	sub    $0x1,%ebx
  80047a:	53                   	push   %ebx
  80047b:	50                   	push   %eax
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800482:	ff 75 e0             	pushl  -0x20(%ebp)
  800485:	ff 75 dc             	pushl  -0x24(%ebp)
  800488:	ff 75 d8             	pushl  -0x28(%ebp)
  80048b:	e8 60 22 00 00       	call   8026f0 <__udivdi3>
  800490:	83 c4 18             	add    $0x18,%esp
  800493:	52                   	push   %edx
  800494:	50                   	push   %eax
  800495:	89 f2                	mov    %esi,%edx
  800497:	89 f8                	mov    %edi,%eax
  800499:	e8 9f ff ff ff       	call   80043d <printnum>
  80049e:	83 c4 20             	add    $0x20,%esp
  8004a1:	eb 13                	jmp    8004b6 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	56                   	push   %esi
  8004a7:	ff 75 18             	pushl  0x18(%ebp)
  8004aa:	ff d7                	call   *%edi
  8004ac:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004af:	83 eb 01             	sub    $0x1,%ebx
  8004b2:	85 db                	test   %ebx,%ebx
  8004b4:	7f ed                	jg     8004a3 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004b6:	83 ec 08             	sub    $0x8,%esp
  8004b9:	56                   	push   %esi
  8004ba:	83 ec 04             	sub    $0x4,%esp
  8004bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c3:	ff 75 dc             	pushl  -0x24(%ebp)
  8004c6:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c9:	e8 32 23 00 00       	call   802800 <__umoddi3>
  8004ce:	83 c4 14             	add    $0x14,%esp
  8004d1:	0f be 80 db 2a 80 00 	movsbl 0x802adb(%eax),%eax
  8004d8:	50                   	push   %eax
  8004d9:	ff d7                	call   *%edi
}
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004e1:	5b                   	pop    %ebx
  8004e2:	5e                   	pop    %esi
  8004e3:	5f                   	pop    %edi
  8004e4:	5d                   	pop    %ebp
  8004e5:	c3                   	ret    

008004e6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e6:	f3 0f 1e fb          	endbr32 
  8004ea:	55                   	push   %ebp
  8004eb:	89 e5                	mov    %esp,%ebp
  8004ed:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004f0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f4:	8b 10                	mov    (%eax),%edx
  8004f6:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f9:	73 0a                	jae    800505 <sprintputch+0x1f>
		*b->buf++ = ch;
  8004fb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004fe:	89 08                	mov    %ecx,(%eax)
  800500:	8b 45 08             	mov    0x8(%ebp),%eax
  800503:	88 02                	mov    %al,(%edx)
}
  800505:	5d                   	pop    %ebp
  800506:	c3                   	ret    

00800507 <printfmt>:
{
  800507:	f3 0f 1e fb          	endbr32 
  80050b:	55                   	push   %ebp
  80050c:	89 e5                	mov    %esp,%ebp
  80050e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800511:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800514:	50                   	push   %eax
  800515:	ff 75 10             	pushl  0x10(%ebp)
  800518:	ff 75 0c             	pushl  0xc(%ebp)
  80051b:	ff 75 08             	pushl  0x8(%ebp)
  80051e:	e8 05 00 00 00       	call   800528 <vprintfmt>
}
  800523:	83 c4 10             	add    $0x10,%esp
  800526:	c9                   	leave  
  800527:	c3                   	ret    

00800528 <vprintfmt>:
{
  800528:	f3 0f 1e fb          	endbr32 
  80052c:	55                   	push   %ebp
  80052d:	89 e5                	mov    %esp,%ebp
  80052f:	57                   	push   %edi
  800530:	56                   	push   %esi
  800531:	53                   	push   %ebx
  800532:	83 ec 3c             	sub    $0x3c,%esp
  800535:	8b 75 08             	mov    0x8(%ebp),%esi
  800538:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80053e:	e9 8e 03 00 00       	jmp    8008d1 <vprintfmt+0x3a9>
		padc = ' ';
  800543:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800547:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80054e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800555:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80055c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800561:	8d 47 01             	lea    0x1(%edi),%eax
  800564:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800567:	0f b6 17             	movzbl (%edi),%edx
  80056a:	8d 42 dd             	lea    -0x23(%edx),%eax
  80056d:	3c 55                	cmp    $0x55,%al
  80056f:	0f 87 df 03 00 00    	ja     800954 <vprintfmt+0x42c>
  800575:	0f b6 c0             	movzbl %al,%eax
  800578:	3e ff 24 85 20 2c 80 	notrack jmp *0x802c20(,%eax,4)
  80057f:	00 
  800580:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800583:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800587:	eb d8                	jmp    800561 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800589:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058c:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800590:	eb cf                	jmp    800561 <vprintfmt+0x39>
  800592:	0f b6 d2             	movzbl %dl,%edx
  800595:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800598:	b8 00 00 00 00       	mov    $0x0,%eax
  80059d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8005a0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005a3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005a7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005aa:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005ad:	83 f9 09             	cmp    $0x9,%ecx
  8005b0:	77 55                	ja     800607 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005b2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8005b5:	eb e9                	jmp    8005a0 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8b 00                	mov    (%eax),%eax
  8005bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8d 40 04             	lea    0x4(%eax),%eax
  8005c5:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005cb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005cf:	79 90                	jns    800561 <vprintfmt+0x39>
				width = precision, precision = -1;
  8005d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005de:	eb 81                	jmp    800561 <vprintfmt+0x39>
  8005e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e3:	85 c0                	test   %eax,%eax
  8005e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ea:	0f 49 d0             	cmovns %eax,%edx
  8005ed:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005f3:	e9 69 ff ff ff       	jmp    800561 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005fb:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800602:	e9 5a ff ff ff       	jmp    800561 <vprintfmt+0x39>
  800607:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80060a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060d:	eb bc                	jmp    8005cb <vprintfmt+0xa3>
			lflag++;
  80060f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800612:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800615:	e9 47 ff ff ff       	jmp    800561 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 78 04             	lea    0x4(%eax),%edi
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	53                   	push   %ebx
  800624:	ff 30                	pushl  (%eax)
  800626:	ff d6                	call   *%esi
			break;
  800628:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80062b:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80062e:	e9 9b 02 00 00       	jmp    8008ce <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8d 78 04             	lea    0x4(%eax),%edi
  800639:	8b 00                	mov    (%eax),%eax
  80063b:	99                   	cltd   
  80063c:	31 d0                	xor    %edx,%eax
  80063e:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800640:	83 f8 0f             	cmp    $0xf,%eax
  800643:	7f 23                	jg     800668 <vprintfmt+0x140>
  800645:	8b 14 85 80 2d 80 00 	mov    0x802d80(,%eax,4),%edx
  80064c:	85 d2                	test   %edx,%edx
  80064e:	74 18                	je     800668 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800650:	52                   	push   %edx
  800651:	68 85 2f 80 00       	push   $0x802f85
  800656:	53                   	push   %ebx
  800657:	56                   	push   %esi
  800658:	e8 aa fe ff ff       	call   800507 <printfmt>
  80065d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800660:	89 7d 14             	mov    %edi,0x14(%ebp)
  800663:	e9 66 02 00 00       	jmp    8008ce <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800668:	50                   	push   %eax
  800669:	68 f3 2a 80 00       	push   $0x802af3
  80066e:	53                   	push   %ebx
  80066f:	56                   	push   %esi
  800670:	e8 92 fe ff ff       	call   800507 <printfmt>
  800675:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800678:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80067b:	e9 4e 02 00 00       	jmp    8008ce <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	83 c0 04             	add    $0x4,%eax
  800686:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800689:	8b 45 14             	mov    0x14(%ebp),%eax
  80068c:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80068e:	85 d2                	test   %edx,%edx
  800690:	b8 ec 2a 80 00       	mov    $0x802aec,%eax
  800695:	0f 45 c2             	cmovne %edx,%eax
  800698:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80069b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80069f:	7e 06                	jle    8006a7 <vprintfmt+0x17f>
  8006a1:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006a5:	75 0d                	jne    8006b4 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a7:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006aa:	89 c7                	mov    %eax,%edi
  8006ac:	03 45 e0             	add    -0x20(%ebp),%eax
  8006af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b2:	eb 55                	jmp    800709 <vprintfmt+0x1e1>
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8006ba:	ff 75 cc             	pushl  -0x34(%ebp)
  8006bd:	e8 46 03 00 00       	call   800a08 <strnlen>
  8006c2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006c5:	29 c2                	sub    %eax,%edx
  8006c7:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006ca:	83 c4 10             	add    $0x10,%esp
  8006cd:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006cf:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d6:	85 ff                	test   %edi,%edi
  8006d8:	7e 11                	jle    8006eb <vprintfmt+0x1c3>
					putch(padc, putdat);
  8006da:	83 ec 08             	sub    $0x8,%esp
  8006dd:	53                   	push   %ebx
  8006de:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e1:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e3:	83 ef 01             	sub    $0x1,%edi
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	eb eb                	jmp    8006d6 <vprintfmt+0x1ae>
  8006eb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006ee:	85 d2                	test   %edx,%edx
  8006f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f5:	0f 49 c2             	cmovns %edx,%eax
  8006f8:	29 c2                	sub    %eax,%edx
  8006fa:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006fd:	eb a8                	jmp    8006a7 <vprintfmt+0x17f>
					putch(ch, putdat);
  8006ff:	83 ec 08             	sub    $0x8,%esp
  800702:	53                   	push   %ebx
  800703:	52                   	push   %edx
  800704:	ff d6                	call   *%esi
  800706:	83 c4 10             	add    $0x10,%esp
  800709:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80070c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80070e:	83 c7 01             	add    $0x1,%edi
  800711:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800715:	0f be d0             	movsbl %al,%edx
  800718:	85 d2                	test   %edx,%edx
  80071a:	74 4b                	je     800767 <vprintfmt+0x23f>
  80071c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800720:	78 06                	js     800728 <vprintfmt+0x200>
  800722:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800726:	78 1e                	js     800746 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  800728:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80072c:	74 d1                	je     8006ff <vprintfmt+0x1d7>
  80072e:	0f be c0             	movsbl %al,%eax
  800731:	83 e8 20             	sub    $0x20,%eax
  800734:	83 f8 5e             	cmp    $0x5e,%eax
  800737:	76 c6                	jbe    8006ff <vprintfmt+0x1d7>
					putch('?', putdat);
  800739:	83 ec 08             	sub    $0x8,%esp
  80073c:	53                   	push   %ebx
  80073d:	6a 3f                	push   $0x3f
  80073f:	ff d6                	call   *%esi
  800741:	83 c4 10             	add    $0x10,%esp
  800744:	eb c3                	jmp    800709 <vprintfmt+0x1e1>
  800746:	89 cf                	mov    %ecx,%edi
  800748:	eb 0e                	jmp    800758 <vprintfmt+0x230>
				putch(' ', putdat);
  80074a:	83 ec 08             	sub    $0x8,%esp
  80074d:	53                   	push   %ebx
  80074e:	6a 20                	push   $0x20
  800750:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800752:	83 ef 01             	sub    $0x1,%edi
  800755:	83 c4 10             	add    $0x10,%esp
  800758:	85 ff                	test   %edi,%edi
  80075a:	7f ee                	jg     80074a <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80075c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80075f:	89 45 14             	mov    %eax,0x14(%ebp)
  800762:	e9 67 01 00 00       	jmp    8008ce <vprintfmt+0x3a6>
  800767:	89 cf                	mov    %ecx,%edi
  800769:	eb ed                	jmp    800758 <vprintfmt+0x230>
	if (lflag >= 2)
  80076b:	83 f9 01             	cmp    $0x1,%ecx
  80076e:	7f 1b                	jg     80078b <vprintfmt+0x263>
	else if (lflag)
  800770:	85 c9                	test   %ecx,%ecx
  800772:	74 63                	je     8007d7 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8b 00                	mov    (%eax),%eax
  800779:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80077c:	99                   	cltd   
  80077d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800780:	8b 45 14             	mov    0x14(%ebp),%eax
  800783:	8d 40 04             	lea    0x4(%eax),%eax
  800786:	89 45 14             	mov    %eax,0x14(%ebp)
  800789:	eb 17                	jmp    8007a2 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80078b:	8b 45 14             	mov    0x14(%ebp),%eax
  80078e:	8b 50 04             	mov    0x4(%eax),%edx
  800791:	8b 00                	mov    (%eax),%eax
  800793:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800796:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	8d 40 08             	lea    0x8(%eax),%eax
  80079f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007a2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007a5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007a8:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007ad:	85 c9                	test   %ecx,%ecx
  8007af:	0f 89 ff 00 00 00    	jns    8008b4 <vprintfmt+0x38c>
				putch('-', putdat);
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	53                   	push   %ebx
  8007b9:	6a 2d                	push   $0x2d
  8007bb:	ff d6                	call   *%esi
				num = -(long long) num;
  8007bd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007c0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007c3:	f7 da                	neg    %edx
  8007c5:	83 d1 00             	adc    $0x0,%ecx
  8007c8:	f7 d9                	neg    %ecx
  8007ca:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007cd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007d2:	e9 dd 00 00 00       	jmp    8008b4 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	8b 00                	mov    (%eax),%eax
  8007dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007df:	99                   	cltd   
  8007e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e6:	8d 40 04             	lea    0x4(%eax),%eax
  8007e9:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ec:	eb b4                	jmp    8007a2 <vprintfmt+0x27a>
	if (lflag >= 2)
  8007ee:	83 f9 01             	cmp    $0x1,%ecx
  8007f1:	7f 1e                	jg     800811 <vprintfmt+0x2e9>
	else if (lflag)
  8007f3:	85 c9                	test   %ecx,%ecx
  8007f5:	74 32                	je     800829 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8007f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fa:	8b 10                	mov    (%eax),%edx
  8007fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800801:	8d 40 04             	lea    0x4(%eax),%eax
  800804:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800807:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80080c:	e9 a3 00 00 00       	jmp    8008b4 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800811:	8b 45 14             	mov    0x14(%ebp),%eax
  800814:	8b 10                	mov    (%eax),%edx
  800816:	8b 48 04             	mov    0x4(%eax),%ecx
  800819:	8d 40 08             	lea    0x8(%eax),%eax
  80081c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80081f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800824:	e9 8b 00 00 00       	jmp    8008b4 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800829:	8b 45 14             	mov    0x14(%ebp),%eax
  80082c:	8b 10                	mov    (%eax),%edx
  80082e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800833:	8d 40 04             	lea    0x4(%eax),%eax
  800836:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800839:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80083e:	eb 74                	jmp    8008b4 <vprintfmt+0x38c>
	if (lflag >= 2)
  800840:	83 f9 01             	cmp    $0x1,%ecx
  800843:	7f 1b                	jg     800860 <vprintfmt+0x338>
	else if (lflag)
  800845:	85 c9                	test   %ecx,%ecx
  800847:	74 2c                	je     800875 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800849:	8b 45 14             	mov    0x14(%ebp),%eax
  80084c:	8b 10                	mov    (%eax),%edx
  80084e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800853:	8d 40 04             	lea    0x4(%eax),%eax
  800856:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800859:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  80085e:	eb 54                	jmp    8008b4 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800860:	8b 45 14             	mov    0x14(%ebp),%eax
  800863:	8b 10                	mov    (%eax),%edx
  800865:	8b 48 04             	mov    0x4(%eax),%ecx
  800868:	8d 40 08             	lea    0x8(%eax),%eax
  80086b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80086e:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800873:	eb 3f                	jmp    8008b4 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800875:	8b 45 14             	mov    0x14(%ebp),%eax
  800878:	8b 10                	mov    (%eax),%edx
  80087a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80087f:	8d 40 04             	lea    0x4(%eax),%eax
  800882:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800885:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  80088a:	eb 28                	jmp    8008b4 <vprintfmt+0x38c>
			putch('0', putdat);
  80088c:	83 ec 08             	sub    $0x8,%esp
  80088f:	53                   	push   %ebx
  800890:	6a 30                	push   $0x30
  800892:	ff d6                	call   *%esi
			putch('x', putdat);
  800894:	83 c4 08             	add    $0x8,%esp
  800897:	53                   	push   %ebx
  800898:	6a 78                	push   $0x78
  80089a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80089c:	8b 45 14             	mov    0x14(%ebp),%eax
  80089f:	8b 10                	mov    (%eax),%edx
  8008a1:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008a6:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008a9:	8d 40 04             	lea    0x4(%eax),%eax
  8008ac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008af:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008b4:	83 ec 0c             	sub    $0xc,%esp
  8008b7:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008bb:	57                   	push   %edi
  8008bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8008bf:	50                   	push   %eax
  8008c0:	51                   	push   %ecx
  8008c1:	52                   	push   %edx
  8008c2:	89 da                	mov    %ebx,%edx
  8008c4:	89 f0                	mov    %esi,%eax
  8008c6:	e8 72 fb ff ff       	call   80043d <printnum>
			break;
  8008cb:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  8008d1:	83 c7 01             	add    $0x1,%edi
  8008d4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008d8:	83 f8 25             	cmp    $0x25,%eax
  8008db:	0f 84 62 fc ff ff    	je     800543 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  8008e1:	85 c0                	test   %eax,%eax
  8008e3:	0f 84 8b 00 00 00    	je     800974 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  8008e9:	83 ec 08             	sub    $0x8,%esp
  8008ec:	53                   	push   %ebx
  8008ed:	50                   	push   %eax
  8008ee:	ff d6                	call   *%esi
  8008f0:	83 c4 10             	add    $0x10,%esp
  8008f3:	eb dc                	jmp    8008d1 <vprintfmt+0x3a9>
	if (lflag >= 2)
  8008f5:	83 f9 01             	cmp    $0x1,%ecx
  8008f8:	7f 1b                	jg     800915 <vprintfmt+0x3ed>
	else if (lflag)
  8008fa:	85 c9                	test   %ecx,%ecx
  8008fc:	74 2c                	je     80092a <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  8008fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800901:	8b 10                	mov    (%eax),%edx
  800903:	b9 00 00 00 00       	mov    $0x0,%ecx
  800908:	8d 40 04             	lea    0x4(%eax),%eax
  80090b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80090e:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800913:	eb 9f                	jmp    8008b4 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800915:	8b 45 14             	mov    0x14(%ebp),%eax
  800918:	8b 10                	mov    (%eax),%edx
  80091a:	8b 48 04             	mov    0x4(%eax),%ecx
  80091d:	8d 40 08             	lea    0x8(%eax),%eax
  800920:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800923:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800928:	eb 8a                	jmp    8008b4 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80092a:	8b 45 14             	mov    0x14(%ebp),%eax
  80092d:	8b 10                	mov    (%eax),%edx
  80092f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800934:	8d 40 04             	lea    0x4(%eax),%eax
  800937:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80093a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80093f:	e9 70 ff ff ff       	jmp    8008b4 <vprintfmt+0x38c>
			putch(ch, putdat);
  800944:	83 ec 08             	sub    $0x8,%esp
  800947:	53                   	push   %ebx
  800948:	6a 25                	push   $0x25
  80094a:	ff d6                	call   *%esi
			break;
  80094c:	83 c4 10             	add    $0x10,%esp
  80094f:	e9 7a ff ff ff       	jmp    8008ce <vprintfmt+0x3a6>
			putch('%', putdat);
  800954:	83 ec 08             	sub    $0x8,%esp
  800957:	53                   	push   %ebx
  800958:	6a 25                	push   $0x25
  80095a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  80095c:	83 c4 10             	add    $0x10,%esp
  80095f:	89 f8                	mov    %edi,%eax
  800961:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800965:	74 05                	je     80096c <vprintfmt+0x444>
  800967:	83 e8 01             	sub    $0x1,%eax
  80096a:	eb f5                	jmp    800961 <vprintfmt+0x439>
  80096c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80096f:	e9 5a ff ff ff       	jmp    8008ce <vprintfmt+0x3a6>
}
  800974:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800977:	5b                   	pop    %ebx
  800978:	5e                   	pop    %esi
  800979:	5f                   	pop    %edi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80097c:	f3 0f 1e fb          	endbr32 
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	83 ec 18             	sub    $0x18,%esp
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80098c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80098f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800993:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800996:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80099d:	85 c0                	test   %eax,%eax
  80099f:	74 26                	je     8009c7 <vsnprintf+0x4b>
  8009a1:	85 d2                	test   %edx,%edx
  8009a3:	7e 22                	jle    8009c7 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009a5:	ff 75 14             	pushl  0x14(%ebp)
  8009a8:	ff 75 10             	pushl  0x10(%ebp)
  8009ab:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009ae:	50                   	push   %eax
  8009af:	68 e6 04 80 00       	push   $0x8004e6
  8009b4:	e8 6f fb ff ff       	call   800528 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009bc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009c2:	83 c4 10             	add    $0x10,%esp
}
  8009c5:	c9                   	leave  
  8009c6:	c3                   	ret    
		return -E_INVAL;
  8009c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009cc:	eb f7                	jmp    8009c5 <vsnprintf+0x49>

008009ce <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009ce:	f3 0f 1e fb          	endbr32 
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  8009d8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009db:	50                   	push   %eax
  8009dc:	ff 75 10             	pushl  0x10(%ebp)
  8009df:	ff 75 0c             	pushl  0xc(%ebp)
  8009e2:	ff 75 08             	pushl  0x8(%ebp)
  8009e5:	e8 92 ff ff ff       	call   80097c <vsnprintf>
	va_end(ap);

	return rc;
}
  8009ea:	c9                   	leave  
  8009eb:	c3                   	ret    

008009ec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009ec:	f3 0f 1e fb          	endbr32 
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009ff:	74 05                	je     800a06 <strlen+0x1a>
		n++;
  800a01:	83 c0 01             	add    $0x1,%eax
  800a04:	eb f5                	jmp    8009fb <strlen+0xf>
	return n;
}
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a08:	f3 0f 1e fb          	endbr32 
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a12:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1a:	39 d0                	cmp    %edx,%eax
  800a1c:	74 0d                	je     800a2b <strnlen+0x23>
  800a1e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a22:	74 05                	je     800a29 <strnlen+0x21>
		n++;
  800a24:	83 c0 01             	add    $0x1,%eax
  800a27:	eb f1                	jmp    800a1a <strnlen+0x12>
  800a29:	89 c2                	mov    %eax,%edx
	return n;
}
  800a2b:	89 d0                	mov    %edx,%eax
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a2f:	f3 0f 1e fb          	endbr32 
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	53                   	push   %ebx
  800a37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a42:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a46:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a49:	83 c0 01             	add    $0x1,%eax
  800a4c:	84 d2                	test   %dl,%dl
  800a4e:	75 f2                	jne    800a42 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a50:	89 c8                	mov    %ecx,%eax
  800a52:	5b                   	pop    %ebx
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a55:	f3 0f 1e fb          	endbr32 
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	53                   	push   %ebx
  800a5d:	83 ec 10             	sub    $0x10,%esp
  800a60:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a63:	53                   	push   %ebx
  800a64:	e8 83 ff ff ff       	call   8009ec <strlen>
  800a69:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a6c:	ff 75 0c             	pushl  0xc(%ebp)
  800a6f:	01 d8                	add    %ebx,%eax
  800a71:	50                   	push   %eax
  800a72:	e8 b8 ff ff ff       	call   800a2f <strcpy>
	return dst;
}
  800a77:	89 d8                	mov    %ebx,%eax
  800a79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a7c:	c9                   	leave  
  800a7d:	c3                   	ret    

00800a7e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a7e:	f3 0f 1e fb          	endbr32 
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	56                   	push   %esi
  800a86:	53                   	push   %ebx
  800a87:	8b 75 08             	mov    0x8(%ebp),%esi
  800a8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8d:	89 f3                	mov    %esi,%ebx
  800a8f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a92:	89 f0                	mov    %esi,%eax
  800a94:	39 d8                	cmp    %ebx,%eax
  800a96:	74 11                	je     800aa9 <strncpy+0x2b>
		*dst++ = *src;
  800a98:	83 c0 01             	add    $0x1,%eax
  800a9b:	0f b6 0a             	movzbl (%edx),%ecx
  800a9e:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aa1:	80 f9 01             	cmp    $0x1,%cl
  800aa4:	83 da ff             	sbb    $0xffffffff,%edx
  800aa7:	eb eb                	jmp    800a94 <strncpy+0x16>
	}
	return ret;
}
  800aa9:	89 f0                	mov    %esi,%eax
  800aab:	5b                   	pop    %ebx
  800aac:	5e                   	pop    %esi
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aaf:	f3 0f 1e fb          	endbr32 
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	56                   	push   %esi
  800ab7:	53                   	push   %ebx
  800ab8:	8b 75 08             	mov    0x8(%ebp),%esi
  800abb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800abe:	8b 55 10             	mov    0x10(%ebp),%edx
  800ac1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ac3:	85 d2                	test   %edx,%edx
  800ac5:	74 21                	je     800ae8 <strlcpy+0x39>
  800ac7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800acb:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800acd:	39 c2                	cmp    %eax,%edx
  800acf:	74 14                	je     800ae5 <strlcpy+0x36>
  800ad1:	0f b6 19             	movzbl (%ecx),%ebx
  800ad4:	84 db                	test   %bl,%bl
  800ad6:	74 0b                	je     800ae3 <strlcpy+0x34>
			*dst++ = *src++;
  800ad8:	83 c1 01             	add    $0x1,%ecx
  800adb:	83 c2 01             	add    $0x1,%edx
  800ade:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ae1:	eb ea                	jmp    800acd <strlcpy+0x1e>
  800ae3:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800ae5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ae8:	29 f0                	sub    %esi,%eax
}
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aee:	f3 0f 1e fb          	endbr32 
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800afb:	0f b6 01             	movzbl (%ecx),%eax
  800afe:	84 c0                	test   %al,%al
  800b00:	74 0c                	je     800b0e <strcmp+0x20>
  800b02:	3a 02                	cmp    (%edx),%al
  800b04:	75 08                	jne    800b0e <strcmp+0x20>
		p++, q++;
  800b06:	83 c1 01             	add    $0x1,%ecx
  800b09:	83 c2 01             	add    $0x1,%edx
  800b0c:	eb ed                	jmp    800afb <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b0e:	0f b6 c0             	movzbl %al,%eax
  800b11:	0f b6 12             	movzbl (%edx),%edx
  800b14:	29 d0                	sub    %edx,%eax
}
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b18:	f3 0f 1e fb          	endbr32 
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	53                   	push   %ebx
  800b20:	8b 45 08             	mov    0x8(%ebp),%eax
  800b23:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b26:	89 c3                	mov    %eax,%ebx
  800b28:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b2b:	eb 06                	jmp    800b33 <strncmp+0x1b>
		n--, p++, q++;
  800b2d:	83 c0 01             	add    $0x1,%eax
  800b30:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b33:	39 d8                	cmp    %ebx,%eax
  800b35:	74 16                	je     800b4d <strncmp+0x35>
  800b37:	0f b6 08             	movzbl (%eax),%ecx
  800b3a:	84 c9                	test   %cl,%cl
  800b3c:	74 04                	je     800b42 <strncmp+0x2a>
  800b3e:	3a 0a                	cmp    (%edx),%cl
  800b40:	74 eb                	je     800b2d <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b42:	0f b6 00             	movzbl (%eax),%eax
  800b45:	0f b6 12             	movzbl (%edx),%edx
  800b48:	29 d0                	sub    %edx,%eax
}
  800b4a:	5b                   	pop    %ebx
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    
		return 0;
  800b4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b52:	eb f6                	jmp    800b4a <strncmp+0x32>

00800b54 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b54:	f3 0f 1e fb          	endbr32 
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b62:	0f b6 10             	movzbl (%eax),%edx
  800b65:	84 d2                	test   %dl,%dl
  800b67:	74 09                	je     800b72 <strchr+0x1e>
		if (*s == c)
  800b69:	38 ca                	cmp    %cl,%dl
  800b6b:	74 0a                	je     800b77 <strchr+0x23>
	for (; *s; s++)
  800b6d:	83 c0 01             	add    $0x1,%eax
  800b70:	eb f0                	jmp    800b62 <strchr+0xe>
			return (char *) s;
	return 0;
  800b72:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800b79:	f3 0f 1e fb          	endbr32 
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800b83:	6a 78                	push   $0x78
  800b85:	ff 75 08             	pushl  0x8(%ebp)
  800b88:	e8 c7 ff ff ff       	call   800b54 <strchr>
  800b8d:	83 c4 10             	add    $0x10,%esp
  800b90:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800b98:	eb 0d                	jmp    800ba7 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800b9a:	c1 e0 04             	shl    $0x4,%eax
  800b9d:	0f be d2             	movsbl %dl,%edx
  800ba0:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800ba4:	83 c1 01             	add    $0x1,%ecx
  800ba7:	0f b6 11             	movzbl (%ecx),%edx
  800baa:	84 d2                	test   %dl,%dl
  800bac:	74 11                	je     800bbf <atox+0x46>
		if (*p>='a'){
  800bae:	80 fa 60             	cmp    $0x60,%dl
  800bb1:	7e e7                	jle    800b9a <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800bb3:	c1 e0 04             	shl    $0x4,%eax
  800bb6:	0f be d2             	movsbl %dl,%edx
  800bb9:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800bbd:	eb e5                	jmp    800ba4 <atox+0x2b>
	}

	return v;

}
  800bbf:	c9                   	leave  
  800bc0:	c3                   	ret    

00800bc1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bc1:	f3 0f 1e fb          	endbr32 
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bcf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bd2:	38 ca                	cmp    %cl,%dl
  800bd4:	74 09                	je     800bdf <strfind+0x1e>
  800bd6:	84 d2                	test   %dl,%dl
  800bd8:	74 05                	je     800bdf <strfind+0x1e>
	for (; *s; s++)
  800bda:	83 c0 01             	add    $0x1,%eax
  800bdd:	eb f0                	jmp    800bcf <strfind+0xe>
			break;
	return (char *) s;
}
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800be1:	f3 0f 1e fb          	endbr32 
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	57                   	push   %edi
  800be9:	56                   	push   %esi
  800bea:	53                   	push   %ebx
  800beb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bf1:	85 c9                	test   %ecx,%ecx
  800bf3:	74 31                	je     800c26 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bf5:	89 f8                	mov    %edi,%eax
  800bf7:	09 c8                	or     %ecx,%eax
  800bf9:	a8 03                	test   $0x3,%al
  800bfb:	75 23                	jne    800c20 <memset+0x3f>
		c &= 0xFF;
  800bfd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c01:	89 d3                	mov    %edx,%ebx
  800c03:	c1 e3 08             	shl    $0x8,%ebx
  800c06:	89 d0                	mov    %edx,%eax
  800c08:	c1 e0 18             	shl    $0x18,%eax
  800c0b:	89 d6                	mov    %edx,%esi
  800c0d:	c1 e6 10             	shl    $0x10,%esi
  800c10:	09 f0                	or     %esi,%eax
  800c12:	09 c2                	or     %eax,%edx
  800c14:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c16:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c19:	89 d0                	mov    %edx,%eax
  800c1b:	fc                   	cld    
  800c1c:	f3 ab                	rep stos %eax,%es:(%edi)
  800c1e:	eb 06                	jmp    800c26 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c23:	fc                   	cld    
  800c24:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c26:	89 f8                	mov    %edi,%eax
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c2d:	f3 0f 1e fb          	endbr32 
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	57                   	push   %edi
  800c35:	56                   	push   %esi
  800c36:	8b 45 08             	mov    0x8(%ebp),%eax
  800c39:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c3c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c3f:	39 c6                	cmp    %eax,%esi
  800c41:	73 32                	jae    800c75 <memmove+0x48>
  800c43:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c46:	39 c2                	cmp    %eax,%edx
  800c48:	76 2b                	jbe    800c75 <memmove+0x48>
		s += n;
		d += n;
  800c4a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c4d:	89 fe                	mov    %edi,%esi
  800c4f:	09 ce                	or     %ecx,%esi
  800c51:	09 d6                	or     %edx,%esi
  800c53:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c59:	75 0e                	jne    800c69 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c5b:	83 ef 04             	sub    $0x4,%edi
  800c5e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c61:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c64:	fd                   	std    
  800c65:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c67:	eb 09                	jmp    800c72 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c69:	83 ef 01             	sub    $0x1,%edi
  800c6c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c6f:	fd                   	std    
  800c70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c72:	fc                   	cld    
  800c73:	eb 1a                	jmp    800c8f <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c75:	89 c2                	mov    %eax,%edx
  800c77:	09 ca                	or     %ecx,%edx
  800c79:	09 f2                	or     %esi,%edx
  800c7b:	f6 c2 03             	test   $0x3,%dl
  800c7e:	75 0a                	jne    800c8a <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c80:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c83:	89 c7                	mov    %eax,%edi
  800c85:	fc                   	cld    
  800c86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c88:	eb 05                	jmp    800c8f <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c8a:	89 c7                	mov    %eax,%edi
  800c8c:	fc                   	cld    
  800c8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c93:	f3 0f 1e fb          	endbr32 
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c9d:	ff 75 10             	pushl  0x10(%ebp)
  800ca0:	ff 75 0c             	pushl  0xc(%ebp)
  800ca3:	ff 75 08             	pushl  0x8(%ebp)
  800ca6:	e8 82 ff ff ff       	call   800c2d <memmove>
}
  800cab:	c9                   	leave  
  800cac:	c3                   	ret    

00800cad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cad:	f3 0f 1e fb          	endbr32 
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	56                   	push   %esi
  800cb5:	53                   	push   %ebx
  800cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cbc:	89 c6                	mov    %eax,%esi
  800cbe:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc1:	39 f0                	cmp    %esi,%eax
  800cc3:	74 1c                	je     800ce1 <memcmp+0x34>
		if (*s1 != *s2)
  800cc5:	0f b6 08             	movzbl (%eax),%ecx
  800cc8:	0f b6 1a             	movzbl (%edx),%ebx
  800ccb:	38 d9                	cmp    %bl,%cl
  800ccd:	75 08                	jne    800cd7 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ccf:	83 c0 01             	add    $0x1,%eax
  800cd2:	83 c2 01             	add    $0x1,%edx
  800cd5:	eb ea                	jmp    800cc1 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800cd7:	0f b6 c1             	movzbl %cl,%eax
  800cda:	0f b6 db             	movzbl %bl,%ebx
  800cdd:	29 d8                	sub    %ebx,%eax
  800cdf:	eb 05                	jmp    800ce6 <memcmp+0x39>
	}

	return 0;
  800ce1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce6:	5b                   	pop    %ebx
  800ce7:	5e                   	pop    %esi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cea:	f3 0f 1e fb          	endbr32 
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cf7:	89 c2                	mov    %eax,%edx
  800cf9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cfc:	39 d0                	cmp    %edx,%eax
  800cfe:	73 09                	jae    800d09 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d00:	38 08                	cmp    %cl,(%eax)
  800d02:	74 05                	je     800d09 <memfind+0x1f>
	for (; s < ends; s++)
  800d04:	83 c0 01             	add    $0x1,%eax
  800d07:	eb f3                	jmp    800cfc <memfind+0x12>
			break;
	return (void *) s;
}
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d0b:	f3 0f 1e fb          	endbr32 
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
  800d15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d1b:	eb 03                	jmp    800d20 <strtol+0x15>
		s++;
  800d1d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d20:	0f b6 01             	movzbl (%ecx),%eax
  800d23:	3c 20                	cmp    $0x20,%al
  800d25:	74 f6                	je     800d1d <strtol+0x12>
  800d27:	3c 09                	cmp    $0x9,%al
  800d29:	74 f2                	je     800d1d <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d2b:	3c 2b                	cmp    $0x2b,%al
  800d2d:	74 2a                	je     800d59 <strtol+0x4e>
	int neg = 0;
  800d2f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d34:	3c 2d                	cmp    $0x2d,%al
  800d36:	74 2b                	je     800d63 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d38:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d3e:	75 0f                	jne    800d4f <strtol+0x44>
  800d40:	80 39 30             	cmpb   $0x30,(%ecx)
  800d43:	74 28                	je     800d6d <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d45:	85 db                	test   %ebx,%ebx
  800d47:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d4c:	0f 44 d8             	cmove  %eax,%ebx
  800d4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d54:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d57:	eb 46                	jmp    800d9f <strtol+0x94>
		s++;
  800d59:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d5c:	bf 00 00 00 00       	mov    $0x0,%edi
  800d61:	eb d5                	jmp    800d38 <strtol+0x2d>
		s++, neg = 1;
  800d63:	83 c1 01             	add    $0x1,%ecx
  800d66:	bf 01 00 00 00       	mov    $0x1,%edi
  800d6b:	eb cb                	jmp    800d38 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d6d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d71:	74 0e                	je     800d81 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d73:	85 db                	test   %ebx,%ebx
  800d75:	75 d8                	jne    800d4f <strtol+0x44>
		s++, base = 8;
  800d77:	83 c1 01             	add    $0x1,%ecx
  800d7a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d7f:	eb ce                	jmp    800d4f <strtol+0x44>
		s += 2, base = 16;
  800d81:	83 c1 02             	add    $0x2,%ecx
  800d84:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d89:	eb c4                	jmp    800d4f <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d8b:	0f be d2             	movsbl %dl,%edx
  800d8e:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d91:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d94:	7d 3a                	jge    800dd0 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d96:	83 c1 01             	add    $0x1,%ecx
  800d99:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d9d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d9f:	0f b6 11             	movzbl (%ecx),%edx
  800da2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800da5:	89 f3                	mov    %esi,%ebx
  800da7:	80 fb 09             	cmp    $0x9,%bl
  800daa:	76 df                	jbe    800d8b <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800dac:	8d 72 9f             	lea    -0x61(%edx),%esi
  800daf:	89 f3                	mov    %esi,%ebx
  800db1:	80 fb 19             	cmp    $0x19,%bl
  800db4:	77 08                	ja     800dbe <strtol+0xb3>
			dig = *s - 'a' + 10;
  800db6:	0f be d2             	movsbl %dl,%edx
  800db9:	83 ea 57             	sub    $0x57,%edx
  800dbc:	eb d3                	jmp    800d91 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800dbe:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dc1:	89 f3                	mov    %esi,%ebx
  800dc3:	80 fb 19             	cmp    $0x19,%bl
  800dc6:	77 08                	ja     800dd0 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dc8:	0f be d2             	movsbl %dl,%edx
  800dcb:	83 ea 37             	sub    $0x37,%edx
  800dce:	eb c1                	jmp    800d91 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dd0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dd4:	74 05                	je     800ddb <strtol+0xd0>
		*endptr = (char *) s;
  800dd6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dd9:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ddb:	89 c2                	mov    %eax,%edx
  800ddd:	f7 da                	neg    %edx
  800ddf:	85 ff                	test   %edi,%edi
  800de1:	0f 45 c2             	cmovne %edx,%eax
}
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800de9:	f3 0f 1e fb          	endbr32 
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	57                   	push   %edi
  800df1:	56                   	push   %esi
  800df2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800df3:	b8 00 00 00 00       	mov    $0x0,%eax
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfe:	89 c3                	mov    %eax,%ebx
  800e00:	89 c7                	mov    %eax,%edi
  800e02:	89 c6                	mov    %eax,%esi
  800e04:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e06:	5b                   	pop    %ebx
  800e07:	5e                   	pop    %esi
  800e08:	5f                   	pop    %edi
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <sys_cgetc>:

int
sys_cgetc(void)
{
  800e0b:	f3 0f 1e fb          	endbr32 
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	57                   	push   %edi
  800e13:	56                   	push   %esi
  800e14:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e15:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1a:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1f:	89 d1                	mov    %edx,%ecx
  800e21:	89 d3                	mov    %edx,%ebx
  800e23:	89 d7                	mov    %edx,%edi
  800e25:	89 d6                	mov    %edx,%esi
  800e27:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e29:	5b                   	pop    %ebx
  800e2a:	5e                   	pop    %esi
  800e2b:	5f                   	pop    %edi
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    

00800e2e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e2e:	f3 0f 1e fb          	endbr32 
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e40:	b8 03 00 00 00       	mov    $0x3,%eax
  800e45:	89 cb                	mov    %ecx,%ebx
  800e47:	89 cf                	mov    %ecx,%edi
  800e49:	89 ce                	mov    %ecx,%esi
  800e4b:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e4d:	5b                   	pop    %ebx
  800e4e:	5e                   	pop    %esi
  800e4f:	5f                   	pop    %edi
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    

00800e52 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e52:	f3 0f 1e fb          	endbr32 
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	57                   	push   %edi
  800e5a:	56                   	push   %esi
  800e5b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e61:	b8 02 00 00 00       	mov    $0x2,%eax
  800e66:	89 d1                	mov    %edx,%ecx
  800e68:	89 d3                	mov    %edx,%ebx
  800e6a:	89 d7                	mov    %edx,%edi
  800e6c:	89 d6                	mov    %edx,%esi
  800e6e:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <sys_yield>:

void
sys_yield(void)
{
  800e75:	f3 0f 1e fb          	endbr32 
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	57                   	push   %edi
  800e7d:	56                   	push   %esi
  800e7e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e84:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e89:	89 d1                	mov    %edx,%ecx
  800e8b:	89 d3                	mov    %edx,%ebx
  800e8d:	89 d7                	mov    %edx,%edi
  800e8f:	89 d6                	mov    %edx,%esi
  800e91:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e93:	5b                   	pop    %ebx
  800e94:	5e                   	pop    %esi
  800e95:	5f                   	pop    %edi
  800e96:	5d                   	pop    %ebp
  800e97:	c3                   	ret    

00800e98 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e98:	f3 0f 1e fb          	endbr32 
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	57                   	push   %edi
  800ea0:	56                   	push   %esi
  800ea1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ea2:	be 00 00 00 00       	mov    $0x0,%esi
  800ea7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ead:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb5:	89 f7                	mov    %esi,%edi
  800eb7:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800eb9:	5b                   	pop    %ebx
  800eba:	5e                   	pop    %esi
  800ebb:	5f                   	pop    %edi
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ebe:	f3 0f 1e fb          	endbr32 
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	57                   	push   %edi
  800ec6:	56                   	push   %esi
  800ec7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ec8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ece:	b8 05 00 00 00       	mov    $0x5,%eax
  800ed3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ed9:	8b 75 18             	mov    0x18(%ebp),%esi
  800edc:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ede:	5b                   	pop    %ebx
  800edf:	5e                   	pop    %esi
  800ee0:	5f                   	pop    %edi
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    

00800ee3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ee3:	f3 0f 1e fb          	endbr32 
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	57                   	push   %edi
  800eeb:	56                   	push   %esi
  800eec:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eed:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef8:	b8 06 00 00 00       	mov    $0x6,%eax
  800efd:	89 df                	mov    %ebx,%edi
  800eff:	89 de                	mov    %ebx,%esi
  800f01:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f03:	5b                   	pop    %ebx
  800f04:	5e                   	pop    %esi
  800f05:	5f                   	pop    %edi
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    

00800f08 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f08:	f3 0f 1e fb          	endbr32 
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	57                   	push   %edi
  800f10:	56                   	push   %esi
  800f11:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f17:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1d:	b8 08 00 00 00       	mov    $0x8,%eax
  800f22:	89 df                	mov    %ebx,%edi
  800f24:	89 de                	mov    %ebx,%esi
  800f26:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    

00800f2d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f2d:	f3 0f 1e fb          	endbr32 
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	57                   	push   %edi
  800f35:	56                   	push   %esi
  800f36:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f42:	b8 09 00 00 00       	mov    $0x9,%eax
  800f47:	89 df                	mov    %ebx,%edi
  800f49:	89 de                	mov    %ebx,%esi
  800f4b:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f4d:	5b                   	pop    %ebx
  800f4e:	5e                   	pop    %esi
  800f4f:	5f                   	pop    %edi
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    

00800f52 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f52:	f3 0f 1e fb          	endbr32 
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	57                   	push   %edi
  800f5a:	56                   	push   %esi
  800f5b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f61:	8b 55 08             	mov    0x8(%ebp),%edx
  800f64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f67:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f6c:	89 df                	mov    %ebx,%edi
  800f6e:	89 de                	mov    %ebx,%esi
  800f70:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f72:	5b                   	pop    %ebx
  800f73:	5e                   	pop    %esi
  800f74:	5f                   	pop    %edi
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    

00800f77 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f77:	f3 0f 1e fb          	endbr32 
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	57                   	push   %edi
  800f7f:	56                   	push   %esi
  800f80:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f81:	8b 55 08             	mov    0x8(%ebp),%edx
  800f84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f87:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f8c:	be 00 00 00 00       	mov    $0x0,%esi
  800f91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f94:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f97:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f99:	5b                   	pop    %ebx
  800f9a:	5e                   	pop    %esi
  800f9b:	5f                   	pop    %edi
  800f9c:	5d                   	pop    %ebp
  800f9d:	c3                   	ret    

00800f9e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f9e:	f3 0f 1e fb          	endbr32 
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	57                   	push   %edi
  800fa6:	56                   	push   %esi
  800fa7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fa8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fad:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fb5:	89 cb                	mov    %ecx,%ebx
  800fb7:	89 cf                	mov    %ecx,%edi
  800fb9:	89 ce                	mov    %ecx,%esi
  800fbb:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fbd:	5b                   	pop    %ebx
  800fbe:	5e                   	pop    %esi
  800fbf:	5f                   	pop    %edi
  800fc0:	5d                   	pop    %ebp
  800fc1:	c3                   	ret    

00800fc2 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800fc2:	f3 0f 1e fb          	endbr32 
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	57                   	push   %edi
  800fca:	56                   	push   %esi
  800fcb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fcc:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd1:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fd6:	89 d1                	mov    %edx,%ecx
  800fd8:	89 d3                	mov    %edx,%ebx
  800fda:	89 d7                	mov    %edx,%edi
  800fdc:	89 d6                	mov    %edx,%esi
  800fde:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800fe0:	5b                   	pop    %ebx
  800fe1:	5e                   	pop    %esi
  800fe2:	5f                   	pop    %edi
  800fe3:	5d                   	pop    %ebp
  800fe4:	c3                   	ret    

00800fe5 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800fe5:	f3 0f 1e fb          	endbr32 
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	57                   	push   %edi
  800fed:	56                   	push   %esi
  800fee:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fef:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffa:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fff:	89 df                	mov    %ebx,%edi
  801001:	89 de                	mov    %ebx,%esi
  801003:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  801005:	5b                   	pop    %ebx
  801006:	5e                   	pop    %esi
  801007:	5f                   	pop    %edi
  801008:	5d                   	pop    %ebp
  801009:	c3                   	ret    

0080100a <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  80100a:	f3 0f 1e fb          	endbr32 
  80100e:	55                   	push   %ebp
  80100f:	89 e5                	mov    %esp,%ebp
  801011:	57                   	push   %edi
  801012:	56                   	push   %esi
  801013:	53                   	push   %ebx
	asm volatile("int %1\n"
  801014:	bb 00 00 00 00       	mov    $0x0,%ebx
  801019:	8b 55 08             	mov    0x8(%ebp),%edx
  80101c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101f:	b8 10 00 00 00       	mov    $0x10,%eax
  801024:	89 df                	mov    %ebx,%edi
  801026:	89 de                	mov    %ebx,%esi
  801028:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  80102a:	5b                   	pop    %ebx
  80102b:	5e                   	pop    %esi
  80102c:	5f                   	pop    %edi
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    

0080102f <pgfault>:
// map in our own private writable copy.
//
extern int cnt;
static void
pgfault(struct UTrapframe *utf)
{
  80102f:	f3 0f 1e fb          	endbr32 
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	53                   	push   %ebx
  801037:	83 ec 04             	sub    $0x4,%esp
  80103a:	8b 45 08             	mov    0x8(%ebp),%eax
	// cprintf("[%08x] called pgfault\n", sys_getenvid());
	void *addr = (void *) utf->utf_fault_va;
  80103d:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err&FEC_WR)&&(uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_COW))){
  80103f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801043:	0f 84 9a 00 00 00    	je     8010e3 <pgfault+0xb4>
  801049:	89 d8                	mov    %ebx,%eax
  80104b:	c1 e8 16             	shr    $0x16,%eax
  80104e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801055:	a8 01                	test   $0x1,%al
  801057:	0f 84 86 00 00 00    	je     8010e3 <pgfault+0xb4>
  80105d:	89 d8                	mov    %ebx,%eax
  80105f:	c1 e8 0c             	shr    $0xc,%eax
  801062:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801069:	f6 c2 01             	test   $0x1,%dl
  80106c:	74 75                	je     8010e3 <pgfault+0xb4>
  80106e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801075:	f6 c4 08             	test   $0x8,%ah
  801078:	74 69                	je     8010e3 <pgfault+0xb4>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 在PFTEMP这里给一个物理地址的mapping 相当于store一个物理地址
	if((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W))<0){
  80107a:	83 ec 04             	sub    $0x4,%esp
  80107d:	6a 07                	push   $0x7
  80107f:	68 00 f0 7f 00       	push   $0x7ff000
  801084:	6a 00                	push   $0x0
  801086:	e8 0d fe ff ff       	call   800e98 <sys_page_alloc>
  80108b:	83 c4 10             	add    $0x10,%esp
  80108e:	85 c0                	test   %eax,%eax
  801090:	78 63                	js     8010f5 <pgfault+0xc6>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  801092:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// 先复制addr里的content
	memcpy((void*)PFTEMP, addr, PGSIZE);
  801098:	83 ec 04             	sub    $0x4,%esp
  80109b:	68 00 10 00 00       	push   $0x1000
  8010a0:	53                   	push   %ebx
  8010a1:	68 00 f0 7f 00       	push   $0x7ff000
  8010a6:	e8 e8 fb ff ff       	call   800c93 <memcpy>
	// 在remap addr到PFTEMP位置 即addr与PFTEMP指向同一个物理内存
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))<0){
  8010ab:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8010b2:	53                   	push   %ebx
  8010b3:	6a 00                	push   $0x0
  8010b5:	68 00 f0 7f 00       	push   $0x7ff000
  8010ba:	6a 00                	push   $0x0
  8010bc:	e8 fd fd ff ff       	call   800ebe <sys_page_map>
  8010c1:	83 c4 20             	add    $0x20,%esp
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	78 3f                	js     801107 <pgfault+0xd8>
		panic("pgfault: sys_page_map failed due to %e\n", r);
	}
	if ((r = sys_page_unmap(0, (void*)PFTEMP))<0){
  8010c8:	83 ec 08             	sub    $0x8,%esp
  8010cb:	68 00 f0 7f 00       	push   $0x7ff000
  8010d0:	6a 00                	push   $0x0
  8010d2:	e8 0c fe ff ff       	call   800ee3 <sys_page_unmap>
  8010d7:	83 c4 10             	add    $0x10,%esp
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	78 3b                	js     801119 <pgfault+0xea>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
	}
	
	
}
  8010de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e1:	c9                   	leave  
  8010e2:	c3                   	ret    
		panic("pgfault: page access at %08x is not a write to a copy-on-write\n", addr);
  8010e3:	53                   	push   %ebx
  8010e4:	68 e0 2d 80 00       	push   $0x802de0
  8010e9:	6a 20                	push   $0x20
  8010eb:	68 9e 2e 80 00       	push   $0x802e9e
  8010f0:	e8 49 f2 ff ff       	call   80033e <_panic>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
  8010f5:	50                   	push   %eax
  8010f6:	68 20 2e 80 00       	push   $0x802e20
  8010fb:	6a 2c                	push   $0x2c
  8010fd:	68 9e 2e 80 00       	push   $0x802e9e
  801102:	e8 37 f2 ff ff       	call   80033e <_panic>
		panic("pgfault: sys_page_map failed due to %e\n", r);
  801107:	50                   	push   %eax
  801108:	68 4c 2e 80 00       	push   $0x802e4c
  80110d:	6a 33                	push   $0x33
  80110f:	68 9e 2e 80 00       	push   $0x802e9e
  801114:	e8 25 f2 ff ff       	call   80033e <_panic>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
  801119:	50                   	push   %eax
  80111a:	68 74 2e 80 00       	push   $0x802e74
  80111f:	6a 36                	push   $0x36
  801121:	68 9e 2e 80 00       	push   $0x802e9e
  801126:	e8 13 f2 ff ff       	call   80033e <_panic>

0080112b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80112b:	f3 0f 1e fb          	endbr32 
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	57                   	push   %edi
  801133:	56                   	push   %esi
  801134:	53                   	push   %ebx
  801135:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[%08x] called fork\n", sys_getenvid());
	int r; uintptr_t addr;
	set_pgfault_handler(pgfault);
  801138:	68 2f 10 80 00       	push   $0x80102f
  80113d:	e8 d5 13 00 00       	call   802517 <set_pgfault_handler>
*/
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801142:	b8 07 00 00 00       	mov    $0x7,%eax
  801147:	cd 30                	int    $0x30
  801149:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();
		
	if (envid<0){
  80114c:	83 c4 10             	add    $0x10,%esp
  80114f:	85 c0                	test   %eax,%eax
  801151:	78 29                	js     80117c <fork+0x51>
  801153:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	// duplicate parent address space
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  801155:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid==0){
  80115a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80115e:	75 60                	jne    8011c0 <fork+0x95>
		thisenv = &envs[ENVX(sys_getenvid())];
  801160:	e8 ed fc ff ff       	call   800e52 <sys_getenvid>
  801165:	25 ff 03 00 00       	and    $0x3ff,%eax
  80116a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80116d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801172:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  801177:	e9 14 01 00 00       	jmp    801290 <fork+0x165>
		panic("fork: sys_exofork error %e\n", envid);
  80117c:	50                   	push   %eax
  80117d:	68 a9 2e 80 00       	push   $0x802ea9
  801182:	68 90 00 00 00       	push   $0x90
  801187:	68 9e 2e 80 00       	push   $0x802e9e
  80118c:	e8 ad f1 ff ff       	call   80033e <_panic>
		r = sys_page_map(0, addr, envid, addr, (uvpt[pn]&PTE_SYSCALL));
  801191:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801198:	83 ec 0c             	sub    $0xc,%esp
  80119b:	25 07 0e 00 00       	and    $0xe07,%eax
  8011a0:	50                   	push   %eax
  8011a1:	56                   	push   %esi
  8011a2:	57                   	push   %edi
  8011a3:	56                   	push   %esi
  8011a4:	6a 00                	push   $0x0
  8011a6:	e8 13 fd ff ff       	call   800ebe <sys_page_map>
  8011ab:	83 c4 20             	add    $0x20,%esp
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  8011ae:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011b4:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011ba:	0f 84 95 00 00 00    	je     801255 <fork+0x12a>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  8011c0:	89 d8                	mov    %ebx,%eax
  8011c2:	c1 e8 16             	shr    $0x16,%eax
  8011c5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011cc:	a8 01                	test   $0x1,%al
  8011ce:	74 de                	je     8011ae <fork+0x83>
  8011d0:	89 d8                	mov    %ebx,%eax
  8011d2:	c1 e8 0c             	shr    $0xc,%eax
  8011d5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011dc:	f6 c2 01             	test   $0x1,%dl
  8011df:	74 cd                	je     8011ae <fork+0x83>
	void* addr = (void*)(pn*PGSIZE);
  8011e1:	89 c6                	mov    %eax,%esi
  8011e3:	c1 e6 0c             	shl    $0xc,%esi
	if (uvpt[pn]&PTE_SHARE){
  8011e6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011ed:	f6 c6 04             	test   $0x4,%dh
  8011f0:	75 9f                	jne    801191 <fork+0x66>
		if (uvpt[pn]&PTE_W||uvpt[pn]&PTE_COW){
  8011f2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011f9:	f6 c2 02             	test   $0x2,%dl
  8011fc:	75 0c                	jne    80120a <fork+0xdf>
  8011fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801205:	f6 c4 08             	test   $0x8,%ah
  801208:	74 34                	je     80123e <fork+0x113>
			r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P); // not writable
  80120a:	83 ec 0c             	sub    $0xc,%esp
  80120d:	68 05 08 00 00       	push   $0x805
  801212:	56                   	push   %esi
  801213:	57                   	push   %edi
  801214:	56                   	push   %esi
  801215:	6a 00                	push   $0x0
  801217:	e8 a2 fc ff ff       	call   800ebe <sys_page_map>
			if (r<0) return r;
  80121c:	83 c4 20             	add    $0x20,%esp
  80121f:	85 c0                	test   %eax,%eax
  801221:	78 8b                	js     8011ae <fork+0x83>
			r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P); // not writable
  801223:	83 ec 0c             	sub    $0xc,%esp
  801226:	68 05 08 00 00       	push   $0x805
  80122b:	56                   	push   %esi
  80122c:	6a 00                	push   $0x0
  80122e:	56                   	push   %esi
  80122f:	6a 00                	push   $0x0
  801231:	e8 88 fc ff ff       	call   800ebe <sys_page_map>
  801236:	83 c4 20             	add    $0x20,%esp
  801239:	e9 70 ff ff ff       	jmp    8011ae <fork+0x83>
			if ((r=sys_page_map(0, addr, envid, addr, PTE_P|PTE_U)<0))// read only
  80123e:	83 ec 0c             	sub    $0xc,%esp
  801241:	6a 05                	push   $0x5
  801243:	56                   	push   %esi
  801244:	57                   	push   %edi
  801245:	56                   	push   %esi
  801246:	6a 00                	push   $0x0
  801248:	e8 71 fc ff ff       	call   800ebe <sys_page_map>
  80124d:	83 c4 20             	add    $0x20,%esp
  801250:	e9 59 ff ff ff       	jmp    8011ae <fork+0x83>
			duppage(envid, PGNUM(addr));
		}
	}
	// allocate user exception stack
	// cprintf("alloc user expection stack\n");
	if ((r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_W|PTE_U))<0)
  801255:	83 ec 04             	sub    $0x4,%esp
  801258:	6a 07                	push   $0x7
  80125a:	68 00 f0 bf ee       	push   $0xeebff000
  80125f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801262:	56                   	push   %esi
  801263:	e8 30 fc ff ff       	call   800e98 <sys_page_alloc>
  801268:	83 c4 10             	add    $0x10,%esp
  80126b:	85 c0                	test   %eax,%eax
  80126d:	78 2b                	js     80129a <fork+0x16f>
		return r;
	
	extern void* _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80126f:	83 ec 08             	sub    $0x8,%esp
  801272:	68 8a 25 80 00       	push   $0x80258a
  801277:	56                   	push   %esi
  801278:	e8 d5 fc ff ff       	call   800f52 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE))<0)
  80127d:	83 c4 08             	add    $0x8,%esp
  801280:	6a 02                	push   $0x2
  801282:	56                   	push   %esi
  801283:	e8 80 fc ff ff       	call   800f08 <sys_env_set_status>
  801288:	83 c4 10             	add    $0x10,%esp
		return r;
  80128b:	85 c0                	test   %eax,%eax
  80128d:	0f 48 f8             	cmovs  %eax,%edi

	return envid;
	
}
  801290:	89 f8                	mov    %edi,%eax
  801292:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801295:	5b                   	pop    %ebx
  801296:	5e                   	pop    %esi
  801297:	5f                   	pop    %edi
  801298:	5d                   	pop    %ebp
  801299:	c3                   	ret    
		return r;
  80129a:	89 c7                	mov    %eax,%edi
  80129c:	eb f2                	jmp    801290 <fork+0x165>

0080129e <sfork>:

// Challenge(not sure yet)
int
sfork(void)
{
  80129e:	f3 0f 1e fb          	endbr32 
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8012a8:	68 c5 2e 80 00       	push   $0x802ec5
  8012ad:	68 b2 00 00 00       	push   $0xb2
  8012b2:	68 9e 2e 80 00       	push   $0x802e9e
  8012b7:	e8 82 f0 ff ff       	call   80033e <_panic>

008012bc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012bc:	f3 0f 1e fb          	endbr32 
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8012cb:	c1 e8 0c             	shr    $0xc,%eax
}
  8012ce:	5d                   	pop    %ebp
  8012cf:	c3                   	ret    

008012d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012d0:	f3 0f 1e fb          	endbr32 
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012da:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8012df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012e4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012e9:	5d                   	pop    %ebp
  8012ea:	c3                   	ret    

008012eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012eb:	f3 0f 1e fb          	endbr32 
  8012ef:	55                   	push   %ebp
  8012f0:	89 e5                	mov    %esp,%ebp
  8012f2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012f7:	89 c2                	mov    %eax,%edx
  8012f9:	c1 ea 16             	shr    $0x16,%edx
  8012fc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801303:	f6 c2 01             	test   $0x1,%dl
  801306:	74 2d                	je     801335 <fd_alloc+0x4a>
  801308:	89 c2                	mov    %eax,%edx
  80130a:	c1 ea 0c             	shr    $0xc,%edx
  80130d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801314:	f6 c2 01             	test   $0x1,%dl
  801317:	74 1c                	je     801335 <fd_alloc+0x4a>
  801319:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80131e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801323:	75 d2                	jne    8012f7 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  801325:	8b 45 08             	mov    0x8(%ebp),%eax
  801328:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80132e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801333:	eb 0a                	jmp    80133f <fd_alloc+0x54>
			*fd_store = fd;
  801335:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801338:	89 01                	mov    %eax,(%ecx)
			return 0;
  80133a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80133f:	5d                   	pop    %ebp
  801340:	c3                   	ret    

00801341 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801341:	f3 0f 1e fb          	endbr32 
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80134b:	83 f8 1f             	cmp    $0x1f,%eax
  80134e:	77 30                	ja     801380 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801350:	c1 e0 0c             	shl    $0xc,%eax
  801353:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801358:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80135e:	f6 c2 01             	test   $0x1,%dl
  801361:	74 24                	je     801387 <fd_lookup+0x46>
  801363:	89 c2                	mov    %eax,%edx
  801365:	c1 ea 0c             	shr    $0xc,%edx
  801368:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80136f:	f6 c2 01             	test   $0x1,%dl
  801372:	74 1a                	je     80138e <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801374:	8b 55 0c             	mov    0xc(%ebp),%edx
  801377:	89 02                	mov    %eax,(%edx)
	return 0;
  801379:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80137e:	5d                   	pop    %ebp
  80137f:	c3                   	ret    
		return -E_INVAL;
  801380:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801385:	eb f7                	jmp    80137e <fd_lookup+0x3d>
		return -E_INVAL;
  801387:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80138c:	eb f0                	jmp    80137e <fd_lookup+0x3d>
  80138e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801393:	eb e9                	jmp    80137e <fd_lookup+0x3d>

00801395 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801395:	f3 0f 1e fb          	endbr32 
  801399:	55                   	push   %ebp
  80139a:	89 e5                	mov    %esp,%ebp
  80139c:	83 ec 08             	sub    $0x8,%esp
  80139f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8013a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a7:	b8 20 40 80 00       	mov    $0x804020,%eax
		if (devtab[i]->dev_id == dev_id) {
  8013ac:	39 08                	cmp    %ecx,(%eax)
  8013ae:	74 38                	je     8013e8 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8013b0:	83 c2 01             	add    $0x1,%edx
  8013b3:	8b 04 95 58 2f 80 00 	mov    0x802f58(,%edx,4),%eax
  8013ba:	85 c0                	test   %eax,%eax
  8013bc:	75 ee                	jne    8013ac <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013be:	a1 08 50 80 00       	mov    0x805008,%eax
  8013c3:	8b 40 48             	mov    0x48(%eax),%eax
  8013c6:	83 ec 04             	sub    $0x4,%esp
  8013c9:	51                   	push   %ecx
  8013ca:	50                   	push   %eax
  8013cb:	68 dc 2e 80 00       	push   $0x802edc
  8013d0:	e8 50 f0 ff ff       	call   800425 <cprintf>
	*dev = 0;
  8013d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013de:	83 c4 10             	add    $0x10,%esp
  8013e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013e6:	c9                   	leave  
  8013e7:	c3                   	ret    
			*dev = devtab[i];
  8013e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013eb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f2:	eb f2                	jmp    8013e6 <dev_lookup+0x51>

008013f4 <fd_close>:
{
  8013f4:	f3 0f 1e fb          	endbr32 
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	57                   	push   %edi
  8013fc:	56                   	push   %esi
  8013fd:	53                   	push   %ebx
  8013fe:	83 ec 24             	sub    $0x24,%esp
  801401:	8b 75 08             	mov    0x8(%ebp),%esi
  801404:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801407:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80140a:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80140b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801411:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801414:	50                   	push   %eax
  801415:	e8 27 ff ff ff       	call   801341 <fd_lookup>
  80141a:	89 c3                	mov    %eax,%ebx
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	85 c0                	test   %eax,%eax
  801421:	78 05                	js     801428 <fd_close+0x34>
	    || fd != fd2)
  801423:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801426:	74 16                	je     80143e <fd_close+0x4a>
		return (must_exist ? r : 0);
  801428:	89 f8                	mov    %edi,%eax
  80142a:	84 c0                	test   %al,%al
  80142c:	b8 00 00 00 00       	mov    $0x0,%eax
  801431:	0f 44 d8             	cmove  %eax,%ebx
}
  801434:	89 d8                	mov    %ebx,%eax
  801436:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801439:	5b                   	pop    %ebx
  80143a:	5e                   	pop    %esi
  80143b:	5f                   	pop    %edi
  80143c:	5d                   	pop    %ebp
  80143d:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80143e:	83 ec 08             	sub    $0x8,%esp
  801441:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801444:	50                   	push   %eax
  801445:	ff 36                	pushl  (%esi)
  801447:	e8 49 ff ff ff       	call   801395 <dev_lookup>
  80144c:	89 c3                	mov    %eax,%ebx
  80144e:	83 c4 10             	add    $0x10,%esp
  801451:	85 c0                	test   %eax,%eax
  801453:	78 1a                	js     80146f <fd_close+0x7b>
		if (dev->dev_close)
  801455:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801458:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80145b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801460:	85 c0                	test   %eax,%eax
  801462:	74 0b                	je     80146f <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801464:	83 ec 0c             	sub    $0xc,%esp
  801467:	56                   	push   %esi
  801468:	ff d0                	call   *%eax
  80146a:	89 c3                	mov    %eax,%ebx
  80146c:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80146f:	83 ec 08             	sub    $0x8,%esp
  801472:	56                   	push   %esi
  801473:	6a 00                	push   $0x0
  801475:	e8 69 fa ff ff       	call   800ee3 <sys_page_unmap>
	return r;
  80147a:	83 c4 10             	add    $0x10,%esp
  80147d:	eb b5                	jmp    801434 <fd_close+0x40>

0080147f <close>:

int
close(int fdnum)
{
  80147f:	f3 0f 1e fb          	endbr32 
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
  801486:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801489:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148c:	50                   	push   %eax
  80148d:	ff 75 08             	pushl  0x8(%ebp)
  801490:	e8 ac fe ff ff       	call   801341 <fd_lookup>
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	85 c0                	test   %eax,%eax
  80149a:	79 02                	jns    80149e <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  80149c:	c9                   	leave  
  80149d:	c3                   	ret    
		return fd_close(fd, 1);
  80149e:	83 ec 08             	sub    $0x8,%esp
  8014a1:	6a 01                	push   $0x1
  8014a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a6:	e8 49 ff ff ff       	call   8013f4 <fd_close>
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	eb ec                	jmp    80149c <close+0x1d>

008014b0 <close_all>:

void
close_all(void)
{
  8014b0:	f3 0f 1e fb          	endbr32 
  8014b4:	55                   	push   %ebp
  8014b5:	89 e5                	mov    %esp,%ebp
  8014b7:	53                   	push   %ebx
  8014b8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014bb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014c0:	83 ec 0c             	sub    $0xc,%esp
  8014c3:	53                   	push   %ebx
  8014c4:	e8 b6 ff ff ff       	call   80147f <close>
	for (i = 0; i < MAXFD; i++)
  8014c9:	83 c3 01             	add    $0x1,%ebx
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	83 fb 20             	cmp    $0x20,%ebx
  8014d2:	75 ec                	jne    8014c0 <close_all+0x10>
}
  8014d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d7:	c9                   	leave  
  8014d8:	c3                   	ret    

008014d9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014d9:	f3 0f 1e fb          	endbr32 
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	57                   	push   %edi
  8014e1:	56                   	push   %esi
  8014e2:	53                   	push   %ebx
  8014e3:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014e6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014e9:	50                   	push   %eax
  8014ea:	ff 75 08             	pushl  0x8(%ebp)
  8014ed:	e8 4f fe ff ff       	call   801341 <fd_lookup>
  8014f2:	89 c3                	mov    %eax,%ebx
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	0f 88 81 00 00 00    	js     801580 <dup+0xa7>
		return r;
	close(newfdnum);
  8014ff:	83 ec 0c             	sub    $0xc,%esp
  801502:	ff 75 0c             	pushl  0xc(%ebp)
  801505:	e8 75 ff ff ff       	call   80147f <close>

	newfd = INDEX2FD(newfdnum);
  80150a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80150d:	c1 e6 0c             	shl    $0xc,%esi
  801510:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801516:	83 c4 04             	add    $0x4,%esp
  801519:	ff 75 e4             	pushl  -0x1c(%ebp)
  80151c:	e8 af fd ff ff       	call   8012d0 <fd2data>
  801521:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801523:	89 34 24             	mov    %esi,(%esp)
  801526:	e8 a5 fd ff ff       	call   8012d0 <fd2data>
  80152b:	83 c4 10             	add    $0x10,%esp
  80152e:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801530:	89 d8                	mov    %ebx,%eax
  801532:	c1 e8 16             	shr    $0x16,%eax
  801535:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80153c:	a8 01                	test   $0x1,%al
  80153e:	74 11                	je     801551 <dup+0x78>
  801540:	89 d8                	mov    %ebx,%eax
  801542:	c1 e8 0c             	shr    $0xc,%eax
  801545:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80154c:	f6 c2 01             	test   $0x1,%dl
  80154f:	75 39                	jne    80158a <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801551:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801554:	89 d0                	mov    %edx,%eax
  801556:	c1 e8 0c             	shr    $0xc,%eax
  801559:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801560:	83 ec 0c             	sub    $0xc,%esp
  801563:	25 07 0e 00 00       	and    $0xe07,%eax
  801568:	50                   	push   %eax
  801569:	56                   	push   %esi
  80156a:	6a 00                	push   $0x0
  80156c:	52                   	push   %edx
  80156d:	6a 00                	push   $0x0
  80156f:	e8 4a f9 ff ff       	call   800ebe <sys_page_map>
  801574:	89 c3                	mov    %eax,%ebx
  801576:	83 c4 20             	add    $0x20,%esp
  801579:	85 c0                	test   %eax,%eax
  80157b:	78 31                	js     8015ae <dup+0xd5>
		goto err;

	return newfdnum;
  80157d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801580:	89 d8                	mov    %ebx,%eax
  801582:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801585:	5b                   	pop    %ebx
  801586:	5e                   	pop    %esi
  801587:	5f                   	pop    %edi
  801588:	5d                   	pop    %ebp
  801589:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80158a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801591:	83 ec 0c             	sub    $0xc,%esp
  801594:	25 07 0e 00 00       	and    $0xe07,%eax
  801599:	50                   	push   %eax
  80159a:	57                   	push   %edi
  80159b:	6a 00                	push   $0x0
  80159d:	53                   	push   %ebx
  80159e:	6a 00                	push   $0x0
  8015a0:	e8 19 f9 ff ff       	call   800ebe <sys_page_map>
  8015a5:	89 c3                	mov    %eax,%ebx
  8015a7:	83 c4 20             	add    $0x20,%esp
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	79 a3                	jns    801551 <dup+0x78>
	sys_page_unmap(0, newfd);
  8015ae:	83 ec 08             	sub    $0x8,%esp
  8015b1:	56                   	push   %esi
  8015b2:	6a 00                	push   $0x0
  8015b4:	e8 2a f9 ff ff       	call   800ee3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015b9:	83 c4 08             	add    $0x8,%esp
  8015bc:	57                   	push   %edi
  8015bd:	6a 00                	push   $0x0
  8015bf:	e8 1f f9 ff ff       	call   800ee3 <sys_page_unmap>
	return r;
  8015c4:	83 c4 10             	add    $0x10,%esp
  8015c7:	eb b7                	jmp    801580 <dup+0xa7>

008015c9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015c9:	f3 0f 1e fb          	endbr32 
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	53                   	push   %ebx
  8015d1:	83 ec 1c             	sub    $0x1c,%esp
  8015d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015da:	50                   	push   %eax
  8015db:	53                   	push   %ebx
  8015dc:	e8 60 fd ff ff       	call   801341 <fd_lookup>
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 3f                	js     801627 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ee:	50                   	push   %eax
  8015ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f2:	ff 30                	pushl  (%eax)
  8015f4:	e8 9c fd ff ff       	call   801395 <dev_lookup>
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	78 27                	js     801627 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801600:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801603:	8b 42 08             	mov    0x8(%edx),%eax
  801606:	83 e0 03             	and    $0x3,%eax
  801609:	83 f8 01             	cmp    $0x1,%eax
  80160c:	74 1e                	je     80162c <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80160e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801611:	8b 40 08             	mov    0x8(%eax),%eax
  801614:	85 c0                	test   %eax,%eax
  801616:	74 35                	je     80164d <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801618:	83 ec 04             	sub    $0x4,%esp
  80161b:	ff 75 10             	pushl  0x10(%ebp)
  80161e:	ff 75 0c             	pushl  0xc(%ebp)
  801621:	52                   	push   %edx
  801622:	ff d0                	call   *%eax
  801624:	83 c4 10             	add    $0x10,%esp
}
  801627:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162a:	c9                   	leave  
  80162b:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80162c:	a1 08 50 80 00       	mov    0x805008,%eax
  801631:	8b 40 48             	mov    0x48(%eax),%eax
  801634:	83 ec 04             	sub    $0x4,%esp
  801637:	53                   	push   %ebx
  801638:	50                   	push   %eax
  801639:	68 1d 2f 80 00       	push   $0x802f1d
  80163e:	e8 e2 ed ff ff       	call   800425 <cprintf>
		return -E_INVAL;
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80164b:	eb da                	jmp    801627 <read+0x5e>
		return -E_NOT_SUPP;
  80164d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801652:	eb d3                	jmp    801627 <read+0x5e>

00801654 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801654:	f3 0f 1e fb          	endbr32 
  801658:	55                   	push   %ebp
  801659:	89 e5                	mov    %esp,%ebp
  80165b:	57                   	push   %edi
  80165c:	56                   	push   %esi
  80165d:	53                   	push   %ebx
  80165e:	83 ec 0c             	sub    $0xc,%esp
  801661:	8b 7d 08             	mov    0x8(%ebp),%edi
  801664:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801667:	bb 00 00 00 00       	mov    $0x0,%ebx
  80166c:	eb 02                	jmp    801670 <readn+0x1c>
  80166e:	01 c3                	add    %eax,%ebx
  801670:	39 f3                	cmp    %esi,%ebx
  801672:	73 21                	jae    801695 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801674:	83 ec 04             	sub    $0x4,%esp
  801677:	89 f0                	mov    %esi,%eax
  801679:	29 d8                	sub    %ebx,%eax
  80167b:	50                   	push   %eax
  80167c:	89 d8                	mov    %ebx,%eax
  80167e:	03 45 0c             	add    0xc(%ebp),%eax
  801681:	50                   	push   %eax
  801682:	57                   	push   %edi
  801683:	e8 41 ff ff ff       	call   8015c9 <read>
		if (m < 0)
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	85 c0                	test   %eax,%eax
  80168d:	78 04                	js     801693 <readn+0x3f>
			return m;
		if (m == 0)
  80168f:	75 dd                	jne    80166e <readn+0x1a>
  801691:	eb 02                	jmp    801695 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801693:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801695:	89 d8                	mov    %ebx,%eax
  801697:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80169a:	5b                   	pop    %ebx
  80169b:	5e                   	pop    %esi
  80169c:	5f                   	pop    %edi
  80169d:	5d                   	pop    %ebp
  80169e:	c3                   	ret    

0080169f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80169f:	f3 0f 1e fb          	endbr32 
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	53                   	push   %ebx
  8016a7:	83 ec 1c             	sub    $0x1c,%esp
  8016aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b0:	50                   	push   %eax
  8016b1:	53                   	push   %ebx
  8016b2:	e8 8a fc ff ff       	call   801341 <fd_lookup>
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	78 3a                	js     8016f8 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016be:	83 ec 08             	sub    $0x8,%esp
  8016c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c4:	50                   	push   %eax
  8016c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c8:	ff 30                	pushl  (%eax)
  8016ca:	e8 c6 fc ff ff       	call   801395 <dev_lookup>
  8016cf:	83 c4 10             	add    $0x10,%esp
  8016d2:	85 c0                	test   %eax,%eax
  8016d4:	78 22                	js     8016f8 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016dd:	74 1e                	je     8016fd <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e2:	8b 52 0c             	mov    0xc(%edx),%edx
  8016e5:	85 d2                	test   %edx,%edx
  8016e7:	74 35                	je     80171e <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016e9:	83 ec 04             	sub    $0x4,%esp
  8016ec:	ff 75 10             	pushl  0x10(%ebp)
  8016ef:	ff 75 0c             	pushl  0xc(%ebp)
  8016f2:	50                   	push   %eax
  8016f3:	ff d2                	call   *%edx
  8016f5:	83 c4 10             	add    $0x10,%esp
}
  8016f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fb:	c9                   	leave  
  8016fc:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016fd:	a1 08 50 80 00       	mov    0x805008,%eax
  801702:	8b 40 48             	mov    0x48(%eax),%eax
  801705:	83 ec 04             	sub    $0x4,%esp
  801708:	53                   	push   %ebx
  801709:	50                   	push   %eax
  80170a:	68 39 2f 80 00       	push   $0x802f39
  80170f:	e8 11 ed ff ff       	call   800425 <cprintf>
		return -E_INVAL;
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80171c:	eb da                	jmp    8016f8 <write+0x59>
		return -E_NOT_SUPP;
  80171e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801723:	eb d3                	jmp    8016f8 <write+0x59>

00801725 <seek>:

int
seek(int fdnum, off_t offset)
{
  801725:	f3 0f 1e fb          	endbr32 
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80172f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801732:	50                   	push   %eax
  801733:	ff 75 08             	pushl  0x8(%ebp)
  801736:	e8 06 fc ff ff       	call   801341 <fd_lookup>
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	85 c0                	test   %eax,%eax
  801740:	78 0e                	js     801750 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801742:	8b 55 0c             	mov    0xc(%ebp),%edx
  801745:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801748:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80174b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801750:	c9                   	leave  
  801751:	c3                   	ret    

00801752 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801752:	f3 0f 1e fb          	endbr32 
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	53                   	push   %ebx
  80175a:	83 ec 1c             	sub    $0x1c,%esp
  80175d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801760:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801763:	50                   	push   %eax
  801764:	53                   	push   %ebx
  801765:	e8 d7 fb ff ff       	call   801341 <fd_lookup>
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	85 c0                	test   %eax,%eax
  80176f:	78 37                	js     8017a8 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801771:	83 ec 08             	sub    $0x8,%esp
  801774:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801777:	50                   	push   %eax
  801778:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177b:	ff 30                	pushl  (%eax)
  80177d:	e8 13 fc ff ff       	call   801395 <dev_lookup>
  801782:	83 c4 10             	add    $0x10,%esp
  801785:	85 c0                	test   %eax,%eax
  801787:	78 1f                	js     8017a8 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801789:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801790:	74 1b                	je     8017ad <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801792:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801795:	8b 52 18             	mov    0x18(%edx),%edx
  801798:	85 d2                	test   %edx,%edx
  80179a:	74 32                	je     8017ce <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80179c:	83 ec 08             	sub    $0x8,%esp
  80179f:	ff 75 0c             	pushl  0xc(%ebp)
  8017a2:	50                   	push   %eax
  8017a3:	ff d2                	call   *%edx
  8017a5:	83 c4 10             	add    $0x10,%esp
}
  8017a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ab:	c9                   	leave  
  8017ac:	c3                   	ret    
			thisenv->env_id, fdnum);
  8017ad:	a1 08 50 80 00       	mov    0x805008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017b2:	8b 40 48             	mov    0x48(%eax),%eax
  8017b5:	83 ec 04             	sub    $0x4,%esp
  8017b8:	53                   	push   %ebx
  8017b9:	50                   	push   %eax
  8017ba:	68 fc 2e 80 00       	push   $0x802efc
  8017bf:	e8 61 ec ff ff       	call   800425 <cprintf>
		return -E_INVAL;
  8017c4:	83 c4 10             	add    $0x10,%esp
  8017c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017cc:	eb da                	jmp    8017a8 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8017ce:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017d3:	eb d3                	jmp    8017a8 <ftruncate+0x56>

008017d5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017d5:	f3 0f 1e fb          	endbr32 
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	53                   	push   %ebx
  8017dd:	83 ec 1c             	sub    $0x1c,%esp
  8017e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e6:	50                   	push   %eax
  8017e7:	ff 75 08             	pushl  0x8(%ebp)
  8017ea:	e8 52 fb ff ff       	call   801341 <fd_lookup>
  8017ef:	83 c4 10             	add    $0x10,%esp
  8017f2:	85 c0                	test   %eax,%eax
  8017f4:	78 4b                	js     801841 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f6:	83 ec 08             	sub    $0x8,%esp
  8017f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017fc:	50                   	push   %eax
  8017fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801800:	ff 30                	pushl  (%eax)
  801802:	e8 8e fb ff ff       	call   801395 <dev_lookup>
  801807:	83 c4 10             	add    $0x10,%esp
  80180a:	85 c0                	test   %eax,%eax
  80180c:	78 33                	js     801841 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80180e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801811:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801815:	74 2f                	je     801846 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801817:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80181a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801821:	00 00 00 
	stat->st_isdir = 0;
  801824:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80182b:	00 00 00 
	stat->st_dev = dev;
  80182e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801834:	83 ec 08             	sub    $0x8,%esp
  801837:	53                   	push   %ebx
  801838:	ff 75 f0             	pushl  -0x10(%ebp)
  80183b:	ff 50 14             	call   *0x14(%eax)
  80183e:	83 c4 10             	add    $0x10,%esp
}
  801841:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801844:	c9                   	leave  
  801845:	c3                   	ret    
		return -E_NOT_SUPP;
  801846:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80184b:	eb f4                	jmp    801841 <fstat+0x6c>

0080184d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80184d:	f3 0f 1e fb          	endbr32 
  801851:	55                   	push   %ebp
  801852:	89 e5                	mov    %esp,%ebp
  801854:	56                   	push   %esi
  801855:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801856:	83 ec 08             	sub    $0x8,%esp
  801859:	6a 00                	push   $0x0
  80185b:	ff 75 08             	pushl  0x8(%ebp)
  80185e:	e8 01 02 00 00       	call   801a64 <open>
  801863:	89 c3                	mov    %eax,%ebx
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	85 c0                	test   %eax,%eax
  80186a:	78 1b                	js     801887 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80186c:	83 ec 08             	sub    $0x8,%esp
  80186f:	ff 75 0c             	pushl  0xc(%ebp)
  801872:	50                   	push   %eax
  801873:	e8 5d ff ff ff       	call   8017d5 <fstat>
  801878:	89 c6                	mov    %eax,%esi
	close(fd);
  80187a:	89 1c 24             	mov    %ebx,(%esp)
  80187d:	e8 fd fb ff ff       	call   80147f <close>
	return r;
  801882:	83 c4 10             	add    $0x10,%esp
  801885:	89 f3                	mov    %esi,%ebx
}
  801887:	89 d8                	mov    %ebx,%eax
  801889:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80188c:	5b                   	pop    %ebx
  80188d:	5e                   	pop    %esi
  80188e:	5d                   	pop    %ebp
  80188f:	c3                   	ret    

00801890 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	56                   	push   %esi
  801894:	53                   	push   %ebx
  801895:	89 c6                	mov    %eax,%esi
  801897:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801899:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8018a0:	74 27                	je     8018c9 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018a2:	6a 07                	push   $0x7
  8018a4:	68 00 60 80 00       	push   $0x806000
  8018a9:	56                   	push   %esi
  8018aa:	ff 35 00 50 80 00    	pushl  0x805000
  8018b0:	e8 66 0d 00 00       	call   80261b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018b5:	83 c4 0c             	add    $0xc,%esp
  8018b8:	6a 00                	push   $0x0
  8018ba:	53                   	push   %ebx
  8018bb:	6a 00                	push   $0x0
  8018bd:	e8 ec 0c 00 00       	call   8025ae <ipc_recv>
}
  8018c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c5:	5b                   	pop    %ebx
  8018c6:	5e                   	pop    %esi
  8018c7:	5d                   	pop    %ebp
  8018c8:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018c9:	83 ec 0c             	sub    $0xc,%esp
  8018cc:	6a 01                	push   $0x1
  8018ce:	e8 a0 0d 00 00       	call   802673 <ipc_find_env>
  8018d3:	a3 00 50 80 00       	mov    %eax,0x805000
  8018d8:	83 c4 10             	add    $0x10,%esp
  8018db:	eb c5                	jmp    8018a2 <fsipc+0x12>

008018dd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018dd:	f3 0f 1e fb          	endbr32 
  8018e1:	55                   	push   %ebp
  8018e2:	89 e5                	mov    %esp,%ebp
  8018e4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ed:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8018f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f5:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ff:	b8 02 00 00 00       	mov    $0x2,%eax
  801904:	e8 87 ff ff ff       	call   801890 <fsipc>
}
  801909:	c9                   	leave  
  80190a:	c3                   	ret    

0080190b <devfile_flush>:
{
  80190b:	f3 0f 1e fb          	endbr32 
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801915:	8b 45 08             	mov    0x8(%ebp),%eax
  801918:	8b 40 0c             	mov    0xc(%eax),%eax
  80191b:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801920:	ba 00 00 00 00       	mov    $0x0,%edx
  801925:	b8 06 00 00 00       	mov    $0x6,%eax
  80192a:	e8 61 ff ff ff       	call   801890 <fsipc>
}
  80192f:	c9                   	leave  
  801930:	c3                   	ret    

00801931 <devfile_stat>:
{
  801931:	f3 0f 1e fb          	endbr32 
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	53                   	push   %ebx
  801939:	83 ec 04             	sub    $0x4,%esp
  80193c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80193f:	8b 45 08             	mov    0x8(%ebp),%eax
  801942:	8b 40 0c             	mov    0xc(%eax),%eax
  801945:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80194a:	ba 00 00 00 00       	mov    $0x0,%edx
  80194f:	b8 05 00 00 00       	mov    $0x5,%eax
  801954:	e8 37 ff ff ff       	call   801890 <fsipc>
  801959:	85 c0                	test   %eax,%eax
  80195b:	78 2c                	js     801989 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80195d:	83 ec 08             	sub    $0x8,%esp
  801960:	68 00 60 80 00       	push   $0x806000
  801965:	53                   	push   %ebx
  801966:	e8 c4 f0 ff ff       	call   800a2f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80196b:	a1 80 60 80 00       	mov    0x806080,%eax
  801970:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801976:	a1 84 60 80 00       	mov    0x806084,%eax
  80197b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801989:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198c:	c9                   	leave  
  80198d:	c3                   	ret    

0080198e <devfile_write>:
{
  80198e:	f3 0f 1e fb          	endbr32 
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	83 ec 0c             	sub    $0xc,%esp
  801998:	8b 45 10             	mov    0x10(%ebp),%eax
  80199b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019a0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8019a5:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8019ab:	8b 52 0c             	mov    0xc(%edx),%edx
  8019ae:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  8019b4:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8019b9:	50                   	push   %eax
  8019ba:	ff 75 0c             	pushl  0xc(%ebp)
  8019bd:	68 08 60 80 00       	push   $0x806008
  8019c2:	e8 66 f2 ff ff       	call   800c2d <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8019c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cc:	b8 04 00 00 00       	mov    $0x4,%eax
  8019d1:	e8 ba fe ff ff       	call   801890 <fsipc>
}
  8019d6:	c9                   	leave  
  8019d7:	c3                   	ret    

008019d8 <devfile_read>:
{
  8019d8:	f3 0f 1e fb          	endbr32 
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	56                   	push   %esi
  8019e0:	53                   	push   %ebx
  8019e1:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ea:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8019ef:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8019ff:	e8 8c fe ff ff       	call   801890 <fsipc>
  801a04:	89 c3                	mov    %eax,%ebx
  801a06:	85 c0                	test   %eax,%eax
  801a08:	78 1f                	js     801a29 <devfile_read+0x51>
	assert(r <= n);
  801a0a:	39 f0                	cmp    %esi,%eax
  801a0c:	77 24                	ja     801a32 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801a0e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a13:	7f 36                	jg     801a4b <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a15:	83 ec 04             	sub    $0x4,%esp
  801a18:	50                   	push   %eax
  801a19:	68 00 60 80 00       	push   $0x806000
  801a1e:	ff 75 0c             	pushl  0xc(%ebp)
  801a21:	e8 07 f2 ff ff       	call   800c2d <memmove>
	return r;
  801a26:	83 c4 10             	add    $0x10,%esp
}
  801a29:	89 d8                	mov    %ebx,%eax
  801a2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a2e:	5b                   	pop    %ebx
  801a2f:	5e                   	pop    %esi
  801a30:	5d                   	pop    %ebp
  801a31:	c3                   	ret    
	assert(r <= n);
  801a32:	68 6c 2f 80 00       	push   $0x802f6c
  801a37:	68 73 2f 80 00       	push   $0x802f73
  801a3c:	68 8c 00 00 00       	push   $0x8c
  801a41:	68 88 2f 80 00       	push   $0x802f88
  801a46:	e8 f3 e8 ff ff       	call   80033e <_panic>
	assert(r <= PGSIZE);
  801a4b:	68 93 2f 80 00       	push   $0x802f93
  801a50:	68 73 2f 80 00       	push   $0x802f73
  801a55:	68 8d 00 00 00       	push   $0x8d
  801a5a:	68 88 2f 80 00       	push   $0x802f88
  801a5f:	e8 da e8 ff ff       	call   80033e <_panic>

00801a64 <open>:
{
  801a64:	f3 0f 1e fb          	endbr32 
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	56                   	push   %esi
  801a6c:	53                   	push   %ebx
  801a6d:	83 ec 1c             	sub    $0x1c,%esp
  801a70:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801a73:	56                   	push   %esi
  801a74:	e8 73 ef ff ff       	call   8009ec <strlen>
  801a79:	83 c4 10             	add    $0x10,%esp
  801a7c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a81:	7f 6c                	jg     801aef <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801a83:	83 ec 0c             	sub    $0xc,%esp
  801a86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a89:	50                   	push   %eax
  801a8a:	e8 5c f8 ff ff       	call   8012eb <fd_alloc>
  801a8f:	89 c3                	mov    %eax,%ebx
  801a91:	83 c4 10             	add    $0x10,%esp
  801a94:	85 c0                	test   %eax,%eax
  801a96:	78 3c                	js     801ad4 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801a98:	83 ec 08             	sub    $0x8,%esp
  801a9b:	56                   	push   %esi
  801a9c:	68 00 60 80 00       	push   $0x806000
  801aa1:	e8 89 ef ff ff       	call   800a2f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801aa6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa9:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801aae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ab1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ab6:	e8 d5 fd ff ff       	call   801890 <fsipc>
  801abb:	89 c3                	mov    %eax,%ebx
  801abd:	83 c4 10             	add    $0x10,%esp
  801ac0:	85 c0                	test   %eax,%eax
  801ac2:	78 19                	js     801add <open+0x79>
	return fd2num(fd);
  801ac4:	83 ec 0c             	sub    $0xc,%esp
  801ac7:	ff 75 f4             	pushl  -0xc(%ebp)
  801aca:	e8 ed f7 ff ff       	call   8012bc <fd2num>
  801acf:	89 c3                	mov    %eax,%ebx
  801ad1:	83 c4 10             	add    $0x10,%esp
}
  801ad4:	89 d8                	mov    %ebx,%eax
  801ad6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad9:	5b                   	pop    %ebx
  801ada:	5e                   	pop    %esi
  801adb:	5d                   	pop    %ebp
  801adc:	c3                   	ret    
		fd_close(fd, 0);
  801add:	83 ec 08             	sub    $0x8,%esp
  801ae0:	6a 00                	push   $0x0
  801ae2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae5:	e8 0a f9 ff ff       	call   8013f4 <fd_close>
		return r;
  801aea:	83 c4 10             	add    $0x10,%esp
  801aed:	eb e5                	jmp    801ad4 <open+0x70>
		return -E_BAD_PATH;
  801aef:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801af4:	eb de                	jmp    801ad4 <open+0x70>

00801af6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801af6:	f3 0f 1e fb          	endbr32 
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b00:	ba 00 00 00 00       	mov    $0x0,%edx
  801b05:	b8 08 00 00 00       	mov    $0x8,%eax
  801b0a:	e8 81 fd ff ff       	call   801890 <fsipc>
}
  801b0f:	c9                   	leave  
  801b10:	c3                   	ret    

00801b11 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b11:	f3 0f 1e fb          	endbr32 
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801b1b:	68 ff 2f 80 00       	push   $0x802fff
  801b20:	ff 75 0c             	pushl  0xc(%ebp)
  801b23:	e8 07 ef ff ff       	call   800a2f <strcpy>
	return 0;
}
  801b28:	b8 00 00 00 00       	mov    $0x0,%eax
  801b2d:	c9                   	leave  
  801b2e:	c3                   	ret    

00801b2f <devsock_close>:
{
  801b2f:	f3 0f 1e fb          	endbr32 
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	53                   	push   %ebx
  801b37:	83 ec 10             	sub    $0x10,%esp
  801b3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b3d:	53                   	push   %ebx
  801b3e:	e8 6d 0b 00 00       	call   8026b0 <pageref>
  801b43:	89 c2                	mov    %eax,%edx
  801b45:	83 c4 10             	add    $0x10,%esp
		return 0;
  801b48:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801b4d:	83 fa 01             	cmp    $0x1,%edx
  801b50:	74 05                	je     801b57 <devsock_close+0x28>
}
  801b52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b55:	c9                   	leave  
  801b56:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801b57:	83 ec 0c             	sub    $0xc,%esp
  801b5a:	ff 73 0c             	pushl  0xc(%ebx)
  801b5d:	e8 e3 02 00 00       	call   801e45 <nsipc_close>
  801b62:	83 c4 10             	add    $0x10,%esp
  801b65:	eb eb                	jmp    801b52 <devsock_close+0x23>

00801b67 <devsock_write>:
{
  801b67:	f3 0f 1e fb          	endbr32 
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b71:	6a 00                	push   $0x0
  801b73:	ff 75 10             	pushl  0x10(%ebp)
  801b76:	ff 75 0c             	pushl  0xc(%ebp)
  801b79:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7c:	ff 70 0c             	pushl  0xc(%eax)
  801b7f:	e8 b5 03 00 00       	call   801f39 <nsipc_send>
}
  801b84:	c9                   	leave  
  801b85:	c3                   	ret    

00801b86 <devsock_read>:
{
  801b86:	f3 0f 1e fb          	endbr32 
  801b8a:	55                   	push   %ebp
  801b8b:	89 e5                	mov    %esp,%ebp
  801b8d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b90:	6a 00                	push   $0x0
  801b92:	ff 75 10             	pushl  0x10(%ebp)
  801b95:	ff 75 0c             	pushl  0xc(%ebp)
  801b98:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9b:	ff 70 0c             	pushl  0xc(%eax)
  801b9e:	e8 1f 03 00 00       	call   801ec2 <nsipc_recv>
}
  801ba3:	c9                   	leave  
  801ba4:	c3                   	ret    

00801ba5 <fd2sockid>:
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801bab:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801bae:	52                   	push   %edx
  801baf:	50                   	push   %eax
  801bb0:	e8 8c f7 ff ff       	call   801341 <fd_lookup>
  801bb5:	83 c4 10             	add    $0x10,%esp
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	78 10                	js     801bcc <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bbf:	8b 0d 60 40 80 00    	mov    0x804060,%ecx
  801bc5:	39 08                	cmp    %ecx,(%eax)
  801bc7:	75 05                	jne    801bce <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801bc9:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801bcc:	c9                   	leave  
  801bcd:	c3                   	ret    
		return -E_NOT_SUPP;
  801bce:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801bd3:	eb f7                	jmp    801bcc <fd2sockid+0x27>

00801bd5 <alloc_sockfd>:
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	56                   	push   %esi
  801bd9:	53                   	push   %ebx
  801bda:	83 ec 1c             	sub    $0x1c,%esp
  801bdd:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801bdf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be2:	50                   	push   %eax
  801be3:	e8 03 f7 ff ff       	call   8012eb <fd_alloc>
  801be8:	89 c3                	mov    %eax,%ebx
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	85 c0                	test   %eax,%eax
  801bef:	78 43                	js     801c34 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801bf1:	83 ec 04             	sub    $0x4,%esp
  801bf4:	68 07 04 00 00       	push   $0x407
  801bf9:	ff 75 f4             	pushl  -0xc(%ebp)
  801bfc:	6a 00                	push   $0x0
  801bfe:	e8 95 f2 ff ff       	call   800e98 <sys_page_alloc>
  801c03:	89 c3                	mov    %eax,%ebx
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	85 c0                	test   %eax,%eax
  801c0a:	78 28                	js     801c34 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0f:	8b 15 60 40 80 00    	mov    0x804060,%edx
  801c15:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c21:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c24:	83 ec 0c             	sub    $0xc,%esp
  801c27:	50                   	push   %eax
  801c28:	e8 8f f6 ff ff       	call   8012bc <fd2num>
  801c2d:	89 c3                	mov    %eax,%ebx
  801c2f:	83 c4 10             	add    $0x10,%esp
  801c32:	eb 0c                	jmp    801c40 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801c34:	83 ec 0c             	sub    $0xc,%esp
  801c37:	56                   	push   %esi
  801c38:	e8 08 02 00 00       	call   801e45 <nsipc_close>
		return r;
  801c3d:	83 c4 10             	add    $0x10,%esp
}
  801c40:	89 d8                	mov    %ebx,%eax
  801c42:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c45:	5b                   	pop    %ebx
  801c46:	5e                   	pop    %esi
  801c47:	5d                   	pop    %ebp
  801c48:	c3                   	ret    

00801c49 <accept>:
{
  801c49:	f3 0f 1e fb          	endbr32 
  801c4d:	55                   	push   %ebp
  801c4e:	89 e5                	mov    %esp,%ebp
  801c50:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c53:	8b 45 08             	mov    0x8(%ebp),%eax
  801c56:	e8 4a ff ff ff       	call   801ba5 <fd2sockid>
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	78 1b                	js     801c7a <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c5f:	83 ec 04             	sub    $0x4,%esp
  801c62:	ff 75 10             	pushl  0x10(%ebp)
  801c65:	ff 75 0c             	pushl  0xc(%ebp)
  801c68:	50                   	push   %eax
  801c69:	e8 22 01 00 00       	call   801d90 <nsipc_accept>
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	85 c0                	test   %eax,%eax
  801c73:	78 05                	js     801c7a <accept+0x31>
	return alloc_sockfd(r);
  801c75:	e8 5b ff ff ff       	call   801bd5 <alloc_sockfd>
}
  801c7a:	c9                   	leave  
  801c7b:	c3                   	ret    

00801c7c <bind>:
{
  801c7c:	f3 0f 1e fb          	endbr32 
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c86:	8b 45 08             	mov    0x8(%ebp),%eax
  801c89:	e8 17 ff ff ff       	call   801ba5 <fd2sockid>
  801c8e:	85 c0                	test   %eax,%eax
  801c90:	78 12                	js     801ca4 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801c92:	83 ec 04             	sub    $0x4,%esp
  801c95:	ff 75 10             	pushl  0x10(%ebp)
  801c98:	ff 75 0c             	pushl  0xc(%ebp)
  801c9b:	50                   	push   %eax
  801c9c:	e8 45 01 00 00       	call   801de6 <nsipc_bind>
  801ca1:	83 c4 10             	add    $0x10,%esp
}
  801ca4:	c9                   	leave  
  801ca5:	c3                   	ret    

00801ca6 <shutdown>:
{
  801ca6:	f3 0f 1e fb          	endbr32 
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801cb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb3:	e8 ed fe ff ff       	call   801ba5 <fd2sockid>
  801cb8:	85 c0                	test   %eax,%eax
  801cba:	78 0f                	js     801ccb <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801cbc:	83 ec 08             	sub    $0x8,%esp
  801cbf:	ff 75 0c             	pushl  0xc(%ebp)
  801cc2:	50                   	push   %eax
  801cc3:	e8 57 01 00 00       	call   801e1f <nsipc_shutdown>
  801cc8:	83 c4 10             	add    $0x10,%esp
}
  801ccb:	c9                   	leave  
  801ccc:	c3                   	ret    

00801ccd <connect>:
{
  801ccd:	f3 0f 1e fb          	endbr32 
  801cd1:	55                   	push   %ebp
  801cd2:	89 e5                	mov    %esp,%ebp
  801cd4:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801cd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cda:	e8 c6 fe ff ff       	call   801ba5 <fd2sockid>
  801cdf:	85 c0                	test   %eax,%eax
  801ce1:	78 12                	js     801cf5 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801ce3:	83 ec 04             	sub    $0x4,%esp
  801ce6:	ff 75 10             	pushl  0x10(%ebp)
  801ce9:	ff 75 0c             	pushl  0xc(%ebp)
  801cec:	50                   	push   %eax
  801ced:	e8 71 01 00 00       	call   801e63 <nsipc_connect>
  801cf2:	83 c4 10             	add    $0x10,%esp
}
  801cf5:	c9                   	leave  
  801cf6:	c3                   	ret    

00801cf7 <listen>:
{
  801cf7:	f3 0f 1e fb          	endbr32 
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d01:	8b 45 08             	mov    0x8(%ebp),%eax
  801d04:	e8 9c fe ff ff       	call   801ba5 <fd2sockid>
  801d09:	85 c0                	test   %eax,%eax
  801d0b:	78 0f                	js     801d1c <listen+0x25>
	return nsipc_listen(r, backlog);
  801d0d:	83 ec 08             	sub    $0x8,%esp
  801d10:	ff 75 0c             	pushl  0xc(%ebp)
  801d13:	50                   	push   %eax
  801d14:	e8 83 01 00 00       	call   801e9c <nsipc_listen>
  801d19:	83 c4 10             	add    $0x10,%esp
}
  801d1c:	c9                   	leave  
  801d1d:	c3                   	ret    

00801d1e <socket>:

int
socket(int domain, int type, int protocol)
{
  801d1e:	f3 0f 1e fb          	endbr32 
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d28:	ff 75 10             	pushl  0x10(%ebp)
  801d2b:	ff 75 0c             	pushl  0xc(%ebp)
  801d2e:	ff 75 08             	pushl  0x8(%ebp)
  801d31:	e8 65 02 00 00       	call   801f9b <nsipc_socket>
  801d36:	83 c4 10             	add    $0x10,%esp
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	78 05                	js     801d42 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801d3d:	e8 93 fe ff ff       	call   801bd5 <alloc_sockfd>
}
  801d42:	c9                   	leave  
  801d43:	c3                   	ret    

00801d44 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
  801d47:	53                   	push   %ebx
  801d48:	83 ec 04             	sub    $0x4,%esp
  801d4b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d4d:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801d54:	74 26                	je     801d7c <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d56:	6a 07                	push   $0x7
  801d58:	68 00 70 80 00       	push   $0x807000
  801d5d:	53                   	push   %ebx
  801d5e:	ff 35 04 50 80 00    	pushl  0x805004
  801d64:	e8 b2 08 00 00       	call   80261b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d69:	83 c4 0c             	add    $0xc,%esp
  801d6c:	6a 00                	push   $0x0
  801d6e:	6a 00                	push   $0x0
  801d70:	6a 00                	push   $0x0
  801d72:	e8 37 08 00 00       	call   8025ae <ipc_recv>
}
  801d77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d7a:	c9                   	leave  
  801d7b:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d7c:	83 ec 0c             	sub    $0xc,%esp
  801d7f:	6a 02                	push   $0x2
  801d81:	e8 ed 08 00 00       	call   802673 <ipc_find_env>
  801d86:	a3 04 50 80 00       	mov    %eax,0x805004
  801d8b:	83 c4 10             	add    $0x10,%esp
  801d8e:	eb c6                	jmp    801d56 <nsipc+0x12>

00801d90 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d90:	f3 0f 1e fb          	endbr32 
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	56                   	push   %esi
  801d98:	53                   	push   %ebx
  801d99:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801da4:	8b 06                	mov    (%esi),%eax
  801da6:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801dab:	b8 01 00 00 00       	mov    $0x1,%eax
  801db0:	e8 8f ff ff ff       	call   801d44 <nsipc>
  801db5:	89 c3                	mov    %eax,%ebx
  801db7:	85 c0                	test   %eax,%eax
  801db9:	79 09                	jns    801dc4 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801dbb:	89 d8                	mov    %ebx,%eax
  801dbd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dc0:	5b                   	pop    %ebx
  801dc1:	5e                   	pop    %esi
  801dc2:	5d                   	pop    %ebp
  801dc3:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801dc4:	83 ec 04             	sub    $0x4,%esp
  801dc7:	ff 35 10 70 80 00    	pushl  0x807010
  801dcd:	68 00 70 80 00       	push   $0x807000
  801dd2:	ff 75 0c             	pushl  0xc(%ebp)
  801dd5:	e8 53 ee ff ff       	call   800c2d <memmove>
		*addrlen = ret->ret_addrlen;
  801dda:	a1 10 70 80 00       	mov    0x807010,%eax
  801ddf:	89 06                	mov    %eax,(%esi)
  801de1:	83 c4 10             	add    $0x10,%esp
	return r;
  801de4:	eb d5                	jmp    801dbb <nsipc_accept+0x2b>

00801de6 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801de6:	f3 0f 1e fb          	endbr32 
  801dea:	55                   	push   %ebp
  801deb:	89 e5                	mov    %esp,%ebp
  801ded:	53                   	push   %ebx
  801dee:	83 ec 08             	sub    $0x8,%esp
  801df1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801df4:	8b 45 08             	mov    0x8(%ebp),%eax
  801df7:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801dfc:	53                   	push   %ebx
  801dfd:	ff 75 0c             	pushl  0xc(%ebp)
  801e00:	68 04 70 80 00       	push   $0x807004
  801e05:	e8 23 ee ff ff       	call   800c2d <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e0a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801e10:	b8 02 00 00 00       	mov    $0x2,%eax
  801e15:	e8 2a ff ff ff       	call   801d44 <nsipc>
}
  801e1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e1d:	c9                   	leave  
  801e1e:	c3                   	ret    

00801e1f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e1f:	f3 0f 1e fb          	endbr32 
  801e23:	55                   	push   %ebp
  801e24:	89 e5                	mov    %esp,%ebp
  801e26:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e29:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801e31:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e34:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801e39:	b8 03 00 00 00       	mov    $0x3,%eax
  801e3e:	e8 01 ff ff ff       	call   801d44 <nsipc>
}
  801e43:	c9                   	leave  
  801e44:	c3                   	ret    

00801e45 <nsipc_close>:

int
nsipc_close(int s)
{
  801e45:	f3 0f 1e fb          	endbr32 
  801e49:	55                   	push   %ebp
  801e4a:	89 e5                	mov    %esp,%ebp
  801e4c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e52:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801e57:	b8 04 00 00 00       	mov    $0x4,%eax
  801e5c:	e8 e3 fe ff ff       	call   801d44 <nsipc>
}
  801e61:	c9                   	leave  
  801e62:	c3                   	ret    

00801e63 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e63:	f3 0f 1e fb          	endbr32 
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	53                   	push   %ebx
  801e6b:	83 ec 08             	sub    $0x8,%esp
  801e6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e71:	8b 45 08             	mov    0x8(%ebp),%eax
  801e74:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e79:	53                   	push   %ebx
  801e7a:	ff 75 0c             	pushl  0xc(%ebp)
  801e7d:	68 04 70 80 00       	push   $0x807004
  801e82:	e8 a6 ed ff ff       	call   800c2d <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e87:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801e8d:	b8 05 00 00 00       	mov    $0x5,%eax
  801e92:	e8 ad fe ff ff       	call   801d44 <nsipc>
}
  801e97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e9a:	c9                   	leave  
  801e9b:	c3                   	ret    

00801e9c <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e9c:	f3 0f 1e fb          	endbr32 
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
  801ea3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801eae:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb1:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801eb6:	b8 06 00 00 00       	mov    $0x6,%eax
  801ebb:	e8 84 fe ff ff       	call   801d44 <nsipc>
}
  801ec0:	c9                   	leave  
  801ec1:	c3                   	ret    

00801ec2 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ec2:	f3 0f 1e fb          	endbr32 
  801ec6:	55                   	push   %ebp
  801ec7:	89 e5                	mov    %esp,%ebp
  801ec9:	56                   	push   %esi
  801eca:	53                   	push   %ebx
  801ecb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ece:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed1:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801ed6:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801edc:	8b 45 14             	mov    0x14(%ebp),%eax
  801edf:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ee4:	b8 07 00 00 00       	mov    $0x7,%eax
  801ee9:	e8 56 fe ff ff       	call   801d44 <nsipc>
  801eee:	89 c3                	mov    %eax,%ebx
  801ef0:	85 c0                	test   %eax,%eax
  801ef2:	78 26                	js     801f1a <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801ef4:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801efa:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801eff:	0f 4e c6             	cmovle %esi,%eax
  801f02:	39 c3                	cmp    %eax,%ebx
  801f04:	7f 1d                	jg     801f23 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f06:	83 ec 04             	sub    $0x4,%esp
  801f09:	53                   	push   %ebx
  801f0a:	68 00 70 80 00       	push   $0x807000
  801f0f:	ff 75 0c             	pushl  0xc(%ebp)
  801f12:	e8 16 ed ff ff       	call   800c2d <memmove>
  801f17:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f1a:	89 d8                	mov    %ebx,%eax
  801f1c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f1f:	5b                   	pop    %ebx
  801f20:	5e                   	pop    %esi
  801f21:	5d                   	pop    %ebp
  801f22:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801f23:	68 0b 30 80 00       	push   $0x80300b
  801f28:	68 73 2f 80 00       	push   $0x802f73
  801f2d:	6a 62                	push   $0x62
  801f2f:	68 20 30 80 00       	push   $0x803020
  801f34:	e8 05 e4 ff ff       	call   80033e <_panic>

00801f39 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f39:	f3 0f 1e fb          	endbr32 
  801f3d:	55                   	push   %ebp
  801f3e:	89 e5                	mov    %esp,%ebp
  801f40:	53                   	push   %ebx
  801f41:	83 ec 04             	sub    $0x4,%esp
  801f44:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f47:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4a:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801f4f:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f55:	7f 2e                	jg     801f85 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f57:	83 ec 04             	sub    $0x4,%esp
  801f5a:	53                   	push   %ebx
  801f5b:	ff 75 0c             	pushl  0xc(%ebp)
  801f5e:	68 0c 70 80 00       	push   $0x80700c
  801f63:	e8 c5 ec ff ff       	call   800c2d <memmove>
	nsipcbuf.send.req_size = size;
  801f68:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801f6e:	8b 45 14             	mov    0x14(%ebp),%eax
  801f71:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801f76:	b8 08 00 00 00       	mov    $0x8,%eax
  801f7b:	e8 c4 fd ff ff       	call   801d44 <nsipc>
}
  801f80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f83:	c9                   	leave  
  801f84:	c3                   	ret    
	assert(size < 1600);
  801f85:	68 2c 30 80 00       	push   $0x80302c
  801f8a:	68 73 2f 80 00       	push   $0x802f73
  801f8f:	6a 6d                	push   $0x6d
  801f91:	68 20 30 80 00       	push   $0x803020
  801f96:	e8 a3 e3 ff ff       	call   80033e <_panic>

00801f9b <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f9b:	f3 0f 1e fb          	endbr32 
  801f9f:	55                   	push   %ebp
  801fa0:	89 e5                	mov    %esp,%ebp
  801fa2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801fa5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa8:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801fad:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb0:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801fb5:	8b 45 10             	mov    0x10(%ebp),%eax
  801fb8:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801fbd:	b8 09 00 00 00       	mov    $0x9,%eax
  801fc2:	e8 7d fd ff ff       	call   801d44 <nsipc>
}
  801fc7:	c9                   	leave  
  801fc8:	c3                   	ret    

00801fc9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801fc9:	f3 0f 1e fb          	endbr32 
  801fcd:	55                   	push   %ebp
  801fce:	89 e5                	mov    %esp,%ebp
  801fd0:	56                   	push   %esi
  801fd1:	53                   	push   %ebx
  801fd2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801fd5:	83 ec 0c             	sub    $0xc,%esp
  801fd8:	ff 75 08             	pushl  0x8(%ebp)
  801fdb:	e8 f0 f2 ff ff       	call   8012d0 <fd2data>
  801fe0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801fe2:	83 c4 08             	add    $0x8,%esp
  801fe5:	68 38 30 80 00       	push   $0x803038
  801fea:	53                   	push   %ebx
  801feb:	e8 3f ea ff ff       	call   800a2f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ff0:	8b 46 04             	mov    0x4(%esi),%eax
  801ff3:	2b 06                	sub    (%esi),%eax
  801ff5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ffb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802002:	00 00 00 
	stat->st_dev = &devpipe;
  802005:	c7 83 88 00 00 00 7c 	movl   $0x80407c,0x88(%ebx)
  80200c:	40 80 00 
	return 0;
}
  80200f:	b8 00 00 00 00       	mov    $0x0,%eax
  802014:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802017:	5b                   	pop    %ebx
  802018:	5e                   	pop    %esi
  802019:	5d                   	pop    %ebp
  80201a:	c3                   	ret    

0080201b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80201b:	f3 0f 1e fb          	endbr32 
  80201f:	55                   	push   %ebp
  802020:	89 e5                	mov    %esp,%ebp
  802022:	53                   	push   %ebx
  802023:	83 ec 0c             	sub    $0xc,%esp
  802026:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802029:	53                   	push   %ebx
  80202a:	6a 00                	push   $0x0
  80202c:	e8 b2 ee ff ff       	call   800ee3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802031:	89 1c 24             	mov    %ebx,(%esp)
  802034:	e8 97 f2 ff ff       	call   8012d0 <fd2data>
  802039:	83 c4 08             	add    $0x8,%esp
  80203c:	50                   	push   %eax
  80203d:	6a 00                	push   $0x0
  80203f:	e8 9f ee ff ff       	call   800ee3 <sys_page_unmap>
}
  802044:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802047:	c9                   	leave  
  802048:	c3                   	ret    

00802049 <_pipeisclosed>:
{
  802049:	55                   	push   %ebp
  80204a:	89 e5                	mov    %esp,%ebp
  80204c:	57                   	push   %edi
  80204d:	56                   	push   %esi
  80204e:	53                   	push   %ebx
  80204f:	83 ec 1c             	sub    $0x1c,%esp
  802052:	89 c7                	mov    %eax,%edi
  802054:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802056:	a1 08 50 80 00       	mov    0x805008,%eax
  80205b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80205e:	83 ec 0c             	sub    $0xc,%esp
  802061:	57                   	push   %edi
  802062:	e8 49 06 00 00       	call   8026b0 <pageref>
  802067:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80206a:	89 34 24             	mov    %esi,(%esp)
  80206d:	e8 3e 06 00 00       	call   8026b0 <pageref>
		nn = thisenv->env_runs;
  802072:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802078:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80207b:	83 c4 10             	add    $0x10,%esp
  80207e:	39 cb                	cmp    %ecx,%ebx
  802080:	74 1b                	je     80209d <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802082:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802085:	75 cf                	jne    802056 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802087:	8b 42 58             	mov    0x58(%edx),%eax
  80208a:	6a 01                	push   $0x1
  80208c:	50                   	push   %eax
  80208d:	53                   	push   %ebx
  80208e:	68 3f 30 80 00       	push   $0x80303f
  802093:	e8 8d e3 ff ff       	call   800425 <cprintf>
  802098:	83 c4 10             	add    $0x10,%esp
  80209b:	eb b9                	jmp    802056 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80209d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8020a0:	0f 94 c0             	sete   %al
  8020a3:	0f b6 c0             	movzbl %al,%eax
}
  8020a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020a9:	5b                   	pop    %ebx
  8020aa:	5e                   	pop    %esi
  8020ab:	5f                   	pop    %edi
  8020ac:	5d                   	pop    %ebp
  8020ad:	c3                   	ret    

008020ae <devpipe_write>:
{
  8020ae:	f3 0f 1e fb          	endbr32 
  8020b2:	55                   	push   %ebp
  8020b3:	89 e5                	mov    %esp,%ebp
  8020b5:	57                   	push   %edi
  8020b6:	56                   	push   %esi
  8020b7:	53                   	push   %ebx
  8020b8:	83 ec 28             	sub    $0x28,%esp
  8020bb:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8020be:	56                   	push   %esi
  8020bf:	e8 0c f2 ff ff       	call   8012d0 <fd2data>
  8020c4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8020c6:	83 c4 10             	add    $0x10,%esp
  8020c9:	bf 00 00 00 00       	mov    $0x0,%edi
  8020ce:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020d1:	74 4f                	je     802122 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020d3:	8b 43 04             	mov    0x4(%ebx),%eax
  8020d6:	8b 0b                	mov    (%ebx),%ecx
  8020d8:	8d 51 20             	lea    0x20(%ecx),%edx
  8020db:	39 d0                	cmp    %edx,%eax
  8020dd:	72 14                	jb     8020f3 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8020df:	89 da                	mov    %ebx,%edx
  8020e1:	89 f0                	mov    %esi,%eax
  8020e3:	e8 61 ff ff ff       	call   802049 <_pipeisclosed>
  8020e8:	85 c0                	test   %eax,%eax
  8020ea:	75 3b                	jne    802127 <devpipe_write+0x79>
			sys_yield();
  8020ec:	e8 84 ed ff ff       	call   800e75 <sys_yield>
  8020f1:	eb e0                	jmp    8020d3 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020f6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8020fa:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020fd:	89 c2                	mov    %eax,%edx
  8020ff:	c1 fa 1f             	sar    $0x1f,%edx
  802102:	89 d1                	mov    %edx,%ecx
  802104:	c1 e9 1b             	shr    $0x1b,%ecx
  802107:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80210a:	83 e2 1f             	and    $0x1f,%edx
  80210d:	29 ca                	sub    %ecx,%edx
  80210f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802113:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802117:	83 c0 01             	add    $0x1,%eax
  80211a:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80211d:	83 c7 01             	add    $0x1,%edi
  802120:	eb ac                	jmp    8020ce <devpipe_write+0x20>
	return i;
  802122:	8b 45 10             	mov    0x10(%ebp),%eax
  802125:	eb 05                	jmp    80212c <devpipe_write+0x7e>
				return 0;
  802127:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80212c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80212f:	5b                   	pop    %ebx
  802130:	5e                   	pop    %esi
  802131:	5f                   	pop    %edi
  802132:	5d                   	pop    %ebp
  802133:	c3                   	ret    

00802134 <devpipe_read>:
{
  802134:	f3 0f 1e fb          	endbr32 
  802138:	55                   	push   %ebp
  802139:	89 e5                	mov    %esp,%ebp
  80213b:	57                   	push   %edi
  80213c:	56                   	push   %esi
  80213d:	53                   	push   %ebx
  80213e:	83 ec 18             	sub    $0x18,%esp
  802141:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802144:	57                   	push   %edi
  802145:	e8 86 f1 ff ff       	call   8012d0 <fd2data>
  80214a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80214c:	83 c4 10             	add    $0x10,%esp
  80214f:	be 00 00 00 00       	mov    $0x0,%esi
  802154:	3b 75 10             	cmp    0x10(%ebp),%esi
  802157:	75 14                	jne    80216d <devpipe_read+0x39>
	return i;
  802159:	8b 45 10             	mov    0x10(%ebp),%eax
  80215c:	eb 02                	jmp    802160 <devpipe_read+0x2c>
				return i;
  80215e:	89 f0                	mov    %esi,%eax
}
  802160:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802163:	5b                   	pop    %ebx
  802164:	5e                   	pop    %esi
  802165:	5f                   	pop    %edi
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    
			sys_yield();
  802168:	e8 08 ed ff ff       	call   800e75 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80216d:	8b 03                	mov    (%ebx),%eax
  80216f:	3b 43 04             	cmp    0x4(%ebx),%eax
  802172:	75 18                	jne    80218c <devpipe_read+0x58>
			if (i > 0)
  802174:	85 f6                	test   %esi,%esi
  802176:	75 e6                	jne    80215e <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  802178:	89 da                	mov    %ebx,%edx
  80217a:	89 f8                	mov    %edi,%eax
  80217c:	e8 c8 fe ff ff       	call   802049 <_pipeisclosed>
  802181:	85 c0                	test   %eax,%eax
  802183:	74 e3                	je     802168 <devpipe_read+0x34>
				return 0;
  802185:	b8 00 00 00 00       	mov    $0x0,%eax
  80218a:	eb d4                	jmp    802160 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80218c:	99                   	cltd   
  80218d:	c1 ea 1b             	shr    $0x1b,%edx
  802190:	01 d0                	add    %edx,%eax
  802192:	83 e0 1f             	and    $0x1f,%eax
  802195:	29 d0                	sub    %edx,%eax
  802197:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80219c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80219f:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8021a2:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8021a5:	83 c6 01             	add    $0x1,%esi
  8021a8:	eb aa                	jmp    802154 <devpipe_read+0x20>

008021aa <pipe>:
{
  8021aa:	f3 0f 1e fb          	endbr32 
  8021ae:	55                   	push   %ebp
  8021af:	89 e5                	mov    %esp,%ebp
  8021b1:	56                   	push   %esi
  8021b2:	53                   	push   %ebx
  8021b3:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8021b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021b9:	50                   	push   %eax
  8021ba:	e8 2c f1 ff ff       	call   8012eb <fd_alloc>
  8021bf:	89 c3                	mov    %eax,%ebx
  8021c1:	83 c4 10             	add    $0x10,%esp
  8021c4:	85 c0                	test   %eax,%eax
  8021c6:	0f 88 23 01 00 00    	js     8022ef <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021cc:	83 ec 04             	sub    $0x4,%esp
  8021cf:	68 07 04 00 00       	push   $0x407
  8021d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8021d7:	6a 00                	push   $0x0
  8021d9:	e8 ba ec ff ff       	call   800e98 <sys_page_alloc>
  8021de:	89 c3                	mov    %eax,%ebx
  8021e0:	83 c4 10             	add    $0x10,%esp
  8021e3:	85 c0                	test   %eax,%eax
  8021e5:	0f 88 04 01 00 00    	js     8022ef <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8021eb:	83 ec 0c             	sub    $0xc,%esp
  8021ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021f1:	50                   	push   %eax
  8021f2:	e8 f4 f0 ff ff       	call   8012eb <fd_alloc>
  8021f7:	89 c3                	mov    %eax,%ebx
  8021f9:	83 c4 10             	add    $0x10,%esp
  8021fc:	85 c0                	test   %eax,%eax
  8021fe:	0f 88 db 00 00 00    	js     8022df <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802204:	83 ec 04             	sub    $0x4,%esp
  802207:	68 07 04 00 00       	push   $0x407
  80220c:	ff 75 f0             	pushl  -0x10(%ebp)
  80220f:	6a 00                	push   $0x0
  802211:	e8 82 ec ff ff       	call   800e98 <sys_page_alloc>
  802216:	89 c3                	mov    %eax,%ebx
  802218:	83 c4 10             	add    $0x10,%esp
  80221b:	85 c0                	test   %eax,%eax
  80221d:	0f 88 bc 00 00 00    	js     8022df <pipe+0x135>
	va = fd2data(fd0);
  802223:	83 ec 0c             	sub    $0xc,%esp
  802226:	ff 75 f4             	pushl  -0xc(%ebp)
  802229:	e8 a2 f0 ff ff       	call   8012d0 <fd2data>
  80222e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802230:	83 c4 0c             	add    $0xc,%esp
  802233:	68 07 04 00 00       	push   $0x407
  802238:	50                   	push   %eax
  802239:	6a 00                	push   $0x0
  80223b:	e8 58 ec ff ff       	call   800e98 <sys_page_alloc>
  802240:	89 c3                	mov    %eax,%ebx
  802242:	83 c4 10             	add    $0x10,%esp
  802245:	85 c0                	test   %eax,%eax
  802247:	0f 88 82 00 00 00    	js     8022cf <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80224d:	83 ec 0c             	sub    $0xc,%esp
  802250:	ff 75 f0             	pushl  -0x10(%ebp)
  802253:	e8 78 f0 ff ff       	call   8012d0 <fd2data>
  802258:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80225f:	50                   	push   %eax
  802260:	6a 00                	push   $0x0
  802262:	56                   	push   %esi
  802263:	6a 00                	push   $0x0
  802265:	e8 54 ec ff ff       	call   800ebe <sys_page_map>
  80226a:	89 c3                	mov    %eax,%ebx
  80226c:	83 c4 20             	add    $0x20,%esp
  80226f:	85 c0                	test   %eax,%eax
  802271:	78 4e                	js     8022c1 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  802273:	a1 7c 40 80 00       	mov    0x80407c,%eax
  802278:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80227b:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80227d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802280:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802287:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80228a:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80228c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80228f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802296:	83 ec 0c             	sub    $0xc,%esp
  802299:	ff 75 f4             	pushl  -0xc(%ebp)
  80229c:	e8 1b f0 ff ff       	call   8012bc <fd2num>
  8022a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022a4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8022a6:	83 c4 04             	add    $0x4,%esp
  8022a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8022ac:	e8 0b f0 ff ff       	call   8012bc <fd2num>
  8022b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022b4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8022b7:	83 c4 10             	add    $0x10,%esp
  8022ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8022bf:	eb 2e                	jmp    8022ef <pipe+0x145>
	sys_page_unmap(0, va);
  8022c1:	83 ec 08             	sub    $0x8,%esp
  8022c4:	56                   	push   %esi
  8022c5:	6a 00                	push   $0x0
  8022c7:	e8 17 ec ff ff       	call   800ee3 <sys_page_unmap>
  8022cc:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8022cf:	83 ec 08             	sub    $0x8,%esp
  8022d2:	ff 75 f0             	pushl  -0x10(%ebp)
  8022d5:	6a 00                	push   $0x0
  8022d7:	e8 07 ec ff ff       	call   800ee3 <sys_page_unmap>
  8022dc:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8022df:	83 ec 08             	sub    $0x8,%esp
  8022e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8022e5:	6a 00                	push   $0x0
  8022e7:	e8 f7 eb ff ff       	call   800ee3 <sys_page_unmap>
  8022ec:	83 c4 10             	add    $0x10,%esp
}
  8022ef:	89 d8                	mov    %ebx,%eax
  8022f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022f4:	5b                   	pop    %ebx
  8022f5:	5e                   	pop    %esi
  8022f6:	5d                   	pop    %ebp
  8022f7:	c3                   	ret    

008022f8 <pipeisclosed>:
{
  8022f8:	f3 0f 1e fb          	endbr32 
  8022fc:	55                   	push   %ebp
  8022fd:	89 e5                	mov    %esp,%ebp
  8022ff:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802302:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802305:	50                   	push   %eax
  802306:	ff 75 08             	pushl  0x8(%ebp)
  802309:	e8 33 f0 ff ff       	call   801341 <fd_lookup>
  80230e:	83 c4 10             	add    $0x10,%esp
  802311:	85 c0                	test   %eax,%eax
  802313:	78 18                	js     80232d <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  802315:	83 ec 0c             	sub    $0xc,%esp
  802318:	ff 75 f4             	pushl  -0xc(%ebp)
  80231b:	e8 b0 ef ff ff       	call   8012d0 <fd2data>
  802320:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802322:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802325:	e8 1f fd ff ff       	call   802049 <_pipeisclosed>
  80232a:	83 c4 10             	add    $0x10,%esp
}
  80232d:	c9                   	leave  
  80232e:	c3                   	ret    

0080232f <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80232f:	f3 0f 1e fb          	endbr32 
  802333:	55                   	push   %ebp
  802334:	89 e5                	mov    %esp,%ebp
  802336:	56                   	push   %esi
  802337:	53                   	push   %ebx
  802338:	8b 75 08             	mov    0x8(%ebp),%esi
	// cprintf("[%08x] called wait for child %08x\n", thisenv->env_id, envid);
	const volatile struct Env *e;

	assert(envid != 0);
  80233b:	85 f6                	test   %esi,%esi
  80233d:	74 13                	je     802352 <wait+0x23>
	e = &envs[ENVX(envid)];
  80233f:	89 f3                	mov    %esi,%ebx
  802341:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802347:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80234a:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802350:	eb 1b                	jmp    80236d <wait+0x3e>
	assert(envid != 0);
  802352:	68 57 30 80 00       	push   $0x803057
  802357:	68 73 2f 80 00       	push   $0x802f73
  80235c:	6a 0a                	push   $0xa
  80235e:	68 62 30 80 00       	push   $0x803062
  802363:	e8 d6 df ff ff       	call   80033e <_panic>
		sys_yield();
  802368:	e8 08 eb ff ff       	call   800e75 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80236d:	8b 43 48             	mov    0x48(%ebx),%eax
  802370:	39 f0                	cmp    %esi,%eax
  802372:	75 07                	jne    80237b <wait+0x4c>
  802374:	8b 43 54             	mov    0x54(%ebx),%eax
  802377:	85 c0                	test   %eax,%eax
  802379:	75 ed                	jne    802368 <wait+0x39>
}
  80237b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80237e:	5b                   	pop    %ebx
  80237f:	5e                   	pop    %esi
  802380:	5d                   	pop    %ebp
  802381:	c3                   	ret    

00802382 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802382:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  802386:	b8 00 00 00 00       	mov    $0x0,%eax
  80238b:	c3                   	ret    

0080238c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80238c:	f3 0f 1e fb          	endbr32 
  802390:	55                   	push   %ebp
  802391:	89 e5                	mov    %esp,%ebp
  802393:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802396:	68 6d 30 80 00       	push   $0x80306d
  80239b:	ff 75 0c             	pushl  0xc(%ebp)
  80239e:	e8 8c e6 ff ff       	call   800a2f <strcpy>
	return 0;
}
  8023a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8023a8:	c9                   	leave  
  8023a9:	c3                   	ret    

008023aa <devcons_write>:
{
  8023aa:	f3 0f 1e fb          	endbr32 
  8023ae:	55                   	push   %ebp
  8023af:	89 e5                	mov    %esp,%ebp
  8023b1:	57                   	push   %edi
  8023b2:	56                   	push   %esi
  8023b3:	53                   	push   %ebx
  8023b4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8023ba:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8023bf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8023c5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023c8:	73 31                	jae    8023fb <devcons_write+0x51>
		m = n - tot;
  8023ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023cd:	29 f3                	sub    %esi,%ebx
  8023cf:	83 fb 7f             	cmp    $0x7f,%ebx
  8023d2:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8023d7:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8023da:	83 ec 04             	sub    $0x4,%esp
  8023dd:	53                   	push   %ebx
  8023de:	89 f0                	mov    %esi,%eax
  8023e0:	03 45 0c             	add    0xc(%ebp),%eax
  8023e3:	50                   	push   %eax
  8023e4:	57                   	push   %edi
  8023e5:	e8 43 e8 ff ff       	call   800c2d <memmove>
		sys_cputs(buf, m);
  8023ea:	83 c4 08             	add    $0x8,%esp
  8023ed:	53                   	push   %ebx
  8023ee:	57                   	push   %edi
  8023ef:	e8 f5 e9 ff ff       	call   800de9 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8023f4:	01 de                	add    %ebx,%esi
  8023f6:	83 c4 10             	add    $0x10,%esp
  8023f9:	eb ca                	jmp    8023c5 <devcons_write+0x1b>
}
  8023fb:	89 f0                	mov    %esi,%eax
  8023fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802400:	5b                   	pop    %ebx
  802401:	5e                   	pop    %esi
  802402:	5f                   	pop    %edi
  802403:	5d                   	pop    %ebp
  802404:	c3                   	ret    

00802405 <devcons_read>:
{
  802405:	f3 0f 1e fb          	endbr32 
  802409:	55                   	push   %ebp
  80240a:	89 e5                	mov    %esp,%ebp
  80240c:	83 ec 08             	sub    $0x8,%esp
  80240f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802414:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802418:	74 21                	je     80243b <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  80241a:	e8 ec e9 ff ff       	call   800e0b <sys_cgetc>
  80241f:	85 c0                	test   %eax,%eax
  802421:	75 07                	jne    80242a <devcons_read+0x25>
		sys_yield();
  802423:	e8 4d ea ff ff       	call   800e75 <sys_yield>
  802428:	eb f0                	jmp    80241a <devcons_read+0x15>
	if (c < 0)
  80242a:	78 0f                	js     80243b <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  80242c:	83 f8 04             	cmp    $0x4,%eax
  80242f:	74 0c                	je     80243d <devcons_read+0x38>
	*(char*)vbuf = c;
  802431:	8b 55 0c             	mov    0xc(%ebp),%edx
  802434:	88 02                	mov    %al,(%edx)
	return 1;
  802436:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80243b:	c9                   	leave  
  80243c:	c3                   	ret    
		return 0;
  80243d:	b8 00 00 00 00       	mov    $0x0,%eax
  802442:	eb f7                	jmp    80243b <devcons_read+0x36>

00802444 <cputchar>:
{
  802444:	f3 0f 1e fb          	endbr32 
  802448:	55                   	push   %ebp
  802449:	89 e5                	mov    %esp,%ebp
  80244b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80244e:	8b 45 08             	mov    0x8(%ebp),%eax
  802451:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802454:	6a 01                	push   $0x1
  802456:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802459:	50                   	push   %eax
  80245a:	e8 8a e9 ff ff       	call   800de9 <sys_cputs>
}
  80245f:	83 c4 10             	add    $0x10,%esp
  802462:	c9                   	leave  
  802463:	c3                   	ret    

00802464 <getchar>:
{
  802464:	f3 0f 1e fb          	endbr32 
  802468:	55                   	push   %ebp
  802469:	89 e5                	mov    %esp,%ebp
  80246b:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80246e:	6a 01                	push   $0x1
  802470:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802473:	50                   	push   %eax
  802474:	6a 00                	push   $0x0
  802476:	e8 4e f1 ff ff       	call   8015c9 <read>
	if (r < 0)
  80247b:	83 c4 10             	add    $0x10,%esp
  80247e:	85 c0                	test   %eax,%eax
  802480:	78 06                	js     802488 <getchar+0x24>
	if (r < 1)
  802482:	74 06                	je     80248a <getchar+0x26>
	return c;
  802484:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802488:	c9                   	leave  
  802489:	c3                   	ret    
		return -E_EOF;
  80248a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80248f:	eb f7                	jmp    802488 <getchar+0x24>

00802491 <iscons>:
{
  802491:	f3 0f 1e fb          	endbr32 
  802495:	55                   	push   %ebp
  802496:	89 e5                	mov    %esp,%ebp
  802498:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80249b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80249e:	50                   	push   %eax
  80249f:	ff 75 08             	pushl  0x8(%ebp)
  8024a2:	e8 9a ee ff ff       	call   801341 <fd_lookup>
  8024a7:	83 c4 10             	add    $0x10,%esp
  8024aa:	85 c0                	test   %eax,%eax
  8024ac:	78 11                	js     8024bf <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8024ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024b1:	8b 15 98 40 80 00    	mov    0x804098,%edx
  8024b7:	39 10                	cmp    %edx,(%eax)
  8024b9:	0f 94 c0             	sete   %al
  8024bc:	0f b6 c0             	movzbl %al,%eax
}
  8024bf:	c9                   	leave  
  8024c0:	c3                   	ret    

008024c1 <opencons>:
{
  8024c1:	f3 0f 1e fb          	endbr32 
  8024c5:	55                   	push   %ebp
  8024c6:	89 e5                	mov    %esp,%ebp
  8024c8:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8024cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024ce:	50                   	push   %eax
  8024cf:	e8 17 ee ff ff       	call   8012eb <fd_alloc>
  8024d4:	83 c4 10             	add    $0x10,%esp
  8024d7:	85 c0                	test   %eax,%eax
  8024d9:	78 3a                	js     802515 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024db:	83 ec 04             	sub    $0x4,%esp
  8024de:	68 07 04 00 00       	push   $0x407
  8024e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8024e6:	6a 00                	push   $0x0
  8024e8:	e8 ab e9 ff ff       	call   800e98 <sys_page_alloc>
  8024ed:	83 c4 10             	add    $0x10,%esp
  8024f0:	85 c0                	test   %eax,%eax
  8024f2:	78 21                	js     802515 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8024f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024f7:	8b 15 98 40 80 00    	mov    0x804098,%edx
  8024fd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802502:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802509:	83 ec 0c             	sub    $0xc,%esp
  80250c:	50                   	push   %eax
  80250d:	e8 aa ed ff ff       	call   8012bc <fd2num>
  802512:	83 c4 10             	add    $0x10,%esp
}
  802515:	c9                   	leave  
  802516:	c3                   	ret    

00802517 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802517:	f3 0f 1e fb          	endbr32 
  80251b:	55                   	push   %ebp
  80251c:	89 e5                	mov    %esp,%ebp
  80251e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802521:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802528:	74 0a                	je     802534 <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80252a:	8b 45 08             	mov    0x8(%ebp),%eax
  80252d:	a3 00 80 80 00       	mov    %eax,0x808000

}
  802532:	c9                   	leave  
  802533:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  802534:	83 ec 04             	sub    $0x4,%esp
  802537:	6a 07                	push   $0x7
  802539:	68 00 f0 bf ee       	push   $0xeebff000
  80253e:	6a 00                	push   $0x0
  802540:	e8 53 e9 ff ff       	call   800e98 <sys_page_alloc>
  802545:	83 c4 10             	add    $0x10,%esp
  802548:	85 c0                	test   %eax,%eax
  80254a:	78 2a                	js     802576 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  80254c:	83 ec 08             	sub    $0x8,%esp
  80254f:	68 8a 25 80 00       	push   $0x80258a
  802554:	6a 00                	push   $0x0
  802556:	e8 f7 e9 ff ff       	call   800f52 <sys_env_set_pgfault_upcall>
  80255b:	83 c4 10             	add    $0x10,%esp
  80255e:	85 c0                	test   %eax,%eax
  802560:	79 c8                	jns    80252a <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  802562:	83 ec 04             	sub    $0x4,%esp
  802565:	68 a8 30 80 00       	push   $0x8030a8
  80256a:	6a 2c                	push   $0x2c
  80256c:	68 de 30 80 00       	push   $0x8030de
  802571:	e8 c8 dd ff ff       	call   80033e <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  802576:	83 ec 04             	sub    $0x4,%esp
  802579:	68 7c 30 80 00       	push   $0x80307c
  80257e:	6a 22                	push   $0x22
  802580:	68 de 30 80 00       	push   $0x8030de
  802585:	e8 b4 dd ff ff       	call   80033e <_panic>

0080258a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80258a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80258b:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax   			// 间接寻址
  802590:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802592:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  802595:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  802599:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  80259e:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  8025a2:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  8025a4:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  8025a7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  8025a8:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  8025ab:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  8025ac:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  8025ad:	c3                   	ret    

008025ae <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8025ae:	f3 0f 1e fb          	endbr32 
  8025b2:	55                   	push   %ebp
  8025b3:	89 e5                	mov    %esp,%ebp
  8025b5:	56                   	push   %esi
  8025b6:	53                   	push   %ebx
  8025b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8025ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  8025c0:	85 c0                	test   %eax,%eax
  8025c2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8025c7:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  8025ca:	83 ec 0c             	sub    $0xc,%esp
  8025cd:	50                   	push   %eax
  8025ce:	e8 cb e9 ff ff       	call   800f9e <sys_ipc_recv>
  8025d3:	83 c4 10             	add    $0x10,%esp
  8025d6:	85 c0                	test   %eax,%eax
  8025d8:	75 2b                	jne    802605 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  8025da:	85 f6                	test   %esi,%esi
  8025dc:	74 0a                	je     8025e8 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  8025de:	a1 08 50 80 00       	mov    0x805008,%eax
  8025e3:	8b 40 74             	mov    0x74(%eax),%eax
  8025e6:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  8025e8:	85 db                	test   %ebx,%ebx
  8025ea:	74 0a                	je     8025f6 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  8025ec:	a1 08 50 80 00       	mov    0x805008,%eax
  8025f1:	8b 40 78             	mov    0x78(%eax),%eax
  8025f4:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  8025f6:	a1 08 50 80 00       	mov    0x805008,%eax
  8025fb:	8b 40 70             	mov    0x70(%eax),%eax
}
  8025fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802601:	5b                   	pop    %ebx
  802602:	5e                   	pop    %esi
  802603:	5d                   	pop    %ebp
  802604:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  802605:	85 f6                	test   %esi,%esi
  802607:	74 06                	je     80260f <ipc_recv+0x61>
  802609:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  80260f:	85 db                	test   %ebx,%ebx
  802611:	74 eb                	je     8025fe <ipc_recv+0x50>
  802613:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802619:	eb e3                	jmp    8025fe <ipc_recv+0x50>

0080261b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80261b:	f3 0f 1e fb          	endbr32 
  80261f:	55                   	push   %ebp
  802620:	89 e5                	mov    %esp,%ebp
  802622:	57                   	push   %edi
  802623:	56                   	push   %esi
  802624:	53                   	push   %ebx
  802625:	83 ec 0c             	sub    $0xc,%esp
  802628:	8b 7d 08             	mov    0x8(%ebp),%edi
  80262b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80262e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  802631:	85 db                	test   %ebx,%ebx
  802633:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802638:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  80263b:	ff 75 14             	pushl  0x14(%ebp)
  80263e:	53                   	push   %ebx
  80263f:	56                   	push   %esi
  802640:	57                   	push   %edi
  802641:	e8 31 e9 ff ff       	call   800f77 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  802646:	83 c4 10             	add    $0x10,%esp
  802649:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80264c:	75 07                	jne    802655 <ipc_send+0x3a>
			sys_yield();
  80264e:	e8 22 e8 ff ff       	call   800e75 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802653:	eb e6                	jmp    80263b <ipc_send+0x20>
		}
		else if (ret == 0)
  802655:	85 c0                	test   %eax,%eax
  802657:	75 08                	jne    802661 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  802659:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80265c:	5b                   	pop    %ebx
  80265d:	5e                   	pop    %esi
  80265e:	5f                   	pop    %edi
  80265f:	5d                   	pop    %ebp
  802660:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802661:	50                   	push   %eax
  802662:	68 ec 30 80 00       	push   $0x8030ec
  802667:	6a 48                	push   $0x48
  802669:	68 fa 30 80 00       	push   $0x8030fa
  80266e:	e8 cb dc ff ff       	call   80033e <_panic>

00802673 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802673:	f3 0f 1e fb          	endbr32 
  802677:	55                   	push   %ebp
  802678:	89 e5                	mov    %esp,%ebp
  80267a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80267d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802682:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802685:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80268b:	8b 52 50             	mov    0x50(%edx),%edx
  80268e:	39 ca                	cmp    %ecx,%edx
  802690:	74 11                	je     8026a3 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802692:	83 c0 01             	add    $0x1,%eax
  802695:	3d 00 04 00 00       	cmp    $0x400,%eax
  80269a:	75 e6                	jne    802682 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80269c:	b8 00 00 00 00       	mov    $0x0,%eax
  8026a1:	eb 0b                	jmp    8026ae <ipc_find_env+0x3b>
			return envs[i].env_id;
  8026a3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8026a6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8026ab:	8b 40 48             	mov    0x48(%eax),%eax
}
  8026ae:	5d                   	pop    %ebp
  8026af:	c3                   	ret    

008026b0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026b0:	f3 0f 1e fb          	endbr32 
  8026b4:	55                   	push   %ebp
  8026b5:	89 e5                	mov    %esp,%ebp
  8026b7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026ba:	89 c2                	mov    %eax,%edx
  8026bc:	c1 ea 16             	shr    $0x16,%edx
  8026bf:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8026c6:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8026cb:	f6 c1 01             	test   $0x1,%cl
  8026ce:	74 1c                	je     8026ec <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8026d0:	c1 e8 0c             	shr    $0xc,%eax
  8026d3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8026da:	a8 01                	test   $0x1,%al
  8026dc:	74 0e                	je     8026ec <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8026de:	c1 e8 0c             	shr    $0xc,%eax
  8026e1:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8026e8:	ef 
  8026e9:	0f b7 d2             	movzwl %dx,%edx
}
  8026ec:	89 d0                	mov    %edx,%eax
  8026ee:	5d                   	pop    %ebp
  8026ef:	c3                   	ret    

008026f0 <__udivdi3>:
  8026f0:	f3 0f 1e fb          	endbr32 
  8026f4:	55                   	push   %ebp
  8026f5:	57                   	push   %edi
  8026f6:	56                   	push   %esi
  8026f7:	53                   	push   %ebx
  8026f8:	83 ec 1c             	sub    $0x1c,%esp
  8026fb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026ff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802703:	8b 74 24 34          	mov    0x34(%esp),%esi
  802707:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80270b:	85 d2                	test   %edx,%edx
  80270d:	75 19                	jne    802728 <__udivdi3+0x38>
  80270f:	39 f3                	cmp    %esi,%ebx
  802711:	76 4d                	jbe    802760 <__udivdi3+0x70>
  802713:	31 ff                	xor    %edi,%edi
  802715:	89 e8                	mov    %ebp,%eax
  802717:	89 f2                	mov    %esi,%edx
  802719:	f7 f3                	div    %ebx
  80271b:	89 fa                	mov    %edi,%edx
  80271d:	83 c4 1c             	add    $0x1c,%esp
  802720:	5b                   	pop    %ebx
  802721:	5e                   	pop    %esi
  802722:	5f                   	pop    %edi
  802723:	5d                   	pop    %ebp
  802724:	c3                   	ret    
  802725:	8d 76 00             	lea    0x0(%esi),%esi
  802728:	39 f2                	cmp    %esi,%edx
  80272a:	76 14                	jbe    802740 <__udivdi3+0x50>
  80272c:	31 ff                	xor    %edi,%edi
  80272e:	31 c0                	xor    %eax,%eax
  802730:	89 fa                	mov    %edi,%edx
  802732:	83 c4 1c             	add    $0x1c,%esp
  802735:	5b                   	pop    %ebx
  802736:	5e                   	pop    %esi
  802737:	5f                   	pop    %edi
  802738:	5d                   	pop    %ebp
  802739:	c3                   	ret    
  80273a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802740:	0f bd fa             	bsr    %edx,%edi
  802743:	83 f7 1f             	xor    $0x1f,%edi
  802746:	75 48                	jne    802790 <__udivdi3+0xa0>
  802748:	39 f2                	cmp    %esi,%edx
  80274a:	72 06                	jb     802752 <__udivdi3+0x62>
  80274c:	31 c0                	xor    %eax,%eax
  80274e:	39 eb                	cmp    %ebp,%ebx
  802750:	77 de                	ja     802730 <__udivdi3+0x40>
  802752:	b8 01 00 00 00       	mov    $0x1,%eax
  802757:	eb d7                	jmp    802730 <__udivdi3+0x40>
  802759:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802760:	89 d9                	mov    %ebx,%ecx
  802762:	85 db                	test   %ebx,%ebx
  802764:	75 0b                	jne    802771 <__udivdi3+0x81>
  802766:	b8 01 00 00 00       	mov    $0x1,%eax
  80276b:	31 d2                	xor    %edx,%edx
  80276d:	f7 f3                	div    %ebx
  80276f:	89 c1                	mov    %eax,%ecx
  802771:	31 d2                	xor    %edx,%edx
  802773:	89 f0                	mov    %esi,%eax
  802775:	f7 f1                	div    %ecx
  802777:	89 c6                	mov    %eax,%esi
  802779:	89 e8                	mov    %ebp,%eax
  80277b:	89 f7                	mov    %esi,%edi
  80277d:	f7 f1                	div    %ecx
  80277f:	89 fa                	mov    %edi,%edx
  802781:	83 c4 1c             	add    $0x1c,%esp
  802784:	5b                   	pop    %ebx
  802785:	5e                   	pop    %esi
  802786:	5f                   	pop    %edi
  802787:	5d                   	pop    %ebp
  802788:	c3                   	ret    
  802789:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802790:	89 f9                	mov    %edi,%ecx
  802792:	b8 20 00 00 00       	mov    $0x20,%eax
  802797:	29 f8                	sub    %edi,%eax
  802799:	d3 e2                	shl    %cl,%edx
  80279b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80279f:	89 c1                	mov    %eax,%ecx
  8027a1:	89 da                	mov    %ebx,%edx
  8027a3:	d3 ea                	shr    %cl,%edx
  8027a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8027a9:	09 d1                	or     %edx,%ecx
  8027ab:	89 f2                	mov    %esi,%edx
  8027ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027b1:	89 f9                	mov    %edi,%ecx
  8027b3:	d3 e3                	shl    %cl,%ebx
  8027b5:	89 c1                	mov    %eax,%ecx
  8027b7:	d3 ea                	shr    %cl,%edx
  8027b9:	89 f9                	mov    %edi,%ecx
  8027bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8027bf:	89 eb                	mov    %ebp,%ebx
  8027c1:	d3 e6                	shl    %cl,%esi
  8027c3:	89 c1                	mov    %eax,%ecx
  8027c5:	d3 eb                	shr    %cl,%ebx
  8027c7:	09 de                	or     %ebx,%esi
  8027c9:	89 f0                	mov    %esi,%eax
  8027cb:	f7 74 24 08          	divl   0x8(%esp)
  8027cf:	89 d6                	mov    %edx,%esi
  8027d1:	89 c3                	mov    %eax,%ebx
  8027d3:	f7 64 24 0c          	mull   0xc(%esp)
  8027d7:	39 d6                	cmp    %edx,%esi
  8027d9:	72 15                	jb     8027f0 <__udivdi3+0x100>
  8027db:	89 f9                	mov    %edi,%ecx
  8027dd:	d3 e5                	shl    %cl,%ebp
  8027df:	39 c5                	cmp    %eax,%ebp
  8027e1:	73 04                	jae    8027e7 <__udivdi3+0xf7>
  8027e3:	39 d6                	cmp    %edx,%esi
  8027e5:	74 09                	je     8027f0 <__udivdi3+0x100>
  8027e7:	89 d8                	mov    %ebx,%eax
  8027e9:	31 ff                	xor    %edi,%edi
  8027eb:	e9 40 ff ff ff       	jmp    802730 <__udivdi3+0x40>
  8027f0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8027f3:	31 ff                	xor    %edi,%edi
  8027f5:	e9 36 ff ff ff       	jmp    802730 <__udivdi3+0x40>
  8027fa:	66 90                	xchg   %ax,%ax
  8027fc:	66 90                	xchg   %ax,%ax
  8027fe:	66 90                	xchg   %ax,%ax

00802800 <__umoddi3>:
  802800:	f3 0f 1e fb          	endbr32 
  802804:	55                   	push   %ebp
  802805:	57                   	push   %edi
  802806:	56                   	push   %esi
  802807:	53                   	push   %ebx
  802808:	83 ec 1c             	sub    $0x1c,%esp
  80280b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80280f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802813:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802817:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80281b:	85 c0                	test   %eax,%eax
  80281d:	75 19                	jne    802838 <__umoddi3+0x38>
  80281f:	39 df                	cmp    %ebx,%edi
  802821:	76 5d                	jbe    802880 <__umoddi3+0x80>
  802823:	89 f0                	mov    %esi,%eax
  802825:	89 da                	mov    %ebx,%edx
  802827:	f7 f7                	div    %edi
  802829:	89 d0                	mov    %edx,%eax
  80282b:	31 d2                	xor    %edx,%edx
  80282d:	83 c4 1c             	add    $0x1c,%esp
  802830:	5b                   	pop    %ebx
  802831:	5e                   	pop    %esi
  802832:	5f                   	pop    %edi
  802833:	5d                   	pop    %ebp
  802834:	c3                   	ret    
  802835:	8d 76 00             	lea    0x0(%esi),%esi
  802838:	89 f2                	mov    %esi,%edx
  80283a:	39 d8                	cmp    %ebx,%eax
  80283c:	76 12                	jbe    802850 <__umoddi3+0x50>
  80283e:	89 f0                	mov    %esi,%eax
  802840:	89 da                	mov    %ebx,%edx
  802842:	83 c4 1c             	add    $0x1c,%esp
  802845:	5b                   	pop    %ebx
  802846:	5e                   	pop    %esi
  802847:	5f                   	pop    %edi
  802848:	5d                   	pop    %ebp
  802849:	c3                   	ret    
  80284a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802850:	0f bd e8             	bsr    %eax,%ebp
  802853:	83 f5 1f             	xor    $0x1f,%ebp
  802856:	75 50                	jne    8028a8 <__umoddi3+0xa8>
  802858:	39 d8                	cmp    %ebx,%eax
  80285a:	0f 82 e0 00 00 00    	jb     802940 <__umoddi3+0x140>
  802860:	89 d9                	mov    %ebx,%ecx
  802862:	39 f7                	cmp    %esi,%edi
  802864:	0f 86 d6 00 00 00    	jbe    802940 <__umoddi3+0x140>
  80286a:	89 d0                	mov    %edx,%eax
  80286c:	89 ca                	mov    %ecx,%edx
  80286e:	83 c4 1c             	add    $0x1c,%esp
  802871:	5b                   	pop    %ebx
  802872:	5e                   	pop    %esi
  802873:	5f                   	pop    %edi
  802874:	5d                   	pop    %ebp
  802875:	c3                   	ret    
  802876:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80287d:	8d 76 00             	lea    0x0(%esi),%esi
  802880:	89 fd                	mov    %edi,%ebp
  802882:	85 ff                	test   %edi,%edi
  802884:	75 0b                	jne    802891 <__umoddi3+0x91>
  802886:	b8 01 00 00 00       	mov    $0x1,%eax
  80288b:	31 d2                	xor    %edx,%edx
  80288d:	f7 f7                	div    %edi
  80288f:	89 c5                	mov    %eax,%ebp
  802891:	89 d8                	mov    %ebx,%eax
  802893:	31 d2                	xor    %edx,%edx
  802895:	f7 f5                	div    %ebp
  802897:	89 f0                	mov    %esi,%eax
  802899:	f7 f5                	div    %ebp
  80289b:	89 d0                	mov    %edx,%eax
  80289d:	31 d2                	xor    %edx,%edx
  80289f:	eb 8c                	jmp    80282d <__umoddi3+0x2d>
  8028a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028a8:	89 e9                	mov    %ebp,%ecx
  8028aa:	ba 20 00 00 00       	mov    $0x20,%edx
  8028af:	29 ea                	sub    %ebp,%edx
  8028b1:	d3 e0                	shl    %cl,%eax
  8028b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8028b7:	89 d1                	mov    %edx,%ecx
  8028b9:	89 f8                	mov    %edi,%eax
  8028bb:	d3 e8                	shr    %cl,%eax
  8028bd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8028c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8028c5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8028c9:	09 c1                	or     %eax,%ecx
  8028cb:	89 d8                	mov    %ebx,%eax
  8028cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028d1:	89 e9                	mov    %ebp,%ecx
  8028d3:	d3 e7                	shl    %cl,%edi
  8028d5:	89 d1                	mov    %edx,%ecx
  8028d7:	d3 e8                	shr    %cl,%eax
  8028d9:	89 e9                	mov    %ebp,%ecx
  8028db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8028df:	d3 e3                	shl    %cl,%ebx
  8028e1:	89 c7                	mov    %eax,%edi
  8028e3:	89 d1                	mov    %edx,%ecx
  8028e5:	89 f0                	mov    %esi,%eax
  8028e7:	d3 e8                	shr    %cl,%eax
  8028e9:	89 e9                	mov    %ebp,%ecx
  8028eb:	89 fa                	mov    %edi,%edx
  8028ed:	d3 e6                	shl    %cl,%esi
  8028ef:	09 d8                	or     %ebx,%eax
  8028f1:	f7 74 24 08          	divl   0x8(%esp)
  8028f5:	89 d1                	mov    %edx,%ecx
  8028f7:	89 f3                	mov    %esi,%ebx
  8028f9:	f7 64 24 0c          	mull   0xc(%esp)
  8028fd:	89 c6                	mov    %eax,%esi
  8028ff:	89 d7                	mov    %edx,%edi
  802901:	39 d1                	cmp    %edx,%ecx
  802903:	72 06                	jb     80290b <__umoddi3+0x10b>
  802905:	75 10                	jne    802917 <__umoddi3+0x117>
  802907:	39 c3                	cmp    %eax,%ebx
  802909:	73 0c                	jae    802917 <__umoddi3+0x117>
  80290b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80290f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802913:	89 d7                	mov    %edx,%edi
  802915:	89 c6                	mov    %eax,%esi
  802917:	89 ca                	mov    %ecx,%edx
  802919:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80291e:	29 f3                	sub    %esi,%ebx
  802920:	19 fa                	sbb    %edi,%edx
  802922:	89 d0                	mov    %edx,%eax
  802924:	d3 e0                	shl    %cl,%eax
  802926:	89 e9                	mov    %ebp,%ecx
  802928:	d3 eb                	shr    %cl,%ebx
  80292a:	d3 ea                	shr    %cl,%edx
  80292c:	09 d8                	or     %ebx,%eax
  80292e:	83 c4 1c             	add    $0x1c,%esp
  802931:	5b                   	pop    %ebx
  802932:	5e                   	pop    %esi
  802933:	5f                   	pop    %edi
  802934:	5d                   	pop    %ebp
  802935:	c3                   	ret    
  802936:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80293d:	8d 76 00             	lea    0x0(%esi),%esi
  802940:	29 fe                	sub    %edi,%esi
  802942:	19 c3                	sbb    %eax,%ebx
  802944:	89 f2                	mov    %esi,%edx
  802946:	89 d9                	mov    %ebx,%ecx
  802948:	e9 1d ff ff ff       	jmp    80286a <__umoddi3+0x6a>
