
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 8f 03 00 00       	call   8003c0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  800042:	b9 00 00 00 00       	mov    $0x0,%ecx
	for (i = 0; i < n; i++)
  800047:	b8 00 00 00 00       	mov    $0x0,%eax
  80004c:	39 d8                	cmp    %ebx,%eax
  80004e:	7d 0e                	jge    80005e <sum+0x2b>
		tot ^= i * s[i];
  800050:	0f be 14 06          	movsbl (%esi,%eax,1),%edx
  800054:	0f af d0             	imul   %eax,%edx
  800057:	31 d1                	xor    %edx,%ecx
	for (i = 0; i < n; i++)
  800059:	83 c0 01             	add    $0x1,%eax
  80005c:	eb ee                	jmp    80004c <sum+0x19>
	return tot;
}
  80005e:	89 c8                	mov    %ecx,%eax
  800060:	5b                   	pop    %ebx
  800061:	5e                   	pop    %esi
  800062:	5d                   	pop    %ebp
  800063:	c3                   	ret    

00800064 <umain>:

void
umain(int argc, char **argv)
{
  800064:	f3 0f 1e fb          	endbr32 
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	57                   	push   %edi
  80006c:	56                   	push   %esi
  80006d:	53                   	push   %ebx
  80006e:	81 ec 18 01 00 00    	sub    $0x118,%esp
  800074:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  800077:	68 c0 2b 80 00       	push   $0x802bc0
  80007c:	e8 8e 04 00 00       	call   80050f <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800081:	83 c4 08             	add    $0x8,%esp
  800084:	68 70 17 00 00       	push   $0x1770
  800089:	68 00 40 80 00       	push   $0x804000
  80008e:	e8 a0 ff ff ff       	call   800033 <sum>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  80009b:	0f 84 99 00 00 00    	je     80013a <umain+0xd6>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  8000a1:	83 ec 04             	sub    $0x4,%esp
  8000a4:	68 9e 98 0f 00       	push   $0xf989e
  8000a9:	50                   	push   %eax
  8000aa:	68 88 2c 80 00       	push   $0x802c88
  8000af:	e8 5b 04 00 00       	call   80050f <cprintf>
  8000b4:	83 c4 10             	add    $0x10,%esp
			x, want);
	else
		cprintf("init: data seems okay\n");
	if ((x = sum(bss, sizeof bss)) != 0)
  8000b7:	83 ec 08             	sub    $0x8,%esp
  8000ba:	68 70 17 00 00       	push   $0x1770
  8000bf:	68 20 60 80 00       	push   $0x806020
  8000c4:	e8 6a ff ff ff       	call   800033 <sum>
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	85 c0                	test   %eax,%eax
  8000ce:	74 7f                	je     80014f <umain+0xeb>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d0:	83 ec 08             	sub    $0x8,%esp
  8000d3:	50                   	push   %eax
  8000d4:	68 c4 2c 80 00       	push   $0x802cc4
  8000d9:	e8 31 04 00 00       	call   80050f <cprintf>
  8000de:	83 c4 10             	add    $0x10,%esp
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000e1:	83 ec 08             	sub    $0x8,%esp
  8000e4:	68 fc 2b 80 00       	push   $0x802bfc
  8000e9:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8000ef:	50                   	push   %eax
  8000f0:	e8 4a 0a 00 00       	call   800b3f <strcat>
	for (i = 0; i < argc; i++) {
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  8000fd:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	for (i = 0; i < argc; i++) {
  800103:	39 fb                	cmp    %edi,%ebx
  800105:	7d 5a                	jge    800161 <umain+0xfd>
		strcat(args, " '");
  800107:	83 ec 08             	sub    $0x8,%esp
  80010a:	68 08 2c 80 00       	push   $0x802c08
  80010f:	56                   	push   %esi
  800110:	e8 2a 0a 00 00       	call   800b3f <strcat>
		strcat(args, argv[i]);
  800115:	83 c4 08             	add    $0x8,%esp
  800118:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011b:	ff 34 98             	pushl  (%eax,%ebx,4)
  80011e:	56                   	push   %esi
  80011f:	e8 1b 0a 00 00       	call   800b3f <strcat>
		strcat(args, "'");
  800124:	83 c4 08             	add    $0x8,%esp
  800127:	68 09 2c 80 00       	push   $0x802c09
  80012c:	56                   	push   %esi
  80012d:	e8 0d 0a 00 00       	call   800b3f <strcat>
	for (i = 0; i < argc; i++) {
  800132:	83 c3 01             	add    $0x1,%ebx
  800135:	83 c4 10             	add    $0x10,%esp
  800138:	eb c9                	jmp    800103 <umain+0x9f>
		cprintf("init: data seems okay\n");
  80013a:	83 ec 0c             	sub    $0xc,%esp
  80013d:	68 cf 2b 80 00       	push   $0x802bcf
  800142:	e8 c8 03 00 00       	call   80050f <cprintf>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	e9 68 ff ff ff       	jmp    8000b7 <umain+0x53>
		cprintf("init: bss seems okay\n");
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	68 e6 2b 80 00       	push   $0x802be6
  800157:	e8 b3 03 00 00       	call   80050f <cprintf>
  80015c:	83 c4 10             	add    $0x10,%esp
  80015f:	eb 80                	jmp    8000e1 <umain+0x7d>
	}
	cprintf("%s\n", args);
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80016a:	50                   	push   %eax
  80016b:	68 0b 2c 80 00       	push   $0x802c0b
  800170:	e8 9a 03 00 00       	call   80050f <cprintf>

	cprintf("init: running sh\n");
  800175:	c7 04 24 0f 2c 80 00 	movl   $0x802c0f,(%esp)
  80017c:	e8 8e 03 00 00       	call   80050f <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  800181:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800188:	e8 4f 11 00 00       	call   8012dc <close>
	if ((r = opencons()) < 0)
  80018d:	e8 d8 01 00 00       	call   80036a <opencons>
  800192:	83 c4 10             	add    $0x10,%esp
  800195:	85 c0                	test   %eax,%eax
  800197:	78 14                	js     8001ad <umain+0x149>
		panic("opencons: %e", r);
	if (r != 0)
  800199:	74 24                	je     8001bf <umain+0x15b>
		panic("first opencons used fd %d", r);
  80019b:	50                   	push   %eax
  80019c:	68 3a 2c 80 00       	push   $0x802c3a
  8001a1:	6a 39                	push   $0x39
  8001a3:	68 2e 2c 80 00       	push   $0x802c2e
  8001a8:	e8 7b 02 00 00       	call   800428 <_panic>
		panic("opencons: %e", r);
  8001ad:	50                   	push   %eax
  8001ae:	68 21 2c 80 00       	push   $0x802c21
  8001b3:	6a 37                	push   $0x37
  8001b5:	68 2e 2c 80 00       	push   $0x802c2e
  8001ba:	e8 69 02 00 00       	call   800428 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001bf:	83 ec 08             	sub    $0x8,%esp
  8001c2:	6a 01                	push   $0x1
  8001c4:	6a 00                	push   $0x0
  8001c6:	e8 6b 11 00 00       	call   801336 <dup>
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	85 c0                	test   %eax,%eax
  8001d0:	79 23                	jns    8001f5 <umain+0x191>
		panic("dup: %e", r);
  8001d2:	50                   	push   %eax
  8001d3:	68 54 2c 80 00       	push   $0x802c54
  8001d8:	6a 3b                	push   $0x3b
  8001da:	68 2e 2c 80 00       	push   $0x802c2e
  8001df:	e8 44 02 00 00       	call   800428 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
		r = spawnl("/sh", "sh", (char*)0);
		if (r < 0) {
			cprintf("init: spawn sh: %e\n", r);
  8001e4:	83 ec 08             	sub    $0x8,%esp
  8001e7:	50                   	push   %eax
  8001e8:	68 73 2c 80 00       	push   $0x802c73
  8001ed:	e8 1d 03 00 00       	call   80050f <cprintf>
			continue;
  8001f2:	83 c4 10             	add    $0x10,%esp
		cprintf("init: starting sh\n");
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	68 5c 2c 80 00       	push   $0x802c5c
  8001fd:	e8 0d 03 00 00       	call   80050f <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  800202:	83 c4 0c             	add    $0xc,%esp
  800205:	6a 00                	push   $0x0
  800207:	68 70 2c 80 00       	push   $0x802c70
  80020c:	68 6f 2c 80 00       	push   $0x802c6f
  800211:	e8 d1 1c 00 00       	call   801ee7 <spawnl>
		if (r < 0) {
  800216:	83 c4 10             	add    $0x10,%esp
  800219:	85 c0                	test   %eax,%eax
  80021b:	78 c7                	js     8001e4 <umain+0x180>
		}
		wait(r);
  80021d:	83 ec 0c             	sub    $0xc,%esp
  800220:	50                   	push   %eax
  800221:	e8 91 25 00 00       	call   8027b7 <wait>
  800226:	83 c4 10             	add    $0x10,%esp
  800229:	eb ca                	jmp    8001f5 <umain+0x191>

0080022b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80022b:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  80022f:	b8 00 00 00 00       	mov    $0x0,%eax
  800234:	c3                   	ret    

00800235 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800235:	f3 0f 1e fb          	endbr32 
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80023f:	68 f3 2c 80 00       	push   $0x802cf3
  800244:	ff 75 0c             	pushl  0xc(%ebp)
  800247:	e8 cd 08 00 00       	call   800b19 <strcpy>
	return 0;
}
  80024c:	b8 00 00 00 00       	mov    $0x0,%eax
  800251:	c9                   	leave  
  800252:	c3                   	ret    

00800253 <devcons_write>:
{
  800253:	f3 0f 1e fb          	endbr32 
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	57                   	push   %edi
  80025b:	56                   	push   %esi
  80025c:	53                   	push   %ebx
  80025d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800263:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800268:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80026e:	3b 75 10             	cmp    0x10(%ebp),%esi
  800271:	73 31                	jae    8002a4 <devcons_write+0x51>
		m = n - tot;
  800273:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800276:	29 f3                	sub    %esi,%ebx
  800278:	83 fb 7f             	cmp    $0x7f,%ebx
  80027b:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800280:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800283:	83 ec 04             	sub    $0x4,%esp
  800286:	53                   	push   %ebx
  800287:	89 f0                	mov    %esi,%eax
  800289:	03 45 0c             	add    0xc(%ebp),%eax
  80028c:	50                   	push   %eax
  80028d:	57                   	push   %edi
  80028e:	e8 84 0a 00 00       	call   800d17 <memmove>
		sys_cputs(buf, m);
  800293:	83 c4 08             	add    $0x8,%esp
  800296:	53                   	push   %ebx
  800297:	57                   	push   %edi
  800298:	e8 36 0c 00 00       	call   800ed3 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80029d:	01 de                	add    %ebx,%esi
  80029f:	83 c4 10             	add    $0x10,%esp
  8002a2:	eb ca                	jmp    80026e <devcons_write+0x1b>
}
  8002a4:	89 f0                	mov    %esi,%eax
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <devcons_read>:
{
  8002ae:	f3 0f 1e fb          	endbr32 
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	83 ec 08             	sub    $0x8,%esp
  8002b8:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8002bd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002c1:	74 21                	je     8002e4 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8002c3:	e8 2d 0c 00 00       	call   800ef5 <sys_cgetc>
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	75 07                	jne    8002d3 <devcons_read+0x25>
		sys_yield();
  8002cc:	e8 8e 0c 00 00       	call   800f5f <sys_yield>
  8002d1:	eb f0                	jmp    8002c3 <devcons_read+0x15>
	if (c < 0)
  8002d3:	78 0f                	js     8002e4 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8002d5:	83 f8 04             	cmp    $0x4,%eax
  8002d8:	74 0c                	je     8002e6 <devcons_read+0x38>
	*(char*)vbuf = c;
  8002da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002dd:	88 02                	mov    %al,(%edx)
	return 1;
  8002df:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8002e4:	c9                   	leave  
  8002e5:	c3                   	ret    
		return 0;
  8002e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8002eb:	eb f7                	jmp    8002e4 <devcons_read+0x36>

008002ed <cputchar>:
{
  8002ed:	f3 0f 1e fb          	endbr32 
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8002f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fa:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8002fd:	6a 01                	push   $0x1
  8002ff:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800302:	50                   	push   %eax
  800303:	e8 cb 0b 00 00       	call   800ed3 <sys_cputs>
}
  800308:	83 c4 10             	add    $0x10,%esp
  80030b:	c9                   	leave  
  80030c:	c3                   	ret    

0080030d <getchar>:
{
  80030d:	f3 0f 1e fb          	endbr32 
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800317:	6a 01                	push   $0x1
  800319:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80031c:	50                   	push   %eax
  80031d:	6a 00                	push   $0x0
  80031f:	e8 02 11 00 00       	call   801426 <read>
	if (r < 0)
  800324:	83 c4 10             	add    $0x10,%esp
  800327:	85 c0                	test   %eax,%eax
  800329:	78 06                	js     800331 <getchar+0x24>
	if (r < 1)
  80032b:	74 06                	je     800333 <getchar+0x26>
	return c;
  80032d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800331:	c9                   	leave  
  800332:	c3                   	ret    
		return -E_EOF;
  800333:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800338:	eb f7                	jmp    800331 <getchar+0x24>

0080033a <iscons>:
{
  80033a:	f3 0f 1e fb          	endbr32 
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800344:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800347:	50                   	push   %eax
  800348:	ff 75 08             	pushl  0x8(%ebp)
  80034b:	e8 4e 0e 00 00       	call   80119e <fd_lookup>
  800350:	83 c4 10             	add    $0x10,%esp
  800353:	85 c0                	test   %eax,%eax
  800355:	78 11                	js     800368 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  800357:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80035a:	8b 15 70 57 80 00    	mov    0x805770,%edx
  800360:	39 10                	cmp    %edx,(%eax)
  800362:	0f 94 c0             	sete   %al
  800365:	0f b6 c0             	movzbl %al,%eax
}
  800368:	c9                   	leave  
  800369:	c3                   	ret    

0080036a <opencons>:
{
  80036a:	f3 0f 1e fb          	endbr32 
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800374:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800377:	50                   	push   %eax
  800378:	e8 cb 0d 00 00       	call   801148 <fd_alloc>
  80037d:	83 c4 10             	add    $0x10,%esp
  800380:	85 c0                	test   %eax,%eax
  800382:	78 3a                	js     8003be <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800384:	83 ec 04             	sub    $0x4,%esp
  800387:	68 07 04 00 00       	push   $0x407
  80038c:	ff 75 f4             	pushl  -0xc(%ebp)
  80038f:	6a 00                	push   $0x0
  800391:	e8 ec 0b 00 00       	call   800f82 <sys_page_alloc>
  800396:	83 c4 10             	add    $0x10,%esp
  800399:	85 c0                	test   %eax,%eax
  80039b:	78 21                	js     8003be <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80039d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003a0:	8b 15 70 57 80 00    	mov    0x805770,%edx
  8003a6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8003a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003ab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8003b2:	83 ec 0c             	sub    $0xc,%esp
  8003b5:	50                   	push   %eax
  8003b6:	e8 5e 0d 00 00       	call   801119 <fd2num>
  8003bb:	83 c4 10             	add    $0x10,%esp
}
  8003be:	c9                   	leave  
  8003bf:	c3                   	ret    

008003c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8003c0:	f3 0f 1e fb          	endbr32 
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
  8003c7:	56                   	push   %esi
  8003c8:	53                   	push   %ebx
  8003c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8003cf:	e8 68 0b 00 00       	call   800f3c <sys_getenvid>
  8003d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003d9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8003dc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003e1:	a3 90 77 80 00       	mov    %eax,0x807790
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003e6:	85 db                	test   %ebx,%ebx
  8003e8:	7e 07                	jle    8003f1 <libmain+0x31>
		binaryname = argv[0];
  8003ea:	8b 06                	mov    (%esi),%eax
  8003ec:	a3 8c 57 80 00       	mov    %eax,0x80578c

	// call user main routine
	umain(argc, argv);
  8003f1:	83 ec 08             	sub    $0x8,%esp
  8003f4:	56                   	push   %esi
  8003f5:	53                   	push   %ebx
  8003f6:	e8 69 fc ff ff       	call   800064 <umain>

	// exit gracefully
	exit();
  8003fb:	e8 0a 00 00 00       	call   80040a <exit>
}
  800400:	83 c4 10             	add    $0x10,%esp
  800403:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800406:	5b                   	pop    %ebx
  800407:	5e                   	pop    %esi
  800408:	5d                   	pop    %ebp
  800409:	c3                   	ret    

0080040a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80040a:	f3 0f 1e fb          	endbr32 
  80040e:	55                   	push   %ebp
  80040f:	89 e5                	mov    %esp,%ebp
  800411:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  800414:	e8 f4 0e 00 00       	call   80130d <close_all>
	sys_env_destroy(0);
  800419:	83 ec 0c             	sub    $0xc,%esp
  80041c:	6a 00                	push   $0x0
  80041e:	e8 f5 0a 00 00       	call   800f18 <sys_env_destroy>
}
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800428:	f3 0f 1e fb          	endbr32 
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	56                   	push   %esi
  800430:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800431:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800434:	8b 35 8c 57 80 00    	mov    0x80578c,%esi
  80043a:	e8 fd 0a 00 00       	call   800f3c <sys_getenvid>
  80043f:	83 ec 0c             	sub    $0xc,%esp
  800442:	ff 75 0c             	pushl  0xc(%ebp)
  800445:	ff 75 08             	pushl  0x8(%ebp)
  800448:	56                   	push   %esi
  800449:	50                   	push   %eax
  80044a:	68 0c 2d 80 00       	push   $0x802d0c
  80044f:	e8 bb 00 00 00       	call   80050f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800454:	83 c4 18             	add    $0x18,%esp
  800457:	53                   	push   %ebx
  800458:	ff 75 10             	pushl  0x10(%ebp)
  80045b:	e8 5a 00 00 00       	call   8004ba <vcprintf>
	cprintf("\n");
  800460:	c7 04 24 67 32 80 00 	movl   $0x803267,(%esp)
  800467:	e8 a3 00 00 00       	call   80050f <cprintf>
  80046c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80046f:	cc                   	int3   
  800470:	eb fd                	jmp    80046f <_panic+0x47>

00800472 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800472:	f3 0f 1e fb          	endbr32 
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	53                   	push   %ebx
  80047a:	83 ec 04             	sub    $0x4,%esp
  80047d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800480:	8b 13                	mov    (%ebx),%edx
  800482:	8d 42 01             	lea    0x1(%edx),%eax
  800485:	89 03                	mov    %eax,(%ebx)
  800487:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80048a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80048e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800493:	74 09                	je     80049e <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800495:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800499:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80049c:	c9                   	leave  
  80049d:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	68 ff 00 00 00       	push   $0xff
  8004a6:	8d 43 08             	lea    0x8(%ebx),%eax
  8004a9:	50                   	push   %eax
  8004aa:	e8 24 0a 00 00       	call   800ed3 <sys_cputs>
		b->idx = 0;
  8004af:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	eb db                	jmp    800495 <putch+0x23>

008004ba <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004ba:	f3 0f 1e fb          	endbr32 
  8004be:	55                   	push   %ebp
  8004bf:	89 e5                	mov    %esp,%ebp
  8004c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004ce:	00 00 00 
	b.cnt = 0;
  8004d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004db:	ff 75 0c             	pushl  0xc(%ebp)
  8004de:	ff 75 08             	pushl  0x8(%ebp)
  8004e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004e7:	50                   	push   %eax
  8004e8:	68 72 04 80 00       	push   $0x800472
  8004ed:	e8 20 01 00 00       	call   800612 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004f2:	83 c4 08             	add    $0x8,%esp
  8004f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800501:	50                   	push   %eax
  800502:	e8 cc 09 00 00       	call   800ed3 <sys_cputs>

	return b.cnt;
}
  800507:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80050d:	c9                   	leave  
  80050e:	c3                   	ret    

0080050f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80050f:	f3 0f 1e fb          	endbr32 
  800513:	55                   	push   %ebp
  800514:	89 e5                	mov    %esp,%ebp
  800516:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800519:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80051c:	50                   	push   %eax
  80051d:	ff 75 08             	pushl  0x8(%ebp)
  800520:	e8 95 ff ff ff       	call   8004ba <vcprintf>
	va_end(ap);

	return cnt;
}
  800525:	c9                   	leave  
  800526:	c3                   	ret    

00800527 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800527:	55                   	push   %ebp
  800528:	89 e5                	mov    %esp,%ebp
  80052a:	57                   	push   %edi
  80052b:	56                   	push   %esi
  80052c:	53                   	push   %ebx
  80052d:	83 ec 1c             	sub    $0x1c,%esp
  800530:	89 c7                	mov    %eax,%edi
  800532:	89 d6                	mov    %edx,%esi
  800534:	8b 45 08             	mov    0x8(%ebp),%eax
  800537:	8b 55 0c             	mov    0xc(%ebp),%edx
  80053a:	89 d1                	mov    %edx,%ecx
  80053c:	89 c2                	mov    %eax,%edx
  80053e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800541:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800544:	8b 45 10             	mov    0x10(%ebp),%eax
  800547:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  80054a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80054d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800554:	39 c2                	cmp    %eax,%edx
  800556:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800559:	72 3e                	jb     800599 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80055b:	83 ec 0c             	sub    $0xc,%esp
  80055e:	ff 75 18             	pushl  0x18(%ebp)
  800561:	83 eb 01             	sub    $0x1,%ebx
  800564:	53                   	push   %ebx
  800565:	50                   	push   %eax
  800566:	83 ec 08             	sub    $0x8,%esp
  800569:	ff 75 e4             	pushl  -0x1c(%ebp)
  80056c:	ff 75 e0             	pushl  -0x20(%ebp)
  80056f:	ff 75 dc             	pushl  -0x24(%ebp)
  800572:	ff 75 d8             	pushl  -0x28(%ebp)
  800575:	e8 d6 23 00 00       	call   802950 <__udivdi3>
  80057a:	83 c4 18             	add    $0x18,%esp
  80057d:	52                   	push   %edx
  80057e:	50                   	push   %eax
  80057f:	89 f2                	mov    %esi,%edx
  800581:	89 f8                	mov    %edi,%eax
  800583:	e8 9f ff ff ff       	call   800527 <printnum>
  800588:	83 c4 20             	add    $0x20,%esp
  80058b:	eb 13                	jmp    8005a0 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	56                   	push   %esi
  800591:	ff 75 18             	pushl  0x18(%ebp)
  800594:	ff d7                	call   *%edi
  800596:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800599:	83 eb 01             	sub    $0x1,%ebx
  80059c:	85 db                	test   %ebx,%ebx
  80059e:	7f ed                	jg     80058d <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005a0:	83 ec 08             	sub    $0x8,%esp
  8005a3:	56                   	push   %esi
  8005a4:	83 ec 04             	sub    $0x4,%esp
  8005a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ad:	ff 75 dc             	pushl  -0x24(%ebp)
  8005b0:	ff 75 d8             	pushl  -0x28(%ebp)
  8005b3:	e8 a8 24 00 00       	call   802a60 <__umoddi3>
  8005b8:	83 c4 14             	add    $0x14,%esp
  8005bb:	0f be 80 2f 2d 80 00 	movsbl 0x802d2f(%eax),%eax
  8005c2:	50                   	push   %eax
  8005c3:	ff d7                	call   *%edi
}
  8005c5:	83 c4 10             	add    $0x10,%esp
  8005c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005cb:	5b                   	pop    %ebx
  8005cc:	5e                   	pop    %esi
  8005cd:	5f                   	pop    %edi
  8005ce:	5d                   	pop    %ebp
  8005cf:	c3                   	ret    

