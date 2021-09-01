
obj/user/echotest.debug:     file format elf32-i386


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
  80002c:	e8 b2 04 00 00       	call   8004e3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:

const char *msg = "Hello world!\n";

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n", m);
  800039:	50                   	push   %eax
  80003a:	68 00 28 80 00       	push   $0x802800
  80003f:	e8 a4 05 00 00       	call   8005e8 <cprintf>
	exit();
  800044:	e8 e4 04 00 00       	call   80052d <exit>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <umain>:

void umain(int argc, char **argv)
{
  80004e:	f3 0f 1e fb          	endbr32 
  800052:	55                   	push   %ebp
  800053:	89 e5                	mov    %esp,%ebp
  800055:	57                   	push   %edi
  800056:	56                   	push   %esi
  800057:	53                   	push   %ebx
  800058:	83 ec 58             	sub    $0x58,%esp
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	cprintf("Connecting to:\n");
  80005b:	68 04 28 80 00       	push   $0x802804
  800060:	e8 83 05 00 00       	call   8005e8 <cprintf>
	cprintf("\tip address %s = %x\n", IPADDR, inet_addr(IPADDR));
  800065:	c7 04 24 14 28 80 00 	movl   $0x802814,(%esp)
  80006c:	e8 35 04 00 00       	call   8004a6 <inet_addr>
  800071:	83 c4 0c             	add    $0xc,%esp
  800074:	50                   	push   %eax
  800075:	68 14 28 80 00       	push   $0x802814
  80007a:	68 1e 28 80 00       	push   $0x80281e
  80007f:	e8 64 05 00 00       	call   8005e8 <cprintf>

	// Create the TCP socket
	if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  800084:	83 c4 0c             	add    $0xc,%esp
  800087:	6a 06                	push   $0x6
  800089:	6a 01                	push   $0x1
  80008b:	6a 02                	push   $0x2
  80008d:	e8 c2 1b 00 00       	call   801c54 <socket>
  800092:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	85 c0                	test   %eax,%eax
  80009a:	0f 88 b4 00 00 00    	js     800154 <umain+0x106>
		die("Failed to create socket");

	cprintf("opened socket\n");
  8000a0:	83 ec 0c             	sub    $0xc,%esp
  8000a3:	68 4b 28 80 00       	push   $0x80284b
  8000a8:	e8 3b 05 00 00       	call   8005e8 <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  8000ad:	83 c4 0c             	add    $0xc,%esp
  8000b0:	6a 10                	push   $0x10
  8000b2:	6a 00                	push   $0x0
  8000b4:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8000b7:	53                   	push   %ebx
  8000b8:	e8 e7 0c 00 00       	call   800da4 <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  8000bd:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = inet_addr(IPADDR);   // IP address
  8000c1:	c7 04 24 14 28 80 00 	movl   $0x802814,(%esp)
  8000c8:	e8 d9 03 00 00       	call   8004a6 <inet_addr>
  8000cd:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  8000d0:	c7 04 24 10 27 00 00 	movl   $0x2710,(%esp)
  8000d7:	e8 a1 01 00 00       	call   80027d <htons>
  8000dc:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to connect to server\n");
  8000e0:	c7 04 24 5a 28 80 00 	movl   $0x80285a,(%esp)
  8000e7:	e8 fc 04 00 00       	call   8005e8 <cprintf>

	// Establish connection
	if (connect(sock, (struct sockaddr *) &echoserver, sizeof(echoserver)) < 0)
  8000ec:	83 c4 0c             	add    $0xc,%esp
  8000ef:	6a 10                	push   $0x10
  8000f1:	53                   	push   %ebx
  8000f2:	ff 75 b4             	pushl  -0x4c(%ebp)
  8000f5:	e8 09 1b 00 00       	call   801c03 <connect>
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	78 62                	js     800163 <umain+0x115>
		die("Failed to connect with server");

	cprintf("connected to server\n");
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	68 95 28 80 00       	push   $0x802895
  800109:	e8 da 04 00 00       	call   8005e8 <cprintf>

	// Send the word to the server
	echolen = strlen(msg);
  80010e:	83 c4 04             	add    $0x4,%esp
  800111:	ff 35 00 30 80 00    	pushl  0x803000
  800117:	e8 93 0a 00 00       	call   800baf <strlen>
  80011c:	89 c7                	mov    %eax,%edi
  80011e:	89 45 b0             	mov    %eax,-0x50(%ebp)
	if (write(sock, msg, echolen) != echolen)
  800121:	83 c4 0c             	add    $0xc,%esp
  800124:	50                   	push   %eax
  800125:	ff 35 00 30 80 00    	pushl  0x803000
  80012b:	ff 75 b4             	pushl  -0x4c(%ebp)
  80012e:	e8 a2 14 00 00       	call   8015d5 <write>
  800133:	83 c4 10             	add    $0x10,%esp
  800136:	39 c7                	cmp    %eax,%edi
  800138:	75 35                	jne    80016f <umain+0x121>
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
  80013a:	83 ec 0c             	sub    $0xc,%esp
  80013d:	68 aa 28 80 00       	push   $0x8028aa
  800142:	e8 a1 04 00 00       	call   8005e8 <cprintf>
	while (received < echolen) {
  800147:	83 c4 10             	add    $0x10,%esp
	int received = 0;
  80014a:	be 00 00 00 00       	mov    $0x0,%esi
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  80014f:	8d 7d b8             	lea    -0x48(%ebp),%edi
	while (received < echolen) {
  800152:	eb 3a                	jmp    80018e <umain+0x140>
		die("Failed to create socket");
  800154:	b8 33 28 80 00       	mov    $0x802833,%eax
  800159:	e8 d5 fe ff ff       	call   800033 <die>
  80015e:	e9 3d ff ff ff       	jmp    8000a0 <umain+0x52>
		die("Failed to connect with server");
  800163:	b8 77 28 80 00       	mov    $0x802877,%eax
  800168:	e8 c6 fe ff ff       	call   800033 <die>
  80016d:	eb 92                	jmp    800101 <umain+0xb3>
		die("Mismatch in number of sent bytes");
  80016f:	b8 c4 28 80 00       	mov    $0x8028c4,%eax
  800174:	e8 ba fe ff ff       	call   800033 <die>
  800179:	eb bf                	jmp    80013a <umain+0xec>
			die("Failed to receive bytes from server");
		}
		received += bytes;
  80017b:	01 de                	add    %ebx,%esi
		buffer[bytes] = '\0';        // Assure null terminated string
  80017d:	c6 44 1d b8 00       	movb   $0x0,-0x48(%ebp,%ebx,1)
		cprintf(buffer);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	57                   	push   %edi
  800186:	e8 5d 04 00 00       	call   8005e8 <cprintf>
  80018b:	83 c4 10             	add    $0x10,%esp
	while (received < echolen) {
  80018e:	3b 75 b0             	cmp    -0x50(%ebp),%esi
  800191:	73 23                	jae    8001b6 <umain+0x168>
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  800193:	83 ec 04             	sub    $0x4,%esp
  800196:	6a 1f                	push   $0x1f
  800198:	57                   	push   %edi
  800199:	ff 75 b4             	pushl  -0x4c(%ebp)
  80019c:	e8 5e 13 00 00       	call   8014ff <read>
  8001a1:	89 c3                	mov    %eax,%ebx
  8001a3:	83 c4 10             	add    $0x10,%esp
  8001a6:	85 c0                	test   %eax,%eax
  8001a8:	7f d1                	jg     80017b <umain+0x12d>
			die("Failed to receive bytes from server");
  8001aa:	b8 e8 28 80 00       	mov    $0x8028e8,%eax
  8001af:	e8 7f fe ff ff       	call   800033 <die>
  8001b4:	eb c5                	jmp    80017b <umain+0x12d>
	}
	cprintf("\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 b4 28 80 00       	push   $0x8028b4
  8001be:	e8 25 04 00 00       	call   8005e8 <cprintf>

	close(sock);
  8001c3:	83 c4 04             	add    $0x4,%esp
  8001c6:	ff 75 b4             	pushl  -0x4c(%ebp)
  8001c9:	e8 e7 11 00 00       	call   8013b5 <close>
}
  8001ce:	83 c4 10             	add    $0x10,%esp
  8001d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d4:	5b                   	pop    %ebx
  8001d5:	5e                   	pop    %esi
  8001d6:	5f                   	pop    %edi
  8001d7:	5d                   	pop    %ebp
  8001d8:	c3                   	ret    

008001d9 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8001d9:	f3 0f 1e fb          	endbr32 
  8001dd:	55                   	push   %ebp
  8001de:	89 e5                	mov    %esp,%ebp
  8001e0:	57                   	push   %edi
  8001e1:	56                   	push   %esi
  8001e2:	53                   	push   %ebx
  8001e3:	83 ec 18             	sub    $0x18,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8001e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  8001ec:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
  ap = (u8_t *)&s_addr;
  8001f0:	8d 75 f0             	lea    -0x10(%ebp),%esi
  rp = str;
  8001f3:	bf 00 40 80 00       	mov    $0x804000,%edi
  8001f8:	eb 2e                	jmp    800228 <inet_ntoa+0x4f>
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
  8001fa:	0f b6 c8             	movzbl %al,%ecx
  8001fd:	0f b6 4c 0d ed       	movzbl -0x13(%ebp,%ecx,1),%ecx
  800202:	88 0a                	mov    %cl,(%edx)
  800204:	83 c2 01             	add    $0x1,%edx
    while(i--)
  800207:	83 e8 01             	sub    $0x1,%eax
  80020a:	3c ff                	cmp    $0xff,%al
  80020c:	75 ec                	jne    8001fa <inet_ntoa+0x21>
  80020e:	0f b6 db             	movzbl %bl,%ebx
  800211:	01 fb                	add    %edi,%ebx
    *rp++ = '.';
  800213:	8d 7b 01             	lea    0x1(%ebx),%edi
  800216:	c6 03 2e             	movb   $0x2e,(%ebx)
  800219:	83 c6 01             	add    $0x1,%esi
  for(n = 0; n < 4; n++) {
  80021c:	80 45 df 01          	addb   $0x1,-0x21(%ebp)
  800220:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
  800224:	3c 04                	cmp    $0x4,%al
  800226:	74 45                	je     80026d <inet_ntoa+0x94>
  rp = str;
  800228:	bb 00 00 00 00       	mov    $0x0,%ebx
      rem = *ap % (u8_t)10;
  80022d:	0f b6 16             	movzbl (%esi),%edx
      *ap /= (u8_t)10;
  800230:	0f b6 ca             	movzbl %dl,%ecx
  800233:	8d 04 89             	lea    (%ecx,%ecx,4),%eax
  800236:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
  800239:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80023c:	66 c1 e8 0b          	shr    $0xb,%ax
  800240:	88 06                	mov    %al,(%esi)
  800242:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  800244:	83 c3 01             	add    $0x1,%ebx
  800247:	0f b6 c9             	movzbl %cl,%ecx
  80024a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
      rem = *ap % (u8_t)10;
  80024d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800250:	01 c0                	add    %eax,%eax
  800252:	89 d1                	mov    %edx,%ecx
  800254:	29 c1                	sub    %eax,%ecx
  800256:	89 c8                	mov    %ecx,%eax
      inv[i++] = '0' + rem;
  800258:	83 c0 30             	add    $0x30,%eax
  80025b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80025e:	88 44 0d ed          	mov    %al,-0x13(%ebp,%ecx,1)
    } while(*ap);
  800262:	80 fa 09             	cmp    $0x9,%dl
  800265:	77 c6                	ja     80022d <inet_ntoa+0x54>
  800267:	89 fa                	mov    %edi,%edx
      inv[i++] = '0' + rem;
  800269:	89 d8                	mov    %ebx,%eax
  80026b:	eb 9a                	jmp    800207 <inet_ntoa+0x2e>
    ap++;
  }
  *--rp = 0;
  80026d:	c6 03 00             	movb   $0x0,(%ebx)
  return str;
}
  800270:	b8 00 40 80 00       	mov    $0x804000,%eax
  800275:	83 c4 18             	add    $0x18,%esp
  800278:	5b                   	pop    %ebx
  800279:	5e                   	pop    %esi
  80027a:	5f                   	pop    %edi
  80027b:	5d                   	pop    %ebp
  80027c:	c3                   	ret    

0080027d <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  80027d:	f3 0f 1e fb          	endbr32 
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800284:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800288:	66 c1 c0 08          	rol    $0x8,%ax
}
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    

0080028e <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  80028e:	f3 0f 1e fb          	endbr32 
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800295:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800299:	66 c1 c0 08          	rol    $0x8,%ax
  return htons(n);
}
  80029d:	5d                   	pop    %ebp
  80029e:	c3                   	ret    

0080029f <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  80029f:	f3 0f 1e fb          	endbr32 
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  8002a9:	89 d0                	mov    %edx,%eax
  8002ab:	c1 e0 18             	shl    $0x18,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
  8002ae:	89 d1                	mov    %edx,%ecx
  8002b0:	c1 e9 18             	shr    $0x18,%ecx
    ((n & 0xff0000UL) >> 8) |
  8002b3:	09 c8                	or     %ecx,%eax
    ((n & 0xff00) << 8) |
  8002b5:	89 d1                	mov    %edx,%ecx
  8002b7:	c1 e1 08             	shl    $0x8,%ecx
  8002ba:	81 e1 00 00 ff 00    	and    $0xff0000,%ecx
    ((n & 0xff0000UL) >> 8) |
  8002c0:	09 c8                	or     %ecx,%eax
  8002c2:	c1 ea 08             	shr    $0x8,%edx
  8002c5:	81 e2 00 ff 00 00    	and    $0xff00,%edx
  8002cb:	09 d0                	or     %edx,%eax
}
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <inet_aton>:
{
  8002cf:	f3 0f 1e fb          	endbr32 
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
  8002d6:	57                   	push   %edi
  8002d7:	56                   	push   %esi
  8002d8:	53                   	push   %ebx
  8002d9:	83 ec 2c             	sub    $0x2c,%esp
  8002dc:	8b 55 08             	mov    0x8(%ebp),%edx
  c = *cp;
  8002df:	0f be 02             	movsbl (%edx),%eax
  u32_t *pp = parts;
  8002e2:	8d 75 d8             	lea    -0x28(%ebp),%esi
  8002e5:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8002e8:	e9 a7 00 00 00       	jmp    800394 <inet_aton+0xc5>
      c = *++cp;
  8002ed:	0f b6 42 01          	movzbl 0x1(%edx),%eax
      if (c == 'x' || c == 'X') {
  8002f1:	89 c1                	mov    %eax,%ecx
  8002f3:	83 e1 df             	and    $0xffffffdf,%ecx
  8002f6:	80 f9 58             	cmp    $0x58,%cl
  8002f9:	74 10                	je     80030b <inet_aton+0x3c>
      c = *++cp;
  8002fb:	83 c2 01             	add    $0x1,%edx
  8002fe:	0f be c0             	movsbl %al,%eax
        base = 8;
  800301:	be 08 00 00 00       	mov    $0x8,%esi
  800306:	e9 a3 00 00 00       	jmp    8003ae <inet_aton+0xdf>
        c = *++cp;
  80030b:	0f be 42 02          	movsbl 0x2(%edx),%eax
  80030f:	8d 52 02             	lea    0x2(%edx),%edx
        base = 16;
  800312:	be 10 00 00 00       	mov    $0x10,%esi
  800317:	e9 92 00 00 00       	jmp    8003ae <inet_aton+0xdf>
      } else if (base == 16 && isxdigit(c)) {
  80031c:	83 fe 10             	cmp    $0x10,%esi
  80031f:	75 4d                	jne    80036e <inet_aton+0x9f>
  800321:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  800324:	88 4d d3             	mov    %cl,-0x2d(%ebp)
  800327:	89 c1                	mov    %eax,%ecx
  800329:	83 e1 df             	and    $0xffffffdf,%ecx
  80032c:	83 e9 41             	sub    $0x41,%ecx
  80032f:	80 f9 05             	cmp    $0x5,%cl
  800332:	77 3a                	ja     80036e <inet_aton+0x9f>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800334:	c1 e3 04             	shl    $0x4,%ebx
  800337:	83 c0 0a             	add    $0xa,%eax
  80033a:	80 7d d3 1a          	cmpb   $0x1a,-0x2d(%ebp)
  80033e:	19 c9                	sbb    %ecx,%ecx
  800340:	83 e1 20             	and    $0x20,%ecx
  800343:	83 c1 41             	add    $0x41,%ecx
  800346:	29 c8                	sub    %ecx,%eax
  800348:	09 c3                	or     %eax,%ebx
        c = *++cp;
  80034a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80034d:	0f be 40 01          	movsbl 0x1(%eax),%eax
  800351:	83 c2 01             	add    $0x1,%edx
  800354:	89 55 d4             	mov    %edx,-0x2c(%ebp)
      if (isdigit(c)) {
  800357:	89 c7                	mov    %eax,%edi
  800359:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80035c:	80 f9 09             	cmp    $0x9,%cl
  80035f:	77 bb                	ja     80031c <inet_aton+0x4d>
        val = (val * base) + (int)(c - '0');
  800361:	0f af de             	imul   %esi,%ebx
  800364:	8d 5c 18 d0          	lea    -0x30(%eax,%ebx,1),%ebx
        c = *++cp;
  800368:	0f be 42 01          	movsbl 0x1(%edx),%eax
  80036c:	eb e3                	jmp    800351 <inet_aton+0x82>
    if (c == '.') {
  80036e:	83 f8 2e             	cmp    $0x2e,%eax
  800371:	75 42                	jne    8003b5 <inet_aton+0xe6>
      if (pp >= parts + 3)
  800373:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800376:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800379:	39 c6                	cmp    %eax,%esi
  80037b:	0f 84 16 01 00 00    	je     800497 <inet_aton+0x1c8>
      *pp++ = val;
  800381:	83 c6 04             	add    $0x4,%esi
  800384:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800387:	89 5e fc             	mov    %ebx,-0x4(%esi)
      c = *++cp;
  80038a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80038d:	8d 50 01             	lea    0x1(%eax),%edx
  800390:	0f be 40 01          	movsbl 0x1(%eax),%eax
    if (!isdigit(c))
  800394:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800397:	80 f9 09             	cmp    $0x9,%cl
  80039a:	0f 87 f0 00 00 00    	ja     800490 <inet_aton+0x1c1>
    base = 10;
  8003a0:	be 0a 00 00 00       	mov    $0xa,%esi
    if (c == '0') {
  8003a5:	83 f8 30             	cmp    $0x30,%eax
  8003a8:	0f 84 3f ff ff ff    	je     8002ed <inet_aton+0x1e>
    base = 10;
  8003ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003b3:	eb 9f                	jmp    800354 <inet_aton+0x85>
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003b5:	85 c0                	test   %eax,%eax
  8003b7:	74 29                	je     8003e2 <inet_aton+0x113>
    return (0);
  8003b9:	ba 00 00 00 00       	mov    $0x0,%edx
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003be:	89 f9                	mov    %edi,%ecx
  8003c0:	80 f9 1f             	cmp    $0x1f,%cl
  8003c3:	0f 86 d3 00 00 00    	jbe    80049c <inet_aton+0x1cd>
  8003c9:	84 c0                	test   %al,%al
  8003cb:	0f 88 cb 00 00 00    	js     80049c <inet_aton+0x1cd>
  8003d1:	83 f8 20             	cmp    $0x20,%eax
  8003d4:	74 0c                	je     8003e2 <inet_aton+0x113>
  8003d6:	83 e8 09             	sub    $0x9,%eax
  8003d9:	83 f8 04             	cmp    $0x4,%eax
  8003dc:	0f 87 ba 00 00 00    	ja     80049c <inet_aton+0x1cd>
  n = pp - parts + 1;
  8003e2:	8d 45 d8             	lea    -0x28(%ebp),%eax
  8003e5:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8003e8:	29 c6                	sub    %eax,%esi
  8003ea:	89 f0                	mov    %esi,%eax
  8003ec:	c1 f8 02             	sar    $0x2,%eax
  8003ef:	8d 50 01             	lea    0x1(%eax),%edx
  switch (n) {
  8003f2:	83 f8 02             	cmp    $0x2,%eax
  8003f5:	74 7a                	je     800471 <inet_aton+0x1a2>
  8003f7:	83 fa 03             	cmp    $0x3,%edx
  8003fa:	7f 49                	jg     800445 <inet_aton+0x176>
  8003fc:	85 d2                	test   %edx,%edx
  8003fe:	0f 84 98 00 00 00    	je     80049c <inet_aton+0x1cd>
  800404:	83 fa 02             	cmp    $0x2,%edx
  800407:	75 19                	jne    800422 <inet_aton+0x153>
      return (0);
  800409:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xffffffUL)
  80040e:	81 fb ff ff ff 00    	cmp    $0xffffff,%ebx
  800414:	0f 87 82 00 00 00    	ja     80049c <inet_aton+0x1cd>
    val |= parts[0] << 24;
  80041a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80041d:	c1 e0 18             	shl    $0x18,%eax
  800420:	09 c3                	or     %eax,%ebx
  return (1);
  800422:	ba 01 00 00 00       	mov    $0x1,%edx
  if (addr)
  800427:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80042b:	74 6f                	je     80049c <inet_aton+0x1cd>
    addr->s_addr = htonl(val);
  80042d:	83 ec 0c             	sub    $0xc,%esp
  800430:	53                   	push   %ebx
  800431:	e8 69 fe ff ff       	call   80029f <htonl>
  800436:	83 c4 10             	add    $0x10,%esp
  800439:	8b 75 0c             	mov    0xc(%ebp),%esi
  80043c:	89 06                	mov    %eax,(%esi)
  return (1);
  80043e:	ba 01 00 00 00       	mov    $0x1,%edx
  800443:	eb 57                	jmp    80049c <inet_aton+0x1cd>
  switch (n) {
  800445:	83 fa 04             	cmp    $0x4,%edx
  800448:	75 d8                	jne    800422 <inet_aton+0x153>
      return (0);
  80044a:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xff)
  80044f:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
  800455:	77 45                	ja     80049c <inet_aton+0x1cd>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  800457:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80045a:	c1 e0 18             	shl    $0x18,%eax
  80045d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800460:	c1 e2 10             	shl    $0x10,%edx
  800463:	09 d0                	or     %edx,%eax
  800465:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800468:	c1 e2 08             	shl    $0x8,%edx
  80046b:	09 d0                	or     %edx,%eax
  80046d:	09 c3                	or     %eax,%ebx
    break;
  80046f:	eb b1                	jmp    800422 <inet_aton+0x153>
      return (0);
  800471:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xffff)
  800476:	81 fb ff ff 00 00    	cmp    $0xffff,%ebx
  80047c:	77 1e                	ja     80049c <inet_aton+0x1cd>
    val |= (parts[0] << 24) | (parts[1] << 16);
  80047e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800481:	c1 e0 18             	shl    $0x18,%eax
  800484:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800487:	c1 e2 10             	shl    $0x10,%edx
  80048a:	09 d0                	or     %edx,%eax
  80048c:	09 c3                	or     %eax,%ebx
    break;
  80048e:	eb 92                	jmp    800422 <inet_aton+0x153>
      return (0);
  800490:	ba 00 00 00 00       	mov    $0x0,%edx
  800495:	eb 05                	jmp    80049c <inet_aton+0x1cd>
        return (0);
  800497:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80049c:	89 d0                	mov    %edx,%eax
  80049e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a1:	5b                   	pop    %ebx
  8004a2:	5e                   	pop    %esi
  8004a3:	5f                   	pop    %edi
  8004a4:	5d                   	pop    %ebp
  8004a5:	c3                   	ret    

008004a6 <inet_addr>:
{
  8004a6:	f3 0f 1e fb          	endbr32 
  8004aa:	55                   	push   %ebp
  8004ab:	89 e5                	mov    %esp,%ebp
  8004ad:	83 ec 20             	sub    $0x20,%esp
  if (inet_aton(cp, &val)) {
  8004b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004b3:	50                   	push   %eax
  8004b4:	ff 75 08             	pushl  0x8(%ebp)
  8004b7:	e8 13 fe ff ff       	call   8002cf <inet_aton>
  8004bc:	83 c4 10             	add    $0x10,%esp
    return (val.s_addr);
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004c6:	0f 45 45 f4          	cmovne -0xc(%ebp),%eax
}
  8004ca:	c9                   	leave  
  8004cb:	c3                   	ret    

008004cc <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  8004cc:	f3 0f 1e fb          	endbr32 
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	83 ec 14             	sub    $0x14,%esp
  return htonl(n);
  8004d6:	ff 75 08             	pushl  0x8(%ebp)
  8004d9:	e8 c1 fd ff ff       	call   80029f <htonl>
  8004de:	83 c4 10             	add    $0x10,%esp
}
  8004e1:	c9                   	leave  
  8004e2:	c3                   	ret    

008004e3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8004e3:	f3 0f 1e fb          	endbr32 
  8004e7:	55                   	push   %ebp
  8004e8:	89 e5                	mov    %esp,%ebp
  8004ea:	56                   	push   %esi
  8004eb:	53                   	push   %ebx
  8004ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004ef:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8004f2:	e8 1e 0b 00 00       	call   801015 <sys_getenvid>
  8004f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004fc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8004ff:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800504:	a3 18 40 80 00       	mov    %eax,0x804018
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800509:	85 db                	test   %ebx,%ebx
  80050b:	7e 07                	jle    800514 <libmain+0x31>
		binaryname = argv[0];
  80050d:	8b 06                	mov    (%esi),%eax
  80050f:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	56                   	push   %esi
  800518:	53                   	push   %ebx
  800519:	e8 30 fb ff ff       	call   80004e <umain>

	// exit gracefully
	exit();
  80051e:	e8 0a 00 00 00       	call   80052d <exit>
}
  800523:	83 c4 10             	add    $0x10,%esp
  800526:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800529:	5b                   	pop    %ebx
  80052a:	5e                   	pop    %esi
  80052b:	5d                   	pop    %ebp
  80052c:	c3                   	ret    

0080052d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80052d:	f3 0f 1e fb          	endbr32 
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  800537:	e8 aa 0e 00 00       	call   8013e6 <close_all>
	sys_env_destroy(0);
  80053c:	83 ec 0c             	sub    $0xc,%esp
  80053f:	6a 00                	push   $0x0
  800541:	e8 ab 0a 00 00       	call   800ff1 <sys_env_destroy>
}
  800546:	83 c4 10             	add    $0x10,%esp
  800549:	c9                   	leave  
  80054a:	c3                   	ret    

0080054b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80054b:	f3 0f 1e fb          	endbr32 
  80054f:	55                   	push   %ebp
  800550:	89 e5                	mov    %esp,%ebp
  800552:	53                   	push   %ebx
  800553:	83 ec 04             	sub    $0x4,%esp
  800556:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800559:	8b 13                	mov    (%ebx),%edx
  80055b:	8d 42 01             	lea    0x1(%edx),%eax
  80055e:	89 03                	mov    %eax,(%ebx)
  800560:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800563:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800567:	3d ff 00 00 00       	cmp    $0xff,%eax
  80056c:	74 09                	je     800577 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80056e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800572:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800575:	c9                   	leave  
  800576:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800577:	83 ec 08             	sub    $0x8,%esp
  80057a:	68 ff 00 00 00       	push   $0xff
  80057f:	8d 43 08             	lea    0x8(%ebx),%eax
  800582:	50                   	push   %eax
  800583:	e8 24 0a 00 00       	call   800fac <sys_cputs>
		b->idx = 0;
  800588:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80058e:	83 c4 10             	add    $0x10,%esp
  800591:	eb db                	jmp    80056e <putch+0x23>

00800593 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800593:	f3 0f 1e fb          	endbr32 
  800597:	55                   	push   %ebp
  800598:	89 e5                	mov    %esp,%ebp
  80059a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8005a0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005a7:	00 00 00 
	b.cnt = 0;
  8005aa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005b1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005b4:	ff 75 0c             	pushl  0xc(%ebp)
  8005b7:	ff 75 08             	pushl  0x8(%ebp)
  8005ba:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005c0:	50                   	push   %eax
  8005c1:	68 4b 05 80 00       	push   $0x80054b
  8005c6:	e8 20 01 00 00       	call   8006eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005cb:	83 c4 08             	add    $0x8,%esp
  8005ce:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005d4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005da:	50                   	push   %eax
  8005db:	e8 cc 09 00 00       	call   800fac <sys_cputs>

	return b.cnt;
}
  8005e0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005e6:	c9                   	leave  
  8005e7:	c3                   	ret    

008005e8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005e8:	f3 0f 1e fb          	endbr32 
  8005ec:	55                   	push   %ebp
  8005ed:	89 e5                	mov    %esp,%ebp
  8005ef:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005f2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005f5:	50                   	push   %eax
  8005f6:	ff 75 08             	pushl  0x8(%ebp)
  8005f9:	e8 95 ff ff ff       	call   800593 <vcprintf>
	va_end(ap);

	return cnt;
}
  8005fe:	c9                   	leave  
  8005ff:	c3                   	ret    

