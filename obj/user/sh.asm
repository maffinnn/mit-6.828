
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 0c 0a 00 00       	call   800a3d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 0c             	sub    $0xc,%esp
  800040:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800043:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int t;

	if (s == 0) {
  800046:	85 db                	test   %ebx,%ebx
  800048:	74 1a                	je     800064 <_gettoken+0x31>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
	}

	if (debug > 1)
  80004a:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  800051:	7f 31                	jg     800084 <_gettoken+0x51>
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
  800053:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	*p2 = 0;
  800059:	8b 45 10             	mov    0x10(%ebp),%eax
  80005c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  800062:	eb 3a                	jmp    80009e <_gettoken+0x6b>
		return 0;
  800064:	be 00 00 00 00       	mov    $0x0,%esi
		if (debug > 1)
  800069:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  800070:	7e 59                	jle    8000cb <_gettoken+0x98>
			cprintf("GETTOKEN NULL\n");
  800072:	83 ec 0c             	sub    $0xc,%esp
  800075:	68 e0 38 80 00       	push   $0x8038e0
  80007a:	e8 0d 0b 00 00       	call   800b8c <cprintf>
  80007f:	83 c4 10             	add    $0x10,%esp
  800082:	eb 47                	jmp    8000cb <_gettoken+0x98>
		cprintf("GETTOKEN: %s\n", s);
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	53                   	push   %ebx
  800088:	68 ef 38 80 00       	push   $0x8038ef
  80008d:	e8 fa 0a 00 00       	call   800b8c <cprintf>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	eb bc                	jmp    800053 <_gettoken+0x20>
		*s++ = 0;
  800097:	83 c3 01             	add    $0x1,%ebx
  80009a:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
	while (strchr(WHITESPACE, *s))
  80009e:	83 ec 08             	sub    $0x8,%esp
  8000a1:	0f be 03             	movsbl (%ebx),%eax
  8000a4:	50                   	push   %eax
  8000a5:	68 fd 38 80 00       	push   $0x8038fd
  8000aa:	e8 00 13 00 00       	call   8013af <strchr>
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	75 e1                	jne    800097 <_gettoken+0x64>
	if (*s == 0) {
  8000b6:	0f b6 03             	movzbl (%ebx),%eax
  8000b9:	84 c0                	test   %al,%al
  8000bb:	75 2a                	jne    8000e7 <_gettoken+0xb4>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000bd:	be 00 00 00 00       	mov    $0x0,%esi
		if (debug > 1)
  8000c2:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  8000c9:	7f 0a                	jg     8000d5 <_gettoken+0xa2>
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
}
  8000cb:	89 f0                	mov    %esi,%eax
  8000cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d0:	5b                   	pop    %ebx
  8000d1:	5e                   	pop    %esi
  8000d2:	5f                   	pop    %edi
  8000d3:	5d                   	pop    %ebp
  8000d4:	c3                   	ret    
			cprintf("EOL\n");
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	68 02 39 80 00       	push   $0x803902
  8000dd:	e8 aa 0a 00 00       	call   800b8c <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb e4                	jmp    8000cb <_gettoken+0x98>
	if (strchr(SYMBOLS, *s)) {
  8000e7:	83 ec 08             	sub    $0x8,%esp
  8000ea:	0f be c0             	movsbl %al,%eax
  8000ed:	50                   	push   %eax
  8000ee:	68 13 39 80 00       	push   $0x803913
  8000f3:	e8 b7 12 00 00       	call   8013af <strchr>
  8000f8:	83 c4 10             	add    $0x10,%esp
  8000fb:	85 c0                	test   %eax,%eax
  8000fd:	74 2c                	je     80012b <_gettoken+0xf8>
		t = *s;
  8000ff:	0f be 33             	movsbl (%ebx),%esi
		*p1 = s;
  800102:	89 1f                	mov    %ebx,(%edi)
		*s++ = 0;
  800104:	c6 03 00             	movb   $0x0,(%ebx)
  800107:	83 c3 01             	add    $0x1,%ebx
  80010a:	8b 45 10             	mov    0x10(%ebp),%eax
  80010d:	89 18                	mov    %ebx,(%eax)
		if (debug > 1)
  80010f:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  800116:	7e b3                	jle    8000cb <_gettoken+0x98>
			cprintf("TOK %c\n", t);
  800118:	83 ec 08             	sub    $0x8,%esp
  80011b:	56                   	push   %esi
  80011c:	68 07 39 80 00       	push   $0x803907
  800121:	e8 66 0a 00 00       	call   800b8c <cprintf>
  800126:	83 c4 10             	add    $0x10,%esp
  800129:	eb a0                	jmp    8000cb <_gettoken+0x98>
	*p1 = s;
  80012b:	89 1f                	mov    %ebx,(%edi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80012d:	eb 03                	jmp    800132 <_gettoken+0xff>
		s++;
  80012f:	83 c3 01             	add    $0x1,%ebx
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800132:	0f b6 03             	movzbl (%ebx),%eax
  800135:	84 c0                	test   %al,%al
  800137:	74 18                	je     800151 <_gettoken+0x11e>
  800139:	83 ec 08             	sub    $0x8,%esp
  80013c:	0f be c0             	movsbl %al,%eax
  80013f:	50                   	push   %eax
  800140:	68 0f 39 80 00       	push   $0x80390f
  800145:	e8 65 12 00 00       	call   8013af <strchr>
  80014a:	83 c4 10             	add    $0x10,%esp
  80014d:	85 c0                	test   %eax,%eax
  80014f:	74 de                	je     80012f <_gettoken+0xfc>
	*p2 = s;
  800151:	8b 45 10             	mov    0x10(%ebp),%eax
  800154:	89 18                	mov    %ebx,(%eax)
	return 'w';
  800156:	be 77 00 00 00       	mov    $0x77,%esi
	if (debug > 1) {
  80015b:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  800162:	0f 8e 63 ff ff ff    	jle    8000cb <_gettoken+0x98>
		t = **p2;
  800168:	0f b6 33             	movzbl (%ebx),%esi
		**p2 = 0;
  80016b:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  80016e:	83 ec 08             	sub    $0x8,%esp
  800171:	ff 37                	pushl  (%edi)
  800173:	68 1b 39 80 00       	push   $0x80391b
  800178:	e8 0f 0a 00 00       	call   800b8c <cprintf>
		**p2 = t;
  80017d:	8b 45 10             	mov    0x10(%ebp),%eax
  800180:	8b 00                	mov    (%eax),%eax
  800182:	89 f2                	mov    %esi,%edx
  800184:	88 10                	mov    %dl,(%eax)
  800186:	83 c4 10             	add    $0x10,%esp
	return 'w';
  800189:	be 77 00 00 00       	mov    $0x77,%esi
  80018e:	e9 38 ff ff ff       	jmp    8000cb <_gettoken+0x98>

00800193 <gettoken>:

int
gettoken(char *s, char **p1)
{
  800193:	f3 0f 1e fb          	endbr32 
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	83 ec 08             	sub    $0x8,%esp
  80019d:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001a0:	85 c0                	test   %eax,%eax
  8001a2:	74 22                	je     8001c6 <gettoken+0x33>
		nc = _gettoken(s, &np1, &np2);
  8001a4:	83 ec 04             	sub    $0x4,%esp
  8001a7:	68 0c 60 80 00       	push   $0x80600c
  8001ac:	68 10 60 80 00       	push   $0x806010
  8001b1:	50                   	push   %eax
  8001b2:	e8 7c fe ff ff       	call   800033 <_gettoken>
  8001b7:	a3 08 60 80 00       	mov    %eax,0x806008
		return 0;
  8001bc:	83 c4 10             	add    $0x10,%esp
  8001bf:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	c = nc;
	*p1 = np1;
	nc = _gettoken(np2, &np1, &np2);
	return c;
}
  8001c4:	c9                   	leave  
  8001c5:	c3                   	ret    
	c = nc;
  8001c6:	a1 08 60 80 00       	mov    0x806008,%eax
  8001cb:	a3 04 60 80 00       	mov    %eax,0x806004
	*p1 = np1;
  8001d0:	8b 15 10 60 80 00    	mov    0x806010,%edx
  8001d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d9:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001db:	83 ec 04             	sub    $0x4,%esp
  8001de:	68 0c 60 80 00       	push   $0x80600c
  8001e3:	68 10 60 80 00       	push   $0x806010
  8001e8:	ff 35 0c 60 80 00    	pushl  0x80600c
  8001ee:	e8 40 fe ff ff       	call   800033 <_gettoken>
  8001f3:	a3 08 60 80 00       	mov    %eax,0x806008
	return c;
  8001f8:	a1 04 60 80 00       	mov    0x806004,%eax
  8001fd:	83 c4 10             	add    $0x10,%esp
  800200:	eb c2                	jmp    8001c4 <gettoken+0x31>

00800202 <runcmd>:
{
  800202:	f3 0f 1e fb          	endbr32 
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	81 ec 64 04 00 00    	sub    $0x464,%esp
	gettoken(s, 0);
  800212:	6a 00                	push   $0x0
  800214:	ff 75 08             	pushl  0x8(%ebp)
  800217:	e8 77 ff ff ff       	call   800193 <gettoken>
  80021c:	83 c4 10             	add    $0x10,%esp
		switch ((c = gettoken(0, &t))) {
  80021f:	8d 75 a4             	lea    -0x5c(%ebp),%esi
	argc = 0;
  800222:	bf 00 00 00 00       	mov    $0x0,%edi
		switch ((c = gettoken(0, &t))) {
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	6a 00                	push   $0x0
  80022d:	e8 61 ff ff ff       	call   800193 <gettoken>
  800232:	89 c3                	mov    %eax,%ebx
  800234:	83 c4 10             	add    $0x10,%esp
  800237:	83 f8 3e             	cmp    $0x3e,%eax
  80023a:	0f 84 31 01 00 00    	je     800371 <runcmd+0x16f>
  800240:	7f 49                	jg     80028b <runcmd+0x89>
  800242:	85 c0                	test   %eax,%eax
  800244:	0f 84 1b 02 00 00    	je     800465 <runcmd+0x263>
  80024a:	83 f8 3c             	cmp    $0x3c,%eax
  80024d:	0f 85 ee 02 00 00    	jne    800541 <runcmd+0x33f>
			if (gettoken(0, &t) != 'w') {
  800253:	83 ec 08             	sub    $0x8,%esp
  800256:	56                   	push   %esi
  800257:	6a 00                	push   $0x0
  800259:	e8 35 ff ff ff       	call   800193 <gettoken>
  80025e:	83 c4 10             	add    $0x10,%esp
  800261:	83 f8 77             	cmp    $0x77,%eax
  800264:	0f 85 ba 00 00 00    	jne    800324 <runcmd+0x122>
			if ((fd = open(t, O_RDONLY))<0){
  80026a:	83 ec 08             	sub    $0x8,%esp
  80026d:	6a 00                	push   $0x0
  80026f:	ff 75 a4             	pushl  -0x5c(%ebp)
  800272:	e8 a7 21 00 00       	call   80241e <open>
  800277:	89 c3                	mov    %eax,%ebx
  800279:	83 c4 10             	add    $0x10,%esp
  80027c:	85 c0                	test   %eax,%eax
  80027e:	0f 88 ba 00 00 00    	js     80033e <runcmd+0x13c>
			if (fd!=0){
  800284:	74 a1                	je     800227 <runcmd+0x25>
  800286:	e9 cb 00 00 00       	jmp    800356 <runcmd+0x154>
		switch ((c = gettoken(0, &t))) {
  80028b:	83 f8 77             	cmp    $0x77,%eax
  80028e:	74 69                	je     8002f9 <runcmd+0xf7>
  800290:	83 f8 7c             	cmp    $0x7c,%eax
  800293:	0f 85 a8 02 00 00    	jne    800541 <runcmd+0x33f>
			if ((r = pipe(p)) < 0) {
  800299:	83 ec 0c             	sub    $0xc,%esp
  80029c:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  8002a2:	50                   	push   %eax
  8002a3:	e8 0b 30 00 00       	call   8032b3 <pipe>
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	85 c0                	test   %eax,%eax
  8002ad:	0f 88 40 01 00 00    	js     8003f3 <runcmd+0x1f1>
			if (debug)
  8002b3:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8002ba:	0f 85 4e 01 00 00    	jne    80040e <runcmd+0x20c>
			if ((r = fork()) < 0) {
  8002c0:	e8 c1 16 00 00       	call   801986 <fork>
  8002c5:	89 c3                	mov    %eax,%ebx
  8002c7:	85 c0                	test   %eax,%eax
  8002c9:	0f 88 60 01 00 00    	js     80042f <runcmd+0x22d>
			if (r == 0) {
  8002cf:	0f 85 70 01 00 00    	jne    800445 <runcmd+0x243>
				if (p[0] != 0) {
  8002d5:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8002db:	85 c0                	test   %eax,%eax
  8002dd:	0f 85 1c 02 00 00    	jne    8004ff <runcmd+0x2fd>
				close(p[1]);
  8002e3:	83 ec 0c             	sub    $0xc,%esp
  8002e6:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8002ec:	e8 48 1b 00 00       	call   801e39 <close>
				goto again;
  8002f1:	83 c4 10             	add    $0x10,%esp
  8002f4:	e9 29 ff ff ff       	jmp    800222 <runcmd+0x20>
			if (argc == MAXARGS) {
  8002f9:	83 ff 10             	cmp    $0x10,%edi
  8002fc:	74 0f                	je     80030d <runcmd+0x10b>
			argv[argc++] = t;
  8002fe:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800301:	89 44 bd a8          	mov    %eax,-0x58(%ebp,%edi,4)
  800305:	8d 7f 01             	lea    0x1(%edi),%edi
			break;
  800308:	e9 1a ff ff ff       	jmp    800227 <runcmd+0x25>
				cprintf("too many arguments\n");
  80030d:	83 ec 0c             	sub    $0xc,%esp
  800310:	68 25 39 80 00       	push   $0x803925
  800315:	e8 72 08 00 00       	call   800b8c <cprintf>
				exit();
  80031a:	e8 68 07 00 00       	call   800a87 <exit>
  80031f:	83 c4 10             	add    $0x10,%esp
  800322:	eb da                	jmp    8002fe <runcmd+0xfc>
				cprintf("syntax error: < not followed by word\n");
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	68 7c 3a 80 00       	push   $0x803a7c
  80032c:	e8 5b 08 00 00       	call   800b8c <cprintf>
				exit();
  800331:	e8 51 07 00 00       	call   800a87 <exit>
  800336:	83 c4 10             	add    $0x10,%esp
  800339:	e9 2c ff ff ff       	jmp    80026a <runcmd+0x68>
				fprintf(2, "open error: file %s %e\n", t, fd);
  80033e:	50                   	push   %eax
  80033f:	ff 75 a4             	pushl  -0x5c(%ebp)
  800342:	68 39 39 80 00       	push   $0x803939
  800347:	6a 02                	push   $0x2
  800349:	e8 6c 22 00 00       	call   8025ba <fprintf>
				exit();
  80034e:	e8 34 07 00 00       	call   800a87 <exit>
  800353:	83 c4 10             	add    $0x10,%esp
				dup(fd, 0);
  800356:	83 ec 08             	sub    $0x8,%esp
  800359:	6a 00                	push   $0x0
  80035b:	53                   	push   %ebx
  80035c:	e8 32 1b 00 00       	call   801e93 <dup>
				close(fd);
  800361:	89 1c 24             	mov    %ebx,(%esp)
  800364:	e8 d0 1a 00 00       	call   801e39 <close>
  800369:	83 c4 10             	add    $0x10,%esp
  80036c:	e9 b6 fe ff ff       	jmp    800227 <runcmd+0x25>
			if (gettoken(0, &t) != 'w') {
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	56                   	push   %esi
  800375:	6a 00                	push   $0x0
  800377:	e8 17 fe ff ff       	call   800193 <gettoken>
  80037c:	83 c4 10             	add    $0x10,%esp
  80037f:	83 f8 77             	cmp    $0x77,%eax
  800382:	75 24                	jne    8003a8 <runcmd+0x1a6>
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	68 01 03 00 00       	push   $0x301
  80038c:	ff 75 a4             	pushl  -0x5c(%ebp)
  80038f:	e8 8a 20 00 00       	call   80241e <open>
  800394:	89 c3                	mov    %eax,%ebx
  800396:	83 c4 10             	add    $0x10,%esp
  800399:	85 c0                	test   %eax,%eax
  80039b:	78 22                	js     8003bf <runcmd+0x1bd>
			if (fd != 1) {
  80039d:	83 f8 01             	cmp    $0x1,%eax
  8003a0:	0f 84 81 fe ff ff    	je     800227 <runcmd+0x25>
  8003a6:	eb 30                	jmp    8003d8 <runcmd+0x1d6>
				cprintf("syntax error: > not followed by word\n");
  8003a8:	83 ec 0c             	sub    $0xc,%esp
  8003ab:	68 a4 3a 80 00       	push   $0x803aa4
  8003b0:	e8 d7 07 00 00       	call   800b8c <cprintf>
				exit();
  8003b5:	e8 cd 06 00 00       	call   800a87 <exit>
  8003ba:	83 c4 10             	add    $0x10,%esp
  8003bd:	eb c5                	jmp    800384 <runcmd+0x182>
				cprintf("open %s for write: %e", t, fd);
  8003bf:	83 ec 04             	sub    $0x4,%esp
  8003c2:	50                   	push   %eax
  8003c3:	ff 75 a4             	pushl  -0x5c(%ebp)
  8003c6:	68 51 39 80 00       	push   $0x803951
  8003cb:	e8 bc 07 00 00       	call   800b8c <cprintf>
				exit();
  8003d0:	e8 b2 06 00 00       	call   800a87 <exit>
  8003d5:	83 c4 10             	add    $0x10,%esp
				dup(fd, 1);
  8003d8:	83 ec 08             	sub    $0x8,%esp
  8003db:	6a 01                	push   $0x1
  8003dd:	53                   	push   %ebx
  8003de:	e8 b0 1a 00 00       	call   801e93 <dup>
				close(fd);
  8003e3:	89 1c 24             	mov    %ebx,(%esp)
  8003e6:	e8 4e 1a 00 00       	call   801e39 <close>
  8003eb:	83 c4 10             	add    $0x10,%esp
  8003ee:	e9 34 fe ff ff       	jmp    800227 <runcmd+0x25>
				cprintf("pipe: %e", r);
  8003f3:	83 ec 08             	sub    $0x8,%esp
  8003f6:	50                   	push   %eax
  8003f7:	68 67 39 80 00       	push   $0x803967
  8003fc:	e8 8b 07 00 00       	call   800b8c <cprintf>
				exit();
  800401:	e8 81 06 00 00       	call   800a87 <exit>
  800406:	83 c4 10             	add    $0x10,%esp
  800409:	e9 a5 fe ff ff       	jmp    8002b3 <runcmd+0xb1>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  80040e:	83 ec 04             	sub    $0x4,%esp
  800411:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800417:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80041d:	68 70 39 80 00       	push   $0x803970
  800422:	e8 65 07 00 00       	call   800b8c <cprintf>
  800427:	83 c4 10             	add    $0x10,%esp
  80042a:	e9 91 fe ff ff       	jmp    8002c0 <runcmd+0xbe>
				cprintf("fork: %e", r);
  80042f:	83 ec 08             	sub    $0x8,%esp
  800432:	50                   	push   %eax
  800433:	68 7d 39 80 00       	push   $0x80397d
  800438:	e8 4f 07 00 00       	call   800b8c <cprintf>
				exit();
  80043d:	e8 45 06 00 00       	call   800a87 <exit>
  800442:	83 c4 10             	add    $0x10,%esp
				if (p[1] != 1) {
  800445:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  80044b:	83 f8 01             	cmp    $0x1,%eax
  80044e:	0f 85 cc 00 00 00    	jne    800520 <runcmd+0x31e>
				close(p[0]);
  800454:	83 ec 0c             	sub    $0xc,%esp
  800457:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80045d:	e8 d7 19 00 00       	call   801e39 <close>
				goto runit;
  800462:	83 c4 10             	add    $0x10,%esp
	if(argc == 0) {
  800465:	85 ff                	test   %edi,%edi
  800467:	0f 84 e6 00 00 00    	je     800553 <runcmd+0x351>
	if (argv[0][0] != '/') {
  80046d:	8b 45 a8             	mov    -0x58(%ebp),%eax
  800470:	80 38 2f             	cmpb   $0x2f,(%eax)
  800473:	0f 85 f5 00 00 00    	jne    80056e <runcmd+0x36c>
	argv[argc] = 0;
  800479:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
  800480:	00 
	if (debug) {
  800481:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800488:	0f 85 08 01 00 00    	jne    800596 <runcmd+0x394>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  80048e:	83 ec 08             	sub    $0x8,%esp
  800491:	8d 45 a8             	lea    -0x58(%ebp),%eax
  800494:	50                   	push   %eax
  800495:	ff 75 a8             	pushl  -0x58(%ebp)
  800498:	e8 52 21 00 00       	call   8025ef <spawn>
  80049d:	89 c6                	mov    %eax,%esi
  80049f:	83 c4 10             	add    $0x10,%esp
  8004a2:	85 c0                	test   %eax,%eax
  8004a4:	0f 88 3a 01 00 00    	js     8005e4 <runcmd+0x3e2>
	close_all();
  8004aa:	e8 bb 19 00 00       	call   801e6a <close_all>
		if (debug)
  8004af:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8004b6:	0f 85 75 01 00 00    	jne    800631 <runcmd+0x42f>
		wait(r);
  8004bc:	83 ec 0c             	sub    $0xc,%esp
  8004bf:	56                   	push   %esi
  8004c0:	e8 73 2f 00 00       	call   803438 <wait>
		if (debug)
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8004cf:	0f 85 7b 01 00 00    	jne    800650 <runcmd+0x44e>
	if (pipe_child) {
  8004d5:	85 db                	test   %ebx,%ebx
  8004d7:	74 19                	je     8004f2 <runcmd+0x2f0>
		wait(pipe_child);
  8004d9:	83 ec 0c             	sub    $0xc,%esp
  8004dc:	53                   	push   %ebx
  8004dd:	e8 56 2f 00 00       	call   803438 <wait>
		if (debug)
  8004e2:	83 c4 10             	add    $0x10,%esp
  8004e5:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8004ec:	0f 85 79 01 00 00    	jne    80066b <runcmd+0x469>
	exit();
  8004f2:	e8 90 05 00 00       	call   800a87 <exit>
}
  8004f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004fa:	5b                   	pop    %ebx
  8004fb:	5e                   	pop    %esi
  8004fc:	5f                   	pop    %edi
  8004fd:	5d                   	pop    %ebp
  8004fe:	c3                   	ret    
					dup(p[0], 0);
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	6a 00                	push   $0x0
  800504:	50                   	push   %eax
  800505:	e8 89 19 00 00       	call   801e93 <dup>
					close(p[0]);
  80050a:	83 c4 04             	add    $0x4,%esp
  80050d:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800513:	e8 21 19 00 00       	call   801e39 <close>
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	e9 c3 fd ff ff       	jmp    8002e3 <runcmd+0xe1>
					dup(p[1], 1);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	6a 01                	push   $0x1
  800525:	50                   	push   %eax
  800526:	e8 68 19 00 00       	call   801e93 <dup>
					close(p[1]);
  80052b:	83 c4 04             	add    $0x4,%esp
  80052e:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800534:	e8 00 19 00 00       	call   801e39 <close>
  800539:	83 c4 10             	add    $0x10,%esp
  80053c:	e9 13 ff ff ff       	jmp    800454 <runcmd+0x252>
			panic("bad return %d from gettoken", c);
  800541:	53                   	push   %ebx
  800542:	68 86 39 80 00       	push   $0x803986
  800547:	6a 77                	push   $0x77
  800549:	68 a2 39 80 00       	push   $0x8039a2
  80054e:	e8 52 05 00 00       	call   800aa5 <_panic>
		if (debug)
  800553:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80055a:	74 9b                	je     8004f7 <runcmd+0x2f5>
			cprintf("EMPTY COMMAND\n");
  80055c:	83 ec 0c             	sub    $0xc,%esp
  80055f:	68 ac 39 80 00       	push   $0x8039ac
  800564:	e8 23 06 00 00       	call   800b8c <cprintf>
  800569:	83 c4 10             	add    $0x10,%esp
  80056c:	eb 89                	jmp    8004f7 <runcmd+0x2f5>
		argv0buf[0] = '/';
  80056e:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	50                   	push   %eax
  800579:	8d b5 a4 fb ff ff    	lea    -0x45c(%ebp),%esi
  80057f:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  800585:	50                   	push   %eax
  800586:	e8 ff 0c 00 00       	call   80128a <strcpy>
		argv[0] = argv0buf;
  80058b:	89 75 a8             	mov    %esi,-0x58(%ebp)
  80058e:	83 c4 10             	add    $0x10,%esp
  800591:	e9 e3 fe ff ff       	jmp    800479 <runcmd+0x277>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  800596:	a1 28 64 80 00       	mov    0x806428,%eax
  80059b:	8b 40 48             	mov    0x48(%eax),%eax
  80059e:	83 ec 08             	sub    $0x8,%esp
  8005a1:	50                   	push   %eax
  8005a2:	68 bb 39 80 00       	push   $0x8039bb
  8005a7:	e8 e0 05 00 00       	call   800b8c <cprintf>
  8005ac:	8d 75 a8             	lea    -0x58(%ebp),%esi
		for (i = 0; argv[i]; i++)
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	eb 11                	jmp    8005c5 <runcmd+0x3c3>
			cprintf(" %s", argv[i]);
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	50                   	push   %eax
  8005b8:	68 43 3a 80 00       	push   $0x803a43
  8005bd:	e8 ca 05 00 00       	call   800b8c <cprintf>
  8005c2:	83 c4 10             	add    $0x10,%esp
  8005c5:	83 c6 04             	add    $0x4,%esi
		for (i = 0; argv[i]; i++)
  8005c8:	8b 46 fc             	mov    -0x4(%esi),%eax
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	75 e5                	jne    8005b4 <runcmd+0x3b2>
		cprintf("\n");
  8005cf:	83 ec 0c             	sub    $0xc,%esp
  8005d2:	68 00 39 80 00       	push   $0x803900
  8005d7:	e8 b0 05 00 00       	call   800b8c <cprintf>
  8005dc:	83 c4 10             	add    $0x10,%esp
  8005df:	e9 aa fe ff ff       	jmp    80048e <runcmd+0x28c>
		cprintf("spawn %s: %e\n", argv[0], r);
  8005e4:	83 ec 04             	sub    $0x4,%esp
  8005e7:	50                   	push   %eax
  8005e8:	ff 75 a8             	pushl  -0x58(%ebp)
  8005eb:	68 c9 39 80 00       	push   $0x8039c9
  8005f0:	e8 97 05 00 00       	call   800b8c <cprintf>
	close_all();
  8005f5:	e8 70 18 00 00       	call   801e6a <close_all>
  8005fa:	83 c4 10             	add    $0x10,%esp
	if (pipe_child) {
  8005fd:	85 db                	test   %ebx,%ebx
  8005ff:	0f 84 ed fe ff ff    	je     8004f2 <runcmd+0x2f0>
		if (debug)
  800605:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80060c:	0f 84 c7 fe ff ff    	je     8004d9 <runcmd+0x2d7>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  800612:	a1 28 64 80 00       	mov    0x806428,%eax
  800617:	8b 40 48             	mov    0x48(%eax),%eax
  80061a:	83 ec 04             	sub    $0x4,%esp
  80061d:	53                   	push   %ebx
  80061e:	50                   	push   %eax
  80061f:	68 02 3a 80 00       	push   $0x803a02
  800624:	e8 63 05 00 00       	call   800b8c <cprintf>
  800629:	83 c4 10             	add    $0x10,%esp
  80062c:	e9 a8 fe ff ff       	jmp    8004d9 <runcmd+0x2d7>
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800631:	a1 28 64 80 00       	mov    0x806428,%eax
  800636:	8b 40 48             	mov    0x48(%eax),%eax
  800639:	56                   	push   %esi
  80063a:	ff 75 a8             	pushl  -0x58(%ebp)
  80063d:	50                   	push   %eax
  80063e:	68 d7 39 80 00       	push   $0x8039d7
  800643:	e8 44 05 00 00       	call   800b8c <cprintf>
  800648:	83 c4 10             	add    $0x10,%esp
  80064b:	e9 6c fe ff ff       	jmp    8004bc <runcmd+0x2ba>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800650:	a1 28 64 80 00       	mov    0x806428,%eax
  800655:	8b 40 48             	mov    0x48(%eax),%eax
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	50                   	push   %eax
  80065c:	68 ec 39 80 00       	push   $0x8039ec
  800661:	e8 26 05 00 00       	call   800b8c <cprintf>
  800666:	83 c4 10             	add    $0x10,%esp
  800669:	eb 92                	jmp    8005fd <runcmd+0x3fb>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  80066b:	a1 28 64 80 00       	mov    0x806428,%eax
  800670:	8b 40 48             	mov    0x48(%eax),%eax
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	50                   	push   %eax
  800677:	68 ec 39 80 00       	push   $0x8039ec
  80067c:	e8 0b 05 00 00       	call   800b8c <cprintf>
  800681:	83 c4 10             	add    $0x10,%esp
  800684:	e9 69 fe ff ff       	jmp    8004f2 <runcmd+0x2f0>

00800689 <usage>:


void
usage(void)
{
  800689:	f3 0f 1e fb          	endbr32 
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800693:	68 cc 3a 80 00       	push   $0x803acc
  800698:	e8 ef 04 00 00       	call   800b8c <cprintf>
	exit();
  80069d:	e8 e5 03 00 00       	call   800a87 <exit>
}
  8006a2:	83 c4 10             	add    $0x10,%esp
  8006a5:	c9                   	leave  
  8006a6:	c3                   	ret    

008006a7 <umain>:

void
umain(int argc, char **argv)
{
  8006a7:	f3 0f 1e fb          	endbr32 
  8006ab:	55                   	push   %ebp
  8006ac:	89 e5                	mov    %esp,%ebp
  8006ae:	57                   	push   %edi
  8006af:	56                   	push   %esi
  8006b0:	53                   	push   %ebx
  8006b1:	83 ec 30             	sub    $0x30,%esp
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  8006b4:	8d 45 d8             	lea    -0x28(%ebp),%eax
  8006b7:	50                   	push   %eax
  8006b8:	ff 75 0c             	pushl  0xc(%ebp)
  8006bb:	8d 45 08             	lea    0x8(%ebp),%eax
  8006be:	50                   	push   %eax
  8006bf:	e8 53 14 00 00       	call   801b17 <argstart>
	while ((r = argnext(&args)) >= 0)
  8006c4:	83 c4 10             	add    $0x10,%esp
	echocmds = 0;
  8006c7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
	interactive = '?';
  8006ce:	bf 3f 00 00 00       	mov    $0x3f,%edi
	while ((r = argnext(&args)) >= 0)
  8006d3:	8d 5d d8             	lea    -0x28(%ebp),%ebx
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006d6:	be 01 00 00 00       	mov    $0x1,%esi
	while ((r = argnext(&args)) >= 0)
  8006db:	eb 10                	jmp    8006ed <umain+0x46>
			debug++;
  8006dd:	83 05 00 60 80 00 01 	addl   $0x1,0x806000
			break;
  8006e4:	eb 07                	jmp    8006ed <umain+0x46>
			interactive = 1;
  8006e6:	89 f7                	mov    %esi,%edi
  8006e8:	eb 03                	jmp    8006ed <umain+0x46>
		switch (r) {
  8006ea:	89 75 d4             	mov    %esi,-0x2c(%ebp)
	while ((r = argnext(&args)) >= 0)
  8006ed:	83 ec 0c             	sub    $0xc,%esp
  8006f0:	53                   	push   %ebx
  8006f1:	e8 55 14 00 00       	call   801b4b <argnext>
  8006f6:	83 c4 10             	add    $0x10,%esp
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	78 16                	js     800713 <umain+0x6c>
		switch (r) {
  8006fd:	83 f8 69             	cmp    $0x69,%eax
  800700:	74 e4                	je     8006e6 <umain+0x3f>
  800702:	83 f8 78             	cmp    $0x78,%eax
  800705:	74 e3                	je     8006ea <umain+0x43>
  800707:	83 f8 64             	cmp    $0x64,%eax
  80070a:	74 d1                	je     8006dd <umain+0x36>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  80070c:	e8 78 ff ff ff       	call   800689 <usage>
  800711:	eb da                	jmp    8006ed <umain+0x46>
		}

	if (argc > 2)
  800713:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  800717:	7f 1f                	jg     800738 <umain+0x91>
		usage();
	if (argc == 2) {
  800719:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  80071d:	74 20                	je     80073f <umain+0x98>
		close(0);
		if ((r = open(argv[1], O_RDONLY)) < 0)
			panic("open %s: %e", argv[1], r);
		assert(r == 0);
	}
	if (interactive == '?')
  80071f:	83 ff 3f             	cmp    $0x3f,%edi
  800722:	74 75                	je     800799 <umain+0xf2>
  800724:	85 ff                	test   %edi,%edi
  800726:	bf 47 3a 80 00       	mov    $0x803a47,%edi
  80072b:	b8 00 00 00 00       	mov    $0x0,%eax
  800730:	0f 44 f8             	cmove  %eax,%edi
  800733:	e9 06 01 00 00       	jmp    80083e <umain+0x197>
		usage();
  800738:	e8 4c ff ff ff       	call   800689 <usage>
  80073d:	eb da                	jmp    800719 <umain+0x72>
		close(0);
  80073f:	83 ec 0c             	sub    $0xc,%esp
  800742:	6a 00                	push   $0x0
  800744:	e8 f0 16 00 00       	call   801e39 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  800749:	83 c4 08             	add    $0x8,%esp
  80074c:	6a 00                	push   $0x0
  80074e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800751:	ff 70 04             	pushl  0x4(%eax)
  800754:	e8 c5 1c 00 00       	call   80241e <open>
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	85 c0                	test   %eax,%eax
  80075e:	78 1b                	js     80077b <umain+0xd4>
		assert(r == 0);
  800760:	74 bd                	je     80071f <umain+0x78>
  800762:	68 2b 3a 80 00       	push   $0x803a2b
  800767:	68 32 3a 80 00       	push   $0x803a32
  80076c:	68 28 01 00 00       	push   $0x128
  800771:	68 a2 39 80 00       	push   $0x8039a2
  800776:	e8 2a 03 00 00       	call   800aa5 <_panic>
			panic("open %s: %e", argv[1], r);
  80077b:	83 ec 0c             	sub    $0xc,%esp
  80077e:	50                   	push   %eax
  80077f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800782:	ff 70 04             	pushl  0x4(%eax)
  800785:	68 1f 3a 80 00       	push   $0x803a1f
  80078a:	68 27 01 00 00       	push   $0x127
  80078f:	68 a2 39 80 00       	push   $0x8039a2
  800794:	e8 0c 03 00 00       	call   800aa5 <_panic>
		interactive = iscons(0);
  800799:	83 ec 0c             	sub    $0xc,%esp
  80079c:	6a 00                	push   $0x0
  80079e:	e8 14 02 00 00       	call   8009b7 <iscons>
  8007a3:	89 c7                	mov    %eax,%edi
  8007a5:	83 c4 10             	add    $0x10,%esp
  8007a8:	e9 77 ff ff ff       	jmp    800724 <umain+0x7d>
	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
		if (buf == NULL) {
			if (debug)
  8007ad:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8007b4:	75 0a                	jne    8007c0 <umain+0x119>
				cprintf("EXITING\n");
			exit();	// end of file
  8007b6:	e8 cc 02 00 00       	call   800a87 <exit>
  8007bb:	e9 94 00 00 00       	jmp    800854 <umain+0x1ad>
				cprintf("EXITING\n");
  8007c0:	83 ec 0c             	sub    $0xc,%esp
  8007c3:	68 4a 3a 80 00       	push   $0x803a4a
  8007c8:	e8 bf 03 00 00       	call   800b8c <cprintf>
  8007cd:	83 c4 10             	add    $0x10,%esp
  8007d0:	eb e4                	jmp    8007b6 <umain+0x10f>
		}
		if (debug)
			cprintf("LINE: %s\n", buf);
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	53                   	push   %ebx
  8007d6:	68 53 3a 80 00       	push   $0x803a53
  8007db:	e8 ac 03 00 00       	call   800b8c <cprintf>
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	eb 7c                	jmp    800861 <umain+0x1ba>
		if (buf[0] == '#')
			continue;
		if (echocmds)
			printf("# %s\n", buf);
  8007e5:	83 ec 08             	sub    $0x8,%esp
  8007e8:	53                   	push   %ebx
  8007e9:	68 5d 3a 80 00       	push   $0x803a5d
  8007ee:	e8 e2 1d 00 00       	call   8025d5 <printf>
  8007f3:	83 c4 10             	add    $0x10,%esp
  8007f6:	eb 78                	jmp    800870 <umain+0x1c9>
		if (debug)
			cprintf("BEFORE FORK\n");
  8007f8:	83 ec 0c             	sub    $0xc,%esp
  8007fb:	68 63 3a 80 00       	push   $0x803a63
  800800:	e8 87 03 00 00       	call   800b8c <cprintf>
  800805:	83 c4 10             	add    $0x10,%esp
  800808:	eb 73                	jmp    80087d <umain+0x1d6>
		if ((r = fork()) < 0)
			panic("fork: %e", r);
  80080a:	50                   	push   %eax
  80080b:	68 7d 39 80 00       	push   $0x80397d
  800810:	68 3f 01 00 00       	push   $0x13f
  800815:	68 a2 39 80 00       	push   $0x8039a2
  80081a:	e8 86 02 00 00       	call   800aa5 <_panic>
		if (debug)
			cprintf("FORK: %d\n", r);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	50                   	push   %eax
  800823:	68 70 3a 80 00       	push   $0x803a70
  800828:	e8 5f 03 00 00       	call   800b8c <cprintf>
  80082d:	83 c4 10             	add    $0x10,%esp
  800830:	eb 5f                	jmp    800891 <umain+0x1ea>
		if (r == 0) {
			runcmd(buf);
			exit();
		} else
			wait(r);
  800832:	83 ec 0c             	sub    $0xc,%esp
  800835:	56                   	push   %esi
  800836:	e8 fd 2b 00 00       	call   803438 <wait>
  80083b:	83 c4 10             	add    $0x10,%esp
		buf = readline(interactive ? "$ " : NULL);
  80083e:	83 ec 0c             	sub    $0xc,%esp
  800841:	57                   	push   %edi
  800842:	e8 0c 09 00 00       	call   801153 <readline>
  800847:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800849:	83 c4 10             	add    $0x10,%esp
  80084c:	85 c0                	test   %eax,%eax
  80084e:	0f 84 59 ff ff ff    	je     8007ad <umain+0x106>
		if (debug)
  800854:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80085b:	0f 85 71 ff ff ff    	jne    8007d2 <umain+0x12b>
		if (buf[0] == '#')
  800861:	80 3b 23             	cmpb   $0x23,(%ebx)
  800864:	74 d8                	je     80083e <umain+0x197>
		if (echocmds)
  800866:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80086a:	0f 85 75 ff ff ff    	jne    8007e5 <umain+0x13e>
		if (debug)
  800870:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800877:	0f 85 7b ff ff ff    	jne    8007f8 <umain+0x151>
		if ((r = fork()) < 0)
  80087d:	e8 04 11 00 00       	call   801986 <fork>
  800882:	89 c6                	mov    %eax,%esi
  800884:	85 c0                	test   %eax,%eax
  800886:	78 82                	js     80080a <umain+0x163>
		if (debug)
  800888:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80088f:	75 8e                	jne    80081f <umain+0x178>
		if (r == 0) {
  800891:	85 f6                	test   %esi,%esi
  800893:	75 9d                	jne    800832 <umain+0x18b>
			runcmd(buf);
  800895:	83 ec 0c             	sub    $0xc,%esp
  800898:	53                   	push   %ebx
  800899:	e8 64 f9 ff ff       	call   800202 <runcmd>
			exit();
  80089e:	e8 e4 01 00 00       	call   800a87 <exit>
  8008a3:	83 c4 10             	add    $0x10,%esp
  8008a6:	eb 96                	jmp    80083e <umain+0x197>

008008a8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8008a8:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  8008ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b1:	c3                   	ret    

008008b2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8008b2:	f3 0f 1e fb          	endbr32 
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8008bc:	68 ed 3a 80 00       	push   $0x803aed
  8008c1:	ff 75 0c             	pushl  0xc(%ebp)
  8008c4:	e8 c1 09 00 00       	call   80128a <strcpy>
	return 0;
}
  8008c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ce:	c9                   	leave  
  8008cf:	c3                   	ret    

008008d0 <devcons_write>:
{
  8008d0:	f3 0f 1e fb          	endbr32 
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	57                   	push   %edi
  8008d8:	56                   	push   %esi
  8008d9:	53                   	push   %ebx
  8008da:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8008e0:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8008e5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8008eb:	3b 75 10             	cmp    0x10(%ebp),%esi
  8008ee:	73 31                	jae    800921 <devcons_write+0x51>
		m = n - tot;
  8008f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008f3:	29 f3                	sub    %esi,%ebx
  8008f5:	83 fb 7f             	cmp    $0x7f,%ebx
  8008f8:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8008fd:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800900:	83 ec 04             	sub    $0x4,%esp
  800903:	53                   	push   %ebx
  800904:	89 f0                	mov    %esi,%eax
  800906:	03 45 0c             	add    0xc(%ebp),%eax
  800909:	50                   	push   %eax
  80090a:	57                   	push   %edi
  80090b:	e8 78 0b 00 00       	call   801488 <memmove>
		sys_cputs(buf, m);
  800910:	83 c4 08             	add    $0x8,%esp
  800913:	53                   	push   %ebx
  800914:	57                   	push   %edi
  800915:	e8 2a 0d 00 00       	call   801644 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80091a:	01 de                	add    %ebx,%esi
  80091c:	83 c4 10             	add    $0x10,%esp
  80091f:	eb ca                	jmp    8008eb <devcons_write+0x1b>
}
  800921:	89 f0                	mov    %esi,%eax
  800923:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800926:	5b                   	pop    %ebx
  800927:	5e                   	pop    %esi
  800928:	5f                   	pop    %edi
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <devcons_read>:
{
  80092b:	f3 0f 1e fb          	endbr32 
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 08             	sub    $0x8,%esp
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80093a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80093e:	74 21                	je     800961 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800940:	e8 21 0d 00 00       	call   801666 <sys_cgetc>
  800945:	85 c0                	test   %eax,%eax
  800947:	75 07                	jne    800950 <devcons_read+0x25>
		sys_yield();
  800949:	e8 82 0d 00 00       	call   8016d0 <sys_yield>
  80094e:	eb f0                	jmp    800940 <devcons_read+0x15>
	if (c < 0)
  800950:	78 0f                	js     800961 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800952:	83 f8 04             	cmp    $0x4,%eax
  800955:	74 0c                	je     800963 <devcons_read+0x38>
	*(char*)vbuf = c;
  800957:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095a:	88 02                	mov    %al,(%edx)
	return 1;
  80095c:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800961:	c9                   	leave  
  800962:	c3                   	ret    
		return 0;
  800963:	b8 00 00 00 00       	mov    $0x0,%eax
  800968:	eb f7                	jmp    800961 <devcons_read+0x36>

0080096a <cputchar>:
{
  80096a:	f3 0f 1e fb          	endbr32 
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80097a:	6a 01                	push   $0x1
  80097c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80097f:	50                   	push   %eax
  800980:	e8 bf 0c 00 00       	call   801644 <sys_cputs>
}
  800985:	83 c4 10             	add    $0x10,%esp
  800988:	c9                   	leave  
  800989:	c3                   	ret    

0080098a <getchar>:
{
  80098a:	f3 0f 1e fb          	endbr32 
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800994:	6a 01                	push   $0x1
  800996:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800999:	50                   	push   %eax
  80099a:	6a 00                	push   $0x0
  80099c:	e8 e2 15 00 00       	call   801f83 <read>
	if (r < 0)
  8009a1:	83 c4 10             	add    $0x10,%esp
  8009a4:	85 c0                	test   %eax,%eax
  8009a6:	78 06                	js     8009ae <getchar+0x24>
	if (r < 1)
  8009a8:	74 06                	je     8009b0 <getchar+0x26>
	return c;
  8009aa:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8009ae:	c9                   	leave  
  8009af:	c3                   	ret    
		return -E_EOF;
  8009b0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8009b5:	eb f7                	jmp    8009ae <getchar+0x24>

008009b7 <iscons>:
{
  8009b7:	f3 0f 1e fb          	endbr32 
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8009c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009c4:	50                   	push   %eax
  8009c5:	ff 75 08             	pushl  0x8(%ebp)
  8009c8:	e8 2e 13 00 00       	call   801cfb <fd_lookup>
  8009cd:	83 c4 10             	add    $0x10,%esp
  8009d0:	85 c0                	test   %eax,%eax
  8009d2:	78 11                	js     8009e5 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8009d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009d7:	8b 15 00 50 80 00    	mov    0x805000,%edx
  8009dd:	39 10                	cmp    %edx,(%eax)
  8009df:	0f 94 c0             	sete   %al
  8009e2:	0f b6 c0             	movzbl %al,%eax
}
  8009e5:	c9                   	leave  
  8009e6:	c3                   	ret    

008009e7 <opencons>:
{
  8009e7:	f3 0f 1e fb          	endbr32 
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8009f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009f4:	50                   	push   %eax
  8009f5:	e8 ab 12 00 00       	call   801ca5 <fd_alloc>
  8009fa:	83 c4 10             	add    $0x10,%esp
  8009fd:	85 c0                	test   %eax,%eax
  8009ff:	78 3a                	js     800a3b <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800a01:	83 ec 04             	sub    $0x4,%esp
  800a04:	68 07 04 00 00       	push   $0x407
  800a09:	ff 75 f4             	pushl  -0xc(%ebp)
  800a0c:	6a 00                	push   $0x0
  800a0e:	e8 e0 0c 00 00       	call   8016f3 <sys_page_alloc>
  800a13:	83 c4 10             	add    $0x10,%esp
  800a16:	85 c0                	test   %eax,%eax
  800a18:	78 21                	js     800a3b <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  800a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a1d:	8b 15 00 50 80 00    	mov    0x805000,%edx
  800a23:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a28:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800a2f:	83 ec 0c             	sub    $0xc,%esp
  800a32:	50                   	push   %eax
  800a33:	e8 3e 12 00 00       	call   801c76 <fd2num>
  800a38:	83 c4 10             	add    $0x10,%esp
}
  800a3b:	c9                   	leave  
  800a3c:	c3                   	ret    

00800a3d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800a3d:	f3 0f 1e fb          	endbr32 
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	56                   	push   %esi
  800a45:	53                   	push   %ebx
  800a46:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a49:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800a4c:	e8 5c 0c 00 00       	call   8016ad <sys_getenvid>
  800a51:	25 ff 03 00 00       	and    $0x3ff,%eax
  800a56:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800a59:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800a5e:	a3 28 64 80 00       	mov    %eax,0x806428
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800a63:	85 db                	test   %ebx,%ebx
  800a65:	7e 07                	jle    800a6e <libmain+0x31>
		binaryname = argv[0];
  800a67:	8b 06                	mov    (%esi),%eax
  800a69:	a3 1c 50 80 00       	mov    %eax,0x80501c

	// call user main routine
	umain(argc, argv);
  800a6e:	83 ec 08             	sub    $0x8,%esp
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
  800a73:	e8 2f fc ff ff       	call   8006a7 <umain>

	// exit gracefully
	exit();
  800a78:	e8 0a 00 00 00       	call   800a87 <exit>
}
  800a7d:	83 c4 10             	add    $0x10,%esp
  800a80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a83:	5b                   	pop    %ebx
  800a84:	5e                   	pop    %esi
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a87:	f3 0f 1e fb          	endbr32 
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  800a91:	e8 d4 13 00 00       	call   801e6a <close_all>
	sys_env_destroy(0);
  800a96:	83 ec 0c             	sub    $0xc,%esp
  800a99:	6a 00                	push   $0x0
  800a9b:	e8 e9 0b 00 00       	call   801689 <sys_env_destroy>
}
  800aa0:	83 c4 10             	add    $0x10,%esp
  800aa3:	c9                   	leave  
  800aa4:	c3                   	ret    

00800aa5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800aa5:	f3 0f 1e fb          	endbr32 
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	56                   	push   %esi
  800aad:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800aae:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ab1:	8b 35 1c 50 80 00    	mov    0x80501c,%esi
  800ab7:	e8 f1 0b 00 00       	call   8016ad <sys_getenvid>
  800abc:	83 ec 0c             	sub    $0xc,%esp
  800abf:	ff 75 0c             	pushl  0xc(%ebp)
  800ac2:	ff 75 08             	pushl  0x8(%ebp)
  800ac5:	56                   	push   %esi
  800ac6:	50                   	push   %eax
  800ac7:	68 04 3b 80 00       	push   $0x803b04
  800acc:	e8 bb 00 00 00       	call   800b8c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ad1:	83 c4 18             	add    $0x18,%esp
  800ad4:	53                   	push   %ebx
  800ad5:	ff 75 10             	pushl  0x10(%ebp)
  800ad8:	e8 5a 00 00 00       	call   800b37 <vcprintf>
	cprintf("\n");
  800add:	c7 04 24 00 39 80 00 	movl   $0x803900,(%esp)
  800ae4:	e8 a3 00 00 00       	call   800b8c <cprintf>
  800ae9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800aec:	cc                   	int3   
  800aed:	eb fd                	jmp    800aec <_panic+0x47>

00800aef <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800aef:	f3 0f 1e fb          	endbr32 
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	53                   	push   %ebx
  800af7:	83 ec 04             	sub    $0x4,%esp
  800afa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800afd:	8b 13                	mov    (%ebx),%edx
  800aff:	8d 42 01             	lea    0x1(%edx),%eax
  800b02:	89 03                	mov    %eax,(%ebx)
  800b04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b07:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800b0b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800b10:	74 09                	je     800b1b <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800b12:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800b16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b19:	c9                   	leave  
  800b1a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800b1b:	83 ec 08             	sub    $0x8,%esp
  800b1e:	68 ff 00 00 00       	push   $0xff
  800b23:	8d 43 08             	lea    0x8(%ebx),%eax
  800b26:	50                   	push   %eax
  800b27:	e8 18 0b 00 00       	call   801644 <sys_cputs>
		b->idx = 0;
  800b2c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800b32:	83 c4 10             	add    $0x10,%esp
  800b35:	eb db                	jmp    800b12 <putch+0x23>

00800b37 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800b37:	f3 0f 1e fb          	endbr32 
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800b44:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800b4b:	00 00 00 
	b.cnt = 0;
  800b4e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800b55:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800b58:	ff 75 0c             	pushl  0xc(%ebp)
  800b5b:	ff 75 08             	pushl  0x8(%ebp)
  800b5e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800b64:	50                   	push   %eax
  800b65:	68 ef 0a 80 00       	push   $0x800aef
  800b6a:	e8 20 01 00 00       	call   800c8f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800b6f:	83 c4 08             	add    $0x8,%esp
  800b72:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800b78:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800b7e:	50                   	push   %eax
  800b7f:	e8 c0 0a 00 00       	call   801644 <sys_cputs>

	return b.cnt;
}
  800b84:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800b8a:	c9                   	leave  
  800b8b:	c3                   	ret    

00800b8c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b8c:	f3 0f 1e fb          	endbr32 
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b96:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b99:	50                   	push   %eax
  800b9a:	ff 75 08             	pushl  0x8(%ebp)
  800b9d:	e8 95 ff ff ff       	call   800b37 <vcprintf>
	va_end(ap);

	return cnt;
}
  800ba2:	c9                   	leave  
  800ba3:	c3                   	ret    

00800ba4 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
  800baa:	83 ec 1c             	sub    $0x1c,%esp
  800bad:	89 c7                	mov    %eax,%edi
  800baf:	89 d6                	mov    %edx,%esi
  800bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb7:	89 d1                	mov    %edx,%ecx
  800bb9:	89 c2                	mov    %eax,%edx
  800bbb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bbe:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800bc1:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800bc7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800bd1:	39 c2                	cmp    %eax,%edx
  800bd3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800bd6:	72 3e                	jb     800c16 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800bd8:	83 ec 0c             	sub    $0xc,%esp
  800bdb:	ff 75 18             	pushl  0x18(%ebp)
  800bde:	83 eb 01             	sub    $0x1,%ebx
  800be1:	53                   	push   %ebx
  800be2:	50                   	push   %eax
  800be3:	83 ec 08             	sub    $0x8,%esp
  800be6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800be9:	ff 75 e0             	pushl  -0x20(%ebp)
  800bec:	ff 75 dc             	pushl  -0x24(%ebp)
  800bef:	ff 75 d8             	pushl  -0x28(%ebp)
  800bf2:	e8 79 2a 00 00       	call   803670 <__udivdi3>
  800bf7:	83 c4 18             	add    $0x18,%esp
  800bfa:	52                   	push   %edx
  800bfb:	50                   	push   %eax
  800bfc:	89 f2                	mov    %esi,%edx
  800bfe:	89 f8                	mov    %edi,%eax
  800c00:	e8 9f ff ff ff       	call   800ba4 <printnum>
  800c05:	83 c4 20             	add    $0x20,%esp
  800c08:	eb 13                	jmp    800c1d <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800c0a:	83 ec 08             	sub    $0x8,%esp
  800c0d:	56                   	push   %esi
  800c0e:	ff 75 18             	pushl  0x18(%ebp)
  800c11:	ff d7                	call   *%edi
  800c13:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800c16:	83 eb 01             	sub    $0x1,%ebx
  800c19:	85 db                	test   %ebx,%ebx
  800c1b:	7f ed                	jg     800c0a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800c1d:	83 ec 08             	sub    $0x8,%esp
  800c20:	56                   	push   %esi
  800c21:	83 ec 04             	sub    $0x4,%esp
  800c24:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c27:	ff 75 e0             	pushl  -0x20(%ebp)
  800c2a:	ff 75 dc             	pushl  -0x24(%ebp)
  800c2d:	ff 75 d8             	pushl  -0x28(%ebp)
  800c30:	e8 4b 2b 00 00       	call   803780 <__umoddi3>
  800c35:	83 c4 14             	add    $0x14,%esp
  800c38:	0f be 80 27 3b 80 00 	movsbl 0x803b27(%eax),%eax
  800c3f:	50                   	push   %eax
  800c40:	ff d7                	call   *%edi
}
  800c42:	83 c4 10             	add    $0x10,%esp
  800c45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c4d:	f3 0f 1e fb          	endbr32 
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c57:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800c5b:	8b 10                	mov    (%eax),%edx
  800c5d:	3b 50 04             	cmp    0x4(%eax),%edx
  800c60:	73 0a                	jae    800c6c <sprintputch+0x1f>
		*b->buf++ = ch;
  800c62:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c65:	89 08                	mov    %ecx,(%eax)
  800c67:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6a:	88 02                	mov    %al,(%edx)
}
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <printfmt>:
{
  800c6e:	f3 0f 1e fb          	endbr32 
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800c78:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c7b:	50                   	push   %eax
  800c7c:	ff 75 10             	pushl  0x10(%ebp)
  800c7f:	ff 75 0c             	pushl  0xc(%ebp)
  800c82:	ff 75 08             	pushl  0x8(%ebp)
  800c85:	e8 05 00 00 00       	call   800c8f <vprintfmt>
}
  800c8a:	83 c4 10             	add    $0x10,%esp
  800c8d:	c9                   	leave  
  800c8e:	c3                   	ret    

00800c8f <vprintfmt>:
{
  800c8f:	f3 0f 1e fb          	endbr32 
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 3c             	sub    $0x3c,%esp
  800c9c:	8b 75 08             	mov    0x8(%ebp),%esi
  800c9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ca2:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ca5:	e9 8e 03 00 00       	jmp    801038 <vprintfmt+0x3a9>
		padc = ' ';
  800caa:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800cae:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800cb5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800cbc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800cc3:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800cc8:	8d 47 01             	lea    0x1(%edi),%eax
  800ccb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800cce:	0f b6 17             	movzbl (%edi),%edx
  800cd1:	8d 42 dd             	lea    -0x23(%edx),%eax
  800cd4:	3c 55                	cmp    $0x55,%al
  800cd6:	0f 87 df 03 00 00    	ja     8010bb <vprintfmt+0x42c>
  800cdc:	0f b6 c0             	movzbl %al,%eax
  800cdf:	3e ff 24 85 60 3c 80 	notrack jmp *0x803c60(,%eax,4)
  800ce6:	00 
  800ce7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800cea:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800cee:	eb d8                	jmp    800cc8 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800cf0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cf3:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800cf7:	eb cf                	jmp    800cc8 <vprintfmt+0x39>
  800cf9:	0f b6 d2             	movzbl %dl,%edx
  800cfc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800cff:	b8 00 00 00 00       	mov    $0x0,%eax
  800d04:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800d07:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800d0a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800d0e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800d11:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800d14:	83 f9 09             	cmp    $0x9,%ecx
  800d17:	77 55                	ja     800d6e <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800d19:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800d1c:	eb e9                	jmp    800d07 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800d1e:	8b 45 14             	mov    0x14(%ebp),%eax
  800d21:	8b 00                	mov    (%eax),%eax
  800d23:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d26:	8b 45 14             	mov    0x14(%ebp),%eax
  800d29:	8d 40 04             	lea    0x4(%eax),%eax
  800d2c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800d2f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800d32:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d36:	79 90                	jns    800cc8 <vprintfmt+0x39>
				width = precision, precision = -1;
  800d38:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d3b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d3e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800d45:	eb 81                	jmp    800cc8 <vprintfmt+0x39>
  800d47:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d51:	0f 49 d0             	cmovns %eax,%edx
  800d54:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800d57:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800d5a:	e9 69 ff ff ff       	jmp    800cc8 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800d5f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800d62:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800d69:	e9 5a ff ff ff       	jmp    800cc8 <vprintfmt+0x39>
  800d6e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800d71:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d74:	eb bc                	jmp    800d32 <vprintfmt+0xa3>
			lflag++;
  800d76:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800d79:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800d7c:	e9 47 ff ff ff       	jmp    800cc8 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800d81:	8b 45 14             	mov    0x14(%ebp),%eax
  800d84:	8d 78 04             	lea    0x4(%eax),%edi
  800d87:	83 ec 08             	sub    $0x8,%esp
  800d8a:	53                   	push   %ebx
  800d8b:	ff 30                	pushl  (%eax)
  800d8d:	ff d6                	call   *%esi
			break;
  800d8f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800d92:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800d95:	e9 9b 02 00 00       	jmp    801035 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800d9a:	8b 45 14             	mov    0x14(%ebp),%eax
  800d9d:	8d 78 04             	lea    0x4(%eax),%edi
  800da0:	8b 00                	mov    (%eax),%eax
  800da2:	99                   	cltd   
  800da3:	31 d0                	xor    %edx,%eax
  800da5:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800da7:	83 f8 0f             	cmp    $0xf,%eax
  800daa:	7f 23                	jg     800dcf <vprintfmt+0x140>
  800dac:	8b 14 85 c0 3d 80 00 	mov    0x803dc0(,%eax,4),%edx
  800db3:	85 d2                	test   %edx,%edx
  800db5:	74 18                	je     800dcf <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800db7:	52                   	push   %edx
  800db8:	68 44 3a 80 00       	push   $0x803a44
  800dbd:	53                   	push   %ebx
  800dbe:	56                   	push   %esi
  800dbf:	e8 aa fe ff ff       	call   800c6e <printfmt>
  800dc4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800dc7:	89 7d 14             	mov    %edi,0x14(%ebp)
  800dca:	e9 66 02 00 00       	jmp    801035 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800dcf:	50                   	push   %eax
  800dd0:	68 3f 3b 80 00       	push   $0x803b3f
  800dd5:	53                   	push   %ebx
  800dd6:	56                   	push   %esi
  800dd7:	e8 92 fe ff ff       	call   800c6e <printfmt>
  800ddc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800ddf:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800de2:	e9 4e 02 00 00       	jmp    801035 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800de7:	8b 45 14             	mov    0x14(%ebp),%eax
  800dea:	83 c0 04             	add    $0x4,%eax
  800ded:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800df0:	8b 45 14             	mov    0x14(%ebp),%eax
  800df3:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800df5:	85 d2                	test   %edx,%edx
  800df7:	b8 38 3b 80 00       	mov    $0x803b38,%eax
  800dfc:	0f 45 c2             	cmovne %edx,%eax
  800dff:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800e02:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800e06:	7e 06                	jle    800e0e <vprintfmt+0x17f>
  800e08:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800e0c:	75 0d                	jne    800e1b <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800e0e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800e11:	89 c7                	mov    %eax,%edi
  800e13:	03 45 e0             	add    -0x20(%ebp),%eax
  800e16:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800e19:	eb 55                	jmp    800e70 <vprintfmt+0x1e1>
  800e1b:	83 ec 08             	sub    $0x8,%esp
  800e1e:	ff 75 d8             	pushl  -0x28(%ebp)
  800e21:	ff 75 cc             	pushl  -0x34(%ebp)
  800e24:	e8 3a 04 00 00       	call   801263 <strnlen>
  800e29:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800e2c:	29 c2                	sub    %eax,%edx
  800e2e:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800e31:	83 c4 10             	add    $0x10,%esp
  800e34:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800e36:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800e3a:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800e3d:	85 ff                	test   %edi,%edi
  800e3f:	7e 11                	jle    800e52 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800e41:	83 ec 08             	sub    $0x8,%esp
  800e44:	53                   	push   %ebx
  800e45:	ff 75 e0             	pushl  -0x20(%ebp)
  800e48:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800e4a:	83 ef 01             	sub    $0x1,%edi
  800e4d:	83 c4 10             	add    $0x10,%esp
  800e50:	eb eb                	jmp    800e3d <vprintfmt+0x1ae>
  800e52:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800e55:	85 d2                	test   %edx,%edx
  800e57:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5c:	0f 49 c2             	cmovns %edx,%eax
  800e5f:	29 c2                	sub    %eax,%edx
  800e61:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800e64:	eb a8                	jmp    800e0e <vprintfmt+0x17f>
					putch(ch, putdat);
  800e66:	83 ec 08             	sub    $0x8,%esp
  800e69:	53                   	push   %ebx
  800e6a:	52                   	push   %edx
  800e6b:	ff d6                	call   *%esi
  800e6d:	83 c4 10             	add    $0x10,%esp
  800e70:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800e73:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e75:	83 c7 01             	add    $0x1,%edi
  800e78:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e7c:	0f be d0             	movsbl %al,%edx
  800e7f:	85 d2                	test   %edx,%edx
  800e81:	74 4b                	je     800ece <vprintfmt+0x23f>
  800e83:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e87:	78 06                	js     800e8f <vprintfmt+0x200>
  800e89:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800e8d:	78 1e                	js     800ead <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  800e8f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800e93:	74 d1                	je     800e66 <vprintfmt+0x1d7>
  800e95:	0f be c0             	movsbl %al,%eax
  800e98:	83 e8 20             	sub    $0x20,%eax
  800e9b:	83 f8 5e             	cmp    $0x5e,%eax
  800e9e:	76 c6                	jbe    800e66 <vprintfmt+0x1d7>
					putch('?', putdat);
  800ea0:	83 ec 08             	sub    $0x8,%esp
  800ea3:	53                   	push   %ebx
  800ea4:	6a 3f                	push   $0x3f
  800ea6:	ff d6                	call   *%esi
  800ea8:	83 c4 10             	add    $0x10,%esp
  800eab:	eb c3                	jmp    800e70 <vprintfmt+0x1e1>
  800ead:	89 cf                	mov    %ecx,%edi
  800eaf:	eb 0e                	jmp    800ebf <vprintfmt+0x230>
				putch(' ', putdat);
  800eb1:	83 ec 08             	sub    $0x8,%esp
  800eb4:	53                   	push   %ebx
  800eb5:	6a 20                	push   $0x20
  800eb7:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800eb9:	83 ef 01             	sub    $0x1,%edi
  800ebc:	83 c4 10             	add    $0x10,%esp
  800ebf:	85 ff                	test   %edi,%edi
  800ec1:	7f ee                	jg     800eb1 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800ec3:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800ec6:	89 45 14             	mov    %eax,0x14(%ebp)
  800ec9:	e9 67 01 00 00       	jmp    801035 <vprintfmt+0x3a6>
  800ece:	89 cf                	mov    %ecx,%edi
  800ed0:	eb ed                	jmp    800ebf <vprintfmt+0x230>
	if (lflag >= 2)
  800ed2:	83 f9 01             	cmp    $0x1,%ecx
  800ed5:	7f 1b                	jg     800ef2 <vprintfmt+0x263>
	else if (lflag)
  800ed7:	85 c9                	test   %ecx,%ecx
  800ed9:	74 63                	je     800f3e <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800edb:	8b 45 14             	mov    0x14(%ebp),%eax
  800ede:	8b 00                	mov    (%eax),%eax
  800ee0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ee3:	99                   	cltd   
  800ee4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ee7:	8b 45 14             	mov    0x14(%ebp),%eax
  800eea:	8d 40 04             	lea    0x4(%eax),%eax
  800eed:	89 45 14             	mov    %eax,0x14(%ebp)
  800ef0:	eb 17                	jmp    800f09 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800ef2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ef5:	8b 50 04             	mov    0x4(%eax),%edx
  800ef8:	8b 00                	mov    (%eax),%eax
  800efa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800efd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800f00:	8b 45 14             	mov    0x14(%ebp),%eax
  800f03:	8d 40 08             	lea    0x8(%eax),%eax
  800f06:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800f09:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800f0c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800f0f:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800f14:	85 c9                	test   %ecx,%ecx
  800f16:	0f 89 ff 00 00 00    	jns    80101b <vprintfmt+0x38c>
				putch('-', putdat);
  800f1c:	83 ec 08             	sub    $0x8,%esp
  800f1f:	53                   	push   %ebx
  800f20:	6a 2d                	push   $0x2d
  800f22:	ff d6                	call   *%esi
				num = -(long long) num;
  800f24:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800f27:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800f2a:	f7 da                	neg    %edx
  800f2c:	83 d1 00             	adc    $0x0,%ecx
  800f2f:	f7 d9                	neg    %ecx
  800f31:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800f34:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f39:	e9 dd 00 00 00       	jmp    80101b <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800f3e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f41:	8b 00                	mov    (%eax),%eax
  800f43:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f46:	99                   	cltd   
  800f47:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800f4a:	8b 45 14             	mov    0x14(%ebp),%eax
  800f4d:	8d 40 04             	lea    0x4(%eax),%eax
  800f50:	89 45 14             	mov    %eax,0x14(%ebp)
  800f53:	eb b4                	jmp    800f09 <vprintfmt+0x27a>
	if (lflag >= 2)
  800f55:	83 f9 01             	cmp    $0x1,%ecx
  800f58:	7f 1e                	jg     800f78 <vprintfmt+0x2e9>
	else if (lflag)
  800f5a:	85 c9                	test   %ecx,%ecx
  800f5c:	74 32                	je     800f90 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800f5e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f61:	8b 10                	mov    (%eax),%edx
  800f63:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f68:	8d 40 04             	lea    0x4(%eax),%eax
  800f6b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800f6e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800f73:	e9 a3 00 00 00       	jmp    80101b <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800f78:	8b 45 14             	mov    0x14(%ebp),%eax
  800f7b:	8b 10                	mov    (%eax),%edx
  800f7d:	8b 48 04             	mov    0x4(%eax),%ecx
  800f80:	8d 40 08             	lea    0x8(%eax),%eax
  800f83:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800f86:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800f8b:	e9 8b 00 00 00       	jmp    80101b <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800f90:	8b 45 14             	mov    0x14(%ebp),%eax
  800f93:	8b 10                	mov    (%eax),%edx
  800f95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f9a:	8d 40 04             	lea    0x4(%eax),%eax
  800f9d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800fa0:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800fa5:	eb 74                	jmp    80101b <vprintfmt+0x38c>
	if (lflag >= 2)
  800fa7:	83 f9 01             	cmp    $0x1,%ecx
  800faa:	7f 1b                	jg     800fc7 <vprintfmt+0x338>
	else if (lflag)
  800fac:	85 c9                	test   %ecx,%ecx
  800fae:	74 2c                	je     800fdc <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800fb0:	8b 45 14             	mov    0x14(%ebp),%eax
  800fb3:	8b 10                	mov    (%eax),%edx
  800fb5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fba:	8d 40 04             	lea    0x4(%eax),%eax
  800fbd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800fc0:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800fc5:	eb 54                	jmp    80101b <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800fc7:	8b 45 14             	mov    0x14(%ebp),%eax
  800fca:	8b 10                	mov    (%eax),%edx
  800fcc:	8b 48 04             	mov    0x4(%eax),%ecx
  800fcf:	8d 40 08             	lea    0x8(%eax),%eax
  800fd2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800fd5:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800fda:	eb 3f                	jmp    80101b <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800fdc:	8b 45 14             	mov    0x14(%ebp),%eax
  800fdf:	8b 10                	mov    (%eax),%edx
  800fe1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe6:	8d 40 04             	lea    0x4(%eax),%eax
  800fe9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800fec:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800ff1:	eb 28                	jmp    80101b <vprintfmt+0x38c>
			putch('0', putdat);
  800ff3:	83 ec 08             	sub    $0x8,%esp
  800ff6:	53                   	push   %ebx
  800ff7:	6a 30                	push   $0x30
  800ff9:	ff d6                	call   *%esi
			putch('x', putdat);
  800ffb:	83 c4 08             	add    $0x8,%esp
  800ffe:	53                   	push   %ebx
  800fff:	6a 78                	push   $0x78
  801001:	ff d6                	call   *%esi
			num = (unsigned long long)
  801003:	8b 45 14             	mov    0x14(%ebp),%eax
  801006:	8b 10                	mov    (%eax),%edx
  801008:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80100d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801010:	8d 40 04             	lea    0x4(%eax),%eax
  801013:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801016:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80101b:	83 ec 0c             	sub    $0xc,%esp
  80101e:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801022:	57                   	push   %edi
  801023:	ff 75 e0             	pushl  -0x20(%ebp)
  801026:	50                   	push   %eax
  801027:	51                   	push   %ecx
  801028:	52                   	push   %edx
  801029:	89 da                	mov    %ebx,%edx
  80102b:	89 f0                	mov    %esi,%eax
  80102d:	e8 72 fb ff ff       	call   800ba4 <printnum>
			break;
  801032:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  801035:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  801038:	83 c7 01             	add    $0x1,%edi
  80103b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80103f:	83 f8 25             	cmp    $0x25,%eax
  801042:	0f 84 62 fc ff ff    	je     800caa <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  801048:	85 c0                	test   %eax,%eax
  80104a:	0f 84 8b 00 00 00    	je     8010db <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  801050:	83 ec 08             	sub    $0x8,%esp
  801053:	53                   	push   %ebx
  801054:	50                   	push   %eax
  801055:	ff d6                	call   *%esi
  801057:	83 c4 10             	add    $0x10,%esp
  80105a:	eb dc                	jmp    801038 <vprintfmt+0x3a9>
	if (lflag >= 2)
  80105c:	83 f9 01             	cmp    $0x1,%ecx
  80105f:	7f 1b                	jg     80107c <vprintfmt+0x3ed>
	else if (lflag)
  801061:	85 c9                	test   %ecx,%ecx
  801063:	74 2c                	je     801091 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  801065:	8b 45 14             	mov    0x14(%ebp),%eax
  801068:	8b 10                	mov    (%eax),%edx
  80106a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80106f:	8d 40 04             	lea    0x4(%eax),%eax
  801072:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801075:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80107a:	eb 9f                	jmp    80101b <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80107c:	8b 45 14             	mov    0x14(%ebp),%eax
  80107f:	8b 10                	mov    (%eax),%edx
  801081:	8b 48 04             	mov    0x4(%eax),%ecx
  801084:	8d 40 08             	lea    0x8(%eax),%eax
  801087:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80108a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80108f:	eb 8a                	jmp    80101b <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801091:	8b 45 14             	mov    0x14(%ebp),%eax
  801094:	8b 10                	mov    (%eax),%edx
  801096:	b9 00 00 00 00       	mov    $0x0,%ecx
  80109b:	8d 40 04             	lea    0x4(%eax),%eax
  80109e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8010a1:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8010a6:	e9 70 ff ff ff       	jmp    80101b <vprintfmt+0x38c>
			putch(ch, putdat);
  8010ab:	83 ec 08             	sub    $0x8,%esp
  8010ae:	53                   	push   %ebx
  8010af:	6a 25                	push   $0x25
  8010b1:	ff d6                	call   *%esi
			break;
  8010b3:	83 c4 10             	add    $0x10,%esp
  8010b6:	e9 7a ff ff ff       	jmp    801035 <vprintfmt+0x3a6>
			putch('%', putdat);
  8010bb:	83 ec 08             	sub    $0x8,%esp
  8010be:	53                   	push   %ebx
  8010bf:	6a 25                	push   $0x25
  8010c1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  8010c3:	83 c4 10             	add    $0x10,%esp
  8010c6:	89 f8                	mov    %edi,%eax
  8010c8:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8010cc:	74 05                	je     8010d3 <vprintfmt+0x444>
  8010ce:	83 e8 01             	sub    $0x1,%eax
  8010d1:	eb f5                	jmp    8010c8 <vprintfmt+0x439>
  8010d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010d6:	e9 5a ff ff ff       	jmp    801035 <vprintfmt+0x3a6>
}
  8010db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010de:	5b                   	pop    %ebx
  8010df:	5e                   	pop    %esi
  8010e0:	5f                   	pop    %edi
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8010e3:	f3 0f 1e fb          	endbr32 
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	83 ec 18             	sub    $0x18,%esp
  8010ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8010f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8010f6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8010fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8010fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801104:	85 c0                	test   %eax,%eax
  801106:	74 26                	je     80112e <vsnprintf+0x4b>
  801108:	85 d2                	test   %edx,%edx
  80110a:	7e 22                	jle    80112e <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80110c:	ff 75 14             	pushl  0x14(%ebp)
  80110f:	ff 75 10             	pushl  0x10(%ebp)
  801112:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801115:	50                   	push   %eax
  801116:	68 4d 0c 80 00       	push   $0x800c4d
  80111b:	e8 6f fb ff ff       	call   800c8f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801120:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801123:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801126:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801129:	83 c4 10             	add    $0x10,%esp
}
  80112c:	c9                   	leave  
  80112d:	c3                   	ret    
		return -E_INVAL;
  80112e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801133:	eb f7                	jmp    80112c <vsnprintf+0x49>

00801135 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801135:	f3 0f 1e fb          	endbr32 
  801139:	55                   	push   %ebp
  80113a:	89 e5                	mov    %esp,%ebp
  80113c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  80113f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801142:	50                   	push   %eax
  801143:	ff 75 10             	pushl  0x10(%ebp)
  801146:	ff 75 0c             	pushl  0xc(%ebp)
  801149:	ff 75 08             	pushl  0x8(%ebp)
  80114c:	e8 92 ff ff ff       	call   8010e3 <vsnprintf>
	va_end(ap);

	return rc;
}
  801151:	c9                   	leave  
  801152:	c3                   	ret    

00801153 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  801153:	f3 0f 1e fb          	endbr32 
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	57                   	push   %edi
  80115b:	56                   	push   %esi
  80115c:	53                   	push   %ebx
  80115d:	83 ec 0c             	sub    $0xc,%esp
  801160:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  801163:	85 c0                	test   %eax,%eax
  801165:	74 13                	je     80117a <readline+0x27>
		fprintf(1, "%s", prompt);
  801167:	83 ec 04             	sub    $0x4,%esp
  80116a:	50                   	push   %eax
  80116b:	68 44 3a 80 00       	push   $0x803a44
  801170:	6a 01                	push   $0x1
  801172:	e8 43 14 00 00       	call   8025ba <fprintf>
  801177:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  80117a:	83 ec 0c             	sub    $0xc,%esp
  80117d:	6a 00                	push   $0x0
  80117f:	e8 33 f8 ff ff       	call   8009b7 <iscons>
  801184:	89 c7                	mov    %eax,%edi
  801186:	83 c4 10             	add    $0x10,%esp
	i = 0;
  801189:	be 00 00 00 00       	mov    $0x0,%esi
  80118e:	eb 57                	jmp    8011e7 <readline+0x94>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  801190:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
  801195:	83 fb f8             	cmp    $0xfffffff8,%ebx
  801198:	75 08                	jne    8011a2 <readline+0x4f>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  80119a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119d:	5b                   	pop    %ebx
  80119e:	5e                   	pop    %esi
  80119f:	5f                   	pop    %edi
  8011a0:	5d                   	pop    %ebp
  8011a1:	c3                   	ret    
				cprintf("read error: %e\n", c);
  8011a2:	83 ec 08             	sub    $0x8,%esp
  8011a5:	53                   	push   %ebx
  8011a6:	68 1f 3e 80 00       	push   $0x803e1f
  8011ab:	e8 dc f9 ff ff       	call   800b8c <cprintf>
  8011b0:	83 c4 10             	add    $0x10,%esp
			return NULL;
  8011b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b8:	eb e0                	jmp    80119a <readline+0x47>
			if (echoing)
  8011ba:	85 ff                	test   %edi,%edi
  8011bc:	75 05                	jne    8011c3 <readline+0x70>
			i--;
  8011be:	83 ee 01             	sub    $0x1,%esi
  8011c1:	eb 24                	jmp    8011e7 <readline+0x94>
				cputchar('\b');
  8011c3:	83 ec 0c             	sub    $0xc,%esp
  8011c6:	6a 08                	push   $0x8
  8011c8:	e8 9d f7 ff ff       	call   80096a <cputchar>
  8011cd:	83 c4 10             	add    $0x10,%esp
  8011d0:	eb ec                	jmp    8011be <readline+0x6b>
				cputchar(c);
  8011d2:	83 ec 0c             	sub    $0xc,%esp
  8011d5:	53                   	push   %ebx
  8011d6:	e8 8f f7 ff ff       	call   80096a <cputchar>
  8011db:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8011de:	88 9e 20 60 80 00    	mov    %bl,0x806020(%esi)
  8011e4:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
  8011e7:	e8 9e f7 ff ff       	call   80098a <getchar>
  8011ec:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	78 9e                	js     801190 <readline+0x3d>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8011f2:	83 f8 08             	cmp    $0x8,%eax
  8011f5:	0f 94 c2             	sete   %dl
  8011f8:	83 f8 7f             	cmp    $0x7f,%eax
  8011fb:	0f 94 c0             	sete   %al
  8011fe:	08 c2                	or     %al,%dl
  801200:	74 04                	je     801206 <readline+0xb3>
  801202:	85 f6                	test   %esi,%esi
  801204:	7f b4                	jg     8011ba <readline+0x67>
		} else if (c >= ' ' && i < BUFLEN-1) {
  801206:	83 fb 1f             	cmp    $0x1f,%ebx
  801209:	7e 0e                	jle    801219 <readline+0xc6>
  80120b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  801211:	7f 06                	jg     801219 <readline+0xc6>
			if (echoing)
  801213:	85 ff                	test   %edi,%edi
  801215:	74 c7                	je     8011de <readline+0x8b>
  801217:	eb b9                	jmp    8011d2 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
  801219:	83 fb 0a             	cmp    $0xa,%ebx
  80121c:	74 05                	je     801223 <readline+0xd0>
  80121e:	83 fb 0d             	cmp    $0xd,%ebx
  801221:	75 c4                	jne    8011e7 <readline+0x94>
			if (echoing)
  801223:	85 ff                	test   %edi,%edi
  801225:	75 11                	jne    801238 <readline+0xe5>
			buf[i] = 0;
  801227:	c6 86 20 60 80 00 00 	movb   $0x0,0x806020(%esi)
			return buf;
  80122e:	b8 20 60 80 00       	mov    $0x806020,%eax
  801233:	e9 62 ff ff ff       	jmp    80119a <readline+0x47>
				cputchar('\n');
  801238:	83 ec 0c             	sub    $0xc,%esp
  80123b:	6a 0a                	push   $0xa
  80123d:	e8 28 f7 ff ff       	call   80096a <cputchar>
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	eb e0                	jmp    801227 <readline+0xd4>

00801247 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801247:	f3 0f 1e fb          	endbr32 
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801251:	b8 00 00 00 00       	mov    $0x0,%eax
  801256:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80125a:	74 05                	je     801261 <strlen+0x1a>
		n++;
  80125c:	83 c0 01             	add    $0x1,%eax
  80125f:	eb f5                	jmp    801256 <strlen+0xf>
	return n;
}
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    

00801263 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801263:	f3 0f 1e fb          	endbr32 
  801267:	55                   	push   %ebp
  801268:	89 e5                	mov    %esp,%ebp
  80126a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801270:	b8 00 00 00 00       	mov    $0x0,%eax
  801275:	39 d0                	cmp    %edx,%eax
  801277:	74 0d                	je     801286 <strnlen+0x23>
  801279:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80127d:	74 05                	je     801284 <strnlen+0x21>
		n++;
  80127f:	83 c0 01             	add    $0x1,%eax
  801282:	eb f1                	jmp    801275 <strnlen+0x12>
  801284:	89 c2                	mov    %eax,%edx
	return n;
}
  801286:	89 d0                	mov    %edx,%eax
  801288:	5d                   	pop    %ebp
  801289:	c3                   	ret    

0080128a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80128a:	f3 0f 1e fb          	endbr32 
  80128e:	55                   	push   %ebp
  80128f:	89 e5                	mov    %esp,%ebp
  801291:	53                   	push   %ebx
  801292:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801295:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801298:	b8 00 00 00 00       	mov    $0x0,%eax
  80129d:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8012a1:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8012a4:	83 c0 01             	add    $0x1,%eax
  8012a7:	84 d2                	test   %dl,%dl
  8012a9:	75 f2                	jne    80129d <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8012ab:	89 c8                	mov    %ecx,%eax
  8012ad:	5b                   	pop    %ebx
  8012ae:	5d                   	pop    %ebp
  8012af:	c3                   	ret    

008012b0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8012b0:	f3 0f 1e fb          	endbr32 
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
  8012b7:	53                   	push   %ebx
  8012b8:	83 ec 10             	sub    $0x10,%esp
  8012bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8012be:	53                   	push   %ebx
  8012bf:	e8 83 ff ff ff       	call   801247 <strlen>
  8012c4:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8012c7:	ff 75 0c             	pushl  0xc(%ebp)
  8012ca:	01 d8                	add    %ebx,%eax
  8012cc:	50                   	push   %eax
  8012cd:	e8 b8 ff ff ff       	call   80128a <strcpy>
	return dst;
}
  8012d2:	89 d8                	mov    %ebx,%eax
  8012d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d7:	c9                   	leave  
  8012d8:	c3                   	ret    

008012d9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8012d9:	f3 0f 1e fb          	endbr32 
  8012dd:	55                   	push   %ebp
  8012de:	89 e5                	mov    %esp,%ebp
  8012e0:	56                   	push   %esi
  8012e1:	53                   	push   %ebx
  8012e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8012e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e8:	89 f3                	mov    %esi,%ebx
  8012ea:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8012ed:	89 f0                	mov    %esi,%eax
  8012ef:	39 d8                	cmp    %ebx,%eax
  8012f1:	74 11                	je     801304 <strncpy+0x2b>
		*dst++ = *src;
  8012f3:	83 c0 01             	add    $0x1,%eax
  8012f6:	0f b6 0a             	movzbl (%edx),%ecx
  8012f9:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8012fc:	80 f9 01             	cmp    $0x1,%cl
  8012ff:	83 da ff             	sbb    $0xffffffff,%edx
  801302:	eb eb                	jmp    8012ef <strncpy+0x16>
	}
	return ret;
}
  801304:	89 f0                	mov    %esi,%eax
  801306:	5b                   	pop    %ebx
  801307:	5e                   	pop    %esi
  801308:	5d                   	pop    %ebp
  801309:	c3                   	ret    

0080130a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80130a:	f3 0f 1e fb          	endbr32 
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
  801311:	56                   	push   %esi
  801312:	53                   	push   %ebx
  801313:	8b 75 08             	mov    0x8(%ebp),%esi
  801316:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801319:	8b 55 10             	mov    0x10(%ebp),%edx
  80131c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80131e:	85 d2                	test   %edx,%edx
  801320:	74 21                	je     801343 <strlcpy+0x39>
  801322:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801326:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801328:	39 c2                	cmp    %eax,%edx
  80132a:	74 14                	je     801340 <strlcpy+0x36>
  80132c:	0f b6 19             	movzbl (%ecx),%ebx
  80132f:	84 db                	test   %bl,%bl
  801331:	74 0b                	je     80133e <strlcpy+0x34>
			*dst++ = *src++;
  801333:	83 c1 01             	add    $0x1,%ecx
  801336:	83 c2 01             	add    $0x1,%edx
  801339:	88 5a ff             	mov    %bl,-0x1(%edx)
  80133c:	eb ea                	jmp    801328 <strlcpy+0x1e>
  80133e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801340:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801343:	29 f0                	sub    %esi,%eax
}
  801345:	5b                   	pop    %ebx
  801346:	5e                   	pop    %esi
  801347:	5d                   	pop    %ebp
  801348:	c3                   	ret    

00801349 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801349:	f3 0f 1e fb          	endbr32 
  80134d:	55                   	push   %ebp
  80134e:	89 e5                	mov    %esp,%ebp
  801350:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801353:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801356:	0f b6 01             	movzbl (%ecx),%eax
  801359:	84 c0                	test   %al,%al
  80135b:	74 0c                	je     801369 <strcmp+0x20>
  80135d:	3a 02                	cmp    (%edx),%al
  80135f:	75 08                	jne    801369 <strcmp+0x20>
		p++, q++;
  801361:	83 c1 01             	add    $0x1,%ecx
  801364:	83 c2 01             	add    $0x1,%edx
  801367:	eb ed                	jmp    801356 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801369:	0f b6 c0             	movzbl %al,%eax
  80136c:	0f b6 12             	movzbl (%edx),%edx
  80136f:	29 d0                	sub    %edx,%eax
}
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    

00801373 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801373:	f3 0f 1e fb          	endbr32 
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	53                   	push   %ebx
  80137b:	8b 45 08             	mov    0x8(%ebp),%eax
  80137e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801381:	89 c3                	mov    %eax,%ebx
  801383:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801386:	eb 06                	jmp    80138e <strncmp+0x1b>
		n--, p++, q++;
  801388:	83 c0 01             	add    $0x1,%eax
  80138b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80138e:	39 d8                	cmp    %ebx,%eax
  801390:	74 16                	je     8013a8 <strncmp+0x35>
  801392:	0f b6 08             	movzbl (%eax),%ecx
  801395:	84 c9                	test   %cl,%cl
  801397:	74 04                	je     80139d <strncmp+0x2a>
  801399:	3a 0a                	cmp    (%edx),%cl
  80139b:	74 eb                	je     801388 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80139d:	0f b6 00             	movzbl (%eax),%eax
  8013a0:	0f b6 12             	movzbl (%edx),%edx
  8013a3:	29 d0                	sub    %edx,%eax
}
  8013a5:	5b                   	pop    %ebx
  8013a6:	5d                   	pop    %ebp
  8013a7:	c3                   	ret    
		return 0;
  8013a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ad:	eb f6                	jmp    8013a5 <strncmp+0x32>

008013af <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8013af:	f3 0f 1e fb          	endbr32 
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
  8013b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8013bd:	0f b6 10             	movzbl (%eax),%edx
  8013c0:	84 d2                	test   %dl,%dl
  8013c2:	74 09                	je     8013cd <strchr+0x1e>
		if (*s == c)
  8013c4:	38 ca                	cmp    %cl,%dl
  8013c6:	74 0a                	je     8013d2 <strchr+0x23>
	for (; *s; s++)
  8013c8:	83 c0 01             	add    $0x1,%eax
  8013cb:	eb f0                	jmp    8013bd <strchr+0xe>
			return (char *) s;
	return 0;
  8013cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013d2:	5d                   	pop    %ebp
  8013d3:	c3                   	ret    

008013d4 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  8013d4:	f3 0f 1e fb          	endbr32 
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  8013de:	6a 78                	push   $0x78
  8013e0:	ff 75 08             	pushl  0x8(%ebp)
  8013e3:	e8 c7 ff ff ff       	call   8013af <strchr>
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  8013ee:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  8013f3:	eb 0d                	jmp    801402 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  8013f5:	c1 e0 04             	shl    $0x4,%eax
  8013f8:	0f be d2             	movsbl %dl,%edx
  8013fb:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  8013ff:	83 c1 01             	add    $0x1,%ecx
  801402:	0f b6 11             	movzbl (%ecx),%edx
  801405:	84 d2                	test   %dl,%dl
  801407:	74 11                	je     80141a <atox+0x46>
		if (*p>='a'){
  801409:	80 fa 60             	cmp    $0x60,%dl
  80140c:	7e e7                	jle    8013f5 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  80140e:	c1 e0 04             	shl    $0x4,%eax
  801411:	0f be d2             	movsbl %dl,%edx
  801414:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  801418:	eb e5                	jmp    8013ff <atox+0x2b>
	}

	return v;

}
  80141a:	c9                   	leave  
  80141b:	c3                   	ret    

0080141c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80141c:	f3 0f 1e fb          	endbr32 
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	8b 45 08             	mov    0x8(%ebp),%eax
  801426:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80142a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80142d:	38 ca                	cmp    %cl,%dl
  80142f:	74 09                	je     80143a <strfind+0x1e>
  801431:	84 d2                	test   %dl,%dl
  801433:	74 05                	je     80143a <strfind+0x1e>
	for (; *s; s++)
  801435:	83 c0 01             	add    $0x1,%eax
  801438:	eb f0                	jmp    80142a <strfind+0xe>
			break;
	return (char *) s;
}
  80143a:	5d                   	pop    %ebp
  80143b:	c3                   	ret    

0080143c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80143c:	f3 0f 1e fb          	endbr32 
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	57                   	push   %edi
  801444:	56                   	push   %esi
  801445:	53                   	push   %ebx
  801446:	8b 7d 08             	mov    0x8(%ebp),%edi
  801449:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80144c:	85 c9                	test   %ecx,%ecx
  80144e:	74 31                	je     801481 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801450:	89 f8                	mov    %edi,%eax
  801452:	09 c8                	or     %ecx,%eax
  801454:	a8 03                	test   $0x3,%al
  801456:	75 23                	jne    80147b <memset+0x3f>
		c &= 0xFF;
  801458:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80145c:	89 d3                	mov    %edx,%ebx
  80145e:	c1 e3 08             	shl    $0x8,%ebx
  801461:	89 d0                	mov    %edx,%eax
  801463:	c1 e0 18             	shl    $0x18,%eax
  801466:	89 d6                	mov    %edx,%esi
  801468:	c1 e6 10             	shl    $0x10,%esi
  80146b:	09 f0                	or     %esi,%eax
  80146d:	09 c2                	or     %eax,%edx
  80146f:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801471:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801474:	89 d0                	mov    %edx,%eax
  801476:	fc                   	cld    
  801477:	f3 ab                	rep stos %eax,%es:(%edi)
  801479:	eb 06                	jmp    801481 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80147b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80147e:	fc                   	cld    
  80147f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801481:	89 f8                	mov    %edi,%eax
  801483:	5b                   	pop    %ebx
  801484:	5e                   	pop    %esi
  801485:	5f                   	pop    %edi
  801486:	5d                   	pop    %ebp
  801487:	c3                   	ret    

00801488 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801488:	f3 0f 1e fb          	endbr32 
  80148c:	55                   	push   %ebp
  80148d:	89 e5                	mov    %esp,%ebp
  80148f:	57                   	push   %edi
  801490:	56                   	push   %esi
  801491:	8b 45 08             	mov    0x8(%ebp),%eax
  801494:	8b 75 0c             	mov    0xc(%ebp),%esi
  801497:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80149a:	39 c6                	cmp    %eax,%esi
  80149c:	73 32                	jae    8014d0 <memmove+0x48>
  80149e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8014a1:	39 c2                	cmp    %eax,%edx
  8014a3:	76 2b                	jbe    8014d0 <memmove+0x48>
		s += n;
		d += n;
  8014a5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8014a8:	89 fe                	mov    %edi,%esi
  8014aa:	09 ce                	or     %ecx,%esi
  8014ac:	09 d6                	or     %edx,%esi
  8014ae:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8014b4:	75 0e                	jne    8014c4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8014b6:	83 ef 04             	sub    $0x4,%edi
  8014b9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8014bc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8014bf:	fd                   	std    
  8014c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8014c2:	eb 09                	jmp    8014cd <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8014c4:	83 ef 01             	sub    $0x1,%edi
  8014c7:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8014ca:	fd                   	std    
  8014cb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8014cd:	fc                   	cld    
  8014ce:	eb 1a                	jmp    8014ea <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8014d0:	89 c2                	mov    %eax,%edx
  8014d2:	09 ca                	or     %ecx,%edx
  8014d4:	09 f2                	or     %esi,%edx
  8014d6:	f6 c2 03             	test   $0x3,%dl
  8014d9:	75 0a                	jne    8014e5 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8014db:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8014de:	89 c7                	mov    %eax,%edi
  8014e0:	fc                   	cld    
  8014e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8014e3:	eb 05                	jmp    8014ea <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8014e5:	89 c7                	mov    %eax,%edi
  8014e7:	fc                   	cld    
  8014e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8014ea:	5e                   	pop    %esi
  8014eb:	5f                   	pop    %edi
  8014ec:	5d                   	pop    %ebp
  8014ed:	c3                   	ret    

008014ee <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8014ee:	f3 0f 1e fb          	endbr32 
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8014f8:	ff 75 10             	pushl  0x10(%ebp)
  8014fb:	ff 75 0c             	pushl  0xc(%ebp)
  8014fe:	ff 75 08             	pushl  0x8(%ebp)
  801501:	e8 82 ff ff ff       	call   801488 <memmove>
}
  801506:	c9                   	leave  
  801507:	c3                   	ret    

00801508 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801508:	f3 0f 1e fb          	endbr32 
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	56                   	push   %esi
  801510:	53                   	push   %ebx
  801511:	8b 45 08             	mov    0x8(%ebp),%eax
  801514:	8b 55 0c             	mov    0xc(%ebp),%edx
  801517:	89 c6                	mov    %eax,%esi
  801519:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80151c:	39 f0                	cmp    %esi,%eax
  80151e:	74 1c                	je     80153c <memcmp+0x34>
		if (*s1 != *s2)
  801520:	0f b6 08             	movzbl (%eax),%ecx
  801523:	0f b6 1a             	movzbl (%edx),%ebx
  801526:	38 d9                	cmp    %bl,%cl
  801528:	75 08                	jne    801532 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80152a:	83 c0 01             	add    $0x1,%eax
  80152d:	83 c2 01             	add    $0x1,%edx
  801530:	eb ea                	jmp    80151c <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801532:	0f b6 c1             	movzbl %cl,%eax
  801535:	0f b6 db             	movzbl %bl,%ebx
  801538:	29 d8                	sub    %ebx,%eax
  80153a:	eb 05                	jmp    801541 <memcmp+0x39>
	}

	return 0;
  80153c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801541:	5b                   	pop    %ebx
  801542:	5e                   	pop    %esi
  801543:	5d                   	pop    %ebp
  801544:	c3                   	ret    

00801545 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801545:	f3 0f 1e fb          	endbr32 
  801549:	55                   	push   %ebp
  80154a:	89 e5                	mov    %esp,%ebp
  80154c:	8b 45 08             	mov    0x8(%ebp),%eax
  80154f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801552:	89 c2                	mov    %eax,%edx
  801554:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801557:	39 d0                	cmp    %edx,%eax
  801559:	73 09                	jae    801564 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  80155b:	38 08                	cmp    %cl,(%eax)
  80155d:	74 05                	je     801564 <memfind+0x1f>
	for (; s < ends; s++)
  80155f:	83 c0 01             	add    $0x1,%eax
  801562:	eb f3                	jmp    801557 <memfind+0x12>
			break;
	return (void *) s;
}
  801564:	5d                   	pop    %ebp
  801565:	c3                   	ret    

00801566 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801566:	f3 0f 1e fb          	endbr32 
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	57                   	push   %edi
  80156e:	56                   	push   %esi
  80156f:	53                   	push   %ebx
  801570:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801573:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801576:	eb 03                	jmp    80157b <strtol+0x15>
		s++;
  801578:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  80157b:	0f b6 01             	movzbl (%ecx),%eax
  80157e:	3c 20                	cmp    $0x20,%al
  801580:	74 f6                	je     801578 <strtol+0x12>
  801582:	3c 09                	cmp    $0x9,%al
  801584:	74 f2                	je     801578 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801586:	3c 2b                	cmp    $0x2b,%al
  801588:	74 2a                	je     8015b4 <strtol+0x4e>
	int neg = 0;
  80158a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80158f:	3c 2d                	cmp    $0x2d,%al
  801591:	74 2b                	je     8015be <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801593:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801599:	75 0f                	jne    8015aa <strtol+0x44>
  80159b:	80 39 30             	cmpb   $0x30,(%ecx)
  80159e:	74 28                	je     8015c8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8015a0:	85 db                	test   %ebx,%ebx
  8015a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8015a7:	0f 44 d8             	cmove  %eax,%ebx
  8015aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8015af:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8015b2:	eb 46                	jmp    8015fa <strtol+0x94>
		s++;
  8015b4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8015b7:	bf 00 00 00 00       	mov    $0x0,%edi
  8015bc:	eb d5                	jmp    801593 <strtol+0x2d>
		s++, neg = 1;
  8015be:	83 c1 01             	add    $0x1,%ecx
  8015c1:	bf 01 00 00 00       	mov    $0x1,%edi
  8015c6:	eb cb                	jmp    801593 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8015c8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8015cc:	74 0e                	je     8015dc <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8015ce:	85 db                	test   %ebx,%ebx
  8015d0:	75 d8                	jne    8015aa <strtol+0x44>
		s++, base = 8;
  8015d2:	83 c1 01             	add    $0x1,%ecx
  8015d5:	bb 08 00 00 00       	mov    $0x8,%ebx
  8015da:	eb ce                	jmp    8015aa <strtol+0x44>
		s += 2, base = 16;
  8015dc:	83 c1 02             	add    $0x2,%ecx
  8015df:	bb 10 00 00 00       	mov    $0x10,%ebx
  8015e4:	eb c4                	jmp    8015aa <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8015e6:	0f be d2             	movsbl %dl,%edx
  8015e9:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8015ec:	3b 55 10             	cmp    0x10(%ebp),%edx
  8015ef:	7d 3a                	jge    80162b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8015f1:	83 c1 01             	add    $0x1,%ecx
  8015f4:	0f af 45 10          	imul   0x10(%ebp),%eax
  8015f8:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8015fa:	0f b6 11             	movzbl (%ecx),%edx
  8015fd:	8d 72 d0             	lea    -0x30(%edx),%esi
  801600:	89 f3                	mov    %esi,%ebx
  801602:	80 fb 09             	cmp    $0x9,%bl
  801605:	76 df                	jbe    8015e6 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801607:	8d 72 9f             	lea    -0x61(%edx),%esi
  80160a:	89 f3                	mov    %esi,%ebx
  80160c:	80 fb 19             	cmp    $0x19,%bl
  80160f:	77 08                	ja     801619 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801611:	0f be d2             	movsbl %dl,%edx
  801614:	83 ea 57             	sub    $0x57,%edx
  801617:	eb d3                	jmp    8015ec <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801619:	8d 72 bf             	lea    -0x41(%edx),%esi
  80161c:	89 f3                	mov    %esi,%ebx
  80161e:	80 fb 19             	cmp    $0x19,%bl
  801621:	77 08                	ja     80162b <strtol+0xc5>
			dig = *s - 'A' + 10;
  801623:	0f be d2             	movsbl %dl,%edx
  801626:	83 ea 37             	sub    $0x37,%edx
  801629:	eb c1                	jmp    8015ec <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  80162b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80162f:	74 05                	je     801636 <strtol+0xd0>
		*endptr = (char *) s;
  801631:	8b 75 0c             	mov    0xc(%ebp),%esi
  801634:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801636:	89 c2                	mov    %eax,%edx
  801638:	f7 da                	neg    %edx
  80163a:	85 ff                	test   %edi,%edi
  80163c:	0f 45 c2             	cmovne %edx,%eax
}
  80163f:	5b                   	pop    %ebx
  801640:	5e                   	pop    %esi
  801641:	5f                   	pop    %edi
  801642:	5d                   	pop    %ebp
  801643:	c3                   	ret    

00801644 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801644:	f3 0f 1e fb          	endbr32 
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	57                   	push   %edi
  80164c:	56                   	push   %esi
  80164d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80164e:	b8 00 00 00 00       	mov    $0x0,%eax
  801653:	8b 55 08             	mov    0x8(%ebp),%edx
  801656:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801659:	89 c3                	mov    %eax,%ebx
  80165b:	89 c7                	mov    %eax,%edi
  80165d:	89 c6                	mov    %eax,%esi
  80165f:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801661:	5b                   	pop    %ebx
  801662:	5e                   	pop    %esi
  801663:	5f                   	pop    %edi
  801664:	5d                   	pop    %ebp
  801665:	c3                   	ret    

00801666 <sys_cgetc>:

int
sys_cgetc(void)
{
  801666:	f3 0f 1e fb          	endbr32 
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	57                   	push   %edi
  80166e:	56                   	push   %esi
  80166f:	53                   	push   %ebx
	asm volatile("int %1\n"
  801670:	ba 00 00 00 00       	mov    $0x0,%edx
  801675:	b8 01 00 00 00       	mov    $0x1,%eax
  80167a:	89 d1                	mov    %edx,%ecx
  80167c:	89 d3                	mov    %edx,%ebx
  80167e:	89 d7                	mov    %edx,%edi
  801680:	89 d6                	mov    %edx,%esi
  801682:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801684:	5b                   	pop    %ebx
  801685:	5e                   	pop    %esi
  801686:	5f                   	pop    %edi
  801687:	5d                   	pop    %ebp
  801688:	c3                   	ret    

00801689 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801689:	f3 0f 1e fb          	endbr32 
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	57                   	push   %edi
  801691:	56                   	push   %esi
  801692:	53                   	push   %ebx
	asm volatile("int %1\n"
  801693:	b9 00 00 00 00       	mov    $0x0,%ecx
  801698:	8b 55 08             	mov    0x8(%ebp),%edx
  80169b:	b8 03 00 00 00       	mov    $0x3,%eax
  8016a0:	89 cb                	mov    %ecx,%ebx
  8016a2:	89 cf                	mov    %ecx,%edi
  8016a4:	89 ce                	mov    %ecx,%esi
  8016a6:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8016a8:	5b                   	pop    %ebx
  8016a9:	5e                   	pop    %esi
  8016aa:	5f                   	pop    %edi
  8016ab:	5d                   	pop    %ebp
  8016ac:	c3                   	ret    

008016ad <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8016ad:	f3 0f 1e fb          	endbr32 
  8016b1:	55                   	push   %ebp
  8016b2:	89 e5                	mov    %esp,%ebp
  8016b4:	57                   	push   %edi
  8016b5:	56                   	push   %esi
  8016b6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8016b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016bc:	b8 02 00 00 00       	mov    $0x2,%eax
  8016c1:	89 d1                	mov    %edx,%ecx
  8016c3:	89 d3                	mov    %edx,%ebx
  8016c5:	89 d7                	mov    %edx,%edi
  8016c7:	89 d6                	mov    %edx,%esi
  8016c9:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8016cb:	5b                   	pop    %ebx
  8016cc:	5e                   	pop    %esi
  8016cd:	5f                   	pop    %edi
  8016ce:	5d                   	pop    %ebp
  8016cf:	c3                   	ret    

008016d0 <sys_yield>:

void
sys_yield(void)
{
  8016d0:	f3 0f 1e fb          	endbr32 
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	57                   	push   %edi
  8016d8:	56                   	push   %esi
  8016d9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8016da:	ba 00 00 00 00       	mov    $0x0,%edx
  8016df:	b8 0b 00 00 00       	mov    $0xb,%eax
  8016e4:	89 d1                	mov    %edx,%ecx
  8016e6:	89 d3                	mov    %edx,%ebx
  8016e8:	89 d7                	mov    %edx,%edi
  8016ea:	89 d6                	mov    %edx,%esi
  8016ec:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8016ee:	5b                   	pop    %ebx
  8016ef:	5e                   	pop    %esi
  8016f0:	5f                   	pop    %edi
  8016f1:	5d                   	pop    %ebp
  8016f2:	c3                   	ret    

008016f3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8016f3:	f3 0f 1e fb          	endbr32 
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	57                   	push   %edi
  8016fb:	56                   	push   %esi
  8016fc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8016fd:	be 00 00 00 00       	mov    $0x0,%esi
  801702:	8b 55 08             	mov    0x8(%ebp),%edx
  801705:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801708:	b8 04 00 00 00       	mov    $0x4,%eax
  80170d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801710:	89 f7                	mov    %esi,%edi
  801712:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801714:	5b                   	pop    %ebx
  801715:	5e                   	pop    %esi
  801716:	5f                   	pop    %edi
  801717:	5d                   	pop    %ebp
  801718:	c3                   	ret    

00801719 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801719:	f3 0f 1e fb          	endbr32 
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	57                   	push   %edi
  801721:	56                   	push   %esi
  801722:	53                   	push   %ebx
	asm volatile("int %1\n"
  801723:	8b 55 08             	mov    0x8(%ebp),%edx
  801726:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801729:	b8 05 00 00 00       	mov    $0x5,%eax
  80172e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801731:	8b 7d 14             	mov    0x14(%ebp),%edi
  801734:	8b 75 18             	mov    0x18(%ebp),%esi
  801737:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801739:	5b                   	pop    %ebx
  80173a:	5e                   	pop    %esi
  80173b:	5f                   	pop    %edi
  80173c:	5d                   	pop    %ebp
  80173d:	c3                   	ret    

0080173e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80173e:	f3 0f 1e fb          	endbr32 
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	57                   	push   %edi
  801746:	56                   	push   %esi
  801747:	53                   	push   %ebx
	asm volatile("int %1\n"
  801748:	bb 00 00 00 00       	mov    $0x0,%ebx
  80174d:	8b 55 08             	mov    0x8(%ebp),%edx
  801750:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801753:	b8 06 00 00 00       	mov    $0x6,%eax
  801758:	89 df                	mov    %ebx,%edi
  80175a:	89 de                	mov    %ebx,%esi
  80175c:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80175e:	5b                   	pop    %ebx
  80175f:	5e                   	pop    %esi
  801760:	5f                   	pop    %edi
  801761:	5d                   	pop    %ebp
  801762:	c3                   	ret    

00801763 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801763:	f3 0f 1e fb          	endbr32 
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	57                   	push   %edi
  80176b:	56                   	push   %esi
  80176c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80176d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801772:	8b 55 08             	mov    0x8(%ebp),%edx
  801775:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801778:	b8 08 00 00 00       	mov    $0x8,%eax
  80177d:	89 df                	mov    %ebx,%edi
  80177f:	89 de                	mov    %ebx,%esi
  801781:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801783:	5b                   	pop    %ebx
  801784:	5e                   	pop    %esi
  801785:	5f                   	pop    %edi
  801786:	5d                   	pop    %ebp
  801787:	c3                   	ret    

00801788 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801788:	f3 0f 1e fb          	endbr32 
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	57                   	push   %edi
  801790:	56                   	push   %esi
  801791:	53                   	push   %ebx
	asm volatile("int %1\n"
  801792:	bb 00 00 00 00       	mov    $0x0,%ebx
  801797:	8b 55 08             	mov    0x8(%ebp),%edx
  80179a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80179d:	b8 09 00 00 00       	mov    $0x9,%eax
  8017a2:	89 df                	mov    %ebx,%edi
  8017a4:	89 de                	mov    %ebx,%esi
  8017a6:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8017a8:	5b                   	pop    %ebx
  8017a9:	5e                   	pop    %esi
  8017aa:	5f                   	pop    %edi
  8017ab:	5d                   	pop    %ebp
  8017ac:	c3                   	ret    

008017ad <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8017ad:	f3 0f 1e fb          	endbr32 
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	57                   	push   %edi
  8017b5:	56                   	push   %esi
  8017b6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8017b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8017bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8017c7:	89 df                	mov    %ebx,%edi
  8017c9:	89 de                	mov    %ebx,%esi
  8017cb:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8017cd:	5b                   	pop    %ebx
  8017ce:	5e                   	pop    %esi
  8017cf:	5f                   	pop    %edi
  8017d0:	5d                   	pop    %ebp
  8017d1:	c3                   	ret    

008017d2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8017d2:	f3 0f 1e fb          	endbr32 
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	57                   	push   %edi
  8017da:	56                   	push   %esi
  8017db:	53                   	push   %ebx
	asm volatile("int %1\n"
  8017dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8017df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017e2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8017e7:	be 00 00 00 00       	mov    $0x0,%esi
  8017ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8017ef:	8b 7d 14             	mov    0x14(%ebp),%edi
  8017f2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8017f4:	5b                   	pop    %ebx
  8017f5:	5e                   	pop    %esi
  8017f6:	5f                   	pop    %edi
  8017f7:	5d                   	pop    %ebp
  8017f8:	c3                   	ret    

008017f9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8017f9:	f3 0f 1e fb          	endbr32 
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	57                   	push   %edi
  801801:	56                   	push   %esi
  801802:	53                   	push   %ebx
	asm volatile("int %1\n"
  801803:	b9 00 00 00 00       	mov    $0x0,%ecx
  801808:	8b 55 08             	mov    0x8(%ebp),%edx
  80180b:	b8 0d 00 00 00       	mov    $0xd,%eax
  801810:	89 cb                	mov    %ecx,%ebx
  801812:	89 cf                	mov    %ecx,%edi
  801814:	89 ce                	mov    %ecx,%esi
  801816:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801818:	5b                   	pop    %ebx
  801819:	5e                   	pop    %esi
  80181a:	5f                   	pop    %edi
  80181b:	5d                   	pop    %ebp
  80181c:	c3                   	ret    

0080181d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80181d:	f3 0f 1e fb          	endbr32 
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	57                   	push   %edi
  801825:	56                   	push   %esi
  801826:	53                   	push   %ebx
	asm volatile("int %1\n"
  801827:	ba 00 00 00 00       	mov    $0x0,%edx
  80182c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801831:	89 d1                	mov    %edx,%ecx
  801833:	89 d3                	mov    %edx,%ebx
  801835:	89 d7                	mov    %edx,%edi
  801837:	89 d6                	mov    %edx,%esi
  801839:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80183b:	5b                   	pop    %ebx
  80183c:	5e                   	pop    %esi
  80183d:	5f                   	pop    %edi
  80183e:	5d                   	pop    %ebp
  80183f:	c3                   	ret    

00801840 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  801840:	f3 0f 1e fb          	endbr32 
  801844:	55                   	push   %ebp
  801845:	89 e5                	mov    %esp,%ebp
  801847:	57                   	push   %edi
  801848:	56                   	push   %esi
  801849:	53                   	push   %ebx
	asm volatile("int %1\n"
  80184a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80184f:	8b 55 08             	mov    0x8(%ebp),%edx
  801852:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801855:	b8 0f 00 00 00       	mov    $0xf,%eax
  80185a:	89 df                	mov    %ebx,%edi
  80185c:	89 de                	mov    %ebx,%esi
  80185e:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  801860:	5b                   	pop    %ebx
  801861:	5e                   	pop    %esi
  801862:	5f                   	pop    %edi
  801863:	5d                   	pop    %ebp
  801864:	c3                   	ret    

00801865 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  801865:	f3 0f 1e fb          	endbr32 
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	57                   	push   %edi
  80186d:	56                   	push   %esi
  80186e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80186f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801874:	8b 55 08             	mov    0x8(%ebp),%edx
  801877:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80187a:	b8 10 00 00 00       	mov    $0x10,%eax
  80187f:	89 df                	mov    %ebx,%edi
  801881:	89 de                	mov    %ebx,%esi
  801883:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  801885:	5b                   	pop    %ebx
  801886:	5e                   	pop    %esi
  801887:	5f                   	pop    %edi
  801888:	5d                   	pop    %ebp
  801889:	c3                   	ret    

0080188a <pgfault>:
// map in our own private writable copy.
//
extern int cnt;
static void
pgfault(struct UTrapframe *utf)
{
  80188a:	f3 0f 1e fb          	endbr32 
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	53                   	push   %ebx
  801892:	83 ec 04             	sub    $0x4,%esp
  801895:	8b 45 08             	mov    0x8(%ebp),%eax
	// cprintf("[%08x] called pgfault\n", sys_getenvid());
	void *addr = (void *) utf->utf_fault_va;
  801898:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err&FEC_WR)&&(uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_COW))){
  80189a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80189e:	0f 84 9a 00 00 00    	je     80193e <pgfault+0xb4>
  8018a4:	89 d8                	mov    %ebx,%eax
  8018a6:	c1 e8 16             	shr    $0x16,%eax
  8018a9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018b0:	a8 01                	test   $0x1,%al
  8018b2:	0f 84 86 00 00 00    	je     80193e <pgfault+0xb4>
  8018b8:	89 d8                	mov    %ebx,%eax
  8018ba:	c1 e8 0c             	shr    $0xc,%eax
  8018bd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018c4:	f6 c2 01             	test   $0x1,%dl
  8018c7:	74 75                	je     80193e <pgfault+0xb4>
  8018c9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018d0:	f6 c4 08             	test   $0x8,%ah
  8018d3:	74 69                	je     80193e <pgfault+0xb4>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 在PFTEMP这里给一个物理地址的mapping 相当于store一个物理地址
	if((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W))<0){
  8018d5:	83 ec 04             	sub    $0x4,%esp
  8018d8:	6a 07                	push   $0x7
  8018da:	68 00 f0 7f 00       	push   $0x7ff000
  8018df:	6a 00                	push   $0x0
  8018e1:	e8 0d fe ff ff       	call   8016f3 <sys_page_alloc>
  8018e6:	83 c4 10             	add    $0x10,%esp
  8018e9:	85 c0                	test   %eax,%eax
  8018eb:	78 63                	js     801950 <pgfault+0xc6>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  8018ed:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// 先复制addr里的content
	memcpy((void*)PFTEMP, addr, PGSIZE);
  8018f3:	83 ec 04             	sub    $0x4,%esp
  8018f6:	68 00 10 00 00       	push   $0x1000
  8018fb:	53                   	push   %ebx
  8018fc:	68 00 f0 7f 00       	push   $0x7ff000
  801901:	e8 e8 fb ff ff       	call   8014ee <memcpy>
	// 在remap addr到PFTEMP位置 即addr与PFTEMP指向同一个物理内存
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))<0){
  801906:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80190d:	53                   	push   %ebx
  80190e:	6a 00                	push   $0x0
  801910:	68 00 f0 7f 00       	push   $0x7ff000
  801915:	6a 00                	push   $0x0
  801917:	e8 fd fd ff ff       	call   801719 <sys_page_map>
  80191c:	83 c4 20             	add    $0x20,%esp
  80191f:	85 c0                	test   %eax,%eax
  801921:	78 3f                	js     801962 <pgfault+0xd8>
		panic("pgfault: sys_page_map failed due to %e\n", r);
	}
	if ((r = sys_page_unmap(0, (void*)PFTEMP))<0){
  801923:	83 ec 08             	sub    $0x8,%esp
  801926:	68 00 f0 7f 00       	push   $0x7ff000
  80192b:	6a 00                	push   $0x0
  80192d:	e8 0c fe ff ff       	call   80173e <sys_page_unmap>
  801932:	83 c4 10             	add    $0x10,%esp
  801935:	85 c0                	test   %eax,%eax
  801937:	78 3b                	js     801974 <pgfault+0xea>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
	}
	
	
}
  801939:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80193c:	c9                   	leave  
  80193d:	c3                   	ret    
		panic("pgfault: page access at %08x is not a write to a copy-on-write\n", addr);
  80193e:	53                   	push   %ebx
  80193f:	68 30 3e 80 00       	push   $0x803e30
  801944:	6a 20                	push   $0x20
  801946:	68 ee 3e 80 00       	push   $0x803eee
  80194b:	e8 55 f1 ff ff       	call   800aa5 <_panic>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
  801950:	50                   	push   %eax
  801951:	68 70 3e 80 00       	push   $0x803e70
  801956:	6a 2c                	push   $0x2c
  801958:	68 ee 3e 80 00       	push   $0x803eee
  80195d:	e8 43 f1 ff ff       	call   800aa5 <_panic>
		panic("pgfault: sys_page_map failed due to %e\n", r);
  801962:	50                   	push   %eax
  801963:	68 9c 3e 80 00       	push   $0x803e9c
  801968:	6a 33                	push   $0x33
  80196a:	68 ee 3e 80 00       	push   $0x803eee
  80196f:	e8 31 f1 ff ff       	call   800aa5 <_panic>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
  801974:	50                   	push   %eax
  801975:	68 c4 3e 80 00       	push   $0x803ec4
  80197a:	6a 36                	push   $0x36
  80197c:	68 ee 3e 80 00       	push   $0x803eee
  801981:	e8 1f f1 ff ff       	call   800aa5 <_panic>

00801986 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801986:	f3 0f 1e fb          	endbr32 
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	57                   	push   %edi
  80198e:	56                   	push   %esi
  80198f:	53                   	push   %ebx
  801990:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[%08x] called fork\n", sys_getenvid());
	int r; uintptr_t addr;
	set_pgfault_handler(pgfault);
  801993:	68 8a 18 80 00       	push   $0x80188a
  801998:	e8 ee 1a 00 00       	call   80348b <set_pgfault_handler>
*/
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80199d:	b8 07 00 00 00       	mov    $0x7,%eax
  8019a2:	cd 30                	int    $0x30
  8019a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();
		
	if (envid<0){
  8019a7:	83 c4 10             	add    $0x10,%esp
  8019aa:	85 c0                	test   %eax,%eax
  8019ac:	78 29                	js     8019d7 <fork+0x51>
  8019ae:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	// duplicate parent address space
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  8019b0:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid==0){
  8019b5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8019b9:	75 60                	jne    801a1b <fork+0x95>
		thisenv = &envs[ENVX(sys_getenvid())];
  8019bb:	e8 ed fc ff ff       	call   8016ad <sys_getenvid>
  8019c0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8019c5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8019c8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8019cd:	a3 28 64 80 00       	mov    %eax,0x806428
		return 0;
  8019d2:	e9 14 01 00 00       	jmp    801aeb <fork+0x165>
		panic("fork: sys_exofork error %e\n", envid);
  8019d7:	50                   	push   %eax
  8019d8:	68 f9 3e 80 00       	push   $0x803ef9
  8019dd:	68 90 00 00 00       	push   $0x90
  8019e2:	68 ee 3e 80 00       	push   $0x803eee
  8019e7:	e8 b9 f0 ff ff       	call   800aa5 <_panic>
		r = sys_page_map(0, addr, envid, addr, (uvpt[pn]&PTE_SYSCALL));
  8019ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019f3:	83 ec 0c             	sub    $0xc,%esp
  8019f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8019fb:	50                   	push   %eax
  8019fc:	56                   	push   %esi
  8019fd:	57                   	push   %edi
  8019fe:	56                   	push   %esi
  8019ff:	6a 00                	push   $0x0
  801a01:	e8 13 fd ff ff       	call   801719 <sys_page_map>
  801a06:	83 c4 20             	add    $0x20,%esp
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  801a09:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a0f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801a15:	0f 84 95 00 00 00    	je     801ab0 <fork+0x12a>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  801a1b:	89 d8                	mov    %ebx,%eax
  801a1d:	c1 e8 16             	shr    $0x16,%eax
  801a20:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a27:	a8 01                	test   $0x1,%al
  801a29:	74 de                	je     801a09 <fork+0x83>
  801a2b:	89 d8                	mov    %ebx,%eax
  801a2d:	c1 e8 0c             	shr    $0xc,%eax
  801a30:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a37:	f6 c2 01             	test   $0x1,%dl
  801a3a:	74 cd                	je     801a09 <fork+0x83>
	void* addr = (void*)(pn*PGSIZE);
  801a3c:	89 c6                	mov    %eax,%esi
  801a3e:	c1 e6 0c             	shl    $0xc,%esi
	if (uvpt[pn]&PTE_SHARE){
  801a41:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a48:	f6 c6 04             	test   $0x4,%dh
  801a4b:	75 9f                	jne    8019ec <fork+0x66>
		if (uvpt[pn]&PTE_W||uvpt[pn]&PTE_COW){
  801a4d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a54:	f6 c2 02             	test   $0x2,%dl
  801a57:	75 0c                	jne    801a65 <fork+0xdf>
  801a59:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a60:	f6 c4 08             	test   $0x8,%ah
  801a63:	74 34                	je     801a99 <fork+0x113>
			r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P); // not writable
  801a65:	83 ec 0c             	sub    $0xc,%esp
  801a68:	68 05 08 00 00       	push   $0x805
  801a6d:	56                   	push   %esi
  801a6e:	57                   	push   %edi
  801a6f:	56                   	push   %esi
  801a70:	6a 00                	push   $0x0
  801a72:	e8 a2 fc ff ff       	call   801719 <sys_page_map>
			if (r<0) return r;
  801a77:	83 c4 20             	add    $0x20,%esp
  801a7a:	85 c0                	test   %eax,%eax
  801a7c:	78 8b                	js     801a09 <fork+0x83>
			r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P); // not writable
  801a7e:	83 ec 0c             	sub    $0xc,%esp
  801a81:	68 05 08 00 00       	push   $0x805
  801a86:	56                   	push   %esi
  801a87:	6a 00                	push   $0x0
  801a89:	56                   	push   %esi
  801a8a:	6a 00                	push   $0x0
  801a8c:	e8 88 fc ff ff       	call   801719 <sys_page_map>
  801a91:	83 c4 20             	add    $0x20,%esp
  801a94:	e9 70 ff ff ff       	jmp    801a09 <fork+0x83>
			if ((r=sys_page_map(0, addr, envid, addr, PTE_P|PTE_U)<0))// read only
  801a99:	83 ec 0c             	sub    $0xc,%esp
  801a9c:	6a 05                	push   $0x5
  801a9e:	56                   	push   %esi
  801a9f:	57                   	push   %edi
  801aa0:	56                   	push   %esi
  801aa1:	6a 00                	push   $0x0
  801aa3:	e8 71 fc ff ff       	call   801719 <sys_page_map>
  801aa8:	83 c4 20             	add    $0x20,%esp
  801aab:	e9 59 ff ff ff       	jmp    801a09 <fork+0x83>
			duppage(envid, PGNUM(addr));
		}
	}
	// allocate user exception stack
	// cprintf("alloc user expection stack\n");
	if ((r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_W|PTE_U))<0)
  801ab0:	83 ec 04             	sub    $0x4,%esp
  801ab3:	6a 07                	push   $0x7
  801ab5:	68 00 f0 bf ee       	push   $0xeebff000
  801aba:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801abd:	56                   	push   %esi
  801abe:	e8 30 fc ff ff       	call   8016f3 <sys_page_alloc>
  801ac3:	83 c4 10             	add    $0x10,%esp
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	78 2b                	js     801af5 <fork+0x16f>
		return r;
	
	extern void* _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801aca:	83 ec 08             	sub    $0x8,%esp
  801acd:	68 fe 34 80 00       	push   $0x8034fe
  801ad2:	56                   	push   %esi
  801ad3:	e8 d5 fc ff ff       	call   8017ad <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE))<0)
  801ad8:	83 c4 08             	add    $0x8,%esp
  801adb:	6a 02                	push   $0x2
  801add:	56                   	push   %esi
  801ade:	e8 80 fc ff ff       	call   801763 <sys_env_set_status>
  801ae3:	83 c4 10             	add    $0x10,%esp
		return r;
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	0f 48 f8             	cmovs  %eax,%edi

	return envid;
	
}
  801aeb:	89 f8                	mov    %edi,%eax
  801aed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af0:	5b                   	pop    %ebx
  801af1:	5e                   	pop    %esi
  801af2:	5f                   	pop    %edi
  801af3:	5d                   	pop    %ebp
  801af4:	c3                   	ret    
		return r;
  801af5:	89 c7                	mov    %eax,%edi
  801af7:	eb f2                	jmp    801aeb <fork+0x165>

00801af9 <sfork>:

// Challenge(not sure yet)
int
sfork(void)
{
  801af9:	f3 0f 1e fb          	endbr32 
  801afd:	55                   	push   %ebp
  801afe:	89 e5                	mov    %esp,%ebp
  801b00:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801b03:	68 15 3f 80 00       	push   $0x803f15
  801b08:	68 b2 00 00 00       	push   $0xb2
  801b0d:	68 ee 3e 80 00       	push   $0x803eee
  801b12:	e8 8e ef ff ff       	call   800aa5 <_panic>

00801b17 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801b17:	f3 0f 1e fb          	endbr32 
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	8b 55 08             	mov    0x8(%ebp),%edx
  801b21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b24:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801b27:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801b29:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801b2c:	83 3a 01             	cmpl   $0x1,(%edx)
  801b2f:	7e 09                	jle    801b3a <argstart+0x23>
  801b31:	ba 01 39 80 00       	mov    $0x803901,%edx
  801b36:	85 c9                	test   %ecx,%ecx
  801b38:	75 05                	jne    801b3f <argstart+0x28>
  801b3a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3f:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801b42:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801b49:	5d                   	pop    %ebp
  801b4a:	c3                   	ret    

00801b4b <argnext>:

int
argnext(struct Argstate *args)
{
  801b4b:	f3 0f 1e fb          	endbr32 
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	53                   	push   %ebx
  801b53:	83 ec 04             	sub    $0x4,%esp
  801b56:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801b59:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801b60:	8b 43 08             	mov    0x8(%ebx),%eax
  801b63:	85 c0                	test   %eax,%eax
  801b65:	74 74                	je     801bdb <argnext+0x90>
		return -1;

	if (!*args->curarg) {
  801b67:	80 38 00             	cmpb   $0x0,(%eax)
  801b6a:	75 48                	jne    801bb4 <argnext+0x69>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801b6c:	8b 0b                	mov    (%ebx),%ecx
  801b6e:	83 39 01             	cmpl   $0x1,(%ecx)
  801b71:	74 5a                	je     801bcd <argnext+0x82>
		    || args->argv[1][0] != '-'
  801b73:	8b 53 04             	mov    0x4(%ebx),%edx
  801b76:	8b 42 04             	mov    0x4(%edx),%eax
  801b79:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b7c:	75 4f                	jne    801bcd <argnext+0x82>
		    || args->argv[1][1] == '\0')
  801b7e:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b82:	74 49                	je     801bcd <argnext+0x82>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801b84:	83 c0 01             	add    $0x1,%eax
  801b87:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b8a:	83 ec 04             	sub    $0x4,%esp
  801b8d:	8b 01                	mov    (%ecx),%eax
  801b8f:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801b96:	50                   	push   %eax
  801b97:	8d 42 08             	lea    0x8(%edx),%eax
  801b9a:	50                   	push   %eax
  801b9b:	83 c2 04             	add    $0x4,%edx
  801b9e:	52                   	push   %edx
  801b9f:	e8 e4 f8 ff ff       	call   801488 <memmove>
		(*args->argc)--;
  801ba4:	8b 03                	mov    (%ebx),%eax
  801ba6:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801ba9:	8b 43 08             	mov    0x8(%ebx),%eax
  801bac:	83 c4 10             	add    $0x10,%esp
  801baf:	80 38 2d             	cmpb   $0x2d,(%eax)
  801bb2:	74 13                	je     801bc7 <argnext+0x7c>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801bb4:	8b 43 08             	mov    0x8(%ebx),%eax
  801bb7:	0f b6 10             	movzbl (%eax),%edx
	args->curarg++;
  801bba:	83 c0 01             	add    $0x1,%eax
  801bbd:	89 43 08             	mov    %eax,0x8(%ebx)
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801bc0:	89 d0                	mov    %edx,%eax
  801bc2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc5:	c9                   	leave  
  801bc6:	c3                   	ret    
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801bc7:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801bcb:	75 e7                	jne    801bb4 <argnext+0x69>
	args->curarg = 0;
  801bcd:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801bd4:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801bd9:	eb e5                	jmp    801bc0 <argnext+0x75>
		return -1;
  801bdb:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801be0:	eb de                	jmp    801bc0 <argnext+0x75>

00801be2 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801be2:	f3 0f 1e fb          	endbr32 
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	53                   	push   %ebx
  801bea:	83 ec 04             	sub    $0x4,%esp
  801bed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801bf0:	8b 43 08             	mov    0x8(%ebx),%eax
  801bf3:	85 c0                	test   %eax,%eax
  801bf5:	74 12                	je     801c09 <argnextvalue+0x27>
		return 0;
	if (*args->curarg) {
  801bf7:	80 38 00             	cmpb   $0x0,(%eax)
  801bfa:	74 12                	je     801c0e <argnextvalue+0x2c>
		args->argvalue = args->curarg;
  801bfc:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801bff:	c7 43 08 01 39 80 00 	movl   $0x803901,0x8(%ebx)
		(*args->argc)--;
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
  801c06:	8b 43 0c             	mov    0xc(%ebx),%eax
}
  801c09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c0c:	c9                   	leave  
  801c0d:	c3                   	ret    
	} else if (*args->argc > 1) {
  801c0e:	8b 13                	mov    (%ebx),%edx
  801c10:	83 3a 01             	cmpl   $0x1,(%edx)
  801c13:	7f 10                	jg     801c25 <argnextvalue+0x43>
		args->argvalue = 0;
  801c15:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801c1c:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  801c23:	eb e1                	jmp    801c06 <argnextvalue+0x24>
		args->argvalue = args->argv[1];
  801c25:	8b 43 04             	mov    0x4(%ebx),%eax
  801c28:	8b 48 04             	mov    0x4(%eax),%ecx
  801c2b:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801c2e:	83 ec 04             	sub    $0x4,%esp
  801c31:	8b 12                	mov    (%edx),%edx
  801c33:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801c3a:	52                   	push   %edx
  801c3b:	8d 50 08             	lea    0x8(%eax),%edx
  801c3e:	52                   	push   %edx
  801c3f:	83 c0 04             	add    $0x4,%eax
  801c42:	50                   	push   %eax
  801c43:	e8 40 f8 ff ff       	call   801488 <memmove>
		(*args->argc)--;
  801c48:	8b 03                	mov    (%ebx),%eax
  801c4a:	83 28 01             	subl   $0x1,(%eax)
  801c4d:	83 c4 10             	add    $0x10,%esp
  801c50:	eb b4                	jmp    801c06 <argnextvalue+0x24>

00801c52 <argvalue>:
{
  801c52:	f3 0f 1e fb          	endbr32 
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	83 ec 08             	sub    $0x8,%esp
  801c5c:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801c5f:	8b 42 0c             	mov    0xc(%edx),%eax
  801c62:	85 c0                	test   %eax,%eax
  801c64:	74 02                	je     801c68 <argvalue+0x16>
}
  801c66:	c9                   	leave  
  801c67:	c3                   	ret    
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801c68:	83 ec 0c             	sub    $0xc,%esp
  801c6b:	52                   	push   %edx
  801c6c:	e8 71 ff ff ff       	call   801be2 <argnextvalue>
  801c71:	83 c4 10             	add    $0x10,%esp
  801c74:	eb f0                	jmp    801c66 <argvalue+0x14>

00801c76 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801c76:	f3 0f 1e fb          	endbr32 
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c80:	05 00 00 00 30       	add    $0x30000000,%eax
  801c85:	c1 e8 0c             	shr    $0xc,%eax
}
  801c88:	5d                   	pop    %ebp
  801c89:	c3                   	ret    

00801c8a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801c8a:	f3 0f 1e fb          	endbr32 
  801c8e:	55                   	push   %ebp
  801c8f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c91:	8b 45 08             	mov    0x8(%ebp),%eax
  801c94:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801c99:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801c9e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801ca3:	5d                   	pop    %ebp
  801ca4:	c3                   	ret    

00801ca5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801ca5:	f3 0f 1e fb          	endbr32 
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801cb1:	89 c2                	mov    %eax,%edx
  801cb3:	c1 ea 16             	shr    $0x16,%edx
  801cb6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cbd:	f6 c2 01             	test   $0x1,%dl
  801cc0:	74 2d                	je     801cef <fd_alloc+0x4a>
  801cc2:	89 c2                	mov    %eax,%edx
  801cc4:	c1 ea 0c             	shr    $0xc,%edx
  801cc7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801cce:	f6 c2 01             	test   $0x1,%dl
  801cd1:	74 1c                	je     801cef <fd_alloc+0x4a>
  801cd3:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801cd8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801cdd:	75 d2                	jne    801cb1 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  801cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801ce8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801ced:	eb 0a                	jmp    801cf9 <fd_alloc+0x54>
			*fd_store = fd;
  801cef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cf2:	89 01                	mov    %eax,(%ecx)
			return 0;
  801cf4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cf9:	5d                   	pop    %ebp
  801cfa:	c3                   	ret    

00801cfb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801cfb:	f3 0f 1e fb          	endbr32 
  801cff:	55                   	push   %ebp
  801d00:	89 e5                	mov    %esp,%ebp
  801d02:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801d05:	83 f8 1f             	cmp    $0x1f,%eax
  801d08:	77 30                	ja     801d3a <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801d0a:	c1 e0 0c             	shl    $0xc,%eax
  801d0d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801d12:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801d18:	f6 c2 01             	test   $0x1,%dl
  801d1b:	74 24                	je     801d41 <fd_lookup+0x46>
  801d1d:	89 c2                	mov    %eax,%edx
  801d1f:	c1 ea 0c             	shr    $0xc,%edx
  801d22:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d29:	f6 c2 01             	test   $0x1,%dl
  801d2c:	74 1a                	je     801d48 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801d2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d31:	89 02                	mov    %eax,(%edx)
	return 0;
  801d33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d38:	5d                   	pop    %ebp
  801d39:	c3                   	ret    
		return -E_INVAL;
  801d3a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d3f:	eb f7                	jmp    801d38 <fd_lookup+0x3d>
		return -E_INVAL;
  801d41:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d46:	eb f0                	jmp    801d38 <fd_lookup+0x3d>
  801d48:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d4d:	eb e9                	jmp    801d38 <fd_lookup+0x3d>

00801d4f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801d4f:	f3 0f 1e fb          	endbr32 
  801d53:	55                   	push   %ebp
  801d54:	89 e5                	mov    %esp,%ebp
  801d56:	83 ec 08             	sub    $0x8,%esp
  801d59:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801d5c:	ba 00 00 00 00       	mov    $0x0,%edx
  801d61:	b8 20 50 80 00       	mov    $0x805020,%eax
		if (devtab[i]->dev_id == dev_id) {
  801d66:	39 08                	cmp    %ecx,(%eax)
  801d68:	74 38                	je     801da2 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  801d6a:	83 c2 01             	add    $0x1,%edx
  801d6d:	8b 04 95 a8 3f 80 00 	mov    0x803fa8(,%edx,4),%eax
  801d74:	85 c0                	test   %eax,%eax
  801d76:	75 ee                	jne    801d66 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801d78:	a1 28 64 80 00       	mov    0x806428,%eax
  801d7d:	8b 40 48             	mov    0x48(%eax),%eax
  801d80:	83 ec 04             	sub    $0x4,%esp
  801d83:	51                   	push   %ecx
  801d84:	50                   	push   %eax
  801d85:	68 2c 3f 80 00       	push   $0x803f2c
  801d8a:	e8 fd ed ff ff       	call   800b8c <cprintf>
	*dev = 0;
  801d8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d92:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801d98:	83 c4 10             	add    $0x10,%esp
  801d9b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801da0:	c9                   	leave  
  801da1:	c3                   	ret    
			*dev = devtab[i];
  801da2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801da5:	89 01                	mov    %eax,(%ecx)
			return 0;
  801da7:	b8 00 00 00 00       	mov    $0x0,%eax
  801dac:	eb f2                	jmp    801da0 <dev_lookup+0x51>

00801dae <fd_close>:
{
  801dae:	f3 0f 1e fb          	endbr32 
  801db2:	55                   	push   %ebp
  801db3:	89 e5                	mov    %esp,%ebp
  801db5:	57                   	push   %edi
  801db6:	56                   	push   %esi
  801db7:	53                   	push   %ebx
  801db8:	83 ec 24             	sub    $0x24,%esp
  801dbb:	8b 75 08             	mov    0x8(%ebp),%esi
  801dbe:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801dc1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801dc4:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801dc5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801dcb:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801dce:	50                   	push   %eax
  801dcf:	e8 27 ff ff ff       	call   801cfb <fd_lookup>
  801dd4:	89 c3                	mov    %eax,%ebx
  801dd6:	83 c4 10             	add    $0x10,%esp
  801dd9:	85 c0                	test   %eax,%eax
  801ddb:	78 05                	js     801de2 <fd_close+0x34>
	    || fd != fd2)
  801ddd:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801de0:	74 16                	je     801df8 <fd_close+0x4a>
		return (must_exist ? r : 0);
  801de2:	89 f8                	mov    %edi,%eax
  801de4:	84 c0                	test   %al,%al
  801de6:	b8 00 00 00 00       	mov    $0x0,%eax
  801deb:	0f 44 d8             	cmove  %eax,%ebx
}
  801dee:	89 d8                	mov    %ebx,%eax
  801df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df3:	5b                   	pop    %ebx
  801df4:	5e                   	pop    %esi
  801df5:	5f                   	pop    %edi
  801df6:	5d                   	pop    %ebp
  801df7:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801df8:	83 ec 08             	sub    $0x8,%esp
  801dfb:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801dfe:	50                   	push   %eax
  801dff:	ff 36                	pushl  (%esi)
  801e01:	e8 49 ff ff ff       	call   801d4f <dev_lookup>
  801e06:	89 c3                	mov    %eax,%ebx
  801e08:	83 c4 10             	add    $0x10,%esp
  801e0b:	85 c0                	test   %eax,%eax
  801e0d:	78 1a                	js     801e29 <fd_close+0x7b>
		if (dev->dev_close)
  801e0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e12:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801e15:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	74 0b                	je     801e29 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801e1e:	83 ec 0c             	sub    $0xc,%esp
  801e21:	56                   	push   %esi
  801e22:	ff d0                	call   *%eax
  801e24:	89 c3                	mov    %eax,%ebx
  801e26:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801e29:	83 ec 08             	sub    $0x8,%esp
  801e2c:	56                   	push   %esi
  801e2d:	6a 00                	push   $0x0
  801e2f:	e8 0a f9 ff ff       	call   80173e <sys_page_unmap>
	return r;
  801e34:	83 c4 10             	add    $0x10,%esp
  801e37:	eb b5                	jmp    801dee <fd_close+0x40>

00801e39 <close>:

int
close(int fdnum)
{
  801e39:	f3 0f 1e fb          	endbr32 
  801e3d:	55                   	push   %ebp
  801e3e:	89 e5                	mov    %esp,%ebp
  801e40:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e43:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e46:	50                   	push   %eax
  801e47:	ff 75 08             	pushl  0x8(%ebp)
  801e4a:	e8 ac fe ff ff       	call   801cfb <fd_lookup>
  801e4f:	83 c4 10             	add    $0x10,%esp
  801e52:	85 c0                	test   %eax,%eax
  801e54:	79 02                	jns    801e58 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801e56:	c9                   	leave  
  801e57:	c3                   	ret    
		return fd_close(fd, 1);
  801e58:	83 ec 08             	sub    $0x8,%esp
  801e5b:	6a 01                	push   $0x1
  801e5d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e60:	e8 49 ff ff ff       	call   801dae <fd_close>
  801e65:	83 c4 10             	add    $0x10,%esp
  801e68:	eb ec                	jmp    801e56 <close+0x1d>

00801e6a <close_all>:

void
close_all(void)
{
  801e6a:	f3 0f 1e fb          	endbr32 
  801e6e:	55                   	push   %ebp
  801e6f:	89 e5                	mov    %esp,%ebp
  801e71:	53                   	push   %ebx
  801e72:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801e75:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801e7a:	83 ec 0c             	sub    $0xc,%esp
  801e7d:	53                   	push   %ebx
  801e7e:	e8 b6 ff ff ff       	call   801e39 <close>
	for (i = 0; i < MAXFD; i++)
  801e83:	83 c3 01             	add    $0x1,%ebx
  801e86:	83 c4 10             	add    $0x10,%esp
  801e89:	83 fb 20             	cmp    $0x20,%ebx
  801e8c:	75 ec                	jne    801e7a <close_all+0x10>
}
  801e8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e91:	c9                   	leave  
  801e92:	c3                   	ret    

00801e93 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801e93:	f3 0f 1e fb          	endbr32 
  801e97:	55                   	push   %ebp
  801e98:	89 e5                	mov    %esp,%ebp
  801e9a:	57                   	push   %edi
  801e9b:	56                   	push   %esi
  801e9c:	53                   	push   %ebx
  801e9d:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801ea0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ea3:	50                   	push   %eax
  801ea4:	ff 75 08             	pushl  0x8(%ebp)
  801ea7:	e8 4f fe ff ff       	call   801cfb <fd_lookup>
  801eac:	89 c3                	mov    %eax,%ebx
  801eae:	83 c4 10             	add    $0x10,%esp
  801eb1:	85 c0                	test   %eax,%eax
  801eb3:	0f 88 81 00 00 00    	js     801f3a <dup+0xa7>
		return r;
	close(newfdnum);
  801eb9:	83 ec 0c             	sub    $0xc,%esp
  801ebc:	ff 75 0c             	pushl  0xc(%ebp)
  801ebf:	e8 75 ff ff ff       	call   801e39 <close>

	newfd = INDEX2FD(newfdnum);
  801ec4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ec7:	c1 e6 0c             	shl    $0xc,%esi
  801eca:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801ed0:	83 c4 04             	add    $0x4,%esp
  801ed3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ed6:	e8 af fd ff ff       	call   801c8a <fd2data>
  801edb:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801edd:	89 34 24             	mov    %esi,(%esp)
  801ee0:	e8 a5 fd ff ff       	call   801c8a <fd2data>
  801ee5:	83 c4 10             	add    $0x10,%esp
  801ee8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801eea:	89 d8                	mov    %ebx,%eax
  801eec:	c1 e8 16             	shr    $0x16,%eax
  801eef:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ef6:	a8 01                	test   $0x1,%al
  801ef8:	74 11                	je     801f0b <dup+0x78>
  801efa:	89 d8                	mov    %ebx,%eax
  801efc:	c1 e8 0c             	shr    $0xc,%eax
  801eff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801f06:	f6 c2 01             	test   $0x1,%dl
  801f09:	75 39                	jne    801f44 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801f0b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801f0e:	89 d0                	mov    %edx,%eax
  801f10:	c1 e8 0c             	shr    $0xc,%eax
  801f13:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801f1a:	83 ec 0c             	sub    $0xc,%esp
  801f1d:	25 07 0e 00 00       	and    $0xe07,%eax
  801f22:	50                   	push   %eax
  801f23:	56                   	push   %esi
  801f24:	6a 00                	push   $0x0
  801f26:	52                   	push   %edx
  801f27:	6a 00                	push   $0x0
  801f29:	e8 eb f7 ff ff       	call   801719 <sys_page_map>
  801f2e:	89 c3                	mov    %eax,%ebx
  801f30:	83 c4 20             	add    $0x20,%esp
  801f33:	85 c0                	test   %eax,%eax
  801f35:	78 31                	js     801f68 <dup+0xd5>
		goto err;

	return newfdnum;
  801f37:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801f3a:	89 d8                	mov    %ebx,%eax
  801f3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f3f:	5b                   	pop    %ebx
  801f40:	5e                   	pop    %esi
  801f41:	5f                   	pop    %edi
  801f42:	5d                   	pop    %ebp
  801f43:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801f44:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801f4b:	83 ec 0c             	sub    $0xc,%esp
  801f4e:	25 07 0e 00 00       	and    $0xe07,%eax
  801f53:	50                   	push   %eax
  801f54:	57                   	push   %edi
  801f55:	6a 00                	push   $0x0
  801f57:	53                   	push   %ebx
  801f58:	6a 00                	push   $0x0
  801f5a:	e8 ba f7 ff ff       	call   801719 <sys_page_map>
  801f5f:	89 c3                	mov    %eax,%ebx
  801f61:	83 c4 20             	add    $0x20,%esp
  801f64:	85 c0                	test   %eax,%eax
  801f66:	79 a3                	jns    801f0b <dup+0x78>
	sys_page_unmap(0, newfd);
  801f68:	83 ec 08             	sub    $0x8,%esp
  801f6b:	56                   	push   %esi
  801f6c:	6a 00                	push   $0x0
  801f6e:	e8 cb f7 ff ff       	call   80173e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801f73:	83 c4 08             	add    $0x8,%esp
  801f76:	57                   	push   %edi
  801f77:	6a 00                	push   $0x0
  801f79:	e8 c0 f7 ff ff       	call   80173e <sys_page_unmap>
	return r;
  801f7e:	83 c4 10             	add    $0x10,%esp
  801f81:	eb b7                	jmp    801f3a <dup+0xa7>

00801f83 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801f83:	f3 0f 1e fb          	endbr32 
  801f87:	55                   	push   %ebp
  801f88:	89 e5                	mov    %esp,%ebp
  801f8a:	53                   	push   %ebx
  801f8b:	83 ec 1c             	sub    $0x1c,%esp
  801f8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f91:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f94:	50                   	push   %eax
  801f95:	53                   	push   %ebx
  801f96:	e8 60 fd ff ff       	call   801cfb <fd_lookup>
  801f9b:	83 c4 10             	add    $0x10,%esp
  801f9e:	85 c0                	test   %eax,%eax
  801fa0:	78 3f                	js     801fe1 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fa2:	83 ec 08             	sub    $0x8,%esp
  801fa5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa8:	50                   	push   %eax
  801fa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fac:	ff 30                	pushl  (%eax)
  801fae:	e8 9c fd ff ff       	call   801d4f <dev_lookup>
  801fb3:	83 c4 10             	add    $0x10,%esp
  801fb6:	85 c0                	test   %eax,%eax
  801fb8:	78 27                	js     801fe1 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801fba:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fbd:	8b 42 08             	mov    0x8(%edx),%eax
  801fc0:	83 e0 03             	and    $0x3,%eax
  801fc3:	83 f8 01             	cmp    $0x1,%eax
  801fc6:	74 1e                	je     801fe6 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fcb:	8b 40 08             	mov    0x8(%eax),%eax
  801fce:	85 c0                	test   %eax,%eax
  801fd0:	74 35                	je     802007 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801fd2:	83 ec 04             	sub    $0x4,%esp
  801fd5:	ff 75 10             	pushl  0x10(%ebp)
  801fd8:	ff 75 0c             	pushl  0xc(%ebp)
  801fdb:	52                   	push   %edx
  801fdc:	ff d0                	call   *%eax
  801fde:	83 c4 10             	add    $0x10,%esp
}
  801fe1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fe4:	c9                   	leave  
  801fe5:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801fe6:	a1 28 64 80 00       	mov    0x806428,%eax
  801feb:	8b 40 48             	mov    0x48(%eax),%eax
  801fee:	83 ec 04             	sub    $0x4,%esp
  801ff1:	53                   	push   %ebx
  801ff2:	50                   	push   %eax
  801ff3:	68 6d 3f 80 00       	push   $0x803f6d
  801ff8:	e8 8f eb ff ff       	call   800b8c <cprintf>
		return -E_INVAL;
  801ffd:	83 c4 10             	add    $0x10,%esp
  802000:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802005:	eb da                	jmp    801fe1 <read+0x5e>
		return -E_NOT_SUPP;
  802007:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80200c:	eb d3                	jmp    801fe1 <read+0x5e>

0080200e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80200e:	f3 0f 1e fb          	endbr32 
  802012:	55                   	push   %ebp
  802013:	89 e5                	mov    %esp,%ebp
  802015:	57                   	push   %edi
  802016:	56                   	push   %esi
  802017:	53                   	push   %ebx
  802018:	83 ec 0c             	sub    $0xc,%esp
  80201b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80201e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802021:	bb 00 00 00 00       	mov    $0x0,%ebx
  802026:	eb 02                	jmp    80202a <readn+0x1c>
  802028:	01 c3                	add    %eax,%ebx
  80202a:	39 f3                	cmp    %esi,%ebx
  80202c:	73 21                	jae    80204f <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80202e:	83 ec 04             	sub    $0x4,%esp
  802031:	89 f0                	mov    %esi,%eax
  802033:	29 d8                	sub    %ebx,%eax
  802035:	50                   	push   %eax
  802036:	89 d8                	mov    %ebx,%eax
  802038:	03 45 0c             	add    0xc(%ebp),%eax
  80203b:	50                   	push   %eax
  80203c:	57                   	push   %edi
  80203d:	e8 41 ff ff ff       	call   801f83 <read>
		if (m < 0)
  802042:	83 c4 10             	add    $0x10,%esp
  802045:	85 c0                	test   %eax,%eax
  802047:	78 04                	js     80204d <readn+0x3f>
			return m;
		if (m == 0)
  802049:	75 dd                	jne    802028 <readn+0x1a>
  80204b:	eb 02                	jmp    80204f <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80204d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80204f:	89 d8                	mov    %ebx,%eax
  802051:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802054:	5b                   	pop    %ebx
  802055:	5e                   	pop    %esi
  802056:	5f                   	pop    %edi
  802057:	5d                   	pop    %ebp
  802058:	c3                   	ret    

00802059 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802059:	f3 0f 1e fb          	endbr32 
  80205d:	55                   	push   %ebp
  80205e:	89 e5                	mov    %esp,%ebp
  802060:	53                   	push   %ebx
  802061:	83 ec 1c             	sub    $0x1c,%esp
  802064:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802067:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80206a:	50                   	push   %eax
  80206b:	53                   	push   %ebx
  80206c:	e8 8a fc ff ff       	call   801cfb <fd_lookup>
  802071:	83 c4 10             	add    $0x10,%esp
  802074:	85 c0                	test   %eax,%eax
  802076:	78 3a                	js     8020b2 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802078:	83 ec 08             	sub    $0x8,%esp
  80207b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80207e:	50                   	push   %eax
  80207f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802082:	ff 30                	pushl  (%eax)
  802084:	e8 c6 fc ff ff       	call   801d4f <dev_lookup>
  802089:	83 c4 10             	add    $0x10,%esp
  80208c:	85 c0                	test   %eax,%eax
  80208e:	78 22                	js     8020b2 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802090:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802093:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802097:	74 1e                	je     8020b7 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802099:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80209c:	8b 52 0c             	mov    0xc(%edx),%edx
  80209f:	85 d2                	test   %edx,%edx
  8020a1:	74 35                	je     8020d8 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8020a3:	83 ec 04             	sub    $0x4,%esp
  8020a6:	ff 75 10             	pushl  0x10(%ebp)
  8020a9:	ff 75 0c             	pushl  0xc(%ebp)
  8020ac:	50                   	push   %eax
  8020ad:	ff d2                	call   *%edx
  8020af:	83 c4 10             	add    $0x10,%esp
}
  8020b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020b5:	c9                   	leave  
  8020b6:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8020b7:	a1 28 64 80 00       	mov    0x806428,%eax
  8020bc:	8b 40 48             	mov    0x48(%eax),%eax
  8020bf:	83 ec 04             	sub    $0x4,%esp
  8020c2:	53                   	push   %ebx
  8020c3:	50                   	push   %eax
  8020c4:	68 89 3f 80 00       	push   $0x803f89
  8020c9:	e8 be ea ff ff       	call   800b8c <cprintf>
		return -E_INVAL;
  8020ce:	83 c4 10             	add    $0x10,%esp
  8020d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8020d6:	eb da                	jmp    8020b2 <write+0x59>
		return -E_NOT_SUPP;
  8020d8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8020dd:	eb d3                	jmp    8020b2 <write+0x59>

008020df <seek>:

int
seek(int fdnum, off_t offset)
{
  8020df:	f3 0f 1e fb          	endbr32 
  8020e3:	55                   	push   %ebp
  8020e4:	89 e5                	mov    %esp,%ebp
  8020e6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ec:	50                   	push   %eax
  8020ed:	ff 75 08             	pushl  0x8(%ebp)
  8020f0:	e8 06 fc ff ff       	call   801cfb <fd_lookup>
  8020f5:	83 c4 10             	add    $0x10,%esp
  8020f8:	85 c0                	test   %eax,%eax
  8020fa:	78 0e                	js     80210a <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8020fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802102:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802105:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80210a:	c9                   	leave  
  80210b:	c3                   	ret    

0080210c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80210c:	f3 0f 1e fb          	endbr32 
  802110:	55                   	push   %ebp
  802111:	89 e5                	mov    %esp,%ebp
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
  802117:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80211a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80211d:	50                   	push   %eax
  80211e:	53                   	push   %ebx
  80211f:	e8 d7 fb ff ff       	call   801cfb <fd_lookup>
  802124:	83 c4 10             	add    $0x10,%esp
  802127:	85 c0                	test   %eax,%eax
  802129:	78 37                	js     802162 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80212b:	83 ec 08             	sub    $0x8,%esp
  80212e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802131:	50                   	push   %eax
  802132:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802135:	ff 30                	pushl  (%eax)
  802137:	e8 13 fc ff ff       	call   801d4f <dev_lookup>
  80213c:	83 c4 10             	add    $0x10,%esp
  80213f:	85 c0                	test   %eax,%eax
  802141:	78 1f                	js     802162 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802143:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802146:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80214a:	74 1b                	je     802167 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80214c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80214f:	8b 52 18             	mov    0x18(%edx),%edx
  802152:	85 d2                	test   %edx,%edx
  802154:	74 32                	je     802188 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802156:	83 ec 08             	sub    $0x8,%esp
  802159:	ff 75 0c             	pushl  0xc(%ebp)
  80215c:	50                   	push   %eax
  80215d:	ff d2                	call   *%edx
  80215f:	83 c4 10             	add    $0x10,%esp
}
  802162:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802165:	c9                   	leave  
  802166:	c3                   	ret    
			thisenv->env_id, fdnum);
  802167:	a1 28 64 80 00       	mov    0x806428,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80216c:	8b 40 48             	mov    0x48(%eax),%eax
  80216f:	83 ec 04             	sub    $0x4,%esp
  802172:	53                   	push   %ebx
  802173:	50                   	push   %eax
  802174:	68 4c 3f 80 00       	push   $0x803f4c
  802179:	e8 0e ea ff ff       	call   800b8c <cprintf>
		return -E_INVAL;
  80217e:	83 c4 10             	add    $0x10,%esp
  802181:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802186:	eb da                	jmp    802162 <ftruncate+0x56>
		return -E_NOT_SUPP;
  802188:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80218d:	eb d3                	jmp    802162 <ftruncate+0x56>

0080218f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80218f:	f3 0f 1e fb          	endbr32 
  802193:	55                   	push   %ebp
  802194:	89 e5                	mov    %esp,%ebp
  802196:	53                   	push   %ebx
  802197:	83 ec 1c             	sub    $0x1c,%esp
  80219a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80219d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021a0:	50                   	push   %eax
  8021a1:	ff 75 08             	pushl  0x8(%ebp)
  8021a4:	e8 52 fb ff ff       	call   801cfb <fd_lookup>
  8021a9:	83 c4 10             	add    $0x10,%esp
  8021ac:	85 c0                	test   %eax,%eax
  8021ae:	78 4b                	js     8021fb <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8021b0:	83 ec 08             	sub    $0x8,%esp
  8021b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021b6:	50                   	push   %eax
  8021b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021ba:	ff 30                	pushl  (%eax)
  8021bc:	e8 8e fb ff ff       	call   801d4f <dev_lookup>
  8021c1:	83 c4 10             	add    $0x10,%esp
  8021c4:	85 c0                	test   %eax,%eax
  8021c6:	78 33                	js     8021fb <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8021c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021cb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8021cf:	74 2f                	je     802200 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8021d1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8021d4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8021db:	00 00 00 
	stat->st_isdir = 0;
  8021de:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8021e5:	00 00 00 
	stat->st_dev = dev;
  8021e8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8021ee:	83 ec 08             	sub    $0x8,%esp
  8021f1:	53                   	push   %ebx
  8021f2:	ff 75 f0             	pushl  -0x10(%ebp)
  8021f5:	ff 50 14             	call   *0x14(%eax)
  8021f8:	83 c4 10             	add    $0x10,%esp
}
  8021fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021fe:	c9                   	leave  
  8021ff:	c3                   	ret    
		return -E_NOT_SUPP;
  802200:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802205:	eb f4                	jmp    8021fb <fstat+0x6c>

00802207 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802207:	f3 0f 1e fb          	endbr32 
  80220b:	55                   	push   %ebp
  80220c:	89 e5                	mov    %esp,%ebp
  80220e:	56                   	push   %esi
  80220f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802210:	83 ec 08             	sub    $0x8,%esp
  802213:	6a 00                	push   $0x0
  802215:	ff 75 08             	pushl  0x8(%ebp)
  802218:	e8 01 02 00 00       	call   80241e <open>
  80221d:	89 c3                	mov    %eax,%ebx
  80221f:	83 c4 10             	add    $0x10,%esp
  802222:	85 c0                	test   %eax,%eax
  802224:	78 1b                	js     802241 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  802226:	83 ec 08             	sub    $0x8,%esp
  802229:	ff 75 0c             	pushl  0xc(%ebp)
  80222c:	50                   	push   %eax
  80222d:	e8 5d ff ff ff       	call   80218f <fstat>
  802232:	89 c6                	mov    %eax,%esi
	close(fd);
  802234:	89 1c 24             	mov    %ebx,(%esp)
  802237:	e8 fd fb ff ff       	call   801e39 <close>
	return r;
  80223c:	83 c4 10             	add    $0x10,%esp
  80223f:	89 f3                	mov    %esi,%ebx
}
  802241:	89 d8                	mov    %ebx,%eax
  802243:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802246:	5b                   	pop    %ebx
  802247:	5e                   	pop    %esi
  802248:	5d                   	pop    %ebp
  802249:	c3                   	ret    

0080224a <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  80224a:	55                   	push   %ebp
  80224b:	89 e5                	mov    %esp,%ebp
  80224d:	56                   	push   %esi
  80224e:	53                   	push   %ebx
  80224f:	89 c6                	mov    %eax,%esi
  802251:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802253:	83 3d 20 64 80 00 00 	cmpl   $0x0,0x806420
  80225a:	74 27                	je     802283 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80225c:	6a 07                	push   $0x7
  80225e:	68 00 70 80 00       	push   $0x807000
  802263:	56                   	push   %esi
  802264:	ff 35 20 64 80 00    	pushl  0x806420
  80226a:	e8 20 13 00 00       	call   80358f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80226f:	83 c4 0c             	add    $0xc,%esp
  802272:	6a 00                	push   $0x0
  802274:	53                   	push   %ebx
  802275:	6a 00                	push   $0x0
  802277:	e8 a6 12 00 00       	call   803522 <ipc_recv>
}
  80227c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80227f:	5b                   	pop    %ebx
  802280:	5e                   	pop    %esi
  802281:	5d                   	pop    %ebp
  802282:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802283:	83 ec 0c             	sub    $0xc,%esp
  802286:	6a 01                	push   $0x1
  802288:	e8 5a 13 00 00       	call   8035e7 <ipc_find_env>
  80228d:	a3 20 64 80 00       	mov    %eax,0x806420
  802292:	83 c4 10             	add    $0x10,%esp
  802295:	eb c5                	jmp    80225c <fsipc+0x12>

