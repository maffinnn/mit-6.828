
obj/user/httpd.debug:     file format elf32-i386


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
  80002c:	e8 9e 07 00 00       	call   8007cf <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:
	{404, "Not Found"},
};

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n", m);
  800039:	50                   	push   %eax
  80003a:	68 80 2d 80 00       	push   $0x802d80
  80003f:	e8 da 08 00 00       	call   80091e <cprintf>
	exit();
  800044:	e8 d0 07 00 00       	call   800819 <exit>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <send_error>:
	return 0;
}

static int
send_error(struct http_request *req, int code)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	81 ec 0c 02 00 00    	sub    $0x20c,%esp
  80005a:	89 c3                	mov    %eax,%ebx
	char buf[512];
	int r;

	struct error_messages *e = errors;
  80005c:	b8 00 40 80 00       	mov    $0x804000,%eax
	while (e->code != 0 && e->msg != 0) {
  800061:	8b 08                	mov    (%eax),%ecx
  800063:	85 c9                	test   %ecx,%ecx
  800065:	74 52                	je     8000b9 <send_error+0x6b>
		if (e->code == code)
  800067:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
  80006b:	74 09                	je     800076 <send_error+0x28>
  80006d:	39 d1                	cmp    %edx,%ecx
  80006f:	74 05                	je     800076 <send_error+0x28>
			break;
		e++;
  800071:	83 c0 08             	add    $0x8,%eax
  800074:	eb eb                	jmp    800061 <send_error+0x13>
	}

	if (e->code == 0)
		return -1;

	r = snprintf(buf, 512, "HTTP/" HTTP_VERSION" %d %s\r\n"
  800076:	8b 40 04             	mov    0x4(%eax),%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	51                   	push   %ecx
  80007e:	50                   	push   %eax
  80007f:	51                   	push   %ecx
  800080:	68 20 2e 80 00       	push   $0x802e20
  800085:	68 00 02 00 00       	push   $0x200
  80008a:	8d bd e8 fd ff ff    	lea    -0x218(%ebp),%edi
  800090:	57                   	push   %edi
  800091:	e8 31 0e 00 00       	call   800ec7 <snprintf>
  800096:	89 c6                	mov    %eax,%esi
			       "Content-type: text/html\r\n"
			       "\r\n"
			       "<html><body><p>%d - %s</p></body></html>\r\n",
			       e->code, e->msg, e->code, e->msg);

	if (write(req->sock, buf, r) != r)
  800098:	83 c4 1c             	add    $0x1c,%esp
  80009b:	50                   	push   %eax
  80009c:	57                   	push   %edi
  80009d:	ff 33                	pushl  (%ebx)
  80009f:	e8 67 18 00 00       	call   80190b <write>
  8000a4:	83 c4 10             	add    $0x10,%esp
  8000a7:	39 f0                	cmp    %esi,%eax
  8000a9:	0f 95 c0             	setne  %al
  8000ac:	0f b6 c0             	movzbl %al,%eax
  8000af:	f7 d8                	neg    %eax
		return -1;

	return 0;
}
  8000b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b4:	5b                   	pop    %ebx
  8000b5:	5e                   	pop    %esi
  8000b6:	5f                   	pop    %edi
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    
		return -1;
  8000b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8000be:	eb f1                	jmp    8000b1 <send_error+0x63>

008000c0 <handle_client>:
	return r;
}