00800600 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800600:	55                   	push   %ebp
  800601:	89 e5                	mov    %esp,%ebp
  800603:	57                   	push   %edi
  800604:	56                   	push   %esi
  800605:	53                   	push   %ebx
  800606:	83 ec 1c             	sub    $0x1c,%esp
  800609:	89 c7                	mov    %eax,%edi
  80060b:	89 d6                	mov    %edx,%esi
  80060d:	8b 45 08             	mov    0x8(%ebp),%eax
  800610:	8b 55 0c             	mov    0xc(%ebp),%edx
  800613:	89 d1                	mov    %edx,%ecx
  800615:	89 c2                	mov    %eax,%edx
  800617:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80061d:	8b 45 10             	mov    0x10(%ebp),%eax
  800620:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800623:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800626:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80062d:	39 c2                	cmp    %eax,%edx
  80062f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800632:	72 3e                	jb     800672 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800634:	83 ec 0c             	sub    $0xc,%esp
  800637:	ff 75 18             	pushl  0x18(%ebp)
  80063a:	83 eb 01             	sub    $0x1,%ebx
  80063d:	53                   	push   %ebx
  80063e:	50                   	push   %eax
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	ff 75 e4             	pushl  -0x1c(%ebp)
  800645:	ff 75 e0             	pushl  -0x20(%ebp)
  800648:	ff 75 dc             	pushl  -0x24(%ebp)
  80064b:	ff 75 d8             	pushl  -0x28(%ebp)
  80064e:	e8 3d 1f 00 00       	call   802590 <__udivdi3>
  800653:	83 c4 18             	add    $0x18,%esp
  800656:	52                   	push   %edx
  800657:	50                   	push   %eax
  800658:	89 f2                	mov    %esi,%edx
  80065a:	89 f8                	mov    %edi,%eax
  80065c:	e8 9f ff ff ff       	call   800600 <printnum>
  800661:	83 c4 20             	add    $0x20,%esp
  800664:	eb 13                	jmp    800679 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800666:	83 ec 08             	sub    $0x8,%esp
  800669:	56                   	push   %esi
  80066a:	ff 75 18             	pushl  0x18(%ebp)
  80066d:	ff d7                	call   *%edi
  80066f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800672:	83 eb 01             	sub    $0x1,%ebx
  800675:	85 db                	test   %ebx,%ebx
  800677:	7f ed                	jg     800666 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800679:	83 ec 08             	sub    $0x8,%esp
  80067c:	56                   	push   %esi
  80067d:	83 ec 04             	sub    $0x4,%esp
  800680:	ff 75 e4             	pushl  -0x1c(%ebp)
  800683:	ff 75 e0             	pushl  -0x20(%ebp)
  800686:	ff 75 dc             	pushl  -0x24(%ebp)
  800689:	ff 75 d8             	pushl  -0x28(%ebp)
  80068c:	e8 0f 20 00 00       	call   8026a0 <__umoddi3>
  800691:	83 c4 14             	add    $0x14,%esp
  800694:	0f be 80 16 29 80 00 	movsbl 0x802916(%eax),%eax
  80069b:	50                   	push   %eax
  80069c:	ff d7                	call   *%edi
}
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006a4:	5b                   	pop    %ebx
  8006a5:	5e                   	pop    %esi
  8006a6:	5f                   	pop    %edi
  8006a7:	5d                   	pop    %ebp
  8006a8:	c3                   	ret    

008006a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006a9:	f3 0f 1e fb          	endbr32 
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
  8006b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006b3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006b7:	8b 10                	mov    (%eax),%edx
  8006b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8006bc:	73 0a                	jae    8006c8 <sprintputch+0x1f>
		*b->buf++ = ch;
  8006be:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006c1:	89 08                	mov    %ecx,(%eax)
  8006c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c6:	88 02                	mov    %al,(%edx)
}
  8006c8:	5d                   	pop    %ebp
  8006c9:	c3                   	ret    

008006ca <printfmt>:
{
  8006ca:	f3 0f 1e fb          	endbr32 
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8006d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006d7:	50                   	push   %eax
  8006d8:	ff 75 10             	pushl  0x10(%ebp)
  8006db:	ff 75 0c             	pushl  0xc(%ebp)
  8006de:	ff 75 08             	pushl  0x8(%ebp)
  8006e1:	e8 05 00 00 00       	call   8006eb <vprintfmt>
}
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	c9                   	leave  
  8006ea:	c3                   	ret    

008006eb <vprintfmt>:
{
  8006eb:	f3 0f 1e fb          	endbr32 
  8006ef:	55                   	push   %ebp
  8006f0:	89 e5                	mov    %esp,%ebp
  8006f2:	57                   	push   %edi
  8006f3:	56                   	push   %esi
  8006f4:	53                   	push   %ebx
  8006f5:	83 ec 3c             	sub    $0x3c,%esp
  8006f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  800701:	e9 8e 03 00 00       	jmp    800a94 <vprintfmt+0x3a9>
		padc = ' ';
  800706:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80070a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800711:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800718:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80071f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800724:	8d 47 01             	lea    0x1(%edi),%eax
  800727:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80072a:	0f b6 17             	movzbl (%edi),%edx
  80072d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800730:	3c 55                	cmp    $0x55,%al
  800732:	0f 87 df 03 00 00    	ja     800b17 <vprintfmt+0x42c>
  800738:	0f b6 c0             	movzbl %al,%eax
  80073b:	3e ff 24 85 60 2a 80 	notrack jmp *0x802a60(,%eax,4)
  800742:	00 
  800743:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800746:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80074a:	eb d8                	jmp    800724 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80074c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80074f:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800753:	eb cf                	jmp    800724 <vprintfmt+0x39>
  800755:	0f b6 d2             	movzbl %dl,%edx
  800758:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80075b:	b8 00 00 00 00       	mov    $0x0,%eax
  800760:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800763:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800766:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80076a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80076d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800770:	83 f9 09             	cmp    $0x9,%ecx
  800773:	77 55                	ja     8007ca <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800775:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800778:	eb e9                	jmp    800763 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8b 00                	mov    (%eax),%eax
  80077f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800782:	8b 45 14             	mov    0x14(%ebp),%eax
  800785:	8d 40 04             	lea    0x4(%eax),%eax
  800788:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80078b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80078e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800792:	79 90                	jns    800724 <vprintfmt+0x39>
				width = precision, precision = -1;
  800794:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800797:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80079a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8007a1:	eb 81                	jmp    800724 <vprintfmt+0x39>
  8007a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ad:	0f 49 d0             	cmovns %eax,%edx
  8007b0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8007b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8007b6:	e9 69 ff ff ff       	jmp    800724 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8007bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8007be:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8007c5:	e9 5a ff ff ff       	jmp    800724 <vprintfmt+0x39>
  8007ca:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8007cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d0:	eb bc                	jmp    80078e <vprintfmt+0xa3>
			lflag++;
  8007d2:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8007d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8007d8:	e9 47 ff ff ff       	jmp    800724 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8d 78 04             	lea    0x4(%eax),%edi
  8007e3:	83 ec 08             	sub    $0x8,%esp
  8007e6:	53                   	push   %ebx
  8007e7:	ff 30                	pushl  (%eax)
  8007e9:	ff d6                	call   *%esi
			break;
  8007eb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8007ee:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8007f1:	e9 9b 02 00 00       	jmp    800a91 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8007f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f9:	8d 78 04             	lea    0x4(%eax),%edi
  8007fc:	8b 00                	mov    (%eax),%eax
  8007fe:	99                   	cltd   
  8007ff:	31 d0                	xor    %edx,%eax
  800801:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800803:	83 f8 0f             	cmp    $0xf,%eax
  800806:	7f 23                	jg     80082b <vprintfmt+0x140>
  800808:	8b 14 85 c0 2b 80 00 	mov    0x802bc0(,%eax,4),%edx
  80080f:	85 d2                	test   %edx,%edx
  800811:	74 18                	je     80082b <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800813:	52                   	push   %edx
  800814:	68 c9 2c 80 00       	push   $0x802cc9
  800819:	53                   	push   %ebx
  80081a:	56                   	push   %esi
  80081b:	e8 aa fe ff ff       	call   8006ca <printfmt>
  800820:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800823:	89 7d 14             	mov    %edi,0x14(%ebp)
  800826:	e9 66 02 00 00       	jmp    800a91 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80082b:	50                   	push   %eax
  80082c:	68 2e 29 80 00       	push   $0x80292e
  800831:	53                   	push   %ebx
  800832:	56                   	push   %esi
  800833:	e8 92 fe ff ff       	call   8006ca <printfmt>
  800838:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80083b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80083e:	e9 4e 02 00 00       	jmp    800a91 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800843:	8b 45 14             	mov    0x14(%ebp),%eax
  800846:	83 c0 04             	add    $0x4,%eax
  800849:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80084c:	8b 45 14             	mov    0x14(%ebp),%eax
  80084f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800851:	85 d2                	test   %edx,%edx
  800853:	b8 27 29 80 00       	mov    $0x802927,%eax
  800858:	0f 45 c2             	cmovne %edx,%eax
  80085b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80085e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800862:	7e 06                	jle    80086a <vprintfmt+0x17f>
  800864:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800868:	75 0d                	jne    800877 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80086a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80086d:	89 c7                	mov    %eax,%edi
  80086f:	03 45 e0             	add    -0x20(%ebp),%eax
  800872:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800875:	eb 55                	jmp    8008cc <vprintfmt+0x1e1>
  800877:	83 ec 08             	sub    $0x8,%esp
  80087a:	ff 75 d8             	pushl  -0x28(%ebp)
  80087d:	ff 75 cc             	pushl  -0x34(%ebp)
  800880:	e8 46 03 00 00       	call   800bcb <strnlen>
  800885:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800888:	29 c2                	sub    %eax,%edx
  80088a:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80088d:	83 c4 10             	add    $0x10,%esp
  800890:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800892:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800896:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800899:	85 ff                	test   %edi,%edi
  80089b:	7e 11                	jle    8008ae <vprintfmt+0x1c3>
					putch(padc, putdat);
  80089d:	83 ec 08             	sub    $0x8,%esp
  8008a0:	53                   	push   %ebx
  8008a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8008a4:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8008a6:	83 ef 01             	sub    $0x1,%edi
  8008a9:	83 c4 10             	add    $0x10,%esp
  8008ac:	eb eb                	jmp    800899 <vprintfmt+0x1ae>
  8008ae:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8008b1:	85 d2                	test   %edx,%edx
  8008b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b8:	0f 49 c2             	cmovns %edx,%eax
  8008bb:	29 c2                	sub    %eax,%edx
  8008bd:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8008c0:	eb a8                	jmp    80086a <vprintfmt+0x17f>
					putch(ch, putdat);
  8008c2:	83 ec 08             	sub    $0x8,%esp
  8008c5:	53                   	push   %ebx
  8008c6:	52                   	push   %edx
  8008c7:	ff d6                	call   *%esi
  8008c9:	83 c4 10             	add    $0x10,%esp
  8008cc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8008cf:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008d1:	83 c7 01             	add    $0x1,%edi
  8008d4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008d8:	0f be d0             	movsbl %al,%edx
  8008db:	85 d2                	test   %edx,%edx
  8008dd:	74 4b                	je     80092a <vprintfmt+0x23f>
  8008df:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008e3:	78 06                	js     8008eb <vprintfmt+0x200>
  8008e5:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8008e9:	78 1e                	js     800909 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  8008eb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8008ef:	74 d1                	je     8008c2 <vprintfmt+0x1d7>
  8008f1:	0f be c0             	movsbl %al,%eax
  8008f4:	83 e8 20             	sub    $0x20,%eax
  8008f7:	83 f8 5e             	cmp    $0x5e,%eax
  8008fa:	76 c6                	jbe    8008c2 <vprintfmt+0x1d7>
					putch('?', putdat);
  8008fc:	83 ec 08             	sub    $0x8,%esp
  8008ff:	53                   	push   %ebx
  800900:	6a 3f                	push   $0x3f
  800902:	ff d6                	call   *%esi
  800904:	83 c4 10             	add    $0x10,%esp
  800907:	eb c3                	jmp    8008cc <vprintfmt+0x1e1>
  800909:	89 cf                	mov    %ecx,%edi
  80090b:	eb 0e                	jmp    80091b <vprintfmt+0x230>
				putch(' ', putdat);
  80090d:	83 ec 08             	sub    $0x8,%esp
  800910:	53                   	push   %ebx
  800911:	6a 20                	push   $0x20
  800913:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800915:	83 ef 01             	sub    $0x1,%edi
  800918:	83 c4 10             	add    $0x10,%esp
  80091b:	85 ff                	test   %edi,%edi
  80091d:	7f ee                	jg     80090d <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80091f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800922:	89 45 14             	mov    %eax,0x14(%ebp)
  800925:	e9 67 01 00 00       	jmp    800a91 <vprintfmt+0x3a6>
  80092a:	89 cf                	mov    %ecx,%edi
  80092c:	eb ed                	jmp    80091b <vprintfmt+0x230>
	if (lflag >= 2)
  80092e:	83 f9 01             	cmp    $0x1,%ecx
  800931:	7f 1b                	jg     80094e <vprintfmt+0x263>
	else if (lflag)
  800933:	85 c9                	test   %ecx,%ecx
  800935:	74 63                	je     80099a <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800937:	8b 45 14             	mov    0x14(%ebp),%eax
  80093a:	8b 00                	mov    (%eax),%eax
  80093c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80093f:	99                   	cltd   
  800940:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800943:	8b 45 14             	mov    0x14(%ebp),%eax
  800946:	8d 40 04             	lea    0x4(%eax),%eax
  800949:	89 45 14             	mov    %eax,0x14(%ebp)
  80094c:	eb 17                	jmp    800965 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80094e:	8b 45 14             	mov    0x14(%ebp),%eax
  800951:	8b 50 04             	mov    0x4(%eax),%edx
  800954:	8b 00                	mov    (%eax),%eax
  800956:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800959:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80095c:	8b 45 14             	mov    0x14(%ebp),%eax
  80095f:	8d 40 08             	lea    0x8(%eax),%eax
  800962:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800965:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800968:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80096b:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800970:	85 c9                	test   %ecx,%ecx
  800972:	0f 89 ff 00 00 00    	jns    800a77 <vprintfmt+0x38c>
				putch('-', putdat);
  800978:	83 ec 08             	sub    $0x8,%esp
  80097b:	53                   	push   %ebx
  80097c:	6a 2d                	push   $0x2d
  80097e:	ff d6                	call   *%esi
				num = -(long long) num;
  800980:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800983:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800986:	f7 da                	neg    %edx
  800988:	83 d1 00             	adc    $0x0,%ecx
  80098b:	f7 d9                	neg    %ecx
  80098d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800990:	b8 0a 00 00 00       	mov    $0xa,%eax
  800995:	e9 dd 00 00 00       	jmp    800a77 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  80099a:	8b 45 14             	mov    0x14(%ebp),%eax
  80099d:	8b 00                	mov    (%eax),%eax
  80099f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009a2:	99                   	cltd   
  8009a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8009a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a9:	8d 40 04             	lea    0x4(%eax),%eax
  8009ac:	89 45 14             	mov    %eax,0x14(%ebp)
  8009af:	eb b4                	jmp    800965 <vprintfmt+0x27a>
	if (lflag >= 2)
  8009b1:	83 f9 01             	cmp    $0x1,%ecx
  8009b4:	7f 1e                	jg     8009d4 <vprintfmt+0x2e9>
	else if (lflag)
  8009b6:	85 c9                	test   %ecx,%ecx
  8009b8:	74 32                	je     8009ec <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8009ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bd:	8b 10                	mov    (%eax),%edx
  8009bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009c4:	8d 40 04             	lea    0x4(%eax),%eax
  8009c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009ca:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8009cf:	e9 a3 00 00 00       	jmp    800a77 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8009d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d7:	8b 10                	mov    (%eax),%edx
  8009d9:	8b 48 04             	mov    0x4(%eax),%ecx
  8009dc:	8d 40 08             	lea    0x8(%eax),%eax
  8009df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009e2:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8009e7:	e9 8b 00 00 00       	jmp    800a77 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8009ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ef:	8b 10                	mov    (%eax),%edx
  8009f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009f6:	8d 40 04             	lea    0x4(%eax),%eax
  8009f9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009fc:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800a01:	eb 74                	jmp    800a77 <vprintfmt+0x38c>
	if (lflag >= 2)
  800a03:	83 f9 01             	cmp    $0x1,%ecx
  800a06:	7f 1b                	jg     800a23 <vprintfmt+0x338>
	else if (lflag)
  800a08:	85 c9                	test   %ecx,%ecx
  800a0a:	74 2c                	je     800a38 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800a0c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0f:	8b 10                	mov    (%eax),%edx
  800a11:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a16:	8d 40 04             	lea    0x4(%eax),%eax
  800a19:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800a1c:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800a21:	eb 54                	jmp    800a77 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800a23:	8b 45 14             	mov    0x14(%ebp),%eax
  800a26:	8b 10                	mov    (%eax),%edx
  800a28:	8b 48 04             	mov    0x4(%eax),%ecx
  800a2b:	8d 40 08             	lea    0x8(%eax),%eax
  800a2e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800a31:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800a36:	eb 3f                	jmp    800a77 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800a38:	8b 45 14             	mov    0x14(%ebp),%eax
  800a3b:	8b 10                	mov    (%eax),%edx
  800a3d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a42:	8d 40 04             	lea    0x4(%eax),%eax
  800a45:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800a48:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800a4d:	eb 28                	jmp    800a77 <vprintfmt+0x38c>
			putch('0', putdat);
  800a4f:	83 ec 08             	sub    $0x8,%esp
  800a52:	53                   	push   %ebx
  800a53:	6a 30                	push   $0x30
  800a55:	ff d6                	call   *%esi
			putch('x', putdat);
  800a57:	83 c4 08             	add    $0x8,%esp
  800a5a:	53                   	push   %ebx
  800a5b:	6a 78                	push   $0x78
  800a5d:	ff d6                	call   *%esi
			num = (unsigned long long)
  800a5f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a62:	8b 10                	mov    (%eax),%edx
  800a64:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800a69:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800a6c:	8d 40 04             	lea    0x4(%eax),%eax
  800a6f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a72:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800a77:	83 ec 0c             	sub    $0xc,%esp
  800a7a:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800a7e:	57                   	push   %edi
  800a7f:	ff 75 e0             	pushl  -0x20(%ebp)
  800a82:	50                   	push   %eax
  800a83:	51                   	push   %ecx
  800a84:	52                   	push   %edx
  800a85:	89 da                	mov    %ebx,%edx
  800a87:	89 f0                	mov    %esi,%eax
  800a89:	e8 72 fb ff ff       	call   800600 <printnum>
			break;
  800a8e:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800a91:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  800a94:	83 c7 01             	add    $0x1,%edi
  800a97:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a9b:	83 f8 25             	cmp    $0x25,%eax
  800a9e:	0f 84 62 fc ff ff    	je     800706 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  800aa4:	85 c0                	test   %eax,%eax
  800aa6:	0f 84 8b 00 00 00    	je     800b37 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  800aac:	83 ec 08             	sub    $0x8,%esp
  800aaf:	53                   	push   %ebx
  800ab0:	50                   	push   %eax
  800ab1:	ff d6                	call   *%esi
  800ab3:	83 c4 10             	add    $0x10,%esp
  800ab6:	eb dc                	jmp    800a94 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800ab8:	83 f9 01             	cmp    $0x1,%ecx
  800abb:	7f 1b                	jg     800ad8 <vprintfmt+0x3ed>
	else if (lflag)
  800abd:	85 c9                	test   %ecx,%ecx
  800abf:	74 2c                	je     800aed <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800ac1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac4:	8b 10                	mov    (%eax),%edx
  800ac6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800acb:	8d 40 04             	lea    0x4(%eax),%eax
  800ace:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800ad1:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800ad6:	eb 9f                	jmp    800a77 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800ad8:	8b 45 14             	mov    0x14(%ebp),%eax
  800adb:	8b 10                	mov    (%eax),%edx
  800add:	8b 48 04             	mov    0x4(%eax),%ecx
  800ae0:	8d 40 08             	lea    0x8(%eax),%eax
  800ae3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800ae6:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800aeb:	eb 8a                	jmp    800a77 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800aed:	8b 45 14             	mov    0x14(%ebp),%eax
  800af0:	8b 10                	mov    (%eax),%edx
  800af2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af7:	8d 40 04             	lea    0x4(%eax),%eax
  800afa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800afd:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800b02:	e9 70 ff ff ff       	jmp    800a77 <vprintfmt+0x38c>
			putch(ch, putdat);
  800b07:	83 ec 08             	sub    $0x8,%esp
  800b0a:	53                   	push   %ebx
  800b0b:	6a 25                	push   $0x25
  800b0d:	ff d6                	call   *%esi
			break;
  800b0f:	83 c4 10             	add    $0x10,%esp
  800b12:	e9 7a ff ff ff       	jmp    800a91 <vprintfmt+0x3a6>
			putch('%', putdat);
  800b17:	83 ec 08             	sub    $0x8,%esp
  800b1a:	53                   	push   %ebx
  800b1b:	6a 25                	push   $0x25
  800b1d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800b1f:	83 c4 10             	add    $0x10,%esp
  800b22:	89 f8                	mov    %edi,%eax
  800b24:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800b28:	74 05                	je     800b2f <vprintfmt+0x444>
  800b2a:	83 e8 01             	sub    $0x1,%eax
  800b2d:	eb f5                	jmp    800b24 <vprintfmt+0x439>
  800b2f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b32:	e9 5a ff ff ff       	jmp    800a91 <vprintfmt+0x3a6>
}
  800b37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b3f:	f3 0f 1e fb          	endbr32 
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	83 ec 18             	sub    $0x18,%esp
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b4f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b52:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b56:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b60:	85 c0                	test   %eax,%eax
  800b62:	74 26                	je     800b8a <vsnprintf+0x4b>
  800b64:	85 d2                	test   %edx,%edx
  800b66:	7e 22                	jle    800b8a <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b68:	ff 75 14             	pushl  0x14(%ebp)
  800b6b:	ff 75 10             	pushl  0x10(%ebp)
  800b6e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b71:	50                   	push   %eax
  800b72:	68 a9 06 80 00       	push   $0x8006a9
  800b77:	e8 6f fb ff ff       	call   8006eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b7f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b85:	83 c4 10             	add    $0x10,%esp
}
  800b88:	c9                   	leave  
  800b89:	c3                   	ret    
		return -E_INVAL;
  800b8a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b8f:	eb f7                	jmp    800b88 <vsnprintf+0x49>

