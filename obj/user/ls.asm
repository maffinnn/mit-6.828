
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 a9 02 00 00       	call   8002da <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	const char *sep;

	if(flag['l'])
  800042:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  800049:	74 20                	je     80006b <ls1+0x38>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  80004b:	89 f0                	mov    %esi,%eax
  80004d:	3c 01                	cmp    $0x1,%al
  80004f:	19 c0                	sbb    %eax,%eax
  800051:	83 e0 c9             	and    $0xffffffc9,%eax
  800054:	83 c0 64             	add    $0x64,%eax
  800057:	83 ec 04             	sub    $0x4,%esp
  80005a:	50                   	push   %eax
  80005b:	ff 75 10             	pushl  0x10(%ebp)
  80005e:	68 62 28 80 00       	push   $0x802862
  800063:	e8 89 1a 00 00       	call   801af1 <printf>
  800068:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  80006b:	85 db                	test   %ebx,%ebx
  80006d:	74 1c                	je     80008b <ls1+0x58>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006f:	b8 c8 28 80 00       	mov    $0x8028c8,%eax
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800074:	80 3b 00             	cmpb   $0x0,(%ebx)
  800077:	75 4b                	jne    8000c4 <ls1+0x91>
		printf("%s%s", prefix, sep);
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 6b 28 80 00       	push   $0x80286b
  800083:	e8 69 1a 00 00       	call   801af1 <printf>
  800088:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	ff 75 14             	pushl  0x14(%ebp)
  800091:	68 c9 2c 80 00       	push   $0x802cc9
  800096:	e8 56 1a 00 00       	call   801af1 <printf>
	if(flag['F'] && isdir)
  80009b:	83 c4 10             	add    $0x10,%esp
  80009e:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000a5:	74 06                	je     8000ad <ls1+0x7a>
  8000a7:	89 f0                	mov    %esi,%eax
  8000a9:	84 c0                	test   %al,%al
  8000ab:	75 37                	jne    8000e4 <ls1+0xb1>
		printf("/");
	printf("\n");
  8000ad:	83 ec 0c             	sub    $0xc,%esp
  8000b0:	68 c7 28 80 00       	push   $0x8028c7
  8000b5:	e8 37 1a 00 00       	call   801af1 <printf>
}
  8000ba:	83 c4 10             	add    $0x10,%esp
  8000bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5d                   	pop    %ebp
  8000c3:	c3                   	ret    
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  8000c4:	83 ec 0c             	sub    $0xc,%esp
  8000c7:	53                   	push   %ebx
  8000c8:	e8 23 09 00 00       	call   8009f0 <strlen>
  8000cd:	83 c4 10             	add    $0x10,%esp
			sep = "";
  8000d0:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  8000d5:	b8 60 28 80 00       	mov    $0x802860,%eax
  8000da:	ba c8 28 80 00       	mov    $0x8028c8,%edx
  8000df:	0f 44 c2             	cmove  %edx,%eax
  8000e2:	eb 95                	jmp    800079 <ls1+0x46>
		printf("/");
  8000e4:	83 ec 0c             	sub    $0xc,%esp
  8000e7:	68 60 28 80 00       	push   $0x802860
  8000ec:	e8 00 1a 00 00       	call   801af1 <printf>
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	eb b7                	jmp    8000ad <ls1+0x7a>

008000f6 <lsdir>:
{
  8000f6:	f3 0f 1e fb          	endbr32 
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	57                   	push   %edi
  8000fe:	56                   	push   %esi
  8000ff:	53                   	push   %ebx
  800100:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800106:	8b 7d 08             	mov    0x8(%ebp),%edi
	if ((fd = open(path, O_RDONLY)) < 0)
  800109:	6a 00                	push   $0x0
  80010b:	57                   	push   %edi
  80010c:	e8 29 18 00 00       	call   80193a <open>
  800111:	89 c3                	mov    %eax,%ebx
  800113:	83 c4 10             	add    $0x10,%esp
  800116:	85 c0                	test   %eax,%eax
  800118:	78 4a                	js     800164 <lsdir+0x6e>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80011a:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800120:	83 ec 04             	sub    $0x4,%esp
  800123:	68 00 01 00 00       	push   $0x100
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	e8 fb 13 00 00       	call   80152a <readn>
  80012f:	83 c4 10             	add    $0x10,%esp
  800132:	3d 00 01 00 00       	cmp    $0x100,%eax
  800137:	75 41                	jne    80017a <lsdir+0x84>
		if (f.f_name[0])
  800139:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  800140:	74 de                	je     800120 <lsdir+0x2a>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  800142:	56                   	push   %esi
  800143:	ff b5 68 ff ff ff    	pushl  -0x98(%ebp)
  800149:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  800150:	0f 94 c0             	sete   %al
  800153:	0f b6 c0             	movzbl %al,%eax
  800156:	50                   	push   %eax
  800157:	ff 75 0c             	pushl  0xc(%ebp)
  80015a:	e8 d4 fe ff ff       	call   800033 <ls1>
  80015f:	83 c4 10             	add    $0x10,%esp
  800162:	eb bc                	jmp    800120 <lsdir+0x2a>
		panic("open %s: %e", path, fd);
  800164:	83 ec 0c             	sub    $0xc,%esp
  800167:	50                   	push   %eax
  800168:	57                   	push   %edi
  800169:	68 70 28 80 00       	push   $0x802870
  80016e:	6a 1d                	push   $0x1d
  800170:	68 7c 28 80 00       	push   $0x80287c
  800175:	e8 c8 01 00 00       	call   800342 <_panic>
	if (n > 0)
  80017a:	85 c0                	test   %eax,%eax
  80017c:	7f 0a                	jg     800188 <lsdir+0x92>
	if (n < 0)
  80017e:	78 1a                	js     80019a <lsdir+0xa4>
}
  800180:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800183:	5b                   	pop    %ebx
  800184:	5e                   	pop    %esi
  800185:	5f                   	pop    %edi
  800186:	5d                   	pop    %ebp
  800187:	c3                   	ret    
		panic("short read in directory %s", path);
  800188:	57                   	push   %edi
  800189:	68 86 28 80 00       	push   $0x802886
  80018e:	6a 22                	push   $0x22
  800190:	68 7c 28 80 00       	push   $0x80287c
  800195:	e8 a8 01 00 00       	call   800342 <_panic>
		panic("error reading directory %s: %e", path, n);
  80019a:	83 ec 0c             	sub    $0xc,%esp
  80019d:	50                   	push   %eax
  80019e:	57                   	push   %edi
  80019f:	68 cc 28 80 00       	push   $0x8028cc
  8001a4:	6a 24                	push   $0x24
  8001a6:	68 7c 28 80 00       	push   $0x80287c
  8001ab:	e8 92 01 00 00       	call   800342 <_panic>

008001b0 <ls>:
{
  8001b0:	f3 0f 1e fb          	endbr32 
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	53                   	push   %ebx
  8001b8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  8001be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = stat(path, &st)) < 0)
  8001c1:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001c7:	50                   	push   %eax
  8001c8:	53                   	push   %ebx
  8001c9:	e8 55 15 00 00       	call   801723 <stat>
  8001ce:	83 c4 10             	add    $0x10,%esp
  8001d1:	85 c0                	test   %eax,%eax
  8001d3:	78 2c                	js     800201 <ls+0x51>
	if (st.st_isdir && !flag['d'])
  8001d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001d8:	85 c0                	test   %eax,%eax
  8001da:	74 09                	je     8001e5 <ls+0x35>
  8001dc:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  8001e3:	74 32                	je     800217 <ls+0x67>
		ls1(0, st.st_isdir, st.st_size, path);
  8001e5:	53                   	push   %ebx
  8001e6:	ff 75 ec             	pushl  -0x14(%ebp)
  8001e9:	85 c0                	test   %eax,%eax
  8001eb:	0f 95 c0             	setne  %al
  8001ee:	0f b6 c0             	movzbl %al,%eax
  8001f1:	50                   	push   %eax
  8001f2:	6a 00                	push   $0x0
  8001f4:	e8 3a fe ff ff       	call   800033 <ls1>
  8001f9:	83 c4 10             	add    $0x10,%esp
}
  8001fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ff:	c9                   	leave  
  800200:	c3                   	ret    
		panic("stat %s: %e", path, r);
  800201:	83 ec 0c             	sub    $0xc,%esp
  800204:	50                   	push   %eax
  800205:	53                   	push   %ebx
  800206:	68 a1 28 80 00       	push   $0x8028a1
  80020b:	6a 0f                	push   $0xf
  80020d:	68 7c 28 80 00       	push   $0x80287c
  800212:	e8 2b 01 00 00       	call   800342 <_panic>
		lsdir(path, prefix);
  800217:	83 ec 08             	sub    $0x8,%esp
  80021a:	ff 75 0c             	pushl  0xc(%ebp)
  80021d:	53                   	push   %ebx
  80021e:	e8 d3 fe ff ff       	call   8000f6 <lsdir>
  800223:	83 c4 10             	add    $0x10,%esp
  800226:	eb d4                	jmp    8001fc <ls+0x4c>

00800228 <usage>:

void
usage(void)
{
  800228:	f3 0f 1e fb          	endbr32 
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	83 ec 14             	sub    $0x14,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800232:	68 ad 28 80 00       	push   $0x8028ad
  800237:	e8 b5 18 00 00       	call   801af1 <printf>
	exit();
  80023c:	e8 e3 00 00 00       	call   800324 <exit>
}
  800241:	83 c4 10             	add    $0x10,%esp
  800244:	c9                   	leave  
  800245:	c3                   	ret    

00800246 <umain>:

void
umain(int argc, char **argv)
{
  800246:	f3 0f 1e fb          	endbr32 
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	56                   	push   %esi
  80024e:	53                   	push   %ebx
  80024f:	83 ec 14             	sub    $0x14,%esp
  800252:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800255:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800258:	50                   	push   %eax
  800259:	56                   	push   %esi
  80025a:	8d 45 08             	lea    0x8(%ebp),%eax
  80025d:	50                   	push   %eax
  80025e:	e8 d0 0d 00 00       	call   801033 <argstart>
	while ((i = argnext(&args)) >= 0)
  800263:	83 c4 10             	add    $0x10,%esp
  800266:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  800269:	eb 08                	jmp    800273 <umain+0x2d>
		switch (i) {
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  80026b:	83 04 85 20 40 80 00 	addl   $0x1,0x804020(,%eax,4)
  800272:	01 
	while ((i = argnext(&args)) >= 0)
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	53                   	push   %ebx
  800277:	e8 eb 0d 00 00       	call   801067 <argnext>
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	85 c0                	test   %eax,%eax
  800281:	78 16                	js     800299 <umain+0x53>
		switch (i) {
  800283:	89 c2                	mov    %eax,%edx
  800285:	83 e2 f7             	and    $0xfffffff7,%edx
  800288:	83 fa 64             	cmp    $0x64,%edx
  80028b:	74 de                	je     80026b <umain+0x25>
  80028d:	83 f8 46             	cmp    $0x46,%eax
  800290:	74 d9                	je     80026b <umain+0x25>
			break;
		default:
			usage();
  800292:	e8 91 ff ff ff       	call   800228 <usage>
  800297:	eb da                	jmp    800273 <umain+0x2d>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  800299:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  80029e:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8002a2:	75 2a                	jne    8002ce <umain+0x88>
		ls("/", "");
  8002a4:	83 ec 08             	sub    $0x8,%esp
  8002a7:	68 c8 28 80 00       	push   $0x8028c8
  8002ac:	68 60 28 80 00       	push   $0x802860
  8002b1:	e8 fa fe ff ff       	call   8001b0 <ls>
  8002b6:	83 c4 10             	add    $0x10,%esp
  8002b9:	eb 18                	jmp    8002d3 <umain+0x8d>
			ls(argv[i], argv[i]);
  8002bb:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8002be:	83 ec 08             	sub    $0x8,%esp
  8002c1:	50                   	push   %eax
  8002c2:	50                   	push   %eax
  8002c3:	e8 e8 fe ff ff       	call   8001b0 <ls>
		for (i = 1; i < argc; i++)
  8002c8:	83 c3 01             	add    $0x1,%ebx
  8002cb:	83 c4 10             	add    $0x10,%esp
  8002ce:	39 5d 08             	cmp    %ebx,0x8(%ebp)
  8002d1:	7f e8                	jg     8002bb <umain+0x75>
	}
}
  8002d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002d6:	5b                   	pop    %ebx
  8002d7:	5e                   	pop    %esi
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    

008002da <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002da:	f3 0f 1e fb          	endbr32 
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	56                   	push   %esi
  8002e2:	53                   	push   %ebx
  8002e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002e6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002e9:	e8 68 0b 00 00       	call   800e56 <sys_getenvid>
  8002ee:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002f3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002f6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002fb:	a3 20 44 80 00       	mov    %eax,0x804420
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800300:	85 db                	test   %ebx,%ebx
  800302:	7e 07                	jle    80030b <libmain+0x31>
		binaryname = argv[0];
  800304:	8b 06                	mov    (%esi),%eax
  800306:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80030b:	83 ec 08             	sub    $0x8,%esp
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	e8 31 ff ff ff       	call   800246 <umain>

	// exit gracefully
	exit();
  800315:	e8 0a 00 00 00       	call   800324 <exit>
}
  80031a:	83 c4 10             	add    $0x10,%esp
  80031d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800320:	5b                   	pop    %ebx
  800321:	5e                   	pop    %esi
  800322:	5d                   	pop    %ebp
  800323:	c3                   	ret    

00800324 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800324:	f3 0f 1e fb          	endbr32 
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  80032e:	e8 53 10 00 00       	call   801386 <close_all>
	sys_env_destroy(0);
  800333:	83 ec 0c             	sub    $0xc,%esp
  800336:	6a 00                	push   $0x0
  800338:	e8 f5 0a 00 00       	call   800e32 <sys_env_destroy>
}
  80033d:	83 c4 10             	add    $0x10,%esp
  800340:	c9                   	leave  
  800341:	c3                   	ret    

00800342 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800342:	f3 0f 1e fb          	endbr32 
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	56                   	push   %esi
  80034a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80034b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80034e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800354:	e8 fd 0a 00 00       	call   800e56 <sys_getenvid>
  800359:	83 ec 0c             	sub    $0xc,%esp
  80035c:	ff 75 0c             	pushl  0xc(%ebp)
  80035f:	ff 75 08             	pushl  0x8(%ebp)
  800362:	56                   	push   %esi
  800363:	50                   	push   %eax
  800364:	68 f8 28 80 00       	push   $0x8028f8
  800369:	e8 bb 00 00 00       	call   800429 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80036e:	83 c4 18             	add    $0x18,%esp
  800371:	53                   	push   %ebx
  800372:	ff 75 10             	pushl  0x10(%ebp)
  800375:	e8 5a 00 00 00       	call   8003d4 <vcprintf>
	cprintf("\n");
  80037a:	c7 04 24 c7 28 80 00 	movl   $0x8028c7,(%esp)
  800381:	e8 a3 00 00 00       	call   800429 <cprintf>
  800386:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800389:	cc                   	int3   
  80038a:	eb fd                	jmp    800389 <_panic+0x47>

0080038c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80038c:	f3 0f 1e fb          	endbr32 
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	53                   	push   %ebx
  800394:	83 ec 04             	sub    $0x4,%esp
  800397:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80039a:	8b 13                	mov    (%ebx),%edx
  80039c:	8d 42 01             	lea    0x1(%edx),%eax
  80039f:	89 03                	mov    %eax,(%ebx)
  8003a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003a8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003ad:	74 09                	je     8003b8 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003af:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003b6:	c9                   	leave  
  8003b7:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003b8:	83 ec 08             	sub    $0x8,%esp
  8003bb:	68 ff 00 00 00       	push   $0xff
  8003c0:	8d 43 08             	lea    0x8(%ebx),%eax
  8003c3:	50                   	push   %eax
  8003c4:	e8 24 0a 00 00       	call   800ded <sys_cputs>
		b->idx = 0;
  8003c9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003cf:	83 c4 10             	add    $0x10,%esp
  8003d2:	eb db                	jmp    8003af <putch+0x23>

008003d4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003d4:	f3 0f 1e fb          	endbr32 
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003e1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003e8:	00 00 00 
	b.cnt = 0;
  8003eb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003f5:	ff 75 0c             	pushl  0xc(%ebp)
  8003f8:	ff 75 08             	pushl  0x8(%ebp)
  8003fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800401:	50                   	push   %eax
  800402:	68 8c 03 80 00       	push   $0x80038c
  800407:	e8 20 01 00 00       	call   80052c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80040c:	83 c4 08             	add    $0x8,%esp
  80040f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800415:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80041b:	50                   	push   %eax
  80041c:	e8 cc 09 00 00       	call   800ded <sys_cputs>

	return b.cnt;
}
  800421:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800427:	c9                   	leave  
  800428:	c3                   	ret    

00800429 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800429:	f3 0f 1e fb          	endbr32 
  80042d:	55                   	push   %ebp
  80042e:	89 e5                	mov    %esp,%ebp
  800430:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800433:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800436:	50                   	push   %eax
  800437:	ff 75 08             	pushl  0x8(%ebp)
  80043a:	e8 95 ff ff ff       	call   8003d4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80043f:	c9                   	leave  
  800440:	c3                   	ret    

00800441 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800441:	55                   	push   %ebp
  800442:	89 e5                	mov    %esp,%ebp
  800444:	57                   	push   %edi
  800445:	56                   	push   %esi
  800446:	53                   	push   %ebx
  800447:	83 ec 1c             	sub    $0x1c,%esp
  80044a:	89 c7                	mov    %eax,%edi
  80044c:	89 d6                	mov    %edx,%esi
  80044e:	8b 45 08             	mov    0x8(%ebp),%eax
  800451:	8b 55 0c             	mov    0xc(%ebp),%edx
  800454:	89 d1                	mov    %edx,%ecx
  800456:	89 c2                	mov    %eax,%edx
  800458:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80045b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80045e:	8b 45 10             	mov    0x10(%ebp),%eax
  800461:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800464:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800467:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80046e:	39 c2                	cmp    %eax,%edx
  800470:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800473:	72 3e                	jb     8004b3 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800475:	83 ec 0c             	sub    $0xc,%esp
  800478:	ff 75 18             	pushl  0x18(%ebp)
  80047b:	83 eb 01             	sub    $0x1,%ebx
  80047e:	53                   	push   %ebx
  80047f:	50                   	push   %eax
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	ff 75 e4             	pushl  -0x1c(%ebp)
  800486:	ff 75 e0             	pushl  -0x20(%ebp)
  800489:	ff 75 dc             	pushl  -0x24(%ebp)
  80048c:	ff 75 d8             	pushl  -0x28(%ebp)
  80048f:	e8 6c 21 00 00       	call   802600 <__udivdi3>
  800494:	83 c4 18             	add    $0x18,%esp
  800497:	52                   	push   %edx
  800498:	50                   	push   %eax
  800499:	89 f2                	mov    %esi,%edx
  80049b:	89 f8                	mov    %edi,%eax
  80049d:	e8 9f ff ff ff       	call   800441 <printnum>
  8004a2:	83 c4 20             	add    $0x20,%esp
  8004a5:	eb 13                	jmp    8004ba <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	56                   	push   %esi
  8004ab:	ff 75 18             	pushl  0x18(%ebp)
  8004ae:	ff d7                	call   *%edi
  8004b0:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004b3:	83 eb 01             	sub    $0x1,%ebx
  8004b6:	85 db                	test   %ebx,%ebx
  8004b8:	7f ed                	jg     8004a7 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	56                   	push   %esi
  8004be:	83 ec 04             	sub    $0x4,%esp
  8004c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c7:	ff 75 dc             	pushl  -0x24(%ebp)
  8004ca:	ff 75 d8             	pushl  -0x28(%ebp)
  8004cd:	e8 3e 22 00 00       	call   802710 <__umoddi3>
  8004d2:	83 c4 14             	add    $0x14,%esp
  8004d5:	0f be 80 1b 29 80 00 	movsbl 0x80291b(%eax),%eax
  8004dc:	50                   	push   %eax
  8004dd:	ff d7                	call   *%edi
}
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004e5:	5b                   	pop    %ebx
  8004e6:	5e                   	pop    %esi
  8004e7:	5f                   	pop    %edi
  8004e8:	5d                   	pop    %ebp
  8004e9:	c3                   	ret    