static void
handle_client(int sock)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
  8000c6:	81 ec c0 06 00 00    	sub    $0x6c0,%esp
  8000cc:	89 c6                	mov    %eax,%esi
	struct http_request *req = &con_d;

	while (1)
	{
		// Receive message
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  8000ce:	68 00 02 00 00       	push   $0x200
  8000d3:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  8000d9:	50                   	push   %eax
  8000da:	56                   	push   %esi
  8000db:	e8 55 17 00 00       	call   801835 <read>
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	85 c0                	test   %eax,%eax
  8000e5:	78 44                	js     80012b <handle_client+0x6b>
			panic("failed to read");

		memset(req, 0, sizeof(*req));
  8000e7:	83 ec 04             	sub    $0x4,%esp
  8000ea:	6a 0c                	push   $0xc
  8000ec:	6a 00                	push   $0x0
  8000ee:	8d 45 dc             	lea    -0x24(%ebp),%eax
  8000f1:	50                   	push   %eax
  8000f2:	e8 e3 0f 00 00       	call   8010da <memset>

		req->sock = sock;
  8000f7:	89 75 dc             	mov    %esi,-0x24(%ebp)
	if (strncmp(request, "GET ", 4) != 0)
  8000fa:	83 c4 0c             	add    $0xc,%esp
  8000fd:	6a 04                	push   $0x4
  8000ff:	68 a0 2d 80 00       	push   $0x802da0
  800104:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  80010a:	50                   	push   %eax
  80010b:	e8 01 0f 00 00       	call   801011 <strncmp>
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	85 c0                	test   %eax,%eax
  800115:	0f 85 ae 02 00 00    	jne    8003c9 <handle_client+0x309>
	request += 4;
  80011b:	8d 9d e0 fd ff ff    	lea    -0x220(%ebp),%ebx
	while (*request && *request != ' ')
  800121:	f6 03 df             	testb  $0xdf,(%ebx)
  800124:	74 1c                	je     800142 <handle_client+0x82>
		request++;
  800126:	83 c3 01             	add    $0x1,%ebx
  800129:	eb f6                	jmp    800121 <handle_client+0x61>
			panic("failed to read");
  80012b:	83 ec 04             	sub    $0x4,%esp
  80012e:	68 84 2d 80 00       	push   $0x802d84
  800133:	68 16 01 00 00       	push   $0x116
  800138:	68 93 2d 80 00       	push   $0x802d93
  80013d:	e8 f5 06 00 00       	call   800837 <_panic>
	url_len = request - url;
  800142:	89 df                	mov    %ebx,%edi
  800144:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
  80014a:	29 c7                	sub    %eax,%edi
	req->url = malloc(url_len + 1);
  80014c:	83 ec 0c             	sub    $0xc,%esp
  80014f:	8d 47 01             	lea    0x1(%edi),%eax
  800152:	50                   	push   %eax
  800153:	e8 8d 21 00 00       	call   8022e5 <malloc>
  800158:	89 45 e0             	mov    %eax,-0x20(%ebp)
	memmove(req->url, url, url_len);
  80015b:	83 c4 0c             	add    $0xc,%esp
  80015e:	57                   	push   %edi
  80015f:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  800165:	51                   	push   %ecx
  800166:	50                   	push   %eax
  800167:	e8 ba 0f 00 00       	call   801126 <memmove>
	req->url[url_len] = '\0';
  80016c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80016f:	c6 04 38 00          	movb   $0x0,(%eax,%edi,1)
	request++;
  800173:	83 c3 01             	add    $0x1,%ebx
	while (*request && *request != '\n')
  800176:	83 c4 10             	add    $0x10,%esp
	request++;
  800179:	89 d8                	mov    %ebx,%eax
	while (*request && *request != '\n')
  80017b:	0f b6 10             	movzbl (%eax),%edx
  80017e:	84 d2                	test   %dl,%dl
  800180:	74 0a                	je     80018c <handle_client+0xcc>
  800182:	80 fa 0a             	cmp    $0xa,%dl
  800185:	74 05                	je     80018c <handle_client+0xcc>
		request++;
  800187:	83 c0 01             	add    $0x1,%eax
  80018a:	eb ef                	jmp    80017b <handle_client+0xbb>
	version_len = request - version;
  80018c:	29 d8                	sub    %ebx,%eax
  80018e:	89 c7                	mov    %eax,%edi
	req->version = malloc(version_len + 1);
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	8d 40 01             	lea    0x1(%eax),%eax
  800196:	50                   	push   %eax
  800197:	e8 49 21 00 00       	call   8022e5 <malloc>
  80019c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	memmove(req->version, version, version_len);
  80019f:	83 c4 0c             	add    $0xc,%esp
  8001a2:	57                   	push   %edi
  8001a3:	53                   	push   %ebx
  8001a4:	50                   	push   %eax
  8001a5:	e8 7c 0f 00 00       	call   801126 <memmove>
	req->version[version_len] = '\0';
  8001aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001ad:	c6 04 38 00          	movb   $0x0,(%eax,%edi,1)
	if ((fd=open(req->url, O_RDONLY))<0){
  8001b1:	83 c4 08             	add    $0x8,%esp
  8001b4:	6a 00                	push   $0x0
  8001b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b9:	e8 12 1b 00 00       	call   801cd0 <open>
  8001be:	89 c3                	mov    %eax,%ebx
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	78 4d                	js     800214 <handle_client+0x154>
	if ((r=fstat(fd, &st))<0)
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	8d 85 50 f9 ff ff    	lea    -0x6b0(%ebp),%eax
  8001d0:	50                   	push   %eax
  8001d1:	53                   	push   %ebx
  8001d2:	e8 6a 18 00 00       	call   801a41 <fstat>
  8001d7:	83 c4 10             	add    $0x10,%esp
  8001da:	85 c0                	test   %eax,%eax
  8001dc:	78 48                	js     800226 <handle_client+0x166>
	if (st.st_isdir)
  8001de:	83 bd d4 f9 ff ff 00 	cmpl   $0x0,-0x62c(%ebp)
  8001e5:	75 51                	jne    800238 <handle_client+0x178>
	file_size = st.st_size;
  8001e7:	8b 85 d0 f9 ff ff    	mov    -0x630(%ebp),%eax
  8001ed:	89 85 40 f9 ff ff    	mov    %eax,-0x6c0(%ebp)
	struct responce_header *h = headers;
  8001f3:	bf 10 40 80 00       	mov    $0x804010,%edi
	while (h->code != 0 && h->header!= 0) {
  8001f8:	8b 07                	mov    (%edi),%eax
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	0f 84 5e 01 00 00    	je     800360 <handle_client+0x2a0>
		if (h->code == code)
  800202:	83 7f 04 00          	cmpl   $0x0,0x4(%edi)
  800206:	74 42                	je     80024a <handle_client+0x18a>
  800208:	3d c8 00 00 00       	cmp    $0xc8,%eax
  80020d:	74 3b                	je     80024a <handle_client+0x18a>
		h++;
  80020f:	83 c7 08             	add    $0x8,%edi
  800212:	eb e4                	jmp    8001f8 <handle_client+0x138>
		return send_error(req, 404);
  800214:	ba 94 01 00 00       	mov    $0x194,%edx
  800219:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80021c:	e8 2d fe ff ff       	call   80004e <send_error>
  800221:	e9 46 01 00 00       	jmp    80036c <handle_client+0x2ac>
		return send_error(req, 404);
  800226:	ba 94 01 00 00       	mov    $0x194,%edx
  80022b:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80022e:	e8 1b fe ff ff       	call   80004e <send_error>
  800233:	e9 34 01 00 00       	jmp    80036c <handle_client+0x2ac>
		return send_error(req, 404);
  800238:	ba 94 01 00 00       	mov    $0x194,%edx
  80023d:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800240:	e8 09 fe ff ff       	call   80004e <send_error>
  800245:	e9 22 01 00 00       	jmp    80036c <handle_client+0x2ac>
	int len = strlen(h->header);
  80024a:	83 ec 0c             	sub    $0xc,%esp
  80024d:	ff 77 04             	pushl  0x4(%edi)
  800250:	e8 90 0c 00 00       	call   800ee5 <strlen>
	if (write(req->sock, h->header, len) != len) {
  800255:	83 c4 0c             	add    $0xc,%esp
  800258:	89 85 44 f9 ff ff    	mov    %eax,-0x6bc(%ebp)
  80025e:	50                   	push   %eax
  80025f:	ff 77 04             	pushl  0x4(%edi)
  800262:	ff 75 dc             	pushl  -0x24(%ebp)
  800265:	e8 a1 16 00 00       	call   80190b <write>
  80026a:	83 c4 10             	add    $0x10,%esp
  80026d:	39 85 44 f9 ff ff    	cmp    %eax,-0x6bc(%ebp)
  800273:	0f 85 19 01 00 00    	jne    800392 <handle_client+0x2d2>
	r = snprintf(buf, 64, "Content-Length: %ld\r\n", (long)size);
  800279:	ff b5 40 f9 ff ff    	pushl  -0x6c0(%ebp)
  80027f:	68 d4 2d 80 00       	push   $0x802dd4
  800284:	6a 40                	push   $0x40
  800286:	8d 85 dc f9 ff ff    	lea    -0x624(%ebp),%eax
  80028c:	50                   	push   %eax
  80028d:	e8 35 0c 00 00       	call   800ec7 <snprintf>
  800292:	89 c7                	mov    %eax,%edi
	if (r > 63)
  800294:	83 c4 10             	add    $0x10,%esp
  800297:	83 f8 3f             	cmp    $0x3f,%eax
  80029a:	0f 8f 01 01 00 00    	jg     8003a1 <handle_client+0x2e1>
	if (write(req->sock, buf, r) != r)
  8002a0:	83 ec 04             	sub    $0x4,%esp
  8002a3:	57                   	push   %edi
  8002a4:	8d 85 dc f9 ff ff    	lea    -0x624(%ebp),%eax
  8002aa:	50                   	push   %eax
  8002ab:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ae:	e8 58 16 00 00       	call   80190b <write>
	if ((r = send_size(req, file_size)) < 0)
  8002b3:	83 c4 10             	add    $0x10,%esp
  8002b6:	39 c7                	cmp    %eax,%edi
  8002b8:	0f 85 a2 00 00 00    	jne    800360 <handle_client+0x2a0>
	r = snprintf(buf, 128, "Content-Type: %s\r\n", type);
  8002be:	68 b7 2d 80 00       	push   $0x802db7
  8002c3:	68 c1 2d 80 00       	push   $0x802dc1
  8002c8:	68 80 00 00 00       	push   $0x80
  8002cd:	8d 85 dc f9 ff ff    	lea    -0x624(%ebp),%eax
  8002d3:	50                   	push   %eax
  8002d4:	e8 ee 0b 00 00       	call   800ec7 <snprintf>
  8002d9:	89 c7                	mov    %eax,%edi
	if (r > 127)
  8002db:	83 c4 10             	add    $0x10,%esp
  8002de:	83 f8 7f             	cmp    $0x7f,%eax
  8002e1:	0f 8f ce 00 00 00    	jg     8003b5 <handle_client+0x2f5>
	if (write(req->sock, buf, r) != r)
  8002e7:	83 ec 04             	sub    $0x4,%esp
  8002ea:	50                   	push   %eax
  8002eb:	8d 85 dc f9 ff ff    	lea    -0x624(%ebp),%eax
  8002f1:	50                   	push   %eax
  8002f2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f5:	e8 11 16 00 00       	call   80190b <write>
	if ((r = send_content_type(req)) < 0)
  8002fa:	83 c4 10             	add    $0x10,%esp
  8002fd:	39 c7                	cmp    %eax,%edi
  8002ff:	75 5f                	jne    800360 <handle_client+0x2a0>
	int fin_len = strlen(fin);
  800301:	83 ec 0c             	sub    $0xc,%esp
  800304:	68 e7 2d 80 00       	push   $0x802de7
  800309:	e8 d7 0b 00 00       	call   800ee5 <strlen>
  80030e:	89 c7                	mov    %eax,%edi
	if (write(req->sock, fin, fin_len) != fin_len)
  800310:	83 c4 0c             	add    $0xc,%esp
  800313:	50                   	push   %eax
  800314:	68 e7 2d 80 00       	push   $0x802de7
  800319:	ff 75 dc             	pushl  -0x24(%ebp)
  80031c:	e8 ea 15 00 00       	call   80190b <write>
	if ((r = send_header_fin(req)) < 0)
  800321:	83 c4 10             	add    $0x10,%esp
  800324:	39 c7                	cmp    %eax,%edi
  800326:	75 38                	jne    800360 <handle_client+0x2a0>
		if ((r = read(fd, buf, 1024))<0)
  800328:	83 ec 04             	sub    $0x4,%esp
  80032b:	68 00 04 00 00       	push   $0x400
  800330:	8d 85 dc f9 ff ff    	lea    -0x624(%ebp),%eax
  800336:	50                   	push   %eax
  800337:	53                   	push   %ebx
  800338:	e8 f8 14 00 00       	call   801835 <read>
  80033d:	89 c7                	mov    %eax,%edi
  80033f:	83 c4 10             	add    $0x10,%esp
  800342:	85 c0                	test   %eax,%eax
  800344:	78 1a                	js     800360 <handle_client+0x2a0>
		if (write(req->sock, buf, r)!=r)
  800346:	83 ec 04             	sub    $0x4,%esp
  800349:	50                   	push   %eax
  80034a:	8d 85 dc f9 ff ff    	lea    -0x624(%ebp),%eax
  800350:	50                   	push   %eax
  800351:	ff 75 dc             	pushl  -0x24(%ebp)
  800354:	e8 b2 15 00 00       	call   80190b <write>
  800359:	83 c4 10             	add    $0x10,%esp
  80035c:	39 c7                	cmp    %eax,%edi
  80035e:	74 c8                	je     800328 <handle_client+0x268>
	close(fd);
  800360:	83 ec 0c             	sub    $0xc,%esp
  800363:	53                   	push   %ebx
  800364:	e8 82 13 00 00       	call   8016eb <close>
	return r;
  800369:	83 c4 10             	add    $0x10,%esp
	free(req->url);
  80036c:	83 ec 0c             	sub    $0xc,%esp
  80036f:	ff 75 e0             	pushl  -0x20(%ebp)
  800372:	e8 be 1e 00 00       	call   802235 <free>
	free(req->version);
  800377:	83 c4 04             	add    $0x4,%esp
  80037a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80037d:	e8 b3 1e 00 00       	call   802235 <free>

		// no keep alive
		break;
	}

	close(sock);
  800382:	89 34 24             	mov    %esi,(%esp)
  800385:	e8 61 13 00 00       	call   8016eb <close>
}
  80038a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80038d:	5b                   	pop    %ebx
  80038e:	5e                   	pop    %esi
  80038f:	5f                   	pop    %edi
  800390:	5d                   	pop    %ebp
  800391:	c3                   	ret    
		die("Failed to send bytes to client");
  800392:	b8 9c 2e 80 00       	mov    $0x802e9c,%eax
  800397:	e8 97 fc ff ff       	call   800033 <die>
  80039c:	e9 d8 fe ff ff       	jmp    800279 <handle_client+0x1b9>
		panic("buffer too small!");
  8003a1:	83 ec 04             	sub    $0x4,%esp
  8003a4:	68 a5 2d 80 00       	push   $0x802da5
  8003a9:	6a 62                	push   $0x62
  8003ab:	68 93 2d 80 00       	push   $0x802d93
  8003b0:	e8 82 04 00 00       	call   800837 <_panic>
		panic("buffer too small!");
  8003b5:	83 ec 04             	sub    $0x4,%esp
  8003b8:	68 a5 2d 80 00       	push   $0x802da5
  8003bd:	6a 7e                	push   $0x7e
  8003bf:	68 93 2d 80 00       	push   $0x802d93
  8003c4:	e8 6e 04 00 00       	call   800837 <_panic>
			send_error(req, 400);
  8003c9:	ba 90 01 00 00       	mov    $0x190,%edx
  8003ce:	8d 45 dc             	lea    -0x24(%ebp),%eax
  8003d1:	e8 78 fc ff ff       	call   80004e <send_error>
  8003d6:	eb 94                	jmp    80036c <handle_client+0x2ac>

008003d8 <umain>:

void
umain(int argc, char **argv)
{
  8003d8:	f3 0f 1e fb          	endbr32 
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	57                   	push   %edi
  8003e0:	56                   	push   %esi
  8003e1:	53                   	push   %ebx
  8003e2:	83 ec 40             	sub    $0x40,%esp
	int serversock, clientsock;
	struct sockaddr_in server, client;

	binaryname = "jhttpd";
  8003e5:	c7 05 20 40 80 00 ea 	movl   $0x802dea,0x804020
  8003ec:	2d 80 00 

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  8003ef:	6a 06                	push   $0x6
  8003f1:	6a 01                	push   $0x1
  8003f3:	6a 02                	push   $0x2
  8003f5:	e8 90 1b 00 00       	call   801f8a <socket>
  8003fa:	89 c6                	mov    %eax,%esi
  8003fc:	83 c4 10             	add    $0x10,%esp
  8003ff:	85 c0                	test   %eax,%eax
  800401:	78 6d                	js     800470 <umain+0x98>
		die("Failed to create socket");

	// Construct the server sockaddr_in structure
	memset(&server, 0, sizeof(server));		// Clear struct
  800403:	83 ec 04             	sub    $0x4,%esp
  800406:	6a 10                	push   $0x10
  800408:	6a 00                	push   $0x0
  80040a:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  80040d:	53                   	push   %ebx
  80040e:	e8 c7 0c 00 00       	call   8010da <memset>
	server.sin_family = AF_INET;			// Internet/IP
  800413:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	server.sin_addr.s_addr = htonl(INADDR_ANY);	// IP address
  800417:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80041e:	e8 68 01 00 00       	call   80058b <htonl>
  800423:	89 45 dc             	mov    %eax,-0x24(%ebp)
	server.sin_port = htons(PORT);			// server port
  800426:	c7 04 24 50 00 00 00 	movl   $0x50,(%esp)
  80042d:	e8 37 01 00 00       	call   800569 <htons>
  800432:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &server,
  800436:	83 c4 0c             	add    $0xc,%esp
  800439:	6a 10                	push   $0x10
  80043b:	53                   	push   %ebx
  80043c:	56                   	push   %esi
  80043d:	e8 a6 1a 00 00       	call   801ee8 <bind>
  800442:	83 c4 10             	add    $0x10,%esp
  800445:	85 c0                	test   %eax,%eax
  800447:	78 33                	js     80047c <umain+0xa4>
	{
		die("Failed to bind the server socket");
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	6a 05                	push   $0x5
  80044e:	56                   	push   %esi
  80044f:	e8 0f 1b 00 00       	call   801f63 <listen>
  800454:	83 c4 10             	add    $0x10,%esp
  800457:	85 c0                	test   %eax,%eax
  800459:	78 2d                	js     800488 <umain+0xb0>
		die("Failed to listen on server socket");

	cprintf("Waiting for http connections...\n");
  80045b:	83 ec 0c             	sub    $0xc,%esp
  80045e:	68 04 2f 80 00       	push   $0x802f04
  800463:	e8 b6 04 00 00       	call   80091e <cprintf>
  800468:	83 c4 10             	add    $0x10,%esp

	while (1) {
		unsigned int clientlen = sizeof(client);
		// Wait for client connection
		if ((clientsock = accept(serversock,
  80046b:	8d 7d c4             	lea    -0x3c(%ebp),%edi
  80046e:	eb 35                	jmp    8004a5 <umain+0xcd>
		die("Failed to create socket");
  800470:	b8 f1 2d 80 00       	mov    $0x802df1,%eax
  800475:	e8 b9 fb ff ff       	call   800033 <die>
  80047a:	eb 87                	jmp    800403 <umain+0x2b>
		die("Failed to bind the server socket");
  80047c:	b8 bc 2e 80 00       	mov    $0x802ebc,%eax
  800481:	e8 ad fb ff ff       	call   800033 <die>
  800486:	eb c1                	jmp    800449 <umain+0x71>
		die("Failed to listen on server socket");
  800488:	b8 e0 2e 80 00       	mov    $0x802ee0,%eax
  80048d:	e8 a1 fb ff ff       	call   800033 <die>
  800492:	eb c7                	jmp    80045b <umain+0x83>
					 (struct sockaddr *) &client,
					 &clientlen)) < 0)
		{
			die("Failed to accept client connection");
  800494:	b8 28 2f 80 00       	mov    $0x802f28,%eax
  800499:	e8 95 fb ff ff       	call   800033 <die>
		}
		handle_client(clientsock);
  80049e:	89 d8                	mov    %ebx,%eax
  8004a0:	e8 1b fc ff ff       	call   8000c0 <handle_client>
		unsigned int clientlen = sizeof(client);
  8004a5:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		if ((clientsock = accept(serversock,
  8004ac:	83 ec 04             	sub    $0x4,%esp
  8004af:	57                   	push   %edi
  8004b0:	8d 45 c8             	lea    -0x38(%ebp),%eax
  8004b3:	50                   	push   %eax
  8004b4:	56                   	push   %esi
  8004b5:	e8 fb 19 00 00       	call   801eb5 <accept>
  8004ba:	89 c3                	mov    %eax,%ebx
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	78 d1                	js     800494 <umain+0xbc>
  8004c3:	eb d9                	jmp    80049e <umain+0xc6>

008004c5 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8004c5:	f3 0f 1e fb          	endbr32 
  8004c9:	55                   	push   %ebp
  8004ca:	89 e5                	mov    %esp,%ebp
  8004cc:	57                   	push   %edi
  8004cd:	56                   	push   %esi
  8004ce:	53                   	push   %ebx
  8004cf:	83 ec 18             	sub    $0x18,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8004d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  8004d8:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
  ap = (u8_t *)&s_addr;
  8004dc:	8d 75 f0             	lea    -0x10(%ebp),%esi
  rp = str;
  8004df:	bf 00 50 80 00       	mov    $0x805000,%edi
  8004e4:	eb 2e                	jmp    800514 <inet_ntoa+0x4f>
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
  8004e6:	0f b6 c8             	movzbl %al,%ecx
  8004e9:	0f b6 4c 0d ed       	movzbl -0x13(%ebp,%ecx,1),%ecx
  8004ee:	88 0a                	mov    %cl,(%edx)
  8004f0:	83 c2 01             	add    $0x1,%edx
    while(i--)
  8004f3:	83 e8 01             	sub    $0x1,%eax
  8004f6:	3c ff                	cmp    $0xff,%al
  8004f8:	75 ec                	jne    8004e6 <inet_ntoa+0x21>
  8004fa:	0f b6 db             	movzbl %bl,%ebx
  8004fd:	01 fb                	add    %edi,%ebx
    *rp++ = '.';
  8004ff:	8d 7b 01             	lea    0x1(%ebx),%edi
  800502:	c6 03 2e             	movb   $0x2e,(%ebx)
  800505:	83 c6 01             	add    $0x1,%esi
  for(n = 0; n < 4; n++) {
  800508:	80 45 df 01          	addb   $0x1,-0x21(%ebp)
  80050c:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
  800510:	3c 04                	cmp    $0x4,%al
  800512:	74 45                	je     800559 <inet_ntoa+0x94>
  rp = str;
  800514:	bb 00 00 00 00       	mov    $0x0,%ebx
      rem = *ap % (u8_t)10;
  800519:	0f b6 16             	movzbl (%esi),%edx
      *ap /= (u8_t)10;
  80051c:	0f b6 ca             	movzbl %dl,%ecx
  80051f:	8d 04 89             	lea    (%ecx,%ecx,4),%eax
  800522:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
  800525:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800528:	66 c1 e8 0b          	shr    $0xb,%ax
  80052c:	88 06                	mov    %al,(%esi)
  80052e:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  800530:	83 c3 01             	add    $0x1,%ebx
  800533:	0f b6 c9             	movzbl %cl,%ecx
  800536:	89 4d e0             	mov    %ecx,-0x20(%ebp)
      rem = *ap % (u8_t)10;
  800539:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80053c:	01 c0                	add    %eax,%eax
  80053e:	89 d1                	mov    %edx,%ecx
  800540:	29 c1                	sub    %eax,%ecx
  800542:	89 c8                	mov    %ecx,%eax
      inv[i++] = '0' + rem;
  800544:	83 c0 30             	add    $0x30,%eax
  800547:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80054a:	88 44 0d ed          	mov    %al,-0x13(%ebp,%ecx,1)
    } while(*ap);
  80054e:	80 fa 09             	cmp    $0x9,%dl
  800551:	77 c6                	ja     800519 <inet_ntoa+0x54>
  800553:	89 fa                	mov    %edi,%edx
      inv[i++] = '0' + rem;
  800555:	89 d8                	mov    %ebx,%eax
  800557:	eb 9a                	jmp    8004f3 <inet_ntoa+0x2e>
    ap++;
  }
  *--rp = 0;
  800559:	c6 03 00             	movb   $0x0,(%ebx)
  return str;
}
  80055c:	b8 00 50 80 00       	mov    $0x805000,%eax
  800561:	83 c4 18             	add    $0x18,%esp
  800564:	5b                   	pop    %ebx
  800565:	5e                   	pop    %esi
  800566:	5f                   	pop    %edi
  800567:	5d                   	pop    %ebp
  800568:	c3                   	ret    

00800569 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  800569:	f3 0f 1e fb          	endbr32 
  80056d:	55                   	push   %ebp
  80056e:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800570:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800574:	66 c1 c0 08          	rol    $0x8,%ax
}
  800578:	5d                   	pop    %ebp
  800579:	c3                   	ret    

0080057a <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  80057a:	f3 0f 1e fb          	endbr32 
  80057e:	55                   	push   %ebp
  80057f:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800581:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800585:	66 c1 c0 08          	rol    $0x8,%ax
  return htons(n);
}
  800589:	5d                   	pop    %ebp
  80058a:	c3                   	ret    

0080058b <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  80058b:	f3 0f 1e fb          	endbr32 
  80058f:	55                   	push   %ebp
  800590:	89 e5                	mov    %esp,%ebp
  800592:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  800595:	89 d0                	mov    %edx,%eax
  800597:	c1 e0 18             	shl    $0x18,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
  80059a:	89 d1                	mov    %edx,%ecx
  80059c:	c1 e9 18             	shr    $0x18,%ecx
    ((n & 0xff0000UL) >> 8) |
  80059f:	09 c8                	or     %ecx,%eax
    ((n & 0xff00) << 8) |
  8005a1:	89 d1                	mov    %edx,%ecx
  8005a3:	c1 e1 08             	shl    $0x8,%ecx
  8005a6:	81 e1 00 00 ff 00    	and    $0xff0000,%ecx
    ((n & 0xff0000UL) >> 8) |
  8005ac:	09 c8                	or     %ecx,%eax
  8005ae:	c1 ea 08             	shr    $0x8,%edx
  8005b1:	81 e2 00 ff 00 00    	and    $0xff00,%edx
  8005b7:	09 d0                	or     %edx,%eax
}
  8005b9:	5d                   	pop    %ebp
  8005ba:	c3                   	ret    

008005bb <inet_aton>:
{
  8005bb:	f3 0f 1e fb          	endbr32 
  8005bf:	55                   	push   %ebp
  8005c0:	89 e5                	mov    %esp,%ebp
  8005c2:	57                   	push   %edi
  8005c3:	56                   	push   %esi
  8005c4:	53                   	push   %ebx
  8005c5:	83 ec 2c             	sub    $0x2c,%esp
  8005c8:	8b 55 08             	mov    0x8(%ebp),%edx
  c = *cp;
  8005cb:	0f be 02             	movsbl (%edx),%eax
  u32_t *pp = parts;
  8005ce:	8d 75 d8             	lea    -0x28(%ebp),%esi
  8005d1:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8005d4:	e9 a7 00 00 00       	jmp    800680 <inet_aton+0xc5>
      c = *++cp;
  8005d9:	0f b6 42 01          	movzbl 0x1(%edx),%eax
      if (c == 'x' || c == 'X') {
  8005dd:	89 c1                	mov    %eax,%ecx
  8005df:	83 e1 df             	and    $0xffffffdf,%ecx
  8005e2:	80 f9 58             	cmp    $0x58,%cl
  8005e5:	74 10                	je     8005f7 <inet_aton+0x3c>
      c = *++cp;
  8005e7:	83 c2 01             	add    $0x1,%edx
  8005ea:	0f be c0             	movsbl %al,%eax
        base = 8;
  8005ed:	be 08 00 00 00       	mov    $0x8,%esi
  8005f2:	e9 a3 00 00 00       	jmp    80069a <inet_aton+0xdf>
        c = *++cp;
  8005f7:	0f be 42 02          	movsbl 0x2(%edx),%eax
  8005fb:	8d 52 02             	lea    0x2(%edx),%edx
        base = 16;
  8005fe:	be 10 00 00 00       	mov    $0x10,%esi
  800603:	e9 92 00 00 00       	jmp    80069a <inet_aton+0xdf>
      } else if (base == 16 && isxdigit(c)) {
  800608:	83 fe 10             	cmp    $0x10,%esi
  80060b:	75 4d                	jne    80065a <inet_aton+0x9f>
  80060d:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  800610:	88 4d d3             	mov    %cl,-0x2d(%ebp)
  800613:	89 c1                	mov    %eax,%ecx
  800615:	83 e1 df             	and    $0xffffffdf,%ecx
  800618:	83 e9 41             	sub    $0x41,%ecx
  80061b:	80 f9 05             	cmp    $0x5,%cl
  80061e:	77 3a                	ja     80065a <inet_aton+0x9f>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800620:	c1 e3 04             	shl    $0x4,%ebx
  800623:	83 c0 0a             	add    $0xa,%eax
  800626:	80 7d d3 1a          	cmpb   $0x1a,-0x2d(%ebp)
  80062a:	19 c9                	sbb    %ecx,%ecx
  80062c:	83 e1 20             	and    $0x20,%ecx
  80062f:	83 c1 41             	add    $0x41,%ecx
  800632:	29 c8                	sub    %ecx,%eax
  800634:	09 c3                	or     %eax,%ebx
        c = *++cp;
  800636:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800639:	0f be 40 01          	movsbl 0x1(%eax),%eax
  80063d:	83 c2 01             	add    $0x1,%edx
  800640:	89 55 d4             	mov    %edx,-0x2c(%ebp)
      if (isdigit(c)) {
  800643:	89 c7                	mov    %eax,%edi
  800645:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800648:	80 f9 09             	cmp    $0x9,%cl
  80064b:	77 bb                	ja     800608 <inet_aton+0x4d>
        val = (val * base) + (int)(c - '0');
  80064d:	0f af de             	imul   %esi,%ebx
  800650:	8d 5c 18 d0          	lea    -0x30(%eax,%ebx,1),%ebx
        c = *++cp;
  800654:	0f be 42 01          	movsbl 0x1(%edx),%eax
  800658:	eb e3                	jmp    80063d <inet_aton+0x82>
    if (c == '.') {
  80065a:	83 f8 2e             	cmp    $0x2e,%eax
  80065d:	75 42                	jne    8006a1 <inet_aton+0xe6>
      if (pp >= parts + 3)
  80065f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800662:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800665:	39 c6                	cmp    %eax,%esi
  800667:	0f 84 16 01 00 00    	je     800783 <inet_aton+0x1c8>
      *pp++ = val;
  80066d:	83 c6 04             	add    $0x4,%esi
  800670:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800673:	89 5e fc             	mov    %ebx,-0x4(%esi)
      c = *++cp;
  800676:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800679:	8d 50 01             	lea    0x1(%eax),%edx
  80067c:	0f be 40 01          	movsbl 0x1(%eax),%eax
    if (!isdigit(c))
  800680:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800683:	80 f9 09             	cmp    $0x9,%cl
  800686:	0f 87 f0 00 00 00    	ja     80077c <inet_aton+0x1c1>
    base = 10;
  80068c:	be 0a 00 00 00       	mov    $0xa,%esi
    if (c == '0') {
  800691:	83 f8 30             	cmp    $0x30,%eax
  800694:	0f 84 3f ff ff ff    	je     8005d9 <inet_aton+0x1e>
    base = 10;
  80069a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80069f:	eb 9f                	jmp    800640 <inet_aton+0x85>
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	74 29                	je     8006ce <inet_aton+0x113>
    return (0);
  8006a5:	ba 00 00 00 00       	mov    $0x0,%edx
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8006aa:	89 f9                	mov    %edi,%ecx
  8006ac:	80 f9 1f             	cmp    $0x1f,%cl
  8006af:	0f 86 d3 00 00 00    	jbe    800788 <inet_aton+0x1cd>
  8006b5:	84 c0                	test   %al,%al
  8006b7:	0f 88 cb 00 00 00    	js     800788 <inet_aton+0x1cd>
  8006bd:	83 f8 20             	cmp    $0x20,%eax
  8006c0:	74 0c                	je     8006ce <inet_aton+0x113>
  8006c2:	83 e8 09             	sub    $0x9,%eax
  8006c5:	83 f8 04             	cmp    $0x4,%eax
  8006c8:	0f 87 ba 00 00 00    	ja     800788 <inet_aton+0x1cd>
  n = pp - parts + 1;
  8006ce:	8d 45 d8             	lea    -0x28(%ebp),%eax
  8006d1:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8006d4:	29 c6                	sub    %eax,%esi
  8006d6:	89 f0                	mov    %esi,%eax
  8006d8:	c1 f8 02             	sar    $0x2,%eax
  8006db:	8d 50 01             	lea    0x1(%eax),%edx
  switch (n) {
  8006de:	83 f8 02             	cmp    $0x2,%eax
  8006e1:	74 7a                	je     80075d <inet_aton+0x1a2>
  8006e3:	83 fa 03             	cmp    $0x3,%edx
  8006e6:	7f 49                	jg     800731 <inet_aton+0x176>
  8006e8:	85 d2                	test   %edx,%edx
  8006ea:	0f 84 98 00 00 00    	je     800788 <inet_aton+0x1cd>
  8006f0:	83 fa 02             	cmp    $0x2,%edx
  8006f3:	75 19                	jne    80070e <inet_aton+0x153>
      return (0);
  8006f5:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xffffffUL)
  8006fa:	81 fb ff ff ff 00    	cmp    $0xffffff,%ebx
  800700:	0f 87 82 00 00 00    	ja     800788 <inet_aton+0x1cd>
    val |= parts[0] << 24;
  800706:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800709:	c1 e0 18             	shl    $0x18,%eax
  80070c:	09 c3                	or     %eax,%ebx
  return (1);
  80070e:	ba 01 00 00 00       	mov    $0x1,%edx
  if (addr)
  800713:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800717:	74 6f                	je     800788 <inet_aton+0x1cd>
    addr->s_addr = htonl(val);
  800719:	83 ec 0c             	sub    $0xc,%esp
  80071c:	53                   	push   %ebx
  80071d:	e8 69 fe ff ff       	call   80058b <htonl>
  800722:	83 c4 10             	add    $0x10,%esp
  800725:	8b 75 0c             	mov    0xc(%ebp),%esi
  800728:	89 06                	mov    %eax,(%esi)
  return (1);
  80072a:	ba 01 00 00 00       	mov    $0x1,%edx
  80072f:	eb 57                	jmp    800788 <inet_aton+0x1cd>
  switch (n) {
  800731:	83 fa 04             	cmp    $0x4,%edx
  800734:	75 d8                	jne    80070e <inet_aton+0x153>
      return (0);
  800736:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xff)
  80073b:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
  800741:	77 45                	ja     800788 <inet_aton+0x1cd>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  800743:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800746:	c1 e0 18             	shl    $0x18,%eax
  800749:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80074c:	c1 e2 10             	shl    $0x10,%edx
  80074f:	09 d0                	or     %edx,%eax
  800751:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800754:	c1 e2 08             	shl    $0x8,%edx
  800757:	09 d0                	or     %edx,%eax
  800759:	09 c3                	or     %eax,%ebx
    break;
  80075b:	eb b1                	jmp    80070e <inet_aton+0x153>
      return (0);
  80075d:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xffff)
  800762:	81 fb ff ff 00 00    	cmp    $0xffff,%ebx
  800768:	77 1e                	ja     800788 <inet_aton+0x1cd>
    val |= (parts[0] << 24) | (parts[1] << 16);
  80076a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80076d:	c1 e0 18             	shl    $0x18,%eax
  800770:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800773:	c1 e2 10             	shl    $0x10,%edx
  800776:	09 d0                	or     %edx,%eax
  800778:	09 c3                	or     %eax,%ebx
    break;
  80077a:	eb 92                	jmp    80070e <inet_aton+0x153>
      return (0);
  80077c:	ba 00 00 00 00       	mov    $0x0,%edx
  800781:	eb 05                	jmp    800788 <inet_aton+0x1cd>
        return (0);
  800783:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800788:	89 d0                	mov    %edx,%eax
  80078a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078d:	5b                   	pop    %ebx
  80078e:	5e                   	pop    %esi
  80078f:	5f                   	pop    %edi
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <inet_addr>:
{
  800792:	f3 0f 1e fb          	endbr32 
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	83 ec 20             	sub    $0x20,%esp
  if (inet_aton(cp, &val)) {
  80079c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80079f:	50                   	push   %eax
  8007a0:	ff 75 08             	pushl  0x8(%ebp)
  8007a3:	e8 13 fe ff ff       	call   8005bb <inet_aton>
  8007a8:	83 c4 10             	add    $0x10,%esp
    return (val.s_addr);
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8007b2:	0f 45 45 f4          	cmovne -0xc(%ebp),%eax
}
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    

008007b8 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  8007b8:	f3 0f 1e fb          	endbr32 
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	83 ec 14             	sub    $0x14,%esp
  return htonl(n);
  8007c2:	ff 75 08             	pushl  0x8(%ebp)
  8007c5:	e8 c1 fd ff ff       	call   80058b <htonl>
  8007ca:	83 c4 10             	add    $0x10,%esp
}
  8007cd:	c9                   	leave  
  8007ce:	c3                   	ret    

008007cf <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8007cf:	f3 0f 1e fb          	endbr32 
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	56                   	push   %esi
  8007d7:	53                   	push   %ebx
  8007d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007db:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8007de:	e8 68 0b 00 00       	call   80134b <sys_getenvid>
  8007e3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8007e8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8007eb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8007f0:	a3 1c 50 80 00       	mov    %eax,0x80501c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8007f5:	85 db                	test   %ebx,%ebx
  8007f7:	7e 07                	jle    800800 <libmain+0x31>
		binaryname = argv[0];
  8007f9:	8b 06                	mov    (%esi),%eax
  8007fb:	a3 20 40 80 00       	mov    %eax,0x804020

	// call user main routine
	umain(argc, argv);
  800800:	83 ec 08             	sub    $0x8,%esp
  800803:	56                   	push   %esi
  800804:	53                   	push   %ebx
  800805:	e8 ce fb ff ff       	call   8003d8 <umain>

	// exit gracefully
	exit();
  80080a:	e8 0a 00 00 00       	call   800819 <exit>
}
  80080f:	83 c4 10             	add    $0x10,%esp
  800812:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800815:	5b                   	pop    %ebx
  800816:	5e                   	pop    %esi
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800819:	f3 0f 1e fb          	endbr32 
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  800823:	e8 f4 0e 00 00       	call   80171c <close_all>
	sys_env_destroy(0);
  800828:	83 ec 0c             	sub    $0xc,%esp
  80082b:	6a 00                	push   $0x0
  80082d:	e8 f5 0a 00 00       	call   801327 <sys_env_destroy>
}
  800832:	83 c4 10             	add    $0x10,%esp
  800835:	c9                   	leave  
  800836:	c3                   	ret    

00800837 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800837:	f3 0f 1e fb          	endbr32 
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	56                   	push   %esi
  80083f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800840:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800843:	8b 35 20 40 80 00    	mov    0x804020,%esi
  800849:	e8 fd 0a 00 00       	call   80134b <sys_getenvid>
  80084e:	83 ec 0c             	sub    $0xc,%esp
  800851:	ff 75 0c             	pushl  0xc(%ebp)
  800854:	ff 75 08             	pushl  0x8(%ebp)
  800857:	56                   	push   %esi
  800858:	50                   	push   %eax
  800859:	68 7c 2f 80 00       	push   $0x802f7c
  80085e:	e8 bb 00 00 00       	call   80091e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800863:	83 c4 18             	add    $0x18,%esp
  800866:	53                   	push   %ebx
  800867:	ff 75 10             	pushl  0x10(%ebp)
  80086a:	e8 5a 00 00 00       	call   8008c9 <vcprintf>
	cprintf("\n");
  80086f:	c7 04 24 e8 2d 80 00 	movl   $0x802de8,(%esp)
  800876:	e8 a3 00 00 00       	call   80091e <cprintf>
  80087b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80087e:	cc                   	int3   
  80087f:	eb fd                	jmp    80087e <_panic+0x47>

00800881 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800881:	f3 0f 1e fb          	endbr32 
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	53                   	push   %ebx
  800889:	83 ec 04             	sub    $0x4,%esp
  80088c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80088f:	8b 13                	mov    (%ebx),%edx
  800891:	8d 42 01             	lea    0x1(%edx),%eax
  800894:	89 03                	mov    %eax,(%ebx)
  800896:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800899:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80089d:	3d ff 00 00 00       	cmp    $0xff,%eax
  8008a2:	74 09                	je     8008ad <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8008a4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8008a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ab:	c9                   	leave  
  8008ac:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8008ad:	83 ec 08             	sub    $0x8,%esp
  8008b0:	68 ff 00 00 00       	push   $0xff
  8008b5:	8d 43 08             	lea    0x8(%ebx),%eax
  8008b8:	50                   	push   %eax
  8008b9:	e8 24 0a 00 00       	call   8012e2 <sys_cputs>
		b->idx = 0;
  8008be:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8008c4:	83 c4 10             	add    $0x10,%esp
  8008c7:	eb db                	jmp    8008a4 <putch+0x23>

008008c9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8008c9:	f3 0f 1e fb          	endbr32 
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8008d6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8008dd:	00 00 00 
	b.cnt = 0;
  8008e0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8008e7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8008ea:	ff 75 0c             	pushl  0xc(%ebp)
  8008ed:	ff 75 08             	pushl  0x8(%ebp)
  8008f0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8008f6:	50                   	push   %eax
  8008f7:	68 81 08 80 00       	push   $0x800881
  8008fc:	e8 20 01 00 00       	call   800a21 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800901:	83 c4 08             	add    $0x8,%esp
  800904:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80090a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800910:	50                   	push   %eax
  800911:	e8 cc 09 00 00       	call   8012e2 <sys_cputs>

	return b.cnt;
}
  800916:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80091c:	c9                   	leave  
  80091d:	c3                   	ret    

0080091e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80091e:	f3 0f 1e fb          	endbr32 
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800928:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80092b:	50                   	push   %eax
  80092c:	ff 75 08             	pushl  0x8(%ebp)
  80092f:	e8 95 ff ff ff       	call   8008c9 <vcprintf>
	va_end(ap);

	return cnt;
}
  800934:	c9                   	leave  
  800935:	c3                   	ret    

00800936 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	57                   	push   %edi
  80093a:	56                   	push   %esi
  80093b:	53                   	push   %ebx
  80093c:	83 ec 1c             	sub    $0x1c,%esp
  80093f:	89 c7                	mov    %eax,%edi
  800941:	89 d6                	mov    %edx,%esi
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	8b 55 0c             	mov    0xc(%ebp),%edx
  800949:	89 d1                	mov    %edx,%ecx
  80094b:	89 c2                	mov    %eax,%edx
  80094d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800950:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800953:	8b 45 10             	mov    0x10(%ebp),%eax
  800956:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800959:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80095c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800963:	39 c2                	cmp    %eax,%edx
  800965:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800968:	72 3e                	jb     8009a8 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80096a:	83 ec 0c             	sub    $0xc,%esp
  80096d:	ff 75 18             	pushl  0x18(%ebp)
  800970:	83 eb 01             	sub    $0x1,%ebx
  800973:	53                   	push   %ebx
  800974:	50                   	push   %eax
  800975:	83 ec 08             	sub    $0x8,%esp
  800978:	ff 75 e4             	pushl  -0x1c(%ebp)
  80097b:	ff 75 e0             	pushl  -0x20(%ebp)
  80097e:	ff 75 dc             	pushl  -0x24(%ebp)
  800981:	ff 75 d8             	pushl  -0x28(%ebp)
  800984:	e8 97 21 00 00       	call   802b20 <__udivdi3>
  800989:	83 c4 18             	add    $0x18,%esp
  80098c:	52                   	push   %edx
  80098d:	50                   	push   %eax
  80098e:	89 f2                	mov    %esi,%edx
  800990:	89 f8                	mov    %edi,%eax
  800992:	e8 9f ff ff ff       	call   800936 <printnum>
  800997:	83 c4 20             	add    $0x20,%esp
  80099a:	eb 13                	jmp    8009af <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80099c:	83 ec 08             	sub    $0x8,%esp
  80099f:	56                   	push   %esi
  8009a0:	ff 75 18             	pushl  0x18(%ebp)
  8009a3:	ff d7                	call   *%edi
  8009a5:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8009a8:	83 eb 01             	sub    $0x1,%ebx
  8009ab:	85 db                	test   %ebx,%ebx
  8009ad:	7f ed                	jg     80099c <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8009af:	83 ec 08             	sub    $0x8,%esp
  8009b2:	56                   	push   %esi
  8009b3:	83 ec 04             	sub    $0x4,%esp
  8009b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8009b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8009bc:	ff 75 dc             	pushl  -0x24(%ebp)
  8009bf:	ff 75 d8             	pushl  -0x28(%ebp)
  8009c2:	e8 69 22 00 00       	call   802c30 <__umoddi3>
  8009c7:	83 c4 14             	add    $0x14,%esp
  8009ca:	0f be 80 9f 2f 80 00 	movsbl 0x802f9f(%eax),%eax
  8009d1:	50                   	push   %eax
  8009d2:	ff d7                	call   *%edi
}
  8009d4:	83 c4 10             	add    $0x10,%esp
  8009d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009da:	5b                   	pop    %ebx
  8009db:	5e                   	pop    %esi
  8009dc:	5f                   	pop    %edi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8009df:	f3 0f 1e fb          	endbr32 
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8009e9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8009ed:	8b 10                	mov    (%eax),%edx
  8009ef:	3b 50 04             	cmp    0x4(%eax),%edx
  8009f2:	73 0a                	jae    8009fe <sprintputch+0x1f>
		*b->buf++ = ch;
  8009f4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009f7:	89 08                	mov    %ecx,(%eax)
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	88 02                	mov    %al,(%edx)
}
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <printfmt>:
{
  800a00:	f3 0f 1e fb          	endbr32 
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800a0a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800a0d:	50                   	push   %eax
  800a0e:	ff 75 10             	pushl  0x10(%ebp)
  800a11:	ff 75 0c             	pushl  0xc(%ebp)
  800a14:	ff 75 08             	pushl  0x8(%ebp)
  800a17:	e8 05 00 00 00       	call   800a21 <vprintfmt>
}
  800a1c:	83 c4 10             	add    $0x10,%esp
  800a1f:	c9                   	leave  
  800a20:	c3                   	ret    

00800a21 <vprintfmt>:
{
  800a21:	f3 0f 1e fb          	endbr32 
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	57                   	push   %edi
  800a29:	56                   	push   %esi
  800a2a:	53                   	push   %ebx
  800a2b:	83 ec 3c             	sub    $0x3c,%esp
  800a2e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a31:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a34:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a37:	e9 8e 03 00 00       	jmp    800dca <vprintfmt+0x3a9>
		padc = ' ';
  800a3c:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800a40:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800a47:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800a4e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800a55:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800a5a:	8d 47 01             	lea    0x1(%edi),%eax
  800a5d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a60:	0f b6 17             	movzbl (%edi),%edx
  800a63:	8d 42 dd             	lea    -0x23(%edx),%eax
  800a66:	3c 55                	cmp    $0x55,%al
  800a68:	0f 87 df 03 00 00    	ja     800e4d <vprintfmt+0x42c>
  800a6e:	0f b6 c0             	movzbl %al,%eax
  800a71:	3e ff 24 85 e0 30 80 	notrack jmp *0x8030e0(,%eax,4)
  800a78:	00 
  800a79:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800a7c:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800a80:	eb d8                	jmp    800a5a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800a82:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a85:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800a89:	eb cf                	jmp    800a5a <vprintfmt+0x39>
  800a8b:	0f b6 d2             	movzbl %dl,%edx
  800a8e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800a91:	b8 00 00 00 00       	mov    $0x0,%eax
  800a96:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800a99:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800a9c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800aa0:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800aa3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800aa6:	83 f9 09             	cmp    $0x9,%ecx
  800aa9:	77 55                	ja     800b00 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800aab:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800aae:	eb e9                	jmp    800a99 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800ab0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab3:	8b 00                	mov    (%eax),%eax
  800ab5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ab8:	8b 45 14             	mov    0x14(%ebp),%eax
  800abb:	8d 40 04             	lea    0x4(%eax),%eax
  800abe:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800ac1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800ac4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ac8:	79 90                	jns    800a5a <vprintfmt+0x39>
				width = precision, precision = -1;
  800aca:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800acd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ad0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800ad7:	eb 81                	jmp    800a5a <vprintfmt+0x39>
  800ad9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800adc:	85 c0                	test   %eax,%eax
  800ade:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae3:	0f 49 d0             	cmovns %eax,%edx
  800ae6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800ae9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800aec:	e9 69 ff ff ff       	jmp    800a5a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800af1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800af4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800afb:	e9 5a ff ff ff       	jmp    800a5a <vprintfmt+0x39>
  800b00:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800b03:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b06:	eb bc                	jmp    800ac4 <vprintfmt+0xa3>
			lflag++;
  800b08:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800b0b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800b0e:	e9 47 ff ff ff       	jmp    800a5a <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800b13:	8b 45 14             	mov    0x14(%ebp),%eax
  800b16:	8d 78 04             	lea    0x4(%eax),%edi
  800b19:	83 ec 08             	sub    $0x8,%esp
  800b1c:	53                   	push   %ebx
  800b1d:	ff 30                	pushl  (%eax)
  800b1f:	ff d6                	call   *%esi
			break;
  800b21:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800b24:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800b27:	e9 9b 02 00 00       	jmp    800dc7 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800b2c:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2f:	8d 78 04             	lea    0x4(%eax),%edi
  800b32:	8b 00                	mov    (%eax),%eax
  800b34:	99                   	cltd   
  800b35:	31 d0                	xor    %edx,%eax
  800b37:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800b39:	83 f8 0f             	cmp    $0xf,%eax
  800b3c:	7f 23                	jg     800b61 <vprintfmt+0x140>
  800b3e:	8b 14 85 40 32 80 00 	mov    0x803240(,%eax,4),%edx
  800b45:	85 d2                	test   %edx,%edx
  800b47:	74 18                	je     800b61 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800b49:	52                   	push   %edx
  800b4a:	68 49 33 80 00       	push   $0x803349
  800b4f:	53                   	push   %ebx
  800b50:	56                   	push   %esi
  800b51:	e8 aa fe ff ff       	call   800a00 <printfmt>
  800b56:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800b59:	89 7d 14             	mov    %edi,0x14(%ebp)
  800b5c:	e9 66 02 00 00       	jmp    800dc7 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800b61:	50                   	push   %eax
  800b62:	68 b7 2f 80 00       	push   $0x802fb7
  800b67:	53                   	push   %ebx
  800b68:	56                   	push   %esi
  800b69:	e8 92 fe ff ff       	call   800a00 <printfmt>
  800b6e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800b71:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800b74:	e9 4e 02 00 00       	jmp    800dc7 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800b79:	8b 45 14             	mov    0x14(%ebp),%eax
  800b7c:	83 c0 04             	add    $0x4,%eax
  800b7f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800b82:	8b 45 14             	mov    0x14(%ebp),%eax
  800b85:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800b87:	85 d2                	test   %edx,%edx
  800b89:	b8 b0 2f 80 00       	mov    $0x802fb0,%eax
  800b8e:	0f 45 c2             	cmovne %edx,%eax
  800b91:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800b94:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b98:	7e 06                	jle    800ba0 <vprintfmt+0x17f>
  800b9a:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800b9e:	75 0d                	jne    800bad <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800ba0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ba3:	89 c7                	mov    %eax,%edi
  800ba5:	03 45 e0             	add    -0x20(%ebp),%eax
  800ba8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bab:	eb 55                	jmp    800c02 <vprintfmt+0x1e1>
  800bad:	83 ec 08             	sub    $0x8,%esp
  800bb0:	ff 75 d8             	pushl  -0x28(%ebp)
  800bb3:	ff 75 cc             	pushl  -0x34(%ebp)
  800bb6:	e8 46 03 00 00       	call   800f01 <strnlen>
  800bbb:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800bbe:	29 c2                	sub    %eax,%edx
  800bc0:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800bc3:	83 c4 10             	add    $0x10,%esp
  800bc6:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800bc8:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800bcc:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800bcf:	85 ff                	test   %edi,%edi
  800bd1:	7e 11                	jle    800be4 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800bd3:	83 ec 08             	sub    $0x8,%esp
  800bd6:	53                   	push   %ebx
  800bd7:	ff 75 e0             	pushl  -0x20(%ebp)
  800bda:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800bdc:	83 ef 01             	sub    $0x1,%edi
  800bdf:	83 c4 10             	add    $0x10,%esp
  800be2:	eb eb                	jmp    800bcf <vprintfmt+0x1ae>
  800be4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800be7:	85 d2                	test   %edx,%edx
  800be9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bee:	0f 49 c2             	cmovns %edx,%eax
  800bf1:	29 c2                	sub    %eax,%edx
  800bf3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800bf6:	eb a8                	jmp    800ba0 <vprintfmt+0x17f>
					putch(ch, putdat);
  800bf8:	83 ec 08             	sub    $0x8,%esp
  800bfb:	53                   	push   %ebx
  800bfc:	52                   	push   %edx
  800bfd:	ff d6                	call   *%esi
  800bff:	83 c4 10             	add    $0x10,%esp
  800c02:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800c05:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c07:	83 c7 01             	add    $0x1,%edi
  800c0a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c0e:	0f be d0             	movsbl %al,%edx
  800c11:	85 d2                	test   %edx,%edx
  800c13:	74 4b                	je     800c60 <vprintfmt+0x23f>
  800c15:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800c19:	78 06                	js     800c21 <vprintfmt+0x200>
  800c1b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800c1f:	78 1e                	js     800c3f <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  800c21:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800c25:	74 d1                	je     800bf8 <vprintfmt+0x1d7>
  800c27:	0f be c0             	movsbl %al,%eax
  800c2a:	83 e8 20             	sub    $0x20,%eax
  800c2d:	83 f8 5e             	cmp    $0x5e,%eax
  800c30:	76 c6                	jbe    800bf8 <vprintfmt+0x1d7>
					putch('?', putdat);
  800c32:	83 ec 08             	sub    $0x8,%esp
  800c35:	53                   	push   %ebx
  800c36:	6a 3f                	push   $0x3f
  800c38:	ff d6                	call   *%esi
  800c3a:	83 c4 10             	add    $0x10,%esp
  800c3d:	eb c3                	jmp    800c02 <vprintfmt+0x1e1>
  800c3f:	89 cf                	mov    %ecx,%edi
  800c41:	eb 0e                	jmp    800c51 <vprintfmt+0x230>
				putch(' ', putdat);
  800c43:	83 ec 08             	sub    $0x8,%esp
  800c46:	53                   	push   %ebx
  800c47:	6a 20                	push   $0x20
  800c49:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800c4b:	83 ef 01             	sub    $0x1,%edi
  800c4e:	83 c4 10             	add    $0x10,%esp
  800c51:	85 ff                	test   %edi,%edi
  800c53:	7f ee                	jg     800c43 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800c55:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800c58:	89 45 14             	mov    %eax,0x14(%ebp)
  800c5b:	e9 67 01 00 00       	jmp    800dc7 <vprintfmt+0x3a6>
  800c60:	89 cf                	mov    %ecx,%edi
  800c62:	eb ed                	jmp    800c51 <vprintfmt+0x230>
	if (lflag >= 2)
  800c64:	83 f9 01             	cmp    $0x1,%ecx
  800c67:	7f 1b                	jg     800c84 <vprintfmt+0x263>
	else if (lflag)
  800c69:	85 c9                	test   %ecx,%ecx
  800c6b:	74 63                	je     800cd0 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800c6d:	8b 45 14             	mov    0x14(%ebp),%eax
  800c70:	8b 00                	mov    (%eax),%eax
  800c72:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c75:	99                   	cltd   
  800c76:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800c79:	8b 45 14             	mov    0x14(%ebp),%eax
  800c7c:	8d 40 04             	lea    0x4(%eax),%eax
  800c7f:	89 45 14             	mov    %eax,0x14(%ebp)
  800c82:	eb 17                	jmp    800c9b <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800c84:	8b 45 14             	mov    0x14(%ebp),%eax
  800c87:	8b 50 04             	mov    0x4(%eax),%edx
  800c8a:	8b 00                	mov    (%eax),%eax
  800c8c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c8f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800c92:	8b 45 14             	mov    0x14(%ebp),%eax
  800c95:	8d 40 08             	lea    0x8(%eax),%eax
  800c98:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800c9b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800c9e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800ca1:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800ca6:	85 c9                	test   %ecx,%ecx
  800ca8:	0f 89 ff 00 00 00    	jns    800dad <vprintfmt+0x38c>
				putch('-', putdat);
  800cae:	83 ec 08             	sub    $0x8,%esp
  800cb1:	53                   	push   %ebx
  800cb2:	6a 2d                	push   $0x2d
  800cb4:	ff d6                	call   *%esi
				num = -(long long) num;
  800cb6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800cb9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800cbc:	f7 da                	neg    %edx
  800cbe:	83 d1 00             	adc    $0x0,%ecx
  800cc1:	f7 d9                	neg    %ecx
  800cc3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800cc6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ccb:	e9 dd 00 00 00       	jmp    800dad <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800cd0:	8b 45 14             	mov    0x14(%ebp),%eax
  800cd3:	8b 00                	mov    (%eax),%eax
  800cd5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800cd8:	99                   	cltd   
  800cd9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800cdc:	8b 45 14             	mov    0x14(%ebp),%eax
  800cdf:	8d 40 04             	lea    0x4(%eax),%eax
  800ce2:	89 45 14             	mov    %eax,0x14(%ebp)
  800ce5:	eb b4                	jmp    800c9b <vprintfmt+0x27a>
	if (lflag >= 2)
  800ce7:	83 f9 01             	cmp    $0x1,%ecx
  800cea:	7f 1e                	jg     800d0a <vprintfmt+0x2e9>
	else if (lflag)
  800cec:	85 c9                	test   %ecx,%ecx
  800cee:	74 32                	je     800d22 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800cf0:	8b 45 14             	mov    0x14(%ebp),%eax
  800cf3:	8b 10                	mov    (%eax),%edx
  800cf5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfa:	8d 40 04             	lea    0x4(%eax),%eax
  800cfd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800d00:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800d05:	e9 a3 00 00 00       	jmp    800dad <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800d0a:	8b 45 14             	mov    0x14(%ebp),%eax
  800d0d:	8b 10                	mov    (%eax),%edx
  800d0f:	8b 48 04             	mov    0x4(%eax),%ecx
  800d12:	8d 40 08             	lea    0x8(%eax),%eax
  800d15:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800d18:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800d1d:	e9 8b 00 00 00       	jmp    800dad <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800d22:	8b 45 14             	mov    0x14(%ebp),%eax
  800d25:	8b 10                	mov    (%eax),%edx
  800d27:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d2c:	8d 40 04             	lea    0x4(%eax),%eax
  800d2f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800d32:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800d37:	eb 74                	jmp    800dad <vprintfmt+0x38c>
	if (lflag >= 2)
  800d39:	83 f9 01             	cmp    $0x1,%ecx
  800d3c:	7f 1b                	jg     800d59 <vprintfmt+0x338>
	else if (lflag)
  800d3e:	85 c9                	test   %ecx,%ecx
  800d40:	74 2c                	je     800d6e <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800d42:	8b 45 14             	mov    0x14(%ebp),%eax
  800d45:	8b 10                	mov    (%eax),%edx
  800d47:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4c:	8d 40 04             	lea    0x4(%eax),%eax
  800d4f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800d52:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800d57:	eb 54                	jmp    800dad <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800d59:	8b 45 14             	mov    0x14(%ebp),%eax
  800d5c:	8b 10                	mov    (%eax),%edx
  800d5e:	8b 48 04             	mov    0x4(%eax),%ecx
  800d61:	8d 40 08             	lea    0x8(%eax),%eax
  800d64:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800d67:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800d6c:	eb 3f                	jmp    800dad <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800d6e:	8b 45 14             	mov    0x14(%ebp),%eax
  800d71:	8b 10                	mov    (%eax),%edx
  800d73:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d78:	8d 40 04             	lea    0x4(%eax),%eax
  800d7b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800d7e:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800d83:	eb 28                	jmp    800dad <vprintfmt+0x38c>
			putch('0', putdat);
  800d85:	83 ec 08             	sub    $0x8,%esp
  800d88:	53                   	push   %ebx
  800d89:	6a 30                	push   $0x30
  800d8b:	ff d6                	call   *%esi
			putch('x', putdat);
  800d8d:	83 c4 08             	add    $0x8,%esp
  800d90:	53                   	push   %ebx
  800d91:	6a 78                	push   $0x78
  800d93:	ff d6                	call   *%esi
			num = (unsigned long long)
  800d95:	8b 45 14             	mov    0x14(%ebp),%eax
  800d98:	8b 10                	mov    (%eax),%edx
  800d9a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800d9f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800da2:	8d 40 04             	lea    0x4(%eax),%eax
  800da5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800da8:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800dad:	83 ec 0c             	sub    $0xc,%esp
  800db0:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800db4:	57                   	push   %edi
  800db5:	ff 75 e0             	pushl  -0x20(%ebp)
  800db8:	50                   	push   %eax
  800db9:	51                   	push   %ecx
  800dba:	52                   	push   %edx
  800dbb:	89 da                	mov    %ebx,%edx
  800dbd:	89 f0                	mov    %esi,%eax
  800dbf:	e8 72 fb ff ff       	call   800936 <printnum>
			break;
  800dc4:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800dc7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  800dca:	83 c7 01             	add    $0x1,%edi
  800dcd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800dd1:	83 f8 25             	cmp    $0x25,%eax
  800dd4:	0f 84 62 fc ff ff    	je     800a3c <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	0f 84 8b 00 00 00    	je     800e6d <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  800de2:	83 ec 08             	sub    $0x8,%esp
  800de5:	53                   	push   %ebx
  800de6:	50                   	push   %eax
  800de7:	ff d6                	call   *%esi
  800de9:	83 c4 10             	add    $0x10,%esp
  800dec:	eb dc                	jmp    800dca <vprintfmt+0x3a9>
	if (lflag >= 2)
  800dee:	83 f9 01             	cmp    $0x1,%ecx
  800df1:	7f 1b                	jg     800e0e <vprintfmt+0x3ed>
	else if (lflag)
  800df3:	85 c9                	test   %ecx,%ecx
  800df5:	74 2c                	je     800e23 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800df7:	8b 45 14             	mov    0x14(%ebp),%eax
  800dfa:	8b 10                	mov    (%eax),%edx
  800dfc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e01:	8d 40 04             	lea    0x4(%eax),%eax
  800e04:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800e07:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800e0c:	eb 9f                	jmp    800dad <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800e0e:	8b 45 14             	mov    0x14(%ebp),%eax
  800e11:	8b 10                	mov    (%eax),%edx
  800e13:	8b 48 04             	mov    0x4(%eax),%ecx
  800e16:	8d 40 08             	lea    0x8(%eax),%eax
  800e19:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800e1c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800e21:	eb 8a                	jmp    800dad <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800e23:	8b 45 14             	mov    0x14(%ebp),%eax
  800e26:	8b 10                	mov    (%eax),%edx
  800e28:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e2d:	8d 40 04             	lea    0x4(%eax),%eax
  800e30:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800e33:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800e38:	e9 70 ff ff ff       	jmp    800dad <vprintfmt+0x38c>
			putch(ch, putdat);
  800e3d:	83 ec 08             	sub    $0x8,%esp
  800e40:	53                   	push   %ebx
  800e41:	6a 25                	push   $0x25
  800e43:	ff d6                	call   *%esi
			break;
  800e45:	83 c4 10             	add    $0x10,%esp
  800e48:	e9 7a ff ff ff       	jmp    800dc7 <vprintfmt+0x3a6>
			putch('%', putdat);
  800e4d:	83 ec 08             	sub    $0x8,%esp
  800e50:	53                   	push   %ebx
  800e51:	6a 25                	push   $0x25
  800e53:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800e55:	83 c4 10             	add    $0x10,%esp
  800e58:	89 f8                	mov    %edi,%eax
  800e5a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800e5e:	74 05                	je     800e65 <vprintfmt+0x444>
  800e60:	83 e8 01             	sub    $0x1,%eax
  800e63:	eb f5                	jmp    800e5a <vprintfmt+0x439>
  800e65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e68:	e9 5a ff ff ff       	jmp    800dc7 <vprintfmt+0x3a6>
}
  800e6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800e75:	f3 0f 1e fb          	endbr32 
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	83 ec 18             	sub    $0x18,%esp
  800e7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e82:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800e85:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e88:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800e8c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800e8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800e96:	85 c0                	test   %eax,%eax
  800e98:	74 26                	je     800ec0 <vsnprintf+0x4b>
  800e9a:	85 d2                	test   %edx,%edx
  800e9c:	7e 22                	jle    800ec0 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800e9e:	ff 75 14             	pushl  0x14(%ebp)
  800ea1:	ff 75 10             	pushl  0x10(%ebp)
  800ea4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ea7:	50                   	push   %eax
  800ea8:	68 df 09 80 00       	push   $0x8009df
  800ead:	e8 6f fb ff ff       	call   800a21 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800eb2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eb5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ebb:	83 c4 10             	add    $0x10,%esp
}
  800ebe:	c9                   	leave  
  800ebf:	c3                   	ret    
		return -E_INVAL;
  800ec0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec5:	eb f7                	jmp    800ebe <vsnprintf+0x49>

