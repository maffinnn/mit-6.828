
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 7d 04 00 00       	call   8004ae <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	81 ec 84 00 00 00    	sub    $0x84,%esp
  800043:	8b 75 08             	mov    0x8(%ebp),%esi
  800046:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800049:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  80004c:	53                   	push   %ebx
  80004d:	56                   	push   %esi
  80004e:	e8 aa 18 00 00       	call   8018fd <seek>
	seek(kfd, off);
  800053:	83 c4 08             	add    $0x8,%esp
  800056:	53                   	push   %ebx
  800057:	57                   	push   %edi
  800058:	e8 a0 18 00 00       	call   8018fd <seek>

	cprintf("shell produced incorrect output.\n");
  80005d:	c7 04 24 c0 2f 80 00 	movl   $0x802fc0,(%esp)
  800064:	e8 94 05 00 00       	call   8005fd <cprintf>
	cprintf("expected:\n===\n");
  800069:	c7 04 24 2b 30 80 00 	movl   $0x80302b,(%esp)
  800070:	e8 88 05 00 00       	call   8005fd <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  80007b:	83 ec 04             	sub    $0x4,%esp
  80007e:	6a 63                	push   $0x63
  800080:	53                   	push   %ebx
  800081:	57                   	push   %edi
  800082:	e8 1a 17 00 00       	call   8017a1 <read>
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	85 c0                	test   %eax,%eax
  80008c:	7e 0f                	jle    80009d <wrong+0x6a>
		sys_cputs(buf, n);
  80008e:	83 ec 08             	sub    $0x8,%esp
  800091:	50                   	push   %eax
  800092:	53                   	push   %ebx
  800093:	e8 29 0f 00 00       	call   800fc1 <sys_cputs>
  800098:	83 c4 10             	add    $0x10,%esp
  80009b:	eb de                	jmp    80007b <wrong+0x48>
	cprintf("===\ngot:\n===\n");
  80009d:	83 ec 0c             	sub    $0xc,%esp
  8000a0:	68 3a 30 80 00       	push   $0x80303a
  8000a5:	e8 53 05 00 00       	call   8005fd <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000aa:	83 c4 10             	add    $0x10,%esp
  8000ad:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000b0:	eb 0d                	jmp    8000bf <wrong+0x8c>
		sys_cputs(buf, n);
  8000b2:	83 ec 08             	sub    $0x8,%esp
  8000b5:	50                   	push   %eax
  8000b6:	53                   	push   %ebx
  8000b7:	e8 05 0f 00 00       	call   800fc1 <sys_cputs>
  8000bc:	83 c4 10             	add    $0x10,%esp
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bf:	83 ec 04             	sub    $0x4,%esp
  8000c2:	6a 63                	push   $0x63
  8000c4:	53                   	push   %ebx
  8000c5:	56                   	push   %esi
  8000c6:	e8 d6 16 00 00       	call   8017a1 <read>
  8000cb:	83 c4 10             	add    $0x10,%esp
  8000ce:	85 c0                	test   %eax,%eax
  8000d0:	7f e0                	jg     8000b2 <wrong+0x7f>
	cprintf("===\n");
  8000d2:	83 ec 0c             	sub    $0xc,%esp
  8000d5:	68 35 30 80 00       	push   $0x803035
  8000da:	e8 1e 05 00 00       	call   8005fd <cprintf>
	exit();
  8000df:	e8 14 04 00 00       	call   8004f8 <exit>
}
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5f                   	pop    %edi
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    

008000ef <umain>:
{
  8000ef:	f3 0f 1e fb          	endbr32 
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	57                   	push   %edi
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 38             	sub    $0x38,%esp
	close(0);
  8000fc:	6a 00                	push   $0x0
  8000fe:	e8 54 15 00 00       	call   801657 <close>
	close(1);
  800103:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80010a:	e8 48 15 00 00       	call   801657 <close>
	opencons();
  80010f:	e8 44 03 00 00       	call   800458 <opencons>
	opencons();
  800114:	e8 3f 03 00 00       	call   800458 <opencons>
	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800119:	83 c4 08             	add    $0x8,%esp
  80011c:	6a 00                	push   $0x0
  80011e:	68 48 30 80 00       	push   $0x803048
  800123:	e8 14 1b 00 00       	call   801c3c <open>
  800128:	89 c3                	mov    %eax,%ebx
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	85 c0                	test   %eax,%eax
  80012f:	0f 88 e7 00 00 00    	js     80021c <umain+0x12d>
	if ((wfd = pipe(pfds)) < 0)
  800135:	83 ec 0c             	sub    $0xc,%esp
  800138:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	e8 6c 28 00 00       	call   8029ad <pipe>
  800141:	83 c4 10             	add    $0x10,%esp
  800144:	85 c0                	test   %eax,%eax
  800146:	0f 88 e2 00 00 00    	js     80022e <umain+0x13f>
	wfd = pfds[1];
  80014c:	8b 75 e0             	mov    -0x20(%ebp),%esi
	cprintf("running sh -x < testshell.sh | cat\n");
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	68 e4 2f 80 00       	push   $0x802fe4
  800157:	e8 a1 04 00 00       	call   8005fd <cprintf>
	if ((r = fork()) < 0)
  80015c:	e8 a2 11 00 00       	call   801303 <fork>
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	85 c0                	test   %eax,%eax
  800166:	0f 88 d4 00 00 00    	js     800240 <umain+0x151>
	if (r == 0) {
  80016c:	75 6f                	jne    8001dd <umain+0xee>
		dup(rfd, 0);
  80016e:	83 ec 08             	sub    $0x8,%esp
  800171:	6a 00                	push   $0x0
  800173:	53                   	push   %ebx
  800174:	e8 38 15 00 00       	call   8016b1 <dup>
		dup(wfd, 1);
  800179:	83 c4 08             	add    $0x8,%esp
  80017c:	6a 01                	push   $0x1
  80017e:	56                   	push   %esi
  80017f:	e8 2d 15 00 00       	call   8016b1 <dup>
		close(rfd);
  800184:	89 1c 24             	mov    %ebx,(%esp)
  800187:	e8 cb 14 00 00       	call   801657 <close>
		close(wfd);
  80018c:	89 34 24             	mov    %esi,(%esp)
  80018f:	e8 c3 14 00 00       	call   801657 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  800194:	6a 00                	push   $0x0
  800196:	68 8e 30 80 00       	push   $0x80308e
  80019b:	68 52 30 80 00       	push   $0x803052
  8001a0:	68 91 30 80 00       	push   $0x803091
  8001a5:	e8 b8 20 00 00       	call   802262 <spawnl>
  8001aa:	89 c7                	mov    %eax,%edi
  8001ac:	83 c4 20             	add    $0x20,%esp
  8001af:	85 c0                	test   %eax,%eax
  8001b1:	0f 88 9b 00 00 00    	js     800252 <umain+0x163>
		close(0);
  8001b7:	83 ec 0c             	sub    $0xc,%esp
  8001ba:	6a 00                	push   $0x0
  8001bc:	e8 96 14 00 00       	call   801657 <close>
		close(1);
  8001c1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001c8:	e8 8a 14 00 00       	call   801657 <close>
		wait(r); // wait for the spawnd child process to exit
  8001cd:	89 3c 24             	mov    %edi,(%esp)
  8001d0:	e8 5d 29 00 00       	call   802b32 <wait>
		exit();
  8001d5:	e8 1e 03 00 00       	call   8004f8 <exit>
  8001da:	83 c4 10             	add    $0x10,%esp
	close(rfd);
  8001dd:	83 ec 0c             	sub    $0xc,%esp
  8001e0:	53                   	push   %ebx
  8001e1:	e8 71 14 00 00       	call   801657 <close>
	close(wfd);
  8001e6:	89 34 24             	mov    %esi,(%esp)
  8001e9:	e8 69 14 00 00       	call   801657 <close>
	rfd = pfds[0];
  8001ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  8001f4:	83 c4 08             	add    $0x8,%esp
  8001f7:	6a 00                	push   $0x0
  8001f9:	68 9f 30 80 00       	push   $0x80309f
  8001fe:	e8 39 1a 00 00       	call   801c3c <open>
  800203:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800206:	83 c4 10             	add    $0x10,%esp
  800209:	85 c0                	test   %eax,%eax
  80020b:	78 57                	js     800264 <umain+0x175>
  80020d:	be 01 00 00 00       	mov    $0x1,%esi
	nloff = 0;
  800212:	bf 00 00 00 00       	mov    $0x0,%edi
  800217:	e9 9a 00 00 00       	jmp    8002b6 <umain+0x1c7>
		panic("open testshell.sh: %e", rfd);
  80021c:	50                   	push   %eax
  80021d:	68 55 30 80 00       	push   $0x803055
  800222:	6a 13                	push   $0x13
  800224:	68 6b 30 80 00       	push   $0x80306b
  800229:	e8 e8 02 00 00       	call   800516 <_panic>
		panic("pipe: %e", wfd);
  80022e:	50                   	push   %eax
  80022f:	68 7c 30 80 00       	push   $0x80307c
  800234:	6a 16                	push   $0x16
  800236:	68 6b 30 80 00       	push   $0x80306b
  80023b:	e8 d6 02 00 00       	call   800516 <_panic>
		panic("fork: %e", r);
  800240:	50                   	push   %eax
  800241:	68 85 30 80 00       	push   $0x803085
  800246:	6a 1b                	push   $0x1b
  800248:	68 6b 30 80 00       	push   $0x80306b
  80024d:	e8 c4 02 00 00       	call   800516 <_panic>
			panic("spawn: %e", r);
  800252:	50                   	push   %eax
  800253:	68 95 30 80 00       	push   $0x803095
  800258:	6a 26                	push   $0x26
  80025a:	68 6b 30 80 00       	push   $0x80306b
  80025f:	e8 b2 02 00 00       	call   800516 <_panic>
		panic("open testshell.key for reading: %e", kfd);
  800264:	50                   	push   %eax
  800265:	68 08 30 80 00       	push   $0x803008
  80026a:	6a 32                	push   $0x32
  80026c:	68 6b 30 80 00       	push   $0x80306b
  800271:	e8 a0 02 00 00       	call   800516 <_panic>
			panic("reading testshell.out: %e", n1);
  800276:	53                   	push   %ebx
  800277:	68 ad 30 80 00       	push   $0x8030ad
  80027c:	6a 39                	push   $0x39
  80027e:	68 6b 30 80 00       	push   $0x80306b
  800283:	e8 8e 02 00 00       	call   800516 <_panic>
			panic("reading testshell.key: %e", n2);
  800288:	50                   	push   %eax
  800289:	68 c7 30 80 00       	push   $0x8030c7
  80028e:	6a 3b                	push   $0x3b
  800290:	68 6b 30 80 00       	push   $0x80306b
  800295:	e8 7c 02 00 00       	call   800516 <_panic>
			wrong(rfd, kfd, nloff);
  80029a:	83 ec 04             	sub    $0x4,%esp
  80029d:	57                   	push   %edi
  80029e:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002a1:	ff 75 d0             	pushl  -0x30(%ebp)
  8002a4:	e8 8a fd ff ff       	call   800033 <wrong>
  8002a9:	83 c4 10             	add    $0x10,%esp
			nloff = off+1;
  8002ac:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002b0:	0f 44 fe             	cmove  %esi,%edi
  8002b3:	83 c6 01             	add    $0x1,%esi
		n1 = read(rfd, &c1, 1);
  8002b6:	83 ec 04             	sub    $0x4,%esp
  8002b9:	6a 01                	push   $0x1
  8002bb:	8d 45 e7             	lea    -0x19(%ebp),%eax
  8002be:	50                   	push   %eax
  8002bf:	ff 75 d0             	pushl  -0x30(%ebp)
  8002c2:	e8 da 14 00 00       	call   8017a1 <read>
  8002c7:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  8002c9:	83 c4 0c             	add    $0xc,%esp
  8002cc:	6a 01                	push   $0x1
  8002ce:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  8002d1:	50                   	push   %eax
  8002d2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002d5:	e8 c7 14 00 00       	call   8017a1 <read>
		if (n1 < 0)
  8002da:	83 c4 10             	add    $0x10,%esp
  8002dd:	85 db                	test   %ebx,%ebx
  8002df:	78 95                	js     800276 <umain+0x187>
		if (n2 < 0)
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	78 a3                	js     800288 <umain+0x199>
		if (n1 == 0 && n2 == 0)
  8002e5:	89 da                	mov    %ebx,%edx
  8002e7:	09 c2                	or     %eax,%edx
  8002e9:	74 15                	je     800300 <umain+0x211>
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002eb:	83 fb 01             	cmp    $0x1,%ebx
  8002ee:	75 aa                	jne    80029a <umain+0x1ab>
  8002f0:	83 f8 01             	cmp    $0x1,%eax
  8002f3:	75 a5                	jne    80029a <umain+0x1ab>
  8002f5:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002f9:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002fc:	75 9c                	jne    80029a <umain+0x1ab>
  8002fe:	eb ac                	jmp    8002ac <umain+0x1bd>
	cprintf("shell ran correctly\n");
  800300:	83 ec 0c             	sub    $0xc,%esp
  800303:	68 e1 30 80 00       	push   $0x8030e1
  800308:	e8 f0 02 00 00       	call   8005fd <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  80030d:	cc                   	int3   
}
  80030e:	83 c4 10             	add    $0x10,%esp
  800311:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800314:	5b                   	pop    %ebx
  800315:	5e                   	pop    %esi
  800316:	5f                   	pop    %edi
  800317:	5d                   	pop    %ebp
  800318:	c3                   	ret    

00800319 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800319:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  80031d:	b8 00 00 00 00       	mov    $0x0,%eax
  800322:	c3                   	ret    

00800323 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800323:	f3 0f 1e fb          	endbr32 
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80032d:	68 f6 30 80 00       	push   $0x8030f6
  800332:	ff 75 0c             	pushl  0xc(%ebp)
  800335:	e8 cd 08 00 00       	call   800c07 <strcpy>
	return 0;
}
  80033a:	b8 00 00 00 00       	mov    $0x0,%eax
  80033f:	c9                   	leave  
  800340:	c3                   	ret    

00800341 <devcons_write>:
{
  800341:	f3 0f 1e fb          	endbr32 
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	57                   	push   %edi
  800349:	56                   	push   %esi
  80034a:	53                   	push   %ebx
  80034b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800351:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800356:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80035c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80035f:	73 31                	jae    800392 <devcons_write+0x51>
		m = n - tot;
  800361:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800364:	29 f3                	sub    %esi,%ebx
  800366:	83 fb 7f             	cmp    $0x7f,%ebx
  800369:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80036e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800371:	83 ec 04             	sub    $0x4,%esp
  800374:	53                   	push   %ebx
  800375:	89 f0                	mov    %esi,%eax
  800377:	03 45 0c             	add    0xc(%ebp),%eax
  80037a:	50                   	push   %eax
  80037b:	57                   	push   %edi
  80037c:	e8 84 0a 00 00       	call   800e05 <memmove>
		sys_cputs(buf, m);
  800381:	83 c4 08             	add    $0x8,%esp
  800384:	53                   	push   %ebx
  800385:	57                   	push   %edi
  800386:	e8 36 0c 00 00       	call   800fc1 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80038b:	01 de                	add    %ebx,%esi
  80038d:	83 c4 10             	add    $0x10,%esp
  800390:	eb ca                	jmp    80035c <devcons_write+0x1b>
}
  800392:	89 f0                	mov    %esi,%eax
  800394:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800397:	5b                   	pop    %ebx
  800398:	5e                   	pop    %esi
  800399:	5f                   	pop    %edi
  80039a:	5d                   	pop    %ebp
  80039b:	c3                   	ret    

0080039c <devcons_read>:
{
  80039c:	f3 0f 1e fb          	endbr32 
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8003ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8003af:	74 21                	je     8003d2 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8003b1:	e8 2d 0c 00 00       	call   800fe3 <sys_cgetc>
  8003b6:	85 c0                	test   %eax,%eax
  8003b8:	75 07                	jne    8003c1 <devcons_read+0x25>
		sys_yield();
  8003ba:	e8 8e 0c 00 00       	call   80104d <sys_yield>
  8003bf:	eb f0                	jmp    8003b1 <devcons_read+0x15>
	if (c < 0)
  8003c1:	78 0f                	js     8003d2 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8003c3:	83 f8 04             	cmp    $0x4,%eax
  8003c6:	74 0c                	je     8003d4 <devcons_read+0x38>
	*(char*)vbuf = c;
  8003c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003cb:	88 02                	mov    %al,(%edx)
	return 1;
  8003cd:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8003d2:	c9                   	leave  
  8003d3:	c3                   	ret    
		return 0;
  8003d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d9:	eb f7                	jmp    8003d2 <devcons_read+0x36>

008003db <cputchar>:
{
  8003db:	f3 0f 1e fb          	endbr32 
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e8:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8003eb:	6a 01                	push   $0x1
  8003ed:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003f0:	50                   	push   %eax
  8003f1:	e8 cb 0b 00 00       	call   800fc1 <sys_cputs>
}
  8003f6:	83 c4 10             	add    $0x10,%esp
  8003f9:	c9                   	leave  
  8003fa:	c3                   	ret    

008003fb <getchar>:
{
  8003fb:	f3 0f 1e fb          	endbr32 
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800405:	6a 01                	push   $0x1
  800407:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80040a:	50                   	push   %eax
  80040b:	6a 00                	push   $0x0
  80040d:	e8 8f 13 00 00       	call   8017a1 <read>
	if (r < 0)
  800412:	83 c4 10             	add    $0x10,%esp
  800415:	85 c0                	test   %eax,%eax
  800417:	78 06                	js     80041f <getchar+0x24>
	if (r < 1)
  800419:	74 06                	je     800421 <getchar+0x26>
	return c;
  80041b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80041f:	c9                   	leave  
  800420:	c3                   	ret    
		return -E_EOF;
  800421:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800426:	eb f7                	jmp    80041f <getchar+0x24>

00800428 <iscons>:
{
  800428:	f3 0f 1e fb          	endbr32 
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800432:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800435:	50                   	push   %eax
  800436:	ff 75 08             	pushl  0x8(%ebp)
  800439:	e8 db 10 00 00       	call   801519 <fd_lookup>
  80043e:	83 c4 10             	add    $0x10,%esp
  800441:	85 c0                	test   %eax,%eax
  800443:	78 11                	js     800456 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  800445:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800448:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80044e:	39 10                	cmp    %edx,(%eax)
  800450:	0f 94 c0             	sete   %al
  800453:	0f b6 c0             	movzbl %al,%eax
}
  800456:	c9                   	leave  
  800457:	c3                   	ret    

00800458 <opencons>:
{
  800458:	f3 0f 1e fb          	endbr32 
  80045c:	55                   	push   %ebp
  80045d:	89 e5                	mov    %esp,%ebp
  80045f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800462:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800465:	50                   	push   %eax
  800466:	e8 58 10 00 00       	call   8014c3 <fd_alloc>
  80046b:	83 c4 10             	add    $0x10,%esp
  80046e:	85 c0                	test   %eax,%eax
  800470:	78 3a                	js     8004ac <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800472:	83 ec 04             	sub    $0x4,%esp
  800475:	68 07 04 00 00       	push   $0x407
  80047a:	ff 75 f4             	pushl  -0xc(%ebp)
  80047d:	6a 00                	push   $0x0
  80047f:	e8 ec 0b 00 00       	call   801070 <sys_page_alloc>
  800484:	83 c4 10             	add    $0x10,%esp
  800487:	85 c0                	test   %eax,%eax
  800489:	78 21                	js     8004ac <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80048b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80048e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800494:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800496:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800499:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8004a0:	83 ec 0c             	sub    $0xc,%esp
  8004a3:	50                   	push   %eax
  8004a4:	e8 eb 0f 00 00       	call   801494 <fd2num>
  8004a9:	83 c4 10             	add    $0x10,%esp
}
  8004ac:	c9                   	leave  
  8004ad:	c3                   	ret    

008004ae <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8004ae:	f3 0f 1e fb          	endbr32 
  8004b2:	55                   	push   %ebp
  8004b3:	89 e5                	mov    %esp,%ebp
  8004b5:	56                   	push   %esi
  8004b6:	53                   	push   %ebx
  8004b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004ba:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8004bd:	e8 68 0b 00 00       	call   80102a <sys_getenvid>
  8004c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004c7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8004ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004cf:	a3 08 50 80 00       	mov    %eax,0x805008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004d4:	85 db                	test   %ebx,%ebx
  8004d6:	7e 07                	jle    8004df <libmain+0x31>
		binaryname = argv[0];
  8004d8:	8b 06                	mov    (%esi),%eax
  8004da:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	56                   	push   %esi
  8004e3:	53                   	push   %ebx
  8004e4:	e8 06 fc ff ff       	call   8000ef <umain>

	// exit gracefully
	exit();
  8004e9:	e8 0a 00 00 00       	call   8004f8 <exit>
}
  8004ee:	83 c4 10             	add    $0x10,%esp
  8004f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f4:	5b                   	pop    %ebx
  8004f5:	5e                   	pop    %esi
  8004f6:	5d                   	pop    %ebp
  8004f7:	c3                   	ret    

008004f8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004f8:	f3 0f 1e fb          	endbr32 
  8004fc:	55                   	push   %ebp
  8004fd:	89 e5                	mov    %esp,%ebp
  8004ff:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  800502:	e8 81 11 00 00       	call   801688 <close_all>
	sys_env_destroy(0);
  800507:	83 ec 0c             	sub    $0xc,%esp
  80050a:	6a 00                	push   $0x0
  80050c:	e8 f5 0a 00 00       	call   801006 <sys_env_destroy>
}
  800511:	83 c4 10             	add    $0x10,%esp
  800514:	c9                   	leave  
  800515:	c3                   	ret    

00800516 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800516:	f3 0f 1e fb          	endbr32 
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	56                   	push   %esi
  80051e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80051f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800522:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800528:	e8 fd 0a 00 00       	call   80102a <sys_getenvid>
  80052d:	83 ec 0c             	sub    $0xc,%esp
  800530:	ff 75 0c             	pushl  0xc(%ebp)
  800533:	ff 75 08             	pushl  0x8(%ebp)
  800536:	56                   	push   %esi
  800537:	50                   	push   %eax
  800538:	68 0c 31 80 00       	push   $0x80310c
  80053d:	e8 bb 00 00 00       	call   8005fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800542:	83 c4 18             	add    $0x18,%esp
  800545:	53                   	push   %ebx
  800546:	ff 75 10             	pushl  0x10(%ebp)
  800549:	e8 5a 00 00 00       	call   8005a8 <vcprintf>
	cprintf("\n");
  80054e:	c7 04 24 38 30 80 00 	movl   $0x803038,(%esp)
  800555:	e8 a3 00 00 00       	call   8005fd <cprintf>
  80055a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80055d:	cc                   	int3   
  80055e:	eb fd                	jmp    80055d <_panic+0x47>

00800560 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800560:	f3 0f 1e fb          	endbr32 
  800564:	55                   	push   %ebp
  800565:	89 e5                	mov    %esp,%ebp
  800567:	53                   	push   %ebx
  800568:	83 ec 04             	sub    $0x4,%esp
  80056b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80056e:	8b 13                	mov    (%ebx),%edx
  800570:	8d 42 01             	lea    0x1(%edx),%eax
  800573:	89 03                	mov    %eax,(%ebx)
  800575:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800578:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80057c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800581:	74 09                	je     80058c <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800583:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800587:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80058a:	c9                   	leave  
  80058b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80058c:	83 ec 08             	sub    $0x8,%esp
  80058f:	68 ff 00 00 00       	push   $0xff
  800594:	8d 43 08             	lea    0x8(%ebx),%eax
  800597:	50                   	push   %eax
  800598:	e8 24 0a 00 00       	call   800fc1 <sys_cputs>
		b->idx = 0;
  80059d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8005a3:	83 c4 10             	add    $0x10,%esp
  8005a6:	eb db                	jmp    800583 <putch+0x23>

008005a8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8005a8:	f3 0f 1e fb          	endbr32 
  8005ac:	55                   	push   %ebp
  8005ad:	89 e5                	mov    %esp,%ebp
  8005af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8005b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005bc:	00 00 00 
	b.cnt = 0;
  8005bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005c9:	ff 75 0c             	pushl  0xc(%ebp)
  8005cc:	ff 75 08             	pushl  0x8(%ebp)
  8005cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005d5:	50                   	push   %eax
  8005d6:	68 60 05 80 00       	push   $0x800560
  8005db:	e8 20 01 00 00       	call   800700 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005e0:	83 c4 08             	add    $0x8,%esp
  8005e3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005ef:	50                   	push   %eax
  8005f0:	e8 cc 09 00 00       	call   800fc1 <sys_cputs>

	return b.cnt;
}
  8005f5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005fb:	c9                   	leave  
  8005fc:	c3                   	ret    

008005fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005fd:	f3 0f 1e fb          	endbr32 
  800601:	55                   	push   %ebp
  800602:	89 e5                	mov    %esp,%ebp
  800604:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800607:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80060a:	50                   	push   %eax
  80060b:	ff 75 08             	pushl  0x8(%ebp)
  80060e:	e8 95 ff ff ff       	call   8005a8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800613:	c9                   	leave  
  800614:	c3                   	ret    