008005d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005d0:	f3 0f 1e fb          	endbr32 
  8005d4:	55                   	push   %ebp
  8005d5:	89 e5                	mov    %esp,%ebp
  8005d7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005da:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005de:	8b 10                	mov    (%eax),%edx
  8005e0:	3b 50 04             	cmp    0x4(%eax),%edx
  8005e3:	73 0a                	jae    8005ef <sprintputch+0x1f>
		*b->buf++ = ch;
  8005e5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005e8:	89 08                	mov    %ecx,(%eax)
  8005ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ed:	88 02                	mov    %al,(%edx)
}
  8005ef:	5d                   	pop    %ebp
  8005f0:	c3                   	ret    

008005f1 <printfmt>:
{
  8005f1:	f3 0f 1e fb          	endbr32 
  8005f5:	55                   	push   %ebp
  8005f6:	89 e5                	mov    %esp,%ebp
  8005f8:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8005fb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005fe:	50                   	push   %eax
  8005ff:	ff 75 10             	pushl  0x10(%ebp)
  800602:	ff 75 0c             	pushl  0xc(%ebp)
  800605:	ff 75 08             	pushl  0x8(%ebp)
  800608:	e8 05 00 00 00       	call   800612 <vprintfmt>
}
  80060d:	83 c4 10             	add    $0x10,%esp
  800610:	c9                   	leave  
  800611:	c3                   	ret    

00800612 <vprintfmt>:
{
  800612:	f3 0f 1e fb          	endbr32 
  800616:	55                   	push   %ebp
  800617:	89 e5                	mov    %esp,%ebp
  800619:	57                   	push   %edi
  80061a:	56                   	push   %esi
  80061b:	53                   	push   %ebx
  80061c:	83 ec 3c             	sub    $0x3c,%esp
  80061f:	8b 75 08             	mov    0x8(%ebp),%esi
  800622:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800625:	8b 7d 10             	mov    0x10(%ebp),%edi
  800628:	e9 8e 03 00 00       	jmp    8009bb <vprintfmt+0x3a9>
		padc = ' ';
  80062d:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800631:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800638:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80063f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800646:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80064b:	8d 47 01             	lea    0x1(%edi),%eax
  80064e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800651:	0f b6 17             	movzbl (%edi),%edx
  800654:	8d 42 dd             	lea    -0x23(%edx),%eax
  800657:	3c 55                	cmp    $0x55,%al
  800659:	0f 87 df 03 00 00    	ja     800a3e <vprintfmt+0x42c>
  80065f:	0f b6 c0             	movzbl %al,%eax
  800662:	3e ff 24 85 80 2e 80 	notrack jmp *0x802e80(,%eax,4)
  800669:	00 
  80066a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80066d:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800671:	eb d8                	jmp    80064b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800673:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800676:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80067a:	eb cf                	jmp    80064b <vprintfmt+0x39>
  80067c:	0f b6 d2             	movzbl %dl,%edx
  80067f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800682:	b8 00 00 00 00       	mov    $0x0,%eax
  800687:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  80068a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80068d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800691:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800694:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800697:	83 f9 09             	cmp    $0x9,%ecx
  80069a:	77 55                	ja     8006f1 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80069c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  80069f:	eb e9                	jmp    80068a <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8006a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a4:	8b 00                	mov    (%eax),%eax
  8006a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ac:	8d 40 04             	lea    0x4(%eax),%eax
  8006af:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8006b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8006b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006b9:	79 90                	jns    80064b <vprintfmt+0x39>
				width = precision, precision = -1;
  8006bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006c1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8006c8:	eb 81                	jmp    80064b <vprintfmt+0x39>
  8006ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006cd:	85 c0                	test   %eax,%eax
  8006cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8006d4:	0f 49 d0             	cmovns %eax,%edx
  8006d7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8006da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8006dd:	e9 69 ff ff ff       	jmp    80064b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8006e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8006e5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8006ec:	e9 5a ff ff ff       	jmp    80064b <vprintfmt+0x39>
  8006f1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f7:	eb bc                	jmp    8006b5 <vprintfmt+0xa3>
			lflag++;
  8006f9:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8006fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8006ff:	e9 47 ff ff ff       	jmp    80064b <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800704:	8b 45 14             	mov    0x14(%ebp),%eax
  800707:	8d 78 04             	lea    0x4(%eax),%edi
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	ff 30                	pushl  (%eax)
  800710:	ff d6                	call   *%esi
			break;
  800712:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800715:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800718:	e9 9b 02 00 00       	jmp    8009b8 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80071d:	8b 45 14             	mov    0x14(%ebp),%eax
  800720:	8d 78 04             	lea    0x4(%eax),%edi
  800723:	8b 00                	mov    (%eax),%eax
  800725:	99                   	cltd   
  800726:	31 d0                	xor    %edx,%eax
  800728:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80072a:	83 f8 0f             	cmp    $0xf,%eax
  80072d:	7f 23                	jg     800752 <vprintfmt+0x140>
  80072f:	8b 14 85 e0 2f 80 00 	mov    0x802fe0(,%eax,4),%edx
  800736:	85 d2                	test   %edx,%edx
  800738:	74 18                	je     800752 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80073a:	52                   	push   %edx
  80073b:	68 e9 30 80 00       	push   $0x8030e9
  800740:	53                   	push   %ebx
  800741:	56                   	push   %esi
  800742:	e8 aa fe ff ff       	call   8005f1 <printfmt>
  800747:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80074a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80074d:	e9 66 02 00 00       	jmp    8009b8 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800752:	50                   	push   %eax
  800753:	68 47 2d 80 00       	push   $0x802d47
  800758:	53                   	push   %ebx
  800759:	56                   	push   %esi
  80075a:	e8 92 fe ff ff       	call   8005f1 <printfmt>
  80075f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800762:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800765:	e9 4e 02 00 00       	jmp    8009b8 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  80076a:	8b 45 14             	mov    0x14(%ebp),%eax
  80076d:	83 c0 04             	add    $0x4,%eax
  800770:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800773:	8b 45 14             	mov    0x14(%ebp),%eax
  800776:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800778:	85 d2                	test   %edx,%edx
  80077a:	b8 40 2d 80 00       	mov    $0x802d40,%eax
  80077f:	0f 45 c2             	cmovne %edx,%eax
  800782:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800785:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800789:	7e 06                	jle    800791 <vprintfmt+0x17f>
  80078b:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80078f:	75 0d                	jne    80079e <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800791:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800794:	89 c7                	mov    %eax,%edi
  800796:	03 45 e0             	add    -0x20(%ebp),%eax
  800799:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80079c:	eb 55                	jmp    8007f3 <vprintfmt+0x1e1>
  80079e:	83 ec 08             	sub    $0x8,%esp
  8007a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8007a4:	ff 75 cc             	pushl  -0x34(%ebp)
  8007a7:	e8 46 03 00 00       	call   800af2 <strnlen>
  8007ac:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007af:	29 c2                	sub    %eax,%edx
  8007b1:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8007b4:	83 c4 10             	add    $0x10,%esp
  8007b7:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8007b9:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8007bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8007c0:	85 ff                	test   %edi,%edi
  8007c2:	7e 11                	jle    8007d5 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8007c4:	83 ec 08             	sub    $0x8,%esp
  8007c7:	53                   	push   %ebx
  8007c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8007cb:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8007cd:	83 ef 01             	sub    $0x1,%edi
  8007d0:	83 c4 10             	add    $0x10,%esp
  8007d3:	eb eb                	jmp    8007c0 <vprintfmt+0x1ae>
  8007d5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8007d8:	85 d2                	test   %edx,%edx
  8007da:	b8 00 00 00 00       	mov    $0x0,%eax
  8007df:	0f 49 c2             	cmovns %edx,%eax
  8007e2:	29 c2                	sub    %eax,%edx
  8007e4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8007e7:	eb a8                	jmp    800791 <vprintfmt+0x17f>
					putch(ch, putdat);
  8007e9:	83 ec 08             	sub    $0x8,%esp
  8007ec:	53                   	push   %ebx
  8007ed:	52                   	push   %edx
  8007ee:	ff d6                	call   *%esi
  8007f0:	83 c4 10             	add    $0x10,%esp
  8007f3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007f6:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007f8:	83 c7 01             	add    $0x1,%edi
  8007fb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007ff:	0f be d0             	movsbl %al,%edx
  800802:	85 d2                	test   %edx,%edx
  800804:	74 4b                	je     800851 <vprintfmt+0x23f>
  800806:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80080a:	78 06                	js     800812 <vprintfmt+0x200>
  80080c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800810:	78 1e                	js     800830 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  800812:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800816:	74 d1                	je     8007e9 <vprintfmt+0x1d7>
  800818:	0f be c0             	movsbl %al,%eax
  80081b:	83 e8 20             	sub    $0x20,%eax
  80081e:	83 f8 5e             	cmp    $0x5e,%eax
  800821:	76 c6                	jbe    8007e9 <vprintfmt+0x1d7>
					putch('?', putdat);
  800823:	83 ec 08             	sub    $0x8,%esp
  800826:	53                   	push   %ebx
  800827:	6a 3f                	push   $0x3f
  800829:	ff d6                	call   *%esi
  80082b:	83 c4 10             	add    $0x10,%esp
  80082e:	eb c3                	jmp    8007f3 <vprintfmt+0x1e1>
  800830:	89 cf                	mov    %ecx,%edi
  800832:	eb 0e                	jmp    800842 <vprintfmt+0x230>
				putch(' ', putdat);
  800834:	83 ec 08             	sub    $0x8,%esp
  800837:	53                   	push   %ebx
  800838:	6a 20                	push   $0x20
  80083a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80083c:	83 ef 01             	sub    $0x1,%edi
  80083f:	83 c4 10             	add    $0x10,%esp
  800842:	85 ff                	test   %edi,%edi
  800844:	7f ee                	jg     800834 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800846:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800849:	89 45 14             	mov    %eax,0x14(%ebp)
  80084c:	e9 67 01 00 00       	jmp    8009b8 <vprintfmt+0x3a6>
  800851:	89 cf                	mov    %ecx,%edi
  800853:	eb ed                	jmp    800842 <vprintfmt+0x230>
	if (lflag >= 2)
  800855:	83 f9 01             	cmp    $0x1,%ecx
  800858:	7f 1b                	jg     800875 <vprintfmt+0x263>
	else if (lflag)
  80085a:	85 c9                	test   %ecx,%ecx
  80085c:	74 63                	je     8008c1 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80085e:	8b 45 14             	mov    0x14(%ebp),%eax
  800861:	8b 00                	mov    (%eax),%eax
  800863:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800866:	99                   	cltd   
  800867:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80086a:	8b 45 14             	mov    0x14(%ebp),%eax
  80086d:	8d 40 04             	lea    0x4(%eax),%eax
  800870:	89 45 14             	mov    %eax,0x14(%ebp)
  800873:	eb 17                	jmp    80088c <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800875:	8b 45 14             	mov    0x14(%ebp),%eax
  800878:	8b 50 04             	mov    0x4(%eax),%edx
  80087b:	8b 00                	mov    (%eax),%eax
  80087d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800880:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800883:	8b 45 14             	mov    0x14(%ebp),%eax
  800886:	8d 40 08             	lea    0x8(%eax),%eax
  800889:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80088c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80088f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800892:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800897:	85 c9                	test   %ecx,%ecx
  800899:	0f 89 ff 00 00 00    	jns    80099e <vprintfmt+0x38c>
				putch('-', putdat);
  80089f:	83 ec 08             	sub    $0x8,%esp
  8008a2:	53                   	push   %ebx
  8008a3:	6a 2d                	push   $0x2d
  8008a5:	ff d6                	call   *%esi
				num = -(long long) num;
  8008a7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008aa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8008ad:	f7 da                	neg    %edx
  8008af:	83 d1 00             	adc    $0x0,%ecx
  8008b2:	f7 d9                	neg    %ecx
  8008b4:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8008b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008bc:	e9 dd 00 00 00       	jmp    80099e <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8008c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c4:	8b 00                	mov    (%eax),%eax
  8008c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c9:	99                   	cltd   
  8008ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d0:	8d 40 04             	lea    0x4(%eax),%eax
  8008d3:	89 45 14             	mov    %eax,0x14(%ebp)
  8008d6:	eb b4                	jmp    80088c <vprintfmt+0x27a>
	if (lflag >= 2)
  8008d8:	83 f9 01             	cmp    $0x1,%ecx
  8008db:	7f 1e                	jg     8008fb <vprintfmt+0x2e9>
	else if (lflag)
  8008dd:	85 c9                	test   %ecx,%ecx
  8008df:	74 32                	je     800913 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8008e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e4:	8b 10                	mov    (%eax),%edx
  8008e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008eb:	8d 40 04             	lea    0x4(%eax),%eax
  8008ee:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8008f1:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8008f6:	e9 a3 00 00 00       	jmp    80099e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8008fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fe:	8b 10                	mov    (%eax),%edx
  800900:	8b 48 04             	mov    0x4(%eax),%ecx
  800903:	8d 40 08             	lea    0x8(%eax),%eax
  800906:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800909:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80090e:	e9 8b 00 00 00       	jmp    80099e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800913:	8b 45 14             	mov    0x14(%ebp),%eax
  800916:	8b 10                	mov    (%eax),%edx
  800918:	b9 00 00 00 00       	mov    $0x0,%ecx
  80091d:	8d 40 04             	lea    0x4(%eax),%eax
  800920:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800923:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800928:	eb 74                	jmp    80099e <vprintfmt+0x38c>
	if (lflag >= 2)
  80092a:	83 f9 01             	cmp    $0x1,%ecx
  80092d:	7f 1b                	jg     80094a <vprintfmt+0x338>
	else if (lflag)
  80092f:	85 c9                	test   %ecx,%ecx
  800931:	74 2c                	je     80095f <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800933:	8b 45 14             	mov    0x14(%ebp),%eax
  800936:	8b 10                	mov    (%eax),%edx
  800938:	b9 00 00 00 00       	mov    $0x0,%ecx
  80093d:	8d 40 04             	lea    0x4(%eax),%eax
  800940:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800943:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800948:	eb 54                	jmp    80099e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80094a:	8b 45 14             	mov    0x14(%ebp),%eax
  80094d:	8b 10                	mov    (%eax),%edx
  80094f:	8b 48 04             	mov    0x4(%eax),%ecx
  800952:	8d 40 08             	lea    0x8(%eax),%eax
  800955:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800958:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  80095d:	eb 3f                	jmp    80099e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80095f:	8b 45 14             	mov    0x14(%ebp),%eax
  800962:	8b 10                	mov    (%eax),%edx
  800964:	b9 00 00 00 00       	mov    $0x0,%ecx
  800969:	8d 40 04             	lea    0x4(%eax),%eax
  80096c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80096f:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800974:	eb 28                	jmp    80099e <vprintfmt+0x38c>
			putch('0', putdat);
  800976:	83 ec 08             	sub    $0x8,%esp
  800979:	53                   	push   %ebx
  80097a:	6a 30                	push   $0x30
  80097c:	ff d6                	call   *%esi
			putch('x', putdat);
  80097e:	83 c4 08             	add    $0x8,%esp
  800981:	53                   	push   %ebx
  800982:	6a 78                	push   $0x78
  800984:	ff d6                	call   *%esi
			num = (unsigned long long)
  800986:	8b 45 14             	mov    0x14(%ebp),%eax
  800989:	8b 10                	mov    (%eax),%edx
  80098b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800990:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800993:	8d 40 04             	lea    0x4(%eax),%eax
  800996:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800999:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80099e:	83 ec 0c             	sub    $0xc,%esp
  8009a1:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8009a5:	57                   	push   %edi
  8009a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8009a9:	50                   	push   %eax
  8009aa:	51                   	push   %ecx
  8009ab:	52                   	push   %edx
  8009ac:	89 da                	mov    %ebx,%edx
  8009ae:	89 f0                	mov    %esi,%eax
  8009b0:	e8 72 fb ff ff       	call   800527 <printnum>
			break;
  8009b5:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8009b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  8009bb:	83 c7 01             	add    $0x1,%edi
  8009be:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8009c2:	83 f8 25             	cmp    $0x25,%eax
  8009c5:	0f 84 62 fc ff ff    	je     80062d <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  8009cb:	85 c0                	test   %eax,%eax
  8009cd:	0f 84 8b 00 00 00    	je     800a5e <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  8009d3:	83 ec 08             	sub    $0x8,%esp
  8009d6:	53                   	push   %ebx
  8009d7:	50                   	push   %eax
  8009d8:	ff d6                	call   *%esi
  8009da:	83 c4 10             	add    $0x10,%esp
  8009dd:	eb dc                	jmp    8009bb <vprintfmt+0x3a9>
	if (lflag >= 2)
  8009df:	83 f9 01             	cmp    $0x1,%ecx
  8009e2:	7f 1b                	jg     8009ff <vprintfmt+0x3ed>
	else if (lflag)
  8009e4:	85 c9                	test   %ecx,%ecx
  8009e6:	74 2c                	je     800a14 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  8009e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009eb:	8b 10                	mov    (%eax),%edx
  8009ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009f2:	8d 40 04             	lea    0x4(%eax),%eax
  8009f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009f8:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8009fd:	eb 9f                	jmp    80099e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8009ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800a02:	8b 10                	mov    (%eax),%edx
  800a04:	8b 48 04             	mov    0x4(%eax),%ecx
  800a07:	8d 40 08             	lea    0x8(%eax),%eax
  800a0a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a0d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800a12:	eb 8a                	jmp    80099e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800a14:	8b 45 14             	mov    0x14(%ebp),%eax
  800a17:	8b 10                	mov    (%eax),%edx
  800a19:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a1e:	8d 40 04             	lea    0x4(%eax),%eax
  800a21:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a24:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800a29:	e9 70 ff ff ff       	jmp    80099e <vprintfmt+0x38c>
			putch(ch, putdat);
  800a2e:	83 ec 08             	sub    $0x8,%esp
  800a31:	53                   	push   %ebx
  800a32:	6a 25                	push   $0x25
  800a34:	ff d6                	call   *%esi
			break;
  800a36:	83 c4 10             	add    $0x10,%esp
  800a39:	e9 7a ff ff ff       	jmp    8009b8 <vprintfmt+0x3a6>
			putch('%', putdat);
  800a3e:	83 ec 08             	sub    $0x8,%esp
  800a41:	53                   	push   %ebx
  800a42:	6a 25                	push   $0x25
  800a44:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800a46:	83 c4 10             	add    $0x10,%esp
  800a49:	89 f8                	mov    %edi,%eax
  800a4b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800a4f:	74 05                	je     800a56 <vprintfmt+0x444>
  800a51:	83 e8 01             	sub    $0x1,%eax
  800a54:	eb f5                	jmp    800a4b <vprintfmt+0x439>
  800a56:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a59:	e9 5a ff ff ff       	jmp    8009b8 <vprintfmt+0x3a6>
}
  800a5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a61:	5b                   	pop    %ebx
  800a62:	5e                   	pop    %esi
  800a63:	5f                   	pop    %edi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a66:	f3 0f 1e fb          	endbr32 
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	83 ec 18             	sub    $0x18,%esp
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a76:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a79:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a7d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a80:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a87:	85 c0                	test   %eax,%eax
  800a89:	74 26                	je     800ab1 <vsnprintf+0x4b>
  800a8b:	85 d2                	test   %edx,%edx
  800a8d:	7e 22                	jle    800ab1 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a8f:	ff 75 14             	pushl  0x14(%ebp)
  800a92:	ff 75 10             	pushl  0x10(%ebp)
  800a95:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a98:	50                   	push   %eax
  800a99:	68 d0 05 80 00       	push   $0x8005d0
  800a9e:	e8 6f fb ff ff       	call   800612 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800aa3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800aa6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aac:	83 c4 10             	add    $0x10,%esp
}
  800aaf:	c9                   	leave  
  800ab0:	c3                   	ret    
		return -E_INVAL;
  800ab1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ab6:	eb f7                	jmp    800aaf <vsnprintf+0x49>

00800ab8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ab8:	f3 0f 1e fb          	endbr32 
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  800ac2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ac5:	50                   	push   %eax
  800ac6:	ff 75 10             	pushl  0x10(%ebp)
  800ac9:	ff 75 0c             	pushl  0xc(%ebp)
  800acc:	ff 75 08             	pushl  0x8(%ebp)
  800acf:	e8 92 ff ff ff       	call   800a66 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ad4:	c9                   	leave  
  800ad5:	c3                   	ret    

00800ad6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ad6:	f3 0f 1e fb          	endbr32 
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ae0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ae9:	74 05                	je     800af0 <strlen+0x1a>
		n++;
  800aeb:	83 c0 01             	add    $0x1,%eax
  800aee:	eb f5                	jmp    800ae5 <strlen+0xf>
	return n;
}
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800af2:	f3 0f 1e fb          	endbr32 
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800afc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aff:	b8 00 00 00 00       	mov    $0x0,%eax
  800b04:	39 d0                	cmp    %edx,%eax
  800b06:	74 0d                	je     800b15 <strnlen+0x23>
  800b08:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b0c:	74 05                	je     800b13 <strnlen+0x21>
		n++;
  800b0e:	83 c0 01             	add    $0x1,%eax
  800b11:	eb f1                	jmp    800b04 <strnlen+0x12>
  800b13:	89 c2                	mov    %eax,%edx
	return n;
}
  800b15:	89 d0                	mov    %edx,%eax
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b19:	f3 0f 1e fb          	endbr32 
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	53                   	push   %ebx
  800b21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b27:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800b30:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800b33:	83 c0 01             	add    $0x1,%eax
  800b36:	84 d2                	test   %dl,%dl
  800b38:	75 f2                	jne    800b2c <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800b3a:	89 c8                	mov    %ecx,%eax
  800b3c:	5b                   	pop    %ebx
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b3f:	f3 0f 1e fb          	endbr32 
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	53                   	push   %ebx
  800b47:	83 ec 10             	sub    $0x10,%esp
  800b4a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b4d:	53                   	push   %ebx
  800b4e:	e8 83 ff ff ff       	call   800ad6 <strlen>
  800b53:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800b56:	ff 75 0c             	pushl  0xc(%ebp)
  800b59:	01 d8                	add    %ebx,%eax
  800b5b:	50                   	push   %eax
  800b5c:	e8 b8 ff ff ff       	call   800b19 <strcpy>
	return dst;
}
  800b61:	89 d8                	mov    %ebx,%eax
  800b63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b66:	c9                   	leave  
  800b67:	c3                   	ret    