00800ec7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ec7:	f3 0f 1e fb          	endbr32 
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  800ed1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ed4:	50                   	push   %eax
  800ed5:	ff 75 10             	pushl  0x10(%ebp)
  800ed8:	ff 75 0c             	pushl  0xc(%ebp)
  800edb:	ff 75 08             	pushl  0x8(%ebp)
  800ede:	e8 92 ff ff ff       	call   800e75 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ee3:	c9                   	leave  
  800ee4:	c3                   	ret    

00800ee5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ee5:	f3 0f 1e fb          	endbr32 
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800eef:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ef8:	74 05                	je     800eff <strlen+0x1a>
		n++;
  800efa:	83 c0 01             	add    $0x1,%eax
  800efd:	eb f5                	jmp    800ef4 <strlen+0xf>
	return n;
}
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    

00800f01 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800f01:	f3 0f 1e fb          	endbr32 
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f0b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f13:	39 d0                	cmp    %edx,%eax
  800f15:	74 0d                	je     800f24 <strnlen+0x23>
  800f17:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800f1b:	74 05                	je     800f22 <strnlen+0x21>
		n++;
  800f1d:	83 c0 01             	add    $0x1,%eax
  800f20:	eb f1                	jmp    800f13 <strnlen+0x12>
  800f22:	89 c2                	mov    %eax,%edx
	return n;
}
  800f24:	89 d0                	mov    %edx,%eax
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    

00800f28 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800f28:	f3 0f 1e fb          	endbr32 
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	53                   	push   %ebx
  800f30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800f36:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3b:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800f3f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800f42:	83 c0 01             	add    $0x1,%eax
  800f45:	84 d2                	test   %dl,%dl
  800f47:	75 f2                	jne    800f3b <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800f49:	89 c8                	mov    %ecx,%eax
  800f4b:	5b                   	pop    %ebx
  800f4c:	5d                   	pop    %ebp
  800f4d:	c3                   	ret    

00800f4e <strcat>:

char *
strcat(char *dst, const char *src)
{
  800f4e:	f3 0f 1e fb          	endbr32 
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	53                   	push   %ebx
  800f56:	83 ec 10             	sub    $0x10,%esp
  800f59:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800f5c:	53                   	push   %ebx
  800f5d:	e8 83 ff ff ff       	call   800ee5 <strlen>
  800f62:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800f65:	ff 75 0c             	pushl  0xc(%ebp)
  800f68:	01 d8                	add    %ebx,%eax
  800f6a:	50                   	push   %eax
  800f6b:	e8 b8 ff ff ff       	call   800f28 <strcpy>
	return dst;
}
  800f70:	89 d8                	mov    %ebx,%eax
  800f72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f75:	c9                   	leave  
  800f76:	c3                   	ret    

00800f77 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800f77:	f3 0f 1e fb          	endbr32 
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	56                   	push   %esi
  800f7f:	53                   	push   %ebx
  800f80:	8b 75 08             	mov    0x8(%ebp),%esi
  800f83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f86:	89 f3                	mov    %esi,%ebx
  800f88:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f8b:	89 f0                	mov    %esi,%eax
  800f8d:	39 d8                	cmp    %ebx,%eax
  800f8f:	74 11                	je     800fa2 <strncpy+0x2b>
		*dst++ = *src;
  800f91:	83 c0 01             	add    $0x1,%eax
  800f94:	0f b6 0a             	movzbl (%edx),%ecx
  800f97:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800f9a:	80 f9 01             	cmp    $0x1,%cl
  800f9d:	83 da ff             	sbb    $0xffffffff,%edx
  800fa0:	eb eb                	jmp    800f8d <strncpy+0x16>
	}
	return ret;
}
  800fa2:	89 f0                	mov    %esi,%eax
  800fa4:	5b                   	pop    %ebx
  800fa5:	5e                   	pop    %esi
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    

00800fa8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800fa8:	f3 0f 1e fb          	endbr32 
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	56                   	push   %esi
  800fb0:	53                   	push   %ebx
  800fb1:	8b 75 08             	mov    0x8(%ebp),%esi
  800fb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb7:	8b 55 10             	mov    0x10(%ebp),%edx
  800fba:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800fbc:	85 d2                	test   %edx,%edx
  800fbe:	74 21                	je     800fe1 <strlcpy+0x39>
  800fc0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800fc4:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800fc6:	39 c2                	cmp    %eax,%edx
  800fc8:	74 14                	je     800fde <strlcpy+0x36>
  800fca:	0f b6 19             	movzbl (%ecx),%ebx
  800fcd:	84 db                	test   %bl,%bl
  800fcf:	74 0b                	je     800fdc <strlcpy+0x34>
			*dst++ = *src++;
  800fd1:	83 c1 01             	add    $0x1,%ecx
  800fd4:	83 c2 01             	add    $0x1,%edx
  800fd7:	88 5a ff             	mov    %bl,-0x1(%edx)
  800fda:	eb ea                	jmp    800fc6 <strlcpy+0x1e>
  800fdc:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800fde:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800fe1:	29 f0                	sub    %esi,%eax
}
  800fe3:	5b                   	pop    %ebx
  800fe4:	5e                   	pop    %esi
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    

00800fe7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800fe7:	f3 0f 1e fb          	endbr32 
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ff1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ff4:	0f b6 01             	movzbl (%ecx),%eax
  800ff7:	84 c0                	test   %al,%al
  800ff9:	74 0c                	je     801007 <strcmp+0x20>
  800ffb:	3a 02                	cmp    (%edx),%al
  800ffd:	75 08                	jne    801007 <strcmp+0x20>
		p++, q++;
  800fff:	83 c1 01             	add    $0x1,%ecx
  801002:	83 c2 01             	add    $0x1,%edx
  801005:	eb ed                	jmp    800ff4 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801007:	0f b6 c0             	movzbl %al,%eax
  80100a:	0f b6 12             	movzbl (%edx),%edx
  80100d:	29 d0                	sub    %edx,%eax
}
  80100f:	5d                   	pop    %ebp
  801010:	c3                   	ret    

00801011 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801011:	f3 0f 1e fb          	endbr32 
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	53                   	push   %ebx
  801019:	8b 45 08             	mov    0x8(%ebp),%eax
  80101c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80101f:	89 c3                	mov    %eax,%ebx
  801021:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801024:	eb 06                	jmp    80102c <strncmp+0x1b>
		n--, p++, q++;
  801026:	83 c0 01             	add    $0x1,%eax
  801029:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80102c:	39 d8                	cmp    %ebx,%eax
  80102e:	74 16                	je     801046 <strncmp+0x35>
  801030:	0f b6 08             	movzbl (%eax),%ecx
  801033:	84 c9                	test   %cl,%cl
  801035:	74 04                	je     80103b <strncmp+0x2a>
  801037:	3a 0a                	cmp    (%edx),%cl
  801039:	74 eb                	je     801026 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80103b:	0f b6 00             	movzbl (%eax),%eax
  80103e:	0f b6 12             	movzbl (%edx),%edx
  801041:	29 d0                	sub    %edx,%eax
}
  801043:	5b                   	pop    %ebx
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    
		return 0;
  801046:	b8 00 00 00 00       	mov    $0x0,%eax
  80104b:	eb f6                	jmp    801043 <strncmp+0x32>

0080104d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80104d:	f3 0f 1e fb          	endbr32 
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	8b 45 08             	mov    0x8(%ebp),%eax
  801057:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80105b:	0f b6 10             	movzbl (%eax),%edx
  80105e:	84 d2                	test   %dl,%dl
  801060:	74 09                	je     80106b <strchr+0x1e>
		if (*s == c)
  801062:	38 ca                	cmp    %cl,%dl
  801064:	74 0a                	je     801070 <strchr+0x23>
	for (; *s; s++)
  801066:	83 c0 01             	add    $0x1,%eax
  801069:	eb f0                	jmp    80105b <strchr+0xe>
			return (char *) s;
	return 0;
  80106b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801070:	5d                   	pop    %ebp
  801071:	c3                   	ret    

00801072 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  801072:	f3 0f 1e fb          	endbr32 
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  80107c:	6a 78                	push   $0x78
  80107e:	ff 75 08             	pushl  0x8(%ebp)
  801081:	e8 c7 ff ff ff       	call   80104d <strchr>
  801086:	83 c4 10             	add    $0x10,%esp
  801089:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  80108c:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  801091:	eb 0d                	jmp    8010a0 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  801093:	c1 e0 04             	shl    $0x4,%eax
  801096:	0f be d2             	movsbl %dl,%edx
  801099:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  80109d:	83 c1 01             	add    $0x1,%ecx
  8010a0:	0f b6 11             	movzbl (%ecx),%edx
  8010a3:	84 d2                	test   %dl,%dl
  8010a5:	74 11                	je     8010b8 <atox+0x46>
		if (*p>='a'){
  8010a7:	80 fa 60             	cmp    $0x60,%dl
  8010aa:	7e e7                	jle    801093 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  8010ac:	c1 e0 04             	shl    $0x4,%eax
  8010af:	0f be d2             	movsbl %dl,%edx
  8010b2:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  8010b6:	eb e5                	jmp    80109d <atox+0x2b>
	}

	return v;

}
  8010b8:	c9                   	leave  
  8010b9:	c3                   	ret    

008010ba <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8010ba:	f3 0f 1e fb          	endbr32 
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8010c8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8010cb:	38 ca                	cmp    %cl,%dl
  8010cd:	74 09                	je     8010d8 <strfind+0x1e>
  8010cf:	84 d2                	test   %dl,%dl
  8010d1:	74 05                	je     8010d8 <strfind+0x1e>
	for (; *s; s++)
  8010d3:	83 c0 01             	add    $0x1,%eax
  8010d6:	eb f0                	jmp    8010c8 <strfind+0xe>
			break;
	return (char *) s;
}
  8010d8:	5d                   	pop    %ebp
  8010d9:	c3                   	ret    