00800615 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800615:	55                   	push   %ebp
  800616:	89 e5                	mov    %esp,%ebp
  800618:	57                   	push   %edi
  800619:	56                   	push   %esi
  80061a:	53                   	push   %ebx
  80061b:	83 ec 1c             	sub    $0x1c,%esp
  80061e:	89 c7                	mov    %eax,%edi
  800620:	89 d6                	mov    %edx,%esi
  800622:	8b 45 08             	mov    0x8(%ebp),%eax
  800625:	8b 55 0c             	mov    0xc(%ebp),%edx
  800628:	89 d1                	mov    %edx,%ecx
  80062a:	89 c2                	mov    %eax,%edx
  80062c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800632:	8b 45 10             	mov    0x10(%ebp),%eax
  800635:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800638:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80063b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800642:	39 c2                	cmp    %eax,%edx
  800644:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800647:	72 3e                	jb     800687 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800649:	83 ec 0c             	sub    $0xc,%esp
  80064c:	ff 75 18             	pushl  0x18(%ebp)
  80064f:	83 eb 01             	sub    $0x1,%ebx
  800652:	53                   	push   %ebx
  800653:	50                   	push   %eax
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	ff 75 e4             	pushl  -0x1c(%ebp)
  80065a:	ff 75 e0             	pushl  -0x20(%ebp)
  80065d:	ff 75 dc             	pushl  -0x24(%ebp)
  800660:	ff 75 d8             	pushl  -0x28(%ebp)
  800663:	e8 f8 26 00 00       	call   802d60 <__udivdi3>
  800668:	83 c4 18             	add    $0x18,%esp
  80066b:	52                   	push   %edx
  80066c:	50                   	push   %eax
  80066d:	89 f2                	mov    %esi,%edx
  80066f:	89 f8                	mov    %edi,%eax
  800671:	e8 9f ff ff ff       	call   800615 <printnum>
  800676:	83 c4 20             	add    $0x20,%esp
  800679:	eb 13                	jmp    80068e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80067b:	83 ec 08             	sub    $0x8,%esp
  80067e:	56                   	push   %esi
  80067f:	ff 75 18             	pushl  0x18(%ebp)
  800682:	ff d7                	call   *%edi
  800684:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800687:	83 eb 01             	sub    $0x1,%ebx
  80068a:	85 db                	test   %ebx,%ebx
  80068c:	7f ed                	jg     80067b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80068e:	83 ec 08             	sub    $0x8,%esp
  800691:	56                   	push   %esi
  800692:	83 ec 04             	sub    $0x4,%esp
  800695:	ff 75 e4             	pushl  -0x1c(%ebp)
  800698:	ff 75 e0             	pushl  -0x20(%ebp)
  80069b:	ff 75 dc             	pushl  -0x24(%ebp)
  80069e:	ff 75 d8             	pushl  -0x28(%ebp)
  8006a1:	e8 ca 27 00 00       	call   802e70 <__umoddi3>
  8006a6:	83 c4 14             	add    $0x14,%esp
  8006a9:	0f be 80 2f 31 80 00 	movsbl 0x80312f(%eax),%eax
  8006b0:	50                   	push   %eax
  8006b1:	ff d7                	call   *%edi
}
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b9:	5b                   	pop    %ebx
  8006ba:	5e                   	pop    %esi
  8006bb:	5f                   	pop    %edi
  8006bc:	5d                   	pop    %ebp
  8006bd:	c3                   	ret    

008006be <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006be:	f3 0f 1e fb          	endbr32 
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006c8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006cc:	8b 10                	mov    (%eax),%edx
  8006ce:	3b 50 04             	cmp    0x4(%eax),%edx
  8006d1:	73 0a                	jae    8006dd <sprintputch+0x1f>
		*b->buf++ = ch;
  8006d3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006d6:	89 08                	mov    %ecx,(%eax)
  8006d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006db:	88 02                	mov    %al,(%edx)
}
  8006dd:	5d                   	pop    %ebp
  8006de:	c3                   	ret    

008006df <printfmt>:
{
  8006df:	f3 0f 1e fb          	endbr32 
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8006e9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006ec:	50                   	push   %eax
  8006ed:	ff 75 10             	pushl  0x10(%ebp)
  8006f0:	ff 75 0c             	pushl  0xc(%ebp)
  8006f3:	ff 75 08             	pushl  0x8(%ebp)
  8006f6:	e8 05 00 00 00       	call   800700 <vprintfmt>
}
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	c9                   	leave  
  8006ff:	c3                   	ret    

00800700 <vprintfmt>:
{
  800700:	f3 0f 1e fb          	endbr32 
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	57                   	push   %edi
  800708:	56                   	push   %esi
  800709:	53                   	push   %ebx
  80070a:	83 ec 3c             	sub    $0x3c,%esp
  80070d:	8b 75 08             	mov    0x8(%ebp),%esi
  800710:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800713:	8b 7d 10             	mov    0x10(%ebp),%edi
  800716:	e9 8e 03 00 00       	jmp    800aa9 <vprintfmt+0x3a9>
		padc = ' ';
  80071b:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80071f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800726:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80072d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800734:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800739:	8d 47 01             	lea    0x1(%edi),%eax
  80073c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80073f:	0f b6 17             	movzbl (%edi),%edx
  800742:	8d 42 dd             	lea    -0x23(%edx),%eax
  800745:	3c 55                	cmp    $0x55,%al
  800747:	0f 87 df 03 00 00    	ja     800b2c <vprintfmt+0x42c>
  80074d:	0f b6 c0             	movzbl %al,%eax
  800750:	3e ff 24 85 80 32 80 	notrack jmp *0x803280(,%eax,4)
  800757:	00 
  800758:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80075b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80075f:	eb d8                	jmp    800739 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800761:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800764:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800768:	eb cf                	jmp    800739 <vprintfmt+0x39>
  80076a:	0f b6 d2             	movzbl %dl,%edx
  80076d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800770:	b8 00 00 00 00       	mov    $0x0,%eax
  800775:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800778:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80077b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80077f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800782:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800785:	83 f9 09             	cmp    $0x9,%ecx
  800788:	77 55                	ja     8007df <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80078a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  80078d:	eb e9                	jmp    800778 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	8b 00                	mov    (%eax),%eax
  800794:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8d 40 04             	lea    0x4(%eax),%eax
  80079d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8007a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8007a3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007a7:	79 90                	jns    800739 <vprintfmt+0x39>
				width = precision, precision = -1;
  8007a9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007af:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8007b6:	eb 81                	jmp    800739 <vprintfmt+0x39>
  8007b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007bb:	85 c0                	test   %eax,%eax
  8007bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c2:	0f 49 d0             	cmovns %eax,%edx
  8007c5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8007c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8007cb:	e9 69 ff ff ff       	jmp    800739 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8007d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8007d3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8007da:	e9 5a ff ff ff       	jmp    800739 <vprintfmt+0x39>
  8007df:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8007e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e5:	eb bc                	jmp    8007a3 <vprintfmt+0xa3>
			lflag++;
  8007e7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8007ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8007ed:	e9 47 ff ff ff       	jmp    800739 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	8d 78 04             	lea    0x4(%eax),%edi
  8007f8:	83 ec 08             	sub    $0x8,%esp
  8007fb:	53                   	push   %ebx
  8007fc:	ff 30                	pushl  (%eax)
  8007fe:	ff d6                	call   *%esi
			break;
  800800:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800803:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800806:	e9 9b 02 00 00       	jmp    800aa6 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8d 78 04             	lea    0x4(%eax),%edi
  800811:	8b 00                	mov    (%eax),%eax
  800813:	99                   	cltd   
  800814:	31 d0                	xor    %edx,%eax
  800816:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800818:	83 f8 0f             	cmp    $0xf,%eax
  80081b:	7f 23                	jg     800840 <vprintfmt+0x140>
  80081d:	8b 14 85 e0 33 80 00 	mov    0x8033e0(,%eax,4),%edx
  800824:	85 d2                	test   %edx,%edx
  800826:	74 18                	je     800840 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800828:	52                   	push   %edx
  800829:	68 e5 35 80 00       	push   $0x8035e5
  80082e:	53                   	push   %ebx
  80082f:	56                   	push   %esi
  800830:	e8 aa fe ff ff       	call   8006df <printfmt>
  800835:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800838:	89 7d 14             	mov    %edi,0x14(%ebp)
  80083b:	e9 66 02 00 00       	jmp    800aa6 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800840:	50                   	push   %eax
  800841:	68 47 31 80 00       	push   $0x803147
  800846:	53                   	push   %ebx
  800847:	56                   	push   %esi
  800848:	e8 92 fe ff ff       	call   8006df <printfmt>
  80084d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800850:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800853:	e9 4e 02 00 00       	jmp    800aa6 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800858:	8b 45 14             	mov    0x14(%ebp),%eax
  80085b:	83 c0 04             	add    $0x4,%eax
  80085e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800861:	8b 45 14             	mov    0x14(%ebp),%eax
  800864:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800866:	85 d2                	test   %edx,%edx
  800868:	b8 40 31 80 00       	mov    $0x803140,%eax
  80086d:	0f 45 c2             	cmovne %edx,%eax
  800870:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800873:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800877:	7e 06                	jle    80087f <vprintfmt+0x17f>
  800879:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80087d:	75 0d                	jne    80088c <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80087f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800882:	89 c7                	mov    %eax,%edi
  800884:	03 45 e0             	add    -0x20(%ebp),%eax
  800887:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80088a:	eb 55                	jmp    8008e1 <vprintfmt+0x1e1>
  80088c:	83 ec 08             	sub    $0x8,%esp
  80088f:	ff 75 d8             	pushl  -0x28(%ebp)
  800892:	ff 75 cc             	pushl  -0x34(%ebp)
  800895:	e8 46 03 00 00       	call   800be0 <strnlen>
  80089a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80089d:	29 c2                	sub    %eax,%edx
  80089f:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8008a2:	83 c4 10             	add    $0x10,%esp
  8008a5:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8008a7:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8008ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8008ae:	85 ff                	test   %edi,%edi
  8008b0:	7e 11                	jle    8008c3 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8008b2:	83 ec 08             	sub    $0x8,%esp
  8008b5:	53                   	push   %ebx
  8008b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8008b9:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8008bb:	83 ef 01             	sub    $0x1,%edi
  8008be:	83 c4 10             	add    $0x10,%esp
  8008c1:	eb eb                	jmp    8008ae <vprintfmt+0x1ae>
  8008c3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8008c6:	85 d2                	test   %edx,%edx
  8008c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cd:	0f 49 c2             	cmovns %edx,%eax
  8008d0:	29 c2                	sub    %eax,%edx
  8008d2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8008d5:	eb a8                	jmp    80087f <vprintfmt+0x17f>
					putch(ch, putdat);
  8008d7:	83 ec 08             	sub    $0x8,%esp
  8008da:	53                   	push   %ebx
  8008db:	52                   	push   %edx
  8008dc:	ff d6                	call   *%esi
  8008de:	83 c4 10             	add    $0x10,%esp
  8008e1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8008e4:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008e6:	83 c7 01             	add    $0x1,%edi
  8008e9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008ed:	0f be d0             	movsbl %al,%edx
  8008f0:	85 d2                	test   %edx,%edx
  8008f2:	74 4b                	je     80093f <vprintfmt+0x23f>
  8008f4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008f8:	78 06                	js     800900 <vprintfmt+0x200>
  8008fa:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8008fe:	78 1e                	js     80091e <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  800900:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800904:	74 d1                	je     8008d7 <vprintfmt+0x1d7>
  800906:	0f be c0             	movsbl %al,%eax
  800909:	83 e8 20             	sub    $0x20,%eax
  80090c:	83 f8 5e             	cmp    $0x5e,%eax
  80090f:	76 c6                	jbe    8008d7 <vprintfmt+0x1d7>
					putch('?', putdat);
  800911:	83 ec 08             	sub    $0x8,%esp
  800914:	53                   	push   %ebx
  800915:	6a 3f                	push   $0x3f
  800917:	ff d6                	call   *%esi
  800919:	83 c4 10             	add    $0x10,%esp
  80091c:	eb c3                	jmp    8008e1 <vprintfmt+0x1e1>
  80091e:	89 cf                	mov    %ecx,%edi
  800920:	eb 0e                	jmp    800930 <vprintfmt+0x230>
				putch(' ', putdat);
  800922:	83 ec 08             	sub    $0x8,%esp
  800925:	53                   	push   %ebx
  800926:	6a 20                	push   $0x20
  800928:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80092a:	83 ef 01             	sub    $0x1,%edi
  80092d:	83 c4 10             	add    $0x10,%esp
  800930:	85 ff                	test   %edi,%edi
  800932:	7f ee                	jg     800922 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800934:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800937:	89 45 14             	mov    %eax,0x14(%ebp)
  80093a:	e9 67 01 00 00       	jmp    800aa6 <vprintfmt+0x3a6>
  80093f:	89 cf                	mov    %ecx,%edi
  800941:	eb ed                	jmp    800930 <vprintfmt+0x230>
	if (lflag >= 2)
  800943:	83 f9 01             	cmp    $0x1,%ecx
  800946:	7f 1b                	jg     800963 <vprintfmt+0x263>
	else if (lflag)
  800948:	85 c9                	test   %ecx,%ecx
  80094a:	74 63                	je     8009af <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80094c:	8b 45 14             	mov    0x14(%ebp),%eax
  80094f:	8b 00                	mov    (%eax),%eax
  800951:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800954:	99                   	cltd   
  800955:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800958:	8b 45 14             	mov    0x14(%ebp),%eax
  80095b:	8d 40 04             	lea    0x4(%eax),%eax
  80095e:	89 45 14             	mov    %eax,0x14(%ebp)
  800961:	eb 17                	jmp    80097a <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800963:	8b 45 14             	mov    0x14(%ebp),%eax
  800966:	8b 50 04             	mov    0x4(%eax),%edx
  800969:	8b 00                	mov    (%eax),%eax
  80096b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80096e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800971:	8b 45 14             	mov    0x14(%ebp),%eax
  800974:	8d 40 08             	lea    0x8(%eax),%eax
  800977:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80097a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80097d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800980:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800985:	85 c9                	test   %ecx,%ecx
  800987:	0f 89 ff 00 00 00    	jns    800a8c <vprintfmt+0x38c>
				putch('-', putdat);
  80098d:	83 ec 08             	sub    $0x8,%esp
  800990:	53                   	push   %ebx
  800991:	6a 2d                	push   $0x2d
  800993:	ff d6                	call   *%esi
				num = -(long long) num;
  800995:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800998:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80099b:	f7 da                	neg    %edx
  80099d:	83 d1 00             	adc    $0x0,%ecx
  8009a0:	f7 d9                	neg    %ecx
  8009a2:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8009a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009aa:	e9 dd 00 00 00       	jmp    800a8c <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8009af:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b2:	8b 00                	mov    (%eax),%eax
  8009b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009b7:	99                   	cltd   
  8009b8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8009bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8009be:	8d 40 04             	lea    0x4(%eax),%eax
  8009c1:	89 45 14             	mov    %eax,0x14(%ebp)
  8009c4:	eb b4                	jmp    80097a <vprintfmt+0x27a>
	if (lflag >= 2)
  8009c6:	83 f9 01             	cmp    $0x1,%ecx
  8009c9:	7f 1e                	jg     8009e9 <vprintfmt+0x2e9>
	else if (lflag)
  8009cb:	85 c9                	test   %ecx,%ecx
  8009cd:	74 32                	je     800a01 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8009cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d2:	8b 10                	mov    (%eax),%edx
  8009d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009d9:	8d 40 04             	lea    0x4(%eax),%eax
  8009dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009df:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8009e4:	e9 a3 00 00 00       	jmp    800a8c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8009e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ec:	8b 10                	mov    (%eax),%edx
  8009ee:	8b 48 04             	mov    0x4(%eax),%ecx
  8009f1:	8d 40 08             	lea    0x8(%eax),%eax
  8009f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009f7:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8009fc:	e9 8b 00 00 00       	jmp    800a8c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800a01:	8b 45 14             	mov    0x14(%ebp),%eax
  800a04:	8b 10                	mov    (%eax),%edx
  800a06:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a0b:	8d 40 04             	lea    0x4(%eax),%eax
  800a0e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800a11:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800a16:	eb 74                	jmp    800a8c <vprintfmt+0x38c>
	if (lflag >= 2)
  800a18:	83 f9 01             	cmp    $0x1,%ecx
  800a1b:	7f 1b                	jg     800a38 <vprintfmt+0x338>
	else if (lflag)
  800a1d:	85 c9                	test   %ecx,%ecx
  800a1f:	74 2c                	je     800a4d <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800a21:	8b 45 14             	mov    0x14(%ebp),%eax
  800a24:	8b 10                	mov    (%eax),%edx
  800a26:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a2b:	8d 40 04             	lea    0x4(%eax),%eax
  800a2e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800a31:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800a36:	eb 54                	jmp    800a8c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800a38:	8b 45 14             	mov    0x14(%ebp),%eax
  800a3b:	8b 10                	mov    (%eax),%edx
  800a3d:	8b 48 04             	mov    0x4(%eax),%ecx
  800a40:	8d 40 08             	lea    0x8(%eax),%eax
  800a43:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800a46:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800a4b:	eb 3f                	jmp    800a8c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800a4d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a50:	8b 10                	mov    (%eax),%edx
  800a52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a57:	8d 40 04             	lea    0x4(%eax),%eax
  800a5a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800a5d:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800a62:	eb 28                	jmp    800a8c <vprintfmt+0x38c>
			putch('0', putdat);
  800a64:	83 ec 08             	sub    $0x8,%esp
  800a67:	53                   	push   %ebx
  800a68:	6a 30                	push   $0x30
  800a6a:	ff d6                	call   *%esi
			putch('x', putdat);
  800a6c:	83 c4 08             	add    $0x8,%esp
  800a6f:	53                   	push   %ebx
  800a70:	6a 78                	push   $0x78
  800a72:	ff d6                	call   *%esi
			num = (unsigned long long)
  800a74:	8b 45 14             	mov    0x14(%ebp),%eax
  800a77:	8b 10                	mov    (%eax),%edx
  800a79:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800a7e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800a81:	8d 40 04             	lea    0x4(%eax),%eax
  800a84:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a87:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800a8c:	83 ec 0c             	sub    $0xc,%esp
  800a8f:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800a93:	57                   	push   %edi
  800a94:	ff 75 e0             	pushl  -0x20(%ebp)
  800a97:	50                   	push   %eax
  800a98:	51                   	push   %ecx
  800a99:	52                   	push   %edx
  800a9a:	89 da                	mov    %ebx,%edx
  800a9c:	89 f0                	mov    %esi,%eax
  800a9e:	e8 72 fb ff ff       	call   800615 <printnum>
			break;
  800aa3:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800aa6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  800aa9:	83 c7 01             	add    $0x1,%edi
  800aac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ab0:	83 f8 25             	cmp    $0x25,%eax
  800ab3:	0f 84 62 fc ff ff    	je     80071b <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  800ab9:	85 c0                	test   %eax,%eax
  800abb:	0f 84 8b 00 00 00    	je     800b4c <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  800ac1:	83 ec 08             	sub    $0x8,%esp
  800ac4:	53                   	push   %ebx
  800ac5:	50                   	push   %eax
  800ac6:	ff d6                	call   *%esi
  800ac8:	83 c4 10             	add    $0x10,%esp
  800acb:	eb dc                	jmp    800aa9 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800acd:	83 f9 01             	cmp    $0x1,%ecx
  800ad0:	7f 1b                	jg     800aed <vprintfmt+0x3ed>
	else if (lflag)
  800ad2:	85 c9                	test   %ecx,%ecx
  800ad4:	74 2c                	je     800b02 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800ad6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad9:	8b 10                	mov    (%eax),%edx
  800adb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae0:	8d 40 04             	lea    0x4(%eax),%eax
  800ae3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800ae6:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800aeb:	eb 9f                	jmp    800a8c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800aed:	8b 45 14             	mov    0x14(%ebp),%eax
  800af0:	8b 10                	mov    (%eax),%edx
  800af2:	8b 48 04             	mov    0x4(%eax),%ecx
  800af5:	8d 40 08             	lea    0x8(%eax),%eax
  800af8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800afb:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800b00:	eb 8a                	jmp    800a8c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800b02:	8b 45 14             	mov    0x14(%ebp),%eax
  800b05:	8b 10                	mov    (%eax),%edx
  800b07:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0c:	8d 40 04             	lea    0x4(%eax),%eax
  800b0f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800b12:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800b17:	e9 70 ff ff ff       	jmp    800a8c <vprintfmt+0x38c>
			putch(ch, putdat);
  800b1c:	83 ec 08             	sub    $0x8,%esp
  800b1f:	53                   	push   %ebx
  800b20:	6a 25                	push   $0x25
  800b22:	ff d6                	call   *%esi
			break;
  800b24:	83 c4 10             	add    $0x10,%esp
  800b27:	e9 7a ff ff ff       	jmp    800aa6 <vprintfmt+0x3a6>
			putch('%', putdat);
  800b2c:	83 ec 08             	sub    $0x8,%esp
  800b2f:	53                   	push   %ebx
  800b30:	6a 25                	push   $0x25
  800b32:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800b34:	83 c4 10             	add    $0x10,%esp
  800b37:	89 f8                	mov    %edi,%eax
  800b39:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800b3d:	74 05                	je     800b44 <vprintfmt+0x444>
  800b3f:	83 e8 01             	sub    $0x1,%eax
  800b42:	eb f5                	jmp    800b39 <vprintfmt+0x439>
  800b44:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b47:	e9 5a ff ff ff       	jmp    800aa6 <vprintfmt+0x3a6>
}
  800b4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b54:	f3 0f 1e fb          	endbr32 
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	83 ec 18             	sub    $0x18,%esp
  800b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b61:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b64:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b67:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b6b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b75:	85 c0                	test   %eax,%eax
  800b77:	74 26                	je     800b9f <vsnprintf+0x4b>
  800b79:	85 d2                	test   %edx,%edx
  800b7b:	7e 22                	jle    800b9f <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b7d:	ff 75 14             	pushl  0x14(%ebp)
  800b80:	ff 75 10             	pushl  0x10(%ebp)
  800b83:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b86:	50                   	push   %eax
  800b87:	68 be 06 80 00       	push   $0x8006be
  800b8c:	e8 6f fb ff ff       	call   800700 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b91:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b94:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b9a:	83 c4 10             	add    $0x10,%esp
}
  800b9d:	c9                   	leave  
  800b9e:	c3                   	ret    
		return -E_INVAL;
  800b9f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ba4:	eb f7                	jmp    800b9d <vsnprintf+0x49>

00800ba6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ba6:	f3 0f 1e fb          	endbr32 
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  800bb0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800bb3:	50                   	push   %eax
  800bb4:	ff 75 10             	pushl  0x10(%ebp)
  800bb7:	ff 75 0c             	pushl  0xc(%ebp)
  800bba:	ff 75 08             	pushl  0x8(%ebp)
  800bbd:	e8 92 ff ff ff       	call   800b54 <vsnprintf>
	va_end(ap);

	return rc;
}
  800bc2:	c9                   	leave  
  800bc3:	c3                   	ret    

00800bc4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bc4:	f3 0f 1e fb          	endbr32 
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800bce:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bd7:	74 05                	je     800bde <strlen+0x1a>
		n++;
  800bd9:	83 c0 01             	add    $0x1,%eax
  800bdc:	eb f5                	jmp    800bd3 <strlen+0xf>
	return n;
}
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800be0:	f3 0f 1e fb          	endbr32 
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bea:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bed:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf2:	39 d0                	cmp    %edx,%eax
  800bf4:	74 0d                	je     800c03 <strnlen+0x23>
  800bf6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800bfa:	74 05                	je     800c01 <strnlen+0x21>
		n++;
  800bfc:	83 c0 01             	add    $0x1,%eax
  800bff:	eb f1                	jmp    800bf2 <strnlen+0x12>
  800c01:	89 c2                	mov    %eax,%edx
	return n;
}
  800c03:	89 d0                	mov    %edx,%eax
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c07:	f3 0f 1e fb          	endbr32 
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	53                   	push   %ebx
  800c0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c15:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800c1e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800c21:	83 c0 01             	add    $0x1,%eax
  800c24:	84 d2                	test   %dl,%dl
  800c26:	75 f2                	jne    800c1a <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800c28:	89 c8                	mov    %ecx,%eax
  800c2a:	5b                   	pop    %ebx
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c2d:	f3 0f 1e fb          	endbr32 
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	53                   	push   %ebx
  800c35:	83 ec 10             	sub    $0x10,%esp
  800c38:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c3b:	53                   	push   %ebx
  800c3c:	e8 83 ff ff ff       	call   800bc4 <strlen>
  800c41:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800c44:	ff 75 0c             	pushl  0xc(%ebp)
  800c47:	01 d8                	add    %ebx,%eax
  800c49:	50                   	push   %eax
  800c4a:	e8 b8 ff ff ff       	call   800c07 <strcpy>
	return dst;
}
  800c4f:	89 d8                	mov    %ebx,%eax
  800c51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c54:	c9                   	leave  
  800c55:	c3                   	ret    