008004ea <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ea:	f3 0f 1e fb          	endbr32 
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  8004f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f8:	8b 10                	mov    (%eax),%edx
  8004fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8004fd:	73 0a                	jae    800509 <sprintputch+0x1f>
		*b->buf++ = ch;
  8004ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800502:	89 08                	mov    %ecx,(%eax)
  800504:	8b 45 08             	mov    0x8(%ebp),%eax
  800507:	88 02                	mov    %al,(%edx)
}
  800509:	5d                   	pop    %ebp
  80050a:	c3                   	ret    

0080050b <printfmt>:
{
  80050b:	f3 0f 1e fb          	endbr32 
  80050f:	55                   	push   %ebp
  800510:	89 e5                	mov    %esp,%ebp
  800512:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800515:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800518:	50                   	push   %eax
  800519:	ff 75 10             	pushl  0x10(%ebp)
  80051c:	ff 75 0c             	pushl  0xc(%ebp)
  80051f:	ff 75 08             	pushl  0x8(%ebp)
  800522:	e8 05 00 00 00       	call   80052c <vprintfmt>
}
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	c9                   	leave  
  80052b:	c3                   	ret    

0080052c <vprintfmt>:
{
  80052c:	f3 0f 1e fb          	endbr32 
  800530:	55                   	push   %ebp
  800531:	89 e5                	mov    %esp,%ebp
  800533:	57                   	push   %edi
  800534:	56                   	push   %esi
  800535:	53                   	push   %ebx
  800536:	83 ec 3c             	sub    $0x3c,%esp
  800539:	8b 75 08             	mov    0x8(%ebp),%esi
  80053c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800542:	e9 8e 03 00 00       	jmp    8008d5 <vprintfmt+0x3a9>
		padc = ' ';
  800547:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80054b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800552:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800559:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800560:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800565:	8d 47 01             	lea    0x1(%edi),%eax
  800568:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80056b:	0f b6 17             	movzbl (%edi),%edx
  80056e:	8d 42 dd             	lea    -0x23(%edx),%eax
  800571:	3c 55                	cmp    $0x55,%al
  800573:	0f 87 df 03 00 00    	ja     800958 <vprintfmt+0x42c>
  800579:	0f b6 c0             	movzbl %al,%eax
  80057c:	3e ff 24 85 60 2a 80 	notrack jmp *0x802a60(,%eax,4)
  800583:	00 
  800584:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800587:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80058b:	eb d8                	jmp    800565 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800590:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800594:	eb cf                	jmp    800565 <vprintfmt+0x39>
  800596:	0f b6 d2             	movzbl %dl,%edx
  800599:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80059c:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8005a4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005a7:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005ab:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005ae:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005b1:	83 f9 09             	cmp    $0x9,%ecx
  8005b4:	77 55                	ja     80060b <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005b6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8005b9:	eb e9                	jmp    8005a4 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8b 00                	mov    (%eax),%eax
  8005c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8d 40 04             	lea    0x4(%eax),%eax
  8005c9:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005cf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d3:	79 90                	jns    800565 <vprintfmt+0x39>
				width = precision, precision = -1;
  8005d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005db:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005e2:	eb 81                	jmp    800565 <vprintfmt+0x39>
  8005e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e7:	85 c0                	test   %eax,%eax
  8005e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ee:	0f 49 d0             	cmovns %eax,%edx
  8005f1:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005f7:	e9 69 ff ff ff       	jmp    800565 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005ff:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800606:	e9 5a ff ff ff       	jmp    800565 <vprintfmt+0x39>
  80060b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80060e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800611:	eb bc                	jmp    8005cf <vprintfmt+0xa3>
			lflag++;
  800613:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800616:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800619:	e9 47 ff ff ff       	jmp    800565 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80061e:	8b 45 14             	mov    0x14(%ebp),%eax
  800621:	8d 78 04             	lea    0x4(%eax),%edi
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	53                   	push   %ebx
  800628:	ff 30                	pushl  (%eax)
  80062a:	ff d6                	call   *%esi
			break;
  80062c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80062f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800632:	e9 9b 02 00 00       	jmp    8008d2 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800637:	8b 45 14             	mov    0x14(%ebp),%eax
  80063a:	8d 78 04             	lea    0x4(%eax),%edi
  80063d:	8b 00                	mov    (%eax),%eax
  80063f:	99                   	cltd   
  800640:	31 d0                	xor    %edx,%eax
  800642:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800644:	83 f8 0f             	cmp    $0xf,%eax
  800647:	7f 23                	jg     80066c <vprintfmt+0x140>
  800649:	8b 14 85 c0 2b 80 00 	mov    0x802bc0(,%eax,4),%edx
  800650:	85 d2                	test   %edx,%edx
  800652:	74 18                	je     80066c <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800654:	52                   	push   %edx
  800655:	68 c9 2c 80 00       	push   $0x802cc9
  80065a:	53                   	push   %ebx
  80065b:	56                   	push   %esi
  80065c:	e8 aa fe ff ff       	call   80050b <printfmt>
  800661:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800664:	89 7d 14             	mov    %edi,0x14(%ebp)
  800667:	e9 66 02 00 00       	jmp    8008d2 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80066c:	50                   	push   %eax
  80066d:	68 33 29 80 00       	push   $0x802933
  800672:	53                   	push   %ebx
  800673:	56                   	push   %esi
  800674:	e8 92 fe ff ff       	call   80050b <printfmt>
  800679:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80067c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80067f:	e9 4e 02 00 00       	jmp    8008d2 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	83 c0 04             	add    $0x4,%eax
  80068a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800692:	85 d2                	test   %edx,%edx
  800694:	b8 2c 29 80 00       	mov    $0x80292c,%eax
  800699:	0f 45 c2             	cmovne %edx,%eax
  80069c:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80069f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006a3:	7e 06                	jle    8006ab <vprintfmt+0x17f>
  8006a5:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006a9:	75 0d                	jne    8006b8 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ab:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006ae:	89 c7                	mov    %eax,%edi
  8006b0:	03 45 e0             	add    -0x20(%ebp),%eax
  8006b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b6:	eb 55                	jmp    80070d <vprintfmt+0x1e1>
  8006b8:	83 ec 08             	sub    $0x8,%esp
  8006bb:	ff 75 d8             	pushl  -0x28(%ebp)
  8006be:	ff 75 cc             	pushl  -0x34(%ebp)
  8006c1:	e8 46 03 00 00       	call   800a0c <strnlen>
  8006c6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006c9:	29 c2                	sub    %eax,%edx
  8006cb:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006d3:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006da:	85 ff                	test   %edi,%edi
  8006dc:	7e 11                	jle    8006ef <vprintfmt+0x1c3>
					putch(padc, putdat);
  8006de:	83 ec 08             	sub    $0x8,%esp
  8006e1:	53                   	push   %ebx
  8006e2:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e7:	83 ef 01             	sub    $0x1,%edi
  8006ea:	83 c4 10             	add    $0x10,%esp
  8006ed:	eb eb                	jmp    8006da <vprintfmt+0x1ae>
  8006ef:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006f2:	85 d2                	test   %edx,%edx
  8006f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f9:	0f 49 c2             	cmovns %edx,%eax
  8006fc:	29 c2                	sub    %eax,%edx
  8006fe:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800701:	eb a8                	jmp    8006ab <vprintfmt+0x17f>
					putch(ch, putdat);
  800703:	83 ec 08             	sub    $0x8,%esp
  800706:	53                   	push   %ebx
  800707:	52                   	push   %edx
  800708:	ff d6                	call   *%esi
  80070a:	83 c4 10             	add    $0x10,%esp
  80070d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800710:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800712:	83 c7 01             	add    $0x1,%edi
  800715:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800719:	0f be d0             	movsbl %al,%edx
  80071c:	85 d2                	test   %edx,%edx
  80071e:	74 4b                	je     80076b <vprintfmt+0x23f>
  800720:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800724:	78 06                	js     80072c <vprintfmt+0x200>
  800726:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80072a:	78 1e                	js     80074a <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  80072c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800730:	74 d1                	je     800703 <vprintfmt+0x1d7>
  800732:	0f be c0             	movsbl %al,%eax
  800735:	83 e8 20             	sub    $0x20,%eax
  800738:	83 f8 5e             	cmp    $0x5e,%eax
  80073b:	76 c6                	jbe    800703 <vprintfmt+0x1d7>
					putch('?', putdat);
  80073d:	83 ec 08             	sub    $0x8,%esp
  800740:	53                   	push   %ebx
  800741:	6a 3f                	push   $0x3f
  800743:	ff d6                	call   *%esi
  800745:	83 c4 10             	add    $0x10,%esp
  800748:	eb c3                	jmp    80070d <vprintfmt+0x1e1>
  80074a:	89 cf                	mov    %ecx,%edi
  80074c:	eb 0e                	jmp    80075c <vprintfmt+0x230>
				putch(' ', putdat);
  80074e:	83 ec 08             	sub    $0x8,%esp
  800751:	53                   	push   %ebx
  800752:	6a 20                	push   $0x20
  800754:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800756:	83 ef 01             	sub    $0x1,%edi
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	85 ff                	test   %edi,%edi
  80075e:	7f ee                	jg     80074e <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800760:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800763:	89 45 14             	mov    %eax,0x14(%ebp)
  800766:	e9 67 01 00 00       	jmp    8008d2 <vprintfmt+0x3a6>
  80076b:	89 cf                	mov    %ecx,%edi
  80076d:	eb ed                	jmp    80075c <vprintfmt+0x230>
	if (lflag >= 2)
  80076f:	83 f9 01             	cmp    $0x1,%ecx
  800772:	7f 1b                	jg     80078f <vprintfmt+0x263>
	else if (lflag)
  800774:	85 c9                	test   %ecx,%ecx
  800776:	74 63                	je     8007db <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800778:	8b 45 14             	mov    0x14(%ebp),%eax
  80077b:	8b 00                	mov    (%eax),%eax
  80077d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800780:	99                   	cltd   
  800781:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800784:	8b 45 14             	mov    0x14(%ebp),%eax
  800787:	8d 40 04             	lea    0x4(%eax),%eax
  80078a:	89 45 14             	mov    %eax,0x14(%ebp)
  80078d:	eb 17                	jmp    8007a6 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	8b 50 04             	mov    0x4(%eax),%edx
  800795:	8b 00                	mov    (%eax),%eax
  800797:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80079a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80079d:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a0:	8d 40 08             	lea    0x8(%eax),%eax
  8007a3:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007ac:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007b1:	85 c9                	test   %ecx,%ecx
  8007b3:	0f 89 ff 00 00 00    	jns    8008b8 <vprintfmt+0x38c>
				putch('-', putdat);
  8007b9:	83 ec 08             	sub    $0x8,%esp
  8007bc:	53                   	push   %ebx
  8007bd:	6a 2d                	push   $0x2d
  8007bf:	ff d6                	call   *%esi
				num = -(long long) num;
  8007c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007c4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007c7:	f7 da                	neg    %edx
  8007c9:	83 d1 00             	adc    $0x0,%ecx
  8007cc:	f7 d9                	neg    %ecx
  8007ce:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007d1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007d6:	e9 dd 00 00 00       	jmp    8008b8 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	8b 00                	mov    (%eax),%eax
  8007e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e3:	99                   	cltd   
  8007e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ea:	8d 40 04             	lea    0x4(%eax),%eax
  8007ed:	89 45 14             	mov    %eax,0x14(%ebp)
  8007f0:	eb b4                	jmp    8007a6 <vprintfmt+0x27a>
	if (lflag >= 2)
  8007f2:	83 f9 01             	cmp    $0x1,%ecx
  8007f5:	7f 1e                	jg     800815 <vprintfmt+0x2e9>
	else if (lflag)
  8007f7:	85 c9                	test   %ecx,%ecx
  8007f9:	74 32                	je     80082d <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8007fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fe:	8b 10                	mov    (%eax),%edx
  800800:	b9 00 00 00 00       	mov    $0x0,%ecx
  800805:	8d 40 04             	lea    0x4(%eax),%eax
  800808:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80080b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800810:	e9 a3 00 00 00       	jmp    8008b8 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800815:	8b 45 14             	mov    0x14(%ebp),%eax
  800818:	8b 10                	mov    (%eax),%edx
  80081a:	8b 48 04             	mov    0x4(%eax),%ecx
  80081d:	8d 40 08             	lea    0x8(%eax),%eax
  800820:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800823:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800828:	e9 8b 00 00 00       	jmp    8008b8 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80082d:	8b 45 14             	mov    0x14(%ebp),%eax
  800830:	8b 10                	mov    (%eax),%edx
  800832:	b9 00 00 00 00       	mov    $0x0,%ecx
  800837:	8d 40 04             	lea    0x4(%eax),%eax
  80083a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80083d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800842:	eb 74                	jmp    8008b8 <vprintfmt+0x38c>
	if (lflag >= 2)
  800844:	83 f9 01             	cmp    $0x1,%ecx
  800847:	7f 1b                	jg     800864 <vprintfmt+0x338>
	else if (lflag)
  800849:	85 c9                	test   %ecx,%ecx
  80084b:	74 2c                	je     800879 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  80084d:	8b 45 14             	mov    0x14(%ebp),%eax
  800850:	8b 10                	mov    (%eax),%edx
  800852:	b9 00 00 00 00       	mov    $0x0,%ecx
  800857:	8d 40 04             	lea    0x4(%eax),%eax
  80085a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80085d:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800862:	eb 54                	jmp    8008b8 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800864:	8b 45 14             	mov    0x14(%ebp),%eax
  800867:	8b 10                	mov    (%eax),%edx
  800869:	8b 48 04             	mov    0x4(%eax),%ecx
  80086c:	8d 40 08             	lea    0x8(%eax),%eax
  80086f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800872:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800877:	eb 3f                	jmp    8008b8 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800879:	8b 45 14             	mov    0x14(%ebp),%eax
  80087c:	8b 10                	mov    (%eax),%edx
  80087e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800883:	8d 40 04             	lea    0x4(%eax),%eax
  800886:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800889:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  80088e:	eb 28                	jmp    8008b8 <vprintfmt+0x38c>
			putch('0', putdat);
  800890:	83 ec 08             	sub    $0x8,%esp
  800893:	53                   	push   %ebx
  800894:	6a 30                	push   $0x30
  800896:	ff d6                	call   *%esi
			putch('x', putdat);
  800898:	83 c4 08             	add    $0x8,%esp
  80089b:	53                   	push   %ebx
  80089c:	6a 78                	push   $0x78
  80089e:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a3:	8b 10                	mov    (%eax),%edx
  8008a5:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008aa:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008ad:	8d 40 04             	lea    0x4(%eax),%eax
  8008b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008b3:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008b8:	83 ec 0c             	sub    $0xc,%esp
  8008bb:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008bf:	57                   	push   %edi
  8008c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8008c3:	50                   	push   %eax
  8008c4:	51                   	push   %ecx
  8008c5:	52                   	push   %edx
  8008c6:	89 da                	mov    %ebx,%edx
  8008c8:	89 f0                	mov    %esi,%eax
  8008ca:	e8 72 fb ff ff       	call   800441 <printnum>
			break;
  8008cf:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  8008d5:	83 c7 01             	add    $0x1,%edi
  8008d8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008dc:	83 f8 25             	cmp    $0x25,%eax
  8008df:	0f 84 62 fc ff ff    	je     800547 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  8008e5:	85 c0                	test   %eax,%eax
  8008e7:	0f 84 8b 00 00 00    	je     800978 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  8008ed:	83 ec 08             	sub    $0x8,%esp
  8008f0:	53                   	push   %ebx
  8008f1:	50                   	push   %eax
  8008f2:	ff d6                	call   *%esi
  8008f4:	83 c4 10             	add    $0x10,%esp
  8008f7:	eb dc                	jmp    8008d5 <vprintfmt+0x3a9>
	if (lflag >= 2)
  8008f9:	83 f9 01             	cmp    $0x1,%ecx
  8008fc:	7f 1b                	jg     800919 <vprintfmt+0x3ed>
	else if (lflag)
  8008fe:	85 c9                	test   %ecx,%ecx
  800900:	74 2c                	je     80092e <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800902:	8b 45 14             	mov    0x14(%ebp),%eax
  800905:	8b 10                	mov    (%eax),%edx
  800907:	b9 00 00 00 00       	mov    $0x0,%ecx
  80090c:	8d 40 04             	lea    0x4(%eax),%eax
  80090f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800912:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800917:	eb 9f                	jmp    8008b8 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800919:	8b 45 14             	mov    0x14(%ebp),%eax
  80091c:	8b 10                	mov    (%eax),%edx
  80091e:	8b 48 04             	mov    0x4(%eax),%ecx
  800921:	8d 40 08             	lea    0x8(%eax),%eax
  800924:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800927:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80092c:	eb 8a                	jmp    8008b8 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80092e:	8b 45 14             	mov    0x14(%ebp),%eax
  800931:	8b 10                	mov    (%eax),%edx
  800933:	b9 00 00 00 00       	mov    $0x0,%ecx
  800938:	8d 40 04             	lea    0x4(%eax),%eax
  80093b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80093e:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800943:	e9 70 ff ff ff       	jmp    8008b8 <vprintfmt+0x38c>
			putch(ch, putdat);
  800948:	83 ec 08             	sub    $0x8,%esp
  80094b:	53                   	push   %ebx
  80094c:	6a 25                	push   $0x25
  80094e:	ff d6                	call   *%esi
			break;
  800950:	83 c4 10             	add    $0x10,%esp
  800953:	e9 7a ff ff ff       	jmp    8008d2 <vprintfmt+0x3a6>
			putch('%', putdat);
  800958:	83 ec 08             	sub    $0x8,%esp
  80095b:	53                   	push   %ebx
  80095c:	6a 25                	push   $0x25
  80095e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800960:	83 c4 10             	add    $0x10,%esp
  800963:	89 f8                	mov    %edi,%eax
  800965:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800969:	74 05                	je     800970 <vprintfmt+0x444>
  80096b:	83 e8 01             	sub    $0x1,%eax
  80096e:	eb f5                	jmp    800965 <vprintfmt+0x439>
  800970:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800973:	e9 5a ff ff ff       	jmp    8008d2 <vprintfmt+0x3a6>
}
  800978:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5f                   	pop    %edi
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800980:	f3 0f 1e fb          	endbr32 
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	83 ec 18             	sub    $0x18,%esp
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800990:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800993:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800997:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80099a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009a1:	85 c0                	test   %eax,%eax
  8009a3:	74 26                	je     8009cb <vsnprintf+0x4b>
  8009a5:	85 d2                	test   %edx,%edx
  8009a7:	7e 22                	jle    8009cb <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009a9:	ff 75 14             	pushl  0x14(%ebp)
  8009ac:	ff 75 10             	pushl  0x10(%ebp)
  8009af:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009b2:	50                   	push   %eax
  8009b3:	68 ea 04 80 00       	push   $0x8004ea
  8009b8:	e8 6f fb ff ff       	call   80052c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009c0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009c6:	83 c4 10             	add    $0x10,%esp
}
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    
		return -E_INVAL;
  8009cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009d0:	eb f7                	jmp    8009c9 <vsnprintf+0x49>