00800b68 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b68:	f3 0f 1e fb          	endbr32 
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
  800b71:	8b 75 08             	mov    0x8(%ebp),%esi
  800b74:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b77:	89 f3                	mov    %esi,%ebx
  800b79:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b7c:	89 f0                	mov    %esi,%eax
  800b7e:	39 d8                	cmp    %ebx,%eax
  800b80:	74 11                	je     800b93 <strncpy+0x2b>
		*dst++ = *src;
  800b82:	83 c0 01             	add    $0x1,%eax
  800b85:	0f b6 0a             	movzbl (%edx),%ecx
  800b88:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b8b:	80 f9 01             	cmp    $0x1,%cl
  800b8e:	83 da ff             	sbb    $0xffffffff,%edx
  800b91:	eb eb                	jmp    800b7e <strncpy+0x16>
	}
	return ret;
}
  800b93:	89 f0                	mov    %esi,%eax
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b99:	f3 0f 1e fb          	endbr32 
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
  800ba2:	8b 75 08             	mov    0x8(%ebp),%esi
  800ba5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba8:	8b 55 10             	mov    0x10(%ebp),%edx
  800bab:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bad:	85 d2                	test   %edx,%edx
  800baf:	74 21                	je     800bd2 <strlcpy+0x39>
  800bb1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800bb5:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800bb7:	39 c2                	cmp    %eax,%edx
  800bb9:	74 14                	je     800bcf <strlcpy+0x36>
  800bbb:	0f b6 19             	movzbl (%ecx),%ebx
  800bbe:	84 db                	test   %bl,%bl
  800bc0:	74 0b                	je     800bcd <strlcpy+0x34>
			*dst++ = *src++;
  800bc2:	83 c1 01             	add    $0x1,%ecx
  800bc5:	83 c2 01             	add    $0x1,%edx
  800bc8:	88 5a ff             	mov    %bl,-0x1(%edx)
  800bcb:	eb ea                	jmp    800bb7 <strlcpy+0x1e>
  800bcd:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800bcf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bd2:	29 f0                	sub    %esi,%eax
}
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bd8:	f3 0f 1e fb          	endbr32 
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800be5:	0f b6 01             	movzbl (%ecx),%eax
  800be8:	84 c0                	test   %al,%al
  800bea:	74 0c                	je     800bf8 <strcmp+0x20>
  800bec:	3a 02                	cmp    (%edx),%al
  800bee:	75 08                	jne    800bf8 <strcmp+0x20>
		p++, q++;
  800bf0:	83 c1 01             	add    $0x1,%ecx
  800bf3:	83 c2 01             	add    $0x1,%edx
  800bf6:	eb ed                	jmp    800be5 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bf8:	0f b6 c0             	movzbl %al,%eax
  800bfb:	0f b6 12             	movzbl (%edx),%edx
  800bfe:	29 d0                	sub    %edx,%eax
}
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    

00800c02 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c02:	f3 0f 1e fb          	endbr32 
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	53                   	push   %ebx
  800c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c10:	89 c3                	mov    %eax,%ebx
  800c12:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c15:	eb 06                	jmp    800c1d <strncmp+0x1b>
		n--, p++, q++;
  800c17:	83 c0 01             	add    $0x1,%eax
  800c1a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800c1d:	39 d8                	cmp    %ebx,%eax
  800c1f:	74 16                	je     800c37 <strncmp+0x35>
  800c21:	0f b6 08             	movzbl (%eax),%ecx
  800c24:	84 c9                	test   %cl,%cl
  800c26:	74 04                	je     800c2c <strncmp+0x2a>
  800c28:	3a 0a                	cmp    (%edx),%cl
  800c2a:	74 eb                	je     800c17 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c2c:	0f b6 00             	movzbl (%eax),%eax
  800c2f:	0f b6 12             	movzbl (%edx),%edx
  800c32:	29 d0                	sub    %edx,%eax
}
  800c34:	5b                   	pop    %ebx
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    
		return 0;
  800c37:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3c:	eb f6                	jmp    800c34 <strncmp+0x32>

00800c3e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c3e:	f3 0f 1e fb          	endbr32 
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	8b 45 08             	mov    0x8(%ebp),%eax
  800c48:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c4c:	0f b6 10             	movzbl (%eax),%edx
  800c4f:	84 d2                	test   %dl,%dl
  800c51:	74 09                	je     800c5c <strchr+0x1e>
		if (*s == c)
  800c53:	38 ca                	cmp    %cl,%dl
  800c55:	74 0a                	je     800c61 <strchr+0x23>
	for (; *s; s++)
  800c57:	83 c0 01             	add    $0x1,%eax
  800c5a:	eb f0                	jmp    800c4c <strchr+0xe>
			return (char *) s;
	return 0;
  800c5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800c63:	f3 0f 1e fb          	endbr32 
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800c6d:	6a 78                	push   $0x78
  800c6f:	ff 75 08             	pushl  0x8(%ebp)
  800c72:	e8 c7 ff ff ff       	call   800c3e <strchr>
  800c77:	83 c4 10             	add    $0x10,%esp
  800c7a:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  800c7d:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800c82:	eb 0d                	jmp    800c91 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800c84:	c1 e0 04             	shl    $0x4,%eax
  800c87:	0f be d2             	movsbl %dl,%edx
  800c8a:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800c8e:	83 c1 01             	add    $0x1,%ecx
  800c91:	0f b6 11             	movzbl (%ecx),%edx
  800c94:	84 d2                	test   %dl,%dl
  800c96:	74 11                	je     800ca9 <atox+0x46>
		if (*p>='a'){
  800c98:	80 fa 60             	cmp    $0x60,%dl
  800c9b:	7e e7                	jle    800c84 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800c9d:	c1 e0 04             	shl    $0x4,%eax
  800ca0:	0f be d2             	movsbl %dl,%edx
  800ca3:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800ca7:	eb e5                	jmp    800c8e <atox+0x2b>
	}

	return v;

}
  800ca9:	c9                   	leave  
  800caa:	c3                   	ret    

00800cab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cab:	f3 0f 1e fb          	endbr32 
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cb9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800cbc:	38 ca                	cmp    %cl,%dl
  800cbe:	74 09                	je     800cc9 <strfind+0x1e>
  800cc0:	84 d2                	test   %dl,%dl
  800cc2:	74 05                	je     800cc9 <strfind+0x1e>
	for (; *s; s++)
  800cc4:	83 c0 01             	add    $0x1,%eax
  800cc7:	eb f0                	jmp    800cb9 <strfind+0xe>
			break;
	return (char *) s;
}
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ccb:	f3 0f 1e fb          	endbr32 
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
  800cd5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cd8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cdb:	85 c9                	test   %ecx,%ecx
  800cdd:	74 31                	je     800d10 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cdf:	89 f8                	mov    %edi,%eax
  800ce1:	09 c8                	or     %ecx,%eax
  800ce3:	a8 03                	test   $0x3,%al
  800ce5:	75 23                	jne    800d0a <memset+0x3f>
		c &= 0xFF;
  800ce7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ceb:	89 d3                	mov    %edx,%ebx
  800ced:	c1 e3 08             	shl    $0x8,%ebx
  800cf0:	89 d0                	mov    %edx,%eax
  800cf2:	c1 e0 18             	shl    $0x18,%eax
  800cf5:	89 d6                	mov    %edx,%esi
  800cf7:	c1 e6 10             	shl    $0x10,%esi
  800cfa:	09 f0                	or     %esi,%eax
  800cfc:	09 c2                	or     %eax,%edx
  800cfe:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d00:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800d03:	89 d0                	mov    %edx,%eax
  800d05:	fc                   	cld    
  800d06:	f3 ab                	rep stos %eax,%es:(%edi)
  800d08:	eb 06                	jmp    800d10 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0d:	fc                   	cld    
  800d0e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d10:	89 f8                	mov    %edi,%eax
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d17:	f3 0f 1e fb          	endbr32 
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	8b 45 08             	mov    0x8(%ebp),%eax
  800d23:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d26:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d29:	39 c6                	cmp    %eax,%esi
  800d2b:	73 32                	jae    800d5f <memmove+0x48>
  800d2d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d30:	39 c2                	cmp    %eax,%edx
  800d32:	76 2b                	jbe    800d5f <memmove+0x48>
		s += n;
		d += n;
  800d34:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d37:	89 fe                	mov    %edi,%esi
  800d39:	09 ce                	or     %ecx,%esi
  800d3b:	09 d6                	or     %edx,%esi
  800d3d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d43:	75 0e                	jne    800d53 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d45:	83 ef 04             	sub    $0x4,%edi
  800d48:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d4b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d4e:	fd                   	std    
  800d4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d51:	eb 09                	jmp    800d5c <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d53:	83 ef 01             	sub    $0x1,%edi
  800d56:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d59:	fd                   	std    
  800d5a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d5c:	fc                   	cld    
  800d5d:	eb 1a                	jmp    800d79 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d5f:	89 c2                	mov    %eax,%edx
  800d61:	09 ca                	or     %ecx,%edx
  800d63:	09 f2                	or     %esi,%edx
  800d65:	f6 c2 03             	test   $0x3,%dl
  800d68:	75 0a                	jne    800d74 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d6a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d6d:	89 c7                	mov    %eax,%edi
  800d6f:	fc                   	cld    
  800d70:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d72:	eb 05                	jmp    800d79 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800d74:	89 c7                	mov    %eax,%edi
  800d76:	fc                   	cld    
  800d77:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d7d:	f3 0f 1e fb          	endbr32 
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d87:	ff 75 10             	pushl  0x10(%ebp)
  800d8a:	ff 75 0c             	pushl  0xc(%ebp)
  800d8d:	ff 75 08             	pushl  0x8(%ebp)
  800d90:	e8 82 ff ff ff       	call   800d17 <memmove>
}
  800d95:	c9                   	leave  
  800d96:	c3                   	ret    

00800d97 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d97:	f3 0f 1e fb          	endbr32 
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
  800da0:	8b 45 08             	mov    0x8(%ebp),%eax
  800da3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da6:	89 c6                	mov    %eax,%esi
  800da8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dab:	39 f0                	cmp    %esi,%eax
  800dad:	74 1c                	je     800dcb <memcmp+0x34>
		if (*s1 != *s2)
  800daf:	0f b6 08             	movzbl (%eax),%ecx
  800db2:	0f b6 1a             	movzbl (%edx),%ebx
  800db5:	38 d9                	cmp    %bl,%cl
  800db7:	75 08                	jne    800dc1 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800db9:	83 c0 01             	add    $0x1,%eax
  800dbc:	83 c2 01             	add    $0x1,%edx
  800dbf:	eb ea                	jmp    800dab <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800dc1:	0f b6 c1             	movzbl %cl,%eax
  800dc4:	0f b6 db             	movzbl %bl,%ebx
  800dc7:	29 d8                	sub    %ebx,%eax
  800dc9:	eb 05                	jmp    800dd0 <memcmp+0x39>
	}

	return 0;
  800dcb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dd4:	f3 0f 1e fb          	endbr32 
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800de1:	89 c2                	mov    %eax,%edx
  800de3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800de6:	39 d0                	cmp    %edx,%eax
  800de8:	73 09                	jae    800df3 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800dea:	38 08                	cmp    %cl,(%eax)
  800dec:	74 05                	je     800df3 <memfind+0x1f>
	for (; s < ends; s++)
  800dee:	83 c0 01             	add    $0x1,%eax
  800df1:	eb f3                	jmp    800de6 <memfind+0x12>
			break;
	return (void *) s;
}
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    

00800df5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800df5:	f3 0f 1e fb          	endbr32 
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	57                   	push   %edi
  800dfd:	56                   	push   %esi
  800dfe:	53                   	push   %ebx
  800dff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e05:	eb 03                	jmp    800e0a <strtol+0x15>
		s++;
  800e07:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800e0a:	0f b6 01             	movzbl (%ecx),%eax
  800e0d:	3c 20                	cmp    $0x20,%al
  800e0f:	74 f6                	je     800e07 <strtol+0x12>
  800e11:	3c 09                	cmp    $0x9,%al
  800e13:	74 f2                	je     800e07 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800e15:	3c 2b                	cmp    $0x2b,%al
  800e17:	74 2a                	je     800e43 <strtol+0x4e>
	int neg = 0;
  800e19:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800e1e:	3c 2d                	cmp    $0x2d,%al
  800e20:	74 2b                	je     800e4d <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e22:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e28:	75 0f                	jne    800e39 <strtol+0x44>
  800e2a:	80 39 30             	cmpb   $0x30,(%ecx)
  800e2d:	74 28                	je     800e57 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e2f:	85 db                	test   %ebx,%ebx
  800e31:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e36:	0f 44 d8             	cmove  %eax,%ebx
  800e39:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e41:	eb 46                	jmp    800e89 <strtol+0x94>
		s++;
  800e43:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800e46:	bf 00 00 00 00       	mov    $0x0,%edi
  800e4b:	eb d5                	jmp    800e22 <strtol+0x2d>
		s++, neg = 1;
  800e4d:	83 c1 01             	add    $0x1,%ecx
  800e50:	bf 01 00 00 00       	mov    $0x1,%edi
  800e55:	eb cb                	jmp    800e22 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e57:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e5b:	74 0e                	je     800e6b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800e5d:	85 db                	test   %ebx,%ebx
  800e5f:	75 d8                	jne    800e39 <strtol+0x44>
		s++, base = 8;
  800e61:	83 c1 01             	add    $0x1,%ecx
  800e64:	bb 08 00 00 00       	mov    $0x8,%ebx
  800e69:	eb ce                	jmp    800e39 <strtol+0x44>
		s += 2, base = 16;
  800e6b:	83 c1 02             	add    $0x2,%ecx
  800e6e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e73:	eb c4                	jmp    800e39 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800e75:	0f be d2             	movsbl %dl,%edx
  800e78:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e7b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e7e:	7d 3a                	jge    800eba <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800e80:	83 c1 01             	add    $0x1,%ecx
  800e83:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e87:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800e89:	0f b6 11             	movzbl (%ecx),%edx
  800e8c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e8f:	89 f3                	mov    %esi,%ebx
  800e91:	80 fb 09             	cmp    $0x9,%bl
  800e94:	76 df                	jbe    800e75 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800e96:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e99:	89 f3                	mov    %esi,%ebx
  800e9b:	80 fb 19             	cmp    $0x19,%bl
  800e9e:	77 08                	ja     800ea8 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ea0:	0f be d2             	movsbl %dl,%edx
  800ea3:	83 ea 57             	sub    $0x57,%edx
  800ea6:	eb d3                	jmp    800e7b <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ea8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800eab:	89 f3                	mov    %esi,%ebx
  800ead:	80 fb 19             	cmp    $0x19,%bl
  800eb0:	77 08                	ja     800eba <strtol+0xc5>
			dig = *s - 'A' + 10;
  800eb2:	0f be d2             	movsbl %dl,%edx
  800eb5:	83 ea 37             	sub    $0x37,%edx
  800eb8:	eb c1                	jmp    800e7b <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800eba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ebe:	74 05                	je     800ec5 <strtol+0xd0>
		*endptr = (char *) s;
  800ec0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ec3:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ec5:	89 c2                	mov    %eax,%edx
  800ec7:	f7 da                	neg    %edx
  800ec9:	85 ff                	test   %edi,%edi
  800ecb:	0f 45 c2             	cmovne %edx,%eax
}
  800ece:	5b                   	pop    %ebx
  800ecf:	5e                   	pop    %esi
  800ed0:	5f                   	pop    %edi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    

00800ed3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ed3:	f3 0f 1e fb          	endbr32 
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	57                   	push   %edi
  800edb:	56                   	push   %esi
  800edc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800edd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee8:	89 c3                	mov    %eax,%ebx
  800eea:	89 c7                	mov    %eax,%edi
  800eec:	89 c6                	mov    %eax,%esi
  800eee:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ef5:	f3 0f 1e fb          	endbr32 
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	57                   	push   %edi
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eff:	ba 00 00 00 00       	mov    $0x0,%edx
  800f04:	b8 01 00 00 00       	mov    $0x1,%eax
  800f09:	89 d1                	mov    %edx,%ecx
  800f0b:	89 d3                	mov    %edx,%ebx
  800f0d:	89 d7                	mov    %edx,%edi
  800f0f:	89 d6                	mov    %edx,%esi
  800f11:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f13:	5b                   	pop    %ebx
  800f14:	5e                   	pop    %esi
  800f15:	5f                   	pop    %edi
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    

00800f18 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f18:	f3 0f 1e fb          	endbr32 
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	57                   	push   %edi
  800f20:	56                   	push   %esi
  800f21:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f22:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f27:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2a:	b8 03 00 00 00       	mov    $0x3,%eax
  800f2f:	89 cb                	mov    %ecx,%ebx
  800f31:	89 cf                	mov    %ecx,%edi
  800f33:	89 ce                	mov    %ecx,%esi
  800f35:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f37:	5b                   	pop    %ebx
  800f38:	5e                   	pop    %esi
  800f39:	5f                   	pop    %edi
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    

00800f3c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f3c:	f3 0f 1e fb          	endbr32 
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	57                   	push   %edi
  800f44:	56                   	push   %esi
  800f45:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f46:	ba 00 00 00 00       	mov    $0x0,%edx
  800f4b:	b8 02 00 00 00       	mov    $0x2,%eax
  800f50:	89 d1                	mov    %edx,%ecx
  800f52:	89 d3                	mov    %edx,%ebx
  800f54:	89 d7                	mov    %edx,%edi
  800f56:	89 d6                	mov    %edx,%esi
  800f58:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f5a:	5b                   	pop    %ebx
  800f5b:	5e                   	pop    %esi
  800f5c:	5f                   	pop    %edi
  800f5d:	5d                   	pop    %ebp
  800f5e:	c3                   	ret    

00800f5f <sys_yield>:

void
sys_yield(void)
{
  800f5f:	f3 0f 1e fb          	endbr32 
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	57                   	push   %edi
  800f67:	56                   	push   %esi
  800f68:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f69:	ba 00 00 00 00       	mov    $0x0,%edx
  800f6e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f73:	89 d1                	mov    %edx,%ecx
  800f75:	89 d3                	mov    %edx,%ebx
  800f77:	89 d7                	mov    %edx,%edi
  800f79:	89 d6                	mov    %edx,%esi
  800f7b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f7d:	5b                   	pop    %ebx
  800f7e:	5e                   	pop    %esi
  800f7f:	5f                   	pop    %edi
  800f80:	5d                   	pop    %ebp
  800f81:	c3                   	ret    

00800f82 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f82:	f3 0f 1e fb          	endbr32 
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	57                   	push   %edi
  800f8a:	56                   	push   %esi
  800f8b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f8c:	be 00 00 00 00       	mov    $0x0,%esi
  800f91:	8b 55 08             	mov    0x8(%ebp),%edx
  800f94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f97:	b8 04 00 00 00       	mov    $0x4,%eax
  800f9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f9f:	89 f7                	mov    %esi,%edi
  800fa1:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fa3:	5b                   	pop    %ebx
  800fa4:	5e                   	pop    %esi
  800fa5:	5f                   	pop    %edi
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    

00800fa8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fa8:	f3 0f 1e fb          	endbr32 
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	57                   	push   %edi
  800fb0:	56                   	push   %esi
  800fb1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb8:	b8 05 00 00 00       	mov    $0x5,%eax
  800fbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fc0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fc3:	8b 75 18             	mov    0x18(%ebp),%esi
  800fc6:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fc8:	5b                   	pop    %ebx
  800fc9:	5e                   	pop    %esi
  800fca:	5f                   	pop    %edi
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    

00800fcd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fcd:	f3 0f 1e fb          	endbr32 
  800fd1:	55                   	push   %ebp
  800fd2:	89 e5                	mov    %esp,%ebp
  800fd4:	57                   	push   %edi
  800fd5:	56                   	push   %esi
  800fd6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe2:	b8 06 00 00 00       	mov    $0x6,%eax
  800fe7:	89 df                	mov    %ebx,%edi
  800fe9:	89 de                	mov    %ebx,%esi
  800feb:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fed:	5b                   	pop    %ebx
  800fee:	5e                   	pop    %esi
  800fef:	5f                   	pop    %edi
  800ff0:	5d                   	pop    %ebp
  800ff1:	c3                   	ret    

00800ff2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ff2:	f3 0f 1e fb          	endbr32 
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	57                   	push   %edi
  800ffa:	56                   	push   %esi
  800ffb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ffc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801001:	8b 55 08             	mov    0x8(%ebp),%edx
  801004:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801007:	b8 08 00 00 00       	mov    $0x8,%eax
  80100c:	89 df                	mov    %ebx,%edi
  80100e:	89 de                	mov    %ebx,%esi
  801010:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801012:	5b                   	pop    %ebx
  801013:	5e                   	pop    %esi
  801014:	5f                   	pop    %edi
  801015:	5d                   	pop    %ebp
  801016:	c3                   	ret    

00801017 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801017:	f3 0f 1e fb          	endbr32 
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	57                   	push   %edi
  80101f:	56                   	push   %esi
  801020:	53                   	push   %ebx
	asm volatile("int %1\n"
  801021:	bb 00 00 00 00       	mov    $0x0,%ebx
  801026:	8b 55 08             	mov    0x8(%ebp),%edx
  801029:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80102c:	b8 09 00 00 00       	mov    $0x9,%eax
  801031:	89 df                	mov    %ebx,%edi
  801033:	89 de                	mov    %ebx,%esi
  801035:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801037:	5b                   	pop    %ebx
  801038:	5e                   	pop    %esi
  801039:	5f                   	pop    %edi
  80103a:	5d                   	pop    %ebp
  80103b:	c3                   	ret    

0080103c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80103c:	f3 0f 1e fb          	endbr32 
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	57                   	push   %edi
  801044:	56                   	push   %esi
  801045:	53                   	push   %ebx
	asm volatile("int %1\n"
  801046:	bb 00 00 00 00       	mov    $0x0,%ebx
  80104b:	8b 55 08             	mov    0x8(%ebp),%edx
  80104e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801051:	b8 0a 00 00 00       	mov    $0xa,%eax
  801056:	89 df                	mov    %ebx,%edi
  801058:	89 de                	mov    %ebx,%esi
  80105a:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80105c:	5b                   	pop    %ebx
  80105d:	5e                   	pop    %esi
  80105e:	5f                   	pop    %edi
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    

00801061 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801061:	f3 0f 1e fb          	endbr32 
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	57                   	push   %edi
  801069:	56                   	push   %esi
  80106a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80106b:	8b 55 08             	mov    0x8(%ebp),%edx
  80106e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801071:	b8 0c 00 00 00       	mov    $0xc,%eax
  801076:	be 00 00 00 00       	mov    $0x0,%esi
  80107b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80107e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801081:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801083:	5b                   	pop    %ebx
  801084:	5e                   	pop    %esi
  801085:	5f                   	pop    %edi
  801086:	5d                   	pop    %ebp
  801087:	c3                   	ret    

00801088 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801088:	f3 0f 1e fb          	endbr32 
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	57                   	push   %edi
  801090:	56                   	push   %esi
  801091:	53                   	push   %ebx
	asm volatile("int %1\n"
  801092:	b9 00 00 00 00       	mov    $0x0,%ecx
  801097:	8b 55 08             	mov    0x8(%ebp),%edx
  80109a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80109f:	89 cb                	mov    %ecx,%ebx
  8010a1:	89 cf                	mov    %ecx,%edi
  8010a3:	89 ce                	mov    %ecx,%esi
  8010a5:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010a7:	5b                   	pop    %ebx
  8010a8:	5e                   	pop    %esi
  8010a9:	5f                   	pop    %edi
  8010aa:	5d                   	pop    %ebp
  8010ab:	c3                   	ret    

008010ac <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8010ac:	f3 0f 1e fb          	endbr32 
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	57                   	push   %edi
  8010b4:	56                   	push   %esi
  8010b5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8010bb:	b8 0e 00 00 00       	mov    $0xe,%eax
  8010c0:	89 d1                	mov    %edx,%ecx
  8010c2:	89 d3                	mov    %edx,%ebx
  8010c4:	89 d7                	mov    %edx,%edi
  8010c6:	89 d6                	mov    %edx,%esi
  8010c8:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8010ca:	5b                   	pop    %ebx
  8010cb:	5e                   	pop    %esi
  8010cc:	5f                   	pop    %edi
  8010cd:	5d                   	pop    %ebp
  8010ce:	c3                   	ret    

008010cf <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  8010cf:	f3 0f 1e fb          	endbr32 
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	57                   	push   %edi
  8010d7:	56                   	push   %esi
  8010d8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010de:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e4:	b8 0f 00 00 00       	mov    $0xf,%eax
  8010e9:	89 df                	mov    %ebx,%edi
  8010eb:	89 de                	mov    %ebx,%esi
  8010ed:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  8010ef:	5b                   	pop    %ebx
  8010f0:	5e                   	pop    %esi
  8010f1:	5f                   	pop    %edi
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    

008010f4 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  8010f4:	f3 0f 1e fb          	endbr32 
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	57                   	push   %edi
  8010fc:	56                   	push   %esi
  8010fd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801103:	8b 55 08             	mov    0x8(%ebp),%edx
  801106:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801109:	b8 10 00 00 00       	mov    $0x10,%eax
  80110e:	89 df                	mov    %ebx,%edi
  801110:	89 de                	mov    %ebx,%esi
  801112:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  801114:	5b                   	pop    %ebx
  801115:	5e                   	pop    %esi
  801116:	5f                   	pop    %edi
  801117:	5d                   	pop    %ebp
  801118:	c3                   	ret    

00801119 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801119:	f3 0f 1e fb          	endbr32 
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801120:	8b 45 08             	mov    0x8(%ebp),%eax
  801123:	05 00 00 00 30       	add    $0x30000000,%eax
  801128:	c1 e8 0c             	shr    $0xc,%eax
}
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    

0080112d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80112d:	f3 0f 1e fb          	endbr32 
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801134:	8b 45 08             	mov    0x8(%ebp),%eax
  801137:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80113c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801141:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801146:	5d                   	pop    %ebp
  801147:	c3                   	ret    

00801148 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801148:	f3 0f 1e fb          	endbr32 
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
  80114f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801154:	89 c2                	mov    %eax,%edx
  801156:	c1 ea 16             	shr    $0x16,%edx
  801159:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801160:	f6 c2 01             	test   $0x1,%dl
  801163:	74 2d                	je     801192 <fd_alloc+0x4a>
  801165:	89 c2                	mov    %eax,%edx
  801167:	c1 ea 0c             	shr    $0xc,%edx
  80116a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801171:	f6 c2 01             	test   $0x1,%dl
  801174:	74 1c                	je     801192 <fd_alloc+0x4a>
  801176:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80117b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801180:	75 d2                	jne    801154 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  801182:	8b 45 08             	mov    0x8(%ebp),%eax
  801185:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80118b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801190:	eb 0a                	jmp    80119c <fd_alloc+0x54>
			*fd_store = fd;
  801192:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801195:	89 01                	mov    %eax,(%ecx)
			return 0;
  801197:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    

0080119e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80119e:	f3 0f 1e fb          	endbr32 
  8011a2:	55                   	push   %ebp
  8011a3:	89 e5                	mov    %esp,%ebp
  8011a5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011a8:	83 f8 1f             	cmp    $0x1f,%eax
  8011ab:	77 30                	ja     8011dd <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011ad:	c1 e0 0c             	shl    $0xc,%eax
  8011b0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011b5:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8011bb:	f6 c2 01             	test   $0x1,%dl
  8011be:	74 24                	je     8011e4 <fd_lookup+0x46>
  8011c0:	89 c2                	mov    %eax,%edx
  8011c2:	c1 ea 0c             	shr    $0xc,%edx
  8011c5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011cc:	f6 c2 01             	test   $0x1,%dl
  8011cf:	74 1a                	je     8011eb <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d4:	89 02                	mov    %eax,(%edx)
	return 0;
  8011d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    
		return -E_INVAL;
  8011dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e2:	eb f7                	jmp    8011db <fd_lookup+0x3d>
		return -E_INVAL;
  8011e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e9:	eb f0                	jmp    8011db <fd_lookup+0x3d>
  8011eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f0:	eb e9                	jmp    8011db <fd_lookup+0x3d>

008011f2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011f2:	f3 0f 1e fb          	endbr32 
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
  8011f9:	83 ec 08             	sub    $0x8,%esp
  8011fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8011ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801204:	b8 a0 57 80 00       	mov    $0x8057a0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801209:	39 08                	cmp    %ecx,(%eax)
  80120b:	74 38                	je     801245 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80120d:	83 c2 01             	add    $0x1,%edx
  801210:	8b 04 95 bc 30 80 00 	mov    0x8030bc(,%edx,4),%eax
  801217:	85 c0                	test   %eax,%eax
  801219:	75 ee                	jne    801209 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80121b:	a1 90 77 80 00       	mov    0x807790,%eax
  801220:	8b 40 48             	mov    0x48(%eax),%eax
  801223:	83 ec 04             	sub    $0x4,%esp
  801226:	51                   	push   %ecx
  801227:	50                   	push   %eax
  801228:	68 40 30 80 00       	push   $0x803040
  80122d:	e8 dd f2 ff ff       	call   80050f <cprintf>
	*dev = 0;
  801232:	8b 45 0c             	mov    0xc(%ebp),%eax
  801235:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80123b:	83 c4 10             	add    $0x10,%esp
  80123e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801243:	c9                   	leave  
  801244:	c3                   	ret    
			*dev = devtab[i];
  801245:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801248:	89 01                	mov    %eax,(%ecx)
			return 0;
  80124a:	b8 00 00 00 00       	mov    $0x0,%eax
  80124f:	eb f2                	jmp    801243 <dev_lookup+0x51>

00801251 <fd_close>:
{
  801251:	f3 0f 1e fb          	endbr32 
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	57                   	push   %edi
  801259:	56                   	push   %esi
  80125a:	53                   	push   %ebx
  80125b:	83 ec 24             	sub    $0x24,%esp
  80125e:	8b 75 08             	mov    0x8(%ebp),%esi
  801261:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801264:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801267:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801268:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80126e:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801271:	50                   	push   %eax
  801272:	e8 27 ff ff ff       	call   80119e <fd_lookup>
  801277:	89 c3                	mov    %eax,%ebx
  801279:	83 c4 10             	add    $0x10,%esp
  80127c:	85 c0                	test   %eax,%eax
  80127e:	78 05                	js     801285 <fd_close+0x34>
	    || fd != fd2)
  801280:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801283:	74 16                	je     80129b <fd_close+0x4a>
		return (must_exist ? r : 0);
  801285:	89 f8                	mov    %edi,%eax
  801287:	84 c0                	test   %al,%al
  801289:	b8 00 00 00 00       	mov    $0x0,%eax
  80128e:	0f 44 d8             	cmove  %eax,%ebx
}
  801291:	89 d8                	mov    %ebx,%eax
  801293:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801296:	5b                   	pop    %ebx
  801297:	5e                   	pop    %esi
  801298:	5f                   	pop    %edi
  801299:	5d                   	pop    %ebp
  80129a:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80129b:	83 ec 08             	sub    $0x8,%esp
  80129e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8012a1:	50                   	push   %eax
  8012a2:	ff 36                	pushl  (%esi)
  8012a4:	e8 49 ff ff ff       	call   8011f2 <dev_lookup>
  8012a9:	89 c3                	mov    %eax,%ebx
  8012ab:	83 c4 10             	add    $0x10,%esp
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	78 1a                	js     8012cc <fd_close+0x7b>
		if (dev->dev_close)
  8012b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012b5:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8012b8:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	74 0b                	je     8012cc <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8012c1:	83 ec 0c             	sub    $0xc,%esp
  8012c4:	56                   	push   %esi
  8012c5:	ff d0                	call   *%eax
  8012c7:	89 c3                	mov    %eax,%ebx
  8012c9:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8012cc:	83 ec 08             	sub    $0x8,%esp
  8012cf:	56                   	push   %esi
  8012d0:	6a 00                	push   $0x0
  8012d2:	e8 f6 fc ff ff       	call   800fcd <sys_page_unmap>
	return r;
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	eb b5                	jmp    801291 <fd_close+0x40>

008012dc <close>:

int
close(int fdnum)
{
  8012dc:	f3 0f 1e fb          	endbr32 
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e9:	50                   	push   %eax
  8012ea:	ff 75 08             	pushl  0x8(%ebp)
  8012ed:	e8 ac fe ff ff       	call   80119e <fd_lookup>
  8012f2:	83 c4 10             	add    $0x10,%esp
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	79 02                	jns    8012fb <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8012f9:	c9                   	leave  
  8012fa:	c3                   	ret    
		return fd_close(fd, 1);
  8012fb:	83 ec 08             	sub    $0x8,%esp
  8012fe:	6a 01                	push   $0x1
  801300:	ff 75 f4             	pushl  -0xc(%ebp)
  801303:	e8 49 ff ff ff       	call   801251 <fd_close>
  801308:	83 c4 10             	add    $0x10,%esp
  80130b:	eb ec                	jmp    8012f9 <close+0x1d>

0080130d <close_all>:

void
close_all(void)
{
  80130d:	f3 0f 1e fb          	endbr32 
  801311:	55                   	push   %ebp
  801312:	89 e5                	mov    %esp,%ebp
  801314:	53                   	push   %ebx
  801315:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801318:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80131d:	83 ec 0c             	sub    $0xc,%esp
  801320:	53                   	push   %ebx
  801321:	e8 b6 ff ff ff       	call   8012dc <close>
	for (i = 0; i < MAXFD; i++)
  801326:	83 c3 01             	add    $0x1,%ebx
  801329:	83 c4 10             	add    $0x10,%esp
  80132c:	83 fb 20             	cmp    $0x20,%ebx
  80132f:	75 ec                	jne    80131d <close_all+0x10>
}
  801331:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801334:	c9                   	leave  
  801335:	c3                   	ret    

00801336 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801336:	f3 0f 1e fb          	endbr32 
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	57                   	push   %edi
  80133e:	56                   	push   %esi
  80133f:	53                   	push   %ebx
  801340:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801343:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801346:	50                   	push   %eax
  801347:	ff 75 08             	pushl  0x8(%ebp)
  80134a:	e8 4f fe ff ff       	call   80119e <fd_lookup>
  80134f:	89 c3                	mov    %eax,%ebx
  801351:	83 c4 10             	add    $0x10,%esp
  801354:	85 c0                	test   %eax,%eax
  801356:	0f 88 81 00 00 00    	js     8013dd <dup+0xa7>
		return r;
	close(newfdnum);
  80135c:	83 ec 0c             	sub    $0xc,%esp
  80135f:	ff 75 0c             	pushl  0xc(%ebp)
  801362:	e8 75 ff ff ff       	call   8012dc <close>

	newfd = INDEX2FD(newfdnum);
  801367:	8b 75 0c             	mov    0xc(%ebp),%esi
  80136a:	c1 e6 0c             	shl    $0xc,%esi
  80136d:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801373:	83 c4 04             	add    $0x4,%esp
  801376:	ff 75 e4             	pushl  -0x1c(%ebp)
  801379:	e8 af fd ff ff       	call   80112d <fd2data>
  80137e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801380:	89 34 24             	mov    %esi,(%esp)
  801383:	e8 a5 fd ff ff       	call   80112d <fd2data>
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80138d:	89 d8                	mov    %ebx,%eax
  80138f:	c1 e8 16             	shr    $0x16,%eax
  801392:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801399:	a8 01                	test   $0x1,%al
  80139b:	74 11                	je     8013ae <dup+0x78>
  80139d:	89 d8                	mov    %ebx,%eax
  80139f:	c1 e8 0c             	shr    $0xc,%eax
  8013a2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013a9:	f6 c2 01             	test   $0x1,%dl
  8013ac:	75 39                	jne    8013e7 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013b1:	89 d0                	mov    %edx,%eax
  8013b3:	c1 e8 0c             	shr    $0xc,%eax
  8013b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013bd:	83 ec 0c             	sub    $0xc,%esp
  8013c0:	25 07 0e 00 00       	and    $0xe07,%eax
  8013c5:	50                   	push   %eax
  8013c6:	56                   	push   %esi
  8013c7:	6a 00                	push   $0x0
  8013c9:	52                   	push   %edx
  8013ca:	6a 00                	push   $0x0
  8013cc:	e8 d7 fb ff ff       	call   800fa8 <sys_page_map>
  8013d1:	89 c3                	mov    %eax,%ebx
  8013d3:	83 c4 20             	add    $0x20,%esp
  8013d6:	85 c0                	test   %eax,%eax
  8013d8:	78 31                	js     80140b <dup+0xd5>
		goto err;

	return newfdnum;
  8013da:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013dd:	89 d8                	mov    %ebx,%eax
  8013df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e2:	5b                   	pop    %ebx
  8013e3:	5e                   	pop    %esi
  8013e4:	5f                   	pop    %edi
  8013e5:	5d                   	pop    %ebp
  8013e6:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013e7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ee:	83 ec 0c             	sub    $0xc,%esp
  8013f1:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f6:	50                   	push   %eax
  8013f7:	57                   	push   %edi
  8013f8:	6a 00                	push   $0x0
  8013fa:	53                   	push   %ebx
  8013fb:	6a 00                	push   $0x0
  8013fd:	e8 a6 fb ff ff       	call   800fa8 <sys_page_map>
  801402:	89 c3                	mov    %eax,%ebx
  801404:	83 c4 20             	add    $0x20,%esp
  801407:	85 c0                	test   %eax,%eax
  801409:	79 a3                	jns    8013ae <dup+0x78>
	sys_page_unmap(0, newfd);
  80140b:	83 ec 08             	sub    $0x8,%esp
  80140e:	56                   	push   %esi
  80140f:	6a 00                	push   $0x0
  801411:	e8 b7 fb ff ff       	call   800fcd <sys_page_unmap>
	sys_page_unmap(0, nva);
  801416:	83 c4 08             	add    $0x8,%esp
  801419:	57                   	push   %edi
  80141a:	6a 00                	push   $0x0
  80141c:	e8 ac fb ff ff       	call   800fcd <sys_page_unmap>
	return r;
  801421:	83 c4 10             	add    $0x10,%esp
  801424:	eb b7                	jmp    8013dd <dup+0xa7>

00801426 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801426:	f3 0f 1e fb          	endbr32 
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	53                   	push   %ebx
  80142e:	83 ec 1c             	sub    $0x1c,%esp
  801431:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801434:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801437:	50                   	push   %eax
  801438:	53                   	push   %ebx
  801439:	e8 60 fd ff ff       	call   80119e <fd_lookup>
  80143e:	83 c4 10             	add    $0x10,%esp
  801441:	85 c0                	test   %eax,%eax
  801443:	78 3f                	js     801484 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801445:	83 ec 08             	sub    $0x8,%esp
  801448:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144b:	50                   	push   %eax
  80144c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144f:	ff 30                	pushl  (%eax)
  801451:	e8 9c fd ff ff       	call   8011f2 <dev_lookup>
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 27                	js     801484 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80145d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801460:	8b 42 08             	mov    0x8(%edx),%eax
  801463:	83 e0 03             	and    $0x3,%eax
  801466:	83 f8 01             	cmp    $0x1,%eax
  801469:	74 1e                	je     801489 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80146b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80146e:	8b 40 08             	mov    0x8(%eax),%eax
  801471:	85 c0                	test   %eax,%eax
  801473:	74 35                	je     8014aa <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801475:	83 ec 04             	sub    $0x4,%esp
  801478:	ff 75 10             	pushl  0x10(%ebp)
  80147b:	ff 75 0c             	pushl  0xc(%ebp)
  80147e:	52                   	push   %edx
  80147f:	ff d0                	call   *%eax
  801481:	83 c4 10             	add    $0x10,%esp
}
  801484:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801487:	c9                   	leave  
  801488:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801489:	a1 90 77 80 00       	mov    0x807790,%eax
  80148e:	8b 40 48             	mov    0x48(%eax),%eax
  801491:	83 ec 04             	sub    $0x4,%esp
  801494:	53                   	push   %ebx
  801495:	50                   	push   %eax
  801496:	68 81 30 80 00       	push   $0x803081
  80149b:	e8 6f f0 ff ff       	call   80050f <cprintf>
		return -E_INVAL;
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a8:	eb da                	jmp    801484 <read+0x5e>
		return -E_NOT_SUPP;
  8014aa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014af:	eb d3                	jmp    801484 <read+0x5e>

008014b1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014b1:	f3 0f 1e fb          	endbr32 
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	57                   	push   %edi
  8014b9:	56                   	push   %esi
  8014ba:	53                   	push   %ebx
  8014bb:	83 ec 0c             	sub    $0xc,%esp
  8014be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014c1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014c9:	eb 02                	jmp    8014cd <readn+0x1c>
  8014cb:	01 c3                	add    %eax,%ebx
  8014cd:	39 f3                	cmp    %esi,%ebx
  8014cf:	73 21                	jae    8014f2 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014d1:	83 ec 04             	sub    $0x4,%esp
  8014d4:	89 f0                	mov    %esi,%eax
  8014d6:	29 d8                	sub    %ebx,%eax
  8014d8:	50                   	push   %eax
  8014d9:	89 d8                	mov    %ebx,%eax
  8014db:	03 45 0c             	add    0xc(%ebp),%eax
  8014de:	50                   	push   %eax
  8014df:	57                   	push   %edi
  8014e0:	e8 41 ff ff ff       	call   801426 <read>
		if (m < 0)
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	78 04                	js     8014f0 <readn+0x3f>
			return m;
		if (m == 0)
  8014ec:	75 dd                	jne    8014cb <readn+0x1a>
  8014ee:	eb 02                	jmp    8014f2 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014f0:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8014f2:	89 d8                	mov    %ebx,%eax
  8014f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f7:	5b                   	pop    %ebx
  8014f8:	5e                   	pop    %esi
  8014f9:	5f                   	pop    %edi
  8014fa:	5d                   	pop    %ebp
  8014fb:	c3                   	ret    

008014fc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014fc:	f3 0f 1e fb          	endbr32 
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	53                   	push   %ebx
  801504:	83 ec 1c             	sub    $0x1c,%esp
  801507:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150d:	50                   	push   %eax
  80150e:	53                   	push   %ebx
  80150f:	e8 8a fc ff ff       	call   80119e <fd_lookup>
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	85 c0                	test   %eax,%eax
  801519:	78 3a                	js     801555 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151b:	83 ec 08             	sub    $0x8,%esp
  80151e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801521:	50                   	push   %eax
  801522:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801525:	ff 30                	pushl  (%eax)
  801527:	e8 c6 fc ff ff       	call   8011f2 <dev_lookup>
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	85 c0                	test   %eax,%eax
  801531:	78 22                	js     801555 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801533:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801536:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80153a:	74 1e                	je     80155a <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80153c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80153f:	8b 52 0c             	mov    0xc(%edx),%edx
  801542:	85 d2                	test   %edx,%edx
  801544:	74 35                	je     80157b <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801546:	83 ec 04             	sub    $0x4,%esp
  801549:	ff 75 10             	pushl  0x10(%ebp)
  80154c:	ff 75 0c             	pushl  0xc(%ebp)
  80154f:	50                   	push   %eax
  801550:	ff d2                	call   *%edx
  801552:	83 c4 10             	add    $0x10,%esp
}
  801555:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801558:	c9                   	leave  
  801559:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80155a:	a1 90 77 80 00       	mov    0x807790,%eax
  80155f:	8b 40 48             	mov    0x48(%eax),%eax
  801562:	83 ec 04             	sub    $0x4,%esp
  801565:	53                   	push   %ebx
  801566:	50                   	push   %eax
  801567:	68 9d 30 80 00       	push   $0x80309d
  80156c:	e8 9e ef ff ff       	call   80050f <cprintf>
		return -E_INVAL;
  801571:	83 c4 10             	add    $0x10,%esp
  801574:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801579:	eb da                	jmp    801555 <write+0x59>
		return -E_NOT_SUPP;
  80157b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801580:	eb d3                	jmp    801555 <write+0x59>

00801582 <seek>:

int
seek(int fdnum, off_t offset)
{
  801582:	f3 0f 1e fb          	endbr32 
  801586:	55                   	push   %ebp
  801587:	89 e5                	mov    %esp,%ebp
  801589:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80158c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158f:	50                   	push   %eax
  801590:	ff 75 08             	pushl  0x8(%ebp)
  801593:	e8 06 fc ff ff       	call   80119e <fd_lookup>
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	85 c0                	test   %eax,%eax
  80159d:	78 0e                	js     8015ad <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80159f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ad:	c9                   	leave  
  8015ae:	c3                   	ret    

008015af <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015af:	f3 0f 1e fb          	endbr32 
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	53                   	push   %ebx
  8015b7:	83 ec 1c             	sub    $0x1c,%esp
  8015ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c0:	50                   	push   %eax
  8015c1:	53                   	push   %ebx
  8015c2:	e8 d7 fb ff ff       	call   80119e <fd_lookup>
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	85 c0                	test   %eax,%eax
  8015cc:	78 37                	js     801605 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ce:	83 ec 08             	sub    $0x8,%esp
  8015d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d4:	50                   	push   %eax
  8015d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d8:	ff 30                	pushl  (%eax)
  8015da:	e8 13 fc ff ff       	call   8011f2 <dev_lookup>
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	85 c0                	test   %eax,%eax
  8015e4:	78 1f                	js     801605 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ed:	74 1b                	je     80160a <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8015ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f2:	8b 52 18             	mov    0x18(%edx),%edx
  8015f5:	85 d2                	test   %edx,%edx
  8015f7:	74 32                	je     80162b <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015f9:	83 ec 08             	sub    $0x8,%esp
  8015fc:	ff 75 0c             	pushl  0xc(%ebp)
  8015ff:	50                   	push   %eax
  801600:	ff d2                	call   *%edx
  801602:	83 c4 10             	add    $0x10,%esp
}
  801605:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801608:	c9                   	leave  
  801609:	c3                   	ret    
			thisenv->env_id, fdnum);
  80160a:	a1 90 77 80 00       	mov    0x807790,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80160f:	8b 40 48             	mov    0x48(%eax),%eax
  801612:	83 ec 04             	sub    $0x4,%esp
  801615:	53                   	push   %ebx
  801616:	50                   	push   %eax
  801617:	68 60 30 80 00       	push   $0x803060
  80161c:	e8 ee ee ff ff       	call   80050f <cprintf>
		return -E_INVAL;
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801629:	eb da                	jmp    801605 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80162b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801630:	eb d3                	jmp    801605 <ftruncate+0x56>

00801632 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801632:	f3 0f 1e fb          	endbr32 
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	53                   	push   %ebx
  80163a:	83 ec 1c             	sub    $0x1c,%esp
  80163d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801640:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801643:	50                   	push   %eax
  801644:	ff 75 08             	pushl  0x8(%ebp)
  801647:	e8 52 fb ff ff       	call   80119e <fd_lookup>
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	85 c0                	test   %eax,%eax
  801651:	78 4b                	js     80169e <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801653:	83 ec 08             	sub    $0x8,%esp
  801656:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801659:	50                   	push   %eax
  80165a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165d:	ff 30                	pushl  (%eax)
  80165f:	e8 8e fb ff ff       	call   8011f2 <dev_lookup>
  801664:	83 c4 10             	add    $0x10,%esp
  801667:	85 c0                	test   %eax,%eax
  801669:	78 33                	js     80169e <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80166b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801672:	74 2f                	je     8016a3 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801674:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801677:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80167e:	00 00 00 
	stat->st_isdir = 0;
  801681:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801688:	00 00 00 
	stat->st_dev = dev;
  80168b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801691:	83 ec 08             	sub    $0x8,%esp
  801694:	53                   	push   %ebx
  801695:	ff 75 f0             	pushl  -0x10(%ebp)
  801698:	ff 50 14             	call   *0x14(%eax)
  80169b:	83 c4 10             	add    $0x10,%esp
}
  80169e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a1:	c9                   	leave  
  8016a2:	c3                   	ret    
		return -E_NOT_SUPP;
  8016a3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016a8:	eb f4                	jmp    80169e <fstat+0x6c>

