
obj/user/echo.debug:     file format elf32-i386


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
  80002c:	e8 b7 00 00 00       	call   8000e8 <libmain>
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
  800040:	8b 7d 08             	mov    0x8(%ebp),%edi
  800043:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
  800046:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  80004d:	83 ff 01             	cmp    $0x1,%edi
  800050:	7f 07                	jg     800059 <umain+0x26>
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  800052:	bb 01 00 00 00       	mov    $0x1,%ebx
  800057:	eb 60                	jmp    8000b9 <umain+0x86>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800059:	83 ec 08             	sub    $0x8,%esp
  80005c:	68 00 24 80 00       	push   $0x802400
  800061:	ff 76 04             	pushl  0x4(%esi)
  800064:	e8 e9 01 00 00       	call   800252 <strcmp>
  800069:	83 c4 10             	add    $0x10,%esp
	nflag = 0;
  80006c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800073:	85 c0                	test   %eax,%eax
  800075:	75 db                	jne    800052 <umain+0x1f>
		argc--;
  800077:	83 ef 01             	sub    $0x1,%edi
		argv++;
  80007a:	83 c6 04             	add    $0x4,%esi
		nflag = 1;
  80007d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  800084:	eb cc                	jmp    800052 <umain+0x1f>
		if (i > 1)
			write(1, " ", 1);
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 01                	push   $0x1
  80008b:	68 03 24 80 00       	push   $0x802403
  800090:	6a 01                	push   $0x1
  800092:	e8 df 0a 00 00       	call   800b76 <write>
  800097:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000a0:	e8 ab 00 00 00       	call   800150 <strlen>
  8000a5:	83 c4 0c             	add    $0xc,%esp
  8000a8:	50                   	push   %eax
  8000a9:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ac:	6a 01                	push   $0x1
  8000ae:	e8 c3 0a 00 00       	call   800b76 <write>
	for (i = 1; i < argc; i++) {
  8000b3:	83 c3 01             	add    $0x1,%ebx
  8000b6:	83 c4 10             	add    $0x10,%esp
  8000b9:	39 df                	cmp    %ebx,%edi
  8000bb:	7e 07                	jle    8000c4 <umain+0x91>
		if (i > 1)
  8000bd:	83 fb 01             	cmp    $0x1,%ebx
  8000c0:	7f c4                	jg     800086 <umain+0x53>
  8000c2:	eb d6                	jmp    80009a <umain+0x67>
	}
	if (!nflag)
  8000c4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c8:	74 08                	je     8000d2 <umain+0x9f>
		write(1, "\n", 1);
}
  8000ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    
		write(1, "\n", 1);
  8000d2:	83 ec 04             	sub    $0x4,%esp
  8000d5:	6a 01                	push   $0x1
  8000d7:	68 84 25 80 00       	push   $0x802584
  8000dc:	6a 01                	push   $0x1
  8000de:	e8 93 0a 00 00       	call   800b76 <write>
  8000e3:	83 c4 10             	add    $0x10,%esp
}
  8000e6:	eb e2                	jmp    8000ca <umain+0x97>

008000e8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e8:	f3 0f 1e fb          	endbr32 
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f7:	e8 ba 04 00 00       	call   8005b6 <sys_getenvid>
  8000fc:	25 ff 03 00 00       	and    $0x3ff,%eax
  800101:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800104:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800109:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010e:	85 db                	test   %ebx,%ebx
  800110:	7e 07                	jle    800119 <libmain+0x31>
		binaryname = argv[0];
  800112:	8b 06                	mov    (%esi),%eax
  800114:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800119:	83 ec 08             	sub    $0x8,%esp
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
  80011e:	e8 10 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800123:	e8 0a 00 00 00       	call   800132 <exit>
}
  800128:	83 c4 10             	add    $0x10,%esp
  80012b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800132:	f3 0f 1e fb          	endbr32 
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  80013c:	e8 46 08 00 00       	call   800987 <close_all>
	sys_env_destroy(0);
  800141:	83 ec 0c             	sub    $0xc,%esp
  800144:	6a 00                	push   $0x0
  800146:	e8 47 04 00 00       	call   800592 <sys_env_destroy>
}
  80014b:	83 c4 10             	add    $0x10,%esp
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800150:	f3 0f 1e fb          	endbr32 
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80015a:	b8 00 00 00 00       	mov    $0x0,%eax
  80015f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800163:	74 05                	je     80016a <strlen+0x1a>
		n++;
  800165:	83 c0 01             	add    $0x1,%eax
  800168:	eb f5                	jmp    80015f <strlen+0xf>
	return n;
}
  80016a:	5d                   	pop    %ebp
  80016b:	c3                   	ret    

0080016c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80016c:	f3 0f 1e fb          	endbr32 
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800176:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800179:	b8 00 00 00 00       	mov    $0x0,%eax
  80017e:	39 d0                	cmp    %edx,%eax
  800180:	74 0d                	je     80018f <strnlen+0x23>
  800182:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800186:	74 05                	je     80018d <strnlen+0x21>
		n++;
  800188:	83 c0 01             	add    $0x1,%eax
  80018b:	eb f1                	jmp    80017e <strnlen+0x12>
  80018d:	89 c2                	mov    %eax,%edx
	return n;
}
  80018f:	89 d0                	mov    %edx,%eax
  800191:	5d                   	pop    %ebp
  800192:	c3                   	ret    

00800193 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800193:	f3 0f 1e fb          	endbr32 
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	53                   	push   %ebx
  80019b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80019e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8001a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8001a6:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8001aa:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8001ad:	83 c0 01             	add    $0x1,%eax
  8001b0:	84 d2                	test   %dl,%dl
  8001b2:	75 f2                	jne    8001a6 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8001b4:	89 c8                	mov    %ecx,%eax
  8001b6:	5b                   	pop    %ebx
  8001b7:	5d                   	pop    %ebp
  8001b8:	c3                   	ret    

008001b9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8001b9:	f3 0f 1e fb          	endbr32 
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	53                   	push   %ebx
  8001c1:	83 ec 10             	sub    $0x10,%esp
  8001c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8001c7:	53                   	push   %ebx
  8001c8:	e8 83 ff ff ff       	call   800150 <strlen>
  8001cd:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8001d0:	ff 75 0c             	pushl  0xc(%ebp)
  8001d3:	01 d8                	add    %ebx,%eax
  8001d5:	50                   	push   %eax
  8001d6:	e8 b8 ff ff ff       	call   800193 <strcpy>
	return dst;
}
  8001db:	89 d8                	mov    %ebx,%eax
  8001dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e0:	c9                   	leave  
  8001e1:	c3                   	ret    

008001e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001e2:	f3 0f 1e fb          	endbr32 
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8001ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f1:	89 f3                	mov    %esi,%ebx
  8001f3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001f6:	89 f0                	mov    %esi,%eax
  8001f8:	39 d8                	cmp    %ebx,%eax
  8001fa:	74 11                	je     80020d <strncpy+0x2b>
		*dst++ = *src;
  8001fc:	83 c0 01             	add    $0x1,%eax
  8001ff:	0f b6 0a             	movzbl (%edx),%ecx
  800202:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800205:	80 f9 01             	cmp    $0x1,%cl
  800208:	83 da ff             	sbb    $0xffffffff,%edx
  80020b:	eb eb                	jmp    8001f8 <strncpy+0x16>
	}
	return ret;
}
  80020d:	89 f0                	mov    %esi,%eax
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5d                   	pop    %ebp
  800212:	c3                   	ret    

00800213 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800213:	f3 0f 1e fb          	endbr32 
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	56                   	push   %esi
  80021b:	53                   	push   %ebx
  80021c:	8b 75 08             	mov    0x8(%ebp),%esi
  80021f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800222:	8b 55 10             	mov    0x10(%ebp),%edx
  800225:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800227:	85 d2                	test   %edx,%edx
  800229:	74 21                	je     80024c <strlcpy+0x39>
  80022b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80022f:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800231:	39 c2                	cmp    %eax,%edx
  800233:	74 14                	je     800249 <strlcpy+0x36>
  800235:	0f b6 19             	movzbl (%ecx),%ebx
  800238:	84 db                	test   %bl,%bl
  80023a:	74 0b                	je     800247 <strlcpy+0x34>
			*dst++ = *src++;
  80023c:	83 c1 01             	add    $0x1,%ecx
  80023f:	83 c2 01             	add    $0x1,%edx
  800242:	88 5a ff             	mov    %bl,-0x1(%edx)
  800245:	eb ea                	jmp    800231 <strlcpy+0x1e>
  800247:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800249:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80024c:	29 f0                	sub    %esi,%eax
}
  80024e:	5b                   	pop    %ebx
  80024f:	5e                   	pop    %esi
  800250:	5d                   	pop    %ebp
  800251:	c3                   	ret    

00800252 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800252:	f3 0f 1e fb          	endbr32 
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80025c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80025f:	0f b6 01             	movzbl (%ecx),%eax
  800262:	84 c0                	test   %al,%al
  800264:	74 0c                	je     800272 <strcmp+0x20>
  800266:	3a 02                	cmp    (%edx),%al
  800268:	75 08                	jne    800272 <strcmp+0x20>
		p++, q++;
  80026a:	83 c1 01             	add    $0x1,%ecx
  80026d:	83 c2 01             	add    $0x1,%edx
  800270:	eb ed                	jmp    80025f <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800272:	0f b6 c0             	movzbl %al,%eax
  800275:	0f b6 12             	movzbl (%edx),%edx
  800278:	29 d0                	sub    %edx,%eax
}
  80027a:	5d                   	pop    %ebp
  80027b:	c3                   	ret    

0080027c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80027c:	f3 0f 1e fb          	endbr32 
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	53                   	push   %ebx
  800284:	8b 45 08             	mov    0x8(%ebp),%eax
  800287:	8b 55 0c             	mov    0xc(%ebp),%edx
  80028a:	89 c3                	mov    %eax,%ebx
  80028c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80028f:	eb 06                	jmp    800297 <strncmp+0x1b>
		n--, p++, q++;
  800291:	83 c0 01             	add    $0x1,%eax
  800294:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800297:	39 d8                	cmp    %ebx,%eax
  800299:	74 16                	je     8002b1 <strncmp+0x35>
  80029b:	0f b6 08             	movzbl (%eax),%ecx
  80029e:	84 c9                	test   %cl,%cl
  8002a0:	74 04                	je     8002a6 <strncmp+0x2a>
  8002a2:	3a 0a                	cmp    (%edx),%cl
  8002a4:	74 eb                	je     800291 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8002a6:	0f b6 00             	movzbl (%eax),%eax
  8002a9:	0f b6 12             	movzbl (%edx),%edx
  8002ac:	29 d0                	sub    %edx,%eax
}
  8002ae:	5b                   	pop    %ebx
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    
		return 0;
  8002b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8002b6:	eb f6                	jmp    8002ae <strncmp+0x32>

008002b8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8002b8:	f3 0f 1e fb          	endbr32 
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002c6:	0f b6 10             	movzbl (%eax),%edx
  8002c9:	84 d2                	test   %dl,%dl
  8002cb:	74 09                	je     8002d6 <strchr+0x1e>
		if (*s == c)
  8002cd:	38 ca                	cmp    %cl,%dl
  8002cf:	74 0a                	je     8002db <strchr+0x23>
	for (; *s; s++)
  8002d1:	83 c0 01             	add    $0x1,%eax
  8002d4:	eb f0                	jmp    8002c6 <strchr+0xe>
			return (char *) s;
	return 0;
  8002d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8002db:	5d                   	pop    %ebp
  8002dc:	c3                   	ret    

008002dd <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  8002dd:	f3 0f 1e fb          	endbr32 
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  8002e7:	6a 78                	push   $0x78
  8002e9:	ff 75 08             	pushl  0x8(%ebp)
  8002ec:	e8 c7 ff ff ff       	call   8002b8 <strchr>
  8002f1:	83 c4 10             	add    $0x10,%esp
  8002f4:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  8002f7:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  8002fc:	eb 0d                	jmp    80030b <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  8002fe:	c1 e0 04             	shl    $0x4,%eax
  800301:	0f be d2             	movsbl %dl,%edx
  800304:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800308:	83 c1 01             	add    $0x1,%ecx
  80030b:	0f b6 11             	movzbl (%ecx),%edx
  80030e:	84 d2                	test   %dl,%dl
  800310:	74 11                	je     800323 <atox+0x46>
		if (*p>='a'){
  800312:	80 fa 60             	cmp    $0x60,%dl
  800315:	7e e7                	jle    8002fe <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800317:	c1 e0 04             	shl    $0x4,%eax
  80031a:	0f be d2             	movsbl %dl,%edx
  80031d:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800321:	eb e5                	jmp    800308 <atox+0x2b>
	}

	return v;

}
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800325:	f3 0f 1e fb          	endbr32 
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	8b 45 08             	mov    0x8(%ebp),%eax
  80032f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800333:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800336:	38 ca                	cmp    %cl,%dl
  800338:	74 09                	je     800343 <strfind+0x1e>
  80033a:	84 d2                	test   %dl,%dl
  80033c:	74 05                	je     800343 <strfind+0x1e>
	for (; *s; s++)
  80033e:	83 c0 01             	add    $0x1,%eax
  800341:	eb f0                	jmp    800333 <strfind+0xe>
			break;
	return (char *) s;
}
  800343:	5d                   	pop    %ebp
  800344:	c3                   	ret    

00800345 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800345:	f3 0f 1e fb          	endbr32 
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	57                   	push   %edi
  80034d:	56                   	push   %esi
  80034e:	53                   	push   %ebx
  80034f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800352:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800355:	85 c9                	test   %ecx,%ecx
  800357:	74 31                	je     80038a <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800359:	89 f8                	mov    %edi,%eax
  80035b:	09 c8                	or     %ecx,%eax
  80035d:	a8 03                	test   $0x3,%al
  80035f:	75 23                	jne    800384 <memset+0x3f>
		c &= 0xFF;
  800361:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800365:	89 d3                	mov    %edx,%ebx
  800367:	c1 e3 08             	shl    $0x8,%ebx
  80036a:	89 d0                	mov    %edx,%eax
  80036c:	c1 e0 18             	shl    $0x18,%eax
  80036f:	89 d6                	mov    %edx,%esi
  800371:	c1 e6 10             	shl    $0x10,%esi
  800374:	09 f0                	or     %esi,%eax
  800376:	09 c2                	or     %eax,%edx
  800378:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80037a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80037d:	89 d0                	mov    %edx,%eax
  80037f:	fc                   	cld    
  800380:	f3 ab                	rep stos %eax,%es:(%edi)
  800382:	eb 06                	jmp    80038a <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800384:	8b 45 0c             	mov    0xc(%ebp),%eax
  800387:	fc                   	cld    
  800388:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80038a:	89 f8                	mov    %edi,%eax
  80038c:	5b                   	pop    %ebx
  80038d:	5e                   	pop    %esi
  80038e:	5f                   	pop    %edi
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800391:	f3 0f 1e fb          	endbr32 
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	57                   	push   %edi
  800399:	56                   	push   %esi
  80039a:	8b 45 08             	mov    0x8(%ebp),%eax
  80039d:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8003a3:	39 c6                	cmp    %eax,%esi
  8003a5:	73 32                	jae    8003d9 <memmove+0x48>
  8003a7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8003aa:	39 c2                	cmp    %eax,%edx
  8003ac:	76 2b                	jbe    8003d9 <memmove+0x48>
		s += n;
		d += n;
  8003ae:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8003b1:	89 fe                	mov    %edi,%esi
  8003b3:	09 ce                	or     %ecx,%esi
  8003b5:	09 d6                	or     %edx,%esi
  8003b7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8003bd:	75 0e                	jne    8003cd <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8003bf:	83 ef 04             	sub    $0x4,%edi
  8003c2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8003c5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8003c8:	fd                   	std    
  8003c9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8003cb:	eb 09                	jmp    8003d6 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8003cd:	83 ef 01             	sub    $0x1,%edi
  8003d0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8003d3:	fd                   	std    
  8003d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8003d6:	fc                   	cld    
  8003d7:	eb 1a                	jmp    8003f3 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8003d9:	89 c2                	mov    %eax,%edx
  8003db:	09 ca                	or     %ecx,%edx
  8003dd:	09 f2                	or     %esi,%edx
  8003df:	f6 c2 03             	test   $0x3,%dl
  8003e2:	75 0a                	jne    8003ee <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8003e4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8003e7:	89 c7                	mov    %eax,%edi
  8003e9:	fc                   	cld    
  8003ea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8003ec:	eb 05                	jmp    8003f3 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8003ee:	89 c7                	mov    %eax,%edi
  8003f0:	fc                   	cld    
  8003f1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8003f3:	5e                   	pop    %esi
  8003f4:	5f                   	pop    %edi
  8003f5:	5d                   	pop    %ebp
  8003f6:	c3                   	ret    

008003f7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8003f7:	f3 0f 1e fb          	endbr32 
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
  8003fe:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800401:	ff 75 10             	pushl  0x10(%ebp)
  800404:	ff 75 0c             	pushl  0xc(%ebp)
  800407:	ff 75 08             	pushl  0x8(%ebp)
  80040a:	e8 82 ff ff ff       	call   800391 <memmove>
}
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800411:	f3 0f 1e fb          	endbr32 
  800415:	55                   	push   %ebp
  800416:	89 e5                	mov    %esp,%ebp
  800418:	56                   	push   %esi
  800419:	53                   	push   %ebx
  80041a:	8b 45 08             	mov    0x8(%ebp),%eax
  80041d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800420:	89 c6                	mov    %eax,%esi
  800422:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800425:	39 f0                	cmp    %esi,%eax
  800427:	74 1c                	je     800445 <memcmp+0x34>
		if (*s1 != *s2)
  800429:	0f b6 08             	movzbl (%eax),%ecx
  80042c:	0f b6 1a             	movzbl (%edx),%ebx
  80042f:	38 d9                	cmp    %bl,%cl
  800431:	75 08                	jne    80043b <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800433:	83 c0 01             	add    $0x1,%eax
  800436:	83 c2 01             	add    $0x1,%edx
  800439:	eb ea                	jmp    800425 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  80043b:	0f b6 c1             	movzbl %cl,%eax
  80043e:	0f b6 db             	movzbl %bl,%ebx
  800441:	29 d8                	sub    %ebx,%eax
  800443:	eb 05                	jmp    80044a <memcmp+0x39>
	}

	return 0;
  800445:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80044a:	5b                   	pop    %ebx
  80044b:	5e                   	pop    %esi
  80044c:	5d                   	pop    %ebp
  80044d:	c3                   	ret    

0080044e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80044e:	f3 0f 1e fb          	endbr32 
  800452:	55                   	push   %ebp
  800453:	89 e5                	mov    %esp,%ebp
  800455:	8b 45 08             	mov    0x8(%ebp),%eax
  800458:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80045b:	89 c2                	mov    %eax,%edx
  80045d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800460:	39 d0                	cmp    %edx,%eax
  800462:	73 09                	jae    80046d <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800464:	38 08                	cmp    %cl,(%eax)
  800466:	74 05                	je     80046d <memfind+0x1f>
	for (; s < ends; s++)
  800468:	83 c0 01             	add    $0x1,%eax
  80046b:	eb f3                	jmp    800460 <memfind+0x12>
			break;
	return (void *) s;
}
  80046d:	5d                   	pop    %ebp
  80046e:	c3                   	ret    