00802297 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802297:	f3 0f 1e fb          	endbr32 
  80229b:	55                   	push   %ebp
  80229c:	89 e5                	mov    %esp,%ebp
  80229e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8022a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8022a7:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8022ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022af:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8022b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8022b9:	b8 02 00 00 00       	mov    $0x2,%eax
  8022be:	e8 87 ff ff ff       	call   80224a <fsipc>
}
  8022c3:	c9                   	leave  
  8022c4:	c3                   	ret    

008022c5 <devfile_flush>:
{
  8022c5:	f3 0f 1e fb          	endbr32 
  8022c9:	55                   	push   %ebp
  8022ca:	89 e5                	mov    %esp,%ebp
  8022cc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8022cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8022d5:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8022da:	ba 00 00 00 00       	mov    $0x0,%edx
  8022df:	b8 06 00 00 00       	mov    $0x6,%eax
  8022e4:	e8 61 ff ff ff       	call   80224a <fsipc>
}
  8022e9:	c9                   	leave  
  8022ea:	c3                   	ret    

008022eb <devfile_stat>:
{
  8022eb:	f3 0f 1e fb          	endbr32 
  8022ef:	55                   	push   %ebp
  8022f0:	89 e5                	mov    %esp,%ebp
  8022f2:	53                   	push   %ebx
  8022f3:	83 ec 04             	sub    $0x4,%esp
  8022f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8022f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8022fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8022ff:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802304:	ba 00 00 00 00       	mov    $0x0,%edx
  802309:	b8 05 00 00 00       	mov    $0x5,%eax
  80230e:	e8 37 ff ff ff       	call   80224a <fsipc>
  802313:	85 c0                	test   %eax,%eax
  802315:	78 2c                	js     802343 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802317:	83 ec 08             	sub    $0x8,%esp
  80231a:	68 00 70 80 00       	push   $0x807000
  80231f:	53                   	push   %ebx
  802320:	e8 65 ef ff ff       	call   80128a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802325:	a1 80 70 80 00       	mov    0x807080,%eax
  80232a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802330:	a1 84 70 80 00       	mov    0x807084,%eax
  802335:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80233b:	83 c4 10             	add    $0x10,%esp
  80233e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802343:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802346:	c9                   	leave  
  802347:	c3                   	ret    

00802348 <devfile_write>:
{
  802348:	f3 0f 1e fb          	endbr32 
  80234c:	55                   	push   %ebp
  80234d:	89 e5                	mov    %esp,%ebp
  80234f:	83 ec 0c             	sub    $0xc,%esp
  802352:	8b 45 10             	mov    0x10(%ebp),%eax
  802355:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80235a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80235f:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802362:	8b 55 08             	mov    0x8(%ebp),%edx
  802365:	8b 52 0c             	mov    0xc(%edx),%edx
  802368:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  80236e:	a3 04 70 80 00       	mov    %eax,0x807004
	memmove(fsipcbuf.write.req_buf, buf, n);
  802373:	50                   	push   %eax
  802374:	ff 75 0c             	pushl  0xc(%ebp)
  802377:	68 08 70 80 00       	push   $0x807008
  80237c:	e8 07 f1 ff ff       	call   801488 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  802381:	ba 00 00 00 00       	mov    $0x0,%edx
  802386:	b8 04 00 00 00       	mov    $0x4,%eax
  80238b:	e8 ba fe ff ff       	call   80224a <fsipc>
}
  802390:	c9                   	leave  
  802391:	c3                   	ret    

00802392 <devfile_read>:
{
  802392:	f3 0f 1e fb          	endbr32 
  802396:	55                   	push   %ebp
  802397:	89 e5                	mov    %esp,%ebp
  802399:	56                   	push   %esi
  80239a:	53                   	push   %ebx
  80239b:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80239e:	8b 45 08             	mov    0x8(%ebp),%eax
  8023a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8023a4:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8023a9:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8023af:	ba 00 00 00 00       	mov    $0x0,%edx
  8023b4:	b8 03 00 00 00       	mov    $0x3,%eax
  8023b9:	e8 8c fe ff ff       	call   80224a <fsipc>
  8023be:	89 c3                	mov    %eax,%ebx
  8023c0:	85 c0                	test   %eax,%eax
  8023c2:	78 1f                	js     8023e3 <devfile_read+0x51>
	assert(r <= n);
  8023c4:	39 f0                	cmp    %esi,%eax
  8023c6:	77 24                	ja     8023ec <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8023c8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8023cd:	7f 36                	jg     802405 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8023cf:	83 ec 04             	sub    $0x4,%esp
  8023d2:	50                   	push   %eax
  8023d3:	68 00 70 80 00       	push   $0x807000
  8023d8:	ff 75 0c             	pushl  0xc(%ebp)
  8023db:	e8 a8 f0 ff ff       	call   801488 <memmove>
	return r;
  8023e0:	83 c4 10             	add    $0x10,%esp
}
  8023e3:	89 d8                	mov    %ebx,%eax
  8023e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023e8:	5b                   	pop    %ebx
  8023e9:	5e                   	pop    %esi
  8023ea:	5d                   	pop    %ebp
  8023eb:	c3                   	ret    
	assert(r <= n);
  8023ec:	68 bc 3f 80 00       	push   $0x803fbc
  8023f1:	68 32 3a 80 00       	push   $0x803a32
  8023f6:	68 8c 00 00 00       	push   $0x8c
  8023fb:	68 c3 3f 80 00       	push   $0x803fc3
  802400:	e8 a0 e6 ff ff       	call   800aa5 <_panic>
	assert(r <= PGSIZE);
  802405:	68 ce 3f 80 00       	push   $0x803fce
  80240a:	68 32 3a 80 00       	push   $0x803a32
  80240f:	68 8d 00 00 00       	push   $0x8d
  802414:	68 c3 3f 80 00       	push   $0x803fc3
  802419:	e8 87 e6 ff ff       	call   800aa5 <_panic>

0080241e <open>:
{
  80241e:	f3 0f 1e fb          	endbr32 
  802422:	55                   	push   %ebp
  802423:	89 e5                	mov    %esp,%ebp
  802425:	56                   	push   %esi
  802426:	53                   	push   %ebx
  802427:	83 ec 1c             	sub    $0x1c,%esp
  80242a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80242d:	56                   	push   %esi
  80242e:	e8 14 ee ff ff       	call   801247 <strlen>
  802433:	83 c4 10             	add    $0x10,%esp
  802436:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80243b:	7f 6c                	jg     8024a9 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80243d:	83 ec 0c             	sub    $0xc,%esp
  802440:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802443:	50                   	push   %eax
  802444:	e8 5c f8 ff ff       	call   801ca5 <fd_alloc>
  802449:	89 c3                	mov    %eax,%ebx
  80244b:	83 c4 10             	add    $0x10,%esp
  80244e:	85 c0                	test   %eax,%eax
  802450:	78 3c                	js     80248e <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  802452:	83 ec 08             	sub    $0x8,%esp
  802455:	56                   	push   %esi
  802456:	68 00 70 80 00       	push   $0x807000
  80245b:	e8 2a ee ff ff       	call   80128a <strcpy>
	fsipcbuf.open.req_omode = mode;
  802460:	8b 45 0c             	mov    0xc(%ebp),%eax
  802463:	a3 00 74 80 00       	mov    %eax,0x807400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802468:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80246b:	b8 01 00 00 00       	mov    $0x1,%eax
  802470:	e8 d5 fd ff ff       	call   80224a <fsipc>
  802475:	89 c3                	mov    %eax,%ebx
  802477:	83 c4 10             	add    $0x10,%esp
  80247a:	85 c0                	test   %eax,%eax
  80247c:	78 19                	js     802497 <open+0x79>
	return fd2num(fd);
  80247e:	83 ec 0c             	sub    $0xc,%esp
  802481:	ff 75 f4             	pushl  -0xc(%ebp)
  802484:	e8 ed f7 ff ff       	call   801c76 <fd2num>
  802489:	89 c3                	mov    %eax,%ebx
  80248b:	83 c4 10             	add    $0x10,%esp
}
  80248e:	89 d8                	mov    %ebx,%eax
  802490:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802493:	5b                   	pop    %ebx
  802494:	5e                   	pop    %esi
  802495:	5d                   	pop    %ebp
  802496:	c3                   	ret    
		fd_close(fd, 0);
  802497:	83 ec 08             	sub    $0x8,%esp
  80249a:	6a 00                	push   $0x0
  80249c:	ff 75 f4             	pushl  -0xc(%ebp)
  80249f:	e8 0a f9 ff ff       	call   801dae <fd_close>
		return r;
  8024a4:	83 c4 10             	add    $0x10,%esp
  8024a7:	eb e5                	jmp    80248e <open+0x70>
		return -E_BAD_PATH;
  8024a9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8024ae:	eb de                	jmp    80248e <open+0x70>

008024b0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8024b0:	f3 0f 1e fb          	endbr32 
  8024b4:	55                   	push   %ebp
  8024b5:	89 e5                	mov    %esp,%ebp
  8024b7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8024ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8024bf:	b8 08 00 00 00       	mov    $0x8,%eax
  8024c4:	e8 81 fd ff ff       	call   80224a <fsipc>
}
  8024c9:	c9                   	leave  
  8024ca:	c3                   	ret    

