
obj/user/echosrv.debug:     file format elf32-i386


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
  80002c:	e8 d0 04 00 00       	call   800501 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:
#define BUFFSIZE 32
#define MAXPENDING 5    // Max connection requests

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n", m);
  800039:	50                   	push   %eax
  80003a:	68 70 28 80 00       	push   $0x802870
  80003f:	e8 c2 05 00 00       	call   800606 <cprintf>
	exit();
  800044:	e8 02 05 00 00       	call   80054b <exit>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <handle_client>:

void
handle_client(int sock)
{
  80004e:	f3 0f 1e fb          	endbr32 
  800052:	55                   	push   %ebp
  800053:	89 e5                	mov    %esp,%ebp
  800055:	57                   	push   %edi
  800056:	56                   	push   %esi
  800057:	53                   	push   %ebx
  800058:	83 ec 30             	sub    $0x30,%esp
  80005b:	8b 75 08             	mov    0x8(%ebp),%esi
	char buffer[BUFFSIZE];
	int received = -1;
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80005e:	6a 20                	push   $0x20
  800060:	8d 45 c8             	lea    -0x38(%ebp),%eax
  800063:	50                   	push   %eax
  800064:	56                   	push   %esi
  800065:	e8 b3 14 00 00       	call   80151d <read>
  80006a:	89 c3                	mov    %eax,%ebx
  80006c:	83 c4 10             	add    $0x10,%esp
		die("Failed to receive initial bytes from client");

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
		// Send back received data
		if (write(sock, buffer, received) != received)
  80006f:	8d 7d c8             	lea    -0x38(%ebp),%edi
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  800072:	85 c0                	test   %eax,%eax
  800074:	79 3d                	jns    8000b3 <handle_client+0x65>
		die("Failed to receive initial bytes from client");
  800076:	b8 74 28 80 00       	mov    $0x802874,%eax
  80007b:	e8 b3 ff ff ff       	call   800033 <die>

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
			die("Failed to receive additional bytes from client");
	}
	close(sock);
  800080:	83 ec 0c             	sub    $0xc,%esp
  800083:	56                   	push   %esi
  800084:	e8 4a 13 00 00       	call   8013d3 <close>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80008f:	5b                   	pop    %ebx
  800090:	5e                   	pop    %esi
  800091:	5f                   	pop    %edi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    
			die("Failed to send bytes to client");
  800094:	b8 a0 28 80 00       	mov    $0x8028a0,%eax
  800099:	e8 95 ff ff ff       	call   800033 <die>
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80009e:	83 ec 04             	sub    $0x4,%esp
  8000a1:	6a 20                	push   $0x20
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	e8 73 14 00 00       	call   80151d <read>
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	83 c4 10             	add    $0x10,%esp
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	78 18                	js     8000cb <handle_client+0x7d>
	while (received > 0) {
  8000b3:	85 db                	test   %ebx,%ebx
  8000b5:	7e c9                	jle    800080 <handle_client+0x32>
		if (write(sock, buffer, received) != received)
  8000b7:	83 ec 04             	sub    $0x4,%esp
  8000ba:	53                   	push   %ebx
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	e8 31 15 00 00       	call   8015f3 <write>
  8000c2:	83 c4 10             	add    $0x10,%esp
  8000c5:	39 d8                	cmp    %ebx,%eax
  8000c7:	74 d5                	je     80009e <handle_client+0x50>
  8000c9:	eb c9                	jmp    800094 <handle_client+0x46>
			die("Failed to receive additional bytes from client");
  8000cb:	b8 c0 28 80 00       	mov    $0x8028c0,%eax
  8000d0:	e8 5e ff ff ff       	call   800033 <die>
  8000d5:	eb dc                	jmp    8000b3 <handle_client+0x65>

008000d7 <umain>:

void
umain(int argc, char **argv)
{
  8000d7:	f3 0f 1e fb          	endbr32 
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 40             	sub    $0x40,%esp
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  8000e4:	6a 06                	push   $0x6
  8000e6:	6a 01                	push   $0x1
  8000e8:	6a 02                	push   $0x2
  8000ea:	e8 83 1b 00 00       	call   801c72 <socket>
  8000ef:	89 c6                	mov    %eax,%esi
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	0f 88 86 00 00 00    	js     800182 <umain+0xab>
		die("Failed to create socket");

	cprintf("opened socket\n");
  8000fc:	83 ec 0c             	sub    $0xc,%esp
  8000ff:	68 38 28 80 00       	push   $0x802838
  800104:	e8 fd 04 00 00       	call   800606 <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  800109:	83 c4 0c             	add    $0xc,%esp
  80010c:	6a 10                	push   $0x10
  80010e:	6a 00                	push   $0x0
  800110:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800113:	53                   	push   %ebx
  800114:	e8 a9 0c 00 00       	call   800dc2 <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  800119:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = htonl(INADDR_ANY);   // IP address
  80011d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800124:	e8 94 01 00 00       	call   8002bd <htonl>
  800129:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  80012c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800133:	e8 63 01 00 00       	call   80029b <htons>
  800138:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to bind\n");
  80013c:	c7 04 24 47 28 80 00 	movl   $0x802847,(%esp)
  800143:	e8 be 04 00 00       	call   800606 <cprintf>

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &echoserver,
  800148:	83 c4 0c             	add    $0xc,%esp
  80014b:	6a 10                	push   $0x10
  80014d:	53                   	push   %ebx
  80014e:	56                   	push   %esi
  80014f:	e8 7c 1a 00 00       	call   801bd0 <bind>
  800154:	83 c4 10             	add    $0x10,%esp
  800157:	85 c0                	test   %eax,%eax
  800159:	78 36                	js     800191 <umain+0xba>
		 sizeof(echoserver)) < 0) {
		die("Failed to bind the server socket");
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  80015b:	83 ec 08             	sub    $0x8,%esp
  80015e:	6a 05                	push   $0x5
  800160:	56                   	push   %esi
  800161:	e8 e5 1a 00 00       	call   801c4b <listen>
  800166:	83 c4 10             	add    $0x10,%esp
  800169:	85 c0                	test   %eax,%eax
  80016b:	78 30                	js     80019d <umain+0xc6>
		die("Failed to listen on server socket");

	cprintf("bound\n");
  80016d:	83 ec 0c             	sub    $0xc,%esp
  800170:	68 57 28 80 00       	push   $0x802857
  800175:	e8 8c 04 00 00       	call   800606 <cprintf>
  80017a:	83 c4 10             	add    $0x10,%esp
	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
		// Wait for client connection
		if ((clientsock =
		     accept(serversock, (struct sockaddr *) &echoclient,
  80017d:	8d 7d c4             	lea    -0x3c(%ebp),%edi
  800180:	eb 55                	jmp    8001d7 <umain+0x100>
		die("Failed to create socket");
  800182:	b8 20 28 80 00       	mov    $0x802820,%eax
  800187:	e8 a7 fe ff ff       	call   800033 <die>
  80018c:	e9 6b ff ff ff       	jmp    8000fc <umain+0x25>
		die("Failed to bind the server socket");
  800191:	b8 f0 28 80 00       	mov    $0x8028f0,%eax
  800196:	e8 98 fe ff ff       	call   800033 <die>
  80019b:	eb be                	jmp    80015b <umain+0x84>
		die("Failed to listen on server socket");
  80019d:	b8 14 29 80 00       	mov    $0x802914,%eax
  8001a2:	e8 8c fe ff ff       	call   800033 <die>
  8001a7:	eb c4                	jmp    80016d <umain+0x96>
			    &clientlen)) < 0) {
			die("Failed to accept client connection");
  8001a9:	b8 38 29 80 00       	mov    $0x802938,%eax
  8001ae:	e8 80 fe ff ff       	call   800033 <die>
		}
		cprintf("Client connected: %s\n", inet_ntoa(echoclient.sin_addr));
  8001b3:	83 ec 0c             	sub    $0xc,%esp
  8001b6:	ff 75 cc             	pushl  -0x34(%ebp)
  8001b9:	e8 39 00 00 00       	call   8001f7 <inet_ntoa>
  8001be:	83 c4 08             	add    $0x8,%esp
  8001c1:	50                   	push   %eax
  8001c2:	68 5e 28 80 00       	push   $0x80285e
  8001c7:	e8 3a 04 00 00       	call   800606 <cprintf>
		handle_client(clientsock);
  8001cc:	89 1c 24             	mov    %ebx,(%esp)
  8001cf:	e8 7a fe ff ff       	call   80004e <handle_client>
	while (1) {
  8001d4:	83 c4 10             	add    $0x10,%esp
		unsigned int clientlen = sizeof(echoclient);
  8001d7:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		     accept(serversock, (struct sockaddr *) &echoclient,
  8001de:	83 ec 04             	sub    $0x4,%esp
  8001e1:	57                   	push   %edi
  8001e2:	8d 45 c8             	lea    -0x38(%ebp),%eax
  8001e5:	50                   	push   %eax
  8001e6:	56                   	push   %esi
  8001e7:	e8 b1 19 00 00       	call   801b9d <accept>
  8001ec:	89 c3                	mov    %eax,%ebx
		if ((clientsock =
  8001ee:	83 c4 10             	add    $0x10,%esp
  8001f1:	85 c0                	test   %eax,%eax
  8001f3:	78 b4                	js     8001a9 <umain+0xd2>
  8001f5:	eb bc                	jmp    8001b3 <umain+0xdc>

008001f7 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8001f7:	f3 0f 1e fb          	endbr32 
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	57                   	push   %edi
  8001ff:	56                   	push   %esi
  800200:	53                   	push   %ebx
  800201:	83 ec 18             	sub    $0x18,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800204:	8b 45 08             	mov    0x8(%ebp),%eax
  800207:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  80020a:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
  ap = (u8_t *)&s_addr;
  80020e:	8d 75 f0             	lea    -0x10(%ebp),%esi
  rp = str;
  800211:	bf 00 40 80 00       	mov    $0x804000,%edi
  800216:	eb 2e                	jmp    800246 <inet_ntoa+0x4f>
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
  800218:	0f b6 c8             	movzbl %al,%ecx
  80021b:	0f b6 4c 0d ed       	movzbl -0x13(%ebp,%ecx,1),%ecx
  800220:	88 0a                	mov    %cl,(%edx)
  800222:	83 c2 01             	add    $0x1,%edx
    while(i--)
  800225:	83 e8 01             	sub    $0x1,%eax
  800228:	3c ff                	cmp    $0xff,%al
  80022a:	75 ec                	jne    800218 <inet_ntoa+0x21>
  80022c:	0f b6 db             	movzbl %bl,%ebx
  80022f:	01 fb                	add    %edi,%ebx
    *rp++ = '.';
  800231:	8d 7b 01             	lea    0x1(%ebx),%edi
  800234:	c6 03 2e             	movb   $0x2e,(%ebx)
  800237:	83 c6 01             	add    $0x1,%esi
  for(n = 0; n < 4; n++) {
  80023a:	80 45 df 01          	addb   $0x1,-0x21(%ebp)
  80023e:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
  800242:	3c 04                	cmp    $0x4,%al
  800244:	74 45                	je     80028b <inet_ntoa+0x94>
  rp = str;
  800246:	bb 00 00 00 00       	mov    $0x0,%ebx
      rem = *ap % (u8_t)10;
  80024b:	0f b6 16             	movzbl (%esi),%edx
      *ap /= (u8_t)10;
  80024e:	0f b6 ca             	movzbl %dl,%ecx
  800251:	8d 04 89             	lea    (%ecx,%ecx,4),%eax
  800254:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
  800257:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80025a:	66 c1 e8 0b          	shr    $0xb,%ax
  80025e:	88 06                	mov    %al,(%esi)
  800260:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  800262:	83 c3 01             	add    $0x1,%ebx
  800265:	0f b6 c9             	movzbl %cl,%ecx
  800268:	89 4d e0             	mov    %ecx,-0x20(%ebp)
      rem = *ap % (u8_t)10;
  80026b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80026e:	01 c0                	add    %eax,%eax
  800270:	89 d1                	mov    %edx,%ecx
  800272:	29 c1                	sub    %eax,%ecx
  800274:	89 c8                	mov    %ecx,%eax
      inv[i++] = '0' + rem;
  800276:	83 c0 30             	add    $0x30,%eax
  800279:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80027c:	88 44 0d ed          	mov    %al,-0x13(%ebp,%ecx,1)
    } while(*ap);
  800280:	80 fa 09             	cmp    $0x9,%dl
  800283:	77 c6                	ja     80024b <inet_ntoa+0x54>
  800285:	89 fa                	mov    %edi,%edx
      inv[i++] = '0' + rem;
  800287:	89 d8                	mov    %ebx,%eax
  800289:	eb 9a                	jmp    800225 <inet_ntoa+0x2e>
    ap++;
  }
  *--rp = 0;
  80028b:	c6 03 00             	movb   $0x0,(%ebx)
  return str;
}
  80028e:	b8 00 40 80 00       	mov    $0x804000,%eax
  800293:	83 c4 18             	add    $0x18,%esp
  800296:	5b                   	pop    %ebx
  800297:	5e                   	pop    %esi
  800298:	5f                   	pop    %edi
  800299:	5d                   	pop    %ebp
  80029a:	c3                   	ret    

0080029b <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  80029b:	f3 0f 1e fb          	endbr32 
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  8002a2:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8002a6:	66 c1 c0 08          	rol    $0x8,%ax
}
  8002aa:	5d                   	pop    %ebp
  8002ab:	c3                   	ret    

008002ac <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  8002ac:	f3 0f 1e fb          	endbr32 
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  8002b3:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8002b7:	66 c1 c0 08          	rol    $0x8,%ax
  return htons(n);
}
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  8002bd:	f3 0f 1e fb          	endbr32 
  8002c1:	55                   	push   %ebp
  8002c2:	89 e5                	mov    %esp,%ebp
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  8002c7:	89 d0                	mov    %edx,%eax
  8002c9:	c1 e0 18             	shl    $0x18,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
  8002cc:	89 d1                	mov    %edx,%ecx
  8002ce:	c1 e9 18             	shr    $0x18,%ecx
    ((n & 0xff0000UL) >> 8) |
  8002d1:	09 c8                	or     %ecx,%eax
    ((n & 0xff00) << 8) |
  8002d3:	89 d1                	mov    %edx,%ecx
  8002d5:	c1 e1 08             	shl    $0x8,%ecx
  8002d8:	81 e1 00 00 ff 00    	and    $0xff0000,%ecx
    ((n & 0xff0000UL) >> 8) |
  8002de:	09 c8                	or     %ecx,%eax
  8002e0:	c1 ea 08             	shr    $0x8,%edx
  8002e3:	81 e2 00 ff 00 00    	and    $0xff00,%edx
  8002e9:	09 d0                	or     %edx,%eax
}
  8002eb:	5d                   	pop    %ebp
  8002ec:	c3                   	ret    