0080046f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80046f:	f3 0f 1e fb          	endbr32 
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
  800476:	57                   	push   %edi
  800477:	56                   	push   %esi
  800478:	53                   	push   %ebx
  800479:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80047c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80047f:	eb 03                	jmp    800484 <strtol+0x15>
		s++;
  800481:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800484:	0f b6 01             	movzbl (%ecx),%eax
  800487:	3c 20                	cmp    $0x20,%al
  800489:	74 f6                	je     800481 <strtol+0x12>
  80048b:	3c 09                	cmp    $0x9,%al
  80048d:	74 f2                	je     800481 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  80048f:	3c 2b                	cmp    $0x2b,%al
  800491:	74 2a                	je     8004bd <strtol+0x4e>
	int neg = 0;
  800493:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800498:	3c 2d                	cmp    $0x2d,%al
  80049a:	74 2b                	je     8004c7 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80049c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8004a2:	75 0f                	jne    8004b3 <strtol+0x44>
  8004a4:	80 39 30             	cmpb   $0x30,(%ecx)
  8004a7:	74 28                	je     8004d1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8004a9:	85 db                	test   %ebx,%ebx
  8004ab:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004b0:	0f 44 d8             	cmove  %eax,%ebx
  8004b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004bb:	eb 46                	jmp    800503 <strtol+0x94>
		s++;
  8004bd:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8004c0:	bf 00 00 00 00       	mov    $0x0,%edi
  8004c5:	eb d5                	jmp    80049c <strtol+0x2d>
		s++, neg = 1;
  8004c7:	83 c1 01             	add    $0x1,%ecx
  8004ca:	bf 01 00 00 00       	mov    $0x1,%edi
  8004cf:	eb cb                	jmp    80049c <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8004d1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8004d5:	74 0e                	je     8004e5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8004d7:	85 db                	test   %ebx,%ebx
  8004d9:	75 d8                	jne    8004b3 <strtol+0x44>
		s++, base = 8;
  8004db:	83 c1 01             	add    $0x1,%ecx
  8004de:	bb 08 00 00 00       	mov    $0x8,%ebx
  8004e3:	eb ce                	jmp    8004b3 <strtol+0x44>
		s += 2, base = 16;
  8004e5:	83 c1 02             	add    $0x2,%ecx
  8004e8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8004ed:	eb c4                	jmp    8004b3 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8004ef:	0f be d2             	movsbl %dl,%edx
  8004f2:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8004f5:	3b 55 10             	cmp    0x10(%ebp),%edx
  8004f8:	7d 3a                	jge    800534 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8004fa:	83 c1 01             	add    $0x1,%ecx
  8004fd:	0f af 45 10          	imul   0x10(%ebp),%eax
  800501:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800503:	0f b6 11             	movzbl (%ecx),%edx
  800506:	8d 72 d0             	lea    -0x30(%edx),%esi
  800509:	89 f3                	mov    %esi,%ebx
  80050b:	80 fb 09             	cmp    $0x9,%bl
  80050e:	76 df                	jbe    8004ef <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800510:	8d 72 9f             	lea    -0x61(%edx),%esi
  800513:	89 f3                	mov    %esi,%ebx
  800515:	80 fb 19             	cmp    $0x19,%bl
  800518:	77 08                	ja     800522 <strtol+0xb3>
			dig = *s - 'a' + 10;
  80051a:	0f be d2             	movsbl %dl,%edx
  80051d:	83 ea 57             	sub    $0x57,%edx
  800520:	eb d3                	jmp    8004f5 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800522:	8d 72 bf             	lea    -0x41(%edx),%esi
  800525:	89 f3                	mov    %esi,%ebx
  800527:	80 fb 19             	cmp    $0x19,%bl
  80052a:	77 08                	ja     800534 <strtol+0xc5>
			dig = *s - 'A' + 10;
  80052c:	0f be d2             	movsbl %dl,%edx
  80052f:	83 ea 37             	sub    $0x37,%edx
  800532:	eb c1                	jmp    8004f5 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800534:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800538:	74 05                	je     80053f <strtol+0xd0>
		*endptr = (char *) s;
  80053a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80053d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  80053f:	89 c2                	mov    %eax,%edx
  800541:	f7 da                	neg    %edx
  800543:	85 ff                	test   %edi,%edi
  800545:	0f 45 c2             	cmovne %edx,%eax
}
  800548:	5b                   	pop    %ebx
  800549:	5e                   	pop    %esi
  80054a:	5f                   	pop    %edi
  80054b:	5d                   	pop    %ebp
  80054c:	c3                   	ret    