008009d2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009d2:	f3 0f 1e fb          	endbr32 
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  8009dc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009df:	50                   	push   %eax
  8009e0:	ff 75 10             	pushl  0x10(%ebp)
  8009e3:	ff 75 0c             	pushl  0xc(%ebp)
  8009e6:	ff 75 08             	pushl  0x8(%ebp)
  8009e9:	e8 92 ff ff ff       	call   800980 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009ee:	c9                   	leave  
  8009ef:	c3                   	ret    

008009f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009f0:	f3 0f 1e fb          	endbr32 
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ff:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a03:	74 05                	je     800a0a <strlen+0x1a>
		n++;
  800a05:	83 c0 01             	add    $0x1,%eax
  800a08:	eb f5                	jmp    8009ff <strlen+0xf>
	return n;
}
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a0c:	f3 0f 1e fb          	endbr32 
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a16:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a19:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1e:	39 d0                	cmp    %edx,%eax
  800a20:	74 0d                	je     800a2f <strnlen+0x23>
  800a22:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a26:	74 05                	je     800a2d <strnlen+0x21>
		n++;
  800a28:	83 c0 01             	add    $0x1,%eax
  800a2b:	eb f1                	jmp    800a1e <strnlen+0x12>
  800a2d:	89 c2                	mov    %eax,%edx
	return n;
}
  800a2f:	89 d0                	mov    %edx,%eax
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a33:	f3 0f 1e fb          	endbr32 
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	53                   	push   %ebx
  800a3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a41:	b8 00 00 00 00       	mov    $0x0,%eax
  800a46:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a4a:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a4d:	83 c0 01             	add    $0x1,%eax
  800a50:	84 d2                	test   %dl,%dl
  800a52:	75 f2                	jne    800a46 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a54:	89 c8                	mov    %ecx,%eax
  800a56:	5b                   	pop    %ebx
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a59:	f3 0f 1e fb          	endbr32 
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	53                   	push   %ebx
  800a61:	83 ec 10             	sub    $0x10,%esp
  800a64:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a67:	53                   	push   %ebx
  800a68:	e8 83 ff ff ff       	call   8009f0 <strlen>
  800a6d:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a70:	ff 75 0c             	pushl  0xc(%ebp)
  800a73:	01 d8                	add    %ebx,%eax
  800a75:	50                   	push   %eax
  800a76:	e8 b8 ff ff ff       	call   800a33 <strcpy>
	return dst;
}
  800a7b:	89 d8                	mov    %ebx,%eax
  800a7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a80:	c9                   	leave  
  800a81:	c3                   	ret    

00800a82 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a82:	f3 0f 1e fb          	endbr32 
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	56                   	push   %esi
  800a8a:	53                   	push   %ebx
  800a8b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a91:	89 f3                	mov    %esi,%ebx
  800a93:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a96:	89 f0                	mov    %esi,%eax
  800a98:	39 d8                	cmp    %ebx,%eax
  800a9a:	74 11                	je     800aad <strncpy+0x2b>
		*dst++ = *src;
  800a9c:	83 c0 01             	add    $0x1,%eax
  800a9f:	0f b6 0a             	movzbl (%edx),%ecx
  800aa2:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aa5:	80 f9 01             	cmp    $0x1,%cl
  800aa8:	83 da ff             	sbb    $0xffffffff,%edx
  800aab:	eb eb                	jmp    800a98 <strncpy+0x16>
	}
	return ret;
}
  800aad:	89 f0                	mov    %esi,%eax
  800aaf:	5b                   	pop    %ebx
  800ab0:	5e                   	pop    %esi
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ab3:	f3 0f 1e fb          	endbr32 
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	56                   	push   %esi
  800abb:	53                   	push   %ebx
  800abc:	8b 75 08             	mov    0x8(%ebp),%esi
  800abf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac2:	8b 55 10             	mov    0x10(%ebp),%edx
  800ac5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ac7:	85 d2                	test   %edx,%edx
  800ac9:	74 21                	je     800aec <strlcpy+0x39>
  800acb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800acf:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800ad1:	39 c2                	cmp    %eax,%edx
  800ad3:	74 14                	je     800ae9 <strlcpy+0x36>
  800ad5:	0f b6 19             	movzbl (%ecx),%ebx
  800ad8:	84 db                	test   %bl,%bl
  800ada:	74 0b                	je     800ae7 <strlcpy+0x34>
			*dst++ = *src++;
  800adc:	83 c1 01             	add    $0x1,%ecx
  800adf:	83 c2 01             	add    $0x1,%edx
  800ae2:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ae5:	eb ea                	jmp    800ad1 <strlcpy+0x1e>
  800ae7:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800ae9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800aec:	29 f0                	sub    %esi,%eax
}
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800af2:	f3 0f 1e fb          	endbr32 
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800afc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aff:	0f b6 01             	movzbl (%ecx),%eax
  800b02:	84 c0                	test   %al,%al
  800b04:	74 0c                	je     800b12 <strcmp+0x20>
  800b06:	3a 02                	cmp    (%edx),%al
  800b08:	75 08                	jne    800b12 <strcmp+0x20>
		p++, q++;
  800b0a:	83 c1 01             	add    $0x1,%ecx
  800b0d:	83 c2 01             	add    $0x1,%edx
  800b10:	eb ed                	jmp    800aff <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b12:	0f b6 c0             	movzbl %al,%eax
  800b15:	0f b6 12             	movzbl (%edx),%edx
  800b18:	29 d0                	sub    %edx,%eax
}
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b1c:	f3 0f 1e fb          	endbr32 
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	53                   	push   %ebx
  800b24:	8b 45 08             	mov    0x8(%ebp),%eax
  800b27:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2a:	89 c3                	mov    %eax,%ebx
  800b2c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b2f:	eb 06                	jmp    800b37 <strncmp+0x1b>
		n--, p++, q++;
  800b31:	83 c0 01             	add    $0x1,%eax
  800b34:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b37:	39 d8                	cmp    %ebx,%eax
  800b39:	74 16                	je     800b51 <strncmp+0x35>
  800b3b:	0f b6 08             	movzbl (%eax),%ecx
  800b3e:	84 c9                	test   %cl,%cl
  800b40:	74 04                	je     800b46 <strncmp+0x2a>
  800b42:	3a 0a                	cmp    (%edx),%cl
  800b44:	74 eb                	je     800b31 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b46:	0f b6 00             	movzbl (%eax),%eax
  800b49:	0f b6 12             	movzbl (%edx),%edx
  800b4c:	29 d0                	sub    %edx,%eax
}
  800b4e:	5b                   	pop    %ebx
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    
		return 0;
  800b51:	b8 00 00 00 00       	mov    $0x0,%eax
  800b56:	eb f6                	jmp    800b4e <strncmp+0x32>

00800b58 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b58:	f3 0f 1e fb          	endbr32 
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b62:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b66:	0f b6 10             	movzbl (%eax),%edx
  800b69:	84 d2                	test   %dl,%dl
  800b6b:	74 09                	je     800b76 <strchr+0x1e>
		if (*s == c)
  800b6d:	38 ca                	cmp    %cl,%dl
  800b6f:	74 0a                	je     800b7b <strchr+0x23>
	for (; *s; s++)
  800b71:	83 c0 01             	add    $0x1,%eax
  800b74:	eb f0                	jmp    800b66 <strchr+0xe>
			return (char *) s;
	return 0;
  800b76:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800b7d:	f3 0f 1e fb          	endbr32 
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800b87:	6a 78                	push   $0x78
  800b89:	ff 75 08             	pushl  0x8(%ebp)
  800b8c:	e8 c7 ff ff ff       	call   800b58 <strchr>
  800b91:	83 c4 10             	add    $0x10,%esp
  800b94:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  800b97:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800b9c:	eb 0d                	jmp    800bab <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800b9e:	c1 e0 04             	shl    $0x4,%eax
  800ba1:	0f be d2             	movsbl %dl,%edx
  800ba4:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800ba8:	83 c1 01             	add    $0x1,%ecx
  800bab:	0f b6 11             	movzbl (%ecx),%edx
  800bae:	84 d2                	test   %dl,%dl
  800bb0:	74 11                	je     800bc3 <atox+0x46>
		if (*p>='a'){
  800bb2:	80 fa 60             	cmp    $0x60,%dl
  800bb5:	7e e7                	jle    800b9e <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800bb7:	c1 e0 04             	shl    $0x4,%eax
  800bba:	0f be d2             	movsbl %dl,%edx
  800bbd:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800bc1:	eb e5                	jmp    800ba8 <atox+0x2b>
	}

	return v;

}
  800bc3:	c9                   	leave  
  800bc4:	c3                   	ret    

00800bc5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bc5:	f3 0f 1e fb          	endbr32 
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bd3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bd6:	38 ca                	cmp    %cl,%dl
  800bd8:	74 09                	je     800be3 <strfind+0x1e>
  800bda:	84 d2                	test   %dl,%dl
  800bdc:	74 05                	je     800be3 <strfind+0x1e>
	for (; *s; s++)
  800bde:	83 c0 01             	add    $0x1,%eax
  800be1:	eb f0                	jmp    800bd3 <strfind+0xe>
			break;
	return (char *) s;
}
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800be5:	f3 0f 1e fb          	endbr32 
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
  800bef:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bf2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bf5:	85 c9                	test   %ecx,%ecx
  800bf7:	74 31                	je     800c2a <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bf9:	89 f8                	mov    %edi,%eax
  800bfb:	09 c8                	or     %ecx,%eax
  800bfd:	a8 03                	test   $0x3,%al
  800bff:	75 23                	jne    800c24 <memset+0x3f>
		c &= 0xFF;
  800c01:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c05:	89 d3                	mov    %edx,%ebx
  800c07:	c1 e3 08             	shl    $0x8,%ebx
  800c0a:	89 d0                	mov    %edx,%eax
  800c0c:	c1 e0 18             	shl    $0x18,%eax
  800c0f:	89 d6                	mov    %edx,%esi
  800c11:	c1 e6 10             	shl    $0x10,%esi
  800c14:	09 f0                	or     %esi,%eax
  800c16:	09 c2                	or     %eax,%edx
  800c18:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c1a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c1d:	89 d0                	mov    %edx,%eax
  800c1f:	fc                   	cld    
  800c20:	f3 ab                	rep stos %eax,%es:(%edi)
  800c22:	eb 06                	jmp    800c2a <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c27:	fc                   	cld    
  800c28:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c2a:	89 f8                	mov    %edi,%eax
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c31:	f3 0f 1e fb          	endbr32 
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c43:	39 c6                	cmp    %eax,%esi
  800c45:	73 32                	jae    800c79 <memmove+0x48>
  800c47:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c4a:	39 c2                	cmp    %eax,%edx
  800c4c:	76 2b                	jbe    800c79 <memmove+0x48>
		s += n;
		d += n;
  800c4e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c51:	89 fe                	mov    %edi,%esi
  800c53:	09 ce                	or     %ecx,%esi
  800c55:	09 d6                	or     %edx,%esi
  800c57:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c5d:	75 0e                	jne    800c6d <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c5f:	83 ef 04             	sub    $0x4,%edi
  800c62:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c65:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c68:	fd                   	std    
  800c69:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c6b:	eb 09                	jmp    800c76 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c6d:	83 ef 01             	sub    $0x1,%edi
  800c70:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c73:	fd                   	std    
  800c74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c76:	fc                   	cld    
  800c77:	eb 1a                	jmp    800c93 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c79:	89 c2                	mov    %eax,%edx
  800c7b:	09 ca                	or     %ecx,%edx
  800c7d:	09 f2                	or     %esi,%edx
  800c7f:	f6 c2 03             	test   $0x3,%dl
  800c82:	75 0a                	jne    800c8e <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c84:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c87:	89 c7                	mov    %eax,%edi
  800c89:	fc                   	cld    
  800c8a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c8c:	eb 05                	jmp    800c93 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c8e:	89 c7                	mov    %eax,%edi
  800c90:	fc                   	cld    
  800c91:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c97:	f3 0f 1e fb          	endbr32 
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ca1:	ff 75 10             	pushl  0x10(%ebp)
  800ca4:	ff 75 0c             	pushl  0xc(%ebp)
  800ca7:	ff 75 08             	pushl  0x8(%ebp)
  800caa:	e8 82 ff ff ff       	call   800c31 <memmove>
}
  800caf:	c9                   	leave  
  800cb0:	c3                   	ret    

00800cb1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cb1:	f3 0f 1e fb          	endbr32 
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cc0:	89 c6                	mov    %eax,%esi
  800cc2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc5:	39 f0                	cmp    %esi,%eax
  800cc7:	74 1c                	je     800ce5 <memcmp+0x34>
		if (*s1 != *s2)
  800cc9:	0f b6 08             	movzbl (%eax),%ecx
  800ccc:	0f b6 1a             	movzbl (%edx),%ebx
  800ccf:	38 d9                	cmp    %bl,%cl
  800cd1:	75 08                	jne    800cdb <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cd3:	83 c0 01             	add    $0x1,%eax
  800cd6:	83 c2 01             	add    $0x1,%edx
  800cd9:	eb ea                	jmp    800cc5 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800cdb:	0f b6 c1             	movzbl %cl,%eax
  800cde:	0f b6 db             	movzbl %bl,%ebx
  800ce1:	29 d8                	sub    %ebx,%eax
  800ce3:	eb 05                	jmp    800cea <memcmp+0x39>
	}

	return 0;
  800ce5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cee:	f3 0f 1e fb          	endbr32 
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cfb:	89 c2                	mov    %eax,%edx
  800cfd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d00:	39 d0                	cmp    %edx,%eax
  800d02:	73 09                	jae    800d0d <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d04:	38 08                	cmp    %cl,(%eax)
  800d06:	74 05                	je     800d0d <memfind+0x1f>
	for (; s < ends; s++)
  800d08:	83 c0 01             	add    $0x1,%eax
  800d0b:	eb f3                	jmp    800d00 <memfind+0x12>
			break;
	return (void *) s;
}
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d0f:	f3 0f 1e fb          	endbr32 
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d1f:	eb 03                	jmp    800d24 <strtol+0x15>
		s++;
  800d21:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d24:	0f b6 01             	movzbl (%ecx),%eax
  800d27:	3c 20                	cmp    $0x20,%al
  800d29:	74 f6                	je     800d21 <strtol+0x12>
  800d2b:	3c 09                	cmp    $0x9,%al
  800d2d:	74 f2                	je     800d21 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d2f:	3c 2b                	cmp    $0x2b,%al
  800d31:	74 2a                	je     800d5d <strtol+0x4e>
	int neg = 0;
  800d33:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d38:	3c 2d                	cmp    $0x2d,%al
  800d3a:	74 2b                	je     800d67 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d3c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d42:	75 0f                	jne    800d53 <strtol+0x44>
  800d44:	80 39 30             	cmpb   $0x30,(%ecx)
  800d47:	74 28                	je     800d71 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d49:	85 db                	test   %ebx,%ebx
  800d4b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d50:	0f 44 d8             	cmove  %eax,%ebx
  800d53:	b8 00 00 00 00       	mov    $0x0,%eax
  800d58:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d5b:	eb 46                	jmp    800da3 <strtol+0x94>
		s++;
  800d5d:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d60:	bf 00 00 00 00       	mov    $0x0,%edi
  800d65:	eb d5                	jmp    800d3c <strtol+0x2d>
		s++, neg = 1;
  800d67:	83 c1 01             	add    $0x1,%ecx
  800d6a:	bf 01 00 00 00       	mov    $0x1,%edi
  800d6f:	eb cb                	jmp    800d3c <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d71:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d75:	74 0e                	je     800d85 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d77:	85 db                	test   %ebx,%ebx
  800d79:	75 d8                	jne    800d53 <strtol+0x44>
		s++, base = 8;
  800d7b:	83 c1 01             	add    $0x1,%ecx
  800d7e:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d83:	eb ce                	jmp    800d53 <strtol+0x44>
		s += 2, base = 16;
  800d85:	83 c1 02             	add    $0x2,%ecx
  800d88:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d8d:	eb c4                	jmp    800d53 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d8f:	0f be d2             	movsbl %dl,%edx
  800d92:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d95:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d98:	7d 3a                	jge    800dd4 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d9a:	83 c1 01             	add    $0x1,%ecx
  800d9d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800da1:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800da3:	0f b6 11             	movzbl (%ecx),%edx
  800da6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800da9:	89 f3                	mov    %esi,%ebx
  800dab:	80 fb 09             	cmp    $0x9,%bl
  800dae:	76 df                	jbe    800d8f <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800db0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800db3:	89 f3                	mov    %esi,%ebx
  800db5:	80 fb 19             	cmp    $0x19,%bl
  800db8:	77 08                	ja     800dc2 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800dba:	0f be d2             	movsbl %dl,%edx
  800dbd:	83 ea 57             	sub    $0x57,%edx
  800dc0:	eb d3                	jmp    800d95 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800dc2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dc5:	89 f3                	mov    %esi,%ebx
  800dc7:	80 fb 19             	cmp    $0x19,%bl
  800dca:	77 08                	ja     800dd4 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dcc:	0f be d2             	movsbl %dl,%edx
  800dcf:	83 ea 37             	sub    $0x37,%edx
  800dd2:	eb c1                	jmp    800d95 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dd4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dd8:	74 05                	je     800ddf <strtol+0xd0>
		*endptr = (char *) s;
  800dda:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ddd:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ddf:	89 c2                	mov    %eax,%edx
  800de1:	f7 da                	neg    %edx
  800de3:	85 ff                	test   %edi,%edi
  800de5:	0f 45 c2             	cmovne %edx,%eax
}
  800de8:	5b                   	pop    %ebx
  800de9:	5e                   	pop    %esi
  800dea:	5f                   	pop    %edi
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    

00800ded <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ded:	f3 0f 1e fb          	endbr32 
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	57                   	push   %edi
  800df5:	56                   	push   %esi
  800df6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800df7:	b8 00 00 00 00       	mov    $0x0,%eax
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e02:	89 c3                	mov    %eax,%ebx
  800e04:	89 c7                	mov    %eax,%edi
  800e06:	89 c6                	mov    %eax,%esi
  800e08:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e0a:	5b                   	pop    %ebx
  800e0b:	5e                   	pop    %esi
  800e0c:	5f                   	pop    %edi
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <sys_cgetc>:

int
sys_cgetc(void)
{
  800e0f:	f3 0f 1e fb          	endbr32 
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e19:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e23:	89 d1                	mov    %edx,%ecx
  800e25:	89 d3                	mov    %edx,%ebx
  800e27:	89 d7                	mov    %edx,%edi
  800e29:	89 d6                	mov    %edx,%esi
  800e2b:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    

00800e32 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e32:	f3 0f 1e fb          	endbr32 
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	57                   	push   %edi
  800e3a:	56                   	push   %esi
  800e3b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e41:	8b 55 08             	mov    0x8(%ebp),%edx
  800e44:	b8 03 00 00 00       	mov    $0x3,%eax
  800e49:	89 cb                	mov    %ecx,%ebx
  800e4b:	89 cf                	mov    %ecx,%edi
  800e4d:	89 ce                	mov    %ecx,%esi
  800e4f:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e51:	5b                   	pop    %ebx
  800e52:	5e                   	pop    %esi
  800e53:	5f                   	pop    %edi
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e56:	f3 0f 1e fb          	endbr32 
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	57                   	push   %edi
  800e5e:	56                   	push   %esi
  800e5f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e60:	ba 00 00 00 00       	mov    $0x0,%edx
  800e65:	b8 02 00 00 00       	mov    $0x2,%eax
  800e6a:	89 d1                	mov    %edx,%ecx
  800e6c:	89 d3                	mov    %edx,%ebx
  800e6e:	89 d7                	mov    %edx,%edi
  800e70:	89 d6                	mov    %edx,%esi
  800e72:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5f                   	pop    %edi
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    

00800e79 <sys_yield>:

void
sys_yield(void)
{
  800e79:	f3 0f 1e fb          	endbr32 
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	57                   	push   %edi
  800e81:	56                   	push   %esi
  800e82:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e83:	ba 00 00 00 00       	mov    $0x0,%edx
  800e88:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e8d:	89 d1                	mov    %edx,%ecx
  800e8f:	89 d3                	mov    %edx,%ebx
  800e91:	89 d7                	mov    %edx,%edi
  800e93:	89 d6                	mov    %edx,%esi
  800e95:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5f                   	pop    %edi
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e9c:	f3 0f 1e fb          	endbr32 
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	57                   	push   %edi
  800ea4:	56                   	push   %esi
  800ea5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ea6:	be 00 00 00 00       	mov    $0x0,%esi
  800eab:	8b 55 08             	mov    0x8(%ebp),%edx
  800eae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb1:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb9:	89 f7                	mov    %esi,%edi
  800ebb:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ebd:	5b                   	pop    %ebx
  800ebe:	5e                   	pop    %esi
  800ebf:	5f                   	pop    %edi
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    

00800ec2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ec2:	f3 0f 1e fb          	endbr32 
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ecc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed2:	b8 05 00 00 00       	mov    $0x5,%eax
  800ed7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eda:	8b 7d 14             	mov    0x14(%ebp),%edi
  800edd:	8b 75 18             	mov    0x18(%ebp),%esi
  800ee0:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ee2:	5b                   	pop    %ebx
  800ee3:	5e                   	pop    %esi
  800ee4:	5f                   	pop    %edi
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ee7:	f3 0f 1e fb          	endbr32 
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	57                   	push   %edi
  800eef:	56                   	push   %esi
  800ef0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ef1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efc:	b8 06 00 00 00       	mov    $0x6,%eax
  800f01:	89 df                	mov    %ebx,%edi
  800f03:	89 de                	mov    %ebx,%esi
  800f05:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f07:	5b                   	pop    %ebx
  800f08:	5e                   	pop    %esi
  800f09:	5f                   	pop    %edi
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f0c:	f3 0f 1e fb          	endbr32 
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	57                   	push   %edi
  800f14:	56                   	push   %esi
  800f15:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f21:	b8 08 00 00 00       	mov    $0x8,%eax
  800f26:	89 df                	mov    %ebx,%edi
  800f28:	89 de                	mov    %ebx,%esi
  800f2a:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f2c:	5b                   	pop    %ebx
  800f2d:	5e                   	pop    %esi
  800f2e:	5f                   	pop    %edi
  800f2f:	5d                   	pop    %ebp
  800f30:	c3                   	ret    

00800f31 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f31:	f3 0f 1e fb          	endbr32 
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	57                   	push   %edi
  800f39:	56                   	push   %esi
  800f3a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f40:	8b 55 08             	mov    0x8(%ebp),%edx
  800f43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f46:	b8 09 00 00 00       	mov    $0x9,%eax
  800f4b:	89 df                	mov    %ebx,%edi
  800f4d:	89 de                	mov    %ebx,%esi
  800f4f:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f51:	5b                   	pop    %ebx
  800f52:	5e                   	pop    %esi
  800f53:	5f                   	pop    %edi
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    

00800f56 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f56:	f3 0f 1e fb          	endbr32 
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	57                   	push   %edi
  800f5e:	56                   	push   %esi
  800f5f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f65:	8b 55 08             	mov    0x8(%ebp),%edx
  800f68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f6b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f70:	89 df                	mov    %ebx,%edi
  800f72:	89 de                	mov    %ebx,%esi
  800f74:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f76:	5b                   	pop    %ebx
  800f77:	5e                   	pop    %esi
  800f78:	5f                   	pop    %edi
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    

00800f7b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f7b:	f3 0f 1e fb          	endbr32 
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	57                   	push   %edi
  800f83:	56                   	push   %esi
  800f84:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f85:	8b 55 08             	mov    0x8(%ebp),%edx
  800f88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f90:	be 00 00 00 00       	mov    $0x0,%esi
  800f95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f98:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f9b:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f9d:	5b                   	pop    %ebx
  800f9e:	5e                   	pop    %esi
  800f9f:	5f                   	pop    %edi
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    

00800fa2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fa2:	f3 0f 1e fb          	endbr32 
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	57                   	push   %edi
  800faa:	56                   	push   %esi
  800fab:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fac:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb4:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fb9:	89 cb                	mov    %ecx,%ebx
  800fbb:	89 cf                	mov    %ecx,%edi
  800fbd:	89 ce                	mov    %ecx,%esi
  800fbf:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fc1:	5b                   	pop    %ebx
  800fc2:	5e                   	pop    %esi
  800fc3:	5f                   	pop    %edi
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    

00800fc6 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800fc6:	f3 0f 1e fb          	endbr32 
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd5:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fda:	89 d1                	mov    %edx,%ecx
  800fdc:	89 d3                	mov    %edx,%ebx
  800fde:	89 d7                	mov    %edx,%edi
  800fe0:	89 d6                	mov    %edx,%esi
  800fe2:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800fe4:	5b                   	pop    %ebx
  800fe5:	5e                   	pop    %esi
  800fe6:	5f                   	pop    %edi
  800fe7:	5d                   	pop    %ebp
  800fe8:	c3                   	ret    

00800fe9 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800fe9:	f3 0f 1e fb          	endbr32 
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	57                   	push   %edi
  800ff1:	56                   	push   %esi
  800ff2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ff3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffe:	b8 0f 00 00 00       	mov    $0xf,%eax
  801003:	89 df                	mov    %ebx,%edi
  801005:	89 de                	mov    %ebx,%esi
  801007:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  801009:	5b                   	pop    %ebx
  80100a:	5e                   	pop    %esi
  80100b:	5f                   	pop    %edi
  80100c:	5d                   	pop    %ebp
  80100d:	c3                   	ret    

0080100e <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  80100e:	f3 0f 1e fb          	endbr32 
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	57                   	push   %edi
  801016:	56                   	push   %esi
  801017:	53                   	push   %ebx
	asm volatile("int %1\n"
  801018:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101d:	8b 55 08             	mov    0x8(%ebp),%edx
  801020:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801023:	b8 10 00 00 00       	mov    $0x10,%eax
  801028:	89 df                	mov    %ebx,%edi
  80102a:	89 de                	mov    %ebx,%esi
  80102c:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  80102e:	5b                   	pop    %ebx
  80102f:	5e                   	pop    %esi
  801030:	5f                   	pop    %edi
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801033:	f3 0f 1e fb          	endbr32 
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	8b 55 08             	mov    0x8(%ebp),%edx
  80103d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801040:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801043:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801045:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801048:	83 3a 01             	cmpl   $0x1,(%edx)
  80104b:	7e 09                	jle    801056 <argstart+0x23>
  80104d:	ba c8 28 80 00       	mov    $0x8028c8,%edx
  801052:	85 c9                	test   %ecx,%ecx
  801054:	75 05                	jne    80105b <argstart+0x28>
  801056:	ba 00 00 00 00       	mov    $0x0,%edx
  80105b:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  80105e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801065:	5d                   	pop    %ebp
  801066:	c3                   	ret    

00801067 <argnext>:

int
argnext(struct Argstate *args)
{
  801067:	f3 0f 1e fb          	endbr32 
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	53                   	push   %ebx
  80106f:	83 ec 04             	sub    $0x4,%esp
  801072:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801075:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  80107c:	8b 43 08             	mov    0x8(%ebx),%eax
  80107f:	85 c0                	test   %eax,%eax
  801081:	74 74                	je     8010f7 <argnext+0x90>
		return -1;

	if (!*args->curarg) {
  801083:	80 38 00             	cmpb   $0x0,(%eax)
  801086:	75 48                	jne    8010d0 <argnext+0x69>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801088:	8b 0b                	mov    (%ebx),%ecx
  80108a:	83 39 01             	cmpl   $0x1,(%ecx)
  80108d:	74 5a                	je     8010e9 <argnext+0x82>
		    || args->argv[1][0] != '-'
  80108f:	8b 53 04             	mov    0x4(%ebx),%edx
  801092:	8b 42 04             	mov    0x4(%edx),%eax
  801095:	80 38 2d             	cmpb   $0x2d,(%eax)
  801098:	75 4f                	jne    8010e9 <argnext+0x82>
		    || args->argv[1][1] == '\0')
  80109a:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80109e:	74 49                	je     8010e9 <argnext+0x82>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  8010a0:	83 c0 01             	add    $0x1,%eax
  8010a3:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8010a6:	83 ec 04             	sub    $0x4,%esp
  8010a9:	8b 01                	mov    (%ecx),%eax
  8010ab:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  8010b2:	50                   	push   %eax
  8010b3:	8d 42 08             	lea    0x8(%edx),%eax
  8010b6:	50                   	push   %eax
  8010b7:	83 c2 04             	add    $0x4,%edx
  8010ba:	52                   	push   %edx
  8010bb:	e8 71 fb ff ff       	call   800c31 <memmove>
		(*args->argc)--;
  8010c0:	8b 03                	mov    (%ebx),%eax
  8010c2:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  8010c5:	8b 43 08             	mov    0x8(%ebx),%eax
  8010c8:	83 c4 10             	add    $0x10,%esp
  8010cb:	80 38 2d             	cmpb   $0x2d,(%eax)
  8010ce:	74 13                	je     8010e3 <argnext+0x7c>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  8010d0:	8b 43 08             	mov    0x8(%ebx),%eax
  8010d3:	0f b6 10             	movzbl (%eax),%edx
	args->curarg++;
  8010d6:	83 c0 01             	add    $0x1,%eax
  8010d9:	89 43 08             	mov    %eax,0x8(%ebx)
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  8010dc:	89 d0                	mov    %edx,%eax
  8010de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e1:	c9                   	leave  
  8010e2:	c3                   	ret    
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  8010e3:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8010e7:	75 e7                	jne    8010d0 <argnext+0x69>
	args->curarg = 0;
  8010e9:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  8010f0:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8010f5:	eb e5                	jmp    8010dc <argnext+0x75>
		return -1;
  8010f7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8010fc:	eb de                	jmp    8010dc <argnext+0x75>

008010fe <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  8010fe:	f3 0f 1e fb          	endbr32 
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
  801105:	53                   	push   %ebx
  801106:	83 ec 04             	sub    $0x4,%esp
  801109:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  80110c:	8b 43 08             	mov    0x8(%ebx),%eax
  80110f:	85 c0                	test   %eax,%eax
  801111:	74 12                	je     801125 <argnextvalue+0x27>
		return 0;
	if (*args->curarg) {
  801113:	80 38 00             	cmpb   $0x0,(%eax)
  801116:	74 12                	je     80112a <argnextvalue+0x2c>
		args->argvalue = args->curarg;
  801118:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  80111b:	c7 43 08 c8 28 80 00 	movl   $0x8028c8,0x8(%ebx)
		(*args->argc)--;
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
  801122:	8b 43 0c             	mov    0xc(%ebx),%eax
}
  801125:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801128:	c9                   	leave  
  801129:	c3                   	ret    
	} else if (*args->argc > 1) {
  80112a:	8b 13                	mov    (%ebx),%edx
  80112c:	83 3a 01             	cmpl   $0x1,(%edx)
  80112f:	7f 10                	jg     801141 <argnextvalue+0x43>
		args->argvalue = 0;
  801131:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801138:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  80113f:	eb e1                	jmp    801122 <argnextvalue+0x24>
		args->argvalue = args->argv[1];
  801141:	8b 43 04             	mov    0x4(%ebx),%eax
  801144:	8b 48 04             	mov    0x4(%eax),%ecx
  801147:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80114a:	83 ec 04             	sub    $0x4,%esp
  80114d:	8b 12                	mov    (%edx),%edx
  80114f:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801156:	52                   	push   %edx
  801157:	8d 50 08             	lea    0x8(%eax),%edx
  80115a:	52                   	push   %edx
  80115b:	83 c0 04             	add    $0x4,%eax
  80115e:	50                   	push   %eax
  80115f:	e8 cd fa ff ff       	call   800c31 <memmove>
		(*args->argc)--;
  801164:	8b 03                	mov    (%ebx),%eax
  801166:	83 28 01             	subl   $0x1,(%eax)
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	eb b4                	jmp    801122 <argnextvalue+0x24>

0080116e <argvalue>:
{
  80116e:	f3 0f 1e fb          	endbr32 
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
  801175:	83 ec 08             	sub    $0x8,%esp
  801178:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  80117b:	8b 42 0c             	mov    0xc(%edx),%eax
  80117e:	85 c0                	test   %eax,%eax
  801180:	74 02                	je     801184 <argvalue+0x16>
}
  801182:	c9                   	leave  
  801183:	c3                   	ret    
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801184:	83 ec 0c             	sub    $0xc,%esp
  801187:	52                   	push   %edx
  801188:	e8 71 ff ff ff       	call   8010fe <argnextvalue>
  80118d:	83 c4 10             	add    $0x10,%esp
  801190:	eb f0                	jmp    801182 <argvalue+0x14>

00801192 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801192:	f3 0f 1e fb          	endbr32 
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801199:	8b 45 08             	mov    0x8(%ebp),%eax
  80119c:	05 00 00 00 30       	add    $0x30000000,%eax
  8011a1:	c1 e8 0c             	shr    $0xc,%eax
}
  8011a4:	5d                   	pop    %ebp
  8011a5:	c3                   	ret    

008011a6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011a6:	f3 0f 1e fb          	endbr32 
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b0:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011b5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011ba:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011bf:	5d                   	pop    %ebp
  8011c0:	c3                   	ret    

008011c1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011c1:	f3 0f 1e fb          	endbr32 
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
  8011c8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011cd:	89 c2                	mov    %eax,%edx
  8011cf:	c1 ea 16             	shr    $0x16,%edx
  8011d2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d9:	f6 c2 01             	test   $0x1,%dl
  8011dc:	74 2d                	je     80120b <fd_alloc+0x4a>
  8011de:	89 c2                	mov    %eax,%edx
  8011e0:	c1 ea 0c             	shr    $0xc,%edx
  8011e3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ea:	f6 c2 01             	test   $0x1,%dl
  8011ed:	74 1c                	je     80120b <fd_alloc+0x4a>
  8011ef:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8011f4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011f9:	75 d2                	jne    8011cd <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  8011fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801204:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801209:	eb 0a                	jmp    801215 <fd_alloc+0x54>
			*fd_store = fd;
  80120b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801210:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801215:	5d                   	pop    %ebp
  801216:	c3                   	ret    

00801217 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801217:	f3 0f 1e fb          	endbr32 
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801221:	83 f8 1f             	cmp    $0x1f,%eax
  801224:	77 30                	ja     801256 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801226:	c1 e0 0c             	shl    $0xc,%eax
  801229:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80122e:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801234:	f6 c2 01             	test   $0x1,%dl
  801237:	74 24                	je     80125d <fd_lookup+0x46>
  801239:	89 c2                	mov    %eax,%edx
  80123b:	c1 ea 0c             	shr    $0xc,%edx
  80123e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801245:	f6 c2 01             	test   $0x1,%dl
  801248:	74 1a                	je     801264 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80124a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124d:	89 02                	mov    %eax,(%edx)
	return 0;
  80124f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801254:	5d                   	pop    %ebp
  801255:	c3                   	ret    
		return -E_INVAL;
  801256:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80125b:	eb f7                	jmp    801254 <fd_lookup+0x3d>
		return -E_INVAL;
  80125d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801262:	eb f0                	jmp    801254 <fd_lookup+0x3d>
  801264:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801269:	eb e9                	jmp    801254 <fd_lookup+0x3d>

0080126b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80126b:	f3 0f 1e fb          	endbr32 
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	83 ec 08             	sub    $0x8,%esp
  801275:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801278:	ba 00 00 00 00       	mov    $0x0,%edx
  80127d:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  801282:	39 08                	cmp    %ecx,(%eax)
  801284:	74 38                	je     8012be <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  801286:	83 c2 01             	add    $0x1,%edx
  801289:	8b 04 95 9c 2c 80 00 	mov    0x802c9c(,%edx,4),%eax
  801290:	85 c0                	test   %eax,%eax
  801292:	75 ee                	jne    801282 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801294:	a1 20 44 80 00       	mov    0x804420,%eax
  801299:	8b 40 48             	mov    0x48(%eax),%eax
  80129c:	83 ec 04             	sub    $0x4,%esp
  80129f:	51                   	push   %ecx
  8012a0:	50                   	push   %eax
  8012a1:	68 20 2c 80 00       	push   $0x802c20
  8012a6:	e8 7e f1 ff ff       	call   800429 <cprintf>
	*dev = 0;
  8012ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ae:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012b4:	83 c4 10             	add    $0x10,%esp
  8012b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012bc:	c9                   	leave  
  8012bd:	c3                   	ret    
			*dev = devtab[i];
  8012be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c8:	eb f2                	jmp    8012bc <dev_lookup+0x51>

008012ca <fd_close>:
{
  8012ca:	f3 0f 1e fb          	endbr32 
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	57                   	push   %edi
  8012d2:	56                   	push   %esi
  8012d3:	53                   	push   %ebx
  8012d4:	83 ec 24             	sub    $0x24,%esp
  8012d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8012da:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012dd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012e0:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012e1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012e7:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ea:	50                   	push   %eax
  8012eb:	e8 27 ff ff ff       	call   801217 <fd_lookup>
  8012f0:	89 c3                	mov    %eax,%ebx
  8012f2:	83 c4 10             	add    $0x10,%esp
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	78 05                	js     8012fe <fd_close+0x34>
	    || fd != fd2)
  8012f9:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8012fc:	74 16                	je     801314 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8012fe:	89 f8                	mov    %edi,%eax
  801300:	84 c0                	test   %al,%al
  801302:	b8 00 00 00 00       	mov    $0x0,%eax
  801307:	0f 44 d8             	cmove  %eax,%ebx
}
  80130a:	89 d8                	mov    %ebx,%eax
  80130c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80130f:	5b                   	pop    %ebx
  801310:	5e                   	pop    %esi
  801311:	5f                   	pop    %edi
  801312:	5d                   	pop    %ebp
  801313:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801314:	83 ec 08             	sub    $0x8,%esp
  801317:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80131a:	50                   	push   %eax
  80131b:	ff 36                	pushl  (%esi)
  80131d:	e8 49 ff ff ff       	call   80126b <dev_lookup>
  801322:	89 c3                	mov    %eax,%ebx
  801324:	83 c4 10             	add    $0x10,%esp
  801327:	85 c0                	test   %eax,%eax
  801329:	78 1a                	js     801345 <fd_close+0x7b>
		if (dev->dev_close)
  80132b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80132e:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801331:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801336:	85 c0                	test   %eax,%eax
  801338:	74 0b                	je     801345 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80133a:	83 ec 0c             	sub    $0xc,%esp
  80133d:	56                   	push   %esi
  80133e:	ff d0                	call   *%eax
  801340:	89 c3                	mov    %eax,%ebx
  801342:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801345:	83 ec 08             	sub    $0x8,%esp
  801348:	56                   	push   %esi
  801349:	6a 00                	push   $0x0
  80134b:	e8 97 fb ff ff       	call   800ee7 <sys_page_unmap>
	return r;
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	eb b5                	jmp    80130a <fd_close+0x40>

00801355 <close>:

int
close(int fdnum)
{
  801355:	f3 0f 1e fb          	endbr32 
  801359:	55                   	push   %ebp
  80135a:	89 e5                	mov    %esp,%ebp
  80135c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80135f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801362:	50                   	push   %eax
  801363:	ff 75 08             	pushl  0x8(%ebp)
  801366:	e8 ac fe ff ff       	call   801217 <fd_lookup>
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	85 c0                	test   %eax,%eax
  801370:	79 02                	jns    801374 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801372:	c9                   	leave  
  801373:	c3                   	ret    
		return fd_close(fd, 1);
  801374:	83 ec 08             	sub    $0x8,%esp
  801377:	6a 01                	push   $0x1
  801379:	ff 75 f4             	pushl  -0xc(%ebp)
  80137c:	e8 49 ff ff ff       	call   8012ca <fd_close>
  801381:	83 c4 10             	add    $0x10,%esp
  801384:	eb ec                	jmp    801372 <close+0x1d>

00801386 <close_all>:

void
close_all(void)
{
  801386:	f3 0f 1e fb          	endbr32 
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	53                   	push   %ebx
  80138e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801391:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801396:	83 ec 0c             	sub    $0xc,%esp
  801399:	53                   	push   %ebx
  80139a:	e8 b6 ff ff ff       	call   801355 <close>
	for (i = 0; i < MAXFD; i++)
  80139f:	83 c3 01             	add    $0x1,%ebx
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	83 fb 20             	cmp    $0x20,%ebx
  8013a8:	75 ec                	jne    801396 <close_all+0x10>
}
  8013aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ad:	c9                   	leave  
  8013ae:	c3                   	ret    

008013af <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013af:	f3 0f 1e fb          	endbr32 
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
  8013b6:	57                   	push   %edi
  8013b7:	56                   	push   %esi
  8013b8:	53                   	push   %ebx
  8013b9:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013bc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013bf:	50                   	push   %eax
  8013c0:	ff 75 08             	pushl  0x8(%ebp)
  8013c3:	e8 4f fe ff ff       	call   801217 <fd_lookup>
  8013c8:	89 c3                	mov    %eax,%ebx
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	0f 88 81 00 00 00    	js     801456 <dup+0xa7>
		return r;
	close(newfdnum);
  8013d5:	83 ec 0c             	sub    $0xc,%esp
  8013d8:	ff 75 0c             	pushl  0xc(%ebp)
  8013db:	e8 75 ff ff ff       	call   801355 <close>

	newfd = INDEX2FD(newfdnum);
  8013e0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013e3:	c1 e6 0c             	shl    $0xc,%esi
  8013e6:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013ec:	83 c4 04             	add    $0x4,%esp
  8013ef:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013f2:	e8 af fd ff ff       	call   8011a6 <fd2data>
  8013f7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013f9:	89 34 24             	mov    %esi,(%esp)
  8013fc:	e8 a5 fd ff ff       	call   8011a6 <fd2data>
  801401:	83 c4 10             	add    $0x10,%esp
  801404:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801406:	89 d8                	mov    %ebx,%eax
  801408:	c1 e8 16             	shr    $0x16,%eax
  80140b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801412:	a8 01                	test   $0x1,%al
  801414:	74 11                	je     801427 <dup+0x78>
  801416:	89 d8                	mov    %ebx,%eax
  801418:	c1 e8 0c             	shr    $0xc,%eax
  80141b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801422:	f6 c2 01             	test   $0x1,%dl
  801425:	75 39                	jne    801460 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801427:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80142a:	89 d0                	mov    %edx,%eax
  80142c:	c1 e8 0c             	shr    $0xc,%eax
  80142f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801436:	83 ec 0c             	sub    $0xc,%esp
  801439:	25 07 0e 00 00       	and    $0xe07,%eax
  80143e:	50                   	push   %eax
  80143f:	56                   	push   %esi
  801440:	6a 00                	push   $0x0
  801442:	52                   	push   %edx
  801443:	6a 00                	push   $0x0
  801445:	e8 78 fa ff ff       	call   800ec2 <sys_page_map>
  80144a:	89 c3                	mov    %eax,%ebx
  80144c:	83 c4 20             	add    $0x20,%esp
  80144f:	85 c0                	test   %eax,%eax
  801451:	78 31                	js     801484 <dup+0xd5>
		goto err;

	return newfdnum;
  801453:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801456:	89 d8                	mov    %ebx,%eax
  801458:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80145b:	5b                   	pop    %ebx
  80145c:	5e                   	pop    %esi
  80145d:	5f                   	pop    %edi
  80145e:	5d                   	pop    %ebp
  80145f:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801460:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801467:	83 ec 0c             	sub    $0xc,%esp
  80146a:	25 07 0e 00 00       	and    $0xe07,%eax
  80146f:	50                   	push   %eax
  801470:	57                   	push   %edi
  801471:	6a 00                	push   $0x0
  801473:	53                   	push   %ebx
  801474:	6a 00                	push   $0x0
  801476:	e8 47 fa ff ff       	call   800ec2 <sys_page_map>
  80147b:	89 c3                	mov    %eax,%ebx
  80147d:	83 c4 20             	add    $0x20,%esp
  801480:	85 c0                	test   %eax,%eax
  801482:	79 a3                	jns    801427 <dup+0x78>
	sys_page_unmap(0, newfd);
  801484:	83 ec 08             	sub    $0x8,%esp
  801487:	56                   	push   %esi
  801488:	6a 00                	push   $0x0
  80148a:	e8 58 fa ff ff       	call   800ee7 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80148f:	83 c4 08             	add    $0x8,%esp
  801492:	57                   	push   %edi
  801493:	6a 00                	push   $0x0
  801495:	e8 4d fa ff ff       	call   800ee7 <sys_page_unmap>
	return r;
  80149a:	83 c4 10             	add    $0x10,%esp
  80149d:	eb b7                	jmp    801456 <dup+0xa7>

0080149f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80149f:	f3 0f 1e fb          	endbr32 
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	53                   	push   %ebx
  8014a7:	83 ec 1c             	sub    $0x1c,%esp
  8014aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b0:	50                   	push   %eax
  8014b1:	53                   	push   %ebx
  8014b2:	e8 60 fd ff ff       	call   801217 <fd_lookup>
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	78 3f                	js     8014fd <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014be:	83 ec 08             	sub    $0x8,%esp
  8014c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c4:	50                   	push   %eax
  8014c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c8:	ff 30                	pushl  (%eax)
  8014ca:	e8 9c fd ff ff       	call   80126b <dev_lookup>
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	78 27                	js     8014fd <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014d6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014d9:	8b 42 08             	mov    0x8(%edx),%eax
  8014dc:	83 e0 03             	and    $0x3,%eax
  8014df:	83 f8 01             	cmp    $0x1,%eax
  8014e2:	74 1e                	je     801502 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e7:	8b 40 08             	mov    0x8(%eax),%eax
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	74 35                	je     801523 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014ee:	83 ec 04             	sub    $0x4,%esp
  8014f1:	ff 75 10             	pushl  0x10(%ebp)
  8014f4:	ff 75 0c             	pushl  0xc(%ebp)
  8014f7:	52                   	push   %edx
  8014f8:	ff d0                	call   *%eax
  8014fa:	83 c4 10             	add    $0x10,%esp
}
  8014fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801500:	c9                   	leave  
  801501:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801502:	a1 20 44 80 00       	mov    0x804420,%eax
  801507:	8b 40 48             	mov    0x48(%eax),%eax
  80150a:	83 ec 04             	sub    $0x4,%esp
  80150d:	53                   	push   %ebx
  80150e:	50                   	push   %eax
  80150f:	68 61 2c 80 00       	push   $0x802c61
  801514:	e8 10 ef ff ff       	call   800429 <cprintf>
		return -E_INVAL;
  801519:	83 c4 10             	add    $0x10,%esp
  80151c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801521:	eb da                	jmp    8014fd <read+0x5e>
		return -E_NOT_SUPP;
  801523:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801528:	eb d3                	jmp    8014fd <read+0x5e>

0080152a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80152a:	f3 0f 1e fb          	endbr32 
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	57                   	push   %edi
  801532:	56                   	push   %esi
  801533:	53                   	push   %ebx
  801534:	83 ec 0c             	sub    $0xc,%esp
  801537:	8b 7d 08             	mov    0x8(%ebp),%edi
  80153a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80153d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801542:	eb 02                	jmp    801546 <readn+0x1c>
  801544:	01 c3                	add    %eax,%ebx
  801546:	39 f3                	cmp    %esi,%ebx
  801548:	73 21                	jae    80156b <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80154a:	83 ec 04             	sub    $0x4,%esp
  80154d:	89 f0                	mov    %esi,%eax
  80154f:	29 d8                	sub    %ebx,%eax
  801551:	50                   	push   %eax
  801552:	89 d8                	mov    %ebx,%eax
  801554:	03 45 0c             	add    0xc(%ebp),%eax
  801557:	50                   	push   %eax
  801558:	57                   	push   %edi
  801559:	e8 41 ff ff ff       	call   80149f <read>
		if (m < 0)
  80155e:	83 c4 10             	add    $0x10,%esp
  801561:	85 c0                	test   %eax,%eax
  801563:	78 04                	js     801569 <readn+0x3f>
			return m;
		if (m == 0)
  801565:	75 dd                	jne    801544 <readn+0x1a>
  801567:	eb 02                	jmp    80156b <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801569:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80156b:	89 d8                	mov    %ebx,%eax
  80156d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801570:	5b                   	pop    %ebx
  801571:	5e                   	pop    %esi
  801572:	5f                   	pop    %edi
  801573:	5d                   	pop    %ebp
  801574:	c3                   	ret    

00801575 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801575:	f3 0f 1e fb          	endbr32 
  801579:	55                   	push   %ebp
  80157a:	89 e5                	mov    %esp,%ebp
  80157c:	53                   	push   %ebx
  80157d:	83 ec 1c             	sub    $0x1c,%esp
  801580:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801583:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801586:	50                   	push   %eax
  801587:	53                   	push   %ebx
  801588:	e8 8a fc ff ff       	call   801217 <fd_lookup>
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	85 c0                	test   %eax,%eax
  801592:	78 3a                	js     8015ce <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801594:	83 ec 08             	sub    $0x8,%esp
  801597:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159a:	50                   	push   %eax
  80159b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159e:	ff 30                	pushl  (%eax)
  8015a0:	e8 c6 fc ff ff       	call   80126b <dev_lookup>
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	78 22                	js     8015ce <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015af:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015b3:	74 1e                	je     8015d3 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b8:	8b 52 0c             	mov    0xc(%edx),%edx
  8015bb:	85 d2                	test   %edx,%edx
  8015bd:	74 35                	je     8015f4 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015bf:	83 ec 04             	sub    $0x4,%esp
  8015c2:	ff 75 10             	pushl  0x10(%ebp)
  8015c5:	ff 75 0c             	pushl  0xc(%ebp)
  8015c8:	50                   	push   %eax
  8015c9:	ff d2                	call   *%edx
  8015cb:	83 c4 10             	add    $0x10,%esp
}
  8015ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d1:	c9                   	leave  
  8015d2:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d3:	a1 20 44 80 00       	mov    0x804420,%eax
  8015d8:	8b 40 48             	mov    0x48(%eax),%eax
  8015db:	83 ec 04             	sub    $0x4,%esp
  8015de:	53                   	push   %ebx
  8015df:	50                   	push   %eax
  8015e0:	68 7d 2c 80 00       	push   $0x802c7d
  8015e5:	e8 3f ee ff ff       	call   800429 <cprintf>
		return -E_INVAL;
  8015ea:	83 c4 10             	add    $0x10,%esp
  8015ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015f2:	eb da                	jmp    8015ce <write+0x59>
		return -E_NOT_SUPP;
  8015f4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015f9:	eb d3                	jmp    8015ce <write+0x59>

008015fb <seek>:

int
seek(int fdnum, off_t offset)
{
  8015fb:	f3 0f 1e fb          	endbr32 
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801605:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801608:	50                   	push   %eax
  801609:	ff 75 08             	pushl  0x8(%ebp)
  80160c:	e8 06 fc ff ff       	call   801217 <fd_lookup>
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	85 c0                	test   %eax,%eax
  801616:	78 0e                	js     801626 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801618:	8b 55 0c             	mov    0xc(%ebp),%edx
  80161b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80161e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801621:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801626:	c9                   	leave  
  801627:	c3                   	ret    

00801628 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801628:	f3 0f 1e fb          	endbr32 
  80162c:	55                   	push   %ebp
  80162d:	89 e5                	mov    %esp,%ebp
  80162f:	53                   	push   %ebx
  801630:	83 ec 1c             	sub    $0x1c,%esp
  801633:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801636:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801639:	50                   	push   %eax
  80163a:	53                   	push   %ebx
  80163b:	e8 d7 fb ff ff       	call   801217 <fd_lookup>
  801640:	83 c4 10             	add    $0x10,%esp
  801643:	85 c0                	test   %eax,%eax
  801645:	78 37                	js     80167e <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801647:	83 ec 08             	sub    $0x8,%esp
  80164a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164d:	50                   	push   %eax
  80164e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801651:	ff 30                	pushl  (%eax)
  801653:	e8 13 fc ff ff       	call   80126b <dev_lookup>
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	85 c0                	test   %eax,%eax
  80165d:	78 1f                	js     80167e <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80165f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801662:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801666:	74 1b                	je     801683 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801668:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80166b:	8b 52 18             	mov    0x18(%edx),%edx
  80166e:	85 d2                	test   %edx,%edx
  801670:	74 32                	je     8016a4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801672:	83 ec 08             	sub    $0x8,%esp
  801675:	ff 75 0c             	pushl  0xc(%ebp)
  801678:	50                   	push   %eax
  801679:	ff d2                	call   *%edx
  80167b:	83 c4 10             	add    $0x10,%esp
}
  80167e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801681:	c9                   	leave  
  801682:	c3                   	ret    
			thisenv->env_id, fdnum);
  801683:	a1 20 44 80 00       	mov    0x804420,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801688:	8b 40 48             	mov    0x48(%eax),%eax
  80168b:	83 ec 04             	sub    $0x4,%esp
  80168e:	53                   	push   %ebx
  80168f:	50                   	push   %eax
  801690:	68 40 2c 80 00       	push   $0x802c40
  801695:	e8 8f ed ff ff       	call   800429 <cprintf>
		return -E_INVAL;
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016a2:	eb da                	jmp    80167e <ftruncate+0x56>
		return -E_NOT_SUPP;
  8016a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016a9:	eb d3                	jmp    80167e <ftruncate+0x56>