008016aa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016aa:	f3 0f 1e fb          	endbr32 
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	56                   	push   %esi
  8016b2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016b3:	83 ec 08             	sub    $0x8,%esp
  8016b6:	6a 00                	push   $0x0
  8016b8:	ff 75 08             	pushl  0x8(%ebp)
  8016bb:	e8 01 02 00 00       	call   8018c1 <open>
  8016c0:	89 c3                	mov    %eax,%ebx
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	78 1b                	js     8016e4 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8016c9:	83 ec 08             	sub    $0x8,%esp
  8016cc:	ff 75 0c             	pushl  0xc(%ebp)
  8016cf:	50                   	push   %eax
  8016d0:	e8 5d ff ff ff       	call   801632 <fstat>
  8016d5:	89 c6                	mov    %eax,%esi
	close(fd);
  8016d7:	89 1c 24             	mov    %ebx,(%esp)
  8016da:	e8 fd fb ff ff       	call   8012dc <close>
	return r;
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	89 f3                	mov    %esi,%ebx
}
  8016e4:	89 d8                	mov    %ebx,%eax
  8016e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e9:	5b                   	pop    %ebx
  8016ea:	5e                   	pop    %esi
  8016eb:	5d                   	pop    %ebp
  8016ec:	c3                   	ret    

008016ed <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
  8016f0:	56                   	push   %esi
  8016f1:	53                   	push   %ebx
  8016f2:	89 c6                	mov    %eax,%esi
  8016f4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016f6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8016fd:	74 27                	je     801726 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016ff:	6a 07                	push   $0x7
  801701:	68 00 80 80 00       	push   $0x808000
  801706:	56                   	push   %esi
  801707:	ff 35 00 60 80 00    	pushl  0x806000
  80170d:	e8 65 11 00 00       	call   802877 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801712:	83 c4 0c             	add    $0xc,%esp
  801715:	6a 00                	push   $0x0
  801717:	53                   	push   %ebx
  801718:	6a 00                	push   $0x0
  80171a:	e8 eb 10 00 00       	call   80280a <ipc_recv>
}
  80171f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801722:	5b                   	pop    %ebx
  801723:	5e                   	pop    %esi
  801724:	5d                   	pop    %ebp
  801725:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801726:	83 ec 0c             	sub    $0xc,%esp
  801729:	6a 01                	push   $0x1
  80172b:	e8 9f 11 00 00       	call   8028cf <ipc_find_env>
  801730:	a3 00 60 80 00       	mov    %eax,0x806000
  801735:	83 c4 10             	add    $0x10,%esp
  801738:	eb c5                	jmp    8016ff <fsipc+0x12>

0080173a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80173a:	f3 0f 1e fb          	endbr32 
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801744:	8b 45 08             	mov    0x8(%ebp),%eax
  801747:	8b 40 0c             	mov    0xc(%eax),%eax
  80174a:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.set_size.req_size = newsize;
  80174f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801752:	a3 04 80 80 00       	mov    %eax,0x808004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801757:	ba 00 00 00 00       	mov    $0x0,%edx
  80175c:	b8 02 00 00 00       	mov    $0x2,%eax
  801761:	e8 87 ff ff ff       	call   8016ed <fsipc>
}
  801766:	c9                   	leave  
  801767:	c3                   	ret    

00801768 <devfile_flush>:
{
  801768:	f3 0f 1e fb          	endbr32 
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801772:	8b 45 08             	mov    0x8(%ebp),%eax
  801775:	8b 40 0c             	mov    0xc(%eax),%eax
  801778:	a3 00 80 80 00       	mov    %eax,0x808000
	return fsipc(FSREQ_FLUSH, NULL);
  80177d:	ba 00 00 00 00       	mov    $0x0,%edx
  801782:	b8 06 00 00 00       	mov    $0x6,%eax
  801787:	e8 61 ff ff ff       	call   8016ed <fsipc>
}
  80178c:	c9                   	leave  
  80178d:	c3                   	ret    

0080178e <devfile_stat>:
{
  80178e:	f3 0f 1e fb          	endbr32 
  801792:	55                   	push   %ebp
  801793:	89 e5                	mov    %esp,%ebp
  801795:	53                   	push   %ebx
  801796:	83 ec 04             	sub    $0x4,%esp
  801799:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80179c:	8b 45 08             	mov    0x8(%ebp),%eax
  80179f:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a2:	a3 00 80 80 00       	mov    %eax,0x808000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ac:	b8 05 00 00 00       	mov    $0x5,%eax
  8017b1:	e8 37 ff ff ff       	call   8016ed <fsipc>
  8017b6:	85 c0                	test   %eax,%eax
  8017b8:	78 2c                	js     8017e6 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017ba:	83 ec 08             	sub    $0x8,%esp
  8017bd:	68 00 80 80 00       	push   $0x808000
  8017c2:	53                   	push   %ebx
  8017c3:	e8 51 f3 ff ff       	call   800b19 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017c8:	a1 80 80 80 00       	mov    0x808080,%eax
  8017cd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017d3:	a1 84 80 80 00       	mov    0x808084,%eax
  8017d8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017de:	83 c4 10             	add    $0x10,%esp
  8017e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e9:	c9                   	leave  
  8017ea:	c3                   	ret    

008017eb <devfile_write>:
{
  8017eb:	f3 0f 1e fb          	endbr32 
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	83 ec 0c             	sub    $0xc,%esp
  8017f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8017f8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017fd:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801802:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801805:	8b 55 08             	mov    0x8(%ebp),%edx
  801808:	8b 52 0c             	mov    0xc(%edx),%edx
  80180b:	89 15 00 80 80 00    	mov    %edx,0x808000
	fsipcbuf.write.req_n = n;
  801811:	a3 04 80 80 00       	mov    %eax,0x808004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801816:	50                   	push   %eax
  801817:	ff 75 0c             	pushl  0xc(%ebp)
  80181a:	68 08 80 80 00       	push   $0x808008
  80181f:	e8 f3 f4 ff ff       	call   800d17 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801824:	ba 00 00 00 00       	mov    $0x0,%edx
  801829:	b8 04 00 00 00       	mov    $0x4,%eax
  80182e:	e8 ba fe ff ff       	call   8016ed <fsipc>
}
  801833:	c9                   	leave  
  801834:	c3                   	ret    

00801835 <devfile_read>:
{
  801835:	f3 0f 1e fb          	endbr32 
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	56                   	push   %esi
  80183d:	53                   	push   %ebx
  80183e:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801841:	8b 45 08             	mov    0x8(%ebp),%eax
  801844:	8b 40 0c             	mov    0xc(%eax),%eax
  801847:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.read.req_n = n;
  80184c:	89 35 04 80 80 00    	mov    %esi,0x808004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801852:	ba 00 00 00 00       	mov    $0x0,%edx
  801857:	b8 03 00 00 00       	mov    $0x3,%eax
  80185c:	e8 8c fe ff ff       	call   8016ed <fsipc>
  801861:	89 c3                	mov    %eax,%ebx
  801863:	85 c0                	test   %eax,%eax
  801865:	78 1f                	js     801886 <devfile_read+0x51>
	assert(r <= n);
  801867:	39 f0                	cmp    %esi,%eax
  801869:	77 24                	ja     80188f <devfile_read+0x5a>
	assert(r <= PGSIZE);
  80186b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801870:	7f 36                	jg     8018a8 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801872:	83 ec 04             	sub    $0x4,%esp
  801875:	50                   	push   %eax
  801876:	68 00 80 80 00       	push   $0x808000
  80187b:	ff 75 0c             	pushl  0xc(%ebp)
  80187e:	e8 94 f4 ff ff       	call   800d17 <memmove>
	return r;
  801883:	83 c4 10             	add    $0x10,%esp
}
  801886:	89 d8                	mov    %ebx,%eax
  801888:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80188b:	5b                   	pop    %ebx
  80188c:	5e                   	pop    %esi
  80188d:	5d                   	pop    %ebp
  80188e:	c3                   	ret    
	assert(r <= n);
  80188f:	68 d0 30 80 00       	push   $0x8030d0
  801894:	68 d7 30 80 00       	push   $0x8030d7
  801899:	68 8c 00 00 00       	push   $0x8c
  80189e:	68 ec 30 80 00       	push   $0x8030ec
  8018a3:	e8 80 eb ff ff       	call   800428 <_panic>
	assert(r <= PGSIZE);
  8018a8:	68 f7 30 80 00       	push   $0x8030f7
  8018ad:	68 d7 30 80 00       	push   $0x8030d7
  8018b2:	68 8d 00 00 00       	push   $0x8d
  8018b7:	68 ec 30 80 00       	push   $0x8030ec
  8018bc:	e8 67 eb ff ff       	call   800428 <_panic>

008018c1 <open>:
{
  8018c1:	f3 0f 1e fb          	endbr32 
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	56                   	push   %esi
  8018c9:	53                   	push   %ebx
  8018ca:	83 ec 1c             	sub    $0x1c,%esp
  8018cd:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8018d0:	56                   	push   %esi
  8018d1:	e8 00 f2 ff ff       	call   800ad6 <strlen>
  8018d6:	83 c4 10             	add    $0x10,%esp
  8018d9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018de:	7f 6c                	jg     80194c <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8018e0:	83 ec 0c             	sub    $0xc,%esp
  8018e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e6:	50                   	push   %eax
  8018e7:	e8 5c f8 ff ff       	call   801148 <fd_alloc>
  8018ec:	89 c3                	mov    %eax,%ebx
  8018ee:	83 c4 10             	add    $0x10,%esp
  8018f1:	85 c0                	test   %eax,%eax
  8018f3:	78 3c                	js     801931 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8018f5:	83 ec 08             	sub    $0x8,%esp
  8018f8:	56                   	push   %esi
  8018f9:	68 00 80 80 00       	push   $0x808000
  8018fe:	e8 16 f2 ff ff       	call   800b19 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801903:	8b 45 0c             	mov    0xc(%ebp),%eax
  801906:	a3 00 84 80 00       	mov    %eax,0x808400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80190b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80190e:	b8 01 00 00 00       	mov    $0x1,%eax
  801913:	e8 d5 fd ff ff       	call   8016ed <fsipc>
  801918:	89 c3                	mov    %eax,%ebx
  80191a:	83 c4 10             	add    $0x10,%esp
  80191d:	85 c0                	test   %eax,%eax
  80191f:	78 19                	js     80193a <open+0x79>
	return fd2num(fd);
  801921:	83 ec 0c             	sub    $0xc,%esp
  801924:	ff 75 f4             	pushl  -0xc(%ebp)
  801927:	e8 ed f7 ff ff       	call   801119 <fd2num>
  80192c:	89 c3                	mov    %eax,%ebx
  80192e:	83 c4 10             	add    $0x10,%esp
}
  801931:	89 d8                	mov    %ebx,%eax
  801933:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801936:	5b                   	pop    %ebx
  801937:	5e                   	pop    %esi
  801938:	5d                   	pop    %ebp
  801939:	c3                   	ret    
		fd_close(fd, 0);
  80193a:	83 ec 08             	sub    $0x8,%esp
  80193d:	6a 00                	push   $0x0
  80193f:	ff 75 f4             	pushl  -0xc(%ebp)
  801942:	e8 0a f9 ff ff       	call   801251 <fd_close>
		return r;
  801947:	83 c4 10             	add    $0x10,%esp
  80194a:	eb e5                	jmp    801931 <open+0x70>
		return -E_BAD_PATH;
  80194c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801951:	eb de                	jmp    801931 <open+0x70>

00801953 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801953:	f3 0f 1e fb          	endbr32 
  801957:	55                   	push   %ebp
  801958:	89 e5                	mov    %esp,%ebp
  80195a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80195d:	ba 00 00 00 00       	mov    $0x0,%edx
  801962:	b8 08 00 00 00       	mov    $0x8,%eax
  801967:	e8 81 fd ff ff       	call   8016ed <fsipc>
}
  80196c:	c9                   	leave  
  80196d:	c3                   	ret    