008010da <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8010da:	f3 0f 1e fb          	endbr32 
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	57                   	push   %edi
  8010e2:	56                   	push   %esi
  8010e3:	53                   	push   %ebx
  8010e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8010ea:	85 c9                	test   %ecx,%ecx
  8010ec:	74 31                	je     80111f <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8010ee:	89 f8                	mov    %edi,%eax
  8010f0:	09 c8                	or     %ecx,%eax
  8010f2:	a8 03                	test   $0x3,%al
  8010f4:	75 23                	jne    801119 <memset+0x3f>
		c &= 0xFF;
  8010f6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8010fa:	89 d3                	mov    %edx,%ebx
  8010fc:	c1 e3 08             	shl    $0x8,%ebx
  8010ff:	89 d0                	mov    %edx,%eax
  801101:	c1 e0 18             	shl    $0x18,%eax
  801104:	89 d6                	mov    %edx,%esi
  801106:	c1 e6 10             	shl    $0x10,%esi
  801109:	09 f0                	or     %esi,%eax
  80110b:	09 c2                	or     %eax,%edx
  80110d:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80110f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801112:	89 d0                	mov    %edx,%eax
  801114:	fc                   	cld    
  801115:	f3 ab                	rep stos %eax,%es:(%edi)
  801117:	eb 06                	jmp    80111f <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801119:	8b 45 0c             	mov    0xc(%ebp),%eax
  80111c:	fc                   	cld    
  80111d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80111f:	89 f8                	mov    %edi,%eax
  801121:	5b                   	pop    %ebx
  801122:	5e                   	pop    %esi
  801123:	5f                   	pop    %edi
  801124:	5d                   	pop    %ebp
  801125:	c3                   	ret    

00801126 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801126:	f3 0f 1e fb          	endbr32 
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	57                   	push   %edi
  80112e:	56                   	push   %esi
  80112f:	8b 45 08             	mov    0x8(%ebp),%eax
  801132:	8b 75 0c             	mov    0xc(%ebp),%esi
  801135:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801138:	39 c6                	cmp    %eax,%esi
  80113a:	73 32                	jae    80116e <memmove+0x48>
  80113c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80113f:	39 c2                	cmp    %eax,%edx
  801141:	76 2b                	jbe    80116e <memmove+0x48>
		s += n;
		d += n;
  801143:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801146:	89 fe                	mov    %edi,%esi
  801148:	09 ce                	or     %ecx,%esi
  80114a:	09 d6                	or     %edx,%esi
  80114c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801152:	75 0e                	jne    801162 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801154:	83 ef 04             	sub    $0x4,%edi
  801157:	8d 72 fc             	lea    -0x4(%edx),%esi
  80115a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80115d:	fd                   	std    
  80115e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801160:	eb 09                	jmp    80116b <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801162:	83 ef 01             	sub    $0x1,%edi
  801165:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801168:	fd                   	std    
  801169:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80116b:	fc                   	cld    
  80116c:	eb 1a                	jmp    801188 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80116e:	89 c2                	mov    %eax,%edx
  801170:	09 ca                	or     %ecx,%edx
  801172:	09 f2                	or     %esi,%edx
  801174:	f6 c2 03             	test   $0x3,%dl
  801177:	75 0a                	jne    801183 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801179:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80117c:	89 c7                	mov    %eax,%edi
  80117e:	fc                   	cld    
  80117f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801181:	eb 05                	jmp    801188 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  801183:	89 c7                	mov    %eax,%edi
  801185:	fc                   	cld    
  801186:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801188:	5e                   	pop    %esi
  801189:	5f                   	pop    %edi
  80118a:	5d                   	pop    %ebp
  80118b:	c3                   	ret    

0080118c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80118c:	f3 0f 1e fb          	endbr32 
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801196:	ff 75 10             	pushl  0x10(%ebp)
  801199:	ff 75 0c             	pushl  0xc(%ebp)
  80119c:	ff 75 08             	pushl  0x8(%ebp)
  80119f:	e8 82 ff ff ff       	call   801126 <memmove>
}
  8011a4:	c9                   	leave  
  8011a5:	c3                   	ret    

008011a6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8011a6:	f3 0f 1e fb          	endbr32 
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	56                   	push   %esi
  8011ae:	53                   	push   %ebx
  8011af:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b5:	89 c6                	mov    %eax,%esi
  8011b7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011ba:	39 f0                	cmp    %esi,%eax
  8011bc:	74 1c                	je     8011da <memcmp+0x34>
		if (*s1 != *s2)
  8011be:	0f b6 08             	movzbl (%eax),%ecx
  8011c1:	0f b6 1a             	movzbl (%edx),%ebx
  8011c4:	38 d9                	cmp    %bl,%cl
  8011c6:	75 08                	jne    8011d0 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8011c8:	83 c0 01             	add    $0x1,%eax
  8011cb:	83 c2 01             	add    $0x1,%edx
  8011ce:	eb ea                	jmp    8011ba <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8011d0:	0f b6 c1             	movzbl %cl,%eax
  8011d3:	0f b6 db             	movzbl %bl,%ebx
  8011d6:	29 d8                	sub    %ebx,%eax
  8011d8:	eb 05                	jmp    8011df <memcmp+0x39>
	}

	return 0;
  8011da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011df:	5b                   	pop    %ebx
  8011e0:	5e                   	pop    %esi
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    

008011e3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8011e3:	f3 0f 1e fb          	endbr32 
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8011f0:	89 c2                	mov    %eax,%edx
  8011f2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8011f5:	39 d0                	cmp    %edx,%eax
  8011f7:	73 09                	jae    801202 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  8011f9:	38 08                	cmp    %cl,(%eax)
  8011fb:	74 05                	je     801202 <memfind+0x1f>
	for (; s < ends; s++)
  8011fd:	83 c0 01             	add    $0x1,%eax
  801200:	eb f3                	jmp    8011f5 <memfind+0x12>
			break;
	return (void *) s;
}
  801202:	5d                   	pop    %ebp
  801203:	c3                   	ret    

00801204 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801204:	f3 0f 1e fb          	endbr32 
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	57                   	push   %edi
  80120c:	56                   	push   %esi
  80120d:	53                   	push   %ebx
  80120e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801211:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801214:	eb 03                	jmp    801219 <strtol+0x15>
		s++;
  801216:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801219:	0f b6 01             	movzbl (%ecx),%eax
  80121c:	3c 20                	cmp    $0x20,%al
  80121e:	74 f6                	je     801216 <strtol+0x12>
  801220:	3c 09                	cmp    $0x9,%al
  801222:	74 f2                	je     801216 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801224:	3c 2b                	cmp    $0x2b,%al
  801226:	74 2a                	je     801252 <strtol+0x4e>
	int neg = 0;
  801228:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80122d:	3c 2d                	cmp    $0x2d,%al
  80122f:	74 2b                	je     80125c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801231:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801237:	75 0f                	jne    801248 <strtol+0x44>
  801239:	80 39 30             	cmpb   $0x30,(%ecx)
  80123c:	74 28                	je     801266 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80123e:	85 db                	test   %ebx,%ebx
  801240:	b8 0a 00 00 00       	mov    $0xa,%eax
  801245:	0f 44 d8             	cmove  %eax,%ebx
  801248:	b8 00 00 00 00       	mov    $0x0,%eax
  80124d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801250:	eb 46                	jmp    801298 <strtol+0x94>
		s++;
  801252:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801255:	bf 00 00 00 00       	mov    $0x0,%edi
  80125a:	eb d5                	jmp    801231 <strtol+0x2d>
		s++, neg = 1;
  80125c:	83 c1 01             	add    $0x1,%ecx
  80125f:	bf 01 00 00 00       	mov    $0x1,%edi
  801264:	eb cb                	jmp    801231 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801266:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80126a:	74 0e                	je     80127a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80126c:	85 db                	test   %ebx,%ebx
  80126e:	75 d8                	jne    801248 <strtol+0x44>
		s++, base = 8;
  801270:	83 c1 01             	add    $0x1,%ecx
  801273:	bb 08 00 00 00       	mov    $0x8,%ebx
  801278:	eb ce                	jmp    801248 <strtol+0x44>
		s += 2, base = 16;
  80127a:	83 c1 02             	add    $0x2,%ecx
  80127d:	bb 10 00 00 00       	mov    $0x10,%ebx
  801282:	eb c4                	jmp    801248 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801284:	0f be d2             	movsbl %dl,%edx
  801287:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80128a:	3b 55 10             	cmp    0x10(%ebp),%edx
  80128d:	7d 3a                	jge    8012c9 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  80128f:	83 c1 01             	add    $0x1,%ecx
  801292:	0f af 45 10          	imul   0x10(%ebp),%eax
  801296:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801298:	0f b6 11             	movzbl (%ecx),%edx
  80129b:	8d 72 d0             	lea    -0x30(%edx),%esi
  80129e:	89 f3                	mov    %esi,%ebx
  8012a0:	80 fb 09             	cmp    $0x9,%bl
  8012a3:	76 df                	jbe    801284 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  8012a5:	8d 72 9f             	lea    -0x61(%edx),%esi
  8012a8:	89 f3                	mov    %esi,%ebx
  8012aa:	80 fb 19             	cmp    $0x19,%bl
  8012ad:	77 08                	ja     8012b7 <strtol+0xb3>
			dig = *s - 'a' + 10;
  8012af:	0f be d2             	movsbl %dl,%edx
  8012b2:	83 ea 57             	sub    $0x57,%edx
  8012b5:	eb d3                	jmp    80128a <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  8012b7:	8d 72 bf             	lea    -0x41(%edx),%esi
  8012ba:	89 f3                	mov    %esi,%ebx
  8012bc:	80 fb 19             	cmp    $0x19,%bl
  8012bf:	77 08                	ja     8012c9 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8012c1:	0f be d2             	movsbl %dl,%edx
  8012c4:	83 ea 37             	sub    $0x37,%edx
  8012c7:	eb c1                	jmp    80128a <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  8012c9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8012cd:	74 05                	je     8012d4 <strtol+0xd0>
		*endptr = (char *) s;
  8012cf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012d2:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8012d4:	89 c2                	mov    %eax,%edx
  8012d6:	f7 da                	neg    %edx
  8012d8:	85 ff                	test   %edi,%edi
  8012da:	0f 45 c2             	cmovne %edx,%eax
}
  8012dd:	5b                   	pop    %ebx
  8012de:	5e                   	pop    %esi
  8012df:	5f                   	pop    %edi
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    