0080054d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80054d:	f3 0f 1e fb          	endbr32 
  800551:	55                   	push   %ebp
  800552:	89 e5                	mov    %esp,%ebp
  800554:	57                   	push   %edi
  800555:	56                   	push   %esi
  800556:	53                   	push   %ebx
	asm volatile("int %1\n"
  800557:	b8 00 00 00 00       	mov    $0x0,%eax
  80055c:	8b 55 08             	mov    0x8(%ebp),%edx
  80055f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800562:	89 c3                	mov    %eax,%ebx
  800564:	89 c7                	mov    %eax,%edi
  800566:	89 c6                	mov    %eax,%esi
  800568:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80056a:	5b                   	pop    %ebx
  80056b:	5e                   	pop    %esi
  80056c:	5f                   	pop    %edi
  80056d:	5d                   	pop    %ebp
  80056e:	c3                   	ret    

0080056f <sys_cgetc>:

int
sys_cgetc(void)
{
  80056f:	f3 0f 1e fb          	endbr32 
  800573:	55                   	push   %ebp
  800574:	89 e5                	mov    %esp,%ebp
  800576:	57                   	push   %edi
  800577:	56                   	push   %esi
  800578:	53                   	push   %ebx
	asm volatile("int %1\n"
  800579:	ba 00 00 00 00       	mov    $0x0,%edx
  80057e:	b8 01 00 00 00       	mov    $0x1,%eax
  800583:	89 d1                	mov    %edx,%ecx
  800585:	89 d3                	mov    %edx,%ebx
  800587:	89 d7                	mov    %edx,%edi
  800589:	89 d6                	mov    %edx,%esi
  80058b:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80058d:	5b                   	pop    %ebx
  80058e:	5e                   	pop    %esi
  80058f:	5f                   	pop    %edi
  800590:	5d                   	pop    %ebp
  800591:	c3                   	ret    

00800592 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800592:	f3 0f 1e fb          	endbr32 
  800596:	55                   	push   %ebp
  800597:	89 e5                	mov    %esp,%ebp
  800599:	57                   	push   %edi
  80059a:	56                   	push   %esi
  80059b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80059c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8005a4:	b8 03 00 00 00       	mov    $0x3,%eax
  8005a9:	89 cb                	mov    %ecx,%ebx
  8005ab:	89 cf                	mov    %ecx,%edi
  8005ad:	89 ce                	mov    %ecx,%esi
  8005af:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8005b1:	5b                   	pop    %ebx
  8005b2:	5e                   	pop    %esi
  8005b3:	5f                   	pop    %edi
  8005b4:	5d                   	pop    %ebp
  8005b5:	c3                   	ret    

008005b6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8005b6:	f3 0f 1e fb          	endbr32 
  8005ba:	55                   	push   %ebp
  8005bb:	89 e5                	mov    %esp,%ebp
  8005bd:	57                   	push   %edi
  8005be:	56                   	push   %esi
  8005bf:	53                   	push   %ebx
	asm volatile("int %1\n"
  8005c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c5:	b8 02 00 00 00       	mov    $0x2,%eax
  8005ca:	89 d1                	mov    %edx,%ecx
  8005cc:	89 d3                	mov    %edx,%ebx
  8005ce:	89 d7                	mov    %edx,%edi
  8005d0:	89 d6                	mov    %edx,%esi
  8005d2:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8005d4:	5b                   	pop    %ebx
  8005d5:	5e                   	pop    %esi
  8005d6:	5f                   	pop    %edi
  8005d7:	5d                   	pop    %ebp
  8005d8:	c3                   	ret    

008005d9 <sys_yield>:

void
sys_yield(void)
{
  8005d9:	f3 0f 1e fb          	endbr32 
  8005dd:	55                   	push   %ebp
  8005de:	89 e5                	mov    %esp,%ebp
  8005e0:	57                   	push   %edi
  8005e1:	56                   	push   %esi
  8005e2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8005e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8005ed:	89 d1                	mov    %edx,%ecx
  8005ef:	89 d3                	mov    %edx,%ebx
  8005f1:	89 d7                	mov    %edx,%edi
  8005f3:	89 d6                	mov    %edx,%esi
  8005f5:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8005f7:	5b                   	pop    %ebx
  8005f8:	5e                   	pop    %esi
  8005f9:	5f                   	pop    %edi
  8005fa:	5d                   	pop    %ebp
  8005fb:	c3                   	ret    

008005fc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8005fc:	f3 0f 1e fb          	endbr32 
  800600:	55                   	push   %ebp
  800601:	89 e5                	mov    %esp,%ebp
  800603:	57                   	push   %edi
  800604:	56                   	push   %esi
  800605:	53                   	push   %ebx
	asm volatile("int %1\n"
  800606:	be 00 00 00 00       	mov    $0x0,%esi
  80060b:	8b 55 08             	mov    0x8(%ebp),%edx
  80060e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800611:	b8 04 00 00 00       	mov    $0x4,%eax
  800616:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800619:	89 f7                	mov    %esi,%edi
  80061b:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80061d:	5b                   	pop    %ebx
  80061e:	5e                   	pop    %esi
  80061f:	5f                   	pop    %edi
  800620:	5d                   	pop    %ebp
  800621:	c3                   	ret    

00800622 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800622:	f3 0f 1e fb          	endbr32 
  800626:	55                   	push   %ebp
  800627:	89 e5                	mov    %esp,%ebp
  800629:	57                   	push   %edi
  80062a:	56                   	push   %esi
  80062b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80062c:	8b 55 08             	mov    0x8(%ebp),%edx
  80062f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800632:	b8 05 00 00 00       	mov    $0x5,%eax
  800637:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80063a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80063d:	8b 75 18             	mov    0x18(%ebp),%esi
  800640:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800642:	5b                   	pop    %ebx
  800643:	5e                   	pop    %esi
  800644:	5f                   	pop    %edi
  800645:	5d                   	pop    %ebp
  800646:	c3                   	ret    

00800647 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800647:	f3 0f 1e fb          	endbr32 
  80064b:	55                   	push   %ebp
  80064c:	89 e5                	mov    %esp,%ebp
  80064e:	57                   	push   %edi
  80064f:	56                   	push   %esi
  800650:	53                   	push   %ebx
	asm volatile("int %1\n"
  800651:	bb 00 00 00 00       	mov    $0x0,%ebx
  800656:	8b 55 08             	mov    0x8(%ebp),%edx
  800659:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80065c:	b8 06 00 00 00       	mov    $0x6,%eax
  800661:	89 df                	mov    %ebx,%edi
  800663:	89 de                	mov    %ebx,%esi
  800665:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800667:	5b                   	pop    %ebx
  800668:	5e                   	pop    %esi
  800669:	5f                   	pop    %edi
  80066a:	5d                   	pop    %ebp
  80066b:	c3                   	ret    

0080066c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80066c:	f3 0f 1e fb          	endbr32 
  800670:	55                   	push   %ebp
  800671:	89 e5                	mov    %esp,%ebp
  800673:	57                   	push   %edi
  800674:	56                   	push   %esi
  800675:	53                   	push   %ebx
	asm volatile("int %1\n"
  800676:	bb 00 00 00 00       	mov    $0x0,%ebx
  80067b:	8b 55 08             	mov    0x8(%ebp),%edx
  80067e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800681:	b8 08 00 00 00       	mov    $0x8,%eax
  800686:	89 df                	mov    %ebx,%edi
  800688:	89 de                	mov    %ebx,%esi
  80068a:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80068c:	5b                   	pop    %ebx
  80068d:	5e                   	pop    %esi
  80068e:	5f                   	pop    %edi
  80068f:	5d                   	pop    %ebp
  800690:	c3                   	ret    

00800691 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800691:	f3 0f 1e fb          	endbr32 
  800695:	55                   	push   %ebp
  800696:	89 e5                	mov    %esp,%ebp
  800698:	57                   	push   %edi
  800699:	56                   	push   %esi
  80069a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80069b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8006a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006a6:	b8 09 00 00 00       	mov    $0x9,%eax
  8006ab:	89 df                	mov    %ebx,%edi
  8006ad:	89 de                	mov    %ebx,%esi
  8006af:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8006b1:	5b                   	pop    %ebx
  8006b2:	5e                   	pop    %esi
  8006b3:	5f                   	pop    %edi
  8006b4:	5d                   	pop    %ebp
  8006b5:	c3                   	ret    

008006b6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8006b6:	f3 0f 1e fb          	endbr32 
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	57                   	push   %edi
  8006be:	56                   	push   %esi
  8006bf:	53                   	push   %ebx
	asm volatile("int %1\n"
  8006c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d0:	89 df                	mov    %ebx,%edi
  8006d2:	89 de                	mov    %ebx,%esi
  8006d4:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8006d6:	5b                   	pop    %ebx
  8006d7:	5e                   	pop    %esi
  8006d8:	5f                   	pop    %edi
  8006d9:	5d                   	pop    %ebp
  8006da:	c3                   	ret    

008006db <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8006db:	f3 0f 1e fb          	endbr32 
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	57                   	push   %edi
  8006e3:	56                   	push   %esi
  8006e4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8006e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006eb:	b8 0c 00 00 00       	mov    $0xc,%eax
  8006f0:	be 00 00 00 00       	mov    $0x0,%esi
  8006f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006f8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8006fb:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8006fd:	5b                   	pop    %ebx
  8006fe:	5e                   	pop    %esi
  8006ff:	5f                   	pop    %edi
  800700:	5d                   	pop    %ebp
  800701:	c3                   	ret    

00800702 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800702:	f3 0f 1e fb          	endbr32 
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	57                   	push   %edi
  80070a:	56                   	push   %esi
  80070b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80070c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800711:	8b 55 08             	mov    0x8(%ebp),%edx
  800714:	b8 0d 00 00 00       	mov    $0xd,%eax
  800719:	89 cb                	mov    %ecx,%ebx
  80071b:	89 cf                	mov    %ecx,%edi
  80071d:	89 ce                	mov    %ecx,%esi
  80071f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800721:	5b                   	pop    %ebx
  800722:	5e                   	pop    %esi
  800723:	5f                   	pop    %edi
  800724:	5d                   	pop    %ebp
  800725:	c3                   	ret    

00800726 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800726:	f3 0f 1e fb          	endbr32 
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	57                   	push   %edi
  80072e:	56                   	push   %esi
  80072f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800730:	ba 00 00 00 00       	mov    $0x0,%edx
  800735:	b8 0e 00 00 00       	mov    $0xe,%eax
  80073a:	89 d1                	mov    %edx,%ecx
  80073c:	89 d3                	mov    %edx,%ebx
  80073e:	89 d7                	mov    %edx,%edi
  800740:	89 d6                	mov    %edx,%esi
  800742:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800744:	5b                   	pop    %ebx
  800745:	5e                   	pop    %esi
  800746:	5f                   	pop    %edi
  800747:	5d                   	pop    %ebp
  800748:	c3                   	ret    

00800749 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800749:	f3 0f 1e fb          	endbr32 
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	57                   	push   %edi
  800751:	56                   	push   %esi
  800752:	53                   	push   %ebx
	asm volatile("int %1\n"
  800753:	bb 00 00 00 00       	mov    $0x0,%ebx
  800758:	8b 55 08             	mov    0x8(%ebp),%edx
  80075b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80075e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800763:	89 df                	mov    %ebx,%edi
  800765:	89 de                	mov    %ebx,%esi
  800767:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800769:	5b                   	pop    %ebx
  80076a:	5e                   	pop    %esi
  80076b:	5f                   	pop    %edi
  80076c:	5d                   	pop    %ebp
  80076d:	c3                   	ret    

0080076e <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  80076e:	f3 0f 1e fb          	endbr32 
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	57                   	push   %edi
  800776:	56                   	push   %esi
  800777:	53                   	push   %ebx
	asm volatile("int %1\n"
  800778:	bb 00 00 00 00       	mov    $0x0,%ebx
  80077d:	8b 55 08             	mov    0x8(%ebp),%edx
  800780:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800783:	b8 10 00 00 00       	mov    $0x10,%eax
  800788:	89 df                	mov    %ebx,%edi
  80078a:	89 de                	mov    %ebx,%esi
  80078c:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  80078e:	5b                   	pop    %ebx
  80078f:	5e                   	pop    %esi
  800790:	5f                   	pop    %edi
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800793:	f3 0f 1e fb          	endbr32 
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80079a:	8b 45 08             	mov    0x8(%ebp),%eax
  80079d:	05 00 00 00 30       	add    $0x30000000,%eax
  8007a2:	c1 e8 0c             	shr    $0xc,%eax
}
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8007a7:	f3 0f 1e fb          	endbr32 
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8007ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b1:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8007b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8007bb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8007c2:	f3 0f 1e fb          	endbr32 
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8007ce:	89 c2                	mov    %eax,%edx
  8007d0:	c1 ea 16             	shr    $0x16,%edx
  8007d3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8007da:	f6 c2 01             	test   $0x1,%dl
  8007dd:	74 2d                	je     80080c <fd_alloc+0x4a>
  8007df:	89 c2                	mov    %eax,%edx
  8007e1:	c1 ea 0c             	shr    $0xc,%edx
  8007e4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007eb:	f6 c2 01             	test   $0x1,%dl
  8007ee:	74 1c                	je     80080c <fd_alloc+0x4a>
  8007f0:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8007f5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8007fa:	75 d2                	jne    8007ce <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  8007fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800805:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80080a:	eb 0a                	jmp    800816 <fd_alloc+0x54>
			*fd_store = fd;
  80080c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800811:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800818:	f3 0f 1e fb          	endbr32 
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800822:	83 f8 1f             	cmp    $0x1f,%eax
  800825:	77 30                	ja     800857 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800827:	c1 e0 0c             	shl    $0xc,%eax
  80082a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80082f:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800835:	f6 c2 01             	test   $0x1,%dl
  800838:	74 24                	je     80085e <fd_lookup+0x46>
  80083a:	89 c2                	mov    %eax,%edx
  80083c:	c1 ea 0c             	shr    $0xc,%edx
  80083f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800846:	f6 c2 01             	test   $0x1,%dl
  800849:	74 1a                	je     800865 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80084b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084e:	89 02                	mov    %eax,(%edx)
	return 0;
  800850:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    
		return -E_INVAL;
  800857:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80085c:	eb f7                	jmp    800855 <fd_lookup+0x3d>
		return -E_INVAL;
  80085e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800863:	eb f0                	jmp    800855 <fd_lookup+0x3d>
  800865:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80086a:	eb e9                	jmp    800855 <fd_lookup+0x3d>

0080086c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80086c:	f3 0f 1e fb          	endbr32 
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	83 ec 08             	sub    $0x8,%esp
  800876:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800879:	ba 00 00 00 00       	mov    $0x0,%edx
  80087e:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  800883:	39 08                	cmp    %ecx,(%eax)
  800885:	74 38                	je     8008bf <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  800887:	83 c2 01             	add    $0x1,%edx
  80088a:	8b 04 95 8c 24 80 00 	mov    0x80248c(,%edx,4),%eax
  800891:	85 c0                	test   %eax,%eax
  800893:	75 ee                	jne    800883 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800895:	a1 08 40 80 00       	mov    0x804008,%eax
  80089a:	8b 40 48             	mov    0x48(%eax),%eax
  80089d:	83 ec 04             	sub    $0x4,%esp
  8008a0:	51                   	push   %ecx
  8008a1:	50                   	push   %eax
  8008a2:	68 10 24 80 00       	push   $0x802410
  8008a7:	e8 d6 11 00 00       	call   801a82 <cprintf>
	*dev = 0;
  8008ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008af:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8008b5:	83 c4 10             	add    $0x10,%esp
  8008b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8008bd:	c9                   	leave  
  8008be:	c3                   	ret    
			*dev = devtab[i];
  8008bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8008c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c9:	eb f2                	jmp    8008bd <dev_lookup+0x51>

008008cb <fd_close>:
{
  8008cb:	f3 0f 1e fb          	endbr32 
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	57                   	push   %edi
  8008d3:	56                   	push   %esi
  8008d4:	53                   	push   %ebx
  8008d5:	83 ec 24             	sub    $0x24,%esp
  8008d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008db:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008de:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008e1:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8008e2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8008e8:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008eb:	50                   	push   %eax
  8008ec:	e8 27 ff ff ff       	call   800818 <fd_lookup>
  8008f1:	89 c3                	mov    %eax,%ebx
  8008f3:	83 c4 10             	add    $0x10,%esp
  8008f6:	85 c0                	test   %eax,%eax
  8008f8:	78 05                	js     8008ff <fd_close+0x34>
	    || fd != fd2)
  8008fa:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8008fd:	74 16                	je     800915 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8008ff:	89 f8                	mov    %edi,%eax
  800901:	84 c0                	test   %al,%al
  800903:	b8 00 00 00 00       	mov    $0x0,%eax
  800908:	0f 44 d8             	cmove  %eax,%ebx
}
  80090b:	89 d8                	mov    %ebx,%eax
  80090d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800910:	5b                   	pop    %ebx
  800911:	5e                   	pop    %esi
  800912:	5f                   	pop    %edi
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800915:	83 ec 08             	sub    $0x8,%esp
  800918:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80091b:	50                   	push   %eax
  80091c:	ff 36                	pushl  (%esi)
  80091e:	e8 49 ff ff ff       	call   80086c <dev_lookup>
  800923:	89 c3                	mov    %eax,%ebx
  800925:	83 c4 10             	add    $0x10,%esp
  800928:	85 c0                	test   %eax,%eax
  80092a:	78 1a                	js     800946 <fd_close+0x7b>
		if (dev->dev_close)
  80092c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80092f:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800932:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800937:	85 c0                	test   %eax,%eax
  800939:	74 0b                	je     800946 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80093b:	83 ec 0c             	sub    $0xc,%esp
  80093e:	56                   	push   %esi
  80093f:	ff d0                	call   *%eax
  800941:	89 c3                	mov    %eax,%ebx
  800943:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800946:	83 ec 08             	sub    $0x8,%esp
  800949:	56                   	push   %esi
  80094a:	6a 00                	push   $0x0
  80094c:	e8 f6 fc ff ff       	call   800647 <sys_page_unmap>
	return r;
  800951:	83 c4 10             	add    $0x10,%esp
  800954:	eb b5                	jmp    80090b <fd_close+0x40>

00800956 <close>:

int
close(int fdnum)
{
  800956:	f3 0f 1e fb          	endbr32 
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800960:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800963:	50                   	push   %eax
  800964:	ff 75 08             	pushl  0x8(%ebp)
  800967:	e8 ac fe ff ff       	call   800818 <fd_lookup>
  80096c:	83 c4 10             	add    $0x10,%esp
  80096f:	85 c0                	test   %eax,%eax
  800971:	79 02                	jns    800975 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800973:	c9                   	leave  
  800974:	c3                   	ret    
		return fd_close(fd, 1);
  800975:	83 ec 08             	sub    $0x8,%esp
  800978:	6a 01                	push   $0x1
  80097a:	ff 75 f4             	pushl  -0xc(%ebp)
  80097d:	e8 49 ff ff ff       	call   8008cb <fd_close>
  800982:	83 c4 10             	add    $0x10,%esp
  800985:	eb ec                	jmp    800973 <close+0x1d>

00800987 <close_all>:

void
close_all(void)
{
  800987:	f3 0f 1e fb          	endbr32 
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	53                   	push   %ebx
  80098f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800992:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800997:	83 ec 0c             	sub    $0xc,%esp
  80099a:	53                   	push   %ebx
  80099b:	e8 b6 ff ff ff       	call   800956 <close>
	for (i = 0; i < MAXFD; i++)
  8009a0:	83 c3 01             	add    $0x1,%ebx
  8009a3:	83 c4 10             	add    $0x10,%esp
  8009a6:	83 fb 20             	cmp    $0x20,%ebx
  8009a9:	75 ec                	jne    800997 <close_all+0x10>
}
  8009ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ae:	c9                   	leave  
  8009af:	c3                   	ret    

008009b0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8009b0:	f3 0f 1e fb          	endbr32 
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	57                   	push   %edi
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8009bd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8009c0:	50                   	push   %eax
  8009c1:	ff 75 08             	pushl  0x8(%ebp)
  8009c4:	e8 4f fe ff ff       	call   800818 <fd_lookup>
  8009c9:	89 c3                	mov    %eax,%ebx
  8009cb:	83 c4 10             	add    $0x10,%esp
  8009ce:	85 c0                	test   %eax,%eax
  8009d0:	0f 88 81 00 00 00    	js     800a57 <dup+0xa7>
		return r;
	close(newfdnum);
  8009d6:	83 ec 0c             	sub    $0xc,%esp
  8009d9:	ff 75 0c             	pushl  0xc(%ebp)
  8009dc:	e8 75 ff ff ff       	call   800956 <close>

	newfd = INDEX2FD(newfdnum);
  8009e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e4:	c1 e6 0c             	shl    $0xc,%esi
  8009e7:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8009ed:	83 c4 04             	add    $0x4,%esp
  8009f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8009f3:	e8 af fd ff ff       	call   8007a7 <fd2data>
  8009f8:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8009fa:	89 34 24             	mov    %esi,(%esp)
  8009fd:	e8 a5 fd ff ff       	call   8007a7 <fd2data>
  800a02:	83 c4 10             	add    $0x10,%esp
  800a05:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800a07:	89 d8                	mov    %ebx,%eax
  800a09:	c1 e8 16             	shr    $0x16,%eax
  800a0c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a13:	a8 01                	test   $0x1,%al
  800a15:	74 11                	je     800a28 <dup+0x78>
  800a17:	89 d8                	mov    %ebx,%eax
  800a19:	c1 e8 0c             	shr    $0xc,%eax
  800a1c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800a23:	f6 c2 01             	test   $0x1,%dl
  800a26:	75 39                	jne    800a61 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a28:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a2b:	89 d0                	mov    %edx,%eax
  800a2d:	c1 e8 0c             	shr    $0xc,%eax
  800a30:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a37:	83 ec 0c             	sub    $0xc,%esp
  800a3a:	25 07 0e 00 00       	and    $0xe07,%eax
  800a3f:	50                   	push   %eax
  800a40:	56                   	push   %esi
  800a41:	6a 00                	push   $0x0
  800a43:	52                   	push   %edx
  800a44:	6a 00                	push   $0x0
  800a46:	e8 d7 fb ff ff       	call   800622 <sys_page_map>
  800a4b:	89 c3                	mov    %eax,%ebx
  800a4d:	83 c4 20             	add    $0x20,%esp
  800a50:	85 c0                	test   %eax,%eax
  800a52:	78 31                	js     800a85 <dup+0xd5>
		goto err;

	return newfdnum;
  800a54:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800a57:	89 d8                	mov    %ebx,%eax
  800a59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a5c:	5b                   	pop    %ebx
  800a5d:	5e                   	pop    %esi
  800a5e:	5f                   	pop    %edi
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a61:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a68:	83 ec 0c             	sub    $0xc,%esp
  800a6b:	25 07 0e 00 00       	and    $0xe07,%eax
  800a70:	50                   	push   %eax
  800a71:	57                   	push   %edi
  800a72:	6a 00                	push   $0x0
  800a74:	53                   	push   %ebx
  800a75:	6a 00                	push   $0x0
  800a77:	e8 a6 fb ff ff       	call   800622 <sys_page_map>
  800a7c:	89 c3                	mov    %eax,%ebx
  800a7e:	83 c4 20             	add    $0x20,%esp
  800a81:	85 c0                	test   %eax,%eax
  800a83:	79 a3                	jns    800a28 <dup+0x78>
	sys_page_unmap(0, newfd);
  800a85:	83 ec 08             	sub    $0x8,%esp
  800a88:	56                   	push   %esi
  800a89:	6a 00                	push   $0x0
  800a8b:	e8 b7 fb ff ff       	call   800647 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a90:	83 c4 08             	add    $0x8,%esp
  800a93:	57                   	push   %edi
  800a94:	6a 00                	push   $0x0
  800a96:	e8 ac fb ff ff       	call   800647 <sys_page_unmap>
	return r;
  800a9b:	83 c4 10             	add    $0x10,%esp
  800a9e:	eb b7                	jmp    800a57 <dup+0xa7>

00800aa0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800aa0:	f3 0f 1e fb          	endbr32 
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	53                   	push   %ebx
  800aa8:	83 ec 1c             	sub    $0x1c,%esp
  800aab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800aae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ab1:	50                   	push   %eax
  800ab2:	53                   	push   %ebx
  800ab3:	e8 60 fd ff ff       	call   800818 <fd_lookup>
  800ab8:	83 c4 10             	add    $0x10,%esp
  800abb:	85 c0                	test   %eax,%eax
  800abd:	78 3f                	js     800afe <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800abf:	83 ec 08             	sub    $0x8,%esp
  800ac2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ac5:	50                   	push   %eax
  800ac6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ac9:	ff 30                	pushl  (%eax)
  800acb:	e8 9c fd ff ff       	call   80086c <dev_lookup>
  800ad0:	83 c4 10             	add    $0x10,%esp
  800ad3:	85 c0                	test   %eax,%eax
  800ad5:	78 27                	js     800afe <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800ad7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ada:	8b 42 08             	mov    0x8(%edx),%eax
  800add:	83 e0 03             	and    $0x3,%eax
  800ae0:	83 f8 01             	cmp    $0x1,%eax
  800ae3:	74 1e                	je     800b03 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ae8:	8b 40 08             	mov    0x8(%eax),%eax
  800aeb:	85 c0                	test   %eax,%eax
  800aed:	74 35                	je     800b24 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800aef:	83 ec 04             	sub    $0x4,%esp
  800af2:	ff 75 10             	pushl  0x10(%ebp)
  800af5:	ff 75 0c             	pushl  0xc(%ebp)
  800af8:	52                   	push   %edx
  800af9:	ff d0                	call   *%eax
  800afb:	83 c4 10             	add    $0x10,%esp
}
  800afe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b01:	c9                   	leave  
  800b02:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800b03:	a1 08 40 80 00       	mov    0x804008,%eax
  800b08:	8b 40 48             	mov    0x48(%eax),%eax
  800b0b:	83 ec 04             	sub    $0x4,%esp
  800b0e:	53                   	push   %ebx
  800b0f:	50                   	push   %eax
  800b10:	68 51 24 80 00       	push   $0x802451
  800b15:	e8 68 0f 00 00       	call   801a82 <cprintf>
		return -E_INVAL;
  800b1a:	83 c4 10             	add    $0x10,%esp
  800b1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b22:	eb da                	jmp    800afe <read+0x5e>
		return -E_NOT_SUPP;
  800b24:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800b29:	eb d3                	jmp    800afe <read+0x5e>

00800b2b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800b2b:	f3 0f 1e fb          	endbr32 
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	83 ec 0c             	sub    $0xc,%esp
  800b38:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b3b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b43:	eb 02                	jmp    800b47 <readn+0x1c>
  800b45:	01 c3                	add    %eax,%ebx
  800b47:	39 f3                	cmp    %esi,%ebx
  800b49:	73 21                	jae    800b6c <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b4b:	83 ec 04             	sub    $0x4,%esp
  800b4e:	89 f0                	mov    %esi,%eax
  800b50:	29 d8                	sub    %ebx,%eax
  800b52:	50                   	push   %eax
  800b53:	89 d8                	mov    %ebx,%eax
  800b55:	03 45 0c             	add    0xc(%ebp),%eax
  800b58:	50                   	push   %eax
  800b59:	57                   	push   %edi
  800b5a:	e8 41 ff ff ff       	call   800aa0 <read>
		if (m < 0)
  800b5f:	83 c4 10             	add    $0x10,%esp
  800b62:	85 c0                	test   %eax,%eax
  800b64:	78 04                	js     800b6a <readn+0x3f>
			return m;
		if (m == 0)
  800b66:	75 dd                	jne    800b45 <readn+0x1a>
  800b68:	eb 02                	jmp    800b6c <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b6a:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800b6c:	89 d8                	mov    %ebx,%eax
  800b6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800b76:	f3 0f 1e fb          	endbr32 
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	53                   	push   %ebx
  800b7e:	83 ec 1c             	sub    $0x1c,%esp
  800b81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b84:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b87:	50                   	push   %eax
  800b88:	53                   	push   %ebx
  800b89:	e8 8a fc ff ff       	call   800818 <fd_lookup>
  800b8e:	83 c4 10             	add    $0x10,%esp
  800b91:	85 c0                	test   %eax,%eax
  800b93:	78 3a                	js     800bcf <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b95:	83 ec 08             	sub    $0x8,%esp
  800b98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b9b:	50                   	push   %eax
  800b9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b9f:	ff 30                	pushl  (%eax)
  800ba1:	e8 c6 fc ff ff       	call   80086c <dev_lookup>
  800ba6:	83 c4 10             	add    $0x10,%esp
  800ba9:	85 c0                	test   %eax,%eax
  800bab:	78 22                	js     800bcf <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800bad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bb0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800bb4:	74 1e                	je     800bd4 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800bb6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bb9:	8b 52 0c             	mov    0xc(%edx),%edx
  800bbc:	85 d2                	test   %edx,%edx
  800bbe:	74 35                	je     800bf5 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800bc0:	83 ec 04             	sub    $0x4,%esp
  800bc3:	ff 75 10             	pushl  0x10(%ebp)
  800bc6:	ff 75 0c             	pushl  0xc(%ebp)
  800bc9:	50                   	push   %eax
  800bca:	ff d2                	call   *%edx
  800bcc:	83 c4 10             	add    $0x10,%esp
}
  800bcf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd2:	c9                   	leave  
  800bd3:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800bd4:	a1 08 40 80 00       	mov    0x804008,%eax
  800bd9:	8b 40 48             	mov    0x48(%eax),%eax
  800bdc:	83 ec 04             	sub    $0x4,%esp
  800bdf:	53                   	push   %ebx
  800be0:	50                   	push   %eax
  800be1:	68 6d 24 80 00       	push   $0x80246d
  800be6:	e8 97 0e 00 00       	call   801a82 <cprintf>
		return -E_INVAL;
  800beb:	83 c4 10             	add    $0x10,%esp
  800bee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bf3:	eb da                	jmp    800bcf <write+0x59>
		return -E_NOT_SUPP;
  800bf5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800bfa:	eb d3                	jmp    800bcf <write+0x59>

00800bfc <seek>:

int
seek(int fdnum, off_t offset)
{
  800bfc:	f3 0f 1e fb          	endbr32 
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800c06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c09:	50                   	push   %eax
  800c0a:	ff 75 08             	pushl  0x8(%ebp)
  800c0d:	e8 06 fc ff ff       	call   800818 <fd_lookup>
  800c12:	83 c4 10             	add    $0x10,%esp
  800c15:	85 c0                	test   %eax,%eax
  800c17:	78 0e                	js     800c27 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  800c19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c1f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800c22:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c27:	c9                   	leave  
  800c28:	c3                   	ret    

00800c29 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800c29:	f3 0f 1e fb          	endbr32 
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	53                   	push   %ebx
  800c31:	83 ec 1c             	sub    $0x1c,%esp
  800c34:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c37:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c3a:	50                   	push   %eax
  800c3b:	53                   	push   %ebx
  800c3c:	e8 d7 fb ff ff       	call   800818 <fd_lookup>
  800c41:	83 c4 10             	add    $0x10,%esp
  800c44:	85 c0                	test   %eax,%eax
  800c46:	78 37                	js     800c7f <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c48:	83 ec 08             	sub    $0x8,%esp
  800c4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c4e:	50                   	push   %eax
  800c4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c52:	ff 30                	pushl  (%eax)
  800c54:	e8 13 fc ff ff       	call   80086c <dev_lookup>
  800c59:	83 c4 10             	add    $0x10,%esp
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	78 1f                	js     800c7f <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c63:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c67:	74 1b                	je     800c84 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800c69:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c6c:	8b 52 18             	mov    0x18(%edx),%edx
  800c6f:	85 d2                	test   %edx,%edx
  800c71:	74 32                	je     800ca5 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800c73:	83 ec 08             	sub    $0x8,%esp
  800c76:	ff 75 0c             	pushl  0xc(%ebp)
  800c79:	50                   	push   %eax
  800c7a:	ff d2                	call   *%edx
  800c7c:	83 c4 10             	add    $0x10,%esp
}
  800c7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c82:	c9                   	leave  
  800c83:	c3                   	ret    
			thisenv->env_id, fdnum);
  800c84:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800c89:	8b 40 48             	mov    0x48(%eax),%eax
  800c8c:	83 ec 04             	sub    $0x4,%esp
  800c8f:	53                   	push   %ebx
  800c90:	50                   	push   %eax
  800c91:	68 30 24 80 00       	push   $0x802430
  800c96:	e8 e7 0d 00 00       	call   801a82 <cprintf>
		return -E_INVAL;
  800c9b:	83 c4 10             	add    $0x10,%esp
  800c9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ca3:	eb da                	jmp    800c7f <ftruncate+0x56>
		return -E_NOT_SUPP;
  800ca5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800caa:	eb d3                	jmp    800c7f <ftruncate+0x56>

00800cac <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800cac:	f3 0f 1e fb          	endbr32 
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	53                   	push   %ebx
  800cb4:	83 ec 1c             	sub    $0x1c,%esp
  800cb7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800cba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800cbd:	50                   	push   %eax
  800cbe:	ff 75 08             	pushl  0x8(%ebp)
  800cc1:	e8 52 fb ff ff       	call   800818 <fd_lookup>
  800cc6:	83 c4 10             	add    $0x10,%esp
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	78 4b                	js     800d18 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ccd:	83 ec 08             	sub    $0x8,%esp
  800cd0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cd3:	50                   	push   %eax
  800cd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cd7:	ff 30                	pushl  (%eax)
  800cd9:	e8 8e fb ff ff       	call   80086c <dev_lookup>
  800cde:	83 c4 10             	add    $0x10,%esp
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	78 33                	js     800d18 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  800ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ce8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800cec:	74 2f                	je     800d1d <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800cee:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800cf1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800cf8:	00 00 00 
	stat->st_isdir = 0;
  800cfb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800d02:	00 00 00 
	stat->st_dev = dev;
  800d05:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800d0b:	83 ec 08             	sub    $0x8,%esp
  800d0e:	53                   	push   %ebx
  800d0f:	ff 75 f0             	pushl  -0x10(%ebp)
  800d12:	ff 50 14             	call   *0x14(%eax)
  800d15:	83 c4 10             	add    $0x10,%esp
}
  800d18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d1b:	c9                   	leave  
  800d1c:	c3                   	ret    
		return -E_NOT_SUPP;
  800d1d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800d22:	eb f4                	jmp    800d18 <fstat+0x6c>

00800d24 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800d24:	f3 0f 1e fb          	endbr32 
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800d2d:	83 ec 08             	sub    $0x8,%esp
  800d30:	6a 00                	push   $0x0
  800d32:	ff 75 08             	pushl  0x8(%ebp)
  800d35:	e8 01 02 00 00       	call   800f3b <open>
  800d3a:	89 c3                	mov    %eax,%ebx
  800d3c:	83 c4 10             	add    $0x10,%esp
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	78 1b                	js     800d5e <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  800d43:	83 ec 08             	sub    $0x8,%esp
  800d46:	ff 75 0c             	pushl  0xc(%ebp)
  800d49:	50                   	push   %eax
  800d4a:	e8 5d ff ff ff       	call   800cac <fstat>
  800d4f:	89 c6                	mov    %eax,%esi
	close(fd);
  800d51:	89 1c 24             	mov    %ebx,(%esp)
  800d54:	e8 fd fb ff ff       	call   800956 <close>
	return r;
  800d59:	83 c4 10             	add    $0x10,%esp
  800d5c:	89 f3                	mov    %esi,%ebx
}
  800d5e:	89 d8                	mov    %ebx,%eax
  800d60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
  800d6c:	89 c6                	mov    %eax,%esi
  800d6e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800d70:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800d77:	74 27                	je     800da0 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d79:	6a 07                	push   $0x7
  800d7b:	68 00 50 80 00       	push   $0x805000
  800d80:	56                   	push   %esi
  800d81:	ff 35 00 40 80 00    	pushl  0x804000
  800d87:	e8 2a 13 00 00       	call   8020b6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800d8c:	83 c4 0c             	add    $0xc,%esp
  800d8f:	6a 00                	push   $0x0
  800d91:	53                   	push   %ebx
  800d92:	6a 00                	push   $0x0
  800d94:	e8 b0 12 00 00       	call   802049 <ipc_recv>
}
  800d99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800da0:	83 ec 0c             	sub    $0xc,%esp
  800da3:	6a 01                	push   $0x1
  800da5:	e8 64 13 00 00       	call   80210e <ipc_find_env>
  800daa:	a3 00 40 80 00       	mov    %eax,0x804000
  800daf:	83 c4 10             	add    $0x10,%esp
  800db2:	eb c5                	jmp    800d79 <fsipc+0x12>

00800db4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800db4:	f3 0f 1e fb          	endbr32 
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc1:	8b 40 0c             	mov    0xc(%eax),%eax
  800dc4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800dc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dcc:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800dd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd6:	b8 02 00 00 00       	mov    $0x2,%eax
  800ddb:	e8 87 ff ff ff       	call   800d67 <fsipc>
}
  800de0:	c9                   	leave  
  800de1:	c3                   	ret    

00800de2 <devfile_flush>:
{
  800de2:	f3 0f 1e fb          	endbr32 
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800dec:	8b 45 08             	mov    0x8(%ebp),%eax
  800def:	8b 40 0c             	mov    0xc(%eax),%eax
  800df2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800df7:	ba 00 00 00 00       	mov    $0x0,%edx
  800dfc:	b8 06 00 00 00       	mov    $0x6,%eax
  800e01:	e8 61 ff ff ff       	call   800d67 <fsipc>
}
  800e06:	c9                   	leave  
  800e07:	c3                   	ret    

00800e08 <devfile_stat>:
{
  800e08:	f3 0f 1e fb          	endbr32 
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 04             	sub    $0x4,%esp
  800e13:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800e16:	8b 45 08             	mov    0x8(%ebp),%eax
  800e19:	8b 40 0c             	mov    0xc(%eax),%eax
  800e1c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800e21:	ba 00 00 00 00       	mov    $0x0,%edx
  800e26:	b8 05 00 00 00       	mov    $0x5,%eax
  800e2b:	e8 37 ff ff ff       	call   800d67 <fsipc>
  800e30:	85 c0                	test   %eax,%eax
  800e32:	78 2c                	js     800e60 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800e34:	83 ec 08             	sub    $0x8,%esp
  800e37:	68 00 50 80 00       	push   $0x805000
  800e3c:	53                   	push   %ebx
  800e3d:	e8 51 f3 ff ff       	call   800193 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800e42:	a1 80 50 80 00       	mov    0x805080,%eax
  800e47:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800e4d:	a1 84 50 80 00       	mov    0x805084,%eax
  800e52:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800e58:	83 c4 10             	add    $0x10,%esp
  800e5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e60:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e63:	c9                   	leave  
  800e64:	c3                   	ret    

00800e65 <devfile_write>:
{
  800e65:	f3 0f 1e fb          	endbr32 
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	83 ec 0c             	sub    $0xc,%esp
  800e6f:	8b 45 10             	mov    0x10(%ebp),%eax
  800e72:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800e77:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800e7c:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800e7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e82:	8b 52 0c             	mov    0xc(%edx),%edx
  800e85:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800e8b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800e90:	50                   	push   %eax
  800e91:	ff 75 0c             	pushl  0xc(%ebp)
  800e94:	68 08 50 80 00       	push   $0x805008
  800e99:	e8 f3 f4 ff ff       	call   800391 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800e9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea3:	b8 04 00 00 00       	mov    $0x4,%eax
  800ea8:	e8 ba fe ff ff       	call   800d67 <fsipc>
}
  800ead:	c9                   	leave  
  800eae:	c3                   	ret    

00800eaf <devfile_read>:
{
  800eaf:	f3 0f 1e fb          	endbr32 
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	56                   	push   %esi
  800eb7:	53                   	push   %ebx
  800eb8:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ebb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebe:	8b 40 0c             	mov    0xc(%eax),%eax
  800ec1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ec6:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ecc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed1:	b8 03 00 00 00       	mov    $0x3,%eax
  800ed6:	e8 8c fe ff ff       	call   800d67 <fsipc>
  800edb:	89 c3                	mov    %eax,%ebx
  800edd:	85 c0                	test   %eax,%eax
  800edf:	78 1f                	js     800f00 <devfile_read+0x51>
	assert(r <= n);
  800ee1:	39 f0                	cmp    %esi,%eax
  800ee3:	77 24                	ja     800f09 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800ee5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800eea:	7f 36                	jg     800f22 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800eec:	83 ec 04             	sub    $0x4,%esp
  800eef:	50                   	push   %eax
  800ef0:	68 00 50 80 00       	push   $0x805000
  800ef5:	ff 75 0c             	pushl  0xc(%ebp)
  800ef8:	e8 94 f4 ff ff       	call   800391 <memmove>
	return r;
  800efd:	83 c4 10             	add    $0x10,%esp
}
  800f00:	89 d8                	mov    %ebx,%eax
  800f02:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f05:	5b                   	pop    %ebx
  800f06:	5e                   	pop    %esi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    
	assert(r <= n);
  800f09:	68 a0 24 80 00       	push   $0x8024a0
  800f0e:	68 a7 24 80 00       	push   $0x8024a7
  800f13:	68 8c 00 00 00       	push   $0x8c
  800f18:	68 bc 24 80 00       	push   $0x8024bc
  800f1d:	e8 79 0a 00 00       	call   80199b <_panic>
	assert(r <= PGSIZE);
  800f22:	68 c7 24 80 00       	push   $0x8024c7
  800f27:	68 a7 24 80 00       	push   $0x8024a7
  800f2c:	68 8d 00 00 00       	push   $0x8d
  800f31:	68 bc 24 80 00       	push   $0x8024bc
  800f36:	e8 60 0a 00 00       	call   80199b <_panic>

00800f3b <open>:
{
  800f3b:	f3 0f 1e fb          	endbr32 
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	56                   	push   %esi
  800f43:	53                   	push   %ebx
  800f44:	83 ec 1c             	sub    $0x1c,%esp
  800f47:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800f4a:	56                   	push   %esi
  800f4b:	e8 00 f2 ff ff       	call   800150 <strlen>
  800f50:	83 c4 10             	add    $0x10,%esp
  800f53:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800f58:	7f 6c                	jg     800fc6 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800f5a:	83 ec 0c             	sub    $0xc,%esp
  800f5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f60:	50                   	push   %eax
  800f61:	e8 5c f8 ff ff       	call   8007c2 <fd_alloc>
  800f66:	89 c3                	mov    %eax,%ebx
  800f68:	83 c4 10             	add    $0x10,%esp
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	78 3c                	js     800fab <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800f6f:	83 ec 08             	sub    $0x8,%esp
  800f72:	56                   	push   %esi
  800f73:	68 00 50 80 00       	push   $0x805000
  800f78:	e8 16 f2 ff ff       	call   800193 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800f7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f80:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800f85:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f88:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8d:	e8 d5 fd ff ff       	call   800d67 <fsipc>
  800f92:	89 c3                	mov    %eax,%ebx
  800f94:	83 c4 10             	add    $0x10,%esp
  800f97:	85 c0                	test   %eax,%eax
  800f99:	78 19                	js     800fb4 <open+0x79>
	return fd2num(fd);
  800f9b:	83 ec 0c             	sub    $0xc,%esp
  800f9e:	ff 75 f4             	pushl  -0xc(%ebp)
  800fa1:	e8 ed f7 ff ff       	call   800793 <fd2num>
  800fa6:	89 c3                	mov    %eax,%ebx
  800fa8:	83 c4 10             	add    $0x10,%esp
}
  800fab:	89 d8                	mov    %ebx,%eax
  800fad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fb0:	5b                   	pop    %ebx
  800fb1:	5e                   	pop    %esi
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    
		fd_close(fd, 0);
  800fb4:	83 ec 08             	sub    $0x8,%esp
  800fb7:	6a 00                	push   $0x0
  800fb9:	ff 75 f4             	pushl  -0xc(%ebp)
  800fbc:	e8 0a f9 ff ff       	call   8008cb <fd_close>
		return r;
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	eb e5                	jmp    800fab <open+0x70>
		return -E_BAD_PATH;
  800fc6:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800fcb:	eb de                	jmp    800fab <open+0x70>

00800fcd <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800fcd:	f3 0f 1e fb          	endbr32 
  800fd1:	55                   	push   %ebp
  800fd2:	89 e5                	mov    %esp,%ebp
  800fd4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800fd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800fdc:	b8 08 00 00 00       	mov    $0x8,%eax
  800fe1:	e8 81 fd ff ff       	call   800d67 <fsipc>
}
  800fe6:	c9                   	leave  
  800fe7:	c3                   	ret    

00800fe8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800fe8:	f3 0f 1e fb          	endbr32 
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800ff2:	68 33 25 80 00       	push   $0x802533
  800ff7:	ff 75 0c             	pushl  0xc(%ebp)
  800ffa:	e8 94 f1 ff ff       	call   800193 <strcpy>
	return 0;
}
  800fff:	b8 00 00 00 00       	mov    $0x0,%eax
  801004:	c9                   	leave  
  801005:	c3                   	ret    

00801006 <devsock_close>:
{
  801006:	f3 0f 1e fb          	endbr32 
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	53                   	push   %ebx
  80100e:	83 ec 10             	sub    $0x10,%esp
  801011:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801014:	53                   	push   %ebx
  801015:	e8 31 11 00 00       	call   80214b <pageref>
  80101a:	89 c2                	mov    %eax,%edx
  80101c:	83 c4 10             	add    $0x10,%esp
		return 0;
  80101f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801024:	83 fa 01             	cmp    $0x1,%edx
  801027:	74 05                	je     80102e <devsock_close+0x28>
}
  801029:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80102c:	c9                   	leave  
  80102d:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  80102e:	83 ec 0c             	sub    $0xc,%esp
  801031:	ff 73 0c             	pushl  0xc(%ebx)
  801034:	e8 e3 02 00 00       	call   80131c <nsipc_close>
  801039:	83 c4 10             	add    $0x10,%esp
  80103c:	eb eb                	jmp    801029 <devsock_close+0x23>

0080103e <devsock_write>:
{
  80103e:	f3 0f 1e fb          	endbr32 
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801048:	6a 00                	push   $0x0
  80104a:	ff 75 10             	pushl  0x10(%ebp)
  80104d:	ff 75 0c             	pushl  0xc(%ebp)
  801050:	8b 45 08             	mov    0x8(%ebp),%eax
  801053:	ff 70 0c             	pushl  0xc(%eax)
  801056:	e8 b5 03 00 00       	call   801410 <nsipc_send>
}
  80105b:	c9                   	leave  
  80105c:	c3                   	ret    

0080105d <devsock_read>:
{
  80105d:	f3 0f 1e fb          	endbr32 
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801067:	6a 00                	push   $0x0
  801069:	ff 75 10             	pushl  0x10(%ebp)
  80106c:	ff 75 0c             	pushl  0xc(%ebp)
  80106f:	8b 45 08             	mov    0x8(%ebp),%eax
  801072:	ff 70 0c             	pushl  0xc(%eax)
  801075:	e8 1f 03 00 00       	call   801399 <nsipc_recv>
}
  80107a:	c9                   	leave  
  80107b:	c3                   	ret    

0080107c <fd2sockid>:
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801082:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801085:	52                   	push   %edx
  801086:	50                   	push   %eax
  801087:	e8 8c f7 ff ff       	call   800818 <fd_lookup>
  80108c:	83 c4 10             	add    $0x10,%esp
  80108f:	85 c0                	test   %eax,%eax
  801091:	78 10                	js     8010a3 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801093:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801096:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  80109c:	39 08                	cmp    %ecx,(%eax)
  80109e:	75 05                	jne    8010a5 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8010a0:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8010a3:	c9                   	leave  
  8010a4:	c3                   	ret    
		return -E_NOT_SUPP;
  8010a5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8010aa:	eb f7                	jmp    8010a3 <fd2sockid+0x27>

008010ac <alloc_sockfd>:
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	56                   	push   %esi
  8010b0:	53                   	push   %ebx
  8010b1:	83 ec 1c             	sub    $0x1c,%esp
  8010b4:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8010b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b9:	50                   	push   %eax
  8010ba:	e8 03 f7 ff ff       	call   8007c2 <fd_alloc>
  8010bf:	89 c3                	mov    %eax,%ebx
  8010c1:	83 c4 10             	add    $0x10,%esp
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	78 43                	js     80110b <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8010c8:	83 ec 04             	sub    $0x4,%esp
  8010cb:	68 07 04 00 00       	push   $0x407
  8010d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8010d3:	6a 00                	push   $0x0
  8010d5:	e8 22 f5 ff ff       	call   8005fc <sys_page_alloc>
  8010da:	89 c3                	mov    %eax,%ebx
  8010dc:	83 c4 10             	add    $0x10,%esp
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	78 28                	js     80110b <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  8010e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010e6:	8b 15 60 30 80 00    	mov    0x803060,%edx
  8010ec:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8010ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010f1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8010f8:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8010fb:	83 ec 0c             	sub    $0xc,%esp
  8010fe:	50                   	push   %eax
  8010ff:	e8 8f f6 ff ff       	call   800793 <fd2num>
  801104:	89 c3                	mov    %eax,%ebx
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	eb 0c                	jmp    801117 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  80110b:	83 ec 0c             	sub    $0xc,%esp
  80110e:	56                   	push   %esi
  80110f:	e8 08 02 00 00       	call   80131c <nsipc_close>
		return r;
  801114:	83 c4 10             	add    $0x10,%esp
}
  801117:	89 d8                	mov    %ebx,%eax
  801119:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80111c:	5b                   	pop    %ebx
  80111d:	5e                   	pop    %esi
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    

00801120 <accept>:
{
  801120:	f3 0f 1e fb          	endbr32 
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80112a:	8b 45 08             	mov    0x8(%ebp),%eax
  80112d:	e8 4a ff ff ff       	call   80107c <fd2sockid>
  801132:	85 c0                	test   %eax,%eax
  801134:	78 1b                	js     801151 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801136:	83 ec 04             	sub    $0x4,%esp
  801139:	ff 75 10             	pushl  0x10(%ebp)
  80113c:	ff 75 0c             	pushl  0xc(%ebp)
  80113f:	50                   	push   %eax
  801140:	e8 22 01 00 00       	call   801267 <nsipc_accept>
  801145:	83 c4 10             	add    $0x10,%esp
  801148:	85 c0                	test   %eax,%eax
  80114a:	78 05                	js     801151 <accept+0x31>
	return alloc_sockfd(r);
  80114c:	e8 5b ff ff ff       	call   8010ac <alloc_sockfd>
}
  801151:	c9                   	leave  
  801152:	c3                   	ret    

00801153 <bind>:
{
  801153:	f3 0f 1e fb          	endbr32 
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80115d:	8b 45 08             	mov    0x8(%ebp),%eax
  801160:	e8 17 ff ff ff       	call   80107c <fd2sockid>
  801165:	85 c0                	test   %eax,%eax
  801167:	78 12                	js     80117b <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801169:	83 ec 04             	sub    $0x4,%esp
  80116c:	ff 75 10             	pushl  0x10(%ebp)
  80116f:	ff 75 0c             	pushl  0xc(%ebp)
  801172:	50                   	push   %eax
  801173:	e8 45 01 00 00       	call   8012bd <nsipc_bind>
  801178:	83 c4 10             	add    $0x10,%esp
}
  80117b:	c9                   	leave  
  80117c:	c3                   	ret    

0080117d <shutdown>:
{
  80117d:	f3 0f 1e fb          	endbr32 
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801187:	8b 45 08             	mov    0x8(%ebp),%eax
  80118a:	e8 ed fe ff ff       	call   80107c <fd2sockid>
  80118f:	85 c0                	test   %eax,%eax
  801191:	78 0f                	js     8011a2 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801193:	83 ec 08             	sub    $0x8,%esp
  801196:	ff 75 0c             	pushl  0xc(%ebp)
  801199:	50                   	push   %eax
  80119a:	e8 57 01 00 00       	call   8012f6 <nsipc_shutdown>
  80119f:	83 c4 10             	add    $0x10,%esp
}
  8011a2:	c9                   	leave  
  8011a3:	c3                   	ret    

008011a4 <connect>:
{
  8011a4:	f3 0f 1e fb          	endbr32 
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8011ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b1:	e8 c6 fe ff ff       	call   80107c <fd2sockid>
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	78 12                	js     8011cc <connect+0x28>
	return nsipc_connect(r, name, namelen);
  8011ba:	83 ec 04             	sub    $0x4,%esp
  8011bd:	ff 75 10             	pushl  0x10(%ebp)
  8011c0:	ff 75 0c             	pushl  0xc(%ebp)
  8011c3:	50                   	push   %eax
  8011c4:	e8 71 01 00 00       	call   80133a <nsipc_connect>
  8011c9:	83 c4 10             	add    $0x10,%esp
}
  8011cc:	c9                   	leave  
  8011cd:	c3                   	ret    

008011ce <listen>:
{
  8011ce:	f3 0f 1e fb          	endbr32 
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8011d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011db:	e8 9c fe ff ff       	call   80107c <fd2sockid>
  8011e0:	85 c0                	test   %eax,%eax
  8011e2:	78 0f                	js     8011f3 <listen+0x25>
	return nsipc_listen(r, backlog);
  8011e4:	83 ec 08             	sub    $0x8,%esp
  8011e7:	ff 75 0c             	pushl  0xc(%ebp)
  8011ea:	50                   	push   %eax
  8011eb:	e8 83 01 00 00       	call   801373 <nsipc_listen>
  8011f0:	83 c4 10             	add    $0x10,%esp
}
  8011f3:	c9                   	leave  
  8011f4:	c3                   	ret    

008011f5 <socket>:

int
socket(int domain, int type, int protocol)
{
  8011f5:	f3 0f 1e fb          	endbr32 
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8011ff:	ff 75 10             	pushl  0x10(%ebp)
  801202:	ff 75 0c             	pushl  0xc(%ebp)
  801205:	ff 75 08             	pushl  0x8(%ebp)
  801208:	e8 65 02 00 00       	call   801472 <nsipc_socket>
  80120d:	83 c4 10             	add    $0x10,%esp
  801210:	85 c0                	test   %eax,%eax
  801212:	78 05                	js     801219 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801214:	e8 93 fe ff ff       	call   8010ac <alloc_sockfd>
}
  801219:	c9                   	leave  
  80121a:	c3                   	ret    

0080121b <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	53                   	push   %ebx
  80121f:	83 ec 04             	sub    $0x4,%esp
  801222:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801224:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80122b:	74 26                	je     801253 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80122d:	6a 07                	push   $0x7
  80122f:	68 00 60 80 00       	push   $0x806000
  801234:	53                   	push   %ebx
  801235:	ff 35 04 40 80 00    	pushl  0x804004
  80123b:	e8 76 0e 00 00       	call   8020b6 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801240:	83 c4 0c             	add    $0xc,%esp
  801243:	6a 00                	push   $0x0
  801245:	6a 00                	push   $0x0
  801247:	6a 00                	push   $0x0
  801249:	e8 fb 0d 00 00       	call   802049 <ipc_recv>
}
  80124e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801251:	c9                   	leave  
  801252:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801253:	83 ec 0c             	sub    $0xc,%esp
  801256:	6a 02                	push   $0x2
  801258:	e8 b1 0e 00 00       	call   80210e <ipc_find_env>
  80125d:	a3 04 40 80 00       	mov    %eax,0x804004
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	eb c6                	jmp    80122d <nsipc+0x12>