00800c56 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c56:	f3 0f 1e fb          	endbr32 
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	56                   	push   %esi
  800c5e:	53                   	push   %ebx
  800c5f:	8b 75 08             	mov    0x8(%ebp),%esi
  800c62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c65:	89 f3                	mov    %esi,%ebx
  800c67:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c6a:	89 f0                	mov    %esi,%eax
  800c6c:	39 d8                	cmp    %ebx,%eax
  800c6e:	74 11                	je     800c81 <strncpy+0x2b>
		*dst++ = *src;
  800c70:	83 c0 01             	add    $0x1,%eax
  800c73:	0f b6 0a             	movzbl (%edx),%ecx
  800c76:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c79:	80 f9 01             	cmp    $0x1,%cl
  800c7c:	83 da ff             	sbb    $0xffffffff,%edx
  800c7f:	eb eb                	jmp    800c6c <strncpy+0x16>
	}
	return ret;
}
  800c81:	89 f0                	mov    %esi,%eax
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c87:	f3 0f 1e fb          	endbr32 
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	8b 75 08             	mov    0x8(%ebp),%esi
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	8b 55 10             	mov    0x10(%ebp),%edx
  800c99:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c9b:	85 d2                	test   %edx,%edx
  800c9d:	74 21                	je     800cc0 <strlcpy+0x39>
  800c9f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ca3:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800ca5:	39 c2                	cmp    %eax,%edx
  800ca7:	74 14                	je     800cbd <strlcpy+0x36>
  800ca9:	0f b6 19             	movzbl (%ecx),%ebx
  800cac:	84 db                	test   %bl,%bl
  800cae:	74 0b                	je     800cbb <strlcpy+0x34>
			*dst++ = *src++;
  800cb0:	83 c1 01             	add    $0x1,%ecx
  800cb3:	83 c2 01             	add    $0x1,%edx
  800cb6:	88 5a ff             	mov    %bl,-0x1(%edx)
  800cb9:	eb ea                	jmp    800ca5 <strlcpy+0x1e>
  800cbb:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800cbd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800cc0:	29 f0                	sub    %esi,%eax
}
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cc6:	f3 0f 1e fb          	endbr32 
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800cd3:	0f b6 01             	movzbl (%ecx),%eax
  800cd6:	84 c0                	test   %al,%al
  800cd8:	74 0c                	je     800ce6 <strcmp+0x20>
  800cda:	3a 02                	cmp    (%edx),%al
  800cdc:	75 08                	jne    800ce6 <strcmp+0x20>
		p++, q++;
  800cde:	83 c1 01             	add    $0x1,%ecx
  800ce1:	83 c2 01             	add    $0x1,%edx
  800ce4:	eb ed                	jmp    800cd3 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ce6:	0f b6 c0             	movzbl %al,%eax
  800ce9:	0f b6 12             	movzbl (%edx),%edx
  800cec:	29 d0                	sub    %edx,%eax
}
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cf0:	f3 0f 1e fb          	endbr32 
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	53                   	push   %ebx
  800cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cfe:	89 c3                	mov    %eax,%ebx
  800d00:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d03:	eb 06                	jmp    800d0b <strncmp+0x1b>
		n--, p++, q++;
  800d05:	83 c0 01             	add    $0x1,%eax
  800d08:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800d0b:	39 d8                	cmp    %ebx,%eax
  800d0d:	74 16                	je     800d25 <strncmp+0x35>
  800d0f:	0f b6 08             	movzbl (%eax),%ecx
  800d12:	84 c9                	test   %cl,%cl
  800d14:	74 04                	je     800d1a <strncmp+0x2a>
  800d16:	3a 0a                	cmp    (%edx),%cl
  800d18:	74 eb                	je     800d05 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d1a:	0f b6 00             	movzbl (%eax),%eax
  800d1d:	0f b6 12             	movzbl (%edx),%edx
  800d20:	29 d0                	sub    %edx,%eax
}
  800d22:	5b                   	pop    %ebx
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    
		return 0;
  800d25:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2a:	eb f6                	jmp    800d22 <strncmp+0x32>

00800d2c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d2c:	f3 0f 1e fb          	endbr32 
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	8b 45 08             	mov    0x8(%ebp),%eax
  800d36:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d3a:	0f b6 10             	movzbl (%eax),%edx
  800d3d:	84 d2                	test   %dl,%dl
  800d3f:	74 09                	je     800d4a <strchr+0x1e>
		if (*s == c)
  800d41:	38 ca                	cmp    %cl,%dl
  800d43:	74 0a                	je     800d4f <strchr+0x23>
	for (; *s; s++)
  800d45:	83 c0 01             	add    $0x1,%eax
  800d48:	eb f0                	jmp    800d3a <strchr+0xe>
			return (char *) s;
	return 0;
  800d4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800d51:	f3 0f 1e fb          	endbr32 
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800d5b:	6a 78                	push   $0x78
  800d5d:	ff 75 08             	pushl  0x8(%ebp)
  800d60:	e8 c7 ff ff ff       	call   800d2c <strchr>
  800d65:	83 c4 10             	add    $0x10,%esp
  800d68:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  800d6b:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800d70:	eb 0d                	jmp    800d7f <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800d72:	c1 e0 04             	shl    $0x4,%eax
  800d75:	0f be d2             	movsbl %dl,%edx
  800d78:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800d7c:	83 c1 01             	add    $0x1,%ecx
  800d7f:	0f b6 11             	movzbl (%ecx),%edx
  800d82:	84 d2                	test   %dl,%dl
  800d84:	74 11                	je     800d97 <atox+0x46>
		if (*p>='a'){
  800d86:	80 fa 60             	cmp    $0x60,%dl
  800d89:	7e e7                	jle    800d72 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800d8b:	c1 e0 04             	shl    $0x4,%eax
  800d8e:	0f be d2             	movsbl %dl,%edx
  800d91:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800d95:	eb e5                	jmp    800d7c <atox+0x2b>
	}

	return v;

}
  800d97:	c9                   	leave  
  800d98:	c3                   	ret    

00800d99 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d99:	f3 0f 1e fb          	endbr32 
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	8b 45 08             	mov    0x8(%ebp),%eax
  800da3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800da7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800daa:	38 ca                	cmp    %cl,%dl
  800dac:	74 09                	je     800db7 <strfind+0x1e>
  800dae:	84 d2                	test   %dl,%dl
  800db0:	74 05                	je     800db7 <strfind+0x1e>
	for (; *s; s++)
  800db2:	83 c0 01             	add    $0x1,%eax
  800db5:	eb f0                	jmp    800da7 <strfind+0xe>
			break;
	return (char *) s;
}
  800db7:	5d                   	pop    %ebp
  800db8:	c3                   	ret    

00800db9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800db9:	f3 0f 1e fb          	endbr32 
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	57                   	push   %edi
  800dc1:	56                   	push   %esi
  800dc2:	53                   	push   %ebx
  800dc3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dc6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800dc9:	85 c9                	test   %ecx,%ecx
  800dcb:	74 31                	je     800dfe <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dcd:	89 f8                	mov    %edi,%eax
  800dcf:	09 c8                	or     %ecx,%eax
  800dd1:	a8 03                	test   $0x3,%al
  800dd3:	75 23                	jne    800df8 <memset+0x3f>
		c &= 0xFF;
  800dd5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dd9:	89 d3                	mov    %edx,%ebx
  800ddb:	c1 e3 08             	shl    $0x8,%ebx
  800dde:	89 d0                	mov    %edx,%eax
  800de0:	c1 e0 18             	shl    $0x18,%eax
  800de3:	89 d6                	mov    %edx,%esi
  800de5:	c1 e6 10             	shl    $0x10,%esi
  800de8:	09 f0                	or     %esi,%eax
  800dea:	09 c2                	or     %eax,%edx
  800dec:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800dee:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800df1:	89 d0                	mov    %edx,%eax
  800df3:	fc                   	cld    
  800df4:	f3 ab                	rep stos %eax,%es:(%edi)
  800df6:	eb 06                	jmp    800dfe <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800df8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dfb:	fc                   	cld    
  800dfc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dfe:	89 f8                	mov    %edi,%eax
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e05:	f3 0f 1e fb          	endbr32 
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	57                   	push   %edi
  800e0d:	56                   	push   %esi
  800e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e11:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e14:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e17:	39 c6                	cmp    %eax,%esi
  800e19:	73 32                	jae    800e4d <memmove+0x48>
  800e1b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e1e:	39 c2                	cmp    %eax,%edx
  800e20:	76 2b                	jbe    800e4d <memmove+0x48>
		s += n;
		d += n;
  800e22:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e25:	89 fe                	mov    %edi,%esi
  800e27:	09 ce                	or     %ecx,%esi
  800e29:	09 d6                	or     %edx,%esi
  800e2b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e31:	75 0e                	jne    800e41 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e33:	83 ef 04             	sub    $0x4,%edi
  800e36:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e39:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800e3c:	fd                   	std    
  800e3d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e3f:	eb 09                	jmp    800e4a <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e41:	83 ef 01             	sub    $0x1,%edi
  800e44:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800e47:	fd                   	std    
  800e48:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e4a:	fc                   	cld    
  800e4b:	eb 1a                	jmp    800e67 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e4d:	89 c2                	mov    %eax,%edx
  800e4f:	09 ca                	or     %ecx,%edx
  800e51:	09 f2                	or     %esi,%edx
  800e53:	f6 c2 03             	test   $0x3,%dl
  800e56:	75 0a                	jne    800e62 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e58:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800e5b:	89 c7                	mov    %eax,%edi
  800e5d:	fc                   	cld    
  800e5e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e60:	eb 05                	jmp    800e67 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800e62:	89 c7                	mov    %eax,%edi
  800e64:	fc                   	cld    
  800e65:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e67:	5e                   	pop    %esi
  800e68:	5f                   	pop    %edi
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e6b:	f3 0f 1e fb          	endbr32 
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e75:	ff 75 10             	pushl  0x10(%ebp)
  800e78:	ff 75 0c             	pushl  0xc(%ebp)
  800e7b:	ff 75 08             	pushl  0x8(%ebp)
  800e7e:	e8 82 ff ff ff       	call   800e05 <memmove>
}
  800e83:	c9                   	leave  
  800e84:	c3                   	ret    

00800e85 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e85:	f3 0f 1e fb          	endbr32 
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	56                   	push   %esi
  800e8d:	53                   	push   %ebx
  800e8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e91:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e94:	89 c6                	mov    %eax,%esi
  800e96:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e99:	39 f0                	cmp    %esi,%eax
  800e9b:	74 1c                	je     800eb9 <memcmp+0x34>
		if (*s1 != *s2)
  800e9d:	0f b6 08             	movzbl (%eax),%ecx
  800ea0:	0f b6 1a             	movzbl (%edx),%ebx
  800ea3:	38 d9                	cmp    %bl,%cl
  800ea5:	75 08                	jne    800eaf <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ea7:	83 c0 01             	add    $0x1,%eax
  800eaa:	83 c2 01             	add    $0x1,%edx
  800ead:	eb ea                	jmp    800e99 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800eaf:	0f b6 c1             	movzbl %cl,%eax
  800eb2:	0f b6 db             	movzbl %bl,%ebx
  800eb5:	29 d8                	sub    %ebx,%eax
  800eb7:	eb 05                	jmp    800ebe <memcmp+0x39>
	}

	return 0;
  800eb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    

00800ec2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ec2:	f3 0f 1e fb          	endbr32 
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ecf:	89 c2                	mov    %eax,%edx
  800ed1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ed4:	39 d0                	cmp    %edx,%eax
  800ed6:	73 09                	jae    800ee1 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ed8:	38 08                	cmp    %cl,(%eax)
  800eda:	74 05                	je     800ee1 <memfind+0x1f>
	for (; s < ends; s++)
  800edc:	83 c0 01             	add    $0x1,%eax
  800edf:	eb f3                	jmp    800ed4 <memfind+0x12>
			break;
	return (void *) s;
}
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    

00800ee3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ee3:	f3 0f 1e fb          	endbr32 
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	57                   	push   %edi
  800eeb:	56                   	push   %esi
  800eec:	53                   	push   %ebx
  800eed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ef3:	eb 03                	jmp    800ef8 <strtol+0x15>
		s++;
  800ef5:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ef8:	0f b6 01             	movzbl (%ecx),%eax
  800efb:	3c 20                	cmp    $0x20,%al
  800efd:	74 f6                	je     800ef5 <strtol+0x12>
  800eff:	3c 09                	cmp    $0x9,%al
  800f01:	74 f2                	je     800ef5 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800f03:	3c 2b                	cmp    $0x2b,%al
  800f05:	74 2a                	je     800f31 <strtol+0x4e>
	int neg = 0;
  800f07:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800f0c:	3c 2d                	cmp    $0x2d,%al
  800f0e:	74 2b                	je     800f3b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f10:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f16:	75 0f                	jne    800f27 <strtol+0x44>
  800f18:	80 39 30             	cmpb   $0x30,(%ecx)
  800f1b:	74 28                	je     800f45 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f1d:	85 db                	test   %ebx,%ebx
  800f1f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f24:	0f 44 d8             	cmove  %eax,%ebx
  800f27:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800f2f:	eb 46                	jmp    800f77 <strtol+0x94>
		s++;
  800f31:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800f34:	bf 00 00 00 00       	mov    $0x0,%edi
  800f39:	eb d5                	jmp    800f10 <strtol+0x2d>
		s++, neg = 1;
  800f3b:	83 c1 01             	add    $0x1,%ecx
  800f3e:	bf 01 00 00 00       	mov    $0x1,%edi
  800f43:	eb cb                	jmp    800f10 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f45:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f49:	74 0e                	je     800f59 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800f4b:	85 db                	test   %ebx,%ebx
  800f4d:	75 d8                	jne    800f27 <strtol+0x44>
		s++, base = 8;
  800f4f:	83 c1 01             	add    $0x1,%ecx
  800f52:	bb 08 00 00 00       	mov    $0x8,%ebx
  800f57:	eb ce                	jmp    800f27 <strtol+0x44>
		s += 2, base = 16;
  800f59:	83 c1 02             	add    $0x2,%ecx
  800f5c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f61:	eb c4                	jmp    800f27 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800f63:	0f be d2             	movsbl %dl,%edx
  800f66:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f69:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f6c:	7d 3a                	jge    800fa8 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800f6e:	83 c1 01             	add    $0x1,%ecx
  800f71:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f75:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800f77:	0f b6 11             	movzbl (%ecx),%edx
  800f7a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f7d:	89 f3                	mov    %esi,%ebx
  800f7f:	80 fb 09             	cmp    $0x9,%bl
  800f82:	76 df                	jbe    800f63 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800f84:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f87:	89 f3                	mov    %esi,%ebx
  800f89:	80 fb 19             	cmp    $0x19,%bl
  800f8c:	77 08                	ja     800f96 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800f8e:	0f be d2             	movsbl %dl,%edx
  800f91:	83 ea 57             	sub    $0x57,%edx
  800f94:	eb d3                	jmp    800f69 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800f96:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f99:	89 f3                	mov    %esi,%ebx
  800f9b:	80 fb 19             	cmp    $0x19,%bl
  800f9e:	77 08                	ja     800fa8 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800fa0:	0f be d2             	movsbl %dl,%edx
  800fa3:	83 ea 37             	sub    $0x37,%edx
  800fa6:	eb c1                	jmp    800f69 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800fa8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fac:	74 05                	je     800fb3 <strtol+0xd0>
		*endptr = (char *) s;
  800fae:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fb1:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800fb3:	89 c2                	mov    %eax,%edx
  800fb5:	f7 da                	neg    %edx
  800fb7:	85 ff                	test   %edi,%edi
  800fb9:	0f 45 c2             	cmovne %edx,%eax
}
  800fbc:	5b                   	pop    %ebx
  800fbd:	5e                   	pop    %esi
  800fbe:	5f                   	pop    %edi
  800fbf:	5d                   	pop    %ebp
  800fc0:	c3                   	ret    

00800fc1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fc1:	f3 0f 1e fb          	endbr32 
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	57                   	push   %edi
  800fc9:	56                   	push   %esi
  800fca:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fcb:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd6:	89 c3                	mov    %eax,%ebx
  800fd8:	89 c7                	mov    %eax,%edi
  800fda:	89 c6                	mov    %eax,%esi
  800fdc:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fde:	5b                   	pop    %ebx
  800fdf:	5e                   	pop    %esi
  800fe0:	5f                   	pop    %edi
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    

00800fe3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800fe3:	f3 0f 1e fb          	endbr32 
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	57                   	push   %edi
  800feb:	56                   	push   %esi
  800fec:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fed:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff7:	89 d1                	mov    %edx,%ecx
  800ff9:	89 d3                	mov    %edx,%ebx
  800ffb:	89 d7                	mov    %edx,%edi
  800ffd:	89 d6                	mov    %edx,%esi
  800fff:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801001:	5b                   	pop    %ebx
  801002:	5e                   	pop    %esi
  801003:	5f                   	pop    %edi
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    