008012e2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8012e2:	f3 0f 1e fb          	endbr32 
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	57                   	push   %edi
  8012ea:	56                   	push   %esi
  8012eb:	53                   	push   %ebx
	asm volatile("int %1\n"
  8012ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f7:	89 c3                	mov    %eax,%ebx
  8012f9:	89 c7                	mov    %eax,%edi
  8012fb:	89 c6                	mov    %eax,%esi
  8012fd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8012ff:	5b                   	pop    %ebx
  801300:	5e                   	pop    %esi
  801301:	5f                   	pop    %edi
  801302:	5d                   	pop    %ebp
  801303:	c3                   	ret    

00801304 <sys_cgetc>:

int
sys_cgetc(void)
{
  801304:	f3 0f 1e fb          	endbr32 
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	57                   	push   %edi
  80130c:	56                   	push   %esi
  80130d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80130e:	ba 00 00 00 00       	mov    $0x0,%edx
  801313:	b8 01 00 00 00       	mov    $0x1,%eax
  801318:	89 d1                	mov    %edx,%ecx
  80131a:	89 d3                	mov    %edx,%ebx
  80131c:	89 d7                	mov    %edx,%edi
  80131e:	89 d6                	mov    %edx,%esi
  801320:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801322:	5b                   	pop    %ebx
  801323:	5e                   	pop    %esi
  801324:	5f                   	pop    %edi
  801325:	5d                   	pop    %ebp
  801326:	c3                   	ret    

00801327 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801327:	f3 0f 1e fb          	endbr32 
  80132b:	55                   	push   %ebp
  80132c:	89 e5                	mov    %esp,%ebp
  80132e:	57                   	push   %edi
  80132f:	56                   	push   %esi
  801330:	53                   	push   %ebx
	asm volatile("int %1\n"
  801331:	b9 00 00 00 00       	mov    $0x0,%ecx
  801336:	8b 55 08             	mov    0x8(%ebp),%edx
  801339:	b8 03 00 00 00       	mov    $0x3,%eax
  80133e:	89 cb                	mov    %ecx,%ebx
  801340:	89 cf                	mov    %ecx,%edi
  801342:	89 ce                	mov    %ecx,%esi
  801344:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801346:	5b                   	pop    %ebx
  801347:	5e                   	pop    %esi
  801348:	5f                   	pop    %edi
  801349:	5d                   	pop    %ebp
  80134a:	c3                   	ret    

0080134b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80134b:	f3 0f 1e fb          	endbr32 
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	57                   	push   %edi
  801353:	56                   	push   %esi
  801354:	53                   	push   %ebx
	asm volatile("int %1\n"
  801355:	ba 00 00 00 00       	mov    $0x0,%edx
  80135a:	b8 02 00 00 00       	mov    $0x2,%eax
  80135f:	89 d1                	mov    %edx,%ecx
  801361:	89 d3                	mov    %edx,%ebx
  801363:	89 d7                	mov    %edx,%edi
  801365:	89 d6                	mov    %edx,%esi
  801367:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801369:	5b                   	pop    %ebx
  80136a:	5e                   	pop    %esi
  80136b:	5f                   	pop    %edi
  80136c:	5d                   	pop    %ebp
  80136d:	c3                   	ret    

0080136e <sys_yield>:

void
sys_yield(void)
{
  80136e:	f3 0f 1e fb          	endbr32 
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	57                   	push   %edi
  801376:	56                   	push   %esi
  801377:	53                   	push   %ebx
	asm volatile("int %1\n"
  801378:	ba 00 00 00 00       	mov    $0x0,%edx
  80137d:	b8 0b 00 00 00       	mov    $0xb,%eax
  801382:	89 d1                	mov    %edx,%ecx
  801384:	89 d3                	mov    %edx,%ebx
  801386:	89 d7                	mov    %edx,%edi
  801388:	89 d6                	mov    %edx,%esi
  80138a:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80138c:	5b                   	pop    %ebx
  80138d:	5e                   	pop    %esi
  80138e:	5f                   	pop    %edi
  80138f:	5d                   	pop    %ebp
  801390:	c3                   	ret    

00801391 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801391:	f3 0f 1e fb          	endbr32 
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	57                   	push   %edi
  801399:	56                   	push   %esi
  80139a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80139b:	be 00 00 00 00       	mov    $0x0,%esi
  8013a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8013a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a6:	b8 04 00 00 00       	mov    $0x4,%eax
  8013ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013ae:	89 f7                	mov    %esi,%edi
  8013b0:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8013b2:	5b                   	pop    %ebx
  8013b3:	5e                   	pop    %esi
  8013b4:	5f                   	pop    %edi
  8013b5:	5d                   	pop    %ebp
  8013b6:	c3                   	ret    

008013b7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8013b7:	f3 0f 1e fb          	endbr32 
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	57                   	push   %edi
  8013bf:	56                   	push   %esi
  8013c0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8013c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8013c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013c7:	b8 05 00 00 00       	mov    $0x5,%eax
  8013cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013cf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8013d2:	8b 75 18             	mov    0x18(%ebp),%esi
  8013d5:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8013d7:	5b                   	pop    %ebx
  8013d8:	5e                   	pop    %esi
  8013d9:	5f                   	pop    %edi
  8013da:	5d                   	pop    %ebp
  8013db:	c3                   	ret    

008013dc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8013dc:	f3 0f 1e fb          	endbr32 
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	57                   	push   %edi
  8013e4:	56                   	push   %esi
  8013e5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8013e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8013f6:	89 df                	mov    %ebx,%edi
  8013f8:	89 de                	mov    %ebx,%esi
  8013fa:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8013fc:	5b                   	pop    %ebx
  8013fd:	5e                   	pop    %esi
  8013fe:	5f                   	pop    %edi
  8013ff:	5d                   	pop    %ebp
  801400:	c3                   	ret    

00801401 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801401:	f3 0f 1e fb          	endbr32 
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	57                   	push   %edi
  801409:	56                   	push   %esi
  80140a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80140b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801410:	8b 55 08             	mov    0x8(%ebp),%edx
  801413:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801416:	b8 08 00 00 00       	mov    $0x8,%eax
  80141b:	89 df                	mov    %ebx,%edi
  80141d:	89 de                	mov    %ebx,%esi
  80141f:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801421:	5b                   	pop    %ebx
  801422:	5e                   	pop    %esi
  801423:	5f                   	pop    %edi
  801424:	5d                   	pop    %ebp
  801425:	c3                   	ret    

00801426 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801426:	f3 0f 1e fb          	endbr32 
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	57                   	push   %edi
  80142e:	56                   	push   %esi
  80142f:	53                   	push   %ebx
	asm volatile("int %1\n"
  801430:	bb 00 00 00 00       	mov    $0x0,%ebx
  801435:	8b 55 08             	mov    0x8(%ebp),%edx
  801438:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80143b:	b8 09 00 00 00       	mov    $0x9,%eax
  801440:	89 df                	mov    %ebx,%edi
  801442:	89 de                	mov    %ebx,%esi
  801444:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801446:	5b                   	pop    %ebx
  801447:	5e                   	pop    %esi
  801448:	5f                   	pop    %edi
  801449:	5d                   	pop    %ebp
  80144a:	c3                   	ret    

0080144b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80144b:	f3 0f 1e fb          	endbr32 
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	57                   	push   %edi
  801453:	56                   	push   %esi
  801454:	53                   	push   %ebx
	asm volatile("int %1\n"
  801455:	bb 00 00 00 00       	mov    $0x0,%ebx
  80145a:	8b 55 08             	mov    0x8(%ebp),%edx
  80145d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801460:	b8 0a 00 00 00       	mov    $0xa,%eax
  801465:	89 df                	mov    %ebx,%edi
  801467:	89 de                	mov    %ebx,%esi
  801469:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80146b:	5b                   	pop    %ebx
  80146c:	5e                   	pop    %esi
  80146d:	5f                   	pop    %edi
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    

00801470 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801470:	f3 0f 1e fb          	endbr32 
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	57                   	push   %edi
  801478:	56                   	push   %esi
  801479:	53                   	push   %ebx
	asm volatile("int %1\n"
  80147a:	8b 55 08             	mov    0x8(%ebp),%edx
  80147d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801480:	b8 0c 00 00 00       	mov    $0xc,%eax
  801485:	be 00 00 00 00       	mov    $0x0,%esi
  80148a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80148d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801490:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801492:	5b                   	pop    %ebx
  801493:	5e                   	pop    %esi
  801494:	5f                   	pop    %edi
  801495:	5d                   	pop    %ebp
  801496:	c3                   	ret    

00801497 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801497:	f3 0f 1e fb          	endbr32 
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	57                   	push   %edi
  80149f:	56                   	push   %esi
  8014a0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8014a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8014a9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8014ae:	89 cb                	mov    %ecx,%ebx
  8014b0:	89 cf                	mov    %ecx,%edi
  8014b2:	89 ce                	mov    %ecx,%esi
  8014b4:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8014b6:	5b                   	pop    %ebx
  8014b7:	5e                   	pop    %esi
  8014b8:	5f                   	pop    %edi
  8014b9:	5d                   	pop    %ebp
  8014ba:	c3                   	ret    

008014bb <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8014bb:	f3 0f 1e fb          	endbr32 
  8014bf:	55                   	push   %ebp
  8014c0:	89 e5                	mov    %esp,%ebp
  8014c2:	57                   	push   %edi
  8014c3:	56                   	push   %esi
  8014c4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8014c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ca:	b8 0e 00 00 00       	mov    $0xe,%eax
  8014cf:	89 d1                	mov    %edx,%ecx
  8014d1:	89 d3                	mov    %edx,%ebx
  8014d3:	89 d7                	mov    %edx,%edi
  8014d5:	89 d6                	mov    %edx,%esi
  8014d7:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8014d9:	5b                   	pop    %ebx
  8014da:	5e                   	pop    %esi
  8014db:	5f                   	pop    %edi
  8014dc:	5d                   	pop    %ebp
  8014dd:	c3                   	ret    

008014de <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  8014de:	f3 0f 1e fb          	endbr32 
  8014e2:	55                   	push   %ebp
  8014e3:	89 e5                	mov    %esp,%ebp
  8014e5:	57                   	push   %edi
  8014e6:	56                   	push   %esi
  8014e7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8014e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014f3:	b8 0f 00 00 00       	mov    $0xf,%eax
  8014f8:	89 df                	mov    %ebx,%edi
  8014fa:	89 de                	mov    %ebx,%esi
  8014fc:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  8014fe:	5b                   	pop    %ebx
  8014ff:	5e                   	pop    %esi
  801500:	5f                   	pop    %edi
  801501:	5d                   	pop    %ebp
  801502:	c3                   	ret    

00801503 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  801503:	f3 0f 1e fb          	endbr32 
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	57                   	push   %edi
  80150b:	56                   	push   %esi
  80150c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80150d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801512:	8b 55 08             	mov    0x8(%ebp),%edx
  801515:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801518:	b8 10 00 00 00       	mov    $0x10,%eax
  80151d:	89 df                	mov    %ebx,%edi
  80151f:	89 de                	mov    %ebx,%esi
  801521:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  801523:	5b                   	pop    %ebx
  801524:	5e                   	pop    %esi
  801525:	5f                   	pop    %edi
  801526:	5d                   	pop    %ebp
  801527:	c3                   	ret    

00801528 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801528:	f3 0f 1e fb          	endbr32 
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80152f:	8b 45 08             	mov    0x8(%ebp),%eax
  801532:	05 00 00 00 30       	add    $0x30000000,%eax
  801537:	c1 e8 0c             	shr    $0xc,%eax
}
  80153a:	5d                   	pop    %ebp
  80153b:	c3                   	ret    

0080153c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80153c:	f3 0f 1e fb          	endbr32 
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801543:	8b 45 08             	mov    0x8(%ebp),%eax
  801546:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80154b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801550:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801555:	5d                   	pop    %ebp
  801556:	c3                   	ret    

00801557 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801557:	f3 0f 1e fb          	endbr32 
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801563:	89 c2                	mov    %eax,%edx
  801565:	c1 ea 16             	shr    $0x16,%edx
  801568:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80156f:	f6 c2 01             	test   $0x1,%dl
  801572:	74 2d                	je     8015a1 <fd_alloc+0x4a>
  801574:	89 c2                	mov    %eax,%edx
  801576:	c1 ea 0c             	shr    $0xc,%edx
  801579:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801580:	f6 c2 01             	test   $0x1,%dl
  801583:	74 1c                	je     8015a1 <fd_alloc+0x4a>
  801585:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80158a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80158f:	75 d2                	jne    801563 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  801591:	8b 45 08             	mov    0x8(%ebp),%eax
  801594:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80159a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80159f:	eb 0a                	jmp    8015ab <fd_alloc+0x54>
			*fd_store = fd;
  8015a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015a4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ab:	5d                   	pop    %ebp
  8015ac:	c3                   	ret    

008015ad <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8015ad:	f3 0f 1e fb          	endbr32 
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8015b7:	83 f8 1f             	cmp    $0x1f,%eax
  8015ba:	77 30                	ja     8015ec <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8015bc:	c1 e0 0c             	shl    $0xc,%eax
  8015bf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8015c4:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8015ca:	f6 c2 01             	test   $0x1,%dl
  8015cd:	74 24                	je     8015f3 <fd_lookup+0x46>
  8015cf:	89 c2                	mov    %eax,%edx
  8015d1:	c1 ea 0c             	shr    $0xc,%edx
  8015d4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015db:	f6 c2 01             	test   $0x1,%dl
  8015de:	74 1a                	je     8015fa <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e3:	89 02                	mov    %eax,(%edx)
	return 0;
  8015e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ea:	5d                   	pop    %ebp
  8015eb:	c3                   	ret    
		return -E_INVAL;
  8015ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015f1:	eb f7                	jmp    8015ea <fd_lookup+0x3d>
		return -E_INVAL;
  8015f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015f8:	eb f0                	jmp    8015ea <fd_lookup+0x3d>
  8015fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ff:	eb e9                	jmp    8015ea <fd_lookup+0x3d>

00801601 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801601:	f3 0f 1e fb          	endbr32 
  801605:	55                   	push   %ebp
  801606:	89 e5                	mov    %esp,%ebp
  801608:	83 ec 08             	sub    $0x8,%esp
  80160b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  80160e:	ba 00 00 00 00       	mov    $0x0,%edx
  801613:	b8 40 40 80 00       	mov    $0x804040,%eax
		if (devtab[i]->dev_id == dev_id) {
  801618:	39 08                	cmp    %ecx,(%eax)
  80161a:	74 38                	je     801654 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80161c:	83 c2 01             	add    $0x1,%edx
  80161f:	8b 04 95 1c 33 80 00 	mov    0x80331c(,%edx,4),%eax
  801626:	85 c0                	test   %eax,%eax
  801628:	75 ee                	jne    801618 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80162a:	a1 1c 50 80 00       	mov    0x80501c,%eax
  80162f:	8b 40 48             	mov    0x48(%eax),%eax
  801632:	83 ec 04             	sub    $0x4,%esp
  801635:	51                   	push   %ecx
  801636:	50                   	push   %eax
  801637:	68 a0 32 80 00       	push   $0x8032a0
  80163c:	e8 dd f2 ff ff       	call   80091e <cprintf>
	*dev = 0;
  801641:	8b 45 0c             	mov    0xc(%ebp),%eax
  801644:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801652:	c9                   	leave  
  801653:	c3                   	ret    
			*dev = devtab[i];
  801654:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801657:	89 01                	mov    %eax,(%ecx)
			return 0;
  801659:	b8 00 00 00 00       	mov    $0x0,%eax
  80165e:	eb f2                	jmp    801652 <dev_lookup+0x51>

00801660 <fd_close>:
{
  801660:	f3 0f 1e fb          	endbr32 
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	57                   	push   %edi
  801668:	56                   	push   %esi
  801669:	53                   	push   %ebx
  80166a:	83 ec 24             	sub    $0x24,%esp
  80166d:	8b 75 08             	mov    0x8(%ebp),%esi
  801670:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801673:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801676:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801677:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80167d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801680:	50                   	push   %eax
  801681:	e8 27 ff ff ff       	call   8015ad <fd_lookup>
  801686:	89 c3                	mov    %eax,%ebx
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	85 c0                	test   %eax,%eax
  80168d:	78 05                	js     801694 <fd_close+0x34>
	    || fd != fd2)
  80168f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801692:	74 16                	je     8016aa <fd_close+0x4a>
		return (must_exist ? r : 0);
  801694:	89 f8                	mov    %edi,%eax
  801696:	84 c0                	test   %al,%al
  801698:	b8 00 00 00 00       	mov    $0x0,%eax
  80169d:	0f 44 d8             	cmove  %eax,%ebx
}
  8016a0:	89 d8                	mov    %ebx,%eax
  8016a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a5:	5b                   	pop    %ebx
  8016a6:	5e                   	pop    %esi
  8016a7:	5f                   	pop    %edi
  8016a8:	5d                   	pop    %ebp
  8016a9:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8016aa:	83 ec 08             	sub    $0x8,%esp
  8016ad:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8016b0:	50                   	push   %eax
  8016b1:	ff 36                	pushl  (%esi)
  8016b3:	e8 49 ff ff ff       	call   801601 <dev_lookup>
  8016b8:	89 c3                	mov    %eax,%ebx
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	85 c0                	test   %eax,%eax
  8016bf:	78 1a                	js     8016db <fd_close+0x7b>
		if (dev->dev_close)
  8016c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016c4:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8016c7:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	74 0b                	je     8016db <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8016d0:	83 ec 0c             	sub    $0xc,%esp
  8016d3:	56                   	push   %esi
  8016d4:	ff d0                	call   *%eax
  8016d6:	89 c3                	mov    %eax,%ebx
  8016d8:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8016db:	83 ec 08             	sub    $0x8,%esp
  8016de:	56                   	push   %esi
  8016df:	6a 00                	push   $0x0
  8016e1:	e8 f6 fc ff ff       	call   8013dc <sys_page_unmap>
	return r;
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	eb b5                	jmp    8016a0 <fd_close+0x40>

008016eb <close>:

int
close(int fdnum)
{
  8016eb:	f3 0f 1e fb          	endbr32 
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f8:	50                   	push   %eax
  8016f9:	ff 75 08             	pushl  0x8(%ebp)
  8016fc:	e8 ac fe ff ff       	call   8015ad <fd_lookup>
  801701:	83 c4 10             	add    $0x10,%esp
  801704:	85 c0                	test   %eax,%eax
  801706:	79 02                	jns    80170a <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801708:	c9                   	leave  
  801709:	c3                   	ret    
		return fd_close(fd, 1);
  80170a:	83 ec 08             	sub    $0x8,%esp
  80170d:	6a 01                	push   $0x1
  80170f:	ff 75 f4             	pushl  -0xc(%ebp)
  801712:	e8 49 ff ff ff       	call   801660 <fd_close>
  801717:	83 c4 10             	add    $0x10,%esp
  80171a:	eb ec                	jmp    801708 <close+0x1d>

0080171c <close_all>:

void
close_all(void)
{
  80171c:	f3 0f 1e fb          	endbr32 
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	53                   	push   %ebx
  801724:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801727:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80172c:	83 ec 0c             	sub    $0xc,%esp
  80172f:	53                   	push   %ebx
  801730:	e8 b6 ff ff ff       	call   8016eb <close>
	for (i = 0; i < MAXFD; i++)
  801735:	83 c3 01             	add    $0x1,%ebx
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	83 fb 20             	cmp    $0x20,%ebx
  80173e:	75 ec                	jne    80172c <close_all+0x10>
}
  801740:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801743:	c9                   	leave  
  801744:	c3                   	ret    

00801745 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801745:	f3 0f 1e fb          	endbr32 
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	57                   	push   %edi
  80174d:	56                   	push   %esi
  80174e:	53                   	push   %ebx
  80174f:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801752:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801755:	50                   	push   %eax
  801756:	ff 75 08             	pushl  0x8(%ebp)
  801759:	e8 4f fe ff ff       	call   8015ad <fd_lookup>
  80175e:	89 c3                	mov    %eax,%ebx
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	85 c0                	test   %eax,%eax
  801765:	0f 88 81 00 00 00    	js     8017ec <dup+0xa7>
		return r;
	close(newfdnum);
  80176b:	83 ec 0c             	sub    $0xc,%esp
  80176e:	ff 75 0c             	pushl  0xc(%ebp)
  801771:	e8 75 ff ff ff       	call   8016eb <close>

	newfd = INDEX2FD(newfdnum);
  801776:	8b 75 0c             	mov    0xc(%ebp),%esi
  801779:	c1 e6 0c             	shl    $0xc,%esi
  80177c:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801782:	83 c4 04             	add    $0x4,%esp
  801785:	ff 75 e4             	pushl  -0x1c(%ebp)
  801788:	e8 af fd ff ff       	call   80153c <fd2data>
  80178d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80178f:	89 34 24             	mov    %esi,(%esp)
  801792:	e8 a5 fd ff ff       	call   80153c <fd2data>
  801797:	83 c4 10             	add    $0x10,%esp
  80179a:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80179c:	89 d8                	mov    %ebx,%eax
  80179e:	c1 e8 16             	shr    $0x16,%eax
  8017a1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8017a8:	a8 01                	test   $0x1,%al
  8017aa:	74 11                	je     8017bd <dup+0x78>
  8017ac:	89 d8                	mov    %ebx,%eax
  8017ae:	c1 e8 0c             	shr    $0xc,%eax
  8017b1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8017b8:	f6 c2 01             	test   $0x1,%dl
  8017bb:	75 39                	jne    8017f6 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017bd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017c0:	89 d0                	mov    %edx,%eax
  8017c2:	c1 e8 0c             	shr    $0xc,%eax
  8017c5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017cc:	83 ec 0c             	sub    $0xc,%esp
  8017cf:	25 07 0e 00 00       	and    $0xe07,%eax
  8017d4:	50                   	push   %eax
  8017d5:	56                   	push   %esi
  8017d6:	6a 00                	push   $0x0
  8017d8:	52                   	push   %edx
  8017d9:	6a 00                	push   $0x0
  8017db:	e8 d7 fb ff ff       	call   8013b7 <sys_page_map>
  8017e0:	89 c3                	mov    %eax,%ebx
  8017e2:	83 c4 20             	add    $0x20,%esp
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	78 31                	js     80181a <dup+0xd5>
		goto err;

	return newfdnum;
  8017e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8017ec:	89 d8                	mov    %ebx,%eax
  8017ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017f1:	5b                   	pop    %ebx
  8017f2:	5e                   	pop    %esi
  8017f3:	5f                   	pop    %edi
  8017f4:	5d                   	pop    %ebp
  8017f5:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8017f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017fd:	83 ec 0c             	sub    $0xc,%esp
  801800:	25 07 0e 00 00       	and    $0xe07,%eax
  801805:	50                   	push   %eax
  801806:	57                   	push   %edi
  801807:	6a 00                	push   $0x0
  801809:	53                   	push   %ebx
  80180a:	6a 00                	push   $0x0
  80180c:	e8 a6 fb ff ff       	call   8013b7 <sys_page_map>
  801811:	89 c3                	mov    %eax,%ebx
  801813:	83 c4 20             	add    $0x20,%esp
  801816:	85 c0                	test   %eax,%eax
  801818:	79 a3                	jns    8017bd <dup+0x78>
	sys_page_unmap(0, newfd);
  80181a:	83 ec 08             	sub    $0x8,%esp
  80181d:	56                   	push   %esi
  80181e:	6a 00                	push   $0x0
  801820:	e8 b7 fb ff ff       	call   8013dc <sys_page_unmap>
	sys_page_unmap(0, nva);
  801825:	83 c4 08             	add    $0x8,%esp
  801828:	57                   	push   %edi
  801829:	6a 00                	push   $0x0
  80182b:	e8 ac fb ff ff       	call   8013dc <sys_page_unmap>
	return r;
  801830:	83 c4 10             	add    $0x10,%esp
  801833:	eb b7                	jmp    8017ec <dup+0xa7>

00801835 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801835:	f3 0f 1e fb          	endbr32 
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	53                   	push   %ebx
  80183d:	83 ec 1c             	sub    $0x1c,%esp
  801840:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801843:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801846:	50                   	push   %eax
  801847:	53                   	push   %ebx
  801848:	e8 60 fd ff ff       	call   8015ad <fd_lookup>
  80184d:	83 c4 10             	add    $0x10,%esp
  801850:	85 c0                	test   %eax,%eax
  801852:	78 3f                	js     801893 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801854:	83 ec 08             	sub    $0x8,%esp
  801857:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80185a:	50                   	push   %eax
  80185b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185e:	ff 30                	pushl  (%eax)
  801860:	e8 9c fd ff ff       	call   801601 <dev_lookup>
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	85 c0                	test   %eax,%eax
  80186a:	78 27                	js     801893 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80186c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80186f:	8b 42 08             	mov    0x8(%edx),%eax
  801872:	83 e0 03             	and    $0x3,%eax
  801875:	83 f8 01             	cmp    $0x1,%eax
  801878:	74 1e                	je     801898 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80187a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80187d:	8b 40 08             	mov    0x8(%eax),%eax
  801880:	85 c0                	test   %eax,%eax
  801882:	74 35                	je     8018b9 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801884:	83 ec 04             	sub    $0x4,%esp
  801887:	ff 75 10             	pushl  0x10(%ebp)
  80188a:	ff 75 0c             	pushl  0xc(%ebp)
  80188d:	52                   	push   %edx
  80188e:	ff d0                	call   *%eax
  801890:	83 c4 10             	add    $0x10,%esp
}
  801893:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801896:	c9                   	leave  
  801897:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801898:	a1 1c 50 80 00       	mov    0x80501c,%eax
  80189d:	8b 40 48             	mov    0x48(%eax),%eax
  8018a0:	83 ec 04             	sub    $0x4,%esp
  8018a3:	53                   	push   %ebx
  8018a4:	50                   	push   %eax
  8018a5:	68 e1 32 80 00       	push   $0x8032e1
  8018aa:	e8 6f f0 ff ff       	call   80091e <cprintf>
		return -E_INVAL;
  8018af:	83 c4 10             	add    $0x10,%esp
  8018b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018b7:	eb da                	jmp    801893 <read+0x5e>
		return -E_NOT_SUPP;
  8018b9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018be:	eb d3                	jmp    801893 <read+0x5e>

008018c0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8018c0:	f3 0f 1e fb          	endbr32 
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	57                   	push   %edi
  8018c8:	56                   	push   %esi
  8018c9:	53                   	push   %ebx
  8018ca:	83 ec 0c             	sub    $0xc,%esp
  8018cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018d0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018d8:	eb 02                	jmp    8018dc <readn+0x1c>
  8018da:	01 c3                	add    %eax,%ebx
  8018dc:	39 f3                	cmp    %esi,%ebx
  8018de:	73 21                	jae    801901 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018e0:	83 ec 04             	sub    $0x4,%esp
  8018e3:	89 f0                	mov    %esi,%eax
  8018e5:	29 d8                	sub    %ebx,%eax
  8018e7:	50                   	push   %eax
  8018e8:	89 d8                	mov    %ebx,%eax
  8018ea:	03 45 0c             	add    0xc(%ebp),%eax
  8018ed:	50                   	push   %eax
  8018ee:	57                   	push   %edi
  8018ef:	e8 41 ff ff ff       	call   801835 <read>
		if (m < 0)
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	85 c0                	test   %eax,%eax
  8018f9:	78 04                	js     8018ff <readn+0x3f>
			return m;
		if (m == 0)
  8018fb:	75 dd                	jne    8018da <readn+0x1a>
  8018fd:	eb 02                	jmp    801901 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018ff:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801901:	89 d8                	mov    %ebx,%eax
  801903:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801906:	5b                   	pop    %ebx
  801907:	5e                   	pop    %esi
  801908:	5f                   	pop    %edi
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    

0080190b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80190b:	f3 0f 1e fb          	endbr32 
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	53                   	push   %ebx
  801913:	83 ec 1c             	sub    $0x1c,%esp
  801916:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801919:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80191c:	50                   	push   %eax
  80191d:	53                   	push   %ebx
  80191e:	e8 8a fc ff ff       	call   8015ad <fd_lookup>
  801923:	83 c4 10             	add    $0x10,%esp
  801926:	85 c0                	test   %eax,%eax
  801928:	78 3a                	js     801964 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80192a:	83 ec 08             	sub    $0x8,%esp
  80192d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801930:	50                   	push   %eax
  801931:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801934:	ff 30                	pushl  (%eax)
  801936:	e8 c6 fc ff ff       	call   801601 <dev_lookup>
  80193b:	83 c4 10             	add    $0x10,%esp
  80193e:	85 c0                	test   %eax,%eax
  801940:	78 22                	js     801964 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801942:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801945:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801949:	74 1e                	je     801969 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80194b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80194e:	8b 52 0c             	mov    0xc(%edx),%edx
  801951:	85 d2                	test   %edx,%edx
  801953:	74 35                	je     80198a <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801955:	83 ec 04             	sub    $0x4,%esp
  801958:	ff 75 10             	pushl  0x10(%ebp)
  80195b:	ff 75 0c             	pushl  0xc(%ebp)
  80195e:	50                   	push   %eax
  80195f:	ff d2                	call   *%edx
  801961:	83 c4 10             	add    $0x10,%esp
}
  801964:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801967:	c9                   	leave  
  801968:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801969:	a1 1c 50 80 00       	mov    0x80501c,%eax
  80196e:	8b 40 48             	mov    0x48(%eax),%eax
  801971:	83 ec 04             	sub    $0x4,%esp
  801974:	53                   	push   %ebx
  801975:	50                   	push   %eax
  801976:	68 fd 32 80 00       	push   $0x8032fd
  80197b:	e8 9e ef ff ff       	call   80091e <cprintf>
		return -E_INVAL;
  801980:	83 c4 10             	add    $0x10,%esp
  801983:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801988:	eb da                	jmp    801964 <write+0x59>
		return -E_NOT_SUPP;
  80198a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80198f:	eb d3                	jmp    801964 <write+0x59>

00801991 <seek>:

int
seek(int fdnum, off_t offset)
{
  801991:	f3 0f 1e fb          	endbr32 
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80199b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199e:	50                   	push   %eax
  80199f:	ff 75 08             	pushl  0x8(%ebp)
  8019a2:	e8 06 fc ff ff       	call   8015ad <fd_lookup>
  8019a7:	83 c4 10             	add    $0x10,%esp
  8019aa:	85 c0                	test   %eax,%eax
  8019ac:	78 0e                	js     8019bc <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8019ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8019b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019bc:	c9                   	leave  
  8019bd:	c3                   	ret    

008019be <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8019be:	f3 0f 1e fb          	endbr32 
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	53                   	push   %ebx
  8019c6:	83 ec 1c             	sub    $0x1c,%esp
  8019c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019cf:	50                   	push   %eax
  8019d0:	53                   	push   %ebx
  8019d1:	e8 d7 fb ff ff       	call   8015ad <fd_lookup>
  8019d6:	83 c4 10             	add    $0x10,%esp
  8019d9:	85 c0                	test   %eax,%eax
  8019db:	78 37                	js     801a14 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019dd:	83 ec 08             	sub    $0x8,%esp
  8019e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e3:	50                   	push   %eax
  8019e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019e7:	ff 30                	pushl  (%eax)
  8019e9:	e8 13 fc ff ff       	call   801601 <dev_lookup>
  8019ee:	83 c4 10             	add    $0x10,%esp
  8019f1:	85 c0                	test   %eax,%eax
  8019f3:	78 1f                	js     801a14 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019f8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019fc:	74 1b                	je     801a19 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8019fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a01:	8b 52 18             	mov    0x18(%edx),%edx
  801a04:	85 d2                	test   %edx,%edx
  801a06:	74 32                	je     801a3a <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801a08:	83 ec 08             	sub    $0x8,%esp
  801a0b:	ff 75 0c             	pushl  0xc(%ebp)
  801a0e:	50                   	push   %eax
  801a0f:	ff d2                	call   *%edx
  801a11:	83 c4 10             	add    $0x10,%esp
}
  801a14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a17:	c9                   	leave  
  801a18:	c3                   	ret    
			thisenv->env_id, fdnum);
  801a19:	a1 1c 50 80 00       	mov    0x80501c,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801a1e:	8b 40 48             	mov    0x48(%eax),%eax
  801a21:	83 ec 04             	sub    $0x4,%esp
  801a24:	53                   	push   %ebx
  801a25:	50                   	push   %eax
  801a26:	68 c0 32 80 00       	push   $0x8032c0
  801a2b:	e8 ee ee ff ff       	call   80091e <cprintf>
		return -E_INVAL;
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a38:	eb da                	jmp    801a14 <ftruncate+0x56>
		return -E_NOT_SUPP;
  801a3a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a3f:	eb d3                	jmp    801a14 <ftruncate+0x56>

00801a41 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a41:	f3 0f 1e fb          	endbr32 
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	53                   	push   %ebx
  801a49:	83 ec 1c             	sub    $0x1c,%esp
  801a4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a4f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a52:	50                   	push   %eax
  801a53:	ff 75 08             	pushl  0x8(%ebp)
  801a56:	e8 52 fb ff ff       	call   8015ad <fd_lookup>
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	78 4b                	js     801aad <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a62:	83 ec 08             	sub    $0x8,%esp
  801a65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a68:	50                   	push   %eax
  801a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a6c:	ff 30                	pushl  (%eax)
  801a6e:	e8 8e fb ff ff       	call   801601 <dev_lookup>
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	85 c0                	test   %eax,%eax
  801a78:	78 33                	js     801aad <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a7d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a81:	74 2f                	je     801ab2 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a83:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a86:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a8d:	00 00 00 
	stat->st_isdir = 0;
  801a90:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a97:	00 00 00 
	stat->st_dev = dev;
  801a9a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801aa0:	83 ec 08             	sub    $0x8,%esp
  801aa3:	53                   	push   %ebx
  801aa4:	ff 75 f0             	pushl  -0x10(%ebp)
  801aa7:	ff 50 14             	call   *0x14(%eax)
  801aaa:	83 c4 10             	add    $0x10,%esp
}
  801aad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab0:	c9                   	leave  
  801ab1:	c3                   	ret    
		return -E_NOT_SUPP;
  801ab2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801ab7:	eb f4                	jmp    801aad <fstat+0x6c>

00801ab9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801ab9:	f3 0f 1e fb          	endbr32 
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	56                   	push   %esi
  801ac1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801ac2:	83 ec 08             	sub    $0x8,%esp
  801ac5:	6a 00                	push   $0x0
  801ac7:	ff 75 08             	pushl  0x8(%ebp)
  801aca:	e8 01 02 00 00       	call   801cd0 <open>
  801acf:	89 c3                	mov    %eax,%ebx
  801ad1:	83 c4 10             	add    $0x10,%esp
  801ad4:	85 c0                	test   %eax,%eax
  801ad6:	78 1b                	js     801af3 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801ad8:	83 ec 08             	sub    $0x8,%esp
  801adb:	ff 75 0c             	pushl  0xc(%ebp)
  801ade:	50                   	push   %eax
  801adf:	e8 5d ff ff ff       	call   801a41 <fstat>
  801ae4:	89 c6                	mov    %eax,%esi
	close(fd);
  801ae6:	89 1c 24             	mov    %ebx,(%esp)
  801ae9:	e8 fd fb ff ff       	call   8016eb <close>
	return r;
  801aee:	83 c4 10             	add    $0x10,%esp
  801af1:	89 f3                	mov    %esi,%ebx
}
  801af3:	89 d8                	mov    %ebx,%eax
  801af5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af8:	5b                   	pop    %ebx
  801af9:	5e                   	pop    %esi
  801afa:	5d                   	pop    %ebp
  801afb:	c3                   	ret    

00801afc <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	56                   	push   %esi
  801b00:	53                   	push   %ebx
  801b01:	89 c6                	mov    %eax,%esi
  801b03:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801b05:	83 3d 10 50 80 00 00 	cmpl   $0x0,0x805010
  801b0c:	74 27                	je     801b35 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b0e:	6a 07                	push   $0x7
  801b10:	68 00 60 80 00       	push   $0x806000
  801b15:	56                   	push   %esi
  801b16:	ff 35 10 50 80 00    	pushl  0x805010
  801b1c:	e8 21 0f 00 00       	call   802a42 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b21:	83 c4 0c             	add    $0xc,%esp
  801b24:	6a 00                	push   $0x0
  801b26:	53                   	push   %ebx
  801b27:	6a 00                	push   $0x0
  801b29:	e8 a7 0e 00 00       	call   8029d5 <ipc_recv>
}
  801b2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b31:	5b                   	pop    %ebx
  801b32:	5e                   	pop    %esi
  801b33:	5d                   	pop    %ebp
  801b34:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b35:	83 ec 0c             	sub    $0xc,%esp
  801b38:	6a 01                	push   $0x1
  801b3a:	e8 5b 0f 00 00       	call   802a9a <ipc_find_env>
  801b3f:	a3 10 50 80 00       	mov    %eax,0x805010
  801b44:	83 c4 10             	add    $0x10,%esp
  801b47:	eb c5                	jmp    801b0e <fsipc+0x12>

00801b49 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b49:	f3 0f 1e fb          	endbr32 
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b53:	8b 45 08             	mov    0x8(%ebp),%eax
  801b56:	8b 40 0c             	mov    0xc(%eax),%eax
  801b59:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b61:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b66:	ba 00 00 00 00       	mov    $0x0,%edx
  801b6b:	b8 02 00 00 00       	mov    $0x2,%eax
  801b70:	e8 87 ff ff ff       	call   801afc <fsipc>
}
  801b75:	c9                   	leave  
  801b76:	c3                   	ret    

00801b77 <devfile_flush>:
{
  801b77:	f3 0f 1e fb          	endbr32 
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b81:	8b 45 08             	mov    0x8(%ebp),%eax
  801b84:	8b 40 0c             	mov    0xc(%eax),%eax
  801b87:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b8c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b91:	b8 06 00 00 00       	mov    $0x6,%eax
  801b96:	e8 61 ff ff ff       	call   801afc <fsipc>
}
  801b9b:	c9                   	leave  
  801b9c:	c3                   	ret    

00801b9d <devfile_stat>:
{
  801b9d:	f3 0f 1e fb          	endbr32 
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	53                   	push   %ebx
  801ba5:	83 ec 04             	sub    $0x4,%esp
  801ba8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801bab:	8b 45 08             	mov    0x8(%ebp),%eax
  801bae:	8b 40 0c             	mov    0xc(%eax),%eax
  801bb1:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801bb6:	ba 00 00 00 00       	mov    $0x0,%edx
  801bbb:	b8 05 00 00 00       	mov    $0x5,%eax
  801bc0:	e8 37 ff ff ff       	call   801afc <fsipc>
  801bc5:	85 c0                	test   %eax,%eax
  801bc7:	78 2c                	js     801bf5 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801bc9:	83 ec 08             	sub    $0x8,%esp
  801bcc:	68 00 60 80 00       	push   $0x806000
  801bd1:	53                   	push   %ebx
  801bd2:	e8 51 f3 ff ff       	call   800f28 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801bd7:	a1 80 60 80 00       	mov    0x806080,%eax
  801bdc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801be2:	a1 84 60 80 00       	mov    0x806084,%eax
  801be7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801bed:	83 c4 10             	add    $0x10,%esp
  801bf0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bf5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf8:	c9                   	leave  
  801bf9:	c3                   	ret    

00801bfa <devfile_write>:
{
  801bfa:	f3 0f 1e fb          	endbr32 
  801bfe:	55                   	push   %ebp
  801bff:	89 e5                	mov    %esp,%ebp
  801c01:	83 ec 0c             	sub    $0xc,%esp
  801c04:	8b 45 10             	mov    0x10(%ebp),%eax
  801c07:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801c0c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801c11:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801c14:	8b 55 08             	mov    0x8(%ebp),%edx
  801c17:	8b 52 0c             	mov    0xc(%edx),%edx
  801c1a:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801c20:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801c25:	50                   	push   %eax
  801c26:	ff 75 0c             	pushl  0xc(%ebp)
  801c29:	68 08 60 80 00       	push   $0x806008
  801c2e:	e8 f3 f4 ff ff       	call   801126 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801c33:	ba 00 00 00 00       	mov    $0x0,%edx
  801c38:	b8 04 00 00 00       	mov    $0x4,%eax
  801c3d:	e8 ba fe ff ff       	call   801afc <fsipc>
}
  801c42:	c9                   	leave  
  801c43:	c3                   	ret    

00801c44 <devfile_read>:
{
  801c44:	f3 0f 1e fb          	endbr32 
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	56                   	push   %esi
  801c4c:	53                   	push   %ebx
  801c4d:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c50:	8b 45 08             	mov    0x8(%ebp),%eax
  801c53:	8b 40 0c             	mov    0xc(%eax),%eax
  801c56:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801c5b:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c61:	ba 00 00 00 00       	mov    $0x0,%edx
  801c66:	b8 03 00 00 00       	mov    $0x3,%eax
  801c6b:	e8 8c fe ff ff       	call   801afc <fsipc>
  801c70:	89 c3                	mov    %eax,%ebx
  801c72:	85 c0                	test   %eax,%eax
  801c74:	78 1f                	js     801c95 <devfile_read+0x51>
	assert(r <= n);
  801c76:	39 f0                	cmp    %esi,%eax
  801c78:	77 24                	ja     801c9e <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801c7a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c7f:	7f 36                	jg     801cb7 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c81:	83 ec 04             	sub    $0x4,%esp
  801c84:	50                   	push   %eax
  801c85:	68 00 60 80 00       	push   $0x806000
  801c8a:	ff 75 0c             	pushl  0xc(%ebp)
  801c8d:	e8 94 f4 ff ff       	call   801126 <memmove>
	return r;
  801c92:	83 c4 10             	add    $0x10,%esp
}
  801c95:	89 d8                	mov    %ebx,%eax
  801c97:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c9a:	5b                   	pop    %ebx
  801c9b:	5e                   	pop    %esi
  801c9c:	5d                   	pop    %ebp
  801c9d:	c3                   	ret    
	assert(r <= n);
  801c9e:	68 30 33 80 00       	push   $0x803330
  801ca3:	68 37 33 80 00       	push   $0x803337
  801ca8:	68 8c 00 00 00       	push   $0x8c
  801cad:	68 4c 33 80 00       	push   $0x80334c
  801cb2:	e8 80 eb ff ff       	call   800837 <_panic>
	assert(r <= PGSIZE);
  801cb7:	68 57 33 80 00       	push   $0x803357
  801cbc:	68 37 33 80 00       	push   $0x803337
  801cc1:	68 8d 00 00 00       	push   $0x8d
  801cc6:	68 4c 33 80 00       	push   $0x80334c
  801ccb:	e8 67 eb ff ff       	call   800837 <_panic>

00801cd0 <open>:
{
  801cd0:	f3 0f 1e fb          	endbr32 
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
  801cd7:	56                   	push   %esi
  801cd8:	53                   	push   %ebx
  801cd9:	83 ec 1c             	sub    $0x1c,%esp
  801cdc:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801cdf:	56                   	push   %esi
  801ce0:	e8 00 f2 ff ff       	call   800ee5 <strlen>
  801ce5:	83 c4 10             	add    $0x10,%esp
  801ce8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ced:	7f 6c                	jg     801d5b <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801cef:	83 ec 0c             	sub    $0xc,%esp
  801cf2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf5:	50                   	push   %eax
  801cf6:	e8 5c f8 ff ff       	call   801557 <fd_alloc>
  801cfb:	89 c3                	mov    %eax,%ebx
  801cfd:	83 c4 10             	add    $0x10,%esp
  801d00:	85 c0                	test   %eax,%eax
  801d02:	78 3c                	js     801d40 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801d04:	83 ec 08             	sub    $0x8,%esp
  801d07:	56                   	push   %esi
  801d08:	68 00 60 80 00       	push   $0x806000
  801d0d:	e8 16 f2 ff ff       	call   800f28 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801d12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d15:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d1d:	b8 01 00 00 00       	mov    $0x1,%eax
  801d22:	e8 d5 fd ff ff       	call   801afc <fsipc>
  801d27:	89 c3                	mov    %eax,%ebx
  801d29:	83 c4 10             	add    $0x10,%esp
  801d2c:	85 c0                	test   %eax,%eax
  801d2e:	78 19                	js     801d49 <open+0x79>
	return fd2num(fd);
  801d30:	83 ec 0c             	sub    $0xc,%esp
  801d33:	ff 75 f4             	pushl  -0xc(%ebp)
  801d36:	e8 ed f7 ff ff       	call   801528 <fd2num>
  801d3b:	89 c3                	mov    %eax,%ebx
  801d3d:	83 c4 10             	add    $0x10,%esp
}
  801d40:	89 d8                	mov    %ebx,%eax
  801d42:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d45:	5b                   	pop    %ebx
  801d46:	5e                   	pop    %esi
  801d47:	5d                   	pop    %ebp
  801d48:	c3                   	ret    
		fd_close(fd, 0);
  801d49:	83 ec 08             	sub    $0x8,%esp
  801d4c:	6a 00                	push   $0x0
  801d4e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d51:	e8 0a f9 ff ff       	call   801660 <fd_close>
		return r;
  801d56:	83 c4 10             	add    $0x10,%esp
  801d59:	eb e5                	jmp    801d40 <open+0x70>
		return -E_BAD_PATH;
  801d5b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801d60:	eb de                	jmp    801d40 <open+0x70>

00801d62 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d62:	f3 0f 1e fb          	endbr32 
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
  801d69:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d6c:	ba 00 00 00 00       	mov    $0x0,%edx
  801d71:	b8 08 00 00 00       	mov    $0x8,%eax
  801d76:	e8 81 fd ff ff       	call   801afc <fsipc>
}
  801d7b:	c9                   	leave  
  801d7c:	c3                   	ret    

00801d7d <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d7d:	f3 0f 1e fb          	endbr32 
  801d81:	55                   	push   %ebp
  801d82:	89 e5                	mov    %esp,%ebp
  801d84:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801d87:	68 c3 33 80 00       	push   $0x8033c3
  801d8c:	ff 75 0c             	pushl  0xc(%ebp)
  801d8f:	e8 94 f1 ff ff       	call   800f28 <strcpy>
	return 0;
}
  801d94:	b8 00 00 00 00       	mov    $0x0,%eax
  801d99:	c9                   	leave  
  801d9a:	c3                   	ret    

00801d9b <devsock_close>:
{
  801d9b:	f3 0f 1e fb          	endbr32 
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
  801da2:	53                   	push   %ebx
  801da3:	83 ec 10             	sub    $0x10,%esp
  801da6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801da9:	53                   	push   %ebx
  801daa:	e8 28 0d 00 00       	call   802ad7 <pageref>
  801daf:	89 c2                	mov    %eax,%edx
  801db1:	83 c4 10             	add    $0x10,%esp
		return 0;
  801db4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801db9:	83 fa 01             	cmp    $0x1,%edx
  801dbc:	74 05                	je     801dc3 <devsock_close+0x28>
}
  801dbe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dc1:	c9                   	leave  
  801dc2:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801dc3:	83 ec 0c             	sub    $0xc,%esp
  801dc6:	ff 73 0c             	pushl  0xc(%ebx)
  801dc9:	e8 e3 02 00 00       	call   8020b1 <nsipc_close>
  801dce:	83 c4 10             	add    $0x10,%esp
  801dd1:	eb eb                	jmp    801dbe <devsock_close+0x23>

00801dd3 <devsock_write>:
{
  801dd3:	f3 0f 1e fb          	endbr32 
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ddd:	6a 00                	push   $0x0
  801ddf:	ff 75 10             	pushl  0x10(%ebp)
  801de2:	ff 75 0c             	pushl  0xc(%ebp)
  801de5:	8b 45 08             	mov    0x8(%ebp),%eax
  801de8:	ff 70 0c             	pushl  0xc(%eax)
  801deb:	e8 b5 03 00 00       	call   8021a5 <nsipc_send>
}
  801df0:	c9                   	leave  
  801df1:	c3                   	ret    

00801df2 <devsock_read>:
{
  801df2:	f3 0f 1e fb          	endbr32 
  801df6:	55                   	push   %ebp
  801df7:	89 e5                	mov    %esp,%ebp
  801df9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801dfc:	6a 00                	push   $0x0
  801dfe:	ff 75 10             	pushl  0x10(%ebp)
  801e01:	ff 75 0c             	pushl  0xc(%ebp)
  801e04:	8b 45 08             	mov    0x8(%ebp),%eax
  801e07:	ff 70 0c             	pushl  0xc(%eax)
  801e0a:	e8 1f 03 00 00       	call   80212e <nsipc_recv>
}
  801e0f:	c9                   	leave  
  801e10:	c3                   	ret    

00801e11 <fd2sockid>:
{
  801e11:	55                   	push   %ebp
  801e12:	89 e5                	mov    %esp,%ebp
  801e14:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801e17:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801e1a:	52                   	push   %edx
  801e1b:	50                   	push   %eax
  801e1c:	e8 8c f7 ff ff       	call   8015ad <fd_lookup>
  801e21:	83 c4 10             	add    $0x10,%esp
  801e24:	85 c0                	test   %eax,%eax
  801e26:	78 10                	js     801e38 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2b:	8b 0d 80 40 80 00    	mov    0x804080,%ecx
  801e31:	39 08                	cmp    %ecx,(%eax)
  801e33:	75 05                	jne    801e3a <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801e35:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801e38:	c9                   	leave  
  801e39:	c3                   	ret    
		return -E_NOT_SUPP;
  801e3a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801e3f:	eb f7                	jmp    801e38 <fd2sockid+0x27>

00801e41 <alloc_sockfd>:
{
  801e41:	55                   	push   %ebp
  801e42:	89 e5                	mov    %esp,%ebp
  801e44:	56                   	push   %esi
  801e45:	53                   	push   %ebx
  801e46:	83 ec 1c             	sub    $0x1c,%esp
  801e49:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801e4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e4e:	50                   	push   %eax
  801e4f:	e8 03 f7 ff ff       	call   801557 <fd_alloc>
  801e54:	89 c3                	mov    %eax,%ebx
  801e56:	83 c4 10             	add    $0x10,%esp
  801e59:	85 c0                	test   %eax,%eax
  801e5b:	78 43                	js     801ea0 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801e5d:	83 ec 04             	sub    $0x4,%esp
  801e60:	68 07 04 00 00       	push   $0x407
  801e65:	ff 75 f4             	pushl  -0xc(%ebp)
  801e68:	6a 00                	push   $0x0
  801e6a:	e8 22 f5 ff ff       	call   801391 <sys_page_alloc>
  801e6f:	89 c3                	mov    %eax,%ebx
  801e71:	83 c4 10             	add    $0x10,%esp
  801e74:	85 c0                	test   %eax,%eax
  801e76:	78 28                	js     801ea0 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7b:	8b 15 80 40 80 00    	mov    0x804080,%edx
  801e81:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e86:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801e8d:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801e90:	83 ec 0c             	sub    $0xc,%esp
  801e93:	50                   	push   %eax
  801e94:	e8 8f f6 ff ff       	call   801528 <fd2num>
  801e99:	89 c3                	mov    %eax,%ebx
  801e9b:	83 c4 10             	add    $0x10,%esp
  801e9e:	eb 0c                	jmp    801eac <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801ea0:	83 ec 0c             	sub    $0xc,%esp
  801ea3:	56                   	push   %esi
  801ea4:	e8 08 02 00 00       	call   8020b1 <nsipc_close>
		return r;
  801ea9:	83 c4 10             	add    $0x10,%esp
}
  801eac:	89 d8                	mov    %ebx,%eax
  801eae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb1:	5b                   	pop    %ebx
  801eb2:	5e                   	pop    %esi
  801eb3:	5d                   	pop    %ebp
  801eb4:	c3                   	ret    

00801eb5 <accept>:
{
  801eb5:	f3 0f 1e fb          	endbr32 
  801eb9:	55                   	push   %ebp
  801eba:	89 e5                	mov    %esp,%ebp
  801ebc:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ebf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec2:	e8 4a ff ff ff       	call   801e11 <fd2sockid>
  801ec7:	85 c0                	test   %eax,%eax
  801ec9:	78 1b                	js     801ee6 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ecb:	83 ec 04             	sub    $0x4,%esp
  801ece:	ff 75 10             	pushl  0x10(%ebp)
  801ed1:	ff 75 0c             	pushl  0xc(%ebp)
  801ed4:	50                   	push   %eax
  801ed5:	e8 22 01 00 00       	call   801ffc <nsipc_accept>
  801eda:	83 c4 10             	add    $0x10,%esp
  801edd:	85 c0                	test   %eax,%eax
  801edf:	78 05                	js     801ee6 <accept+0x31>
	return alloc_sockfd(r);
  801ee1:	e8 5b ff ff ff       	call   801e41 <alloc_sockfd>
}
  801ee6:	c9                   	leave  
  801ee7:	c3                   	ret    

00801ee8 <bind>:
{
  801ee8:	f3 0f 1e fb          	endbr32 
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ef2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef5:	e8 17 ff ff ff       	call   801e11 <fd2sockid>
  801efa:	85 c0                	test   %eax,%eax
  801efc:	78 12                	js     801f10 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801efe:	83 ec 04             	sub    $0x4,%esp
  801f01:	ff 75 10             	pushl  0x10(%ebp)
  801f04:	ff 75 0c             	pushl  0xc(%ebp)
  801f07:	50                   	push   %eax
  801f08:	e8 45 01 00 00       	call   802052 <nsipc_bind>
  801f0d:	83 c4 10             	add    $0x10,%esp
}
  801f10:	c9                   	leave  
  801f11:	c3                   	ret    

00801f12 <shutdown>:
{
  801f12:	f3 0f 1e fb          	endbr32 
  801f16:	55                   	push   %ebp
  801f17:	89 e5                	mov    %esp,%ebp
  801f19:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801f1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1f:	e8 ed fe ff ff       	call   801e11 <fd2sockid>
  801f24:	85 c0                	test   %eax,%eax
  801f26:	78 0f                	js     801f37 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801f28:	83 ec 08             	sub    $0x8,%esp
  801f2b:	ff 75 0c             	pushl  0xc(%ebp)
  801f2e:	50                   	push   %eax
  801f2f:	e8 57 01 00 00       	call   80208b <nsipc_shutdown>
  801f34:	83 c4 10             	add    $0x10,%esp
}
  801f37:	c9                   	leave  
  801f38:	c3                   	ret    

00801f39 <connect>:
{
  801f39:	f3 0f 1e fb          	endbr32 
  801f3d:	55                   	push   %ebp
  801f3e:	89 e5                	mov    %esp,%ebp
  801f40:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801f43:	8b 45 08             	mov    0x8(%ebp),%eax
  801f46:	e8 c6 fe ff ff       	call   801e11 <fd2sockid>
  801f4b:	85 c0                	test   %eax,%eax
  801f4d:	78 12                	js     801f61 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801f4f:	83 ec 04             	sub    $0x4,%esp
  801f52:	ff 75 10             	pushl  0x10(%ebp)
  801f55:	ff 75 0c             	pushl  0xc(%ebp)
  801f58:	50                   	push   %eax
  801f59:	e8 71 01 00 00       	call   8020cf <nsipc_connect>
  801f5e:	83 c4 10             	add    $0x10,%esp
}
  801f61:	c9                   	leave  
  801f62:	c3                   	ret    

00801f63 <listen>:
{
  801f63:	f3 0f 1e fb          	endbr32 
  801f67:	55                   	push   %ebp
  801f68:	89 e5                	mov    %esp,%ebp
  801f6a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801f6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f70:	e8 9c fe ff ff       	call   801e11 <fd2sockid>
  801f75:	85 c0                	test   %eax,%eax
  801f77:	78 0f                	js     801f88 <listen+0x25>
	return nsipc_listen(r, backlog);
  801f79:	83 ec 08             	sub    $0x8,%esp
  801f7c:	ff 75 0c             	pushl  0xc(%ebp)
  801f7f:	50                   	push   %eax
  801f80:	e8 83 01 00 00       	call   802108 <nsipc_listen>
  801f85:	83 c4 10             	add    $0x10,%esp
}
  801f88:	c9                   	leave  
  801f89:	c3                   	ret    

00801f8a <socket>:

int
socket(int domain, int type, int protocol)
{
  801f8a:	f3 0f 1e fb          	endbr32 
  801f8e:	55                   	push   %ebp
  801f8f:	89 e5                	mov    %esp,%ebp
  801f91:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f94:	ff 75 10             	pushl  0x10(%ebp)
  801f97:	ff 75 0c             	pushl  0xc(%ebp)
  801f9a:	ff 75 08             	pushl  0x8(%ebp)
  801f9d:	e8 65 02 00 00       	call   802207 <nsipc_socket>
  801fa2:	83 c4 10             	add    $0x10,%esp
  801fa5:	85 c0                	test   %eax,%eax
  801fa7:	78 05                	js     801fae <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801fa9:	e8 93 fe ff ff       	call   801e41 <alloc_sockfd>
}
  801fae:	c9                   	leave  
  801faf:	c3                   	ret    

00801fb0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 04             	sub    $0x4,%esp
  801fb7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801fb9:	83 3d 14 50 80 00 00 	cmpl   $0x0,0x805014
  801fc0:	74 26                	je     801fe8 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801fc2:	6a 07                	push   $0x7
  801fc4:	68 00 70 80 00       	push   $0x807000
  801fc9:	53                   	push   %ebx
  801fca:	ff 35 14 50 80 00    	pushl  0x805014
  801fd0:	e8 6d 0a 00 00       	call   802a42 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801fd5:	83 c4 0c             	add    $0xc,%esp
  801fd8:	6a 00                	push   $0x0
  801fda:	6a 00                	push   $0x0
  801fdc:	6a 00                	push   $0x0
  801fde:	e8 f2 09 00 00       	call   8029d5 <ipc_recv>
}
  801fe3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fe6:	c9                   	leave  
  801fe7:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801fe8:	83 ec 0c             	sub    $0xc,%esp
  801feb:	6a 02                	push   $0x2
  801fed:	e8 a8 0a 00 00       	call   802a9a <ipc_find_env>
  801ff2:	a3 14 50 80 00       	mov    %eax,0x805014
  801ff7:	83 c4 10             	add    $0x10,%esp
  801ffa:	eb c6                	jmp    801fc2 <nsipc+0x12>

00801ffc <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ffc:	f3 0f 1e fb          	endbr32 
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	56                   	push   %esi
  802004:	53                   	push   %ebx
  802005:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802008:	8b 45 08             	mov    0x8(%ebp),%eax
  80200b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802010:	8b 06                	mov    (%esi),%eax
  802012:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802017:	b8 01 00 00 00       	mov    $0x1,%eax
  80201c:	e8 8f ff ff ff       	call   801fb0 <nsipc>
  802021:	89 c3                	mov    %eax,%ebx
  802023:	85 c0                	test   %eax,%eax
  802025:	79 09                	jns    802030 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  802027:	89 d8                	mov    %ebx,%eax
  802029:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80202c:	5b                   	pop    %ebx
  80202d:	5e                   	pop    %esi
  80202e:	5d                   	pop    %ebp
  80202f:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802030:	83 ec 04             	sub    $0x4,%esp
  802033:	ff 35 10 70 80 00    	pushl  0x807010
  802039:	68 00 70 80 00       	push   $0x807000
  80203e:	ff 75 0c             	pushl  0xc(%ebp)
  802041:	e8 e0 f0 ff ff       	call   801126 <memmove>
		*addrlen = ret->ret_addrlen;
  802046:	a1 10 70 80 00       	mov    0x807010,%eax
  80204b:	89 06                	mov    %eax,(%esi)
  80204d:	83 c4 10             	add    $0x10,%esp
	return r;
  802050:	eb d5                	jmp    802027 <nsipc_accept+0x2b>

00802052 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802052:	f3 0f 1e fb          	endbr32 
  802056:	55                   	push   %ebp
  802057:	89 e5                	mov    %esp,%ebp
  802059:	53                   	push   %ebx
  80205a:	83 ec 08             	sub    $0x8,%esp
  80205d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802060:	8b 45 08             	mov    0x8(%ebp),%eax
  802063:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802068:	53                   	push   %ebx
  802069:	ff 75 0c             	pushl  0xc(%ebp)
  80206c:	68 04 70 80 00       	push   $0x807004
  802071:	e8 b0 f0 ff ff       	call   801126 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802076:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80207c:	b8 02 00 00 00       	mov    $0x2,%eax
  802081:	e8 2a ff ff ff       	call   801fb0 <nsipc>
}
  802086:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802089:	c9                   	leave  
  80208a:	c3                   	ret    