008016ab <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016ab:	f3 0f 1e fb          	endbr32 
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	53                   	push   %ebx
  8016b3:	83 ec 1c             	sub    $0x1c,%esp
  8016b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016bc:	50                   	push   %eax
  8016bd:	ff 75 08             	pushl  0x8(%ebp)
  8016c0:	e8 52 fb ff ff       	call   801217 <fd_lookup>
  8016c5:	83 c4 10             	add    $0x10,%esp
  8016c8:	85 c0                	test   %eax,%eax
  8016ca:	78 4b                	js     801717 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016cc:	83 ec 08             	sub    $0x8,%esp
  8016cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d2:	50                   	push   %eax
  8016d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d6:	ff 30                	pushl  (%eax)
  8016d8:	e8 8e fb ff ff       	call   80126b <dev_lookup>
  8016dd:	83 c4 10             	add    $0x10,%esp
  8016e0:	85 c0                	test   %eax,%eax
  8016e2:	78 33                	js     801717 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8016e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016eb:	74 2f                	je     80171c <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016ed:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016f0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016f7:	00 00 00 
	stat->st_isdir = 0;
  8016fa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801701:	00 00 00 
	stat->st_dev = dev;
  801704:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80170a:	83 ec 08             	sub    $0x8,%esp
  80170d:	53                   	push   %ebx
  80170e:	ff 75 f0             	pushl  -0x10(%ebp)
  801711:	ff 50 14             	call   *0x14(%eax)
  801714:	83 c4 10             	add    $0x10,%esp
}
  801717:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171a:	c9                   	leave  
  80171b:	c3                   	ret    
		return -E_NOT_SUPP;
  80171c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801721:	eb f4                	jmp    801717 <fstat+0x6c>

00801723 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801723:	f3 0f 1e fb          	endbr32 
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	56                   	push   %esi
  80172b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80172c:	83 ec 08             	sub    $0x8,%esp
  80172f:	6a 00                	push   $0x0
  801731:	ff 75 08             	pushl  0x8(%ebp)
  801734:	e8 01 02 00 00       	call   80193a <open>
  801739:	89 c3                	mov    %eax,%ebx
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	85 c0                	test   %eax,%eax
  801740:	78 1b                	js     80175d <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801742:	83 ec 08             	sub    $0x8,%esp
  801745:	ff 75 0c             	pushl  0xc(%ebp)
  801748:	50                   	push   %eax
  801749:	e8 5d ff ff ff       	call   8016ab <fstat>
  80174e:	89 c6                	mov    %eax,%esi
	close(fd);
  801750:	89 1c 24             	mov    %ebx,(%esp)
  801753:	e8 fd fb ff ff       	call   801355 <close>
	return r;
  801758:	83 c4 10             	add    $0x10,%esp
  80175b:	89 f3                	mov    %esi,%ebx
}
  80175d:	89 d8                	mov    %ebx,%eax
  80175f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801762:	5b                   	pop    %ebx
  801763:	5e                   	pop    %esi
  801764:	5d                   	pop    %ebp
  801765:	c3                   	ret    

