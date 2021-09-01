
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 4d 02 00 00       	call   80027e <libmain>
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
  80003a:	53                   	push   %ebx
  80003b:	83 ec 04             	sub    $0x4,%esp
  80003e:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  800043:	e8 c9 0e 00 00       	call   800f11 <sys_yield>
	for (i = 0; i < 10; ++i)
  800048:	83 eb 01             	sub    $0x1,%ebx
  80004b:	75 f6                	jne    800043 <umain+0x10>

	close(0);
  80004d:	83 ec 0c             	sub    $0xc,%esp
  800050:	6a 00                	push   $0x0
  800052:	e8 37 12 00 00       	call   80128e <close>
	if ((r = opencons()) < 0)
  800057:	e8 cc 01 00 00       	call   800228 <opencons>
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	85 c0                	test   %eax,%eax
  800061:	78 14                	js     800077 <umain+0x44>
		panic("opencons: %e", r);
	if (r != 0)
  800063:	74 24                	je     800089 <umain+0x56>
		panic("first opencons used fd %d", r);
  800065:	50                   	push   %eax
  800066:	68 3c 26 80 00       	push   $0x80263c
  80006b:	6a 11                	push   $0x11
  80006d:	68 2d 26 80 00       	push   $0x80262d
  800072:	e8 6f 02 00 00       	call   8002e6 <_panic>
		panic("opencons: %e", r);
  800077:	50                   	push   %eax
  800078:	68 20 26 80 00       	push   $0x802620
  80007d:	6a 0f                	push   $0xf
  80007f:	68 2d 26 80 00       	push   $0x80262d
  800084:	e8 5d 02 00 00       	call   8002e6 <_panic>
	if ((r = dup(0, 1)) < 0)
  800089:	83 ec 08             	sub    $0x8,%esp
  80008c:	6a 01                	push   $0x1
  80008e:	6a 00                	push   $0x0
  800090:	e8 53 12 00 00       	call   8012e8 <dup>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	85 c0                	test   %eax,%eax
  80009a:	79 25                	jns    8000c1 <umain+0x8e>
		panic("dup: %e", r);
  80009c:	50                   	push   %eax
  80009d:	68 56 26 80 00       	push   $0x802656
  8000a2:	6a 13                	push   $0x13
  8000a4:	68 2d 26 80 00       	push   $0x80262d
  8000a9:	e8 38 02 00 00       	call   8002e6 <_panic>
	for(;;){
		char *buf;

		buf = readline("Type a line: ");
		if (buf != NULL)
			fprintf(1, "%s\n", buf);
  8000ae:	83 ec 04             	sub    $0x4,%esp
  8000b1:	50                   	push   %eax
  8000b2:	68 6c 26 80 00       	push   $0x80266c
  8000b7:	6a 01                	push   $0x1
  8000b9:	e8 51 19 00 00       	call   801a0f <fprintf>
  8000be:	83 c4 10             	add    $0x10,%esp
		buf = readline("Type a line: ");
  8000c1:	83 ec 0c             	sub    $0xc,%esp
  8000c4:	68 5e 26 80 00       	push   $0x80265e
  8000c9:	e8 c6 08 00 00       	call   800994 <readline>
		if (buf != NULL)
  8000ce:	83 c4 10             	add    $0x10,%esp
  8000d1:	85 c0                	test   %eax,%eax
  8000d3:	75 d9                	jne    8000ae <umain+0x7b>
		else
			fprintf(1, "(end of file received)\n");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 70 26 80 00       	push   $0x802670
  8000dd:	6a 01                	push   $0x1
  8000df:	e8 2b 19 00 00       	call   801a0f <fprintf>
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	eb d8                	jmp    8000c1 <umain+0x8e>

008000e9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8000e9:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  8000ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f2:	c3                   	ret    

008000f3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8000f3:	f3 0f 1e fb          	endbr32 
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8000fd:	68 88 26 80 00       	push   $0x802688
  800102:	ff 75 0c             	pushl  0xc(%ebp)
  800105:	e8 c1 09 00 00       	call   800acb <strcpy>
	return 0;
}
  80010a:	b8 00 00 00 00       	mov    $0x0,%eax
  80010f:	c9                   	leave  
  800110:	c3                   	ret    

00800111 <devcons_write>:
{
  800111:	f3 0f 1e fb          	endbr32 
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	57                   	push   %edi
  800119:	56                   	push   %esi
  80011a:	53                   	push   %ebx
  80011b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800121:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800126:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80012c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80012f:	73 31                	jae    800162 <devcons_write+0x51>
		m = n - tot;
  800131:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800134:	29 f3                	sub    %esi,%ebx
  800136:	83 fb 7f             	cmp    $0x7f,%ebx
  800139:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80013e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800141:	83 ec 04             	sub    $0x4,%esp
  800144:	53                   	push   %ebx
  800145:	89 f0                	mov    %esi,%eax
  800147:	03 45 0c             	add    0xc(%ebp),%eax
  80014a:	50                   	push   %eax
  80014b:	57                   	push   %edi
  80014c:	e8 78 0b 00 00       	call   800cc9 <memmove>
		sys_cputs(buf, m);
  800151:	83 c4 08             	add    $0x8,%esp
  800154:	53                   	push   %ebx
  800155:	57                   	push   %edi
  800156:	e8 2a 0d 00 00       	call   800e85 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80015b:	01 de                	add    %ebx,%esi
  80015d:	83 c4 10             	add    $0x10,%esp
  800160:	eb ca                	jmp    80012c <devcons_write+0x1b>
}
  800162:	89 f0                	mov    %esi,%eax
  800164:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800167:	5b                   	pop    %ebx
  800168:	5e                   	pop    %esi
  800169:	5f                   	pop    %edi
  80016a:	5d                   	pop    %ebp
  80016b:	c3                   	ret    

0080016c <devcons_read>:
{
  80016c:	f3 0f 1e fb          	endbr32 
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80017b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80017f:	74 21                	je     8001a2 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800181:	e8 21 0d 00 00       	call   800ea7 <sys_cgetc>
  800186:	85 c0                	test   %eax,%eax
  800188:	75 07                	jne    800191 <devcons_read+0x25>
		sys_yield();
  80018a:	e8 82 0d 00 00       	call   800f11 <sys_yield>
  80018f:	eb f0                	jmp    800181 <devcons_read+0x15>
	if (c < 0)
  800191:	78 0f                	js     8001a2 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800193:	83 f8 04             	cmp    $0x4,%eax
  800196:	74 0c                	je     8001a4 <devcons_read+0x38>
	*(char*)vbuf = c;
  800198:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019b:	88 02                	mov    %al,(%edx)
	return 1;
  80019d:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    
		return 0;
  8001a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001a9:	eb f7                	jmp    8001a2 <devcons_read+0x36>

008001ab <cputchar>:
{
  8001ab:	f3 0f 1e fb          	endbr32 
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8001bb:	6a 01                	push   $0x1
  8001bd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001c0:	50                   	push   %eax
  8001c1:	e8 bf 0c 00 00       	call   800e85 <sys_cputs>
}
  8001c6:	83 c4 10             	add    $0x10,%esp
  8001c9:	c9                   	leave  
  8001ca:	c3                   	ret    

008001cb <getchar>:
{
  8001cb:	f3 0f 1e fb          	endbr32 
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8001d5:	6a 01                	push   $0x1
  8001d7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001da:	50                   	push   %eax
  8001db:	6a 00                	push   $0x0
  8001dd:	e8 f6 11 00 00       	call   8013d8 <read>
	if (r < 0)
  8001e2:	83 c4 10             	add    $0x10,%esp
  8001e5:	85 c0                	test   %eax,%eax
  8001e7:	78 06                	js     8001ef <getchar+0x24>
	if (r < 1)
  8001e9:	74 06                	je     8001f1 <getchar+0x26>
	return c;
  8001eb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    
		return -E_EOF;
  8001f1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8001f6:	eb f7                	jmp    8001ef <getchar+0x24>

008001f8 <iscons>:
{
  8001f8:	f3 0f 1e fb          	endbr32 
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800202:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800205:	50                   	push   %eax
  800206:	ff 75 08             	pushl  0x8(%ebp)
  800209:	e8 42 0f 00 00       	call   801150 <fd_lookup>
  80020e:	83 c4 10             	add    $0x10,%esp
  800211:	85 c0                	test   %eax,%eax
  800213:	78 11                	js     800226 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  800215:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800218:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80021e:	39 10                	cmp    %edx,(%eax)
  800220:	0f 94 c0             	sete   %al
  800223:	0f b6 c0             	movzbl %al,%eax
}
  800226:	c9                   	leave  
  800227:	c3                   	ret    

00800228 <opencons>:
{
  800228:	f3 0f 1e fb          	endbr32 
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800232:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800235:	50                   	push   %eax
  800236:	e8 bf 0e 00 00       	call   8010fa <fd_alloc>
  80023b:	83 c4 10             	add    $0x10,%esp
  80023e:	85 c0                	test   %eax,%eax
  800240:	78 3a                	js     80027c <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800242:	83 ec 04             	sub    $0x4,%esp
  800245:	68 07 04 00 00       	push   $0x407
  80024a:	ff 75 f4             	pushl  -0xc(%ebp)
  80024d:	6a 00                	push   $0x0
  80024f:	e8 e0 0c 00 00       	call   800f34 <sys_page_alloc>
  800254:	83 c4 10             	add    $0x10,%esp
  800257:	85 c0                	test   %eax,%eax
  800259:	78 21                	js     80027c <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80025b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80025e:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800264:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800266:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800269:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	50                   	push   %eax
  800274:	e8 52 0e 00 00       	call   8010cb <fd2num>
  800279:	83 c4 10             	add    $0x10,%esp
}
  80027c:	c9                   	leave  
  80027d:	c3                   	ret    

0080027e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80027e:	f3 0f 1e fb          	endbr32 
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	56                   	push   %esi
  800286:	53                   	push   %ebx
  800287:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80028a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80028d:	e8 5c 0c 00 00       	call   800eee <sys_getenvid>
  800292:	25 ff 03 00 00       	and    $0x3ff,%eax
  800297:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80029a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80029f:	a3 08 44 80 00       	mov    %eax,0x804408
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002a4:	85 db                	test   %ebx,%ebx
  8002a6:	7e 07                	jle    8002af <libmain+0x31>
		binaryname = argv[0];
  8002a8:	8b 06                	mov    (%esi),%eax
  8002aa:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  8002af:	83 ec 08             	sub    $0x8,%esp
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	e8 7a fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002b9:	e8 0a 00 00 00       	call   8002c8 <exit>
}
  8002be:	83 c4 10             	add    $0x10,%esp
  8002c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c4:	5b                   	pop    %ebx
  8002c5:	5e                   	pop    %esi
  8002c6:	5d                   	pop    %ebp
  8002c7:	c3                   	ret    

008002c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002c8:	f3 0f 1e fb          	endbr32 
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  8002d2:	e8 e8 0f 00 00       	call   8012bf <close_all>
	sys_env_destroy(0);
  8002d7:	83 ec 0c             	sub    $0xc,%esp
  8002da:	6a 00                	push   $0x0
  8002dc:	e8 e9 0b 00 00       	call   800eca <sys_env_destroy>
}
  8002e1:	83 c4 10             	add    $0x10,%esp
  8002e4:	c9                   	leave  
  8002e5:	c3                   	ret    

008002e6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002e6:	f3 0f 1e fb          	endbr32 
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	56                   	push   %esi
  8002ee:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002ef:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002f2:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  8002f8:	e8 f1 0b 00 00       	call   800eee <sys_getenvid>
  8002fd:	83 ec 0c             	sub    $0xc,%esp
  800300:	ff 75 0c             	pushl  0xc(%ebp)
  800303:	ff 75 08             	pushl  0x8(%ebp)
  800306:	56                   	push   %esi
  800307:	50                   	push   %eax
  800308:	68 a0 26 80 00       	push   $0x8026a0
  80030d:	e8 bb 00 00 00       	call   8003cd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800312:	83 c4 18             	add    $0x18,%esp
  800315:	53                   	push   %ebx
  800316:	ff 75 10             	pushl  0x10(%ebp)
  800319:	e8 5a 00 00 00       	call   800378 <vcprintf>
	cprintf("\n");
  80031e:	c7 04 24 86 26 80 00 	movl   $0x802686,(%esp)
  800325:	e8 a3 00 00 00       	call   8003cd <cprintf>
  80032a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80032d:	cc                   	int3   
  80032e:	eb fd                	jmp    80032d <_panic+0x47>

00800330 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800330:	f3 0f 1e fb          	endbr32 
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	53                   	push   %ebx
  800338:	83 ec 04             	sub    $0x4,%esp
  80033b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80033e:	8b 13                	mov    (%ebx),%edx
  800340:	8d 42 01             	lea    0x1(%edx),%eax
  800343:	89 03                	mov    %eax,(%ebx)
  800345:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800348:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80034c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800351:	74 09                	je     80035c <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800353:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800357:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80035a:	c9                   	leave  
  80035b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80035c:	83 ec 08             	sub    $0x8,%esp
  80035f:	68 ff 00 00 00       	push   $0xff
  800364:	8d 43 08             	lea    0x8(%ebx),%eax
  800367:	50                   	push   %eax
  800368:	e8 18 0b 00 00       	call   800e85 <sys_cputs>
		b->idx = 0;
  80036d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800373:	83 c4 10             	add    $0x10,%esp
  800376:	eb db                	jmp    800353 <putch+0x23>

00800378 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800378:	f3 0f 1e fb          	endbr32 
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800385:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80038c:	00 00 00 
	b.cnt = 0;
  80038f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800396:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800399:	ff 75 0c             	pushl  0xc(%ebp)
  80039c:	ff 75 08             	pushl  0x8(%ebp)
  80039f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003a5:	50                   	push   %eax
  8003a6:	68 30 03 80 00       	push   $0x800330
  8003ab:	e8 20 01 00 00       	call   8004d0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003b0:	83 c4 08             	add    $0x8,%esp
  8003b3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003b9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003bf:	50                   	push   %eax
  8003c0:	e8 c0 0a 00 00       	call   800e85 <sys_cputs>

	return b.cnt;
}
  8003c5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003cb:	c9                   	leave  
  8003cc:	c3                   	ret    

008003cd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003cd:	f3 0f 1e fb          	endbr32 
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003d7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003da:	50                   	push   %eax
  8003db:	ff 75 08             	pushl  0x8(%ebp)
  8003de:	e8 95 ff ff ff       	call   800378 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003e3:	c9                   	leave  
  8003e4:	c3                   	ret    

008003e5 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	57                   	push   %edi
  8003e9:	56                   	push   %esi
  8003ea:	53                   	push   %ebx
  8003eb:	83 ec 1c             	sub    $0x1c,%esp
  8003ee:	89 c7                	mov    %eax,%edi
  8003f0:	89 d6                	mov    %edx,%esi
  8003f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f8:	89 d1                	mov    %edx,%ecx
  8003fa:	89 c2                	mov    %eax,%edx
  8003fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800402:	8b 45 10             	mov    0x10(%ebp),%eax
  800405:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800408:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80040b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800412:	39 c2                	cmp    %eax,%edx
  800414:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800417:	72 3e                	jb     800457 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800419:	83 ec 0c             	sub    $0xc,%esp
  80041c:	ff 75 18             	pushl  0x18(%ebp)
  80041f:	83 eb 01             	sub    $0x1,%ebx
  800422:	53                   	push   %ebx
  800423:	50                   	push   %eax
  800424:	83 ec 08             	sub    $0x8,%esp
  800427:	ff 75 e4             	pushl  -0x1c(%ebp)
  80042a:	ff 75 e0             	pushl  -0x20(%ebp)
  80042d:	ff 75 dc             	pushl  -0x24(%ebp)
  800430:	ff 75 d8             	pushl  -0x28(%ebp)
  800433:	e8 78 1f 00 00       	call   8023b0 <__udivdi3>
  800438:	83 c4 18             	add    $0x18,%esp
  80043b:	52                   	push   %edx
  80043c:	50                   	push   %eax
  80043d:	89 f2                	mov    %esi,%edx
  80043f:	89 f8                	mov    %edi,%eax
  800441:	e8 9f ff ff ff       	call   8003e5 <printnum>
  800446:	83 c4 20             	add    $0x20,%esp
  800449:	eb 13                	jmp    80045e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80044b:	83 ec 08             	sub    $0x8,%esp
  80044e:	56                   	push   %esi
  80044f:	ff 75 18             	pushl  0x18(%ebp)
  800452:	ff d7                	call   *%edi
  800454:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800457:	83 eb 01             	sub    $0x1,%ebx
  80045a:	85 db                	test   %ebx,%ebx
  80045c:	7f ed                	jg     80044b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80045e:	83 ec 08             	sub    $0x8,%esp
  800461:	56                   	push   %esi
  800462:	83 ec 04             	sub    $0x4,%esp
  800465:	ff 75 e4             	pushl  -0x1c(%ebp)
  800468:	ff 75 e0             	pushl  -0x20(%ebp)
  80046b:	ff 75 dc             	pushl  -0x24(%ebp)
  80046e:	ff 75 d8             	pushl  -0x28(%ebp)
  800471:	e8 4a 20 00 00       	call   8024c0 <__umoddi3>
  800476:	83 c4 14             	add    $0x14,%esp
  800479:	0f be 80 c3 26 80 00 	movsbl 0x8026c3(%eax),%eax
  800480:	50                   	push   %eax
  800481:	ff d7                	call   *%edi
}
  800483:	83 c4 10             	add    $0x10,%esp
  800486:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800489:	5b                   	pop    %ebx
  80048a:	5e                   	pop    %esi
  80048b:	5f                   	pop    %edi
  80048c:	5d                   	pop    %ebp
  80048d:	c3                   	ret    

0080048e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80048e:	f3 0f 1e fb          	endbr32 
  800492:	55                   	push   %ebp
  800493:	89 e5                	mov    %esp,%ebp
  800495:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800498:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80049c:	8b 10                	mov    (%eax),%edx
  80049e:	3b 50 04             	cmp    0x4(%eax),%edx
  8004a1:	73 0a                	jae    8004ad <sprintputch+0x1f>
		*b->buf++ = ch;
  8004a3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004a6:	89 08                	mov    %ecx,(%eax)
  8004a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ab:	88 02                	mov    %al,(%edx)
}
  8004ad:	5d                   	pop    %ebp
  8004ae:	c3                   	ret    

008004af <printfmt>:
{
  8004af:	f3 0f 1e fb          	endbr32 
  8004b3:	55                   	push   %ebp
  8004b4:	89 e5                	mov    %esp,%ebp
  8004b6:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004b9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004bc:	50                   	push   %eax
  8004bd:	ff 75 10             	pushl  0x10(%ebp)
  8004c0:	ff 75 0c             	pushl  0xc(%ebp)
  8004c3:	ff 75 08             	pushl  0x8(%ebp)
  8004c6:	e8 05 00 00 00       	call   8004d0 <vprintfmt>
}
  8004cb:	83 c4 10             	add    $0x10,%esp
  8004ce:	c9                   	leave  
  8004cf:	c3                   	ret    