008024cb <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8024cb:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8024cf:	7f 01                	jg     8024d2 <writebuf+0x7>
  8024d1:	c3                   	ret    
{
  8024d2:	55                   	push   %ebp
  8024d3:	89 e5                	mov    %esp,%ebp
  8024d5:	53                   	push   %ebx
  8024d6:	83 ec 08             	sub    $0x8,%esp
  8024d9:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  8024db:	ff 70 04             	pushl  0x4(%eax)
  8024de:	8d 40 10             	lea    0x10(%eax),%eax
  8024e1:	50                   	push   %eax
  8024e2:	ff 33                	pushl  (%ebx)
  8024e4:	e8 70 fb ff ff       	call   802059 <write>
		if (result > 0)
  8024e9:	83 c4 10             	add    $0x10,%esp
  8024ec:	85 c0                	test   %eax,%eax
  8024ee:	7e 03                	jle    8024f3 <writebuf+0x28>
			b->result += result;
  8024f0:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8024f3:	39 43 04             	cmp    %eax,0x4(%ebx)
  8024f6:	74 0d                	je     802505 <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  8024f8:	85 c0                	test   %eax,%eax
  8024fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8024ff:	0f 4f c2             	cmovg  %edx,%eax
  802502:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  802505:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802508:	c9                   	leave  
  802509:	c3                   	ret    

0080250a <putch>:

static void
putch(int ch, void *thunk)
{
  80250a:	f3 0f 1e fb          	endbr32 
  80250e:	55                   	push   %ebp
  80250f:	89 e5                	mov    %esp,%ebp
  802511:	53                   	push   %ebx
  802512:	83 ec 04             	sub    $0x4,%esp
  802515:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  802518:	8b 53 04             	mov    0x4(%ebx),%edx
  80251b:	8d 42 01             	lea    0x1(%edx),%eax
  80251e:	89 43 04             	mov    %eax,0x4(%ebx)
  802521:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802524:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  802528:	3d 00 01 00 00       	cmp    $0x100,%eax
  80252d:	74 06                	je     802535 <putch+0x2b>
		writebuf(b);
		b->idx = 0;
	}
}
  80252f:	83 c4 04             	add    $0x4,%esp
  802532:	5b                   	pop    %ebx
  802533:	5d                   	pop    %ebp
  802534:	c3                   	ret    
		writebuf(b);
  802535:	89 d8                	mov    %ebx,%eax
  802537:	e8 8f ff ff ff       	call   8024cb <writebuf>
		b->idx = 0;
  80253c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  802543:	eb ea                	jmp    80252f <putch+0x25>