00800b91 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b91:	f3 0f 1e fb          	endbr32 
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  800b9b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b9e:	50                   	push   %eax
  800b9f:	ff 75 10             	pushl  0x10(%ebp)
  800ba2:	ff 75 0c             	pushl  0xc(%ebp)
  800ba5:	ff 75 08             	pushl  0x8(%ebp)
  800ba8:	e8 92 ff ff ff       	call   800b3f <vsnprintf>
	va_end(ap);

	return rc;
}
  800bad:	c9                   	leave  
  800bae:	c3                   	ret    

00800baf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800baf:	f3 0f 1e fb          	endbr32 
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800bb9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbe:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bc2:	74 05                	je     800bc9 <strlen+0x1a>
		n++;
  800bc4:	83 c0 01             	add    $0x1,%eax
  800bc7:	eb f5                	jmp    800bbe <strlen+0xf>
	return n;
}
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bcb:	f3 0f 1e fb          	endbr32 
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bd8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bdd:	39 d0                	cmp    %edx,%eax
  800bdf:	74 0d                	je     800bee <strnlen+0x23>
  800be1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800be5:	74 05                	je     800bec <strnlen+0x21>
		n++;
  800be7:	83 c0 01             	add    $0x1,%eax
  800bea:	eb f1                	jmp    800bdd <strnlen+0x12>
  800bec:	89 c2                	mov    %eax,%edx
	return n;
}
  800bee:	89 d0                	mov    %edx,%eax
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bf2:	f3 0f 1e fb          	endbr32 
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	53                   	push   %ebx
  800bfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bfd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c00:	b8 00 00 00 00       	mov    $0x0,%eax
  800c05:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800c09:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800c0c:	83 c0 01             	add    $0x1,%eax
  800c0f:	84 d2                	test   %dl,%dl
  800c11:	75 f2                	jne    800c05 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800c13:	89 c8                	mov    %ecx,%eax
  800c15:	5b                   	pop    %ebx
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c18:	f3 0f 1e fb          	endbr32 
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	53                   	push   %ebx
  800c20:	83 ec 10             	sub    $0x10,%esp
  800c23:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c26:	53                   	push   %ebx
  800c27:	e8 83 ff ff ff       	call   800baf <strlen>
  800c2c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800c2f:	ff 75 0c             	pushl  0xc(%ebp)
  800c32:	01 d8                	add    %ebx,%eax
  800c34:	50                   	push   %eax
  800c35:	e8 b8 ff ff ff       	call   800bf2 <strcpy>
	return dst;
}
  800c3a:	89 d8                	mov    %ebx,%eax
  800c3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c3f:	c9                   	leave  
  800c40:	c3                   	ret    

00800c41 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c41:	f3 0f 1e fb          	endbr32 
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
  800c4a:	8b 75 08             	mov    0x8(%ebp),%esi
  800c4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c50:	89 f3                	mov    %esi,%ebx
  800c52:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c55:	89 f0                	mov    %esi,%eax
  800c57:	39 d8                	cmp    %ebx,%eax
  800c59:	74 11                	je     800c6c <strncpy+0x2b>
		*dst++ = *src;
  800c5b:	83 c0 01             	add    $0x1,%eax
  800c5e:	0f b6 0a             	movzbl (%edx),%ecx
  800c61:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c64:	80 f9 01             	cmp    $0x1,%cl
  800c67:	83 da ff             	sbb    $0xffffffff,%edx
  800c6a:	eb eb                	jmp    800c57 <strncpy+0x16>
	}
	return ret;
}
  800c6c:	89 f0                	mov    %esi,%eax
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c72:	f3 0f 1e fb          	endbr32 
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	8b 75 08             	mov    0x8(%ebp),%esi
  800c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c81:	8b 55 10             	mov    0x10(%ebp),%edx
  800c84:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c86:	85 d2                	test   %edx,%edx
  800c88:	74 21                	je     800cab <strlcpy+0x39>
  800c8a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c8e:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800c90:	39 c2                	cmp    %eax,%edx
  800c92:	74 14                	je     800ca8 <strlcpy+0x36>
  800c94:	0f b6 19             	movzbl (%ecx),%ebx
  800c97:	84 db                	test   %bl,%bl
  800c99:	74 0b                	je     800ca6 <strlcpy+0x34>
			*dst++ = *src++;
  800c9b:	83 c1 01             	add    $0x1,%ecx
  800c9e:	83 c2 01             	add    $0x1,%edx
  800ca1:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ca4:	eb ea                	jmp    800c90 <strlcpy+0x1e>
  800ca6:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800ca8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800cab:	29 f0                	sub    %esi,%eax
}
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cb1:	f3 0f 1e fb          	endbr32 
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cbb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800cbe:	0f b6 01             	movzbl (%ecx),%eax
  800cc1:	84 c0                	test   %al,%al
  800cc3:	74 0c                	je     800cd1 <strcmp+0x20>
  800cc5:	3a 02                	cmp    (%edx),%al
  800cc7:	75 08                	jne    800cd1 <strcmp+0x20>
		p++, q++;
  800cc9:	83 c1 01             	add    $0x1,%ecx
  800ccc:	83 c2 01             	add    $0x1,%edx
  800ccf:	eb ed                	jmp    800cbe <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800cd1:	0f b6 c0             	movzbl %al,%eax
  800cd4:	0f b6 12             	movzbl (%edx),%edx
  800cd7:	29 d0                	sub    %edx,%eax
}
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cdb:	f3 0f 1e fb          	endbr32 
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	53                   	push   %ebx
  800ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ce9:	89 c3                	mov    %eax,%ebx
  800ceb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800cee:	eb 06                	jmp    800cf6 <strncmp+0x1b>
		n--, p++, q++;
  800cf0:	83 c0 01             	add    $0x1,%eax
  800cf3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800cf6:	39 d8                	cmp    %ebx,%eax
  800cf8:	74 16                	je     800d10 <strncmp+0x35>
  800cfa:	0f b6 08             	movzbl (%eax),%ecx
  800cfd:	84 c9                	test   %cl,%cl
  800cff:	74 04                	je     800d05 <strncmp+0x2a>
  800d01:	3a 0a                	cmp    (%edx),%cl
  800d03:	74 eb                	je     800cf0 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d05:	0f b6 00             	movzbl (%eax),%eax
  800d08:	0f b6 12             	movzbl (%edx),%edx
  800d0b:	29 d0                	sub    %edx,%eax
}
  800d0d:	5b                   	pop    %ebx
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    
		return 0;
  800d10:	b8 00 00 00 00       	mov    $0x0,%eax
  800d15:	eb f6                	jmp    800d0d <strncmp+0x32>

00800d17 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d17:	f3 0f 1e fb          	endbr32 
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d25:	0f b6 10             	movzbl (%eax),%edx
  800d28:	84 d2                	test   %dl,%dl
  800d2a:	74 09                	je     800d35 <strchr+0x1e>
		if (*s == c)
  800d2c:	38 ca                	cmp    %cl,%dl
  800d2e:	74 0a                	je     800d3a <strchr+0x23>
	for (; *s; s++)
  800d30:	83 c0 01             	add    $0x1,%eax
  800d33:	eb f0                	jmp    800d25 <strchr+0xe>
			return (char *) s;
	return 0;
  800d35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800d3c:	f3 0f 1e fb          	endbr32 
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800d46:	6a 78                	push   $0x78
  800d48:	ff 75 08             	pushl  0x8(%ebp)
  800d4b:	e8 c7 ff ff ff       	call   800d17 <strchr>
  800d50:	83 c4 10             	add    $0x10,%esp
  800d53:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  800d56:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800d5b:	eb 0d                	jmp    800d6a <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800d5d:	c1 e0 04             	shl    $0x4,%eax
  800d60:	0f be d2             	movsbl %dl,%edx
  800d63:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800d67:	83 c1 01             	add    $0x1,%ecx
  800d6a:	0f b6 11             	movzbl (%ecx),%edx
  800d6d:	84 d2                	test   %dl,%dl
  800d6f:	74 11                	je     800d82 <atox+0x46>
		if (*p>='a'){
  800d71:	80 fa 60             	cmp    $0x60,%dl
  800d74:	7e e7                	jle    800d5d <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800d76:	c1 e0 04             	shl    $0x4,%eax
  800d79:	0f be d2             	movsbl %dl,%edx
  800d7c:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800d80:	eb e5                	jmp    800d67 <atox+0x2b>
	}

	return v;

}
  800d82:	c9                   	leave  
  800d83:	c3                   	ret    

00800d84 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d84:	f3 0f 1e fb          	endbr32 
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d92:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800d95:	38 ca                	cmp    %cl,%dl
  800d97:	74 09                	je     800da2 <strfind+0x1e>
  800d99:	84 d2                	test   %dl,%dl
  800d9b:	74 05                	je     800da2 <strfind+0x1e>
	for (; *s; s++)
  800d9d:	83 c0 01             	add    $0x1,%eax
  800da0:	eb f0                	jmp    800d92 <strfind+0xe>
			break;
	return (char *) s;
}
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800da4:	f3 0f 1e fb          	endbr32 
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	57                   	push   %edi
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
  800dae:	8b 7d 08             	mov    0x8(%ebp),%edi
  800db1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800db4:	85 c9                	test   %ecx,%ecx
  800db6:	74 31                	je     800de9 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800db8:	89 f8                	mov    %edi,%eax
  800dba:	09 c8                	or     %ecx,%eax
  800dbc:	a8 03                	test   $0x3,%al
  800dbe:	75 23                	jne    800de3 <memset+0x3f>
		c &= 0xFF;
  800dc0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dc4:	89 d3                	mov    %edx,%ebx
  800dc6:	c1 e3 08             	shl    $0x8,%ebx
  800dc9:	89 d0                	mov    %edx,%eax
  800dcb:	c1 e0 18             	shl    $0x18,%eax
  800dce:	89 d6                	mov    %edx,%esi
  800dd0:	c1 e6 10             	shl    $0x10,%esi
  800dd3:	09 f0                	or     %esi,%eax
  800dd5:	09 c2                	or     %eax,%edx
  800dd7:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800dd9:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ddc:	89 d0                	mov    %edx,%eax
  800dde:	fc                   	cld    
  800ddf:	f3 ab                	rep stos %eax,%es:(%edi)
  800de1:	eb 06                	jmp    800de9 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800de3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de6:	fc                   	cld    
  800de7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800de9:	89 f8                	mov    %edi,%eax
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800df0:	f3 0f 1e fb          	endbr32 
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	57                   	push   %edi
  800df8:	56                   	push   %esi
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e02:	39 c6                	cmp    %eax,%esi
  800e04:	73 32                	jae    800e38 <memmove+0x48>
  800e06:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e09:	39 c2                	cmp    %eax,%edx
  800e0b:	76 2b                	jbe    800e38 <memmove+0x48>
		s += n;
		d += n;
  800e0d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e10:	89 fe                	mov    %edi,%esi
  800e12:	09 ce                	or     %ecx,%esi
  800e14:	09 d6                	or     %edx,%esi
  800e16:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e1c:	75 0e                	jne    800e2c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e1e:	83 ef 04             	sub    $0x4,%edi
  800e21:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e24:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800e27:	fd                   	std    
  800e28:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e2a:	eb 09                	jmp    800e35 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e2c:	83 ef 01             	sub    $0x1,%edi
  800e2f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800e32:	fd                   	std    
  800e33:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e35:	fc                   	cld    
  800e36:	eb 1a                	jmp    800e52 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e38:	89 c2                	mov    %eax,%edx
  800e3a:	09 ca                	or     %ecx,%edx
  800e3c:	09 f2                	or     %esi,%edx
  800e3e:	f6 c2 03             	test   $0x3,%dl
  800e41:	75 0a                	jne    800e4d <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e43:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800e46:	89 c7                	mov    %eax,%edi
  800e48:	fc                   	cld    
  800e49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e4b:	eb 05                	jmp    800e52 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800e4d:	89 c7                	mov    %eax,%edi
  800e4f:	fc                   	cld    
  800e50:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e52:	5e                   	pop    %esi
  800e53:	5f                   	pop    %edi
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e56:	f3 0f 1e fb          	endbr32 
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e60:	ff 75 10             	pushl  0x10(%ebp)
  800e63:	ff 75 0c             	pushl  0xc(%ebp)
  800e66:	ff 75 08             	pushl  0x8(%ebp)
  800e69:	e8 82 ff ff ff       	call   800df0 <memmove>
}
  800e6e:	c9                   	leave  
  800e6f:	c3                   	ret    

00800e70 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e70:	f3 0f 1e fb          	endbr32 
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	56                   	push   %esi
  800e78:	53                   	push   %ebx
  800e79:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e7f:	89 c6                	mov    %eax,%esi
  800e81:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e84:	39 f0                	cmp    %esi,%eax
  800e86:	74 1c                	je     800ea4 <memcmp+0x34>
		if (*s1 != *s2)
  800e88:	0f b6 08             	movzbl (%eax),%ecx
  800e8b:	0f b6 1a             	movzbl (%edx),%ebx
  800e8e:	38 d9                	cmp    %bl,%cl
  800e90:	75 08                	jne    800e9a <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800e92:	83 c0 01             	add    $0x1,%eax
  800e95:	83 c2 01             	add    $0x1,%edx
  800e98:	eb ea                	jmp    800e84 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800e9a:	0f b6 c1             	movzbl %cl,%eax
  800e9d:	0f b6 db             	movzbl %bl,%ebx
  800ea0:	29 d8                	sub    %ebx,%eax
  800ea2:	eb 05                	jmp    800ea9 <memcmp+0x39>
	}

	return 0;
  800ea4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ea9:	5b                   	pop    %ebx
  800eaa:	5e                   	pop    %esi
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ead:	f3 0f 1e fb          	endbr32 
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800eba:	89 c2                	mov    %eax,%edx
  800ebc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ebf:	39 d0                	cmp    %edx,%eax
  800ec1:	73 09                	jae    800ecc <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ec3:	38 08                	cmp    %cl,(%eax)
  800ec5:	74 05                	je     800ecc <memfind+0x1f>
	for (; s < ends; s++)
  800ec7:	83 c0 01             	add    $0x1,%eax
  800eca:	eb f3                	jmp    800ebf <memfind+0x12>
			break;
	return (void *) s;
}
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    