00801267 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801267:	f3 0f 1e fb          	endbr32 
  80126b:	55                   	push   %ebp
  80126c:	89 e5                	mov    %esp,%ebp
  80126e:	56                   	push   %esi
  80126f:	53                   	push   %ebx
  801270:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801273:	8b 45 08             	mov    0x8(%ebp),%eax
  801276:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80127b:	8b 06                	mov    (%esi),%eax
  80127d:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801282:	b8 01 00 00 00       	mov    $0x1,%eax
  801287:	e8 8f ff ff ff       	call   80121b <nsipc>
  80128c:	89 c3                	mov    %eax,%ebx
  80128e:	85 c0                	test   %eax,%eax
  801290:	79 09                	jns    80129b <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801292:	89 d8                	mov    %ebx,%eax
  801294:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801297:	5b                   	pop    %ebx
  801298:	5e                   	pop    %esi
  801299:	5d                   	pop    %ebp
  80129a:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80129b:	83 ec 04             	sub    $0x4,%esp
  80129e:	ff 35 10 60 80 00    	pushl  0x806010
  8012a4:	68 00 60 80 00       	push   $0x806000
  8012a9:	ff 75 0c             	pushl  0xc(%ebp)
  8012ac:	e8 e0 f0 ff ff       	call   800391 <memmove>
		*addrlen = ret->ret_addrlen;
  8012b1:	a1 10 60 80 00       	mov    0x806010,%eax
  8012b6:	89 06                	mov    %eax,(%esi)
  8012b8:	83 c4 10             	add    $0x10,%esp
	return r;
  8012bb:	eb d5                	jmp    801292 <nsipc_accept+0x2b>