00802545 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  802545:	f3 0f 1e fb          	endbr32 
  802549:	55                   	push   %ebp
  80254a:	89 e5                	mov    %esp,%ebp
  80254c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  802552:	8b 45 08             	mov    0x8(%ebp),%eax
  802555:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80255b:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802562:	00 00 00 
	b.result = 0;
  802565:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80256c:	00 00 00 
	b.error = 1;
  80256f:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  802576:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  802579:	ff 75 10             	pushl  0x10(%ebp)
  80257c:	ff 75 0c             	pushl  0xc(%ebp)
  80257f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802585:	50                   	push   %eax
  802586:	68 0a 25 80 00       	push   $0x80250a
  80258b:	e8 ff e6 ff ff       	call   800c8f <vprintfmt>
	if (b.idx > 0)
  802590:	83 c4 10             	add    $0x10,%esp
  802593:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80259a:	7f 11                	jg     8025ad <vfprintf+0x68>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  80259c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8025a2:	85 c0                	test   %eax,%eax
  8025a4:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8025ab:	c9                   	leave  
  8025ac:	c3                   	ret    
		writebuf(&b);
  8025ad:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8025b3:	e8 13 ff ff ff       	call   8024cb <writebuf>
  8025b8:	eb e2                	jmp    80259c <vfprintf+0x57>