008002ed <inet_aton>:
{
  8002ed:	f3 0f 1e fb          	endbr32 
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	57                   	push   %edi
  8002f5:	56                   	push   %esi
  8002f6:	53                   	push   %ebx
  8002f7:	83 ec 2c             	sub    $0x2c,%esp
  8002fa:	8b 55 08             	mov    0x8(%ebp),%edx
  c = *cp;
  8002fd:	0f be 02             	movsbl (%edx),%eax
  u32_t *pp = parts;
  800300:	8d 75 d8             	lea    -0x28(%ebp),%esi
  800303:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800306:	e9 a7 00 00 00       	jmp    8003b2 <inet_aton+0xc5>
      c = *++cp;
  80030b:	0f b6 42 01          	movzbl 0x1(%edx),%eax
      if (c == 'x' || c == 'X') {
  80030f:	89 c1                	mov    %eax,%ecx
  800311:	83 e1 df             	and    $0xffffffdf,%ecx
  800314:	80 f9 58             	cmp    $0x58,%cl
  800317:	74 10                	je     800329 <inet_aton+0x3c>
      c = *++cp;
  800319:	83 c2 01             	add    $0x1,%edx
  80031c:	0f be c0             	movsbl %al,%eax
        base = 8;
  80031f:	be 08 00 00 00       	mov    $0x8,%esi
  800324:	e9 a3 00 00 00       	jmp    8003cc <inet_aton+0xdf>
        c = *++cp;
  800329:	0f be 42 02          	movsbl 0x2(%edx),%eax
  80032d:	8d 52 02             	lea    0x2(%edx),%edx
        base = 16;
  800330:	be 10 00 00 00       	mov    $0x10,%esi
  800335:	e9 92 00 00 00       	jmp    8003cc <inet_aton+0xdf>
      } else if (base == 16 && isxdigit(c)) {
  80033a:	83 fe 10             	cmp    $0x10,%esi
  80033d:	75 4d                	jne    80038c <inet_aton+0x9f>
  80033f:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  800342:	88 4d d3             	mov    %cl,-0x2d(%ebp)
  800345:	89 c1                	mov    %eax,%ecx
  800347:	83 e1 df             	and    $0xffffffdf,%ecx
  80034a:	83 e9 41             	sub    $0x41,%ecx
  80034d:	80 f9 05             	cmp    $0x5,%cl
  800350:	77 3a                	ja     80038c <inet_aton+0x9f>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800352:	c1 e3 04             	shl    $0x4,%ebx
  800355:	83 c0 0a             	add    $0xa,%eax
  800358:	80 7d d3 1a          	cmpb   $0x1a,-0x2d(%ebp)
  80035c:	19 c9                	sbb    %ecx,%ecx
  80035e:	83 e1 20             	and    $0x20,%ecx
  800361:	83 c1 41             	add    $0x41,%ecx
  800364:	29 c8                	sub    %ecx,%eax
  800366:	09 c3                	or     %eax,%ebx
        c = *++cp;
  800368:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80036b:	0f be 40 01          	movsbl 0x1(%eax),%eax
  80036f:	83 c2 01             	add    $0x1,%edx
  800372:	89 55 d4             	mov    %edx,-0x2c(%ebp)
      if (isdigit(c)) {
  800375:	89 c7                	mov    %eax,%edi
  800377:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80037a:	80 f9 09             	cmp    $0x9,%cl
  80037d:	77 bb                	ja     80033a <inet_aton+0x4d>
        val = (val * base) + (int)(c - '0');
  80037f:	0f af de             	imul   %esi,%ebx
  800382:	8d 5c 18 d0          	lea    -0x30(%eax,%ebx,1),%ebx
        c = *++cp;
  800386:	0f be 42 01          	movsbl 0x1(%edx),%eax
  80038a:	eb e3                	jmp    80036f <inet_aton+0x82>
    if (c == '.') {
  80038c:	83 f8 2e             	cmp    $0x2e,%eax
  80038f:	75 42                	jne    8003d3 <inet_aton+0xe6>
      if (pp >= parts + 3)
  800391:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800394:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800397:	39 c6                	cmp    %eax,%esi
  800399:	0f 84 16 01 00 00    	je     8004b5 <inet_aton+0x1c8>
      *pp++ = val;
  80039f:	83 c6 04             	add    $0x4,%esi
  8003a2:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8003a5:	89 5e fc             	mov    %ebx,-0x4(%esi)
      c = *++cp;
  8003a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003ab:	8d 50 01             	lea    0x1(%eax),%edx
  8003ae:	0f be 40 01          	movsbl 0x1(%eax),%eax
    if (!isdigit(c))
  8003b2:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003b5:	80 f9 09             	cmp    $0x9,%cl
  8003b8:	0f 87 f0 00 00 00    	ja     8004ae <inet_aton+0x1c1>
    base = 10;
  8003be:	be 0a 00 00 00       	mov    $0xa,%esi
    if (c == '0') {
  8003c3:	83 f8 30             	cmp    $0x30,%eax
  8003c6:	0f 84 3f ff ff ff    	je     80030b <inet_aton+0x1e>
    base = 10;
  8003cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003d1:	eb 9f                	jmp    800372 <inet_aton+0x85>
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003d3:	85 c0                	test   %eax,%eax
  8003d5:	74 29                	je     800400 <inet_aton+0x113>
    return (0);
  8003d7:	ba 00 00 00 00       	mov    $0x0,%edx
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003dc:	89 f9                	mov    %edi,%ecx
  8003de:	80 f9 1f             	cmp    $0x1f,%cl
  8003e1:	0f 86 d3 00 00 00    	jbe    8004ba <inet_aton+0x1cd>
  8003e7:	84 c0                	test   %al,%al
  8003e9:	0f 88 cb 00 00 00    	js     8004ba <inet_aton+0x1cd>
  8003ef:	83 f8 20             	cmp    $0x20,%eax
  8003f2:	74 0c                	je     800400 <inet_aton+0x113>
  8003f4:	83 e8 09             	sub    $0x9,%eax
  8003f7:	83 f8 04             	cmp    $0x4,%eax
  8003fa:	0f 87 ba 00 00 00    	ja     8004ba <inet_aton+0x1cd>
  n = pp - parts + 1;
  800400:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800403:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800406:	29 c6                	sub    %eax,%esi
  800408:	89 f0                	mov    %esi,%eax
  80040a:	c1 f8 02             	sar    $0x2,%eax
  80040d:	8d 50 01             	lea    0x1(%eax),%edx
  switch (n) {
  800410:	83 f8 02             	cmp    $0x2,%eax
  800413:	74 7a                	je     80048f <inet_aton+0x1a2>
  800415:	83 fa 03             	cmp    $0x3,%edx
  800418:	7f 49                	jg     800463 <inet_aton+0x176>
  80041a:	85 d2                	test   %edx,%edx
  80041c:	0f 84 98 00 00 00    	je     8004ba <inet_aton+0x1cd>
  800422:	83 fa 02             	cmp    $0x2,%edx
  800425:	75 19                	jne    800440 <inet_aton+0x153>
      return (0);
  800427:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xffffffUL)
  80042c:	81 fb ff ff ff 00    	cmp    $0xffffff,%ebx
  800432:	0f 87 82 00 00 00    	ja     8004ba <inet_aton+0x1cd>
    val |= parts[0] << 24;
  800438:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80043b:	c1 e0 18             	shl    $0x18,%eax
  80043e:	09 c3                	or     %eax,%ebx
  return (1);
  800440:	ba 01 00 00 00       	mov    $0x1,%edx
  if (addr)
  800445:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800449:	74 6f                	je     8004ba <inet_aton+0x1cd>
    addr->s_addr = htonl(val);
  80044b:	83 ec 0c             	sub    $0xc,%esp
  80044e:	53                   	push   %ebx
  80044f:	e8 69 fe ff ff       	call   8002bd <htonl>
  800454:	83 c4 10             	add    $0x10,%esp
  800457:	8b 75 0c             	mov    0xc(%ebp),%esi
  80045a:	89 06                	mov    %eax,(%esi)
  return (1);
  80045c:	ba 01 00 00 00       	mov    $0x1,%edx
  800461:	eb 57                	jmp    8004ba <inet_aton+0x1cd>
  switch (n) {
  800463:	83 fa 04             	cmp    $0x4,%edx
  800466:	75 d8                	jne    800440 <inet_aton+0x153>
      return (0);
  800468:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xff)
  80046d:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
  800473:	77 45                	ja     8004ba <inet_aton+0x1cd>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  800475:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800478:	c1 e0 18             	shl    $0x18,%eax
  80047b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80047e:	c1 e2 10             	shl    $0x10,%edx
  800481:	09 d0                	or     %edx,%eax
  800483:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800486:	c1 e2 08             	shl    $0x8,%edx
  800489:	09 d0                	or     %edx,%eax
  80048b:	09 c3                	or     %eax,%ebx
    break;
  80048d:	eb b1                	jmp    800440 <inet_aton+0x153>
      return (0);
  80048f:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xffff)
  800494:	81 fb ff ff 00 00    	cmp    $0xffff,%ebx
  80049a:	77 1e                	ja     8004ba <inet_aton+0x1cd>
    val |= (parts[0] << 24) | (parts[1] << 16);
  80049c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80049f:	c1 e0 18             	shl    $0x18,%eax
  8004a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8004a5:	c1 e2 10             	shl    $0x10,%edx
  8004a8:	09 d0                	or     %edx,%eax
  8004aa:	09 c3                	or     %eax,%ebx
    break;
  8004ac:	eb 92                	jmp    800440 <inet_aton+0x153>
      return (0);
  8004ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b3:	eb 05                	jmp    8004ba <inet_aton+0x1cd>
        return (0);
  8004b5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004ba:	89 d0                	mov    %edx,%eax
  8004bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004bf:	5b                   	pop    %ebx
  8004c0:	5e                   	pop    %esi
  8004c1:	5f                   	pop    %edi
  8004c2:	5d                   	pop    %ebp
  8004c3:	c3                   	ret    

008004c4 <inet_addr>:
{
  8004c4:	f3 0f 1e fb          	endbr32 
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	83 ec 20             	sub    $0x20,%esp
  if (inet_aton(cp, &val)) {
  8004ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004d1:	50                   	push   %eax
  8004d2:	ff 75 08             	pushl  0x8(%ebp)
  8004d5:	e8 13 fe ff ff       	call   8002ed <inet_aton>
  8004da:	83 c4 10             	add    $0x10,%esp
    return (val.s_addr);
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004e4:	0f 45 45 f4          	cmovne -0xc(%ebp),%eax
}
  8004e8:	c9                   	leave  
  8004e9:	c3                   	ret    

008004ea <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  8004ea:	f3 0f 1e fb          	endbr32 
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  8004f1:	83 ec 14             	sub    $0x14,%esp
  return htonl(n);
  8004f4:	ff 75 08             	pushl  0x8(%ebp)
  8004f7:	e8 c1 fd ff ff       	call   8002bd <htonl>
  8004fc:	83 c4 10             	add    $0x10,%esp
}
  8004ff:	c9                   	leave  
  800500:	c3                   	ret    

00800501 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800501:	f3 0f 1e fb          	endbr32 
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
  800508:	56                   	push   %esi
  800509:	53                   	push   %ebx
  80050a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80050d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800510:	e8 1e 0b 00 00       	call   801033 <sys_getenvid>
  800515:	25 ff 03 00 00       	and    $0x3ff,%eax
  80051a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80051d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800522:	a3 18 40 80 00       	mov    %eax,0x804018
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800527:	85 db                	test   %ebx,%ebx
  800529:	7e 07                	jle    800532 <libmain+0x31>
		binaryname = argv[0];
  80052b:	8b 06                	mov    (%esi),%eax
  80052d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	56                   	push   %esi
  800536:	53                   	push   %ebx
  800537:	e8 9b fb ff ff       	call   8000d7 <umain>

	// exit gracefully
	exit();
  80053c:	e8 0a 00 00 00       	call   80054b <exit>
}
  800541:	83 c4 10             	add    $0x10,%esp
  800544:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800547:	5b                   	pop    %ebx
  800548:	5e                   	pop    %esi
  800549:	5d                   	pop    %ebp
  80054a:	c3                   	ret    

0080054b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80054b:	f3 0f 1e fb          	endbr32 
  80054f:	55                   	push   %ebp
  800550:	89 e5                	mov    %esp,%ebp
  800552:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  800555:	e8 aa 0e 00 00       	call   801404 <close_all>
	sys_env_destroy(0);
  80055a:	83 ec 0c             	sub    $0xc,%esp
  80055d:	6a 00                	push   $0x0
  80055f:	e8 ab 0a 00 00       	call   80100f <sys_env_destroy>
}
  800564:	83 c4 10             	add    $0x10,%esp
  800567:	c9                   	leave  
  800568:	c3                   	ret    

00800569 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800569:	f3 0f 1e fb          	endbr32 
  80056d:	55                   	push   %ebp
  80056e:	89 e5                	mov    %esp,%ebp
  800570:	53                   	push   %ebx
  800571:	83 ec 04             	sub    $0x4,%esp
  800574:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800577:	8b 13                	mov    (%ebx),%edx
  800579:	8d 42 01             	lea    0x1(%edx),%eax
  80057c:	89 03                	mov    %eax,(%ebx)
  80057e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800581:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800585:	3d ff 00 00 00       	cmp    $0xff,%eax
  80058a:	74 09                	je     800595 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80058c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800590:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800593:	c9                   	leave  
  800594:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800595:	83 ec 08             	sub    $0x8,%esp
  800598:	68 ff 00 00 00       	push   $0xff
  80059d:	8d 43 08             	lea    0x8(%ebx),%eax
  8005a0:	50                   	push   %eax
  8005a1:	e8 24 0a 00 00       	call   800fca <sys_cputs>
		b->idx = 0;
  8005a6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8005ac:	83 c4 10             	add    $0x10,%esp
  8005af:	eb db                	jmp    80058c <putch+0x23>

008005b1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8005b1:	f3 0f 1e fb          	endbr32 
  8005b5:	55                   	push   %ebp
  8005b6:	89 e5                	mov    %esp,%ebp
  8005b8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8005be:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005c5:	00 00 00 
	b.cnt = 0;
  8005c8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005cf:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005d2:	ff 75 0c             	pushl  0xc(%ebp)
  8005d5:	ff 75 08             	pushl  0x8(%ebp)
  8005d8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005de:	50                   	push   %eax
  8005df:	68 69 05 80 00       	push   $0x800569
  8005e4:	e8 20 01 00 00       	call   800709 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005e9:	83 c4 08             	add    $0x8,%esp
  8005ec:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005f2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005f8:	50                   	push   %eax
  8005f9:	e8 cc 09 00 00       	call   800fca <sys_cputs>

	return b.cnt;
}
  8005fe:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800604:	c9                   	leave  
  800605:	c3                   	ret    

00800606 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800606:	f3 0f 1e fb          	endbr32 
  80060a:	55                   	push   %ebp
  80060b:	89 e5                	mov    %esp,%ebp
  80060d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800610:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800613:	50                   	push   %eax
  800614:	ff 75 08             	pushl  0x8(%ebp)
  800617:	e8 95 ff ff ff       	call   8005b1 <vcprintf>
	va_end(ap);

	return cnt;
}
  80061c:	c9                   	leave  
  80061d:	c3                   	ret    

0080061e <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80061e:	55                   	push   %ebp
  80061f:	89 e5                	mov    %esp,%ebp
  800621:	57                   	push   %edi
  800622:	56                   	push   %esi
  800623:	53                   	push   %ebx
  800624:	83 ec 1c             	sub    $0x1c,%esp
  800627:	89 c7                	mov    %eax,%edi
  800629:	89 d6                	mov    %edx,%esi
  80062b:	8b 45 08             	mov    0x8(%ebp),%eax
  80062e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800631:	89 d1                	mov    %edx,%ecx
  800633:	89 c2                	mov    %eax,%edx
  800635:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800638:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80063b:	8b 45 10             	mov    0x10(%ebp),%eax
  80063e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800641:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800644:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80064b:	39 c2                	cmp    %eax,%edx
  80064d:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800650:	72 3e                	jb     800690 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800652:	83 ec 0c             	sub    $0xc,%esp
  800655:	ff 75 18             	pushl  0x18(%ebp)
  800658:	83 eb 01             	sub    $0x1,%ebx
  80065b:	53                   	push   %ebx
  80065c:	50                   	push   %eax
  80065d:	83 ec 08             	sub    $0x8,%esp
  800660:	ff 75 e4             	pushl  -0x1c(%ebp)
  800663:	ff 75 e0             	pushl  -0x20(%ebp)
  800666:	ff 75 dc             	pushl  -0x24(%ebp)
  800669:	ff 75 d8             	pushl  -0x28(%ebp)
  80066c:	e8 3f 1f 00 00       	call   8025b0 <__udivdi3>
  800671:	83 c4 18             	add    $0x18,%esp
  800674:	52                   	push   %edx
  800675:	50                   	push   %eax
  800676:	89 f2                	mov    %esi,%edx
  800678:	89 f8                	mov    %edi,%eax
  80067a:	e8 9f ff ff ff       	call   80061e <printnum>
  80067f:	83 c4 20             	add    $0x20,%esp
  800682:	eb 13                	jmp    800697 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800684:	83 ec 08             	sub    $0x8,%esp
  800687:	56                   	push   %esi
  800688:	ff 75 18             	pushl  0x18(%ebp)
  80068b:	ff d7                	call   *%edi
  80068d:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800690:	83 eb 01             	sub    $0x1,%ebx
  800693:	85 db                	test   %ebx,%ebx
  800695:	7f ed                	jg     800684 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	56                   	push   %esi
  80069b:	83 ec 04             	sub    $0x4,%esp
  80069e:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a4:	ff 75 dc             	pushl  -0x24(%ebp)
  8006a7:	ff 75 d8             	pushl  -0x28(%ebp)
  8006aa:	e8 11 20 00 00       	call   8026c0 <__umoddi3>
  8006af:	83 c4 14             	add    $0x14,%esp
  8006b2:	0f be 80 65 29 80 00 	movsbl 0x802965(%eax),%eax
  8006b9:	50                   	push   %eax
  8006ba:	ff d7                	call   *%edi
}
  8006bc:	83 c4 10             	add    $0x10,%esp
  8006bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c2:	5b                   	pop    %ebx
  8006c3:	5e                   	pop    %esi
  8006c4:	5f                   	pop    %edi
  8006c5:	5d                   	pop    %ebp
  8006c6:	c3                   	ret    

008006c7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006c7:	f3 0f 1e fb          	endbr32 
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
  8006ce:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006d1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006d5:	8b 10                	mov    (%eax),%edx
  8006d7:	3b 50 04             	cmp    0x4(%eax),%edx
  8006da:	73 0a                	jae    8006e6 <sprintputch+0x1f>
		*b->buf++ = ch;
  8006dc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006df:	89 08                	mov    %ecx,(%eax)
  8006e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e4:	88 02                	mov    %al,(%edx)
}
  8006e6:	5d                   	pop    %ebp
  8006e7:	c3                   	ret    

008006e8 <printfmt>:
{
  8006e8:	f3 0f 1e fb          	endbr32 
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8006f2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006f5:	50                   	push   %eax
  8006f6:	ff 75 10             	pushl  0x10(%ebp)
  8006f9:	ff 75 0c             	pushl  0xc(%ebp)
  8006fc:	ff 75 08             	pushl  0x8(%ebp)
  8006ff:	e8 05 00 00 00       	call   800709 <vprintfmt>
}
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	c9                   	leave  
  800708:	c3                   	ret    

00800709 <vprintfmt>:
{
  800709:	f3 0f 1e fb          	endbr32 
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	57                   	push   %edi
  800711:	56                   	push   %esi
  800712:	53                   	push   %ebx
  800713:	83 ec 3c             	sub    $0x3c,%esp
  800716:	8b 75 08             	mov    0x8(%ebp),%esi
  800719:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80071c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80071f:	e9 8e 03 00 00       	jmp    800ab2 <vprintfmt+0x3a9>
		padc = ' ';
  800724:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800728:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80072f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800736:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80073d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800742:	8d 47 01             	lea    0x1(%edi),%eax
  800745:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800748:	0f b6 17             	movzbl (%edi),%edx
  80074b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80074e:	3c 55                	cmp    $0x55,%al
  800750:	0f 87 df 03 00 00    	ja     800b35 <vprintfmt+0x42c>
  800756:	0f b6 c0             	movzbl %al,%eax
  800759:	3e ff 24 85 a0 2a 80 	notrack jmp *0x802aa0(,%eax,4)
  800760:	00 
  800761:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800764:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800768:	eb d8                	jmp    800742 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80076a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80076d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800771:	eb cf                	jmp    800742 <vprintfmt+0x39>
  800773:	0f b6 d2             	movzbl %dl,%edx
  800776:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800779:	b8 00 00 00 00       	mov    $0x0,%eax
  80077e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800781:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800784:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800788:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80078b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80078e:	83 f9 09             	cmp    $0x9,%ecx
  800791:	77 55                	ja     8007e8 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800793:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800796:	eb e9                	jmp    800781 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800798:	8b 45 14             	mov    0x14(%ebp),%eax
  80079b:	8b 00                	mov    (%eax),%eax
  80079d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a3:	8d 40 04             	lea    0x4(%eax),%eax
  8007a6:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8007a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8007ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007b0:	79 90                	jns    800742 <vprintfmt+0x39>
				width = precision, precision = -1;
  8007b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007b8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8007bf:	eb 81                	jmp    800742 <vprintfmt+0x39>
  8007c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007c4:	85 c0                	test   %eax,%eax
  8007c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8007cb:	0f 49 d0             	cmovns %eax,%edx
  8007ce:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8007d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8007d4:	e9 69 ff ff ff       	jmp    800742 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8007d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8007dc:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8007e3:	e9 5a ff ff ff       	jmp    800742 <vprintfmt+0x39>
  8007e8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8007eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ee:	eb bc                	jmp    8007ac <vprintfmt+0xa3>
			lflag++;
  8007f0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8007f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8007f6:	e9 47 ff ff ff       	jmp    800742 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8007fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fe:	8d 78 04             	lea    0x4(%eax),%edi
  800801:	83 ec 08             	sub    $0x8,%esp
  800804:	53                   	push   %ebx
  800805:	ff 30                	pushl  (%eax)
  800807:	ff d6                	call   *%esi
			break;
  800809:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80080c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80080f:	e9 9b 02 00 00       	jmp    800aaf <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800814:	8b 45 14             	mov    0x14(%ebp),%eax
  800817:	8d 78 04             	lea    0x4(%eax),%edi
  80081a:	8b 00                	mov    (%eax),%eax
  80081c:	99                   	cltd   
  80081d:	31 d0                	xor    %edx,%eax
  80081f:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800821:	83 f8 0f             	cmp    $0xf,%eax
  800824:	7f 23                	jg     800849 <vprintfmt+0x140>
  800826:	8b 14 85 00 2c 80 00 	mov    0x802c00(,%eax,4),%edx
  80082d:	85 d2                	test   %edx,%edx
  80082f:	74 18                	je     800849 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800831:	52                   	push   %edx
  800832:	68 09 2d 80 00       	push   $0x802d09
  800837:	53                   	push   %ebx
  800838:	56                   	push   %esi
  800839:	e8 aa fe ff ff       	call   8006e8 <printfmt>
  80083e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800841:	89 7d 14             	mov    %edi,0x14(%ebp)
  800844:	e9 66 02 00 00       	jmp    800aaf <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800849:	50                   	push   %eax
  80084a:	68 7d 29 80 00       	push   $0x80297d
  80084f:	53                   	push   %ebx
  800850:	56                   	push   %esi
  800851:	e8 92 fe ff ff       	call   8006e8 <printfmt>
  800856:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800859:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80085c:	e9 4e 02 00 00       	jmp    800aaf <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800861:	8b 45 14             	mov    0x14(%ebp),%eax
  800864:	83 c0 04             	add    $0x4,%eax
  800867:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80086a:	8b 45 14             	mov    0x14(%ebp),%eax
  80086d:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80086f:	85 d2                	test   %edx,%edx
  800871:	b8 76 29 80 00       	mov    $0x802976,%eax
  800876:	0f 45 c2             	cmovne %edx,%eax
  800879:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80087c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800880:	7e 06                	jle    800888 <vprintfmt+0x17f>
  800882:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800886:	75 0d                	jne    800895 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800888:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80088b:	89 c7                	mov    %eax,%edi
  80088d:	03 45 e0             	add    -0x20(%ebp),%eax
  800890:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800893:	eb 55                	jmp    8008ea <vprintfmt+0x1e1>
  800895:	83 ec 08             	sub    $0x8,%esp
  800898:	ff 75 d8             	pushl  -0x28(%ebp)
  80089b:	ff 75 cc             	pushl  -0x34(%ebp)
  80089e:	e8 46 03 00 00       	call   800be9 <strnlen>
  8008a3:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8008a6:	29 c2                	sub    %eax,%edx
  8008a8:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8008ab:	83 c4 10             	add    $0x10,%esp
  8008ae:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8008b0:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8008b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b7:	85 ff                	test   %edi,%edi
  8008b9:	7e 11                	jle    8008cc <vprintfmt+0x1c3>
					putch(padc, putdat);
  8008bb:	83 ec 08             	sub    $0x8,%esp
  8008be:	53                   	push   %ebx
  8008bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8008c2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8008c4:	83 ef 01             	sub    $0x1,%edi
  8008c7:	83 c4 10             	add    $0x10,%esp
  8008ca:	eb eb                	jmp    8008b7 <vprintfmt+0x1ae>
  8008cc:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8008cf:	85 d2                	test   %edx,%edx
  8008d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d6:	0f 49 c2             	cmovns %edx,%eax
  8008d9:	29 c2                	sub    %eax,%edx
  8008db:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8008de:	eb a8                	jmp    800888 <vprintfmt+0x17f>
					putch(ch, putdat);
  8008e0:	83 ec 08             	sub    $0x8,%esp
  8008e3:	53                   	push   %ebx
  8008e4:	52                   	push   %edx
  8008e5:	ff d6                	call   *%esi
  8008e7:	83 c4 10             	add    $0x10,%esp
  8008ea:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8008ed:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008ef:	83 c7 01             	add    $0x1,%edi
  8008f2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008f6:	0f be d0             	movsbl %al,%edx
  8008f9:	85 d2                	test   %edx,%edx
  8008fb:	74 4b                	je     800948 <vprintfmt+0x23f>
  8008fd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800901:	78 06                	js     800909 <vprintfmt+0x200>
  800903:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800907:	78 1e                	js     800927 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  800909:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80090d:	74 d1                	je     8008e0 <vprintfmt+0x1d7>
  80090f:	0f be c0             	movsbl %al,%eax
  800912:	83 e8 20             	sub    $0x20,%eax
  800915:	83 f8 5e             	cmp    $0x5e,%eax
  800918:	76 c6                	jbe    8008e0 <vprintfmt+0x1d7>
					putch('?', putdat);
  80091a:	83 ec 08             	sub    $0x8,%esp
  80091d:	53                   	push   %ebx
  80091e:	6a 3f                	push   $0x3f
  800920:	ff d6                	call   *%esi
  800922:	83 c4 10             	add    $0x10,%esp
  800925:	eb c3                	jmp    8008ea <vprintfmt+0x1e1>
  800927:	89 cf                	mov    %ecx,%edi
  800929:	eb 0e                	jmp    800939 <vprintfmt+0x230>
				putch(' ', putdat);
  80092b:	83 ec 08             	sub    $0x8,%esp
  80092e:	53                   	push   %ebx
  80092f:	6a 20                	push   $0x20
  800931:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800933:	83 ef 01             	sub    $0x1,%edi
  800936:	83 c4 10             	add    $0x10,%esp
  800939:	85 ff                	test   %edi,%edi
  80093b:	7f ee                	jg     80092b <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80093d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800940:	89 45 14             	mov    %eax,0x14(%ebp)
  800943:	e9 67 01 00 00       	jmp    800aaf <vprintfmt+0x3a6>
  800948:	89 cf                	mov    %ecx,%edi
  80094a:	eb ed                	jmp    800939 <vprintfmt+0x230>
	if (lflag >= 2)
  80094c:	83 f9 01             	cmp    $0x1,%ecx
  80094f:	7f 1b                	jg     80096c <vprintfmt+0x263>
	else if (lflag)
  800951:	85 c9                	test   %ecx,%ecx
  800953:	74 63                	je     8009b8 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800955:	8b 45 14             	mov    0x14(%ebp),%eax
  800958:	8b 00                	mov    (%eax),%eax
  80095a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80095d:	99                   	cltd   
  80095e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800961:	8b 45 14             	mov    0x14(%ebp),%eax
  800964:	8d 40 04             	lea    0x4(%eax),%eax
  800967:	89 45 14             	mov    %eax,0x14(%ebp)
  80096a:	eb 17                	jmp    800983 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80096c:	8b 45 14             	mov    0x14(%ebp),%eax
  80096f:	8b 50 04             	mov    0x4(%eax),%edx
  800972:	8b 00                	mov    (%eax),%eax
  800974:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800977:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80097a:	8b 45 14             	mov    0x14(%ebp),%eax
  80097d:	8d 40 08             	lea    0x8(%eax),%eax
  800980:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800983:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800986:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800989:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80098e:	85 c9                	test   %ecx,%ecx
  800990:	0f 89 ff 00 00 00    	jns    800a95 <vprintfmt+0x38c>
				putch('-', putdat);
  800996:	83 ec 08             	sub    $0x8,%esp
  800999:	53                   	push   %ebx
  80099a:	6a 2d                	push   $0x2d
  80099c:	ff d6                	call   *%esi
				num = -(long long) num;
  80099e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8009a1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8009a4:	f7 da                	neg    %edx
  8009a6:	83 d1 00             	adc    $0x0,%ecx
  8009a9:	f7 d9                	neg    %ecx
  8009ab:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8009ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009b3:	e9 dd 00 00 00       	jmp    800a95 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8009b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bb:	8b 00                	mov    (%eax),%eax
  8009bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009c0:	99                   	cltd   
  8009c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8009c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c7:	8d 40 04             	lea    0x4(%eax),%eax
  8009ca:	89 45 14             	mov    %eax,0x14(%ebp)
  8009cd:	eb b4                	jmp    800983 <vprintfmt+0x27a>
	if (lflag >= 2)
  8009cf:	83 f9 01             	cmp    $0x1,%ecx
  8009d2:	7f 1e                	jg     8009f2 <vprintfmt+0x2e9>
	else if (lflag)
  8009d4:	85 c9                	test   %ecx,%ecx
  8009d6:	74 32                	je     800a0a <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8009d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009db:	8b 10                	mov    (%eax),%edx
  8009dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009e2:	8d 40 04             	lea    0x4(%eax),%eax
  8009e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009e8:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8009ed:	e9 a3 00 00 00       	jmp    800a95 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8009f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f5:	8b 10                	mov    (%eax),%edx
  8009f7:	8b 48 04             	mov    0x4(%eax),%ecx
  8009fa:	8d 40 08             	lea    0x8(%eax),%eax
  8009fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800a00:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800a05:	e9 8b 00 00 00       	jmp    800a95 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800a0a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0d:	8b 10                	mov    (%eax),%edx
  800a0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a14:	8d 40 04             	lea    0x4(%eax),%eax
  800a17:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800a1a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800a1f:	eb 74                	jmp    800a95 <vprintfmt+0x38c>
	if (lflag >= 2)
  800a21:	83 f9 01             	cmp    $0x1,%ecx
  800a24:	7f 1b                	jg     800a41 <vprintfmt+0x338>
	else if (lflag)
  800a26:	85 c9                	test   %ecx,%ecx
  800a28:	74 2c                	je     800a56 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800a2a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a2d:	8b 10                	mov    (%eax),%edx
  800a2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a34:	8d 40 04             	lea    0x4(%eax),%eax
  800a37:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800a3a:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800a3f:	eb 54                	jmp    800a95 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800a41:	8b 45 14             	mov    0x14(%ebp),%eax
  800a44:	8b 10                	mov    (%eax),%edx
  800a46:	8b 48 04             	mov    0x4(%eax),%ecx
  800a49:	8d 40 08             	lea    0x8(%eax),%eax
  800a4c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800a4f:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800a54:	eb 3f                	jmp    800a95 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800a56:	8b 45 14             	mov    0x14(%ebp),%eax
  800a59:	8b 10                	mov    (%eax),%edx
  800a5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a60:	8d 40 04             	lea    0x4(%eax),%eax
  800a63:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800a66:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800a6b:	eb 28                	jmp    800a95 <vprintfmt+0x38c>
			putch('0', putdat);
  800a6d:	83 ec 08             	sub    $0x8,%esp
  800a70:	53                   	push   %ebx
  800a71:	6a 30                	push   $0x30
  800a73:	ff d6                	call   *%esi
			putch('x', putdat);
  800a75:	83 c4 08             	add    $0x8,%esp
  800a78:	53                   	push   %ebx
  800a79:	6a 78                	push   $0x78
  800a7b:	ff d6                	call   *%esi
			num = (unsigned long long)
  800a7d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a80:	8b 10                	mov    (%eax),%edx
  800a82:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800a87:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800a8a:	8d 40 04             	lea    0x4(%eax),%eax
  800a8d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a90:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800a95:	83 ec 0c             	sub    $0xc,%esp
  800a98:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800a9c:	57                   	push   %edi
  800a9d:	ff 75 e0             	pushl  -0x20(%ebp)
  800aa0:	50                   	push   %eax
  800aa1:	51                   	push   %ecx
  800aa2:	52                   	push   %edx
  800aa3:	89 da                	mov    %ebx,%edx
  800aa5:	89 f0                	mov    %esi,%eax
  800aa7:	e8 72 fb ff ff       	call   80061e <printnum>
			break;
  800aac:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800aaf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  800ab2:	83 c7 01             	add    $0x1,%edi
  800ab5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ab9:	83 f8 25             	cmp    $0x25,%eax
  800abc:	0f 84 62 fc ff ff    	je     800724 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  800ac2:	85 c0                	test   %eax,%eax
  800ac4:	0f 84 8b 00 00 00    	je     800b55 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  800aca:	83 ec 08             	sub    $0x8,%esp
  800acd:	53                   	push   %ebx
  800ace:	50                   	push   %eax
  800acf:	ff d6                	call   *%esi
  800ad1:	83 c4 10             	add    $0x10,%esp
  800ad4:	eb dc                	jmp    800ab2 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800ad6:	83 f9 01             	cmp    $0x1,%ecx
  800ad9:	7f 1b                	jg     800af6 <vprintfmt+0x3ed>
	else if (lflag)
  800adb:	85 c9                	test   %ecx,%ecx
  800add:	74 2c                	je     800b0b <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800adf:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae2:	8b 10                	mov    (%eax),%edx
  800ae4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae9:	8d 40 04             	lea    0x4(%eax),%eax
  800aec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800aef:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800af4:	eb 9f                	jmp    800a95 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800af6:	8b 45 14             	mov    0x14(%ebp),%eax
  800af9:	8b 10                	mov    (%eax),%edx
  800afb:	8b 48 04             	mov    0x4(%eax),%ecx
  800afe:	8d 40 08             	lea    0x8(%eax),%eax
  800b01:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800b04:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800b09:	eb 8a                	jmp    800a95 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800b0b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b0e:	8b 10                	mov    (%eax),%edx
  800b10:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b15:	8d 40 04             	lea    0x4(%eax),%eax
  800b18:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800b1b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800b20:	e9 70 ff ff ff       	jmp    800a95 <vprintfmt+0x38c>
			putch(ch, putdat);
  800b25:	83 ec 08             	sub    $0x8,%esp
  800b28:	53                   	push   %ebx
  800b29:	6a 25                	push   $0x25
  800b2b:	ff d6                	call   *%esi
			break;
  800b2d:	83 c4 10             	add    $0x10,%esp
  800b30:	e9 7a ff ff ff       	jmp    800aaf <vprintfmt+0x3a6>
			putch('%', putdat);
  800b35:	83 ec 08             	sub    $0x8,%esp
  800b38:	53                   	push   %ebx
  800b39:	6a 25                	push   $0x25
  800b3b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800b3d:	83 c4 10             	add    $0x10,%esp
  800b40:	89 f8                	mov    %edi,%eax
  800b42:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800b46:	74 05                	je     800b4d <vprintfmt+0x444>
  800b48:	83 e8 01             	sub    $0x1,%eax
  800b4b:	eb f5                	jmp    800b42 <vprintfmt+0x439>
  800b4d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b50:	e9 5a ff ff ff       	jmp    800aaf <vprintfmt+0x3a6>
}
  800b55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b5d:	f3 0f 1e fb          	endbr32 
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	83 ec 18             	sub    $0x18,%esp
  800b67:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b70:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b74:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b77:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b7e:	85 c0                	test   %eax,%eax
  800b80:	74 26                	je     800ba8 <vsnprintf+0x4b>
  800b82:	85 d2                	test   %edx,%edx
  800b84:	7e 22                	jle    800ba8 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b86:	ff 75 14             	pushl  0x14(%ebp)
  800b89:	ff 75 10             	pushl  0x10(%ebp)
  800b8c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b8f:	50                   	push   %eax
  800b90:	68 c7 06 80 00       	push   $0x8006c7
  800b95:	e8 6f fb ff ff       	call   800709 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b9d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ba3:	83 c4 10             	add    $0x10,%esp
}
  800ba6:	c9                   	leave  
  800ba7:	c3                   	ret    
		return -E_INVAL;
  800ba8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bad:	eb f7                	jmp    800ba6 <vsnprintf+0x49>