008012bd <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8012bd:	f3 0f 1e fb          	endbr32 
  8012c1:	55                   	push   %ebp
  8012c2:	89 e5                	mov    %esp,%ebp
  8012c4:	53                   	push   %ebx
  8012c5:	83 ec 08             	sub    $0x8,%esp
  8012c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8012cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ce:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8012d3:	53                   	push   %ebx
  8012d4:	ff 75 0c             	pushl  0xc(%ebp)
  8012d7:	68 04 60 80 00       	push   $0x806004
  8012dc:	e8 b0 f0 ff ff       	call   800391 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8012e1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8012e7:	b8 02 00 00 00       	mov    $0x2,%eax
  8012ec:	e8 2a ff ff ff       	call   80121b <nsipc>
}
  8012f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f4:	c9                   	leave  
  8012f5:	c3                   	ret    

008012f6 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8012f6:	f3 0f 1e fb          	endbr32 
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801300:	8b 45 08             	mov    0x8(%ebp),%eax
  801303:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801308:	8b 45 0c             	mov    0xc(%ebp),%eax
  80130b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801310:	b8 03 00 00 00       	mov    $0x3,%eax
  801315:	e8 01 ff ff ff       	call   80121b <nsipc>
}
  80131a:	c9                   	leave  
  80131b:	c3                   	ret    

0080131c <nsipc_close>:

int
nsipc_close(int s)
{
  80131c:	f3 0f 1e fb          	endbr32 
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801326:	8b 45 08             	mov    0x8(%ebp),%eax
  801329:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80132e:	b8 04 00 00 00       	mov    $0x4,%eax
  801333:	e8 e3 fe ff ff       	call   80121b <nsipc>
}
  801338:	c9                   	leave  
  801339:	c3                   	ret    

0080133a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80133a:	f3 0f 1e fb          	endbr32 
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	53                   	push   %ebx
  801342:	83 ec 08             	sub    $0x8,%esp
  801345:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801348:	8b 45 08             	mov    0x8(%ebp),%eax
  80134b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801350:	53                   	push   %ebx
  801351:	ff 75 0c             	pushl  0xc(%ebp)
  801354:	68 04 60 80 00       	push   $0x806004
  801359:	e8 33 f0 ff ff       	call   800391 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80135e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801364:	b8 05 00 00 00       	mov    $0x5,%eax
  801369:	e8 ad fe ff ff       	call   80121b <nsipc>
}
  80136e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801371:	c9                   	leave  
  801372:	c3                   	ret    

00801373 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801373:	f3 0f 1e fb          	endbr32 
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80137d:	8b 45 08             	mov    0x8(%ebp),%eax
  801380:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801385:	8b 45 0c             	mov    0xc(%ebp),%eax
  801388:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80138d:	b8 06 00 00 00       	mov    $0x6,%eax
  801392:	e8 84 fe ff ff       	call   80121b <nsipc>
}
  801397:	c9                   	leave  
  801398:	c3                   	ret    

00801399 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801399:	f3 0f 1e fb          	endbr32 
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	56                   	push   %esi
  8013a1:	53                   	push   %ebx
  8013a2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8013a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8013ad:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8013b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b6:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8013bb:	b8 07 00 00 00       	mov    $0x7,%eax
  8013c0:	e8 56 fe ff ff       	call   80121b <nsipc>
  8013c5:	89 c3                	mov    %eax,%ebx
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	78 26                	js     8013f1 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  8013cb:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  8013d1:	b8 3f 06 00 00       	mov    $0x63f,%eax
  8013d6:	0f 4e c6             	cmovle %esi,%eax
  8013d9:	39 c3                	cmp    %eax,%ebx
  8013db:	7f 1d                	jg     8013fa <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8013dd:	83 ec 04             	sub    $0x4,%esp
  8013e0:	53                   	push   %ebx
  8013e1:	68 00 60 80 00       	push   $0x806000
  8013e6:	ff 75 0c             	pushl  0xc(%ebp)
  8013e9:	e8 a3 ef ff ff       	call   800391 <memmove>
  8013ee:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8013f1:	89 d8                	mov    %ebx,%eax
  8013f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f6:	5b                   	pop    %ebx
  8013f7:	5e                   	pop    %esi
  8013f8:	5d                   	pop    %ebp
  8013f9:	c3                   	ret    
		assert(r < 1600 && r <= len);
  8013fa:	68 3f 25 80 00       	push   $0x80253f
  8013ff:	68 a7 24 80 00       	push   $0x8024a7
  801404:	6a 62                	push   $0x62
  801406:	68 54 25 80 00       	push   $0x802554
  80140b:	e8 8b 05 00 00       	call   80199b <_panic>

00801410 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801410:	f3 0f 1e fb          	endbr32 
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	53                   	push   %ebx
  801418:	83 ec 04             	sub    $0x4,%esp
  80141b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80141e:	8b 45 08             	mov    0x8(%ebp),%eax
  801421:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801426:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80142c:	7f 2e                	jg     80145c <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80142e:	83 ec 04             	sub    $0x4,%esp
  801431:	53                   	push   %ebx
  801432:	ff 75 0c             	pushl  0xc(%ebp)
  801435:	68 0c 60 80 00       	push   $0x80600c
  80143a:	e8 52 ef ff ff       	call   800391 <memmove>
	nsipcbuf.send.req_size = size;
  80143f:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801445:	8b 45 14             	mov    0x14(%ebp),%eax
  801448:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80144d:	b8 08 00 00 00       	mov    $0x8,%eax
  801452:	e8 c4 fd ff ff       	call   80121b <nsipc>
}
  801457:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80145a:	c9                   	leave  
  80145b:	c3                   	ret    
	assert(size < 1600);
  80145c:	68 60 25 80 00       	push   $0x802560
  801461:	68 a7 24 80 00       	push   $0x8024a7
  801466:	6a 6d                	push   $0x6d
  801468:	68 54 25 80 00       	push   $0x802554
  80146d:	e8 29 05 00 00       	call   80199b <_panic>

00801472 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801472:	f3 0f 1e fb          	endbr32 
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80147c:	8b 45 08             	mov    0x8(%ebp),%eax
  80147f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801484:	8b 45 0c             	mov    0xc(%ebp),%eax
  801487:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80148c:	8b 45 10             	mov    0x10(%ebp),%eax
  80148f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801494:	b8 09 00 00 00       	mov    $0x9,%eax
  801499:	e8 7d fd ff ff       	call   80121b <nsipc>
}
  80149e:	c9                   	leave  
  80149f:	c3                   	ret    

008014a0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014a0:	f3 0f 1e fb          	endbr32 
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
  8014a7:	56                   	push   %esi
  8014a8:	53                   	push   %ebx
  8014a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8014ac:	83 ec 0c             	sub    $0xc,%esp
  8014af:	ff 75 08             	pushl  0x8(%ebp)
  8014b2:	e8 f0 f2 ff ff       	call   8007a7 <fd2data>
  8014b7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8014b9:	83 c4 08             	add    $0x8,%esp
  8014bc:	68 6c 25 80 00       	push   $0x80256c
  8014c1:	53                   	push   %ebx
  8014c2:	e8 cc ec ff ff       	call   800193 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8014c7:	8b 46 04             	mov    0x4(%esi),%eax
  8014ca:	2b 06                	sub    (%esi),%eax
  8014cc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8014d2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014d9:	00 00 00 
	stat->st_dev = &devpipe;
  8014dc:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  8014e3:	30 80 00 
	return 0;
}
  8014e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ee:	5b                   	pop    %ebx
  8014ef:	5e                   	pop    %esi
  8014f0:	5d                   	pop    %ebp
  8014f1:	c3                   	ret    

008014f2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8014f2:	f3 0f 1e fb          	endbr32 
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	53                   	push   %ebx
  8014fa:	83 ec 0c             	sub    $0xc,%esp
  8014fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801500:	53                   	push   %ebx
  801501:	6a 00                	push   $0x0
  801503:	e8 3f f1 ff ff       	call   800647 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801508:	89 1c 24             	mov    %ebx,(%esp)
  80150b:	e8 97 f2 ff ff       	call   8007a7 <fd2data>
  801510:	83 c4 08             	add    $0x8,%esp
  801513:	50                   	push   %eax
  801514:	6a 00                	push   $0x0
  801516:	e8 2c f1 ff ff       	call   800647 <sys_page_unmap>
}
  80151b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151e:	c9                   	leave  
  80151f:	c3                   	ret    

00801520 <_pipeisclosed>:
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
  801523:	57                   	push   %edi
  801524:	56                   	push   %esi
  801525:	53                   	push   %ebx
  801526:	83 ec 1c             	sub    $0x1c,%esp
  801529:	89 c7                	mov    %eax,%edi
  80152b:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80152d:	a1 08 40 80 00       	mov    0x804008,%eax
  801532:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801535:	83 ec 0c             	sub    $0xc,%esp
  801538:	57                   	push   %edi
  801539:	e8 0d 0c 00 00       	call   80214b <pageref>
  80153e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801541:	89 34 24             	mov    %esi,(%esp)
  801544:	e8 02 0c 00 00       	call   80214b <pageref>
		nn = thisenv->env_runs;
  801549:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80154f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801552:	83 c4 10             	add    $0x10,%esp
  801555:	39 cb                	cmp    %ecx,%ebx
  801557:	74 1b                	je     801574 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801559:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80155c:	75 cf                	jne    80152d <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80155e:	8b 42 58             	mov    0x58(%edx),%eax
  801561:	6a 01                	push   $0x1
  801563:	50                   	push   %eax
  801564:	53                   	push   %ebx
  801565:	68 73 25 80 00       	push   $0x802573
  80156a:	e8 13 05 00 00       	call   801a82 <cprintf>
  80156f:	83 c4 10             	add    $0x10,%esp
  801572:	eb b9                	jmp    80152d <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801574:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801577:	0f 94 c0             	sete   %al
  80157a:	0f b6 c0             	movzbl %al,%eax
}
  80157d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801580:	5b                   	pop    %ebx
  801581:	5e                   	pop    %esi
  801582:	5f                   	pop    %edi
  801583:	5d                   	pop    %ebp
  801584:	c3                   	ret    

00801585 <devpipe_write>:
{
  801585:	f3 0f 1e fb          	endbr32 
  801589:	55                   	push   %ebp
  80158a:	89 e5                	mov    %esp,%ebp
  80158c:	57                   	push   %edi
  80158d:	56                   	push   %esi
  80158e:	53                   	push   %ebx
  80158f:	83 ec 28             	sub    $0x28,%esp
  801592:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801595:	56                   	push   %esi
  801596:	e8 0c f2 ff ff       	call   8007a7 <fd2data>
  80159b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80159d:	83 c4 10             	add    $0x10,%esp
  8015a0:	bf 00 00 00 00       	mov    $0x0,%edi
  8015a5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8015a8:	74 4f                	je     8015f9 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015aa:	8b 43 04             	mov    0x4(%ebx),%eax
  8015ad:	8b 0b                	mov    (%ebx),%ecx
  8015af:	8d 51 20             	lea    0x20(%ecx),%edx
  8015b2:	39 d0                	cmp    %edx,%eax
  8015b4:	72 14                	jb     8015ca <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8015b6:	89 da                	mov    %ebx,%edx
  8015b8:	89 f0                	mov    %esi,%eax
  8015ba:	e8 61 ff ff ff       	call   801520 <_pipeisclosed>
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	75 3b                	jne    8015fe <devpipe_write+0x79>
			sys_yield();
  8015c3:	e8 11 f0 ff ff       	call   8005d9 <sys_yield>
  8015c8:	eb e0                	jmp    8015aa <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8015ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015cd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8015d1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8015d4:	89 c2                	mov    %eax,%edx
  8015d6:	c1 fa 1f             	sar    $0x1f,%edx
  8015d9:	89 d1                	mov    %edx,%ecx
  8015db:	c1 e9 1b             	shr    $0x1b,%ecx
  8015de:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8015e1:	83 e2 1f             	and    $0x1f,%edx
  8015e4:	29 ca                	sub    %ecx,%edx
  8015e6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8015ea:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8015ee:	83 c0 01             	add    $0x1,%eax
  8015f1:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8015f4:	83 c7 01             	add    $0x1,%edi
  8015f7:	eb ac                	jmp    8015a5 <devpipe_write+0x20>
	return i;
  8015f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8015fc:	eb 05                	jmp    801603 <devpipe_write+0x7e>
				return 0;
  8015fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801603:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801606:	5b                   	pop    %ebx
  801607:	5e                   	pop    %esi
  801608:	5f                   	pop    %edi
  801609:	5d                   	pop    %ebp
  80160a:	c3                   	ret    

0080160b <devpipe_read>:
{
  80160b:	f3 0f 1e fb          	endbr32 
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	57                   	push   %edi
  801613:	56                   	push   %esi
  801614:	53                   	push   %ebx
  801615:	83 ec 18             	sub    $0x18,%esp
  801618:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80161b:	57                   	push   %edi
  80161c:	e8 86 f1 ff ff       	call   8007a7 <fd2data>
  801621:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	be 00 00 00 00       	mov    $0x0,%esi
  80162b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80162e:	75 14                	jne    801644 <devpipe_read+0x39>
	return i;
  801630:	8b 45 10             	mov    0x10(%ebp),%eax
  801633:	eb 02                	jmp    801637 <devpipe_read+0x2c>
				return i;
  801635:	89 f0                	mov    %esi,%eax
}
  801637:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163a:	5b                   	pop    %ebx
  80163b:	5e                   	pop    %esi
  80163c:	5f                   	pop    %edi
  80163d:	5d                   	pop    %ebp
  80163e:	c3                   	ret    
			sys_yield();
  80163f:	e8 95 ef ff ff       	call   8005d9 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801644:	8b 03                	mov    (%ebx),%eax
  801646:	3b 43 04             	cmp    0x4(%ebx),%eax
  801649:	75 18                	jne    801663 <devpipe_read+0x58>
			if (i > 0)
  80164b:	85 f6                	test   %esi,%esi
  80164d:	75 e6                	jne    801635 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  80164f:	89 da                	mov    %ebx,%edx
  801651:	89 f8                	mov    %edi,%eax
  801653:	e8 c8 fe ff ff       	call   801520 <_pipeisclosed>
  801658:	85 c0                	test   %eax,%eax
  80165a:	74 e3                	je     80163f <devpipe_read+0x34>
				return 0;
  80165c:	b8 00 00 00 00       	mov    $0x0,%eax
  801661:	eb d4                	jmp    801637 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801663:	99                   	cltd   
  801664:	c1 ea 1b             	shr    $0x1b,%edx
  801667:	01 d0                	add    %edx,%eax
  801669:	83 e0 1f             	and    $0x1f,%eax
  80166c:	29 d0                	sub    %edx,%eax
  80166e:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801673:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801676:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801679:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80167c:	83 c6 01             	add    $0x1,%esi
  80167f:	eb aa                	jmp    80162b <devpipe_read+0x20>

00801681 <pipe>:
{
  801681:	f3 0f 1e fb          	endbr32 
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	56                   	push   %esi
  801689:	53                   	push   %ebx
  80168a:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80168d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801690:	50                   	push   %eax
  801691:	e8 2c f1 ff ff       	call   8007c2 <fd_alloc>
  801696:	89 c3                	mov    %eax,%ebx
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	85 c0                	test   %eax,%eax
  80169d:	0f 88 23 01 00 00    	js     8017c6 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016a3:	83 ec 04             	sub    $0x4,%esp
  8016a6:	68 07 04 00 00       	push   $0x407
  8016ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8016ae:	6a 00                	push   $0x0
  8016b0:	e8 47 ef ff ff       	call   8005fc <sys_page_alloc>
  8016b5:	89 c3                	mov    %eax,%ebx
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	0f 88 04 01 00 00    	js     8017c6 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8016c2:	83 ec 0c             	sub    $0xc,%esp
  8016c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c8:	50                   	push   %eax
  8016c9:	e8 f4 f0 ff ff       	call   8007c2 <fd_alloc>
  8016ce:	89 c3                	mov    %eax,%ebx
  8016d0:	83 c4 10             	add    $0x10,%esp
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	0f 88 db 00 00 00    	js     8017b6 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016db:	83 ec 04             	sub    $0x4,%esp
  8016de:	68 07 04 00 00       	push   $0x407
  8016e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8016e6:	6a 00                	push   $0x0
  8016e8:	e8 0f ef ff ff       	call   8005fc <sys_page_alloc>
  8016ed:	89 c3                	mov    %eax,%ebx
  8016ef:	83 c4 10             	add    $0x10,%esp
  8016f2:	85 c0                	test   %eax,%eax
  8016f4:	0f 88 bc 00 00 00    	js     8017b6 <pipe+0x135>
	va = fd2data(fd0);
  8016fa:	83 ec 0c             	sub    $0xc,%esp
  8016fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801700:	e8 a2 f0 ff ff       	call   8007a7 <fd2data>
  801705:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801707:	83 c4 0c             	add    $0xc,%esp
  80170a:	68 07 04 00 00       	push   $0x407
  80170f:	50                   	push   %eax
  801710:	6a 00                	push   $0x0
  801712:	e8 e5 ee ff ff       	call   8005fc <sys_page_alloc>
  801717:	89 c3                	mov    %eax,%ebx
  801719:	83 c4 10             	add    $0x10,%esp
  80171c:	85 c0                	test   %eax,%eax
  80171e:	0f 88 82 00 00 00    	js     8017a6 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801724:	83 ec 0c             	sub    $0xc,%esp
  801727:	ff 75 f0             	pushl  -0x10(%ebp)
  80172a:	e8 78 f0 ff ff       	call   8007a7 <fd2data>
  80172f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801736:	50                   	push   %eax
  801737:	6a 00                	push   $0x0
  801739:	56                   	push   %esi
  80173a:	6a 00                	push   $0x0
  80173c:	e8 e1 ee ff ff       	call   800622 <sys_page_map>
  801741:	89 c3                	mov    %eax,%ebx
  801743:	83 c4 20             	add    $0x20,%esp
  801746:	85 c0                	test   %eax,%eax
  801748:	78 4e                	js     801798 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  80174a:	a1 7c 30 80 00       	mov    0x80307c,%eax
  80174f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801752:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801754:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801757:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80175e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801761:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801763:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801766:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80176d:	83 ec 0c             	sub    $0xc,%esp
  801770:	ff 75 f4             	pushl  -0xc(%ebp)
  801773:	e8 1b f0 ff ff       	call   800793 <fd2num>
  801778:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80177b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80177d:	83 c4 04             	add    $0x4,%esp
  801780:	ff 75 f0             	pushl  -0x10(%ebp)
  801783:	e8 0b f0 ff ff       	call   800793 <fd2num>
  801788:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80178b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80178e:	83 c4 10             	add    $0x10,%esp
  801791:	bb 00 00 00 00       	mov    $0x0,%ebx
  801796:	eb 2e                	jmp    8017c6 <pipe+0x145>
	sys_page_unmap(0, va);
  801798:	83 ec 08             	sub    $0x8,%esp
  80179b:	56                   	push   %esi
  80179c:	6a 00                	push   $0x0
  80179e:	e8 a4 ee ff ff       	call   800647 <sys_page_unmap>
  8017a3:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8017a6:	83 ec 08             	sub    $0x8,%esp
  8017a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ac:	6a 00                	push   $0x0
  8017ae:	e8 94 ee ff ff       	call   800647 <sys_page_unmap>
  8017b3:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8017b6:	83 ec 08             	sub    $0x8,%esp
  8017b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8017bc:	6a 00                	push   $0x0
  8017be:	e8 84 ee ff ff       	call   800647 <sys_page_unmap>
  8017c3:	83 c4 10             	add    $0x10,%esp
}
  8017c6:	89 d8                	mov    %ebx,%eax
  8017c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017cb:	5b                   	pop    %ebx
  8017cc:	5e                   	pop    %esi
  8017cd:	5d                   	pop    %ebp
  8017ce:	c3                   	ret    

008017cf <pipeisclosed>:
{
  8017cf:	f3 0f 1e fb          	endbr32 
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017dc:	50                   	push   %eax
  8017dd:	ff 75 08             	pushl  0x8(%ebp)
  8017e0:	e8 33 f0 ff ff       	call   800818 <fd_lookup>
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	78 18                	js     801804 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  8017ec:	83 ec 0c             	sub    $0xc,%esp
  8017ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f2:	e8 b0 ef ff ff       	call   8007a7 <fd2data>
  8017f7:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8017f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fc:	e8 1f fd ff ff       	call   801520 <_pipeisclosed>
  801801:	83 c4 10             	add    $0x10,%esp
}
  801804:	c9                   	leave  
  801805:	c3                   	ret    

00801806 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801806:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  80180a:	b8 00 00 00 00       	mov    $0x0,%eax
  80180f:	c3                   	ret    

00801810 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801810:	f3 0f 1e fb          	endbr32 
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80181a:	68 8b 25 80 00       	push   $0x80258b
  80181f:	ff 75 0c             	pushl  0xc(%ebp)
  801822:	e8 6c e9 ff ff       	call   800193 <strcpy>
	return 0;
}
  801827:	b8 00 00 00 00       	mov    $0x0,%eax
  80182c:	c9                   	leave  
  80182d:	c3                   	ret    