0080196e <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80196e:	f3 0f 1e fb          	endbr32 
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	57                   	push   %edi
  801976:	56                   	push   %esi
  801977:	53                   	push   %ebx
  801978:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80197e:	6a 00                	push   $0x0
  801980:	ff 75 08             	pushl  0x8(%ebp)
  801983:	e8 39 ff ff ff       	call   8018c1 <open>
  801988:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80198e:	83 c4 10             	add    $0x10,%esp
  801991:	85 c0                	test   %eax,%eax
  801993:	0f 88 b2 04 00 00    	js     801e4b <spawn+0x4dd>
  801999:	89 c1                	mov    %eax,%ecx
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80199b:	83 ec 04             	sub    $0x4,%esp
  80199e:	68 00 02 00 00       	push   $0x200
  8019a3:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8019a9:	50                   	push   %eax
  8019aa:	51                   	push   %ecx
  8019ab:	e8 01 fb ff ff       	call   8014b1 <readn>
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8019b8:	75 7e                	jne    801a38 <spawn+0xca>
	    || elf->e_magic != ELF_MAGIC) {
  8019ba:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8019c1:	45 4c 46 
  8019c4:	75 72                	jne    801a38 <spawn+0xca>
*/
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8019c6:	b8 07 00 00 00       	mov    $0x7,%eax
  8019cb:	cd 30                	int    $0x30
  8019cd:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8019d3:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8019d9:	85 c0                	test   %eax,%eax
  8019db:	0f 88 5e 04 00 00    	js     801e3f <spawn+0x4d1>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8019e1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8019e6:	6b f0 7c             	imul   $0x7c,%eax,%esi
  8019e9:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8019ef:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8019f5:	b9 11 00 00 00       	mov    $0x11,%ecx
  8019fa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8019fc:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a02:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a08:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801a0d:	be 00 00 00 00       	mov    $0x0,%esi
  801a12:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a15:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
	for (argc = 0; argv[argc] != 0; argc++)
  801a1c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a1f:	85 c0                	test   %eax,%eax
  801a21:	74 4d                	je     801a70 <spawn+0x102>
		string_size += strlen(argv[argc]) + 1;
  801a23:	83 ec 0c             	sub    $0xc,%esp
  801a26:	50                   	push   %eax
  801a27:	e8 aa f0 ff ff       	call   800ad6 <strlen>
  801a2c:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801a30:	83 c3 01             	add    $0x1,%ebx
  801a33:	83 c4 10             	add    $0x10,%esp
  801a36:	eb dd                	jmp    801a15 <spawn+0xa7>
		close(fd);
  801a38:	83 ec 0c             	sub    $0xc,%esp
  801a3b:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801a41:	e8 96 f8 ff ff       	call   8012dc <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801a46:	83 c4 0c             	add    $0xc,%esp
  801a49:	68 7f 45 4c 46       	push   $0x464c457f
  801a4e:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801a54:	68 63 31 80 00       	push   $0x803163
  801a59:	e8 b1 ea ff ff       	call   80050f <cprintf>
		return -E_NOT_EXEC;
  801a5e:	83 c4 10             	add    $0x10,%esp
  801a61:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  801a68:	ff ff ff 
  801a6b:	e9 db 03 00 00       	jmp    801e4b <spawn+0x4dd>
  801a70:	89 85 70 fd ff ff    	mov    %eax,-0x290(%ebp)
  801a76:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801a7c:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a82:	bf 00 10 40 00       	mov    $0x401000,%edi
  801a87:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a89:	89 fa                	mov    %edi,%edx
  801a8b:	83 e2 fc             	and    $0xfffffffc,%edx
  801a8e:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a95:	29 c2                	sub    %eax,%edx
  801a97:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a9d:	8d 42 f8             	lea    -0x8(%edx),%eax
  801aa0:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801aa5:	0f 86 12 04 00 00    	jbe    801ebd <spawn+0x54f>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801aab:	83 ec 04             	sub    $0x4,%esp
  801aae:	6a 07                	push   $0x7
  801ab0:	68 00 00 40 00       	push   $0x400000
  801ab5:	6a 00                	push   $0x0
  801ab7:	e8 c6 f4 ff ff       	call   800f82 <sys_page_alloc>
  801abc:	83 c4 10             	add    $0x10,%esp
  801abf:	85 c0                	test   %eax,%eax
  801ac1:	0f 88 fb 03 00 00    	js     801ec2 <spawn+0x554>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801ac7:	be 00 00 00 00       	mov    $0x0,%esi
  801acc:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801ad2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ad5:	eb 30                	jmp    801b07 <spawn+0x199>
		argv_store[i] = UTEMP2USTACK(string_store);
  801ad7:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801add:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801ae3:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801ae6:	83 ec 08             	sub    $0x8,%esp
  801ae9:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801aec:	57                   	push   %edi
  801aed:	e8 27 f0 ff ff       	call   800b19 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801af2:	83 c4 04             	add    $0x4,%esp
  801af5:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801af8:	e8 d9 ef ff ff       	call   800ad6 <strlen>
  801afd:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801b01:	83 c6 01             	add    $0x1,%esi
  801b04:	83 c4 10             	add    $0x10,%esp
  801b07:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  801b0d:	7f c8                	jg     801ad7 <spawn+0x169>
	}
	argv_store[argc] = 0;
  801b0f:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801b15:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801b1b:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b22:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b28:	0f 85 88 00 00 00    	jne    801bb6 <spawn+0x248>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b2e:	8b 8d 90 fd ff ff    	mov    -0x270(%ebp),%ecx
  801b34:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  801b3a:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801b3d:	89 c8                	mov    %ecx,%eax
  801b3f:	8b 95 84 fd ff ff    	mov    -0x27c(%ebp),%edx
  801b45:	89 51 f8             	mov    %edx,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b48:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801b4d:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b53:	83 ec 0c             	sub    $0xc,%esp
  801b56:	6a 07                	push   $0x7
  801b58:	68 00 d0 bf ee       	push   $0xeebfd000
  801b5d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b63:	68 00 00 40 00       	push   $0x400000
  801b68:	6a 00                	push   $0x0
  801b6a:	e8 39 f4 ff ff       	call   800fa8 <sys_page_map>
  801b6f:	89 c3                	mov    %eax,%ebx
  801b71:	83 c4 20             	add    $0x20,%esp
  801b74:	85 c0                	test   %eax,%eax
  801b76:	0f 88 4e 03 00 00    	js     801eca <spawn+0x55c>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b7c:	83 ec 08             	sub    $0x8,%esp
  801b7f:	68 00 00 40 00       	push   $0x400000
  801b84:	6a 00                	push   $0x0
  801b86:	e8 42 f4 ff ff       	call   800fcd <sys_page_unmap>
  801b8b:	89 c3                	mov    %eax,%ebx
  801b8d:	83 c4 10             	add    $0x10,%esp
  801b90:	85 c0                	test   %eax,%eax
  801b92:	0f 88 32 03 00 00    	js     801eca <spawn+0x55c>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b98:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b9e:	8d b4 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%esi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ba5:	c7 85 84 fd ff ff 00 	movl   $0x0,-0x27c(%ebp)
  801bac:	00 00 00 
  801baf:	89 f7                	mov    %esi,%edi
  801bb1:	e9 4f 01 00 00       	jmp    801d05 <spawn+0x397>
	assert(string_store == (char*)UTEMP + PGSIZE);
  801bb6:	68 f0 31 80 00       	push   $0x8031f0
  801bbb:	68 d7 30 80 00       	push   $0x8030d7
  801bc0:	68 f1 00 00 00       	push   $0xf1
  801bc5:	68 7d 31 80 00       	push   $0x80317d
  801bca:	e8 59 e8 ff ff       	call   800428 <_panic>
			// allocate a blank page bss segment
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801bcf:	83 ec 04             	sub    $0x4,%esp
  801bd2:	6a 07                	push   $0x7
  801bd4:	68 00 00 40 00       	push   $0x400000
  801bd9:	6a 00                	push   $0x0
  801bdb:	e8 a2 f3 ff ff       	call   800f82 <sys_page_alloc>
  801be0:	83 c4 10             	add    $0x10,%esp
  801be3:	85 c0                	test   %eax,%eax
  801be5:	0f 88 6e 02 00 00    	js     801e59 <spawn+0x4eb>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801beb:	83 ec 08             	sub    $0x8,%esp
  801bee:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801bf4:	01 f8                	add    %edi,%eax
  801bf6:	50                   	push   %eax
  801bf7:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801bfd:	e8 80 f9 ff ff       	call   801582 <seek>
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	85 c0                	test   %eax,%eax
  801c07:	0f 88 53 02 00 00    	js     801e60 <spawn+0x4f2>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c0d:	83 ec 04             	sub    $0x4,%esp
  801c10:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801c16:	29 f8                	sub    %edi,%eax
  801c18:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c1d:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801c22:	0f 47 c1             	cmova  %ecx,%eax
  801c25:	50                   	push   %eax
  801c26:	68 00 00 40 00       	push   $0x400000
  801c2b:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801c31:	e8 7b f8 ff ff       	call   8014b1 <readn>
  801c36:	83 c4 10             	add    $0x10,%esp
  801c39:	85 c0                	test   %eax,%eax
  801c3b:	0f 88 26 02 00 00    	js     801e67 <spawn+0x4f9>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c41:	83 ec 0c             	sub    $0xc,%esp
  801c44:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c4a:	53                   	push   %ebx
  801c4b:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c51:	68 00 00 40 00       	push   $0x400000
  801c56:	6a 00                	push   $0x0
  801c58:	e8 4b f3 ff ff       	call   800fa8 <sys_page_map>
  801c5d:	83 c4 20             	add    $0x20,%esp
  801c60:	85 c0                	test   %eax,%eax
  801c62:	78 7c                	js     801ce0 <spawn+0x372>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  801c64:	83 ec 08             	sub    $0x8,%esp
  801c67:	68 00 00 40 00       	push   $0x400000
  801c6c:	6a 00                	push   $0x0
  801c6e:	e8 5a f3 ff ff       	call   800fcd <sys_page_unmap>
  801c73:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801c76:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c7c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c82:	89 f7                	mov    %esi,%edi
  801c84:	39 b5 7c fd ff ff    	cmp    %esi,-0x284(%ebp)
  801c8a:	76 69                	jbe    801cf5 <spawn+0x387>
		if (i >= filesz) {
  801c8c:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801c92:	0f 87 37 ff ff ff    	ja     801bcf <spawn+0x261>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c98:	83 ec 04             	sub    $0x4,%esp
  801c9b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ca1:	53                   	push   %ebx
  801ca2:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801ca8:	e8 d5 f2 ff ff       	call   800f82 <sys_page_alloc>
  801cad:	83 c4 10             	add    $0x10,%esp
  801cb0:	85 c0                	test   %eax,%eax
  801cb2:	79 c2                	jns    801c76 <spawn+0x308>
  801cb4:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801cb6:	83 ec 0c             	sub    $0xc,%esp
  801cb9:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801cbf:	e8 54 f2 ff ff       	call   800f18 <sys_env_destroy>
	close(fd);
  801cc4:	83 c4 04             	add    $0x4,%esp
  801cc7:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801ccd:	e8 0a f6 ff ff       	call   8012dc <close>
	return r;
  801cd2:	83 c4 10             	add    $0x10,%esp
  801cd5:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
  801cdb:	e9 6b 01 00 00       	jmp    801e4b <spawn+0x4dd>
				panic("spawn: sys_page_map data: %e", r);
  801ce0:	50                   	push   %eax
  801ce1:	68 89 31 80 00       	push   $0x803189
  801ce6:	68 24 01 00 00       	push   $0x124
  801ceb:	68 7d 31 80 00       	push   $0x80317d
  801cf0:	e8 33 e7 ff ff       	call   800428 <_panic>
  801cf5:	8b bd 78 fd ff ff    	mov    -0x288(%ebp),%edi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801cfb:	83 85 84 fd ff ff 01 	addl   $0x1,-0x27c(%ebp)
  801d02:	83 c7 20             	add    $0x20,%edi
  801d05:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d0c:	3b 85 84 fd ff ff    	cmp    -0x27c(%ebp),%eax
  801d12:	7e 6d                	jle    801d81 <spawn+0x413>
		if (ph->p_type != ELF_PROG_LOAD)
  801d14:	83 3f 01             	cmpl   $0x1,(%edi)
  801d17:	75 e2                	jne    801cfb <spawn+0x38d>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801d19:	8b 47 18             	mov    0x18(%edi),%eax
  801d1c:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801d1f:	83 f8 01             	cmp    $0x1,%eax
  801d22:	19 c0                	sbb    %eax,%eax
  801d24:	83 e0 fe             	and    $0xfffffffe,%eax
  801d27:	83 c0 07             	add    $0x7,%eax
  801d2a:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801d30:	8b 57 04             	mov    0x4(%edi),%edx
  801d33:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801d39:	8b 4f 10             	mov    0x10(%edi),%ecx
  801d3c:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  801d42:	8b 77 14             	mov    0x14(%edi),%esi
  801d45:	89 b5 7c fd ff ff    	mov    %esi,-0x284(%ebp)
  801d4b:	8b 5f 08             	mov    0x8(%edi),%ebx
	if ((i = PGOFF(va))) {
  801d4e:	89 d8                	mov    %ebx,%eax
  801d50:	25 ff 0f 00 00       	and    $0xfff,%eax
  801d55:	74 1a                	je     801d71 <spawn+0x403>
		va -= i;
  801d57:	29 c3                	sub    %eax,%ebx
		memsz += i;
  801d59:	01 c6                	add    %eax,%esi
  801d5b:	89 b5 7c fd ff ff    	mov    %esi,-0x284(%ebp)
		filesz += i;
  801d61:	01 c1                	add    %eax,%ecx
  801d63:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
		fileoffset -= i;
  801d69:	29 c2                	sub    %eax,%edx
  801d6b:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801d71:	be 00 00 00 00       	mov    $0x0,%esi
  801d76:	89 bd 78 fd ff ff    	mov    %edi,-0x288(%ebp)
  801d7c:	e9 01 ff ff ff       	jmp    801c82 <spawn+0x314>
	close(fd);
  801d81:	83 ec 0c             	sub    $0xc,%esp
  801d84:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801d8a:	e8 4d f5 ff ff       	call   8012dc <close>
  801d8f:	83 c4 10             	add    $0x10,%esp
  801d92:	8b b5 88 fd ff ff    	mov    -0x278(%ebp),%esi
  801d98:	8b 9d 70 fd ff ff    	mov    -0x290(%ebp),%ebx
  801d9e:	eb 12                	jmp    801db2 <spawn+0x444>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	void* addr; int r;
	for (addr = 0; addr<(void*)USTACKTOP; addr+=PGSIZE){
  801da0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801da6:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801dac:	0f 84 bc 00 00 00    	je     801e6e <spawn+0x500>
		if ((uvpd[PDX(addr)]&PTE_P) && (uvpt[PGNUM(addr)]&PTE_P) && (uvpt[PGNUM(addr)]&PTE_SHARE)){
  801db2:	89 d8                	mov    %ebx,%eax
  801db4:	c1 e8 16             	shr    $0x16,%eax
  801db7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801dbe:	a8 01                	test   $0x1,%al
  801dc0:	74 de                	je     801da0 <spawn+0x432>
  801dc2:	89 d8                	mov    %ebx,%eax
  801dc4:	c1 e8 0c             	shr    $0xc,%eax
  801dc7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801dce:	f6 c2 01             	test   $0x1,%dl
  801dd1:	74 cd                	je     801da0 <spawn+0x432>
  801dd3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801dda:	f6 c6 04             	test   $0x4,%dh
  801ddd:	74 c1                	je     801da0 <spawn+0x432>
			if ((r = sys_page_map(0, addr, child, addr, (uvpt[PGNUM(addr)]&PTE_SYSCALL)))<0)
  801ddf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801de6:	83 ec 0c             	sub    $0xc,%esp
  801de9:	25 07 0e 00 00       	and    $0xe07,%eax
  801dee:	50                   	push   %eax
  801def:	53                   	push   %ebx
  801df0:	56                   	push   %esi
  801df1:	53                   	push   %ebx
  801df2:	6a 00                	push   $0x0
  801df4:	e8 af f1 ff ff       	call   800fa8 <sys_page_map>
  801df9:	83 c4 20             	add    $0x20,%esp
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	79 a0                	jns    801da0 <spawn+0x432>
		panic("copy_shared_pages: %e", r);
  801e00:	50                   	push   %eax
  801e01:	68 d7 31 80 00       	push   $0x8031d7
  801e06:	68 82 00 00 00       	push   $0x82
  801e0b:	68 7d 31 80 00       	push   $0x80317d
  801e10:	e8 13 e6 ff ff       	call   800428 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801e15:	50                   	push   %eax
  801e16:	68 a6 31 80 00       	push   $0x8031a6
  801e1b:	68 86 00 00 00       	push   $0x86
  801e20:	68 7d 31 80 00       	push   $0x80317d
  801e25:	e8 fe e5 ff ff       	call   800428 <_panic>
		panic("sys_env_set_status: %e", r);
  801e2a:	50                   	push   %eax
  801e2b:	68 c0 31 80 00       	push   $0x8031c0
  801e30:	68 89 00 00 00       	push   $0x89
  801e35:	68 7d 31 80 00       	push   $0x80317d
  801e3a:	e8 e9 e5 ff ff       	call   800428 <_panic>
		return r;
  801e3f:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801e45:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
}
  801e4b:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801e51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e54:	5b                   	pop    %ebx
  801e55:	5e                   	pop    %esi
  801e56:	5f                   	pop    %edi
  801e57:	5d                   	pop    %ebp
  801e58:	c3                   	ret    
  801e59:	89 c7                	mov    %eax,%edi
  801e5b:	e9 56 fe ff ff       	jmp    801cb6 <spawn+0x348>
  801e60:	89 c7                	mov    %eax,%edi
  801e62:	e9 4f fe ff ff       	jmp    801cb6 <spawn+0x348>
  801e67:	89 c7                	mov    %eax,%edi
  801e69:	e9 48 fe ff ff       	jmp    801cb6 <spawn+0x348>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801e6e:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801e75:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e78:	83 ec 08             	sub    $0x8,%esp
  801e7b:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e81:	50                   	push   %eax
  801e82:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e88:	e8 8a f1 ff ff       	call   801017 <sys_env_set_trapframe>
  801e8d:	83 c4 10             	add    $0x10,%esp
  801e90:	85 c0                	test   %eax,%eax
  801e92:	78 81                	js     801e15 <spawn+0x4a7>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e94:	83 ec 08             	sub    $0x8,%esp
  801e97:	6a 02                	push   $0x2
  801e99:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e9f:	e8 4e f1 ff ff       	call   800ff2 <sys_env_set_status>
  801ea4:	83 c4 10             	add    $0x10,%esp
  801ea7:	85 c0                	test   %eax,%eax
  801ea9:	0f 88 7b ff ff ff    	js     801e2a <spawn+0x4bc>
	return child;
  801eaf:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801eb5:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801ebb:	eb 8e                	jmp    801e4b <spawn+0x4dd>
		return -E_NO_MEM;
  801ebd:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ec2:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801ec8:	eb 81                	jmp    801e4b <spawn+0x4dd>
	sys_page_unmap(0, UTEMP);
  801eca:	83 ec 08             	sub    $0x8,%esp
  801ecd:	68 00 00 40 00       	push   $0x400000
  801ed2:	6a 00                	push   $0x0
  801ed4:	e8 f4 f0 ff ff       	call   800fcd <sys_page_unmap>
  801ed9:	83 c4 10             	add    $0x10,%esp
  801edc:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801ee2:	e9 64 ff ff ff       	jmp    801e4b <spawn+0x4dd>

00801ee7 <spawnl>:
{
  801ee7:	f3 0f 1e fb          	endbr32 
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	57                   	push   %edi
  801eef:	56                   	push   %esi
  801ef0:	53                   	push   %ebx
  801ef1:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  801ef4:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  801ef7:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  801efc:	8d 4a 04             	lea    0x4(%edx),%ecx
  801eff:	83 3a 00             	cmpl   $0x0,(%edx)
  801f02:	74 07                	je     801f0b <spawnl+0x24>
		argc++;
  801f04:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  801f07:	89 ca                	mov    %ecx,%edx
  801f09:	eb f1                	jmp    801efc <spawnl+0x15>
	const char *argv[argc+2];
  801f0b:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  801f12:	89 d1                	mov    %edx,%ecx
  801f14:	83 e1 f0             	and    $0xfffffff0,%ecx
  801f17:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  801f1d:	89 e6                	mov    %esp,%esi
  801f1f:	29 d6                	sub    %edx,%esi
  801f21:	89 f2                	mov    %esi,%edx
  801f23:	39 d4                	cmp    %edx,%esp
  801f25:	74 10                	je     801f37 <spawnl+0x50>
  801f27:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  801f2d:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  801f34:	00 
  801f35:	eb ec                	jmp    801f23 <spawnl+0x3c>
  801f37:	89 ca                	mov    %ecx,%edx
  801f39:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801f3f:	29 d4                	sub    %edx,%esp
  801f41:	85 d2                	test   %edx,%edx
  801f43:	74 05                	je     801f4a <spawnl+0x63>
  801f45:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  801f4a:	8d 74 24 03          	lea    0x3(%esp),%esi
  801f4e:	89 f2                	mov    %esi,%edx
  801f50:	c1 ea 02             	shr    $0x2,%edx
  801f53:	83 e6 fc             	and    $0xfffffffc,%esi
  801f56:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801f58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f5b:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801f62:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801f69:	00 
	va_start(vl, arg0);
  801f6a:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801f6d:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  801f6f:	b8 00 00 00 00       	mov    $0x0,%eax
  801f74:	eb 0b                	jmp    801f81 <spawnl+0x9a>
		argv[i+1] = va_arg(vl, const char *);
  801f76:	83 c0 01             	add    $0x1,%eax
  801f79:	8b 39                	mov    (%ecx),%edi
  801f7b:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  801f7e:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  801f81:	39 d0                	cmp    %edx,%eax
  801f83:	75 f1                	jne    801f76 <spawnl+0x8f>
	return spawn(prog, argv);
  801f85:	83 ec 08             	sub    $0x8,%esp
  801f88:	56                   	push   %esi
  801f89:	ff 75 08             	pushl  0x8(%ebp)
  801f8c:	e8 dd f9 ff ff       	call   80196e <spawn>
}
  801f91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f94:	5b                   	pop    %ebx
  801f95:	5e                   	pop    %esi
  801f96:	5f                   	pop    %edi
  801f97:	5d                   	pop    %ebp
  801f98:	c3                   	ret    

00801f99 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801f99:	f3 0f 1e fb          	endbr32 
  801f9d:	55                   	push   %ebp
  801f9e:	89 e5                	mov    %esp,%ebp
  801fa0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801fa3:	68 16 32 80 00       	push   $0x803216
  801fa8:	ff 75 0c             	pushl  0xc(%ebp)
  801fab:	e8 69 eb ff ff       	call   800b19 <strcpy>
	return 0;
}
  801fb0:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb5:	c9                   	leave  
  801fb6:	c3                   	ret    

00801fb7 <devsock_close>:
{
  801fb7:	f3 0f 1e fb          	endbr32 
  801fbb:	55                   	push   %ebp
  801fbc:	89 e5                	mov    %esp,%ebp
  801fbe:	53                   	push   %ebx
  801fbf:	83 ec 10             	sub    $0x10,%esp
  801fc2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801fc5:	53                   	push   %ebx
  801fc6:	e8 41 09 00 00       	call   80290c <pageref>
  801fcb:	89 c2                	mov    %eax,%edx
  801fcd:	83 c4 10             	add    $0x10,%esp
		return 0;
  801fd0:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801fd5:	83 fa 01             	cmp    $0x1,%edx
  801fd8:	74 05                	je     801fdf <devsock_close+0x28>
}
  801fda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fdd:	c9                   	leave  
  801fde:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801fdf:	83 ec 0c             	sub    $0xc,%esp
  801fe2:	ff 73 0c             	pushl  0xc(%ebx)
  801fe5:	e8 e3 02 00 00       	call   8022cd <nsipc_close>
  801fea:	83 c4 10             	add    $0x10,%esp
  801fed:	eb eb                	jmp    801fda <devsock_close+0x23>

00801fef <devsock_write>:
{
  801fef:	f3 0f 1e fb          	endbr32 
  801ff3:	55                   	push   %ebp
  801ff4:	89 e5                	mov    %esp,%ebp
  801ff6:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ff9:	6a 00                	push   $0x0
  801ffb:	ff 75 10             	pushl  0x10(%ebp)
  801ffe:	ff 75 0c             	pushl  0xc(%ebp)
  802001:	8b 45 08             	mov    0x8(%ebp),%eax
  802004:	ff 70 0c             	pushl  0xc(%eax)
  802007:	e8 b5 03 00 00       	call   8023c1 <nsipc_send>
}
  80200c:	c9                   	leave  
  80200d:	c3                   	ret    

0080200e <devsock_read>:
{
  80200e:	f3 0f 1e fb          	endbr32 
  802012:	55                   	push   %ebp
  802013:	89 e5                	mov    %esp,%ebp
  802015:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802018:	6a 00                	push   $0x0
  80201a:	ff 75 10             	pushl  0x10(%ebp)
  80201d:	ff 75 0c             	pushl  0xc(%ebp)
  802020:	8b 45 08             	mov    0x8(%ebp),%eax
  802023:	ff 70 0c             	pushl  0xc(%eax)
  802026:	e8 1f 03 00 00       	call   80234a <nsipc_recv>
}
  80202b:	c9                   	leave  
  80202c:	c3                   	ret    

0080202d <fd2sockid>:
{
  80202d:	55                   	push   %ebp
  80202e:	89 e5                	mov    %esp,%ebp
  802030:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  802033:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802036:	52                   	push   %edx
  802037:	50                   	push   %eax
  802038:	e8 61 f1 ff ff       	call   80119e <fd_lookup>
  80203d:	83 c4 10             	add    $0x10,%esp
  802040:	85 c0                	test   %eax,%eax
  802042:	78 10                	js     802054 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  802044:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802047:	8b 0d e0 57 80 00    	mov    0x8057e0,%ecx
  80204d:	39 08                	cmp    %ecx,(%eax)
  80204f:	75 05                	jne    802056 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  802051:	8b 40 0c             	mov    0xc(%eax),%eax
}
  802054:	c9                   	leave  
  802055:	c3                   	ret    
		return -E_NOT_SUPP;
  802056:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80205b:	eb f7                	jmp    802054 <fd2sockid+0x27>

0080205d <alloc_sockfd>:
{
  80205d:	55                   	push   %ebp
  80205e:	89 e5                	mov    %esp,%ebp
  802060:	56                   	push   %esi
  802061:	53                   	push   %ebx
  802062:	83 ec 1c             	sub    $0x1c,%esp
  802065:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  802067:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80206a:	50                   	push   %eax
  80206b:	e8 d8 f0 ff ff       	call   801148 <fd_alloc>
  802070:	89 c3                	mov    %eax,%ebx
  802072:	83 c4 10             	add    $0x10,%esp
  802075:	85 c0                	test   %eax,%eax
  802077:	78 43                	js     8020bc <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802079:	83 ec 04             	sub    $0x4,%esp
  80207c:	68 07 04 00 00       	push   $0x407
  802081:	ff 75 f4             	pushl  -0xc(%ebp)
  802084:	6a 00                	push   $0x0
  802086:	e8 f7 ee ff ff       	call   800f82 <sys_page_alloc>
  80208b:	89 c3                	mov    %eax,%ebx
  80208d:	83 c4 10             	add    $0x10,%esp
  802090:	85 c0                	test   %eax,%eax
  802092:	78 28                	js     8020bc <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  802094:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802097:	8b 15 e0 57 80 00    	mov    0x8057e0,%edx
  80209d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80209f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8020a9:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8020ac:	83 ec 0c             	sub    $0xc,%esp
  8020af:	50                   	push   %eax
  8020b0:	e8 64 f0 ff ff       	call   801119 <fd2num>
  8020b5:	89 c3                	mov    %eax,%ebx
  8020b7:	83 c4 10             	add    $0x10,%esp
  8020ba:	eb 0c                	jmp    8020c8 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8020bc:	83 ec 0c             	sub    $0xc,%esp
  8020bf:	56                   	push   %esi
  8020c0:	e8 08 02 00 00       	call   8022cd <nsipc_close>
		return r;
  8020c5:	83 c4 10             	add    $0x10,%esp
}
  8020c8:	89 d8                	mov    %ebx,%eax
  8020ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020cd:	5b                   	pop    %ebx
  8020ce:	5e                   	pop    %esi
  8020cf:	5d                   	pop    %ebp
  8020d0:	c3                   	ret    

008020d1 <accept>:
{
  8020d1:	f3 0f 1e fb          	endbr32 
  8020d5:	55                   	push   %ebp
  8020d6:	89 e5                	mov    %esp,%ebp
  8020d8:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8020db:	8b 45 08             	mov    0x8(%ebp),%eax
  8020de:	e8 4a ff ff ff       	call   80202d <fd2sockid>
  8020e3:	85 c0                	test   %eax,%eax
  8020e5:	78 1b                	js     802102 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8020e7:	83 ec 04             	sub    $0x4,%esp
  8020ea:	ff 75 10             	pushl  0x10(%ebp)
  8020ed:	ff 75 0c             	pushl  0xc(%ebp)
  8020f0:	50                   	push   %eax
  8020f1:	e8 22 01 00 00       	call   802218 <nsipc_accept>
  8020f6:	83 c4 10             	add    $0x10,%esp
  8020f9:	85 c0                	test   %eax,%eax
  8020fb:	78 05                	js     802102 <accept+0x31>
	return alloc_sockfd(r);
  8020fd:	e8 5b ff ff ff       	call   80205d <alloc_sockfd>
}
  802102:	c9                   	leave  
  802103:	c3                   	ret    

00802104 <bind>:
{
  802104:	f3 0f 1e fb          	endbr32 
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
  80210b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80210e:	8b 45 08             	mov    0x8(%ebp),%eax
  802111:	e8 17 ff ff ff       	call   80202d <fd2sockid>
  802116:	85 c0                	test   %eax,%eax
  802118:	78 12                	js     80212c <bind+0x28>
	return nsipc_bind(r, name, namelen);
  80211a:	83 ec 04             	sub    $0x4,%esp
  80211d:	ff 75 10             	pushl  0x10(%ebp)
  802120:	ff 75 0c             	pushl  0xc(%ebp)
  802123:	50                   	push   %eax
  802124:	e8 45 01 00 00       	call   80226e <nsipc_bind>
  802129:	83 c4 10             	add    $0x10,%esp
}
  80212c:	c9                   	leave  
  80212d:	c3                   	ret    

0080212e <shutdown>:
{
  80212e:	f3 0f 1e fb          	endbr32 
  802132:	55                   	push   %ebp
  802133:	89 e5                	mov    %esp,%ebp
  802135:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802138:	8b 45 08             	mov    0x8(%ebp),%eax
  80213b:	e8 ed fe ff ff       	call   80202d <fd2sockid>
  802140:	85 c0                	test   %eax,%eax
  802142:	78 0f                	js     802153 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  802144:	83 ec 08             	sub    $0x8,%esp
  802147:	ff 75 0c             	pushl  0xc(%ebp)
  80214a:	50                   	push   %eax
  80214b:	e8 57 01 00 00       	call   8022a7 <nsipc_shutdown>
  802150:	83 c4 10             	add    $0x10,%esp
}
  802153:	c9                   	leave  
  802154:	c3                   	ret    

00802155 <connect>:
{
  802155:	f3 0f 1e fb          	endbr32 
  802159:	55                   	push   %ebp
  80215a:	89 e5                	mov    %esp,%ebp
  80215c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80215f:	8b 45 08             	mov    0x8(%ebp),%eax
  802162:	e8 c6 fe ff ff       	call   80202d <fd2sockid>
  802167:	85 c0                	test   %eax,%eax
  802169:	78 12                	js     80217d <connect+0x28>
	return nsipc_connect(r, name, namelen);
  80216b:	83 ec 04             	sub    $0x4,%esp
  80216e:	ff 75 10             	pushl  0x10(%ebp)
  802171:	ff 75 0c             	pushl  0xc(%ebp)
  802174:	50                   	push   %eax
  802175:	e8 71 01 00 00       	call   8022eb <nsipc_connect>
  80217a:	83 c4 10             	add    $0x10,%esp
}
  80217d:	c9                   	leave  
  80217e:	c3                   	ret    

0080217f <listen>:
{
  80217f:	f3 0f 1e fb          	endbr32 
  802183:	55                   	push   %ebp
  802184:	89 e5                	mov    %esp,%ebp
  802186:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802189:	8b 45 08             	mov    0x8(%ebp),%eax
  80218c:	e8 9c fe ff ff       	call   80202d <fd2sockid>
  802191:	85 c0                	test   %eax,%eax
  802193:	78 0f                	js     8021a4 <listen+0x25>
	return nsipc_listen(r, backlog);
  802195:	83 ec 08             	sub    $0x8,%esp
  802198:	ff 75 0c             	pushl  0xc(%ebp)
  80219b:	50                   	push   %eax
  80219c:	e8 83 01 00 00       	call   802324 <nsipc_listen>
  8021a1:	83 c4 10             	add    $0x10,%esp
}
  8021a4:	c9                   	leave  
  8021a5:	c3                   	ret    

008021a6 <socket>:

int
socket(int domain, int type, int protocol)
{
  8021a6:	f3 0f 1e fb          	endbr32 
  8021aa:	55                   	push   %ebp
  8021ab:	89 e5                	mov    %esp,%ebp
  8021ad:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8021b0:	ff 75 10             	pushl  0x10(%ebp)
  8021b3:	ff 75 0c             	pushl  0xc(%ebp)
  8021b6:	ff 75 08             	pushl  0x8(%ebp)
  8021b9:	e8 65 02 00 00       	call   802423 <nsipc_socket>
  8021be:	83 c4 10             	add    $0x10,%esp
  8021c1:	85 c0                	test   %eax,%eax
  8021c3:	78 05                	js     8021ca <socket+0x24>
		return r;
	return alloc_sockfd(r);
  8021c5:	e8 93 fe ff ff       	call   80205d <alloc_sockfd>
}
  8021ca:	c9                   	leave  
  8021cb:	c3                   	ret    

008021cc <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8021cc:	55                   	push   %ebp
  8021cd:	89 e5                	mov    %esp,%ebp
  8021cf:	53                   	push   %ebx
  8021d0:	83 ec 04             	sub    $0x4,%esp
  8021d3:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8021d5:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  8021dc:	74 26                	je     802204 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8021de:	6a 07                	push   $0x7
  8021e0:	68 00 90 80 00       	push   $0x809000
  8021e5:	53                   	push   %ebx
  8021e6:	ff 35 04 60 80 00    	pushl  0x806004
  8021ec:	e8 86 06 00 00       	call   802877 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8021f1:	83 c4 0c             	add    $0xc,%esp
  8021f4:	6a 00                	push   $0x0
  8021f6:	6a 00                	push   $0x0
  8021f8:	6a 00                	push   $0x0
  8021fa:	e8 0b 06 00 00       	call   80280a <ipc_recv>
}
  8021ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802202:	c9                   	leave  
  802203:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802204:	83 ec 0c             	sub    $0xc,%esp
  802207:	6a 02                	push   $0x2
  802209:	e8 c1 06 00 00       	call   8028cf <ipc_find_env>
  80220e:	a3 04 60 80 00       	mov    %eax,0x806004
  802213:	83 c4 10             	add    $0x10,%esp
  802216:	eb c6                	jmp    8021de <nsipc+0x12>

00802218 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802218:	f3 0f 1e fb          	endbr32 
  80221c:	55                   	push   %ebp
  80221d:	89 e5                	mov    %esp,%ebp
  80221f:	56                   	push   %esi
  802220:	53                   	push   %ebx
  802221:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802224:	8b 45 08             	mov    0x8(%ebp),%eax
  802227:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80222c:	8b 06                	mov    (%esi),%eax
  80222e:	a3 04 90 80 00       	mov    %eax,0x809004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802233:	b8 01 00 00 00       	mov    $0x1,%eax
  802238:	e8 8f ff ff ff       	call   8021cc <nsipc>
  80223d:	89 c3                	mov    %eax,%ebx
  80223f:	85 c0                	test   %eax,%eax
  802241:	79 09                	jns    80224c <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  802243:	89 d8                	mov    %ebx,%eax
  802245:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802248:	5b                   	pop    %ebx
  802249:	5e                   	pop    %esi
  80224a:	5d                   	pop    %ebp
  80224b:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80224c:	83 ec 04             	sub    $0x4,%esp
  80224f:	ff 35 10 90 80 00    	pushl  0x809010
  802255:	68 00 90 80 00       	push   $0x809000
  80225a:	ff 75 0c             	pushl  0xc(%ebp)
  80225d:	e8 b5 ea ff ff       	call   800d17 <memmove>
		*addrlen = ret->ret_addrlen;
  802262:	a1 10 90 80 00       	mov    0x809010,%eax
  802267:	89 06                	mov    %eax,(%esi)
  802269:	83 c4 10             	add    $0x10,%esp
	return r;
  80226c:	eb d5                	jmp    802243 <nsipc_accept+0x2b>

0080226e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80226e:	f3 0f 1e fb          	endbr32 
  802272:	55                   	push   %ebp
  802273:	89 e5                	mov    %esp,%ebp
  802275:	53                   	push   %ebx
  802276:	83 ec 08             	sub    $0x8,%esp
  802279:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80227c:	8b 45 08             	mov    0x8(%ebp),%eax
  80227f:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802284:	53                   	push   %ebx
  802285:	ff 75 0c             	pushl  0xc(%ebp)
  802288:	68 04 90 80 00       	push   $0x809004
  80228d:	e8 85 ea ff ff       	call   800d17 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802292:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_BIND);
  802298:	b8 02 00 00 00       	mov    $0x2,%eax
  80229d:	e8 2a ff ff ff       	call   8021cc <nsipc>
}
  8022a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022a5:	c9                   	leave  
  8022a6:	c3                   	ret    