00800ece <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ece:	f3 0f 1e fb          	endbr32 
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	57                   	push   %edi
  800ed6:	56                   	push   %esi
  800ed7:	53                   	push   %ebx
  800ed8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800edb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ede:	eb 03                	jmp    800ee3 <strtol+0x15>
		s++;
  800ee0:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ee3:	0f b6 01             	movzbl (%ecx),%eax
  800ee6:	3c 20                	cmp    $0x20,%al
  800ee8:	74 f6                	je     800ee0 <strtol+0x12>
  800eea:	3c 09                	cmp    $0x9,%al
  800eec:	74 f2                	je     800ee0 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800eee:	3c 2b                	cmp    $0x2b,%al
  800ef0:	74 2a                	je     800f1c <strtol+0x4e>
	int neg = 0;
  800ef2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ef7:	3c 2d                	cmp    $0x2d,%al
  800ef9:	74 2b                	je     800f26 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800efb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f01:	75 0f                	jne    800f12 <strtol+0x44>
  800f03:	80 39 30             	cmpb   $0x30,(%ecx)
  800f06:	74 28                	je     800f30 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f08:	85 db                	test   %ebx,%ebx
  800f0a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f0f:	0f 44 d8             	cmove  %eax,%ebx
  800f12:	b8 00 00 00 00       	mov    $0x0,%eax
  800f17:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800f1a:	eb 46                	jmp    800f62 <strtol+0x94>
		s++;
  800f1c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800f1f:	bf 00 00 00 00       	mov    $0x0,%edi
  800f24:	eb d5                	jmp    800efb <strtol+0x2d>
		s++, neg = 1;
  800f26:	83 c1 01             	add    $0x1,%ecx
  800f29:	bf 01 00 00 00       	mov    $0x1,%edi
  800f2e:	eb cb                	jmp    800efb <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f30:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f34:	74 0e                	je     800f44 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800f36:	85 db                	test   %ebx,%ebx
  800f38:	75 d8                	jne    800f12 <strtol+0x44>
		s++, base = 8;
  800f3a:	83 c1 01             	add    $0x1,%ecx
  800f3d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800f42:	eb ce                	jmp    800f12 <strtol+0x44>
		s += 2, base = 16;
  800f44:	83 c1 02             	add    $0x2,%ecx
  800f47:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f4c:	eb c4                	jmp    800f12 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800f4e:	0f be d2             	movsbl %dl,%edx
  800f51:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f54:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f57:	7d 3a                	jge    800f93 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800f59:	83 c1 01             	add    $0x1,%ecx
  800f5c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f60:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800f62:	0f b6 11             	movzbl (%ecx),%edx
  800f65:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f68:	89 f3                	mov    %esi,%ebx
  800f6a:	80 fb 09             	cmp    $0x9,%bl
  800f6d:	76 df                	jbe    800f4e <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800f6f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f72:	89 f3                	mov    %esi,%ebx
  800f74:	80 fb 19             	cmp    $0x19,%bl
  800f77:	77 08                	ja     800f81 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800f79:	0f be d2             	movsbl %dl,%edx
  800f7c:	83 ea 57             	sub    $0x57,%edx
  800f7f:	eb d3                	jmp    800f54 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800f81:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f84:	89 f3                	mov    %esi,%ebx
  800f86:	80 fb 19             	cmp    $0x19,%bl
  800f89:	77 08                	ja     800f93 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800f8b:	0f be d2             	movsbl %dl,%edx
  800f8e:	83 ea 37             	sub    $0x37,%edx
  800f91:	eb c1                	jmp    800f54 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800f93:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f97:	74 05                	je     800f9e <strtol+0xd0>
		*endptr = (char *) s;
  800f99:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f9c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800f9e:	89 c2                	mov    %eax,%edx
  800fa0:	f7 da                	neg    %edx
  800fa2:	85 ff                	test   %edi,%edi
  800fa4:	0f 45 c2             	cmovne %edx,%eax
}
  800fa7:	5b                   	pop    %ebx
  800fa8:	5e                   	pop    %esi
  800fa9:	5f                   	pop    %edi
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fac:	f3 0f 1e fb          	endbr32 
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	57                   	push   %edi
  800fb4:	56                   	push   %esi
  800fb5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc1:	89 c3                	mov    %eax,%ebx
  800fc3:	89 c7                	mov    %eax,%edi
  800fc5:	89 c6                	mov    %eax,%esi
  800fc7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fc9:	5b                   	pop    %ebx
  800fca:	5e                   	pop    %esi
  800fcb:	5f                   	pop    %edi
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    

00800fce <sys_cgetc>:

int
sys_cgetc(void)
{
  800fce:	f3 0f 1e fb          	endbr32 
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	57                   	push   %edi
  800fd6:	56                   	push   %esi
  800fd7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800fdd:	b8 01 00 00 00       	mov    $0x1,%eax
  800fe2:	89 d1                	mov    %edx,%ecx
  800fe4:	89 d3                	mov    %edx,%ebx
  800fe6:	89 d7                	mov    %edx,%edi
  800fe8:	89 d6                	mov    %edx,%esi
  800fea:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fec:	5b                   	pop    %ebx
  800fed:	5e                   	pop    %esi
  800fee:	5f                   	pop    %edi
  800fef:	5d                   	pop    %ebp
  800ff0:	c3                   	ret    

00800ff1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ff1:	f3 0f 1e fb          	endbr32 
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	57                   	push   %edi
  800ff9:	56                   	push   %esi
  800ffa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ffb:	b9 00 00 00 00       	mov    $0x0,%ecx
  801000:	8b 55 08             	mov    0x8(%ebp),%edx
  801003:	b8 03 00 00 00       	mov    $0x3,%eax
  801008:	89 cb                	mov    %ecx,%ebx
  80100a:	89 cf                	mov    %ecx,%edi
  80100c:	89 ce                	mov    %ecx,%esi
  80100e:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801010:	5b                   	pop    %ebx
  801011:	5e                   	pop    %esi
  801012:	5f                   	pop    %edi
  801013:	5d                   	pop    %ebp
  801014:	c3                   	ret    

00801015 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801015:	f3 0f 1e fb          	endbr32 
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	57                   	push   %edi
  80101d:	56                   	push   %esi
  80101e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80101f:	ba 00 00 00 00       	mov    $0x0,%edx
  801024:	b8 02 00 00 00       	mov    $0x2,%eax
  801029:	89 d1                	mov    %edx,%ecx
  80102b:	89 d3                	mov    %edx,%ebx
  80102d:	89 d7                	mov    %edx,%edi
  80102f:	89 d6                	mov    %edx,%esi
  801031:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801033:	5b                   	pop    %ebx
  801034:	5e                   	pop    %esi
  801035:	5f                   	pop    %edi
  801036:	5d                   	pop    %ebp
  801037:	c3                   	ret    

00801038 <sys_yield>:

void
sys_yield(void)
{
  801038:	f3 0f 1e fb          	endbr32 
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	57                   	push   %edi
  801040:	56                   	push   %esi
  801041:	53                   	push   %ebx
	asm volatile("int %1\n"
  801042:	ba 00 00 00 00       	mov    $0x0,%edx
  801047:	b8 0b 00 00 00       	mov    $0xb,%eax
  80104c:	89 d1                	mov    %edx,%ecx
  80104e:	89 d3                	mov    %edx,%ebx
  801050:	89 d7                	mov    %edx,%edi
  801052:	89 d6                	mov    %edx,%esi
  801054:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801056:	5b                   	pop    %ebx
  801057:	5e                   	pop    %esi
  801058:	5f                   	pop    %edi
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    

0080105b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80105b:	f3 0f 1e fb          	endbr32 
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
  801062:	57                   	push   %edi
  801063:	56                   	push   %esi
  801064:	53                   	push   %ebx
	asm volatile("int %1\n"
  801065:	be 00 00 00 00       	mov    $0x0,%esi
  80106a:	8b 55 08             	mov    0x8(%ebp),%edx
  80106d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801070:	b8 04 00 00 00       	mov    $0x4,%eax
  801075:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801078:	89 f7                	mov    %esi,%edi
  80107a:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80107c:	5b                   	pop    %ebx
  80107d:	5e                   	pop    %esi
  80107e:	5f                   	pop    %edi
  80107f:	5d                   	pop    %ebp
  801080:	c3                   	ret    

00801081 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801081:	f3 0f 1e fb          	endbr32 
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	57                   	push   %edi
  801089:	56                   	push   %esi
  80108a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80108b:	8b 55 08             	mov    0x8(%ebp),%edx
  80108e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801091:	b8 05 00 00 00       	mov    $0x5,%eax
  801096:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801099:	8b 7d 14             	mov    0x14(%ebp),%edi
  80109c:	8b 75 18             	mov    0x18(%ebp),%esi
  80109f:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010a1:	5b                   	pop    %ebx
  8010a2:	5e                   	pop    %esi
  8010a3:	5f                   	pop    %edi
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  8010bb:	b8 06 00 00 00       	mov    $0x6,%eax
  8010c0:	89 df                	mov    %ebx,%edi
  8010c2:	89 de                	mov    %ebx,%esi
  8010c4:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8010c6:	5b                   	pop    %ebx
  8010c7:	5e                   	pop    %esi
  8010c8:	5f                   	pop    %edi
  8010c9:	5d                   	pop    %ebp
  8010ca:	c3                   	ret    

008010cb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010cb:	f3 0f 1e fb          	endbr32 
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	57                   	push   %edi
  8010d3:	56                   	push   %esi
  8010d4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010da:	8b 55 08             	mov    0x8(%ebp),%edx
  8010dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e0:	b8 08 00 00 00       	mov    $0x8,%eax
  8010e5:	89 df                	mov    %ebx,%edi
  8010e7:	89 de                	mov    %ebx,%esi
  8010e9:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010eb:	5b                   	pop    %ebx
  8010ec:	5e                   	pop    %esi
  8010ed:	5f                   	pop    %edi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010f0:	f3 0f 1e fb          	endbr32 
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	57                   	push   %edi
  8010f8:	56                   	push   %esi
  8010f9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801102:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801105:	b8 09 00 00 00       	mov    $0x9,%eax
  80110a:	89 df                	mov    %ebx,%edi
  80110c:	89 de                	mov    %ebx,%esi
  80110e:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801110:	5b                   	pop    %ebx
  801111:	5e                   	pop    %esi
  801112:	5f                   	pop    %edi
  801113:	5d                   	pop    %ebp
  801114:	c3                   	ret    

00801115 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801115:	f3 0f 1e fb          	endbr32 
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	57                   	push   %edi
  80111d:	56                   	push   %esi
  80111e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80111f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801124:	8b 55 08             	mov    0x8(%ebp),%edx
  801127:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80112f:	89 df                	mov    %ebx,%edi
  801131:	89 de                	mov    %ebx,%esi
  801133:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801135:	5b                   	pop    %ebx
  801136:	5e                   	pop    %esi
  801137:	5f                   	pop    %edi
  801138:	5d                   	pop    %ebp
  801139:	c3                   	ret    

0080113a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80113a:	f3 0f 1e fb          	endbr32 
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	57                   	push   %edi
  801142:	56                   	push   %esi
  801143:	53                   	push   %ebx
	asm volatile("int %1\n"
  801144:	8b 55 08             	mov    0x8(%ebp),%edx
  801147:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80114f:	be 00 00 00 00       	mov    $0x0,%esi
  801154:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801157:	8b 7d 14             	mov    0x14(%ebp),%edi
  80115a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80115c:	5b                   	pop    %ebx
  80115d:	5e                   	pop    %esi
  80115e:	5f                   	pop    %edi
  80115f:	5d                   	pop    %ebp
  801160:	c3                   	ret    

00801161 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801161:	f3 0f 1e fb          	endbr32 
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	57                   	push   %edi
  801169:	56                   	push   %esi
  80116a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80116b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801170:	8b 55 08             	mov    0x8(%ebp),%edx
  801173:	b8 0d 00 00 00       	mov    $0xd,%eax
  801178:	89 cb                	mov    %ecx,%ebx
  80117a:	89 cf                	mov    %ecx,%edi
  80117c:	89 ce                	mov    %ecx,%esi
  80117e:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801180:	5b                   	pop    %ebx
  801181:	5e                   	pop    %esi
  801182:	5f                   	pop    %edi
  801183:	5d                   	pop    %ebp
  801184:	c3                   	ret    

00801185 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801185:	f3 0f 1e fb          	endbr32 
  801189:	55                   	push   %ebp
  80118a:	89 e5                	mov    %esp,%ebp
  80118c:	57                   	push   %edi
  80118d:	56                   	push   %esi
  80118e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80118f:	ba 00 00 00 00       	mov    $0x0,%edx
  801194:	b8 0e 00 00 00       	mov    $0xe,%eax
  801199:	89 d1                	mov    %edx,%ecx
  80119b:	89 d3                	mov    %edx,%ebx
  80119d:	89 d7                	mov    %edx,%edi
  80119f:	89 d6                	mov    %edx,%esi
  8011a1:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8011a3:	5b                   	pop    %ebx
  8011a4:	5e                   	pop    %esi
  8011a5:	5f                   	pop    %edi
  8011a6:	5d                   	pop    %ebp
  8011a7:	c3                   	ret    

008011a8 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  8011a8:	f3 0f 1e fb          	endbr32 
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	57                   	push   %edi
  8011b0:	56                   	push   %esi
  8011b1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011bd:	b8 0f 00 00 00       	mov    $0xf,%eax
  8011c2:	89 df                	mov    %ebx,%edi
  8011c4:	89 de                	mov    %ebx,%esi
  8011c6:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  8011c8:	5b                   	pop    %ebx
  8011c9:	5e                   	pop    %esi
  8011ca:	5f                   	pop    %edi
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    

008011cd <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  8011cd:	f3 0f 1e fb          	endbr32 
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	57                   	push   %edi
  8011d5:	56                   	push   %esi
  8011d6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8011df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e2:	b8 10 00 00 00       	mov    $0x10,%eax
  8011e7:	89 df                	mov    %ebx,%edi
  8011e9:	89 de                	mov    %ebx,%esi
  8011eb:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  8011ed:	5b                   	pop    %ebx
  8011ee:	5e                   	pop    %esi
  8011ef:	5f                   	pop    %edi
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    

008011f2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011f2:	f3 0f 1e fb          	endbr32 
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fc:	05 00 00 00 30       	add    $0x30000000,%eax
  801201:	c1 e8 0c             	shr    $0xc,%eax
}
  801204:	5d                   	pop    %ebp
  801205:	c3                   	ret    

00801206 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801206:	f3 0f 1e fb          	endbr32 
  80120a:	55                   	push   %ebp
  80120b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80120d:	8b 45 08             	mov    0x8(%ebp),%eax
  801210:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801215:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80121a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80121f:	5d                   	pop    %ebp
  801220:	c3                   	ret    

00801221 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801221:	f3 0f 1e fb          	endbr32 
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
  801228:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80122d:	89 c2                	mov    %eax,%edx
  80122f:	c1 ea 16             	shr    $0x16,%edx
  801232:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801239:	f6 c2 01             	test   $0x1,%dl
  80123c:	74 2d                	je     80126b <fd_alloc+0x4a>
  80123e:	89 c2                	mov    %eax,%edx
  801240:	c1 ea 0c             	shr    $0xc,%edx
  801243:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80124a:	f6 c2 01             	test   $0x1,%dl
  80124d:	74 1c                	je     80126b <fd_alloc+0x4a>
  80124f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801254:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801259:	75 d2                	jne    80122d <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  80125b:	8b 45 08             	mov    0x8(%ebp),%eax
  80125e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801264:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801269:	eb 0a                	jmp    801275 <fd_alloc+0x54>
			*fd_store = fd;
  80126b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801270:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801275:	5d                   	pop    %ebp
  801276:	c3                   	ret    

00801277 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801277:	f3 0f 1e fb          	endbr32 
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801281:	83 f8 1f             	cmp    $0x1f,%eax
  801284:	77 30                	ja     8012b6 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801286:	c1 e0 0c             	shl    $0xc,%eax
  801289:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80128e:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801294:	f6 c2 01             	test   $0x1,%dl
  801297:	74 24                	je     8012bd <fd_lookup+0x46>
  801299:	89 c2                	mov    %eax,%edx
  80129b:	c1 ea 0c             	shr    $0xc,%edx
  80129e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a5:	f6 c2 01             	test   $0x1,%dl
  8012a8:	74 1a                	je     8012c4 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ad:	89 02                	mov    %eax,(%edx)
	return 0;
  8012af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012b4:	5d                   	pop    %ebp
  8012b5:	c3                   	ret    
		return -E_INVAL;
  8012b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012bb:	eb f7                	jmp    8012b4 <fd_lookup+0x3d>
		return -E_INVAL;
  8012bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c2:	eb f0                	jmp    8012b4 <fd_lookup+0x3d>
  8012c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c9:	eb e9                	jmp    8012b4 <fd_lookup+0x3d>

008012cb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012cb:	f3 0f 1e fb          	endbr32 
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	83 ec 08             	sub    $0x8,%esp
  8012d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8012d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8012dd:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  8012e2:	39 08                	cmp    %ecx,(%eax)
  8012e4:	74 38                	je     80131e <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8012e6:	83 c2 01             	add    $0x1,%edx
  8012e9:	8b 04 95 9c 2c 80 00 	mov    0x802c9c(,%edx,4),%eax
  8012f0:	85 c0                	test   %eax,%eax
  8012f2:	75 ee                	jne    8012e2 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012f4:	a1 18 40 80 00       	mov    0x804018,%eax
  8012f9:	8b 40 48             	mov    0x48(%eax),%eax
  8012fc:	83 ec 04             	sub    $0x4,%esp
  8012ff:	51                   	push   %ecx
  801300:	50                   	push   %eax
  801301:	68 20 2c 80 00       	push   $0x802c20
  801306:	e8 dd f2 ff ff       	call   8005e8 <cprintf>
	*dev = 0;
  80130b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80130e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801314:	83 c4 10             	add    $0x10,%esp
  801317:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80131c:	c9                   	leave  
  80131d:	c3                   	ret    
			*dev = devtab[i];
  80131e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801321:	89 01                	mov    %eax,(%ecx)
			return 0;
  801323:	b8 00 00 00 00       	mov    $0x0,%eax
  801328:	eb f2                	jmp    80131c <dev_lookup+0x51>

0080132a <fd_close>:
{
  80132a:	f3 0f 1e fb          	endbr32 
  80132e:	55                   	push   %ebp
  80132f:	89 e5                	mov    %esp,%ebp
  801331:	57                   	push   %edi
  801332:	56                   	push   %esi
  801333:	53                   	push   %ebx
  801334:	83 ec 24             	sub    $0x24,%esp
  801337:	8b 75 08             	mov    0x8(%ebp),%esi
  80133a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80133d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801340:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801341:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801347:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80134a:	50                   	push   %eax
  80134b:	e8 27 ff ff ff       	call   801277 <fd_lookup>
  801350:	89 c3                	mov    %eax,%ebx
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	85 c0                	test   %eax,%eax
  801357:	78 05                	js     80135e <fd_close+0x34>
	    || fd != fd2)
  801359:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80135c:	74 16                	je     801374 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80135e:	89 f8                	mov    %edi,%eax
  801360:	84 c0                	test   %al,%al
  801362:	b8 00 00 00 00       	mov    $0x0,%eax
  801367:	0f 44 d8             	cmove  %eax,%ebx
}
  80136a:	89 d8                	mov    %ebx,%eax
  80136c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80136f:	5b                   	pop    %ebx
  801370:	5e                   	pop    %esi
  801371:	5f                   	pop    %edi
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801374:	83 ec 08             	sub    $0x8,%esp
  801377:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80137a:	50                   	push   %eax
  80137b:	ff 36                	pushl  (%esi)
  80137d:	e8 49 ff ff ff       	call   8012cb <dev_lookup>
  801382:	89 c3                	mov    %eax,%ebx
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	85 c0                	test   %eax,%eax
  801389:	78 1a                	js     8013a5 <fd_close+0x7b>
		if (dev->dev_close)
  80138b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80138e:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801391:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801396:	85 c0                	test   %eax,%eax
  801398:	74 0b                	je     8013a5 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80139a:	83 ec 0c             	sub    $0xc,%esp
  80139d:	56                   	push   %esi
  80139e:	ff d0                	call   *%eax
  8013a0:	89 c3                	mov    %eax,%ebx
  8013a2:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8013a5:	83 ec 08             	sub    $0x8,%esp
  8013a8:	56                   	push   %esi
  8013a9:	6a 00                	push   $0x0
  8013ab:	e8 f6 fc ff ff       	call   8010a6 <sys_page_unmap>
	return r;
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	eb b5                	jmp    80136a <fd_close+0x40>

008013b5 <close>:

int
close(int fdnum)
{
  8013b5:	f3 0f 1e fb          	endbr32 
  8013b9:	55                   	push   %ebp
  8013ba:	89 e5                	mov    %esp,%ebp
  8013bc:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c2:	50                   	push   %eax
  8013c3:	ff 75 08             	pushl  0x8(%ebp)
  8013c6:	e8 ac fe ff ff       	call   801277 <fd_lookup>
  8013cb:	83 c4 10             	add    $0x10,%esp
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	79 02                	jns    8013d4 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8013d2:	c9                   	leave  
  8013d3:	c3                   	ret    
		return fd_close(fd, 1);
  8013d4:	83 ec 08             	sub    $0x8,%esp
  8013d7:	6a 01                	push   $0x1
  8013d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8013dc:	e8 49 ff ff ff       	call   80132a <fd_close>
  8013e1:	83 c4 10             	add    $0x10,%esp
  8013e4:	eb ec                	jmp    8013d2 <close+0x1d>

008013e6 <close_all>:

void
close_all(void)
{
  8013e6:	f3 0f 1e fb          	endbr32 
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	53                   	push   %ebx
  8013ee:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013f6:	83 ec 0c             	sub    $0xc,%esp
  8013f9:	53                   	push   %ebx
  8013fa:	e8 b6 ff ff ff       	call   8013b5 <close>
	for (i = 0; i < MAXFD; i++)
  8013ff:	83 c3 01             	add    $0x1,%ebx
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	83 fb 20             	cmp    $0x20,%ebx
  801408:	75 ec                	jne    8013f6 <close_all+0x10>
}
  80140a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140d:	c9                   	leave  
  80140e:	c3                   	ret    

0080140f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80140f:	f3 0f 1e fb          	endbr32 
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	57                   	push   %edi
  801417:	56                   	push   %esi
  801418:	53                   	push   %ebx
  801419:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80141c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80141f:	50                   	push   %eax
  801420:	ff 75 08             	pushl  0x8(%ebp)
  801423:	e8 4f fe ff ff       	call   801277 <fd_lookup>
  801428:	89 c3                	mov    %eax,%ebx
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	85 c0                	test   %eax,%eax
  80142f:	0f 88 81 00 00 00    	js     8014b6 <dup+0xa7>
		return r;
	close(newfdnum);
  801435:	83 ec 0c             	sub    $0xc,%esp
  801438:	ff 75 0c             	pushl  0xc(%ebp)
  80143b:	e8 75 ff ff ff       	call   8013b5 <close>

	newfd = INDEX2FD(newfdnum);
  801440:	8b 75 0c             	mov    0xc(%ebp),%esi
  801443:	c1 e6 0c             	shl    $0xc,%esi
  801446:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80144c:	83 c4 04             	add    $0x4,%esp
  80144f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801452:	e8 af fd ff ff       	call   801206 <fd2data>
  801457:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801459:	89 34 24             	mov    %esi,(%esp)
  80145c:	e8 a5 fd ff ff       	call   801206 <fd2data>
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801466:	89 d8                	mov    %ebx,%eax
  801468:	c1 e8 16             	shr    $0x16,%eax
  80146b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801472:	a8 01                	test   $0x1,%al
  801474:	74 11                	je     801487 <dup+0x78>
  801476:	89 d8                	mov    %ebx,%eax
  801478:	c1 e8 0c             	shr    $0xc,%eax
  80147b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801482:	f6 c2 01             	test   $0x1,%dl
  801485:	75 39                	jne    8014c0 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801487:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80148a:	89 d0                	mov    %edx,%eax
  80148c:	c1 e8 0c             	shr    $0xc,%eax
  80148f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801496:	83 ec 0c             	sub    $0xc,%esp
  801499:	25 07 0e 00 00       	and    $0xe07,%eax
  80149e:	50                   	push   %eax
  80149f:	56                   	push   %esi
  8014a0:	6a 00                	push   $0x0
  8014a2:	52                   	push   %edx
  8014a3:	6a 00                	push   $0x0
  8014a5:	e8 d7 fb ff ff       	call   801081 <sys_page_map>
  8014aa:	89 c3                	mov    %eax,%ebx
  8014ac:	83 c4 20             	add    $0x20,%esp
  8014af:	85 c0                	test   %eax,%eax
  8014b1:	78 31                	js     8014e4 <dup+0xd5>
		goto err;

	return newfdnum;
  8014b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014b6:	89 d8                	mov    %ebx,%eax
  8014b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014bb:	5b                   	pop    %ebx
  8014bc:	5e                   	pop    %esi
  8014bd:	5f                   	pop    %edi
  8014be:	5d                   	pop    %ebp
  8014bf:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c7:	83 ec 0c             	sub    $0xc,%esp
  8014ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8014cf:	50                   	push   %eax
  8014d0:	57                   	push   %edi
  8014d1:	6a 00                	push   $0x0
  8014d3:	53                   	push   %ebx
  8014d4:	6a 00                	push   $0x0
  8014d6:	e8 a6 fb ff ff       	call   801081 <sys_page_map>
  8014db:	89 c3                	mov    %eax,%ebx
  8014dd:	83 c4 20             	add    $0x20,%esp
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	79 a3                	jns    801487 <dup+0x78>
	sys_page_unmap(0, newfd);
  8014e4:	83 ec 08             	sub    $0x8,%esp
  8014e7:	56                   	push   %esi
  8014e8:	6a 00                	push   $0x0
  8014ea:	e8 b7 fb ff ff       	call   8010a6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014ef:	83 c4 08             	add    $0x8,%esp
  8014f2:	57                   	push   %edi
  8014f3:	6a 00                	push   $0x0
  8014f5:	e8 ac fb ff ff       	call   8010a6 <sys_page_unmap>
	return r;
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	eb b7                	jmp    8014b6 <dup+0xa7>

008014ff <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014ff:	f3 0f 1e fb          	endbr32 
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	53                   	push   %ebx
  801507:	83 ec 1c             	sub    $0x1c,%esp
  80150a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801510:	50                   	push   %eax
  801511:	53                   	push   %ebx
  801512:	e8 60 fd ff ff       	call   801277 <fd_lookup>
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	85 c0                	test   %eax,%eax
  80151c:	78 3f                	js     80155d <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151e:	83 ec 08             	sub    $0x8,%esp
  801521:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801524:	50                   	push   %eax
  801525:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801528:	ff 30                	pushl  (%eax)
  80152a:	e8 9c fd ff ff       	call   8012cb <dev_lookup>
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	85 c0                	test   %eax,%eax
  801534:	78 27                	js     80155d <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801536:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801539:	8b 42 08             	mov    0x8(%edx),%eax
  80153c:	83 e0 03             	and    $0x3,%eax
  80153f:	83 f8 01             	cmp    $0x1,%eax
  801542:	74 1e                	je     801562 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801544:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801547:	8b 40 08             	mov    0x8(%eax),%eax
  80154a:	85 c0                	test   %eax,%eax
  80154c:	74 35                	je     801583 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80154e:	83 ec 04             	sub    $0x4,%esp
  801551:	ff 75 10             	pushl  0x10(%ebp)
  801554:	ff 75 0c             	pushl  0xc(%ebp)
  801557:	52                   	push   %edx
  801558:	ff d0                	call   *%eax
  80155a:	83 c4 10             	add    $0x10,%esp
}
  80155d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801560:	c9                   	leave  
  801561:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801562:	a1 18 40 80 00       	mov    0x804018,%eax
  801567:	8b 40 48             	mov    0x48(%eax),%eax
  80156a:	83 ec 04             	sub    $0x4,%esp
  80156d:	53                   	push   %ebx
  80156e:	50                   	push   %eax
  80156f:	68 61 2c 80 00       	push   $0x802c61
  801574:	e8 6f f0 ff ff       	call   8005e8 <cprintf>
		return -E_INVAL;
  801579:	83 c4 10             	add    $0x10,%esp
  80157c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801581:	eb da                	jmp    80155d <read+0x5e>
		return -E_NOT_SUPP;
  801583:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801588:	eb d3                	jmp    80155d <read+0x5e>

0080158a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80158a:	f3 0f 1e fb          	endbr32 
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	57                   	push   %edi
  801592:	56                   	push   %esi
  801593:	53                   	push   %ebx
  801594:	83 ec 0c             	sub    $0xc,%esp
  801597:	8b 7d 08             	mov    0x8(%ebp),%edi
  80159a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80159d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a2:	eb 02                	jmp    8015a6 <readn+0x1c>
  8015a4:	01 c3                	add    %eax,%ebx
  8015a6:	39 f3                	cmp    %esi,%ebx
  8015a8:	73 21                	jae    8015cb <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015aa:	83 ec 04             	sub    $0x4,%esp
  8015ad:	89 f0                	mov    %esi,%eax
  8015af:	29 d8                	sub    %ebx,%eax
  8015b1:	50                   	push   %eax
  8015b2:	89 d8                	mov    %ebx,%eax
  8015b4:	03 45 0c             	add    0xc(%ebp),%eax
  8015b7:	50                   	push   %eax
  8015b8:	57                   	push   %edi
  8015b9:	e8 41 ff ff ff       	call   8014ff <read>
		if (m < 0)
  8015be:	83 c4 10             	add    $0x10,%esp
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	78 04                	js     8015c9 <readn+0x3f>
			return m;
		if (m == 0)
  8015c5:	75 dd                	jne    8015a4 <readn+0x1a>
  8015c7:	eb 02                	jmp    8015cb <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015c9:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8015cb:	89 d8                	mov    %ebx,%eax
  8015cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d0:	5b                   	pop    %ebx
  8015d1:	5e                   	pop    %esi
  8015d2:	5f                   	pop    %edi
  8015d3:	5d                   	pop    %ebp
  8015d4:	c3                   	ret    

008015d5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015d5:	f3 0f 1e fb          	endbr32 
  8015d9:	55                   	push   %ebp
  8015da:	89 e5                	mov    %esp,%ebp
  8015dc:	53                   	push   %ebx
  8015dd:	83 ec 1c             	sub    $0x1c,%esp
  8015e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e6:	50                   	push   %eax
  8015e7:	53                   	push   %ebx
  8015e8:	e8 8a fc ff ff       	call   801277 <fd_lookup>
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	78 3a                	js     80162e <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f4:	83 ec 08             	sub    $0x8,%esp
  8015f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fa:	50                   	push   %eax
  8015fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fe:	ff 30                	pushl  (%eax)
  801600:	e8 c6 fc ff ff       	call   8012cb <dev_lookup>
  801605:	83 c4 10             	add    $0x10,%esp
  801608:	85 c0                	test   %eax,%eax
  80160a:	78 22                	js     80162e <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80160c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801613:	74 1e                	je     801633 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801615:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801618:	8b 52 0c             	mov    0xc(%edx),%edx
  80161b:	85 d2                	test   %edx,%edx
  80161d:	74 35                	je     801654 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80161f:	83 ec 04             	sub    $0x4,%esp
  801622:	ff 75 10             	pushl  0x10(%ebp)
  801625:	ff 75 0c             	pushl  0xc(%ebp)
  801628:	50                   	push   %eax
  801629:	ff d2                	call   *%edx
  80162b:	83 c4 10             	add    $0x10,%esp
}
  80162e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801631:	c9                   	leave  
  801632:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801633:	a1 18 40 80 00       	mov    0x804018,%eax
  801638:	8b 40 48             	mov    0x48(%eax),%eax
  80163b:	83 ec 04             	sub    $0x4,%esp
  80163e:	53                   	push   %ebx
  80163f:	50                   	push   %eax
  801640:	68 7d 2c 80 00       	push   $0x802c7d
  801645:	e8 9e ef ff ff       	call   8005e8 <cprintf>
		return -E_INVAL;
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801652:	eb da                	jmp    80162e <write+0x59>
		return -E_NOT_SUPP;
  801654:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801659:	eb d3                	jmp    80162e <write+0x59>

0080165b <seek>:

int
seek(int fdnum, off_t offset)
{
  80165b:	f3 0f 1e fb          	endbr32 
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801665:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	ff 75 08             	pushl  0x8(%ebp)
  80166c:	e8 06 fc ff ff       	call   801277 <fd_lookup>
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	85 c0                	test   %eax,%eax
  801676:	78 0e                	js     801686 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801678:	8b 55 0c             	mov    0xc(%ebp),%edx
  80167b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801681:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801686:	c9                   	leave  
  801687:	c3                   	ret    

00801688 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801688:	f3 0f 1e fb          	endbr32 
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	53                   	push   %ebx
  801690:	83 ec 1c             	sub    $0x1c,%esp
  801693:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801696:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801699:	50                   	push   %eax
  80169a:	53                   	push   %ebx
  80169b:	e8 d7 fb ff ff       	call   801277 <fd_lookup>
  8016a0:	83 c4 10             	add    $0x10,%esp
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	78 37                	js     8016de <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a7:	83 ec 08             	sub    $0x8,%esp
  8016aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ad:	50                   	push   %eax
  8016ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b1:	ff 30                	pushl  (%eax)
  8016b3:	e8 13 fc ff ff       	call   8012cb <dev_lookup>
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	78 1f                	js     8016de <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c6:	74 1b                	je     8016e3 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8016c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016cb:	8b 52 18             	mov    0x18(%edx),%edx
  8016ce:	85 d2                	test   %edx,%edx
  8016d0:	74 32                	je     801704 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016d2:	83 ec 08             	sub    $0x8,%esp
  8016d5:	ff 75 0c             	pushl  0xc(%ebp)
  8016d8:	50                   	push   %eax
  8016d9:	ff d2                	call   *%edx
  8016db:	83 c4 10             	add    $0x10,%esp
}
  8016de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e1:	c9                   	leave  
  8016e2:	c3                   	ret    
			thisenv->env_id, fdnum);
  8016e3:	a1 18 40 80 00       	mov    0x804018,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016e8:	8b 40 48             	mov    0x48(%eax),%eax
  8016eb:	83 ec 04             	sub    $0x4,%esp
  8016ee:	53                   	push   %ebx
  8016ef:	50                   	push   %eax
  8016f0:	68 40 2c 80 00       	push   $0x802c40
  8016f5:	e8 ee ee ff ff       	call   8005e8 <cprintf>
		return -E_INVAL;
  8016fa:	83 c4 10             	add    $0x10,%esp
  8016fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801702:	eb da                	jmp    8016de <ftruncate+0x56>
		return -E_NOT_SUPP;
  801704:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801709:	eb d3                	jmp    8016de <ftruncate+0x56>

0080170b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80170b:	f3 0f 1e fb          	endbr32 
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	53                   	push   %ebx
  801713:	83 ec 1c             	sub    $0x1c,%esp
  801716:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801719:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171c:	50                   	push   %eax
  80171d:	ff 75 08             	pushl  0x8(%ebp)
  801720:	e8 52 fb ff ff       	call   801277 <fd_lookup>
  801725:	83 c4 10             	add    $0x10,%esp
  801728:	85 c0                	test   %eax,%eax
  80172a:	78 4b                	js     801777 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172c:	83 ec 08             	sub    $0x8,%esp
  80172f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801732:	50                   	push   %eax
  801733:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801736:	ff 30                	pushl  (%eax)
  801738:	e8 8e fb ff ff       	call   8012cb <dev_lookup>
  80173d:	83 c4 10             	add    $0x10,%esp
  801740:	85 c0                	test   %eax,%eax
  801742:	78 33                	js     801777 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801744:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801747:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80174b:	74 2f                	je     80177c <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80174d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801750:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801757:	00 00 00 
	stat->st_isdir = 0;
  80175a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801761:	00 00 00 
	stat->st_dev = dev;
  801764:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80176a:	83 ec 08             	sub    $0x8,%esp
  80176d:	53                   	push   %ebx
  80176e:	ff 75 f0             	pushl  -0x10(%ebp)
  801771:	ff 50 14             	call   *0x14(%eax)
  801774:	83 c4 10             	add    $0x10,%esp
}
  801777:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177a:	c9                   	leave  
  80177b:	c3                   	ret    
		return -E_NOT_SUPP;
  80177c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801781:	eb f4                	jmp    801777 <fstat+0x6c>