008004d0 <vprintfmt>:
{
  8004d0:	f3 0f 1e fb          	endbr32 
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
  8004d7:	57                   	push   %edi
  8004d8:	56                   	push   %esi
  8004d9:	53                   	push   %ebx
  8004da:	83 ec 3c             	sub    $0x3c,%esp
  8004dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004e6:	e9 8e 03 00 00       	jmp    800879 <vprintfmt+0x3a9>
		padc = ' ';
  8004eb:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8004ef:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8004f6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8004fd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800504:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800509:	8d 47 01             	lea    0x1(%edi),%eax
  80050c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80050f:	0f b6 17             	movzbl (%edi),%edx
  800512:	8d 42 dd             	lea    -0x23(%edx),%eax
  800515:	3c 55                	cmp    $0x55,%al
  800517:	0f 87 df 03 00 00    	ja     8008fc <vprintfmt+0x42c>
  80051d:	0f b6 c0             	movzbl %al,%eax
  800520:	3e ff 24 85 00 28 80 	notrack jmp *0x802800(,%eax,4)
  800527:	00 
  800528:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80052b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80052f:	eb d8                	jmp    800509 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800531:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800534:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800538:	eb cf                	jmp    800509 <vprintfmt+0x39>
  80053a:	0f b6 d2             	movzbl %dl,%edx
  80053d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800540:	b8 00 00 00 00       	mov    $0x0,%eax
  800545:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800548:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80054b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80054f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800552:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800555:	83 f9 09             	cmp    $0x9,%ecx
  800558:	77 55                	ja     8005af <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80055a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  80055d:	eb e9                	jmp    800548 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8b 00                	mov    (%eax),%eax
  800564:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 40 04             	lea    0x4(%eax),%eax
  80056d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800570:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800573:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800577:	79 90                	jns    800509 <vprintfmt+0x39>
				width = precision, precision = -1;
  800579:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80057c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800586:	eb 81                	jmp    800509 <vprintfmt+0x39>
  800588:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80058b:	85 c0                	test   %eax,%eax
  80058d:	ba 00 00 00 00       	mov    $0x0,%edx
  800592:	0f 49 d0             	cmovns %eax,%edx
  800595:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800598:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80059b:	e9 69 ff ff ff       	jmp    800509 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005a3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005aa:	e9 5a ff ff ff       	jmp    800509 <vprintfmt+0x39>
  8005af:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b5:	eb bc                	jmp    800573 <vprintfmt+0xa3>
			lflag++;
  8005b7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005bd:	e9 47 ff ff ff       	jmp    800509 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 78 04             	lea    0x4(%eax),%edi
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	53                   	push   %ebx
  8005cc:	ff 30                	pushl  (%eax)
  8005ce:	ff d6                	call   *%esi
			break;
  8005d0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005d3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005d6:	e9 9b 02 00 00       	jmp    800876 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8d 78 04             	lea    0x4(%eax),%edi
  8005e1:	8b 00                	mov    (%eax),%eax
  8005e3:	99                   	cltd   
  8005e4:	31 d0                	xor    %edx,%eax
  8005e6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005e8:	83 f8 0f             	cmp    $0xf,%eax
  8005eb:	7f 23                	jg     800610 <vprintfmt+0x140>
  8005ed:	8b 14 85 60 29 80 00 	mov    0x802960(,%eax,4),%edx
  8005f4:	85 d2                	test   %edx,%edx
  8005f6:	74 18                	je     800610 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8005f8:	52                   	push   %edx
  8005f9:	68 79 2a 80 00       	push   $0x802a79
  8005fe:	53                   	push   %ebx
  8005ff:	56                   	push   %esi
  800600:	e8 aa fe ff ff       	call   8004af <printfmt>
  800605:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800608:	89 7d 14             	mov    %edi,0x14(%ebp)
  80060b:	e9 66 02 00 00       	jmp    800876 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800610:	50                   	push   %eax
  800611:	68 db 26 80 00       	push   $0x8026db
  800616:	53                   	push   %ebx
  800617:	56                   	push   %esi
  800618:	e8 92 fe ff ff       	call   8004af <printfmt>
  80061d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800620:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800623:	e9 4e 02 00 00       	jmp    800876 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	83 c0 04             	add    $0x4,%eax
  80062e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800636:	85 d2                	test   %edx,%edx
  800638:	b8 d4 26 80 00       	mov    $0x8026d4,%eax
  80063d:	0f 45 c2             	cmovne %edx,%eax
  800640:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800643:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800647:	7e 06                	jle    80064f <vprintfmt+0x17f>
  800649:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80064d:	75 0d                	jne    80065c <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80064f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800652:	89 c7                	mov    %eax,%edi
  800654:	03 45 e0             	add    -0x20(%ebp),%eax
  800657:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80065a:	eb 55                	jmp    8006b1 <vprintfmt+0x1e1>
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	ff 75 d8             	pushl  -0x28(%ebp)
  800662:	ff 75 cc             	pushl  -0x34(%ebp)
  800665:	e8 3a 04 00 00       	call   800aa4 <strnlen>
  80066a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80066d:	29 c2                	sub    %eax,%edx
  80066f:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800672:	83 c4 10             	add    $0x10,%esp
  800675:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800677:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80067b:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80067e:	85 ff                	test   %edi,%edi
  800680:	7e 11                	jle    800693 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800682:	83 ec 08             	sub    $0x8,%esp
  800685:	53                   	push   %ebx
  800686:	ff 75 e0             	pushl  -0x20(%ebp)
  800689:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80068b:	83 ef 01             	sub    $0x1,%edi
  80068e:	83 c4 10             	add    $0x10,%esp
  800691:	eb eb                	jmp    80067e <vprintfmt+0x1ae>
  800693:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800696:	85 d2                	test   %edx,%edx
  800698:	b8 00 00 00 00       	mov    $0x0,%eax
  80069d:	0f 49 c2             	cmovns %edx,%eax
  8006a0:	29 c2                	sub    %eax,%edx
  8006a2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006a5:	eb a8                	jmp    80064f <vprintfmt+0x17f>
					putch(ch, putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	52                   	push   %edx
  8006ac:	ff d6                	call   *%esi
  8006ae:	83 c4 10             	add    $0x10,%esp
  8006b1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006b4:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b6:	83 c7 01             	add    $0x1,%edi
  8006b9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006bd:	0f be d0             	movsbl %al,%edx
  8006c0:	85 d2                	test   %edx,%edx
  8006c2:	74 4b                	je     80070f <vprintfmt+0x23f>
  8006c4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006c8:	78 06                	js     8006d0 <vprintfmt+0x200>
  8006ca:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8006ce:	78 1e                	js     8006ee <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  8006d0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006d4:	74 d1                	je     8006a7 <vprintfmt+0x1d7>
  8006d6:	0f be c0             	movsbl %al,%eax
  8006d9:	83 e8 20             	sub    $0x20,%eax
  8006dc:	83 f8 5e             	cmp    $0x5e,%eax
  8006df:	76 c6                	jbe    8006a7 <vprintfmt+0x1d7>
					putch('?', putdat);
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	53                   	push   %ebx
  8006e5:	6a 3f                	push   $0x3f
  8006e7:	ff d6                	call   *%esi
  8006e9:	83 c4 10             	add    $0x10,%esp
  8006ec:	eb c3                	jmp    8006b1 <vprintfmt+0x1e1>
  8006ee:	89 cf                	mov    %ecx,%edi
  8006f0:	eb 0e                	jmp    800700 <vprintfmt+0x230>
				putch(' ', putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	6a 20                	push   $0x20
  8006f8:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8006fa:	83 ef 01             	sub    $0x1,%edi
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	85 ff                	test   %edi,%edi
  800702:	7f ee                	jg     8006f2 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800704:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800707:	89 45 14             	mov    %eax,0x14(%ebp)
  80070a:	e9 67 01 00 00       	jmp    800876 <vprintfmt+0x3a6>
  80070f:	89 cf                	mov    %ecx,%edi
  800711:	eb ed                	jmp    800700 <vprintfmt+0x230>
	if (lflag >= 2)
  800713:	83 f9 01             	cmp    $0x1,%ecx
  800716:	7f 1b                	jg     800733 <vprintfmt+0x263>
	else if (lflag)
  800718:	85 c9                	test   %ecx,%ecx
  80071a:	74 63                	je     80077f <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8b 00                	mov    (%eax),%eax
  800721:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800724:	99                   	cltd   
  800725:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800728:	8b 45 14             	mov    0x14(%ebp),%eax
  80072b:	8d 40 04             	lea    0x4(%eax),%eax
  80072e:	89 45 14             	mov    %eax,0x14(%ebp)
  800731:	eb 17                	jmp    80074a <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800733:	8b 45 14             	mov    0x14(%ebp),%eax
  800736:	8b 50 04             	mov    0x4(%eax),%edx
  800739:	8b 00                	mov    (%eax),%eax
  80073b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80073e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800741:	8b 45 14             	mov    0x14(%ebp),%eax
  800744:	8d 40 08             	lea    0x8(%eax),%eax
  800747:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80074a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80074d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800750:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800755:	85 c9                	test   %ecx,%ecx
  800757:	0f 89 ff 00 00 00    	jns    80085c <vprintfmt+0x38c>
				putch('-', putdat);
  80075d:	83 ec 08             	sub    $0x8,%esp
  800760:	53                   	push   %ebx
  800761:	6a 2d                	push   $0x2d
  800763:	ff d6                	call   *%esi
				num = -(long long) num;
  800765:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800768:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80076b:	f7 da                	neg    %edx
  80076d:	83 d1 00             	adc    $0x0,%ecx
  800770:	f7 d9                	neg    %ecx
  800772:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800775:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077a:	e9 dd 00 00 00       	jmp    80085c <vprintfmt+0x38c>
		return va_arg(*ap, int);
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	8b 00                	mov    (%eax),%eax
  800784:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800787:	99                   	cltd   
  800788:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80078b:	8b 45 14             	mov    0x14(%ebp),%eax
  80078e:	8d 40 04             	lea    0x4(%eax),%eax
  800791:	89 45 14             	mov    %eax,0x14(%ebp)
  800794:	eb b4                	jmp    80074a <vprintfmt+0x27a>
	if (lflag >= 2)
  800796:	83 f9 01             	cmp    $0x1,%ecx
  800799:	7f 1e                	jg     8007b9 <vprintfmt+0x2e9>
	else if (lflag)
  80079b:	85 c9                	test   %ecx,%ecx
  80079d:	74 32                	je     8007d1 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  80079f:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a2:	8b 10                	mov    (%eax),%edx
  8007a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007a9:	8d 40 04             	lea    0x4(%eax),%eax
  8007ac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007af:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8007b4:	e9 a3 00 00 00       	jmp    80085c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8007b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bc:	8b 10                	mov    (%eax),%edx
  8007be:	8b 48 04             	mov    0x4(%eax),%ecx
  8007c1:	8d 40 08             	lea    0x8(%eax),%eax
  8007c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007c7:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8007cc:	e9 8b 00 00 00       	jmp    80085c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8007d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d4:	8b 10                	mov    (%eax),%edx
  8007d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007db:	8d 40 04             	lea    0x4(%eax),%eax
  8007de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007e1:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8007e6:	eb 74                	jmp    80085c <vprintfmt+0x38c>
	if (lflag >= 2)
  8007e8:	83 f9 01             	cmp    $0x1,%ecx
  8007eb:	7f 1b                	jg     800808 <vprintfmt+0x338>
	else if (lflag)
  8007ed:	85 c9                	test   %ecx,%ecx
  8007ef:	74 2c                	je     80081d <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  8007f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f4:	8b 10                	mov    (%eax),%edx
  8007f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fb:	8d 40 04             	lea    0x4(%eax),%eax
  8007fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800801:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800806:	eb 54                	jmp    80085c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800808:	8b 45 14             	mov    0x14(%ebp),%eax
  80080b:	8b 10                	mov    (%eax),%edx
  80080d:	8b 48 04             	mov    0x4(%eax),%ecx
  800810:	8d 40 08             	lea    0x8(%eax),%eax
  800813:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800816:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  80081b:	eb 3f                	jmp    80085c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80081d:	8b 45 14             	mov    0x14(%ebp),%eax
  800820:	8b 10                	mov    (%eax),%edx
  800822:	b9 00 00 00 00       	mov    $0x0,%ecx
  800827:	8d 40 04             	lea    0x4(%eax),%eax
  80082a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80082d:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800832:	eb 28                	jmp    80085c <vprintfmt+0x38c>
			putch('0', putdat);
  800834:	83 ec 08             	sub    $0x8,%esp
  800837:	53                   	push   %ebx
  800838:	6a 30                	push   $0x30
  80083a:	ff d6                	call   *%esi
			putch('x', putdat);
  80083c:	83 c4 08             	add    $0x8,%esp
  80083f:	53                   	push   %ebx
  800840:	6a 78                	push   $0x78
  800842:	ff d6                	call   *%esi
			num = (unsigned long long)
  800844:	8b 45 14             	mov    0x14(%ebp),%eax
  800847:	8b 10                	mov    (%eax),%edx
  800849:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80084e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800851:	8d 40 04             	lea    0x4(%eax),%eax
  800854:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800857:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80085c:	83 ec 0c             	sub    $0xc,%esp
  80085f:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800863:	57                   	push   %edi
  800864:	ff 75 e0             	pushl  -0x20(%ebp)
  800867:	50                   	push   %eax
  800868:	51                   	push   %ecx
  800869:	52                   	push   %edx
  80086a:	89 da                	mov    %ebx,%edx
  80086c:	89 f0                	mov    %esi,%eax
  80086e:	e8 72 fb ff ff       	call   8003e5 <printnum>
			break;
  800873:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800876:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  800879:	83 c7 01             	add    $0x1,%edi
  80087c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800880:	83 f8 25             	cmp    $0x25,%eax
  800883:	0f 84 62 fc ff ff    	je     8004eb <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  800889:	85 c0                	test   %eax,%eax
  80088b:	0f 84 8b 00 00 00    	je     80091c <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  800891:	83 ec 08             	sub    $0x8,%esp
  800894:	53                   	push   %ebx
  800895:	50                   	push   %eax
  800896:	ff d6                	call   *%esi
  800898:	83 c4 10             	add    $0x10,%esp
  80089b:	eb dc                	jmp    800879 <vprintfmt+0x3a9>
	if (lflag >= 2)
  80089d:	83 f9 01             	cmp    $0x1,%ecx
  8008a0:	7f 1b                	jg     8008bd <vprintfmt+0x3ed>
	else if (lflag)
  8008a2:	85 c9                	test   %ecx,%ecx
  8008a4:	74 2c                	je     8008d2 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  8008a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a9:	8b 10                	mov    (%eax),%edx
  8008ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b0:	8d 40 04             	lea    0x4(%eax),%eax
  8008b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008b6:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8008bb:	eb 9f                	jmp    80085c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8008bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c0:	8b 10                	mov    (%eax),%edx
  8008c2:	8b 48 04             	mov    0x4(%eax),%ecx
  8008c5:	8d 40 08             	lea    0x8(%eax),%eax
  8008c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008cb:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8008d0:	eb 8a                	jmp    80085c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8008d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d5:	8b 10                	mov    (%eax),%edx
  8008d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008dc:	8d 40 04             	lea    0x4(%eax),%eax
  8008df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008e2:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8008e7:	e9 70 ff ff ff       	jmp    80085c <vprintfmt+0x38c>
			putch(ch, putdat);
  8008ec:	83 ec 08             	sub    $0x8,%esp
  8008ef:	53                   	push   %ebx
  8008f0:	6a 25                	push   $0x25
  8008f2:	ff d6                	call   *%esi
			break;
  8008f4:	83 c4 10             	add    $0x10,%esp
  8008f7:	e9 7a ff ff ff       	jmp    800876 <vprintfmt+0x3a6>
			putch('%', putdat);
  8008fc:	83 ec 08             	sub    $0x8,%esp
  8008ff:	53                   	push   %ebx
  800900:	6a 25                	push   $0x25
  800902:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800904:	83 c4 10             	add    $0x10,%esp
  800907:	89 f8                	mov    %edi,%eax
  800909:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80090d:	74 05                	je     800914 <vprintfmt+0x444>
  80090f:	83 e8 01             	sub    $0x1,%eax
  800912:	eb f5                	jmp    800909 <vprintfmt+0x439>
  800914:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800917:	e9 5a ff ff ff       	jmp    800876 <vprintfmt+0x3a6>
}
  80091c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80091f:	5b                   	pop    %ebx
  800920:	5e                   	pop    %esi
  800921:	5f                   	pop    %edi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800924:	f3 0f 1e fb          	endbr32 
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	83 ec 18             	sub    $0x18,%esp
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800934:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800937:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80093b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80093e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800945:	85 c0                	test   %eax,%eax
  800947:	74 26                	je     80096f <vsnprintf+0x4b>
  800949:	85 d2                	test   %edx,%edx
  80094b:	7e 22                	jle    80096f <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80094d:	ff 75 14             	pushl  0x14(%ebp)
  800950:	ff 75 10             	pushl  0x10(%ebp)
  800953:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800956:	50                   	push   %eax
  800957:	68 8e 04 80 00       	push   $0x80048e
  80095c:	e8 6f fb ff ff       	call   8004d0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800961:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800964:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800967:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096a:	83 c4 10             	add    $0x10,%esp
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    
		return -E_INVAL;
  80096f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800974:	eb f7                	jmp    80096d <vsnprintf+0x49>

00800976 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800976:	f3 0f 1e fb          	endbr32 
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  800980:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800983:	50                   	push   %eax
  800984:	ff 75 10             	pushl  0x10(%ebp)
  800987:	ff 75 0c             	pushl  0xc(%ebp)
  80098a:	ff 75 08             	pushl  0x8(%ebp)
  80098d:	e8 92 ff ff ff       	call   800924 <vsnprintf>
	va_end(ap);

	return rc;
}
  800992:	c9                   	leave  
  800993:	c3                   	ret    

00800994 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800994:	f3 0f 1e fb          	endbr32 
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	57                   	push   %edi
  80099c:	56                   	push   %esi
  80099d:	53                   	push   %ebx
  80099e:	83 ec 0c             	sub    $0xc,%esp
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8009a4:	85 c0                	test   %eax,%eax
  8009a6:	74 13                	je     8009bb <readline+0x27>
		fprintf(1, "%s", prompt);
  8009a8:	83 ec 04             	sub    $0x4,%esp
  8009ab:	50                   	push   %eax
  8009ac:	68 79 2a 80 00       	push   $0x802a79
  8009b1:	6a 01                	push   $0x1
  8009b3:	e8 57 10 00 00       	call   801a0f <fprintf>
  8009b8:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  8009bb:	83 ec 0c             	sub    $0xc,%esp
  8009be:	6a 00                	push   $0x0
  8009c0:	e8 33 f8 ff ff       	call   8001f8 <iscons>
  8009c5:	89 c7                	mov    %eax,%edi
  8009c7:	83 c4 10             	add    $0x10,%esp
	i = 0;
  8009ca:	be 00 00 00 00       	mov    $0x0,%esi
  8009cf:	eb 57                	jmp    800a28 <readline+0x94>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
  8009d6:	83 fb f8             	cmp    $0xfffffff8,%ebx
  8009d9:	75 08                	jne    8009e3 <readline+0x4f>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  8009db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009de:	5b                   	pop    %ebx
  8009df:	5e                   	pop    %esi
  8009e0:	5f                   	pop    %edi
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    
				cprintf("read error: %e\n", c);
  8009e3:	83 ec 08             	sub    $0x8,%esp
  8009e6:	53                   	push   %ebx
  8009e7:	68 bf 29 80 00       	push   $0x8029bf
  8009ec:	e8 dc f9 ff ff       	call   8003cd <cprintf>
  8009f1:	83 c4 10             	add    $0x10,%esp
			return NULL;
  8009f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f9:	eb e0                	jmp    8009db <readline+0x47>
			if (echoing)
  8009fb:	85 ff                	test   %edi,%edi
  8009fd:	75 05                	jne    800a04 <readline+0x70>
			i--;
  8009ff:	83 ee 01             	sub    $0x1,%esi
  800a02:	eb 24                	jmp    800a28 <readline+0x94>
				cputchar('\b');
  800a04:	83 ec 0c             	sub    $0xc,%esp
  800a07:	6a 08                	push   $0x8
  800a09:	e8 9d f7 ff ff       	call   8001ab <cputchar>
  800a0e:	83 c4 10             	add    $0x10,%esp
  800a11:	eb ec                	jmp    8009ff <readline+0x6b>
				cputchar(c);
  800a13:	83 ec 0c             	sub    $0xc,%esp
  800a16:	53                   	push   %ebx
  800a17:	e8 8f f7 ff ff       	call   8001ab <cputchar>
  800a1c:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  800a1f:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  800a25:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
  800a28:	e8 9e f7 ff ff       	call   8001cb <getchar>
  800a2d:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  800a2f:	85 c0                	test   %eax,%eax
  800a31:	78 9e                	js     8009d1 <readline+0x3d>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  800a33:	83 f8 08             	cmp    $0x8,%eax
  800a36:	0f 94 c2             	sete   %dl
  800a39:	83 f8 7f             	cmp    $0x7f,%eax
  800a3c:	0f 94 c0             	sete   %al
  800a3f:	08 c2                	or     %al,%dl
  800a41:	74 04                	je     800a47 <readline+0xb3>
  800a43:	85 f6                	test   %esi,%esi
  800a45:	7f b4                	jg     8009fb <readline+0x67>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800a47:	83 fb 1f             	cmp    $0x1f,%ebx
  800a4a:	7e 0e                	jle    800a5a <readline+0xc6>
  800a4c:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  800a52:	7f 06                	jg     800a5a <readline+0xc6>
			if (echoing)
  800a54:	85 ff                	test   %edi,%edi
  800a56:	74 c7                	je     800a1f <readline+0x8b>
  800a58:	eb b9                	jmp    800a13 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
  800a5a:	83 fb 0a             	cmp    $0xa,%ebx
  800a5d:	74 05                	je     800a64 <readline+0xd0>
  800a5f:	83 fb 0d             	cmp    $0xd,%ebx
  800a62:	75 c4                	jne    800a28 <readline+0x94>
			if (echoing)
  800a64:	85 ff                	test   %edi,%edi
  800a66:	75 11                	jne    800a79 <readline+0xe5>
			buf[i] = 0;
  800a68:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  800a6f:	b8 00 40 80 00       	mov    $0x804000,%eax
  800a74:	e9 62 ff ff ff       	jmp    8009db <readline+0x47>
				cputchar('\n');
  800a79:	83 ec 0c             	sub    $0xc,%esp
  800a7c:	6a 0a                	push   $0xa
  800a7e:	e8 28 f7 ff ff       	call   8001ab <cputchar>
  800a83:	83 c4 10             	add    $0x10,%esp
  800a86:	eb e0                	jmp    800a68 <readline+0xd4>

00800a88 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a88:	f3 0f 1e fb          	endbr32 
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
  800a97:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a9b:	74 05                	je     800aa2 <strlen+0x1a>
		n++;
  800a9d:	83 c0 01             	add    $0x1,%eax
  800aa0:	eb f5                	jmp    800a97 <strlen+0xf>
	return n;
}
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800aa4:	f3 0f 1e fb          	endbr32 
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aae:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ab1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab6:	39 d0                	cmp    %edx,%eax
  800ab8:	74 0d                	je     800ac7 <strnlen+0x23>
  800aba:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800abe:	74 05                	je     800ac5 <strnlen+0x21>
		n++;
  800ac0:	83 c0 01             	add    $0x1,%eax
  800ac3:	eb f1                	jmp    800ab6 <strnlen+0x12>
  800ac5:	89 c2                	mov    %eax,%edx
	return n;
}
  800ac7:	89 d0                	mov    %edx,%eax
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800acb:	f3 0f 1e fb          	endbr32 
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	53                   	push   %ebx
  800ad3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ade:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800ae2:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800ae5:	83 c0 01             	add    $0x1,%eax
  800ae8:	84 d2                	test   %dl,%dl
  800aea:	75 f2                	jne    800ade <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800aec:	89 c8                	mov    %ecx,%eax
  800aee:	5b                   	pop    %ebx
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800af1:	f3 0f 1e fb          	endbr32 
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	53                   	push   %ebx
  800af9:	83 ec 10             	sub    $0x10,%esp
  800afc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aff:	53                   	push   %ebx
  800b00:	e8 83 ff ff ff       	call   800a88 <strlen>
  800b05:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800b08:	ff 75 0c             	pushl  0xc(%ebp)
  800b0b:	01 d8                	add    %ebx,%eax
  800b0d:	50                   	push   %eax
  800b0e:	e8 b8 ff ff ff       	call   800acb <strcpy>
	return dst;
}
  800b13:	89 d8                	mov    %ebx,%eax
  800b15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b18:	c9                   	leave  
  800b19:	c3                   	ret    