00800baf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800baf:	f3 0f 1e fb          	endbr32 
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  800bb9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800bbc:	50                   	push   %eax
  800bbd:	ff 75 10             	pushl  0x10(%ebp)
  800bc0:	ff 75 0c             	pushl  0xc(%ebp)
  800bc3:	ff 75 08             	pushl  0x8(%ebp)
  800bc6:	e8 92 ff ff ff       	call   800b5d <vsnprintf>
	va_end(ap);

	return rc;
}
  800bcb:	c9                   	leave  
  800bcc:	c3                   	ret    

00800bcd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bcd:	f3 0f 1e fb          	endbr32 
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800bd7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bdc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800be0:	74 05                	je     800be7 <strlen+0x1a>
		n++;
  800be2:	83 c0 01             	add    $0x1,%eax
  800be5:	eb f5                	jmp    800bdc <strlen+0xf>
	return n;
}
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800be9:	f3 0f 1e fb          	endbr32 
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bf6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfb:	39 d0                	cmp    %edx,%eax
  800bfd:	74 0d                	je     800c0c <strnlen+0x23>
  800bff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c03:	74 05                	je     800c0a <strnlen+0x21>
		n++;
  800c05:	83 c0 01             	add    $0x1,%eax
  800c08:	eb f1                	jmp    800bfb <strnlen+0x12>
  800c0a:	89 c2                	mov    %eax,%edx
	return n;
}
  800c0c:	89 d0                	mov    %edx,%eax
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c10:	f3 0f 1e fb          	endbr32 
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	53                   	push   %ebx
  800c18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c23:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800c27:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800c2a:	83 c0 01             	add    $0x1,%eax
  800c2d:	84 d2                	test   %dl,%dl
  800c2f:	75 f2                	jne    800c23 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800c31:	89 c8                	mov    %ecx,%eax
  800c33:	5b                   	pop    %ebx
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c36:	f3 0f 1e fb          	endbr32 
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	53                   	push   %ebx
  800c3e:	83 ec 10             	sub    $0x10,%esp
  800c41:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c44:	53                   	push   %ebx
  800c45:	e8 83 ff ff ff       	call   800bcd <strlen>
  800c4a:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800c4d:	ff 75 0c             	pushl  0xc(%ebp)
  800c50:	01 d8                	add    %ebx,%eax
  800c52:	50                   	push   %eax
  800c53:	e8 b8 ff ff ff       	call   800c10 <strcpy>
	return dst;
}
  800c58:	89 d8                	mov    %ebx,%eax
  800c5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c5d:	c9                   	leave  
  800c5e:	c3                   	ret    

00800c5f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c5f:	f3 0f 1e fb          	endbr32 
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
  800c68:	8b 75 08             	mov    0x8(%ebp),%esi
  800c6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c6e:	89 f3                	mov    %esi,%ebx
  800c70:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c73:	89 f0                	mov    %esi,%eax
  800c75:	39 d8                	cmp    %ebx,%eax
  800c77:	74 11                	je     800c8a <strncpy+0x2b>
		*dst++ = *src;
  800c79:	83 c0 01             	add    $0x1,%eax
  800c7c:	0f b6 0a             	movzbl (%edx),%ecx
  800c7f:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c82:	80 f9 01             	cmp    $0x1,%cl
  800c85:	83 da ff             	sbb    $0xffffffff,%edx
  800c88:	eb eb                	jmp    800c75 <strncpy+0x16>
	}
	return ret;
}
  800c8a:	89 f0                	mov    %esi,%eax
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c90:	f3 0f 1e fb          	endbr32 
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	8b 75 08             	mov    0x8(%ebp),%esi
  800c9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9f:	8b 55 10             	mov    0x10(%ebp),%edx
  800ca2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ca4:	85 d2                	test   %edx,%edx
  800ca6:	74 21                	je     800cc9 <strlcpy+0x39>
  800ca8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800cac:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800cae:	39 c2                	cmp    %eax,%edx
  800cb0:	74 14                	je     800cc6 <strlcpy+0x36>
  800cb2:	0f b6 19             	movzbl (%ecx),%ebx
  800cb5:	84 db                	test   %bl,%bl
  800cb7:	74 0b                	je     800cc4 <strlcpy+0x34>
			*dst++ = *src++;
  800cb9:	83 c1 01             	add    $0x1,%ecx
  800cbc:	83 c2 01             	add    $0x1,%edx
  800cbf:	88 5a ff             	mov    %bl,-0x1(%edx)
  800cc2:	eb ea                	jmp    800cae <strlcpy+0x1e>
  800cc4:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800cc6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800cc9:	29 f0                	sub    %esi,%eax
}
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ccf:	f3 0f 1e fb          	endbr32 
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800cdc:	0f b6 01             	movzbl (%ecx),%eax
  800cdf:	84 c0                	test   %al,%al
  800ce1:	74 0c                	je     800cef <strcmp+0x20>
  800ce3:	3a 02                	cmp    (%edx),%al
  800ce5:	75 08                	jne    800cef <strcmp+0x20>
		p++, q++;
  800ce7:	83 c1 01             	add    $0x1,%ecx
  800cea:	83 c2 01             	add    $0x1,%edx
  800ced:	eb ed                	jmp    800cdc <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800cef:	0f b6 c0             	movzbl %al,%eax
  800cf2:	0f b6 12             	movzbl (%edx),%edx
  800cf5:	29 d0                	sub    %edx,%eax
}
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cf9:	f3 0f 1e fb          	endbr32 
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	53                   	push   %ebx
  800d01:	8b 45 08             	mov    0x8(%ebp),%eax
  800d04:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d07:	89 c3                	mov    %eax,%ebx
  800d09:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d0c:	eb 06                	jmp    800d14 <strncmp+0x1b>
		n--, p++, q++;
  800d0e:	83 c0 01             	add    $0x1,%eax
  800d11:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800d14:	39 d8                	cmp    %ebx,%eax
  800d16:	74 16                	je     800d2e <strncmp+0x35>
  800d18:	0f b6 08             	movzbl (%eax),%ecx
  800d1b:	84 c9                	test   %cl,%cl
  800d1d:	74 04                	je     800d23 <strncmp+0x2a>
  800d1f:	3a 0a                	cmp    (%edx),%cl
  800d21:	74 eb                	je     800d0e <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d23:	0f b6 00             	movzbl (%eax),%eax
  800d26:	0f b6 12             	movzbl (%edx),%edx
  800d29:	29 d0                	sub    %edx,%eax
}
  800d2b:	5b                   	pop    %ebx
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    
		return 0;
  800d2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d33:	eb f6                	jmp    800d2b <strncmp+0x32>

00800d35 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d35:	f3 0f 1e fb          	endbr32 
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d43:	0f b6 10             	movzbl (%eax),%edx
  800d46:	84 d2                	test   %dl,%dl
  800d48:	74 09                	je     800d53 <strchr+0x1e>
		if (*s == c)
  800d4a:	38 ca                	cmp    %cl,%dl
  800d4c:	74 0a                	je     800d58 <strchr+0x23>
	for (; *s; s++)
  800d4e:	83 c0 01             	add    $0x1,%eax
  800d51:	eb f0                	jmp    800d43 <strchr+0xe>
			return (char *) s;
	return 0;
  800d53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800d5a:	f3 0f 1e fb          	endbr32 
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800d64:	6a 78                	push   $0x78
  800d66:	ff 75 08             	pushl  0x8(%ebp)
  800d69:	e8 c7 ff ff ff       	call   800d35 <strchr>
  800d6e:	83 c4 10             	add    $0x10,%esp
  800d71:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  800d74:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800d79:	eb 0d                	jmp    800d88 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800d7b:	c1 e0 04             	shl    $0x4,%eax
  800d7e:	0f be d2             	movsbl %dl,%edx
  800d81:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800d85:	83 c1 01             	add    $0x1,%ecx
  800d88:	0f b6 11             	movzbl (%ecx),%edx
  800d8b:	84 d2                	test   %dl,%dl
  800d8d:	74 11                	je     800da0 <atox+0x46>
		if (*p>='a'){
  800d8f:	80 fa 60             	cmp    $0x60,%dl
  800d92:	7e e7                	jle    800d7b <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800d94:	c1 e0 04             	shl    $0x4,%eax
  800d97:	0f be d2             	movsbl %dl,%edx
  800d9a:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800d9e:	eb e5                	jmp    800d85 <atox+0x2b>
	}

	return v;

}
  800da0:	c9                   	leave  
  800da1:	c3                   	ret    

00800da2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800da2:	f3 0f 1e fb          	endbr32 
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800db0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800db3:	38 ca                	cmp    %cl,%dl
  800db5:	74 09                	je     800dc0 <strfind+0x1e>
  800db7:	84 d2                	test   %dl,%dl
  800db9:	74 05                	je     800dc0 <strfind+0x1e>
	for (; *s; s++)
  800dbb:	83 c0 01             	add    $0x1,%eax
  800dbe:	eb f0                	jmp    800db0 <strfind+0xe>
			break;
	return (char *) s;
}
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800dc2:	f3 0f 1e fb          	endbr32 
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	57                   	push   %edi
  800dca:	56                   	push   %esi
  800dcb:	53                   	push   %ebx
  800dcc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dcf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800dd2:	85 c9                	test   %ecx,%ecx
  800dd4:	74 31                	je     800e07 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dd6:	89 f8                	mov    %edi,%eax
  800dd8:	09 c8                	or     %ecx,%eax
  800dda:	a8 03                	test   $0x3,%al
  800ddc:	75 23                	jne    800e01 <memset+0x3f>
		c &= 0xFF;
  800dde:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800de2:	89 d3                	mov    %edx,%ebx
  800de4:	c1 e3 08             	shl    $0x8,%ebx
  800de7:	89 d0                	mov    %edx,%eax
  800de9:	c1 e0 18             	shl    $0x18,%eax
  800dec:	89 d6                	mov    %edx,%esi
  800dee:	c1 e6 10             	shl    $0x10,%esi
  800df1:	09 f0                	or     %esi,%eax
  800df3:	09 c2                	or     %eax,%edx
  800df5:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800df7:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800dfa:	89 d0                	mov    %edx,%eax
  800dfc:	fc                   	cld    
  800dfd:	f3 ab                	rep stos %eax,%es:(%edi)
  800dff:	eb 06                	jmp    800e07 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e04:	fc                   	cld    
  800e05:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e07:	89 f8                	mov    %edi,%eax
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e0e:	f3 0f 1e fb          	endbr32 
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e1d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e20:	39 c6                	cmp    %eax,%esi
  800e22:	73 32                	jae    800e56 <memmove+0x48>
  800e24:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e27:	39 c2                	cmp    %eax,%edx
  800e29:	76 2b                	jbe    800e56 <memmove+0x48>
		s += n;
		d += n;
  800e2b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e2e:	89 fe                	mov    %edi,%esi
  800e30:	09 ce                	or     %ecx,%esi
  800e32:	09 d6                	or     %edx,%esi
  800e34:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e3a:	75 0e                	jne    800e4a <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e3c:	83 ef 04             	sub    $0x4,%edi
  800e3f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e42:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800e45:	fd                   	std    
  800e46:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e48:	eb 09                	jmp    800e53 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e4a:	83 ef 01             	sub    $0x1,%edi
  800e4d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800e50:	fd                   	std    
  800e51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e53:	fc                   	cld    
  800e54:	eb 1a                	jmp    800e70 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e56:	89 c2                	mov    %eax,%edx
  800e58:	09 ca                	or     %ecx,%edx
  800e5a:	09 f2                	or     %esi,%edx
  800e5c:	f6 c2 03             	test   $0x3,%dl
  800e5f:	75 0a                	jne    800e6b <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e61:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800e64:	89 c7                	mov    %eax,%edi
  800e66:	fc                   	cld    
  800e67:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e69:	eb 05                	jmp    800e70 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800e6b:	89 c7                	mov    %eax,%edi
  800e6d:	fc                   	cld    
  800e6e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e70:	5e                   	pop    %esi
  800e71:	5f                   	pop    %edi
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e74:	f3 0f 1e fb          	endbr32 
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e7e:	ff 75 10             	pushl  0x10(%ebp)
  800e81:	ff 75 0c             	pushl  0xc(%ebp)
  800e84:	ff 75 08             	pushl  0x8(%ebp)
  800e87:	e8 82 ff ff ff       	call   800e0e <memmove>
}
  800e8c:	c9                   	leave  
  800e8d:	c3                   	ret    