0080208b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80208b:	f3 0f 1e fb          	endbr32 
  80208f:	55                   	push   %ebp
  802090:	89 e5                	mov    %esp,%ebp
  802092:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802095:	8b 45 08             	mov    0x8(%ebp),%eax
  802098:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80209d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020a0:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8020a5:	b8 03 00 00 00       	mov    $0x3,%eax
  8020aa:	e8 01 ff ff ff       	call   801fb0 <nsipc>
}
  8020af:	c9                   	leave  
  8020b0:	c3                   	ret    

008020b1 <nsipc_close>:

int
nsipc_close(int s)
{
  8020b1:	f3 0f 1e fb          	endbr32 
  8020b5:	55                   	push   %ebp
  8020b6:	89 e5                	mov    %esp,%ebp
  8020b8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8020bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020be:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8020c3:	b8 04 00 00 00       	mov    $0x4,%eax
  8020c8:	e8 e3 fe ff ff       	call   801fb0 <nsipc>
}
  8020cd:	c9                   	leave  
  8020ce:	c3                   	ret    

008020cf <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020cf:	f3 0f 1e fb          	endbr32 
  8020d3:	55                   	push   %ebp
  8020d4:	89 e5                	mov    %esp,%ebp
  8020d6:	53                   	push   %ebx
  8020d7:	83 ec 08             	sub    $0x8,%esp
  8020da:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8020dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e0:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8020e5:	53                   	push   %ebx
  8020e6:	ff 75 0c             	pushl  0xc(%ebp)
  8020e9:	68 04 70 80 00       	push   $0x807004
  8020ee:	e8 33 f0 ff ff       	call   801126 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8020f3:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8020f9:	b8 05 00 00 00       	mov    $0x5,%eax
  8020fe:	e8 ad fe ff ff       	call   801fb0 <nsipc>
}
  802103:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802106:	c9                   	leave  
  802107:	c3                   	ret    

00802108 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802108:	f3 0f 1e fb          	endbr32 
  80210c:	55                   	push   %ebp
  80210d:	89 e5                	mov    %esp,%ebp
  80210f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802112:	8b 45 08             	mov    0x8(%ebp),%eax
  802115:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80211a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80211d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802122:	b8 06 00 00 00       	mov    $0x6,%eax
  802127:	e8 84 fe ff ff       	call   801fb0 <nsipc>
}
  80212c:	c9                   	leave  
  80212d:	c3                   	ret    

0080212e <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80212e:	f3 0f 1e fb          	endbr32 
  802132:	55                   	push   %ebp
  802133:	89 e5                	mov    %esp,%ebp
  802135:	56                   	push   %esi
  802136:	53                   	push   %ebx
  802137:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80213a:	8b 45 08             	mov    0x8(%ebp),%eax
  80213d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802142:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802148:	8b 45 14             	mov    0x14(%ebp),%eax
  80214b:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802150:	b8 07 00 00 00       	mov    $0x7,%eax
  802155:	e8 56 fe ff ff       	call   801fb0 <nsipc>
  80215a:	89 c3                	mov    %eax,%ebx
  80215c:	85 c0                	test   %eax,%eax
  80215e:	78 26                	js     802186 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  802160:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  802166:	b8 3f 06 00 00       	mov    $0x63f,%eax
  80216b:	0f 4e c6             	cmovle %esi,%eax
  80216e:	39 c3                	cmp    %eax,%ebx
  802170:	7f 1d                	jg     80218f <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802172:	83 ec 04             	sub    $0x4,%esp
  802175:	53                   	push   %ebx
  802176:	68 00 70 80 00       	push   $0x807000
  80217b:	ff 75 0c             	pushl  0xc(%ebp)
  80217e:	e8 a3 ef ff ff       	call   801126 <memmove>
  802183:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802186:	89 d8                	mov    %ebx,%eax
  802188:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80218b:	5b                   	pop    %ebx
  80218c:	5e                   	pop    %esi
  80218d:	5d                   	pop    %ebp
  80218e:	c3                   	ret    
		assert(r < 1600 && r <= len);
  80218f:	68 cf 33 80 00       	push   $0x8033cf
  802194:	68 37 33 80 00       	push   $0x803337
  802199:	6a 62                	push   $0x62
  80219b:	68 e4 33 80 00       	push   $0x8033e4
  8021a0:	e8 92 e6 ff ff       	call   800837 <_panic>

008021a5 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8021a5:	f3 0f 1e fb          	endbr32 
  8021a9:	55                   	push   %ebp
  8021aa:	89 e5                	mov    %esp,%ebp
  8021ac:	53                   	push   %ebx
  8021ad:	83 ec 04             	sub    $0x4,%esp
  8021b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8021b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b6:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8021bb:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8021c1:	7f 2e                	jg     8021f1 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8021c3:	83 ec 04             	sub    $0x4,%esp
  8021c6:	53                   	push   %ebx
  8021c7:	ff 75 0c             	pushl  0xc(%ebp)
  8021ca:	68 0c 70 80 00       	push   $0x80700c
  8021cf:	e8 52 ef ff ff       	call   801126 <memmove>
	nsipcbuf.send.req_size = size;
  8021d4:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8021da:	8b 45 14             	mov    0x14(%ebp),%eax
  8021dd:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8021e2:	b8 08 00 00 00       	mov    $0x8,%eax
  8021e7:	e8 c4 fd ff ff       	call   801fb0 <nsipc>
}
  8021ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021ef:	c9                   	leave  
  8021f0:	c3                   	ret    
	assert(size < 1600);
  8021f1:	68 f0 33 80 00       	push   $0x8033f0
  8021f6:	68 37 33 80 00       	push   $0x803337
  8021fb:	6a 6d                	push   $0x6d
  8021fd:	68 e4 33 80 00       	push   $0x8033e4
  802202:	e8 30 e6 ff ff       	call   800837 <_panic>

00802207 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802207:	f3 0f 1e fb          	endbr32 
  80220b:	55                   	push   %ebp
  80220c:	89 e5                	mov    %esp,%ebp
  80220e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802211:	8b 45 08             	mov    0x8(%ebp),%eax
  802214:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802219:	8b 45 0c             	mov    0xc(%ebp),%eax
  80221c:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802221:	8b 45 10             	mov    0x10(%ebp),%eax
  802224:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802229:	b8 09 00 00 00       	mov    $0x9,%eax
  80222e:	e8 7d fd ff ff       	call   801fb0 <nsipc>
}
  802233:	c9                   	leave  
  802234:	c3                   	ret    

00802235 <free>:
	return v;
}

void
free(void *v)
{
  802235:	f3 0f 1e fb          	endbr32 
  802239:	55                   	push   %ebp
  80223a:	89 e5                	mov    %esp,%ebp
  80223c:	53                   	push   %ebx
  80223d:	83 ec 04             	sub    $0x4,%esp
  802240:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint8_t *c;
	uint32_t *ref;

	if (v == 0)
  802243:	85 db                	test   %ebx,%ebx
  802245:	0f 84 85 00 00 00    	je     8022d0 <free+0x9b>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);
  80224b:	8d 83 00 00 00 f8    	lea    -0x8000000(%ebx),%eax
  802251:	3d ff ff ff 07       	cmp    $0x7ffffff,%eax
  802256:	77 51                	ja     8022a9 <free+0x74>

	c = ROUNDDOWN(v, PGSIZE);
  802258:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  80225e:	89 d8                	mov    %ebx,%eax
  802260:	c1 e8 0c             	shr    $0xc,%eax
  802263:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80226a:	f6 c4 02             	test   $0x2,%ah
  80226d:	74 50                	je     8022bf <free+0x8a>
		sys_page_unmap(0, c);
  80226f:	83 ec 08             	sub    $0x8,%esp
  802272:	53                   	push   %ebx
  802273:	6a 00                	push   $0x0
  802275:	e8 62 f1 ff ff       	call   8013dc <sys_page_unmap>
		c += PGSIZE;
  80227a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(mbegin <= c && c < mend);
  802280:	8d 83 00 00 00 f8    	lea    -0x8000000(%ebx),%eax
  802286:	83 c4 10             	add    $0x10,%esp
  802289:	3d ff ff ff 07       	cmp    $0x7ffffff,%eax
  80228e:	76 ce                	jbe    80225e <free+0x29>
  802290:	68 37 34 80 00       	push   $0x803437
  802295:	68 37 33 80 00       	push   $0x803337
  80229a:	68 81 00 00 00       	push   $0x81
  80229f:	68 2a 34 80 00       	push   $0x80342a
  8022a4:	e8 8e e5 ff ff       	call   800837 <_panic>
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);
  8022a9:	68 fc 33 80 00       	push   $0x8033fc
  8022ae:	68 37 33 80 00       	push   $0x803337
  8022b3:	6a 7a                	push   $0x7a
  8022b5:	68 2a 34 80 00       	push   $0x80342a
  8022ba:	e8 78 e5 ff ff       	call   800837 <_panic>
	/*
	 * c is just a piece of this page, so dec the ref count
	 * and maybe free the page.
	 */
	ref = (uint32_t*) (c + PGSIZE - 4);
	if (--(*ref) == 0)
  8022bf:	8b 83 fc 0f 00 00    	mov    0xffc(%ebx),%eax
  8022c5:	83 e8 01             	sub    $0x1,%eax
  8022c8:	89 83 fc 0f 00 00    	mov    %eax,0xffc(%ebx)
  8022ce:	74 05                	je     8022d5 <free+0xa0>
		sys_page_unmap(0, c);
}
  8022d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022d3:	c9                   	leave  
  8022d4:	c3                   	ret    
		sys_page_unmap(0, c);
  8022d5:	83 ec 08             	sub    $0x8,%esp
  8022d8:	53                   	push   %ebx
  8022d9:	6a 00                	push   $0x0
  8022db:	e8 fc f0 ff ff       	call   8013dc <sys_page_unmap>
  8022e0:	83 c4 10             	add    $0x10,%esp
  8022e3:	eb eb                	jmp    8022d0 <free+0x9b>