008022a7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8022a7:	f3 0f 1e fb          	endbr32 
  8022ab:	55                   	push   %ebp
  8022ac:	89 e5                	mov    %esp,%ebp
  8022ae:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8022b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b4:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.shutdown.req_how = how;
  8022b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022bc:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_SHUTDOWN);
  8022c1:	b8 03 00 00 00       	mov    $0x3,%eax
  8022c6:	e8 01 ff ff ff       	call   8021cc <nsipc>
}
  8022cb:	c9                   	leave  
  8022cc:	c3                   	ret    

008022cd <nsipc_close>:

int
nsipc_close(int s)
{
  8022cd:	f3 0f 1e fb          	endbr32 
  8022d1:	55                   	push   %ebp
  8022d2:	89 e5                	mov    %esp,%ebp
  8022d4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8022d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8022da:	a3 00 90 80 00       	mov    %eax,0x809000
	return nsipc(NSREQ_CLOSE);
  8022df:	b8 04 00 00 00       	mov    $0x4,%eax
  8022e4:	e8 e3 fe ff ff       	call   8021cc <nsipc>
}
  8022e9:	c9                   	leave  
  8022ea:	c3                   	ret    

008022eb <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8022eb:	f3 0f 1e fb          	endbr32 
  8022ef:	55                   	push   %ebp
  8022f0:	89 e5                	mov    %esp,%ebp
  8022f2:	53                   	push   %ebx
  8022f3:	83 ec 08             	sub    $0x8,%esp
  8022f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8022f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8022fc:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802301:	53                   	push   %ebx
  802302:	ff 75 0c             	pushl  0xc(%ebp)
  802305:	68 04 90 80 00       	push   $0x809004
  80230a:	e8 08 ea ff ff       	call   800d17 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80230f:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_CONNECT);
  802315:	b8 05 00 00 00       	mov    $0x5,%eax
  80231a:	e8 ad fe ff ff       	call   8021cc <nsipc>
}
  80231f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802322:	c9                   	leave  
  802323:	c3                   	ret    

00802324 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802324:	f3 0f 1e fb          	endbr32 
  802328:	55                   	push   %ebp
  802329:	89 e5                	mov    %esp,%ebp
  80232b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80232e:	8b 45 08             	mov    0x8(%ebp),%eax
  802331:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.listen.req_backlog = backlog;
  802336:	8b 45 0c             	mov    0xc(%ebp),%eax
  802339:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_LISTEN);
  80233e:	b8 06 00 00 00       	mov    $0x6,%eax
  802343:	e8 84 fe ff ff       	call   8021cc <nsipc>
}
  802348:	c9                   	leave  
  802349:	c3                   	ret    

0080234a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80234a:	f3 0f 1e fb          	endbr32 
  80234e:	55                   	push   %ebp
  80234f:	89 e5                	mov    %esp,%ebp
  802351:	56                   	push   %esi
  802352:	53                   	push   %ebx
  802353:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802356:	8b 45 08             	mov    0x8(%ebp),%eax
  802359:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.recv.req_len = len;
  80235e:	89 35 04 90 80 00    	mov    %esi,0x809004
	nsipcbuf.recv.req_flags = flags;
  802364:	8b 45 14             	mov    0x14(%ebp),%eax
  802367:	a3 08 90 80 00       	mov    %eax,0x809008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80236c:	b8 07 00 00 00       	mov    $0x7,%eax
  802371:	e8 56 fe ff ff       	call   8021cc <nsipc>
  802376:	89 c3                	mov    %eax,%ebx
  802378:	85 c0                	test   %eax,%eax
  80237a:	78 26                	js     8023a2 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  80237c:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  802382:	b8 3f 06 00 00       	mov    $0x63f,%eax
  802387:	0f 4e c6             	cmovle %esi,%eax
  80238a:	39 c3                	cmp    %eax,%ebx
  80238c:	7f 1d                	jg     8023ab <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80238e:	83 ec 04             	sub    $0x4,%esp
  802391:	53                   	push   %ebx
  802392:	68 00 90 80 00       	push   $0x809000
  802397:	ff 75 0c             	pushl  0xc(%ebp)
  80239a:	e8 78 e9 ff ff       	call   800d17 <memmove>
  80239f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8023a2:	89 d8                	mov    %ebx,%eax
  8023a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023a7:	5b                   	pop    %ebx
  8023a8:	5e                   	pop    %esi
  8023a9:	5d                   	pop    %ebp
  8023aa:	c3                   	ret    
		assert(r < 1600 && r <= len);
  8023ab:	68 22 32 80 00       	push   $0x803222
  8023b0:	68 d7 30 80 00       	push   $0x8030d7
  8023b5:	6a 62                	push   $0x62
  8023b7:	68 37 32 80 00       	push   $0x803237
  8023bc:	e8 67 e0 ff ff       	call   800428 <_panic>

008023c1 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8023c1:	f3 0f 1e fb          	endbr32 
  8023c5:	55                   	push   %ebp
  8023c6:	89 e5                	mov    %esp,%ebp
  8023c8:	53                   	push   %ebx
  8023c9:	83 ec 04             	sub    $0x4,%esp
  8023cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8023cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d2:	a3 00 90 80 00       	mov    %eax,0x809000
	assert(size < 1600);
  8023d7:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8023dd:	7f 2e                	jg     80240d <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8023df:	83 ec 04             	sub    $0x4,%esp
  8023e2:	53                   	push   %ebx
  8023e3:	ff 75 0c             	pushl  0xc(%ebp)
  8023e6:	68 0c 90 80 00       	push   $0x80900c
  8023eb:	e8 27 e9 ff ff       	call   800d17 <memmove>
	nsipcbuf.send.req_size = size;
  8023f0:	89 1d 04 90 80 00    	mov    %ebx,0x809004
	nsipcbuf.send.req_flags = flags;
  8023f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8023f9:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SEND);
  8023fe:	b8 08 00 00 00       	mov    $0x8,%eax
  802403:	e8 c4 fd ff ff       	call   8021cc <nsipc>
}
  802408:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80240b:	c9                   	leave  
  80240c:	c3                   	ret    
	assert(size < 1600);
  80240d:	68 43 32 80 00       	push   $0x803243
  802412:	68 d7 30 80 00       	push   $0x8030d7
  802417:	6a 6d                	push   $0x6d
  802419:	68 37 32 80 00       	push   $0x803237
  80241e:	e8 05 e0 ff ff       	call   800428 <_panic>

00802423 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802423:	f3 0f 1e fb          	endbr32 
  802427:	55                   	push   %ebp
  802428:	89 e5                	mov    %esp,%ebp
  80242a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80242d:	8b 45 08             	mov    0x8(%ebp),%eax
  802430:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.socket.req_type = type;
  802435:	8b 45 0c             	mov    0xc(%ebp),%eax
  802438:	a3 04 90 80 00       	mov    %eax,0x809004
	nsipcbuf.socket.req_protocol = protocol;
  80243d:	8b 45 10             	mov    0x10(%ebp),%eax
  802440:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SOCKET);
  802445:	b8 09 00 00 00       	mov    $0x9,%eax
  80244a:	e8 7d fd ff ff       	call   8021cc <nsipc>
}
  80244f:	c9                   	leave  
  802450:	c3                   	ret    

00802451 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802451:	f3 0f 1e fb          	endbr32 
  802455:	55                   	push   %ebp
  802456:	89 e5                	mov    %esp,%ebp
  802458:	56                   	push   %esi
  802459:	53                   	push   %ebx
  80245a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80245d:	83 ec 0c             	sub    $0xc,%esp
  802460:	ff 75 08             	pushl  0x8(%ebp)
  802463:	e8 c5 ec ff ff       	call   80112d <fd2data>
  802468:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80246a:	83 c4 08             	add    $0x8,%esp
  80246d:	68 4f 32 80 00       	push   $0x80324f
  802472:	53                   	push   %ebx
  802473:	e8 a1 e6 ff ff       	call   800b19 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802478:	8b 46 04             	mov    0x4(%esi),%eax
  80247b:	2b 06                	sub    (%esi),%eax
  80247d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802483:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80248a:	00 00 00 
	stat->st_dev = &devpipe;
  80248d:	c7 83 88 00 00 00 fc 	movl   $0x8057fc,0x88(%ebx)
  802494:	57 80 00 
	return 0;
}
  802497:	b8 00 00 00 00       	mov    $0x0,%eax
  80249c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80249f:	5b                   	pop    %ebx
  8024a0:	5e                   	pop    %esi
  8024a1:	5d                   	pop    %ebp
  8024a2:	c3                   	ret    

008024a3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8024a3:	f3 0f 1e fb          	endbr32 
  8024a7:	55                   	push   %ebp
  8024a8:	89 e5                	mov    %esp,%ebp
  8024aa:	53                   	push   %ebx
  8024ab:	83 ec 0c             	sub    $0xc,%esp
  8024ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8024b1:	53                   	push   %ebx
  8024b2:	6a 00                	push   $0x0
  8024b4:	e8 14 eb ff ff       	call   800fcd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8024b9:	89 1c 24             	mov    %ebx,(%esp)
  8024bc:	e8 6c ec ff ff       	call   80112d <fd2data>
  8024c1:	83 c4 08             	add    $0x8,%esp
  8024c4:	50                   	push   %eax
  8024c5:	6a 00                	push   $0x0
  8024c7:	e8 01 eb ff ff       	call   800fcd <sys_page_unmap>
}
  8024cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024cf:	c9                   	leave  
  8024d0:	c3                   	ret    

008024d1 <_pipeisclosed>:
{
  8024d1:	55                   	push   %ebp
  8024d2:	89 e5                	mov    %esp,%ebp
  8024d4:	57                   	push   %edi
  8024d5:	56                   	push   %esi
  8024d6:	53                   	push   %ebx
  8024d7:	83 ec 1c             	sub    $0x1c,%esp
  8024da:	89 c7                	mov    %eax,%edi
  8024dc:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8024de:	a1 90 77 80 00       	mov    0x807790,%eax
  8024e3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8024e6:	83 ec 0c             	sub    $0xc,%esp
  8024e9:	57                   	push   %edi
  8024ea:	e8 1d 04 00 00       	call   80290c <pageref>
  8024ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8024f2:	89 34 24             	mov    %esi,(%esp)
  8024f5:	e8 12 04 00 00       	call   80290c <pageref>
		nn = thisenv->env_runs;
  8024fa:	8b 15 90 77 80 00    	mov    0x807790,%edx
  802500:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802503:	83 c4 10             	add    $0x10,%esp
  802506:	39 cb                	cmp    %ecx,%ebx
  802508:	74 1b                	je     802525 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80250a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80250d:	75 cf                	jne    8024de <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80250f:	8b 42 58             	mov    0x58(%edx),%eax
  802512:	6a 01                	push   $0x1
  802514:	50                   	push   %eax
  802515:	53                   	push   %ebx
  802516:	68 56 32 80 00       	push   $0x803256
  80251b:	e8 ef df ff ff       	call   80050f <cprintf>
  802520:	83 c4 10             	add    $0x10,%esp
  802523:	eb b9                	jmp    8024de <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  802525:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802528:	0f 94 c0             	sete   %al
  80252b:	0f b6 c0             	movzbl %al,%eax
}
  80252e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802531:	5b                   	pop    %ebx
  802532:	5e                   	pop    %esi
  802533:	5f                   	pop    %edi
  802534:	5d                   	pop    %ebp
  802535:	c3                   	ret    

00802536 <devpipe_write>:
{
  802536:	f3 0f 1e fb          	endbr32 
  80253a:	55                   	push   %ebp
  80253b:	89 e5                	mov    %esp,%ebp
  80253d:	57                   	push   %edi
  80253e:	56                   	push   %esi
  80253f:	53                   	push   %ebx
  802540:	83 ec 28             	sub    $0x28,%esp
  802543:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802546:	56                   	push   %esi
  802547:	e8 e1 eb ff ff       	call   80112d <fd2data>
  80254c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80254e:	83 c4 10             	add    $0x10,%esp
  802551:	bf 00 00 00 00       	mov    $0x0,%edi
  802556:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802559:	74 4f                	je     8025aa <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80255b:	8b 43 04             	mov    0x4(%ebx),%eax
  80255e:	8b 0b                	mov    (%ebx),%ecx
  802560:	8d 51 20             	lea    0x20(%ecx),%edx
  802563:	39 d0                	cmp    %edx,%eax
  802565:	72 14                	jb     80257b <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  802567:	89 da                	mov    %ebx,%edx
  802569:	89 f0                	mov    %esi,%eax
  80256b:	e8 61 ff ff ff       	call   8024d1 <_pipeisclosed>
  802570:	85 c0                	test   %eax,%eax
  802572:	75 3b                	jne    8025af <devpipe_write+0x79>
			sys_yield();
  802574:	e8 e6 e9 ff ff       	call   800f5f <sys_yield>
  802579:	eb e0                	jmp    80255b <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80257b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80257e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802582:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802585:	89 c2                	mov    %eax,%edx
  802587:	c1 fa 1f             	sar    $0x1f,%edx
  80258a:	89 d1                	mov    %edx,%ecx
  80258c:	c1 e9 1b             	shr    $0x1b,%ecx
  80258f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802592:	83 e2 1f             	and    $0x1f,%edx
  802595:	29 ca                	sub    %ecx,%edx
  802597:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80259b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80259f:	83 c0 01             	add    $0x1,%eax
  8025a2:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8025a5:	83 c7 01             	add    $0x1,%edi
  8025a8:	eb ac                	jmp    802556 <devpipe_write+0x20>
	return i;
  8025aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8025ad:	eb 05                	jmp    8025b4 <devpipe_write+0x7e>
				return 0;
  8025af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8025b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025b7:	5b                   	pop    %ebx
  8025b8:	5e                   	pop    %esi
  8025b9:	5f                   	pop    %edi
  8025ba:	5d                   	pop    %ebp
  8025bb:	c3                   	ret    

008025bc <devpipe_read>:
{
  8025bc:	f3 0f 1e fb          	endbr32 
  8025c0:	55                   	push   %ebp
  8025c1:	89 e5                	mov    %esp,%ebp
  8025c3:	57                   	push   %edi
  8025c4:	56                   	push   %esi
  8025c5:	53                   	push   %ebx
  8025c6:	83 ec 18             	sub    $0x18,%esp
  8025c9:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8025cc:	57                   	push   %edi
  8025cd:	e8 5b eb ff ff       	call   80112d <fd2data>
  8025d2:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8025d4:	83 c4 10             	add    $0x10,%esp
  8025d7:	be 00 00 00 00       	mov    $0x0,%esi
  8025dc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8025df:	75 14                	jne    8025f5 <devpipe_read+0x39>
	return i;
  8025e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8025e4:	eb 02                	jmp    8025e8 <devpipe_read+0x2c>
				return i;
  8025e6:	89 f0                	mov    %esi,%eax
}
  8025e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025eb:	5b                   	pop    %ebx
  8025ec:	5e                   	pop    %esi
  8025ed:	5f                   	pop    %edi
  8025ee:	5d                   	pop    %ebp
  8025ef:	c3                   	ret    
			sys_yield();
  8025f0:	e8 6a e9 ff ff       	call   800f5f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8025f5:	8b 03                	mov    (%ebx),%eax
  8025f7:	3b 43 04             	cmp    0x4(%ebx),%eax
  8025fa:	75 18                	jne    802614 <devpipe_read+0x58>
			if (i > 0)
  8025fc:	85 f6                	test   %esi,%esi
  8025fe:	75 e6                	jne    8025e6 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  802600:	89 da                	mov    %ebx,%edx
  802602:	89 f8                	mov    %edi,%eax
  802604:	e8 c8 fe ff ff       	call   8024d1 <_pipeisclosed>
  802609:	85 c0                	test   %eax,%eax
  80260b:	74 e3                	je     8025f0 <devpipe_read+0x34>
				return 0;
  80260d:	b8 00 00 00 00       	mov    $0x0,%eax
  802612:	eb d4                	jmp    8025e8 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802614:	99                   	cltd   
  802615:	c1 ea 1b             	shr    $0x1b,%edx
  802618:	01 d0                	add    %edx,%eax
  80261a:	83 e0 1f             	and    $0x1f,%eax
  80261d:	29 d0                	sub    %edx,%eax
  80261f:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802624:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802627:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80262a:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80262d:	83 c6 01             	add    $0x1,%esi
  802630:	eb aa                	jmp    8025dc <devpipe_read+0x20>

00802632 <pipe>:
{
  802632:	f3 0f 1e fb          	endbr32 
  802636:	55                   	push   %ebp
  802637:	89 e5                	mov    %esp,%ebp
  802639:	56                   	push   %esi
  80263a:	53                   	push   %ebx
  80263b:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80263e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802641:	50                   	push   %eax
  802642:	e8 01 eb ff ff       	call   801148 <fd_alloc>
  802647:	89 c3                	mov    %eax,%ebx
  802649:	83 c4 10             	add    $0x10,%esp
  80264c:	85 c0                	test   %eax,%eax
  80264e:	0f 88 23 01 00 00    	js     802777 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802654:	83 ec 04             	sub    $0x4,%esp
  802657:	68 07 04 00 00       	push   $0x407
  80265c:	ff 75 f4             	pushl  -0xc(%ebp)
  80265f:	6a 00                	push   $0x0
  802661:	e8 1c e9 ff ff       	call   800f82 <sys_page_alloc>
  802666:	89 c3                	mov    %eax,%ebx
  802668:	83 c4 10             	add    $0x10,%esp
  80266b:	85 c0                	test   %eax,%eax
  80266d:	0f 88 04 01 00 00    	js     802777 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  802673:	83 ec 0c             	sub    $0xc,%esp
  802676:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802679:	50                   	push   %eax
  80267a:	e8 c9 ea ff ff       	call   801148 <fd_alloc>
  80267f:	89 c3                	mov    %eax,%ebx
  802681:	83 c4 10             	add    $0x10,%esp
  802684:	85 c0                	test   %eax,%eax
  802686:	0f 88 db 00 00 00    	js     802767 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80268c:	83 ec 04             	sub    $0x4,%esp
  80268f:	68 07 04 00 00       	push   $0x407
  802694:	ff 75 f0             	pushl  -0x10(%ebp)
  802697:	6a 00                	push   $0x0
  802699:	e8 e4 e8 ff ff       	call   800f82 <sys_page_alloc>
  80269e:	89 c3                	mov    %eax,%ebx
  8026a0:	83 c4 10             	add    $0x10,%esp
  8026a3:	85 c0                	test   %eax,%eax
  8026a5:	0f 88 bc 00 00 00    	js     802767 <pipe+0x135>
	va = fd2data(fd0);
  8026ab:	83 ec 0c             	sub    $0xc,%esp
  8026ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8026b1:	e8 77 ea ff ff       	call   80112d <fd2data>
  8026b6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026b8:	83 c4 0c             	add    $0xc,%esp
  8026bb:	68 07 04 00 00       	push   $0x407
  8026c0:	50                   	push   %eax
  8026c1:	6a 00                	push   $0x0
  8026c3:	e8 ba e8 ff ff       	call   800f82 <sys_page_alloc>
  8026c8:	89 c3                	mov    %eax,%ebx
  8026ca:	83 c4 10             	add    $0x10,%esp
  8026cd:	85 c0                	test   %eax,%eax
  8026cf:	0f 88 82 00 00 00    	js     802757 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026d5:	83 ec 0c             	sub    $0xc,%esp
  8026d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8026db:	e8 4d ea ff ff       	call   80112d <fd2data>
  8026e0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8026e7:	50                   	push   %eax
  8026e8:	6a 00                	push   $0x0
  8026ea:	56                   	push   %esi
  8026eb:	6a 00                	push   $0x0
  8026ed:	e8 b6 e8 ff ff       	call   800fa8 <sys_page_map>
  8026f2:	89 c3                	mov    %eax,%ebx
  8026f4:	83 c4 20             	add    $0x20,%esp
  8026f7:	85 c0                	test   %eax,%eax
  8026f9:	78 4e                	js     802749 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8026fb:	a1 fc 57 80 00       	mov    0x8057fc,%eax
  802700:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802703:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802705:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802708:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80270f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802712:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802714:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802717:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80271e:	83 ec 0c             	sub    $0xc,%esp
  802721:	ff 75 f4             	pushl  -0xc(%ebp)
  802724:	e8 f0 e9 ff ff       	call   801119 <fd2num>
  802729:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80272c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80272e:	83 c4 04             	add    $0x4,%esp
  802731:	ff 75 f0             	pushl  -0x10(%ebp)
  802734:	e8 e0 e9 ff ff       	call   801119 <fd2num>
  802739:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80273c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80273f:	83 c4 10             	add    $0x10,%esp
  802742:	bb 00 00 00 00       	mov    $0x0,%ebx
  802747:	eb 2e                	jmp    802777 <pipe+0x145>
	sys_page_unmap(0, va);
  802749:	83 ec 08             	sub    $0x8,%esp
  80274c:	56                   	push   %esi
  80274d:	6a 00                	push   $0x0
  80274f:	e8 79 e8 ff ff       	call   800fcd <sys_page_unmap>
  802754:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802757:	83 ec 08             	sub    $0x8,%esp
  80275a:	ff 75 f0             	pushl  -0x10(%ebp)
  80275d:	6a 00                	push   $0x0
  80275f:	e8 69 e8 ff ff       	call   800fcd <sys_page_unmap>
  802764:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802767:	83 ec 08             	sub    $0x8,%esp
  80276a:	ff 75 f4             	pushl  -0xc(%ebp)
  80276d:	6a 00                	push   $0x0
  80276f:	e8 59 e8 ff ff       	call   800fcd <sys_page_unmap>
  802774:	83 c4 10             	add    $0x10,%esp
}
  802777:	89 d8                	mov    %ebx,%eax
  802779:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80277c:	5b                   	pop    %ebx
  80277d:	5e                   	pop    %esi
  80277e:	5d                   	pop    %ebp
  80277f:	c3                   	ret    

00802780 <pipeisclosed>:
{
  802780:	f3 0f 1e fb          	endbr32 
  802784:	55                   	push   %ebp
  802785:	89 e5                	mov    %esp,%ebp
  802787:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80278a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80278d:	50                   	push   %eax
  80278e:	ff 75 08             	pushl  0x8(%ebp)
  802791:	e8 08 ea ff ff       	call   80119e <fd_lookup>
  802796:	83 c4 10             	add    $0x10,%esp
  802799:	85 c0                	test   %eax,%eax
  80279b:	78 18                	js     8027b5 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  80279d:	83 ec 0c             	sub    $0xc,%esp
  8027a0:	ff 75 f4             	pushl  -0xc(%ebp)
  8027a3:	e8 85 e9 ff ff       	call   80112d <fd2data>
  8027a8:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8027aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027ad:	e8 1f fd ff ff       	call   8024d1 <_pipeisclosed>
  8027b2:	83 c4 10             	add    $0x10,%esp
}
  8027b5:	c9                   	leave  
  8027b6:	c3                   	ret    

008027b7 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8027b7:	f3 0f 1e fb          	endbr32 
  8027bb:	55                   	push   %ebp
  8027bc:	89 e5                	mov    %esp,%ebp
  8027be:	56                   	push   %esi
  8027bf:	53                   	push   %ebx
  8027c0:	8b 75 08             	mov    0x8(%ebp),%esi
	// cprintf("[%08x] called wait for child %08x\n", thisenv->env_id, envid);
	const volatile struct Env *e;

	assert(envid != 0);
  8027c3:	85 f6                	test   %esi,%esi
  8027c5:	74 13                	je     8027da <wait+0x23>
	e = &envs[ENVX(envid)];
  8027c7:	89 f3                	mov    %esi,%ebx
  8027c9:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8027cf:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8027d2:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8027d8:	eb 1b                	jmp    8027f5 <wait+0x3e>
	assert(envid != 0);
  8027da:	68 6e 32 80 00       	push   $0x80326e
  8027df:	68 d7 30 80 00       	push   $0x8030d7
  8027e4:	6a 0a                	push   $0xa
  8027e6:	68 79 32 80 00       	push   $0x803279
  8027eb:	e8 38 dc ff ff       	call   800428 <_panic>
		sys_yield();
  8027f0:	e8 6a e7 ff ff       	call   800f5f <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8027f5:	8b 43 48             	mov    0x48(%ebx),%eax
  8027f8:	39 f0                	cmp    %esi,%eax
  8027fa:	75 07                	jne    802803 <wait+0x4c>
  8027fc:	8b 43 54             	mov    0x54(%ebx),%eax
  8027ff:	85 c0                	test   %eax,%eax
  802801:	75 ed                	jne    8027f0 <wait+0x39>
}
  802803:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802806:	5b                   	pop    %ebx
  802807:	5e                   	pop    %esi
  802808:	5d                   	pop    %ebp
  802809:	c3                   	ret    