00800e8e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e8e:	f3 0f 1e fb          	endbr32 
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	56                   	push   %esi
  800e96:	53                   	push   %ebx
  800e97:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e9d:	89 c6                	mov    %eax,%esi
  800e9f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ea2:	39 f0                	cmp    %esi,%eax
  800ea4:	74 1c                	je     800ec2 <memcmp+0x34>
		if (*s1 != *s2)
  800ea6:	0f b6 08             	movzbl (%eax),%ecx
  800ea9:	0f b6 1a             	movzbl (%edx),%ebx
  800eac:	38 d9                	cmp    %bl,%cl
  800eae:	75 08                	jne    800eb8 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800eb0:	83 c0 01             	add    $0x1,%eax
  800eb3:	83 c2 01             	add    $0x1,%edx
  800eb6:	eb ea                	jmp    800ea2 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800eb8:	0f b6 c1             	movzbl %cl,%eax
  800ebb:	0f b6 db             	movzbl %bl,%ebx
  800ebe:	29 d8                	sub    %ebx,%eax
  800ec0:	eb 05                	jmp    800ec7 <memcmp+0x39>
	}

	return 0;
  800ec2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ec7:	5b                   	pop    %ebx
  800ec8:	5e                   	pop    %esi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ecb:	f3 0f 1e fb          	endbr32 
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ed8:	89 c2                	mov    %eax,%edx
  800eda:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800edd:	39 d0                	cmp    %edx,%eax
  800edf:	73 09                	jae    800eea <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ee1:	38 08                	cmp    %cl,(%eax)
  800ee3:	74 05                	je     800eea <memfind+0x1f>
	for (; s < ends; s++)
  800ee5:	83 c0 01             	add    $0x1,%eax
  800ee8:	eb f3                	jmp    800edd <memfind+0x12>
			break;
	return (void *) s;
}
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800eec:	f3 0f 1e fb          	endbr32 
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	57                   	push   %edi
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
  800ef6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800efc:	eb 03                	jmp    800f01 <strtol+0x15>
		s++;
  800efe:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800f01:	0f b6 01             	movzbl (%ecx),%eax
  800f04:	3c 20                	cmp    $0x20,%al
  800f06:	74 f6                	je     800efe <strtol+0x12>
  800f08:	3c 09                	cmp    $0x9,%al
  800f0a:	74 f2                	je     800efe <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800f0c:	3c 2b                	cmp    $0x2b,%al
  800f0e:	74 2a                	je     800f3a <strtol+0x4e>
	int neg = 0;
  800f10:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800f15:	3c 2d                	cmp    $0x2d,%al
  800f17:	74 2b                	je     800f44 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f19:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f1f:	75 0f                	jne    800f30 <strtol+0x44>
  800f21:	80 39 30             	cmpb   $0x30,(%ecx)
  800f24:	74 28                	je     800f4e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f26:	85 db                	test   %ebx,%ebx
  800f28:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f2d:	0f 44 d8             	cmove  %eax,%ebx
  800f30:	b8 00 00 00 00       	mov    $0x0,%eax
  800f35:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800f38:	eb 46                	jmp    800f80 <strtol+0x94>
		s++;
  800f3a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800f3d:	bf 00 00 00 00       	mov    $0x0,%edi
  800f42:	eb d5                	jmp    800f19 <strtol+0x2d>
		s++, neg = 1;
  800f44:	83 c1 01             	add    $0x1,%ecx
  800f47:	bf 01 00 00 00       	mov    $0x1,%edi
  800f4c:	eb cb                	jmp    800f19 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f4e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f52:	74 0e                	je     800f62 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800f54:	85 db                	test   %ebx,%ebx
  800f56:	75 d8                	jne    800f30 <strtol+0x44>
		s++, base = 8;
  800f58:	83 c1 01             	add    $0x1,%ecx
  800f5b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800f60:	eb ce                	jmp    800f30 <strtol+0x44>
		s += 2, base = 16;
  800f62:	83 c1 02             	add    $0x2,%ecx
  800f65:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f6a:	eb c4                	jmp    800f30 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800f6c:	0f be d2             	movsbl %dl,%edx
  800f6f:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f72:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f75:	7d 3a                	jge    800fb1 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800f77:	83 c1 01             	add    $0x1,%ecx
  800f7a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f7e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800f80:	0f b6 11             	movzbl (%ecx),%edx
  800f83:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f86:	89 f3                	mov    %esi,%ebx
  800f88:	80 fb 09             	cmp    $0x9,%bl
  800f8b:	76 df                	jbe    800f6c <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800f8d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f90:	89 f3                	mov    %esi,%ebx
  800f92:	80 fb 19             	cmp    $0x19,%bl
  800f95:	77 08                	ja     800f9f <strtol+0xb3>
			dig = *s - 'a' + 10;
  800f97:	0f be d2             	movsbl %dl,%edx
  800f9a:	83 ea 57             	sub    $0x57,%edx
  800f9d:	eb d3                	jmp    800f72 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800f9f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800fa2:	89 f3                	mov    %esi,%ebx
  800fa4:	80 fb 19             	cmp    $0x19,%bl
  800fa7:	77 08                	ja     800fb1 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800fa9:	0f be d2             	movsbl %dl,%edx
  800fac:	83 ea 37             	sub    $0x37,%edx
  800faf:	eb c1                	jmp    800f72 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800fb1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fb5:	74 05                	je     800fbc <strtol+0xd0>
		*endptr = (char *) s;
  800fb7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fba:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800fbc:	89 c2                	mov    %eax,%edx
  800fbe:	f7 da                	neg    %edx
  800fc0:	85 ff                	test   %edi,%edi
  800fc2:	0f 45 c2             	cmovne %edx,%eax
}
  800fc5:	5b                   	pop    %ebx
  800fc6:	5e                   	pop    %esi
  800fc7:	5f                   	pop    %edi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fca:	f3 0f 1e fb          	endbr32 
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	57                   	push   %edi
  800fd2:	56                   	push   %esi
  800fd3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fdf:	89 c3                	mov    %eax,%ebx
  800fe1:	89 c7                	mov    %eax,%edi
  800fe3:	89 c6                	mov    %eax,%esi
  800fe5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fe7:	5b                   	pop    %ebx
  800fe8:	5e                   	pop    %esi
  800fe9:	5f                   	pop    %edi
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    

00800fec <sys_cgetc>:

int
sys_cgetc(void)
{
  800fec:	f3 0f 1e fb          	endbr32 
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	57                   	push   %edi
  800ff4:	56                   	push   %esi
  800ff5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ff6:	ba 00 00 00 00       	mov    $0x0,%edx
  800ffb:	b8 01 00 00 00       	mov    $0x1,%eax
  801000:	89 d1                	mov    %edx,%ecx
  801002:	89 d3                	mov    %edx,%ebx
  801004:	89 d7                	mov    %edx,%edi
  801006:	89 d6                	mov    %edx,%esi
  801008:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80100a:	5b                   	pop    %ebx
  80100b:	5e                   	pop    %esi
  80100c:	5f                   	pop    %edi
  80100d:	5d                   	pop    %ebp
  80100e:	c3                   	ret    

0080100f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80100f:	f3 0f 1e fb          	endbr32 
  801013:	55                   	push   %ebp
  801014:	89 e5                	mov    %esp,%ebp
  801016:	57                   	push   %edi
  801017:	56                   	push   %esi
  801018:	53                   	push   %ebx
	asm volatile("int %1\n"
  801019:	b9 00 00 00 00       	mov    $0x0,%ecx
  80101e:	8b 55 08             	mov    0x8(%ebp),%edx
  801021:	b8 03 00 00 00       	mov    $0x3,%eax
  801026:	89 cb                	mov    %ecx,%ebx
  801028:	89 cf                	mov    %ecx,%edi
  80102a:	89 ce                	mov    %ecx,%esi
  80102c:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80102e:	5b                   	pop    %ebx
  80102f:	5e                   	pop    %esi
  801030:	5f                   	pop    %edi
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801033:	f3 0f 1e fb          	endbr32 
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	57                   	push   %edi
  80103b:	56                   	push   %esi
  80103c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80103d:	ba 00 00 00 00       	mov    $0x0,%edx
  801042:	b8 02 00 00 00       	mov    $0x2,%eax
  801047:	89 d1                	mov    %edx,%ecx
  801049:	89 d3                	mov    %edx,%ebx
  80104b:	89 d7                	mov    %edx,%edi
  80104d:	89 d6                	mov    %edx,%esi
  80104f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801051:	5b                   	pop    %ebx
  801052:	5e                   	pop    %esi
  801053:	5f                   	pop    %edi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <sys_yield>:

void
sys_yield(void)
{
  801056:	f3 0f 1e fb          	endbr32 
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	57                   	push   %edi
  80105e:	56                   	push   %esi
  80105f:	53                   	push   %ebx
	asm volatile("int %1\n"
  801060:	ba 00 00 00 00       	mov    $0x0,%edx
  801065:	b8 0b 00 00 00       	mov    $0xb,%eax
  80106a:	89 d1                	mov    %edx,%ecx
  80106c:	89 d3                	mov    %edx,%ebx
  80106e:	89 d7                	mov    %edx,%edi
  801070:	89 d6                	mov    %edx,%esi
  801072:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801074:	5b                   	pop    %ebx
  801075:	5e                   	pop    %esi
  801076:	5f                   	pop    %edi
  801077:	5d                   	pop    %ebp
  801078:	c3                   	ret    

00801079 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801079:	f3 0f 1e fb          	endbr32 
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	57                   	push   %edi
  801081:	56                   	push   %esi
  801082:	53                   	push   %ebx
	asm volatile("int %1\n"
  801083:	be 00 00 00 00       	mov    $0x0,%esi
  801088:	8b 55 08             	mov    0x8(%ebp),%edx
  80108b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80108e:	b8 04 00 00 00       	mov    $0x4,%eax
  801093:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801096:	89 f7                	mov    %esi,%edi
  801098:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80109a:	5b                   	pop    %ebx
  80109b:	5e                   	pop    %esi
  80109c:	5f                   	pop    %edi
  80109d:	5d                   	pop    %ebp
  80109e:	c3                   	ret    

0080109f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80109f:	f3 0f 1e fb          	endbr32 
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	57                   	push   %edi
  8010a7:	56                   	push   %esi
  8010a8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010af:	b8 05 00 00 00       	mov    $0x5,%eax
  8010b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010b7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ba:	8b 75 18             	mov    0x18(%ebp),%esi
  8010bd:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010bf:	5b                   	pop    %ebx
  8010c0:	5e                   	pop    %esi
  8010c1:	5f                   	pop    %edi
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    

008010c4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010c4:	f3 0f 1e fb          	endbr32 
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	57                   	push   %edi
  8010cc:	56                   	push   %esi
  8010cd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010d9:	b8 06 00 00 00       	mov    $0x6,%eax
  8010de:	89 df                	mov    %ebx,%edi
  8010e0:	89 de                	mov    %ebx,%esi
  8010e2:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8010e4:	5b                   	pop    %ebx
  8010e5:	5e                   	pop    %esi
  8010e6:	5f                   	pop    %edi
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010e9:	f3 0f 1e fb          	endbr32 
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	57                   	push   %edi
  8010f1:	56                   	push   %esi
  8010f2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010fe:	b8 08 00 00 00       	mov    $0x8,%eax
  801103:	89 df                	mov    %ebx,%edi
  801105:	89 de                	mov    %ebx,%esi
  801107:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801109:	5b                   	pop    %ebx
  80110a:	5e                   	pop    %esi
  80110b:	5f                   	pop    %edi
  80110c:	5d                   	pop    %ebp
  80110d:	c3                   	ret    

0080110e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80110e:	f3 0f 1e fb          	endbr32 
  801112:	55                   	push   %ebp
  801113:	89 e5                	mov    %esp,%ebp
  801115:	57                   	push   %edi
  801116:	56                   	push   %esi
  801117:	53                   	push   %ebx
	asm volatile("int %1\n"
  801118:	bb 00 00 00 00       	mov    $0x0,%ebx
  80111d:	8b 55 08             	mov    0x8(%ebp),%edx
  801120:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801123:	b8 09 00 00 00       	mov    $0x9,%eax
  801128:	89 df                	mov    %ebx,%edi
  80112a:	89 de                	mov    %ebx,%esi
  80112c:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80112e:	5b                   	pop    %ebx
  80112f:	5e                   	pop    %esi
  801130:	5f                   	pop    %edi
  801131:	5d                   	pop    %ebp
  801132:	c3                   	ret    

00801133 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801133:	f3 0f 1e fb          	endbr32 
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	57                   	push   %edi
  80113b:	56                   	push   %esi
  80113c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80113d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801142:	8b 55 08             	mov    0x8(%ebp),%edx
  801145:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801148:	b8 0a 00 00 00       	mov    $0xa,%eax
  80114d:	89 df                	mov    %ebx,%edi
  80114f:	89 de                	mov    %ebx,%esi
  801151:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801153:	5b                   	pop    %ebx
  801154:	5e                   	pop    %esi
  801155:	5f                   	pop    %edi
  801156:	5d                   	pop    %ebp
  801157:	c3                   	ret    

00801158 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801158:	f3 0f 1e fb          	endbr32 
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	57                   	push   %edi
  801160:	56                   	push   %esi
  801161:	53                   	push   %ebx
	asm volatile("int %1\n"
  801162:	8b 55 08             	mov    0x8(%ebp),%edx
  801165:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801168:	b8 0c 00 00 00       	mov    $0xc,%eax
  80116d:	be 00 00 00 00       	mov    $0x0,%esi
  801172:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801175:	8b 7d 14             	mov    0x14(%ebp),%edi
  801178:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80117a:	5b                   	pop    %ebx
  80117b:	5e                   	pop    %esi
  80117c:	5f                   	pop    %edi
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    

0080117f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80117f:	f3 0f 1e fb          	endbr32 
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
  801186:	57                   	push   %edi
  801187:	56                   	push   %esi
  801188:	53                   	push   %ebx
	asm volatile("int %1\n"
  801189:	b9 00 00 00 00       	mov    $0x0,%ecx
  80118e:	8b 55 08             	mov    0x8(%ebp),%edx
  801191:	b8 0d 00 00 00       	mov    $0xd,%eax
  801196:	89 cb                	mov    %ecx,%ebx
  801198:	89 cf                	mov    %ecx,%edi
  80119a:	89 ce                	mov    %ecx,%esi
  80119c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80119e:	5b                   	pop    %ebx
  80119f:	5e                   	pop    %esi
  8011a0:	5f                   	pop    %edi
  8011a1:	5d                   	pop    %ebp
  8011a2:	c3                   	ret    

008011a3 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8011a3:	f3 0f 1e fb          	endbr32 
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
  8011aa:	57                   	push   %edi
  8011ab:	56                   	push   %esi
  8011ac:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b2:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011b7:	89 d1                	mov    %edx,%ecx
  8011b9:	89 d3                	mov    %edx,%ebx
  8011bb:	89 d7                	mov    %edx,%edi
  8011bd:	89 d6                	mov    %edx,%esi
  8011bf:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8011c1:	5b                   	pop    %ebx
  8011c2:	5e                   	pop    %esi
  8011c3:	5f                   	pop    %edi
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    

008011c6 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  8011c6:	f3 0f 1e fb          	endbr32 
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
  8011cd:	57                   	push   %edi
  8011ce:	56                   	push   %esi
  8011cf:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011db:	b8 0f 00 00 00       	mov    $0xf,%eax
  8011e0:	89 df                	mov    %ebx,%edi
  8011e2:	89 de                	mov    %ebx,%esi
  8011e4:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  8011e6:	5b                   	pop    %ebx
  8011e7:	5e                   	pop    %esi
  8011e8:	5f                   	pop    %edi
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    

008011eb <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  8011eb:	f3 0f 1e fb          	endbr32 
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	57                   	push   %edi
  8011f3:	56                   	push   %esi
  8011f4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801200:	b8 10 00 00 00       	mov    $0x10,%eax
  801205:	89 df                	mov    %ebx,%edi
  801207:	89 de                	mov    %ebx,%esi
  801209:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  80120b:	5b                   	pop    %ebx
  80120c:	5e                   	pop    %esi
  80120d:	5f                   	pop    %edi
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801210:	f3 0f 1e fb          	endbr32 
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801217:	8b 45 08             	mov    0x8(%ebp),%eax
  80121a:	05 00 00 00 30       	add    $0x30000000,%eax
  80121f:	c1 e8 0c             	shr    $0xc,%eax
}
  801222:	5d                   	pop    %ebp
  801223:	c3                   	ret    

00801224 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801224:	f3 0f 1e fb          	endbr32 
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80122b:	8b 45 08             	mov    0x8(%ebp),%eax
  80122e:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801233:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801238:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80123d:	5d                   	pop    %ebp
  80123e:	c3                   	ret    

0080123f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80123f:	f3 0f 1e fb          	endbr32 
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80124b:	89 c2                	mov    %eax,%edx
  80124d:	c1 ea 16             	shr    $0x16,%edx
  801250:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801257:	f6 c2 01             	test   $0x1,%dl
  80125a:	74 2d                	je     801289 <fd_alloc+0x4a>
  80125c:	89 c2                	mov    %eax,%edx
  80125e:	c1 ea 0c             	shr    $0xc,%edx
  801261:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801268:	f6 c2 01             	test   $0x1,%dl
  80126b:	74 1c                	je     801289 <fd_alloc+0x4a>
  80126d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801272:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801277:	75 d2                	jne    80124b <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  801279:	8b 45 08             	mov    0x8(%ebp),%eax
  80127c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801282:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801287:	eb 0a                	jmp    801293 <fd_alloc+0x54>
			*fd_store = fd;
  801289:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80128c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80128e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801293:	5d                   	pop    %ebp
  801294:	c3                   	ret    

00801295 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801295:	f3 0f 1e fb          	endbr32 
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80129f:	83 f8 1f             	cmp    $0x1f,%eax
  8012a2:	77 30                	ja     8012d4 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012a4:	c1 e0 0c             	shl    $0xc,%eax
  8012a7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012ac:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8012b2:	f6 c2 01             	test   $0x1,%dl
  8012b5:	74 24                	je     8012db <fd_lookup+0x46>
  8012b7:	89 c2                	mov    %eax,%edx
  8012b9:	c1 ea 0c             	shr    $0xc,%edx
  8012bc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012c3:	f6 c2 01             	test   $0x1,%dl
  8012c6:	74 1a                	je     8012e2 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012cb:	89 02                	mov    %eax,(%edx)
	return 0;
  8012cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012d2:	5d                   	pop    %ebp
  8012d3:	c3                   	ret    
		return -E_INVAL;
  8012d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d9:	eb f7                	jmp    8012d2 <fd_lookup+0x3d>
		return -E_INVAL;
  8012db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e0:	eb f0                	jmp    8012d2 <fd_lookup+0x3d>
  8012e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e7:	eb e9                	jmp    8012d2 <fd_lookup+0x3d>

008012e9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012e9:	f3 0f 1e fb          	endbr32 
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	83 ec 08             	sub    $0x8,%esp
  8012f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8012f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8012fb:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  801300:	39 08                	cmp    %ecx,(%eax)
  801302:	74 38                	je     80133c <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  801304:	83 c2 01             	add    $0x1,%edx
  801307:	8b 04 95 dc 2c 80 00 	mov    0x802cdc(,%edx,4),%eax
  80130e:	85 c0                	test   %eax,%eax
  801310:	75 ee                	jne    801300 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801312:	a1 18 40 80 00       	mov    0x804018,%eax
  801317:	8b 40 48             	mov    0x48(%eax),%eax
  80131a:	83 ec 04             	sub    $0x4,%esp
  80131d:	51                   	push   %ecx
  80131e:	50                   	push   %eax
  80131f:	68 60 2c 80 00       	push   $0x802c60
  801324:	e8 dd f2 ff ff       	call   800606 <cprintf>
	*dev = 0;
  801329:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801332:	83 c4 10             	add    $0x10,%esp
  801335:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80133a:	c9                   	leave  
  80133b:	c3                   	ret    
			*dev = devtab[i];
  80133c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80133f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801341:	b8 00 00 00 00       	mov    $0x0,%eax
  801346:	eb f2                	jmp    80133a <dev_lookup+0x51>

00801348 <fd_close>:
{
  801348:	f3 0f 1e fb          	endbr32 
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	57                   	push   %edi
  801350:	56                   	push   %esi
  801351:	53                   	push   %ebx
  801352:	83 ec 24             	sub    $0x24,%esp
  801355:	8b 75 08             	mov    0x8(%ebp),%esi
  801358:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80135b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80135e:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80135f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801365:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801368:	50                   	push   %eax
  801369:	e8 27 ff ff ff       	call   801295 <fd_lookup>
  80136e:	89 c3                	mov    %eax,%ebx
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	85 c0                	test   %eax,%eax
  801375:	78 05                	js     80137c <fd_close+0x34>
	    || fd != fd2)
  801377:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80137a:	74 16                	je     801392 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80137c:	89 f8                	mov    %edi,%eax
  80137e:	84 c0                	test   %al,%al
  801380:	b8 00 00 00 00       	mov    $0x0,%eax
  801385:	0f 44 d8             	cmove  %eax,%ebx
}
  801388:	89 d8                	mov    %ebx,%eax
  80138a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80138d:	5b                   	pop    %ebx
  80138e:	5e                   	pop    %esi
  80138f:	5f                   	pop    %edi
  801390:	5d                   	pop    %ebp
  801391:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801392:	83 ec 08             	sub    $0x8,%esp
  801395:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801398:	50                   	push   %eax
  801399:	ff 36                	pushl  (%esi)
  80139b:	e8 49 ff ff ff       	call   8012e9 <dev_lookup>
  8013a0:	89 c3                	mov    %eax,%ebx
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	78 1a                	js     8013c3 <fd_close+0x7b>
		if (dev->dev_close)
  8013a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013ac:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8013af:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	74 0b                	je     8013c3 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8013b8:	83 ec 0c             	sub    $0xc,%esp
  8013bb:	56                   	push   %esi
  8013bc:	ff d0                	call   *%eax
  8013be:	89 c3                	mov    %eax,%ebx
  8013c0:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8013c3:	83 ec 08             	sub    $0x8,%esp
  8013c6:	56                   	push   %esi
  8013c7:	6a 00                	push   $0x0
  8013c9:	e8 f6 fc ff ff       	call   8010c4 <sys_page_unmap>
	return r;
  8013ce:	83 c4 10             	add    $0x10,%esp
  8013d1:	eb b5                	jmp    801388 <fd_close+0x40>

008013d3 <close>:

int
close(int fdnum)
{
  8013d3:	f3 0f 1e fb          	endbr32 
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e0:	50                   	push   %eax
  8013e1:	ff 75 08             	pushl  0x8(%ebp)
  8013e4:	e8 ac fe ff ff       	call   801295 <fd_lookup>
  8013e9:	83 c4 10             	add    $0x10,%esp
  8013ec:	85 c0                	test   %eax,%eax
  8013ee:	79 02                	jns    8013f2 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8013f0:	c9                   	leave  
  8013f1:	c3                   	ret    
		return fd_close(fd, 1);
  8013f2:	83 ec 08             	sub    $0x8,%esp
  8013f5:	6a 01                	push   $0x1
  8013f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8013fa:	e8 49 ff ff ff       	call   801348 <fd_close>
  8013ff:	83 c4 10             	add    $0x10,%esp
  801402:	eb ec                	jmp    8013f0 <close+0x1d>

00801404 <close_all>:

void
close_all(void)
{
  801404:	f3 0f 1e fb          	endbr32 
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	53                   	push   %ebx
  80140c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80140f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801414:	83 ec 0c             	sub    $0xc,%esp
  801417:	53                   	push   %ebx
  801418:	e8 b6 ff ff ff       	call   8013d3 <close>
	for (i = 0; i < MAXFD; i++)
  80141d:	83 c3 01             	add    $0x1,%ebx
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	83 fb 20             	cmp    $0x20,%ebx
  801426:	75 ec                	jne    801414 <close_all+0x10>
}
  801428:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142b:	c9                   	leave  
  80142c:	c3                   	ret    

0080142d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80142d:	f3 0f 1e fb          	endbr32 
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	57                   	push   %edi
  801435:	56                   	push   %esi
  801436:	53                   	push   %ebx
  801437:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80143a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80143d:	50                   	push   %eax
  80143e:	ff 75 08             	pushl  0x8(%ebp)
  801441:	e8 4f fe ff ff       	call   801295 <fd_lookup>
  801446:	89 c3                	mov    %eax,%ebx
  801448:	83 c4 10             	add    $0x10,%esp
  80144b:	85 c0                	test   %eax,%eax
  80144d:	0f 88 81 00 00 00    	js     8014d4 <dup+0xa7>
		return r;
	close(newfdnum);
  801453:	83 ec 0c             	sub    $0xc,%esp
  801456:	ff 75 0c             	pushl  0xc(%ebp)
  801459:	e8 75 ff ff ff       	call   8013d3 <close>

	newfd = INDEX2FD(newfdnum);
  80145e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801461:	c1 e6 0c             	shl    $0xc,%esi
  801464:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80146a:	83 c4 04             	add    $0x4,%esp
  80146d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801470:	e8 af fd ff ff       	call   801224 <fd2data>
  801475:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801477:	89 34 24             	mov    %esi,(%esp)
  80147a:	e8 a5 fd ff ff       	call   801224 <fd2data>
  80147f:	83 c4 10             	add    $0x10,%esp
  801482:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801484:	89 d8                	mov    %ebx,%eax
  801486:	c1 e8 16             	shr    $0x16,%eax
  801489:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801490:	a8 01                	test   $0x1,%al
  801492:	74 11                	je     8014a5 <dup+0x78>
  801494:	89 d8                	mov    %ebx,%eax
  801496:	c1 e8 0c             	shr    $0xc,%eax
  801499:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014a0:	f6 c2 01             	test   $0x1,%dl
  8014a3:	75 39                	jne    8014de <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014a5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014a8:	89 d0                	mov    %edx,%eax
  8014aa:	c1 e8 0c             	shr    $0xc,%eax
  8014ad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b4:	83 ec 0c             	sub    $0xc,%esp
  8014b7:	25 07 0e 00 00       	and    $0xe07,%eax
  8014bc:	50                   	push   %eax
  8014bd:	56                   	push   %esi
  8014be:	6a 00                	push   $0x0
  8014c0:	52                   	push   %edx
  8014c1:	6a 00                	push   $0x0
  8014c3:	e8 d7 fb ff ff       	call   80109f <sys_page_map>
  8014c8:	89 c3                	mov    %eax,%ebx
  8014ca:	83 c4 20             	add    $0x20,%esp
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	78 31                	js     801502 <dup+0xd5>
		goto err;

	return newfdnum;
  8014d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014d4:	89 d8                	mov    %ebx,%eax
  8014d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014d9:	5b                   	pop    %ebx
  8014da:	5e                   	pop    %esi
  8014db:	5f                   	pop    %edi
  8014dc:	5d                   	pop    %ebp
  8014dd:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014e5:	83 ec 0c             	sub    $0xc,%esp
  8014e8:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ed:	50                   	push   %eax
  8014ee:	57                   	push   %edi
  8014ef:	6a 00                	push   $0x0
  8014f1:	53                   	push   %ebx
  8014f2:	6a 00                	push   $0x0
  8014f4:	e8 a6 fb ff ff       	call   80109f <sys_page_map>
  8014f9:	89 c3                	mov    %eax,%ebx
  8014fb:	83 c4 20             	add    $0x20,%esp
  8014fe:	85 c0                	test   %eax,%eax
  801500:	79 a3                	jns    8014a5 <dup+0x78>
	sys_page_unmap(0, newfd);
  801502:	83 ec 08             	sub    $0x8,%esp
  801505:	56                   	push   %esi
  801506:	6a 00                	push   $0x0
  801508:	e8 b7 fb ff ff       	call   8010c4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80150d:	83 c4 08             	add    $0x8,%esp
  801510:	57                   	push   %edi
  801511:	6a 00                	push   $0x0
  801513:	e8 ac fb ff ff       	call   8010c4 <sys_page_unmap>
	return r;
  801518:	83 c4 10             	add    $0x10,%esp
  80151b:	eb b7                	jmp    8014d4 <dup+0xa7>

0080151d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80151d:	f3 0f 1e fb          	endbr32 
  801521:	55                   	push   %ebp
  801522:	89 e5                	mov    %esp,%ebp
  801524:	53                   	push   %ebx
  801525:	83 ec 1c             	sub    $0x1c,%esp
  801528:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80152e:	50                   	push   %eax
  80152f:	53                   	push   %ebx
  801530:	e8 60 fd ff ff       	call   801295 <fd_lookup>
  801535:	83 c4 10             	add    $0x10,%esp
  801538:	85 c0                	test   %eax,%eax
  80153a:	78 3f                	js     80157b <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153c:	83 ec 08             	sub    $0x8,%esp
  80153f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801542:	50                   	push   %eax
  801543:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801546:	ff 30                	pushl  (%eax)
  801548:	e8 9c fd ff ff       	call   8012e9 <dev_lookup>
  80154d:	83 c4 10             	add    $0x10,%esp
  801550:	85 c0                	test   %eax,%eax
  801552:	78 27                	js     80157b <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801554:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801557:	8b 42 08             	mov    0x8(%edx),%eax
  80155a:	83 e0 03             	and    $0x3,%eax
  80155d:	83 f8 01             	cmp    $0x1,%eax
  801560:	74 1e                	je     801580 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801562:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801565:	8b 40 08             	mov    0x8(%eax),%eax
  801568:	85 c0                	test   %eax,%eax
  80156a:	74 35                	je     8015a1 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80156c:	83 ec 04             	sub    $0x4,%esp
  80156f:	ff 75 10             	pushl  0x10(%ebp)
  801572:	ff 75 0c             	pushl  0xc(%ebp)
  801575:	52                   	push   %edx
  801576:	ff d0                	call   *%eax
  801578:	83 c4 10             	add    $0x10,%esp
}
  80157b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157e:	c9                   	leave  
  80157f:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801580:	a1 18 40 80 00       	mov    0x804018,%eax
  801585:	8b 40 48             	mov    0x48(%eax),%eax
  801588:	83 ec 04             	sub    $0x4,%esp
  80158b:	53                   	push   %ebx
  80158c:	50                   	push   %eax
  80158d:	68 a1 2c 80 00       	push   $0x802ca1
  801592:	e8 6f f0 ff ff       	call   800606 <cprintf>
		return -E_INVAL;
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80159f:	eb da                	jmp    80157b <read+0x5e>
		return -E_NOT_SUPP;
  8015a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015a6:	eb d3                	jmp    80157b <read+0x5e>

008015a8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015a8:	f3 0f 1e fb          	endbr32 
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	57                   	push   %edi
  8015b0:	56                   	push   %esi
  8015b1:	53                   	push   %ebx
  8015b2:	83 ec 0c             	sub    $0xc,%esp
  8015b5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015b8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015c0:	eb 02                	jmp    8015c4 <readn+0x1c>
  8015c2:	01 c3                	add    %eax,%ebx
  8015c4:	39 f3                	cmp    %esi,%ebx
  8015c6:	73 21                	jae    8015e9 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015c8:	83 ec 04             	sub    $0x4,%esp
  8015cb:	89 f0                	mov    %esi,%eax
  8015cd:	29 d8                	sub    %ebx,%eax
  8015cf:	50                   	push   %eax
  8015d0:	89 d8                	mov    %ebx,%eax
  8015d2:	03 45 0c             	add    0xc(%ebp),%eax
  8015d5:	50                   	push   %eax
  8015d6:	57                   	push   %edi
  8015d7:	e8 41 ff ff ff       	call   80151d <read>
		if (m < 0)
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	78 04                	js     8015e7 <readn+0x3f>
			return m;
		if (m == 0)
  8015e3:	75 dd                	jne    8015c2 <readn+0x1a>
  8015e5:	eb 02                	jmp    8015e9 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015e7:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8015e9:	89 d8                	mov    %ebx,%eax
  8015eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ee:	5b                   	pop    %ebx
  8015ef:	5e                   	pop    %esi
  8015f0:	5f                   	pop    %edi
  8015f1:	5d                   	pop    %ebp
  8015f2:	c3                   	ret    

008015f3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015f3:	f3 0f 1e fb          	endbr32 
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	53                   	push   %ebx
  8015fb:	83 ec 1c             	sub    $0x1c,%esp
  8015fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801601:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801604:	50                   	push   %eax
  801605:	53                   	push   %ebx
  801606:	e8 8a fc ff ff       	call   801295 <fd_lookup>
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	85 c0                	test   %eax,%eax
  801610:	78 3a                	js     80164c <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801612:	83 ec 08             	sub    $0x8,%esp
  801615:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801618:	50                   	push   %eax
  801619:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161c:	ff 30                	pushl  (%eax)
  80161e:	e8 c6 fc ff ff       	call   8012e9 <dev_lookup>
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	85 c0                	test   %eax,%eax
  801628:	78 22                	js     80164c <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80162a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801631:	74 1e                	je     801651 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801633:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801636:	8b 52 0c             	mov    0xc(%edx),%edx
  801639:	85 d2                	test   %edx,%edx
  80163b:	74 35                	je     801672 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80163d:	83 ec 04             	sub    $0x4,%esp
  801640:	ff 75 10             	pushl  0x10(%ebp)
  801643:	ff 75 0c             	pushl  0xc(%ebp)
  801646:	50                   	push   %eax
  801647:	ff d2                	call   *%edx
  801649:	83 c4 10             	add    $0x10,%esp
}
  80164c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80164f:	c9                   	leave  
  801650:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801651:	a1 18 40 80 00       	mov    0x804018,%eax
  801656:	8b 40 48             	mov    0x48(%eax),%eax
  801659:	83 ec 04             	sub    $0x4,%esp
  80165c:	53                   	push   %ebx
  80165d:	50                   	push   %eax
  80165e:	68 bd 2c 80 00       	push   $0x802cbd
  801663:	e8 9e ef ff ff       	call   800606 <cprintf>
		return -E_INVAL;
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801670:	eb da                	jmp    80164c <write+0x59>
		return -E_NOT_SUPP;
  801672:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801677:	eb d3                	jmp    80164c <write+0x59>

00801679 <seek>:

int
seek(int fdnum, off_t offset)
{
  801679:	f3 0f 1e fb          	endbr32 
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801683:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801686:	50                   	push   %eax
  801687:	ff 75 08             	pushl  0x8(%ebp)
  80168a:	e8 06 fc ff ff       	call   801295 <fd_lookup>
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	85 c0                	test   %eax,%eax
  801694:	78 0e                	js     8016a4 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801696:	8b 55 0c             	mov    0xc(%ebp),%edx
  801699:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80169f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a4:	c9                   	leave  
  8016a5:	c3                   	ret    

008016a6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016a6:	f3 0f 1e fb          	endbr32 
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	53                   	push   %ebx
  8016ae:	83 ec 1c             	sub    $0x1c,%esp
  8016b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b7:	50                   	push   %eax
  8016b8:	53                   	push   %ebx
  8016b9:	e8 d7 fb ff ff       	call   801295 <fd_lookup>
  8016be:	83 c4 10             	add    $0x10,%esp
  8016c1:	85 c0                	test   %eax,%eax
  8016c3:	78 37                	js     8016fc <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c5:	83 ec 08             	sub    $0x8,%esp
  8016c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cb:	50                   	push   %eax
  8016cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cf:	ff 30                	pushl  (%eax)
  8016d1:	e8 13 fc ff ff       	call   8012e9 <dev_lookup>
  8016d6:	83 c4 10             	add    $0x10,%esp
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	78 1f                	js     8016fc <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016e4:	74 1b                	je     801701 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8016e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e9:	8b 52 18             	mov    0x18(%edx),%edx
  8016ec:	85 d2                	test   %edx,%edx
  8016ee:	74 32                	je     801722 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016f0:	83 ec 08             	sub    $0x8,%esp
  8016f3:	ff 75 0c             	pushl  0xc(%ebp)
  8016f6:	50                   	push   %eax
  8016f7:	ff d2                	call   *%edx
  8016f9:	83 c4 10             	add    $0x10,%esp
}
  8016fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ff:	c9                   	leave  
  801700:	c3                   	ret    
			thisenv->env_id, fdnum);
  801701:	a1 18 40 80 00       	mov    0x804018,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801706:	8b 40 48             	mov    0x48(%eax),%eax
  801709:	83 ec 04             	sub    $0x4,%esp
  80170c:	53                   	push   %ebx
  80170d:	50                   	push   %eax
  80170e:	68 80 2c 80 00       	push   $0x802c80
  801713:	e8 ee ee ff ff       	call   800606 <cprintf>
		return -E_INVAL;
  801718:	83 c4 10             	add    $0x10,%esp
  80171b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801720:	eb da                	jmp    8016fc <ftruncate+0x56>
		return -E_NOT_SUPP;
  801722:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801727:	eb d3                	jmp    8016fc <ftruncate+0x56>

00801729 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801729:	f3 0f 1e fb          	endbr32 
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	53                   	push   %ebx
  801731:	83 ec 1c             	sub    $0x1c,%esp
  801734:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801737:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80173a:	50                   	push   %eax
  80173b:	ff 75 08             	pushl  0x8(%ebp)
  80173e:	e8 52 fb ff ff       	call   801295 <fd_lookup>
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	85 c0                	test   %eax,%eax
  801748:	78 4b                	js     801795 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174a:	83 ec 08             	sub    $0x8,%esp
  80174d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801750:	50                   	push   %eax
  801751:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801754:	ff 30                	pushl  (%eax)
  801756:	e8 8e fb ff ff       	call   8012e9 <dev_lookup>
  80175b:	83 c4 10             	add    $0x10,%esp
  80175e:	85 c0                	test   %eax,%eax
  801760:	78 33                	js     801795 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801762:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801765:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801769:	74 2f                	je     80179a <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80176b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80176e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801775:	00 00 00 
	stat->st_isdir = 0;
  801778:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80177f:	00 00 00 
	stat->st_dev = dev;
  801782:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801788:	83 ec 08             	sub    $0x8,%esp
  80178b:	53                   	push   %ebx
  80178c:	ff 75 f0             	pushl  -0x10(%ebp)
  80178f:	ff 50 14             	call   *0x14(%eax)
  801792:	83 c4 10             	add    $0x10,%esp
}
  801795:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801798:	c9                   	leave  
  801799:	c3                   	ret    
		return -E_NOT_SUPP;
  80179a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80179f:	eb f4                	jmp    801795 <fstat+0x6c>

008017a1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017a1:	f3 0f 1e fb          	endbr32 
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	56                   	push   %esi
  8017a9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017aa:	83 ec 08             	sub    $0x8,%esp
  8017ad:	6a 00                	push   $0x0
  8017af:	ff 75 08             	pushl  0x8(%ebp)
  8017b2:	e8 01 02 00 00       	call   8019b8 <open>
  8017b7:	89 c3                	mov    %eax,%ebx
  8017b9:	83 c4 10             	add    $0x10,%esp
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	78 1b                	js     8017db <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8017c0:	83 ec 08             	sub    $0x8,%esp
  8017c3:	ff 75 0c             	pushl  0xc(%ebp)
  8017c6:	50                   	push   %eax
  8017c7:	e8 5d ff ff ff       	call   801729 <fstat>
  8017cc:	89 c6                	mov    %eax,%esi
	close(fd);
  8017ce:	89 1c 24             	mov    %ebx,(%esp)
  8017d1:	e8 fd fb ff ff       	call   8013d3 <close>
	return r;
  8017d6:	83 c4 10             	add    $0x10,%esp
  8017d9:	89 f3                	mov    %esi,%ebx
}
  8017db:	89 d8                	mov    %ebx,%eax
  8017dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e0:	5b                   	pop    %ebx
  8017e1:	5e                   	pop    %esi
  8017e2:	5d                   	pop    %ebp
  8017e3:	c3                   	ret    

008017e4 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	56                   	push   %esi
  8017e8:	53                   	push   %ebx
  8017e9:	89 c6                	mov    %eax,%esi
  8017eb:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017ed:	83 3d 10 40 80 00 00 	cmpl   $0x0,0x804010
  8017f4:	74 27                	je     80181d <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017f6:	6a 07                	push   $0x7
  8017f8:	68 00 50 80 00       	push   $0x805000
  8017fd:	56                   	push   %esi
  8017fe:	ff 35 10 40 80 00    	pushl  0x804010
  801804:	e8 c6 0c 00 00       	call   8024cf <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801809:	83 c4 0c             	add    $0xc,%esp
  80180c:	6a 00                	push   $0x0
  80180e:	53                   	push   %ebx
  80180f:	6a 00                	push   $0x0
  801811:	e8 4c 0c 00 00       	call   802462 <ipc_recv>
}
  801816:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801819:	5b                   	pop    %ebx
  80181a:	5e                   	pop    %esi
  80181b:	5d                   	pop    %ebp
  80181c:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80181d:	83 ec 0c             	sub    $0xc,%esp
  801820:	6a 01                	push   $0x1
  801822:	e8 00 0d 00 00       	call   802527 <ipc_find_env>
  801827:	a3 10 40 80 00       	mov    %eax,0x804010
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	eb c5                	jmp    8017f6 <fsipc+0x12>

00801831 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801831:	f3 0f 1e fb          	endbr32 
  801835:	55                   	push   %ebp
  801836:	89 e5                	mov    %esp,%ebp
  801838:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80183b:	8b 45 08             	mov    0x8(%ebp),%eax
  80183e:	8b 40 0c             	mov    0xc(%eax),%eax
  801841:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801846:	8b 45 0c             	mov    0xc(%ebp),%eax
  801849:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80184e:	ba 00 00 00 00       	mov    $0x0,%edx
  801853:	b8 02 00 00 00       	mov    $0x2,%eax
  801858:	e8 87 ff ff ff       	call   8017e4 <fsipc>
}
  80185d:	c9                   	leave  
  80185e:	c3                   	ret    

0080185f <devfile_flush>:
{
  80185f:	f3 0f 1e fb          	endbr32 
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801869:	8b 45 08             	mov    0x8(%ebp),%eax
  80186c:	8b 40 0c             	mov    0xc(%eax),%eax
  80186f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801874:	ba 00 00 00 00       	mov    $0x0,%edx
  801879:	b8 06 00 00 00       	mov    $0x6,%eax
  80187e:	e8 61 ff ff ff       	call   8017e4 <fsipc>
}
  801883:	c9                   	leave  
  801884:	c3                   	ret    