00801766 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	56                   	push   %esi
  80176a:	53                   	push   %ebx
  80176b:	89 c6                	mov    %eax,%esi
  80176d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80176f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801776:	74 27                	je     80179f <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801778:	6a 07                	push   $0x7
  80177a:	68 00 50 80 00       	push   $0x805000
  80177f:	56                   	push   %esi
  801780:	ff 35 00 40 80 00    	pushl  0x804000
  801786:	e8 a0 0d 00 00       	call   80252b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80178b:	83 c4 0c             	add    $0xc,%esp
  80178e:	6a 00                	push   $0x0
  801790:	53                   	push   %ebx
  801791:	6a 00                	push   $0x0
  801793:	e8 26 0d 00 00       	call   8024be <ipc_recv>
}
  801798:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80179b:	5b                   	pop    %ebx
  80179c:	5e                   	pop    %esi
  80179d:	5d                   	pop    %ebp
  80179e:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80179f:	83 ec 0c             	sub    $0xc,%esp
  8017a2:	6a 01                	push   $0x1
  8017a4:	e8 da 0d 00 00       	call   802583 <ipc_find_env>
  8017a9:	a3 00 40 80 00       	mov    %eax,0x804000
  8017ae:	83 c4 10             	add    $0x10,%esp
  8017b1:	eb c5                	jmp    801778 <fsipc+0x12>

008017b3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017b3:	f3 0f 1e fb          	endbr32 
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017cb:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d5:	b8 02 00 00 00       	mov    $0x2,%eax
  8017da:	e8 87 ff ff ff       	call   801766 <fsipc>
}
  8017df:	c9                   	leave  
  8017e0:	c3                   	ret    

008017e1 <devfile_flush>:
{
  8017e1:	f3 0f 1e fb          	endbr32 
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ee:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fb:	b8 06 00 00 00       	mov    $0x6,%eax
  801800:	e8 61 ff ff ff       	call   801766 <fsipc>
}
  801805:	c9                   	leave  
  801806:	c3                   	ret    

00801807 <devfile_stat>:
{
  801807:	f3 0f 1e fb          	endbr32 
  80180b:	55                   	push   %ebp
  80180c:	89 e5                	mov    %esp,%ebp
  80180e:	53                   	push   %ebx
  80180f:	83 ec 04             	sub    $0x4,%esp
  801812:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801815:	8b 45 08             	mov    0x8(%ebp),%eax
  801818:	8b 40 0c             	mov    0xc(%eax),%eax
  80181b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801820:	ba 00 00 00 00       	mov    $0x0,%edx
  801825:	b8 05 00 00 00       	mov    $0x5,%eax
  80182a:	e8 37 ff ff ff       	call   801766 <fsipc>
  80182f:	85 c0                	test   %eax,%eax
  801831:	78 2c                	js     80185f <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801833:	83 ec 08             	sub    $0x8,%esp
  801836:	68 00 50 80 00       	push   $0x805000
  80183b:	53                   	push   %ebx
  80183c:	e8 f2 f1 ff ff       	call   800a33 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801841:	a1 80 50 80 00       	mov    0x805080,%eax
  801846:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80184c:	a1 84 50 80 00       	mov    0x805084,%eax
  801851:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801857:	83 c4 10             	add    $0x10,%esp
  80185a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80185f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801862:	c9                   	leave  
  801863:	c3                   	ret    

00801864 <devfile_write>:
{
  801864:	f3 0f 1e fb          	endbr32 
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	83 ec 0c             	sub    $0xc,%esp
  80186e:	8b 45 10             	mov    0x10(%ebp),%eax
  801871:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801876:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80187b:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80187e:	8b 55 08             	mov    0x8(%ebp),%edx
  801881:	8b 52 0c             	mov    0xc(%edx),%edx
  801884:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80188a:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80188f:	50                   	push   %eax
  801890:	ff 75 0c             	pushl  0xc(%ebp)
  801893:	68 08 50 80 00       	push   $0x805008
  801898:	e8 94 f3 ff ff       	call   800c31 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80189d:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a2:	b8 04 00 00 00       	mov    $0x4,%eax
  8018a7:	e8 ba fe ff ff       	call   801766 <fsipc>
}
  8018ac:	c9                   	leave  
  8018ad:	c3                   	ret    

008018ae <devfile_read>:
{
  8018ae:	f3 0f 1e fb          	endbr32 
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	56                   	push   %esi
  8018b6:	53                   	push   %ebx
  8018b7:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018c5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d0:	b8 03 00 00 00       	mov    $0x3,%eax
  8018d5:	e8 8c fe ff ff       	call   801766 <fsipc>
  8018da:	89 c3                	mov    %eax,%ebx
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	78 1f                	js     8018ff <devfile_read+0x51>
	assert(r <= n);
  8018e0:	39 f0                	cmp    %esi,%eax
  8018e2:	77 24                	ja     801908 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8018e4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018e9:	7f 36                	jg     801921 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018eb:	83 ec 04             	sub    $0x4,%esp
  8018ee:	50                   	push   %eax
  8018ef:	68 00 50 80 00       	push   $0x805000
  8018f4:	ff 75 0c             	pushl  0xc(%ebp)
  8018f7:	e8 35 f3 ff ff       	call   800c31 <memmove>
	return r;
  8018fc:	83 c4 10             	add    $0x10,%esp
}
  8018ff:	89 d8                	mov    %ebx,%eax
  801901:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801904:	5b                   	pop    %ebx
  801905:	5e                   	pop    %esi
  801906:	5d                   	pop    %ebp
  801907:	c3                   	ret    
	assert(r <= n);
  801908:	68 b0 2c 80 00       	push   $0x802cb0
  80190d:	68 b7 2c 80 00       	push   $0x802cb7
  801912:	68 8c 00 00 00       	push   $0x8c
  801917:	68 cc 2c 80 00       	push   $0x802ccc
  80191c:	e8 21 ea ff ff       	call   800342 <_panic>
	assert(r <= PGSIZE);
  801921:	68 d7 2c 80 00       	push   $0x802cd7
  801926:	68 b7 2c 80 00       	push   $0x802cb7
  80192b:	68 8d 00 00 00       	push   $0x8d
  801930:	68 cc 2c 80 00       	push   $0x802ccc
  801935:	e8 08 ea ff ff       	call   800342 <_panic>

0080193a <open>:
{
  80193a:	f3 0f 1e fb          	endbr32 
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	56                   	push   %esi
  801942:	53                   	push   %ebx
  801943:	83 ec 1c             	sub    $0x1c,%esp
  801946:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801949:	56                   	push   %esi
  80194a:	e8 a1 f0 ff ff       	call   8009f0 <strlen>
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801957:	7f 6c                	jg     8019c5 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801959:	83 ec 0c             	sub    $0xc,%esp
  80195c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195f:	50                   	push   %eax
  801960:	e8 5c f8 ff ff       	call   8011c1 <fd_alloc>
  801965:	89 c3                	mov    %eax,%ebx
  801967:	83 c4 10             	add    $0x10,%esp
  80196a:	85 c0                	test   %eax,%eax
  80196c:	78 3c                	js     8019aa <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  80196e:	83 ec 08             	sub    $0x8,%esp
  801971:	56                   	push   %esi
  801972:	68 00 50 80 00       	push   $0x805000
  801977:	e8 b7 f0 ff ff       	call   800a33 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80197c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80197f:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801984:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801987:	b8 01 00 00 00       	mov    $0x1,%eax
  80198c:	e8 d5 fd ff ff       	call   801766 <fsipc>
  801991:	89 c3                	mov    %eax,%ebx
  801993:	83 c4 10             	add    $0x10,%esp
  801996:	85 c0                	test   %eax,%eax
  801998:	78 19                	js     8019b3 <open+0x79>
	return fd2num(fd);
  80199a:	83 ec 0c             	sub    $0xc,%esp
  80199d:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a0:	e8 ed f7 ff ff       	call   801192 <fd2num>
  8019a5:	89 c3                	mov    %eax,%ebx
  8019a7:	83 c4 10             	add    $0x10,%esp
}
  8019aa:	89 d8                	mov    %ebx,%eax
  8019ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019af:	5b                   	pop    %ebx
  8019b0:	5e                   	pop    %esi
  8019b1:	5d                   	pop    %ebp
  8019b2:	c3                   	ret    
		fd_close(fd, 0);
  8019b3:	83 ec 08             	sub    $0x8,%esp
  8019b6:	6a 00                	push   $0x0
  8019b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019bb:	e8 0a f9 ff ff       	call   8012ca <fd_close>
		return r;
  8019c0:	83 c4 10             	add    $0x10,%esp
  8019c3:	eb e5                	jmp    8019aa <open+0x70>
		return -E_BAD_PATH;
  8019c5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019ca:	eb de                	jmp    8019aa <open+0x70>

008019cc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019cc:	f3 0f 1e fb          	endbr32 
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019db:	b8 08 00 00 00       	mov    $0x8,%eax
  8019e0:	e8 81 fd ff ff       	call   801766 <fsipc>
}
  8019e5:	c9                   	leave  
  8019e6:	c3                   	ret    

008019e7 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8019e7:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8019eb:	7f 01                	jg     8019ee <writebuf+0x7>
  8019ed:	c3                   	ret    
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	53                   	push   %ebx
  8019f2:	83 ec 08             	sub    $0x8,%esp
  8019f5:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  8019f7:	ff 70 04             	pushl  0x4(%eax)
  8019fa:	8d 40 10             	lea    0x10(%eax),%eax
  8019fd:	50                   	push   %eax
  8019fe:	ff 33                	pushl  (%ebx)
  801a00:	e8 70 fb ff ff       	call   801575 <write>
		if (result > 0)
  801a05:	83 c4 10             	add    $0x10,%esp
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	7e 03                	jle    801a0f <writebuf+0x28>
			b->result += result;
  801a0c:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801a0f:	39 43 04             	cmp    %eax,0x4(%ebx)
  801a12:	74 0d                	je     801a21 <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  801a14:	85 c0                	test   %eax,%eax
  801a16:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1b:	0f 4f c2             	cmovg  %edx,%eax
  801a1e:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801a21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a24:	c9                   	leave  
  801a25:	c3                   	ret    

00801a26 <putch>:

static void
putch(int ch, void *thunk)
{
  801a26:	f3 0f 1e fb          	endbr32 
  801a2a:	55                   	push   %ebp
  801a2b:	89 e5                	mov    %esp,%ebp
  801a2d:	53                   	push   %ebx
  801a2e:	83 ec 04             	sub    $0x4,%esp
  801a31:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801a34:	8b 53 04             	mov    0x4(%ebx),%edx
  801a37:	8d 42 01             	lea    0x1(%edx),%eax
  801a3a:	89 43 04             	mov    %eax,0x4(%ebx)
  801a3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a40:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801a44:	3d 00 01 00 00       	cmp    $0x100,%eax
  801a49:	74 06                	je     801a51 <putch+0x2b>
		writebuf(b);
		b->idx = 0;
	}
}
  801a4b:	83 c4 04             	add    $0x4,%esp
  801a4e:	5b                   	pop    %ebx
  801a4f:	5d                   	pop    %ebp
  801a50:	c3                   	ret    
		writebuf(b);
  801a51:	89 d8                	mov    %ebx,%eax
  801a53:	e8 8f ff ff ff       	call   8019e7 <writebuf>
		b->idx = 0;
  801a58:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  801a5f:	eb ea                	jmp    801a4b <putch+0x25>

00801a61 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801a61:	f3 0f 1e fb          	endbr32 
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a71:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801a77:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801a7e:	00 00 00 
	b.result = 0;
  801a81:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a88:	00 00 00 
	b.error = 1;
  801a8b:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801a92:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801a95:	ff 75 10             	pushl  0x10(%ebp)
  801a98:	ff 75 0c             	pushl  0xc(%ebp)
  801a9b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801aa1:	50                   	push   %eax
  801aa2:	68 26 1a 80 00       	push   $0x801a26
  801aa7:	e8 80 ea ff ff       	call   80052c <vprintfmt>
	if (b.idx > 0)
  801aac:	83 c4 10             	add    $0x10,%esp
  801aaf:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801ab6:	7f 11                	jg     801ac9 <vfprintf+0x68>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  801ab8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801abe:	85 c0                	test   %eax,%eax
  801ac0:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801ac7:	c9                   	leave  
  801ac8:	c3                   	ret    
		writebuf(&b);
  801ac9:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801acf:	e8 13 ff ff ff       	call   8019e7 <writebuf>
  801ad4:	eb e2                	jmp    801ab8 <vfprintf+0x57>

00801ad6 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801ad6:	f3 0f 1e fb          	endbr32 
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801ae0:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801ae3:	50                   	push   %eax
  801ae4:	ff 75 0c             	pushl  0xc(%ebp)
  801ae7:	ff 75 08             	pushl  0x8(%ebp)
  801aea:	e8 72 ff ff ff       	call   801a61 <vfprintf>
	va_end(ap);

	return cnt;
}
  801aef:	c9                   	leave  
  801af0:	c3                   	ret    

00801af1 <printf>:

int
printf(const char *fmt, ...)
{
  801af1:	f3 0f 1e fb          	endbr32 
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801afb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801afe:	50                   	push   %eax
  801aff:	ff 75 08             	pushl  0x8(%ebp)
  801b02:	6a 01                	push   $0x1
  801b04:	e8 58 ff ff ff       	call   801a61 <vfprintf>
	va_end(ap);

	return cnt;
}
  801b09:	c9                   	leave  
  801b0a:	c3                   	ret    

00801b0b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b0b:	f3 0f 1e fb          	endbr32 
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801b15:	68 43 2d 80 00       	push   $0x802d43
  801b1a:	ff 75 0c             	pushl  0xc(%ebp)
  801b1d:	e8 11 ef ff ff       	call   800a33 <strcpy>
	return 0;
}
  801b22:	b8 00 00 00 00       	mov    $0x0,%eax
  801b27:	c9                   	leave  
  801b28:	c3                   	ret    

00801b29 <devsock_close>:
{
  801b29:	f3 0f 1e fb          	endbr32 
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	53                   	push   %ebx
  801b31:	83 ec 10             	sub    $0x10,%esp
  801b34:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b37:	53                   	push   %ebx
  801b38:	e8 83 0a 00 00       	call   8025c0 <pageref>
  801b3d:	89 c2                	mov    %eax,%edx
  801b3f:	83 c4 10             	add    $0x10,%esp
		return 0;
  801b42:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801b47:	83 fa 01             	cmp    $0x1,%edx
  801b4a:	74 05                	je     801b51 <devsock_close+0x28>
}
  801b4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b4f:	c9                   	leave  
  801b50:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801b51:	83 ec 0c             	sub    $0xc,%esp
  801b54:	ff 73 0c             	pushl  0xc(%ebx)
  801b57:	e8 e3 02 00 00       	call   801e3f <nsipc_close>
  801b5c:	83 c4 10             	add    $0x10,%esp
  801b5f:	eb eb                	jmp    801b4c <devsock_close+0x23>

00801b61 <devsock_write>:
{
  801b61:	f3 0f 1e fb          	endbr32 
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b6b:	6a 00                	push   $0x0
  801b6d:	ff 75 10             	pushl  0x10(%ebp)
  801b70:	ff 75 0c             	pushl  0xc(%ebp)
  801b73:	8b 45 08             	mov    0x8(%ebp),%eax
  801b76:	ff 70 0c             	pushl  0xc(%eax)
  801b79:	e8 b5 03 00 00       	call   801f33 <nsipc_send>
}
  801b7e:	c9                   	leave  
  801b7f:	c3                   	ret    

00801b80 <devsock_read>:
{
  801b80:	f3 0f 1e fb          	endbr32 
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b8a:	6a 00                	push   $0x0
  801b8c:	ff 75 10             	pushl  0x10(%ebp)
  801b8f:	ff 75 0c             	pushl  0xc(%ebp)
  801b92:	8b 45 08             	mov    0x8(%ebp),%eax
  801b95:	ff 70 0c             	pushl  0xc(%eax)
  801b98:	e8 1f 03 00 00       	call   801ebc <nsipc_recv>
}
  801b9d:	c9                   	leave  
  801b9e:	c3                   	ret    