00801006 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801006:	f3 0f 1e fb          	endbr32 
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	57                   	push   %edi
  80100e:	56                   	push   %esi
  80100f:	53                   	push   %ebx
	asm volatile("int %1\n"
  801010:	b9 00 00 00 00       	mov    $0x0,%ecx
  801015:	8b 55 08             	mov    0x8(%ebp),%edx
  801018:	b8 03 00 00 00       	mov    $0x3,%eax
  80101d:	89 cb                	mov    %ecx,%ebx
  80101f:	89 cf                	mov    %ecx,%edi
  801021:	89 ce                	mov    %ecx,%esi
  801023:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801025:	5b                   	pop    %ebx
  801026:	5e                   	pop    %esi
  801027:	5f                   	pop    %edi
  801028:	5d                   	pop    %ebp
  801029:	c3                   	ret    

0080102a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80102a:	f3 0f 1e fb          	endbr32 
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	57                   	push   %edi
  801032:	56                   	push   %esi
  801033:	53                   	push   %ebx
	asm volatile("int %1\n"
  801034:	ba 00 00 00 00       	mov    $0x0,%edx
  801039:	b8 02 00 00 00       	mov    $0x2,%eax
  80103e:	89 d1                	mov    %edx,%ecx
  801040:	89 d3                	mov    %edx,%ebx
  801042:	89 d7                	mov    %edx,%edi
  801044:	89 d6                	mov    %edx,%esi
  801046:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801048:	5b                   	pop    %ebx
  801049:	5e                   	pop    %esi
  80104a:	5f                   	pop    %edi
  80104b:	5d                   	pop    %ebp
  80104c:	c3                   	ret    

0080104d <sys_yield>:

void
sys_yield(void)
{
  80104d:	f3 0f 1e fb          	endbr32 
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	57                   	push   %edi
  801055:	56                   	push   %esi
  801056:	53                   	push   %ebx
	asm volatile("int %1\n"
  801057:	ba 00 00 00 00       	mov    $0x0,%edx
  80105c:	b8 0b 00 00 00       	mov    $0xb,%eax
  801061:	89 d1                	mov    %edx,%ecx
  801063:	89 d3                	mov    %edx,%ebx
  801065:	89 d7                	mov    %edx,%edi
  801067:	89 d6                	mov    %edx,%esi
  801069:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80106b:	5b                   	pop    %ebx
  80106c:	5e                   	pop    %esi
  80106d:	5f                   	pop    %edi
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    

00801070 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801070:	f3 0f 1e fb          	endbr32 
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	57                   	push   %edi
  801078:	56                   	push   %esi
  801079:	53                   	push   %ebx
	asm volatile("int %1\n"
  80107a:	be 00 00 00 00       	mov    $0x0,%esi
  80107f:	8b 55 08             	mov    0x8(%ebp),%edx
  801082:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801085:	b8 04 00 00 00       	mov    $0x4,%eax
  80108a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80108d:	89 f7                	mov    %esi,%edi
  80108f:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801091:	5b                   	pop    %ebx
  801092:	5e                   	pop    %esi
  801093:	5f                   	pop    %edi
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    

00801096 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801096:	f3 0f 1e fb          	endbr32 
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	57                   	push   %edi
  80109e:	56                   	push   %esi
  80109f:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8010ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ae:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010b1:	8b 75 18             	mov    0x18(%ebp),%esi
  8010b4:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010b6:	5b                   	pop    %ebx
  8010b7:	5e                   	pop    %esi
  8010b8:	5f                   	pop    %edi
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    

008010bb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010bb:	f3 0f 1e fb          	endbr32 
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	57                   	push   %edi
  8010c3:	56                   	push   %esi
  8010c4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8010cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010d0:	b8 06 00 00 00       	mov    $0x6,%eax
  8010d5:	89 df                	mov    %ebx,%edi
  8010d7:	89 de                	mov    %ebx,%esi
  8010d9:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8010db:	5b                   	pop    %ebx
  8010dc:	5e                   	pop    %esi
  8010dd:	5f                   	pop    %edi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010e0:	f3 0f 1e fb          	endbr32 
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	57                   	push   %edi
  8010e8:	56                   	push   %esi
  8010e9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f5:	b8 08 00 00 00       	mov    $0x8,%eax
  8010fa:	89 df                	mov    %ebx,%edi
  8010fc:	89 de                	mov    %ebx,%esi
  8010fe:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801100:	5b                   	pop    %ebx
  801101:	5e                   	pop    %esi
  801102:	5f                   	pop    %edi
  801103:	5d                   	pop    %ebp
  801104:	c3                   	ret    

00801105 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801105:	f3 0f 1e fb          	endbr32 
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	57                   	push   %edi
  80110d:	56                   	push   %esi
  80110e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80110f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801114:	8b 55 08             	mov    0x8(%ebp),%edx
  801117:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80111a:	b8 09 00 00 00       	mov    $0x9,%eax
  80111f:	89 df                	mov    %ebx,%edi
  801121:	89 de                	mov    %ebx,%esi
  801123:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801125:	5b                   	pop    %ebx
  801126:	5e                   	pop    %esi
  801127:	5f                   	pop    %edi
  801128:	5d                   	pop    %ebp
  801129:	c3                   	ret    

0080112a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80112a:	f3 0f 1e fb          	endbr32 
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	57                   	push   %edi
  801132:	56                   	push   %esi
  801133:	53                   	push   %ebx
	asm volatile("int %1\n"
  801134:	bb 00 00 00 00       	mov    $0x0,%ebx
  801139:	8b 55 08             	mov    0x8(%ebp),%edx
  80113c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801144:	89 df                	mov    %ebx,%edi
  801146:	89 de                	mov    %ebx,%esi
  801148:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80114a:	5b                   	pop    %ebx
  80114b:	5e                   	pop    %esi
  80114c:	5f                   	pop    %edi
  80114d:	5d                   	pop    %ebp
  80114e:	c3                   	ret    

0080114f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80114f:	f3 0f 1e fb          	endbr32 
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	57                   	push   %edi
  801157:	56                   	push   %esi
  801158:	53                   	push   %ebx
	asm volatile("int %1\n"
  801159:	8b 55 08             	mov    0x8(%ebp),%edx
  80115c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115f:	b8 0c 00 00 00       	mov    $0xc,%eax
  801164:	be 00 00 00 00       	mov    $0x0,%esi
  801169:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80116c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80116f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801171:	5b                   	pop    %ebx
  801172:	5e                   	pop    %esi
  801173:	5f                   	pop    %edi
  801174:	5d                   	pop    %ebp
  801175:	c3                   	ret    

00801176 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801176:	f3 0f 1e fb          	endbr32 
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	57                   	push   %edi
  80117e:	56                   	push   %esi
  80117f:	53                   	push   %ebx
	asm volatile("int %1\n"
  801180:	b9 00 00 00 00       	mov    $0x0,%ecx
  801185:	8b 55 08             	mov    0x8(%ebp),%edx
  801188:	b8 0d 00 00 00       	mov    $0xd,%eax
  80118d:	89 cb                	mov    %ecx,%ebx
  80118f:	89 cf                	mov    %ecx,%edi
  801191:	89 ce                	mov    %ecx,%esi
  801193:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801195:	5b                   	pop    %ebx
  801196:	5e                   	pop    %esi
  801197:	5f                   	pop    %edi
  801198:	5d                   	pop    %ebp
  801199:	c3                   	ret    

0080119a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80119a:	f3 0f 1e fb          	endbr32 
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	57                   	push   %edi
  8011a2:	56                   	push   %esi
  8011a3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a9:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011ae:	89 d1                	mov    %edx,%ecx
  8011b0:	89 d3                	mov    %edx,%ebx
  8011b2:	89 d7                	mov    %edx,%edi
  8011b4:	89 d6                	mov    %edx,%esi
  8011b6:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8011b8:	5b                   	pop    %ebx
  8011b9:	5e                   	pop    %esi
  8011ba:	5f                   	pop    %edi
  8011bb:	5d                   	pop    %ebp
  8011bc:	c3                   	ret    

008011bd <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  8011bd:	f3 0f 1e fb          	endbr32 
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	57                   	push   %edi
  8011c5:	56                   	push   %esi
  8011c6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8011cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d2:	b8 0f 00 00 00       	mov    $0xf,%eax
  8011d7:	89 df                	mov    %ebx,%edi
  8011d9:	89 de                	mov    %ebx,%esi
  8011db:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  8011dd:	5b                   	pop    %ebx
  8011de:	5e                   	pop    %esi
  8011df:	5f                   	pop    %edi
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    

008011e2 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  8011e2:	f3 0f 1e fb          	endbr32 
  8011e6:	55                   	push   %ebp
  8011e7:	89 e5                	mov    %esp,%ebp
  8011e9:	57                   	push   %edi
  8011ea:	56                   	push   %esi
  8011eb:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f7:	b8 10 00 00 00       	mov    $0x10,%eax
  8011fc:	89 df                	mov    %ebx,%edi
  8011fe:	89 de                	mov    %ebx,%esi
  801200:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  801202:	5b                   	pop    %ebx
  801203:	5e                   	pop    %esi
  801204:	5f                   	pop    %edi
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    

00801207 <pgfault>:
// map in our own private writable copy.
//
extern int cnt;
static void
pgfault(struct UTrapframe *utf)
{
  801207:	f3 0f 1e fb          	endbr32 
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	53                   	push   %ebx
  80120f:	83 ec 04             	sub    $0x4,%esp
  801212:	8b 45 08             	mov    0x8(%ebp),%eax
	// cprintf("[%08x] called pgfault\n", sys_getenvid());
	void *addr = (void *) utf->utf_fault_va;
  801215:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err&FEC_WR)&&(uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_COW))){
  801217:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80121b:	0f 84 9a 00 00 00    	je     8012bb <pgfault+0xb4>
  801221:	89 d8                	mov    %ebx,%eax
  801223:	c1 e8 16             	shr    $0x16,%eax
  801226:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80122d:	a8 01                	test   $0x1,%al
  80122f:	0f 84 86 00 00 00    	je     8012bb <pgfault+0xb4>
  801235:	89 d8                	mov    %ebx,%eax
  801237:	c1 e8 0c             	shr    $0xc,%eax
  80123a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801241:	f6 c2 01             	test   $0x1,%dl
  801244:	74 75                	je     8012bb <pgfault+0xb4>
  801246:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80124d:	f6 c4 08             	test   $0x8,%ah
  801250:	74 69                	je     8012bb <pgfault+0xb4>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 在PFTEMP这里给一个物理地址的mapping 相当于store一个物理地址
	if((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W))<0){
  801252:	83 ec 04             	sub    $0x4,%esp
  801255:	6a 07                	push   $0x7
  801257:	68 00 f0 7f 00       	push   $0x7ff000
  80125c:	6a 00                	push   $0x0
  80125e:	e8 0d fe ff ff       	call   801070 <sys_page_alloc>
  801263:	83 c4 10             	add    $0x10,%esp
  801266:	85 c0                	test   %eax,%eax
  801268:	78 63                	js     8012cd <pgfault+0xc6>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80126a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// 先复制addr里的content
	memcpy((void*)PFTEMP, addr, PGSIZE);
  801270:	83 ec 04             	sub    $0x4,%esp
  801273:	68 00 10 00 00       	push   $0x1000
  801278:	53                   	push   %ebx
  801279:	68 00 f0 7f 00       	push   $0x7ff000
  80127e:	e8 e8 fb ff ff       	call   800e6b <memcpy>
	// 在remap addr到PFTEMP位置 即addr与PFTEMP指向同一个物理内存
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))<0){
  801283:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80128a:	53                   	push   %ebx
  80128b:	6a 00                	push   $0x0
  80128d:	68 00 f0 7f 00       	push   $0x7ff000
  801292:	6a 00                	push   $0x0
  801294:	e8 fd fd ff ff       	call   801096 <sys_page_map>
  801299:	83 c4 20             	add    $0x20,%esp
  80129c:	85 c0                	test   %eax,%eax
  80129e:	78 3f                	js     8012df <pgfault+0xd8>
		panic("pgfault: sys_page_map failed due to %e\n", r);
	}
	if ((r = sys_page_unmap(0, (void*)PFTEMP))<0){
  8012a0:	83 ec 08             	sub    $0x8,%esp
  8012a3:	68 00 f0 7f 00       	push   $0x7ff000
  8012a8:	6a 00                	push   $0x0
  8012aa:	e8 0c fe ff ff       	call   8010bb <sys_page_unmap>
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	78 3b                	js     8012f1 <pgfault+0xea>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
	}
	
	
}
  8012b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b9:	c9                   	leave  
  8012ba:	c3                   	ret    
		panic("pgfault: page access at %08x is not a write to a copy-on-write\n", addr);
  8012bb:	53                   	push   %ebx
  8012bc:	68 40 34 80 00       	push   $0x803440
  8012c1:	6a 20                	push   $0x20
  8012c3:	68 fe 34 80 00       	push   $0x8034fe
  8012c8:	e8 49 f2 ff ff       	call   800516 <_panic>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
  8012cd:	50                   	push   %eax
  8012ce:	68 80 34 80 00       	push   $0x803480
  8012d3:	6a 2c                	push   $0x2c
  8012d5:	68 fe 34 80 00       	push   $0x8034fe
  8012da:	e8 37 f2 ff ff       	call   800516 <_panic>
		panic("pgfault: sys_page_map failed due to %e\n", r);
  8012df:	50                   	push   %eax
  8012e0:	68 ac 34 80 00       	push   $0x8034ac
  8012e5:	6a 33                	push   $0x33
  8012e7:	68 fe 34 80 00       	push   $0x8034fe
  8012ec:	e8 25 f2 ff ff       	call   800516 <_panic>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
  8012f1:	50                   	push   %eax
  8012f2:	68 d4 34 80 00       	push   $0x8034d4
  8012f7:	6a 36                	push   $0x36
  8012f9:	68 fe 34 80 00       	push   $0x8034fe
  8012fe:	e8 13 f2 ff ff       	call   800516 <_panic>

00801303 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801303:	f3 0f 1e fb          	endbr32 
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
  80130a:	57                   	push   %edi
  80130b:	56                   	push   %esi
  80130c:	53                   	push   %ebx
  80130d:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[%08x] called fork\n", sys_getenvid());
	int r; uintptr_t addr;
	set_pgfault_handler(pgfault);
  801310:	68 07 12 80 00       	push   $0x801207
  801315:	e8 6b 18 00 00       	call   802b85 <set_pgfault_handler>
*/
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80131a:	b8 07 00 00 00       	mov    $0x7,%eax
  80131f:	cd 30                	int    $0x30
  801321:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();
		
	if (envid<0){
  801324:	83 c4 10             	add    $0x10,%esp
  801327:	85 c0                	test   %eax,%eax
  801329:	78 29                	js     801354 <fork+0x51>
  80132b:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	// duplicate parent address space
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  80132d:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid==0){
  801332:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801336:	75 60                	jne    801398 <fork+0x95>
		thisenv = &envs[ENVX(sys_getenvid())];
  801338:	e8 ed fc ff ff       	call   80102a <sys_getenvid>
  80133d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801342:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801345:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80134a:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  80134f:	e9 14 01 00 00       	jmp    801468 <fork+0x165>
		panic("fork: sys_exofork error %e\n", envid);
  801354:	50                   	push   %eax
  801355:	68 09 35 80 00       	push   $0x803509
  80135a:	68 90 00 00 00       	push   $0x90
  80135f:	68 fe 34 80 00       	push   $0x8034fe
  801364:	e8 ad f1 ff ff       	call   800516 <_panic>
		r = sys_page_map(0, addr, envid, addr, (uvpt[pn]&PTE_SYSCALL));
  801369:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801370:	83 ec 0c             	sub    $0xc,%esp
  801373:	25 07 0e 00 00       	and    $0xe07,%eax
  801378:	50                   	push   %eax
  801379:	56                   	push   %esi
  80137a:	57                   	push   %edi
  80137b:	56                   	push   %esi
  80137c:	6a 00                	push   $0x0
  80137e:	e8 13 fd ff ff       	call   801096 <sys_page_map>
  801383:	83 c4 20             	add    $0x20,%esp
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  801386:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80138c:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801392:	0f 84 95 00 00 00    	je     80142d <fork+0x12a>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  801398:	89 d8                	mov    %ebx,%eax
  80139a:	c1 e8 16             	shr    $0x16,%eax
  80139d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013a4:	a8 01                	test   $0x1,%al
  8013a6:	74 de                	je     801386 <fork+0x83>
  8013a8:	89 d8                	mov    %ebx,%eax
  8013aa:	c1 e8 0c             	shr    $0xc,%eax
  8013ad:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013b4:	f6 c2 01             	test   $0x1,%dl
  8013b7:	74 cd                	je     801386 <fork+0x83>
	void* addr = (void*)(pn*PGSIZE);
  8013b9:	89 c6                	mov    %eax,%esi
  8013bb:	c1 e6 0c             	shl    $0xc,%esi
	if (uvpt[pn]&PTE_SHARE){
  8013be:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013c5:	f6 c6 04             	test   $0x4,%dh
  8013c8:	75 9f                	jne    801369 <fork+0x66>
		if (uvpt[pn]&PTE_W||uvpt[pn]&PTE_COW){
  8013ca:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013d1:	f6 c2 02             	test   $0x2,%dl
  8013d4:	75 0c                	jne    8013e2 <fork+0xdf>
  8013d6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013dd:	f6 c4 08             	test   $0x8,%ah
  8013e0:	74 34                	je     801416 <fork+0x113>
			r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P); // not writable
  8013e2:	83 ec 0c             	sub    $0xc,%esp
  8013e5:	68 05 08 00 00       	push   $0x805
  8013ea:	56                   	push   %esi
  8013eb:	57                   	push   %edi
  8013ec:	56                   	push   %esi
  8013ed:	6a 00                	push   $0x0
  8013ef:	e8 a2 fc ff ff       	call   801096 <sys_page_map>
			if (r<0) return r;
  8013f4:	83 c4 20             	add    $0x20,%esp
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	78 8b                	js     801386 <fork+0x83>
			r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P); // not writable
  8013fb:	83 ec 0c             	sub    $0xc,%esp
  8013fe:	68 05 08 00 00       	push   $0x805
  801403:	56                   	push   %esi
  801404:	6a 00                	push   $0x0
  801406:	56                   	push   %esi
  801407:	6a 00                	push   $0x0
  801409:	e8 88 fc ff ff       	call   801096 <sys_page_map>
  80140e:	83 c4 20             	add    $0x20,%esp
  801411:	e9 70 ff ff ff       	jmp    801386 <fork+0x83>
			if ((r=sys_page_map(0, addr, envid, addr, PTE_P|PTE_U)<0))// read only
  801416:	83 ec 0c             	sub    $0xc,%esp
  801419:	6a 05                	push   $0x5
  80141b:	56                   	push   %esi
  80141c:	57                   	push   %edi
  80141d:	56                   	push   %esi
  80141e:	6a 00                	push   $0x0
  801420:	e8 71 fc ff ff       	call   801096 <sys_page_map>
  801425:	83 c4 20             	add    $0x20,%esp
  801428:	e9 59 ff ff ff       	jmp    801386 <fork+0x83>
			duppage(envid, PGNUM(addr));
		}
	}
	// allocate user exception stack
	// cprintf("alloc user expection stack\n");
	if ((r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_W|PTE_U))<0)
  80142d:	83 ec 04             	sub    $0x4,%esp
  801430:	6a 07                	push   $0x7
  801432:	68 00 f0 bf ee       	push   $0xeebff000
  801437:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80143a:	56                   	push   %esi
  80143b:	e8 30 fc ff ff       	call   801070 <sys_page_alloc>
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	85 c0                	test   %eax,%eax
  801445:	78 2b                	js     801472 <fork+0x16f>
		return r;
	
	extern void* _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801447:	83 ec 08             	sub    $0x8,%esp
  80144a:	68 f8 2b 80 00       	push   $0x802bf8
  80144f:	56                   	push   %esi
  801450:	e8 d5 fc ff ff       	call   80112a <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE))<0)
  801455:	83 c4 08             	add    $0x8,%esp
  801458:	6a 02                	push   $0x2
  80145a:	56                   	push   %esi
  80145b:	e8 80 fc ff ff       	call   8010e0 <sys_env_set_status>
  801460:	83 c4 10             	add    $0x10,%esp
		return r;
  801463:	85 c0                	test   %eax,%eax
  801465:	0f 48 f8             	cmovs  %eax,%edi

	return envid;
	
}
  801468:	89 f8                	mov    %edi,%eax
  80146a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80146d:	5b                   	pop    %ebx
  80146e:	5e                   	pop    %esi
  80146f:	5f                   	pop    %edi
  801470:	5d                   	pop    %ebp
  801471:	c3                   	ret    
		return r;
  801472:	89 c7                	mov    %eax,%edi
  801474:	eb f2                	jmp    801468 <fork+0x165>

00801476 <sfork>:

// Challenge(not sure yet)
int
sfork(void)
{
  801476:	f3 0f 1e fb          	endbr32 
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801480:	68 25 35 80 00       	push   $0x803525
  801485:	68 b2 00 00 00       	push   $0xb2
  80148a:	68 fe 34 80 00       	push   $0x8034fe
  80148f:	e8 82 f0 ff ff       	call   800516 <_panic>

00801494 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801494:	f3 0f 1e fb          	endbr32 
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80149b:	8b 45 08             	mov    0x8(%ebp),%eax
  80149e:	05 00 00 00 30       	add    $0x30000000,%eax
  8014a3:	c1 e8 0c             	shr    $0xc,%eax
}
  8014a6:	5d                   	pop    %ebp
  8014a7:	c3                   	ret    

008014a8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014a8:	f3 0f 1e fb          	endbr32 
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014af:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b2:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8014b7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014bc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014c1:	5d                   	pop    %ebp
  8014c2:	c3                   	ret    

008014c3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014c3:	f3 0f 1e fb          	endbr32 
  8014c7:	55                   	push   %ebp
  8014c8:	89 e5                	mov    %esp,%ebp
  8014ca:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014cf:	89 c2                	mov    %eax,%edx
  8014d1:	c1 ea 16             	shr    $0x16,%edx
  8014d4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014db:	f6 c2 01             	test   $0x1,%dl
  8014de:	74 2d                	je     80150d <fd_alloc+0x4a>
  8014e0:	89 c2                	mov    %eax,%edx
  8014e2:	c1 ea 0c             	shr    $0xc,%edx
  8014e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014ec:	f6 c2 01             	test   $0x1,%dl
  8014ef:	74 1c                	je     80150d <fd_alloc+0x4a>
  8014f1:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8014f6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014fb:	75 d2                	jne    8014cf <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  8014fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801500:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801506:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80150b:	eb 0a                	jmp    801517 <fd_alloc+0x54>
			*fd_store = fd;
  80150d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801510:	89 01                	mov    %eax,(%ecx)
			return 0;
  801512:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801517:	5d                   	pop    %ebp
  801518:	c3                   	ret    

00801519 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801519:	f3 0f 1e fb          	endbr32 
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801523:	83 f8 1f             	cmp    $0x1f,%eax
  801526:	77 30                	ja     801558 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801528:	c1 e0 0c             	shl    $0xc,%eax
  80152b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801530:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801536:	f6 c2 01             	test   $0x1,%dl
  801539:	74 24                	je     80155f <fd_lookup+0x46>
  80153b:	89 c2                	mov    %eax,%edx
  80153d:	c1 ea 0c             	shr    $0xc,%edx
  801540:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801547:	f6 c2 01             	test   $0x1,%dl
  80154a:	74 1a                	je     801566 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80154c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80154f:	89 02                	mov    %eax,(%edx)
	return 0;
  801551:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801556:	5d                   	pop    %ebp
  801557:	c3                   	ret    
		return -E_INVAL;
  801558:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80155d:	eb f7                	jmp    801556 <fd_lookup+0x3d>
		return -E_INVAL;
  80155f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801564:	eb f0                	jmp    801556 <fd_lookup+0x3d>
  801566:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80156b:	eb e9                	jmp    801556 <fd_lookup+0x3d>

0080156d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80156d:	f3 0f 1e fb          	endbr32 
  801571:	55                   	push   %ebp
  801572:	89 e5                	mov    %esp,%ebp
  801574:	83 ec 08             	sub    $0x8,%esp
  801577:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  80157a:	ba 00 00 00 00       	mov    $0x0,%edx
  80157f:	b8 20 40 80 00       	mov    $0x804020,%eax
		if (devtab[i]->dev_id == dev_id) {
  801584:	39 08                	cmp    %ecx,(%eax)
  801586:	74 38                	je     8015c0 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  801588:	83 c2 01             	add    $0x1,%edx
  80158b:	8b 04 95 b8 35 80 00 	mov    0x8035b8(,%edx,4),%eax
  801592:	85 c0                	test   %eax,%eax
  801594:	75 ee                	jne    801584 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801596:	a1 08 50 80 00       	mov    0x805008,%eax
  80159b:	8b 40 48             	mov    0x48(%eax),%eax
  80159e:	83 ec 04             	sub    $0x4,%esp
  8015a1:	51                   	push   %ecx
  8015a2:	50                   	push   %eax
  8015a3:	68 3c 35 80 00       	push   $0x80353c
  8015a8:	e8 50 f0 ff ff       	call   8005fd <cprintf>
	*dev = 0;
  8015ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015be:	c9                   	leave  
  8015bf:	c3                   	ret    
			*dev = devtab[i];
  8015c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015c3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ca:	eb f2                	jmp    8015be <dev_lookup+0x51>

008015cc <fd_close>:
{
  8015cc:	f3 0f 1e fb          	endbr32 
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	57                   	push   %edi
  8015d4:	56                   	push   %esi
  8015d5:	53                   	push   %ebx
  8015d6:	83 ec 24             	sub    $0x24,%esp
  8015d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8015dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015df:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015e2:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8015e3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015e9:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015ec:	50                   	push   %eax
  8015ed:	e8 27 ff ff ff       	call   801519 <fd_lookup>
  8015f2:	89 c3                	mov    %eax,%ebx
  8015f4:	83 c4 10             	add    $0x10,%esp
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	78 05                	js     801600 <fd_close+0x34>
	    || fd != fd2)
  8015fb:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8015fe:	74 16                	je     801616 <fd_close+0x4a>
		return (must_exist ? r : 0);
  801600:	89 f8                	mov    %edi,%eax
  801602:	84 c0                	test   %al,%al
  801604:	b8 00 00 00 00       	mov    $0x0,%eax
  801609:	0f 44 d8             	cmove  %eax,%ebx
}
  80160c:	89 d8                	mov    %ebx,%eax
  80160e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801611:	5b                   	pop    %ebx
  801612:	5e                   	pop    %esi
  801613:	5f                   	pop    %edi
  801614:	5d                   	pop    %ebp
  801615:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801616:	83 ec 08             	sub    $0x8,%esp
  801619:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80161c:	50                   	push   %eax
  80161d:	ff 36                	pushl  (%esi)
  80161f:	e8 49 ff ff ff       	call   80156d <dev_lookup>
  801624:	89 c3                	mov    %eax,%ebx
  801626:	83 c4 10             	add    $0x10,%esp
  801629:	85 c0                	test   %eax,%eax
  80162b:	78 1a                	js     801647 <fd_close+0x7b>
		if (dev->dev_close)
  80162d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801630:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801633:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801638:	85 c0                	test   %eax,%eax
  80163a:	74 0b                	je     801647 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80163c:	83 ec 0c             	sub    $0xc,%esp
  80163f:	56                   	push   %esi
  801640:	ff d0                	call   *%eax
  801642:	89 c3                	mov    %eax,%ebx
  801644:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801647:	83 ec 08             	sub    $0x8,%esp
  80164a:	56                   	push   %esi
  80164b:	6a 00                	push   $0x0
  80164d:	e8 69 fa ff ff       	call   8010bb <sys_page_unmap>
	return r;
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	eb b5                	jmp    80160c <fd_close+0x40>

00801657 <close>:

int
close(int fdnum)
{
  801657:	f3 0f 1e fb          	endbr32 
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801661:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801664:	50                   	push   %eax
  801665:	ff 75 08             	pushl  0x8(%ebp)
  801668:	e8 ac fe ff ff       	call   801519 <fd_lookup>
  80166d:	83 c4 10             	add    $0x10,%esp
  801670:	85 c0                	test   %eax,%eax
  801672:	79 02                	jns    801676 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801674:	c9                   	leave  
  801675:	c3                   	ret    
		return fd_close(fd, 1);
  801676:	83 ec 08             	sub    $0x8,%esp
  801679:	6a 01                	push   $0x1
  80167b:	ff 75 f4             	pushl  -0xc(%ebp)
  80167e:	e8 49 ff ff ff       	call   8015cc <fd_close>
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	eb ec                	jmp    801674 <close+0x1d>

00801688 <close_all>:

void
close_all(void)
{
  801688:	f3 0f 1e fb          	endbr32 
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	53                   	push   %ebx
  801690:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801693:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801698:	83 ec 0c             	sub    $0xc,%esp
  80169b:	53                   	push   %ebx
  80169c:	e8 b6 ff ff ff       	call   801657 <close>
	for (i = 0; i < MAXFD; i++)
  8016a1:	83 c3 01             	add    $0x1,%ebx
  8016a4:	83 c4 10             	add    $0x10,%esp
  8016a7:	83 fb 20             	cmp    $0x20,%ebx
  8016aa:	75 ec                	jne    801698 <close_all+0x10>
}
  8016ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016af:	c9                   	leave  
  8016b0:	c3                   	ret    

008016b1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016b1:	f3 0f 1e fb          	endbr32 
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	57                   	push   %edi
  8016b9:	56                   	push   %esi
  8016ba:	53                   	push   %ebx
  8016bb:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016be:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016c1:	50                   	push   %eax
  8016c2:	ff 75 08             	pushl  0x8(%ebp)
  8016c5:	e8 4f fe ff ff       	call   801519 <fd_lookup>
  8016ca:	89 c3                	mov    %eax,%ebx
  8016cc:	83 c4 10             	add    $0x10,%esp
  8016cf:	85 c0                	test   %eax,%eax
  8016d1:	0f 88 81 00 00 00    	js     801758 <dup+0xa7>
		return r;
	close(newfdnum);
  8016d7:	83 ec 0c             	sub    $0xc,%esp
  8016da:	ff 75 0c             	pushl  0xc(%ebp)
  8016dd:	e8 75 ff ff ff       	call   801657 <close>

	newfd = INDEX2FD(newfdnum);
  8016e2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8016e5:	c1 e6 0c             	shl    $0xc,%esi
  8016e8:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8016ee:	83 c4 04             	add    $0x4,%esp
  8016f1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016f4:	e8 af fd ff ff       	call   8014a8 <fd2data>
  8016f9:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016fb:	89 34 24             	mov    %esi,(%esp)
  8016fe:	e8 a5 fd ff ff       	call   8014a8 <fd2data>
  801703:	83 c4 10             	add    $0x10,%esp
  801706:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801708:	89 d8                	mov    %ebx,%eax
  80170a:	c1 e8 16             	shr    $0x16,%eax
  80170d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801714:	a8 01                	test   $0x1,%al
  801716:	74 11                	je     801729 <dup+0x78>
  801718:	89 d8                	mov    %ebx,%eax
  80171a:	c1 e8 0c             	shr    $0xc,%eax
  80171d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801724:	f6 c2 01             	test   $0x1,%dl
  801727:	75 39                	jne    801762 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801729:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80172c:	89 d0                	mov    %edx,%eax
  80172e:	c1 e8 0c             	shr    $0xc,%eax
  801731:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801738:	83 ec 0c             	sub    $0xc,%esp
  80173b:	25 07 0e 00 00       	and    $0xe07,%eax
  801740:	50                   	push   %eax
  801741:	56                   	push   %esi
  801742:	6a 00                	push   $0x0
  801744:	52                   	push   %edx
  801745:	6a 00                	push   $0x0
  801747:	e8 4a f9 ff ff       	call   801096 <sys_page_map>
  80174c:	89 c3                	mov    %eax,%ebx
  80174e:	83 c4 20             	add    $0x20,%esp
  801751:	85 c0                	test   %eax,%eax
  801753:	78 31                	js     801786 <dup+0xd5>
		goto err;

	return newfdnum;
  801755:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801758:	89 d8                	mov    %ebx,%eax
  80175a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175d:	5b                   	pop    %ebx
  80175e:	5e                   	pop    %esi
  80175f:	5f                   	pop    %edi
  801760:	5d                   	pop    %ebp
  801761:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801762:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801769:	83 ec 0c             	sub    $0xc,%esp
  80176c:	25 07 0e 00 00       	and    $0xe07,%eax
  801771:	50                   	push   %eax
  801772:	57                   	push   %edi
  801773:	6a 00                	push   $0x0
  801775:	53                   	push   %ebx
  801776:	6a 00                	push   $0x0
  801778:	e8 19 f9 ff ff       	call   801096 <sys_page_map>
  80177d:	89 c3                	mov    %eax,%ebx
  80177f:	83 c4 20             	add    $0x20,%esp
  801782:	85 c0                	test   %eax,%eax
  801784:	79 a3                	jns    801729 <dup+0x78>
	sys_page_unmap(0, newfd);
  801786:	83 ec 08             	sub    $0x8,%esp
  801789:	56                   	push   %esi
  80178a:	6a 00                	push   $0x0
  80178c:	e8 2a f9 ff ff       	call   8010bb <sys_page_unmap>
	sys_page_unmap(0, nva);
  801791:	83 c4 08             	add    $0x8,%esp
  801794:	57                   	push   %edi
  801795:	6a 00                	push   $0x0
  801797:	e8 1f f9 ff ff       	call   8010bb <sys_page_unmap>
	return r;
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	eb b7                	jmp    801758 <dup+0xa7>

008017a1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017a1:	f3 0f 1e fb          	endbr32 
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	53                   	push   %ebx
  8017a9:	83 ec 1c             	sub    $0x1c,%esp
  8017ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b2:	50                   	push   %eax
  8017b3:	53                   	push   %ebx
  8017b4:	e8 60 fd ff ff       	call   801519 <fd_lookup>
  8017b9:	83 c4 10             	add    $0x10,%esp
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	78 3f                	js     8017ff <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c0:	83 ec 08             	sub    $0x8,%esp
  8017c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c6:	50                   	push   %eax
  8017c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ca:	ff 30                	pushl  (%eax)
  8017cc:	e8 9c fd ff ff       	call   80156d <dev_lookup>
  8017d1:	83 c4 10             	add    $0x10,%esp
  8017d4:	85 c0                	test   %eax,%eax
  8017d6:	78 27                	js     8017ff <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017db:	8b 42 08             	mov    0x8(%edx),%eax
  8017de:	83 e0 03             	and    $0x3,%eax
  8017e1:	83 f8 01             	cmp    $0x1,%eax
  8017e4:	74 1e                	je     801804 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8017e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e9:	8b 40 08             	mov    0x8(%eax),%eax
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	74 35                	je     801825 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017f0:	83 ec 04             	sub    $0x4,%esp
  8017f3:	ff 75 10             	pushl  0x10(%ebp)
  8017f6:	ff 75 0c             	pushl  0xc(%ebp)
  8017f9:	52                   	push   %edx
  8017fa:	ff d0                	call   *%eax
  8017fc:	83 c4 10             	add    $0x10,%esp
}
  8017ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801802:	c9                   	leave  
  801803:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801804:	a1 08 50 80 00       	mov    0x805008,%eax
  801809:	8b 40 48             	mov    0x48(%eax),%eax
  80180c:	83 ec 04             	sub    $0x4,%esp
  80180f:	53                   	push   %ebx
  801810:	50                   	push   %eax
  801811:	68 7d 35 80 00       	push   $0x80357d
  801816:	e8 e2 ed ff ff       	call   8005fd <cprintf>
		return -E_INVAL;
  80181b:	83 c4 10             	add    $0x10,%esp
  80181e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801823:	eb da                	jmp    8017ff <read+0x5e>
		return -E_NOT_SUPP;
  801825:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80182a:	eb d3                	jmp    8017ff <read+0x5e>