00801783 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801783:	f3 0f 1e fb          	endbr32 
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	56                   	push   %esi
  80178b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80178c:	83 ec 08             	sub    $0x8,%esp
  80178f:	6a 00                	push   $0x0
  801791:	ff 75 08             	pushl  0x8(%ebp)
  801794:	e8 01 02 00 00       	call   80199a <open>
  801799:	89 c3                	mov    %eax,%ebx
  80179b:	83 c4 10             	add    $0x10,%esp
  80179e:	85 c0                	test   %eax,%eax
  8017a0:	78 1b                	js     8017bd <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8017a2:	83 ec 08             	sub    $0x8,%esp
  8017a5:	ff 75 0c             	pushl  0xc(%ebp)
  8017a8:	50                   	push   %eax
  8017a9:	e8 5d ff ff ff       	call   80170b <fstat>
  8017ae:	89 c6                	mov    %eax,%esi
	close(fd);
  8017b0:	89 1c 24             	mov    %ebx,(%esp)
  8017b3:	e8 fd fb ff ff       	call   8013b5 <close>
	return r;
  8017b8:	83 c4 10             	add    $0x10,%esp
  8017bb:	89 f3                	mov    %esi,%ebx
}
  8017bd:	89 d8                	mov    %ebx,%eax
  8017bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c2:	5b                   	pop    %ebx
  8017c3:	5e                   	pop    %esi
  8017c4:	5d                   	pop    %ebp
  8017c5:	c3                   	ret    

008017c6 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	56                   	push   %esi
  8017ca:	53                   	push   %ebx
  8017cb:	89 c6                	mov    %eax,%esi
  8017cd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017cf:	83 3d 10 40 80 00 00 	cmpl   $0x0,0x804010
  8017d6:	74 27                	je     8017ff <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017d8:	6a 07                	push   $0x7
  8017da:	68 00 50 80 00       	push   $0x805000
  8017df:	56                   	push   %esi
  8017e0:	ff 35 10 40 80 00    	pushl  0x804010
  8017e6:	e8 c6 0c 00 00       	call   8024b1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017eb:	83 c4 0c             	add    $0xc,%esp
  8017ee:	6a 00                	push   $0x0
  8017f0:	53                   	push   %ebx
  8017f1:	6a 00                	push   $0x0
  8017f3:	e8 4c 0c 00 00       	call   802444 <ipc_recv>
}
  8017f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017fb:	5b                   	pop    %ebx
  8017fc:	5e                   	pop    %esi
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017ff:	83 ec 0c             	sub    $0xc,%esp
  801802:	6a 01                	push   $0x1
  801804:	e8 00 0d 00 00       	call   802509 <ipc_find_env>
  801809:	a3 10 40 80 00       	mov    %eax,0x804010
  80180e:	83 c4 10             	add    $0x10,%esp
  801811:	eb c5                	jmp    8017d8 <fsipc+0x12>

00801813 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801813:	f3 0f 1e fb          	endbr32 
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80181d:	8b 45 08             	mov    0x8(%ebp),%eax
  801820:	8b 40 0c             	mov    0xc(%eax),%eax
  801823:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801828:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801830:	ba 00 00 00 00       	mov    $0x0,%edx
  801835:	b8 02 00 00 00       	mov    $0x2,%eax
  80183a:	e8 87 ff ff ff       	call   8017c6 <fsipc>
}
  80183f:	c9                   	leave  
  801840:	c3                   	ret    

00801841 <devfile_flush>:
{
  801841:	f3 0f 1e fb          	endbr32 
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80184b:	8b 45 08             	mov    0x8(%ebp),%eax
  80184e:	8b 40 0c             	mov    0xc(%eax),%eax
  801851:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801856:	ba 00 00 00 00       	mov    $0x0,%edx
  80185b:	b8 06 00 00 00       	mov    $0x6,%eax
  801860:	e8 61 ff ff ff       	call   8017c6 <fsipc>
}
  801865:	c9                   	leave  
  801866:	c3                   	ret    

00801867 <devfile_stat>:
{
  801867:	f3 0f 1e fb          	endbr32 
  80186b:	55                   	push   %ebp
  80186c:	89 e5                	mov    %esp,%ebp
  80186e:	53                   	push   %ebx
  80186f:	83 ec 04             	sub    $0x4,%esp
  801872:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801875:	8b 45 08             	mov    0x8(%ebp),%eax
  801878:	8b 40 0c             	mov    0xc(%eax),%eax
  80187b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801880:	ba 00 00 00 00       	mov    $0x0,%edx
  801885:	b8 05 00 00 00       	mov    $0x5,%eax
  80188a:	e8 37 ff ff ff       	call   8017c6 <fsipc>
  80188f:	85 c0                	test   %eax,%eax
  801891:	78 2c                	js     8018bf <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801893:	83 ec 08             	sub    $0x8,%esp
  801896:	68 00 50 80 00       	push   $0x805000
  80189b:	53                   	push   %ebx
  80189c:	e8 51 f3 ff ff       	call   800bf2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018a1:	a1 80 50 80 00       	mov    0x805080,%eax
  8018a6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018ac:	a1 84 50 80 00       	mov    0x805084,%eax
  8018b1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c2:	c9                   	leave  
  8018c3:	c3                   	ret    

008018c4 <devfile_write>:
{
  8018c4:	f3 0f 1e fb          	endbr32 
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	83 ec 0c             	sub    $0xc,%esp
  8018ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8018d1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018d6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018db:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018de:	8b 55 08             	mov    0x8(%ebp),%edx
  8018e1:	8b 52 0c             	mov    0xc(%edx),%edx
  8018e4:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018ea:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018ef:	50                   	push   %eax
  8018f0:	ff 75 0c             	pushl  0xc(%ebp)
  8018f3:	68 08 50 80 00       	push   $0x805008
  8018f8:	e8 f3 f4 ff ff       	call   800df0 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801902:	b8 04 00 00 00       	mov    $0x4,%eax
  801907:	e8 ba fe ff ff       	call   8017c6 <fsipc>
}
  80190c:	c9                   	leave  
  80190d:	c3                   	ret    

0080190e <devfile_read>:
{
  80190e:	f3 0f 1e fb          	endbr32 
  801912:	55                   	push   %ebp
  801913:	89 e5                	mov    %esp,%ebp
  801915:	56                   	push   %esi
  801916:	53                   	push   %ebx
  801917:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80191a:	8b 45 08             	mov    0x8(%ebp),%eax
  80191d:	8b 40 0c             	mov    0xc(%eax),%eax
  801920:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801925:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80192b:	ba 00 00 00 00       	mov    $0x0,%edx
  801930:	b8 03 00 00 00       	mov    $0x3,%eax
  801935:	e8 8c fe ff ff       	call   8017c6 <fsipc>
  80193a:	89 c3                	mov    %eax,%ebx
  80193c:	85 c0                	test   %eax,%eax
  80193e:	78 1f                	js     80195f <devfile_read+0x51>
	assert(r <= n);
  801940:	39 f0                	cmp    %esi,%eax
  801942:	77 24                	ja     801968 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801944:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801949:	7f 36                	jg     801981 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80194b:	83 ec 04             	sub    $0x4,%esp
  80194e:	50                   	push   %eax
  80194f:	68 00 50 80 00       	push   $0x805000
  801954:	ff 75 0c             	pushl  0xc(%ebp)
  801957:	e8 94 f4 ff ff       	call   800df0 <memmove>
	return r;
  80195c:	83 c4 10             	add    $0x10,%esp
}
  80195f:	89 d8                	mov    %ebx,%eax
  801961:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801964:	5b                   	pop    %ebx
  801965:	5e                   	pop    %esi
  801966:	5d                   	pop    %ebp
  801967:	c3                   	ret    
	assert(r <= n);
  801968:	68 b0 2c 80 00       	push   $0x802cb0
  80196d:	68 b7 2c 80 00       	push   $0x802cb7
  801972:	68 8c 00 00 00       	push   $0x8c
  801977:	68 cc 2c 80 00       	push   $0x802ccc
  80197c:	e8 79 0a 00 00       	call   8023fa <_panic>
	assert(r <= PGSIZE);
  801981:	68 d7 2c 80 00       	push   $0x802cd7
  801986:	68 b7 2c 80 00       	push   $0x802cb7
  80198b:	68 8d 00 00 00       	push   $0x8d
  801990:	68 cc 2c 80 00       	push   $0x802ccc
  801995:	e8 60 0a 00 00       	call   8023fa <_panic>

0080199a <open>:
{
  80199a:	f3 0f 1e fb          	endbr32 
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	56                   	push   %esi
  8019a2:	53                   	push   %ebx
  8019a3:	83 ec 1c             	sub    $0x1c,%esp
  8019a6:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8019a9:	56                   	push   %esi
  8019aa:	e8 00 f2 ff ff       	call   800baf <strlen>
  8019af:	83 c4 10             	add    $0x10,%esp
  8019b2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019b7:	7f 6c                	jg     801a25 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8019b9:	83 ec 0c             	sub    $0xc,%esp
  8019bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019bf:	50                   	push   %eax
  8019c0:	e8 5c f8 ff ff       	call   801221 <fd_alloc>
  8019c5:	89 c3                	mov    %eax,%ebx
  8019c7:	83 c4 10             	add    $0x10,%esp
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	78 3c                	js     801a0a <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8019ce:	83 ec 08             	sub    $0x8,%esp
  8019d1:	56                   	push   %esi
  8019d2:	68 00 50 80 00       	push   $0x805000
  8019d7:	e8 16 f2 ff ff       	call   800bf2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019df:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ec:	e8 d5 fd ff ff       	call   8017c6 <fsipc>
  8019f1:	89 c3                	mov    %eax,%ebx
  8019f3:	83 c4 10             	add    $0x10,%esp
  8019f6:	85 c0                	test   %eax,%eax
  8019f8:	78 19                	js     801a13 <open+0x79>
	return fd2num(fd);
  8019fa:	83 ec 0c             	sub    $0xc,%esp
  8019fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801a00:	e8 ed f7 ff ff       	call   8011f2 <fd2num>
  801a05:	89 c3                	mov    %eax,%ebx
  801a07:	83 c4 10             	add    $0x10,%esp
}
  801a0a:	89 d8                	mov    %ebx,%eax
  801a0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0f:	5b                   	pop    %ebx
  801a10:	5e                   	pop    %esi
  801a11:	5d                   	pop    %ebp
  801a12:	c3                   	ret    
		fd_close(fd, 0);
  801a13:	83 ec 08             	sub    $0x8,%esp
  801a16:	6a 00                	push   $0x0
  801a18:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1b:	e8 0a f9 ff ff       	call   80132a <fd_close>
		return r;
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	eb e5                	jmp    801a0a <open+0x70>
		return -E_BAD_PATH;
  801a25:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a2a:	eb de                	jmp    801a0a <open+0x70>

00801a2c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a2c:	f3 0f 1e fb          	endbr32 
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a36:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3b:	b8 08 00 00 00       	mov    $0x8,%eax
  801a40:	e8 81 fd ff ff       	call   8017c6 <fsipc>
}
  801a45:	c9                   	leave  
  801a46:	c3                   	ret    