008025ba <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8025ba:	f3 0f 1e fb          	endbr32 
  8025be:	55                   	push   %ebp
  8025bf:	89 e5                	mov    %esp,%ebp
  8025c1:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8025c4:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8025c7:	50                   	push   %eax
  8025c8:	ff 75 0c             	pushl  0xc(%ebp)
  8025cb:	ff 75 08             	pushl  0x8(%ebp)
  8025ce:	e8 72 ff ff ff       	call   802545 <vfprintf>
	va_end(ap);

	return cnt;
}
  8025d3:	c9                   	leave  
  8025d4:	c3                   	ret    

008025d5 <printf>:

int
printf(const char *fmt, ...)
{
  8025d5:	f3 0f 1e fb          	endbr32 
  8025d9:	55                   	push   %ebp
  8025da:	89 e5                	mov    %esp,%ebp
  8025dc:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8025df:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8025e2:	50                   	push   %eax
  8025e3:	ff 75 08             	pushl  0x8(%ebp)
  8025e6:	6a 01                	push   $0x1
  8025e8:	e8 58 ff ff ff       	call   802545 <vfprintf>
	va_end(ap);

	return cnt;
}
  8025ed:	c9                   	leave  
  8025ee:	c3                   	ret    

008025ef <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8025ef:	f3 0f 1e fb          	endbr32 
  8025f3:	55                   	push   %ebp
  8025f4:	89 e5                	mov    %esp,%ebp
  8025f6:	57                   	push   %edi
  8025f7:	56                   	push   %esi
  8025f8:	53                   	push   %ebx
  8025f9:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8025ff:	6a 00                	push   $0x0
  802601:	ff 75 08             	pushl  0x8(%ebp)
  802604:	e8 15 fe ff ff       	call   80241e <open>
  802609:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80260f:	83 c4 10             	add    $0x10,%esp
  802612:	85 c0                	test   %eax,%eax
  802614:	0f 88 b2 04 00 00    	js     802acc <spawn+0x4dd>
  80261a:	89 c1                	mov    %eax,%ecx
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80261c:	83 ec 04             	sub    $0x4,%esp
  80261f:	68 00 02 00 00       	push   $0x200
  802624:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80262a:	50                   	push   %eax
  80262b:	51                   	push   %ecx
  80262c:	e8 dd f9 ff ff       	call   80200e <readn>
  802631:	83 c4 10             	add    $0x10,%esp
  802634:	3d 00 02 00 00       	cmp    $0x200,%eax
  802639:	75 7e                	jne    8026b9 <spawn+0xca>
	    || elf->e_magic != ELF_MAGIC) {
  80263b:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802642:	45 4c 46 
  802645:	75 72                	jne    8026b9 <spawn+0xca>
  802647:	b8 07 00 00 00       	mov    $0x7,%eax
  80264c:	cd 30                	int    $0x30
  80264e:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  802654:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80265a:	85 c0                	test   %eax,%eax
  80265c:	0f 88 5e 04 00 00    	js     802ac0 <spawn+0x4d1>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802662:	25 ff 03 00 00       	and    $0x3ff,%eax
  802667:	6b f0 7c             	imul   $0x7c,%eax,%esi
  80266a:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  802670:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802676:	b9 11 00 00 00       	mov    $0x11,%ecx
  80267b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80267d:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802683:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802689:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  80268e:	be 00 00 00 00       	mov    $0x0,%esi
  802693:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802696:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
	for (argc = 0; argv[argc] != 0; argc++)
  80269d:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8026a0:	85 c0                	test   %eax,%eax
  8026a2:	74 4d                	je     8026f1 <spawn+0x102>
		string_size += strlen(argv[argc]) + 1;
  8026a4:	83 ec 0c             	sub    $0xc,%esp
  8026a7:	50                   	push   %eax
  8026a8:	e8 9a eb ff ff       	call   801247 <strlen>
  8026ad:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8026b1:	83 c3 01             	add    $0x1,%ebx
  8026b4:	83 c4 10             	add    $0x10,%esp
  8026b7:	eb dd                	jmp    802696 <spawn+0xa7>
		close(fd);
  8026b9:	83 ec 0c             	sub    $0xc,%esp
  8026bc:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  8026c2:	e8 72 f7 ff ff       	call   801e39 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8026c7:	83 c4 0c             	add    $0xc,%esp
  8026ca:	68 7f 45 4c 46       	push   $0x464c457f
  8026cf:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8026d5:	68 3a 40 80 00       	push   $0x80403a
  8026da:	e8 ad e4 ff ff       	call   800b8c <cprintf>
		return -E_NOT_EXEC;
  8026df:	83 c4 10             	add    $0x10,%esp
  8026e2:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  8026e9:	ff ff ff 
  8026ec:	e9 db 03 00 00       	jmp    802acc <spawn+0x4dd>
  8026f1:	89 85 70 fd ff ff    	mov    %eax,-0x290(%ebp)
  8026f7:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  8026fd:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802703:	bf 00 10 40 00       	mov    $0x401000,%edi
  802708:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80270a:	89 fa                	mov    %edi,%edx
  80270c:	83 e2 fc             	and    $0xfffffffc,%edx
  80270f:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  802716:	29 c2                	sub    %eax,%edx
  802718:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80271e:	8d 42 f8             	lea    -0x8(%edx),%eax
  802721:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802726:	0f 86 12 04 00 00    	jbe    802b3e <spawn+0x54f>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80272c:	83 ec 04             	sub    $0x4,%esp
  80272f:	6a 07                	push   $0x7
  802731:	68 00 00 40 00       	push   $0x400000
  802736:	6a 00                	push   $0x0
  802738:	e8 b6 ef ff ff       	call   8016f3 <sys_page_alloc>
  80273d:	83 c4 10             	add    $0x10,%esp
  802740:	85 c0                	test   %eax,%eax
  802742:	0f 88 fb 03 00 00    	js     802b43 <spawn+0x554>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802748:	be 00 00 00 00       	mov    $0x0,%esi
  80274d:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  802753:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802756:	eb 30                	jmp    802788 <spawn+0x199>
		argv_store[i] = UTEMP2USTACK(string_store);
  802758:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80275e:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  802764:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  802767:	83 ec 08             	sub    $0x8,%esp
  80276a:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80276d:	57                   	push   %edi
  80276e:	e8 17 eb ff ff       	call   80128a <strcpy>
		string_store += strlen(argv[i]) + 1;
  802773:	83 c4 04             	add    $0x4,%esp
  802776:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802779:	e8 c9 ea ff ff       	call   801247 <strlen>
  80277e:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  802782:	83 c6 01             	add    $0x1,%esi
  802785:	83 c4 10             	add    $0x10,%esp
  802788:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  80278e:	7f c8                	jg     802758 <spawn+0x169>
	}
	argv_store[argc] = 0;
  802790:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802796:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  80279c:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8027a3:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8027a9:	0f 85 88 00 00 00    	jne    802837 <spawn+0x248>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8027af:	8b 8d 90 fd ff ff    	mov    -0x270(%ebp),%ecx
  8027b5:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  8027bb:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  8027be:	89 c8                	mov    %ecx,%eax
  8027c0:	8b 95 84 fd ff ff    	mov    -0x27c(%ebp),%edx
  8027c6:	89 51 f8             	mov    %edx,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8027c9:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8027ce:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8027d4:	83 ec 0c             	sub    $0xc,%esp
  8027d7:	6a 07                	push   $0x7
  8027d9:	68 00 d0 bf ee       	push   $0xeebfd000
  8027de:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8027e4:	68 00 00 40 00       	push   $0x400000
  8027e9:	6a 00                	push   $0x0
  8027eb:	e8 29 ef ff ff       	call   801719 <sys_page_map>
  8027f0:	89 c3                	mov    %eax,%ebx
  8027f2:	83 c4 20             	add    $0x20,%esp
  8027f5:	85 c0                	test   %eax,%eax
  8027f7:	0f 88 4e 03 00 00    	js     802b4b <spawn+0x55c>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8027fd:	83 ec 08             	sub    $0x8,%esp
  802800:	68 00 00 40 00       	push   $0x400000
  802805:	6a 00                	push   $0x0
  802807:	e8 32 ef ff ff       	call   80173e <sys_page_unmap>
  80280c:	89 c3                	mov    %eax,%ebx
  80280e:	83 c4 10             	add    $0x10,%esp
  802811:	85 c0                	test   %eax,%eax
  802813:	0f 88 32 03 00 00    	js     802b4b <spawn+0x55c>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802819:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  80281f:	8d b4 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%esi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802826:	c7 85 84 fd ff ff 00 	movl   $0x0,-0x27c(%ebp)
  80282d:	00 00 00 
  802830:	89 f7                	mov    %esi,%edi
  802832:	e9 4f 01 00 00       	jmp    802986 <spawn+0x397>
	assert(string_store == (char*)UTEMP + PGSIZE);
  802837:	68 c4 40 80 00       	push   $0x8040c4
  80283c:	68 32 3a 80 00       	push   $0x803a32
  802841:	68 f1 00 00 00       	push   $0xf1
  802846:	68 54 40 80 00       	push   $0x804054
  80284b:	e8 55 e2 ff ff       	call   800aa5 <_panic>
			// allocate a blank page bss segment
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802850:	83 ec 04             	sub    $0x4,%esp
  802853:	6a 07                	push   $0x7
  802855:	68 00 00 40 00       	push   $0x400000
  80285a:	6a 00                	push   $0x0
  80285c:	e8 92 ee ff ff       	call   8016f3 <sys_page_alloc>
  802861:	83 c4 10             	add    $0x10,%esp
  802864:	85 c0                	test   %eax,%eax
  802866:	0f 88 6e 02 00 00    	js     802ada <spawn+0x4eb>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80286c:	83 ec 08             	sub    $0x8,%esp
  80286f:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802875:	01 f8                	add    %edi,%eax
  802877:	50                   	push   %eax
  802878:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  80287e:	e8 5c f8 ff ff       	call   8020df <seek>
  802883:	83 c4 10             	add    $0x10,%esp
  802886:	85 c0                	test   %eax,%eax
  802888:	0f 88 53 02 00 00    	js     802ae1 <spawn+0x4f2>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80288e:	83 ec 04             	sub    $0x4,%esp
  802891:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802897:	29 f8                	sub    %edi,%eax
  802899:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80289e:	b9 00 10 00 00       	mov    $0x1000,%ecx
  8028a3:	0f 47 c1             	cmova  %ecx,%eax
  8028a6:	50                   	push   %eax
  8028a7:	68 00 00 40 00       	push   $0x400000
  8028ac:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  8028b2:	e8 57 f7 ff ff       	call   80200e <readn>
  8028b7:	83 c4 10             	add    $0x10,%esp
  8028ba:	85 c0                	test   %eax,%eax
  8028bc:	0f 88 26 02 00 00    	js     802ae8 <spawn+0x4f9>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8028c2:	83 ec 0c             	sub    $0xc,%esp
  8028c5:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8028cb:	53                   	push   %ebx
  8028cc:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8028d2:	68 00 00 40 00       	push   $0x400000
  8028d7:	6a 00                	push   $0x0
  8028d9:	e8 3b ee ff ff       	call   801719 <sys_page_map>
  8028de:	83 c4 20             	add    $0x20,%esp
  8028e1:	85 c0                	test   %eax,%eax
  8028e3:	78 7c                	js     802961 <spawn+0x372>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  8028e5:	83 ec 08             	sub    $0x8,%esp
  8028e8:	68 00 00 40 00       	push   $0x400000
  8028ed:	6a 00                	push   $0x0
  8028ef:	e8 4a ee ff ff       	call   80173e <sys_page_unmap>
  8028f4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  8028f7:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8028fd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802903:	89 f7                	mov    %esi,%edi
  802905:	39 b5 7c fd ff ff    	cmp    %esi,-0x284(%ebp)
  80290b:	76 69                	jbe    802976 <spawn+0x387>
		if (i >= filesz) {
  80290d:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  802913:	0f 87 37 ff ff ff    	ja     802850 <spawn+0x261>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802919:	83 ec 04             	sub    $0x4,%esp
  80291c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802922:	53                   	push   %ebx
  802923:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802929:	e8 c5 ed ff ff       	call   8016f3 <sys_page_alloc>
  80292e:	83 c4 10             	add    $0x10,%esp
  802931:	85 c0                	test   %eax,%eax
  802933:	79 c2                	jns    8028f7 <spawn+0x308>
  802935:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  802937:	83 ec 0c             	sub    $0xc,%esp
  80293a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802940:	e8 44 ed ff ff       	call   801689 <sys_env_destroy>
	close(fd);
  802945:	83 c4 04             	add    $0x4,%esp
  802948:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  80294e:	e8 e6 f4 ff ff       	call   801e39 <close>
	return r;
  802953:	83 c4 10             	add    $0x10,%esp
  802956:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
  80295c:	e9 6b 01 00 00       	jmp    802acc <spawn+0x4dd>
				panic("spawn: sys_page_map data: %e", r);
  802961:	50                   	push   %eax
  802962:	68 60 40 80 00       	push   $0x804060
  802967:	68 24 01 00 00       	push   $0x124
  80296c:	68 54 40 80 00       	push   $0x804054
  802971:	e8 2f e1 ff ff       	call   800aa5 <_panic>
  802976:	8b bd 78 fd ff ff    	mov    -0x288(%ebp),%edi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80297c:	83 85 84 fd ff ff 01 	addl   $0x1,-0x27c(%ebp)
  802983:	83 c7 20             	add    $0x20,%edi
  802986:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80298d:	3b 85 84 fd ff ff    	cmp    -0x27c(%ebp),%eax
  802993:	7e 6d                	jle    802a02 <spawn+0x413>
		if (ph->p_type != ELF_PROG_LOAD)
  802995:	83 3f 01             	cmpl   $0x1,(%edi)
  802998:	75 e2                	jne    80297c <spawn+0x38d>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80299a:	8b 47 18             	mov    0x18(%edi),%eax
  80299d:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8029a0:	83 f8 01             	cmp    $0x1,%eax
  8029a3:	19 c0                	sbb    %eax,%eax
  8029a5:	83 e0 fe             	and    $0xfffffffe,%eax
  8029a8:	83 c0 07             	add    $0x7,%eax
  8029ab:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8029b1:	8b 57 04             	mov    0x4(%edi),%edx
  8029b4:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  8029ba:	8b 4f 10             	mov    0x10(%edi),%ecx
  8029bd:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  8029c3:	8b 77 14             	mov    0x14(%edi),%esi
  8029c6:	89 b5 7c fd ff ff    	mov    %esi,-0x284(%ebp)
  8029cc:	8b 5f 08             	mov    0x8(%edi),%ebx
	if ((i = PGOFF(va))) {
  8029cf:	89 d8                	mov    %ebx,%eax
  8029d1:	25 ff 0f 00 00       	and    $0xfff,%eax
  8029d6:	74 1a                	je     8029f2 <spawn+0x403>
		va -= i;
  8029d8:	29 c3                	sub    %eax,%ebx
		memsz += i;
  8029da:	01 c6                	add    %eax,%esi
  8029dc:	89 b5 7c fd ff ff    	mov    %esi,-0x284(%ebp)
		filesz += i;
  8029e2:	01 c1                	add    %eax,%ecx
  8029e4:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
		fileoffset -= i;
  8029ea:	29 c2                	sub    %eax,%edx
  8029ec:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  8029f2:	be 00 00 00 00       	mov    $0x0,%esi
  8029f7:	89 bd 78 fd ff ff    	mov    %edi,-0x288(%ebp)
  8029fd:	e9 01 ff ff ff       	jmp    802903 <spawn+0x314>
	close(fd);
  802a02:	83 ec 0c             	sub    $0xc,%esp
  802a05:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  802a0b:	e8 29 f4 ff ff       	call   801e39 <close>
  802a10:	83 c4 10             	add    $0x10,%esp
  802a13:	8b b5 88 fd ff ff    	mov    -0x278(%ebp),%esi
  802a19:	8b 9d 70 fd ff ff    	mov    -0x290(%ebp),%ebx
  802a1f:	eb 12                	jmp    802a33 <spawn+0x444>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	void* addr; int r;
	for (addr = 0; addr<(void*)USTACKTOP; addr+=PGSIZE){
  802a21:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802a27:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  802a2d:	0f 84 bc 00 00 00    	je     802aef <spawn+0x500>
		if ((uvpd[PDX(addr)]&PTE_P) && (uvpt[PGNUM(addr)]&PTE_P) && (uvpt[PGNUM(addr)]&PTE_SHARE)){
  802a33:	89 d8                	mov    %ebx,%eax
  802a35:	c1 e8 16             	shr    $0x16,%eax
  802a38:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802a3f:	a8 01                	test   $0x1,%al
  802a41:	74 de                	je     802a21 <spawn+0x432>
  802a43:	89 d8                	mov    %ebx,%eax
  802a45:	c1 e8 0c             	shr    $0xc,%eax
  802a48:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802a4f:	f6 c2 01             	test   $0x1,%dl
  802a52:	74 cd                	je     802a21 <spawn+0x432>
  802a54:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802a5b:	f6 c6 04             	test   $0x4,%dh
  802a5e:	74 c1                	je     802a21 <spawn+0x432>
			if ((r = sys_page_map(0, addr, child, addr, (uvpt[PGNUM(addr)]&PTE_SYSCALL)))<0)
  802a60:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802a67:	83 ec 0c             	sub    $0xc,%esp
  802a6a:	25 07 0e 00 00       	and    $0xe07,%eax
  802a6f:	50                   	push   %eax
  802a70:	53                   	push   %ebx
  802a71:	56                   	push   %esi
  802a72:	53                   	push   %ebx
  802a73:	6a 00                	push   $0x0
  802a75:	e8 9f ec ff ff       	call   801719 <sys_page_map>
  802a7a:	83 c4 20             	add    $0x20,%esp
  802a7d:	85 c0                	test   %eax,%eax
  802a7f:	79 a0                	jns    802a21 <spawn+0x432>
		panic("copy_shared_pages: %e", r);
  802a81:	50                   	push   %eax
  802a82:	68 ae 40 80 00       	push   $0x8040ae
  802a87:	68 82 00 00 00       	push   $0x82
  802a8c:	68 54 40 80 00       	push   $0x804054
  802a91:	e8 0f e0 ff ff       	call   800aa5 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  802a96:	50                   	push   %eax
  802a97:	68 7d 40 80 00       	push   $0x80407d
  802a9c:	68 86 00 00 00       	push   $0x86
  802aa1:	68 54 40 80 00       	push   $0x804054
  802aa6:	e8 fa df ff ff       	call   800aa5 <_panic>
		panic("sys_env_set_status: %e", r);
  802aab:	50                   	push   %eax
  802aac:	68 97 40 80 00       	push   $0x804097
  802ab1:	68 89 00 00 00       	push   $0x89
  802ab6:	68 54 40 80 00       	push   $0x804054
  802abb:	e8 e5 df ff ff       	call   800aa5 <_panic>
		return r;
  802ac0:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802ac6:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
}
  802acc:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802ad2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ad5:	5b                   	pop    %ebx
  802ad6:	5e                   	pop    %esi
  802ad7:	5f                   	pop    %edi
  802ad8:	5d                   	pop    %ebp
  802ad9:	c3                   	ret    
  802ada:	89 c7                	mov    %eax,%edi
  802adc:	e9 56 fe ff ff       	jmp    802937 <spawn+0x348>
  802ae1:	89 c7                	mov    %eax,%edi
  802ae3:	e9 4f fe ff ff       	jmp    802937 <spawn+0x348>
  802ae8:	89 c7                	mov    %eax,%edi
  802aea:	e9 48 fe ff ff       	jmp    802937 <spawn+0x348>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802aef:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802af6:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802af9:	83 ec 08             	sub    $0x8,%esp
  802afc:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802b02:	50                   	push   %eax
  802b03:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802b09:	e8 7a ec ff ff       	call   801788 <sys_env_set_trapframe>
  802b0e:	83 c4 10             	add    $0x10,%esp
  802b11:	85 c0                	test   %eax,%eax
  802b13:	78 81                	js     802a96 <spawn+0x4a7>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802b15:	83 ec 08             	sub    $0x8,%esp
  802b18:	6a 02                	push   $0x2
  802b1a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802b20:	e8 3e ec ff ff       	call   801763 <sys_env_set_status>
  802b25:	83 c4 10             	add    $0x10,%esp
  802b28:	85 c0                	test   %eax,%eax
  802b2a:	0f 88 7b ff ff ff    	js     802aab <spawn+0x4bc>
	return child;
  802b30:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802b36:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802b3c:	eb 8e                	jmp    802acc <spawn+0x4dd>
		return -E_NO_MEM;
  802b3e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802b43:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802b49:	eb 81                	jmp    802acc <spawn+0x4dd>
	sys_page_unmap(0, UTEMP);
  802b4b:	83 ec 08             	sub    $0x8,%esp
  802b4e:	68 00 00 40 00       	push   $0x400000
  802b53:	6a 00                	push   $0x0
  802b55:	e8 e4 eb ff ff       	call   80173e <sys_page_unmap>
  802b5a:	83 c4 10             	add    $0x10,%esp
  802b5d:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802b63:	e9 64 ff ff ff       	jmp    802acc <spawn+0x4dd>

00802b68 <spawnl>:
{
  802b68:	f3 0f 1e fb          	endbr32 
  802b6c:	55                   	push   %ebp
  802b6d:	89 e5                	mov    %esp,%ebp
  802b6f:	57                   	push   %edi
  802b70:	56                   	push   %esi
  802b71:	53                   	push   %ebx
  802b72:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  802b75:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  802b78:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  802b7d:	8d 4a 04             	lea    0x4(%edx),%ecx
  802b80:	83 3a 00             	cmpl   $0x0,(%edx)
  802b83:	74 07                	je     802b8c <spawnl+0x24>
		argc++;
  802b85:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  802b88:	89 ca                	mov    %ecx,%edx
  802b8a:	eb f1                	jmp    802b7d <spawnl+0x15>
	const char *argv[argc+2];
  802b8c:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  802b93:	89 d1                	mov    %edx,%ecx
  802b95:	83 e1 f0             	and    $0xfffffff0,%ecx
  802b98:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  802b9e:	89 e6                	mov    %esp,%esi
  802ba0:	29 d6                	sub    %edx,%esi
  802ba2:	89 f2                	mov    %esi,%edx
  802ba4:	39 d4                	cmp    %edx,%esp
  802ba6:	74 10                	je     802bb8 <spawnl+0x50>
  802ba8:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  802bae:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  802bb5:	00 
  802bb6:	eb ec                	jmp    802ba4 <spawnl+0x3c>
  802bb8:	89 ca                	mov    %ecx,%edx
  802bba:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  802bc0:	29 d4                	sub    %edx,%esp
  802bc2:	85 d2                	test   %edx,%edx
  802bc4:	74 05                	je     802bcb <spawnl+0x63>
  802bc6:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  802bcb:	8d 74 24 03          	lea    0x3(%esp),%esi
  802bcf:	89 f2                	mov    %esi,%edx
  802bd1:	c1 ea 02             	shr    $0x2,%edx
  802bd4:	83 e6 fc             	and    $0xfffffffc,%esi
  802bd7:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802bd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802bdc:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802be3:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802bea:	00 
	va_start(vl, arg0);
  802beb:	8d 4d 10             	lea    0x10(%ebp),%ecx
  802bee:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  802bf0:	b8 00 00 00 00       	mov    $0x0,%eax
  802bf5:	eb 0b                	jmp    802c02 <spawnl+0x9a>
		argv[i+1] = va_arg(vl, const char *);
  802bf7:	83 c0 01             	add    $0x1,%eax
  802bfa:	8b 39                	mov    (%ecx),%edi
  802bfc:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  802bff:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  802c02:	39 d0                	cmp    %edx,%eax
  802c04:	75 f1                	jne    802bf7 <spawnl+0x8f>
	return spawn(prog, argv);
  802c06:	83 ec 08             	sub    $0x8,%esp
  802c09:	56                   	push   %esi
  802c0a:	ff 75 08             	pushl  0x8(%ebp)
  802c0d:	e8 dd f9 ff ff       	call   8025ef <spawn>
}
  802c12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c15:	5b                   	pop    %ebx
  802c16:	5e                   	pop    %esi
  802c17:	5f                   	pop    %edi
  802c18:	5d                   	pop    %ebp
  802c19:	c3                   	ret    

00802c1a <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802c1a:	f3 0f 1e fb          	endbr32 
  802c1e:	55                   	push   %ebp
  802c1f:	89 e5                	mov    %esp,%ebp
  802c21:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  802c24:	68 ea 40 80 00       	push   $0x8040ea
  802c29:	ff 75 0c             	pushl  0xc(%ebp)
  802c2c:	e8 59 e6 ff ff       	call   80128a <strcpy>
	return 0;
}
  802c31:	b8 00 00 00 00       	mov    $0x0,%eax
  802c36:	c9                   	leave  
  802c37:	c3                   	ret    

00802c38 <devsock_close>:
{
  802c38:	f3 0f 1e fb          	endbr32 
  802c3c:	55                   	push   %ebp
  802c3d:	89 e5                	mov    %esp,%ebp
  802c3f:	53                   	push   %ebx
  802c40:	83 ec 10             	sub    $0x10,%esp
  802c43:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802c46:	53                   	push   %ebx
  802c47:	e8 d8 09 00 00       	call   803624 <pageref>
  802c4c:	89 c2                	mov    %eax,%edx
  802c4e:	83 c4 10             	add    $0x10,%esp
		return 0;
  802c51:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  802c56:	83 fa 01             	cmp    $0x1,%edx
  802c59:	74 05                	je     802c60 <devsock_close+0x28>
}
  802c5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c5e:	c9                   	leave  
  802c5f:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  802c60:	83 ec 0c             	sub    $0xc,%esp
  802c63:	ff 73 0c             	pushl  0xc(%ebx)
  802c66:	e8 e3 02 00 00       	call   802f4e <nsipc_close>
  802c6b:	83 c4 10             	add    $0x10,%esp
  802c6e:	eb eb                	jmp    802c5b <devsock_close+0x23>

00802c70 <devsock_write>:
{
  802c70:	f3 0f 1e fb          	endbr32 
  802c74:	55                   	push   %ebp
  802c75:	89 e5                	mov    %esp,%ebp
  802c77:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802c7a:	6a 00                	push   $0x0
  802c7c:	ff 75 10             	pushl  0x10(%ebp)
  802c7f:	ff 75 0c             	pushl  0xc(%ebp)
  802c82:	8b 45 08             	mov    0x8(%ebp),%eax
  802c85:	ff 70 0c             	pushl  0xc(%eax)
  802c88:	e8 b5 03 00 00       	call   803042 <nsipc_send>
}
  802c8d:	c9                   	leave  
  802c8e:	c3                   	ret    

00802c8f <devsock_read>:
{
  802c8f:	f3 0f 1e fb          	endbr32 
  802c93:	55                   	push   %ebp
  802c94:	89 e5                	mov    %esp,%ebp
  802c96:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802c99:	6a 00                	push   $0x0
  802c9b:	ff 75 10             	pushl  0x10(%ebp)
  802c9e:	ff 75 0c             	pushl  0xc(%ebp)
  802ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  802ca4:	ff 70 0c             	pushl  0xc(%eax)
  802ca7:	e8 1f 03 00 00       	call   802fcb <nsipc_recv>
}
  802cac:	c9                   	leave  
  802cad:	c3                   	ret    

00802cae <fd2sockid>:
{
  802cae:	55                   	push   %ebp
  802caf:	89 e5                	mov    %esp,%ebp
  802cb1:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  802cb4:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802cb7:	52                   	push   %edx
  802cb8:	50                   	push   %eax
  802cb9:	e8 3d f0 ff ff       	call   801cfb <fd_lookup>
  802cbe:	83 c4 10             	add    $0x10,%esp
  802cc1:	85 c0                	test   %eax,%eax
  802cc3:	78 10                	js     802cd5 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  802cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cc8:	8b 0d 60 50 80 00    	mov    0x805060,%ecx
  802cce:	39 08                	cmp    %ecx,(%eax)
  802cd0:	75 05                	jne    802cd7 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  802cd2:	8b 40 0c             	mov    0xc(%eax),%eax
}
  802cd5:	c9                   	leave  
  802cd6:	c3                   	ret    
		return -E_NOT_SUPP;
  802cd7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802cdc:	eb f7                	jmp    802cd5 <fd2sockid+0x27>

00802cde <alloc_sockfd>:
{
  802cde:	55                   	push   %ebp
  802cdf:	89 e5                	mov    %esp,%ebp
  802ce1:	56                   	push   %esi
  802ce2:	53                   	push   %ebx
  802ce3:	83 ec 1c             	sub    $0x1c,%esp
  802ce6:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  802ce8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ceb:	50                   	push   %eax
  802cec:	e8 b4 ef ff ff       	call   801ca5 <fd_alloc>
  802cf1:	89 c3                	mov    %eax,%ebx
  802cf3:	83 c4 10             	add    $0x10,%esp
  802cf6:	85 c0                	test   %eax,%eax
  802cf8:	78 43                	js     802d3d <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802cfa:	83 ec 04             	sub    $0x4,%esp
  802cfd:	68 07 04 00 00       	push   $0x407
  802d02:	ff 75 f4             	pushl  -0xc(%ebp)
  802d05:	6a 00                	push   $0x0
  802d07:	e8 e7 e9 ff ff       	call   8016f3 <sys_page_alloc>
  802d0c:	89 c3                	mov    %eax,%ebx
  802d0e:	83 c4 10             	add    $0x10,%esp
  802d11:	85 c0                	test   %eax,%eax
  802d13:	78 28                	js     802d3d <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  802d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d18:	8b 15 60 50 80 00    	mov    0x805060,%edx
  802d1e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d23:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802d2a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802d2d:	83 ec 0c             	sub    $0xc,%esp
  802d30:	50                   	push   %eax
  802d31:	e8 40 ef ff ff       	call   801c76 <fd2num>
  802d36:	89 c3                	mov    %eax,%ebx
  802d38:	83 c4 10             	add    $0x10,%esp
  802d3b:	eb 0c                	jmp    802d49 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  802d3d:	83 ec 0c             	sub    $0xc,%esp
  802d40:	56                   	push   %esi
  802d41:	e8 08 02 00 00       	call   802f4e <nsipc_close>
		return r;
  802d46:	83 c4 10             	add    $0x10,%esp
}
  802d49:	89 d8                	mov    %ebx,%eax
  802d4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d4e:	5b                   	pop    %ebx
  802d4f:	5e                   	pop    %esi
  802d50:	5d                   	pop    %ebp
  802d51:	c3                   	ret    

00802d52 <accept>:
{
  802d52:	f3 0f 1e fb          	endbr32 
  802d56:	55                   	push   %ebp
  802d57:	89 e5                	mov    %esp,%ebp
  802d59:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  802d5f:	e8 4a ff ff ff       	call   802cae <fd2sockid>
  802d64:	85 c0                	test   %eax,%eax
  802d66:	78 1b                	js     802d83 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802d68:	83 ec 04             	sub    $0x4,%esp
  802d6b:	ff 75 10             	pushl  0x10(%ebp)
  802d6e:	ff 75 0c             	pushl  0xc(%ebp)
  802d71:	50                   	push   %eax
  802d72:	e8 22 01 00 00       	call   802e99 <nsipc_accept>
  802d77:	83 c4 10             	add    $0x10,%esp
  802d7a:	85 c0                	test   %eax,%eax
  802d7c:	78 05                	js     802d83 <accept+0x31>
	return alloc_sockfd(r);
  802d7e:	e8 5b ff ff ff       	call   802cde <alloc_sockfd>
}
  802d83:	c9                   	leave  
  802d84:	c3                   	ret    

00802d85 <bind>:
{
  802d85:	f3 0f 1e fb          	endbr32 
  802d89:	55                   	push   %ebp
  802d8a:	89 e5                	mov    %esp,%ebp
  802d8c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  802d92:	e8 17 ff ff ff       	call   802cae <fd2sockid>
  802d97:	85 c0                	test   %eax,%eax
  802d99:	78 12                	js     802dad <bind+0x28>
	return nsipc_bind(r, name, namelen);
  802d9b:	83 ec 04             	sub    $0x4,%esp
  802d9e:	ff 75 10             	pushl  0x10(%ebp)
  802da1:	ff 75 0c             	pushl  0xc(%ebp)
  802da4:	50                   	push   %eax
  802da5:	e8 45 01 00 00       	call   802eef <nsipc_bind>
  802daa:	83 c4 10             	add    $0x10,%esp
}
  802dad:	c9                   	leave  
  802dae:	c3                   	ret    

00802daf <shutdown>:
{
  802daf:	f3 0f 1e fb          	endbr32 
  802db3:	55                   	push   %ebp
  802db4:	89 e5                	mov    %esp,%ebp
  802db6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802db9:	8b 45 08             	mov    0x8(%ebp),%eax
  802dbc:	e8 ed fe ff ff       	call   802cae <fd2sockid>
  802dc1:	85 c0                	test   %eax,%eax
  802dc3:	78 0f                	js     802dd4 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  802dc5:	83 ec 08             	sub    $0x8,%esp
  802dc8:	ff 75 0c             	pushl  0xc(%ebp)
  802dcb:	50                   	push   %eax
  802dcc:	e8 57 01 00 00       	call   802f28 <nsipc_shutdown>
  802dd1:	83 c4 10             	add    $0x10,%esp
}
  802dd4:	c9                   	leave  
  802dd5:	c3                   	ret    

00802dd6 <connect>:
{
  802dd6:	f3 0f 1e fb          	endbr32 
  802dda:	55                   	push   %ebp
  802ddb:	89 e5                	mov    %esp,%ebp
  802ddd:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802de0:	8b 45 08             	mov    0x8(%ebp),%eax
  802de3:	e8 c6 fe ff ff       	call   802cae <fd2sockid>
  802de8:	85 c0                	test   %eax,%eax
  802dea:	78 12                	js     802dfe <connect+0x28>
	return nsipc_connect(r, name, namelen);
  802dec:	83 ec 04             	sub    $0x4,%esp
  802def:	ff 75 10             	pushl  0x10(%ebp)
  802df2:	ff 75 0c             	pushl  0xc(%ebp)
  802df5:	50                   	push   %eax
  802df6:	e8 71 01 00 00       	call   802f6c <nsipc_connect>
  802dfb:	83 c4 10             	add    $0x10,%esp
}
  802dfe:	c9                   	leave  
  802dff:	c3                   	ret    

00802e00 <listen>:
{
  802e00:	f3 0f 1e fb          	endbr32 
  802e04:	55                   	push   %ebp
  802e05:	89 e5                	mov    %esp,%ebp
  802e07:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802e0a:	8b 45 08             	mov    0x8(%ebp),%eax
  802e0d:	e8 9c fe ff ff       	call   802cae <fd2sockid>
  802e12:	85 c0                	test   %eax,%eax
  802e14:	78 0f                	js     802e25 <listen+0x25>
	return nsipc_listen(r, backlog);
  802e16:	83 ec 08             	sub    $0x8,%esp
  802e19:	ff 75 0c             	pushl  0xc(%ebp)
  802e1c:	50                   	push   %eax
  802e1d:	e8 83 01 00 00       	call   802fa5 <nsipc_listen>
  802e22:	83 c4 10             	add    $0x10,%esp
}
  802e25:	c9                   	leave  
  802e26:	c3                   	ret    

00802e27 <socket>:

int
socket(int domain, int type, int protocol)
{
  802e27:	f3 0f 1e fb          	endbr32 
  802e2b:	55                   	push   %ebp
  802e2c:	89 e5                	mov    %esp,%ebp
  802e2e:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802e31:	ff 75 10             	pushl  0x10(%ebp)
  802e34:	ff 75 0c             	pushl  0xc(%ebp)
  802e37:	ff 75 08             	pushl  0x8(%ebp)
  802e3a:	e8 65 02 00 00       	call   8030a4 <nsipc_socket>
  802e3f:	83 c4 10             	add    $0x10,%esp
  802e42:	85 c0                	test   %eax,%eax
  802e44:	78 05                	js     802e4b <socket+0x24>
		return r;
	return alloc_sockfd(r);
  802e46:	e8 93 fe ff ff       	call   802cde <alloc_sockfd>
}
  802e4b:	c9                   	leave  
  802e4c:	c3                   	ret    

00802e4d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802e4d:	55                   	push   %ebp
  802e4e:	89 e5                	mov    %esp,%ebp
  802e50:	53                   	push   %ebx
  802e51:	83 ec 04             	sub    $0x4,%esp
  802e54:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802e56:	83 3d 24 64 80 00 00 	cmpl   $0x0,0x806424
  802e5d:	74 26                	je     802e85 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802e5f:	6a 07                	push   $0x7
  802e61:	68 00 80 80 00       	push   $0x808000
  802e66:	53                   	push   %ebx
  802e67:	ff 35 24 64 80 00    	pushl  0x806424
  802e6d:	e8 1d 07 00 00       	call   80358f <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802e72:	83 c4 0c             	add    $0xc,%esp
  802e75:	6a 00                	push   $0x0
  802e77:	6a 00                	push   $0x0
  802e79:	6a 00                	push   $0x0
  802e7b:	e8 a2 06 00 00       	call   803522 <ipc_recv>
}
  802e80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e83:	c9                   	leave  
  802e84:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802e85:	83 ec 0c             	sub    $0xc,%esp
  802e88:	6a 02                	push   $0x2
  802e8a:	e8 58 07 00 00       	call   8035e7 <ipc_find_env>
  802e8f:	a3 24 64 80 00       	mov    %eax,0x806424
  802e94:	83 c4 10             	add    $0x10,%esp
  802e97:	eb c6                	jmp    802e5f <nsipc+0x12>

00802e99 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802e99:	f3 0f 1e fb          	endbr32 
  802e9d:	55                   	push   %ebp
  802e9e:	89 e5                	mov    %esp,%ebp
  802ea0:	56                   	push   %esi
  802ea1:	53                   	push   %ebx
  802ea2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802ea5:	8b 45 08             	mov    0x8(%ebp),%eax
  802ea8:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802ead:	8b 06                	mov    (%esi),%eax
  802eaf:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802eb4:	b8 01 00 00 00       	mov    $0x1,%eax
  802eb9:	e8 8f ff ff ff       	call   802e4d <nsipc>
  802ebe:	89 c3                	mov    %eax,%ebx
  802ec0:	85 c0                	test   %eax,%eax
  802ec2:	79 09                	jns    802ecd <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  802ec4:	89 d8                	mov    %ebx,%eax
  802ec6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ec9:	5b                   	pop    %ebx
  802eca:	5e                   	pop    %esi
  802ecb:	5d                   	pop    %ebp
  802ecc:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802ecd:	83 ec 04             	sub    $0x4,%esp
  802ed0:	ff 35 10 80 80 00    	pushl  0x808010
  802ed6:	68 00 80 80 00       	push   $0x808000
  802edb:	ff 75 0c             	pushl  0xc(%ebp)
  802ede:	e8 a5 e5 ff ff       	call   801488 <memmove>
		*addrlen = ret->ret_addrlen;
  802ee3:	a1 10 80 80 00       	mov    0x808010,%eax
  802ee8:	89 06                	mov    %eax,(%esi)
  802eea:	83 c4 10             	add    $0x10,%esp
	return r;
  802eed:	eb d5                	jmp    802ec4 <nsipc_accept+0x2b>

00802eef <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802eef:	f3 0f 1e fb          	endbr32 
  802ef3:	55                   	push   %ebp
  802ef4:	89 e5                	mov    %esp,%ebp
  802ef6:	53                   	push   %ebx
  802ef7:	83 ec 08             	sub    $0x8,%esp
  802efa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802efd:	8b 45 08             	mov    0x8(%ebp),%eax
  802f00:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802f05:	53                   	push   %ebx
  802f06:	ff 75 0c             	pushl  0xc(%ebp)
  802f09:	68 04 80 80 00       	push   $0x808004
  802f0e:	e8 75 e5 ff ff       	call   801488 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802f13:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  802f19:	b8 02 00 00 00       	mov    $0x2,%eax
  802f1e:	e8 2a ff ff ff       	call   802e4d <nsipc>
}
  802f23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f26:	c9                   	leave  
  802f27:	c3                   	ret    