00800b1a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b1a:	f3 0f 1e fb          	endbr32 
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
  800b23:	8b 75 08             	mov    0x8(%ebp),%esi
  800b26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b29:	89 f3                	mov    %esi,%ebx
  800b2b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b2e:	89 f0                	mov    %esi,%eax
  800b30:	39 d8                	cmp    %ebx,%eax
  800b32:	74 11                	je     800b45 <strncpy+0x2b>
		*dst++ = *src;
  800b34:	83 c0 01             	add    $0x1,%eax
  800b37:	0f b6 0a             	movzbl (%edx),%ecx
  800b3a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b3d:	80 f9 01             	cmp    $0x1,%cl
  800b40:	83 da ff             	sbb    $0xffffffff,%edx
  800b43:	eb eb                	jmp    800b30 <strncpy+0x16>
	}
	return ret;
}
  800b45:	89 f0                	mov    %esi,%eax
  800b47:	5b                   	pop    %ebx
  800b48:	5e                   	pop    %esi
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b4b:	f3 0f 1e fb          	endbr32 
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	8b 75 08             	mov    0x8(%ebp),%esi
  800b57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5a:	8b 55 10             	mov    0x10(%ebp),%edx
  800b5d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b5f:	85 d2                	test   %edx,%edx
  800b61:	74 21                	je     800b84 <strlcpy+0x39>
  800b63:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b67:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b69:	39 c2                	cmp    %eax,%edx
  800b6b:	74 14                	je     800b81 <strlcpy+0x36>
  800b6d:	0f b6 19             	movzbl (%ecx),%ebx
  800b70:	84 db                	test   %bl,%bl
  800b72:	74 0b                	je     800b7f <strlcpy+0x34>
			*dst++ = *src++;
  800b74:	83 c1 01             	add    $0x1,%ecx
  800b77:	83 c2 01             	add    $0x1,%edx
  800b7a:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b7d:	eb ea                	jmp    800b69 <strlcpy+0x1e>
  800b7f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b81:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b84:	29 f0                	sub    %esi,%eax
}
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b8a:	f3 0f 1e fb          	endbr32 
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b94:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b97:	0f b6 01             	movzbl (%ecx),%eax
  800b9a:	84 c0                	test   %al,%al
  800b9c:	74 0c                	je     800baa <strcmp+0x20>
  800b9e:	3a 02                	cmp    (%edx),%al
  800ba0:	75 08                	jne    800baa <strcmp+0x20>
		p++, q++;
  800ba2:	83 c1 01             	add    $0x1,%ecx
  800ba5:	83 c2 01             	add    $0x1,%edx
  800ba8:	eb ed                	jmp    800b97 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800baa:	0f b6 c0             	movzbl %al,%eax
  800bad:	0f b6 12             	movzbl (%edx),%edx
  800bb0:	29 d0                	sub    %edx,%eax
}
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bb4:	f3 0f 1e fb          	endbr32 
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	53                   	push   %ebx
  800bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bc2:	89 c3                	mov    %eax,%ebx
  800bc4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800bc7:	eb 06                	jmp    800bcf <strncmp+0x1b>
		n--, p++, q++;
  800bc9:	83 c0 01             	add    $0x1,%eax
  800bcc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800bcf:	39 d8                	cmp    %ebx,%eax
  800bd1:	74 16                	je     800be9 <strncmp+0x35>
  800bd3:	0f b6 08             	movzbl (%eax),%ecx
  800bd6:	84 c9                	test   %cl,%cl
  800bd8:	74 04                	je     800bde <strncmp+0x2a>
  800bda:	3a 0a                	cmp    (%edx),%cl
  800bdc:	74 eb                	je     800bc9 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bde:	0f b6 00             	movzbl (%eax),%eax
  800be1:	0f b6 12             	movzbl (%edx),%edx
  800be4:	29 d0                	sub    %edx,%eax
}
  800be6:	5b                   	pop    %ebx
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    
		return 0;
  800be9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bee:	eb f6                	jmp    800be6 <strncmp+0x32>

00800bf0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bf0:	f3 0f 1e fb          	endbr32 
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bfe:	0f b6 10             	movzbl (%eax),%edx
  800c01:	84 d2                	test   %dl,%dl
  800c03:	74 09                	je     800c0e <strchr+0x1e>
		if (*s == c)
  800c05:	38 ca                	cmp    %cl,%dl
  800c07:	74 0a                	je     800c13 <strchr+0x23>
	for (; *s; s++)
  800c09:	83 c0 01             	add    $0x1,%eax
  800c0c:	eb f0                	jmp    800bfe <strchr+0xe>
			return (char *) s;
	return 0;
  800c0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800c15:	f3 0f 1e fb          	endbr32 
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800c1f:	6a 78                	push   $0x78
  800c21:	ff 75 08             	pushl  0x8(%ebp)
  800c24:	e8 c7 ff ff ff       	call   800bf0 <strchr>
  800c29:	83 c4 10             	add    $0x10,%esp
  800c2c:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  800c2f:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800c34:	eb 0d                	jmp    800c43 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800c36:	c1 e0 04             	shl    $0x4,%eax
  800c39:	0f be d2             	movsbl %dl,%edx
  800c3c:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800c40:	83 c1 01             	add    $0x1,%ecx
  800c43:	0f b6 11             	movzbl (%ecx),%edx
  800c46:	84 d2                	test   %dl,%dl
  800c48:	74 11                	je     800c5b <atox+0x46>
		if (*p>='a'){
  800c4a:	80 fa 60             	cmp    $0x60,%dl
  800c4d:	7e e7                	jle    800c36 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800c4f:	c1 e0 04             	shl    $0x4,%eax
  800c52:	0f be d2             	movsbl %dl,%edx
  800c55:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800c59:	eb e5                	jmp    800c40 <atox+0x2b>
	}

	return v;

}
  800c5b:	c9                   	leave  
  800c5c:	c3                   	ret    

00800c5d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c5d:	f3 0f 1e fb          	endbr32 
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	8b 45 08             	mov    0x8(%ebp),%eax
  800c67:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c6b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c6e:	38 ca                	cmp    %cl,%dl
  800c70:	74 09                	je     800c7b <strfind+0x1e>
  800c72:	84 d2                	test   %dl,%dl
  800c74:	74 05                	je     800c7b <strfind+0x1e>
	for (; *s; s++)
  800c76:	83 c0 01             	add    $0x1,%eax
  800c79:	eb f0                	jmp    800c6b <strfind+0xe>
			break;
	return (char *) s;
}
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c7d:	f3 0f 1e fb          	endbr32 
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c8d:	85 c9                	test   %ecx,%ecx
  800c8f:	74 31                	je     800cc2 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c91:	89 f8                	mov    %edi,%eax
  800c93:	09 c8                	or     %ecx,%eax
  800c95:	a8 03                	test   $0x3,%al
  800c97:	75 23                	jne    800cbc <memset+0x3f>
		c &= 0xFF;
  800c99:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c9d:	89 d3                	mov    %edx,%ebx
  800c9f:	c1 e3 08             	shl    $0x8,%ebx
  800ca2:	89 d0                	mov    %edx,%eax
  800ca4:	c1 e0 18             	shl    $0x18,%eax
  800ca7:	89 d6                	mov    %edx,%esi
  800ca9:	c1 e6 10             	shl    $0x10,%esi
  800cac:	09 f0                	or     %esi,%eax
  800cae:	09 c2                	or     %eax,%edx
  800cb0:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800cb2:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800cb5:	89 d0                	mov    %edx,%eax
  800cb7:	fc                   	cld    
  800cb8:	f3 ab                	rep stos %eax,%es:(%edi)
  800cba:	eb 06                	jmp    800cc2 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cbf:	fc                   	cld    
  800cc0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cc2:	89 f8                	mov    %edi,%eax
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cc9:	f3 0f 1e fb          	endbr32 
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cdb:	39 c6                	cmp    %eax,%esi
  800cdd:	73 32                	jae    800d11 <memmove+0x48>
  800cdf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ce2:	39 c2                	cmp    %eax,%edx
  800ce4:	76 2b                	jbe    800d11 <memmove+0x48>
		s += n;
		d += n;
  800ce6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ce9:	89 fe                	mov    %edi,%esi
  800ceb:	09 ce                	or     %ecx,%esi
  800ced:	09 d6                	or     %edx,%esi
  800cef:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cf5:	75 0e                	jne    800d05 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800cf7:	83 ef 04             	sub    $0x4,%edi
  800cfa:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cfd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d00:	fd                   	std    
  800d01:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d03:	eb 09                	jmp    800d0e <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d05:	83 ef 01             	sub    $0x1,%edi
  800d08:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d0b:	fd                   	std    
  800d0c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d0e:	fc                   	cld    
  800d0f:	eb 1a                	jmp    800d2b <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d11:	89 c2                	mov    %eax,%edx
  800d13:	09 ca                	or     %ecx,%edx
  800d15:	09 f2                	or     %esi,%edx
  800d17:	f6 c2 03             	test   $0x3,%dl
  800d1a:	75 0a                	jne    800d26 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d1c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d1f:	89 c7                	mov    %eax,%edi
  800d21:	fc                   	cld    
  800d22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d24:	eb 05                	jmp    800d2b <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800d26:	89 c7                	mov    %eax,%edi
  800d28:	fc                   	cld    
  800d29:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d2b:	5e                   	pop    %esi
  800d2c:	5f                   	pop    %edi
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    

00800d2f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d2f:	f3 0f 1e fb          	endbr32 
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d39:	ff 75 10             	pushl  0x10(%ebp)
  800d3c:	ff 75 0c             	pushl  0xc(%ebp)
  800d3f:	ff 75 08             	pushl  0x8(%ebp)
  800d42:	e8 82 ff ff ff       	call   800cc9 <memmove>
}
  800d47:	c9                   	leave  
  800d48:	c3                   	ret    

00800d49 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d49:	f3 0f 1e fb          	endbr32 
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
  800d52:	8b 45 08             	mov    0x8(%ebp),%eax
  800d55:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d58:	89 c6                	mov    %eax,%esi
  800d5a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d5d:	39 f0                	cmp    %esi,%eax
  800d5f:	74 1c                	je     800d7d <memcmp+0x34>
		if (*s1 != *s2)
  800d61:	0f b6 08             	movzbl (%eax),%ecx
  800d64:	0f b6 1a             	movzbl (%edx),%ebx
  800d67:	38 d9                	cmp    %bl,%cl
  800d69:	75 08                	jne    800d73 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800d6b:	83 c0 01             	add    $0x1,%eax
  800d6e:	83 c2 01             	add    $0x1,%edx
  800d71:	eb ea                	jmp    800d5d <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800d73:	0f b6 c1             	movzbl %cl,%eax
  800d76:	0f b6 db             	movzbl %bl,%ebx
  800d79:	29 d8                	sub    %ebx,%eax
  800d7b:	eb 05                	jmp    800d82 <memcmp+0x39>
	}

	return 0;
  800d7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d86:	f3 0f 1e fb          	endbr32 
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d93:	89 c2                	mov    %eax,%edx
  800d95:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d98:	39 d0                	cmp    %edx,%eax
  800d9a:	73 09                	jae    800da5 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d9c:	38 08                	cmp    %cl,(%eax)
  800d9e:	74 05                	je     800da5 <memfind+0x1f>
	for (; s < ends; s++)
  800da0:	83 c0 01             	add    $0x1,%eax
  800da3:	eb f3                	jmp    800d98 <memfind+0x12>
			break;
	return (void *) s;
}
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800da7:	f3 0f 1e fb          	endbr32 
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
  800db1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db7:	eb 03                	jmp    800dbc <strtol+0x15>
		s++;
  800db9:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800dbc:	0f b6 01             	movzbl (%ecx),%eax
  800dbf:	3c 20                	cmp    $0x20,%al
  800dc1:	74 f6                	je     800db9 <strtol+0x12>
  800dc3:	3c 09                	cmp    $0x9,%al
  800dc5:	74 f2                	je     800db9 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800dc7:	3c 2b                	cmp    $0x2b,%al
  800dc9:	74 2a                	je     800df5 <strtol+0x4e>
	int neg = 0;
  800dcb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800dd0:	3c 2d                	cmp    $0x2d,%al
  800dd2:	74 2b                	je     800dff <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dd4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dda:	75 0f                	jne    800deb <strtol+0x44>
  800ddc:	80 39 30             	cmpb   $0x30,(%ecx)
  800ddf:	74 28                	je     800e09 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800de1:	85 db                	test   %ebx,%ebx
  800de3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800de8:	0f 44 d8             	cmove  %eax,%ebx
  800deb:	b8 00 00 00 00       	mov    $0x0,%eax
  800df0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800df3:	eb 46                	jmp    800e3b <strtol+0x94>
		s++;
  800df5:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800df8:	bf 00 00 00 00       	mov    $0x0,%edi
  800dfd:	eb d5                	jmp    800dd4 <strtol+0x2d>
		s++, neg = 1;
  800dff:	83 c1 01             	add    $0x1,%ecx
  800e02:	bf 01 00 00 00       	mov    $0x1,%edi
  800e07:	eb cb                	jmp    800dd4 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e09:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e0d:	74 0e                	je     800e1d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800e0f:	85 db                	test   %ebx,%ebx
  800e11:	75 d8                	jne    800deb <strtol+0x44>
		s++, base = 8;
  800e13:	83 c1 01             	add    $0x1,%ecx
  800e16:	bb 08 00 00 00       	mov    $0x8,%ebx
  800e1b:	eb ce                	jmp    800deb <strtol+0x44>
		s += 2, base = 16;
  800e1d:	83 c1 02             	add    $0x2,%ecx
  800e20:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e25:	eb c4                	jmp    800deb <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800e27:	0f be d2             	movsbl %dl,%edx
  800e2a:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e2d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e30:	7d 3a                	jge    800e6c <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800e32:	83 c1 01             	add    $0x1,%ecx
  800e35:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e39:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800e3b:	0f b6 11             	movzbl (%ecx),%edx
  800e3e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e41:	89 f3                	mov    %esi,%ebx
  800e43:	80 fb 09             	cmp    $0x9,%bl
  800e46:	76 df                	jbe    800e27 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800e48:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e4b:	89 f3                	mov    %esi,%ebx
  800e4d:	80 fb 19             	cmp    $0x19,%bl
  800e50:	77 08                	ja     800e5a <strtol+0xb3>
			dig = *s - 'a' + 10;
  800e52:	0f be d2             	movsbl %dl,%edx
  800e55:	83 ea 57             	sub    $0x57,%edx
  800e58:	eb d3                	jmp    800e2d <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800e5a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e5d:	89 f3                	mov    %esi,%ebx
  800e5f:	80 fb 19             	cmp    $0x19,%bl
  800e62:	77 08                	ja     800e6c <strtol+0xc5>
			dig = *s - 'A' + 10;
  800e64:	0f be d2             	movsbl %dl,%edx
  800e67:	83 ea 37             	sub    $0x37,%edx
  800e6a:	eb c1                	jmp    800e2d <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800e6c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e70:	74 05                	je     800e77 <strtol+0xd0>
		*endptr = (char *) s;
  800e72:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e75:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800e77:	89 c2                	mov    %eax,%edx
  800e79:	f7 da                	neg    %edx
  800e7b:	85 ff                	test   %edi,%edi
  800e7d:	0f 45 c2             	cmovne %edx,%eax
}
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e85:	f3 0f 1e fb          	endbr32 
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e94:	8b 55 08             	mov    0x8(%ebp),%edx
  800e97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9a:	89 c3                	mov    %eax,%ebx
  800e9c:	89 c7                	mov    %eax,%edi
  800e9e:	89 c6                	mov    %eax,%esi
  800ea0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ea7:	f3 0f 1e fb          	endbr32 
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	57                   	push   %edi
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebb:	89 d1                	mov    %edx,%ecx
  800ebd:	89 d3                	mov    %edx,%ebx
  800ebf:	89 d7                	mov    %edx,%edi
  800ec1:	89 d6                	mov    %edx,%esi
  800ec3:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ec5:	5b                   	pop    %ebx
  800ec6:	5e                   	pop    %esi
  800ec7:	5f                   	pop    %edi
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800eca:	f3 0f 1e fb          	endbr32 
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	57                   	push   %edi
  800ed2:	56                   	push   %esi
  800ed3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ed4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	b8 03 00 00 00       	mov    $0x3,%eax
  800ee1:	89 cb                	mov    %ecx,%ebx
  800ee3:	89 cf                	mov    %ecx,%edi
  800ee5:	89 ce                	mov    %ecx,%esi
  800ee7:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ee9:	5b                   	pop    %ebx
  800eea:	5e                   	pop    %esi
  800eeb:	5f                   	pop    %edi
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    