0080182c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80182c:	f3 0f 1e fb          	endbr32 
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	57                   	push   %edi
  801834:	56                   	push   %esi
  801835:	53                   	push   %ebx
  801836:	83 ec 0c             	sub    $0xc,%esp
  801839:	8b 7d 08             	mov    0x8(%ebp),%edi
  80183c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80183f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801844:	eb 02                	jmp    801848 <readn+0x1c>
  801846:	01 c3                	add    %eax,%ebx
  801848:	39 f3                	cmp    %esi,%ebx
  80184a:	73 21                	jae    80186d <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80184c:	83 ec 04             	sub    $0x4,%esp
  80184f:	89 f0                	mov    %esi,%eax
  801851:	29 d8                	sub    %ebx,%eax
  801853:	50                   	push   %eax
  801854:	89 d8                	mov    %ebx,%eax
  801856:	03 45 0c             	add    0xc(%ebp),%eax
  801859:	50                   	push   %eax
  80185a:	57                   	push   %edi
  80185b:	e8 41 ff ff ff       	call   8017a1 <read>
		if (m < 0)
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	85 c0                	test   %eax,%eax
  801865:	78 04                	js     80186b <readn+0x3f>
			return m;
		if (m == 0)
  801867:	75 dd                	jne    801846 <readn+0x1a>
  801869:	eb 02                	jmp    80186d <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80186b:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80186d:	89 d8                	mov    %ebx,%eax
  80186f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801872:	5b                   	pop    %ebx
  801873:	5e                   	pop    %esi
  801874:	5f                   	pop    %edi
  801875:	5d                   	pop    %ebp
  801876:	c3                   	ret    

00801877 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801877:	f3 0f 1e fb          	endbr32 
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	53                   	push   %ebx
  80187f:	83 ec 1c             	sub    $0x1c,%esp
  801882:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801885:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801888:	50                   	push   %eax
  801889:	53                   	push   %ebx
  80188a:	e8 8a fc ff ff       	call   801519 <fd_lookup>
  80188f:	83 c4 10             	add    $0x10,%esp
  801892:	85 c0                	test   %eax,%eax
  801894:	78 3a                	js     8018d0 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801896:	83 ec 08             	sub    $0x8,%esp
  801899:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189c:	50                   	push   %eax
  80189d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a0:	ff 30                	pushl  (%eax)
  8018a2:	e8 c6 fc ff ff       	call   80156d <dev_lookup>
  8018a7:	83 c4 10             	add    $0x10,%esp
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	78 22                	js     8018d0 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018b5:	74 1e                	je     8018d5 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ba:	8b 52 0c             	mov    0xc(%edx),%edx
  8018bd:	85 d2                	test   %edx,%edx
  8018bf:	74 35                	je     8018f6 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018c1:	83 ec 04             	sub    $0x4,%esp
  8018c4:	ff 75 10             	pushl  0x10(%ebp)
  8018c7:	ff 75 0c             	pushl  0xc(%ebp)
  8018ca:	50                   	push   %eax
  8018cb:	ff d2                	call   *%edx
  8018cd:	83 c4 10             	add    $0x10,%esp
}
  8018d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d3:	c9                   	leave  
  8018d4:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018d5:	a1 08 50 80 00       	mov    0x805008,%eax
  8018da:	8b 40 48             	mov    0x48(%eax),%eax
  8018dd:	83 ec 04             	sub    $0x4,%esp
  8018e0:	53                   	push   %ebx
  8018e1:	50                   	push   %eax
  8018e2:	68 99 35 80 00       	push   $0x803599
  8018e7:	e8 11 ed ff ff       	call   8005fd <cprintf>
		return -E_INVAL;
  8018ec:	83 c4 10             	add    $0x10,%esp
  8018ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018f4:	eb da                	jmp    8018d0 <write+0x59>
		return -E_NOT_SUPP;
  8018f6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018fb:	eb d3                	jmp    8018d0 <write+0x59>

008018fd <seek>:

int
seek(int fdnum, off_t offset)
{
  8018fd:	f3 0f 1e fb          	endbr32 
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801907:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190a:	50                   	push   %eax
  80190b:	ff 75 08             	pushl  0x8(%ebp)
  80190e:	e8 06 fc ff ff       	call   801519 <fd_lookup>
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	85 c0                	test   %eax,%eax
  801918:	78 0e                	js     801928 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80191a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80191d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801920:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801923:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801928:	c9                   	leave  
  801929:	c3                   	ret    

0080192a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80192a:	f3 0f 1e fb          	endbr32 
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	53                   	push   %ebx
  801932:	83 ec 1c             	sub    $0x1c,%esp
  801935:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801938:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80193b:	50                   	push   %eax
  80193c:	53                   	push   %ebx
  80193d:	e8 d7 fb ff ff       	call   801519 <fd_lookup>
  801942:	83 c4 10             	add    $0x10,%esp
  801945:	85 c0                	test   %eax,%eax
  801947:	78 37                	js     801980 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801949:	83 ec 08             	sub    $0x8,%esp
  80194c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194f:	50                   	push   %eax
  801950:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801953:	ff 30                	pushl  (%eax)
  801955:	e8 13 fc ff ff       	call   80156d <dev_lookup>
  80195a:	83 c4 10             	add    $0x10,%esp
  80195d:	85 c0                	test   %eax,%eax
  80195f:	78 1f                	js     801980 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801961:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801964:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801968:	74 1b                	je     801985 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80196a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80196d:	8b 52 18             	mov    0x18(%edx),%edx
  801970:	85 d2                	test   %edx,%edx
  801972:	74 32                	je     8019a6 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801974:	83 ec 08             	sub    $0x8,%esp
  801977:	ff 75 0c             	pushl  0xc(%ebp)
  80197a:	50                   	push   %eax
  80197b:	ff d2                	call   *%edx
  80197d:	83 c4 10             	add    $0x10,%esp
}
  801980:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801983:	c9                   	leave  
  801984:	c3                   	ret    
			thisenv->env_id, fdnum);
  801985:	a1 08 50 80 00       	mov    0x805008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80198a:	8b 40 48             	mov    0x48(%eax),%eax
  80198d:	83 ec 04             	sub    $0x4,%esp
  801990:	53                   	push   %ebx
  801991:	50                   	push   %eax
  801992:	68 5c 35 80 00       	push   $0x80355c
  801997:	e8 61 ec ff ff       	call   8005fd <cprintf>
		return -E_INVAL;
  80199c:	83 c4 10             	add    $0x10,%esp
  80199f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019a4:	eb da                	jmp    801980 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8019a6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019ab:	eb d3                	jmp    801980 <ftruncate+0x56>

008019ad <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019ad:	f3 0f 1e fb          	endbr32 
  8019b1:	55                   	push   %ebp
  8019b2:	89 e5                	mov    %esp,%ebp
  8019b4:	53                   	push   %ebx
  8019b5:	83 ec 1c             	sub    $0x1c,%esp
  8019b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019be:	50                   	push   %eax
  8019bf:	ff 75 08             	pushl  0x8(%ebp)
  8019c2:	e8 52 fb ff ff       	call   801519 <fd_lookup>
  8019c7:	83 c4 10             	add    $0x10,%esp
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	78 4b                	js     801a19 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019ce:	83 ec 08             	sub    $0x8,%esp
  8019d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d4:	50                   	push   %eax
  8019d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019d8:	ff 30                	pushl  (%eax)
  8019da:	e8 8e fb ff ff       	call   80156d <dev_lookup>
  8019df:	83 c4 10             	add    $0x10,%esp
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	78 33                	js     801a19 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8019e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019ed:	74 2f                	je     801a1e <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019ef:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019f2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019f9:	00 00 00 
	stat->st_isdir = 0;
  8019fc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a03:	00 00 00 
	stat->st_dev = dev;
  801a06:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a0c:	83 ec 08             	sub    $0x8,%esp
  801a0f:	53                   	push   %ebx
  801a10:	ff 75 f0             	pushl  -0x10(%ebp)
  801a13:	ff 50 14             	call   *0x14(%eax)
  801a16:	83 c4 10             	add    $0x10,%esp
}
  801a19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1c:	c9                   	leave  
  801a1d:	c3                   	ret    
		return -E_NOT_SUPP;
  801a1e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a23:	eb f4                	jmp    801a19 <fstat+0x6c>

00801a25 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a25:	f3 0f 1e fb          	endbr32 
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	56                   	push   %esi
  801a2d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a2e:	83 ec 08             	sub    $0x8,%esp
  801a31:	6a 00                	push   $0x0
  801a33:	ff 75 08             	pushl  0x8(%ebp)
  801a36:	e8 01 02 00 00       	call   801c3c <open>
  801a3b:	89 c3                	mov    %eax,%ebx
  801a3d:	83 c4 10             	add    $0x10,%esp
  801a40:	85 c0                	test   %eax,%eax
  801a42:	78 1b                	js     801a5f <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801a44:	83 ec 08             	sub    $0x8,%esp
  801a47:	ff 75 0c             	pushl  0xc(%ebp)
  801a4a:	50                   	push   %eax
  801a4b:	e8 5d ff ff ff       	call   8019ad <fstat>
  801a50:	89 c6                	mov    %eax,%esi
	close(fd);
  801a52:	89 1c 24             	mov    %ebx,(%esp)
  801a55:	e8 fd fb ff ff       	call   801657 <close>
	return r;
  801a5a:	83 c4 10             	add    $0x10,%esp
  801a5d:	89 f3                	mov    %esi,%ebx
}
  801a5f:	89 d8                	mov    %ebx,%eax
  801a61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a64:	5b                   	pop    %ebx
  801a65:	5e                   	pop    %esi
  801a66:	5d                   	pop    %ebp
  801a67:	c3                   	ret    

00801a68 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	56                   	push   %esi
  801a6c:	53                   	push   %ebx
  801a6d:	89 c6                	mov    %eax,%esi
  801a6f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a71:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a78:	74 27                	je     801aa1 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a7a:	6a 07                	push   $0x7
  801a7c:	68 00 60 80 00       	push   $0x806000
  801a81:	56                   	push   %esi
  801a82:	ff 35 00 50 80 00    	pushl  0x805000
  801a88:	e8 fc 11 00 00       	call   802c89 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a8d:	83 c4 0c             	add    $0xc,%esp
  801a90:	6a 00                	push   $0x0
  801a92:	53                   	push   %ebx
  801a93:	6a 00                	push   $0x0
  801a95:	e8 82 11 00 00       	call   802c1c <ipc_recv>
}
  801a9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a9d:	5b                   	pop    %ebx
  801a9e:	5e                   	pop    %esi
  801a9f:	5d                   	pop    %ebp
  801aa0:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801aa1:	83 ec 0c             	sub    $0xc,%esp
  801aa4:	6a 01                	push   $0x1
  801aa6:	e8 36 12 00 00       	call   802ce1 <ipc_find_env>
  801aab:	a3 00 50 80 00       	mov    %eax,0x805000
  801ab0:	83 c4 10             	add    $0x10,%esp
  801ab3:	eb c5                	jmp    801a7a <fsipc+0x12>

00801ab5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ab5:	f3 0f 1e fb          	endbr32 
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801abf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac2:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac5:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801aca:	8b 45 0c             	mov    0xc(%ebp),%eax
  801acd:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ad2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad7:	b8 02 00 00 00       	mov    $0x2,%eax
  801adc:	e8 87 ff ff ff       	call   801a68 <fsipc>
}
  801ae1:	c9                   	leave  
  801ae2:	c3                   	ret    

00801ae3 <devfile_flush>:
{
  801ae3:	f3 0f 1e fb          	endbr32 
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801aed:	8b 45 08             	mov    0x8(%ebp),%eax
  801af0:	8b 40 0c             	mov    0xc(%eax),%eax
  801af3:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801af8:	ba 00 00 00 00       	mov    $0x0,%edx
  801afd:	b8 06 00 00 00       	mov    $0x6,%eax
  801b02:	e8 61 ff ff ff       	call   801a68 <fsipc>
}
  801b07:	c9                   	leave  
  801b08:	c3                   	ret    

00801b09 <devfile_stat>:
{
  801b09:	f3 0f 1e fb          	endbr32 
  801b0d:	55                   	push   %ebp
  801b0e:	89 e5                	mov    %esp,%ebp
  801b10:	53                   	push   %ebx
  801b11:	83 ec 04             	sub    $0x4,%esp
  801b14:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b17:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b1d:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b22:	ba 00 00 00 00       	mov    $0x0,%edx
  801b27:	b8 05 00 00 00       	mov    $0x5,%eax
  801b2c:	e8 37 ff ff ff       	call   801a68 <fsipc>
  801b31:	85 c0                	test   %eax,%eax
  801b33:	78 2c                	js     801b61 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b35:	83 ec 08             	sub    $0x8,%esp
  801b38:	68 00 60 80 00       	push   $0x806000
  801b3d:	53                   	push   %ebx
  801b3e:	e8 c4 f0 ff ff       	call   800c07 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b43:	a1 80 60 80 00       	mov    0x806080,%eax
  801b48:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b4e:	a1 84 60 80 00       	mov    0x806084,%eax
  801b53:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b59:	83 c4 10             	add    $0x10,%esp
  801b5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b64:	c9                   	leave  
  801b65:	c3                   	ret    

00801b66 <devfile_write>:
{
  801b66:	f3 0f 1e fb          	endbr32 
  801b6a:	55                   	push   %ebp
  801b6b:	89 e5                	mov    %esp,%ebp
  801b6d:	83 ec 0c             	sub    $0xc,%esp
  801b70:	8b 45 10             	mov    0x10(%ebp),%eax
  801b73:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b78:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b7d:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b80:	8b 55 08             	mov    0x8(%ebp),%edx
  801b83:	8b 52 0c             	mov    0xc(%edx),%edx
  801b86:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801b8c:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801b91:	50                   	push   %eax
  801b92:	ff 75 0c             	pushl  0xc(%ebp)
  801b95:	68 08 60 80 00       	push   $0x806008
  801b9a:	e8 66 f2 ff ff       	call   800e05 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801b9f:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba4:	b8 04 00 00 00       	mov    $0x4,%eax
  801ba9:	e8 ba fe ff ff       	call   801a68 <fsipc>
}
  801bae:	c9                   	leave  
  801baf:	c3                   	ret    

00801bb0 <devfile_read>:
{
  801bb0:	f3 0f 1e fb          	endbr32 
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	56                   	push   %esi
  801bb8:	53                   	push   %ebx
  801bb9:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbf:	8b 40 0c             	mov    0xc(%eax),%eax
  801bc2:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801bc7:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bcd:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd2:	b8 03 00 00 00       	mov    $0x3,%eax
  801bd7:	e8 8c fe ff ff       	call   801a68 <fsipc>
  801bdc:	89 c3                	mov    %eax,%ebx
  801bde:	85 c0                	test   %eax,%eax
  801be0:	78 1f                	js     801c01 <devfile_read+0x51>
	assert(r <= n);
  801be2:	39 f0                	cmp    %esi,%eax
  801be4:	77 24                	ja     801c0a <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801be6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801beb:	7f 36                	jg     801c23 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bed:	83 ec 04             	sub    $0x4,%esp
  801bf0:	50                   	push   %eax
  801bf1:	68 00 60 80 00       	push   $0x806000
  801bf6:	ff 75 0c             	pushl  0xc(%ebp)
  801bf9:	e8 07 f2 ff ff       	call   800e05 <memmove>
	return r;
  801bfe:	83 c4 10             	add    $0x10,%esp
}
  801c01:	89 d8                	mov    %ebx,%eax
  801c03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c06:	5b                   	pop    %ebx
  801c07:	5e                   	pop    %esi
  801c08:	5d                   	pop    %ebp
  801c09:	c3                   	ret    
	assert(r <= n);
  801c0a:	68 cc 35 80 00       	push   $0x8035cc
  801c0f:	68 d3 35 80 00       	push   $0x8035d3
  801c14:	68 8c 00 00 00       	push   $0x8c
  801c19:	68 e8 35 80 00       	push   $0x8035e8
  801c1e:	e8 f3 e8 ff ff       	call   800516 <_panic>
	assert(r <= PGSIZE);
  801c23:	68 f3 35 80 00       	push   $0x8035f3
  801c28:	68 d3 35 80 00       	push   $0x8035d3
  801c2d:	68 8d 00 00 00       	push   $0x8d
  801c32:	68 e8 35 80 00       	push   $0x8035e8
  801c37:	e8 da e8 ff ff       	call   800516 <_panic>

00801c3c <open>:
{
  801c3c:	f3 0f 1e fb          	endbr32 
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	56                   	push   %esi
  801c44:	53                   	push   %ebx
  801c45:	83 ec 1c             	sub    $0x1c,%esp
  801c48:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801c4b:	56                   	push   %esi
  801c4c:	e8 73 ef ff ff       	call   800bc4 <strlen>
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c59:	7f 6c                	jg     801cc7 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801c5b:	83 ec 0c             	sub    $0xc,%esp
  801c5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c61:	50                   	push   %eax
  801c62:	e8 5c f8 ff ff       	call   8014c3 <fd_alloc>
  801c67:	89 c3                	mov    %eax,%ebx
  801c69:	83 c4 10             	add    $0x10,%esp
  801c6c:	85 c0                	test   %eax,%eax
  801c6e:	78 3c                	js     801cac <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801c70:	83 ec 08             	sub    $0x8,%esp
  801c73:	56                   	push   %esi
  801c74:	68 00 60 80 00       	push   $0x806000
  801c79:	e8 89 ef ff ff       	call   800c07 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c81:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c86:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c89:	b8 01 00 00 00       	mov    $0x1,%eax
  801c8e:	e8 d5 fd ff ff       	call   801a68 <fsipc>
  801c93:	89 c3                	mov    %eax,%ebx
  801c95:	83 c4 10             	add    $0x10,%esp
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	78 19                	js     801cb5 <open+0x79>
	return fd2num(fd);
  801c9c:	83 ec 0c             	sub    $0xc,%esp
  801c9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca2:	e8 ed f7 ff ff       	call   801494 <fd2num>
  801ca7:	89 c3                	mov    %eax,%ebx
  801ca9:	83 c4 10             	add    $0x10,%esp
}
  801cac:	89 d8                	mov    %ebx,%eax
  801cae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb1:	5b                   	pop    %ebx
  801cb2:	5e                   	pop    %esi
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    
		fd_close(fd, 0);
  801cb5:	83 ec 08             	sub    $0x8,%esp
  801cb8:	6a 00                	push   $0x0
  801cba:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbd:	e8 0a f9 ff ff       	call   8015cc <fd_close>
		return r;
  801cc2:	83 c4 10             	add    $0x10,%esp
  801cc5:	eb e5                	jmp    801cac <open+0x70>
		return -E_BAD_PATH;
  801cc7:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801ccc:	eb de                	jmp    801cac <open+0x70>

00801cce <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801cce:	f3 0f 1e fb          	endbr32 
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cd8:	ba 00 00 00 00       	mov    $0x0,%edx
  801cdd:	b8 08 00 00 00       	mov    $0x8,%eax
  801ce2:	e8 81 fd ff ff       	call   801a68 <fsipc>
}
  801ce7:	c9                   	leave  
  801ce8:	c3                   	ret    