00802f28 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802f28:	f3 0f 1e fb          	endbr32 
  802f2c:	55                   	push   %ebp
  802f2d:	89 e5                	mov    %esp,%ebp
  802f2f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802f32:	8b 45 08             	mov    0x8(%ebp),%eax
  802f35:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  802f3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f3d:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  802f42:	b8 03 00 00 00       	mov    $0x3,%eax
  802f47:	e8 01 ff ff ff       	call   802e4d <nsipc>
}
  802f4c:	c9                   	leave  
  802f4d:	c3                   	ret    

00802f4e <nsipc_close>:

int
nsipc_close(int s)
{
  802f4e:	f3 0f 1e fb          	endbr32 
  802f52:	55                   	push   %ebp
  802f53:	89 e5                	mov    %esp,%ebp
  802f55:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802f58:	8b 45 08             	mov    0x8(%ebp),%eax
  802f5b:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  802f60:	b8 04 00 00 00       	mov    $0x4,%eax
  802f65:	e8 e3 fe ff ff       	call   802e4d <nsipc>
}
  802f6a:	c9                   	leave  
  802f6b:	c3                   	ret    

00802f6c <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802f6c:	f3 0f 1e fb          	endbr32 
  802f70:	55                   	push   %ebp
  802f71:	89 e5                	mov    %esp,%ebp
  802f73:	53                   	push   %ebx
  802f74:	83 ec 08             	sub    $0x8,%esp
  802f77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802f7a:	8b 45 08             	mov    0x8(%ebp),%eax
  802f7d:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802f82:	53                   	push   %ebx
  802f83:	ff 75 0c             	pushl  0xc(%ebp)
  802f86:	68 04 80 80 00       	push   $0x808004
  802f8b:	e8 f8 e4 ff ff       	call   801488 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802f90:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  802f96:	b8 05 00 00 00       	mov    $0x5,%eax
  802f9b:	e8 ad fe ff ff       	call   802e4d <nsipc>
}
  802fa0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802fa3:	c9                   	leave  
  802fa4:	c3                   	ret    