00800eee <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800eee:	f3 0f 1e fb          	endbr32 
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	57                   	push   %edi
  800ef6:	56                   	push   %esi
  800ef7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ef8:	ba 00 00 00 00       	mov    $0x0,%edx
  800efd:	b8 02 00 00 00       	mov    $0x2,%eax
  800f02:	89 d1                	mov    %edx,%ecx
  800f04:	89 d3                	mov    %edx,%ebx
  800f06:	89 d7                	mov    %edx,%edi
  800f08:	89 d6                	mov    %edx,%esi
  800f0a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f0c:	5b                   	pop    %ebx
  800f0d:	5e                   	pop    %esi
  800f0e:	5f                   	pop    %edi
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    

00800f11 <sys_yield>:

void
sys_yield(void)
{
  800f11:	f3 0f 1e fb          	endbr32 
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	57                   	push   %edi
  800f19:	56                   	push   %esi
  800f1a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f20:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f25:	89 d1                	mov    %edx,%ecx
  800f27:	89 d3                	mov    %edx,%ebx
  800f29:	89 d7                	mov    %edx,%edi
  800f2b:	89 d6                	mov    %edx,%esi
  800f2d:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f2f:	5b                   	pop    %ebx
  800f30:	5e                   	pop    %esi
  800f31:	5f                   	pop    %edi
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    

00800f34 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f34:	f3 0f 1e fb          	endbr32 
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	57                   	push   %edi
  800f3c:	56                   	push   %esi
  800f3d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f3e:	be 00 00 00 00       	mov    $0x0,%esi
  800f43:	8b 55 08             	mov    0x8(%ebp),%edx
  800f46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f49:	b8 04 00 00 00       	mov    $0x4,%eax
  800f4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f51:	89 f7                	mov    %esi,%edi
  800f53:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f55:	5b                   	pop    %ebx
  800f56:	5e                   	pop    %esi
  800f57:	5f                   	pop    %edi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    

00800f5a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f5a:	f3 0f 1e fb          	endbr32 
  800f5e:	55                   	push   %ebp
  800f5f:	89 e5                	mov    %esp,%ebp
  800f61:	57                   	push   %edi
  800f62:	56                   	push   %esi
  800f63:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f64:	8b 55 08             	mov    0x8(%ebp),%edx
  800f67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f6a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f72:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f75:	8b 75 18             	mov    0x18(%ebp),%esi
  800f78:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f7a:	5b                   	pop    %ebx
  800f7b:	5e                   	pop    %esi
  800f7c:	5f                   	pop    %edi
  800f7d:	5d                   	pop    %ebp
  800f7e:	c3                   	ret    

00800f7f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f7f:	f3 0f 1e fb          	endbr32 
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	57                   	push   %edi
  800f87:	56                   	push   %esi
  800f88:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f94:	b8 06 00 00 00       	mov    $0x6,%eax
  800f99:	89 df                	mov    %ebx,%edi
  800f9b:	89 de                	mov    %ebx,%esi
  800f9d:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f9f:	5b                   	pop    %ebx
  800fa0:	5e                   	pop    %esi
  800fa1:	5f                   	pop    %edi
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    

00800fa4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fa4:	f3 0f 1e fb          	endbr32 
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	57                   	push   %edi
  800fac:	56                   	push   %esi
  800fad:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb9:	b8 08 00 00 00       	mov    $0x8,%eax
  800fbe:	89 df                	mov    %ebx,%edi
  800fc0:	89 de                	mov    %ebx,%esi
  800fc2:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fc4:	5b                   	pop    %ebx
  800fc5:	5e                   	pop    %esi
  800fc6:	5f                   	pop    %edi
  800fc7:	5d                   	pop    %ebp
  800fc8:	c3                   	ret    

00800fc9 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fc9:	f3 0f 1e fb          	endbr32 
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	57                   	push   %edi
  800fd1:	56                   	push   %esi
  800fd2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fde:	b8 09 00 00 00       	mov    $0x9,%eax
  800fe3:	89 df                	mov    %ebx,%edi
  800fe5:	89 de                	mov    %ebx,%esi
  800fe7:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fe9:	5b                   	pop    %ebx
  800fea:	5e                   	pop    %esi
  800feb:	5f                   	pop    %edi
  800fec:	5d                   	pop    %ebp
  800fed:	c3                   	ret    

00800fee <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fee:	f3 0f 1e fb          	endbr32 
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	57                   	push   %edi
  800ff6:	56                   	push   %esi
  800ff7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ff8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ffd:	8b 55 08             	mov    0x8(%ebp),%edx
  801000:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801003:	b8 0a 00 00 00       	mov    $0xa,%eax
  801008:	89 df                	mov    %ebx,%edi
  80100a:	89 de                	mov    %ebx,%esi
  80100c:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80100e:	5b                   	pop    %ebx
  80100f:	5e                   	pop    %esi
  801010:	5f                   	pop    %edi
  801011:	5d                   	pop    %ebp
  801012:	c3                   	ret    

00801013 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801013:	f3 0f 1e fb          	endbr32 
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	57                   	push   %edi
  80101b:	56                   	push   %esi
  80101c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80101d:	8b 55 08             	mov    0x8(%ebp),%edx
  801020:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801023:	b8 0c 00 00 00       	mov    $0xc,%eax
  801028:	be 00 00 00 00       	mov    $0x0,%esi
  80102d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801030:	8b 7d 14             	mov    0x14(%ebp),%edi
  801033:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801035:	5b                   	pop    %ebx
  801036:	5e                   	pop    %esi
  801037:	5f                   	pop    %edi
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    

0080103a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80103a:	f3 0f 1e fb          	endbr32 
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	57                   	push   %edi
  801042:	56                   	push   %esi
  801043:	53                   	push   %ebx
	asm volatile("int %1\n"
  801044:	b9 00 00 00 00       	mov    $0x0,%ecx
  801049:	8b 55 08             	mov    0x8(%ebp),%edx
  80104c:	b8 0d 00 00 00       	mov    $0xd,%eax
  801051:	89 cb                	mov    %ecx,%ebx
  801053:	89 cf                	mov    %ecx,%edi
  801055:	89 ce                	mov    %ecx,%esi
  801057:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801059:	5b                   	pop    %ebx
  80105a:	5e                   	pop    %esi
  80105b:	5f                   	pop    %edi
  80105c:	5d                   	pop    %ebp
  80105d:	c3                   	ret    

0080105e <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80105e:	f3 0f 1e fb          	endbr32 
  801062:	55                   	push   %ebp
  801063:	89 e5                	mov    %esp,%ebp
  801065:	57                   	push   %edi
  801066:	56                   	push   %esi
  801067:	53                   	push   %ebx
	asm volatile("int %1\n"
  801068:	ba 00 00 00 00       	mov    $0x0,%edx
  80106d:	b8 0e 00 00 00       	mov    $0xe,%eax
  801072:	89 d1                	mov    %edx,%ecx
  801074:	89 d3                	mov    %edx,%ebx
  801076:	89 d7                	mov    %edx,%edi
  801078:	89 d6                	mov    %edx,%esi
  80107a:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80107c:	5b                   	pop    %ebx
  80107d:	5e                   	pop    %esi
  80107e:	5f                   	pop    %edi
  80107f:	5d                   	pop    %ebp
  801080:	c3                   	ret    

00801081 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  801081:	f3 0f 1e fb          	endbr32 
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	57                   	push   %edi
  801089:	56                   	push   %esi
  80108a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80108b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801090:	8b 55 08             	mov    0x8(%ebp),%edx
  801093:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801096:	b8 0f 00 00 00       	mov    $0xf,%eax
  80109b:	89 df                	mov    %ebx,%edi
  80109d:	89 de                	mov    %ebx,%esi
  80109f:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  8010a1:	5b                   	pop    %ebx
  8010a2:	5e                   	pop    %esi
  8010a3:	5f                   	pop    %edi
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  8010a6:	f3 0f 1e fb          	endbr32 
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	57                   	push   %edi
  8010ae:	56                   	push   %esi
  8010af:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010bb:	b8 10 00 00 00       	mov    $0x10,%eax
  8010c0:	89 df                	mov    %ebx,%edi
  8010c2:	89 de                	mov    %ebx,%esi
  8010c4:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  8010c6:	5b                   	pop    %ebx
  8010c7:	5e                   	pop    %esi
  8010c8:	5f                   	pop    %edi
  8010c9:	5d                   	pop    %ebp
  8010ca:	c3                   	ret    

008010cb <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010cb:	f3 0f 1e fb          	endbr32 
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d5:	05 00 00 00 30       	add    $0x30000000,%eax
  8010da:	c1 e8 0c             	shr    $0xc,%eax
}
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    

008010df <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010df:	f3 0f 1e fb          	endbr32 
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e9:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8010ee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010f3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010f8:	5d                   	pop    %ebp
  8010f9:	c3                   	ret    

008010fa <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010fa:	f3 0f 1e fb          	endbr32 
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
  801101:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801106:	89 c2                	mov    %eax,%edx
  801108:	c1 ea 16             	shr    $0x16,%edx
  80110b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801112:	f6 c2 01             	test   $0x1,%dl
  801115:	74 2d                	je     801144 <fd_alloc+0x4a>
  801117:	89 c2                	mov    %eax,%edx
  801119:	c1 ea 0c             	shr    $0xc,%edx
  80111c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801123:	f6 c2 01             	test   $0x1,%dl
  801126:	74 1c                	je     801144 <fd_alloc+0x4a>
  801128:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80112d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801132:	75 d2                	jne    801106 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  801134:	8b 45 08             	mov    0x8(%ebp),%eax
  801137:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80113d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801142:	eb 0a                	jmp    80114e <fd_alloc+0x54>
			*fd_store = fd;
  801144:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801147:	89 01                	mov    %eax,(%ecx)
			return 0;
  801149:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80114e:	5d                   	pop    %ebp
  80114f:	c3                   	ret    

00801150 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801150:	f3 0f 1e fb          	endbr32 
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80115a:	83 f8 1f             	cmp    $0x1f,%eax
  80115d:	77 30                	ja     80118f <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80115f:	c1 e0 0c             	shl    $0xc,%eax
  801162:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801167:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80116d:	f6 c2 01             	test   $0x1,%dl
  801170:	74 24                	je     801196 <fd_lookup+0x46>
  801172:	89 c2                	mov    %eax,%edx
  801174:	c1 ea 0c             	shr    $0xc,%edx
  801177:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80117e:	f6 c2 01             	test   $0x1,%dl
  801181:	74 1a                	je     80119d <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801183:	8b 55 0c             	mov    0xc(%ebp),%edx
  801186:	89 02                	mov    %eax,(%edx)
	return 0;
  801188:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80118d:	5d                   	pop    %ebp
  80118e:	c3                   	ret    
		return -E_INVAL;
  80118f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801194:	eb f7                	jmp    80118d <fd_lookup+0x3d>
		return -E_INVAL;
  801196:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80119b:	eb f0                	jmp    80118d <fd_lookup+0x3d>
  80119d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a2:	eb e9                	jmp    80118d <fd_lookup+0x3d>

008011a4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011a4:	f3 0f 1e fb          	endbr32 
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	83 ec 08             	sub    $0x8,%esp
  8011ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8011b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b6:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  8011bb:	39 08                	cmp    %ecx,(%eax)
  8011bd:	74 38                	je     8011f7 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8011bf:	83 c2 01             	add    $0x1,%edx
  8011c2:	8b 04 95 4c 2a 80 00 	mov    0x802a4c(,%edx,4),%eax
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	75 ee                	jne    8011bb <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011cd:	a1 08 44 80 00       	mov    0x804408,%eax
  8011d2:	8b 40 48             	mov    0x48(%eax),%eax
  8011d5:	83 ec 04             	sub    $0x4,%esp
  8011d8:	51                   	push   %ecx
  8011d9:	50                   	push   %eax
  8011da:	68 d0 29 80 00       	push   $0x8029d0
  8011df:	e8 e9 f1 ff ff       	call   8003cd <cprintf>
	*dev = 0;
  8011e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011f5:	c9                   	leave  
  8011f6:	c3                   	ret    
			*dev = devtab[i];
  8011f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011fa:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801201:	eb f2                	jmp    8011f5 <dev_lookup+0x51>

00801203 <fd_close>:
{
  801203:	f3 0f 1e fb          	endbr32 
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	57                   	push   %edi
  80120b:	56                   	push   %esi
  80120c:	53                   	push   %ebx
  80120d:	83 ec 24             	sub    $0x24,%esp
  801210:	8b 75 08             	mov    0x8(%ebp),%esi
  801213:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801216:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801219:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80121a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801220:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801223:	50                   	push   %eax
  801224:	e8 27 ff ff ff       	call   801150 <fd_lookup>
  801229:	89 c3                	mov    %eax,%ebx
  80122b:	83 c4 10             	add    $0x10,%esp
  80122e:	85 c0                	test   %eax,%eax
  801230:	78 05                	js     801237 <fd_close+0x34>
	    || fd != fd2)
  801232:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801235:	74 16                	je     80124d <fd_close+0x4a>
		return (must_exist ? r : 0);
  801237:	89 f8                	mov    %edi,%eax
  801239:	84 c0                	test   %al,%al
  80123b:	b8 00 00 00 00       	mov    $0x0,%eax
  801240:	0f 44 d8             	cmove  %eax,%ebx
}
  801243:	89 d8                	mov    %ebx,%eax
  801245:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801248:	5b                   	pop    %ebx
  801249:	5e                   	pop    %esi
  80124a:	5f                   	pop    %edi
  80124b:	5d                   	pop    %ebp
  80124c:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80124d:	83 ec 08             	sub    $0x8,%esp
  801250:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801253:	50                   	push   %eax
  801254:	ff 36                	pushl  (%esi)
  801256:	e8 49 ff ff ff       	call   8011a4 <dev_lookup>
  80125b:	89 c3                	mov    %eax,%ebx
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	85 c0                	test   %eax,%eax
  801262:	78 1a                	js     80127e <fd_close+0x7b>
		if (dev->dev_close)
  801264:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801267:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80126a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80126f:	85 c0                	test   %eax,%eax
  801271:	74 0b                	je     80127e <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801273:	83 ec 0c             	sub    $0xc,%esp
  801276:	56                   	push   %esi
  801277:	ff d0                	call   *%eax
  801279:	89 c3                	mov    %eax,%ebx
  80127b:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80127e:	83 ec 08             	sub    $0x8,%esp
  801281:	56                   	push   %esi
  801282:	6a 00                	push   $0x0
  801284:	e8 f6 fc ff ff       	call   800f7f <sys_page_unmap>
	return r;
  801289:	83 c4 10             	add    $0x10,%esp
  80128c:	eb b5                	jmp    801243 <fd_close+0x40>

0080128e <close>:

int
close(int fdnum)
{
  80128e:	f3 0f 1e fb          	endbr32 
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801298:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129b:	50                   	push   %eax
  80129c:	ff 75 08             	pushl  0x8(%ebp)
  80129f:	e8 ac fe ff ff       	call   801150 <fd_lookup>
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	79 02                	jns    8012ad <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8012ab:	c9                   	leave  
  8012ac:	c3                   	ret    
		return fd_close(fd, 1);
  8012ad:	83 ec 08             	sub    $0x8,%esp
  8012b0:	6a 01                	push   $0x1
  8012b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8012b5:	e8 49 ff ff ff       	call   801203 <fd_close>
  8012ba:	83 c4 10             	add    $0x10,%esp
  8012bd:	eb ec                	jmp    8012ab <close+0x1d>

008012bf <close_all>:

void
close_all(void)
{
  8012bf:	f3 0f 1e fb          	endbr32 
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	53                   	push   %ebx
  8012c7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ca:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012cf:	83 ec 0c             	sub    $0xc,%esp
  8012d2:	53                   	push   %ebx
  8012d3:	e8 b6 ff ff ff       	call   80128e <close>
	for (i = 0; i < MAXFD; i++)
  8012d8:	83 c3 01             	add    $0x1,%ebx
  8012db:	83 c4 10             	add    $0x10,%esp
  8012de:	83 fb 20             	cmp    $0x20,%ebx
  8012e1:	75 ec                	jne    8012cf <close_all+0x10>
}
  8012e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e6:	c9                   	leave  
  8012e7:	c3                   	ret    

008012e8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012e8:	f3 0f 1e fb          	endbr32 
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	57                   	push   %edi
  8012f0:	56                   	push   %esi
  8012f1:	53                   	push   %ebx
  8012f2:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012f5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012f8:	50                   	push   %eax
  8012f9:	ff 75 08             	pushl  0x8(%ebp)
  8012fc:	e8 4f fe ff ff       	call   801150 <fd_lookup>
  801301:	89 c3                	mov    %eax,%ebx
  801303:	83 c4 10             	add    $0x10,%esp
  801306:	85 c0                	test   %eax,%eax
  801308:	0f 88 81 00 00 00    	js     80138f <dup+0xa7>
		return r;
	close(newfdnum);
  80130e:	83 ec 0c             	sub    $0xc,%esp
  801311:	ff 75 0c             	pushl  0xc(%ebp)
  801314:	e8 75 ff ff ff       	call   80128e <close>

	newfd = INDEX2FD(newfdnum);
  801319:	8b 75 0c             	mov    0xc(%ebp),%esi
  80131c:	c1 e6 0c             	shl    $0xc,%esi
  80131f:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801325:	83 c4 04             	add    $0x4,%esp
  801328:	ff 75 e4             	pushl  -0x1c(%ebp)
  80132b:	e8 af fd ff ff       	call   8010df <fd2data>
  801330:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801332:	89 34 24             	mov    %esi,(%esp)
  801335:	e8 a5 fd ff ff       	call   8010df <fd2data>
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80133f:	89 d8                	mov    %ebx,%eax
  801341:	c1 e8 16             	shr    $0x16,%eax
  801344:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80134b:	a8 01                	test   $0x1,%al
  80134d:	74 11                	je     801360 <dup+0x78>
  80134f:	89 d8                	mov    %ebx,%eax
  801351:	c1 e8 0c             	shr    $0xc,%eax
  801354:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80135b:	f6 c2 01             	test   $0x1,%dl
  80135e:	75 39                	jne    801399 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801360:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801363:	89 d0                	mov    %edx,%eax
  801365:	c1 e8 0c             	shr    $0xc,%eax
  801368:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80136f:	83 ec 0c             	sub    $0xc,%esp
  801372:	25 07 0e 00 00       	and    $0xe07,%eax
  801377:	50                   	push   %eax
  801378:	56                   	push   %esi
  801379:	6a 00                	push   $0x0
  80137b:	52                   	push   %edx
  80137c:	6a 00                	push   $0x0
  80137e:	e8 d7 fb ff ff       	call   800f5a <sys_page_map>
  801383:	89 c3                	mov    %eax,%ebx
  801385:	83 c4 20             	add    $0x20,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 31                	js     8013bd <dup+0xd5>
		goto err;

	return newfdnum;
  80138c:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80138f:	89 d8                	mov    %ebx,%eax
  801391:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801394:	5b                   	pop    %ebx
  801395:	5e                   	pop    %esi
  801396:	5f                   	pop    %edi
  801397:	5d                   	pop    %ebp
  801398:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801399:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a0:	83 ec 0c             	sub    $0xc,%esp
  8013a3:	25 07 0e 00 00       	and    $0xe07,%eax
  8013a8:	50                   	push   %eax
  8013a9:	57                   	push   %edi
  8013aa:	6a 00                	push   $0x0
  8013ac:	53                   	push   %ebx
  8013ad:	6a 00                	push   $0x0
  8013af:	e8 a6 fb ff ff       	call   800f5a <sys_page_map>
  8013b4:	89 c3                	mov    %eax,%ebx
  8013b6:	83 c4 20             	add    $0x20,%esp
  8013b9:	85 c0                	test   %eax,%eax
  8013bb:	79 a3                	jns    801360 <dup+0x78>
	sys_page_unmap(0, newfd);
  8013bd:	83 ec 08             	sub    $0x8,%esp
  8013c0:	56                   	push   %esi
  8013c1:	6a 00                	push   $0x0
  8013c3:	e8 b7 fb ff ff       	call   800f7f <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013c8:	83 c4 08             	add    $0x8,%esp
  8013cb:	57                   	push   %edi
  8013cc:	6a 00                	push   $0x0
  8013ce:	e8 ac fb ff ff       	call   800f7f <sys_page_unmap>
	return r;
  8013d3:	83 c4 10             	add    $0x10,%esp
  8013d6:	eb b7                	jmp    80138f <dup+0xa7>

008013d8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013d8:	f3 0f 1e fb          	endbr32 
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	53                   	push   %ebx
  8013e0:	83 ec 1c             	sub    $0x1c,%esp
  8013e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e9:	50                   	push   %eax
  8013ea:	53                   	push   %ebx
  8013eb:	e8 60 fd ff ff       	call   801150 <fd_lookup>
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	78 3f                	js     801436 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f7:	83 ec 08             	sub    $0x8,%esp
  8013fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fd:	50                   	push   %eax
  8013fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801401:	ff 30                	pushl  (%eax)
  801403:	e8 9c fd ff ff       	call   8011a4 <dev_lookup>
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	85 c0                	test   %eax,%eax
  80140d:	78 27                	js     801436 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80140f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801412:	8b 42 08             	mov    0x8(%edx),%eax
  801415:	83 e0 03             	and    $0x3,%eax
  801418:	83 f8 01             	cmp    $0x1,%eax
  80141b:	74 1e                	je     80143b <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80141d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801420:	8b 40 08             	mov    0x8(%eax),%eax
  801423:	85 c0                	test   %eax,%eax
  801425:	74 35                	je     80145c <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801427:	83 ec 04             	sub    $0x4,%esp
  80142a:	ff 75 10             	pushl  0x10(%ebp)
  80142d:	ff 75 0c             	pushl  0xc(%ebp)
  801430:	52                   	push   %edx
  801431:	ff d0                	call   *%eax
  801433:	83 c4 10             	add    $0x10,%esp
}
  801436:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801439:	c9                   	leave  
  80143a:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80143b:	a1 08 44 80 00       	mov    0x804408,%eax
  801440:	8b 40 48             	mov    0x48(%eax),%eax
  801443:	83 ec 04             	sub    $0x4,%esp
  801446:	53                   	push   %ebx
  801447:	50                   	push   %eax
  801448:	68 11 2a 80 00       	push   $0x802a11
  80144d:	e8 7b ef ff ff       	call   8003cd <cprintf>
		return -E_INVAL;
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80145a:	eb da                	jmp    801436 <read+0x5e>
		return -E_NOT_SUPP;
  80145c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801461:	eb d3                	jmp    801436 <read+0x5e>

00801463 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801463:	f3 0f 1e fb          	endbr32 
  801467:	55                   	push   %ebp
  801468:	89 e5                	mov    %esp,%ebp
  80146a:	57                   	push   %edi
  80146b:	56                   	push   %esi
  80146c:	53                   	push   %ebx
  80146d:	83 ec 0c             	sub    $0xc,%esp
  801470:	8b 7d 08             	mov    0x8(%ebp),%edi
  801473:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801476:	bb 00 00 00 00       	mov    $0x0,%ebx
  80147b:	eb 02                	jmp    80147f <readn+0x1c>
  80147d:	01 c3                	add    %eax,%ebx
  80147f:	39 f3                	cmp    %esi,%ebx
  801481:	73 21                	jae    8014a4 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801483:	83 ec 04             	sub    $0x4,%esp
  801486:	89 f0                	mov    %esi,%eax
  801488:	29 d8                	sub    %ebx,%eax
  80148a:	50                   	push   %eax
  80148b:	89 d8                	mov    %ebx,%eax
  80148d:	03 45 0c             	add    0xc(%ebp),%eax
  801490:	50                   	push   %eax
  801491:	57                   	push   %edi
  801492:	e8 41 ff ff ff       	call   8013d8 <read>
		if (m < 0)
  801497:	83 c4 10             	add    $0x10,%esp
  80149a:	85 c0                	test   %eax,%eax
  80149c:	78 04                	js     8014a2 <readn+0x3f>
			return m;
		if (m == 0)
  80149e:	75 dd                	jne    80147d <readn+0x1a>
  8014a0:	eb 02                	jmp    8014a4 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014a2:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8014a4:	89 d8                	mov    %ebx,%eax
  8014a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014a9:	5b                   	pop    %ebx
  8014aa:	5e                   	pop    %esi
  8014ab:	5f                   	pop    %edi
  8014ac:	5d                   	pop    %ebp
  8014ad:	c3                   	ret    

008014ae <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014ae:	f3 0f 1e fb          	endbr32 
  8014b2:	55                   	push   %ebp
  8014b3:	89 e5                	mov    %esp,%ebp
  8014b5:	53                   	push   %ebx
  8014b6:	83 ec 1c             	sub    $0x1c,%esp
  8014b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014bf:	50                   	push   %eax
  8014c0:	53                   	push   %ebx
  8014c1:	e8 8a fc ff ff       	call   801150 <fd_lookup>
  8014c6:	83 c4 10             	add    $0x10,%esp
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 3a                	js     801507 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cd:	83 ec 08             	sub    $0x8,%esp
  8014d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d3:	50                   	push   %eax
  8014d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d7:	ff 30                	pushl  (%eax)
  8014d9:	e8 c6 fc ff ff       	call   8011a4 <dev_lookup>
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	78 22                	js     801507 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014ec:	74 1e                	je     80150c <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f1:	8b 52 0c             	mov    0xc(%edx),%edx
  8014f4:	85 d2                	test   %edx,%edx
  8014f6:	74 35                	je     80152d <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014f8:	83 ec 04             	sub    $0x4,%esp
  8014fb:	ff 75 10             	pushl  0x10(%ebp)
  8014fe:	ff 75 0c             	pushl  0xc(%ebp)
  801501:	50                   	push   %eax
  801502:	ff d2                	call   *%edx
  801504:	83 c4 10             	add    $0x10,%esp
}
  801507:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150a:	c9                   	leave  
  80150b:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80150c:	a1 08 44 80 00       	mov    0x804408,%eax
  801511:	8b 40 48             	mov    0x48(%eax),%eax
  801514:	83 ec 04             	sub    $0x4,%esp
  801517:	53                   	push   %ebx
  801518:	50                   	push   %eax
  801519:	68 2d 2a 80 00       	push   $0x802a2d
  80151e:	e8 aa ee ff ff       	call   8003cd <cprintf>
		return -E_INVAL;
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80152b:	eb da                	jmp    801507 <write+0x59>
		return -E_NOT_SUPP;
  80152d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801532:	eb d3                	jmp    801507 <write+0x59>