00801ce9 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801ce9:	f3 0f 1e fb          	endbr32 
  801ced:	55                   	push   %ebp
  801cee:	89 e5                	mov    %esp,%ebp
  801cf0:	57                   	push   %edi
  801cf1:	56                   	push   %esi
  801cf2:	53                   	push   %ebx
  801cf3:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801cf9:	6a 00                	push   $0x0
  801cfb:	ff 75 08             	pushl  0x8(%ebp)
  801cfe:	e8 39 ff ff ff       	call   801c3c <open>
  801d03:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801d09:	83 c4 10             	add    $0x10,%esp
  801d0c:	85 c0                	test   %eax,%eax
  801d0e:	0f 88 b2 04 00 00    	js     8021c6 <spawn+0x4dd>
  801d14:	89 c1                	mov    %eax,%ecx
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801d16:	83 ec 04             	sub    $0x4,%esp
  801d19:	68 00 02 00 00       	push   $0x200
  801d1e:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801d24:	50                   	push   %eax
  801d25:	51                   	push   %ecx
  801d26:	e8 01 fb ff ff       	call   80182c <readn>
  801d2b:	83 c4 10             	add    $0x10,%esp
  801d2e:	3d 00 02 00 00       	cmp    $0x200,%eax
  801d33:	75 7e                	jne    801db3 <spawn+0xca>
	    || elf->e_magic != ELF_MAGIC) {
  801d35:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801d3c:	45 4c 46 
  801d3f:	75 72                	jne    801db3 <spawn+0xca>
  801d41:	b8 07 00 00 00       	mov    $0x7,%eax
  801d46:	cd 30                	int    $0x30
  801d48:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801d4e:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801d54:	85 c0                	test   %eax,%eax
  801d56:	0f 88 5e 04 00 00    	js     8021ba <spawn+0x4d1>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801d5c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801d61:	6b f0 7c             	imul   $0x7c,%eax,%esi
  801d64:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801d6a:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801d70:	b9 11 00 00 00       	mov    $0x11,%ecx
  801d75:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801d77:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801d7d:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d83:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801d88:	be 00 00 00 00       	mov    $0x0,%esi
  801d8d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d90:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
	for (argc = 0; argv[argc] != 0; argc++)
  801d97:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	74 4d                	je     801deb <spawn+0x102>
		string_size += strlen(argv[argc]) + 1;
  801d9e:	83 ec 0c             	sub    $0xc,%esp
  801da1:	50                   	push   %eax
  801da2:	e8 1d ee ff ff       	call   800bc4 <strlen>
  801da7:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801dab:	83 c3 01             	add    $0x1,%ebx
  801dae:	83 c4 10             	add    $0x10,%esp
  801db1:	eb dd                	jmp    801d90 <spawn+0xa7>
		close(fd);
  801db3:	83 ec 0c             	sub    $0xc,%esp
  801db6:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801dbc:	e8 96 f8 ff ff       	call   801657 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801dc1:	83 c4 0c             	add    $0xc,%esp
  801dc4:	68 7f 45 4c 46       	push   $0x464c457f
  801dc9:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801dcf:	68 5f 36 80 00       	push   $0x80365f
  801dd4:	e8 24 e8 ff ff       	call   8005fd <cprintf>
		return -E_NOT_EXEC;
  801dd9:	83 c4 10             	add    $0x10,%esp
  801ddc:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  801de3:	ff ff ff 
  801de6:	e9 db 03 00 00       	jmp    8021c6 <spawn+0x4dd>
  801deb:	89 85 70 fd ff ff    	mov    %eax,-0x290(%ebp)
  801df1:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801df7:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801dfd:	bf 00 10 40 00       	mov    $0x401000,%edi
  801e02:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801e04:	89 fa                	mov    %edi,%edx
  801e06:	83 e2 fc             	and    $0xfffffffc,%edx
  801e09:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801e10:	29 c2                	sub    %eax,%edx
  801e12:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801e18:	8d 42 f8             	lea    -0x8(%edx),%eax
  801e1b:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801e20:	0f 86 12 04 00 00    	jbe    802238 <spawn+0x54f>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e26:	83 ec 04             	sub    $0x4,%esp
  801e29:	6a 07                	push   $0x7
  801e2b:	68 00 00 40 00       	push   $0x400000
  801e30:	6a 00                	push   $0x0
  801e32:	e8 39 f2 ff ff       	call   801070 <sys_page_alloc>
  801e37:	83 c4 10             	add    $0x10,%esp
  801e3a:	85 c0                	test   %eax,%eax
  801e3c:	0f 88 fb 03 00 00    	js     80223d <spawn+0x554>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801e42:	be 00 00 00 00       	mov    $0x0,%esi
  801e47:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801e4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e50:	eb 30                	jmp    801e82 <spawn+0x199>
		argv_store[i] = UTEMP2USTACK(string_store);
  801e52:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801e58:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801e5e:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801e61:	83 ec 08             	sub    $0x8,%esp
  801e64:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801e67:	57                   	push   %edi
  801e68:	e8 9a ed ff ff       	call   800c07 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801e6d:	83 c4 04             	add    $0x4,%esp
  801e70:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801e73:	e8 4c ed ff ff       	call   800bc4 <strlen>
  801e78:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801e7c:	83 c6 01             	add    $0x1,%esi
  801e7f:	83 c4 10             	add    $0x10,%esp
  801e82:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  801e88:	7f c8                	jg     801e52 <spawn+0x169>
	}
	argv_store[argc] = 0;
  801e8a:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801e90:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801e96:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801e9d:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801ea3:	0f 85 88 00 00 00    	jne    801f31 <spawn+0x248>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801ea9:	8b 8d 90 fd ff ff    	mov    -0x270(%ebp),%ecx
  801eaf:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  801eb5:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801eb8:	89 c8                	mov    %ecx,%eax
  801eba:	8b 95 84 fd ff ff    	mov    -0x27c(%ebp),%edx
  801ec0:	89 51 f8             	mov    %edx,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801ec3:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801ec8:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801ece:	83 ec 0c             	sub    $0xc,%esp
  801ed1:	6a 07                	push   $0x7
  801ed3:	68 00 d0 bf ee       	push   $0xeebfd000
  801ed8:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ede:	68 00 00 40 00       	push   $0x400000
  801ee3:	6a 00                	push   $0x0
  801ee5:	e8 ac f1 ff ff       	call   801096 <sys_page_map>
  801eea:	89 c3                	mov    %eax,%ebx
  801eec:	83 c4 20             	add    $0x20,%esp
  801eef:	85 c0                	test   %eax,%eax
  801ef1:	0f 88 4e 03 00 00    	js     802245 <spawn+0x55c>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801ef7:	83 ec 08             	sub    $0x8,%esp
  801efa:	68 00 00 40 00       	push   $0x400000
  801eff:	6a 00                	push   $0x0
  801f01:	e8 b5 f1 ff ff       	call   8010bb <sys_page_unmap>
  801f06:	89 c3                	mov    %eax,%ebx
  801f08:	83 c4 10             	add    $0x10,%esp
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	0f 88 32 03 00 00    	js     802245 <spawn+0x55c>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801f13:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801f19:	8d b4 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%esi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f20:	c7 85 84 fd ff ff 00 	movl   $0x0,-0x27c(%ebp)
  801f27:	00 00 00 
  801f2a:	89 f7                	mov    %esi,%edi
  801f2c:	e9 4f 01 00 00       	jmp    802080 <spawn+0x397>
	assert(string_store == (char*)UTEMP + PGSIZE);
  801f31:	68 ec 36 80 00       	push   $0x8036ec
  801f36:	68 d3 35 80 00       	push   $0x8035d3
  801f3b:	68 f1 00 00 00       	push   $0xf1
  801f40:	68 79 36 80 00       	push   $0x803679
  801f45:	e8 cc e5 ff ff       	call   800516 <_panic>
			// allocate a blank page bss segment
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f4a:	83 ec 04             	sub    $0x4,%esp
  801f4d:	6a 07                	push   $0x7
  801f4f:	68 00 00 40 00       	push   $0x400000
  801f54:	6a 00                	push   $0x0
  801f56:	e8 15 f1 ff ff       	call   801070 <sys_page_alloc>
  801f5b:	83 c4 10             	add    $0x10,%esp
  801f5e:	85 c0                	test   %eax,%eax
  801f60:	0f 88 6e 02 00 00    	js     8021d4 <spawn+0x4eb>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f66:	83 ec 08             	sub    $0x8,%esp
  801f69:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801f6f:	01 f8                	add    %edi,%eax
  801f71:	50                   	push   %eax
  801f72:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801f78:	e8 80 f9 ff ff       	call   8018fd <seek>
  801f7d:	83 c4 10             	add    $0x10,%esp
  801f80:	85 c0                	test   %eax,%eax
  801f82:	0f 88 53 02 00 00    	js     8021db <spawn+0x4f2>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801f88:	83 ec 04             	sub    $0x4,%esp
  801f8b:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801f91:	29 f8                	sub    %edi,%eax
  801f93:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f98:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801f9d:	0f 47 c1             	cmova  %ecx,%eax
  801fa0:	50                   	push   %eax
  801fa1:	68 00 00 40 00       	push   $0x400000
  801fa6:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801fac:	e8 7b f8 ff ff       	call   80182c <readn>
  801fb1:	83 c4 10             	add    $0x10,%esp
  801fb4:	85 c0                	test   %eax,%eax
  801fb6:	0f 88 26 02 00 00    	js     8021e2 <spawn+0x4f9>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801fbc:	83 ec 0c             	sub    $0xc,%esp
  801fbf:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801fc5:	53                   	push   %ebx
  801fc6:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801fcc:	68 00 00 40 00       	push   $0x400000
  801fd1:	6a 00                	push   $0x0
  801fd3:	e8 be f0 ff ff       	call   801096 <sys_page_map>
  801fd8:	83 c4 20             	add    $0x20,%esp
  801fdb:	85 c0                	test   %eax,%eax
  801fdd:	78 7c                	js     80205b <spawn+0x372>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  801fdf:	83 ec 08             	sub    $0x8,%esp
  801fe2:	68 00 00 40 00       	push   $0x400000
  801fe7:	6a 00                	push   $0x0
  801fe9:	e8 cd f0 ff ff       	call   8010bb <sys_page_unmap>
  801fee:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801ff1:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801ff7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ffd:	89 f7                	mov    %esi,%edi
  801fff:	39 b5 7c fd ff ff    	cmp    %esi,-0x284(%ebp)
  802005:	76 69                	jbe    802070 <spawn+0x387>
		if (i >= filesz) {
  802007:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  80200d:	0f 87 37 ff ff ff    	ja     801f4a <spawn+0x261>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802013:	83 ec 04             	sub    $0x4,%esp
  802016:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80201c:	53                   	push   %ebx
  80201d:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802023:	e8 48 f0 ff ff       	call   801070 <sys_page_alloc>
  802028:	83 c4 10             	add    $0x10,%esp
  80202b:	85 c0                	test   %eax,%eax
  80202d:	79 c2                	jns    801ff1 <spawn+0x308>
  80202f:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  802031:	83 ec 0c             	sub    $0xc,%esp
  802034:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80203a:	e8 c7 ef ff ff       	call   801006 <sys_env_destroy>
	close(fd);
  80203f:	83 c4 04             	add    $0x4,%esp
  802042:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  802048:	e8 0a f6 ff ff       	call   801657 <close>
	return r;
  80204d:	83 c4 10             	add    $0x10,%esp
  802050:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
  802056:	e9 6b 01 00 00       	jmp    8021c6 <spawn+0x4dd>
				panic("spawn: sys_page_map data: %e", r);
  80205b:	50                   	push   %eax
  80205c:	68 85 36 80 00       	push   $0x803685
  802061:	68 24 01 00 00       	push   $0x124
  802066:	68 79 36 80 00       	push   $0x803679
  80206b:	e8 a6 e4 ff ff       	call   800516 <_panic>
  802070:	8b bd 78 fd ff ff    	mov    -0x288(%ebp),%edi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802076:	83 85 84 fd ff ff 01 	addl   $0x1,-0x27c(%ebp)
  80207d:	83 c7 20             	add    $0x20,%edi
  802080:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802087:	3b 85 84 fd ff ff    	cmp    -0x27c(%ebp),%eax
  80208d:	7e 6d                	jle    8020fc <spawn+0x413>
		if (ph->p_type != ELF_PROG_LOAD)
  80208f:	83 3f 01             	cmpl   $0x1,(%edi)
  802092:	75 e2                	jne    802076 <spawn+0x38d>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802094:	8b 47 18             	mov    0x18(%edi),%eax
  802097:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  80209a:	83 f8 01             	cmp    $0x1,%eax
  80209d:	19 c0                	sbb    %eax,%eax
  80209f:	83 e0 fe             	and    $0xfffffffe,%eax
  8020a2:	83 c0 07             	add    $0x7,%eax
  8020a5:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8020ab:	8b 57 04             	mov    0x4(%edi),%edx
  8020ae:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  8020b4:	8b 4f 10             	mov    0x10(%edi),%ecx
  8020b7:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  8020bd:	8b 77 14             	mov    0x14(%edi),%esi
  8020c0:	89 b5 7c fd ff ff    	mov    %esi,-0x284(%ebp)
  8020c6:	8b 5f 08             	mov    0x8(%edi),%ebx
	if ((i = PGOFF(va))) {
  8020c9:	89 d8                	mov    %ebx,%eax
  8020cb:	25 ff 0f 00 00       	and    $0xfff,%eax
  8020d0:	74 1a                	je     8020ec <spawn+0x403>
		va -= i;
  8020d2:	29 c3                	sub    %eax,%ebx
		memsz += i;
  8020d4:	01 c6                	add    %eax,%esi
  8020d6:	89 b5 7c fd ff ff    	mov    %esi,-0x284(%ebp)
		filesz += i;
  8020dc:	01 c1                	add    %eax,%ecx
  8020de:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
		fileoffset -= i;
  8020e4:	29 c2                	sub    %eax,%edx
  8020e6:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  8020ec:	be 00 00 00 00       	mov    $0x0,%esi
  8020f1:	89 bd 78 fd ff ff    	mov    %edi,-0x288(%ebp)
  8020f7:	e9 01 ff ff ff       	jmp    801ffd <spawn+0x314>
	close(fd);
  8020fc:	83 ec 0c             	sub    $0xc,%esp
  8020ff:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  802105:	e8 4d f5 ff ff       	call   801657 <close>
  80210a:	83 c4 10             	add    $0x10,%esp
  80210d:	8b b5 88 fd ff ff    	mov    -0x278(%ebp),%esi
  802113:	8b 9d 70 fd ff ff    	mov    -0x290(%ebp),%ebx
  802119:	eb 12                	jmp    80212d <spawn+0x444>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	void* addr; int r;
	for (addr = 0; addr<(void*)USTACKTOP; addr+=PGSIZE){
  80211b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802121:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  802127:	0f 84 bc 00 00 00    	je     8021e9 <spawn+0x500>
		if ((uvpd[PDX(addr)]&PTE_P) && (uvpt[PGNUM(addr)]&PTE_P) && (uvpt[PGNUM(addr)]&PTE_SHARE)){
  80212d:	89 d8                	mov    %ebx,%eax
  80212f:	c1 e8 16             	shr    $0x16,%eax
  802132:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802139:	a8 01                	test   $0x1,%al
  80213b:	74 de                	je     80211b <spawn+0x432>
  80213d:	89 d8                	mov    %ebx,%eax
  80213f:	c1 e8 0c             	shr    $0xc,%eax
  802142:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802149:	f6 c2 01             	test   $0x1,%dl
  80214c:	74 cd                	je     80211b <spawn+0x432>
  80214e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802155:	f6 c6 04             	test   $0x4,%dh
  802158:	74 c1                	je     80211b <spawn+0x432>
			if ((r = sys_page_map(0, addr, child, addr, (uvpt[PGNUM(addr)]&PTE_SYSCALL)))<0)
  80215a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802161:	83 ec 0c             	sub    $0xc,%esp
  802164:	25 07 0e 00 00       	and    $0xe07,%eax
  802169:	50                   	push   %eax
  80216a:	53                   	push   %ebx
  80216b:	56                   	push   %esi
  80216c:	53                   	push   %ebx
  80216d:	6a 00                	push   $0x0
  80216f:	e8 22 ef ff ff       	call   801096 <sys_page_map>
  802174:	83 c4 20             	add    $0x20,%esp
  802177:	85 c0                	test   %eax,%eax
  802179:	79 a0                	jns    80211b <spawn+0x432>
		panic("copy_shared_pages: %e", r);
  80217b:	50                   	push   %eax
  80217c:	68 d3 36 80 00       	push   $0x8036d3
  802181:	68 82 00 00 00       	push   $0x82
  802186:	68 79 36 80 00       	push   $0x803679
  80218b:	e8 86 e3 ff ff       	call   800516 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  802190:	50                   	push   %eax
  802191:	68 a2 36 80 00       	push   $0x8036a2
  802196:	68 86 00 00 00       	push   $0x86
  80219b:	68 79 36 80 00       	push   $0x803679
  8021a0:	e8 71 e3 ff ff       	call   800516 <_panic>
		panic("sys_env_set_status: %e", r);
  8021a5:	50                   	push   %eax
  8021a6:	68 bc 36 80 00       	push   $0x8036bc
  8021ab:	68 89 00 00 00       	push   $0x89
  8021b0:	68 79 36 80 00       	push   $0x803679
  8021b5:	e8 5c e3 ff ff       	call   800516 <_panic>
		return r;
  8021ba:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8021c0:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
}
  8021c6:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8021cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021cf:	5b                   	pop    %ebx
  8021d0:	5e                   	pop    %esi
  8021d1:	5f                   	pop    %edi
  8021d2:	5d                   	pop    %ebp
  8021d3:	c3                   	ret    
  8021d4:	89 c7                	mov    %eax,%edi
  8021d6:	e9 56 fe ff ff       	jmp    802031 <spawn+0x348>
  8021db:	89 c7                	mov    %eax,%edi
  8021dd:	e9 4f fe ff ff       	jmp    802031 <spawn+0x348>
  8021e2:	89 c7                	mov    %eax,%edi
  8021e4:	e9 48 fe ff ff       	jmp    802031 <spawn+0x348>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8021e9:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8021f0:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8021f3:	83 ec 08             	sub    $0x8,%esp
  8021f6:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8021fc:	50                   	push   %eax
  8021fd:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802203:	e8 fd ee ff ff       	call   801105 <sys_env_set_trapframe>
  802208:	83 c4 10             	add    $0x10,%esp
  80220b:	85 c0                	test   %eax,%eax
  80220d:	78 81                	js     802190 <spawn+0x4a7>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80220f:	83 ec 08             	sub    $0x8,%esp
  802212:	6a 02                	push   $0x2
  802214:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80221a:	e8 c1 ee ff ff       	call   8010e0 <sys_env_set_status>
  80221f:	83 c4 10             	add    $0x10,%esp
  802222:	85 c0                	test   %eax,%eax
  802224:	0f 88 7b ff ff ff    	js     8021a5 <spawn+0x4bc>
	return child;
  80222a:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802230:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802236:	eb 8e                	jmp    8021c6 <spawn+0x4dd>
		return -E_NO_MEM;
  802238:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80223d:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802243:	eb 81                	jmp    8021c6 <spawn+0x4dd>
	sys_page_unmap(0, UTEMP);
  802245:	83 ec 08             	sub    $0x8,%esp
  802248:	68 00 00 40 00       	push   $0x400000
  80224d:	6a 00                	push   $0x0
  80224f:	e8 67 ee ff ff       	call   8010bb <sys_page_unmap>
  802254:	83 c4 10             	add    $0x10,%esp
  802257:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  80225d:	e9 64 ff ff ff       	jmp    8021c6 <spawn+0x4dd>

00802262 <spawnl>:
{
  802262:	f3 0f 1e fb          	endbr32 
  802266:	55                   	push   %ebp
  802267:	89 e5                	mov    %esp,%ebp
  802269:	57                   	push   %edi
  80226a:	56                   	push   %esi
  80226b:	53                   	push   %ebx
  80226c:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  80226f:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  802272:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  802277:	8d 4a 04             	lea    0x4(%edx),%ecx
  80227a:	83 3a 00             	cmpl   $0x0,(%edx)
  80227d:	74 07                	je     802286 <spawnl+0x24>
		argc++;
  80227f:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  802282:	89 ca                	mov    %ecx,%edx
  802284:	eb f1                	jmp    802277 <spawnl+0x15>
	const char *argv[argc+2];
  802286:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  80228d:	89 d1                	mov    %edx,%ecx
  80228f:	83 e1 f0             	and    $0xfffffff0,%ecx
  802292:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  802298:	89 e6                	mov    %esp,%esi
  80229a:	29 d6                	sub    %edx,%esi
  80229c:	89 f2                	mov    %esi,%edx
  80229e:	39 d4                	cmp    %edx,%esp
  8022a0:	74 10                	je     8022b2 <spawnl+0x50>
  8022a2:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  8022a8:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  8022af:	00 
  8022b0:	eb ec                	jmp    80229e <spawnl+0x3c>
  8022b2:	89 ca                	mov    %ecx,%edx
  8022b4:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  8022ba:	29 d4                	sub    %edx,%esp
  8022bc:	85 d2                	test   %edx,%edx
  8022be:	74 05                	je     8022c5 <spawnl+0x63>
  8022c0:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  8022c5:	8d 74 24 03          	lea    0x3(%esp),%esi
  8022c9:	89 f2                	mov    %esi,%edx
  8022cb:	c1 ea 02             	shr    $0x2,%edx
  8022ce:	83 e6 fc             	and    $0xfffffffc,%esi
  8022d1:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  8022d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022d6:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  8022dd:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  8022e4:	00 
	va_start(vl, arg0);
  8022e5:	8d 4d 10             	lea    0x10(%ebp),%ecx
  8022e8:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  8022ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8022ef:	eb 0b                	jmp    8022fc <spawnl+0x9a>
		argv[i+1] = va_arg(vl, const char *);
  8022f1:	83 c0 01             	add    $0x1,%eax
  8022f4:	8b 39                	mov    (%ecx),%edi
  8022f6:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  8022f9:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  8022fc:	39 d0                	cmp    %edx,%eax
  8022fe:	75 f1                	jne    8022f1 <spawnl+0x8f>
	return spawn(prog, argv);
  802300:	83 ec 08             	sub    $0x8,%esp
  802303:	56                   	push   %esi
  802304:	ff 75 08             	pushl  0x8(%ebp)
  802307:	e8 dd f9 ff ff       	call   801ce9 <spawn>
}
  80230c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80230f:	5b                   	pop    %ebx
  802310:	5e                   	pop    %esi
  802311:	5f                   	pop    %edi
  802312:	5d                   	pop    %ebp
  802313:	c3                   	ret    

00802314 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802314:	f3 0f 1e fb          	endbr32 
  802318:	55                   	push   %ebp
  802319:	89 e5                	mov    %esp,%ebp
  80231b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80231e:	68 12 37 80 00       	push   $0x803712
  802323:	ff 75 0c             	pushl  0xc(%ebp)
  802326:	e8 dc e8 ff ff       	call   800c07 <strcpy>
	return 0;
}
  80232b:	b8 00 00 00 00       	mov    $0x0,%eax
  802330:	c9                   	leave  
  802331:	c3                   	ret    

00802332 <devsock_close>:
{
  802332:	f3 0f 1e fb          	endbr32 
  802336:	55                   	push   %ebp
  802337:	89 e5                	mov    %esp,%ebp
  802339:	53                   	push   %ebx
  80233a:	83 ec 10             	sub    $0x10,%esp
  80233d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802340:	53                   	push   %ebx
  802341:	e8 d8 09 00 00       	call   802d1e <pageref>
  802346:	89 c2                	mov    %eax,%edx
  802348:	83 c4 10             	add    $0x10,%esp
		return 0;
  80234b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  802350:	83 fa 01             	cmp    $0x1,%edx
  802353:	74 05                	je     80235a <devsock_close+0x28>
}
  802355:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802358:	c9                   	leave  
  802359:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  80235a:	83 ec 0c             	sub    $0xc,%esp
  80235d:	ff 73 0c             	pushl  0xc(%ebx)
  802360:	e8 e3 02 00 00       	call   802648 <nsipc_close>
  802365:	83 c4 10             	add    $0x10,%esp
  802368:	eb eb                	jmp    802355 <devsock_close+0x23>

0080236a <devsock_write>:
{
  80236a:	f3 0f 1e fb          	endbr32 
  80236e:	55                   	push   %ebp
  80236f:	89 e5                	mov    %esp,%ebp
  802371:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802374:	6a 00                	push   $0x0
  802376:	ff 75 10             	pushl  0x10(%ebp)
  802379:	ff 75 0c             	pushl  0xc(%ebp)
  80237c:	8b 45 08             	mov    0x8(%ebp),%eax
  80237f:	ff 70 0c             	pushl  0xc(%eax)
  802382:	e8 b5 03 00 00       	call   80273c <nsipc_send>
}
  802387:	c9                   	leave  
  802388:	c3                   	ret    

00802389 <devsock_read>:
{
  802389:	f3 0f 1e fb          	endbr32 
  80238d:	55                   	push   %ebp
  80238e:	89 e5                	mov    %esp,%ebp
  802390:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802393:	6a 00                	push   $0x0
  802395:	ff 75 10             	pushl  0x10(%ebp)
  802398:	ff 75 0c             	pushl  0xc(%ebp)
  80239b:	8b 45 08             	mov    0x8(%ebp),%eax
  80239e:	ff 70 0c             	pushl  0xc(%eax)
  8023a1:	e8 1f 03 00 00       	call   8026c5 <nsipc_recv>
}
  8023a6:	c9                   	leave  
  8023a7:	c3                   	ret    

008023a8 <fd2sockid>:
{
  8023a8:	55                   	push   %ebp
  8023a9:	89 e5                	mov    %esp,%ebp
  8023ab:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8023ae:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8023b1:	52                   	push   %edx
  8023b2:	50                   	push   %eax
  8023b3:	e8 61 f1 ff ff       	call   801519 <fd_lookup>
  8023b8:	83 c4 10             	add    $0x10,%esp
  8023bb:	85 c0                	test   %eax,%eax
  8023bd:	78 10                	js     8023cf <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8023bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023c2:	8b 0d 60 40 80 00    	mov    0x804060,%ecx
  8023c8:	39 08                	cmp    %ecx,(%eax)
  8023ca:	75 05                	jne    8023d1 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8023cc:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8023cf:	c9                   	leave  
  8023d0:	c3                   	ret    
		return -E_NOT_SUPP;
  8023d1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8023d6:	eb f7                	jmp    8023cf <fd2sockid+0x27>

008023d8 <alloc_sockfd>:
{
  8023d8:	55                   	push   %ebp
  8023d9:	89 e5                	mov    %esp,%ebp
  8023db:	56                   	push   %esi
  8023dc:	53                   	push   %ebx
  8023dd:	83 ec 1c             	sub    $0x1c,%esp
  8023e0:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8023e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023e5:	50                   	push   %eax
  8023e6:	e8 d8 f0 ff ff       	call   8014c3 <fd_alloc>
  8023eb:	89 c3                	mov    %eax,%ebx
  8023ed:	83 c4 10             	add    $0x10,%esp
  8023f0:	85 c0                	test   %eax,%eax
  8023f2:	78 43                	js     802437 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8023f4:	83 ec 04             	sub    $0x4,%esp
  8023f7:	68 07 04 00 00       	push   $0x407
  8023fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8023ff:	6a 00                	push   $0x0
  802401:	e8 6a ec ff ff       	call   801070 <sys_page_alloc>
  802406:	89 c3                	mov    %eax,%ebx
  802408:	83 c4 10             	add    $0x10,%esp
  80240b:	85 c0                	test   %eax,%eax
  80240d:	78 28                	js     802437 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  80240f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802412:	8b 15 60 40 80 00    	mov    0x804060,%edx
  802418:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80241a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80241d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802424:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802427:	83 ec 0c             	sub    $0xc,%esp
  80242a:	50                   	push   %eax
  80242b:	e8 64 f0 ff ff       	call   801494 <fd2num>
  802430:	89 c3                	mov    %eax,%ebx
  802432:	83 c4 10             	add    $0x10,%esp
  802435:	eb 0c                	jmp    802443 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  802437:	83 ec 0c             	sub    $0xc,%esp
  80243a:	56                   	push   %esi
  80243b:	e8 08 02 00 00       	call   802648 <nsipc_close>
		return r;
  802440:	83 c4 10             	add    $0x10,%esp
}
  802443:	89 d8                	mov    %ebx,%eax
  802445:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802448:	5b                   	pop    %ebx
  802449:	5e                   	pop    %esi
  80244a:	5d                   	pop    %ebp
  80244b:	c3                   	ret    

0080244c <accept>:
{
  80244c:	f3 0f 1e fb          	endbr32 
  802450:	55                   	push   %ebp
  802451:	89 e5                	mov    %esp,%ebp
  802453:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802456:	8b 45 08             	mov    0x8(%ebp),%eax
  802459:	e8 4a ff ff ff       	call   8023a8 <fd2sockid>
  80245e:	85 c0                	test   %eax,%eax
  802460:	78 1b                	js     80247d <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802462:	83 ec 04             	sub    $0x4,%esp
  802465:	ff 75 10             	pushl  0x10(%ebp)
  802468:	ff 75 0c             	pushl  0xc(%ebp)
  80246b:	50                   	push   %eax
  80246c:	e8 22 01 00 00       	call   802593 <nsipc_accept>
  802471:	83 c4 10             	add    $0x10,%esp
  802474:	85 c0                	test   %eax,%eax
  802476:	78 05                	js     80247d <accept+0x31>
	return alloc_sockfd(r);
  802478:	e8 5b ff ff ff       	call   8023d8 <alloc_sockfd>
}
  80247d:	c9                   	leave  
  80247e:	c3                   	ret    

0080247f <bind>:
{
  80247f:	f3 0f 1e fb          	endbr32 
  802483:	55                   	push   %ebp
  802484:	89 e5                	mov    %esp,%ebp
  802486:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802489:	8b 45 08             	mov    0x8(%ebp),%eax
  80248c:	e8 17 ff ff ff       	call   8023a8 <fd2sockid>
  802491:	85 c0                	test   %eax,%eax
  802493:	78 12                	js     8024a7 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  802495:	83 ec 04             	sub    $0x4,%esp
  802498:	ff 75 10             	pushl  0x10(%ebp)
  80249b:	ff 75 0c             	pushl  0xc(%ebp)
  80249e:	50                   	push   %eax
  80249f:	e8 45 01 00 00       	call   8025e9 <nsipc_bind>
  8024a4:	83 c4 10             	add    $0x10,%esp
}
  8024a7:	c9                   	leave  
  8024a8:	c3                   	ret    

008024a9 <shutdown>:
{
  8024a9:	f3 0f 1e fb          	endbr32 
  8024ad:	55                   	push   %ebp
  8024ae:	89 e5                	mov    %esp,%ebp
  8024b0:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8024b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b6:	e8 ed fe ff ff       	call   8023a8 <fd2sockid>
  8024bb:	85 c0                	test   %eax,%eax
  8024bd:	78 0f                	js     8024ce <shutdown+0x25>
	return nsipc_shutdown(r, how);
  8024bf:	83 ec 08             	sub    $0x8,%esp
  8024c2:	ff 75 0c             	pushl  0xc(%ebp)
  8024c5:	50                   	push   %eax
  8024c6:	e8 57 01 00 00       	call   802622 <nsipc_shutdown>
  8024cb:	83 c4 10             	add    $0x10,%esp
}
  8024ce:	c9                   	leave  
  8024cf:	c3                   	ret    

008024d0 <connect>:
{
  8024d0:	f3 0f 1e fb          	endbr32 
  8024d4:	55                   	push   %ebp
  8024d5:	89 e5                	mov    %esp,%ebp
  8024d7:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8024da:	8b 45 08             	mov    0x8(%ebp),%eax
  8024dd:	e8 c6 fe ff ff       	call   8023a8 <fd2sockid>
  8024e2:	85 c0                	test   %eax,%eax
  8024e4:	78 12                	js     8024f8 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  8024e6:	83 ec 04             	sub    $0x4,%esp
  8024e9:	ff 75 10             	pushl  0x10(%ebp)
  8024ec:	ff 75 0c             	pushl  0xc(%ebp)
  8024ef:	50                   	push   %eax
  8024f0:	e8 71 01 00 00       	call   802666 <nsipc_connect>
  8024f5:	83 c4 10             	add    $0x10,%esp
}
  8024f8:	c9                   	leave  
  8024f9:	c3                   	ret    

008024fa <listen>:
{
  8024fa:	f3 0f 1e fb          	endbr32 
  8024fe:	55                   	push   %ebp
  8024ff:	89 e5                	mov    %esp,%ebp
  802501:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802504:	8b 45 08             	mov    0x8(%ebp),%eax
  802507:	e8 9c fe ff ff       	call   8023a8 <fd2sockid>
  80250c:	85 c0                	test   %eax,%eax
  80250e:	78 0f                	js     80251f <listen+0x25>
	return nsipc_listen(r, backlog);
  802510:	83 ec 08             	sub    $0x8,%esp
  802513:	ff 75 0c             	pushl  0xc(%ebp)
  802516:	50                   	push   %eax
  802517:	e8 83 01 00 00       	call   80269f <nsipc_listen>
  80251c:	83 c4 10             	add    $0x10,%esp
}
  80251f:	c9                   	leave  
  802520:	c3                   	ret    

00802521 <socket>:

int
socket(int domain, int type, int protocol)
{
  802521:	f3 0f 1e fb          	endbr32 
  802525:	55                   	push   %ebp
  802526:	89 e5                	mov    %esp,%ebp
  802528:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80252b:	ff 75 10             	pushl  0x10(%ebp)
  80252e:	ff 75 0c             	pushl  0xc(%ebp)
  802531:	ff 75 08             	pushl  0x8(%ebp)
  802534:	e8 65 02 00 00       	call   80279e <nsipc_socket>
  802539:	83 c4 10             	add    $0x10,%esp
  80253c:	85 c0                	test   %eax,%eax
  80253e:	78 05                	js     802545 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  802540:	e8 93 fe ff ff       	call   8023d8 <alloc_sockfd>
}
  802545:	c9                   	leave  
  802546:	c3                   	ret    

00802547 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802547:	55                   	push   %ebp
  802548:	89 e5                	mov    %esp,%ebp
  80254a:	53                   	push   %ebx
  80254b:	83 ec 04             	sub    $0x4,%esp
  80254e:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802550:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802557:	74 26                	je     80257f <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802559:	6a 07                	push   $0x7
  80255b:	68 00 70 80 00       	push   $0x807000
  802560:	53                   	push   %ebx
  802561:	ff 35 04 50 80 00    	pushl  0x805004
  802567:	e8 1d 07 00 00       	call   802c89 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80256c:	83 c4 0c             	add    $0xc,%esp
  80256f:	6a 00                	push   $0x0
  802571:	6a 00                	push   $0x0
  802573:	6a 00                	push   $0x0
  802575:	e8 a2 06 00 00       	call   802c1c <ipc_recv>
}
  80257a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80257d:	c9                   	leave  
  80257e:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80257f:	83 ec 0c             	sub    $0xc,%esp
  802582:	6a 02                	push   $0x2
  802584:	e8 58 07 00 00       	call   802ce1 <ipc_find_env>
  802589:	a3 04 50 80 00       	mov    %eax,0x805004
  80258e:	83 c4 10             	add    $0x10,%esp
  802591:	eb c6                	jmp    802559 <nsipc+0x12>

00802593 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802593:	f3 0f 1e fb          	endbr32 
  802597:	55                   	push   %ebp
  802598:	89 e5                	mov    %esp,%ebp
  80259a:	56                   	push   %esi
  80259b:	53                   	push   %ebx
  80259c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80259f:	8b 45 08             	mov    0x8(%ebp),%eax
  8025a2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8025a7:	8b 06                	mov    (%esi),%eax
  8025a9:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8025ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8025b3:	e8 8f ff ff ff       	call   802547 <nsipc>
  8025b8:	89 c3                	mov    %eax,%ebx
  8025ba:	85 c0                	test   %eax,%eax
  8025bc:	79 09                	jns    8025c7 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8025be:	89 d8                	mov    %ebx,%eax
  8025c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025c3:	5b                   	pop    %ebx
  8025c4:	5e                   	pop    %esi
  8025c5:	5d                   	pop    %ebp
  8025c6:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8025c7:	83 ec 04             	sub    $0x4,%esp
  8025ca:	ff 35 10 70 80 00    	pushl  0x807010
  8025d0:	68 00 70 80 00       	push   $0x807000
  8025d5:	ff 75 0c             	pushl  0xc(%ebp)
  8025d8:	e8 28 e8 ff ff       	call   800e05 <memmove>
		*addrlen = ret->ret_addrlen;
  8025dd:	a1 10 70 80 00       	mov    0x807010,%eax
  8025e2:	89 06                	mov    %eax,(%esi)
  8025e4:	83 c4 10             	add    $0x10,%esp
	return r;
  8025e7:	eb d5                	jmp    8025be <nsipc_accept+0x2b>

008025e9 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8025e9:	f3 0f 1e fb          	endbr32 
  8025ed:	55                   	push   %ebp
  8025ee:	89 e5                	mov    %esp,%ebp
  8025f0:	53                   	push   %ebx
  8025f1:	83 ec 08             	sub    $0x8,%esp
  8025f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8025f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8025fa:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8025ff:	53                   	push   %ebx
  802600:	ff 75 0c             	pushl  0xc(%ebp)
  802603:	68 04 70 80 00       	push   $0x807004
  802608:	e8 f8 e7 ff ff       	call   800e05 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80260d:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802613:	b8 02 00 00 00       	mov    $0x2,%eax
  802618:	e8 2a ff ff ff       	call   802547 <nsipc>
}
  80261d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802620:	c9                   	leave  
  802621:	c3                   	ret    

00802622 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802622:	f3 0f 1e fb          	endbr32 
  802626:	55                   	push   %ebp
  802627:	89 e5                	mov    %esp,%ebp
  802629:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80262c:	8b 45 08             	mov    0x8(%ebp),%eax
  80262f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802634:	8b 45 0c             	mov    0xc(%ebp),%eax
  802637:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  80263c:	b8 03 00 00 00       	mov    $0x3,%eax
  802641:	e8 01 ff ff ff       	call   802547 <nsipc>
}
  802646:	c9                   	leave  
  802647:	c3                   	ret    