00802fa5 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802fa5:	f3 0f 1e fb          	endbr32 
  802fa9:	55                   	push   %ebp
  802faa:	89 e5                	mov    %esp,%ebp
  802fac:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802faf:	8b 45 08             	mov    0x8(%ebp),%eax
  802fb2:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  802fb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  802fba:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  802fbf:	b8 06 00 00 00       	mov    $0x6,%eax
  802fc4:	e8 84 fe ff ff       	call   802e4d <nsipc>
}
  802fc9:	c9                   	leave  
  802fca:	c3                   	ret    

00802fcb <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802fcb:	f3 0f 1e fb          	endbr32 
  802fcf:	55                   	push   %ebp
  802fd0:	89 e5                	mov    %esp,%ebp
  802fd2:	56                   	push   %esi
  802fd3:	53                   	push   %ebx
  802fd4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802fd7:	8b 45 08             	mov    0x8(%ebp),%eax
  802fda:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  802fdf:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  802fe5:	8b 45 14             	mov    0x14(%ebp),%eax
  802fe8:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802fed:	b8 07 00 00 00       	mov    $0x7,%eax
  802ff2:	e8 56 fe ff ff       	call   802e4d <nsipc>
  802ff7:	89 c3                	mov    %eax,%ebx
  802ff9:	85 c0                	test   %eax,%eax
  802ffb:	78 26                	js     803023 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  802ffd:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  803003:	b8 3f 06 00 00       	mov    $0x63f,%eax
  803008:	0f 4e c6             	cmovle %esi,%eax
  80300b:	39 c3                	cmp    %eax,%ebx
  80300d:	7f 1d                	jg     80302c <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80300f:	83 ec 04             	sub    $0x4,%esp
  803012:	53                   	push   %ebx
  803013:	68 00 80 80 00       	push   $0x808000
  803018:	ff 75 0c             	pushl  0xc(%ebp)
  80301b:	e8 68 e4 ff ff       	call   801488 <memmove>
  803020:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  803023:	89 d8                	mov    %ebx,%eax
  803025:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803028:	5b                   	pop    %ebx
  803029:	5e                   	pop    %esi
  80302a:	5d                   	pop    %ebp
  80302b:	c3                   	ret    
		assert(r < 1600 && r <= len);
  80302c:	68 f6 40 80 00       	push   $0x8040f6
  803031:	68 32 3a 80 00       	push   $0x803a32
  803036:	6a 62                	push   $0x62
  803038:	68 0b 41 80 00       	push   $0x80410b
  80303d:	e8 63 da ff ff       	call   800aa5 <_panic>

00803042 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  803042:	f3 0f 1e fb          	endbr32 
  803046:	55                   	push   %ebp
  803047:	89 e5                	mov    %esp,%ebp
  803049:	53                   	push   %ebx
  80304a:	83 ec 04             	sub    $0x4,%esp
  80304d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  803050:	8b 45 08             	mov    0x8(%ebp),%eax
  803053:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  803058:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80305e:	7f 2e                	jg     80308e <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  803060:	83 ec 04             	sub    $0x4,%esp
  803063:	53                   	push   %ebx
  803064:	ff 75 0c             	pushl  0xc(%ebp)
  803067:	68 0c 80 80 00       	push   $0x80800c
  80306c:	e8 17 e4 ff ff       	call   801488 <memmove>
	nsipcbuf.send.req_size = size;
  803071:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  803077:	8b 45 14             	mov    0x14(%ebp),%eax
  80307a:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  80307f:	b8 08 00 00 00       	mov    $0x8,%eax
  803084:	e8 c4 fd ff ff       	call   802e4d <nsipc>
}
  803089:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80308c:	c9                   	leave  
  80308d:	c3                   	ret    
	assert(size < 1600);
  80308e:	68 17 41 80 00       	push   $0x804117
  803093:	68 32 3a 80 00       	push   $0x803a32
  803098:	6a 6d                	push   $0x6d
  80309a:	68 0b 41 80 00       	push   $0x80410b
  80309f:	e8 01 da ff ff       	call   800aa5 <_panic>

008030a4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8030a4:	f3 0f 1e fb          	endbr32 
  8030a8:	55                   	push   %ebp
  8030a9:	89 e5                	mov    %esp,%ebp
  8030ab:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8030ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8030b1:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  8030b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8030b9:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  8030be:	8b 45 10             	mov    0x10(%ebp),%eax
  8030c1:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  8030c6:	b8 09 00 00 00       	mov    $0x9,%eax
  8030cb:	e8 7d fd ff ff       	call   802e4d <nsipc>
}
  8030d0:	c9                   	leave  
  8030d1:	c3                   	ret    

008030d2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8030d2:	f3 0f 1e fb          	endbr32 
  8030d6:	55                   	push   %ebp
  8030d7:	89 e5                	mov    %esp,%ebp
  8030d9:	56                   	push   %esi
  8030da:	53                   	push   %ebx
  8030db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8030de:	83 ec 0c             	sub    $0xc,%esp
  8030e1:	ff 75 08             	pushl  0x8(%ebp)
  8030e4:	e8 a1 eb ff ff       	call   801c8a <fd2data>
  8030e9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8030eb:	83 c4 08             	add    $0x8,%esp
  8030ee:	68 23 41 80 00       	push   $0x804123
  8030f3:	53                   	push   %ebx
  8030f4:	e8 91 e1 ff ff       	call   80128a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8030f9:	8b 46 04             	mov    0x4(%esi),%eax
  8030fc:	2b 06                	sub    (%esi),%eax
  8030fe:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  803104:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80310b:	00 00 00 
	stat->st_dev = &devpipe;
  80310e:	c7 83 88 00 00 00 7c 	movl   $0x80507c,0x88(%ebx)
  803115:	50 80 00 
	return 0;
}
  803118:	b8 00 00 00 00       	mov    $0x0,%eax
  80311d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803120:	5b                   	pop    %ebx
  803121:	5e                   	pop    %esi
  803122:	5d                   	pop    %ebp
  803123:	c3                   	ret    

00803124 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  803124:	f3 0f 1e fb          	endbr32 
  803128:	55                   	push   %ebp
  803129:	89 e5                	mov    %esp,%ebp
  80312b:	53                   	push   %ebx
  80312c:	83 ec 0c             	sub    $0xc,%esp
  80312f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803132:	53                   	push   %ebx
  803133:	6a 00                	push   $0x0
  803135:	e8 04 e6 ff ff       	call   80173e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80313a:	89 1c 24             	mov    %ebx,(%esp)
  80313d:	e8 48 eb ff ff       	call   801c8a <fd2data>
  803142:	83 c4 08             	add    $0x8,%esp
  803145:	50                   	push   %eax
  803146:	6a 00                	push   $0x0
  803148:	e8 f1 e5 ff ff       	call   80173e <sys_page_unmap>
}
  80314d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803150:	c9                   	leave  
  803151:	c3                   	ret    

00803152 <_pipeisclosed>:
{
  803152:	55                   	push   %ebp
  803153:	89 e5                	mov    %esp,%ebp
  803155:	57                   	push   %edi
  803156:	56                   	push   %esi
  803157:	53                   	push   %ebx
  803158:	83 ec 1c             	sub    $0x1c,%esp
  80315b:	89 c7                	mov    %eax,%edi
  80315d:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80315f:	a1 28 64 80 00       	mov    0x806428,%eax
  803164:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  803167:	83 ec 0c             	sub    $0xc,%esp
  80316a:	57                   	push   %edi
  80316b:	e8 b4 04 00 00       	call   803624 <pageref>
  803170:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  803173:	89 34 24             	mov    %esi,(%esp)
  803176:	e8 a9 04 00 00       	call   803624 <pageref>
		nn = thisenv->env_runs;
  80317b:	8b 15 28 64 80 00    	mov    0x806428,%edx
  803181:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  803184:	83 c4 10             	add    $0x10,%esp
  803187:	39 cb                	cmp    %ecx,%ebx
  803189:	74 1b                	je     8031a6 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80318b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80318e:	75 cf                	jne    80315f <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803190:	8b 42 58             	mov    0x58(%edx),%eax
  803193:	6a 01                	push   $0x1
  803195:	50                   	push   %eax
  803196:	53                   	push   %ebx
  803197:	68 2a 41 80 00       	push   $0x80412a
  80319c:	e8 eb d9 ff ff       	call   800b8c <cprintf>
  8031a1:	83 c4 10             	add    $0x10,%esp
  8031a4:	eb b9                	jmp    80315f <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8031a6:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8031a9:	0f 94 c0             	sete   %al
  8031ac:	0f b6 c0             	movzbl %al,%eax
}
  8031af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8031b2:	5b                   	pop    %ebx
  8031b3:	5e                   	pop    %esi
  8031b4:	5f                   	pop    %edi
  8031b5:	5d                   	pop    %ebp
  8031b6:	c3                   	ret    