0080182e <devcons_write>:
{
  80182e:	f3 0f 1e fb          	endbr32 
  801832:	55                   	push   %ebp
  801833:	89 e5                	mov    %esp,%ebp
  801835:	57                   	push   %edi
  801836:	56                   	push   %esi
  801837:	53                   	push   %ebx
  801838:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80183e:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801843:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801849:	3b 75 10             	cmp    0x10(%ebp),%esi
  80184c:	73 31                	jae    80187f <devcons_write+0x51>
		m = n - tot;
  80184e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801851:	29 f3                	sub    %esi,%ebx
  801853:	83 fb 7f             	cmp    $0x7f,%ebx
  801856:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80185b:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80185e:	83 ec 04             	sub    $0x4,%esp
  801861:	53                   	push   %ebx
  801862:	89 f0                	mov    %esi,%eax
  801864:	03 45 0c             	add    0xc(%ebp),%eax
  801867:	50                   	push   %eax
  801868:	57                   	push   %edi
  801869:	e8 23 eb ff ff       	call   800391 <memmove>
		sys_cputs(buf, m);
  80186e:	83 c4 08             	add    $0x8,%esp
  801871:	53                   	push   %ebx
  801872:	57                   	push   %edi
  801873:	e8 d5 ec ff ff       	call   80054d <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801878:	01 de                	add    %ebx,%esi
  80187a:	83 c4 10             	add    $0x10,%esp
  80187d:	eb ca                	jmp    801849 <devcons_write+0x1b>
}
  80187f:	89 f0                	mov    %esi,%eax
  801881:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801884:	5b                   	pop    %ebx
  801885:	5e                   	pop    %esi
  801886:	5f                   	pop    %edi
  801887:	5d                   	pop    %ebp
  801888:	c3                   	ret    

00801889 <devcons_read>:
{
  801889:	f3 0f 1e fb          	endbr32 
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	83 ec 08             	sub    $0x8,%esp
  801893:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801898:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80189c:	74 21                	je     8018bf <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  80189e:	e8 cc ec ff ff       	call   80056f <sys_cgetc>
  8018a3:	85 c0                	test   %eax,%eax
  8018a5:	75 07                	jne    8018ae <devcons_read+0x25>
		sys_yield();
  8018a7:	e8 2d ed ff ff       	call   8005d9 <sys_yield>
  8018ac:	eb f0                	jmp    80189e <devcons_read+0x15>
	if (c < 0)
  8018ae:	78 0f                	js     8018bf <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8018b0:	83 f8 04             	cmp    $0x4,%eax
  8018b3:	74 0c                	je     8018c1 <devcons_read+0x38>
	*(char*)vbuf = c;
  8018b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018b8:	88 02                	mov    %al,(%edx)
	return 1;
  8018ba:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8018bf:	c9                   	leave  
  8018c0:	c3                   	ret    
		return 0;
  8018c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c6:	eb f7                	jmp    8018bf <devcons_read+0x36>

008018c8 <cputchar>:
{
  8018c8:	f3 0f 1e fb          	endbr32 
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8018d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d5:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8018d8:	6a 01                	push   $0x1
  8018da:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8018dd:	50                   	push   %eax
  8018de:	e8 6a ec ff ff       	call   80054d <sys_cputs>
}
  8018e3:	83 c4 10             	add    $0x10,%esp
  8018e6:	c9                   	leave  
  8018e7:	c3                   	ret    

008018e8 <getchar>:
{
  8018e8:	f3 0f 1e fb          	endbr32 
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8018f2:	6a 01                	push   $0x1
  8018f4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8018f7:	50                   	push   %eax
  8018f8:	6a 00                	push   $0x0
  8018fa:	e8 a1 f1 ff ff       	call   800aa0 <read>
	if (r < 0)
  8018ff:	83 c4 10             	add    $0x10,%esp
  801902:	85 c0                	test   %eax,%eax
  801904:	78 06                	js     80190c <getchar+0x24>
	if (r < 1)
  801906:	74 06                	je     80190e <getchar+0x26>
	return c;
  801908:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80190c:	c9                   	leave  
  80190d:	c3                   	ret    
		return -E_EOF;
  80190e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801913:	eb f7                	jmp    80190c <getchar+0x24>

00801915 <iscons>:
{
  801915:	f3 0f 1e fb          	endbr32 
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80191f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801922:	50                   	push   %eax
  801923:	ff 75 08             	pushl  0x8(%ebp)
  801926:	e8 ed ee ff ff       	call   800818 <fd_lookup>
  80192b:	83 c4 10             	add    $0x10,%esp
  80192e:	85 c0                	test   %eax,%eax
  801930:	78 11                	js     801943 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801932:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801935:	8b 15 98 30 80 00    	mov    0x803098,%edx
  80193b:	39 10                	cmp    %edx,(%eax)
  80193d:	0f 94 c0             	sete   %al
  801940:	0f b6 c0             	movzbl %al,%eax
}
  801943:	c9                   	leave  
  801944:	c3                   	ret    

00801945 <opencons>:
{
  801945:	f3 0f 1e fb          	endbr32 
  801949:	55                   	push   %ebp
  80194a:	89 e5                	mov    %esp,%ebp
  80194c:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80194f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801952:	50                   	push   %eax
  801953:	e8 6a ee ff ff       	call   8007c2 <fd_alloc>
  801958:	83 c4 10             	add    $0x10,%esp
  80195b:	85 c0                	test   %eax,%eax
  80195d:	78 3a                	js     801999 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80195f:	83 ec 04             	sub    $0x4,%esp
  801962:	68 07 04 00 00       	push   $0x407
  801967:	ff 75 f4             	pushl  -0xc(%ebp)
  80196a:	6a 00                	push   $0x0
  80196c:	e8 8b ec ff ff       	call   8005fc <sys_page_alloc>
  801971:	83 c4 10             	add    $0x10,%esp
  801974:	85 c0                	test   %eax,%eax
  801976:	78 21                	js     801999 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801978:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80197b:	8b 15 98 30 80 00    	mov    0x803098,%edx
  801981:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801983:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801986:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80198d:	83 ec 0c             	sub    $0xc,%esp
  801990:	50                   	push   %eax
  801991:	e8 fd ed ff ff       	call   800793 <fd2num>
  801996:	83 c4 10             	add    $0x10,%esp
}
  801999:	c9                   	leave  
  80199a:	c3                   	ret    

0080199b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80199b:	f3 0f 1e fb          	endbr32 
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	56                   	push   %esi
  8019a3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019a4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019a7:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019ad:	e8 04 ec ff ff       	call   8005b6 <sys_getenvid>
  8019b2:	83 ec 0c             	sub    $0xc,%esp
  8019b5:	ff 75 0c             	pushl  0xc(%ebp)
  8019b8:	ff 75 08             	pushl  0x8(%ebp)
  8019bb:	56                   	push   %esi
  8019bc:	50                   	push   %eax
  8019bd:	68 98 25 80 00       	push   $0x802598
  8019c2:	e8 bb 00 00 00       	call   801a82 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019c7:	83 c4 18             	add    $0x18,%esp
  8019ca:	53                   	push   %ebx
  8019cb:	ff 75 10             	pushl  0x10(%ebp)
  8019ce:	e8 5a 00 00 00       	call   801a2d <vcprintf>
	cprintf("\n");
  8019d3:	c7 04 24 84 25 80 00 	movl   $0x802584,(%esp)
  8019da:	e8 a3 00 00 00       	call   801a82 <cprintf>
  8019df:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019e2:	cc                   	int3   
  8019e3:	eb fd                	jmp    8019e2 <_panic+0x47>

008019e5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8019e5:	f3 0f 1e fb          	endbr32 
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	53                   	push   %ebx
  8019ed:	83 ec 04             	sub    $0x4,%esp
  8019f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8019f3:	8b 13                	mov    (%ebx),%edx
  8019f5:	8d 42 01             	lea    0x1(%edx),%eax
  8019f8:	89 03                	mov    %eax,(%ebx)
  8019fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019fd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801a01:	3d ff 00 00 00       	cmp    $0xff,%eax
  801a06:	74 09                	je     801a11 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801a08:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801a0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a0f:	c9                   	leave  
  801a10:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801a11:	83 ec 08             	sub    $0x8,%esp
  801a14:	68 ff 00 00 00       	push   $0xff
  801a19:	8d 43 08             	lea    0x8(%ebx),%eax
  801a1c:	50                   	push   %eax
  801a1d:	e8 2b eb ff ff       	call   80054d <sys_cputs>
		b->idx = 0;
  801a22:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a28:	83 c4 10             	add    $0x10,%esp
  801a2b:	eb db                	jmp    801a08 <putch+0x23>

00801a2d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801a2d:	f3 0f 1e fb          	endbr32 
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801a3a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a41:	00 00 00 
	b.cnt = 0;
  801a44:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801a4b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801a4e:	ff 75 0c             	pushl  0xc(%ebp)
  801a51:	ff 75 08             	pushl  0x8(%ebp)
  801a54:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801a5a:	50                   	push   %eax
  801a5b:	68 e5 19 80 00       	push   $0x8019e5
  801a60:	e8 20 01 00 00       	call   801b85 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801a65:	83 c4 08             	add    $0x8,%esp
  801a68:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801a6e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801a74:	50                   	push   %eax
  801a75:	e8 d3 ea ff ff       	call   80054d <sys_cputs>

	return b.cnt;
}
  801a7a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801a80:	c9                   	leave  
  801a81:	c3                   	ret    

00801a82 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801a82:	f3 0f 1e fb          	endbr32 
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a8c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801a8f:	50                   	push   %eax
  801a90:	ff 75 08             	pushl  0x8(%ebp)
  801a93:	e8 95 ff ff ff       	call   801a2d <vcprintf>
	va_end(ap);

	return cnt;
}
  801a98:	c9                   	leave  
  801a99:	c3                   	ret    

00801a9a <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801a9a:	55                   	push   %ebp
  801a9b:	89 e5                	mov    %esp,%ebp
  801a9d:	57                   	push   %edi
  801a9e:	56                   	push   %esi
  801a9f:	53                   	push   %ebx
  801aa0:	83 ec 1c             	sub    $0x1c,%esp
  801aa3:	89 c7                	mov    %eax,%edi
  801aa5:	89 d6                	mov    %edx,%esi
  801aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aaa:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aad:	89 d1                	mov    %edx,%ecx
  801aaf:	89 c2                	mov    %eax,%edx
  801ab1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ab4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801ab7:	8b 45 10             	mov    0x10(%ebp),%eax
  801aba:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  801abd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ac0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801ac7:	39 c2                	cmp    %eax,%edx
  801ac9:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801acc:	72 3e                	jb     801b0c <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801ace:	83 ec 0c             	sub    $0xc,%esp
  801ad1:	ff 75 18             	pushl  0x18(%ebp)
  801ad4:	83 eb 01             	sub    $0x1,%ebx
  801ad7:	53                   	push   %ebx
  801ad8:	50                   	push   %eax
  801ad9:	83 ec 08             	sub    $0x8,%esp
  801adc:	ff 75 e4             	pushl  -0x1c(%ebp)
  801adf:	ff 75 e0             	pushl  -0x20(%ebp)
  801ae2:	ff 75 dc             	pushl  -0x24(%ebp)
  801ae5:	ff 75 d8             	pushl  -0x28(%ebp)
  801ae8:	e8 a3 06 00 00       	call   802190 <__udivdi3>
  801aed:	83 c4 18             	add    $0x18,%esp
  801af0:	52                   	push   %edx
  801af1:	50                   	push   %eax
  801af2:	89 f2                	mov    %esi,%edx
  801af4:	89 f8                	mov    %edi,%eax
  801af6:	e8 9f ff ff ff       	call   801a9a <printnum>
  801afb:	83 c4 20             	add    $0x20,%esp
  801afe:	eb 13                	jmp    801b13 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801b00:	83 ec 08             	sub    $0x8,%esp
  801b03:	56                   	push   %esi
  801b04:	ff 75 18             	pushl  0x18(%ebp)
  801b07:	ff d7                	call   *%edi
  801b09:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801b0c:	83 eb 01             	sub    $0x1,%ebx
  801b0f:	85 db                	test   %ebx,%ebx
  801b11:	7f ed                	jg     801b00 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801b13:	83 ec 08             	sub    $0x8,%esp
  801b16:	56                   	push   %esi
  801b17:	83 ec 04             	sub    $0x4,%esp
  801b1a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b1d:	ff 75 e0             	pushl  -0x20(%ebp)
  801b20:	ff 75 dc             	pushl  -0x24(%ebp)
  801b23:	ff 75 d8             	pushl  -0x28(%ebp)
  801b26:	e8 75 07 00 00       	call   8022a0 <__umoddi3>
  801b2b:	83 c4 14             	add    $0x14,%esp
  801b2e:	0f be 80 bb 25 80 00 	movsbl 0x8025bb(%eax),%eax
  801b35:	50                   	push   %eax
  801b36:	ff d7                	call   *%edi
}
  801b38:	83 c4 10             	add    $0x10,%esp
  801b3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3e:	5b                   	pop    %ebx
  801b3f:	5e                   	pop    %esi
  801b40:	5f                   	pop    %edi
  801b41:	5d                   	pop    %ebp
  801b42:	c3                   	ret    

00801b43 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801b43:	f3 0f 1e fb          	endbr32 
  801b47:	55                   	push   %ebp
  801b48:	89 e5                	mov    %esp,%ebp
  801b4a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801b4d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801b51:	8b 10                	mov    (%eax),%edx
  801b53:	3b 50 04             	cmp    0x4(%eax),%edx
  801b56:	73 0a                	jae    801b62 <sprintputch+0x1f>
		*b->buf++ = ch;
  801b58:	8d 4a 01             	lea    0x1(%edx),%ecx
  801b5b:	89 08                	mov    %ecx,(%eax)
  801b5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b60:	88 02                	mov    %al,(%edx)
}
  801b62:	5d                   	pop    %ebp
  801b63:	c3                   	ret    

00801b64 <printfmt>:
{
  801b64:	f3 0f 1e fb          	endbr32 
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801b6e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801b71:	50                   	push   %eax
  801b72:	ff 75 10             	pushl  0x10(%ebp)
  801b75:	ff 75 0c             	pushl  0xc(%ebp)
  801b78:	ff 75 08             	pushl  0x8(%ebp)
  801b7b:	e8 05 00 00 00       	call   801b85 <vprintfmt>
}
  801b80:	83 c4 10             	add    $0x10,%esp
  801b83:	c9                   	leave  
  801b84:	c3                   	ret    