00801b9f <fd2sockid>:
{
  801b9f:	55                   	push   %ebp
  801ba0:	89 e5                	mov    %esp,%ebp
  801ba2:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801ba5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ba8:	52                   	push   %edx
  801ba9:	50                   	push   %eax
  801baa:	e8 68 f6 ff ff       	call   801217 <fd_lookup>
  801baf:	83 c4 10             	add    $0x10,%esp
  801bb2:	85 c0                	test   %eax,%eax
  801bb4:	78 10                	js     801bc6 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb9:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  801bbf:	39 08                	cmp    %ecx,(%eax)
  801bc1:	75 05                	jne    801bc8 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801bc3:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801bc6:	c9                   	leave  
  801bc7:	c3                   	ret    
		return -E_NOT_SUPP;
  801bc8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801bcd:	eb f7                	jmp    801bc6 <fd2sockid+0x27>

00801bcf <alloc_sockfd>:
{
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	56                   	push   %esi
  801bd3:	53                   	push   %ebx
  801bd4:	83 ec 1c             	sub    $0x1c,%esp
  801bd7:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801bd9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdc:	50                   	push   %eax
  801bdd:	e8 df f5 ff ff       	call   8011c1 <fd_alloc>
  801be2:	89 c3                	mov    %eax,%ebx
  801be4:	83 c4 10             	add    $0x10,%esp
  801be7:	85 c0                	test   %eax,%eax
  801be9:	78 43                	js     801c2e <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801beb:	83 ec 04             	sub    $0x4,%esp
  801bee:	68 07 04 00 00       	push   $0x407
  801bf3:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf6:	6a 00                	push   $0x0
  801bf8:	e8 9f f2 ff ff       	call   800e9c <sys_page_alloc>
  801bfd:	89 c3                	mov    %eax,%ebx
  801bff:	83 c4 10             	add    $0x10,%esp
  801c02:	85 c0                	test   %eax,%eax
  801c04:	78 28                	js     801c2e <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c09:	8b 15 60 30 80 00    	mov    0x803060,%edx
  801c0f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c14:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c1b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c1e:	83 ec 0c             	sub    $0xc,%esp
  801c21:	50                   	push   %eax
  801c22:	e8 6b f5 ff ff       	call   801192 <fd2num>
  801c27:	89 c3                	mov    %eax,%ebx
  801c29:	83 c4 10             	add    $0x10,%esp
  801c2c:	eb 0c                	jmp    801c3a <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801c2e:	83 ec 0c             	sub    $0xc,%esp
  801c31:	56                   	push   %esi
  801c32:	e8 08 02 00 00       	call   801e3f <nsipc_close>
		return r;
  801c37:	83 c4 10             	add    $0x10,%esp
}
  801c3a:	89 d8                	mov    %ebx,%eax
  801c3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c3f:	5b                   	pop    %ebx
  801c40:	5e                   	pop    %esi
  801c41:	5d                   	pop    %ebp
  801c42:	c3                   	ret    

00801c43 <accept>:
{
  801c43:	f3 0f 1e fb          	endbr32 
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c50:	e8 4a ff ff ff       	call   801b9f <fd2sockid>
  801c55:	85 c0                	test   %eax,%eax
  801c57:	78 1b                	js     801c74 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c59:	83 ec 04             	sub    $0x4,%esp
  801c5c:	ff 75 10             	pushl  0x10(%ebp)
  801c5f:	ff 75 0c             	pushl  0xc(%ebp)
  801c62:	50                   	push   %eax
  801c63:	e8 22 01 00 00       	call   801d8a <nsipc_accept>
  801c68:	83 c4 10             	add    $0x10,%esp
  801c6b:	85 c0                	test   %eax,%eax
  801c6d:	78 05                	js     801c74 <accept+0x31>
	return alloc_sockfd(r);
  801c6f:	e8 5b ff ff ff       	call   801bcf <alloc_sockfd>
}
  801c74:	c9                   	leave  
  801c75:	c3                   	ret    

00801c76 <bind>:
{
  801c76:	f3 0f 1e fb          	endbr32 
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c80:	8b 45 08             	mov    0x8(%ebp),%eax
  801c83:	e8 17 ff ff ff       	call   801b9f <fd2sockid>
  801c88:	85 c0                	test   %eax,%eax
  801c8a:	78 12                	js     801c9e <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801c8c:	83 ec 04             	sub    $0x4,%esp
  801c8f:	ff 75 10             	pushl  0x10(%ebp)
  801c92:	ff 75 0c             	pushl  0xc(%ebp)
  801c95:	50                   	push   %eax
  801c96:	e8 45 01 00 00       	call   801de0 <nsipc_bind>
  801c9b:	83 c4 10             	add    $0x10,%esp
}
  801c9e:	c9                   	leave  
  801c9f:	c3                   	ret    

00801ca0 <shutdown>:
{
  801ca0:	f3 0f 1e fb          	endbr32 
  801ca4:	55                   	push   %ebp
  801ca5:	89 e5                	mov    %esp,%ebp
  801ca7:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801caa:	8b 45 08             	mov    0x8(%ebp),%eax
  801cad:	e8 ed fe ff ff       	call   801b9f <fd2sockid>
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	78 0f                	js     801cc5 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801cb6:	83 ec 08             	sub    $0x8,%esp
  801cb9:	ff 75 0c             	pushl  0xc(%ebp)
  801cbc:	50                   	push   %eax
  801cbd:	e8 57 01 00 00       	call   801e19 <nsipc_shutdown>
  801cc2:	83 c4 10             	add    $0x10,%esp
}
  801cc5:	c9                   	leave  
  801cc6:	c3                   	ret    

00801cc7 <connect>:
{
  801cc7:	f3 0f 1e fb          	endbr32 
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801cd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd4:	e8 c6 fe ff ff       	call   801b9f <fd2sockid>
  801cd9:	85 c0                	test   %eax,%eax
  801cdb:	78 12                	js     801cef <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801cdd:	83 ec 04             	sub    $0x4,%esp
  801ce0:	ff 75 10             	pushl  0x10(%ebp)
  801ce3:	ff 75 0c             	pushl  0xc(%ebp)
  801ce6:	50                   	push   %eax
  801ce7:	e8 71 01 00 00       	call   801e5d <nsipc_connect>
  801cec:	83 c4 10             	add    $0x10,%esp
}
  801cef:	c9                   	leave  
  801cf0:	c3                   	ret    

00801cf1 <listen>:
{
  801cf1:	f3 0f 1e fb          	endbr32 
  801cf5:	55                   	push   %ebp
  801cf6:	89 e5                	mov    %esp,%ebp
  801cf8:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfe:	e8 9c fe ff ff       	call   801b9f <fd2sockid>
  801d03:	85 c0                	test   %eax,%eax
  801d05:	78 0f                	js     801d16 <listen+0x25>
	return nsipc_listen(r, backlog);
  801d07:	83 ec 08             	sub    $0x8,%esp
  801d0a:	ff 75 0c             	pushl  0xc(%ebp)
  801d0d:	50                   	push   %eax
  801d0e:	e8 83 01 00 00       	call   801e96 <nsipc_listen>
  801d13:	83 c4 10             	add    $0x10,%esp
}
  801d16:	c9                   	leave  
  801d17:	c3                   	ret    

00801d18 <socket>:

int
socket(int domain, int type, int protocol)
{
  801d18:	f3 0f 1e fb          	endbr32 
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
  801d1f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d22:	ff 75 10             	pushl  0x10(%ebp)
  801d25:	ff 75 0c             	pushl  0xc(%ebp)
  801d28:	ff 75 08             	pushl  0x8(%ebp)
  801d2b:	e8 65 02 00 00       	call   801f95 <nsipc_socket>
  801d30:	83 c4 10             	add    $0x10,%esp
  801d33:	85 c0                	test   %eax,%eax
  801d35:	78 05                	js     801d3c <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801d37:	e8 93 fe ff ff       	call   801bcf <alloc_sockfd>
}
  801d3c:	c9                   	leave  
  801d3d:	c3                   	ret    

00801d3e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
  801d41:	53                   	push   %ebx
  801d42:	83 ec 04             	sub    $0x4,%esp
  801d45:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d47:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801d4e:	74 26                	je     801d76 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d50:	6a 07                	push   $0x7
  801d52:	68 00 60 80 00       	push   $0x806000
  801d57:	53                   	push   %ebx
  801d58:	ff 35 04 40 80 00    	pushl  0x804004
  801d5e:	e8 c8 07 00 00       	call   80252b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d63:	83 c4 0c             	add    $0xc,%esp
  801d66:	6a 00                	push   $0x0
  801d68:	6a 00                	push   $0x0
  801d6a:	6a 00                	push   $0x0
  801d6c:	e8 4d 07 00 00       	call   8024be <ipc_recv>
}
  801d71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d74:	c9                   	leave  
  801d75:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d76:	83 ec 0c             	sub    $0xc,%esp
  801d79:	6a 02                	push   $0x2
  801d7b:	e8 03 08 00 00       	call   802583 <ipc_find_env>
  801d80:	a3 04 40 80 00       	mov    %eax,0x804004
  801d85:	83 c4 10             	add    $0x10,%esp
  801d88:	eb c6                	jmp    801d50 <nsipc+0x12>

00801d8a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d8a:	f3 0f 1e fb          	endbr32 
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	56                   	push   %esi
  801d92:	53                   	push   %ebx
  801d93:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d96:	8b 45 08             	mov    0x8(%ebp),%eax
  801d99:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d9e:	8b 06                	mov    (%esi),%eax
  801da0:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801da5:	b8 01 00 00 00       	mov    $0x1,%eax
  801daa:	e8 8f ff ff ff       	call   801d3e <nsipc>
  801daf:	89 c3                	mov    %eax,%ebx
  801db1:	85 c0                	test   %eax,%eax
  801db3:	79 09                	jns    801dbe <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801db5:	89 d8                	mov    %ebx,%eax
  801db7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dba:	5b                   	pop    %ebx
  801dbb:	5e                   	pop    %esi
  801dbc:	5d                   	pop    %ebp
  801dbd:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801dbe:	83 ec 04             	sub    $0x4,%esp
  801dc1:	ff 35 10 60 80 00    	pushl  0x806010
  801dc7:	68 00 60 80 00       	push   $0x806000
  801dcc:	ff 75 0c             	pushl  0xc(%ebp)
  801dcf:	e8 5d ee ff ff       	call   800c31 <memmove>
		*addrlen = ret->ret_addrlen;
  801dd4:	a1 10 60 80 00       	mov    0x806010,%eax
  801dd9:	89 06                	mov    %eax,(%esi)
  801ddb:	83 c4 10             	add    $0x10,%esp
	return r;
  801dde:	eb d5                	jmp    801db5 <nsipc_accept+0x2b>

00801de0 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801de0:	f3 0f 1e fb          	endbr32 
  801de4:	55                   	push   %ebp
  801de5:	89 e5                	mov    %esp,%ebp
  801de7:	53                   	push   %ebx
  801de8:	83 ec 08             	sub    $0x8,%esp
  801deb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801dee:	8b 45 08             	mov    0x8(%ebp),%eax
  801df1:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801df6:	53                   	push   %ebx
  801df7:	ff 75 0c             	pushl  0xc(%ebp)
  801dfa:	68 04 60 80 00       	push   $0x806004
  801dff:	e8 2d ee ff ff       	call   800c31 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e04:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801e0a:	b8 02 00 00 00       	mov    $0x2,%eax
  801e0f:	e8 2a ff ff ff       	call   801d3e <nsipc>
}
  801e14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e17:	c9                   	leave  
  801e18:	c3                   	ret    

00801e19 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e19:	f3 0f 1e fb          	endbr32 
  801e1d:	55                   	push   %ebp
  801e1e:	89 e5                	mov    %esp,%ebp
  801e20:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e23:	8b 45 08             	mov    0x8(%ebp),%eax
  801e26:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e33:	b8 03 00 00 00       	mov    $0x3,%eax
  801e38:	e8 01 ff ff ff       	call   801d3e <nsipc>
}
  801e3d:	c9                   	leave  
  801e3e:	c3                   	ret    

00801e3f <nsipc_close>:

int
nsipc_close(int s)
{
  801e3f:	f3 0f 1e fb          	endbr32 
  801e43:	55                   	push   %ebp
  801e44:	89 e5                	mov    %esp,%ebp
  801e46:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e49:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4c:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801e51:	b8 04 00 00 00       	mov    $0x4,%eax
  801e56:	e8 e3 fe ff ff       	call   801d3e <nsipc>
}
  801e5b:	c9                   	leave  
  801e5c:	c3                   	ret    

00801e5d <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e5d:	f3 0f 1e fb          	endbr32 
  801e61:	55                   	push   %ebp
  801e62:	89 e5                	mov    %esp,%ebp
  801e64:	53                   	push   %ebx
  801e65:	83 ec 08             	sub    $0x8,%esp
  801e68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e73:	53                   	push   %ebx
  801e74:	ff 75 0c             	pushl  0xc(%ebp)
  801e77:	68 04 60 80 00       	push   $0x806004
  801e7c:	e8 b0 ed ff ff       	call   800c31 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e81:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e87:	b8 05 00 00 00       	mov    $0x5,%eax
  801e8c:	e8 ad fe ff ff       	call   801d3e <nsipc>
}
  801e91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e94:	c9                   	leave  
  801e95:	c3                   	ret    

00801e96 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e96:	f3 0f 1e fb          	endbr32 
  801e9a:	55                   	push   %ebp
  801e9b:	89 e5                	mov    %esp,%ebp
  801e9d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eab:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801eb0:	b8 06 00 00 00       	mov    $0x6,%eax
  801eb5:	e8 84 fe ff ff       	call   801d3e <nsipc>
}
  801eba:	c9                   	leave  
  801ebb:	c3                   	ret    

00801ebc <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ebc:	f3 0f 1e fb          	endbr32 
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	56                   	push   %esi
  801ec4:	53                   	push   %ebx
  801ec5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ed0:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801ed6:	8b 45 14             	mov    0x14(%ebp),%eax
  801ed9:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ede:	b8 07 00 00 00       	mov    $0x7,%eax
  801ee3:	e8 56 fe ff ff       	call   801d3e <nsipc>
  801ee8:	89 c3                	mov    %eax,%ebx
  801eea:	85 c0                	test   %eax,%eax
  801eec:	78 26                	js     801f14 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801eee:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801ef4:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801ef9:	0f 4e c6             	cmovle %esi,%eax
  801efc:	39 c3                	cmp    %eax,%ebx
  801efe:	7f 1d                	jg     801f1d <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f00:	83 ec 04             	sub    $0x4,%esp
  801f03:	53                   	push   %ebx
  801f04:	68 00 60 80 00       	push   $0x806000
  801f09:	ff 75 0c             	pushl  0xc(%ebp)
  801f0c:	e8 20 ed ff ff       	call   800c31 <memmove>
  801f11:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f14:	89 d8                	mov    %ebx,%eax
  801f16:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f19:	5b                   	pop    %ebx
  801f1a:	5e                   	pop    %esi
  801f1b:	5d                   	pop    %ebp
  801f1c:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801f1d:	68 4f 2d 80 00       	push   $0x802d4f
  801f22:	68 b7 2c 80 00       	push   $0x802cb7
  801f27:	6a 62                	push   $0x62
  801f29:	68 64 2d 80 00       	push   $0x802d64
  801f2e:	e8 0f e4 ff ff       	call   800342 <_panic>

00801f33 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f33:	f3 0f 1e fb          	endbr32 
  801f37:	55                   	push   %ebp
  801f38:	89 e5                	mov    %esp,%ebp
  801f3a:	53                   	push   %ebx
  801f3b:	83 ec 04             	sub    $0x4,%esp
  801f3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f41:	8b 45 08             	mov    0x8(%ebp),%eax
  801f44:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801f49:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f4f:	7f 2e                	jg     801f7f <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f51:	83 ec 04             	sub    $0x4,%esp
  801f54:	53                   	push   %ebx
  801f55:	ff 75 0c             	pushl  0xc(%ebp)
  801f58:	68 0c 60 80 00       	push   $0x80600c
  801f5d:	e8 cf ec ff ff       	call   800c31 <memmove>
	nsipcbuf.send.req_size = size;
  801f62:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801f68:	8b 45 14             	mov    0x14(%ebp),%eax
  801f6b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801f70:	b8 08 00 00 00       	mov    $0x8,%eax
  801f75:	e8 c4 fd ff ff       	call   801d3e <nsipc>
}
  801f7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f7d:	c9                   	leave  
  801f7e:	c3                   	ret    
	assert(size < 1600);
  801f7f:	68 70 2d 80 00       	push   $0x802d70
  801f84:	68 b7 2c 80 00       	push   $0x802cb7
  801f89:	6a 6d                	push   $0x6d
  801f8b:	68 64 2d 80 00       	push   $0x802d64
  801f90:	e8 ad e3 ff ff       	call   800342 <_panic>

00801f95 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f95:	f3 0f 1e fb          	endbr32 
  801f99:	55                   	push   %ebp
  801f9a:	89 e5                	mov    %esp,%ebp
  801f9c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801fa7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801faa:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801faf:	8b 45 10             	mov    0x10(%ebp),%eax
  801fb2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801fb7:	b8 09 00 00 00       	mov    $0x9,%eax
  801fbc:	e8 7d fd ff ff       	call   801d3e <nsipc>
}
  801fc1:	c9                   	leave  
  801fc2:	c3                   	ret    

00801fc3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801fc3:	f3 0f 1e fb          	endbr32 
  801fc7:	55                   	push   %ebp
  801fc8:	89 e5                	mov    %esp,%ebp
  801fca:	56                   	push   %esi
  801fcb:	53                   	push   %ebx
  801fcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801fcf:	83 ec 0c             	sub    $0xc,%esp
  801fd2:	ff 75 08             	pushl  0x8(%ebp)
  801fd5:	e8 cc f1 ff ff       	call   8011a6 <fd2data>
  801fda:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801fdc:	83 c4 08             	add    $0x8,%esp
  801fdf:	68 7c 2d 80 00       	push   $0x802d7c
  801fe4:	53                   	push   %ebx
  801fe5:	e8 49 ea ff ff       	call   800a33 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801fea:	8b 46 04             	mov    0x4(%esi),%eax
  801fed:	2b 06                	sub    (%esi),%eax
  801fef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ff5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ffc:	00 00 00 
	stat->st_dev = &devpipe;
  801fff:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  802006:	30 80 00 
	return 0;
}
  802009:	b8 00 00 00 00       	mov    $0x0,%eax
  80200e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802011:	5b                   	pop    %ebx
  802012:	5e                   	pop    %esi
  802013:	5d                   	pop    %ebp
  802014:	c3                   	ret    

00802015 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802015:	f3 0f 1e fb          	endbr32 
  802019:	55                   	push   %ebp
  80201a:	89 e5                	mov    %esp,%ebp
  80201c:	53                   	push   %ebx
  80201d:	83 ec 0c             	sub    $0xc,%esp
  802020:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802023:	53                   	push   %ebx
  802024:	6a 00                	push   $0x0
  802026:	e8 bc ee ff ff       	call   800ee7 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80202b:	89 1c 24             	mov    %ebx,(%esp)
  80202e:	e8 73 f1 ff ff       	call   8011a6 <fd2data>
  802033:	83 c4 08             	add    $0x8,%esp
  802036:	50                   	push   %eax
  802037:	6a 00                	push   $0x0
  802039:	e8 a9 ee ff ff       	call   800ee7 <sys_page_unmap>
}
  80203e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802041:	c9                   	leave  
  802042:	c3                   	ret    

00802043 <_pipeisclosed>:
{
  802043:	55                   	push   %ebp
  802044:	89 e5                	mov    %esp,%ebp
  802046:	57                   	push   %edi
  802047:	56                   	push   %esi
  802048:	53                   	push   %ebx
  802049:	83 ec 1c             	sub    $0x1c,%esp
  80204c:	89 c7                	mov    %eax,%edi
  80204e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802050:	a1 20 44 80 00       	mov    0x804420,%eax
  802055:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802058:	83 ec 0c             	sub    $0xc,%esp
  80205b:	57                   	push   %edi
  80205c:	e8 5f 05 00 00       	call   8025c0 <pageref>
  802061:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802064:	89 34 24             	mov    %esi,(%esp)
  802067:	e8 54 05 00 00       	call   8025c0 <pageref>
		nn = thisenv->env_runs;
  80206c:	8b 15 20 44 80 00    	mov    0x804420,%edx
  802072:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802075:	83 c4 10             	add    $0x10,%esp
  802078:	39 cb                	cmp    %ecx,%ebx
  80207a:	74 1b                	je     802097 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80207c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80207f:	75 cf                	jne    802050 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802081:	8b 42 58             	mov    0x58(%edx),%eax
  802084:	6a 01                	push   $0x1
  802086:	50                   	push   %eax
  802087:	53                   	push   %ebx
  802088:	68 83 2d 80 00       	push   $0x802d83
  80208d:	e8 97 e3 ff ff       	call   800429 <cprintf>
  802092:	83 c4 10             	add    $0x10,%esp
  802095:	eb b9                	jmp    802050 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  802097:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80209a:	0f 94 c0             	sete   %al
  80209d:	0f b6 c0             	movzbl %al,%eax
}
  8020a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    