00801885 <devfile_stat>:
{
  801885:	f3 0f 1e fb          	endbr32 
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
  80188c:	53                   	push   %ebx
  80188d:	83 ec 04             	sub    $0x4,%esp
  801890:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801893:	8b 45 08             	mov    0x8(%ebp),%eax
  801896:	8b 40 0c             	mov    0xc(%eax),%eax
  801899:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80189e:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a3:	b8 05 00 00 00       	mov    $0x5,%eax
  8018a8:	e8 37 ff ff ff       	call   8017e4 <fsipc>
  8018ad:	85 c0                	test   %eax,%eax
  8018af:	78 2c                	js     8018dd <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018b1:	83 ec 08             	sub    $0x8,%esp
  8018b4:	68 00 50 80 00       	push   $0x805000
  8018b9:	53                   	push   %ebx
  8018ba:	e8 51 f3 ff ff       	call   800c10 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018bf:	a1 80 50 80 00       	mov    0x805080,%eax
  8018c4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018ca:	a1 84 50 80 00       	mov    0x805084,%eax
  8018cf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018d5:	83 c4 10             	add    $0x10,%esp
  8018d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e0:	c9                   	leave  
  8018e1:	c3                   	ret    

008018e2 <devfile_write>:
{
  8018e2:	f3 0f 1e fb          	endbr32 
  8018e6:	55                   	push   %ebp
  8018e7:	89 e5                	mov    %esp,%ebp
  8018e9:	83 ec 0c             	sub    $0xc,%esp
  8018ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8018ef:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018f4:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018f9:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8018ff:	8b 52 0c             	mov    0xc(%edx),%edx
  801902:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801908:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80190d:	50                   	push   %eax
  80190e:	ff 75 0c             	pushl  0xc(%ebp)
  801911:	68 08 50 80 00       	push   $0x805008
  801916:	e8 f3 f4 ff ff       	call   800e0e <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80191b:	ba 00 00 00 00       	mov    $0x0,%edx
  801920:	b8 04 00 00 00       	mov    $0x4,%eax
  801925:	e8 ba fe ff ff       	call   8017e4 <fsipc>
}
  80192a:	c9                   	leave  
  80192b:	c3                   	ret    

0080192c <devfile_read>:
{
  80192c:	f3 0f 1e fb          	endbr32 
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	56                   	push   %esi
  801934:	53                   	push   %ebx
  801935:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801938:	8b 45 08             	mov    0x8(%ebp),%eax
  80193b:	8b 40 0c             	mov    0xc(%eax),%eax
  80193e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801943:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801949:	ba 00 00 00 00       	mov    $0x0,%edx
  80194e:	b8 03 00 00 00       	mov    $0x3,%eax
  801953:	e8 8c fe ff ff       	call   8017e4 <fsipc>
  801958:	89 c3                	mov    %eax,%ebx
  80195a:	85 c0                	test   %eax,%eax
  80195c:	78 1f                	js     80197d <devfile_read+0x51>
	assert(r <= n);
  80195e:	39 f0                	cmp    %esi,%eax
  801960:	77 24                	ja     801986 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801962:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801967:	7f 36                	jg     80199f <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801969:	83 ec 04             	sub    $0x4,%esp
  80196c:	50                   	push   %eax
  80196d:	68 00 50 80 00       	push   $0x805000
  801972:	ff 75 0c             	pushl  0xc(%ebp)
  801975:	e8 94 f4 ff ff       	call   800e0e <memmove>
	return r;
  80197a:	83 c4 10             	add    $0x10,%esp
}
  80197d:	89 d8                	mov    %ebx,%eax
  80197f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801982:	5b                   	pop    %ebx
  801983:	5e                   	pop    %esi
  801984:	5d                   	pop    %ebp
  801985:	c3                   	ret    
	assert(r <= n);
  801986:	68 f0 2c 80 00       	push   $0x802cf0
  80198b:	68 f7 2c 80 00       	push   $0x802cf7
  801990:	68 8c 00 00 00       	push   $0x8c
  801995:	68 0c 2d 80 00       	push   $0x802d0c
  80199a:	e8 79 0a 00 00       	call   802418 <_panic>
	assert(r <= PGSIZE);
  80199f:	68 17 2d 80 00       	push   $0x802d17
  8019a4:	68 f7 2c 80 00       	push   $0x802cf7
  8019a9:	68 8d 00 00 00       	push   $0x8d
  8019ae:	68 0c 2d 80 00       	push   $0x802d0c
  8019b3:	e8 60 0a 00 00       	call   802418 <_panic>

008019b8 <open>:
{
  8019b8:	f3 0f 1e fb          	endbr32 
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	56                   	push   %esi
  8019c0:	53                   	push   %ebx
  8019c1:	83 ec 1c             	sub    $0x1c,%esp
  8019c4:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8019c7:	56                   	push   %esi
  8019c8:	e8 00 f2 ff ff       	call   800bcd <strlen>
  8019cd:	83 c4 10             	add    $0x10,%esp
  8019d0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019d5:	7f 6c                	jg     801a43 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8019d7:	83 ec 0c             	sub    $0xc,%esp
  8019da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019dd:	50                   	push   %eax
  8019de:	e8 5c f8 ff ff       	call   80123f <fd_alloc>
  8019e3:	89 c3                	mov    %eax,%ebx
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	85 c0                	test   %eax,%eax
  8019ea:	78 3c                	js     801a28 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8019ec:	83 ec 08             	sub    $0x8,%esp
  8019ef:	56                   	push   %esi
  8019f0:	68 00 50 80 00       	push   $0x805000
  8019f5:	e8 16 f2 ff ff       	call   800c10 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fd:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a02:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a05:	b8 01 00 00 00       	mov    $0x1,%eax
  801a0a:	e8 d5 fd ff ff       	call   8017e4 <fsipc>
  801a0f:	89 c3                	mov    %eax,%ebx
  801a11:	83 c4 10             	add    $0x10,%esp
  801a14:	85 c0                	test   %eax,%eax
  801a16:	78 19                	js     801a31 <open+0x79>
	return fd2num(fd);
  801a18:	83 ec 0c             	sub    $0xc,%esp
  801a1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1e:	e8 ed f7 ff ff       	call   801210 <fd2num>
  801a23:	89 c3                	mov    %eax,%ebx
  801a25:	83 c4 10             	add    $0x10,%esp
}
  801a28:	89 d8                	mov    %ebx,%eax
  801a2a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a2d:	5b                   	pop    %ebx
  801a2e:	5e                   	pop    %esi
  801a2f:	5d                   	pop    %ebp
  801a30:	c3                   	ret    
		fd_close(fd, 0);
  801a31:	83 ec 08             	sub    $0x8,%esp
  801a34:	6a 00                	push   $0x0
  801a36:	ff 75 f4             	pushl  -0xc(%ebp)
  801a39:	e8 0a f9 ff ff       	call   801348 <fd_close>
		return r;
  801a3e:	83 c4 10             	add    $0x10,%esp
  801a41:	eb e5                	jmp    801a28 <open+0x70>
		return -E_BAD_PATH;
  801a43:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a48:	eb de                	jmp    801a28 <open+0x70>

00801a4a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a4a:	f3 0f 1e fb          	endbr32 
  801a4e:	55                   	push   %ebp
  801a4f:	89 e5                	mov    %esp,%ebp
  801a51:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a54:	ba 00 00 00 00       	mov    $0x0,%edx
  801a59:	b8 08 00 00 00       	mov    $0x8,%eax
  801a5e:	e8 81 fd ff ff       	call   8017e4 <fsipc>
}
  801a63:	c9                   	leave  
  801a64:	c3                   	ret    

00801a65 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a65:	f3 0f 1e fb          	endbr32 
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a6f:	68 83 2d 80 00       	push   $0x802d83
  801a74:	ff 75 0c             	pushl  0xc(%ebp)
  801a77:	e8 94 f1 ff ff       	call   800c10 <strcpy>
	return 0;
}
  801a7c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a81:	c9                   	leave  
  801a82:	c3                   	ret    

00801a83 <devsock_close>:
{
  801a83:	f3 0f 1e fb          	endbr32 
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	53                   	push   %ebx
  801a8b:	83 ec 10             	sub    $0x10,%esp
  801a8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a91:	53                   	push   %ebx
  801a92:	e8 cd 0a 00 00       	call   802564 <pageref>
  801a97:	89 c2                	mov    %eax,%edx
  801a99:	83 c4 10             	add    $0x10,%esp
		return 0;
  801a9c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801aa1:	83 fa 01             	cmp    $0x1,%edx
  801aa4:	74 05                	je     801aab <devsock_close+0x28>
}
  801aa6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa9:	c9                   	leave  
  801aaa:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801aab:	83 ec 0c             	sub    $0xc,%esp
  801aae:	ff 73 0c             	pushl  0xc(%ebx)
  801ab1:	e8 e3 02 00 00       	call   801d99 <nsipc_close>
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	eb eb                	jmp    801aa6 <devsock_close+0x23>

00801abb <devsock_write>:
{
  801abb:	f3 0f 1e fb          	endbr32 
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ac5:	6a 00                	push   $0x0
  801ac7:	ff 75 10             	pushl  0x10(%ebp)
  801aca:	ff 75 0c             	pushl  0xc(%ebp)
  801acd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad0:	ff 70 0c             	pushl  0xc(%eax)
  801ad3:	e8 b5 03 00 00       	call   801e8d <nsipc_send>
}
  801ad8:	c9                   	leave  
  801ad9:	c3                   	ret    

00801ada <devsock_read>:
{
  801ada:	f3 0f 1e fb          	endbr32 
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ae4:	6a 00                	push   $0x0
  801ae6:	ff 75 10             	pushl  0x10(%ebp)
  801ae9:	ff 75 0c             	pushl  0xc(%ebp)
  801aec:	8b 45 08             	mov    0x8(%ebp),%eax
  801aef:	ff 70 0c             	pushl  0xc(%eax)
  801af2:	e8 1f 03 00 00       	call   801e16 <nsipc_recv>
}
  801af7:	c9                   	leave  
  801af8:	c3                   	ret    

00801af9 <fd2sockid>:
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801aff:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b02:	52                   	push   %edx
  801b03:	50                   	push   %eax
  801b04:	e8 8c f7 ff ff       	call   801295 <fd_lookup>
  801b09:	83 c4 10             	add    $0x10,%esp
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	78 10                	js     801b20 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b13:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  801b19:	39 08                	cmp    %ecx,(%eax)
  801b1b:	75 05                	jne    801b22 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801b1d:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801b20:	c9                   	leave  
  801b21:	c3                   	ret    
		return -E_NOT_SUPP;
  801b22:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b27:	eb f7                	jmp    801b20 <fd2sockid+0x27>

00801b29 <alloc_sockfd>:
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	56                   	push   %esi
  801b2d:	53                   	push   %ebx
  801b2e:	83 ec 1c             	sub    $0x1c,%esp
  801b31:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801b33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b36:	50                   	push   %eax
  801b37:	e8 03 f7 ff ff       	call   80123f <fd_alloc>
  801b3c:	89 c3                	mov    %eax,%ebx
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	85 c0                	test   %eax,%eax
  801b43:	78 43                	js     801b88 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b45:	83 ec 04             	sub    $0x4,%esp
  801b48:	68 07 04 00 00       	push   $0x407
  801b4d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b50:	6a 00                	push   $0x0
  801b52:	e8 22 f5 ff ff       	call   801079 <sys_page_alloc>
  801b57:	89 c3                	mov    %eax,%ebx
  801b59:	83 c4 10             	add    $0x10,%esp
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	78 28                	js     801b88 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b63:	8b 15 60 30 80 00    	mov    0x803060,%edx
  801b69:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b75:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b78:	83 ec 0c             	sub    $0xc,%esp
  801b7b:	50                   	push   %eax
  801b7c:	e8 8f f6 ff ff       	call   801210 <fd2num>
  801b81:	89 c3                	mov    %eax,%ebx
  801b83:	83 c4 10             	add    $0x10,%esp
  801b86:	eb 0c                	jmp    801b94 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801b88:	83 ec 0c             	sub    $0xc,%esp
  801b8b:	56                   	push   %esi
  801b8c:	e8 08 02 00 00       	call   801d99 <nsipc_close>
		return r;
  801b91:	83 c4 10             	add    $0x10,%esp
}
  801b94:	89 d8                	mov    %ebx,%eax
  801b96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b99:	5b                   	pop    %ebx
  801b9a:	5e                   	pop    %esi
  801b9b:	5d                   	pop    %ebp
  801b9c:	c3                   	ret    

00801b9d <accept>:
{
  801b9d:	f3 0f 1e fb          	endbr32 
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ba7:	8b 45 08             	mov    0x8(%ebp),%eax
  801baa:	e8 4a ff ff ff       	call   801af9 <fd2sockid>
  801baf:	85 c0                	test   %eax,%eax
  801bb1:	78 1b                	js     801bce <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bb3:	83 ec 04             	sub    $0x4,%esp
  801bb6:	ff 75 10             	pushl  0x10(%ebp)
  801bb9:	ff 75 0c             	pushl  0xc(%ebp)
  801bbc:	50                   	push   %eax
  801bbd:	e8 22 01 00 00       	call   801ce4 <nsipc_accept>
  801bc2:	83 c4 10             	add    $0x10,%esp
  801bc5:	85 c0                	test   %eax,%eax
  801bc7:	78 05                	js     801bce <accept+0x31>
	return alloc_sockfd(r);
  801bc9:	e8 5b ff ff ff       	call   801b29 <alloc_sockfd>
}
  801bce:	c9                   	leave  
  801bcf:	c3                   	ret    

00801bd0 <bind>:
{
  801bd0:	f3 0f 1e fb          	endbr32 
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bda:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdd:	e8 17 ff ff ff       	call   801af9 <fd2sockid>
  801be2:	85 c0                	test   %eax,%eax
  801be4:	78 12                	js     801bf8 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801be6:	83 ec 04             	sub    $0x4,%esp
  801be9:	ff 75 10             	pushl  0x10(%ebp)
  801bec:	ff 75 0c             	pushl  0xc(%ebp)
  801bef:	50                   	push   %eax
  801bf0:	e8 45 01 00 00       	call   801d3a <nsipc_bind>
  801bf5:	83 c4 10             	add    $0x10,%esp
}
  801bf8:	c9                   	leave  
  801bf9:	c3                   	ret    

00801bfa <shutdown>:
{
  801bfa:	f3 0f 1e fb          	endbr32 
  801bfe:	55                   	push   %ebp
  801bff:	89 e5                	mov    %esp,%ebp
  801c01:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c04:	8b 45 08             	mov    0x8(%ebp),%eax
  801c07:	e8 ed fe ff ff       	call   801af9 <fd2sockid>
  801c0c:	85 c0                	test   %eax,%eax
  801c0e:	78 0f                	js     801c1f <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801c10:	83 ec 08             	sub    $0x8,%esp
  801c13:	ff 75 0c             	pushl  0xc(%ebp)
  801c16:	50                   	push   %eax
  801c17:	e8 57 01 00 00       	call   801d73 <nsipc_shutdown>
  801c1c:	83 c4 10             	add    $0x10,%esp
}
  801c1f:	c9                   	leave  
  801c20:	c3                   	ret    

00801c21 <connect>:
{
  801c21:	f3 0f 1e fb          	endbr32 
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2e:	e8 c6 fe ff ff       	call   801af9 <fd2sockid>
  801c33:	85 c0                	test   %eax,%eax
  801c35:	78 12                	js     801c49 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801c37:	83 ec 04             	sub    $0x4,%esp
  801c3a:	ff 75 10             	pushl  0x10(%ebp)
  801c3d:	ff 75 0c             	pushl  0xc(%ebp)
  801c40:	50                   	push   %eax
  801c41:	e8 71 01 00 00       	call   801db7 <nsipc_connect>
  801c46:	83 c4 10             	add    $0x10,%esp
}
  801c49:	c9                   	leave  
  801c4a:	c3                   	ret    

00801c4b <listen>:
{
  801c4b:	f3 0f 1e fb          	endbr32 
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c55:	8b 45 08             	mov    0x8(%ebp),%eax
  801c58:	e8 9c fe ff ff       	call   801af9 <fd2sockid>
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	78 0f                	js     801c70 <listen+0x25>
	return nsipc_listen(r, backlog);
  801c61:	83 ec 08             	sub    $0x8,%esp
  801c64:	ff 75 0c             	pushl  0xc(%ebp)
  801c67:	50                   	push   %eax
  801c68:	e8 83 01 00 00       	call   801df0 <nsipc_listen>
  801c6d:	83 c4 10             	add    $0x10,%esp
}
  801c70:	c9                   	leave  
  801c71:	c3                   	ret    

00801c72 <socket>:

int
socket(int domain, int type, int protocol)
{
  801c72:	f3 0f 1e fb          	endbr32 
  801c76:	55                   	push   %ebp
  801c77:	89 e5                	mov    %esp,%ebp
  801c79:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c7c:	ff 75 10             	pushl  0x10(%ebp)
  801c7f:	ff 75 0c             	pushl  0xc(%ebp)
  801c82:	ff 75 08             	pushl  0x8(%ebp)
  801c85:	e8 65 02 00 00       	call   801eef <nsipc_socket>
  801c8a:	83 c4 10             	add    $0x10,%esp
  801c8d:	85 c0                	test   %eax,%eax
  801c8f:	78 05                	js     801c96 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801c91:	e8 93 fe ff ff       	call   801b29 <alloc_sockfd>
}
  801c96:	c9                   	leave  
  801c97:	c3                   	ret    

00801c98 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	53                   	push   %ebx
  801c9c:	83 ec 04             	sub    $0x4,%esp
  801c9f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ca1:	83 3d 14 40 80 00 00 	cmpl   $0x0,0x804014
  801ca8:	74 26                	je     801cd0 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801caa:	6a 07                	push   $0x7
  801cac:	68 00 60 80 00       	push   $0x806000
  801cb1:	53                   	push   %ebx
  801cb2:	ff 35 14 40 80 00    	pushl  0x804014
  801cb8:	e8 12 08 00 00       	call   8024cf <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801cbd:	83 c4 0c             	add    $0xc,%esp
  801cc0:	6a 00                	push   $0x0
  801cc2:	6a 00                	push   $0x0
  801cc4:	6a 00                	push   $0x0
  801cc6:	e8 97 07 00 00       	call   802462 <ipc_recv>
}
  801ccb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cce:	c9                   	leave  
  801ccf:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801cd0:	83 ec 0c             	sub    $0xc,%esp
  801cd3:	6a 02                	push   $0x2
  801cd5:	e8 4d 08 00 00       	call   802527 <ipc_find_env>
  801cda:	a3 14 40 80 00       	mov    %eax,0x804014
  801cdf:	83 c4 10             	add    $0x10,%esp
  801ce2:	eb c6                	jmp    801caa <nsipc+0x12>

00801ce4 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ce4:	f3 0f 1e fb          	endbr32 
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	56                   	push   %esi
  801cec:	53                   	push   %ebx
  801ced:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801cf8:	8b 06                	mov    (%esi),%eax
  801cfa:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801cff:	b8 01 00 00 00       	mov    $0x1,%eax
  801d04:	e8 8f ff ff ff       	call   801c98 <nsipc>
  801d09:	89 c3                	mov    %eax,%ebx
  801d0b:	85 c0                	test   %eax,%eax
  801d0d:	79 09                	jns    801d18 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801d0f:	89 d8                	mov    %ebx,%eax
  801d11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d14:	5b                   	pop    %ebx
  801d15:	5e                   	pop    %esi
  801d16:	5d                   	pop    %ebp
  801d17:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d18:	83 ec 04             	sub    $0x4,%esp
  801d1b:	ff 35 10 60 80 00    	pushl  0x806010
  801d21:	68 00 60 80 00       	push   $0x806000
  801d26:	ff 75 0c             	pushl  0xc(%ebp)
  801d29:	e8 e0 f0 ff ff       	call   800e0e <memmove>
		*addrlen = ret->ret_addrlen;
  801d2e:	a1 10 60 80 00       	mov    0x806010,%eax
  801d33:	89 06                	mov    %eax,(%esi)
  801d35:	83 c4 10             	add    $0x10,%esp
	return r;
  801d38:	eb d5                	jmp    801d0f <nsipc_accept+0x2b>

00801d3a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d3a:	f3 0f 1e fb          	endbr32 
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
  801d41:	53                   	push   %ebx
  801d42:	83 ec 08             	sub    $0x8,%esp
  801d45:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d48:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d50:	53                   	push   %ebx
  801d51:	ff 75 0c             	pushl  0xc(%ebp)
  801d54:	68 04 60 80 00       	push   $0x806004
  801d59:	e8 b0 f0 ff ff       	call   800e0e <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d5e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d64:	b8 02 00 00 00       	mov    $0x2,%eax
  801d69:	e8 2a ff ff ff       	call   801c98 <nsipc>
}
  801d6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d71:	c9                   	leave  
  801d72:	c3                   	ret    

00801d73 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d73:	f3 0f 1e fb          	endbr32 
  801d77:	55                   	push   %ebp
  801d78:	89 e5                	mov    %esp,%ebp
  801d7a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d80:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d85:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d88:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d8d:	b8 03 00 00 00       	mov    $0x3,%eax
  801d92:	e8 01 ff ff ff       	call   801c98 <nsipc>
}
  801d97:	c9                   	leave  
  801d98:	c3                   	ret    

00801d99 <nsipc_close>:

int
nsipc_close(int s)
{
  801d99:	f3 0f 1e fb          	endbr32 
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801da3:	8b 45 08             	mov    0x8(%ebp),%eax
  801da6:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801dab:	b8 04 00 00 00       	mov    $0x4,%eax
  801db0:	e8 e3 fe ff ff       	call   801c98 <nsipc>
}
  801db5:	c9                   	leave  
  801db6:	c3                   	ret    

00801db7 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801db7:	f3 0f 1e fb          	endbr32 
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	53                   	push   %ebx
  801dbf:	83 ec 08             	sub    $0x8,%esp
  801dc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801dcd:	53                   	push   %ebx
  801dce:	ff 75 0c             	pushl  0xc(%ebp)
  801dd1:	68 04 60 80 00       	push   $0x806004
  801dd6:	e8 33 f0 ff ff       	call   800e0e <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ddb:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801de1:	b8 05 00 00 00       	mov    $0x5,%eax
  801de6:	e8 ad fe ff ff       	call   801c98 <nsipc>
}
  801deb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dee:	c9                   	leave  
  801def:	c3                   	ret    

00801df0 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801df0:	f3 0f 1e fb          	endbr32 
  801df4:	55                   	push   %ebp
  801df5:	89 e5                	mov    %esp,%ebp
  801df7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801dfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e02:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e05:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e0a:	b8 06 00 00 00       	mov    $0x6,%eax
  801e0f:	e8 84 fe ff ff       	call   801c98 <nsipc>
}
  801e14:	c9                   	leave  
  801e15:	c3                   	ret    

00801e16 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e16:	f3 0f 1e fb          	endbr32 
  801e1a:	55                   	push   %ebp
  801e1b:	89 e5                	mov    %esp,%ebp
  801e1d:	56                   	push   %esi
  801e1e:	53                   	push   %ebx
  801e1f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e22:	8b 45 08             	mov    0x8(%ebp),%eax
  801e25:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e2a:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e30:	8b 45 14             	mov    0x14(%ebp),%eax
  801e33:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e38:	b8 07 00 00 00       	mov    $0x7,%eax
  801e3d:	e8 56 fe ff ff       	call   801c98 <nsipc>
  801e42:	89 c3                	mov    %eax,%ebx
  801e44:	85 c0                	test   %eax,%eax
  801e46:	78 26                	js     801e6e <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801e48:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801e4e:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801e53:	0f 4e c6             	cmovle %esi,%eax
  801e56:	39 c3                	cmp    %eax,%ebx
  801e58:	7f 1d                	jg     801e77 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e5a:	83 ec 04             	sub    $0x4,%esp
  801e5d:	53                   	push   %ebx
  801e5e:	68 00 60 80 00       	push   $0x806000
  801e63:	ff 75 0c             	pushl  0xc(%ebp)
  801e66:	e8 a3 ef ff ff       	call   800e0e <memmove>
  801e6b:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e6e:	89 d8                	mov    %ebx,%eax
  801e70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e73:	5b                   	pop    %ebx
  801e74:	5e                   	pop    %esi
  801e75:	5d                   	pop    %ebp
  801e76:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801e77:	68 8f 2d 80 00       	push   $0x802d8f
  801e7c:	68 f7 2c 80 00       	push   $0x802cf7
  801e81:	6a 62                	push   $0x62
  801e83:	68 a4 2d 80 00       	push   $0x802da4
  801e88:	e8 8b 05 00 00       	call   802418 <_panic>

00801e8d <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e8d:	f3 0f 1e fb          	endbr32 
  801e91:	55                   	push   %ebp
  801e92:	89 e5                	mov    %esp,%ebp
  801e94:	53                   	push   %ebx
  801e95:	83 ec 04             	sub    $0x4,%esp
  801e98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9e:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ea3:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ea9:	7f 2e                	jg     801ed9 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801eab:	83 ec 04             	sub    $0x4,%esp
  801eae:	53                   	push   %ebx
  801eaf:	ff 75 0c             	pushl  0xc(%ebp)
  801eb2:	68 0c 60 80 00       	push   $0x80600c
  801eb7:	e8 52 ef ff ff       	call   800e0e <memmove>
	nsipcbuf.send.req_size = size;
  801ebc:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ec2:	8b 45 14             	mov    0x14(%ebp),%eax
  801ec5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801eca:	b8 08 00 00 00       	mov    $0x8,%eax
  801ecf:	e8 c4 fd ff ff       	call   801c98 <nsipc>
}
  801ed4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ed7:	c9                   	leave  
  801ed8:	c3                   	ret    
	assert(size < 1600);
  801ed9:	68 b0 2d 80 00       	push   $0x802db0
  801ede:	68 f7 2c 80 00       	push   $0x802cf7
  801ee3:	6a 6d                	push   $0x6d
  801ee5:	68 a4 2d 80 00       	push   $0x802da4
  801eea:	e8 29 05 00 00       	call   802418 <_panic>