00801b85 <vprintfmt>:
{
  801b85:	f3 0f 1e fb          	endbr32 
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	57                   	push   %edi
  801b8d:	56                   	push   %esi
  801b8e:	53                   	push   %ebx
  801b8f:	83 ec 3c             	sub    $0x3c,%esp
  801b92:	8b 75 08             	mov    0x8(%ebp),%esi
  801b95:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b98:	8b 7d 10             	mov    0x10(%ebp),%edi
  801b9b:	e9 8e 03 00 00       	jmp    801f2e <vprintfmt+0x3a9>
		padc = ' ';
  801ba0:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  801ba4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801bab:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801bb2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801bb9:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801bbe:	8d 47 01             	lea    0x1(%edi),%eax
  801bc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801bc4:	0f b6 17             	movzbl (%edi),%edx
  801bc7:	8d 42 dd             	lea    -0x23(%edx),%eax
  801bca:	3c 55                	cmp    $0x55,%al
  801bcc:	0f 87 df 03 00 00    	ja     801fb1 <vprintfmt+0x42c>
  801bd2:	0f b6 c0             	movzbl %al,%eax
  801bd5:	3e ff 24 85 00 27 80 	notrack jmp *0x802700(,%eax,4)
  801bdc:	00 
  801bdd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801be0:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801be4:	eb d8                	jmp    801bbe <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801be6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801be9:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801bed:	eb cf                	jmp    801bbe <vprintfmt+0x39>
  801bef:	0f b6 d2             	movzbl %dl,%edx
  801bf2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801bf5:	b8 00 00 00 00       	mov    $0x0,%eax
  801bfa:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  801bfd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801c00:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801c04:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801c07:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801c0a:	83 f9 09             	cmp    $0x9,%ecx
  801c0d:	77 55                	ja     801c64 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  801c0f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  801c12:	eb e9                	jmp    801bfd <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801c14:	8b 45 14             	mov    0x14(%ebp),%eax
  801c17:	8b 00                	mov    (%eax),%eax
  801c19:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801c1c:	8b 45 14             	mov    0x14(%ebp),%eax
  801c1f:	8d 40 04             	lea    0x4(%eax),%eax
  801c22:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801c25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801c28:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801c2c:	79 90                	jns    801bbe <vprintfmt+0x39>
				width = precision, precision = -1;
  801c2e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801c31:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c34:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801c3b:	eb 81                	jmp    801bbe <vprintfmt+0x39>
  801c3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c40:	85 c0                	test   %eax,%eax
  801c42:	ba 00 00 00 00       	mov    $0x0,%edx
  801c47:	0f 49 d0             	cmovns %eax,%edx
  801c4a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801c4d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801c50:	e9 69 ff ff ff       	jmp    801bbe <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801c55:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801c58:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801c5f:	e9 5a ff ff ff       	jmp    801bbe <vprintfmt+0x39>
  801c64:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801c67:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801c6a:	eb bc                	jmp    801c28 <vprintfmt+0xa3>
			lflag++;
  801c6c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801c6f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801c72:	e9 47 ff ff ff       	jmp    801bbe <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  801c77:	8b 45 14             	mov    0x14(%ebp),%eax
  801c7a:	8d 78 04             	lea    0x4(%eax),%edi
  801c7d:	83 ec 08             	sub    $0x8,%esp
  801c80:	53                   	push   %ebx
  801c81:	ff 30                	pushl  (%eax)
  801c83:	ff d6                	call   *%esi
			break;
  801c85:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801c88:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801c8b:	e9 9b 02 00 00       	jmp    801f2b <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  801c90:	8b 45 14             	mov    0x14(%ebp),%eax
  801c93:	8d 78 04             	lea    0x4(%eax),%edi
  801c96:	8b 00                	mov    (%eax),%eax
  801c98:	99                   	cltd   
  801c99:	31 d0                	xor    %edx,%eax
  801c9b:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801c9d:	83 f8 0f             	cmp    $0xf,%eax
  801ca0:	7f 23                	jg     801cc5 <vprintfmt+0x140>
  801ca2:	8b 14 85 60 28 80 00 	mov    0x802860(,%eax,4),%edx
  801ca9:	85 d2                	test   %edx,%edx
  801cab:	74 18                	je     801cc5 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  801cad:	52                   	push   %edx
  801cae:	68 b9 24 80 00       	push   $0x8024b9
  801cb3:	53                   	push   %ebx
  801cb4:	56                   	push   %esi
  801cb5:	e8 aa fe ff ff       	call   801b64 <printfmt>
  801cba:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801cbd:	89 7d 14             	mov    %edi,0x14(%ebp)
  801cc0:	e9 66 02 00 00       	jmp    801f2b <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  801cc5:	50                   	push   %eax
  801cc6:	68 d3 25 80 00       	push   $0x8025d3
  801ccb:	53                   	push   %ebx
  801ccc:	56                   	push   %esi
  801ccd:	e8 92 fe ff ff       	call   801b64 <printfmt>
  801cd2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801cd5:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801cd8:	e9 4e 02 00 00       	jmp    801f2b <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  801cdd:	8b 45 14             	mov    0x14(%ebp),%eax
  801ce0:	83 c0 04             	add    $0x4,%eax
  801ce3:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801ce6:	8b 45 14             	mov    0x14(%ebp),%eax
  801ce9:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801ceb:	85 d2                	test   %edx,%edx
  801ced:	b8 cc 25 80 00       	mov    $0x8025cc,%eax
  801cf2:	0f 45 c2             	cmovne %edx,%eax
  801cf5:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801cf8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801cfc:	7e 06                	jle    801d04 <vprintfmt+0x17f>
  801cfe:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801d02:	75 0d                	jne    801d11 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  801d04:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801d07:	89 c7                	mov    %eax,%edi
  801d09:	03 45 e0             	add    -0x20(%ebp),%eax
  801d0c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d0f:	eb 55                	jmp    801d66 <vprintfmt+0x1e1>
  801d11:	83 ec 08             	sub    $0x8,%esp
  801d14:	ff 75 d8             	pushl  -0x28(%ebp)
  801d17:	ff 75 cc             	pushl  -0x34(%ebp)
  801d1a:	e8 4d e4 ff ff       	call   80016c <strnlen>
  801d1f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801d22:	29 c2                	sub    %eax,%edx
  801d24:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801d27:	83 c4 10             	add    $0x10,%esp
  801d2a:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  801d2c:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801d30:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801d33:	85 ff                	test   %edi,%edi
  801d35:	7e 11                	jle    801d48 <vprintfmt+0x1c3>
					putch(padc, putdat);
  801d37:	83 ec 08             	sub    $0x8,%esp
  801d3a:	53                   	push   %ebx
  801d3b:	ff 75 e0             	pushl  -0x20(%ebp)
  801d3e:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801d40:	83 ef 01             	sub    $0x1,%edi
  801d43:	83 c4 10             	add    $0x10,%esp
  801d46:	eb eb                	jmp    801d33 <vprintfmt+0x1ae>
  801d48:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801d4b:	85 d2                	test   %edx,%edx
  801d4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d52:	0f 49 c2             	cmovns %edx,%eax
  801d55:	29 c2                	sub    %eax,%edx
  801d57:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801d5a:	eb a8                	jmp    801d04 <vprintfmt+0x17f>
					putch(ch, putdat);
  801d5c:	83 ec 08             	sub    $0x8,%esp
  801d5f:	53                   	push   %ebx
  801d60:	52                   	push   %edx
  801d61:	ff d6                	call   *%esi
  801d63:	83 c4 10             	add    $0x10,%esp
  801d66:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801d69:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801d6b:	83 c7 01             	add    $0x1,%edi
  801d6e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801d72:	0f be d0             	movsbl %al,%edx
  801d75:	85 d2                	test   %edx,%edx
  801d77:	74 4b                	je     801dc4 <vprintfmt+0x23f>
  801d79:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801d7d:	78 06                	js     801d85 <vprintfmt+0x200>
  801d7f:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  801d83:	78 1e                	js     801da3 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  801d85:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801d89:	74 d1                	je     801d5c <vprintfmt+0x1d7>
  801d8b:	0f be c0             	movsbl %al,%eax
  801d8e:	83 e8 20             	sub    $0x20,%eax
  801d91:	83 f8 5e             	cmp    $0x5e,%eax
  801d94:	76 c6                	jbe    801d5c <vprintfmt+0x1d7>
					putch('?', putdat);
  801d96:	83 ec 08             	sub    $0x8,%esp
  801d99:	53                   	push   %ebx
  801d9a:	6a 3f                	push   $0x3f
  801d9c:	ff d6                	call   *%esi
  801d9e:	83 c4 10             	add    $0x10,%esp
  801da1:	eb c3                	jmp    801d66 <vprintfmt+0x1e1>
  801da3:	89 cf                	mov    %ecx,%edi
  801da5:	eb 0e                	jmp    801db5 <vprintfmt+0x230>
				putch(' ', putdat);
  801da7:	83 ec 08             	sub    $0x8,%esp
  801daa:	53                   	push   %ebx
  801dab:	6a 20                	push   $0x20
  801dad:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801daf:	83 ef 01             	sub    $0x1,%edi
  801db2:	83 c4 10             	add    $0x10,%esp
  801db5:	85 ff                	test   %edi,%edi
  801db7:	7f ee                	jg     801da7 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  801db9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801dbc:	89 45 14             	mov    %eax,0x14(%ebp)
  801dbf:	e9 67 01 00 00       	jmp    801f2b <vprintfmt+0x3a6>
  801dc4:	89 cf                	mov    %ecx,%edi
  801dc6:	eb ed                	jmp    801db5 <vprintfmt+0x230>
	if (lflag >= 2)
  801dc8:	83 f9 01             	cmp    $0x1,%ecx
  801dcb:	7f 1b                	jg     801de8 <vprintfmt+0x263>
	else if (lflag)
  801dcd:	85 c9                	test   %ecx,%ecx
  801dcf:	74 63                	je     801e34 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  801dd1:	8b 45 14             	mov    0x14(%ebp),%eax
  801dd4:	8b 00                	mov    (%eax),%eax
  801dd6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801dd9:	99                   	cltd   
  801dda:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801ddd:	8b 45 14             	mov    0x14(%ebp),%eax
  801de0:	8d 40 04             	lea    0x4(%eax),%eax
  801de3:	89 45 14             	mov    %eax,0x14(%ebp)
  801de6:	eb 17                	jmp    801dff <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  801de8:	8b 45 14             	mov    0x14(%ebp),%eax
  801deb:	8b 50 04             	mov    0x4(%eax),%edx
  801dee:	8b 00                	mov    (%eax),%eax
  801df0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801df3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801df6:	8b 45 14             	mov    0x14(%ebp),%eax
  801df9:	8d 40 08             	lea    0x8(%eax),%eax
  801dfc:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801dff:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801e02:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801e05:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  801e0a:	85 c9                	test   %ecx,%ecx
  801e0c:	0f 89 ff 00 00 00    	jns    801f11 <vprintfmt+0x38c>
				putch('-', putdat);
  801e12:	83 ec 08             	sub    $0x8,%esp
  801e15:	53                   	push   %ebx
  801e16:	6a 2d                	push   $0x2d
  801e18:	ff d6                	call   *%esi
				num = -(long long) num;
  801e1a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801e1d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801e20:	f7 da                	neg    %edx
  801e22:	83 d1 00             	adc    $0x0,%ecx
  801e25:	f7 d9                	neg    %ecx
  801e27:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801e2a:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e2f:	e9 dd 00 00 00       	jmp    801f11 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  801e34:	8b 45 14             	mov    0x14(%ebp),%eax
  801e37:	8b 00                	mov    (%eax),%eax
  801e39:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e3c:	99                   	cltd   
  801e3d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801e40:	8b 45 14             	mov    0x14(%ebp),%eax
  801e43:	8d 40 04             	lea    0x4(%eax),%eax
  801e46:	89 45 14             	mov    %eax,0x14(%ebp)
  801e49:	eb b4                	jmp    801dff <vprintfmt+0x27a>
	if (lflag >= 2)
  801e4b:	83 f9 01             	cmp    $0x1,%ecx
  801e4e:	7f 1e                	jg     801e6e <vprintfmt+0x2e9>
	else if (lflag)
  801e50:	85 c9                	test   %ecx,%ecx
  801e52:	74 32                	je     801e86 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  801e54:	8b 45 14             	mov    0x14(%ebp),%eax
  801e57:	8b 10                	mov    (%eax),%edx
  801e59:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e5e:	8d 40 04             	lea    0x4(%eax),%eax
  801e61:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801e64:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  801e69:	e9 a3 00 00 00       	jmp    801f11 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801e6e:	8b 45 14             	mov    0x14(%ebp),%eax
  801e71:	8b 10                	mov    (%eax),%edx
  801e73:	8b 48 04             	mov    0x4(%eax),%ecx
  801e76:	8d 40 08             	lea    0x8(%eax),%eax
  801e79:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801e7c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  801e81:	e9 8b 00 00 00       	jmp    801f11 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801e86:	8b 45 14             	mov    0x14(%ebp),%eax
  801e89:	8b 10                	mov    (%eax),%edx
  801e8b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e90:	8d 40 04             	lea    0x4(%eax),%eax
  801e93:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801e96:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  801e9b:	eb 74                	jmp    801f11 <vprintfmt+0x38c>
	if (lflag >= 2)
  801e9d:	83 f9 01             	cmp    $0x1,%ecx
  801ea0:	7f 1b                	jg     801ebd <vprintfmt+0x338>
	else if (lflag)
  801ea2:	85 c9                	test   %ecx,%ecx
  801ea4:	74 2c                	je     801ed2 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  801ea6:	8b 45 14             	mov    0x14(%ebp),%eax
  801ea9:	8b 10                	mov    (%eax),%edx
  801eab:	b9 00 00 00 00       	mov    $0x0,%ecx
  801eb0:	8d 40 04             	lea    0x4(%eax),%eax
  801eb3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801eb6:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  801ebb:	eb 54                	jmp    801f11 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801ebd:	8b 45 14             	mov    0x14(%ebp),%eax
  801ec0:	8b 10                	mov    (%eax),%edx
  801ec2:	8b 48 04             	mov    0x4(%eax),%ecx
  801ec5:	8d 40 08             	lea    0x8(%eax),%eax
  801ec8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801ecb:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  801ed0:	eb 3f                	jmp    801f11 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801ed2:	8b 45 14             	mov    0x14(%ebp),%eax
  801ed5:	8b 10                	mov    (%eax),%edx
  801ed7:	b9 00 00 00 00       	mov    $0x0,%ecx
  801edc:	8d 40 04             	lea    0x4(%eax),%eax
  801edf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801ee2:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  801ee7:	eb 28                	jmp    801f11 <vprintfmt+0x38c>
			putch('0', putdat);
  801ee9:	83 ec 08             	sub    $0x8,%esp
  801eec:	53                   	push   %ebx
  801eed:	6a 30                	push   $0x30
  801eef:	ff d6                	call   *%esi
			putch('x', putdat);
  801ef1:	83 c4 08             	add    $0x8,%esp
  801ef4:	53                   	push   %ebx
  801ef5:	6a 78                	push   $0x78
  801ef7:	ff d6                	call   *%esi
			num = (unsigned long long)
  801ef9:	8b 45 14             	mov    0x14(%ebp),%eax
  801efc:	8b 10                	mov    (%eax),%edx
  801efe:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801f03:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801f06:	8d 40 04             	lea    0x4(%eax),%eax
  801f09:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801f0c:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  801f11:	83 ec 0c             	sub    $0xc,%esp
  801f14:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801f18:	57                   	push   %edi
  801f19:	ff 75 e0             	pushl  -0x20(%ebp)
  801f1c:	50                   	push   %eax
  801f1d:	51                   	push   %ecx
  801f1e:	52                   	push   %edx
  801f1f:	89 da                	mov    %ebx,%edx
  801f21:	89 f0                	mov    %esi,%eax
  801f23:	e8 72 fb ff ff       	call   801a9a <printnum>
			break;
  801f28:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  801f2b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  801f2e:	83 c7 01             	add    $0x1,%edi
  801f31:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801f35:	83 f8 25             	cmp    $0x25,%eax
  801f38:	0f 84 62 fc ff ff    	je     801ba0 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  801f3e:	85 c0                	test   %eax,%eax
  801f40:	0f 84 8b 00 00 00    	je     801fd1 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  801f46:	83 ec 08             	sub    $0x8,%esp
  801f49:	53                   	push   %ebx
  801f4a:	50                   	push   %eax
  801f4b:	ff d6                	call   *%esi
  801f4d:	83 c4 10             	add    $0x10,%esp
  801f50:	eb dc                	jmp    801f2e <vprintfmt+0x3a9>
	if (lflag >= 2)
  801f52:	83 f9 01             	cmp    $0x1,%ecx
  801f55:	7f 1b                	jg     801f72 <vprintfmt+0x3ed>
	else if (lflag)
  801f57:	85 c9                	test   %ecx,%ecx
  801f59:	74 2c                	je     801f87 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  801f5b:	8b 45 14             	mov    0x14(%ebp),%eax
  801f5e:	8b 10                	mov    (%eax),%edx
  801f60:	b9 00 00 00 00       	mov    $0x0,%ecx
  801f65:	8d 40 04             	lea    0x4(%eax),%eax
  801f68:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801f6b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  801f70:	eb 9f                	jmp    801f11 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801f72:	8b 45 14             	mov    0x14(%ebp),%eax
  801f75:	8b 10                	mov    (%eax),%edx
  801f77:	8b 48 04             	mov    0x4(%eax),%ecx
  801f7a:	8d 40 08             	lea    0x8(%eax),%eax
  801f7d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801f80:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  801f85:	eb 8a                	jmp    801f11 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801f87:	8b 45 14             	mov    0x14(%ebp),%eax
  801f8a:	8b 10                	mov    (%eax),%edx
  801f8c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801f91:	8d 40 04             	lea    0x4(%eax),%eax
  801f94:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801f97:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  801f9c:	e9 70 ff ff ff       	jmp    801f11 <vprintfmt+0x38c>
			putch(ch, putdat);
  801fa1:	83 ec 08             	sub    $0x8,%esp
  801fa4:	53                   	push   %ebx
  801fa5:	6a 25                	push   $0x25
  801fa7:	ff d6                	call   *%esi
			break;
  801fa9:	83 c4 10             	add    $0x10,%esp
  801fac:	e9 7a ff ff ff       	jmp    801f2b <vprintfmt+0x3a6>
			putch('%', putdat);
  801fb1:	83 ec 08             	sub    $0x8,%esp
  801fb4:	53                   	push   %ebx
  801fb5:	6a 25                	push   $0x25
  801fb7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  801fb9:	83 c4 10             	add    $0x10,%esp
  801fbc:	89 f8                	mov    %edi,%eax
  801fbe:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801fc2:	74 05                	je     801fc9 <vprintfmt+0x444>
  801fc4:	83 e8 01             	sub    $0x1,%eax
  801fc7:	eb f5                	jmp    801fbe <vprintfmt+0x439>
  801fc9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801fcc:	e9 5a ff ff ff       	jmp    801f2b <vprintfmt+0x3a6>
}
  801fd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd4:	5b                   	pop    %ebx
  801fd5:	5e                   	pop    %esi
  801fd6:	5f                   	pop    %edi
  801fd7:	5d                   	pop    %ebp
  801fd8:	c3                   	ret    

00801fd9 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801fd9:	f3 0f 1e fb          	endbr32 
  801fdd:	55                   	push   %ebp
  801fde:	89 e5                	mov    %esp,%ebp
  801fe0:	83 ec 18             	sub    $0x18,%esp
  801fe3:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801fe9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801fec:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ff0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ff3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ffa:	85 c0                	test   %eax,%eax
  801ffc:	74 26                	je     802024 <vsnprintf+0x4b>
  801ffe:	85 d2                	test   %edx,%edx
  802000:	7e 22                	jle    802024 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  802002:	ff 75 14             	pushl  0x14(%ebp)
  802005:	ff 75 10             	pushl  0x10(%ebp)
  802008:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80200b:	50                   	push   %eax
  80200c:	68 43 1b 80 00       	push   $0x801b43
  802011:	e8 6f fb ff ff       	call   801b85 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  802016:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802019:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80201c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201f:	83 c4 10             	add    $0x10,%esp
}
  802022:	c9                   	leave  
  802023:	c3                   	ret    
		return -E_INVAL;
  802024:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802029:	eb f7                	jmp    802022 <vsnprintf+0x49>