00801a47 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a47:	f3 0f 1e fb          	endbr32 
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a51:	68 43 2d 80 00       	push   $0x802d43
  801a56:	ff 75 0c             	pushl  0xc(%ebp)
  801a59:	e8 94 f1 ff ff       	call   800bf2 <strcpy>
	return 0;
}
  801a5e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a63:	c9                   	leave  
  801a64:	c3                   	ret    

00801a65 <devsock_close>:
{
  801a65:	f3 0f 1e fb          	endbr32 
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	53                   	push   %ebx
  801a6d:	83 ec 10             	sub    $0x10,%esp
  801a70:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a73:	53                   	push   %ebx
  801a74:	e8 cd 0a 00 00       	call   802546 <pageref>
  801a79:	89 c2                	mov    %eax,%edx
  801a7b:	83 c4 10             	add    $0x10,%esp
		return 0;
  801a7e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801a83:	83 fa 01             	cmp    $0x1,%edx
  801a86:	74 05                	je     801a8d <devsock_close+0x28>
}
  801a88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801a8d:	83 ec 0c             	sub    $0xc,%esp
  801a90:	ff 73 0c             	pushl  0xc(%ebx)
  801a93:	e8 e3 02 00 00       	call   801d7b <nsipc_close>
  801a98:	83 c4 10             	add    $0x10,%esp
  801a9b:	eb eb                	jmp    801a88 <devsock_close+0x23>

00801a9d <devsock_write>:
{
  801a9d:	f3 0f 1e fb          	endbr32 
  801aa1:	55                   	push   %ebp
  801aa2:	89 e5                	mov    %esp,%ebp
  801aa4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801aa7:	6a 00                	push   $0x0
  801aa9:	ff 75 10             	pushl  0x10(%ebp)
  801aac:	ff 75 0c             	pushl  0xc(%ebp)
  801aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab2:	ff 70 0c             	pushl  0xc(%eax)
  801ab5:	e8 b5 03 00 00       	call   801e6f <nsipc_send>
}
  801aba:	c9                   	leave  
  801abb:	c3                   	ret    

00801abc <devsock_read>:
{
  801abc:	f3 0f 1e fb          	endbr32 
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ac6:	6a 00                	push   $0x0
  801ac8:	ff 75 10             	pushl  0x10(%ebp)
  801acb:	ff 75 0c             	pushl  0xc(%ebp)
  801ace:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad1:	ff 70 0c             	pushl  0xc(%eax)
  801ad4:	e8 1f 03 00 00       	call   801df8 <nsipc_recv>
}
  801ad9:	c9                   	leave  
  801ada:	c3                   	ret    

00801adb <fd2sockid>:
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801ae1:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ae4:	52                   	push   %edx
  801ae5:	50                   	push   %eax
  801ae6:	e8 8c f7 ff ff       	call   801277 <fd_lookup>
  801aeb:	83 c4 10             	add    $0x10,%esp
  801aee:	85 c0                	test   %eax,%eax
  801af0:	78 10                	js     801b02 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af5:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  801afb:	39 08                	cmp    %ecx,(%eax)
  801afd:	75 05                	jne    801b04 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801aff:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801b02:	c9                   	leave  
  801b03:	c3                   	ret    
		return -E_NOT_SUPP;
  801b04:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b09:	eb f7                	jmp    801b02 <fd2sockid+0x27>

00801b0b <alloc_sockfd>:
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	56                   	push   %esi
  801b0f:	53                   	push   %ebx
  801b10:	83 ec 1c             	sub    $0x1c,%esp
  801b13:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801b15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b18:	50                   	push   %eax
  801b19:	e8 03 f7 ff ff       	call   801221 <fd_alloc>
  801b1e:	89 c3                	mov    %eax,%ebx
  801b20:	83 c4 10             	add    $0x10,%esp
  801b23:	85 c0                	test   %eax,%eax
  801b25:	78 43                	js     801b6a <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b27:	83 ec 04             	sub    $0x4,%esp
  801b2a:	68 07 04 00 00       	push   $0x407
  801b2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b32:	6a 00                	push   $0x0
  801b34:	e8 22 f5 ff ff       	call   80105b <sys_page_alloc>
  801b39:	89 c3                	mov    %eax,%ebx
  801b3b:	83 c4 10             	add    $0x10,%esp
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	78 28                	js     801b6a <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b45:	8b 15 60 30 80 00    	mov    0x803060,%edx
  801b4b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b50:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b57:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b5a:	83 ec 0c             	sub    $0xc,%esp
  801b5d:	50                   	push   %eax
  801b5e:	e8 8f f6 ff ff       	call   8011f2 <fd2num>
  801b63:	89 c3                	mov    %eax,%ebx
  801b65:	83 c4 10             	add    $0x10,%esp
  801b68:	eb 0c                	jmp    801b76 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801b6a:	83 ec 0c             	sub    $0xc,%esp
  801b6d:	56                   	push   %esi
  801b6e:	e8 08 02 00 00       	call   801d7b <nsipc_close>
		return r;
  801b73:	83 c4 10             	add    $0x10,%esp
}
  801b76:	89 d8                	mov    %ebx,%eax
  801b78:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b7b:	5b                   	pop    %ebx
  801b7c:	5e                   	pop    %esi
  801b7d:	5d                   	pop    %ebp
  801b7e:	c3                   	ret    

00801b7f <accept>:
{
  801b7f:	f3 0f 1e fb          	endbr32 
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b89:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8c:	e8 4a ff ff ff       	call   801adb <fd2sockid>
  801b91:	85 c0                	test   %eax,%eax
  801b93:	78 1b                	js     801bb0 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b95:	83 ec 04             	sub    $0x4,%esp
  801b98:	ff 75 10             	pushl  0x10(%ebp)
  801b9b:	ff 75 0c             	pushl  0xc(%ebp)
  801b9e:	50                   	push   %eax
  801b9f:	e8 22 01 00 00       	call   801cc6 <nsipc_accept>
  801ba4:	83 c4 10             	add    $0x10,%esp
  801ba7:	85 c0                	test   %eax,%eax
  801ba9:	78 05                	js     801bb0 <accept+0x31>
	return alloc_sockfd(r);
  801bab:	e8 5b ff ff ff       	call   801b0b <alloc_sockfd>
}
  801bb0:	c9                   	leave  
  801bb1:	c3                   	ret    

00801bb2 <bind>:
{
  801bb2:	f3 0f 1e fb          	endbr32 
  801bb6:	55                   	push   %ebp
  801bb7:	89 e5                	mov    %esp,%ebp
  801bb9:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbf:	e8 17 ff ff ff       	call   801adb <fd2sockid>
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	78 12                	js     801bda <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801bc8:	83 ec 04             	sub    $0x4,%esp
  801bcb:	ff 75 10             	pushl  0x10(%ebp)
  801bce:	ff 75 0c             	pushl  0xc(%ebp)
  801bd1:	50                   	push   %eax
  801bd2:	e8 45 01 00 00       	call   801d1c <nsipc_bind>
  801bd7:	83 c4 10             	add    $0x10,%esp
}
  801bda:	c9                   	leave  
  801bdb:	c3                   	ret    

00801bdc <shutdown>:
{
  801bdc:	f3 0f 1e fb          	endbr32 
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801be6:	8b 45 08             	mov    0x8(%ebp),%eax
  801be9:	e8 ed fe ff ff       	call   801adb <fd2sockid>
  801bee:	85 c0                	test   %eax,%eax
  801bf0:	78 0f                	js     801c01 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801bf2:	83 ec 08             	sub    $0x8,%esp
  801bf5:	ff 75 0c             	pushl  0xc(%ebp)
  801bf8:	50                   	push   %eax
  801bf9:	e8 57 01 00 00       	call   801d55 <nsipc_shutdown>
  801bfe:	83 c4 10             	add    $0x10,%esp
}
  801c01:	c9                   	leave  
  801c02:	c3                   	ret    

00801c03 <connect>:
{
  801c03:	f3 0f 1e fb          	endbr32 
  801c07:	55                   	push   %ebp
  801c08:	89 e5                	mov    %esp,%ebp
  801c0a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c10:	e8 c6 fe ff ff       	call   801adb <fd2sockid>
  801c15:	85 c0                	test   %eax,%eax
  801c17:	78 12                	js     801c2b <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801c19:	83 ec 04             	sub    $0x4,%esp
  801c1c:	ff 75 10             	pushl  0x10(%ebp)
  801c1f:	ff 75 0c             	pushl  0xc(%ebp)
  801c22:	50                   	push   %eax
  801c23:	e8 71 01 00 00       	call   801d99 <nsipc_connect>
  801c28:	83 c4 10             	add    $0x10,%esp
}
  801c2b:	c9                   	leave  
  801c2c:	c3                   	ret    

00801c2d <listen>:
{
  801c2d:	f3 0f 1e fb          	endbr32 
  801c31:	55                   	push   %ebp
  801c32:	89 e5                	mov    %esp,%ebp
  801c34:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c37:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3a:	e8 9c fe ff ff       	call   801adb <fd2sockid>
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	78 0f                	js     801c52 <listen+0x25>
	return nsipc_listen(r, backlog);
  801c43:	83 ec 08             	sub    $0x8,%esp
  801c46:	ff 75 0c             	pushl  0xc(%ebp)
  801c49:	50                   	push   %eax
  801c4a:	e8 83 01 00 00       	call   801dd2 <nsipc_listen>
  801c4f:	83 c4 10             	add    $0x10,%esp
}
  801c52:	c9                   	leave  
  801c53:	c3                   	ret    

00801c54 <socket>:

int
socket(int domain, int type, int protocol)
{
  801c54:	f3 0f 1e fb          	endbr32 
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c5e:	ff 75 10             	pushl  0x10(%ebp)
  801c61:	ff 75 0c             	pushl  0xc(%ebp)
  801c64:	ff 75 08             	pushl  0x8(%ebp)
  801c67:	e8 65 02 00 00       	call   801ed1 <nsipc_socket>
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	78 05                	js     801c78 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801c73:	e8 93 fe ff ff       	call   801b0b <alloc_sockfd>
}
  801c78:	c9                   	leave  
  801c79:	c3                   	ret    

00801c7a <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	53                   	push   %ebx
  801c7e:	83 ec 04             	sub    $0x4,%esp
  801c81:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c83:	83 3d 14 40 80 00 00 	cmpl   $0x0,0x804014
  801c8a:	74 26                	je     801cb2 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c8c:	6a 07                	push   $0x7
  801c8e:	68 00 60 80 00       	push   $0x806000
  801c93:	53                   	push   %ebx
  801c94:	ff 35 14 40 80 00    	pushl  0x804014
  801c9a:	e8 12 08 00 00       	call   8024b1 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c9f:	83 c4 0c             	add    $0xc,%esp
  801ca2:	6a 00                	push   $0x0
  801ca4:	6a 00                	push   $0x0
  801ca6:	6a 00                	push   $0x0
  801ca8:	e8 97 07 00 00       	call   802444 <ipc_recv>
}
  801cad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cb0:	c9                   	leave  
  801cb1:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801cb2:	83 ec 0c             	sub    $0xc,%esp
  801cb5:	6a 02                	push   $0x2
  801cb7:	e8 4d 08 00 00       	call   802509 <ipc_find_env>
  801cbc:	a3 14 40 80 00       	mov    %eax,0x804014
  801cc1:	83 c4 10             	add    $0x10,%esp
  801cc4:	eb c6                	jmp    801c8c <nsipc+0x12>

00801cc6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cc6:	f3 0f 1e fb          	endbr32 
  801cca:	55                   	push   %ebp
  801ccb:	89 e5                	mov    %esp,%ebp
  801ccd:	56                   	push   %esi
  801cce:	53                   	push   %ebx
  801ccf:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801cda:	8b 06                	mov    (%esi),%eax
  801cdc:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ce1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce6:	e8 8f ff ff ff       	call   801c7a <nsipc>
  801ceb:	89 c3                	mov    %eax,%ebx
  801ced:	85 c0                	test   %eax,%eax
  801cef:	79 09                	jns    801cfa <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801cf1:	89 d8                	mov    %ebx,%eax
  801cf3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf6:	5b                   	pop    %ebx
  801cf7:	5e                   	pop    %esi
  801cf8:	5d                   	pop    %ebp
  801cf9:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cfa:	83 ec 04             	sub    $0x4,%esp
  801cfd:	ff 35 10 60 80 00    	pushl  0x806010
  801d03:	68 00 60 80 00       	push   $0x806000
  801d08:	ff 75 0c             	pushl  0xc(%ebp)
  801d0b:	e8 e0 f0 ff ff       	call   800df0 <memmove>
		*addrlen = ret->ret_addrlen;
  801d10:	a1 10 60 80 00       	mov    0x806010,%eax
  801d15:	89 06                	mov    %eax,(%esi)
  801d17:	83 c4 10             	add    $0x10,%esp
	return r;
  801d1a:	eb d5                	jmp    801cf1 <nsipc_accept+0x2b>

00801d1c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d1c:	f3 0f 1e fb          	endbr32 
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	53                   	push   %ebx
  801d24:	83 ec 08             	sub    $0x8,%esp
  801d27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d32:	53                   	push   %ebx
  801d33:	ff 75 0c             	pushl  0xc(%ebp)
  801d36:	68 04 60 80 00       	push   $0x806004
  801d3b:	e8 b0 f0 ff ff       	call   800df0 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d40:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d46:	b8 02 00 00 00       	mov    $0x2,%eax
  801d4b:	e8 2a ff ff ff       	call   801c7a <nsipc>
}
  801d50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d53:	c9                   	leave  
  801d54:	c3                   	ret    

00801d55 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d55:	f3 0f 1e fb          	endbr32 
  801d59:	55                   	push   %ebp
  801d5a:	89 e5                	mov    %esp,%ebp
  801d5c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d62:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d67:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d6a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d6f:	b8 03 00 00 00       	mov    $0x3,%eax
  801d74:	e8 01 ff ff ff       	call   801c7a <nsipc>
}
  801d79:	c9                   	leave  
  801d7a:	c3                   	ret    

00801d7b <nsipc_close>:

int
nsipc_close(int s)
{
  801d7b:	f3 0f 1e fb          	endbr32 
  801d7f:	55                   	push   %ebp
  801d80:	89 e5                	mov    %esp,%ebp
  801d82:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d85:	8b 45 08             	mov    0x8(%ebp),%eax
  801d88:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d8d:	b8 04 00 00 00       	mov    $0x4,%eax
  801d92:	e8 e3 fe ff ff       	call   801c7a <nsipc>
}
  801d97:	c9                   	leave  
  801d98:	c3                   	ret    

00801d99 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d99:	f3 0f 1e fb          	endbr32 
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	53                   	push   %ebx
  801da1:	83 ec 08             	sub    $0x8,%esp
  801da4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801da7:	8b 45 08             	mov    0x8(%ebp),%eax
  801daa:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801daf:	53                   	push   %ebx
  801db0:	ff 75 0c             	pushl  0xc(%ebp)
  801db3:	68 04 60 80 00       	push   $0x806004
  801db8:	e8 33 f0 ff ff       	call   800df0 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801dbd:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801dc3:	b8 05 00 00 00       	mov    $0x5,%eax
  801dc8:	e8 ad fe ff ff       	call   801c7a <nsipc>
}
  801dcd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dd0:	c9                   	leave  
  801dd1:	c3                   	ret    

00801dd2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801dd2:	f3 0f 1e fb          	endbr32 
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801de4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801dec:	b8 06 00 00 00       	mov    $0x6,%eax
  801df1:	e8 84 fe ff ff       	call   801c7a <nsipc>
}
  801df6:	c9                   	leave  
  801df7:	c3                   	ret    

00801df8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801df8:	f3 0f 1e fb          	endbr32 
  801dfc:	55                   	push   %ebp
  801dfd:	89 e5                	mov    %esp,%ebp
  801dff:	56                   	push   %esi
  801e00:	53                   	push   %ebx
  801e01:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e04:	8b 45 08             	mov    0x8(%ebp),%eax
  801e07:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e0c:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e12:	8b 45 14             	mov    0x14(%ebp),%eax
  801e15:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e1a:	b8 07 00 00 00       	mov    $0x7,%eax
  801e1f:	e8 56 fe ff ff       	call   801c7a <nsipc>
  801e24:	89 c3                	mov    %eax,%ebx
  801e26:	85 c0                	test   %eax,%eax
  801e28:	78 26                	js     801e50 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801e2a:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801e30:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801e35:	0f 4e c6             	cmovle %esi,%eax
  801e38:	39 c3                	cmp    %eax,%ebx
  801e3a:	7f 1d                	jg     801e59 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e3c:	83 ec 04             	sub    $0x4,%esp
  801e3f:	53                   	push   %ebx
  801e40:	68 00 60 80 00       	push   $0x806000
  801e45:	ff 75 0c             	pushl  0xc(%ebp)
  801e48:	e8 a3 ef ff ff       	call   800df0 <memmove>
  801e4d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e50:	89 d8                	mov    %ebx,%eax
  801e52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e55:	5b                   	pop    %ebx
  801e56:	5e                   	pop    %esi
  801e57:	5d                   	pop    %ebp
  801e58:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801e59:	68 4f 2d 80 00       	push   $0x802d4f
  801e5e:	68 b7 2c 80 00       	push   $0x802cb7
  801e63:	6a 62                	push   $0x62
  801e65:	68 64 2d 80 00       	push   $0x802d64
  801e6a:	e8 8b 05 00 00       	call   8023fa <_panic>

00801e6f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e6f:	f3 0f 1e fb          	endbr32 
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	53                   	push   %ebx
  801e77:	83 ec 04             	sub    $0x4,%esp
  801e7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e80:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e85:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e8b:	7f 2e                	jg     801ebb <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e8d:	83 ec 04             	sub    $0x4,%esp
  801e90:	53                   	push   %ebx
  801e91:	ff 75 0c             	pushl  0xc(%ebp)
  801e94:	68 0c 60 80 00       	push   $0x80600c
  801e99:	e8 52 ef ff ff       	call   800df0 <memmove>
	nsipcbuf.send.req_size = size;
  801e9e:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ea4:	8b 45 14             	mov    0x14(%ebp),%eax
  801ea7:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801eac:	b8 08 00 00 00       	mov    $0x8,%eax
  801eb1:	e8 c4 fd ff ff       	call   801c7a <nsipc>
}
  801eb6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eb9:	c9                   	leave  
  801eba:	c3                   	ret    
	assert(size < 1600);
  801ebb:	68 70 2d 80 00       	push   $0x802d70
  801ec0:	68 b7 2c 80 00       	push   $0x802cb7
  801ec5:	6a 6d                	push   $0x6d
  801ec7:	68 64 2d 80 00       	push   $0x802d64
  801ecc:	e8 29 05 00 00       	call   8023fa <_panic>