00801534 <seek>:

int
seek(int fdnum, off_t offset)
{
  801534:	f3 0f 1e fb          	endbr32 
  801538:	55                   	push   %ebp
  801539:	89 e5                	mov    %esp,%ebp
  80153b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80153e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801541:	50                   	push   %eax
  801542:	ff 75 08             	pushl  0x8(%ebp)
  801545:	e8 06 fc ff ff       	call   801150 <fd_lookup>
  80154a:	83 c4 10             	add    $0x10,%esp
  80154d:	85 c0                	test   %eax,%eax
  80154f:	78 0e                	js     80155f <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801551:	8b 55 0c             	mov    0xc(%ebp),%edx
  801554:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801557:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80155a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80155f:	c9                   	leave  
  801560:	c3                   	ret    

00801561 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801561:	f3 0f 1e fb          	endbr32 
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	53                   	push   %ebx
  801569:	83 ec 1c             	sub    $0x1c,%esp
  80156c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801572:	50                   	push   %eax
  801573:	53                   	push   %ebx
  801574:	e8 d7 fb ff ff       	call   801150 <fd_lookup>
  801579:	83 c4 10             	add    $0x10,%esp
  80157c:	85 c0                	test   %eax,%eax
  80157e:	78 37                	js     8015b7 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801580:	83 ec 08             	sub    $0x8,%esp
  801583:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801586:	50                   	push   %eax
  801587:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158a:	ff 30                	pushl  (%eax)
  80158c:	e8 13 fc ff ff       	call   8011a4 <dev_lookup>
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	85 c0                	test   %eax,%eax
  801596:	78 1f                	js     8015b7 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801598:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80159f:	74 1b                	je     8015bc <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8015a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a4:	8b 52 18             	mov    0x18(%edx),%edx
  8015a7:	85 d2                	test   %edx,%edx
  8015a9:	74 32                	je     8015dd <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015ab:	83 ec 08             	sub    $0x8,%esp
  8015ae:	ff 75 0c             	pushl  0xc(%ebp)
  8015b1:	50                   	push   %eax
  8015b2:	ff d2                	call   *%edx
  8015b4:	83 c4 10             	add    $0x10,%esp
}
  8015b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ba:	c9                   	leave  
  8015bb:	c3                   	ret    
			thisenv->env_id, fdnum);
  8015bc:	a1 08 44 80 00       	mov    0x804408,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015c1:	8b 40 48             	mov    0x48(%eax),%eax
  8015c4:	83 ec 04             	sub    $0x4,%esp
  8015c7:	53                   	push   %ebx
  8015c8:	50                   	push   %eax
  8015c9:	68 f0 29 80 00       	push   $0x8029f0
  8015ce:	e8 fa ed ff ff       	call   8003cd <cprintf>
		return -E_INVAL;
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015db:	eb da                	jmp    8015b7 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8015dd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015e2:	eb d3                	jmp    8015b7 <ftruncate+0x56>

008015e4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015e4:	f3 0f 1e fb          	endbr32 
  8015e8:	55                   	push   %ebp
  8015e9:	89 e5                	mov    %esp,%ebp
  8015eb:	53                   	push   %ebx
  8015ec:	83 ec 1c             	sub    $0x1c,%esp
  8015ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f5:	50                   	push   %eax
  8015f6:	ff 75 08             	pushl  0x8(%ebp)
  8015f9:	e8 52 fb ff ff       	call   801150 <fd_lookup>
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	85 c0                	test   %eax,%eax
  801603:	78 4b                	js     801650 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801605:	83 ec 08             	sub    $0x8,%esp
  801608:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160b:	50                   	push   %eax
  80160c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160f:	ff 30                	pushl  (%eax)
  801611:	e8 8e fb ff ff       	call   8011a4 <dev_lookup>
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 33                	js     801650 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80161d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801620:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801624:	74 2f                	je     801655 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801626:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801629:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801630:	00 00 00 
	stat->st_isdir = 0;
  801633:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80163a:	00 00 00 
	stat->st_dev = dev;
  80163d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801643:	83 ec 08             	sub    $0x8,%esp
  801646:	53                   	push   %ebx
  801647:	ff 75 f0             	pushl  -0x10(%ebp)
  80164a:	ff 50 14             	call   *0x14(%eax)
  80164d:	83 c4 10             	add    $0x10,%esp
}
  801650:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801653:	c9                   	leave  
  801654:	c3                   	ret    
		return -E_NOT_SUPP;
  801655:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80165a:	eb f4                	jmp    801650 <fstat+0x6c>

0080165c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80165c:	f3 0f 1e fb          	endbr32 
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	56                   	push   %esi
  801664:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801665:	83 ec 08             	sub    $0x8,%esp
  801668:	6a 00                	push   $0x0
  80166a:	ff 75 08             	pushl  0x8(%ebp)
  80166d:	e8 01 02 00 00       	call   801873 <open>
  801672:	89 c3                	mov    %eax,%ebx
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	85 c0                	test   %eax,%eax
  801679:	78 1b                	js     801696 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80167b:	83 ec 08             	sub    $0x8,%esp
  80167e:	ff 75 0c             	pushl  0xc(%ebp)
  801681:	50                   	push   %eax
  801682:	e8 5d ff ff ff       	call   8015e4 <fstat>
  801687:	89 c6                	mov    %eax,%esi
	close(fd);
  801689:	89 1c 24             	mov    %ebx,(%esp)
  80168c:	e8 fd fb ff ff       	call   80128e <close>
	return r;
  801691:	83 c4 10             	add    $0x10,%esp
  801694:	89 f3                	mov    %esi,%ebx
}
  801696:	89 d8                	mov    %ebx,%eax
  801698:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80169b:	5b                   	pop    %ebx
  80169c:	5e                   	pop    %esi
  80169d:	5d                   	pop    %ebp
  80169e:	c3                   	ret    

0080169f <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	56                   	push   %esi
  8016a3:	53                   	push   %ebx
  8016a4:	89 c6                	mov    %eax,%esi
  8016a6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016a8:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  8016af:	74 27                	je     8016d8 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016b1:	6a 07                	push   $0x7
  8016b3:	68 00 50 80 00       	push   $0x805000
  8016b8:	56                   	push   %esi
  8016b9:	ff 35 00 44 80 00    	pushl  0x804400
  8016bf:	e8 0b 0c 00 00       	call   8022cf <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016c4:	83 c4 0c             	add    $0xc,%esp
  8016c7:	6a 00                	push   $0x0
  8016c9:	53                   	push   %ebx
  8016ca:	6a 00                	push   $0x0
  8016cc:	e8 91 0b 00 00       	call   802262 <ipc_recv>
}
  8016d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016d4:	5b                   	pop    %ebx
  8016d5:	5e                   	pop    %esi
  8016d6:	5d                   	pop    %ebp
  8016d7:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016d8:	83 ec 0c             	sub    $0xc,%esp
  8016db:	6a 01                	push   $0x1
  8016dd:	e8 45 0c 00 00       	call   802327 <ipc_find_env>
  8016e2:	a3 00 44 80 00       	mov    %eax,0x804400
  8016e7:	83 c4 10             	add    $0x10,%esp
  8016ea:	eb c5                	jmp    8016b1 <fsipc+0x12>

008016ec <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016ec:	f3 0f 1e fb          	endbr32 
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8016fc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801701:	8b 45 0c             	mov    0xc(%ebp),%eax
  801704:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801709:	ba 00 00 00 00       	mov    $0x0,%edx
  80170e:	b8 02 00 00 00       	mov    $0x2,%eax
  801713:	e8 87 ff ff ff       	call   80169f <fsipc>
}
  801718:	c9                   	leave  
  801719:	c3                   	ret    

0080171a <devfile_flush>:
{
  80171a:	f3 0f 1e fb          	endbr32 
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801724:	8b 45 08             	mov    0x8(%ebp),%eax
  801727:	8b 40 0c             	mov    0xc(%eax),%eax
  80172a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80172f:	ba 00 00 00 00       	mov    $0x0,%edx
  801734:	b8 06 00 00 00       	mov    $0x6,%eax
  801739:	e8 61 ff ff ff       	call   80169f <fsipc>
}
  80173e:	c9                   	leave  
  80173f:	c3                   	ret    

00801740 <devfile_stat>:
{
  801740:	f3 0f 1e fb          	endbr32 
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	53                   	push   %ebx
  801748:	83 ec 04             	sub    $0x4,%esp
  80174b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80174e:	8b 45 08             	mov    0x8(%ebp),%eax
  801751:	8b 40 0c             	mov    0xc(%eax),%eax
  801754:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801759:	ba 00 00 00 00       	mov    $0x0,%edx
  80175e:	b8 05 00 00 00       	mov    $0x5,%eax
  801763:	e8 37 ff ff ff       	call   80169f <fsipc>
  801768:	85 c0                	test   %eax,%eax
  80176a:	78 2c                	js     801798 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80176c:	83 ec 08             	sub    $0x8,%esp
  80176f:	68 00 50 80 00       	push   $0x805000
  801774:	53                   	push   %ebx
  801775:	e8 51 f3 ff ff       	call   800acb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80177a:	a1 80 50 80 00       	mov    0x805080,%eax
  80177f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801785:	a1 84 50 80 00       	mov    0x805084,%eax
  80178a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801790:	83 c4 10             	add    $0x10,%esp
  801793:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801798:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179b:	c9                   	leave  
  80179c:	c3                   	ret    

0080179d <devfile_write>:
{
  80179d:	f3 0f 1e fb          	endbr32 
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	83 ec 0c             	sub    $0xc,%esp
  8017a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8017aa:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017af:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017b4:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8017ba:	8b 52 0c             	mov    0xc(%edx),%edx
  8017bd:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017c3:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017c8:	50                   	push   %eax
  8017c9:	ff 75 0c             	pushl  0xc(%ebp)
  8017cc:	68 08 50 80 00       	push   $0x805008
  8017d1:	e8 f3 f4 ff ff       	call   800cc9 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017db:	b8 04 00 00 00       	mov    $0x4,%eax
  8017e0:	e8 ba fe ff ff       	call   80169f <fsipc>
}
  8017e5:	c9                   	leave  
  8017e6:	c3                   	ret    

008017e7 <devfile_read>:
{
  8017e7:	f3 0f 1e fb          	endbr32 
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	56                   	push   %esi
  8017ef:	53                   	push   %ebx
  8017f0:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017fe:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801804:	ba 00 00 00 00       	mov    $0x0,%edx
  801809:	b8 03 00 00 00       	mov    $0x3,%eax
  80180e:	e8 8c fe ff ff       	call   80169f <fsipc>
  801813:	89 c3                	mov    %eax,%ebx
  801815:	85 c0                	test   %eax,%eax
  801817:	78 1f                	js     801838 <devfile_read+0x51>
	assert(r <= n);
  801819:	39 f0                	cmp    %esi,%eax
  80181b:	77 24                	ja     801841 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  80181d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801822:	7f 36                	jg     80185a <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801824:	83 ec 04             	sub    $0x4,%esp
  801827:	50                   	push   %eax
  801828:	68 00 50 80 00       	push   $0x805000
  80182d:	ff 75 0c             	pushl  0xc(%ebp)
  801830:	e8 94 f4 ff ff       	call   800cc9 <memmove>
	return r;
  801835:	83 c4 10             	add    $0x10,%esp
}
  801838:	89 d8                	mov    %ebx,%eax
  80183a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80183d:	5b                   	pop    %ebx
  80183e:	5e                   	pop    %esi
  80183f:	5d                   	pop    %ebp
  801840:	c3                   	ret    
	assert(r <= n);
  801841:	68 60 2a 80 00       	push   $0x802a60
  801846:	68 67 2a 80 00       	push   $0x802a67
  80184b:	68 8c 00 00 00       	push   $0x8c
  801850:	68 7c 2a 80 00       	push   $0x802a7c
  801855:	e8 8c ea ff ff       	call   8002e6 <_panic>
	assert(r <= PGSIZE);
  80185a:	68 87 2a 80 00       	push   $0x802a87
  80185f:	68 67 2a 80 00       	push   $0x802a67
  801864:	68 8d 00 00 00       	push   $0x8d
  801869:	68 7c 2a 80 00       	push   $0x802a7c
  80186e:	e8 73 ea ff ff       	call   8002e6 <_panic>

00801873 <open>:
{
  801873:	f3 0f 1e fb          	endbr32 
  801877:	55                   	push   %ebp
  801878:	89 e5                	mov    %esp,%ebp
  80187a:	56                   	push   %esi
  80187b:	53                   	push   %ebx
  80187c:	83 ec 1c             	sub    $0x1c,%esp
  80187f:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801882:	56                   	push   %esi
  801883:	e8 00 f2 ff ff       	call   800a88 <strlen>
  801888:	83 c4 10             	add    $0x10,%esp
  80188b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801890:	7f 6c                	jg     8018fe <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801892:	83 ec 0c             	sub    $0xc,%esp
  801895:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801898:	50                   	push   %eax
  801899:	e8 5c f8 ff ff       	call   8010fa <fd_alloc>
  80189e:	89 c3                	mov    %eax,%ebx
  8018a0:	83 c4 10             	add    $0x10,%esp
  8018a3:	85 c0                	test   %eax,%eax
  8018a5:	78 3c                	js     8018e3 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8018a7:	83 ec 08             	sub    $0x8,%esp
  8018aa:	56                   	push   %esi
  8018ab:	68 00 50 80 00       	push   $0x805000
  8018b0:	e8 16 f2 ff ff       	call   800acb <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b8:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8018c5:	e8 d5 fd ff ff       	call   80169f <fsipc>
  8018ca:	89 c3                	mov    %eax,%ebx
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	85 c0                	test   %eax,%eax
  8018d1:	78 19                	js     8018ec <open+0x79>
	return fd2num(fd);
  8018d3:	83 ec 0c             	sub    $0xc,%esp
  8018d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d9:	e8 ed f7 ff ff       	call   8010cb <fd2num>
  8018de:	89 c3                	mov    %eax,%ebx
  8018e0:	83 c4 10             	add    $0x10,%esp
}
  8018e3:	89 d8                	mov    %ebx,%eax
  8018e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e8:	5b                   	pop    %ebx
  8018e9:	5e                   	pop    %esi
  8018ea:	5d                   	pop    %ebp
  8018eb:	c3                   	ret    
		fd_close(fd, 0);
  8018ec:	83 ec 08             	sub    $0x8,%esp
  8018ef:	6a 00                	push   $0x0
  8018f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f4:	e8 0a f9 ff ff       	call   801203 <fd_close>
		return r;
  8018f9:	83 c4 10             	add    $0x10,%esp
  8018fc:	eb e5                	jmp    8018e3 <open+0x70>
		return -E_BAD_PATH;
  8018fe:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801903:	eb de                	jmp    8018e3 <open+0x70>

00801905 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801905:	f3 0f 1e fb          	endbr32 
  801909:	55                   	push   %ebp
  80190a:	89 e5                	mov    %esp,%ebp
  80190c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80190f:	ba 00 00 00 00       	mov    $0x0,%edx
  801914:	b8 08 00 00 00       	mov    $0x8,%eax
  801919:	e8 81 fd ff ff       	call   80169f <fsipc>
}
  80191e:	c9                   	leave  
  80191f:	c3                   	ret    