00801eef <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801eef:	f3 0f 1e fb          	endbr32 
  801ef3:	55                   	push   %ebp
  801ef4:	89 e5                	mov    %esp,%ebp
  801ef6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  801efc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801f01:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f04:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f09:	8b 45 10             	mov    0x10(%ebp),%eax
  801f0c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801f11:	b8 09 00 00 00       	mov    $0x9,%eax
  801f16:	e8 7d fd ff ff       	call   801c98 <nsipc>
}
  801f1b:	c9                   	leave  
  801f1c:	c3                   	ret    

00801f1d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f1d:	f3 0f 1e fb          	endbr32 
  801f21:	55                   	push   %ebp
  801f22:	89 e5                	mov    %esp,%ebp
  801f24:	56                   	push   %esi
  801f25:	53                   	push   %ebx
  801f26:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f29:	83 ec 0c             	sub    $0xc,%esp
  801f2c:	ff 75 08             	pushl  0x8(%ebp)
  801f2f:	e8 f0 f2 ff ff       	call   801224 <fd2data>
  801f34:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f36:	83 c4 08             	add    $0x8,%esp
  801f39:	68 bc 2d 80 00       	push   $0x802dbc
  801f3e:	53                   	push   %ebx
  801f3f:	e8 cc ec ff ff       	call   800c10 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f44:	8b 46 04             	mov    0x4(%esi),%eax
  801f47:	2b 06                	sub    (%esi),%eax
  801f49:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f4f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f56:	00 00 00 
	stat->st_dev = &devpipe;
  801f59:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801f60:	30 80 00 
	return 0;
}
  801f63:	b8 00 00 00 00       	mov    $0x0,%eax
  801f68:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f6b:	5b                   	pop    %ebx
  801f6c:	5e                   	pop    %esi
  801f6d:	5d                   	pop    %ebp
  801f6e:	c3                   	ret    

00801f6f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f6f:	f3 0f 1e fb          	endbr32 
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	53                   	push   %ebx
  801f77:	83 ec 0c             	sub    $0xc,%esp
  801f7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f7d:	53                   	push   %ebx
  801f7e:	6a 00                	push   $0x0
  801f80:	e8 3f f1 ff ff       	call   8010c4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f85:	89 1c 24             	mov    %ebx,(%esp)
  801f88:	e8 97 f2 ff ff       	call   801224 <fd2data>
  801f8d:	83 c4 08             	add    $0x8,%esp
  801f90:	50                   	push   %eax
  801f91:	6a 00                	push   $0x0
  801f93:	e8 2c f1 ff ff       	call   8010c4 <sys_page_unmap>
}
  801f98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f9b:	c9                   	leave  
  801f9c:	c3                   	ret    

00801f9d <_pipeisclosed>:
{
  801f9d:	55                   	push   %ebp
  801f9e:	89 e5                	mov    %esp,%ebp
  801fa0:	57                   	push   %edi
  801fa1:	56                   	push   %esi
  801fa2:	53                   	push   %ebx
  801fa3:	83 ec 1c             	sub    $0x1c,%esp
  801fa6:	89 c7                	mov    %eax,%edi
  801fa8:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801faa:	a1 18 40 80 00       	mov    0x804018,%eax
  801faf:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801fb2:	83 ec 0c             	sub    $0xc,%esp
  801fb5:	57                   	push   %edi
  801fb6:	e8 a9 05 00 00       	call   802564 <pageref>
  801fbb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801fbe:	89 34 24             	mov    %esi,(%esp)
  801fc1:	e8 9e 05 00 00       	call   802564 <pageref>
		nn = thisenv->env_runs;
  801fc6:	8b 15 18 40 80 00    	mov    0x804018,%edx
  801fcc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fcf:	83 c4 10             	add    $0x10,%esp
  801fd2:	39 cb                	cmp    %ecx,%ebx
  801fd4:	74 1b                	je     801ff1 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801fd6:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801fd9:	75 cf                	jne    801faa <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fdb:	8b 42 58             	mov    0x58(%edx),%eax
  801fde:	6a 01                	push   $0x1
  801fe0:	50                   	push   %eax
  801fe1:	53                   	push   %ebx
  801fe2:	68 c3 2d 80 00       	push   $0x802dc3
  801fe7:	e8 1a e6 ff ff       	call   800606 <cprintf>
  801fec:	83 c4 10             	add    $0x10,%esp
  801fef:	eb b9                	jmp    801faa <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801ff1:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ff4:	0f 94 c0             	sete   %al
  801ff7:	0f b6 c0             	movzbl %al,%eax
}
  801ffa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ffd:	5b                   	pop    %ebx
  801ffe:	5e                   	pop    %esi
  801fff:	5f                   	pop    %edi
  802000:	5d                   	pop    %ebp
  802001:	c3                   	ret    

00802002 <devpipe_write>:
{
  802002:	f3 0f 1e fb          	endbr32 
  802006:	55                   	push   %ebp
  802007:	89 e5                	mov    %esp,%ebp
  802009:	57                   	push   %edi
  80200a:	56                   	push   %esi
  80200b:	53                   	push   %ebx
  80200c:	83 ec 28             	sub    $0x28,%esp
  80200f:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802012:	56                   	push   %esi
  802013:	e8 0c f2 ff ff       	call   801224 <fd2data>
  802018:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80201a:	83 c4 10             	add    $0x10,%esp
  80201d:	bf 00 00 00 00       	mov    $0x0,%edi
  802022:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802025:	74 4f                	je     802076 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802027:	8b 43 04             	mov    0x4(%ebx),%eax
  80202a:	8b 0b                	mov    (%ebx),%ecx
  80202c:	8d 51 20             	lea    0x20(%ecx),%edx
  80202f:	39 d0                	cmp    %edx,%eax
  802031:	72 14                	jb     802047 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  802033:	89 da                	mov    %ebx,%edx
  802035:	89 f0                	mov    %esi,%eax
  802037:	e8 61 ff ff ff       	call   801f9d <_pipeisclosed>
  80203c:	85 c0                	test   %eax,%eax
  80203e:	75 3b                	jne    80207b <devpipe_write+0x79>
			sys_yield();
  802040:	e8 11 f0 ff ff       	call   801056 <sys_yield>
  802045:	eb e0                	jmp    802027 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802047:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80204a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80204e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802051:	89 c2                	mov    %eax,%edx
  802053:	c1 fa 1f             	sar    $0x1f,%edx
  802056:	89 d1                	mov    %edx,%ecx
  802058:	c1 e9 1b             	shr    $0x1b,%ecx
  80205b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80205e:	83 e2 1f             	and    $0x1f,%edx
  802061:	29 ca                	sub    %ecx,%edx
  802063:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802067:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80206b:	83 c0 01             	add    $0x1,%eax
  80206e:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802071:	83 c7 01             	add    $0x1,%edi
  802074:	eb ac                	jmp    802022 <devpipe_write+0x20>
	return i;
  802076:	8b 45 10             	mov    0x10(%ebp),%eax
  802079:	eb 05                	jmp    802080 <devpipe_write+0x7e>
				return 0;
  80207b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802080:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5f                   	pop    %edi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    

00802088 <devpipe_read>:
{
  802088:	f3 0f 1e fb          	endbr32 
  80208c:	55                   	push   %ebp
  80208d:	89 e5                	mov    %esp,%ebp
  80208f:	57                   	push   %edi
  802090:	56                   	push   %esi
  802091:	53                   	push   %ebx
  802092:	83 ec 18             	sub    $0x18,%esp
  802095:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802098:	57                   	push   %edi
  802099:	e8 86 f1 ff ff       	call   801224 <fd2data>
  80209e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8020a0:	83 c4 10             	add    $0x10,%esp
  8020a3:	be 00 00 00 00       	mov    $0x0,%esi
  8020a8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020ab:	75 14                	jne    8020c1 <devpipe_read+0x39>
	return i;
  8020ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8020b0:	eb 02                	jmp    8020b4 <devpipe_read+0x2c>
				return i;
  8020b2:	89 f0                	mov    %esi,%eax
}
  8020b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020b7:	5b                   	pop    %ebx
  8020b8:	5e                   	pop    %esi
  8020b9:	5f                   	pop    %edi
  8020ba:	5d                   	pop    %ebp
  8020bb:	c3                   	ret    
			sys_yield();
  8020bc:	e8 95 ef ff ff       	call   801056 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8020c1:	8b 03                	mov    (%ebx),%eax
  8020c3:	3b 43 04             	cmp    0x4(%ebx),%eax
  8020c6:	75 18                	jne    8020e0 <devpipe_read+0x58>
			if (i > 0)
  8020c8:	85 f6                	test   %esi,%esi
  8020ca:	75 e6                	jne    8020b2 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8020cc:	89 da                	mov    %ebx,%edx
  8020ce:	89 f8                	mov    %edi,%eax
  8020d0:	e8 c8 fe ff ff       	call   801f9d <_pipeisclosed>
  8020d5:	85 c0                	test   %eax,%eax
  8020d7:	74 e3                	je     8020bc <devpipe_read+0x34>
				return 0;
  8020d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8020de:	eb d4                	jmp    8020b4 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020e0:	99                   	cltd   
  8020e1:	c1 ea 1b             	shr    $0x1b,%edx
  8020e4:	01 d0                	add    %edx,%eax
  8020e6:	83 e0 1f             	and    $0x1f,%eax
  8020e9:	29 d0                	sub    %edx,%eax
  8020eb:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8020f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020f3:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8020f6:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8020f9:	83 c6 01             	add    $0x1,%esi
  8020fc:	eb aa                	jmp    8020a8 <devpipe_read+0x20>

008020fe <pipe>:
{
  8020fe:	f3 0f 1e fb          	endbr32 
  802102:	55                   	push   %ebp
  802103:	89 e5                	mov    %esp,%ebp
  802105:	56                   	push   %esi
  802106:	53                   	push   %ebx
  802107:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80210a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80210d:	50                   	push   %eax
  80210e:	e8 2c f1 ff ff       	call   80123f <fd_alloc>
  802113:	89 c3                	mov    %eax,%ebx
  802115:	83 c4 10             	add    $0x10,%esp
  802118:	85 c0                	test   %eax,%eax
  80211a:	0f 88 23 01 00 00    	js     802243 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802120:	83 ec 04             	sub    $0x4,%esp
  802123:	68 07 04 00 00       	push   $0x407
  802128:	ff 75 f4             	pushl  -0xc(%ebp)
  80212b:	6a 00                	push   $0x0
  80212d:	e8 47 ef ff ff       	call   801079 <sys_page_alloc>
  802132:	89 c3                	mov    %eax,%ebx
  802134:	83 c4 10             	add    $0x10,%esp
  802137:	85 c0                	test   %eax,%eax
  802139:	0f 88 04 01 00 00    	js     802243 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  80213f:	83 ec 0c             	sub    $0xc,%esp
  802142:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802145:	50                   	push   %eax
  802146:	e8 f4 f0 ff ff       	call   80123f <fd_alloc>
  80214b:	89 c3                	mov    %eax,%ebx
  80214d:	83 c4 10             	add    $0x10,%esp
  802150:	85 c0                	test   %eax,%eax
  802152:	0f 88 db 00 00 00    	js     802233 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802158:	83 ec 04             	sub    $0x4,%esp
  80215b:	68 07 04 00 00       	push   $0x407
  802160:	ff 75 f0             	pushl  -0x10(%ebp)
  802163:	6a 00                	push   $0x0
  802165:	e8 0f ef ff ff       	call   801079 <sys_page_alloc>
  80216a:	89 c3                	mov    %eax,%ebx
  80216c:	83 c4 10             	add    $0x10,%esp
  80216f:	85 c0                	test   %eax,%eax
  802171:	0f 88 bc 00 00 00    	js     802233 <pipe+0x135>
	va = fd2data(fd0);
  802177:	83 ec 0c             	sub    $0xc,%esp
  80217a:	ff 75 f4             	pushl  -0xc(%ebp)
  80217d:	e8 a2 f0 ff ff       	call   801224 <fd2data>
  802182:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802184:	83 c4 0c             	add    $0xc,%esp
  802187:	68 07 04 00 00       	push   $0x407
  80218c:	50                   	push   %eax
  80218d:	6a 00                	push   $0x0
  80218f:	e8 e5 ee ff ff       	call   801079 <sys_page_alloc>
  802194:	89 c3                	mov    %eax,%ebx
  802196:	83 c4 10             	add    $0x10,%esp
  802199:	85 c0                	test   %eax,%eax
  80219b:	0f 88 82 00 00 00    	js     802223 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021a1:	83 ec 0c             	sub    $0xc,%esp
  8021a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8021a7:	e8 78 f0 ff ff       	call   801224 <fd2data>
  8021ac:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021b3:	50                   	push   %eax
  8021b4:	6a 00                	push   $0x0
  8021b6:	56                   	push   %esi
  8021b7:	6a 00                	push   $0x0
  8021b9:	e8 e1 ee ff ff       	call   80109f <sys_page_map>
  8021be:	89 c3                	mov    %eax,%ebx
  8021c0:	83 c4 20             	add    $0x20,%esp
  8021c3:	85 c0                	test   %eax,%eax
  8021c5:	78 4e                	js     802215 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8021c7:	a1 7c 30 80 00       	mov    0x80307c,%eax
  8021cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021cf:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8021d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021d4:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8021db:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021de:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8021e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021e3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8021ea:	83 ec 0c             	sub    $0xc,%esp
  8021ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8021f0:	e8 1b f0 ff ff       	call   801210 <fd2num>
  8021f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021f8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021fa:	83 c4 04             	add    $0x4,%esp
  8021fd:	ff 75 f0             	pushl  -0x10(%ebp)
  802200:	e8 0b f0 ff ff       	call   801210 <fd2num>
  802205:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802208:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80220b:	83 c4 10             	add    $0x10,%esp
  80220e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802213:	eb 2e                	jmp    802243 <pipe+0x145>
	sys_page_unmap(0, va);
  802215:	83 ec 08             	sub    $0x8,%esp
  802218:	56                   	push   %esi
  802219:	6a 00                	push   $0x0
  80221b:	e8 a4 ee ff ff       	call   8010c4 <sys_page_unmap>
  802220:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802223:	83 ec 08             	sub    $0x8,%esp
  802226:	ff 75 f0             	pushl  -0x10(%ebp)
  802229:	6a 00                	push   $0x0
  80222b:	e8 94 ee ff ff       	call   8010c4 <sys_page_unmap>
  802230:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802233:	83 ec 08             	sub    $0x8,%esp
  802236:	ff 75 f4             	pushl  -0xc(%ebp)
  802239:	6a 00                	push   $0x0
  80223b:	e8 84 ee ff ff       	call   8010c4 <sys_page_unmap>
  802240:	83 c4 10             	add    $0x10,%esp
}
  802243:	89 d8                	mov    %ebx,%eax
  802245:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802248:	5b                   	pop    %ebx
  802249:	5e                   	pop    %esi
  80224a:	5d                   	pop    %ebp
  80224b:	c3                   	ret    

0080224c <pipeisclosed>:
{
  80224c:	f3 0f 1e fb          	endbr32 
  802250:	55                   	push   %ebp
  802251:	89 e5                	mov    %esp,%ebp
  802253:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802256:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802259:	50                   	push   %eax
  80225a:	ff 75 08             	pushl  0x8(%ebp)
  80225d:	e8 33 f0 ff ff       	call   801295 <fd_lookup>
  802262:	83 c4 10             	add    $0x10,%esp
  802265:	85 c0                	test   %eax,%eax
  802267:	78 18                	js     802281 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  802269:	83 ec 0c             	sub    $0xc,%esp
  80226c:	ff 75 f4             	pushl  -0xc(%ebp)
  80226f:	e8 b0 ef ff ff       	call   801224 <fd2data>
  802274:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802276:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802279:	e8 1f fd ff ff       	call   801f9d <_pipeisclosed>
  80227e:	83 c4 10             	add    $0x10,%esp
}
  802281:	c9                   	leave  
  802282:	c3                   	ret    

00802283 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802283:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  802287:	b8 00 00 00 00       	mov    $0x0,%eax
  80228c:	c3                   	ret    

0080228d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80228d:	f3 0f 1e fb          	endbr32 
  802291:	55                   	push   %ebp
  802292:	89 e5                	mov    %esp,%ebp
  802294:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802297:	68 db 2d 80 00       	push   $0x802ddb
  80229c:	ff 75 0c             	pushl  0xc(%ebp)
  80229f:	e8 6c e9 ff ff       	call   800c10 <strcpy>
	return 0;
}
  8022a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8022a9:	c9                   	leave  
  8022aa:	c3                   	ret    

008022ab <devcons_write>:
{
  8022ab:	f3 0f 1e fb          	endbr32 
  8022af:	55                   	push   %ebp
  8022b0:	89 e5                	mov    %esp,%ebp
  8022b2:	57                   	push   %edi
  8022b3:	56                   	push   %esi
  8022b4:	53                   	push   %ebx
  8022b5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8022bb:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8022c0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8022c6:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022c9:	73 31                	jae    8022fc <devcons_write+0x51>
		m = n - tot;
  8022cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022ce:	29 f3                	sub    %esi,%ebx
  8022d0:	83 fb 7f             	cmp    $0x7f,%ebx
  8022d3:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8022d8:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8022db:	83 ec 04             	sub    $0x4,%esp
  8022de:	53                   	push   %ebx
  8022df:	89 f0                	mov    %esi,%eax
  8022e1:	03 45 0c             	add    0xc(%ebp),%eax
  8022e4:	50                   	push   %eax
  8022e5:	57                   	push   %edi
  8022e6:	e8 23 eb ff ff       	call   800e0e <memmove>
		sys_cputs(buf, m);
  8022eb:	83 c4 08             	add    $0x8,%esp
  8022ee:	53                   	push   %ebx
  8022ef:	57                   	push   %edi
  8022f0:	e8 d5 ec ff ff       	call   800fca <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8022f5:	01 de                	add    %ebx,%esi
  8022f7:	83 c4 10             	add    $0x10,%esp
  8022fa:	eb ca                	jmp    8022c6 <devcons_write+0x1b>
}
  8022fc:	89 f0                	mov    %esi,%eax
  8022fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802301:	5b                   	pop    %ebx
  802302:	5e                   	pop    %esi
  802303:	5f                   	pop    %edi
  802304:	5d                   	pop    %ebp
  802305:	c3                   	ret    