00801ed1 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ed1:	f3 0f 1e fb          	endbr32 
  801ed5:	55                   	push   %ebp
  801ed6:	89 e5                	mov    %esp,%ebp
  801ed8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801edb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ede:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ee3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee6:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801eeb:	8b 45 10             	mov    0x10(%ebp),%eax
  801eee:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ef3:	b8 09 00 00 00       	mov    $0x9,%eax
  801ef8:	e8 7d fd ff ff       	call   801c7a <nsipc>
}
  801efd:	c9                   	leave  
  801efe:	c3                   	ret    

00801eff <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801eff:	f3 0f 1e fb          	endbr32 
  801f03:	55                   	push   %ebp
  801f04:	89 e5                	mov    %esp,%ebp
  801f06:	56                   	push   %esi
  801f07:	53                   	push   %ebx
  801f08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f0b:	83 ec 0c             	sub    $0xc,%esp
  801f0e:	ff 75 08             	pushl  0x8(%ebp)
  801f11:	e8 f0 f2 ff ff       	call   801206 <fd2data>
  801f16:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f18:	83 c4 08             	add    $0x8,%esp
  801f1b:	68 7c 2d 80 00       	push   $0x802d7c
  801f20:	53                   	push   %ebx
  801f21:	e8 cc ec ff ff       	call   800bf2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f26:	8b 46 04             	mov    0x4(%esi),%eax
  801f29:	2b 06                	sub    (%esi),%eax
  801f2b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f31:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f38:	00 00 00 
	stat->st_dev = &devpipe;
  801f3b:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801f42:	30 80 00 
	return 0;
}
  801f45:	b8 00 00 00 00       	mov    $0x0,%eax
  801f4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f4d:	5b                   	pop    %ebx
  801f4e:	5e                   	pop    %esi
  801f4f:	5d                   	pop    %ebp
  801f50:	c3                   	ret    

00801f51 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f51:	f3 0f 1e fb          	endbr32 
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	53                   	push   %ebx
  801f59:	83 ec 0c             	sub    $0xc,%esp
  801f5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f5f:	53                   	push   %ebx
  801f60:	6a 00                	push   $0x0
  801f62:	e8 3f f1 ff ff       	call   8010a6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f67:	89 1c 24             	mov    %ebx,(%esp)
  801f6a:	e8 97 f2 ff ff       	call   801206 <fd2data>
  801f6f:	83 c4 08             	add    $0x8,%esp
  801f72:	50                   	push   %eax
  801f73:	6a 00                	push   $0x0
  801f75:	e8 2c f1 ff ff       	call   8010a6 <sys_page_unmap>
}
  801f7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f7d:	c9                   	leave  
  801f7e:	c3                   	ret    

00801f7f <_pipeisclosed>:
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	57                   	push   %edi
  801f83:	56                   	push   %esi
  801f84:	53                   	push   %ebx
  801f85:	83 ec 1c             	sub    $0x1c,%esp
  801f88:	89 c7                	mov    %eax,%edi
  801f8a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801f8c:	a1 18 40 80 00       	mov    0x804018,%eax
  801f91:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f94:	83 ec 0c             	sub    $0xc,%esp
  801f97:	57                   	push   %edi
  801f98:	e8 a9 05 00 00       	call   802546 <pageref>
  801f9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801fa0:	89 34 24             	mov    %esi,(%esp)
  801fa3:	e8 9e 05 00 00       	call   802546 <pageref>
		nn = thisenv->env_runs;
  801fa8:	8b 15 18 40 80 00    	mov    0x804018,%edx
  801fae:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fb1:	83 c4 10             	add    $0x10,%esp
  801fb4:	39 cb                	cmp    %ecx,%ebx
  801fb6:	74 1b                	je     801fd3 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801fb8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801fbb:	75 cf                	jne    801f8c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fbd:	8b 42 58             	mov    0x58(%edx),%eax
  801fc0:	6a 01                	push   $0x1
  801fc2:	50                   	push   %eax
  801fc3:	53                   	push   %ebx
  801fc4:	68 83 2d 80 00       	push   $0x802d83
  801fc9:	e8 1a e6 ff ff       	call   8005e8 <cprintf>
  801fce:	83 c4 10             	add    $0x10,%esp
  801fd1:	eb b9                	jmp    801f8c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801fd3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801fd6:	0f 94 c0             	sete   %al
  801fd9:	0f b6 c0             	movzbl %al,%eax
}
  801fdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fdf:	5b                   	pop    %ebx
  801fe0:	5e                   	pop    %esi
  801fe1:	5f                   	pop    %edi
  801fe2:	5d                   	pop    %ebp
  801fe3:	c3                   	ret    

00801fe4 <devpipe_write>:
{
  801fe4:	f3 0f 1e fb          	endbr32 
  801fe8:	55                   	push   %ebp
  801fe9:	89 e5                	mov    %esp,%ebp
  801feb:	57                   	push   %edi
  801fec:	56                   	push   %esi
  801fed:	53                   	push   %ebx
  801fee:	83 ec 28             	sub    $0x28,%esp
  801ff1:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ff4:	56                   	push   %esi
  801ff5:	e8 0c f2 ff ff       	call   801206 <fd2data>
  801ffa:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ffc:	83 c4 10             	add    $0x10,%esp
  801fff:	bf 00 00 00 00       	mov    $0x0,%edi
  802004:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802007:	74 4f                	je     802058 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802009:	8b 43 04             	mov    0x4(%ebx),%eax
  80200c:	8b 0b                	mov    (%ebx),%ecx
  80200e:	8d 51 20             	lea    0x20(%ecx),%edx
  802011:	39 d0                	cmp    %edx,%eax
  802013:	72 14                	jb     802029 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  802015:	89 da                	mov    %ebx,%edx
  802017:	89 f0                	mov    %esi,%eax
  802019:	e8 61 ff ff ff       	call   801f7f <_pipeisclosed>
  80201e:	85 c0                	test   %eax,%eax
  802020:	75 3b                	jne    80205d <devpipe_write+0x79>
			sys_yield();
  802022:	e8 11 f0 ff ff       	call   801038 <sys_yield>
  802027:	eb e0                	jmp    802009 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802029:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80202c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802030:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802033:	89 c2                	mov    %eax,%edx
  802035:	c1 fa 1f             	sar    $0x1f,%edx
  802038:	89 d1                	mov    %edx,%ecx
  80203a:	c1 e9 1b             	shr    $0x1b,%ecx
  80203d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802040:	83 e2 1f             	and    $0x1f,%edx
  802043:	29 ca                	sub    %ecx,%edx
  802045:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802049:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80204d:	83 c0 01             	add    $0x1,%eax
  802050:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802053:	83 c7 01             	add    $0x1,%edi
  802056:	eb ac                	jmp    802004 <devpipe_write+0x20>
	return i;
  802058:	8b 45 10             	mov    0x10(%ebp),%eax
  80205b:	eb 05                	jmp    802062 <devpipe_write+0x7e>
				return 0;
  80205d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802062:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802065:	5b                   	pop    %ebx
  802066:	5e                   	pop    %esi
  802067:	5f                   	pop    %edi
  802068:	5d                   	pop    %ebp
  802069:	c3                   	ret    

0080206a <devpipe_read>:
{
  80206a:	f3 0f 1e fb          	endbr32 
  80206e:	55                   	push   %ebp
  80206f:	89 e5                	mov    %esp,%ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 18             	sub    $0x18,%esp
  802077:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80207a:	57                   	push   %edi
  80207b:	e8 86 f1 ff ff       	call   801206 <fd2data>
  802080:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802082:	83 c4 10             	add    $0x10,%esp
  802085:	be 00 00 00 00       	mov    $0x0,%esi
  80208a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80208d:	75 14                	jne    8020a3 <devpipe_read+0x39>
	return i;
  80208f:	8b 45 10             	mov    0x10(%ebp),%eax
  802092:	eb 02                	jmp    802096 <devpipe_read+0x2c>
				return i;
  802094:	89 f0                	mov    %esi,%eax
}
  802096:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802099:	5b                   	pop    %ebx
  80209a:	5e                   	pop    %esi
  80209b:	5f                   	pop    %edi
  80209c:	5d                   	pop    %ebp
  80209d:	c3                   	ret    
			sys_yield();
  80209e:	e8 95 ef ff ff       	call   801038 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8020a3:	8b 03                	mov    (%ebx),%eax
  8020a5:	3b 43 04             	cmp    0x4(%ebx),%eax
  8020a8:	75 18                	jne    8020c2 <devpipe_read+0x58>
			if (i > 0)
  8020aa:	85 f6                	test   %esi,%esi
  8020ac:	75 e6                	jne    802094 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8020ae:	89 da                	mov    %ebx,%edx
  8020b0:	89 f8                	mov    %edi,%eax
  8020b2:	e8 c8 fe ff ff       	call   801f7f <_pipeisclosed>
  8020b7:	85 c0                	test   %eax,%eax
  8020b9:	74 e3                	je     80209e <devpipe_read+0x34>
				return 0;
  8020bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c0:	eb d4                	jmp    802096 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020c2:	99                   	cltd   
  8020c3:	c1 ea 1b             	shr    $0x1b,%edx
  8020c6:	01 d0                	add    %edx,%eax
  8020c8:	83 e0 1f             	and    $0x1f,%eax
  8020cb:	29 d0                	sub    %edx,%eax
  8020cd:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8020d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020d5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8020d8:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8020db:	83 c6 01             	add    $0x1,%esi
  8020de:	eb aa                	jmp    80208a <devpipe_read+0x20>

008020e0 <pipe>:
{
  8020e0:	f3 0f 1e fb          	endbr32 
  8020e4:	55                   	push   %ebp
  8020e5:	89 e5                	mov    %esp,%ebp
  8020e7:	56                   	push   %esi
  8020e8:	53                   	push   %ebx
  8020e9:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8020ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ef:	50                   	push   %eax
  8020f0:	e8 2c f1 ff ff       	call   801221 <fd_alloc>
  8020f5:	89 c3                	mov    %eax,%ebx
  8020f7:	83 c4 10             	add    $0x10,%esp
  8020fa:	85 c0                	test   %eax,%eax
  8020fc:	0f 88 23 01 00 00    	js     802225 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802102:	83 ec 04             	sub    $0x4,%esp
  802105:	68 07 04 00 00       	push   $0x407
  80210a:	ff 75 f4             	pushl  -0xc(%ebp)
  80210d:	6a 00                	push   $0x0
  80210f:	e8 47 ef ff ff       	call   80105b <sys_page_alloc>
  802114:	89 c3                	mov    %eax,%ebx
  802116:	83 c4 10             	add    $0x10,%esp
  802119:	85 c0                	test   %eax,%eax
  80211b:	0f 88 04 01 00 00    	js     802225 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  802121:	83 ec 0c             	sub    $0xc,%esp
  802124:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802127:	50                   	push   %eax
  802128:	e8 f4 f0 ff ff       	call   801221 <fd_alloc>
  80212d:	89 c3                	mov    %eax,%ebx
  80212f:	83 c4 10             	add    $0x10,%esp
  802132:	85 c0                	test   %eax,%eax
  802134:	0f 88 db 00 00 00    	js     802215 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80213a:	83 ec 04             	sub    $0x4,%esp
  80213d:	68 07 04 00 00       	push   $0x407
  802142:	ff 75 f0             	pushl  -0x10(%ebp)
  802145:	6a 00                	push   $0x0
  802147:	e8 0f ef ff ff       	call   80105b <sys_page_alloc>
  80214c:	89 c3                	mov    %eax,%ebx
  80214e:	83 c4 10             	add    $0x10,%esp
  802151:	85 c0                	test   %eax,%eax
  802153:	0f 88 bc 00 00 00    	js     802215 <pipe+0x135>
	va = fd2data(fd0);
  802159:	83 ec 0c             	sub    $0xc,%esp
  80215c:	ff 75 f4             	pushl  -0xc(%ebp)
  80215f:	e8 a2 f0 ff ff       	call   801206 <fd2data>
  802164:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802166:	83 c4 0c             	add    $0xc,%esp
  802169:	68 07 04 00 00       	push   $0x407
  80216e:	50                   	push   %eax
  80216f:	6a 00                	push   $0x0
  802171:	e8 e5 ee ff ff       	call   80105b <sys_page_alloc>
  802176:	89 c3                	mov    %eax,%ebx
  802178:	83 c4 10             	add    $0x10,%esp
  80217b:	85 c0                	test   %eax,%eax
  80217d:	0f 88 82 00 00 00    	js     802205 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802183:	83 ec 0c             	sub    $0xc,%esp
  802186:	ff 75 f0             	pushl  -0x10(%ebp)
  802189:	e8 78 f0 ff ff       	call   801206 <fd2data>
  80218e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802195:	50                   	push   %eax
  802196:	6a 00                	push   $0x0
  802198:	56                   	push   %esi
  802199:	6a 00                	push   $0x0
  80219b:	e8 e1 ee ff ff       	call   801081 <sys_page_map>
  8021a0:	89 c3                	mov    %eax,%ebx
  8021a2:	83 c4 20             	add    $0x20,%esp
  8021a5:	85 c0                	test   %eax,%eax
  8021a7:	78 4e                	js     8021f7 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8021a9:	a1 7c 30 80 00       	mov    0x80307c,%eax
  8021ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021b1:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8021b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021b6:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8021bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021c0:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8021c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021c5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8021cc:	83 ec 0c             	sub    $0xc,%esp
  8021cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8021d2:	e8 1b f0 ff ff       	call   8011f2 <fd2num>
  8021d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021da:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021dc:	83 c4 04             	add    $0x4,%esp
  8021df:	ff 75 f0             	pushl  -0x10(%ebp)
  8021e2:	e8 0b f0 ff ff       	call   8011f2 <fd2num>
  8021e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021ea:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021ed:	83 c4 10             	add    $0x10,%esp
  8021f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021f5:	eb 2e                	jmp    802225 <pipe+0x145>
	sys_page_unmap(0, va);
  8021f7:	83 ec 08             	sub    $0x8,%esp
  8021fa:	56                   	push   %esi
  8021fb:	6a 00                	push   $0x0
  8021fd:	e8 a4 ee ff ff       	call   8010a6 <sys_page_unmap>
  802202:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802205:	83 ec 08             	sub    $0x8,%esp
  802208:	ff 75 f0             	pushl  -0x10(%ebp)
  80220b:	6a 00                	push   $0x0
  80220d:	e8 94 ee ff ff       	call   8010a6 <sys_page_unmap>
  802212:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802215:	83 ec 08             	sub    $0x8,%esp
  802218:	ff 75 f4             	pushl  -0xc(%ebp)
  80221b:	6a 00                	push   $0x0
  80221d:	e8 84 ee ff ff       	call   8010a6 <sys_page_unmap>
  802222:	83 c4 10             	add    $0x10,%esp
}
  802225:	89 d8                	mov    %ebx,%eax
  802227:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80222a:	5b                   	pop    %ebx
  80222b:	5e                   	pop    %esi
  80222c:	5d                   	pop    %ebp
  80222d:	c3                   	ret    

0080222e <pipeisclosed>:
{
  80222e:	f3 0f 1e fb          	endbr32 
  802232:	55                   	push   %ebp
  802233:	89 e5                	mov    %esp,%ebp
  802235:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802238:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80223b:	50                   	push   %eax
  80223c:	ff 75 08             	pushl  0x8(%ebp)
  80223f:	e8 33 f0 ff ff       	call   801277 <fd_lookup>
  802244:	83 c4 10             	add    $0x10,%esp
  802247:	85 c0                	test   %eax,%eax
  802249:	78 18                	js     802263 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  80224b:	83 ec 0c             	sub    $0xc,%esp
  80224e:	ff 75 f4             	pushl  -0xc(%ebp)
  802251:	e8 b0 ef ff ff       	call   801206 <fd2data>
  802256:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802258:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80225b:	e8 1f fd ff ff       	call   801f7f <_pipeisclosed>
  802260:	83 c4 10             	add    $0x10,%esp
}
  802263:	c9                   	leave  
  802264:	c3                   	ret    

00802265 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802265:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  802269:	b8 00 00 00 00       	mov    $0x0,%eax
  80226e:	c3                   	ret    

0080226f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80226f:	f3 0f 1e fb          	endbr32 
  802273:	55                   	push   %ebp
  802274:	89 e5                	mov    %esp,%ebp
  802276:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802279:	68 9b 2d 80 00       	push   $0x802d9b
  80227e:	ff 75 0c             	pushl  0xc(%ebp)
  802281:	e8 6c e9 ff ff       	call   800bf2 <strcpy>
	return 0;
}
  802286:	b8 00 00 00 00       	mov    $0x0,%eax
  80228b:	c9                   	leave  
  80228c:	c3                   	ret    

0080228d <devcons_write>:
{
  80228d:	f3 0f 1e fb          	endbr32 
  802291:	55                   	push   %ebp
  802292:	89 e5                	mov    %esp,%ebp
  802294:	57                   	push   %edi
  802295:	56                   	push   %esi
  802296:	53                   	push   %ebx
  802297:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80229d:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8022a2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8022a8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022ab:	73 31                	jae    8022de <devcons_write+0x51>
		m = n - tot;
  8022ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022b0:	29 f3                	sub    %esi,%ebx
  8022b2:	83 fb 7f             	cmp    $0x7f,%ebx
  8022b5:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8022ba:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8022bd:	83 ec 04             	sub    $0x4,%esp
  8022c0:	53                   	push   %ebx
  8022c1:	89 f0                	mov    %esi,%eax
  8022c3:	03 45 0c             	add    0xc(%ebp),%eax
  8022c6:	50                   	push   %eax
  8022c7:	57                   	push   %edi
  8022c8:	e8 23 eb ff ff       	call   800df0 <memmove>
		sys_cputs(buf, m);
  8022cd:	83 c4 08             	add    $0x8,%esp
  8022d0:	53                   	push   %ebx
  8022d1:	57                   	push   %edi
  8022d2:	e8 d5 ec ff ff       	call   800fac <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8022d7:	01 de                	add    %ebx,%esi
  8022d9:	83 c4 10             	add    $0x10,%esp
  8022dc:	eb ca                	jmp    8022a8 <devcons_write+0x1b>
}
  8022de:	89 f0                	mov    %esi,%eax
  8022e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022e3:	5b                   	pop    %ebx
  8022e4:	5e                   	pop    %esi
  8022e5:	5f                   	pop    %edi
  8022e6:	5d                   	pop    %ebp
  8022e7:	c3                   	ret    