0080202b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80202b:	f3 0f 1e fb          	endbr32 
  80202f:	55                   	push   %ebp
  802030:	89 e5                	mov    %esp,%ebp
  802032:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  802035:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  802038:	50                   	push   %eax
  802039:	ff 75 10             	pushl  0x10(%ebp)
  80203c:	ff 75 0c             	pushl  0xc(%ebp)
  80203f:	ff 75 08             	pushl  0x8(%ebp)
  802042:	e8 92 ff ff ff       	call   801fd9 <vsnprintf>
	va_end(ap);

	return rc;
}
  802047:	c9                   	leave  
  802048:	c3                   	ret    

00802049 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802049:	f3 0f 1e fb          	endbr32 
  80204d:	55                   	push   %ebp
  80204e:	89 e5                	mov    %esp,%ebp
  802050:	56                   	push   %esi
  802051:	53                   	push   %ebx
  802052:	8b 75 08             	mov    0x8(%ebp),%esi
  802055:	8b 45 0c             	mov    0xc(%ebp),%eax
  802058:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  80205b:	85 c0                	test   %eax,%eax
  80205d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802062:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  802065:	83 ec 0c             	sub    $0xc,%esp
  802068:	50                   	push   %eax
  802069:	e8 94 e6 ff ff       	call   800702 <sys_ipc_recv>
  80206e:	83 c4 10             	add    $0x10,%esp
  802071:	85 c0                	test   %eax,%eax
  802073:	75 2b                	jne    8020a0 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  802075:	85 f6                	test   %esi,%esi
  802077:	74 0a                	je     802083 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  802079:	a1 08 40 80 00       	mov    0x804008,%eax
  80207e:	8b 40 74             	mov    0x74(%eax),%eax
  802081:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  802083:	85 db                	test   %ebx,%ebx
  802085:	74 0a                	je     802091 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  802087:	a1 08 40 80 00       	mov    0x804008,%eax
  80208c:	8b 40 78             	mov    0x78(%eax),%eax
  80208f:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  802091:	a1 08 40 80 00       	mov    0x804008,%eax
  802096:	8b 40 70             	mov    0x70(%eax),%eax
}
  802099:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80209c:	5b                   	pop    %ebx
  80209d:	5e                   	pop    %esi
  80209e:	5d                   	pop    %ebp
  80209f:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  8020a0:	85 f6                	test   %esi,%esi
  8020a2:	74 06                	je     8020aa <ipc_recv+0x61>
  8020a4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8020aa:	85 db                	test   %ebx,%ebx
  8020ac:	74 eb                	je     802099 <ipc_recv+0x50>
  8020ae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8020b4:	eb e3                	jmp    802099 <ipc_recv+0x50>

008020b6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020b6:	f3 0f 1e fb          	endbr32 
  8020ba:	55                   	push   %ebp
  8020bb:	89 e5                	mov    %esp,%ebp
  8020bd:	57                   	push   %edi
  8020be:	56                   	push   %esi
  8020bf:	53                   	push   %ebx
  8020c0:	83 ec 0c             	sub    $0xc,%esp
  8020c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020c6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  8020cc:	85 db                	test   %ebx,%ebx
  8020ce:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020d3:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8020d6:	ff 75 14             	pushl  0x14(%ebp)
  8020d9:	53                   	push   %ebx
  8020da:	56                   	push   %esi
  8020db:	57                   	push   %edi
  8020dc:	e8 fa e5 ff ff       	call   8006db <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  8020e1:	83 c4 10             	add    $0x10,%esp
  8020e4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020e7:	75 07                	jne    8020f0 <ipc_send+0x3a>
			sys_yield();
  8020e9:	e8 eb e4 ff ff       	call   8005d9 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8020ee:	eb e6                	jmp    8020d6 <ipc_send+0x20>
		}
		else if (ret == 0)
  8020f0:	85 c0                	test   %eax,%eax
  8020f2:	75 08                	jne    8020fc <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  8020f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020f7:	5b                   	pop    %ebx
  8020f8:	5e                   	pop    %esi
  8020f9:	5f                   	pop    %edi
  8020fa:	5d                   	pop    %ebp
  8020fb:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  8020fc:	50                   	push   %eax
  8020fd:	68 bf 28 80 00       	push   $0x8028bf
  802102:	6a 48                	push   $0x48
  802104:	68 cd 28 80 00       	push   $0x8028cd
  802109:	e8 8d f8 ff ff       	call   80199b <_panic>

0080210e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80210e:	f3 0f 1e fb          	endbr32 
  802112:	55                   	push   %ebp
  802113:	89 e5                	mov    %esp,%ebp
  802115:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802118:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80211d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802120:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802126:	8b 52 50             	mov    0x50(%edx),%edx
  802129:	39 ca                	cmp    %ecx,%edx
  80212b:	74 11                	je     80213e <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  80212d:	83 c0 01             	add    $0x1,%eax
  802130:	3d 00 04 00 00       	cmp    $0x400,%eax
  802135:	75 e6                	jne    80211d <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802137:	b8 00 00 00 00       	mov    $0x0,%eax
  80213c:	eb 0b                	jmp    802149 <ipc_find_env+0x3b>
			return envs[i].env_id;
  80213e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802141:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802146:	8b 40 48             	mov    0x48(%eax),%eax
}
  802149:	5d                   	pop    %ebp
  80214a:	c3                   	ret    

0080214b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80214b:	f3 0f 1e fb          	endbr32 
  80214f:	55                   	push   %ebp
  802150:	89 e5                	mov    %esp,%ebp
  802152:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802155:	89 c2                	mov    %eax,%edx
  802157:	c1 ea 16             	shr    $0x16,%edx
  80215a:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802161:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802166:	f6 c1 01             	test   $0x1,%cl
  802169:	74 1c                	je     802187 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  80216b:	c1 e8 0c             	shr    $0xc,%eax
  80216e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802175:	a8 01                	test   $0x1,%al
  802177:	74 0e                	je     802187 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802179:	c1 e8 0c             	shr    $0xc,%eax
  80217c:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802183:	ef 
  802184:	0f b7 d2             	movzwl %dx,%edx
}
  802187:	89 d0                	mov    %edx,%eax
  802189:	5d                   	pop    %ebp
  80218a:	c3                   	ret    
  80218b:	66 90                	xchg   %ax,%ax
  80218d:	66 90                	xchg   %ax,%ax
  80218f:	90                   	nop

00802190 <__udivdi3>:
  802190:	f3 0f 1e fb          	endbr32 
  802194:	55                   	push   %ebp
  802195:	57                   	push   %edi
  802196:	56                   	push   %esi
  802197:	53                   	push   %ebx
  802198:	83 ec 1c             	sub    $0x1c,%esp
  80219b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80219f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8021a3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021a7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8021ab:	85 d2                	test   %edx,%edx
  8021ad:	75 19                	jne    8021c8 <__udivdi3+0x38>
  8021af:	39 f3                	cmp    %esi,%ebx
  8021b1:	76 4d                	jbe    802200 <__udivdi3+0x70>
  8021b3:	31 ff                	xor    %edi,%edi
  8021b5:	89 e8                	mov    %ebp,%eax
  8021b7:	89 f2                	mov    %esi,%edx
  8021b9:	f7 f3                	div    %ebx
  8021bb:	89 fa                	mov    %edi,%edx
  8021bd:	83 c4 1c             	add    $0x1c,%esp
  8021c0:	5b                   	pop    %ebx
  8021c1:	5e                   	pop    %esi
  8021c2:	5f                   	pop    %edi
  8021c3:	5d                   	pop    %ebp
  8021c4:	c3                   	ret    
  8021c5:	8d 76 00             	lea    0x0(%esi),%esi
  8021c8:	39 f2                	cmp    %esi,%edx
  8021ca:	76 14                	jbe    8021e0 <__udivdi3+0x50>
  8021cc:	31 ff                	xor    %edi,%edi
  8021ce:	31 c0                	xor    %eax,%eax
  8021d0:	89 fa                	mov    %edi,%edx
  8021d2:	83 c4 1c             	add    $0x1c,%esp
  8021d5:	5b                   	pop    %ebx
  8021d6:	5e                   	pop    %esi
  8021d7:	5f                   	pop    %edi
  8021d8:	5d                   	pop    %ebp
  8021d9:	c3                   	ret    
  8021da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e0:	0f bd fa             	bsr    %edx,%edi
  8021e3:	83 f7 1f             	xor    $0x1f,%edi
  8021e6:	75 48                	jne    802230 <__udivdi3+0xa0>
  8021e8:	39 f2                	cmp    %esi,%edx
  8021ea:	72 06                	jb     8021f2 <__udivdi3+0x62>
  8021ec:	31 c0                	xor    %eax,%eax
  8021ee:	39 eb                	cmp    %ebp,%ebx
  8021f0:	77 de                	ja     8021d0 <__udivdi3+0x40>
  8021f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8021f7:	eb d7                	jmp    8021d0 <__udivdi3+0x40>
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	89 d9                	mov    %ebx,%ecx
  802202:	85 db                	test   %ebx,%ebx
  802204:	75 0b                	jne    802211 <__udivdi3+0x81>
  802206:	b8 01 00 00 00       	mov    $0x1,%eax
  80220b:	31 d2                	xor    %edx,%edx
  80220d:	f7 f3                	div    %ebx
  80220f:	89 c1                	mov    %eax,%ecx
  802211:	31 d2                	xor    %edx,%edx
  802213:	89 f0                	mov    %esi,%eax
  802215:	f7 f1                	div    %ecx
  802217:	89 c6                	mov    %eax,%esi
  802219:	89 e8                	mov    %ebp,%eax
  80221b:	89 f7                	mov    %esi,%edi
  80221d:	f7 f1                	div    %ecx
  80221f:	89 fa                	mov    %edi,%edx
  802221:	83 c4 1c             	add    $0x1c,%esp
  802224:	5b                   	pop    %ebx
  802225:	5e                   	pop    %esi
  802226:	5f                   	pop    %edi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	89 f9                	mov    %edi,%ecx
  802232:	b8 20 00 00 00       	mov    $0x20,%eax
  802237:	29 f8                	sub    %edi,%eax
  802239:	d3 e2                	shl    %cl,%edx
  80223b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80223f:	89 c1                	mov    %eax,%ecx
  802241:	89 da                	mov    %ebx,%edx
  802243:	d3 ea                	shr    %cl,%edx
  802245:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802249:	09 d1                	or     %edx,%ecx
  80224b:	89 f2                	mov    %esi,%edx
  80224d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802251:	89 f9                	mov    %edi,%ecx
  802253:	d3 e3                	shl    %cl,%ebx
  802255:	89 c1                	mov    %eax,%ecx
  802257:	d3 ea                	shr    %cl,%edx
  802259:	89 f9                	mov    %edi,%ecx
  80225b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80225f:	89 eb                	mov    %ebp,%ebx
  802261:	d3 e6                	shl    %cl,%esi
  802263:	89 c1                	mov    %eax,%ecx
  802265:	d3 eb                	shr    %cl,%ebx
  802267:	09 de                	or     %ebx,%esi
  802269:	89 f0                	mov    %esi,%eax
  80226b:	f7 74 24 08          	divl   0x8(%esp)
  80226f:	89 d6                	mov    %edx,%esi
  802271:	89 c3                	mov    %eax,%ebx
  802273:	f7 64 24 0c          	mull   0xc(%esp)
  802277:	39 d6                	cmp    %edx,%esi
  802279:	72 15                	jb     802290 <__udivdi3+0x100>
  80227b:	89 f9                	mov    %edi,%ecx
  80227d:	d3 e5                	shl    %cl,%ebp
  80227f:	39 c5                	cmp    %eax,%ebp
  802281:	73 04                	jae    802287 <__udivdi3+0xf7>
  802283:	39 d6                	cmp    %edx,%esi
  802285:	74 09                	je     802290 <__udivdi3+0x100>
  802287:	89 d8                	mov    %ebx,%eax
  802289:	31 ff                	xor    %edi,%edi
  80228b:	e9 40 ff ff ff       	jmp    8021d0 <__udivdi3+0x40>
  802290:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802293:	31 ff                	xor    %edi,%edi
  802295:	e9 36 ff ff ff       	jmp    8021d0 <__udivdi3+0x40>
  80229a:	66 90                	xchg   %ax,%ax
  80229c:	66 90                	xchg   %ax,%ax
  80229e:	66 90                	xchg   %ax,%ax

008022a0 <__umoddi3>:
  8022a0:	f3 0f 1e fb          	endbr32 
  8022a4:	55                   	push   %ebp
  8022a5:	57                   	push   %edi
  8022a6:	56                   	push   %esi
  8022a7:	53                   	push   %ebx
  8022a8:	83 ec 1c             	sub    $0x1c,%esp
  8022ab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8022af:	8b 74 24 30          	mov    0x30(%esp),%esi
  8022b3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8022b7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022bb:	85 c0                	test   %eax,%eax
  8022bd:	75 19                	jne    8022d8 <__umoddi3+0x38>
  8022bf:	39 df                	cmp    %ebx,%edi
  8022c1:	76 5d                	jbe    802320 <__umoddi3+0x80>
  8022c3:	89 f0                	mov    %esi,%eax
  8022c5:	89 da                	mov    %ebx,%edx
  8022c7:	f7 f7                	div    %edi
  8022c9:	89 d0                	mov    %edx,%eax
  8022cb:	31 d2                	xor    %edx,%edx
  8022cd:	83 c4 1c             	add    $0x1c,%esp
  8022d0:	5b                   	pop    %ebx
  8022d1:	5e                   	pop    %esi
  8022d2:	5f                   	pop    %edi
  8022d3:	5d                   	pop    %ebp
  8022d4:	c3                   	ret    
  8022d5:	8d 76 00             	lea    0x0(%esi),%esi
  8022d8:	89 f2                	mov    %esi,%edx
  8022da:	39 d8                	cmp    %ebx,%eax
  8022dc:	76 12                	jbe    8022f0 <__umoddi3+0x50>
  8022de:	89 f0                	mov    %esi,%eax
  8022e0:	89 da                	mov    %ebx,%edx
  8022e2:	83 c4 1c             	add    $0x1c,%esp
  8022e5:	5b                   	pop    %ebx
  8022e6:	5e                   	pop    %esi
  8022e7:	5f                   	pop    %edi
  8022e8:	5d                   	pop    %ebp
  8022e9:	c3                   	ret    
  8022ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f0:	0f bd e8             	bsr    %eax,%ebp
  8022f3:	83 f5 1f             	xor    $0x1f,%ebp
  8022f6:	75 50                	jne    802348 <__umoddi3+0xa8>
  8022f8:	39 d8                	cmp    %ebx,%eax
  8022fa:	0f 82 e0 00 00 00    	jb     8023e0 <__umoddi3+0x140>
  802300:	89 d9                	mov    %ebx,%ecx
  802302:	39 f7                	cmp    %esi,%edi
  802304:	0f 86 d6 00 00 00    	jbe    8023e0 <__umoddi3+0x140>
  80230a:	89 d0                	mov    %edx,%eax
  80230c:	89 ca                	mov    %ecx,%edx
  80230e:	83 c4 1c             	add    $0x1c,%esp
  802311:	5b                   	pop    %ebx
  802312:	5e                   	pop    %esi
  802313:	5f                   	pop    %edi
  802314:	5d                   	pop    %ebp
  802315:	c3                   	ret    
  802316:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80231d:	8d 76 00             	lea    0x0(%esi),%esi
  802320:	89 fd                	mov    %edi,%ebp
  802322:	85 ff                	test   %edi,%edi
  802324:	75 0b                	jne    802331 <__umoddi3+0x91>
  802326:	b8 01 00 00 00       	mov    $0x1,%eax
  80232b:	31 d2                	xor    %edx,%edx
  80232d:	f7 f7                	div    %edi
  80232f:	89 c5                	mov    %eax,%ebp
  802331:	89 d8                	mov    %ebx,%eax
  802333:	31 d2                	xor    %edx,%edx
  802335:	f7 f5                	div    %ebp
  802337:	89 f0                	mov    %esi,%eax
  802339:	f7 f5                	div    %ebp
  80233b:	89 d0                	mov    %edx,%eax
  80233d:	31 d2                	xor    %edx,%edx
  80233f:	eb 8c                	jmp    8022cd <__umoddi3+0x2d>
  802341:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802348:	89 e9                	mov    %ebp,%ecx
  80234a:	ba 20 00 00 00       	mov    $0x20,%edx
  80234f:	29 ea                	sub    %ebp,%edx
  802351:	d3 e0                	shl    %cl,%eax
  802353:	89 44 24 08          	mov    %eax,0x8(%esp)
  802357:	89 d1                	mov    %edx,%ecx
  802359:	89 f8                	mov    %edi,%eax
  80235b:	d3 e8                	shr    %cl,%eax
  80235d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802361:	89 54 24 04          	mov    %edx,0x4(%esp)
  802365:	8b 54 24 04          	mov    0x4(%esp),%edx
  802369:	09 c1                	or     %eax,%ecx
  80236b:	89 d8                	mov    %ebx,%eax
  80236d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802371:	89 e9                	mov    %ebp,%ecx
  802373:	d3 e7                	shl    %cl,%edi
  802375:	89 d1                	mov    %edx,%ecx
  802377:	d3 e8                	shr    %cl,%eax
  802379:	89 e9                	mov    %ebp,%ecx
  80237b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80237f:	d3 e3                	shl    %cl,%ebx
  802381:	89 c7                	mov    %eax,%edi
  802383:	89 d1                	mov    %edx,%ecx
  802385:	89 f0                	mov    %esi,%eax
  802387:	d3 e8                	shr    %cl,%eax
  802389:	89 e9                	mov    %ebp,%ecx
  80238b:	89 fa                	mov    %edi,%edx
  80238d:	d3 e6                	shl    %cl,%esi
  80238f:	09 d8                	or     %ebx,%eax
  802391:	f7 74 24 08          	divl   0x8(%esp)
  802395:	89 d1                	mov    %edx,%ecx
  802397:	89 f3                	mov    %esi,%ebx
  802399:	f7 64 24 0c          	mull   0xc(%esp)
  80239d:	89 c6                	mov    %eax,%esi
  80239f:	89 d7                	mov    %edx,%edi
  8023a1:	39 d1                	cmp    %edx,%ecx
  8023a3:	72 06                	jb     8023ab <__umoddi3+0x10b>
  8023a5:	75 10                	jne    8023b7 <__umoddi3+0x117>
  8023a7:	39 c3                	cmp    %eax,%ebx
  8023a9:	73 0c                	jae    8023b7 <__umoddi3+0x117>
  8023ab:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8023af:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8023b3:	89 d7                	mov    %edx,%edi
  8023b5:	89 c6                	mov    %eax,%esi
  8023b7:	89 ca                	mov    %ecx,%edx
  8023b9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023be:	29 f3                	sub    %esi,%ebx
  8023c0:	19 fa                	sbb    %edi,%edx
  8023c2:	89 d0                	mov    %edx,%eax
  8023c4:	d3 e0                	shl    %cl,%eax
  8023c6:	89 e9                	mov    %ebp,%ecx
  8023c8:	d3 eb                	shr    %cl,%ebx
  8023ca:	d3 ea                	shr    %cl,%edx
  8023cc:	09 d8                	or     %ebx,%eax
  8023ce:	83 c4 1c             	add    $0x1c,%esp
  8023d1:	5b                   	pop    %ebx
  8023d2:	5e                   	pop    %esi
  8023d3:	5f                   	pop    %edi
  8023d4:	5d                   	pop    %ebp
  8023d5:	c3                   	ret    
  8023d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023dd:	8d 76 00             	lea    0x0(%esi),%esi
  8023e0:	29 fe                	sub    %edi,%esi
  8023e2:	19 c3                	sbb    %eax,%ebx
  8023e4:	89 f2                	mov    %esi,%edx
  8023e6:	89 d9                	mov    %ebx,%ecx
  8023e8:	e9 1d ff ff ff       	jmp    80230a <__umoddi3+0x6a>