008022e5 <malloc>:
{
  8022e5:	f3 0f 1e fb          	endbr32 
  8022e9:	55                   	push   %ebp
  8022ea:	89 e5                	mov    %esp,%ebp
  8022ec:	57                   	push   %edi
  8022ed:	56                   	push   %esi
  8022ee:	53                   	push   %ebx
  8022ef:	83 ec 1c             	sub    $0x1c,%esp
	if (mptr == 0)
  8022f2:	a1 18 50 80 00       	mov    0x805018,%eax
  8022f7:	85 c0                	test   %eax,%eax
  8022f9:	74 74                	je     80236f <malloc+0x8a>
	n = ROUNDUP(n, 4);
  8022fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022fe:	8d 51 03             	lea    0x3(%ecx),%edx
  802301:	83 e2 fc             	and    $0xfffffffc,%edx
  802304:	89 d6                	mov    %edx,%esi
  802306:	89 55 dc             	mov    %edx,-0x24(%ebp)
	if (n >= MAXMALLOC)
  802309:	81 fa ff ff 0f 00    	cmp    $0xfffff,%edx
  80230f:	0f 87 12 01 00 00    	ja     802427 <malloc+0x142>
	if ((uintptr_t) mptr % PGSIZE){
  802315:	89 c1                	mov    %eax,%ecx
  802317:	a9 ff 0f 00 00       	test   $0xfff,%eax
  80231c:	74 30                	je     80234e <malloc+0x69>
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
  80231e:	89 c3                	mov    %eax,%ebx
  802320:	c1 eb 0c             	shr    $0xc,%ebx
  802323:	8d 54 10 03          	lea    0x3(%eax,%edx,1),%edx
  802327:	c1 ea 0c             	shr    $0xc,%edx
  80232a:	39 d3                	cmp    %edx,%ebx
  80232c:	74 64                	je     802392 <malloc+0xad>
		free(mptr);	/* drop reference to this page */
  80232e:	83 ec 0c             	sub    $0xc,%esp
  802331:	50                   	push   %eax
  802332:	e8 fe fe ff ff       	call   802235 <free>
		mptr = ROUNDDOWN(mptr + PGSIZE, PGSIZE);
  802337:	a1 18 50 80 00       	mov    0x805018,%eax
  80233c:	05 00 10 00 00       	add    $0x1000,%eax
  802341:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802346:	a3 18 50 80 00       	mov    %eax,0x805018
  80234b:	83 c4 10             	add    $0x10,%esp
  80234e:	8b 15 18 50 80 00    	mov    0x805018,%edx
{
  802354:	c7 45 d8 02 00 00 00 	movl   $0x2,-0x28(%ebp)
  80235b:	be 00 00 00 00       	mov    $0x0,%esi
		if (isfree(mptr, n + 4))
  802360:	8b 45 dc             	mov    -0x24(%ebp),%eax
  802363:	8d 78 04             	lea    0x4(%eax),%edi
  802366:	c6 45 e3 01          	movb   $0x1,-0x1d(%ebp)
  80236a:	e9 86 00 00 00       	jmp    8023f5 <malloc+0x110>
		mptr = mbegin;
  80236f:	c7 05 18 50 80 00 00 	movl   $0x8000000,0x805018
  802376:	00 00 08 
	n = ROUNDUP(n, 4);
  802379:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80237c:	8d 51 03             	lea    0x3(%ecx),%edx
  80237f:	83 e2 fc             	and    $0xfffffffc,%edx
  802382:	89 55 dc             	mov    %edx,-0x24(%ebp)
	if (n >= MAXMALLOC)
  802385:	81 fa ff ff 0f 00    	cmp    $0xfffff,%edx
  80238b:	76 c1                	jbe    80234e <malloc+0x69>
  80238d:	e9 fb 00 00 00       	jmp    80248d <malloc+0x1a8>
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
  802392:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
  802398:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
			(*ref)++;
  80239e:	83 41 fc 01          	addl   $0x1,-0x4(%ecx)
			mptr += n;
  8023a2:	89 f2                	mov    %esi,%edx
  8023a4:	01 c2                	add    %eax,%edx
  8023a6:	89 15 18 50 80 00    	mov    %edx,0x805018
			return v;
  8023ac:	e9 dc 00 00 00       	jmp    80248d <malloc+0x1a8>
	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  8023b1:	05 00 10 00 00       	add    $0x1000,%eax
  8023b6:	39 c1                	cmp    %eax,%ecx
  8023b8:	76 74                	jbe    80242e <malloc+0x149>
		if (va >= (uintptr_t) mend
  8023ba:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
  8023bf:	77 22                	ja     8023e3 <malloc+0xfe>
		    || ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)))
  8023c1:	89 c3                	mov    %eax,%ebx
  8023c3:	c1 eb 16             	shr    $0x16,%ebx
  8023c6:	8b 1c 9d 00 d0 7b ef 	mov    -0x10843000(,%ebx,4),%ebx
  8023cd:	f6 c3 01             	test   $0x1,%bl
  8023d0:	74 df                	je     8023b1 <malloc+0xcc>
  8023d2:	89 c3                	mov    %eax,%ebx
  8023d4:	c1 eb 0c             	shr    $0xc,%ebx
  8023d7:	8b 1c 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%ebx
  8023de:	f6 c3 01             	test   $0x1,%bl
  8023e1:	74 ce                	je     8023b1 <malloc+0xcc>
  8023e3:	81 c2 00 10 00 00    	add    $0x1000,%edx
  8023e9:	0f b6 75 e3          	movzbl -0x1d(%ebp),%esi
		if (mptr == mend) {
  8023ed:	81 fa 00 00 00 10    	cmp    $0x10000000,%edx
  8023f3:	74 0a                	je     8023ff <malloc+0x11a>
  8023f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  8023f8:	89 d0                	mov    %edx,%eax
  8023fa:	8d 0c 17             	lea    (%edi,%edx,1),%ecx
  8023fd:	eb b7                	jmp    8023b6 <malloc+0xd1>
			mptr = mbegin;
  8023ff:	ba 00 00 00 08       	mov    $0x8000000,%edx
  802404:	be 01 00 00 00       	mov    $0x1,%esi
			if (++nwrap == 2)
  802409:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80240d:	75 e6                	jne    8023f5 <malloc+0x110>
  80240f:	c7 05 18 50 80 00 00 	movl   $0x8000000,0x805018
  802416:	00 00 08 
				return 0;	/* out of address space */
  802419:	b8 00 00 00 00       	mov    $0x0,%eax
  80241e:	eb 6d                	jmp    80248d <malloc+0x1a8>
			return 0;	/* out of physical memory */
  802420:	b8 00 00 00 00       	mov    $0x0,%eax
  802425:	eb 66                	jmp    80248d <malloc+0x1a8>
		return 0;
  802427:	b8 00 00 00 00       	mov    $0x0,%eax
  80242c:	eb 5f                	jmp    80248d <malloc+0x1a8>
  80242e:	89 f0                	mov    %esi,%eax
  802430:	84 c0                	test   %al,%al
  802432:	74 08                	je     80243c <malloc+0x157>
  802434:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802437:	a3 18 50 80 00       	mov    %eax,0x805018
	for (i = 0; i < n + 4; i += PGSIZE){
  80243c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802441:	89 de                	mov    %ebx,%esi
  802443:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  802446:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80244c:	39 df                	cmp    %ebx,%edi
  80244e:	76 45                	jbe    802495 <malloc+0x1b0>
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
  802450:	83 ec 04             	sub    $0x4,%esp
  802453:	68 07 02 00 00       	push   $0x207
  802458:	03 35 18 50 80 00    	add    0x805018,%esi
  80245e:	56                   	push   %esi
  80245f:	6a 00                	push   $0x0
  802461:	e8 2b ef ff ff       	call   801391 <sys_page_alloc>
  802466:	83 c4 10             	add    $0x10,%esp
  802469:	85 c0                	test   %eax,%eax
  80246b:	79 d4                	jns    802441 <malloc+0x15c>
  80246d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  802470:	eb 42                	jmp    8024b4 <malloc+0x1cf>
	ref = (uint32_t*) (mptr + i - 4);
  802472:	a1 18 50 80 00       	mov    0x805018,%eax
	*ref = 2;	/* reference for mptr, reference for returned block */
  802477:	c7 84 30 fc 0f 00 00 	movl   $0x2,0xffc(%eax,%esi,1)
  80247e:	02 00 00 00 
	mptr += n;
  802482:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802485:	01 c2                	add    %eax,%edx
  802487:	89 15 18 50 80 00    	mov    %edx,0x805018
}
  80248d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802490:	5b                   	pop    %ebx
  802491:	5e                   	pop    %esi
  802492:	5f                   	pop    %edi
  802493:	5d                   	pop    %ebp
  802494:	c3                   	ret    
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
  802495:	83 ec 04             	sub    $0x4,%esp
  802498:	6a 07                	push   $0x7
  80249a:	89 f0                	mov    %esi,%eax
  80249c:	03 05 18 50 80 00    	add    0x805018,%eax
  8024a2:	50                   	push   %eax
  8024a3:	6a 00                	push   $0x0
  8024a5:	e8 e7 ee ff ff       	call   801391 <sys_page_alloc>
  8024aa:	83 c4 10             	add    $0x10,%esp
  8024ad:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8024b0:	85 c0                	test   %eax,%eax
  8024b2:	79 be                	jns    802472 <malloc+0x18d>
			for (; i >= 0; i -= PGSIZE)
  8024b4:	85 db                	test   %ebx,%ebx
  8024b6:	0f 88 64 ff ff ff    	js     802420 <malloc+0x13b>
				sys_page_unmap(0, mptr + i);
  8024bc:	83 ec 08             	sub    $0x8,%esp
  8024bf:	89 d8                	mov    %ebx,%eax
  8024c1:	03 05 18 50 80 00    	add    0x805018,%eax
  8024c7:	50                   	push   %eax
  8024c8:	6a 00                	push   $0x0
  8024ca:	e8 0d ef ff ff       	call   8013dc <sys_page_unmap>
			for (; i >= 0; i -= PGSIZE)
  8024cf:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  8024d5:	83 c4 10             	add    $0x10,%esp
  8024d8:	eb da                	jmp    8024b4 <malloc+0x1cf>

008024da <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8024da:	f3 0f 1e fb          	endbr32 
  8024de:	55                   	push   %ebp
  8024df:	89 e5                	mov    %esp,%ebp
  8024e1:	56                   	push   %esi
  8024e2:	53                   	push   %ebx
  8024e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8024e6:	83 ec 0c             	sub    $0xc,%esp
  8024e9:	ff 75 08             	pushl  0x8(%ebp)
  8024ec:	e8 4b f0 ff ff       	call   80153c <fd2data>
  8024f1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8024f3:	83 c4 08             	add    $0x8,%esp
  8024f6:	68 4f 34 80 00       	push   $0x80344f
  8024fb:	53                   	push   %ebx
  8024fc:	e8 27 ea ff ff       	call   800f28 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802501:	8b 46 04             	mov    0x4(%esi),%eax
  802504:	2b 06                	sub    (%esi),%eax
  802506:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80250c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802513:	00 00 00 
	stat->st_dev = &devpipe;
  802516:	c7 83 88 00 00 00 9c 	movl   $0x80409c,0x88(%ebx)
  80251d:	40 80 00 
	return 0;
}
  802520:	b8 00 00 00 00       	mov    $0x0,%eax
  802525:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802528:	5b                   	pop    %ebx
  802529:	5e                   	pop    %esi
  80252a:	5d                   	pop    %ebp
  80252b:	c3                   	ret    

0080252c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80252c:	f3 0f 1e fb          	endbr32 
  802530:	55                   	push   %ebp
  802531:	89 e5                	mov    %esp,%ebp
  802533:	53                   	push   %ebx
  802534:	83 ec 0c             	sub    $0xc,%esp
  802537:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80253a:	53                   	push   %ebx
  80253b:	6a 00                	push   $0x0
  80253d:	e8 9a ee ff ff       	call   8013dc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802542:	89 1c 24             	mov    %ebx,(%esp)
  802545:	e8 f2 ef ff ff       	call   80153c <fd2data>
  80254a:	83 c4 08             	add    $0x8,%esp
  80254d:	50                   	push   %eax
  80254e:	6a 00                	push   $0x0
  802550:	e8 87 ee ff ff       	call   8013dc <sys_page_unmap>
}
  802555:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802558:	c9                   	leave  
  802559:	c3                   	ret    

0080255a <_pipeisclosed>:
{
  80255a:	55                   	push   %ebp
  80255b:	89 e5                	mov    %esp,%ebp
  80255d:	57                   	push   %edi
  80255e:	56                   	push   %esi
  80255f:	53                   	push   %ebx
  802560:	83 ec 1c             	sub    $0x1c,%esp
  802563:	89 c7                	mov    %eax,%edi
  802565:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802567:	a1 1c 50 80 00       	mov    0x80501c,%eax
  80256c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80256f:	83 ec 0c             	sub    $0xc,%esp
  802572:	57                   	push   %edi
  802573:	e8 5f 05 00 00       	call   802ad7 <pageref>
  802578:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80257b:	89 34 24             	mov    %esi,(%esp)
  80257e:	e8 54 05 00 00       	call   802ad7 <pageref>
		nn = thisenv->env_runs;
  802583:	8b 15 1c 50 80 00    	mov    0x80501c,%edx
  802589:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80258c:	83 c4 10             	add    $0x10,%esp
  80258f:	39 cb                	cmp    %ecx,%ebx
  802591:	74 1b                	je     8025ae <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802593:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802596:	75 cf                	jne    802567 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802598:	8b 42 58             	mov    0x58(%edx),%eax
  80259b:	6a 01                	push   $0x1
  80259d:	50                   	push   %eax
  80259e:	53                   	push   %ebx
  80259f:	68 56 34 80 00       	push   $0x803456
  8025a4:	e8 75 e3 ff ff       	call   80091e <cprintf>
  8025a9:	83 c4 10             	add    $0x10,%esp
  8025ac:	eb b9                	jmp    802567 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8025ae:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8025b1:	0f 94 c0             	sete   %al
  8025b4:	0f b6 c0             	movzbl %al,%eax
}
  8025b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025ba:	5b                   	pop    %ebx
  8025bb:	5e                   	pop    %esi
  8025bc:	5f                   	pop    %edi
  8025bd:	5d                   	pop    %ebp
  8025be:	c3                   	ret    

008025bf <devpipe_write>:
{
  8025bf:	f3 0f 1e fb          	endbr32 
  8025c3:	55                   	push   %ebp
  8025c4:	89 e5                	mov    %esp,%ebp
  8025c6:	57                   	push   %edi
  8025c7:	56                   	push   %esi
  8025c8:	53                   	push   %ebx
  8025c9:	83 ec 28             	sub    $0x28,%esp
  8025cc:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8025cf:	56                   	push   %esi
  8025d0:	e8 67 ef ff ff       	call   80153c <fd2data>
  8025d5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8025d7:	83 c4 10             	add    $0x10,%esp
  8025da:	bf 00 00 00 00       	mov    $0x0,%edi
  8025df:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8025e2:	74 4f                	je     802633 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8025e4:	8b 43 04             	mov    0x4(%ebx),%eax
  8025e7:	8b 0b                	mov    (%ebx),%ecx
  8025e9:	8d 51 20             	lea    0x20(%ecx),%edx
  8025ec:	39 d0                	cmp    %edx,%eax
  8025ee:	72 14                	jb     802604 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8025f0:	89 da                	mov    %ebx,%edx
  8025f2:	89 f0                	mov    %esi,%eax
  8025f4:	e8 61 ff ff ff       	call   80255a <_pipeisclosed>
  8025f9:	85 c0                	test   %eax,%eax
  8025fb:	75 3b                	jne    802638 <devpipe_write+0x79>
			sys_yield();
  8025fd:	e8 6c ed ff ff       	call   80136e <sys_yield>
  802602:	eb e0                	jmp    8025e4 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802604:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802607:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80260b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80260e:	89 c2                	mov    %eax,%edx
  802610:	c1 fa 1f             	sar    $0x1f,%edx
  802613:	89 d1                	mov    %edx,%ecx
  802615:	c1 e9 1b             	shr    $0x1b,%ecx
  802618:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80261b:	83 e2 1f             	and    $0x1f,%edx
  80261e:	29 ca                	sub    %ecx,%edx
  802620:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802624:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802628:	83 c0 01             	add    $0x1,%eax
  80262b:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80262e:	83 c7 01             	add    $0x1,%edi
  802631:	eb ac                	jmp    8025df <devpipe_write+0x20>
	return i;
  802633:	8b 45 10             	mov    0x10(%ebp),%eax
  802636:	eb 05                	jmp    80263d <devpipe_write+0x7e>
				return 0;
  802638:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80263d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802640:	5b                   	pop    %ebx
  802641:	5e                   	pop    %esi
  802642:	5f                   	pop    %edi
  802643:	5d                   	pop    %ebp
  802644:	c3                   	ret    

00802645 <devpipe_read>:
{
  802645:	f3 0f 1e fb          	endbr32 
  802649:	55                   	push   %ebp
  80264a:	89 e5                	mov    %esp,%ebp
  80264c:	57                   	push   %edi
  80264d:	56                   	push   %esi
  80264e:	53                   	push   %ebx
  80264f:	83 ec 18             	sub    $0x18,%esp
  802652:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802655:	57                   	push   %edi
  802656:	e8 e1 ee ff ff       	call   80153c <fd2data>
  80265b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80265d:	83 c4 10             	add    $0x10,%esp
  802660:	be 00 00 00 00       	mov    $0x0,%esi
  802665:	3b 75 10             	cmp    0x10(%ebp),%esi
  802668:	75 14                	jne    80267e <devpipe_read+0x39>
	return i;
  80266a:	8b 45 10             	mov    0x10(%ebp),%eax
  80266d:	eb 02                	jmp    802671 <devpipe_read+0x2c>
				return i;
  80266f:	89 f0                	mov    %esi,%eax
}
  802671:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802674:	5b                   	pop    %ebx
  802675:	5e                   	pop    %esi
  802676:	5f                   	pop    %edi
  802677:	5d                   	pop    %ebp
  802678:	c3                   	ret    
			sys_yield();
  802679:	e8 f0 ec ff ff       	call   80136e <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80267e:	8b 03                	mov    (%ebx),%eax
  802680:	3b 43 04             	cmp    0x4(%ebx),%eax
  802683:	75 18                	jne    80269d <devpipe_read+0x58>
			if (i > 0)
  802685:	85 f6                	test   %esi,%esi
  802687:	75 e6                	jne    80266f <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  802689:	89 da                	mov    %ebx,%edx
  80268b:	89 f8                	mov    %edi,%eax
  80268d:	e8 c8 fe ff ff       	call   80255a <_pipeisclosed>
  802692:	85 c0                	test   %eax,%eax
  802694:	74 e3                	je     802679 <devpipe_read+0x34>
				return 0;
  802696:	b8 00 00 00 00       	mov    $0x0,%eax
  80269b:	eb d4                	jmp    802671 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80269d:	99                   	cltd   
  80269e:	c1 ea 1b             	shr    $0x1b,%edx
  8026a1:	01 d0                	add    %edx,%eax
  8026a3:	83 e0 1f             	and    $0x1f,%eax
  8026a6:	29 d0                	sub    %edx,%eax
  8026a8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8026ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026b0:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8026b3:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8026b6:	83 c6 01             	add    $0x1,%esi
  8026b9:	eb aa                	jmp    802665 <devpipe_read+0x20>

008026bb <pipe>:
{
  8026bb:	f3 0f 1e fb          	endbr32 
  8026bf:	55                   	push   %ebp
  8026c0:	89 e5                	mov    %esp,%ebp
  8026c2:	56                   	push   %esi
  8026c3:	53                   	push   %ebx
  8026c4:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8026c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026ca:	50                   	push   %eax
  8026cb:	e8 87 ee ff ff       	call   801557 <fd_alloc>
  8026d0:	89 c3                	mov    %eax,%ebx
  8026d2:	83 c4 10             	add    $0x10,%esp
  8026d5:	85 c0                	test   %eax,%eax
  8026d7:	0f 88 23 01 00 00    	js     802800 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026dd:	83 ec 04             	sub    $0x4,%esp
  8026e0:	68 07 04 00 00       	push   $0x407
  8026e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8026e8:	6a 00                	push   $0x0
  8026ea:	e8 a2 ec ff ff       	call   801391 <sys_page_alloc>
  8026ef:	89 c3                	mov    %eax,%ebx
  8026f1:	83 c4 10             	add    $0x10,%esp
  8026f4:	85 c0                	test   %eax,%eax
  8026f6:	0f 88 04 01 00 00    	js     802800 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8026fc:	83 ec 0c             	sub    $0xc,%esp
  8026ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802702:	50                   	push   %eax
  802703:	e8 4f ee ff ff       	call   801557 <fd_alloc>
  802708:	89 c3                	mov    %eax,%ebx
  80270a:	83 c4 10             	add    $0x10,%esp
  80270d:	85 c0                	test   %eax,%eax
  80270f:	0f 88 db 00 00 00    	js     8027f0 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802715:	83 ec 04             	sub    $0x4,%esp
  802718:	68 07 04 00 00       	push   $0x407
  80271d:	ff 75 f0             	pushl  -0x10(%ebp)
  802720:	6a 00                	push   $0x0
  802722:	e8 6a ec ff ff       	call   801391 <sys_page_alloc>
  802727:	89 c3                	mov    %eax,%ebx
  802729:	83 c4 10             	add    $0x10,%esp
  80272c:	85 c0                	test   %eax,%eax
  80272e:	0f 88 bc 00 00 00    	js     8027f0 <pipe+0x135>
	va = fd2data(fd0);
  802734:	83 ec 0c             	sub    $0xc,%esp
  802737:	ff 75 f4             	pushl  -0xc(%ebp)
  80273a:	e8 fd ed ff ff       	call   80153c <fd2data>
  80273f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802741:	83 c4 0c             	add    $0xc,%esp
  802744:	68 07 04 00 00       	push   $0x407
  802749:	50                   	push   %eax
  80274a:	6a 00                	push   $0x0
  80274c:	e8 40 ec ff ff       	call   801391 <sys_page_alloc>
  802751:	89 c3                	mov    %eax,%ebx
  802753:	83 c4 10             	add    $0x10,%esp
  802756:	85 c0                	test   %eax,%eax
  802758:	0f 88 82 00 00 00    	js     8027e0 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80275e:	83 ec 0c             	sub    $0xc,%esp
  802761:	ff 75 f0             	pushl  -0x10(%ebp)
  802764:	e8 d3 ed ff ff       	call   80153c <fd2data>
  802769:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802770:	50                   	push   %eax
  802771:	6a 00                	push   $0x0
  802773:	56                   	push   %esi
  802774:	6a 00                	push   $0x0
  802776:	e8 3c ec ff ff       	call   8013b7 <sys_page_map>
  80277b:	89 c3                	mov    %eax,%ebx
  80277d:	83 c4 20             	add    $0x20,%esp
  802780:	85 c0                	test   %eax,%eax
  802782:	78 4e                	js     8027d2 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  802784:	a1 9c 40 80 00       	mov    0x80409c,%eax
  802789:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80278c:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80278e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802791:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802798:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80279b:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80279d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8027a0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8027a7:	83 ec 0c             	sub    $0xc,%esp
  8027aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8027ad:	e8 76 ed ff ff       	call   801528 <fd2num>
  8027b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8027b5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8027b7:	83 c4 04             	add    $0x4,%esp
  8027ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8027bd:	e8 66 ed ff ff       	call   801528 <fd2num>
  8027c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8027c5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8027c8:	83 c4 10             	add    $0x10,%esp
  8027cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027d0:	eb 2e                	jmp    802800 <pipe+0x145>
	sys_page_unmap(0, va);
  8027d2:	83 ec 08             	sub    $0x8,%esp
  8027d5:	56                   	push   %esi
  8027d6:	6a 00                	push   $0x0
  8027d8:	e8 ff eb ff ff       	call   8013dc <sys_page_unmap>
  8027dd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8027e0:	83 ec 08             	sub    $0x8,%esp
  8027e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8027e6:	6a 00                	push   $0x0
  8027e8:	e8 ef eb ff ff       	call   8013dc <sys_page_unmap>
  8027ed:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8027f0:	83 ec 08             	sub    $0x8,%esp
  8027f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8027f6:	6a 00                	push   $0x0
  8027f8:	e8 df eb ff ff       	call   8013dc <sys_page_unmap>
  8027fd:	83 c4 10             	add    $0x10,%esp
}
  802800:	89 d8                	mov    %ebx,%eax
  802802:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802805:	5b                   	pop    %ebx
  802806:	5e                   	pop    %esi
  802807:	5d                   	pop    %ebp
  802808:	c3                   	ret    

00802809 <pipeisclosed>:
{
  802809:	f3 0f 1e fb          	endbr32 
  80280d:	55                   	push   %ebp
  80280e:	89 e5                	mov    %esp,%ebp
  802810:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802813:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802816:	50                   	push   %eax
  802817:	ff 75 08             	pushl  0x8(%ebp)
  80281a:	e8 8e ed ff ff       	call   8015ad <fd_lookup>
  80281f:	83 c4 10             	add    $0x10,%esp
  802822:	85 c0                	test   %eax,%eax
  802824:	78 18                	js     80283e <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  802826:	83 ec 0c             	sub    $0xc,%esp
  802829:	ff 75 f4             	pushl  -0xc(%ebp)
  80282c:	e8 0b ed ff ff       	call   80153c <fd2data>
  802831:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802833:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802836:	e8 1f fd ff ff       	call   80255a <_pipeisclosed>
  80283b:	83 c4 10             	add    $0x10,%esp
}
  80283e:	c9                   	leave  
  80283f:	c3                   	ret    

00802840 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802840:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  802844:	b8 00 00 00 00       	mov    $0x0,%eax
  802849:	c3                   	ret    

0080284a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80284a:	f3 0f 1e fb          	endbr32 
  80284e:	55                   	push   %ebp
  80284f:	89 e5                	mov    %esp,%ebp
  802851:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802854:	68 6e 34 80 00       	push   $0x80346e
  802859:	ff 75 0c             	pushl  0xc(%ebp)
  80285c:	e8 c7 e6 ff ff       	call   800f28 <strcpy>
	return 0;
}
  802861:	b8 00 00 00 00       	mov    $0x0,%eax
  802866:	c9                   	leave  
  802867:	c3                   	ret    