008031b7 <devpipe_write>:
{
  8031b7:	f3 0f 1e fb          	endbr32 
  8031bb:	55                   	push   %ebp
  8031bc:	89 e5                	mov    %esp,%ebp
  8031be:	57                   	push   %edi
  8031bf:	56                   	push   %esi
  8031c0:	53                   	push   %ebx
  8031c1:	83 ec 28             	sub    $0x28,%esp
  8031c4:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8031c7:	56                   	push   %esi
  8031c8:	e8 bd ea ff ff       	call   801c8a <fd2data>
  8031cd:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8031cf:	83 c4 10             	add    $0x10,%esp
  8031d2:	bf 00 00 00 00       	mov    $0x0,%edi
  8031d7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8031da:	74 4f                	je     80322b <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8031dc:	8b 43 04             	mov    0x4(%ebx),%eax
  8031df:	8b 0b                	mov    (%ebx),%ecx
  8031e1:	8d 51 20             	lea    0x20(%ecx),%edx
  8031e4:	39 d0                	cmp    %edx,%eax
  8031e6:	72 14                	jb     8031fc <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8031e8:	89 da                	mov    %ebx,%edx
  8031ea:	89 f0                	mov    %esi,%eax
  8031ec:	e8 61 ff ff ff       	call   803152 <_pipeisclosed>
  8031f1:	85 c0                	test   %eax,%eax
  8031f3:	75 3b                	jne    803230 <devpipe_write+0x79>
			sys_yield();
  8031f5:	e8 d6 e4 ff ff       	call   8016d0 <sys_yield>
  8031fa:	eb e0                	jmp    8031dc <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8031fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8031ff:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803203:	88 4d e7             	mov    %cl,-0x19(%ebp)
  803206:	89 c2                	mov    %eax,%edx
  803208:	c1 fa 1f             	sar    $0x1f,%edx
  80320b:	89 d1                	mov    %edx,%ecx
  80320d:	c1 e9 1b             	shr    $0x1b,%ecx
  803210:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803213:	83 e2 1f             	and    $0x1f,%edx
  803216:	29 ca                	sub    %ecx,%edx
  803218:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80321c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803220:	83 c0 01             	add    $0x1,%eax
  803223:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  803226:	83 c7 01             	add    $0x1,%edi
  803229:	eb ac                	jmp    8031d7 <devpipe_write+0x20>
	return i;
  80322b:	8b 45 10             	mov    0x10(%ebp),%eax
  80322e:	eb 05                	jmp    803235 <devpipe_write+0x7e>
				return 0;
  803230:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803235:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803238:	5b                   	pop    %ebx
  803239:	5e                   	pop    %esi
  80323a:	5f                   	pop    %edi
  80323b:	5d                   	pop    %ebp
  80323c:	c3                   	ret    

0080323d <devpipe_read>:
{
  80323d:	f3 0f 1e fb          	endbr32 
  803241:	55                   	push   %ebp
  803242:	89 e5                	mov    %esp,%ebp
  803244:	57                   	push   %edi
  803245:	56                   	push   %esi
  803246:	53                   	push   %ebx
  803247:	83 ec 18             	sub    $0x18,%esp
  80324a:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80324d:	57                   	push   %edi
  80324e:	e8 37 ea ff ff       	call   801c8a <fd2data>
  803253:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  803255:	83 c4 10             	add    $0x10,%esp
  803258:	be 00 00 00 00       	mov    $0x0,%esi
  80325d:	3b 75 10             	cmp    0x10(%ebp),%esi
  803260:	75 14                	jne    803276 <devpipe_read+0x39>
	return i;
  803262:	8b 45 10             	mov    0x10(%ebp),%eax
  803265:	eb 02                	jmp    803269 <devpipe_read+0x2c>
				return i;
  803267:	89 f0                	mov    %esi,%eax
}
  803269:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80326c:	5b                   	pop    %ebx
  80326d:	5e                   	pop    %esi
  80326e:	5f                   	pop    %edi
  80326f:	5d                   	pop    %ebp
  803270:	c3                   	ret    
			sys_yield();
  803271:	e8 5a e4 ff ff       	call   8016d0 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  803276:	8b 03                	mov    (%ebx),%eax
  803278:	3b 43 04             	cmp    0x4(%ebx),%eax
  80327b:	75 18                	jne    803295 <devpipe_read+0x58>
			if (i > 0)
  80327d:	85 f6                	test   %esi,%esi
  80327f:	75 e6                	jne    803267 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  803281:	89 da                	mov    %ebx,%edx
  803283:	89 f8                	mov    %edi,%eax
  803285:	e8 c8 fe ff ff       	call   803152 <_pipeisclosed>
  80328a:	85 c0                	test   %eax,%eax
  80328c:	74 e3                	je     803271 <devpipe_read+0x34>
				return 0;
  80328e:	b8 00 00 00 00       	mov    $0x0,%eax
  803293:	eb d4                	jmp    803269 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803295:	99                   	cltd   
  803296:	c1 ea 1b             	shr    $0x1b,%edx
  803299:	01 d0                	add    %edx,%eax
  80329b:	83 e0 1f             	and    $0x1f,%eax
  80329e:	29 d0                	sub    %edx,%eax
  8032a0:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8032a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8032a8:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8032ab:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8032ae:	83 c6 01             	add    $0x1,%esi
  8032b1:	eb aa                	jmp    80325d <devpipe_read+0x20>

008032b3 <pipe>:
{
  8032b3:	f3 0f 1e fb          	endbr32 
  8032b7:	55                   	push   %ebp
  8032b8:	89 e5                	mov    %esp,%ebp
  8032ba:	56                   	push   %esi
  8032bb:	53                   	push   %ebx
  8032bc:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8032bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8032c2:	50                   	push   %eax
  8032c3:	e8 dd e9 ff ff       	call   801ca5 <fd_alloc>
  8032c8:	89 c3                	mov    %eax,%ebx
  8032ca:	83 c4 10             	add    $0x10,%esp
  8032cd:	85 c0                	test   %eax,%eax
  8032cf:	0f 88 23 01 00 00    	js     8033f8 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8032d5:	83 ec 04             	sub    $0x4,%esp
  8032d8:	68 07 04 00 00       	push   $0x407
  8032dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8032e0:	6a 00                	push   $0x0
  8032e2:	e8 0c e4 ff ff       	call   8016f3 <sys_page_alloc>
  8032e7:	89 c3                	mov    %eax,%ebx
  8032e9:	83 c4 10             	add    $0x10,%esp
  8032ec:	85 c0                	test   %eax,%eax
  8032ee:	0f 88 04 01 00 00    	js     8033f8 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8032f4:	83 ec 0c             	sub    $0xc,%esp
  8032f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8032fa:	50                   	push   %eax
  8032fb:	e8 a5 e9 ff ff       	call   801ca5 <fd_alloc>
  803300:	89 c3                	mov    %eax,%ebx
  803302:	83 c4 10             	add    $0x10,%esp
  803305:	85 c0                	test   %eax,%eax
  803307:	0f 88 db 00 00 00    	js     8033e8 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80330d:	83 ec 04             	sub    $0x4,%esp
  803310:	68 07 04 00 00       	push   $0x407
  803315:	ff 75 f0             	pushl  -0x10(%ebp)
  803318:	6a 00                	push   $0x0
  80331a:	e8 d4 e3 ff ff       	call   8016f3 <sys_page_alloc>
  80331f:	89 c3                	mov    %eax,%ebx
  803321:	83 c4 10             	add    $0x10,%esp
  803324:	85 c0                	test   %eax,%eax
  803326:	0f 88 bc 00 00 00    	js     8033e8 <pipe+0x135>
	va = fd2data(fd0);
  80332c:	83 ec 0c             	sub    $0xc,%esp
  80332f:	ff 75 f4             	pushl  -0xc(%ebp)
  803332:	e8 53 e9 ff ff       	call   801c8a <fd2data>
  803337:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803339:	83 c4 0c             	add    $0xc,%esp
  80333c:	68 07 04 00 00       	push   $0x407
  803341:	50                   	push   %eax
  803342:	6a 00                	push   $0x0
  803344:	e8 aa e3 ff ff       	call   8016f3 <sys_page_alloc>
  803349:	89 c3                	mov    %eax,%ebx
  80334b:	83 c4 10             	add    $0x10,%esp
  80334e:	85 c0                	test   %eax,%eax
  803350:	0f 88 82 00 00 00    	js     8033d8 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803356:	83 ec 0c             	sub    $0xc,%esp
  803359:	ff 75 f0             	pushl  -0x10(%ebp)
  80335c:	e8 29 e9 ff ff       	call   801c8a <fd2data>
  803361:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  803368:	50                   	push   %eax
  803369:	6a 00                	push   $0x0
  80336b:	56                   	push   %esi
  80336c:	6a 00                	push   $0x0
  80336e:	e8 a6 e3 ff ff       	call   801719 <sys_page_map>
  803373:	89 c3                	mov    %eax,%ebx
  803375:	83 c4 20             	add    $0x20,%esp
  803378:	85 c0                	test   %eax,%eax
  80337a:	78 4e                	js     8033ca <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  80337c:	a1 7c 50 80 00       	mov    0x80507c,%eax
  803381:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803384:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  803386:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803389:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  803390:	8b 55 f0             	mov    -0x10(%ebp),%edx
  803393:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  803395:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803398:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80339f:	83 ec 0c             	sub    $0xc,%esp
  8033a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8033a5:	e8 cc e8 ff ff       	call   801c76 <fd2num>
  8033aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8033ad:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8033af:	83 c4 04             	add    $0x4,%esp
  8033b2:	ff 75 f0             	pushl  -0x10(%ebp)
  8033b5:	e8 bc e8 ff ff       	call   801c76 <fd2num>
  8033ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8033bd:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8033c0:	83 c4 10             	add    $0x10,%esp
  8033c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8033c8:	eb 2e                	jmp    8033f8 <pipe+0x145>
	sys_page_unmap(0, va);
  8033ca:	83 ec 08             	sub    $0x8,%esp
  8033cd:	56                   	push   %esi
  8033ce:	6a 00                	push   $0x0
  8033d0:	e8 69 e3 ff ff       	call   80173e <sys_page_unmap>
  8033d5:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8033d8:	83 ec 08             	sub    $0x8,%esp
  8033db:	ff 75 f0             	pushl  -0x10(%ebp)
  8033de:	6a 00                	push   $0x0
  8033e0:	e8 59 e3 ff ff       	call   80173e <sys_page_unmap>
  8033e5:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8033e8:	83 ec 08             	sub    $0x8,%esp
  8033eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8033ee:	6a 00                	push   $0x0
  8033f0:	e8 49 e3 ff ff       	call   80173e <sys_page_unmap>
  8033f5:	83 c4 10             	add    $0x10,%esp
}
  8033f8:	89 d8                	mov    %ebx,%eax
  8033fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8033fd:	5b                   	pop    %ebx
  8033fe:	5e                   	pop    %esi
  8033ff:	5d                   	pop    %ebp
  803400:	c3                   	ret    

00803401 <pipeisclosed>:
{
  803401:	f3 0f 1e fb          	endbr32 
  803405:	55                   	push   %ebp
  803406:	89 e5                	mov    %esp,%ebp
  803408:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80340b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80340e:	50                   	push   %eax
  80340f:	ff 75 08             	pushl  0x8(%ebp)
  803412:	e8 e4 e8 ff ff       	call   801cfb <fd_lookup>
  803417:	83 c4 10             	add    $0x10,%esp
  80341a:	85 c0                	test   %eax,%eax
  80341c:	78 18                	js     803436 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  80341e:	83 ec 0c             	sub    $0xc,%esp
  803421:	ff 75 f4             	pushl  -0xc(%ebp)
  803424:	e8 61 e8 ff ff       	call   801c8a <fd2data>
  803429:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80342b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80342e:	e8 1f fd ff ff       	call   803152 <_pipeisclosed>
  803433:	83 c4 10             	add    $0x10,%esp
}
  803436:	c9                   	leave  
  803437:	c3                   	ret    

00803438 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  803438:	f3 0f 1e fb          	endbr32 
  80343c:	55                   	push   %ebp
  80343d:	89 e5                	mov    %esp,%ebp
  80343f:	56                   	push   %esi
  803440:	53                   	push   %ebx
  803441:	8b 75 08             	mov    0x8(%ebp),%esi
	// cprintf("[%08x] called wait for child %08x\n", thisenv->env_id, envid);
	const volatile struct Env *e;

	assert(envid != 0);
  803444:	85 f6                	test   %esi,%esi
  803446:	74 13                	je     80345b <wait+0x23>
	e = &envs[ENVX(envid)];
  803448:	89 f3                	mov    %esi,%ebx
  80344a:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  803450:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  803453:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  803459:	eb 1b                	jmp    803476 <wait+0x3e>
	assert(envid != 0);
  80345b:	68 42 41 80 00       	push   $0x804142
  803460:	68 32 3a 80 00       	push   $0x803a32
  803465:	6a 0a                	push   $0xa
  803467:	68 4d 41 80 00       	push   $0x80414d
  80346c:	e8 34 d6 ff ff       	call   800aa5 <_panic>
		sys_yield();
  803471:	e8 5a e2 ff ff       	call   8016d0 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  803476:	8b 43 48             	mov    0x48(%ebx),%eax
  803479:	39 f0                	cmp    %esi,%eax
  80347b:	75 07                	jne    803484 <wait+0x4c>
  80347d:	8b 43 54             	mov    0x54(%ebx),%eax
  803480:	85 c0                	test   %eax,%eax
  803482:	75 ed                	jne    803471 <wait+0x39>
}
  803484:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803487:	5b                   	pop    %ebx
  803488:	5e                   	pop    %esi
  803489:	5d                   	pop    %ebp
  80348a:	c3                   	ret    

0080348b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80348b:	f3 0f 1e fb          	endbr32 
  80348f:	55                   	push   %ebp
  803490:	89 e5                	mov    %esp,%ebp
  803492:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  803495:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  80349c:	74 0a                	je     8034a8 <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80349e:	8b 45 08             	mov    0x8(%ebp),%eax
  8034a1:	a3 00 90 80 00       	mov    %eax,0x809000

}
  8034a6:	c9                   	leave  
  8034a7:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  8034a8:	83 ec 04             	sub    $0x4,%esp
  8034ab:	6a 07                	push   $0x7
  8034ad:	68 00 f0 bf ee       	push   $0xeebff000
  8034b2:	6a 00                	push   $0x0
  8034b4:	e8 3a e2 ff ff       	call   8016f3 <sys_page_alloc>
  8034b9:	83 c4 10             	add    $0x10,%esp
  8034bc:	85 c0                	test   %eax,%eax
  8034be:	78 2a                	js     8034ea <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  8034c0:	83 ec 08             	sub    $0x8,%esp
  8034c3:	68 fe 34 80 00       	push   $0x8034fe
  8034c8:	6a 00                	push   $0x0
  8034ca:	e8 de e2 ff ff       	call   8017ad <sys_env_set_pgfault_upcall>
  8034cf:	83 c4 10             	add    $0x10,%esp
  8034d2:	85 c0                	test   %eax,%eax
  8034d4:	79 c8                	jns    80349e <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  8034d6:	83 ec 04             	sub    $0x4,%esp
  8034d9:	68 84 41 80 00       	push   $0x804184
  8034de:	6a 2c                	push   $0x2c
  8034e0:	68 ba 41 80 00       	push   $0x8041ba
  8034e5:	e8 bb d5 ff ff       	call   800aa5 <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  8034ea:	83 ec 04             	sub    $0x4,%esp
  8034ed:	68 58 41 80 00       	push   $0x804158
  8034f2:	6a 22                	push   $0x22
  8034f4:	68 ba 41 80 00       	push   $0x8041ba
  8034f9:	e8 a7 d5 ff ff       	call   800aa5 <_panic>

008034fe <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8034fe:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8034ff:	a1 00 90 80 00       	mov    0x809000,%eax
	call *%eax   			// 间接寻址
  803504:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  803506:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  803509:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  80350d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  803512:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  803516:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  803518:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  80351b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  80351c:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  80351f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  803520:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  803521:	c3                   	ret    

00803522 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  803522:	f3 0f 1e fb          	endbr32 
  803526:	55                   	push   %ebp
  803527:	89 e5                	mov    %esp,%ebp
  803529:	56                   	push   %esi
  80352a:	53                   	push   %ebx
  80352b:	8b 75 08             	mov    0x8(%ebp),%esi
  80352e:	8b 45 0c             	mov    0xc(%ebp),%eax
  803531:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  803534:	85 c0                	test   %eax,%eax
  803536:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80353b:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  80353e:	83 ec 0c             	sub    $0xc,%esp
  803541:	50                   	push   %eax
  803542:	e8 b2 e2 ff ff       	call   8017f9 <sys_ipc_recv>
  803547:	83 c4 10             	add    $0x10,%esp
  80354a:	85 c0                	test   %eax,%eax
  80354c:	75 2b                	jne    803579 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  80354e:	85 f6                	test   %esi,%esi
  803550:	74 0a                	je     80355c <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  803552:	a1 28 64 80 00       	mov    0x806428,%eax
  803557:	8b 40 74             	mov    0x74(%eax),%eax
  80355a:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  80355c:	85 db                	test   %ebx,%ebx
  80355e:	74 0a                	je     80356a <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  803560:	a1 28 64 80 00       	mov    0x806428,%eax
  803565:	8b 40 78             	mov    0x78(%eax),%eax
  803568:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  80356a:	a1 28 64 80 00       	mov    0x806428,%eax
  80356f:	8b 40 70             	mov    0x70(%eax),%eax
}
  803572:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803575:	5b                   	pop    %ebx
  803576:	5e                   	pop    %esi
  803577:	5d                   	pop    %ebp
  803578:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  803579:	85 f6                	test   %esi,%esi
  80357b:	74 06                	je     803583 <ipc_recv+0x61>
  80357d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  803583:	85 db                	test   %ebx,%ebx
  803585:	74 eb                	je     803572 <ipc_recv+0x50>
  803587:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80358d:	eb e3                	jmp    803572 <ipc_recv+0x50>

0080358f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80358f:	f3 0f 1e fb          	endbr32 
  803593:	55                   	push   %ebp
  803594:	89 e5                	mov    %esp,%ebp
  803596:	57                   	push   %edi
  803597:	56                   	push   %esi
  803598:	53                   	push   %ebx
  803599:	83 ec 0c             	sub    $0xc,%esp
  80359c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80359f:	8b 75 0c             	mov    0xc(%ebp),%esi
  8035a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  8035a5:	85 db                	test   %ebx,%ebx
  8035a7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8035ac:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8035af:	ff 75 14             	pushl  0x14(%ebp)
  8035b2:	53                   	push   %ebx
  8035b3:	56                   	push   %esi
  8035b4:	57                   	push   %edi
  8035b5:	e8 18 e2 ff ff       	call   8017d2 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  8035ba:	83 c4 10             	add    $0x10,%esp
  8035bd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8035c0:	75 07                	jne    8035c9 <ipc_send+0x3a>
			sys_yield();
  8035c2:	e8 09 e1 ff ff       	call   8016d0 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8035c7:	eb e6                	jmp    8035af <ipc_send+0x20>
		}
		else if (ret == 0)
  8035c9:	85 c0                	test   %eax,%eax
  8035cb:	75 08                	jne    8035d5 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  8035cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8035d0:	5b                   	pop    %ebx
  8035d1:	5e                   	pop    %esi
  8035d2:	5f                   	pop    %edi
  8035d3:	5d                   	pop    %ebp
  8035d4:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  8035d5:	50                   	push   %eax
  8035d6:	68 c8 41 80 00       	push   $0x8041c8
  8035db:	6a 48                	push   $0x48
  8035dd:	68 d6 41 80 00       	push   $0x8041d6
  8035e2:	e8 be d4 ff ff       	call   800aa5 <_panic>

008035e7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8035e7:	f3 0f 1e fb          	endbr32 
  8035eb:	55                   	push   %ebp
  8035ec:	89 e5                	mov    %esp,%ebp
  8035ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8035f1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8035f6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8035f9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8035ff:	8b 52 50             	mov    0x50(%edx),%edx
  803602:	39 ca                	cmp    %ecx,%edx
  803604:	74 11                	je     803617 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  803606:	83 c0 01             	add    $0x1,%eax
  803609:	3d 00 04 00 00       	cmp    $0x400,%eax
  80360e:	75 e6                	jne    8035f6 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  803610:	b8 00 00 00 00       	mov    $0x0,%eax
  803615:	eb 0b                	jmp    803622 <ipc_find_env+0x3b>
			return envs[i].env_id;
  803617:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80361a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80361f:	8b 40 48             	mov    0x48(%eax),%eax
}
  803622:	5d                   	pop    %ebp
  803623:	c3                   	ret    

00803624 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803624:	f3 0f 1e fb          	endbr32 
  803628:	55                   	push   %ebp
  803629:	89 e5                	mov    %esp,%ebp
  80362b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80362e:	89 c2                	mov    %eax,%edx
  803630:	c1 ea 16             	shr    $0x16,%edx
  803633:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80363a:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80363f:	f6 c1 01             	test   $0x1,%cl
  803642:	74 1c                	je     803660 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  803644:	c1 e8 0c             	shr    $0xc,%eax
  803647:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80364e:	a8 01                	test   $0x1,%al
  803650:	74 0e                	je     803660 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803652:	c1 e8 0c             	shr    $0xc,%eax
  803655:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80365c:	ef 
  80365d:	0f b7 d2             	movzwl %dx,%edx
}
  803660:	89 d0                	mov    %edx,%eax
  803662:	5d                   	pop    %ebp
  803663:	c3                   	ret    
  803664:	66 90                	xchg   %ax,%ax
  803666:	66 90                	xchg   %ax,%ax
  803668:	66 90                	xchg   %ax,%ax
  80366a:	66 90                	xchg   %ax,%ax
  80366c:	66 90                	xchg   %ax,%ax
  80366e:	66 90                	xchg   %ax,%ax

00803670 <__udivdi3>:
  803670:	f3 0f 1e fb          	endbr32 
  803674:	55                   	push   %ebp
  803675:	57                   	push   %edi
  803676:	56                   	push   %esi
  803677:	53                   	push   %ebx
  803678:	83 ec 1c             	sub    $0x1c,%esp
  80367b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80367f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  803683:	8b 74 24 34          	mov    0x34(%esp),%esi
  803687:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80368b:	85 d2                	test   %edx,%edx
  80368d:	75 19                	jne    8036a8 <__udivdi3+0x38>
  80368f:	39 f3                	cmp    %esi,%ebx
  803691:	76 4d                	jbe    8036e0 <__udivdi3+0x70>
  803693:	31 ff                	xor    %edi,%edi
  803695:	89 e8                	mov    %ebp,%eax
  803697:	89 f2                	mov    %esi,%edx
  803699:	f7 f3                	div    %ebx
  80369b:	89 fa                	mov    %edi,%edx
  80369d:	83 c4 1c             	add    $0x1c,%esp
  8036a0:	5b                   	pop    %ebx
  8036a1:	5e                   	pop    %esi
  8036a2:	5f                   	pop    %edi
  8036a3:	5d                   	pop    %ebp
  8036a4:	c3                   	ret    
  8036a5:	8d 76 00             	lea    0x0(%esi),%esi
  8036a8:	39 f2                	cmp    %esi,%edx
  8036aa:	76 14                	jbe    8036c0 <__udivdi3+0x50>
  8036ac:	31 ff                	xor    %edi,%edi
  8036ae:	31 c0                	xor    %eax,%eax
  8036b0:	89 fa                	mov    %edi,%edx
  8036b2:	83 c4 1c             	add    $0x1c,%esp
  8036b5:	5b                   	pop    %ebx
  8036b6:	5e                   	pop    %esi
  8036b7:	5f                   	pop    %edi
  8036b8:	5d                   	pop    %ebp
  8036b9:	c3                   	ret    
  8036ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8036c0:	0f bd fa             	bsr    %edx,%edi
  8036c3:	83 f7 1f             	xor    $0x1f,%edi
  8036c6:	75 48                	jne    803710 <__udivdi3+0xa0>
  8036c8:	39 f2                	cmp    %esi,%edx
  8036ca:	72 06                	jb     8036d2 <__udivdi3+0x62>
  8036cc:	31 c0                	xor    %eax,%eax
  8036ce:	39 eb                	cmp    %ebp,%ebx
  8036d0:	77 de                	ja     8036b0 <__udivdi3+0x40>
  8036d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8036d7:	eb d7                	jmp    8036b0 <__udivdi3+0x40>
  8036d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8036e0:	89 d9                	mov    %ebx,%ecx
  8036e2:	85 db                	test   %ebx,%ebx
  8036e4:	75 0b                	jne    8036f1 <__udivdi3+0x81>
  8036e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8036eb:	31 d2                	xor    %edx,%edx
  8036ed:	f7 f3                	div    %ebx
  8036ef:	89 c1                	mov    %eax,%ecx
  8036f1:	31 d2                	xor    %edx,%edx
  8036f3:	89 f0                	mov    %esi,%eax
  8036f5:	f7 f1                	div    %ecx
  8036f7:	89 c6                	mov    %eax,%esi
  8036f9:	89 e8                	mov    %ebp,%eax
  8036fb:	89 f7                	mov    %esi,%edi
  8036fd:	f7 f1                	div    %ecx
  8036ff:	89 fa                	mov    %edi,%edx
  803701:	83 c4 1c             	add    $0x1c,%esp
  803704:	5b                   	pop    %ebx
  803705:	5e                   	pop    %esi
  803706:	5f                   	pop    %edi
  803707:	5d                   	pop    %ebp
  803708:	c3                   	ret    
  803709:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803710:	89 f9                	mov    %edi,%ecx
  803712:	b8 20 00 00 00       	mov    $0x20,%eax
  803717:	29 f8                	sub    %edi,%eax
  803719:	d3 e2                	shl    %cl,%edx
  80371b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80371f:	89 c1                	mov    %eax,%ecx
  803721:	89 da                	mov    %ebx,%edx
  803723:	d3 ea                	shr    %cl,%edx
  803725:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  803729:	09 d1                	or     %edx,%ecx
  80372b:	89 f2                	mov    %esi,%edx
  80372d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803731:	89 f9                	mov    %edi,%ecx
  803733:	d3 e3                	shl    %cl,%ebx
  803735:	89 c1                	mov    %eax,%ecx
  803737:	d3 ea                	shr    %cl,%edx
  803739:	89 f9                	mov    %edi,%ecx
  80373b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80373f:	89 eb                	mov    %ebp,%ebx
  803741:	d3 e6                	shl    %cl,%esi
  803743:	89 c1                	mov    %eax,%ecx
  803745:	d3 eb                	shr    %cl,%ebx
  803747:	09 de                	or     %ebx,%esi
  803749:	89 f0                	mov    %esi,%eax
  80374b:	f7 74 24 08          	divl   0x8(%esp)
  80374f:	89 d6                	mov    %edx,%esi
  803751:	89 c3                	mov    %eax,%ebx
  803753:	f7 64 24 0c          	mull   0xc(%esp)
  803757:	39 d6                	cmp    %edx,%esi
  803759:	72 15                	jb     803770 <__udivdi3+0x100>
  80375b:	89 f9                	mov    %edi,%ecx
  80375d:	d3 e5                	shl    %cl,%ebp
  80375f:	39 c5                	cmp    %eax,%ebp
  803761:	73 04                	jae    803767 <__udivdi3+0xf7>
  803763:	39 d6                	cmp    %edx,%esi
  803765:	74 09                	je     803770 <__udivdi3+0x100>
  803767:	89 d8                	mov    %ebx,%eax
  803769:	31 ff                	xor    %edi,%edi
  80376b:	e9 40 ff ff ff       	jmp    8036b0 <__udivdi3+0x40>
  803770:	8d 43 ff             	lea    -0x1(%ebx),%eax
  803773:	31 ff                	xor    %edi,%edi
  803775:	e9 36 ff ff ff       	jmp    8036b0 <__udivdi3+0x40>
  80377a:	66 90                	xchg   %ax,%ax
  80377c:	66 90                	xchg   %ax,%ax
  80377e:	66 90                	xchg   %ax,%ax

00803780 <__umoddi3>:
  803780:	f3 0f 1e fb          	endbr32 
  803784:	55                   	push   %ebp
  803785:	57                   	push   %edi
  803786:	56                   	push   %esi
  803787:	53                   	push   %ebx
  803788:	83 ec 1c             	sub    $0x1c,%esp
  80378b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80378f:	8b 74 24 30          	mov    0x30(%esp),%esi
  803793:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  803797:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80379b:	85 c0                	test   %eax,%eax
  80379d:	75 19                	jne    8037b8 <__umoddi3+0x38>
  80379f:	39 df                	cmp    %ebx,%edi
  8037a1:	76 5d                	jbe    803800 <__umoddi3+0x80>
  8037a3:	89 f0                	mov    %esi,%eax
  8037a5:	89 da                	mov    %ebx,%edx
  8037a7:	f7 f7                	div    %edi
  8037a9:	89 d0                	mov    %edx,%eax
  8037ab:	31 d2                	xor    %edx,%edx
  8037ad:	83 c4 1c             	add    $0x1c,%esp
  8037b0:	5b                   	pop    %ebx
  8037b1:	5e                   	pop    %esi
  8037b2:	5f                   	pop    %edi
  8037b3:	5d                   	pop    %ebp
  8037b4:	c3                   	ret    
  8037b5:	8d 76 00             	lea    0x0(%esi),%esi
  8037b8:	89 f2                	mov    %esi,%edx
  8037ba:	39 d8                	cmp    %ebx,%eax
  8037bc:	76 12                	jbe    8037d0 <__umoddi3+0x50>
  8037be:	89 f0                	mov    %esi,%eax
  8037c0:	89 da                	mov    %ebx,%edx
  8037c2:	83 c4 1c             	add    $0x1c,%esp
  8037c5:	5b                   	pop    %ebx
  8037c6:	5e                   	pop    %esi
  8037c7:	5f                   	pop    %edi
  8037c8:	5d                   	pop    %ebp
  8037c9:	c3                   	ret    
  8037ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8037d0:	0f bd e8             	bsr    %eax,%ebp
  8037d3:	83 f5 1f             	xor    $0x1f,%ebp
  8037d6:	75 50                	jne    803828 <__umoddi3+0xa8>
  8037d8:	39 d8                	cmp    %ebx,%eax
  8037da:	0f 82 e0 00 00 00    	jb     8038c0 <__umoddi3+0x140>
  8037e0:	89 d9                	mov    %ebx,%ecx
  8037e2:	39 f7                	cmp    %esi,%edi
  8037e4:	0f 86 d6 00 00 00    	jbe    8038c0 <__umoddi3+0x140>
  8037ea:	89 d0                	mov    %edx,%eax
  8037ec:	89 ca                	mov    %ecx,%edx
  8037ee:	83 c4 1c             	add    $0x1c,%esp
  8037f1:	5b                   	pop    %ebx
  8037f2:	5e                   	pop    %esi
  8037f3:	5f                   	pop    %edi
  8037f4:	5d                   	pop    %ebp
  8037f5:	c3                   	ret    
  8037f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8037fd:	8d 76 00             	lea    0x0(%esi),%esi
  803800:	89 fd                	mov    %edi,%ebp
  803802:	85 ff                	test   %edi,%edi
  803804:	75 0b                	jne    803811 <__umoddi3+0x91>
  803806:	b8 01 00 00 00       	mov    $0x1,%eax
  80380b:	31 d2                	xor    %edx,%edx
  80380d:	f7 f7                	div    %edi
  80380f:	89 c5                	mov    %eax,%ebp
  803811:	89 d8                	mov    %ebx,%eax
  803813:	31 d2                	xor    %edx,%edx
  803815:	f7 f5                	div    %ebp
  803817:	89 f0                	mov    %esi,%eax
  803819:	f7 f5                	div    %ebp
  80381b:	89 d0                	mov    %edx,%eax
  80381d:	31 d2                	xor    %edx,%edx
  80381f:	eb 8c                	jmp    8037ad <__umoddi3+0x2d>
  803821:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803828:	89 e9                	mov    %ebp,%ecx
  80382a:	ba 20 00 00 00       	mov    $0x20,%edx
  80382f:	29 ea                	sub    %ebp,%edx
  803831:	d3 e0                	shl    %cl,%eax
  803833:	89 44 24 08          	mov    %eax,0x8(%esp)
  803837:	89 d1                	mov    %edx,%ecx
  803839:	89 f8                	mov    %edi,%eax
  80383b:	d3 e8                	shr    %cl,%eax
  80383d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  803841:	89 54 24 04          	mov    %edx,0x4(%esp)
  803845:	8b 54 24 04          	mov    0x4(%esp),%edx
  803849:	09 c1                	or     %eax,%ecx
  80384b:	89 d8                	mov    %ebx,%eax
  80384d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803851:	89 e9                	mov    %ebp,%ecx
  803853:	d3 e7                	shl    %cl,%edi
  803855:	89 d1                	mov    %edx,%ecx
  803857:	d3 e8                	shr    %cl,%eax
  803859:	89 e9                	mov    %ebp,%ecx
  80385b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80385f:	d3 e3                	shl    %cl,%ebx
  803861:	89 c7                	mov    %eax,%edi
  803863:	89 d1                	mov    %edx,%ecx
  803865:	89 f0                	mov    %esi,%eax
  803867:	d3 e8                	shr    %cl,%eax
  803869:	89 e9                	mov    %ebp,%ecx
  80386b:	89 fa                	mov    %edi,%edx
  80386d:	d3 e6                	shl    %cl,%esi
  80386f:	09 d8                	or     %ebx,%eax
  803871:	f7 74 24 08          	divl   0x8(%esp)
  803875:	89 d1                	mov    %edx,%ecx
  803877:	89 f3                	mov    %esi,%ebx
  803879:	f7 64 24 0c          	mull   0xc(%esp)
  80387d:	89 c6                	mov    %eax,%esi
  80387f:	89 d7                	mov    %edx,%edi
  803881:	39 d1                	cmp    %edx,%ecx
  803883:	72 06                	jb     80388b <__umoddi3+0x10b>
  803885:	75 10                	jne    803897 <__umoddi3+0x117>
  803887:	39 c3                	cmp    %eax,%ebx
  803889:	73 0c                	jae    803897 <__umoddi3+0x117>
  80388b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80388f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  803893:	89 d7                	mov    %edx,%edi
  803895:	89 c6                	mov    %eax,%esi
  803897:	89 ca                	mov    %ecx,%edx
  803899:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80389e:	29 f3                	sub    %esi,%ebx
  8038a0:	19 fa                	sbb    %edi,%edx
  8038a2:	89 d0                	mov    %edx,%eax
  8038a4:	d3 e0                	shl    %cl,%eax
  8038a6:	89 e9                	mov    %ebp,%ecx
  8038a8:	d3 eb                	shr    %cl,%ebx
  8038aa:	d3 ea                	shr    %cl,%edx
  8038ac:	09 d8                	or     %ebx,%eax
  8038ae:	83 c4 1c             	add    $0x1c,%esp
  8038b1:	5b                   	pop    %ebx
  8038b2:	5e                   	pop    %esi
  8038b3:	5f                   	pop    %edi
  8038b4:	5d                   	pop    %ebp
  8038b5:	c3                   	ret    
  8038b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8038bd:	8d 76 00             	lea    0x0(%esi),%esi
  8038c0:	29 fe                	sub    %edi,%esi
  8038c2:	19 c3                	sbb    %eax,%ebx
  8038c4:	89 f2                	mov    %esi,%edx
  8038c6:	89 d9                	mov    %ebx,%ecx
  8038c8:	e9 1d ff ff ff       	jmp    8037ea <__umoddi3+0x6a>