00802648 <nsipc_close>:

int
nsipc_close(int s)
{
  802648:	f3 0f 1e fb          	endbr32 
  80264c:	55                   	push   %ebp
  80264d:	89 e5                	mov    %esp,%ebp
  80264f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802652:	8b 45 08             	mov    0x8(%ebp),%eax
  802655:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80265a:	b8 04 00 00 00       	mov    $0x4,%eax
  80265f:	e8 e3 fe ff ff       	call   802547 <nsipc>
}
  802664:	c9                   	leave  
  802665:	c3                   	ret    

00802666 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802666:	f3 0f 1e fb          	endbr32 
  80266a:	55                   	push   %ebp
  80266b:	89 e5                	mov    %esp,%ebp
  80266d:	53                   	push   %ebx
  80266e:	83 ec 08             	sub    $0x8,%esp
  802671:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802674:	8b 45 08             	mov    0x8(%ebp),%eax
  802677:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80267c:	53                   	push   %ebx
  80267d:	ff 75 0c             	pushl  0xc(%ebp)
  802680:	68 04 70 80 00       	push   $0x807004
  802685:	e8 7b e7 ff ff       	call   800e05 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80268a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802690:	b8 05 00 00 00       	mov    $0x5,%eax
  802695:	e8 ad fe ff ff       	call   802547 <nsipc>
}
  80269a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80269d:	c9                   	leave  
  80269e:	c3                   	ret    

0080269f <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80269f:	f3 0f 1e fb          	endbr32 
  8026a3:	55                   	push   %ebp
  8026a4:	89 e5                	mov    %esp,%ebp
  8026a6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8026a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8026ac:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8026b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026b4:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8026b9:	b8 06 00 00 00       	mov    $0x6,%eax
  8026be:	e8 84 fe ff ff       	call   802547 <nsipc>
}
  8026c3:	c9                   	leave  
  8026c4:	c3                   	ret    

008026c5 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8026c5:	f3 0f 1e fb          	endbr32 
  8026c9:	55                   	push   %ebp
  8026ca:	89 e5                	mov    %esp,%ebp
  8026cc:	56                   	push   %esi
  8026cd:	53                   	push   %ebx
  8026ce:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8026d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8026d4:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8026d9:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8026df:	8b 45 14             	mov    0x14(%ebp),%eax
  8026e2:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8026e7:	b8 07 00 00 00       	mov    $0x7,%eax
  8026ec:	e8 56 fe ff ff       	call   802547 <nsipc>
  8026f1:	89 c3                	mov    %eax,%ebx
  8026f3:	85 c0                	test   %eax,%eax
  8026f5:	78 26                	js     80271d <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  8026f7:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  8026fd:	b8 3f 06 00 00       	mov    $0x63f,%eax
  802702:	0f 4e c6             	cmovle %esi,%eax
  802705:	39 c3                	cmp    %eax,%ebx
  802707:	7f 1d                	jg     802726 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802709:	83 ec 04             	sub    $0x4,%esp
  80270c:	53                   	push   %ebx
  80270d:	68 00 70 80 00       	push   $0x807000
  802712:	ff 75 0c             	pushl  0xc(%ebp)
  802715:	e8 eb e6 ff ff       	call   800e05 <memmove>
  80271a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80271d:	89 d8                	mov    %ebx,%eax
  80271f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802722:	5b                   	pop    %ebx
  802723:	5e                   	pop    %esi
  802724:	5d                   	pop    %ebp
  802725:	c3                   	ret    
		assert(r < 1600 && r <= len);
  802726:	68 1e 37 80 00       	push   $0x80371e
  80272b:	68 d3 35 80 00       	push   $0x8035d3
  802730:	6a 62                	push   $0x62
  802732:	68 33 37 80 00       	push   $0x803733
  802737:	e8 da dd ff ff       	call   800516 <_panic>

0080273c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80273c:	f3 0f 1e fb          	endbr32 
  802740:	55                   	push   %ebp
  802741:	89 e5                	mov    %esp,%ebp
  802743:	53                   	push   %ebx
  802744:	83 ec 04             	sub    $0x4,%esp
  802747:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80274a:	8b 45 08             	mov    0x8(%ebp),%eax
  80274d:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802752:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802758:	7f 2e                	jg     802788 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80275a:	83 ec 04             	sub    $0x4,%esp
  80275d:	53                   	push   %ebx
  80275e:	ff 75 0c             	pushl  0xc(%ebp)
  802761:	68 0c 70 80 00       	push   $0x80700c
  802766:	e8 9a e6 ff ff       	call   800e05 <memmove>
	nsipcbuf.send.req_size = size;
  80276b:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802771:	8b 45 14             	mov    0x14(%ebp),%eax
  802774:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802779:	b8 08 00 00 00       	mov    $0x8,%eax
  80277e:	e8 c4 fd ff ff       	call   802547 <nsipc>
}
  802783:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802786:	c9                   	leave  
  802787:	c3                   	ret    
	assert(size < 1600);
  802788:	68 3f 37 80 00       	push   $0x80373f
  80278d:	68 d3 35 80 00       	push   $0x8035d3
  802792:	6a 6d                	push   $0x6d
  802794:	68 33 37 80 00       	push   $0x803733
  802799:	e8 78 dd ff ff       	call   800516 <_panic>

0080279e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80279e:	f3 0f 1e fb          	endbr32 
  8027a2:	55                   	push   %ebp
  8027a3:	89 e5                	mov    %esp,%ebp
  8027a5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8027a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8027ab:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8027b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027b3:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8027b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8027bb:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8027c0:	b8 09 00 00 00       	mov    $0x9,%eax
  8027c5:	e8 7d fd ff ff       	call   802547 <nsipc>
}
  8027ca:	c9                   	leave  
  8027cb:	c3                   	ret    

008027cc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8027cc:	f3 0f 1e fb          	endbr32 
  8027d0:	55                   	push   %ebp
  8027d1:	89 e5                	mov    %esp,%ebp
  8027d3:	56                   	push   %esi
  8027d4:	53                   	push   %ebx
  8027d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8027d8:	83 ec 0c             	sub    $0xc,%esp
  8027db:	ff 75 08             	pushl  0x8(%ebp)
  8027de:	e8 c5 ec ff ff       	call   8014a8 <fd2data>
  8027e3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8027e5:	83 c4 08             	add    $0x8,%esp
  8027e8:	68 4b 37 80 00       	push   $0x80374b
  8027ed:	53                   	push   %ebx
  8027ee:	e8 14 e4 ff ff       	call   800c07 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8027f3:	8b 46 04             	mov    0x4(%esi),%eax
  8027f6:	2b 06                	sub    (%esi),%eax
  8027f8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8027fe:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802805:	00 00 00 
	stat->st_dev = &devpipe;
  802808:	c7 83 88 00 00 00 7c 	movl   $0x80407c,0x88(%ebx)
  80280f:	40 80 00 
	return 0;
}
  802812:	b8 00 00 00 00       	mov    $0x0,%eax
  802817:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80281a:	5b                   	pop    %ebx
  80281b:	5e                   	pop    %esi
  80281c:	5d                   	pop    %ebp
  80281d:	c3                   	ret    

0080281e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80281e:	f3 0f 1e fb          	endbr32 
  802822:	55                   	push   %ebp
  802823:	89 e5                	mov    %esp,%ebp
  802825:	53                   	push   %ebx
  802826:	83 ec 0c             	sub    $0xc,%esp
  802829:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80282c:	53                   	push   %ebx
  80282d:	6a 00                	push   $0x0
  80282f:	e8 87 e8 ff ff       	call   8010bb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802834:	89 1c 24             	mov    %ebx,(%esp)
  802837:	e8 6c ec ff ff       	call   8014a8 <fd2data>
  80283c:	83 c4 08             	add    $0x8,%esp
  80283f:	50                   	push   %eax
  802840:	6a 00                	push   $0x0
  802842:	e8 74 e8 ff ff       	call   8010bb <sys_page_unmap>
}
  802847:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80284a:	c9                   	leave  
  80284b:	c3                   	ret    

0080284c <_pipeisclosed>:
{
  80284c:	55                   	push   %ebp
  80284d:	89 e5                	mov    %esp,%ebp
  80284f:	57                   	push   %edi
  802850:	56                   	push   %esi
  802851:	53                   	push   %ebx
  802852:	83 ec 1c             	sub    $0x1c,%esp
  802855:	89 c7                	mov    %eax,%edi
  802857:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802859:	a1 08 50 80 00       	mov    0x805008,%eax
  80285e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802861:	83 ec 0c             	sub    $0xc,%esp
  802864:	57                   	push   %edi
  802865:	e8 b4 04 00 00       	call   802d1e <pageref>
  80286a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80286d:	89 34 24             	mov    %esi,(%esp)
  802870:	e8 a9 04 00 00       	call   802d1e <pageref>
		nn = thisenv->env_runs;
  802875:	8b 15 08 50 80 00    	mov    0x805008,%edx
  80287b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80287e:	83 c4 10             	add    $0x10,%esp
  802881:	39 cb                	cmp    %ecx,%ebx
  802883:	74 1b                	je     8028a0 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802885:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802888:	75 cf                	jne    802859 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80288a:	8b 42 58             	mov    0x58(%edx),%eax
  80288d:	6a 01                	push   $0x1
  80288f:	50                   	push   %eax
  802890:	53                   	push   %ebx
  802891:	68 52 37 80 00       	push   $0x803752
  802896:	e8 62 dd ff ff       	call   8005fd <cprintf>
  80289b:	83 c4 10             	add    $0x10,%esp
  80289e:	eb b9                	jmp    802859 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8028a0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8028a3:	0f 94 c0             	sete   %al
  8028a6:	0f b6 c0             	movzbl %al,%eax
}
  8028a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8028ac:	5b                   	pop    %ebx
  8028ad:	5e                   	pop    %esi
  8028ae:	5f                   	pop    %edi
  8028af:	5d                   	pop    %ebp
  8028b0:	c3                   	ret    

008028b1 <devpipe_write>:
{
  8028b1:	f3 0f 1e fb          	endbr32 
  8028b5:	55                   	push   %ebp
  8028b6:	89 e5                	mov    %esp,%ebp
  8028b8:	57                   	push   %edi
  8028b9:	56                   	push   %esi
  8028ba:	53                   	push   %ebx
  8028bb:	83 ec 28             	sub    $0x28,%esp
  8028be:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8028c1:	56                   	push   %esi
  8028c2:	e8 e1 eb ff ff       	call   8014a8 <fd2data>
  8028c7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8028c9:	83 c4 10             	add    $0x10,%esp
  8028cc:	bf 00 00 00 00       	mov    $0x0,%edi
  8028d1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8028d4:	74 4f                	je     802925 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8028d6:	8b 43 04             	mov    0x4(%ebx),%eax
  8028d9:	8b 0b                	mov    (%ebx),%ecx
  8028db:	8d 51 20             	lea    0x20(%ecx),%edx
  8028de:	39 d0                	cmp    %edx,%eax
  8028e0:	72 14                	jb     8028f6 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8028e2:	89 da                	mov    %ebx,%edx
  8028e4:	89 f0                	mov    %esi,%eax
  8028e6:	e8 61 ff ff ff       	call   80284c <_pipeisclosed>
  8028eb:	85 c0                	test   %eax,%eax
  8028ed:	75 3b                	jne    80292a <devpipe_write+0x79>
			sys_yield();
  8028ef:	e8 59 e7 ff ff       	call   80104d <sys_yield>
  8028f4:	eb e0                	jmp    8028d6 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8028f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8028f9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8028fd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802900:	89 c2                	mov    %eax,%edx
  802902:	c1 fa 1f             	sar    $0x1f,%edx
  802905:	89 d1                	mov    %edx,%ecx
  802907:	c1 e9 1b             	shr    $0x1b,%ecx
  80290a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80290d:	83 e2 1f             	and    $0x1f,%edx
  802910:	29 ca                	sub    %ecx,%edx
  802912:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802916:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80291a:	83 c0 01             	add    $0x1,%eax
  80291d:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802920:	83 c7 01             	add    $0x1,%edi
  802923:	eb ac                	jmp    8028d1 <devpipe_write+0x20>
	return i;
  802925:	8b 45 10             	mov    0x10(%ebp),%eax
  802928:	eb 05                	jmp    80292f <devpipe_write+0x7e>
				return 0;
  80292a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80292f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802932:	5b                   	pop    %ebx
  802933:	5e                   	pop    %esi
  802934:	5f                   	pop    %edi
  802935:	5d                   	pop    %ebp
  802936:	c3                   	ret    

00802937 <devpipe_read>:
{
  802937:	f3 0f 1e fb          	endbr32 
  80293b:	55                   	push   %ebp
  80293c:	89 e5                	mov    %esp,%ebp
  80293e:	57                   	push   %edi
  80293f:	56                   	push   %esi
  802940:	53                   	push   %ebx
  802941:	83 ec 18             	sub    $0x18,%esp
  802944:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802947:	57                   	push   %edi
  802948:	e8 5b eb ff ff       	call   8014a8 <fd2data>
  80294d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80294f:	83 c4 10             	add    $0x10,%esp
  802952:	be 00 00 00 00       	mov    $0x0,%esi
  802957:	3b 75 10             	cmp    0x10(%ebp),%esi
  80295a:	75 14                	jne    802970 <devpipe_read+0x39>
	return i;
  80295c:	8b 45 10             	mov    0x10(%ebp),%eax
  80295f:	eb 02                	jmp    802963 <devpipe_read+0x2c>
				return i;
  802961:	89 f0                	mov    %esi,%eax
}
  802963:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802966:	5b                   	pop    %ebx
  802967:	5e                   	pop    %esi
  802968:	5f                   	pop    %edi
  802969:	5d                   	pop    %ebp
  80296a:	c3                   	ret    
			sys_yield();
  80296b:	e8 dd e6 ff ff       	call   80104d <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802970:	8b 03                	mov    (%ebx),%eax
  802972:	3b 43 04             	cmp    0x4(%ebx),%eax
  802975:	75 18                	jne    80298f <devpipe_read+0x58>
			if (i > 0)
  802977:	85 f6                	test   %esi,%esi
  802979:	75 e6                	jne    802961 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  80297b:	89 da                	mov    %ebx,%edx
  80297d:	89 f8                	mov    %edi,%eax
  80297f:	e8 c8 fe ff ff       	call   80284c <_pipeisclosed>
  802984:	85 c0                	test   %eax,%eax
  802986:	74 e3                	je     80296b <devpipe_read+0x34>
				return 0;
  802988:	b8 00 00 00 00       	mov    $0x0,%eax
  80298d:	eb d4                	jmp    802963 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80298f:	99                   	cltd   
  802990:	c1 ea 1b             	shr    $0x1b,%edx
  802993:	01 d0                	add    %edx,%eax
  802995:	83 e0 1f             	and    $0x1f,%eax
  802998:	29 d0                	sub    %edx,%eax
  80299a:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80299f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8029a2:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8029a5:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8029a8:	83 c6 01             	add    $0x1,%esi
  8029ab:	eb aa                	jmp    802957 <devpipe_read+0x20>

008029ad <pipe>:
{
  8029ad:	f3 0f 1e fb          	endbr32 
  8029b1:	55                   	push   %ebp
  8029b2:	89 e5                	mov    %esp,%ebp
  8029b4:	56                   	push   %esi
  8029b5:	53                   	push   %ebx
  8029b6:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8029b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029bc:	50                   	push   %eax
  8029bd:	e8 01 eb ff ff       	call   8014c3 <fd_alloc>
  8029c2:	89 c3                	mov    %eax,%ebx
  8029c4:	83 c4 10             	add    $0x10,%esp
  8029c7:	85 c0                	test   %eax,%eax
  8029c9:	0f 88 23 01 00 00    	js     802af2 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8029cf:	83 ec 04             	sub    $0x4,%esp
  8029d2:	68 07 04 00 00       	push   $0x407
  8029d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8029da:	6a 00                	push   $0x0
  8029dc:	e8 8f e6 ff ff       	call   801070 <sys_page_alloc>
  8029e1:	89 c3                	mov    %eax,%ebx
  8029e3:	83 c4 10             	add    $0x10,%esp
  8029e6:	85 c0                	test   %eax,%eax
  8029e8:	0f 88 04 01 00 00    	js     802af2 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8029ee:	83 ec 0c             	sub    $0xc,%esp
  8029f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8029f4:	50                   	push   %eax
  8029f5:	e8 c9 ea ff ff       	call   8014c3 <fd_alloc>
  8029fa:	89 c3                	mov    %eax,%ebx
  8029fc:	83 c4 10             	add    $0x10,%esp
  8029ff:	85 c0                	test   %eax,%eax
  802a01:	0f 88 db 00 00 00    	js     802ae2 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802a07:	83 ec 04             	sub    $0x4,%esp
  802a0a:	68 07 04 00 00       	push   $0x407
  802a0f:	ff 75 f0             	pushl  -0x10(%ebp)
  802a12:	6a 00                	push   $0x0
  802a14:	e8 57 e6 ff ff       	call   801070 <sys_page_alloc>
  802a19:	89 c3                	mov    %eax,%ebx
  802a1b:	83 c4 10             	add    $0x10,%esp
  802a1e:	85 c0                	test   %eax,%eax
  802a20:	0f 88 bc 00 00 00    	js     802ae2 <pipe+0x135>
	va = fd2data(fd0);
  802a26:	83 ec 0c             	sub    $0xc,%esp
  802a29:	ff 75 f4             	pushl  -0xc(%ebp)
  802a2c:	e8 77 ea ff ff       	call   8014a8 <fd2data>
  802a31:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802a33:	83 c4 0c             	add    $0xc,%esp
  802a36:	68 07 04 00 00       	push   $0x407
  802a3b:	50                   	push   %eax
  802a3c:	6a 00                	push   $0x0
  802a3e:	e8 2d e6 ff ff       	call   801070 <sys_page_alloc>
  802a43:	89 c3                	mov    %eax,%ebx
  802a45:	83 c4 10             	add    $0x10,%esp
  802a48:	85 c0                	test   %eax,%eax
  802a4a:	0f 88 82 00 00 00    	js     802ad2 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802a50:	83 ec 0c             	sub    $0xc,%esp
  802a53:	ff 75 f0             	pushl  -0x10(%ebp)
  802a56:	e8 4d ea ff ff       	call   8014a8 <fd2data>
  802a5b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802a62:	50                   	push   %eax
  802a63:	6a 00                	push   $0x0
  802a65:	56                   	push   %esi
  802a66:	6a 00                	push   $0x0
  802a68:	e8 29 e6 ff ff       	call   801096 <sys_page_map>
  802a6d:	89 c3                	mov    %eax,%ebx
  802a6f:	83 c4 20             	add    $0x20,%esp
  802a72:	85 c0                	test   %eax,%eax
  802a74:	78 4e                	js     802ac4 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  802a76:	a1 7c 40 80 00       	mov    0x80407c,%eax
  802a7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802a7e:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802a80:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802a83:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802a8a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802a8d:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a92:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802a99:	83 ec 0c             	sub    $0xc,%esp
  802a9c:	ff 75 f4             	pushl  -0xc(%ebp)
  802a9f:	e8 f0 e9 ff ff       	call   801494 <fd2num>
  802aa4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802aa7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802aa9:	83 c4 04             	add    $0x4,%esp
  802aac:	ff 75 f0             	pushl  -0x10(%ebp)
  802aaf:	e8 e0 e9 ff ff       	call   801494 <fd2num>
  802ab4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802ab7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802aba:	83 c4 10             	add    $0x10,%esp
  802abd:	bb 00 00 00 00       	mov    $0x0,%ebx
  802ac2:	eb 2e                	jmp    802af2 <pipe+0x145>
	sys_page_unmap(0, va);
  802ac4:	83 ec 08             	sub    $0x8,%esp
  802ac7:	56                   	push   %esi
  802ac8:	6a 00                	push   $0x0
  802aca:	e8 ec e5 ff ff       	call   8010bb <sys_page_unmap>
  802acf:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802ad2:	83 ec 08             	sub    $0x8,%esp
  802ad5:	ff 75 f0             	pushl  -0x10(%ebp)
  802ad8:	6a 00                	push   $0x0
  802ada:	e8 dc e5 ff ff       	call   8010bb <sys_page_unmap>
  802adf:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802ae2:	83 ec 08             	sub    $0x8,%esp
  802ae5:	ff 75 f4             	pushl  -0xc(%ebp)
  802ae8:	6a 00                	push   $0x0
  802aea:	e8 cc e5 ff ff       	call   8010bb <sys_page_unmap>
  802aef:	83 c4 10             	add    $0x10,%esp
}
  802af2:	89 d8                	mov    %ebx,%eax
  802af4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802af7:	5b                   	pop    %ebx
  802af8:	5e                   	pop    %esi
  802af9:	5d                   	pop    %ebp
  802afa:	c3                   	ret    

00802afb <pipeisclosed>:
{
  802afb:	f3 0f 1e fb          	endbr32 
  802aff:	55                   	push   %ebp
  802b00:	89 e5                	mov    %esp,%ebp
  802b02:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802b05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b08:	50                   	push   %eax
  802b09:	ff 75 08             	pushl  0x8(%ebp)
  802b0c:	e8 08 ea ff ff       	call   801519 <fd_lookup>
  802b11:	83 c4 10             	add    $0x10,%esp
  802b14:	85 c0                	test   %eax,%eax
  802b16:	78 18                	js     802b30 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  802b18:	83 ec 0c             	sub    $0xc,%esp
  802b1b:	ff 75 f4             	pushl  -0xc(%ebp)
  802b1e:	e8 85 e9 ff ff       	call   8014a8 <fd2data>
  802b23:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b28:	e8 1f fd ff ff       	call   80284c <_pipeisclosed>
  802b2d:	83 c4 10             	add    $0x10,%esp
}
  802b30:	c9                   	leave  
  802b31:	c3                   	ret    

00802b32 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802b32:	f3 0f 1e fb          	endbr32 
  802b36:	55                   	push   %ebp
  802b37:	89 e5                	mov    %esp,%ebp
  802b39:	56                   	push   %esi
  802b3a:	53                   	push   %ebx
  802b3b:	8b 75 08             	mov    0x8(%ebp),%esi
	// cprintf("[%08x] called wait for child %08x\n", thisenv->env_id, envid);
	const volatile struct Env *e;

	assert(envid != 0);
  802b3e:	85 f6                	test   %esi,%esi
  802b40:	74 13                	je     802b55 <wait+0x23>
	e = &envs[ENVX(envid)];
  802b42:	89 f3                	mov    %esi,%ebx
  802b44:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802b4a:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802b4d:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802b53:	eb 1b                	jmp    802b70 <wait+0x3e>
	assert(envid != 0);
  802b55:	68 6a 37 80 00       	push   $0x80376a
  802b5a:	68 d3 35 80 00       	push   $0x8035d3
  802b5f:	6a 0a                	push   $0xa
  802b61:	68 75 37 80 00       	push   $0x803775
  802b66:	e8 ab d9 ff ff       	call   800516 <_panic>
		sys_yield();
  802b6b:	e8 dd e4 ff ff       	call   80104d <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802b70:	8b 43 48             	mov    0x48(%ebx),%eax
  802b73:	39 f0                	cmp    %esi,%eax
  802b75:	75 07                	jne    802b7e <wait+0x4c>
  802b77:	8b 43 54             	mov    0x54(%ebx),%eax
  802b7a:	85 c0                	test   %eax,%eax
  802b7c:	75 ed                	jne    802b6b <wait+0x39>
}
  802b7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b81:	5b                   	pop    %ebx
  802b82:	5e                   	pop    %esi
  802b83:	5d                   	pop    %ebp
  802b84:	c3                   	ret    