00802306 <devcons_read>:
{
  802306:	f3 0f 1e fb          	endbr32 
  80230a:	55                   	push   %ebp
  80230b:	89 e5                	mov    %esp,%ebp
  80230d:	83 ec 08             	sub    $0x8,%esp
  802310:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802315:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802319:	74 21                	je     80233c <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  80231b:	e8 cc ec ff ff       	call   800fec <sys_cgetc>
  802320:	85 c0                	test   %eax,%eax
  802322:	75 07                	jne    80232b <devcons_read+0x25>
		sys_yield();
  802324:	e8 2d ed ff ff       	call   801056 <sys_yield>
  802329:	eb f0                	jmp    80231b <devcons_read+0x15>
	if (c < 0)
  80232b:	78 0f                	js     80233c <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  80232d:	83 f8 04             	cmp    $0x4,%eax
  802330:	74 0c                	je     80233e <devcons_read+0x38>
	*(char*)vbuf = c;
  802332:	8b 55 0c             	mov    0xc(%ebp),%edx
  802335:	88 02                	mov    %al,(%edx)
	return 1;
  802337:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80233c:	c9                   	leave  
  80233d:	c3                   	ret    
		return 0;
  80233e:	b8 00 00 00 00       	mov    $0x0,%eax
  802343:	eb f7                	jmp    80233c <devcons_read+0x36>

00802345 <cputchar>:
{
  802345:	f3 0f 1e fb          	endbr32 
  802349:	55                   	push   %ebp
  80234a:	89 e5                	mov    %esp,%ebp
  80234c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80234f:	8b 45 08             	mov    0x8(%ebp),%eax
  802352:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802355:	6a 01                	push   $0x1
  802357:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80235a:	50                   	push   %eax
  80235b:	e8 6a ec ff ff       	call   800fca <sys_cputs>
}
  802360:	83 c4 10             	add    $0x10,%esp
  802363:	c9                   	leave  
  802364:	c3                   	ret    

00802365 <getchar>:
{
  802365:	f3 0f 1e fb          	endbr32 
  802369:	55                   	push   %ebp
  80236a:	89 e5                	mov    %esp,%ebp
  80236c:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80236f:	6a 01                	push   $0x1
  802371:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802374:	50                   	push   %eax
  802375:	6a 00                	push   $0x0
  802377:	e8 a1 f1 ff ff       	call   80151d <read>
	if (r < 0)
  80237c:	83 c4 10             	add    $0x10,%esp
  80237f:	85 c0                	test   %eax,%eax
  802381:	78 06                	js     802389 <getchar+0x24>
	if (r < 1)
  802383:	74 06                	je     80238b <getchar+0x26>
	return c;
  802385:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802389:	c9                   	leave  
  80238a:	c3                   	ret    
		return -E_EOF;
  80238b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802390:	eb f7                	jmp    802389 <getchar+0x24>

00802392 <iscons>:
{
  802392:	f3 0f 1e fb          	endbr32 
  802396:	55                   	push   %ebp
  802397:	89 e5                	mov    %esp,%ebp
  802399:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80239c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80239f:	50                   	push   %eax
  8023a0:	ff 75 08             	pushl  0x8(%ebp)
  8023a3:	e8 ed ee ff ff       	call   801295 <fd_lookup>
  8023a8:	83 c4 10             	add    $0x10,%esp
  8023ab:	85 c0                	test   %eax,%eax
  8023ad:	78 11                	js     8023c0 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8023af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023b2:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8023b8:	39 10                	cmp    %edx,(%eax)
  8023ba:	0f 94 c0             	sete   %al
  8023bd:	0f b6 c0             	movzbl %al,%eax
}
  8023c0:	c9                   	leave  
  8023c1:	c3                   	ret    

008023c2 <opencons>:
{
  8023c2:	f3 0f 1e fb          	endbr32 
  8023c6:	55                   	push   %ebp
  8023c7:	89 e5                	mov    %esp,%ebp
  8023c9:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8023cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023cf:	50                   	push   %eax
  8023d0:	e8 6a ee ff ff       	call   80123f <fd_alloc>
  8023d5:	83 c4 10             	add    $0x10,%esp
  8023d8:	85 c0                	test   %eax,%eax
  8023da:	78 3a                	js     802416 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023dc:	83 ec 04             	sub    $0x4,%esp
  8023df:	68 07 04 00 00       	push   $0x407
  8023e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8023e7:	6a 00                	push   $0x0
  8023e9:	e8 8b ec ff ff       	call   801079 <sys_page_alloc>
  8023ee:	83 c4 10             	add    $0x10,%esp
  8023f1:	85 c0                	test   %eax,%eax
  8023f3:	78 21                	js     802416 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8023f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f8:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8023fe:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802400:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802403:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80240a:	83 ec 0c             	sub    $0xc,%esp
  80240d:	50                   	push   %eax
  80240e:	e8 fd ed ff ff       	call   801210 <fd2num>
  802413:	83 c4 10             	add    $0x10,%esp
}
  802416:	c9                   	leave  
  802417:	c3                   	ret    

00802418 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802418:	f3 0f 1e fb          	endbr32 
  80241c:	55                   	push   %ebp
  80241d:	89 e5                	mov    %esp,%ebp
  80241f:	56                   	push   %esi
  802420:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802421:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802424:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80242a:	e8 04 ec ff ff       	call   801033 <sys_getenvid>
  80242f:	83 ec 0c             	sub    $0xc,%esp
  802432:	ff 75 0c             	pushl  0xc(%ebp)
  802435:	ff 75 08             	pushl  0x8(%ebp)
  802438:	56                   	push   %esi
  802439:	50                   	push   %eax
  80243a:	68 e8 2d 80 00       	push   $0x802de8
  80243f:	e8 c2 e1 ff ff       	call   800606 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802444:	83 c4 18             	add    $0x18,%esp
  802447:	53                   	push   %ebx
  802448:	ff 75 10             	pushl  0x10(%ebp)
  80244b:	e8 61 e1 ff ff       	call   8005b1 <vcprintf>
	cprintf("\n");
  802450:	c7 04 24 d4 2d 80 00 	movl   $0x802dd4,(%esp)
  802457:	e8 aa e1 ff ff       	call   800606 <cprintf>
  80245c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80245f:	cc                   	int3   
  802460:	eb fd                	jmp    80245f <_panic+0x47>

00802462 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802462:	f3 0f 1e fb          	endbr32 
  802466:	55                   	push   %ebp
  802467:	89 e5                	mov    %esp,%ebp
  802469:	56                   	push   %esi
  80246a:	53                   	push   %ebx
  80246b:	8b 75 08             	mov    0x8(%ebp),%esi
  80246e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802471:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  802474:	85 c0                	test   %eax,%eax
  802476:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80247b:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  80247e:	83 ec 0c             	sub    $0xc,%esp
  802481:	50                   	push   %eax
  802482:	e8 f8 ec ff ff       	call   80117f <sys_ipc_recv>
  802487:	83 c4 10             	add    $0x10,%esp
  80248a:	85 c0                	test   %eax,%eax
  80248c:	75 2b                	jne    8024b9 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  80248e:	85 f6                	test   %esi,%esi
  802490:	74 0a                	je     80249c <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  802492:	a1 18 40 80 00       	mov    0x804018,%eax
  802497:	8b 40 74             	mov    0x74(%eax),%eax
  80249a:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  80249c:	85 db                	test   %ebx,%ebx
  80249e:	74 0a                	je     8024aa <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  8024a0:	a1 18 40 80 00       	mov    0x804018,%eax
  8024a5:	8b 40 78             	mov    0x78(%eax),%eax
  8024a8:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  8024aa:	a1 18 40 80 00       	mov    0x804018,%eax
  8024af:	8b 40 70             	mov    0x70(%eax),%eax
}
  8024b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024b5:	5b                   	pop    %ebx
  8024b6:	5e                   	pop    %esi
  8024b7:	5d                   	pop    %ebp
  8024b8:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  8024b9:	85 f6                	test   %esi,%esi
  8024bb:	74 06                	je     8024c3 <ipc_recv+0x61>
  8024bd:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8024c3:	85 db                	test   %ebx,%ebx
  8024c5:	74 eb                	je     8024b2 <ipc_recv+0x50>
  8024c7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8024cd:	eb e3                	jmp    8024b2 <ipc_recv+0x50>

008024cf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024cf:	f3 0f 1e fb          	endbr32 
  8024d3:	55                   	push   %ebp
  8024d4:	89 e5                	mov    %esp,%ebp
  8024d6:	57                   	push   %edi
  8024d7:	56                   	push   %esi
  8024d8:	53                   	push   %ebx
  8024d9:	83 ec 0c             	sub    $0xc,%esp
  8024dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024df:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  8024e5:	85 db                	test   %ebx,%ebx
  8024e7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8024ec:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8024ef:	ff 75 14             	pushl  0x14(%ebp)
  8024f2:	53                   	push   %ebx
  8024f3:	56                   	push   %esi
  8024f4:	57                   	push   %edi
  8024f5:	e8 5e ec ff ff       	call   801158 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  8024fa:	83 c4 10             	add    $0x10,%esp
  8024fd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802500:	75 07                	jne    802509 <ipc_send+0x3a>
			sys_yield();
  802502:	e8 4f eb ff ff       	call   801056 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802507:	eb e6                	jmp    8024ef <ipc_send+0x20>
		}
		else if (ret == 0)
  802509:	85 c0                	test   %eax,%eax
  80250b:	75 08                	jne    802515 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  80250d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802510:	5b                   	pop    %ebx
  802511:	5e                   	pop    %esi
  802512:	5f                   	pop    %edi
  802513:	5d                   	pop    %ebp
  802514:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802515:	50                   	push   %eax
  802516:	68 0b 2e 80 00       	push   $0x802e0b
  80251b:	6a 48                	push   $0x48
  80251d:	68 19 2e 80 00       	push   $0x802e19
  802522:	e8 f1 fe ff ff       	call   802418 <_panic>

00802527 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802527:	f3 0f 1e fb          	endbr32 
  80252b:	55                   	push   %ebp
  80252c:	89 e5                	mov    %esp,%ebp
  80252e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802531:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802536:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802539:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80253f:	8b 52 50             	mov    0x50(%edx),%edx
  802542:	39 ca                	cmp    %ecx,%edx
  802544:	74 11                	je     802557 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802546:	83 c0 01             	add    $0x1,%eax
  802549:	3d 00 04 00 00       	cmp    $0x400,%eax
  80254e:	75 e6                	jne    802536 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802550:	b8 00 00 00 00       	mov    $0x0,%eax
  802555:	eb 0b                	jmp    802562 <ipc_find_env+0x3b>
			return envs[i].env_id;
  802557:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80255a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80255f:	8b 40 48             	mov    0x48(%eax),%eax
}
  802562:	5d                   	pop    %ebp
  802563:	c3                   	ret    

00802564 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802564:	f3 0f 1e fb          	endbr32 
  802568:	55                   	push   %ebp
  802569:	89 e5                	mov    %esp,%ebp
  80256b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80256e:	89 c2                	mov    %eax,%edx
  802570:	c1 ea 16             	shr    $0x16,%edx
  802573:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80257a:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80257f:	f6 c1 01             	test   $0x1,%cl
  802582:	74 1c                	je     8025a0 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802584:	c1 e8 0c             	shr    $0xc,%eax
  802587:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80258e:	a8 01                	test   $0x1,%al
  802590:	74 0e                	je     8025a0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802592:	c1 e8 0c             	shr    $0xc,%eax
  802595:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80259c:	ef 
  80259d:	0f b7 d2             	movzwl %dx,%edx
}
  8025a0:	89 d0                	mov    %edx,%eax
  8025a2:	5d                   	pop    %ebp
  8025a3:	c3                   	ret    
  8025a4:	66 90                	xchg   %ax,%ax
  8025a6:	66 90                	xchg   %ax,%ax
  8025a8:	66 90                	xchg   %ax,%ax
  8025aa:	66 90                	xchg   %ax,%ax
  8025ac:	66 90                	xchg   %ax,%ax
  8025ae:	66 90                	xchg   %ax,%ax

008025b0 <__udivdi3>:
  8025b0:	f3 0f 1e fb          	endbr32 
  8025b4:	55                   	push   %ebp
  8025b5:	57                   	push   %edi
  8025b6:	56                   	push   %esi
  8025b7:	53                   	push   %ebx
  8025b8:	83 ec 1c             	sub    $0x1c,%esp
  8025bb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025bf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8025c3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025c7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8025cb:	85 d2                	test   %edx,%edx
  8025cd:	75 19                	jne    8025e8 <__udivdi3+0x38>
  8025cf:	39 f3                	cmp    %esi,%ebx
  8025d1:	76 4d                	jbe    802620 <__udivdi3+0x70>
  8025d3:	31 ff                	xor    %edi,%edi
  8025d5:	89 e8                	mov    %ebp,%eax
  8025d7:	89 f2                	mov    %esi,%edx
  8025d9:	f7 f3                	div    %ebx
  8025db:	89 fa                	mov    %edi,%edx
  8025dd:	83 c4 1c             	add    $0x1c,%esp
  8025e0:	5b                   	pop    %ebx
  8025e1:	5e                   	pop    %esi
  8025e2:	5f                   	pop    %edi
  8025e3:	5d                   	pop    %ebp
  8025e4:	c3                   	ret    
  8025e5:	8d 76 00             	lea    0x0(%esi),%esi
  8025e8:	39 f2                	cmp    %esi,%edx
  8025ea:	76 14                	jbe    802600 <__udivdi3+0x50>
  8025ec:	31 ff                	xor    %edi,%edi
  8025ee:	31 c0                	xor    %eax,%eax
  8025f0:	89 fa                	mov    %edi,%edx
  8025f2:	83 c4 1c             	add    $0x1c,%esp
  8025f5:	5b                   	pop    %ebx
  8025f6:	5e                   	pop    %esi
  8025f7:	5f                   	pop    %edi
  8025f8:	5d                   	pop    %ebp
  8025f9:	c3                   	ret    
  8025fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802600:	0f bd fa             	bsr    %edx,%edi
  802603:	83 f7 1f             	xor    $0x1f,%edi
  802606:	75 48                	jne    802650 <__udivdi3+0xa0>
  802608:	39 f2                	cmp    %esi,%edx
  80260a:	72 06                	jb     802612 <__udivdi3+0x62>
  80260c:	31 c0                	xor    %eax,%eax
  80260e:	39 eb                	cmp    %ebp,%ebx
  802610:	77 de                	ja     8025f0 <__udivdi3+0x40>
  802612:	b8 01 00 00 00       	mov    $0x1,%eax
  802617:	eb d7                	jmp    8025f0 <__udivdi3+0x40>
  802619:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802620:	89 d9                	mov    %ebx,%ecx
  802622:	85 db                	test   %ebx,%ebx
  802624:	75 0b                	jne    802631 <__udivdi3+0x81>
  802626:	b8 01 00 00 00       	mov    $0x1,%eax
  80262b:	31 d2                	xor    %edx,%edx
  80262d:	f7 f3                	div    %ebx
  80262f:	89 c1                	mov    %eax,%ecx
  802631:	31 d2                	xor    %edx,%edx
  802633:	89 f0                	mov    %esi,%eax
  802635:	f7 f1                	div    %ecx
  802637:	89 c6                	mov    %eax,%esi
  802639:	89 e8                	mov    %ebp,%eax
  80263b:	89 f7                	mov    %esi,%edi
  80263d:	f7 f1                	div    %ecx
  80263f:	89 fa                	mov    %edi,%edx
  802641:	83 c4 1c             	add    $0x1c,%esp
  802644:	5b                   	pop    %ebx
  802645:	5e                   	pop    %esi
  802646:	5f                   	pop    %edi
  802647:	5d                   	pop    %ebp
  802648:	c3                   	ret    
  802649:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802650:	89 f9                	mov    %edi,%ecx
  802652:	b8 20 00 00 00       	mov    $0x20,%eax
  802657:	29 f8                	sub    %edi,%eax
  802659:	d3 e2                	shl    %cl,%edx
  80265b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80265f:	89 c1                	mov    %eax,%ecx
  802661:	89 da                	mov    %ebx,%edx
  802663:	d3 ea                	shr    %cl,%edx
  802665:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802669:	09 d1                	or     %edx,%ecx
  80266b:	89 f2                	mov    %esi,%edx
  80266d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802671:	89 f9                	mov    %edi,%ecx
  802673:	d3 e3                	shl    %cl,%ebx
  802675:	89 c1                	mov    %eax,%ecx
  802677:	d3 ea                	shr    %cl,%edx
  802679:	89 f9                	mov    %edi,%ecx
  80267b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80267f:	89 eb                	mov    %ebp,%ebx
  802681:	d3 e6                	shl    %cl,%esi
  802683:	89 c1                	mov    %eax,%ecx
  802685:	d3 eb                	shr    %cl,%ebx
  802687:	09 de                	or     %ebx,%esi
  802689:	89 f0                	mov    %esi,%eax
  80268b:	f7 74 24 08          	divl   0x8(%esp)
  80268f:	89 d6                	mov    %edx,%esi
  802691:	89 c3                	mov    %eax,%ebx
  802693:	f7 64 24 0c          	mull   0xc(%esp)
  802697:	39 d6                	cmp    %edx,%esi
  802699:	72 15                	jb     8026b0 <__udivdi3+0x100>
  80269b:	89 f9                	mov    %edi,%ecx
  80269d:	d3 e5                	shl    %cl,%ebp
  80269f:	39 c5                	cmp    %eax,%ebp
  8026a1:	73 04                	jae    8026a7 <__udivdi3+0xf7>
  8026a3:	39 d6                	cmp    %edx,%esi
  8026a5:	74 09                	je     8026b0 <__udivdi3+0x100>
  8026a7:	89 d8                	mov    %ebx,%eax
  8026a9:	31 ff                	xor    %edi,%edi
  8026ab:	e9 40 ff ff ff       	jmp    8025f0 <__udivdi3+0x40>
  8026b0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8026b3:	31 ff                	xor    %edi,%edi
  8026b5:	e9 36 ff ff ff       	jmp    8025f0 <__udivdi3+0x40>
  8026ba:	66 90                	xchg   %ax,%ax
  8026bc:	66 90                	xchg   %ax,%ax
  8026be:	66 90                	xchg   %ax,%ax

008026c0 <__umoddi3>:
  8026c0:	f3 0f 1e fb          	endbr32 
  8026c4:	55                   	push   %ebp
  8026c5:	57                   	push   %edi
  8026c6:	56                   	push   %esi
  8026c7:	53                   	push   %ebx
  8026c8:	83 ec 1c             	sub    $0x1c,%esp
  8026cb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8026cf:	8b 74 24 30          	mov    0x30(%esp),%esi
  8026d3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8026d7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026db:	85 c0                	test   %eax,%eax
  8026dd:	75 19                	jne    8026f8 <__umoddi3+0x38>
  8026df:	39 df                	cmp    %ebx,%edi
  8026e1:	76 5d                	jbe    802740 <__umoddi3+0x80>
  8026e3:	89 f0                	mov    %esi,%eax
  8026e5:	89 da                	mov    %ebx,%edx
  8026e7:	f7 f7                	div    %edi
  8026e9:	89 d0                	mov    %edx,%eax
  8026eb:	31 d2                	xor    %edx,%edx
  8026ed:	83 c4 1c             	add    $0x1c,%esp
  8026f0:	5b                   	pop    %ebx
  8026f1:	5e                   	pop    %esi
  8026f2:	5f                   	pop    %edi
  8026f3:	5d                   	pop    %ebp
  8026f4:	c3                   	ret    
  8026f5:	8d 76 00             	lea    0x0(%esi),%esi
  8026f8:	89 f2                	mov    %esi,%edx
  8026fa:	39 d8                	cmp    %ebx,%eax
  8026fc:	76 12                	jbe    802710 <__umoddi3+0x50>
  8026fe:	89 f0                	mov    %esi,%eax
  802700:	89 da                	mov    %ebx,%edx
  802702:	83 c4 1c             	add    $0x1c,%esp
  802705:	5b                   	pop    %ebx
  802706:	5e                   	pop    %esi
  802707:	5f                   	pop    %edi
  802708:	5d                   	pop    %ebp
  802709:	c3                   	ret    
  80270a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802710:	0f bd e8             	bsr    %eax,%ebp
  802713:	83 f5 1f             	xor    $0x1f,%ebp
  802716:	75 50                	jne    802768 <__umoddi3+0xa8>
  802718:	39 d8                	cmp    %ebx,%eax
  80271a:	0f 82 e0 00 00 00    	jb     802800 <__umoddi3+0x140>
  802720:	89 d9                	mov    %ebx,%ecx
  802722:	39 f7                	cmp    %esi,%edi
  802724:	0f 86 d6 00 00 00    	jbe    802800 <__umoddi3+0x140>
  80272a:	89 d0                	mov    %edx,%eax
  80272c:	89 ca                	mov    %ecx,%edx
  80272e:	83 c4 1c             	add    $0x1c,%esp
  802731:	5b                   	pop    %ebx
  802732:	5e                   	pop    %esi
  802733:	5f                   	pop    %edi
  802734:	5d                   	pop    %ebp
  802735:	c3                   	ret    
  802736:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80273d:	8d 76 00             	lea    0x0(%esi),%esi
  802740:	89 fd                	mov    %edi,%ebp
  802742:	85 ff                	test   %edi,%edi
  802744:	75 0b                	jne    802751 <__umoddi3+0x91>
  802746:	b8 01 00 00 00       	mov    $0x1,%eax
  80274b:	31 d2                	xor    %edx,%edx
  80274d:	f7 f7                	div    %edi
  80274f:	89 c5                	mov    %eax,%ebp
  802751:	89 d8                	mov    %ebx,%eax
  802753:	31 d2                	xor    %edx,%edx
  802755:	f7 f5                	div    %ebp
  802757:	89 f0                	mov    %esi,%eax
  802759:	f7 f5                	div    %ebp
  80275b:	89 d0                	mov    %edx,%eax
  80275d:	31 d2                	xor    %edx,%edx
  80275f:	eb 8c                	jmp    8026ed <__umoddi3+0x2d>
  802761:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802768:	89 e9                	mov    %ebp,%ecx
  80276a:	ba 20 00 00 00       	mov    $0x20,%edx
  80276f:	29 ea                	sub    %ebp,%edx
  802771:	d3 e0                	shl    %cl,%eax
  802773:	89 44 24 08          	mov    %eax,0x8(%esp)
  802777:	89 d1                	mov    %edx,%ecx
  802779:	89 f8                	mov    %edi,%eax
  80277b:	d3 e8                	shr    %cl,%eax
  80277d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802781:	89 54 24 04          	mov    %edx,0x4(%esp)
  802785:	8b 54 24 04          	mov    0x4(%esp),%edx
  802789:	09 c1                	or     %eax,%ecx
  80278b:	89 d8                	mov    %ebx,%eax
  80278d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802791:	89 e9                	mov    %ebp,%ecx
  802793:	d3 e7                	shl    %cl,%edi
  802795:	89 d1                	mov    %edx,%ecx
  802797:	d3 e8                	shr    %cl,%eax
  802799:	89 e9                	mov    %ebp,%ecx
  80279b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80279f:	d3 e3                	shl    %cl,%ebx
  8027a1:	89 c7                	mov    %eax,%edi
  8027a3:	89 d1                	mov    %edx,%ecx
  8027a5:	89 f0                	mov    %esi,%eax
  8027a7:	d3 e8                	shr    %cl,%eax
  8027a9:	89 e9                	mov    %ebp,%ecx
  8027ab:	89 fa                	mov    %edi,%edx
  8027ad:	d3 e6                	shl    %cl,%esi
  8027af:	09 d8                	or     %ebx,%eax
  8027b1:	f7 74 24 08          	divl   0x8(%esp)
  8027b5:	89 d1                	mov    %edx,%ecx
  8027b7:	89 f3                	mov    %esi,%ebx
  8027b9:	f7 64 24 0c          	mull   0xc(%esp)
  8027bd:	89 c6                	mov    %eax,%esi
  8027bf:	89 d7                	mov    %edx,%edi
  8027c1:	39 d1                	cmp    %edx,%ecx
  8027c3:	72 06                	jb     8027cb <__umoddi3+0x10b>
  8027c5:	75 10                	jne    8027d7 <__umoddi3+0x117>
  8027c7:	39 c3                	cmp    %eax,%ebx
  8027c9:	73 0c                	jae    8027d7 <__umoddi3+0x117>
  8027cb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8027cf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8027d3:	89 d7                	mov    %edx,%edi
  8027d5:	89 c6                	mov    %eax,%esi
  8027d7:	89 ca                	mov    %ecx,%edx
  8027d9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027de:	29 f3                	sub    %esi,%ebx
  8027e0:	19 fa                	sbb    %edi,%edx
  8027e2:	89 d0                	mov    %edx,%eax
  8027e4:	d3 e0                	shl    %cl,%eax
  8027e6:	89 e9                	mov    %ebp,%ecx
  8027e8:	d3 eb                	shr    %cl,%ebx
  8027ea:	d3 ea                	shr    %cl,%edx
  8027ec:	09 d8                	or     %ebx,%eax
  8027ee:	83 c4 1c             	add    $0x1c,%esp
  8027f1:	5b                   	pop    %ebx
  8027f2:	5e                   	pop    %esi
  8027f3:	5f                   	pop    %edi
  8027f4:	5d                   	pop    %ebp
  8027f5:	c3                   	ret    
  8027f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027fd:	8d 76 00             	lea    0x0(%esi),%esi
  802800:	29 fe                	sub    %edi,%esi
  802802:	19 c3                	sbb    %eax,%ebx
  802804:	89 f2                	mov    %esi,%edx
  802806:	89 d9                	mov    %ebx,%ecx
  802808:	e9 1d ff ff ff       	jmp    80272a <__umoddi3+0x6a>