00802868 <devcons_write>:
{
  802868:	f3 0f 1e fb          	endbr32 
  80286c:	55                   	push   %ebp
  80286d:	89 e5                	mov    %esp,%ebp
  80286f:	57                   	push   %edi
  802870:	56                   	push   %esi
  802871:	53                   	push   %ebx
  802872:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802878:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80287d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802883:	3b 75 10             	cmp    0x10(%ebp),%esi
  802886:	73 31                	jae    8028b9 <devcons_write+0x51>
		m = n - tot;
  802888:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80288b:	29 f3                	sub    %esi,%ebx
  80288d:	83 fb 7f             	cmp    $0x7f,%ebx
  802890:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802895:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802898:	83 ec 04             	sub    $0x4,%esp
  80289b:	53                   	push   %ebx
  80289c:	89 f0                	mov    %esi,%eax
  80289e:	03 45 0c             	add    0xc(%ebp),%eax
  8028a1:	50                   	push   %eax
  8028a2:	57                   	push   %edi
  8028a3:	e8 7e e8 ff ff       	call   801126 <memmove>
		sys_cputs(buf, m);
  8028a8:	83 c4 08             	add    $0x8,%esp
  8028ab:	53                   	push   %ebx
  8028ac:	57                   	push   %edi
  8028ad:	e8 30 ea ff ff       	call   8012e2 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8028b2:	01 de                	add    %ebx,%esi
  8028b4:	83 c4 10             	add    $0x10,%esp
  8028b7:	eb ca                	jmp    802883 <devcons_write+0x1b>
}
  8028b9:	89 f0                	mov    %esi,%eax
  8028bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8028be:	5b                   	pop    %ebx
  8028bf:	5e                   	pop    %esi
  8028c0:	5f                   	pop    %edi
  8028c1:	5d                   	pop    %ebp
  8028c2:	c3                   	ret    

008028c3 <devcons_read>:
{
  8028c3:	f3 0f 1e fb          	endbr32 
  8028c7:	55                   	push   %ebp
  8028c8:	89 e5                	mov    %esp,%ebp
  8028ca:	83 ec 08             	sub    $0x8,%esp
  8028cd:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8028d2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8028d6:	74 21                	je     8028f9 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8028d8:	e8 27 ea ff ff       	call   801304 <sys_cgetc>
  8028dd:	85 c0                	test   %eax,%eax
  8028df:	75 07                	jne    8028e8 <devcons_read+0x25>
		sys_yield();
  8028e1:	e8 88 ea ff ff       	call   80136e <sys_yield>
  8028e6:	eb f0                	jmp    8028d8 <devcons_read+0x15>
	if (c < 0)
  8028e8:	78 0f                	js     8028f9 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8028ea:	83 f8 04             	cmp    $0x4,%eax
  8028ed:	74 0c                	je     8028fb <devcons_read+0x38>
	*(char*)vbuf = c;
  8028ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8028f2:	88 02                	mov    %al,(%edx)
	return 1;
  8028f4:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8028f9:	c9                   	leave  
  8028fa:	c3                   	ret    
		return 0;
  8028fb:	b8 00 00 00 00       	mov    $0x0,%eax
  802900:	eb f7                	jmp    8028f9 <devcons_read+0x36>

00802902 <cputchar>:
{
  802902:	f3 0f 1e fb          	endbr32 
  802906:	55                   	push   %ebp
  802907:	89 e5                	mov    %esp,%ebp
  802909:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80290c:	8b 45 08             	mov    0x8(%ebp),%eax
  80290f:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802912:	6a 01                	push   $0x1
  802914:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802917:	50                   	push   %eax
  802918:	e8 c5 e9 ff ff       	call   8012e2 <sys_cputs>
}
  80291d:	83 c4 10             	add    $0x10,%esp
  802920:	c9                   	leave  
  802921:	c3                   	ret    

00802922 <getchar>:
{
  802922:	f3 0f 1e fb          	endbr32 
  802926:	55                   	push   %ebp
  802927:	89 e5                	mov    %esp,%ebp
  802929:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80292c:	6a 01                	push   $0x1
  80292e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802931:	50                   	push   %eax
  802932:	6a 00                	push   $0x0
  802934:	e8 fc ee ff ff       	call   801835 <read>
	if (r < 0)
  802939:	83 c4 10             	add    $0x10,%esp
  80293c:	85 c0                	test   %eax,%eax
  80293e:	78 06                	js     802946 <getchar+0x24>
	if (r < 1)
  802940:	74 06                	je     802948 <getchar+0x26>
	return c;
  802942:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802946:	c9                   	leave  
  802947:	c3                   	ret    
		return -E_EOF;
  802948:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80294d:	eb f7                	jmp    802946 <getchar+0x24>

0080294f <iscons>:
{
  80294f:	f3 0f 1e fb          	endbr32 
  802953:	55                   	push   %ebp
  802954:	89 e5                	mov    %esp,%ebp
  802956:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802959:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80295c:	50                   	push   %eax
  80295d:	ff 75 08             	pushl  0x8(%ebp)
  802960:	e8 48 ec ff ff       	call   8015ad <fd_lookup>
  802965:	83 c4 10             	add    $0x10,%esp
  802968:	85 c0                	test   %eax,%eax
  80296a:	78 11                	js     80297d <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80296c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80296f:	8b 15 b8 40 80 00    	mov    0x8040b8,%edx
  802975:	39 10                	cmp    %edx,(%eax)
  802977:	0f 94 c0             	sete   %al
  80297a:	0f b6 c0             	movzbl %al,%eax
}
  80297d:	c9                   	leave  
  80297e:	c3                   	ret    

0080297f <opencons>:
{
  80297f:	f3 0f 1e fb          	endbr32 
  802983:	55                   	push   %ebp
  802984:	89 e5                	mov    %esp,%ebp
  802986:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802989:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80298c:	50                   	push   %eax
  80298d:	e8 c5 eb ff ff       	call   801557 <fd_alloc>
  802992:	83 c4 10             	add    $0x10,%esp
  802995:	85 c0                	test   %eax,%eax
  802997:	78 3a                	js     8029d3 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802999:	83 ec 04             	sub    $0x4,%esp
  80299c:	68 07 04 00 00       	push   $0x407
  8029a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8029a4:	6a 00                	push   $0x0
  8029a6:	e8 e6 e9 ff ff       	call   801391 <sys_page_alloc>
  8029ab:	83 c4 10             	add    $0x10,%esp
  8029ae:	85 c0                	test   %eax,%eax
  8029b0:	78 21                	js     8029d3 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8029b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029b5:	8b 15 b8 40 80 00    	mov    0x8040b8,%edx
  8029bb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8029bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029c0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8029c7:	83 ec 0c             	sub    $0xc,%esp
  8029ca:	50                   	push   %eax
  8029cb:	e8 58 eb ff ff       	call   801528 <fd2num>
  8029d0:	83 c4 10             	add    $0x10,%esp
}
  8029d3:	c9                   	leave  
  8029d4:	c3                   	ret    

008029d5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8029d5:	f3 0f 1e fb          	endbr32 
  8029d9:	55                   	push   %ebp
  8029da:	89 e5                	mov    %esp,%ebp
  8029dc:	56                   	push   %esi
  8029dd:	53                   	push   %ebx
  8029de:	8b 75 08             	mov    0x8(%ebp),%esi
  8029e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  8029e7:	85 c0                	test   %eax,%eax
  8029e9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8029ee:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  8029f1:	83 ec 0c             	sub    $0xc,%esp
  8029f4:	50                   	push   %eax
  8029f5:	e8 9d ea ff ff       	call   801497 <sys_ipc_recv>
  8029fa:	83 c4 10             	add    $0x10,%esp
  8029fd:	85 c0                	test   %eax,%eax
  8029ff:	75 2b                	jne    802a2c <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  802a01:	85 f6                	test   %esi,%esi
  802a03:	74 0a                	je     802a0f <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  802a05:	a1 1c 50 80 00       	mov    0x80501c,%eax
  802a0a:	8b 40 74             	mov    0x74(%eax),%eax
  802a0d:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  802a0f:	85 db                	test   %ebx,%ebx
  802a11:	74 0a                	je     802a1d <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  802a13:	a1 1c 50 80 00       	mov    0x80501c,%eax
  802a18:	8b 40 78             	mov    0x78(%eax),%eax
  802a1b:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  802a1d:	a1 1c 50 80 00       	mov    0x80501c,%eax
  802a22:	8b 40 70             	mov    0x70(%eax),%eax
}
  802a25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a28:	5b                   	pop    %ebx
  802a29:	5e                   	pop    %esi
  802a2a:	5d                   	pop    %ebp
  802a2b:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  802a2c:	85 f6                	test   %esi,%esi
  802a2e:	74 06                	je     802a36 <ipc_recv+0x61>
  802a30:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  802a36:	85 db                	test   %ebx,%ebx
  802a38:	74 eb                	je     802a25 <ipc_recv+0x50>
  802a3a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802a40:	eb e3                	jmp    802a25 <ipc_recv+0x50>

00802a42 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802a42:	f3 0f 1e fb          	endbr32 
  802a46:	55                   	push   %ebp
  802a47:	89 e5                	mov    %esp,%ebp
  802a49:	57                   	push   %edi
  802a4a:	56                   	push   %esi
  802a4b:	53                   	push   %ebx
  802a4c:	83 ec 0c             	sub    $0xc,%esp
  802a4f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802a52:	8b 75 0c             	mov    0xc(%ebp),%esi
  802a55:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  802a58:	85 db                	test   %ebx,%ebx
  802a5a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802a5f:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802a62:	ff 75 14             	pushl  0x14(%ebp)
  802a65:	53                   	push   %ebx
  802a66:	56                   	push   %esi
  802a67:	57                   	push   %edi
  802a68:	e8 03 ea ff ff       	call   801470 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  802a6d:	83 c4 10             	add    $0x10,%esp
  802a70:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802a73:	75 07                	jne    802a7c <ipc_send+0x3a>
			sys_yield();
  802a75:	e8 f4 e8 ff ff       	call   80136e <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802a7a:	eb e6                	jmp    802a62 <ipc_send+0x20>
		}
		else if (ret == 0)
  802a7c:	85 c0                	test   %eax,%eax
  802a7e:	75 08                	jne    802a88 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  802a80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a83:	5b                   	pop    %ebx
  802a84:	5e                   	pop    %esi
  802a85:	5f                   	pop    %edi
  802a86:	5d                   	pop    %ebp
  802a87:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802a88:	50                   	push   %eax
  802a89:	68 7a 34 80 00       	push   $0x80347a
  802a8e:	6a 48                	push   $0x48
  802a90:	68 88 34 80 00       	push   $0x803488
  802a95:	e8 9d dd ff ff       	call   800837 <_panic>

00802a9a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802a9a:	f3 0f 1e fb          	endbr32 
  802a9e:	55                   	push   %ebp
  802a9f:	89 e5                	mov    %esp,%ebp
  802aa1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802aa4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802aa9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802aac:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802ab2:	8b 52 50             	mov    0x50(%edx),%edx
  802ab5:	39 ca                	cmp    %ecx,%edx
  802ab7:	74 11                	je     802aca <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802ab9:	83 c0 01             	add    $0x1,%eax
  802abc:	3d 00 04 00 00       	cmp    $0x400,%eax
  802ac1:	75 e6                	jne    802aa9 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802ac3:	b8 00 00 00 00       	mov    $0x0,%eax
  802ac8:	eb 0b                	jmp    802ad5 <ipc_find_env+0x3b>
			return envs[i].env_id;
  802aca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802acd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802ad2:	8b 40 48             	mov    0x48(%eax),%eax
}
  802ad5:	5d                   	pop    %ebp
  802ad6:	c3                   	ret    

00802ad7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802ad7:	f3 0f 1e fb          	endbr32 
  802adb:	55                   	push   %ebp
  802adc:	89 e5                	mov    %esp,%ebp
  802ade:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802ae1:	89 c2                	mov    %eax,%edx
  802ae3:	c1 ea 16             	shr    $0x16,%edx
  802ae6:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802aed:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802af2:	f6 c1 01             	test   $0x1,%cl
  802af5:	74 1c                	je     802b13 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802af7:	c1 e8 0c             	shr    $0xc,%eax
  802afa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802b01:	a8 01                	test   $0x1,%al
  802b03:	74 0e                	je     802b13 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802b05:	c1 e8 0c             	shr    $0xc,%eax
  802b08:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802b0f:	ef 
  802b10:	0f b7 d2             	movzwl %dx,%edx
}
  802b13:	89 d0                	mov    %edx,%eax
  802b15:	5d                   	pop    %ebp
  802b16:	c3                   	ret    
  802b17:	66 90                	xchg   %ax,%ax
  802b19:	66 90                	xchg   %ax,%ax
  802b1b:	66 90                	xchg   %ax,%ax
  802b1d:	66 90                	xchg   %ax,%ax
  802b1f:	90                   	nop

00802b20 <__udivdi3>:
  802b20:	f3 0f 1e fb          	endbr32 
  802b24:	55                   	push   %ebp
  802b25:	57                   	push   %edi
  802b26:	56                   	push   %esi
  802b27:	53                   	push   %ebx
  802b28:	83 ec 1c             	sub    $0x1c,%esp
  802b2b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802b2f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802b33:	8b 74 24 34          	mov    0x34(%esp),%esi
  802b37:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802b3b:	85 d2                	test   %edx,%edx
  802b3d:	75 19                	jne    802b58 <__udivdi3+0x38>
  802b3f:	39 f3                	cmp    %esi,%ebx
  802b41:	76 4d                	jbe    802b90 <__udivdi3+0x70>
  802b43:	31 ff                	xor    %edi,%edi
  802b45:	89 e8                	mov    %ebp,%eax
  802b47:	89 f2                	mov    %esi,%edx
  802b49:	f7 f3                	div    %ebx
  802b4b:	89 fa                	mov    %edi,%edx
  802b4d:	83 c4 1c             	add    $0x1c,%esp
  802b50:	5b                   	pop    %ebx
  802b51:	5e                   	pop    %esi
  802b52:	5f                   	pop    %edi
  802b53:	5d                   	pop    %ebp
  802b54:	c3                   	ret    
  802b55:	8d 76 00             	lea    0x0(%esi),%esi
  802b58:	39 f2                	cmp    %esi,%edx
  802b5a:	76 14                	jbe    802b70 <__udivdi3+0x50>
  802b5c:	31 ff                	xor    %edi,%edi
  802b5e:	31 c0                	xor    %eax,%eax
  802b60:	89 fa                	mov    %edi,%edx
  802b62:	83 c4 1c             	add    $0x1c,%esp
  802b65:	5b                   	pop    %ebx
  802b66:	5e                   	pop    %esi
  802b67:	5f                   	pop    %edi
  802b68:	5d                   	pop    %ebp
  802b69:	c3                   	ret    
  802b6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802b70:	0f bd fa             	bsr    %edx,%edi
  802b73:	83 f7 1f             	xor    $0x1f,%edi
  802b76:	75 48                	jne    802bc0 <__udivdi3+0xa0>
  802b78:	39 f2                	cmp    %esi,%edx
  802b7a:	72 06                	jb     802b82 <__udivdi3+0x62>
  802b7c:	31 c0                	xor    %eax,%eax
  802b7e:	39 eb                	cmp    %ebp,%ebx
  802b80:	77 de                	ja     802b60 <__udivdi3+0x40>
  802b82:	b8 01 00 00 00       	mov    $0x1,%eax
  802b87:	eb d7                	jmp    802b60 <__udivdi3+0x40>
  802b89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b90:	89 d9                	mov    %ebx,%ecx
  802b92:	85 db                	test   %ebx,%ebx
  802b94:	75 0b                	jne    802ba1 <__udivdi3+0x81>
  802b96:	b8 01 00 00 00       	mov    $0x1,%eax
  802b9b:	31 d2                	xor    %edx,%edx
  802b9d:	f7 f3                	div    %ebx
  802b9f:	89 c1                	mov    %eax,%ecx
  802ba1:	31 d2                	xor    %edx,%edx
  802ba3:	89 f0                	mov    %esi,%eax
  802ba5:	f7 f1                	div    %ecx
  802ba7:	89 c6                	mov    %eax,%esi
  802ba9:	89 e8                	mov    %ebp,%eax
  802bab:	89 f7                	mov    %esi,%edi
  802bad:	f7 f1                	div    %ecx
  802baf:	89 fa                	mov    %edi,%edx
  802bb1:	83 c4 1c             	add    $0x1c,%esp
  802bb4:	5b                   	pop    %ebx
  802bb5:	5e                   	pop    %esi
  802bb6:	5f                   	pop    %edi
  802bb7:	5d                   	pop    %ebp
  802bb8:	c3                   	ret    
  802bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802bc0:	89 f9                	mov    %edi,%ecx
  802bc2:	b8 20 00 00 00       	mov    $0x20,%eax
  802bc7:	29 f8                	sub    %edi,%eax
  802bc9:	d3 e2                	shl    %cl,%edx
  802bcb:	89 54 24 08          	mov    %edx,0x8(%esp)
  802bcf:	89 c1                	mov    %eax,%ecx
  802bd1:	89 da                	mov    %ebx,%edx
  802bd3:	d3 ea                	shr    %cl,%edx
  802bd5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802bd9:	09 d1                	or     %edx,%ecx
  802bdb:	89 f2                	mov    %esi,%edx
  802bdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802be1:	89 f9                	mov    %edi,%ecx
  802be3:	d3 e3                	shl    %cl,%ebx
  802be5:	89 c1                	mov    %eax,%ecx
  802be7:	d3 ea                	shr    %cl,%edx
  802be9:	89 f9                	mov    %edi,%ecx
  802beb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802bef:	89 eb                	mov    %ebp,%ebx
  802bf1:	d3 e6                	shl    %cl,%esi
  802bf3:	89 c1                	mov    %eax,%ecx
  802bf5:	d3 eb                	shr    %cl,%ebx
  802bf7:	09 de                	or     %ebx,%esi
  802bf9:	89 f0                	mov    %esi,%eax
  802bfb:	f7 74 24 08          	divl   0x8(%esp)
  802bff:	89 d6                	mov    %edx,%esi
  802c01:	89 c3                	mov    %eax,%ebx
  802c03:	f7 64 24 0c          	mull   0xc(%esp)
  802c07:	39 d6                	cmp    %edx,%esi
  802c09:	72 15                	jb     802c20 <__udivdi3+0x100>
  802c0b:	89 f9                	mov    %edi,%ecx
  802c0d:	d3 e5                	shl    %cl,%ebp
  802c0f:	39 c5                	cmp    %eax,%ebp
  802c11:	73 04                	jae    802c17 <__udivdi3+0xf7>
  802c13:	39 d6                	cmp    %edx,%esi
  802c15:	74 09                	je     802c20 <__udivdi3+0x100>
  802c17:	89 d8                	mov    %ebx,%eax
  802c19:	31 ff                	xor    %edi,%edi
  802c1b:	e9 40 ff ff ff       	jmp    802b60 <__udivdi3+0x40>
  802c20:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802c23:	31 ff                	xor    %edi,%edi
  802c25:	e9 36 ff ff ff       	jmp    802b60 <__udivdi3+0x40>
  802c2a:	66 90                	xchg   %ax,%ax
  802c2c:	66 90                	xchg   %ax,%ax
  802c2e:	66 90                	xchg   %ax,%ax

00802c30 <__umoddi3>:
  802c30:	f3 0f 1e fb          	endbr32 
  802c34:	55                   	push   %ebp
  802c35:	57                   	push   %edi
  802c36:	56                   	push   %esi
  802c37:	53                   	push   %ebx
  802c38:	83 ec 1c             	sub    $0x1c,%esp
  802c3b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802c3f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802c43:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802c47:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802c4b:	85 c0                	test   %eax,%eax
  802c4d:	75 19                	jne    802c68 <__umoddi3+0x38>
  802c4f:	39 df                	cmp    %ebx,%edi
  802c51:	76 5d                	jbe    802cb0 <__umoddi3+0x80>
  802c53:	89 f0                	mov    %esi,%eax
  802c55:	89 da                	mov    %ebx,%edx
  802c57:	f7 f7                	div    %edi
  802c59:	89 d0                	mov    %edx,%eax
  802c5b:	31 d2                	xor    %edx,%edx
  802c5d:	83 c4 1c             	add    $0x1c,%esp
  802c60:	5b                   	pop    %ebx
  802c61:	5e                   	pop    %esi
  802c62:	5f                   	pop    %edi
  802c63:	5d                   	pop    %ebp
  802c64:	c3                   	ret    
  802c65:	8d 76 00             	lea    0x0(%esi),%esi
  802c68:	89 f2                	mov    %esi,%edx
  802c6a:	39 d8                	cmp    %ebx,%eax
  802c6c:	76 12                	jbe    802c80 <__umoddi3+0x50>
  802c6e:	89 f0                	mov    %esi,%eax
  802c70:	89 da                	mov    %ebx,%edx
  802c72:	83 c4 1c             	add    $0x1c,%esp
  802c75:	5b                   	pop    %ebx
  802c76:	5e                   	pop    %esi
  802c77:	5f                   	pop    %edi
  802c78:	5d                   	pop    %ebp
  802c79:	c3                   	ret    
  802c7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802c80:	0f bd e8             	bsr    %eax,%ebp
  802c83:	83 f5 1f             	xor    $0x1f,%ebp
  802c86:	75 50                	jne    802cd8 <__umoddi3+0xa8>
  802c88:	39 d8                	cmp    %ebx,%eax
  802c8a:	0f 82 e0 00 00 00    	jb     802d70 <__umoddi3+0x140>
  802c90:	89 d9                	mov    %ebx,%ecx
  802c92:	39 f7                	cmp    %esi,%edi
  802c94:	0f 86 d6 00 00 00    	jbe    802d70 <__umoddi3+0x140>
  802c9a:	89 d0                	mov    %edx,%eax
  802c9c:	89 ca                	mov    %ecx,%edx
  802c9e:	83 c4 1c             	add    $0x1c,%esp
  802ca1:	5b                   	pop    %ebx
  802ca2:	5e                   	pop    %esi
  802ca3:	5f                   	pop    %edi
  802ca4:	5d                   	pop    %ebp
  802ca5:	c3                   	ret    
  802ca6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802cad:	8d 76 00             	lea    0x0(%esi),%esi
  802cb0:	89 fd                	mov    %edi,%ebp
  802cb2:	85 ff                	test   %edi,%edi
  802cb4:	75 0b                	jne    802cc1 <__umoddi3+0x91>
  802cb6:	b8 01 00 00 00       	mov    $0x1,%eax
  802cbb:	31 d2                	xor    %edx,%edx
  802cbd:	f7 f7                	div    %edi
  802cbf:	89 c5                	mov    %eax,%ebp
  802cc1:	89 d8                	mov    %ebx,%eax
  802cc3:	31 d2                	xor    %edx,%edx
  802cc5:	f7 f5                	div    %ebp
  802cc7:	89 f0                	mov    %esi,%eax
  802cc9:	f7 f5                	div    %ebp
  802ccb:	89 d0                	mov    %edx,%eax
  802ccd:	31 d2                	xor    %edx,%edx
  802ccf:	eb 8c                	jmp    802c5d <__umoddi3+0x2d>
  802cd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802cd8:	89 e9                	mov    %ebp,%ecx
  802cda:	ba 20 00 00 00       	mov    $0x20,%edx
  802cdf:	29 ea                	sub    %ebp,%edx
  802ce1:	d3 e0                	shl    %cl,%eax
  802ce3:	89 44 24 08          	mov    %eax,0x8(%esp)
  802ce7:	89 d1                	mov    %edx,%ecx
  802ce9:	89 f8                	mov    %edi,%eax
  802ceb:	d3 e8                	shr    %cl,%eax
  802ced:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802cf1:	89 54 24 04          	mov    %edx,0x4(%esp)
  802cf5:	8b 54 24 04          	mov    0x4(%esp),%edx
  802cf9:	09 c1                	or     %eax,%ecx
  802cfb:	89 d8                	mov    %ebx,%eax
  802cfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802d01:	89 e9                	mov    %ebp,%ecx
  802d03:	d3 e7                	shl    %cl,%edi
  802d05:	89 d1                	mov    %edx,%ecx
  802d07:	d3 e8                	shr    %cl,%eax
  802d09:	89 e9                	mov    %ebp,%ecx
  802d0b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802d0f:	d3 e3                	shl    %cl,%ebx
  802d11:	89 c7                	mov    %eax,%edi
  802d13:	89 d1                	mov    %edx,%ecx
  802d15:	89 f0                	mov    %esi,%eax
  802d17:	d3 e8                	shr    %cl,%eax
  802d19:	89 e9                	mov    %ebp,%ecx
  802d1b:	89 fa                	mov    %edi,%edx
  802d1d:	d3 e6                	shl    %cl,%esi
  802d1f:	09 d8                	or     %ebx,%eax
  802d21:	f7 74 24 08          	divl   0x8(%esp)
  802d25:	89 d1                	mov    %edx,%ecx
  802d27:	89 f3                	mov    %esi,%ebx
  802d29:	f7 64 24 0c          	mull   0xc(%esp)
  802d2d:	89 c6                	mov    %eax,%esi
  802d2f:	89 d7                	mov    %edx,%edi
  802d31:	39 d1                	cmp    %edx,%ecx
  802d33:	72 06                	jb     802d3b <__umoddi3+0x10b>
  802d35:	75 10                	jne    802d47 <__umoddi3+0x117>
  802d37:	39 c3                	cmp    %eax,%ebx
  802d39:	73 0c                	jae    802d47 <__umoddi3+0x117>
  802d3b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  802d3f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802d43:	89 d7                	mov    %edx,%edi
  802d45:	89 c6                	mov    %eax,%esi
  802d47:	89 ca                	mov    %ecx,%edx
  802d49:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802d4e:	29 f3                	sub    %esi,%ebx
  802d50:	19 fa                	sbb    %edi,%edx
  802d52:	89 d0                	mov    %edx,%eax
  802d54:	d3 e0                	shl    %cl,%eax
  802d56:	89 e9                	mov    %ebp,%ecx
  802d58:	d3 eb                	shr    %cl,%ebx
  802d5a:	d3 ea                	shr    %cl,%edx
  802d5c:	09 d8                	or     %ebx,%eax
  802d5e:	83 c4 1c             	add    $0x1c,%esp
  802d61:	5b                   	pop    %ebx
  802d62:	5e                   	pop    %esi
  802d63:	5f                   	pop    %edi
  802d64:	5d                   	pop    %ebp
  802d65:	c3                   	ret    
  802d66:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802d6d:	8d 76 00             	lea    0x0(%esi),%esi
  802d70:	29 fe                	sub    %edi,%esi
  802d72:	19 c3                	sbb    %eax,%ebx
  802d74:	89 f2                	mov    %esi,%edx
  802d76:	89 d9                	mov    %ebx,%ecx
  802d78:	e9 1d ff ff ff       	jmp    802c9a <__umoddi3+0x6a>