00802b85 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802b85:	f3 0f 1e fb          	endbr32 
  802b89:	55                   	push   %ebp
  802b8a:	89 e5                	mov    %esp,%ebp
  802b8c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802b8f:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802b96:	74 0a                	je     802ba2 <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802b98:	8b 45 08             	mov    0x8(%ebp),%eax
  802b9b:	a3 00 80 80 00       	mov    %eax,0x808000

}
  802ba0:	c9                   	leave  
  802ba1:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  802ba2:	83 ec 04             	sub    $0x4,%esp
  802ba5:	6a 07                	push   $0x7
  802ba7:	68 00 f0 bf ee       	push   $0xeebff000
  802bac:	6a 00                	push   $0x0
  802bae:	e8 bd e4 ff ff       	call   801070 <sys_page_alloc>
  802bb3:	83 c4 10             	add    $0x10,%esp
  802bb6:	85 c0                	test   %eax,%eax
  802bb8:	78 2a                	js     802be4 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  802bba:	83 ec 08             	sub    $0x8,%esp
  802bbd:	68 f8 2b 80 00       	push   $0x802bf8
  802bc2:	6a 00                	push   $0x0
  802bc4:	e8 61 e5 ff ff       	call   80112a <sys_env_set_pgfault_upcall>
  802bc9:	83 c4 10             	add    $0x10,%esp
  802bcc:	85 c0                	test   %eax,%eax
  802bce:	79 c8                	jns    802b98 <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  802bd0:	83 ec 04             	sub    $0x4,%esp
  802bd3:	68 ac 37 80 00       	push   $0x8037ac
  802bd8:	6a 2c                	push   $0x2c
  802bda:	68 e2 37 80 00       	push   $0x8037e2
  802bdf:	e8 32 d9 ff ff       	call   800516 <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  802be4:	83 ec 04             	sub    $0x4,%esp
  802be7:	68 80 37 80 00       	push   $0x803780
  802bec:	6a 22                	push   $0x22
  802bee:	68 e2 37 80 00       	push   $0x8037e2
  802bf3:	e8 1e d9 ff ff       	call   800516 <_panic>

00802bf8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802bf8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802bf9:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax   			// 间接寻址
  802bfe:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802c00:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  802c03:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  802c07:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  802c0c:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  802c10:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  802c12:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  802c15:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  802c16:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  802c19:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  802c1a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  802c1b:	c3                   	ret    

00802c1c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802c1c:	f3 0f 1e fb          	endbr32 
  802c20:	55                   	push   %ebp
  802c21:	89 e5                	mov    %esp,%ebp
  802c23:	56                   	push   %esi
  802c24:	53                   	push   %ebx
  802c25:	8b 75 08             	mov    0x8(%ebp),%esi
  802c28:	8b 45 0c             	mov    0xc(%ebp),%eax
  802c2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  802c2e:	85 c0                	test   %eax,%eax
  802c30:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802c35:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  802c38:	83 ec 0c             	sub    $0xc,%esp
  802c3b:	50                   	push   %eax
  802c3c:	e8 35 e5 ff ff       	call   801176 <sys_ipc_recv>
  802c41:	83 c4 10             	add    $0x10,%esp
  802c44:	85 c0                	test   %eax,%eax
  802c46:	75 2b                	jne    802c73 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  802c48:	85 f6                	test   %esi,%esi
  802c4a:	74 0a                	je     802c56 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  802c4c:	a1 08 50 80 00       	mov    0x805008,%eax
  802c51:	8b 40 74             	mov    0x74(%eax),%eax
  802c54:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  802c56:	85 db                	test   %ebx,%ebx
  802c58:	74 0a                	je     802c64 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  802c5a:	a1 08 50 80 00       	mov    0x805008,%eax
  802c5f:	8b 40 78             	mov    0x78(%eax),%eax
  802c62:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  802c64:	a1 08 50 80 00       	mov    0x805008,%eax
  802c69:	8b 40 70             	mov    0x70(%eax),%eax
}
  802c6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802c6f:	5b                   	pop    %ebx
  802c70:	5e                   	pop    %esi
  802c71:	5d                   	pop    %ebp
  802c72:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  802c73:	85 f6                	test   %esi,%esi
  802c75:	74 06                	je     802c7d <ipc_recv+0x61>
  802c77:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  802c7d:	85 db                	test   %ebx,%ebx
  802c7f:	74 eb                	je     802c6c <ipc_recv+0x50>
  802c81:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802c87:	eb e3                	jmp    802c6c <ipc_recv+0x50>

00802c89 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802c89:	f3 0f 1e fb          	endbr32 
  802c8d:	55                   	push   %ebp
  802c8e:	89 e5                	mov    %esp,%ebp
  802c90:	57                   	push   %edi
  802c91:	56                   	push   %esi
  802c92:	53                   	push   %ebx
  802c93:	83 ec 0c             	sub    $0xc,%esp
  802c96:	8b 7d 08             	mov    0x8(%ebp),%edi
  802c99:	8b 75 0c             	mov    0xc(%ebp),%esi
  802c9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  802c9f:	85 db                	test   %ebx,%ebx
  802ca1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802ca6:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802ca9:	ff 75 14             	pushl  0x14(%ebp)
  802cac:	53                   	push   %ebx
  802cad:	56                   	push   %esi
  802cae:	57                   	push   %edi
  802caf:	e8 9b e4 ff ff       	call   80114f <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  802cb4:	83 c4 10             	add    $0x10,%esp
  802cb7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802cba:	75 07                	jne    802cc3 <ipc_send+0x3a>
			sys_yield();
  802cbc:	e8 8c e3 ff ff       	call   80104d <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802cc1:	eb e6                	jmp    802ca9 <ipc_send+0x20>
		}
		else if (ret == 0)
  802cc3:	85 c0                	test   %eax,%eax
  802cc5:	75 08                	jne    802ccf <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  802cc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802cca:	5b                   	pop    %ebx
  802ccb:	5e                   	pop    %esi
  802ccc:	5f                   	pop    %edi
  802ccd:	5d                   	pop    %ebp
  802cce:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802ccf:	50                   	push   %eax
  802cd0:	68 f0 37 80 00       	push   $0x8037f0
  802cd5:	6a 48                	push   $0x48
  802cd7:	68 fe 37 80 00       	push   $0x8037fe
  802cdc:	e8 35 d8 ff ff       	call   800516 <_panic>

00802ce1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802ce1:	f3 0f 1e fb          	endbr32 
  802ce5:	55                   	push   %ebp
  802ce6:	89 e5                	mov    %esp,%ebp
  802ce8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802ceb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802cf0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802cf3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802cf9:	8b 52 50             	mov    0x50(%edx),%edx
  802cfc:	39 ca                	cmp    %ecx,%edx
  802cfe:	74 11                	je     802d11 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802d00:	83 c0 01             	add    $0x1,%eax
  802d03:	3d 00 04 00 00       	cmp    $0x400,%eax
  802d08:	75 e6                	jne    802cf0 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802d0a:	b8 00 00 00 00       	mov    $0x0,%eax
  802d0f:	eb 0b                	jmp    802d1c <ipc_find_env+0x3b>
			return envs[i].env_id;
  802d11:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802d14:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802d19:	8b 40 48             	mov    0x48(%eax),%eax
}
  802d1c:	5d                   	pop    %ebp
  802d1d:	c3                   	ret    

00802d1e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802d1e:	f3 0f 1e fb          	endbr32 
  802d22:	55                   	push   %ebp
  802d23:	89 e5                	mov    %esp,%ebp
  802d25:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802d28:	89 c2                	mov    %eax,%edx
  802d2a:	c1 ea 16             	shr    $0x16,%edx
  802d2d:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802d34:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802d39:	f6 c1 01             	test   $0x1,%cl
  802d3c:	74 1c                	je     802d5a <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802d3e:	c1 e8 0c             	shr    $0xc,%eax
  802d41:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802d48:	a8 01                	test   $0x1,%al
  802d4a:	74 0e                	je     802d5a <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802d4c:	c1 e8 0c             	shr    $0xc,%eax
  802d4f:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802d56:	ef 
  802d57:	0f b7 d2             	movzwl %dx,%edx
}
  802d5a:	89 d0                	mov    %edx,%eax
  802d5c:	5d                   	pop    %ebp
  802d5d:	c3                   	ret    
  802d5e:	66 90                	xchg   %ax,%ax

00802d60 <__udivdi3>:
  802d60:	f3 0f 1e fb          	endbr32 
  802d64:	55                   	push   %ebp
  802d65:	57                   	push   %edi
  802d66:	56                   	push   %esi
  802d67:	53                   	push   %ebx
  802d68:	83 ec 1c             	sub    $0x1c,%esp
  802d6b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802d6f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802d73:	8b 74 24 34          	mov    0x34(%esp),%esi
  802d77:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802d7b:	85 d2                	test   %edx,%edx
  802d7d:	75 19                	jne    802d98 <__udivdi3+0x38>
  802d7f:	39 f3                	cmp    %esi,%ebx
  802d81:	76 4d                	jbe    802dd0 <__udivdi3+0x70>
  802d83:	31 ff                	xor    %edi,%edi
  802d85:	89 e8                	mov    %ebp,%eax
  802d87:	89 f2                	mov    %esi,%edx
  802d89:	f7 f3                	div    %ebx
  802d8b:	89 fa                	mov    %edi,%edx
  802d8d:	83 c4 1c             	add    $0x1c,%esp
  802d90:	5b                   	pop    %ebx
  802d91:	5e                   	pop    %esi
  802d92:	5f                   	pop    %edi
  802d93:	5d                   	pop    %ebp
  802d94:	c3                   	ret    
  802d95:	8d 76 00             	lea    0x0(%esi),%esi
  802d98:	39 f2                	cmp    %esi,%edx
  802d9a:	76 14                	jbe    802db0 <__udivdi3+0x50>
  802d9c:	31 ff                	xor    %edi,%edi
  802d9e:	31 c0                	xor    %eax,%eax
  802da0:	89 fa                	mov    %edi,%edx
  802da2:	83 c4 1c             	add    $0x1c,%esp
  802da5:	5b                   	pop    %ebx
  802da6:	5e                   	pop    %esi
  802da7:	5f                   	pop    %edi
  802da8:	5d                   	pop    %ebp
  802da9:	c3                   	ret    
  802daa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802db0:	0f bd fa             	bsr    %edx,%edi
  802db3:	83 f7 1f             	xor    $0x1f,%edi
  802db6:	75 48                	jne    802e00 <__udivdi3+0xa0>
  802db8:	39 f2                	cmp    %esi,%edx
  802dba:	72 06                	jb     802dc2 <__udivdi3+0x62>
  802dbc:	31 c0                	xor    %eax,%eax
  802dbe:	39 eb                	cmp    %ebp,%ebx
  802dc0:	77 de                	ja     802da0 <__udivdi3+0x40>
  802dc2:	b8 01 00 00 00       	mov    $0x1,%eax
  802dc7:	eb d7                	jmp    802da0 <__udivdi3+0x40>
  802dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802dd0:	89 d9                	mov    %ebx,%ecx
  802dd2:	85 db                	test   %ebx,%ebx
  802dd4:	75 0b                	jne    802de1 <__udivdi3+0x81>
  802dd6:	b8 01 00 00 00       	mov    $0x1,%eax
  802ddb:	31 d2                	xor    %edx,%edx
  802ddd:	f7 f3                	div    %ebx
  802ddf:	89 c1                	mov    %eax,%ecx
  802de1:	31 d2                	xor    %edx,%edx
  802de3:	89 f0                	mov    %esi,%eax
  802de5:	f7 f1                	div    %ecx
  802de7:	89 c6                	mov    %eax,%esi
  802de9:	89 e8                	mov    %ebp,%eax
  802deb:	89 f7                	mov    %esi,%edi
  802ded:	f7 f1                	div    %ecx
  802def:	89 fa                	mov    %edi,%edx
  802df1:	83 c4 1c             	add    $0x1c,%esp
  802df4:	5b                   	pop    %ebx
  802df5:	5e                   	pop    %esi
  802df6:	5f                   	pop    %edi
  802df7:	5d                   	pop    %ebp
  802df8:	c3                   	ret    
  802df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802e00:	89 f9                	mov    %edi,%ecx
  802e02:	b8 20 00 00 00       	mov    $0x20,%eax
  802e07:	29 f8                	sub    %edi,%eax
  802e09:	d3 e2                	shl    %cl,%edx
  802e0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  802e0f:	89 c1                	mov    %eax,%ecx
  802e11:	89 da                	mov    %ebx,%edx
  802e13:	d3 ea                	shr    %cl,%edx
  802e15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802e19:	09 d1                	or     %edx,%ecx
  802e1b:	89 f2                	mov    %esi,%edx
  802e1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802e21:	89 f9                	mov    %edi,%ecx
  802e23:	d3 e3                	shl    %cl,%ebx
  802e25:	89 c1                	mov    %eax,%ecx
  802e27:	d3 ea                	shr    %cl,%edx
  802e29:	89 f9                	mov    %edi,%ecx
  802e2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802e2f:	89 eb                	mov    %ebp,%ebx
  802e31:	d3 e6                	shl    %cl,%esi
  802e33:	89 c1                	mov    %eax,%ecx
  802e35:	d3 eb                	shr    %cl,%ebx
  802e37:	09 de                	or     %ebx,%esi
  802e39:	89 f0                	mov    %esi,%eax
  802e3b:	f7 74 24 08          	divl   0x8(%esp)
  802e3f:	89 d6                	mov    %edx,%esi
  802e41:	89 c3                	mov    %eax,%ebx
  802e43:	f7 64 24 0c          	mull   0xc(%esp)
  802e47:	39 d6                	cmp    %edx,%esi
  802e49:	72 15                	jb     802e60 <__udivdi3+0x100>
  802e4b:	89 f9                	mov    %edi,%ecx
  802e4d:	d3 e5                	shl    %cl,%ebp
  802e4f:	39 c5                	cmp    %eax,%ebp
  802e51:	73 04                	jae    802e57 <__udivdi3+0xf7>
  802e53:	39 d6                	cmp    %edx,%esi
  802e55:	74 09                	je     802e60 <__udivdi3+0x100>
  802e57:	89 d8                	mov    %ebx,%eax
  802e59:	31 ff                	xor    %edi,%edi
  802e5b:	e9 40 ff ff ff       	jmp    802da0 <__udivdi3+0x40>
  802e60:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802e63:	31 ff                	xor    %edi,%edi
  802e65:	e9 36 ff ff ff       	jmp    802da0 <__udivdi3+0x40>
  802e6a:	66 90                	xchg   %ax,%ax
  802e6c:	66 90                	xchg   %ax,%ax
  802e6e:	66 90                	xchg   %ax,%ax

00802e70 <__umoddi3>:
  802e70:	f3 0f 1e fb          	endbr32 
  802e74:	55                   	push   %ebp
  802e75:	57                   	push   %edi
  802e76:	56                   	push   %esi
  802e77:	53                   	push   %ebx
  802e78:	83 ec 1c             	sub    $0x1c,%esp
  802e7b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802e7f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802e83:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802e87:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802e8b:	85 c0                	test   %eax,%eax
  802e8d:	75 19                	jne    802ea8 <__umoddi3+0x38>
  802e8f:	39 df                	cmp    %ebx,%edi
  802e91:	76 5d                	jbe    802ef0 <__umoddi3+0x80>
  802e93:	89 f0                	mov    %esi,%eax
  802e95:	89 da                	mov    %ebx,%edx
  802e97:	f7 f7                	div    %edi
  802e99:	89 d0                	mov    %edx,%eax
  802e9b:	31 d2                	xor    %edx,%edx
  802e9d:	83 c4 1c             	add    $0x1c,%esp
  802ea0:	5b                   	pop    %ebx
  802ea1:	5e                   	pop    %esi
  802ea2:	5f                   	pop    %edi
  802ea3:	5d                   	pop    %ebp
  802ea4:	c3                   	ret    
  802ea5:	8d 76 00             	lea    0x0(%esi),%esi
  802ea8:	89 f2                	mov    %esi,%edx
  802eaa:	39 d8                	cmp    %ebx,%eax
  802eac:	76 12                	jbe    802ec0 <__umoddi3+0x50>
  802eae:	89 f0                	mov    %esi,%eax
  802eb0:	89 da                	mov    %ebx,%edx
  802eb2:	83 c4 1c             	add    $0x1c,%esp
  802eb5:	5b                   	pop    %ebx
  802eb6:	5e                   	pop    %esi
  802eb7:	5f                   	pop    %edi
  802eb8:	5d                   	pop    %ebp
  802eb9:	c3                   	ret    
  802eba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802ec0:	0f bd e8             	bsr    %eax,%ebp
  802ec3:	83 f5 1f             	xor    $0x1f,%ebp
  802ec6:	75 50                	jne    802f18 <__umoddi3+0xa8>
  802ec8:	39 d8                	cmp    %ebx,%eax
  802eca:	0f 82 e0 00 00 00    	jb     802fb0 <__umoddi3+0x140>
  802ed0:	89 d9                	mov    %ebx,%ecx
  802ed2:	39 f7                	cmp    %esi,%edi
  802ed4:	0f 86 d6 00 00 00    	jbe    802fb0 <__umoddi3+0x140>
  802eda:	89 d0                	mov    %edx,%eax
  802edc:	89 ca                	mov    %ecx,%edx
  802ede:	83 c4 1c             	add    $0x1c,%esp
  802ee1:	5b                   	pop    %ebx
  802ee2:	5e                   	pop    %esi
  802ee3:	5f                   	pop    %edi
  802ee4:	5d                   	pop    %ebp
  802ee5:	c3                   	ret    
  802ee6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802eed:	8d 76 00             	lea    0x0(%esi),%esi
  802ef0:	89 fd                	mov    %edi,%ebp
  802ef2:	85 ff                	test   %edi,%edi
  802ef4:	75 0b                	jne    802f01 <__umoddi3+0x91>
  802ef6:	b8 01 00 00 00       	mov    $0x1,%eax
  802efb:	31 d2                	xor    %edx,%edx
  802efd:	f7 f7                	div    %edi
  802eff:	89 c5                	mov    %eax,%ebp
  802f01:	89 d8                	mov    %ebx,%eax
  802f03:	31 d2                	xor    %edx,%edx
  802f05:	f7 f5                	div    %ebp
  802f07:	89 f0                	mov    %esi,%eax
  802f09:	f7 f5                	div    %ebp
  802f0b:	89 d0                	mov    %edx,%eax
  802f0d:	31 d2                	xor    %edx,%edx
  802f0f:	eb 8c                	jmp    802e9d <__umoddi3+0x2d>
  802f11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802f18:	89 e9                	mov    %ebp,%ecx
  802f1a:	ba 20 00 00 00       	mov    $0x20,%edx
  802f1f:	29 ea                	sub    %ebp,%edx
  802f21:	d3 e0                	shl    %cl,%eax
  802f23:	89 44 24 08          	mov    %eax,0x8(%esp)
  802f27:	89 d1                	mov    %edx,%ecx
  802f29:	89 f8                	mov    %edi,%eax
  802f2b:	d3 e8                	shr    %cl,%eax
  802f2d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802f31:	89 54 24 04          	mov    %edx,0x4(%esp)
  802f35:	8b 54 24 04          	mov    0x4(%esp),%edx
  802f39:	09 c1                	or     %eax,%ecx
  802f3b:	89 d8                	mov    %ebx,%eax
  802f3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802f41:	89 e9                	mov    %ebp,%ecx
  802f43:	d3 e7                	shl    %cl,%edi
  802f45:	89 d1                	mov    %edx,%ecx
  802f47:	d3 e8                	shr    %cl,%eax
  802f49:	89 e9                	mov    %ebp,%ecx
  802f4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802f4f:	d3 e3                	shl    %cl,%ebx
  802f51:	89 c7                	mov    %eax,%edi
  802f53:	89 d1                	mov    %edx,%ecx
  802f55:	89 f0                	mov    %esi,%eax
  802f57:	d3 e8                	shr    %cl,%eax
  802f59:	89 e9                	mov    %ebp,%ecx
  802f5b:	89 fa                	mov    %edi,%edx
  802f5d:	d3 e6                	shl    %cl,%esi
  802f5f:	09 d8                	or     %ebx,%eax
  802f61:	f7 74 24 08          	divl   0x8(%esp)
  802f65:	89 d1                	mov    %edx,%ecx
  802f67:	89 f3                	mov    %esi,%ebx
  802f69:	f7 64 24 0c          	mull   0xc(%esp)
  802f6d:	89 c6                	mov    %eax,%esi
  802f6f:	89 d7                	mov    %edx,%edi
  802f71:	39 d1                	cmp    %edx,%ecx
  802f73:	72 06                	jb     802f7b <__umoddi3+0x10b>
  802f75:	75 10                	jne    802f87 <__umoddi3+0x117>
  802f77:	39 c3                	cmp    %eax,%ebx
  802f79:	73 0c                	jae    802f87 <__umoddi3+0x117>
  802f7b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  802f7f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802f83:	89 d7                	mov    %edx,%edi
  802f85:	89 c6                	mov    %eax,%esi
  802f87:	89 ca                	mov    %ecx,%edx
  802f89:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802f8e:	29 f3                	sub    %esi,%ebx
  802f90:	19 fa                	sbb    %edi,%edx
  802f92:	89 d0                	mov    %edx,%eax
  802f94:	d3 e0                	shl    %cl,%eax
  802f96:	89 e9                	mov    %ebp,%ecx
  802f98:	d3 eb                	shr    %cl,%ebx
  802f9a:	d3 ea                	shr    %cl,%edx
  802f9c:	09 d8                	or     %ebx,%eax
  802f9e:	83 c4 1c             	add    $0x1c,%esp
  802fa1:	5b                   	pop    %ebx
  802fa2:	5e                   	pop    %esi
  802fa3:	5f                   	pop    %edi
  802fa4:	5d                   	pop    %ebp
  802fa5:	c3                   	ret    
  802fa6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802fad:	8d 76 00             	lea    0x0(%esi),%esi
  802fb0:	29 fe                	sub    %edi,%esi
  802fb2:	19 c3                	sbb    %eax,%ebx
  802fb4:	89 f2                	mov    %esi,%edx
  802fb6:	89 d9                	mov    %ebx,%ecx
  802fb8:	e9 1d ff ff ff       	jmp    802eda <__umoddi3+0x6a>