00801920 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801920:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801924:	7f 01                	jg     801927 <writebuf+0x7>
  801926:	c3                   	ret    
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	53                   	push   %ebx
  80192b:	83 ec 08             	sub    $0x8,%esp
  80192e:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  801930:	ff 70 04             	pushl  0x4(%eax)
  801933:	8d 40 10             	lea    0x10(%eax),%eax
  801936:	50                   	push   %eax
  801937:	ff 33                	pushl  (%ebx)
  801939:	e8 70 fb ff ff       	call   8014ae <write>
		if (result > 0)
  80193e:	83 c4 10             	add    $0x10,%esp
  801941:	85 c0                	test   %eax,%eax
  801943:	7e 03                	jle    801948 <writebuf+0x28>
			b->result += result;
  801945:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801948:	39 43 04             	cmp    %eax,0x4(%ebx)
  80194b:	74 0d                	je     80195a <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  80194d:	85 c0                	test   %eax,%eax
  80194f:	ba 00 00 00 00       	mov    $0x0,%edx
  801954:	0f 4f c2             	cmovg  %edx,%eax
  801957:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80195a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80195d:	c9                   	leave  
  80195e:	c3                   	ret    

0080195f <putch>:

static void
putch(int ch, void *thunk)
{
  80195f:	f3 0f 1e fb          	endbr32 
  801963:	55                   	push   %ebp
  801964:	89 e5                	mov    %esp,%ebp
  801966:	53                   	push   %ebx
  801967:	83 ec 04             	sub    $0x4,%esp
  80196a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80196d:	8b 53 04             	mov    0x4(%ebx),%edx
  801970:	8d 42 01             	lea    0x1(%edx),%eax
  801973:	89 43 04             	mov    %eax,0x4(%ebx)
  801976:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801979:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80197d:	3d 00 01 00 00       	cmp    $0x100,%eax
  801982:	74 06                	je     80198a <putch+0x2b>
		writebuf(b);
		b->idx = 0;
	}
}
  801984:	83 c4 04             	add    $0x4,%esp
  801987:	5b                   	pop    %ebx
  801988:	5d                   	pop    %ebp
  801989:	c3                   	ret    
		writebuf(b);
  80198a:	89 d8                	mov    %ebx,%eax
  80198c:	e8 8f ff ff ff       	call   801920 <writebuf>
		b->idx = 0;
  801991:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  801998:	eb ea                	jmp    801984 <putch+0x25>

0080199a <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80199a:	f3 0f 1e fb          	endbr32 
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8019a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019aa:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8019b0:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8019b7:	00 00 00 
	b.result = 0;
  8019ba:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8019c1:	00 00 00 
	b.error = 1;
  8019c4:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8019cb:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8019ce:	ff 75 10             	pushl  0x10(%ebp)
  8019d1:	ff 75 0c             	pushl  0xc(%ebp)
  8019d4:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019da:	50                   	push   %eax
  8019db:	68 5f 19 80 00       	push   $0x80195f
  8019e0:	e8 eb ea ff ff       	call   8004d0 <vprintfmt>
	if (b.idx > 0)
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8019ef:	7f 11                	jg     801a02 <vfprintf+0x68>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  8019f1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    
		writebuf(&b);
  801a02:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a08:	e8 13 ff ff ff       	call   801920 <writebuf>
  801a0d:	eb e2                	jmp    8019f1 <vfprintf+0x57>

00801a0f <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a0f:	f3 0f 1e fb          	endbr32 
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a19:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a1c:	50                   	push   %eax
  801a1d:	ff 75 0c             	pushl  0xc(%ebp)
  801a20:	ff 75 08             	pushl  0x8(%ebp)
  801a23:	e8 72 ff ff ff       	call   80199a <vfprintf>
	va_end(ap);

	return cnt;
}
  801a28:	c9                   	leave  
  801a29:	c3                   	ret    

00801a2a <printf>:

int
printf(const char *fmt, ...)
{
  801a2a:	f3 0f 1e fb          	endbr32 
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a34:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a37:	50                   	push   %eax
  801a38:	ff 75 08             	pushl  0x8(%ebp)
  801a3b:	6a 01                	push   $0x1
  801a3d:	e8 58 ff ff ff       	call   80199a <vfprintf>
	va_end(ap);

	return cnt;
}
  801a42:	c9                   	leave  
  801a43:	c3                   	ret    

00801a44 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a44:	f3 0f 1e fb          	endbr32 
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a4e:	68 f3 2a 80 00       	push   $0x802af3
  801a53:	ff 75 0c             	pushl  0xc(%ebp)
  801a56:	e8 70 f0 ff ff       	call   800acb <strcpy>
	return 0;
}
  801a5b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a60:	c9                   	leave  
  801a61:	c3                   	ret    

00801a62 <devsock_close>:
{
  801a62:	f3 0f 1e fb          	endbr32 
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	53                   	push   %ebx
  801a6a:	83 ec 10             	sub    $0x10,%esp
  801a6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a70:	53                   	push   %ebx
  801a71:	e8 ee 08 00 00       	call   802364 <pageref>
  801a76:	89 c2                	mov    %eax,%edx
  801a78:	83 c4 10             	add    $0x10,%esp
		return 0;
  801a7b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801a80:	83 fa 01             	cmp    $0x1,%edx
  801a83:	74 05                	je     801a8a <devsock_close+0x28>
}
  801a85:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a88:	c9                   	leave  
  801a89:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801a8a:	83 ec 0c             	sub    $0xc,%esp
  801a8d:	ff 73 0c             	pushl  0xc(%ebx)
  801a90:	e8 e3 02 00 00       	call   801d78 <nsipc_close>
  801a95:	83 c4 10             	add    $0x10,%esp
  801a98:	eb eb                	jmp    801a85 <devsock_close+0x23>

00801a9a <devsock_write>:
{
  801a9a:	f3 0f 1e fb          	endbr32 
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801aa4:	6a 00                	push   $0x0
  801aa6:	ff 75 10             	pushl  0x10(%ebp)
  801aa9:	ff 75 0c             	pushl  0xc(%ebp)
  801aac:	8b 45 08             	mov    0x8(%ebp),%eax
  801aaf:	ff 70 0c             	pushl  0xc(%eax)
  801ab2:	e8 b5 03 00 00       	call   801e6c <nsipc_send>
}
  801ab7:	c9                   	leave  
  801ab8:	c3                   	ret    

00801ab9 <devsock_read>:
{
  801ab9:	f3 0f 1e fb          	endbr32 
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ac3:	6a 00                	push   $0x0
  801ac5:	ff 75 10             	pushl  0x10(%ebp)
  801ac8:	ff 75 0c             	pushl  0xc(%ebp)
  801acb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ace:	ff 70 0c             	pushl  0xc(%eax)
  801ad1:	e8 1f 03 00 00       	call   801df5 <nsipc_recv>
}
  801ad6:	c9                   	leave  
  801ad7:	c3                   	ret    

00801ad8 <fd2sockid>:
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801ade:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ae1:	52                   	push   %edx
  801ae2:	50                   	push   %eax
  801ae3:	e8 68 f6 ff ff       	call   801150 <fd_lookup>
  801ae8:	83 c4 10             	add    $0x10,%esp
  801aeb:	85 c0                	test   %eax,%eax
  801aed:	78 10                	js     801aff <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af2:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  801af8:	39 08                	cmp    %ecx,(%eax)
  801afa:	75 05                	jne    801b01 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801afc:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801aff:	c9                   	leave  
  801b00:	c3                   	ret    
		return -E_NOT_SUPP;
  801b01:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b06:	eb f7                	jmp    801aff <fd2sockid+0x27>

00801b08 <alloc_sockfd>:
{
  801b08:	55                   	push   %ebp
  801b09:	89 e5                	mov    %esp,%ebp
  801b0b:	56                   	push   %esi
  801b0c:	53                   	push   %ebx
  801b0d:	83 ec 1c             	sub    $0x1c,%esp
  801b10:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801b12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b15:	50                   	push   %eax
  801b16:	e8 df f5 ff ff       	call   8010fa <fd_alloc>
  801b1b:	89 c3                	mov    %eax,%ebx
  801b1d:	83 c4 10             	add    $0x10,%esp
  801b20:	85 c0                	test   %eax,%eax
  801b22:	78 43                	js     801b67 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b24:	83 ec 04             	sub    $0x4,%esp
  801b27:	68 07 04 00 00       	push   $0x407
  801b2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2f:	6a 00                	push   $0x0
  801b31:	e8 fe f3 ff ff       	call   800f34 <sys_page_alloc>
  801b36:	89 c3                	mov    %eax,%ebx
  801b38:	83 c4 10             	add    $0x10,%esp
  801b3b:	85 c0                	test   %eax,%eax
  801b3d:	78 28                	js     801b67 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b42:	8b 15 60 30 80 00    	mov    0x803060,%edx
  801b48:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b54:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b57:	83 ec 0c             	sub    $0xc,%esp
  801b5a:	50                   	push   %eax
  801b5b:	e8 6b f5 ff ff       	call   8010cb <fd2num>
  801b60:	89 c3                	mov    %eax,%ebx
  801b62:	83 c4 10             	add    $0x10,%esp
  801b65:	eb 0c                	jmp    801b73 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801b67:	83 ec 0c             	sub    $0xc,%esp
  801b6a:	56                   	push   %esi
  801b6b:	e8 08 02 00 00       	call   801d78 <nsipc_close>
		return r;
  801b70:	83 c4 10             	add    $0x10,%esp
}
  801b73:	89 d8                	mov    %ebx,%eax
  801b75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b78:	5b                   	pop    %ebx
  801b79:	5e                   	pop    %esi
  801b7a:	5d                   	pop    %ebp
  801b7b:	c3                   	ret    

00801b7c <accept>:
{
  801b7c:	f3 0f 1e fb          	endbr32 
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b86:	8b 45 08             	mov    0x8(%ebp),%eax
  801b89:	e8 4a ff ff ff       	call   801ad8 <fd2sockid>
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	78 1b                	js     801bad <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b92:	83 ec 04             	sub    $0x4,%esp
  801b95:	ff 75 10             	pushl  0x10(%ebp)
  801b98:	ff 75 0c             	pushl  0xc(%ebp)
  801b9b:	50                   	push   %eax
  801b9c:	e8 22 01 00 00       	call   801cc3 <nsipc_accept>
  801ba1:	83 c4 10             	add    $0x10,%esp
  801ba4:	85 c0                	test   %eax,%eax
  801ba6:	78 05                	js     801bad <accept+0x31>
	return alloc_sockfd(r);
  801ba8:	e8 5b ff ff ff       	call   801b08 <alloc_sockfd>
}
  801bad:	c9                   	leave  
  801bae:	c3                   	ret    

00801baf <bind>:
{
  801baf:	f3 0f 1e fb          	endbr32 
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbc:	e8 17 ff ff ff       	call   801ad8 <fd2sockid>
  801bc1:	85 c0                	test   %eax,%eax
  801bc3:	78 12                	js     801bd7 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801bc5:	83 ec 04             	sub    $0x4,%esp
  801bc8:	ff 75 10             	pushl  0x10(%ebp)
  801bcb:	ff 75 0c             	pushl  0xc(%ebp)
  801bce:	50                   	push   %eax
  801bcf:	e8 45 01 00 00       	call   801d19 <nsipc_bind>
  801bd4:	83 c4 10             	add    $0x10,%esp
}
  801bd7:	c9                   	leave  
  801bd8:	c3                   	ret    

00801bd9 <shutdown>:
{
  801bd9:	f3 0f 1e fb          	endbr32 
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801be3:	8b 45 08             	mov    0x8(%ebp),%eax
  801be6:	e8 ed fe ff ff       	call   801ad8 <fd2sockid>
  801beb:	85 c0                	test   %eax,%eax
  801bed:	78 0f                	js     801bfe <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801bef:	83 ec 08             	sub    $0x8,%esp
  801bf2:	ff 75 0c             	pushl  0xc(%ebp)
  801bf5:	50                   	push   %eax
  801bf6:	e8 57 01 00 00       	call   801d52 <nsipc_shutdown>
  801bfb:	83 c4 10             	add    $0x10,%esp
}
  801bfe:	c9                   	leave  
  801bff:	c3                   	ret    

00801c00 <connect>:
{
  801c00:	f3 0f 1e fb          	endbr32 
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0d:	e8 c6 fe ff ff       	call   801ad8 <fd2sockid>
  801c12:	85 c0                	test   %eax,%eax
  801c14:	78 12                	js     801c28 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801c16:	83 ec 04             	sub    $0x4,%esp
  801c19:	ff 75 10             	pushl  0x10(%ebp)
  801c1c:	ff 75 0c             	pushl  0xc(%ebp)
  801c1f:	50                   	push   %eax
  801c20:	e8 71 01 00 00       	call   801d96 <nsipc_connect>
  801c25:	83 c4 10             	add    $0x10,%esp
}
  801c28:	c9                   	leave  
  801c29:	c3                   	ret    

00801c2a <listen>:
{
  801c2a:	f3 0f 1e fb          	endbr32 
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c34:	8b 45 08             	mov    0x8(%ebp),%eax
  801c37:	e8 9c fe ff ff       	call   801ad8 <fd2sockid>
  801c3c:	85 c0                	test   %eax,%eax
  801c3e:	78 0f                	js     801c4f <listen+0x25>
	return nsipc_listen(r, backlog);
  801c40:	83 ec 08             	sub    $0x8,%esp
  801c43:	ff 75 0c             	pushl  0xc(%ebp)
  801c46:	50                   	push   %eax
  801c47:	e8 83 01 00 00       	call   801dcf <nsipc_listen>
  801c4c:	83 c4 10             	add    $0x10,%esp
}
  801c4f:	c9                   	leave  
  801c50:	c3                   	ret    

00801c51 <socket>:

int
socket(int domain, int type, int protocol)
{
  801c51:	f3 0f 1e fb          	endbr32 
  801c55:	55                   	push   %ebp
  801c56:	89 e5                	mov    %esp,%ebp
  801c58:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c5b:	ff 75 10             	pushl  0x10(%ebp)
  801c5e:	ff 75 0c             	pushl  0xc(%ebp)
  801c61:	ff 75 08             	pushl  0x8(%ebp)
  801c64:	e8 65 02 00 00       	call   801ece <nsipc_socket>
  801c69:	83 c4 10             	add    $0x10,%esp
  801c6c:	85 c0                	test   %eax,%eax
  801c6e:	78 05                	js     801c75 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801c70:	e8 93 fe ff ff       	call   801b08 <alloc_sockfd>
}
  801c75:	c9                   	leave  
  801c76:	c3                   	ret    

00801c77 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	53                   	push   %ebx
  801c7b:	83 ec 04             	sub    $0x4,%esp
  801c7e:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c80:	83 3d 04 44 80 00 00 	cmpl   $0x0,0x804404
  801c87:	74 26                	je     801caf <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c89:	6a 07                	push   $0x7
  801c8b:	68 00 60 80 00       	push   $0x806000
  801c90:	53                   	push   %ebx
  801c91:	ff 35 04 44 80 00    	pushl  0x804404
  801c97:	e8 33 06 00 00       	call   8022cf <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c9c:	83 c4 0c             	add    $0xc,%esp
  801c9f:	6a 00                	push   $0x0
  801ca1:	6a 00                	push   $0x0
  801ca3:	6a 00                	push   $0x0
  801ca5:	e8 b8 05 00 00       	call   802262 <ipc_recv>
}
  801caa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cad:	c9                   	leave  
  801cae:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801caf:	83 ec 0c             	sub    $0xc,%esp
  801cb2:	6a 02                	push   $0x2
  801cb4:	e8 6e 06 00 00       	call   802327 <ipc_find_env>
  801cb9:	a3 04 44 80 00       	mov    %eax,0x804404
  801cbe:	83 c4 10             	add    $0x10,%esp
  801cc1:	eb c6                	jmp    801c89 <nsipc+0x12>

00801cc3 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cc3:	f3 0f 1e fb          	endbr32 
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	56                   	push   %esi
  801ccb:	53                   	push   %ebx
  801ccc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801cd7:	8b 06                	mov    (%esi),%eax
  801cd9:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801cde:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce3:	e8 8f ff ff ff       	call   801c77 <nsipc>
  801ce8:	89 c3                	mov    %eax,%ebx
  801cea:	85 c0                	test   %eax,%eax
  801cec:	79 09                	jns    801cf7 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801cee:	89 d8                	mov    %ebx,%eax
  801cf0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf3:	5b                   	pop    %ebx
  801cf4:	5e                   	pop    %esi
  801cf5:	5d                   	pop    %ebp
  801cf6:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cf7:	83 ec 04             	sub    $0x4,%esp
  801cfa:	ff 35 10 60 80 00    	pushl  0x806010
  801d00:	68 00 60 80 00       	push   $0x806000
  801d05:	ff 75 0c             	pushl  0xc(%ebp)
  801d08:	e8 bc ef ff ff       	call   800cc9 <memmove>
		*addrlen = ret->ret_addrlen;
  801d0d:	a1 10 60 80 00       	mov    0x806010,%eax
  801d12:	89 06                	mov    %eax,(%esi)
  801d14:	83 c4 10             	add    $0x10,%esp
	return r;
  801d17:	eb d5                	jmp    801cee <nsipc_accept+0x2b>

00801d19 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d19:	f3 0f 1e fb          	endbr32 
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	53                   	push   %ebx
  801d21:	83 ec 08             	sub    $0x8,%esp
  801d24:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d27:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2a:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d2f:	53                   	push   %ebx
  801d30:	ff 75 0c             	pushl  0xc(%ebp)
  801d33:	68 04 60 80 00       	push   $0x806004
  801d38:	e8 8c ef ff ff       	call   800cc9 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d3d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d43:	b8 02 00 00 00       	mov    $0x2,%eax
  801d48:	e8 2a ff ff ff       	call   801c77 <nsipc>
}
  801d4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d50:	c9                   	leave  
  801d51:	c3                   	ret    

00801d52 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d52:	f3 0f 1e fb          	endbr32 
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d67:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d6c:	b8 03 00 00 00       	mov    $0x3,%eax
  801d71:	e8 01 ff ff ff       	call   801c77 <nsipc>
}
  801d76:	c9                   	leave  
  801d77:	c3                   	ret    

00801d78 <nsipc_close>:

int
nsipc_close(int s)
{
  801d78:	f3 0f 1e fb          	endbr32 
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d82:	8b 45 08             	mov    0x8(%ebp),%eax
  801d85:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d8a:	b8 04 00 00 00       	mov    $0x4,%eax
  801d8f:	e8 e3 fe ff ff       	call   801c77 <nsipc>
}
  801d94:	c9                   	leave  
  801d95:	c3                   	ret    