008022e8 <devcons_read>:
{
  8022e8:	f3 0f 1e fb          	endbr32 
  8022ec:	55                   	push   %ebp
  8022ed:	89 e5                	mov    %esp,%ebp
  8022ef:	83 ec 08             	sub    $0x8,%esp
  8022f2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8022f7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022fb:	74 21                	je     80231e <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8022fd:	e8 cc ec ff ff       	call   800fce <sys_cgetc>
  802302:	85 c0                	test   %eax,%eax
  802304:	75 07                	jne    80230d <devcons_read+0x25>
		sys_yield();
  802306:	e8 2d ed ff ff       	call   801038 <sys_yield>
  80230b:	eb f0                	jmp    8022fd <devcons_read+0x15>
	if (c < 0)
  80230d:	78 0f                	js     80231e <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  80230f:	83 f8 04             	cmp    $0x4,%eax
  802312:	74 0c                	je     802320 <devcons_read+0x38>
	*(char*)vbuf = c;
  802314:	8b 55 0c             	mov    0xc(%ebp),%edx
  802317:	88 02                	mov    %al,(%edx)
	return 1;
  802319:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80231e:	c9                   	leave  
  80231f:	c3                   	ret    
		return 0;
  802320:	b8 00 00 00 00       	mov    $0x0,%eax
  802325:	eb f7                	jmp    80231e <devcons_read+0x36>

00802327 <cputchar>:
{
  802327:	f3 0f 1e fb          	endbr32 
  80232b:	55                   	push   %ebp
  80232c:	89 e5                	mov    %esp,%ebp
  80232e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802331:	8b 45 08             	mov    0x8(%ebp),%eax
  802334:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802337:	6a 01                	push   $0x1
  802339:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80233c:	50                   	push   %eax
  80233d:	e8 6a ec ff ff       	call   800fac <sys_cputs>
}
  802342:	83 c4 10             	add    $0x10,%esp
  802345:	c9                   	leave  
  802346:	c3                   	ret    

00802347 <getchar>:
{
  802347:	f3 0f 1e fb          	endbr32 
  80234b:	55                   	push   %ebp
  80234c:	89 e5                	mov    %esp,%ebp
  80234e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802351:	6a 01                	push   $0x1
  802353:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802356:	50                   	push   %eax
  802357:	6a 00                	push   $0x0
  802359:	e8 a1 f1 ff ff       	call   8014ff <read>
	if (r < 0)
  80235e:	83 c4 10             	add    $0x10,%esp
  802361:	85 c0                	test   %eax,%eax
  802363:	78 06                	js     80236b <getchar+0x24>
	if (r < 1)
  802365:	74 06                	je     80236d <getchar+0x26>
	return c;
  802367:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80236b:	c9                   	leave  
  80236c:	c3                   	ret    
		return -E_EOF;
  80236d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802372:	eb f7                	jmp    80236b <getchar+0x24>

00802374 <iscons>:
{
  802374:	f3 0f 1e fb          	endbr32 
  802378:	55                   	push   %ebp
  802379:	89 e5                	mov    %esp,%ebp
  80237b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80237e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802381:	50                   	push   %eax
  802382:	ff 75 08             	pushl  0x8(%ebp)
  802385:	e8 ed ee ff ff       	call   801277 <fd_lookup>
  80238a:	83 c4 10             	add    $0x10,%esp
  80238d:	85 c0                	test   %eax,%eax
  80238f:	78 11                	js     8023a2 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  802391:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802394:	8b 15 98 30 80 00    	mov    0x803098,%edx
  80239a:	39 10                	cmp    %edx,(%eax)
  80239c:	0f 94 c0             	sete   %al
  80239f:	0f b6 c0             	movzbl %al,%eax
}
  8023a2:	c9                   	leave  
  8023a3:	c3                   	ret    

008023a4 <opencons>:
{
  8023a4:	f3 0f 1e fb          	endbr32 
  8023a8:	55                   	push   %ebp
  8023a9:	89 e5                	mov    %esp,%ebp
  8023ab:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8023ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023b1:	50                   	push   %eax
  8023b2:	e8 6a ee ff ff       	call   801221 <fd_alloc>
  8023b7:	83 c4 10             	add    $0x10,%esp
  8023ba:	85 c0                	test   %eax,%eax
  8023bc:	78 3a                	js     8023f8 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023be:	83 ec 04             	sub    $0x4,%esp
  8023c1:	68 07 04 00 00       	push   $0x407
  8023c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8023c9:	6a 00                	push   $0x0
  8023cb:	e8 8b ec ff ff       	call   80105b <sys_page_alloc>
  8023d0:	83 c4 10             	add    $0x10,%esp
  8023d3:	85 c0                	test   %eax,%eax
  8023d5:	78 21                	js     8023f8 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8023d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023da:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8023e0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023e5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023ec:	83 ec 0c             	sub    $0xc,%esp
  8023ef:	50                   	push   %eax
  8023f0:	e8 fd ed ff ff       	call   8011f2 <fd2num>
  8023f5:	83 c4 10             	add    $0x10,%esp
}
  8023f8:	c9                   	leave  
  8023f9:	c3                   	ret    

008023fa <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8023fa:	f3 0f 1e fb          	endbr32 
  8023fe:	55                   	push   %ebp
  8023ff:	89 e5                	mov    %esp,%ebp
  802401:	56                   	push   %esi
  802402:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802403:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802406:	8b 35 04 30 80 00    	mov    0x803004,%esi
  80240c:	e8 04 ec ff ff       	call   801015 <sys_getenvid>
  802411:	83 ec 0c             	sub    $0xc,%esp
  802414:	ff 75 0c             	pushl  0xc(%ebp)
  802417:	ff 75 08             	pushl  0x8(%ebp)
  80241a:	56                   	push   %esi
  80241b:	50                   	push   %eax
  80241c:	68 a8 2d 80 00       	push   $0x802da8
  802421:	e8 c2 e1 ff ff       	call   8005e8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802426:	83 c4 18             	add    $0x18,%esp
  802429:	53                   	push   %ebx
  80242a:	ff 75 10             	pushl  0x10(%ebp)
  80242d:	e8 61 e1 ff ff       	call   800593 <vcprintf>
	cprintf("\n");
  802432:	c7 04 24 b4 28 80 00 	movl   $0x8028b4,(%esp)
  802439:	e8 aa e1 ff ff       	call   8005e8 <cprintf>
  80243e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802441:	cc                   	int3   
  802442:	eb fd                	jmp    802441 <_panic+0x47>

00802444 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802444:	f3 0f 1e fb          	endbr32 
  802448:	55                   	push   %ebp
  802449:	89 e5                	mov    %esp,%ebp
  80244b:	56                   	push   %esi
  80244c:	53                   	push   %ebx
  80244d:	8b 75 08             	mov    0x8(%ebp),%esi
  802450:	8b 45 0c             	mov    0xc(%ebp),%eax
  802453:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  802456:	85 c0                	test   %eax,%eax
  802458:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80245d:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  802460:	83 ec 0c             	sub    $0xc,%esp
  802463:	50                   	push   %eax
  802464:	e8 f8 ec ff ff       	call   801161 <sys_ipc_recv>
  802469:	83 c4 10             	add    $0x10,%esp
  80246c:	85 c0                	test   %eax,%eax
  80246e:	75 2b                	jne    80249b <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  802470:	85 f6                	test   %esi,%esi
  802472:	74 0a                	je     80247e <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  802474:	a1 18 40 80 00       	mov    0x804018,%eax
  802479:	8b 40 74             	mov    0x74(%eax),%eax
  80247c:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  80247e:	85 db                	test   %ebx,%ebx
  802480:	74 0a                	je     80248c <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  802482:	a1 18 40 80 00       	mov    0x804018,%eax
  802487:	8b 40 78             	mov    0x78(%eax),%eax
  80248a:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  80248c:	a1 18 40 80 00       	mov    0x804018,%eax
  802491:	8b 40 70             	mov    0x70(%eax),%eax
}
  802494:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802497:	5b                   	pop    %ebx
  802498:	5e                   	pop    %esi
  802499:	5d                   	pop    %ebp
  80249a:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  80249b:	85 f6                	test   %esi,%esi
  80249d:	74 06                	je     8024a5 <ipc_recv+0x61>
  80249f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8024a5:	85 db                	test   %ebx,%ebx
  8024a7:	74 eb                	je     802494 <ipc_recv+0x50>
  8024a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8024af:	eb e3                	jmp    802494 <ipc_recv+0x50>

008024b1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024b1:	f3 0f 1e fb          	endbr32 
  8024b5:	55                   	push   %ebp
  8024b6:	89 e5                	mov    %esp,%ebp
  8024b8:	57                   	push   %edi
  8024b9:	56                   	push   %esi
  8024ba:	53                   	push   %ebx
  8024bb:	83 ec 0c             	sub    $0xc,%esp
  8024be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024c1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024c4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  8024c7:	85 db                	test   %ebx,%ebx
  8024c9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8024ce:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8024d1:	ff 75 14             	pushl  0x14(%ebp)
  8024d4:	53                   	push   %ebx
  8024d5:	56                   	push   %esi
  8024d6:	57                   	push   %edi
  8024d7:	e8 5e ec ff ff       	call   80113a <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  8024dc:	83 c4 10             	add    $0x10,%esp
  8024df:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024e2:	75 07                	jne    8024eb <ipc_send+0x3a>
			sys_yield();
  8024e4:	e8 4f eb ff ff       	call   801038 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8024e9:	eb e6                	jmp    8024d1 <ipc_send+0x20>
		}
		else if (ret == 0)
  8024eb:	85 c0                	test   %eax,%eax
  8024ed:	75 08                	jne    8024f7 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  8024ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024f2:	5b                   	pop    %ebx
  8024f3:	5e                   	pop    %esi
  8024f4:	5f                   	pop    %edi
  8024f5:	5d                   	pop    %ebp
  8024f6:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  8024f7:	50                   	push   %eax
  8024f8:	68 cb 2d 80 00       	push   $0x802dcb
  8024fd:	6a 48                	push   $0x48
  8024ff:	68 d9 2d 80 00       	push   $0x802dd9
  802504:	e8 f1 fe ff ff       	call   8023fa <_panic>

00802509 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802509:	f3 0f 1e fb          	endbr32 
  80250d:	55                   	push   %ebp
  80250e:	89 e5                	mov    %esp,%ebp
  802510:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802513:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802518:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80251b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802521:	8b 52 50             	mov    0x50(%edx),%edx
  802524:	39 ca                	cmp    %ecx,%edx
  802526:	74 11                	je     802539 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802528:	83 c0 01             	add    $0x1,%eax
  80252b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802530:	75 e6                	jne    802518 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802532:	b8 00 00 00 00       	mov    $0x0,%eax
  802537:	eb 0b                	jmp    802544 <ipc_find_env+0x3b>
			return envs[i].env_id;
  802539:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80253c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802541:	8b 40 48             	mov    0x48(%eax),%eax
}
  802544:	5d                   	pop    %ebp
  802545:	c3                   	ret    

00802546 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802546:	f3 0f 1e fb          	endbr32 
  80254a:	55                   	push   %ebp
  80254b:	89 e5                	mov    %esp,%ebp
  80254d:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802550:	89 c2                	mov    %eax,%edx
  802552:	c1 ea 16             	shr    $0x16,%edx
  802555:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80255c:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802561:	f6 c1 01             	test   $0x1,%cl
  802564:	74 1c                	je     802582 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802566:	c1 e8 0c             	shr    $0xc,%eax
  802569:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802570:	a8 01                	test   $0x1,%al
  802572:	74 0e                	je     802582 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802574:	c1 e8 0c             	shr    $0xc,%eax
  802577:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80257e:	ef 
  80257f:	0f b7 d2             	movzwl %dx,%edx
}
  802582:	89 d0                	mov    %edx,%eax
  802584:	5d                   	pop    %ebp
  802585:	c3                   	ret    
  802586:	66 90                	xchg   %ax,%ax
  802588:	66 90                	xchg   %ax,%ax
  80258a:	66 90                	xchg   %ax,%ax
  80258c:	66 90                	xchg   %ax,%ax
  80258e:	66 90                	xchg   %ax,%ax

00802590 <__udivdi3>:
  802590:	f3 0f 1e fb          	endbr32 
  802594:	55                   	push   %ebp
  802595:	57                   	push   %edi
  802596:	56                   	push   %esi
  802597:	53                   	push   %ebx
  802598:	83 ec 1c             	sub    $0x1c,%esp
  80259b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80259f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8025a3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025a7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8025ab:	85 d2                	test   %edx,%edx
  8025ad:	75 19                	jne    8025c8 <__udivdi3+0x38>
  8025af:	39 f3                	cmp    %esi,%ebx
  8025b1:	76 4d                	jbe    802600 <__udivdi3+0x70>
  8025b3:	31 ff                	xor    %edi,%edi
  8025b5:	89 e8                	mov    %ebp,%eax
  8025b7:	89 f2                	mov    %esi,%edx
  8025b9:	f7 f3                	div    %ebx
  8025bb:	89 fa                	mov    %edi,%edx
  8025bd:	83 c4 1c             	add    $0x1c,%esp
  8025c0:	5b                   	pop    %ebx
  8025c1:	5e                   	pop    %esi
  8025c2:	5f                   	pop    %edi
  8025c3:	5d                   	pop    %ebp
  8025c4:	c3                   	ret    
  8025c5:	8d 76 00             	lea    0x0(%esi),%esi
  8025c8:	39 f2                	cmp    %esi,%edx
  8025ca:	76 14                	jbe    8025e0 <__udivdi3+0x50>
  8025cc:	31 ff                	xor    %edi,%edi
  8025ce:	31 c0                	xor    %eax,%eax
  8025d0:	89 fa                	mov    %edi,%edx
  8025d2:	83 c4 1c             	add    $0x1c,%esp
  8025d5:	5b                   	pop    %ebx
  8025d6:	5e                   	pop    %esi
  8025d7:	5f                   	pop    %edi
  8025d8:	5d                   	pop    %ebp
  8025d9:	c3                   	ret    
  8025da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025e0:	0f bd fa             	bsr    %edx,%edi
  8025e3:	83 f7 1f             	xor    $0x1f,%edi
  8025e6:	75 48                	jne    802630 <__udivdi3+0xa0>
  8025e8:	39 f2                	cmp    %esi,%edx
  8025ea:	72 06                	jb     8025f2 <__udivdi3+0x62>
  8025ec:	31 c0                	xor    %eax,%eax
  8025ee:	39 eb                	cmp    %ebp,%ebx
  8025f0:	77 de                	ja     8025d0 <__udivdi3+0x40>
  8025f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8025f7:	eb d7                	jmp    8025d0 <__udivdi3+0x40>
  8025f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802600:	89 d9                	mov    %ebx,%ecx
  802602:	85 db                	test   %ebx,%ebx
  802604:	75 0b                	jne    802611 <__udivdi3+0x81>
  802606:	b8 01 00 00 00       	mov    $0x1,%eax
  80260b:	31 d2                	xor    %edx,%edx
  80260d:	f7 f3                	div    %ebx
  80260f:	89 c1                	mov    %eax,%ecx
  802611:	31 d2                	xor    %edx,%edx
  802613:	89 f0                	mov    %esi,%eax
  802615:	f7 f1                	div    %ecx
  802617:	89 c6                	mov    %eax,%esi
  802619:	89 e8                	mov    %ebp,%eax
  80261b:	89 f7                	mov    %esi,%edi
  80261d:	f7 f1                	div    %ecx
  80261f:	89 fa                	mov    %edi,%edx
  802621:	83 c4 1c             	add    $0x1c,%esp
  802624:	5b                   	pop    %ebx
  802625:	5e                   	pop    %esi
  802626:	5f                   	pop    %edi
  802627:	5d                   	pop    %ebp
  802628:	c3                   	ret    
  802629:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802630:	89 f9                	mov    %edi,%ecx
  802632:	b8 20 00 00 00       	mov    $0x20,%eax
  802637:	29 f8                	sub    %edi,%eax
  802639:	d3 e2                	shl    %cl,%edx
  80263b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80263f:	89 c1                	mov    %eax,%ecx
  802641:	89 da                	mov    %ebx,%edx
  802643:	d3 ea                	shr    %cl,%edx
  802645:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802649:	09 d1                	or     %edx,%ecx
  80264b:	89 f2                	mov    %esi,%edx
  80264d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802651:	89 f9                	mov    %edi,%ecx
  802653:	d3 e3                	shl    %cl,%ebx
  802655:	89 c1                	mov    %eax,%ecx
  802657:	d3 ea                	shr    %cl,%edx
  802659:	89 f9                	mov    %edi,%ecx
  80265b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80265f:	89 eb                	mov    %ebp,%ebx
  802661:	d3 e6                	shl    %cl,%esi
  802663:	89 c1                	mov    %eax,%ecx
  802665:	d3 eb                	shr    %cl,%ebx
  802667:	09 de                	or     %ebx,%esi
  802669:	89 f0                	mov    %esi,%eax
  80266b:	f7 74 24 08          	divl   0x8(%esp)
  80266f:	89 d6                	mov    %edx,%esi
  802671:	89 c3                	mov    %eax,%ebx
  802673:	f7 64 24 0c          	mull   0xc(%esp)
  802677:	39 d6                	cmp    %edx,%esi
  802679:	72 15                	jb     802690 <__udivdi3+0x100>
  80267b:	89 f9                	mov    %edi,%ecx
  80267d:	d3 e5                	shl    %cl,%ebp
  80267f:	39 c5                	cmp    %eax,%ebp
  802681:	73 04                	jae    802687 <__udivdi3+0xf7>
  802683:	39 d6                	cmp    %edx,%esi
  802685:	74 09                	je     802690 <__udivdi3+0x100>
  802687:	89 d8                	mov    %ebx,%eax
  802689:	31 ff                	xor    %edi,%edi
  80268b:	e9 40 ff ff ff       	jmp    8025d0 <__udivdi3+0x40>
  802690:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802693:	31 ff                	xor    %edi,%edi
  802695:	e9 36 ff ff ff       	jmp    8025d0 <__udivdi3+0x40>
  80269a:	66 90                	xchg   %ax,%ax
  80269c:	66 90                	xchg   %ax,%ax
  80269e:	66 90                	xchg   %ax,%ax

008026a0 <__umoddi3>:
  8026a0:	f3 0f 1e fb          	endbr32 
  8026a4:	55                   	push   %ebp
  8026a5:	57                   	push   %edi
  8026a6:	56                   	push   %esi
  8026a7:	53                   	push   %ebx
  8026a8:	83 ec 1c             	sub    $0x1c,%esp
  8026ab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8026af:	8b 74 24 30          	mov    0x30(%esp),%esi
  8026b3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8026b7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026bb:	85 c0                	test   %eax,%eax
  8026bd:	75 19                	jne    8026d8 <__umoddi3+0x38>
  8026bf:	39 df                	cmp    %ebx,%edi
  8026c1:	76 5d                	jbe    802720 <__umoddi3+0x80>
  8026c3:	89 f0                	mov    %esi,%eax
  8026c5:	89 da                	mov    %ebx,%edx
  8026c7:	f7 f7                	div    %edi
  8026c9:	89 d0                	mov    %edx,%eax
  8026cb:	31 d2                	xor    %edx,%edx
  8026cd:	83 c4 1c             	add    $0x1c,%esp
  8026d0:	5b                   	pop    %ebx
  8026d1:	5e                   	pop    %esi
  8026d2:	5f                   	pop    %edi
  8026d3:	5d                   	pop    %ebp
  8026d4:	c3                   	ret    
  8026d5:	8d 76 00             	lea    0x0(%esi),%esi
  8026d8:	89 f2                	mov    %esi,%edx
  8026da:	39 d8                	cmp    %ebx,%eax
  8026dc:	76 12                	jbe    8026f0 <__umoddi3+0x50>
  8026de:	89 f0                	mov    %esi,%eax
  8026e0:	89 da                	mov    %ebx,%edx
  8026e2:	83 c4 1c             	add    $0x1c,%esp
  8026e5:	5b                   	pop    %ebx
  8026e6:	5e                   	pop    %esi
  8026e7:	5f                   	pop    %edi
  8026e8:	5d                   	pop    %ebp
  8026e9:	c3                   	ret    
  8026ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026f0:	0f bd e8             	bsr    %eax,%ebp
  8026f3:	83 f5 1f             	xor    $0x1f,%ebp
  8026f6:	75 50                	jne    802748 <__umoddi3+0xa8>
  8026f8:	39 d8                	cmp    %ebx,%eax
  8026fa:	0f 82 e0 00 00 00    	jb     8027e0 <__umoddi3+0x140>
  802700:	89 d9                	mov    %ebx,%ecx
  802702:	39 f7                	cmp    %esi,%edi
  802704:	0f 86 d6 00 00 00    	jbe    8027e0 <__umoddi3+0x140>
  80270a:	89 d0                	mov    %edx,%eax
  80270c:	89 ca                	mov    %ecx,%edx
  80270e:	83 c4 1c             	add    $0x1c,%esp
  802711:	5b                   	pop    %ebx
  802712:	5e                   	pop    %esi
  802713:	5f                   	pop    %edi
  802714:	5d                   	pop    %ebp
  802715:	c3                   	ret    
  802716:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80271d:	8d 76 00             	lea    0x0(%esi),%esi
  802720:	89 fd                	mov    %edi,%ebp
  802722:	85 ff                	test   %edi,%edi
  802724:	75 0b                	jne    802731 <__umoddi3+0x91>
  802726:	b8 01 00 00 00       	mov    $0x1,%eax
  80272b:	31 d2                	xor    %edx,%edx
  80272d:	f7 f7                	div    %edi
  80272f:	89 c5                	mov    %eax,%ebp
  802731:	89 d8                	mov    %ebx,%eax
  802733:	31 d2                	xor    %edx,%edx
  802735:	f7 f5                	div    %ebp
  802737:	89 f0                	mov    %esi,%eax
  802739:	f7 f5                	div    %ebp
  80273b:	89 d0                	mov    %edx,%eax
  80273d:	31 d2                	xor    %edx,%edx
  80273f:	eb 8c                	jmp    8026cd <__umoddi3+0x2d>
  802741:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802748:	89 e9                	mov    %ebp,%ecx
  80274a:	ba 20 00 00 00       	mov    $0x20,%edx
  80274f:	29 ea                	sub    %ebp,%edx
  802751:	d3 e0                	shl    %cl,%eax
  802753:	89 44 24 08          	mov    %eax,0x8(%esp)
  802757:	89 d1                	mov    %edx,%ecx
  802759:	89 f8                	mov    %edi,%eax
  80275b:	d3 e8                	shr    %cl,%eax
  80275d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802761:	89 54 24 04          	mov    %edx,0x4(%esp)
  802765:	8b 54 24 04          	mov    0x4(%esp),%edx
  802769:	09 c1                	or     %eax,%ecx
  80276b:	89 d8                	mov    %ebx,%eax
  80276d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802771:	89 e9                	mov    %ebp,%ecx
  802773:	d3 e7                	shl    %cl,%edi
  802775:	89 d1                	mov    %edx,%ecx
  802777:	d3 e8                	shr    %cl,%eax
  802779:	89 e9                	mov    %ebp,%ecx
  80277b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80277f:	d3 e3                	shl    %cl,%ebx
  802781:	89 c7                	mov    %eax,%edi
  802783:	89 d1                	mov    %edx,%ecx
  802785:	89 f0                	mov    %esi,%eax
  802787:	d3 e8                	shr    %cl,%eax
  802789:	89 e9                	mov    %ebp,%ecx
  80278b:	89 fa                	mov    %edi,%edx
  80278d:	d3 e6                	shl    %cl,%esi
  80278f:	09 d8                	or     %ebx,%eax
  802791:	f7 74 24 08          	divl   0x8(%esp)
  802795:	89 d1                	mov    %edx,%ecx
  802797:	89 f3                	mov    %esi,%ebx
  802799:	f7 64 24 0c          	mull   0xc(%esp)
  80279d:	89 c6                	mov    %eax,%esi
  80279f:	89 d7                	mov    %edx,%edi
  8027a1:	39 d1                	cmp    %edx,%ecx
  8027a3:	72 06                	jb     8027ab <__umoddi3+0x10b>
  8027a5:	75 10                	jne    8027b7 <__umoddi3+0x117>
  8027a7:	39 c3                	cmp    %eax,%ebx
  8027a9:	73 0c                	jae    8027b7 <__umoddi3+0x117>
  8027ab:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8027af:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8027b3:	89 d7                	mov    %edx,%edi
  8027b5:	89 c6                	mov    %eax,%esi
  8027b7:	89 ca                	mov    %ecx,%edx
  8027b9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027be:	29 f3                	sub    %esi,%ebx
  8027c0:	19 fa                	sbb    %edi,%edx
  8027c2:	89 d0                	mov    %edx,%eax
  8027c4:	d3 e0                	shl    %cl,%eax
  8027c6:	89 e9                	mov    %ebp,%ecx
  8027c8:	d3 eb                	shr    %cl,%ebx
  8027ca:	d3 ea                	shr    %cl,%edx
  8027cc:	09 d8                	or     %ebx,%eax
  8027ce:	83 c4 1c             	add    $0x1c,%esp
  8027d1:	5b                   	pop    %ebx
  8027d2:	5e                   	pop    %esi
  8027d3:	5f                   	pop    %edi
  8027d4:	5d                   	pop    %ebp
  8027d5:	c3                   	ret    
  8027d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027dd:	8d 76 00             	lea    0x0(%esi),%esi
  8027e0:	29 fe                	sub    %edi,%esi
  8027e2:	19 c3                	sbb    %eax,%ebx
  8027e4:	89 f2                	mov    %esi,%edx
  8027e6:	89 d9                	mov    %ebx,%ecx
  8027e8:	e9 1d ff ff ff       	jmp    80270a <__umoddi3+0x6a>