0080280a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80280a:	f3 0f 1e fb          	endbr32 
  80280e:	55                   	push   %ebp
  80280f:	89 e5                	mov    %esp,%ebp
  802811:	56                   	push   %esi
  802812:	53                   	push   %ebx
  802813:	8b 75 08             	mov    0x8(%ebp),%esi
  802816:	8b 45 0c             	mov    0xc(%ebp),%eax
  802819:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  80281c:	85 c0                	test   %eax,%eax
  80281e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802823:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  802826:	83 ec 0c             	sub    $0xc,%esp
  802829:	50                   	push   %eax
  80282a:	e8 59 e8 ff ff       	call   801088 <sys_ipc_recv>
  80282f:	83 c4 10             	add    $0x10,%esp
  802832:	85 c0                	test   %eax,%eax
  802834:	75 2b                	jne    802861 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  802836:	85 f6                	test   %esi,%esi
  802838:	74 0a                	je     802844 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  80283a:	a1 90 77 80 00       	mov    0x807790,%eax
  80283f:	8b 40 74             	mov    0x74(%eax),%eax
  802842:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  802844:	85 db                	test   %ebx,%ebx
  802846:	74 0a                	je     802852 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  802848:	a1 90 77 80 00       	mov    0x807790,%eax
  80284d:	8b 40 78             	mov    0x78(%eax),%eax
  802850:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  802852:	a1 90 77 80 00       	mov    0x807790,%eax
  802857:	8b 40 70             	mov    0x70(%eax),%eax
}
  80285a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80285d:	5b                   	pop    %ebx
  80285e:	5e                   	pop    %esi
  80285f:	5d                   	pop    %ebp
  802860:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  802861:	85 f6                	test   %esi,%esi
  802863:	74 06                	je     80286b <ipc_recv+0x61>
  802865:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  80286b:	85 db                	test   %ebx,%ebx
  80286d:	74 eb                	je     80285a <ipc_recv+0x50>
  80286f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802875:	eb e3                	jmp    80285a <ipc_recv+0x50>

00802877 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802877:	f3 0f 1e fb          	endbr32 
  80287b:	55                   	push   %ebp
  80287c:	89 e5                	mov    %esp,%ebp
  80287e:	57                   	push   %edi
  80287f:	56                   	push   %esi
  802880:	53                   	push   %ebx
  802881:	83 ec 0c             	sub    $0xc,%esp
  802884:	8b 7d 08             	mov    0x8(%ebp),%edi
  802887:	8b 75 0c             	mov    0xc(%ebp),%esi
  80288a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  80288d:	85 db                	test   %ebx,%ebx
  80288f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802894:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802897:	ff 75 14             	pushl  0x14(%ebp)
  80289a:	53                   	push   %ebx
  80289b:	56                   	push   %esi
  80289c:	57                   	push   %edi
  80289d:	e8 bf e7 ff ff       	call   801061 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  8028a2:	83 c4 10             	add    $0x10,%esp
  8028a5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8028a8:	75 07                	jne    8028b1 <ipc_send+0x3a>
			sys_yield();
  8028aa:	e8 b0 e6 ff ff       	call   800f5f <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8028af:	eb e6                	jmp    802897 <ipc_send+0x20>
		}
		else if (ret == 0)
  8028b1:	85 c0                	test   %eax,%eax
  8028b3:	75 08                	jne    8028bd <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  8028b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8028b8:	5b                   	pop    %ebx
  8028b9:	5e                   	pop    %esi
  8028ba:	5f                   	pop    %edi
  8028bb:	5d                   	pop    %ebp
  8028bc:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  8028bd:	50                   	push   %eax
  8028be:	68 84 32 80 00       	push   $0x803284
  8028c3:	6a 48                	push   $0x48
  8028c5:	68 92 32 80 00       	push   $0x803292
  8028ca:	e8 59 db ff ff       	call   800428 <_panic>

008028cf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8028cf:	f3 0f 1e fb          	endbr32 
  8028d3:	55                   	push   %ebp
  8028d4:	89 e5                	mov    %esp,%ebp
  8028d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8028d9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8028de:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8028e1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8028e7:	8b 52 50             	mov    0x50(%edx),%edx
  8028ea:	39 ca                	cmp    %ecx,%edx
  8028ec:	74 11                	je     8028ff <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8028ee:	83 c0 01             	add    $0x1,%eax
  8028f1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8028f6:	75 e6                	jne    8028de <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8028f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8028fd:	eb 0b                	jmp    80290a <ipc_find_env+0x3b>
			return envs[i].env_id;
  8028ff:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802902:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802907:	8b 40 48             	mov    0x48(%eax),%eax
}
  80290a:	5d                   	pop    %ebp
  80290b:	c3                   	ret    

0080290c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80290c:	f3 0f 1e fb          	endbr32 
  802910:	55                   	push   %ebp
  802911:	89 e5                	mov    %esp,%ebp
  802913:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802916:	89 c2                	mov    %eax,%edx
  802918:	c1 ea 16             	shr    $0x16,%edx
  80291b:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802922:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802927:	f6 c1 01             	test   $0x1,%cl
  80292a:	74 1c                	je     802948 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  80292c:	c1 e8 0c             	shr    $0xc,%eax
  80292f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802936:	a8 01                	test   $0x1,%al
  802938:	74 0e                	je     802948 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80293a:	c1 e8 0c             	shr    $0xc,%eax
  80293d:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802944:	ef 
  802945:	0f b7 d2             	movzwl %dx,%edx
}
  802948:	89 d0                	mov    %edx,%eax
  80294a:	5d                   	pop    %ebp
  80294b:	c3                   	ret    
  80294c:	66 90                	xchg   %ax,%ax
  80294e:	66 90                	xchg   %ax,%ax

00802950 <__udivdi3>:
  802950:	f3 0f 1e fb          	endbr32 
  802954:	55                   	push   %ebp
  802955:	57                   	push   %edi
  802956:	56                   	push   %esi
  802957:	53                   	push   %ebx
  802958:	83 ec 1c             	sub    $0x1c,%esp
  80295b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80295f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802963:	8b 74 24 34          	mov    0x34(%esp),%esi
  802967:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80296b:	85 d2                	test   %edx,%edx
  80296d:	75 19                	jne    802988 <__udivdi3+0x38>
  80296f:	39 f3                	cmp    %esi,%ebx
  802971:	76 4d                	jbe    8029c0 <__udivdi3+0x70>
  802973:	31 ff                	xor    %edi,%edi
  802975:	89 e8                	mov    %ebp,%eax
  802977:	89 f2                	mov    %esi,%edx
  802979:	f7 f3                	div    %ebx
  80297b:	89 fa                	mov    %edi,%edx
  80297d:	83 c4 1c             	add    $0x1c,%esp
  802980:	5b                   	pop    %ebx
  802981:	5e                   	pop    %esi
  802982:	5f                   	pop    %edi
  802983:	5d                   	pop    %ebp
  802984:	c3                   	ret    
  802985:	8d 76 00             	lea    0x0(%esi),%esi
  802988:	39 f2                	cmp    %esi,%edx
  80298a:	76 14                	jbe    8029a0 <__udivdi3+0x50>
  80298c:	31 ff                	xor    %edi,%edi
  80298e:	31 c0                	xor    %eax,%eax
  802990:	89 fa                	mov    %edi,%edx
  802992:	83 c4 1c             	add    $0x1c,%esp
  802995:	5b                   	pop    %ebx
  802996:	5e                   	pop    %esi
  802997:	5f                   	pop    %edi
  802998:	5d                   	pop    %ebp
  802999:	c3                   	ret    
  80299a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8029a0:	0f bd fa             	bsr    %edx,%edi
  8029a3:	83 f7 1f             	xor    $0x1f,%edi
  8029a6:	75 48                	jne    8029f0 <__udivdi3+0xa0>
  8029a8:	39 f2                	cmp    %esi,%edx
  8029aa:	72 06                	jb     8029b2 <__udivdi3+0x62>
  8029ac:	31 c0                	xor    %eax,%eax
  8029ae:	39 eb                	cmp    %ebp,%ebx
  8029b0:	77 de                	ja     802990 <__udivdi3+0x40>
  8029b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8029b7:	eb d7                	jmp    802990 <__udivdi3+0x40>
  8029b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8029c0:	89 d9                	mov    %ebx,%ecx
  8029c2:	85 db                	test   %ebx,%ebx
  8029c4:	75 0b                	jne    8029d1 <__udivdi3+0x81>
  8029c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8029cb:	31 d2                	xor    %edx,%edx
  8029cd:	f7 f3                	div    %ebx
  8029cf:	89 c1                	mov    %eax,%ecx
  8029d1:	31 d2                	xor    %edx,%edx
  8029d3:	89 f0                	mov    %esi,%eax
  8029d5:	f7 f1                	div    %ecx
  8029d7:	89 c6                	mov    %eax,%esi
  8029d9:	89 e8                	mov    %ebp,%eax
  8029db:	89 f7                	mov    %esi,%edi
  8029dd:	f7 f1                	div    %ecx
  8029df:	89 fa                	mov    %edi,%edx
  8029e1:	83 c4 1c             	add    $0x1c,%esp
  8029e4:	5b                   	pop    %ebx
  8029e5:	5e                   	pop    %esi
  8029e6:	5f                   	pop    %edi
  8029e7:	5d                   	pop    %ebp
  8029e8:	c3                   	ret    
  8029e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8029f0:	89 f9                	mov    %edi,%ecx
  8029f2:	b8 20 00 00 00       	mov    $0x20,%eax
  8029f7:	29 f8                	sub    %edi,%eax
  8029f9:	d3 e2                	shl    %cl,%edx
  8029fb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8029ff:	89 c1                	mov    %eax,%ecx
  802a01:	89 da                	mov    %ebx,%edx
  802a03:	d3 ea                	shr    %cl,%edx
  802a05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802a09:	09 d1                	or     %edx,%ecx
  802a0b:	89 f2                	mov    %esi,%edx
  802a0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a11:	89 f9                	mov    %edi,%ecx
  802a13:	d3 e3                	shl    %cl,%ebx
  802a15:	89 c1                	mov    %eax,%ecx
  802a17:	d3 ea                	shr    %cl,%edx
  802a19:	89 f9                	mov    %edi,%ecx
  802a1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802a1f:	89 eb                	mov    %ebp,%ebx
  802a21:	d3 e6                	shl    %cl,%esi
  802a23:	89 c1                	mov    %eax,%ecx
  802a25:	d3 eb                	shr    %cl,%ebx
  802a27:	09 de                	or     %ebx,%esi
  802a29:	89 f0                	mov    %esi,%eax
  802a2b:	f7 74 24 08          	divl   0x8(%esp)
  802a2f:	89 d6                	mov    %edx,%esi
  802a31:	89 c3                	mov    %eax,%ebx
  802a33:	f7 64 24 0c          	mull   0xc(%esp)
  802a37:	39 d6                	cmp    %edx,%esi
  802a39:	72 15                	jb     802a50 <__udivdi3+0x100>
  802a3b:	89 f9                	mov    %edi,%ecx
  802a3d:	d3 e5                	shl    %cl,%ebp
  802a3f:	39 c5                	cmp    %eax,%ebp
  802a41:	73 04                	jae    802a47 <__udivdi3+0xf7>
  802a43:	39 d6                	cmp    %edx,%esi
  802a45:	74 09                	je     802a50 <__udivdi3+0x100>
  802a47:	89 d8                	mov    %ebx,%eax
  802a49:	31 ff                	xor    %edi,%edi
  802a4b:	e9 40 ff ff ff       	jmp    802990 <__udivdi3+0x40>
  802a50:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802a53:	31 ff                	xor    %edi,%edi
  802a55:	e9 36 ff ff ff       	jmp    802990 <__udivdi3+0x40>
  802a5a:	66 90                	xchg   %ax,%ax
  802a5c:	66 90                	xchg   %ax,%ax
  802a5e:	66 90                	xchg   %ax,%ax

00802a60 <__umoddi3>:
  802a60:	f3 0f 1e fb          	endbr32 
  802a64:	55                   	push   %ebp
  802a65:	57                   	push   %edi
  802a66:	56                   	push   %esi
  802a67:	53                   	push   %ebx
  802a68:	83 ec 1c             	sub    $0x1c,%esp
  802a6b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802a6f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802a73:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802a77:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802a7b:	85 c0                	test   %eax,%eax
  802a7d:	75 19                	jne    802a98 <__umoddi3+0x38>
  802a7f:	39 df                	cmp    %ebx,%edi
  802a81:	76 5d                	jbe    802ae0 <__umoddi3+0x80>
  802a83:	89 f0                	mov    %esi,%eax
  802a85:	89 da                	mov    %ebx,%edx
  802a87:	f7 f7                	div    %edi
  802a89:	89 d0                	mov    %edx,%eax
  802a8b:	31 d2                	xor    %edx,%edx
  802a8d:	83 c4 1c             	add    $0x1c,%esp
  802a90:	5b                   	pop    %ebx
  802a91:	5e                   	pop    %esi
  802a92:	5f                   	pop    %edi
  802a93:	5d                   	pop    %ebp
  802a94:	c3                   	ret    
  802a95:	8d 76 00             	lea    0x0(%esi),%esi
  802a98:	89 f2                	mov    %esi,%edx
  802a9a:	39 d8                	cmp    %ebx,%eax
  802a9c:	76 12                	jbe    802ab0 <__umoddi3+0x50>
  802a9e:	89 f0                	mov    %esi,%eax
  802aa0:	89 da                	mov    %ebx,%edx
  802aa2:	83 c4 1c             	add    $0x1c,%esp
  802aa5:	5b                   	pop    %ebx
  802aa6:	5e                   	pop    %esi
  802aa7:	5f                   	pop    %edi
  802aa8:	5d                   	pop    %ebp
  802aa9:	c3                   	ret    
  802aaa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802ab0:	0f bd e8             	bsr    %eax,%ebp
  802ab3:	83 f5 1f             	xor    $0x1f,%ebp
  802ab6:	75 50                	jne    802b08 <__umoddi3+0xa8>
  802ab8:	39 d8                	cmp    %ebx,%eax
  802aba:	0f 82 e0 00 00 00    	jb     802ba0 <__umoddi3+0x140>
  802ac0:	89 d9                	mov    %ebx,%ecx
  802ac2:	39 f7                	cmp    %esi,%edi
  802ac4:	0f 86 d6 00 00 00    	jbe    802ba0 <__umoddi3+0x140>
  802aca:	89 d0                	mov    %edx,%eax
  802acc:	89 ca                	mov    %ecx,%edx
  802ace:	83 c4 1c             	add    $0x1c,%esp
  802ad1:	5b                   	pop    %ebx
  802ad2:	5e                   	pop    %esi
  802ad3:	5f                   	pop    %edi
  802ad4:	5d                   	pop    %ebp
  802ad5:	c3                   	ret    
  802ad6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802add:	8d 76 00             	lea    0x0(%esi),%esi
  802ae0:	89 fd                	mov    %edi,%ebp
  802ae2:	85 ff                	test   %edi,%edi
  802ae4:	75 0b                	jne    802af1 <__umoddi3+0x91>
  802ae6:	b8 01 00 00 00       	mov    $0x1,%eax
  802aeb:	31 d2                	xor    %edx,%edx
  802aed:	f7 f7                	div    %edi
  802aef:	89 c5                	mov    %eax,%ebp
  802af1:	89 d8                	mov    %ebx,%eax
  802af3:	31 d2                	xor    %edx,%edx
  802af5:	f7 f5                	div    %ebp
  802af7:	89 f0                	mov    %esi,%eax
  802af9:	f7 f5                	div    %ebp
  802afb:	89 d0                	mov    %edx,%eax
  802afd:	31 d2                	xor    %edx,%edx
  802aff:	eb 8c                	jmp    802a8d <__umoddi3+0x2d>
  802b01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b08:	89 e9                	mov    %ebp,%ecx
  802b0a:	ba 20 00 00 00       	mov    $0x20,%edx
  802b0f:	29 ea                	sub    %ebp,%edx
  802b11:	d3 e0                	shl    %cl,%eax
  802b13:	89 44 24 08          	mov    %eax,0x8(%esp)
  802b17:	89 d1                	mov    %edx,%ecx
  802b19:	89 f8                	mov    %edi,%eax
  802b1b:	d3 e8                	shr    %cl,%eax
  802b1d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802b21:	89 54 24 04          	mov    %edx,0x4(%esp)
  802b25:	8b 54 24 04          	mov    0x4(%esp),%edx
  802b29:	09 c1                	or     %eax,%ecx
  802b2b:	89 d8                	mov    %ebx,%eax
  802b2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b31:	89 e9                	mov    %ebp,%ecx
  802b33:	d3 e7                	shl    %cl,%edi
  802b35:	89 d1                	mov    %edx,%ecx
  802b37:	d3 e8                	shr    %cl,%eax
  802b39:	89 e9                	mov    %ebp,%ecx
  802b3b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802b3f:	d3 e3                	shl    %cl,%ebx
  802b41:	89 c7                	mov    %eax,%edi
  802b43:	89 d1                	mov    %edx,%ecx
  802b45:	89 f0                	mov    %esi,%eax
  802b47:	d3 e8                	shr    %cl,%eax
  802b49:	89 e9                	mov    %ebp,%ecx
  802b4b:	89 fa                	mov    %edi,%edx
  802b4d:	d3 e6                	shl    %cl,%esi
  802b4f:	09 d8                	or     %ebx,%eax
  802b51:	f7 74 24 08          	divl   0x8(%esp)
  802b55:	89 d1                	mov    %edx,%ecx
  802b57:	89 f3                	mov    %esi,%ebx
  802b59:	f7 64 24 0c          	mull   0xc(%esp)
  802b5d:	89 c6                	mov    %eax,%esi
  802b5f:	89 d7                	mov    %edx,%edi
  802b61:	39 d1                	cmp    %edx,%ecx
  802b63:	72 06                	jb     802b6b <__umoddi3+0x10b>
  802b65:	75 10                	jne    802b77 <__umoddi3+0x117>
  802b67:	39 c3                	cmp    %eax,%ebx
  802b69:	73 0c                	jae    802b77 <__umoddi3+0x117>
  802b6b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  802b6f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802b73:	89 d7                	mov    %edx,%edi
  802b75:	89 c6                	mov    %eax,%esi
  802b77:	89 ca                	mov    %ecx,%edx
  802b79:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802b7e:	29 f3                	sub    %esi,%ebx
  802b80:	19 fa                	sbb    %edi,%edx
  802b82:	89 d0                	mov    %edx,%eax
  802b84:	d3 e0                	shl    %cl,%eax
  802b86:	89 e9                	mov    %ebp,%ecx
  802b88:	d3 eb                	shr    %cl,%ebx
  802b8a:	d3 ea                	shr    %cl,%edx
  802b8c:	09 d8                	or     %ebx,%eax
  802b8e:	83 c4 1c             	add    $0x1c,%esp
  802b91:	5b                   	pop    %ebx
  802b92:	5e                   	pop    %esi
  802b93:	5f                   	pop    %edi
  802b94:	5d                   	pop    %ebp
  802b95:	c3                   	ret    
  802b96:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b9d:	8d 76 00             	lea    0x0(%esi),%esi
  802ba0:	29 fe                	sub    %edi,%esi
  802ba2:	19 c3                	sbb    %eax,%ebx
  802ba4:	89 f2                	mov    %esi,%edx
  802ba6:	89 d9                	mov    %ebx,%ecx
  802ba8:	e9 1d ff ff ff       	jmp    802aca <__umoddi3+0x6a>