00801d96 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d96:	f3 0f 1e fb          	endbr32 
  801d9a:	55                   	push   %ebp
  801d9b:	89 e5                	mov    %esp,%ebp
  801d9d:	53                   	push   %ebx
  801d9e:	83 ec 08             	sub    $0x8,%esp
  801da1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801da4:	8b 45 08             	mov    0x8(%ebp),%eax
  801da7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801dac:	53                   	push   %ebx
  801dad:	ff 75 0c             	pushl  0xc(%ebp)
  801db0:	68 04 60 80 00       	push   $0x806004
  801db5:	e8 0f ef ff ff       	call   800cc9 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801dba:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801dc0:	b8 05 00 00 00       	mov    $0x5,%eax
  801dc5:	e8 ad fe ff ff       	call   801c77 <nsipc>
}
  801dca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dcd:	c9                   	leave  
  801dce:	c3                   	ret    

00801dcf <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801dcf:	f3 0f 1e fb          	endbr32 
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801de1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de4:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801de9:	b8 06 00 00 00       	mov    $0x6,%eax
  801dee:	e8 84 fe ff ff       	call   801c77 <nsipc>
}
  801df3:	c9                   	leave  
  801df4:	c3                   	ret    

00801df5 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801df5:	f3 0f 1e fb          	endbr32 
  801df9:	55                   	push   %ebp
  801dfa:	89 e5                	mov    %esp,%ebp
  801dfc:	56                   	push   %esi
  801dfd:	53                   	push   %ebx
  801dfe:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e01:	8b 45 08             	mov    0x8(%ebp),%eax
  801e04:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e09:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e0f:	8b 45 14             	mov    0x14(%ebp),%eax
  801e12:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e17:	b8 07 00 00 00       	mov    $0x7,%eax
  801e1c:	e8 56 fe ff ff       	call   801c77 <nsipc>
  801e21:	89 c3                	mov    %eax,%ebx
  801e23:	85 c0                	test   %eax,%eax
  801e25:	78 26                	js     801e4d <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801e27:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801e2d:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801e32:	0f 4e c6             	cmovle %esi,%eax
  801e35:	39 c3                	cmp    %eax,%ebx
  801e37:	7f 1d                	jg     801e56 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e39:	83 ec 04             	sub    $0x4,%esp
  801e3c:	53                   	push   %ebx
  801e3d:	68 00 60 80 00       	push   $0x806000
  801e42:	ff 75 0c             	pushl  0xc(%ebp)
  801e45:	e8 7f ee ff ff       	call   800cc9 <memmove>
  801e4a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e4d:	89 d8                	mov    %ebx,%eax
  801e4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e52:	5b                   	pop    %ebx
  801e53:	5e                   	pop    %esi
  801e54:	5d                   	pop    %ebp
  801e55:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801e56:	68 ff 2a 80 00       	push   $0x802aff
  801e5b:	68 67 2a 80 00       	push   $0x802a67
  801e60:	6a 62                	push   $0x62
  801e62:	68 14 2b 80 00       	push   $0x802b14
  801e67:	e8 7a e4 ff ff       	call   8002e6 <_panic>

00801e6c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e6c:	f3 0f 1e fb          	endbr32 
  801e70:	55                   	push   %ebp
  801e71:	89 e5                	mov    %esp,%ebp
  801e73:	53                   	push   %ebx
  801e74:	83 ec 04             	sub    $0x4,%esp
  801e77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7d:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e82:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e88:	7f 2e                	jg     801eb8 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e8a:	83 ec 04             	sub    $0x4,%esp
  801e8d:	53                   	push   %ebx
  801e8e:	ff 75 0c             	pushl  0xc(%ebp)
  801e91:	68 0c 60 80 00       	push   $0x80600c
  801e96:	e8 2e ee ff ff       	call   800cc9 <memmove>
	nsipcbuf.send.req_size = size;
  801e9b:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ea1:	8b 45 14             	mov    0x14(%ebp),%eax
  801ea4:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ea9:	b8 08 00 00 00       	mov    $0x8,%eax
  801eae:	e8 c4 fd ff ff       	call   801c77 <nsipc>
}
  801eb3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eb6:	c9                   	leave  
  801eb7:	c3                   	ret    
	assert(size < 1600);
  801eb8:	68 20 2b 80 00       	push   $0x802b20
  801ebd:	68 67 2a 80 00       	push   $0x802a67
  801ec2:	6a 6d                	push   $0x6d
  801ec4:	68 14 2b 80 00       	push   $0x802b14
  801ec9:	e8 18 e4 ff ff       	call   8002e6 <_panic>

00801ece <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ece:	f3 0f 1e fb          	endbr32 
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ed8:	8b 45 08             	mov    0x8(%ebp),%eax
  801edb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ee0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee3:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ee8:	8b 45 10             	mov    0x10(%ebp),%eax
  801eeb:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ef0:	b8 09 00 00 00       	mov    $0x9,%eax
  801ef5:	e8 7d fd ff ff       	call   801c77 <nsipc>
}
  801efa:	c9                   	leave  
  801efb:	c3                   	ret    

00801efc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801efc:	f3 0f 1e fb          	endbr32 
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	56                   	push   %esi
  801f04:	53                   	push   %ebx
  801f05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f08:	83 ec 0c             	sub    $0xc,%esp
  801f0b:	ff 75 08             	pushl  0x8(%ebp)
  801f0e:	e8 cc f1 ff ff       	call   8010df <fd2data>
  801f13:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f15:	83 c4 08             	add    $0x8,%esp
  801f18:	68 2c 2b 80 00       	push   $0x802b2c
  801f1d:	53                   	push   %ebx
  801f1e:	e8 a8 eb ff ff       	call   800acb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f23:	8b 46 04             	mov    0x4(%esi),%eax
  801f26:	2b 06                	sub    (%esi),%eax
  801f28:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f2e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f35:	00 00 00 
	stat->st_dev = &devpipe;
  801f38:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801f3f:	30 80 00 
	return 0;
}
  801f42:	b8 00 00 00 00       	mov    $0x0,%eax
  801f47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f4a:	5b                   	pop    %ebx
  801f4b:	5e                   	pop    %esi
  801f4c:	5d                   	pop    %ebp
  801f4d:	c3                   	ret    

00801f4e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f4e:	f3 0f 1e fb          	endbr32 
  801f52:	55                   	push   %ebp
  801f53:	89 e5                	mov    %esp,%ebp
  801f55:	53                   	push   %ebx
  801f56:	83 ec 0c             	sub    $0xc,%esp
  801f59:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f5c:	53                   	push   %ebx
  801f5d:	6a 00                	push   $0x0
  801f5f:	e8 1b f0 ff ff       	call   800f7f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f64:	89 1c 24             	mov    %ebx,(%esp)
  801f67:	e8 73 f1 ff ff       	call   8010df <fd2data>
  801f6c:	83 c4 08             	add    $0x8,%esp
  801f6f:	50                   	push   %eax
  801f70:	6a 00                	push   $0x0
  801f72:	e8 08 f0 ff ff       	call   800f7f <sys_page_unmap>
}
  801f77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f7a:	c9                   	leave  
  801f7b:	c3                   	ret    

00801f7c <_pipeisclosed>:
{
  801f7c:	55                   	push   %ebp
  801f7d:	89 e5                	mov    %esp,%ebp
  801f7f:	57                   	push   %edi
  801f80:	56                   	push   %esi
  801f81:	53                   	push   %ebx
  801f82:	83 ec 1c             	sub    $0x1c,%esp
  801f85:	89 c7                	mov    %eax,%edi
  801f87:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801f89:	a1 08 44 80 00       	mov    0x804408,%eax
  801f8e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f91:	83 ec 0c             	sub    $0xc,%esp
  801f94:	57                   	push   %edi
  801f95:	e8 ca 03 00 00       	call   802364 <pageref>
  801f9a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f9d:	89 34 24             	mov    %esi,(%esp)
  801fa0:	e8 bf 03 00 00       	call   802364 <pageref>
		nn = thisenv->env_runs;
  801fa5:	8b 15 08 44 80 00    	mov    0x804408,%edx
  801fab:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fae:	83 c4 10             	add    $0x10,%esp
  801fb1:	39 cb                	cmp    %ecx,%ebx
  801fb3:	74 1b                	je     801fd0 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801fb5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801fb8:	75 cf                	jne    801f89 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fba:	8b 42 58             	mov    0x58(%edx),%eax
  801fbd:	6a 01                	push   $0x1
  801fbf:	50                   	push   %eax
  801fc0:	53                   	push   %ebx
  801fc1:	68 33 2b 80 00       	push   $0x802b33
  801fc6:	e8 02 e4 ff ff       	call   8003cd <cprintf>
  801fcb:	83 c4 10             	add    $0x10,%esp
  801fce:	eb b9                	jmp    801f89 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801fd0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801fd3:	0f 94 c0             	sete   %al
  801fd6:	0f b6 c0             	movzbl %al,%eax
}
  801fd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fdc:	5b                   	pop    %ebx
  801fdd:	5e                   	pop    %esi
  801fde:	5f                   	pop    %edi
  801fdf:	5d                   	pop    %ebp
  801fe0:	c3                   	ret    

00801fe1 <devpipe_write>:
{
  801fe1:	f3 0f 1e fb          	endbr32 
  801fe5:	55                   	push   %ebp
  801fe6:	89 e5                	mov    %esp,%ebp
  801fe8:	57                   	push   %edi
  801fe9:	56                   	push   %esi
  801fea:	53                   	push   %ebx
  801feb:	83 ec 28             	sub    $0x28,%esp
  801fee:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ff1:	56                   	push   %esi
  801ff2:	e8 e8 f0 ff ff       	call   8010df <fd2data>
  801ff7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ff9:	83 c4 10             	add    $0x10,%esp
  801ffc:	bf 00 00 00 00       	mov    $0x0,%edi
  802001:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802004:	74 4f                	je     802055 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802006:	8b 43 04             	mov    0x4(%ebx),%eax
  802009:	8b 0b                	mov    (%ebx),%ecx
  80200b:	8d 51 20             	lea    0x20(%ecx),%edx
  80200e:	39 d0                	cmp    %edx,%eax
  802010:	72 14                	jb     802026 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  802012:	89 da                	mov    %ebx,%edx
  802014:	89 f0                	mov    %esi,%eax
  802016:	e8 61 ff ff ff       	call   801f7c <_pipeisclosed>
  80201b:	85 c0                	test   %eax,%eax
  80201d:	75 3b                	jne    80205a <devpipe_write+0x79>
			sys_yield();
  80201f:	e8 ed ee ff ff       	call   800f11 <sys_yield>
  802024:	eb e0                	jmp    802006 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802026:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802029:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80202d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802030:	89 c2                	mov    %eax,%edx
  802032:	c1 fa 1f             	sar    $0x1f,%edx
  802035:	89 d1                	mov    %edx,%ecx
  802037:	c1 e9 1b             	shr    $0x1b,%ecx
  80203a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80203d:	83 e2 1f             	and    $0x1f,%edx
  802040:	29 ca                	sub    %ecx,%edx
  802042:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802046:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80204a:	83 c0 01             	add    $0x1,%eax
  80204d:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802050:	83 c7 01             	add    $0x1,%edi
  802053:	eb ac                	jmp    802001 <devpipe_write+0x20>
	return i;
  802055:	8b 45 10             	mov    0x10(%ebp),%eax
  802058:	eb 05                	jmp    80205f <devpipe_write+0x7e>
				return 0;
  80205a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80205f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802062:	5b                   	pop    %ebx
  802063:	5e                   	pop    %esi
  802064:	5f                   	pop    %edi
  802065:	5d                   	pop    %ebp
  802066:	c3                   	ret    

00802067 <devpipe_read>:
{
  802067:	f3 0f 1e fb          	endbr32 
  80206b:	55                   	push   %ebp
  80206c:	89 e5                	mov    %esp,%ebp
  80206e:	57                   	push   %edi
  80206f:	56                   	push   %esi
  802070:	53                   	push   %ebx
  802071:	83 ec 18             	sub    $0x18,%esp
  802074:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802077:	57                   	push   %edi
  802078:	e8 62 f0 ff ff       	call   8010df <fd2data>
  80207d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80207f:	83 c4 10             	add    $0x10,%esp
  802082:	be 00 00 00 00       	mov    $0x0,%esi
  802087:	3b 75 10             	cmp    0x10(%ebp),%esi
  80208a:	75 14                	jne    8020a0 <devpipe_read+0x39>
	return i;
  80208c:	8b 45 10             	mov    0x10(%ebp),%eax
  80208f:	eb 02                	jmp    802093 <devpipe_read+0x2c>
				return i;
  802091:	89 f0                	mov    %esi,%eax
}
  802093:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802096:	5b                   	pop    %ebx
  802097:	5e                   	pop    %esi
  802098:	5f                   	pop    %edi
  802099:	5d                   	pop    %ebp
  80209a:	c3                   	ret    
			sys_yield();
  80209b:	e8 71 ee ff ff       	call   800f11 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8020a0:	8b 03                	mov    (%ebx),%eax
  8020a2:	3b 43 04             	cmp    0x4(%ebx),%eax
  8020a5:	75 18                	jne    8020bf <devpipe_read+0x58>
			if (i > 0)
  8020a7:	85 f6                	test   %esi,%esi
  8020a9:	75 e6                	jne    802091 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8020ab:	89 da                	mov    %ebx,%edx
  8020ad:	89 f8                	mov    %edi,%eax
  8020af:	e8 c8 fe ff ff       	call   801f7c <_pipeisclosed>
  8020b4:	85 c0                	test   %eax,%eax
  8020b6:	74 e3                	je     80209b <devpipe_read+0x34>
				return 0;
  8020b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8020bd:	eb d4                	jmp    802093 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020bf:	99                   	cltd   
  8020c0:	c1 ea 1b             	shr    $0x1b,%edx
  8020c3:	01 d0                	add    %edx,%eax
  8020c5:	83 e0 1f             	and    $0x1f,%eax
  8020c8:	29 d0                	sub    %edx,%eax
  8020ca:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8020cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020d2:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8020d5:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8020d8:	83 c6 01             	add    $0x1,%esi
  8020db:	eb aa                	jmp    802087 <devpipe_read+0x20>

008020dd <pipe>:
{
  8020dd:	f3 0f 1e fb          	endbr32 
  8020e1:	55                   	push   %ebp
  8020e2:	89 e5                	mov    %esp,%ebp
  8020e4:	56                   	push   %esi
  8020e5:	53                   	push   %ebx
  8020e6:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8020e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ec:	50                   	push   %eax
  8020ed:	e8 08 f0 ff ff       	call   8010fa <fd_alloc>
  8020f2:	89 c3                	mov    %eax,%ebx
  8020f4:	83 c4 10             	add    $0x10,%esp
  8020f7:	85 c0                	test   %eax,%eax
  8020f9:	0f 88 23 01 00 00    	js     802222 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ff:	83 ec 04             	sub    $0x4,%esp
  802102:	68 07 04 00 00       	push   $0x407
  802107:	ff 75 f4             	pushl  -0xc(%ebp)
  80210a:	6a 00                	push   $0x0
  80210c:	e8 23 ee ff ff       	call   800f34 <sys_page_alloc>
  802111:	89 c3                	mov    %eax,%ebx
  802113:	83 c4 10             	add    $0x10,%esp
  802116:	85 c0                	test   %eax,%eax
  802118:	0f 88 04 01 00 00    	js     802222 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  80211e:	83 ec 0c             	sub    $0xc,%esp
  802121:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802124:	50                   	push   %eax
  802125:	e8 d0 ef ff ff       	call   8010fa <fd_alloc>
  80212a:	89 c3                	mov    %eax,%ebx
  80212c:	83 c4 10             	add    $0x10,%esp
  80212f:	85 c0                	test   %eax,%eax
  802131:	0f 88 db 00 00 00    	js     802212 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802137:	83 ec 04             	sub    $0x4,%esp
  80213a:	68 07 04 00 00       	push   $0x407
  80213f:	ff 75 f0             	pushl  -0x10(%ebp)
  802142:	6a 00                	push   $0x0
  802144:	e8 eb ed ff ff       	call   800f34 <sys_page_alloc>
  802149:	89 c3                	mov    %eax,%ebx
  80214b:	83 c4 10             	add    $0x10,%esp
  80214e:	85 c0                	test   %eax,%eax
  802150:	0f 88 bc 00 00 00    	js     802212 <pipe+0x135>
	va = fd2data(fd0);
  802156:	83 ec 0c             	sub    $0xc,%esp
  802159:	ff 75 f4             	pushl  -0xc(%ebp)
  80215c:	e8 7e ef ff ff       	call   8010df <fd2data>
  802161:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802163:	83 c4 0c             	add    $0xc,%esp
  802166:	68 07 04 00 00       	push   $0x407
  80216b:	50                   	push   %eax
  80216c:	6a 00                	push   $0x0
  80216e:	e8 c1 ed ff ff       	call   800f34 <sys_page_alloc>
  802173:	89 c3                	mov    %eax,%ebx
  802175:	83 c4 10             	add    $0x10,%esp
  802178:	85 c0                	test   %eax,%eax
  80217a:	0f 88 82 00 00 00    	js     802202 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802180:	83 ec 0c             	sub    $0xc,%esp
  802183:	ff 75 f0             	pushl  -0x10(%ebp)
  802186:	e8 54 ef ff ff       	call   8010df <fd2data>
  80218b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802192:	50                   	push   %eax
  802193:	6a 00                	push   $0x0
  802195:	56                   	push   %esi
  802196:	6a 00                	push   $0x0
  802198:	e8 bd ed ff ff       	call   800f5a <sys_page_map>
  80219d:	89 c3                	mov    %eax,%ebx
  80219f:	83 c4 20             	add    $0x20,%esp
  8021a2:	85 c0                	test   %eax,%eax
  8021a4:	78 4e                	js     8021f4 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8021a6:	a1 7c 30 80 00       	mov    0x80307c,%eax
  8021ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021ae:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8021b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021b3:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8021ba:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021bd:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8021bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021c2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8021c9:	83 ec 0c             	sub    $0xc,%esp
  8021cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8021cf:	e8 f7 ee ff ff       	call   8010cb <fd2num>
  8021d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021d7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021d9:	83 c4 04             	add    $0x4,%esp
  8021dc:	ff 75 f0             	pushl  -0x10(%ebp)
  8021df:	e8 e7 ee ff ff       	call   8010cb <fd2num>
  8021e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021e7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021ea:	83 c4 10             	add    $0x10,%esp
  8021ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021f2:	eb 2e                	jmp    802222 <pipe+0x145>
	sys_page_unmap(0, va);
  8021f4:	83 ec 08             	sub    $0x8,%esp
  8021f7:	56                   	push   %esi
  8021f8:	6a 00                	push   $0x0
  8021fa:	e8 80 ed ff ff       	call   800f7f <sys_page_unmap>
  8021ff:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802202:	83 ec 08             	sub    $0x8,%esp
  802205:	ff 75 f0             	pushl  -0x10(%ebp)
  802208:	6a 00                	push   $0x0
  80220a:	e8 70 ed ff ff       	call   800f7f <sys_page_unmap>
  80220f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802212:	83 ec 08             	sub    $0x8,%esp
  802215:	ff 75 f4             	pushl  -0xc(%ebp)
  802218:	6a 00                	push   $0x0
  80221a:	e8 60 ed ff ff       	call   800f7f <sys_page_unmap>
  80221f:	83 c4 10             	add    $0x10,%esp
}
  802222:	89 d8                	mov    %ebx,%eax
  802224:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802227:	5b                   	pop    %ebx
  802228:	5e                   	pop    %esi
  802229:	5d                   	pop    %ebp
  80222a:	c3                   	ret    

0080222b <pipeisclosed>:
{
  80222b:	f3 0f 1e fb          	endbr32 
  80222f:	55                   	push   %ebp
  802230:	89 e5                	mov    %esp,%ebp
  802232:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802235:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802238:	50                   	push   %eax
  802239:	ff 75 08             	pushl  0x8(%ebp)
  80223c:	e8 0f ef ff ff       	call   801150 <fd_lookup>
  802241:	83 c4 10             	add    $0x10,%esp
  802244:	85 c0                	test   %eax,%eax
  802246:	78 18                	js     802260 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  802248:	83 ec 0c             	sub    $0xc,%esp
  80224b:	ff 75 f4             	pushl  -0xc(%ebp)
  80224e:	e8 8c ee ff ff       	call   8010df <fd2data>
  802253:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802255:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802258:	e8 1f fd ff ff       	call   801f7c <_pipeisclosed>
  80225d:	83 c4 10             	add    $0x10,%esp
}
  802260:	c9                   	leave  
  802261:	c3                   	ret    

00802262 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802262:	f3 0f 1e fb          	endbr32 
  802266:	55                   	push   %ebp
  802267:	89 e5                	mov    %esp,%ebp
  802269:	56                   	push   %esi
  80226a:	53                   	push   %ebx
  80226b:	8b 75 08             	mov    0x8(%ebp),%esi
  80226e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802271:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  802274:	85 c0                	test   %eax,%eax
  802276:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80227b:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  80227e:	83 ec 0c             	sub    $0xc,%esp
  802281:	50                   	push   %eax
  802282:	e8 b3 ed ff ff       	call   80103a <sys_ipc_recv>
  802287:	83 c4 10             	add    $0x10,%esp
  80228a:	85 c0                	test   %eax,%eax
  80228c:	75 2b                	jne    8022b9 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  80228e:	85 f6                	test   %esi,%esi
  802290:	74 0a                	je     80229c <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  802292:	a1 08 44 80 00       	mov    0x804408,%eax
  802297:	8b 40 74             	mov    0x74(%eax),%eax
  80229a:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  80229c:	85 db                	test   %ebx,%ebx
  80229e:	74 0a                	je     8022aa <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  8022a0:	a1 08 44 80 00       	mov    0x804408,%eax
  8022a5:	8b 40 78             	mov    0x78(%eax),%eax
  8022a8:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  8022aa:	a1 08 44 80 00       	mov    0x804408,%eax
  8022af:	8b 40 70             	mov    0x70(%eax),%eax
}
  8022b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022b5:	5b                   	pop    %ebx
  8022b6:	5e                   	pop    %esi
  8022b7:	5d                   	pop    %ebp
  8022b8:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  8022b9:	85 f6                	test   %esi,%esi
  8022bb:	74 06                	je     8022c3 <ipc_recv+0x61>
  8022bd:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8022c3:	85 db                	test   %ebx,%ebx
  8022c5:	74 eb                	je     8022b2 <ipc_recv+0x50>
  8022c7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8022cd:	eb e3                	jmp    8022b2 <ipc_recv+0x50>