008020a8 <devpipe_write>:
{
  8020a8:	f3 0f 1e fb          	endbr32 
  8020ac:	55                   	push   %ebp
  8020ad:	89 e5                	mov    %esp,%ebp
  8020af:	57                   	push   %edi
  8020b0:	56                   	push   %esi
  8020b1:	53                   	push   %ebx
  8020b2:	83 ec 28             	sub    $0x28,%esp
  8020b5:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8020b8:	56                   	push   %esi
  8020b9:	e8 e8 f0 ff ff       	call   8011a6 <fd2data>
  8020be:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8020c0:	83 c4 10             	add    $0x10,%esp
  8020c3:	bf 00 00 00 00       	mov    $0x0,%edi
  8020c8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020cb:	74 4f                	je     80211c <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020cd:	8b 43 04             	mov    0x4(%ebx),%eax
  8020d0:	8b 0b                	mov    (%ebx),%ecx
  8020d2:	8d 51 20             	lea    0x20(%ecx),%edx
  8020d5:	39 d0                	cmp    %edx,%eax
  8020d7:	72 14                	jb     8020ed <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8020d9:	89 da                	mov    %ebx,%edx
  8020db:	89 f0                	mov    %esi,%eax
  8020dd:	e8 61 ff ff ff       	call   802043 <_pipeisclosed>
  8020e2:	85 c0                	test   %eax,%eax
  8020e4:	75 3b                	jne    802121 <devpipe_write+0x79>
			sys_yield();
  8020e6:	e8 8e ed ff ff       	call   800e79 <sys_yield>
  8020eb:	eb e0                	jmp    8020cd <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020f0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8020f4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020f7:	89 c2                	mov    %eax,%edx
  8020f9:	c1 fa 1f             	sar    $0x1f,%edx
  8020fc:	89 d1                	mov    %edx,%ecx
  8020fe:	c1 e9 1b             	shr    $0x1b,%ecx
  802101:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802104:	83 e2 1f             	and    $0x1f,%edx
  802107:	29 ca                	sub    %ecx,%edx
  802109:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80210d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802111:	83 c0 01             	add    $0x1,%eax
  802114:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802117:	83 c7 01             	add    $0x1,%edi
  80211a:	eb ac                	jmp    8020c8 <devpipe_write+0x20>
	return i;
  80211c:	8b 45 10             	mov    0x10(%ebp),%eax
  80211f:	eb 05                	jmp    802126 <devpipe_write+0x7e>
				return 0;
  802121:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802126:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802129:	5b                   	pop    %ebx
  80212a:	5e                   	pop    %esi
  80212b:	5f                   	pop    %edi
  80212c:	5d                   	pop    %ebp
  80212d:	c3                   	ret    

0080212e <devpipe_read>:
{
  80212e:	f3 0f 1e fb          	endbr32 
  802132:	55                   	push   %ebp
  802133:	89 e5                	mov    %esp,%ebp
  802135:	57                   	push   %edi
  802136:	56                   	push   %esi
  802137:	53                   	push   %ebx
  802138:	83 ec 18             	sub    $0x18,%esp
  80213b:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80213e:	57                   	push   %edi
  80213f:	e8 62 f0 ff ff       	call   8011a6 <fd2data>
  802144:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802146:	83 c4 10             	add    $0x10,%esp
  802149:	be 00 00 00 00       	mov    $0x0,%esi
  80214e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802151:	75 14                	jne    802167 <devpipe_read+0x39>
	return i;
  802153:	8b 45 10             	mov    0x10(%ebp),%eax
  802156:	eb 02                	jmp    80215a <devpipe_read+0x2c>
				return i;
  802158:	89 f0                	mov    %esi,%eax
}
  80215a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
			sys_yield();
  802162:	e8 12 ed ff ff       	call   800e79 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802167:	8b 03                	mov    (%ebx),%eax
  802169:	3b 43 04             	cmp    0x4(%ebx),%eax
  80216c:	75 18                	jne    802186 <devpipe_read+0x58>
			if (i > 0)
  80216e:	85 f6                	test   %esi,%esi
  802170:	75 e6                	jne    802158 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  802172:	89 da                	mov    %ebx,%edx
  802174:	89 f8                	mov    %edi,%eax
  802176:	e8 c8 fe ff ff       	call   802043 <_pipeisclosed>
  80217b:	85 c0                	test   %eax,%eax
  80217d:	74 e3                	je     802162 <devpipe_read+0x34>
				return 0;
  80217f:	b8 00 00 00 00       	mov    $0x0,%eax
  802184:	eb d4                	jmp    80215a <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802186:	99                   	cltd   
  802187:	c1 ea 1b             	shr    $0x1b,%edx
  80218a:	01 d0                	add    %edx,%eax
  80218c:	83 e0 1f             	and    $0x1f,%eax
  80218f:	29 d0                	sub    %edx,%eax
  802191:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802196:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802199:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80219c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80219f:	83 c6 01             	add    $0x1,%esi
  8021a2:	eb aa                	jmp    80214e <devpipe_read+0x20>

008021a4 <pipe>:
{
  8021a4:	f3 0f 1e fb          	endbr32 
  8021a8:	55                   	push   %ebp
  8021a9:	89 e5                	mov    %esp,%ebp
  8021ab:	56                   	push   %esi
  8021ac:	53                   	push   %ebx
  8021ad:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8021b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021b3:	50                   	push   %eax
  8021b4:	e8 08 f0 ff ff       	call   8011c1 <fd_alloc>
  8021b9:	89 c3                	mov    %eax,%ebx
  8021bb:	83 c4 10             	add    $0x10,%esp
  8021be:	85 c0                	test   %eax,%eax
  8021c0:	0f 88 23 01 00 00    	js     8022e9 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021c6:	83 ec 04             	sub    $0x4,%esp
  8021c9:	68 07 04 00 00       	push   $0x407
  8021ce:	ff 75 f4             	pushl  -0xc(%ebp)
  8021d1:	6a 00                	push   $0x0
  8021d3:	e8 c4 ec ff ff       	call   800e9c <sys_page_alloc>
  8021d8:	89 c3                	mov    %eax,%ebx
  8021da:	83 c4 10             	add    $0x10,%esp
  8021dd:	85 c0                	test   %eax,%eax
  8021df:	0f 88 04 01 00 00    	js     8022e9 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8021e5:	83 ec 0c             	sub    $0xc,%esp
  8021e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021eb:	50                   	push   %eax
  8021ec:	e8 d0 ef ff ff       	call   8011c1 <fd_alloc>
  8021f1:	89 c3                	mov    %eax,%ebx
  8021f3:	83 c4 10             	add    $0x10,%esp
  8021f6:	85 c0                	test   %eax,%eax
  8021f8:	0f 88 db 00 00 00    	js     8022d9 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021fe:	83 ec 04             	sub    $0x4,%esp
  802201:	68 07 04 00 00       	push   $0x407
  802206:	ff 75 f0             	pushl  -0x10(%ebp)
  802209:	6a 00                	push   $0x0
  80220b:	e8 8c ec ff ff       	call   800e9c <sys_page_alloc>
  802210:	89 c3                	mov    %eax,%ebx
  802212:	83 c4 10             	add    $0x10,%esp
  802215:	85 c0                	test   %eax,%eax
  802217:	0f 88 bc 00 00 00    	js     8022d9 <pipe+0x135>
	va = fd2data(fd0);
  80221d:	83 ec 0c             	sub    $0xc,%esp
  802220:	ff 75 f4             	pushl  -0xc(%ebp)
  802223:	e8 7e ef ff ff       	call   8011a6 <fd2data>
  802228:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80222a:	83 c4 0c             	add    $0xc,%esp
  80222d:	68 07 04 00 00       	push   $0x407
  802232:	50                   	push   %eax
  802233:	6a 00                	push   $0x0
  802235:	e8 62 ec ff ff       	call   800e9c <sys_page_alloc>
  80223a:	89 c3                	mov    %eax,%ebx
  80223c:	83 c4 10             	add    $0x10,%esp
  80223f:	85 c0                	test   %eax,%eax
  802241:	0f 88 82 00 00 00    	js     8022c9 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802247:	83 ec 0c             	sub    $0xc,%esp
  80224a:	ff 75 f0             	pushl  -0x10(%ebp)
  80224d:	e8 54 ef ff ff       	call   8011a6 <fd2data>
  802252:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802259:	50                   	push   %eax
  80225a:	6a 00                	push   $0x0
  80225c:	56                   	push   %esi
  80225d:	6a 00                	push   $0x0
  80225f:	e8 5e ec ff ff       	call   800ec2 <sys_page_map>
  802264:	89 c3                	mov    %eax,%ebx
  802266:	83 c4 20             	add    $0x20,%esp
  802269:	85 c0                	test   %eax,%eax
  80226b:	78 4e                	js     8022bb <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  80226d:	a1 7c 30 80 00       	mov    0x80307c,%eax
  802272:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802275:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802277:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80227a:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802281:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802284:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802286:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802289:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802290:	83 ec 0c             	sub    $0xc,%esp
  802293:	ff 75 f4             	pushl  -0xc(%ebp)
  802296:	e8 f7 ee ff ff       	call   801192 <fd2num>
  80229b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80229e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8022a0:	83 c4 04             	add    $0x4,%esp
  8022a3:	ff 75 f0             	pushl  -0x10(%ebp)
  8022a6:	e8 e7 ee ff ff       	call   801192 <fd2num>
  8022ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022ae:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8022b1:	83 c4 10             	add    $0x10,%esp
  8022b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8022b9:	eb 2e                	jmp    8022e9 <pipe+0x145>
	sys_page_unmap(0, va);
  8022bb:	83 ec 08             	sub    $0x8,%esp
  8022be:	56                   	push   %esi
  8022bf:	6a 00                	push   $0x0
  8022c1:	e8 21 ec ff ff       	call   800ee7 <sys_page_unmap>
  8022c6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8022c9:	83 ec 08             	sub    $0x8,%esp
  8022cc:	ff 75 f0             	pushl  -0x10(%ebp)
  8022cf:	6a 00                	push   $0x0
  8022d1:	e8 11 ec ff ff       	call   800ee7 <sys_page_unmap>
  8022d6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8022d9:	83 ec 08             	sub    $0x8,%esp
  8022dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8022df:	6a 00                	push   $0x0
  8022e1:	e8 01 ec ff ff       	call   800ee7 <sys_page_unmap>
  8022e6:	83 c4 10             	add    $0x10,%esp
}
  8022e9:	89 d8                	mov    %ebx,%eax
  8022eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022ee:	5b                   	pop    %ebx
  8022ef:	5e                   	pop    %esi
  8022f0:	5d                   	pop    %ebp
  8022f1:	c3                   	ret    

008022f2 <pipeisclosed>:
{
  8022f2:	f3 0f 1e fb          	endbr32 
  8022f6:	55                   	push   %ebp
  8022f7:	89 e5                	mov    %esp,%ebp
  8022f9:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022ff:	50                   	push   %eax
  802300:	ff 75 08             	pushl  0x8(%ebp)
  802303:	e8 0f ef ff ff       	call   801217 <fd_lookup>
  802308:	83 c4 10             	add    $0x10,%esp
  80230b:	85 c0                	test   %eax,%eax
  80230d:	78 18                	js     802327 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  80230f:	83 ec 0c             	sub    $0xc,%esp
  802312:	ff 75 f4             	pushl  -0xc(%ebp)
  802315:	e8 8c ee ff ff       	call   8011a6 <fd2data>
  80231a:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80231c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80231f:	e8 1f fd ff ff       	call   802043 <_pipeisclosed>
  802324:	83 c4 10             	add    $0x10,%esp
}
  802327:	c9                   	leave  
  802328:	c3                   	ret    

00802329 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802329:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  80232d:	b8 00 00 00 00       	mov    $0x0,%eax
  802332:	c3                   	ret    

00802333 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802333:	f3 0f 1e fb          	endbr32 
  802337:	55                   	push   %ebp
  802338:	89 e5                	mov    %esp,%ebp
  80233a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80233d:	68 9b 2d 80 00       	push   $0x802d9b
  802342:	ff 75 0c             	pushl  0xc(%ebp)
  802345:	e8 e9 e6 ff ff       	call   800a33 <strcpy>
	return 0;
}
  80234a:	b8 00 00 00 00       	mov    $0x0,%eax
  80234f:	c9                   	leave  
  802350:	c3                   	ret    

00802351 <devcons_write>:
{
  802351:	f3 0f 1e fb          	endbr32 
  802355:	55                   	push   %ebp
  802356:	89 e5                	mov    %esp,%ebp
  802358:	57                   	push   %edi
  802359:	56                   	push   %esi
  80235a:	53                   	push   %ebx
  80235b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802361:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802366:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80236c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80236f:	73 31                	jae    8023a2 <devcons_write+0x51>
		m = n - tot;
  802371:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802374:	29 f3                	sub    %esi,%ebx
  802376:	83 fb 7f             	cmp    $0x7f,%ebx
  802379:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80237e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802381:	83 ec 04             	sub    $0x4,%esp
  802384:	53                   	push   %ebx
  802385:	89 f0                	mov    %esi,%eax
  802387:	03 45 0c             	add    0xc(%ebp),%eax
  80238a:	50                   	push   %eax
  80238b:	57                   	push   %edi
  80238c:	e8 a0 e8 ff ff       	call   800c31 <memmove>
		sys_cputs(buf, m);
  802391:	83 c4 08             	add    $0x8,%esp
  802394:	53                   	push   %ebx
  802395:	57                   	push   %edi
  802396:	e8 52 ea ff ff       	call   800ded <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80239b:	01 de                	add    %ebx,%esi
  80239d:	83 c4 10             	add    $0x10,%esp
  8023a0:	eb ca                	jmp    80236c <devcons_write+0x1b>
}
  8023a2:	89 f0                	mov    %esi,%eax
  8023a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023a7:	5b                   	pop    %ebx
  8023a8:	5e                   	pop    %esi
  8023a9:	5f                   	pop    %edi
  8023aa:	5d                   	pop    %ebp
  8023ab:	c3                   	ret    

008023ac <devcons_read>:
{
  8023ac:	f3 0f 1e fb          	endbr32 
  8023b0:	55                   	push   %ebp
  8023b1:	89 e5                	mov    %esp,%ebp
  8023b3:	83 ec 08             	sub    $0x8,%esp
  8023b6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8023bb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023bf:	74 21                	je     8023e2 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8023c1:	e8 49 ea ff ff       	call   800e0f <sys_cgetc>
  8023c6:	85 c0                	test   %eax,%eax
  8023c8:	75 07                	jne    8023d1 <devcons_read+0x25>
		sys_yield();
  8023ca:	e8 aa ea ff ff       	call   800e79 <sys_yield>
  8023cf:	eb f0                	jmp    8023c1 <devcons_read+0x15>
	if (c < 0)
  8023d1:	78 0f                	js     8023e2 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8023d3:	83 f8 04             	cmp    $0x4,%eax
  8023d6:	74 0c                	je     8023e4 <devcons_read+0x38>
	*(char*)vbuf = c;
  8023d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023db:	88 02                	mov    %al,(%edx)
	return 1;
  8023dd:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8023e2:	c9                   	leave  
  8023e3:	c3                   	ret    
		return 0;
  8023e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8023e9:	eb f7                	jmp    8023e2 <devcons_read+0x36>

008023eb <cputchar>:
{
  8023eb:	f3 0f 1e fb          	endbr32 
  8023ef:	55                   	push   %ebp
  8023f0:	89 e5                	mov    %esp,%ebp
  8023f2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8023f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f8:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8023fb:	6a 01                	push   $0x1
  8023fd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802400:	50                   	push   %eax
  802401:	e8 e7 e9 ff ff       	call   800ded <sys_cputs>
}
  802406:	83 c4 10             	add    $0x10,%esp
  802409:	c9                   	leave  
  80240a:	c3                   	ret    

0080240b <getchar>:
{
  80240b:	f3 0f 1e fb          	endbr32 
  80240f:	55                   	push   %ebp
  802410:	89 e5                	mov    %esp,%ebp
  802412:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802415:	6a 01                	push   $0x1
  802417:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80241a:	50                   	push   %eax
  80241b:	6a 00                	push   $0x0
  80241d:	e8 7d f0 ff ff       	call   80149f <read>
	if (r < 0)
  802422:	83 c4 10             	add    $0x10,%esp
  802425:	85 c0                	test   %eax,%eax
  802427:	78 06                	js     80242f <getchar+0x24>
	if (r < 1)
  802429:	74 06                	je     802431 <getchar+0x26>
	return c;
  80242b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80242f:	c9                   	leave  
  802430:	c3                   	ret    
		return -E_EOF;
  802431:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802436:	eb f7                	jmp    80242f <getchar+0x24>

00802438 <iscons>:
{
  802438:	f3 0f 1e fb          	endbr32 
  80243c:	55                   	push   %ebp
  80243d:	89 e5                	mov    %esp,%ebp
  80243f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802442:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802445:	50                   	push   %eax
  802446:	ff 75 08             	pushl  0x8(%ebp)
  802449:	e8 c9 ed ff ff       	call   801217 <fd_lookup>
  80244e:	83 c4 10             	add    $0x10,%esp
  802451:	85 c0                	test   %eax,%eax
  802453:	78 11                	js     802466 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  802455:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802458:	8b 15 98 30 80 00    	mov    0x803098,%edx
  80245e:	39 10                	cmp    %edx,(%eax)
  802460:	0f 94 c0             	sete   %al
  802463:	0f b6 c0             	movzbl %al,%eax
}
  802466:	c9                   	leave  
  802467:	c3                   	ret    

00802468 <opencons>:
{
  802468:	f3 0f 1e fb          	endbr32 
  80246c:	55                   	push   %ebp
  80246d:	89 e5                	mov    %esp,%ebp
  80246f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802472:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802475:	50                   	push   %eax
  802476:	e8 46 ed ff ff       	call   8011c1 <fd_alloc>
  80247b:	83 c4 10             	add    $0x10,%esp
  80247e:	85 c0                	test   %eax,%eax
  802480:	78 3a                	js     8024bc <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802482:	83 ec 04             	sub    $0x4,%esp
  802485:	68 07 04 00 00       	push   $0x407
  80248a:	ff 75 f4             	pushl  -0xc(%ebp)
  80248d:	6a 00                	push   $0x0
  80248f:	e8 08 ea ff ff       	call   800e9c <sys_page_alloc>
  802494:	83 c4 10             	add    $0x10,%esp
  802497:	85 c0                	test   %eax,%eax
  802499:	78 21                	js     8024bc <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80249b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80249e:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8024a4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024a9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024b0:	83 ec 0c             	sub    $0xc,%esp
  8024b3:	50                   	push   %eax
  8024b4:	e8 d9 ec ff ff       	call   801192 <fd2num>
  8024b9:	83 c4 10             	add    $0x10,%esp
}
  8024bc:	c9                   	leave  
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
  8024de:	e8 bf ea ff ff       	call   800fa2 <sys_ipc_recv>
  8024e3:	83 c4 10             	add    $0x10,%esp
  8024e6:	85 c0                	test   %eax,%eax
  8024e8:	75 2b                	jne    802515 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  8024ea:	85 f6                	test   %esi,%esi
  8024ec:	74 0a                	je     8024f8 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  8024ee:	a1 20 44 80 00       	mov    0x804420,%eax
  8024f3:	8b 40 74             	mov    0x74(%eax),%eax
  8024f6:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  8024f8:	85 db                	test   %ebx,%ebx
  8024fa:	74 0a                	je     802506 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  8024fc:	a1 20 44 80 00       	mov    0x804420,%eax
  802501:	8b 40 78             	mov    0x78(%eax),%eax
  802504:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  802506:	a1 20 44 80 00       	mov    0x804420,%eax
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
  802551:	e8 25 ea ff ff       	call   800f7b <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  802556:	83 c4 10             	add    $0x10,%esp
  802559:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80255c:	75 07                	jne    802565 <ipc_send+0x3a>
			sys_yield();
  80255e:	e8 16 e9 ff ff       	call   800e79 <sys_yield>
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
  802572:	68 a7 2d 80 00       	push   $0x802da7
  802577:	6a 48                	push   $0x48
  802579:	68 b5 2d 80 00       	push   $0x802db5
  80257e:	e8 bf dd ff ff       	call   800342 <_panic>

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