008022cf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022cf:	f3 0f 1e fb          	endbr32 
  8022d3:	55                   	push   %ebp
  8022d4:	89 e5                	mov    %esp,%ebp
  8022d6:	57                   	push   %edi
  8022d7:	56                   	push   %esi
  8022d8:	53                   	push   %ebx
  8022d9:	83 ec 0c             	sub    $0xc,%esp
  8022dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022df:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  8022e5:	85 db                	test   %ebx,%ebx
  8022e7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8022ec:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8022ef:	ff 75 14             	pushl  0x14(%ebp)
  8022f2:	53                   	push   %ebx
  8022f3:	56                   	push   %esi
  8022f4:	57                   	push   %edi
  8022f5:	e8 19 ed ff ff       	call   801013 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  8022fa:	83 c4 10             	add    $0x10,%esp
  8022fd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802300:	75 07                	jne    802309 <ipc_send+0x3a>
			sys_yield();
  802302:	e8 0a ec ff ff       	call   800f11 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802307:	eb e6                	jmp    8022ef <ipc_send+0x20>
		}
		else if (ret == 0)
  802309:	85 c0                	test   %eax,%eax
  80230b:	75 08                	jne    802315 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  80230d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802310:	5b                   	pop    %ebx
  802311:	5e                   	pop    %esi
  802312:	5f                   	pop    %edi
  802313:	5d                   	pop    %ebp
  802314:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802315:	50                   	push   %eax
  802316:	68 4b 2b 80 00       	push   $0x802b4b
  80231b:	6a 48                	push   $0x48
  80231d:	68 59 2b 80 00       	push   $0x802b59
  802322:	e8 bf df ff ff       	call   8002e6 <_panic>

00802327 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802327:	f3 0f 1e fb          	endbr32 
  80232b:	55                   	push   %ebp
  80232c:	89 e5                	mov    %esp,%ebp
  80232e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802331:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802336:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802339:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80233f:	8b 52 50             	mov    0x50(%edx),%edx
  802342:	39 ca                	cmp    %ecx,%edx
  802344:	74 11                	je     802357 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802346:	83 c0 01             	add    $0x1,%eax
  802349:	3d 00 04 00 00       	cmp    $0x400,%eax
  80234e:	75 e6                	jne    802336 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802350:	b8 00 00 00 00       	mov    $0x0,%eax
  802355:	eb 0b                	jmp    802362 <ipc_find_env+0x3b>
			return envs[i].env_id;
  802357:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80235a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80235f:	8b 40 48             	mov    0x48(%eax),%eax
}
  802362:	5d                   	pop    %ebp
  802363:	c3                   	ret    

00802364 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802364:	f3 0f 1e fb          	endbr32 
  802368:	55                   	push   %ebp
  802369:	89 e5                	mov    %esp,%ebp
  80236b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80236e:	89 c2                	mov    %eax,%edx
  802370:	c1 ea 16             	shr    $0x16,%edx
  802373:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80237a:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80237f:	f6 c1 01             	test   $0x1,%cl
  802382:	74 1c                	je     8023a0 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802384:	c1 e8 0c             	shr    $0xc,%eax
  802387:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80238e:	a8 01                	test   $0x1,%al
  802390:	74 0e                	je     8023a0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802392:	c1 e8 0c             	shr    $0xc,%eax
  802395:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80239c:	ef 
  80239d:	0f b7 d2             	movzwl %dx,%edx
}
  8023a0:	89 d0                	mov    %edx,%eax
  8023a2:	5d                   	pop    %ebp
  8023a3:	c3                   	ret    
  8023a4:	66 90                	xchg   %ax,%ax
  8023a6:	66 90                	xchg   %ax,%ax
  8023a8:	66 90                	xchg   %ax,%ax
  8023aa:	66 90                	xchg   %ax,%ax
  8023ac:	66 90                	xchg   %ax,%ax
  8023ae:	66 90                	xchg   %ax,%ax

008023b0 <__udivdi3>:
  8023b0:	f3 0f 1e fb          	endbr32 
  8023b4:	55                   	push   %ebp
  8023b5:	57                   	push   %edi
  8023b6:	56                   	push   %esi
  8023b7:	53                   	push   %ebx
  8023b8:	83 ec 1c             	sub    $0x1c,%esp
  8023bb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8023bf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8023c3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023c7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8023cb:	85 d2                	test   %edx,%edx
  8023cd:	75 19                	jne    8023e8 <__udivdi3+0x38>
  8023cf:	39 f3                	cmp    %esi,%ebx
  8023d1:	76 4d                	jbe    802420 <__udivdi3+0x70>
  8023d3:	31 ff                	xor    %edi,%edi
  8023d5:	89 e8                	mov    %ebp,%eax
  8023d7:	89 f2                	mov    %esi,%edx
  8023d9:	f7 f3                	div    %ebx
  8023db:	89 fa                	mov    %edi,%edx
  8023dd:	83 c4 1c             	add    $0x1c,%esp
  8023e0:	5b                   	pop    %ebx
  8023e1:	5e                   	pop    %esi
  8023e2:	5f                   	pop    %edi
  8023e3:	5d                   	pop    %ebp
  8023e4:	c3                   	ret    
  8023e5:	8d 76 00             	lea    0x0(%esi),%esi
  8023e8:	39 f2                	cmp    %esi,%edx
  8023ea:	76 14                	jbe    802400 <__udivdi3+0x50>
  8023ec:	31 ff                	xor    %edi,%edi
  8023ee:	31 c0                	xor    %eax,%eax
  8023f0:	89 fa                	mov    %edi,%edx
  8023f2:	83 c4 1c             	add    $0x1c,%esp
  8023f5:	5b                   	pop    %ebx
  8023f6:	5e                   	pop    %esi
  8023f7:	5f                   	pop    %edi
  8023f8:	5d                   	pop    %ebp
  8023f9:	c3                   	ret    
  8023fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802400:	0f bd fa             	bsr    %edx,%edi
  802403:	83 f7 1f             	xor    $0x1f,%edi
  802406:	75 48                	jne    802450 <__udivdi3+0xa0>
  802408:	39 f2                	cmp    %esi,%edx
  80240a:	72 06                	jb     802412 <__udivdi3+0x62>
  80240c:	31 c0                	xor    %eax,%eax
  80240e:	39 eb                	cmp    %ebp,%ebx
  802410:	77 de                	ja     8023f0 <__udivdi3+0x40>
  802412:	b8 01 00 00 00       	mov    $0x1,%eax
  802417:	eb d7                	jmp    8023f0 <__udivdi3+0x40>
  802419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802420:	89 d9                	mov    %ebx,%ecx
  802422:	85 db                	test   %ebx,%ebx
  802424:	75 0b                	jne    802431 <__udivdi3+0x81>
  802426:	b8 01 00 00 00       	mov    $0x1,%eax
  80242b:	31 d2                	xor    %edx,%edx
  80242d:	f7 f3                	div    %ebx
  80242f:	89 c1                	mov    %eax,%ecx
  802431:	31 d2                	xor    %edx,%edx
  802433:	89 f0                	mov    %esi,%eax
  802435:	f7 f1                	div    %ecx
  802437:	89 c6                	mov    %eax,%esi
  802439:	89 e8                	mov    %ebp,%eax
  80243b:	89 f7                	mov    %esi,%edi
  80243d:	f7 f1                	div    %ecx
  80243f:	89 fa                	mov    %edi,%edx
  802441:	83 c4 1c             	add    $0x1c,%esp
  802444:	5b                   	pop    %ebx
  802445:	5e                   	pop    %esi
  802446:	5f                   	pop    %edi
  802447:	5d                   	pop    %ebp
  802448:	c3                   	ret    
  802449:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802450:	89 f9                	mov    %edi,%ecx
  802452:	b8 20 00 00 00       	mov    $0x20,%eax
  802457:	29 f8                	sub    %edi,%eax
  802459:	d3 e2                	shl    %cl,%edx
  80245b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80245f:	89 c1                	mov    %eax,%ecx
  802461:	89 da                	mov    %ebx,%edx
  802463:	d3 ea                	shr    %cl,%edx
  802465:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802469:	09 d1                	or     %edx,%ecx
  80246b:	89 f2                	mov    %esi,%edx
  80246d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802471:	89 f9                	mov    %edi,%ecx
  802473:	d3 e3                	shl    %cl,%ebx
  802475:	89 c1                	mov    %eax,%ecx
  802477:	d3 ea                	shr    %cl,%edx
  802479:	89 f9                	mov    %edi,%ecx
  80247b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80247f:	89 eb                	mov    %ebp,%ebx
  802481:	d3 e6                	shl    %cl,%esi
  802483:	89 c1                	mov    %eax,%ecx
  802485:	d3 eb                	shr    %cl,%ebx
  802487:	09 de                	or     %ebx,%esi
  802489:	89 f0                	mov    %esi,%eax
  80248b:	f7 74 24 08          	divl   0x8(%esp)
  80248f:	89 d6                	mov    %edx,%esi
  802491:	89 c3                	mov    %eax,%ebx
  802493:	f7 64 24 0c          	mull   0xc(%esp)
  802497:	39 d6                	cmp    %edx,%esi
  802499:	72 15                	jb     8024b0 <__udivdi3+0x100>
  80249b:	89 f9                	mov    %edi,%ecx
  80249d:	d3 e5                	shl    %cl,%ebp
  80249f:	39 c5                	cmp    %eax,%ebp
  8024a1:	73 04                	jae    8024a7 <__udivdi3+0xf7>
  8024a3:	39 d6                	cmp    %edx,%esi
  8024a5:	74 09                	je     8024b0 <__udivdi3+0x100>
  8024a7:	89 d8                	mov    %ebx,%eax
  8024a9:	31 ff                	xor    %edi,%edi
  8024ab:	e9 40 ff ff ff       	jmp    8023f0 <__udivdi3+0x40>
  8024b0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8024b3:	31 ff                	xor    %edi,%edi
  8024b5:	e9 36 ff ff ff       	jmp    8023f0 <__udivdi3+0x40>
  8024ba:	66 90                	xchg   %ax,%ax
  8024bc:	66 90                	xchg   %ax,%ax
  8024be:	66 90                	xchg   %ax,%ax

008024c0 <__umoddi3>:
  8024c0:	f3 0f 1e fb          	endbr32 
  8024c4:	55                   	push   %ebp
  8024c5:	57                   	push   %edi
  8024c6:	56                   	push   %esi
  8024c7:	53                   	push   %ebx
  8024c8:	83 ec 1c             	sub    $0x1c,%esp
  8024cb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8024cf:	8b 74 24 30          	mov    0x30(%esp),%esi
  8024d3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8024d7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024db:	85 c0                	test   %eax,%eax
  8024dd:	75 19                	jne    8024f8 <__umoddi3+0x38>
  8024df:	39 df                	cmp    %ebx,%edi
  8024e1:	76 5d                	jbe    802540 <__umoddi3+0x80>
  8024e3:	89 f0                	mov    %esi,%eax
  8024e5:	89 da                	mov    %ebx,%edx
  8024e7:	f7 f7                	div    %edi
  8024e9:	89 d0                	mov    %edx,%eax
  8024eb:	31 d2                	xor    %edx,%edx
  8024ed:	83 c4 1c             	add    $0x1c,%esp
  8024f0:	5b                   	pop    %ebx
  8024f1:	5e                   	pop    %esi
  8024f2:	5f                   	pop    %edi
  8024f3:	5d                   	pop    %ebp
  8024f4:	c3                   	ret    
  8024f5:	8d 76 00             	lea    0x0(%esi),%esi
  8024f8:	89 f2                	mov    %esi,%edx
  8024fa:	39 d8                	cmp    %ebx,%eax
  8024fc:	76 12                	jbe    802510 <__umoddi3+0x50>
  8024fe:	89 f0                	mov    %esi,%eax
  802500:	89 da                	mov    %ebx,%edx
  802502:	83 c4 1c             	add    $0x1c,%esp
  802505:	5b                   	pop    %ebx
  802506:	5e                   	pop    %esi
  802507:	5f                   	pop    %edi
  802508:	5d                   	pop    %ebp
  802509:	c3                   	ret    
  80250a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802510:	0f bd e8             	bsr    %eax,%ebp
  802513:	83 f5 1f             	xor    $0x1f,%ebp
  802516:	75 50                	jne    802568 <__umoddi3+0xa8>
  802518:	39 d8                	cmp    %ebx,%eax
  80251a:	0f 82 e0 00 00 00    	jb     802600 <__umoddi3+0x140>
  802520:	89 d9                	mov    %ebx,%ecx
  802522:	39 f7                	cmp    %esi,%edi
  802524:	0f 86 d6 00 00 00    	jbe    802600 <__umoddi3+0x140>
  80252a:	89 d0                	mov    %edx,%eax
  80252c:	89 ca                	mov    %ecx,%edx
  80252e:	83 c4 1c             	add    $0x1c,%esp
  802531:	5b                   	pop    %ebx
  802532:	5e                   	pop    %esi
  802533:	5f                   	pop    %edi
  802534:	5d                   	pop    %ebp
  802535:	c3                   	ret    
  802536:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80253d:	8d 76 00             	lea    0x0(%esi),%esi
  802540:	89 fd                	mov    %edi,%ebp
  802542:	85 ff                	test   %edi,%edi
  802544:	75 0b                	jne    802551 <__umoddi3+0x91>
  802546:	b8 01 00 00 00       	mov    $0x1,%eax
  80254b:	31 d2                	xor    %edx,%edx
  80254d:	f7 f7                	div    %edi
  80254f:	89 c5                	mov    %eax,%ebp
  802551:	89 d8                	mov    %ebx,%eax
  802553:	31 d2                	xor    %edx,%edx
  802555:	f7 f5                	div    %ebp
  802557:	89 f0                	mov    %esi,%eax
  802559:	f7 f5                	div    %ebp
  80255b:	89 d0                	mov    %edx,%eax
  80255d:	31 d2                	xor    %edx,%edx
  80255f:	eb 8c                	jmp    8024ed <__umoddi3+0x2d>
  802561:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802568:	89 e9                	mov    %ebp,%ecx
  80256a:	ba 20 00 00 00       	mov    $0x20,%edx
  80256f:	29 ea                	sub    %ebp,%edx
  802571:	d3 e0                	shl    %cl,%eax
  802573:	89 44 24 08          	mov    %eax,0x8(%esp)
  802577:	89 d1                	mov    %edx,%ecx
  802579:	89 f8                	mov    %edi,%eax
  80257b:	d3 e8                	shr    %cl,%eax
  80257d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802581:	89 54 24 04          	mov    %edx,0x4(%esp)
  802585:	8b 54 24 04          	mov    0x4(%esp),%edx
  802589:	09 c1                	or     %eax,%ecx
  80258b:	89 d8                	mov    %ebx,%eax
  80258d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802591:	89 e9                	mov    %ebp,%ecx
  802593:	d3 e7                	shl    %cl,%edi
  802595:	89 d1                	mov    %edx,%ecx
  802597:	d3 e8                	shr    %cl,%eax
  802599:	89 e9                	mov    %ebp,%ecx
  80259b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80259f:	d3 e3                	shl    %cl,%ebx
  8025a1:	89 c7                	mov    %eax,%edi
  8025a3:	89 d1                	mov    %edx,%ecx
  8025a5:	89 f0                	mov    %esi,%eax
  8025a7:	d3 e8                	shr    %cl,%eax
  8025a9:	89 e9                	mov    %ebp,%ecx
  8025ab:	89 fa                	mov    %edi,%edx
  8025ad:	d3 e6                	shl    %cl,%esi
  8025af:	09 d8                	or     %ebx,%eax
  8025b1:	f7 74 24 08          	divl   0x8(%esp)
  8025b5:	89 d1                	mov    %edx,%ecx
  8025b7:	89 f3                	mov    %esi,%ebx
  8025b9:	f7 64 24 0c          	mull   0xc(%esp)
  8025bd:	89 c6                	mov    %eax,%esi
  8025bf:	89 d7                	mov    %edx,%edi
  8025c1:	39 d1                	cmp    %edx,%ecx
  8025c3:	72 06                	jb     8025cb <__umoddi3+0x10b>
  8025c5:	75 10                	jne    8025d7 <__umoddi3+0x117>
  8025c7:	39 c3                	cmp    %eax,%ebx
  8025c9:	73 0c                	jae    8025d7 <__umoddi3+0x117>
  8025cb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8025cf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8025d3:	89 d7                	mov    %edx,%edi
  8025d5:	89 c6                	mov    %eax,%esi
  8025d7:	89 ca                	mov    %ecx,%edx
  8025d9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8025de:	29 f3                	sub    %esi,%ebx
  8025e0:	19 fa                	sbb    %edi,%edx
  8025e2:	89 d0                	mov    %edx,%eax
  8025e4:	d3 e0                	shl    %cl,%eax
  8025e6:	89 e9                	mov    %ebp,%ecx
  8025e8:	d3 eb                	shr    %cl,%ebx
  8025ea:	d3 ea                	shr    %cl,%edx
  8025ec:	09 d8                	or     %ebx,%eax
  8025ee:	83 c4 1c             	add    $0x1c,%esp
  8025f1:	5b                   	pop    %ebx
  8025f2:	5e                   	pop    %esi
  8025f3:	5f                   	pop    %edi
  8025f4:	5d                   	pop    %ebp
  8025f5:	c3                   	ret    
  8025f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025fd:	8d 76 00             	lea    0x0(%esi),%esi
  802600:	29 fe                	sub    %edi,%esi
  802602:	19 c3                	sbb    %eax,%ebx
  802604:	89 f2                	mov    %esi,%edx
  802606:	89 d9                	mov    %ebx,%ecx
  802608:	e9 1d ff ff ff       	jmp    80252a <__umoddi3+0x6a>
