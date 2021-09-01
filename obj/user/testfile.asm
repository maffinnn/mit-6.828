
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 58 06 00 00       	call   800689 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 60 80 00       	push   $0x806000
  800042:	e8 9b 0d 00 00       	call   800de2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 64 80 00    	mov    %ebx,0x806400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 4e 14 00 00       	call   8014a7 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 60 80 00       	push   $0x806000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 e7 13 00 00       	call   80144f <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 69 13 00 00       	call   8013e2 <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	f3 0f 1e fb          	endbr32 
  800082:	55                   	push   %ebp
  800083:	89 e5                	mov    %esp,%ebp
  800085:	57                   	push   %edi
  800086:	56                   	push   %esi
  800087:	53                   	push   %ebx
  800088:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008e:	ba 00 00 00 00       	mov    $0x0,%edx
  800093:	b8 a0 29 80 00       	mov    $0x8029a0,%eax
  800098:	e8 96 ff ff ff       	call   800033 <xopen>
  80009d:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000a0:	74 08                	je     8000aa <umain+0x2c>
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	0f 88 e9 03 00 00    	js     800493 <umain+0x415>
		panic("serve_open /not-found: %e", r);
	else if (r >= 0)
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	0f 89 f3 03 00 00    	jns    8004a5 <umain+0x427>
		panic("serve_open /not-found succeeded!");

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b7:	b8 d5 29 80 00       	mov    $0x8029d5,%eax
  8000bc:	e8 72 ff ff ff       	call   800033 <xopen>
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	0f 88 f0 03 00 00    	js     8004b9 <umain+0x43b>
		panic("serve_open /newmotd: %e", r);
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000c9:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000d0:	0f 85 f5 03 00 00    	jne    8004cb <umain+0x44d>
  8000d6:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  8000dd:	0f 85 e8 03 00 00    	jne    8004cb <umain+0x44d>
  8000e3:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  8000ea:	0f 85 db 03 00 00    	jne    8004cb <umain+0x44d>
		panic("serve_open did not fill struct Fd correctly\n");
	cprintf("serve_open is good\n");
  8000f0:	83 ec 0c             	sub    $0xc,%esp
  8000f3:	68 f6 29 80 00       	push   $0x8029f6
  8000f8:	e8 db 06 00 00       	call   8007d8 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  8000fd:	83 c4 08             	add    $0x8,%esp
  800100:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  800106:	50                   	push   %eax
  800107:	68 00 c0 cc cc       	push   $0xccccc000
  80010c:	ff 15 34 40 80 00    	call   *0x804034
  800112:	83 c4 10             	add    $0x10,%esp
  800115:	85 c0                	test   %eax,%eax
  800117:	0f 88 c2 03 00 00    	js     8004df <umain+0x461>
		panic("file_stat: %e", r);
	if (strlen(msg) != st.st_size)
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	ff 35 00 40 80 00    	pushl  0x804000
  800126:	e8 74 0c 00 00       	call   800d9f <strlen>
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800131:	0f 85 ba 03 00 00    	jne    8004f1 <umain+0x473>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
	cprintf("file_stat is good\n");
  800137:	83 ec 0c             	sub    $0xc,%esp
  80013a:	68 18 2a 80 00       	push   $0x802a18
  80013f:	e8 94 06 00 00       	call   8007d8 <cprintf>

	memset(buf, 0, sizeof buf);
  800144:	83 c4 0c             	add    $0xc,%esp
  800147:	68 00 02 00 00       	push   $0x200
  80014c:	6a 00                	push   $0x0
  80014e:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800154:	53                   	push   %ebx
  800155:	e8 3a 0e 00 00       	call   800f94 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80015a:	83 c4 0c             	add    $0xc,%esp
  80015d:	68 00 02 00 00       	push   $0x200
  800162:	53                   	push   %ebx
  800163:	68 00 c0 cc cc       	push   $0xccccc000
  800168:	ff 15 28 40 80 00    	call   *0x804028
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	85 c0                	test   %eax,%eax
  800173:	0f 88 9d 03 00 00    	js     800516 <umain+0x498>
		panic("file_read: %e", r);
	if (strcmp(buf, msg) != 0)
  800179:	83 ec 08             	sub    $0x8,%esp
  80017c:	ff 35 00 40 80 00    	pushl  0x804000
  800182:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800188:	50                   	push   %eax
  800189:	e8 13 0d 00 00       	call   800ea1 <strcmp>
  80018e:	83 c4 10             	add    $0x10,%esp
  800191:	85 c0                	test   %eax,%eax
  800193:	0f 85 8f 03 00 00    	jne    800528 <umain+0x4aa>
		panic("file_read returned wrong data");
	cprintf("file_read is good\n");
  800199:	83 ec 0c             	sub    $0xc,%esp
  80019c:	68 57 2a 80 00       	push   $0x802a57
  8001a1:	e8 32 06 00 00       	call   8007d8 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  8001a6:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8001ad:	ff 15 30 40 80 00    	call   *0x804030
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	85 c0                	test   %eax,%eax
  8001b8:	0f 88 7e 03 00 00    	js     80053c <umain+0x4be>
		panic("file_close: %e", r);
	cprintf("file_close is good\n");
  8001be:	83 ec 0c             	sub    $0xc,%esp
  8001c1:	68 79 2a 80 00       	push   $0x802a79
  8001c6:	e8 0d 06 00 00       	call   8007d8 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  8001cb:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  8001d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d3:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  8001d8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001db:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  8001e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e3:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  8001e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  8001eb:	83 c4 08             	add    $0x8,%esp
  8001ee:	68 00 c0 cc cc       	push   $0xccccc000
  8001f3:	6a 00                	push   $0x0
  8001f5:	e8 9c 10 00 00       	call   801296 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  8001fa:	83 c4 0c             	add    $0xc,%esp
  8001fd:	68 00 02 00 00       	push   $0x200
  800202:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800208:	50                   	push   %eax
  800209:	8d 45 d8             	lea    -0x28(%ebp),%eax
  80020c:	50                   	push   %eax
  80020d:	ff 15 28 40 80 00    	call   *0x804028
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800219:	0f 85 2f 03 00 00    	jne    80054e <umain+0x4d0>
		panic("serve_read does not handle stale fileids correctly: %e", r);
	cprintf("stale fileid is good\n");
  80021f:	83 ec 0c             	sub    $0xc,%esp
  800222:	68 8d 2a 80 00       	push   $0x802a8d
  800227:	e8 ac 05 00 00       	call   8007d8 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  80022c:	ba 02 01 00 00       	mov    $0x102,%edx
  800231:	b8 a3 2a 80 00       	mov    $0x802aa3,%eax
  800236:	e8 f8 fd ff ff       	call   800033 <xopen>
  80023b:	83 c4 10             	add    $0x10,%esp
  80023e:	85 c0                	test   %eax,%eax
  800240:	0f 88 1a 03 00 00    	js     800560 <umain+0x4e2>
		panic("serve_open /new-file: %e", r);

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  800246:	8b 1d 2c 40 80 00    	mov    0x80402c,%ebx
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	ff 35 00 40 80 00    	pushl  0x804000
  800255:	e8 45 0b 00 00       	call   800d9f <strlen>
  80025a:	83 c4 0c             	add    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	ff 35 00 40 80 00    	pushl  0x804000
  800264:	68 00 c0 cc cc       	push   $0xccccc000
  800269:	ff d3                	call   *%ebx
  80026b:	89 c3                	mov    %eax,%ebx
  80026d:	83 c4 04             	add    $0x4,%esp
  800270:	ff 35 00 40 80 00    	pushl  0x804000
  800276:	e8 24 0b 00 00       	call   800d9f <strlen>
  80027b:	83 c4 10             	add    $0x10,%esp
  80027e:	39 d8                	cmp    %ebx,%eax
  800280:	0f 85 ec 02 00 00    	jne    800572 <umain+0x4f4>
		panic("file_write: %e", r);
	cprintf("file_write is good\n");
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	68 d5 2a 80 00       	push   $0x802ad5
  80028e:	e8 45 05 00 00       	call   8007d8 <cprintf>

	FVA->fd_offset = 0;
  800293:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  80029a:	00 00 00 
	memset(buf, 0, sizeof buf);
  80029d:	83 c4 0c             	add    $0xc,%esp
  8002a0:	68 00 02 00 00       	push   $0x200
  8002a5:	6a 00                	push   $0x0
  8002a7:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8002ad:	53                   	push   %ebx
  8002ae:	e8 e1 0c 00 00       	call   800f94 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8002b3:	83 c4 0c             	add    $0xc,%esp
  8002b6:	68 00 02 00 00       	push   $0x200
  8002bb:	53                   	push   %ebx
  8002bc:	68 00 c0 cc cc       	push   $0xccccc000
  8002c1:	ff 15 28 40 80 00    	call   *0x804028
  8002c7:	89 c3                	mov    %eax,%ebx
  8002c9:	83 c4 10             	add    $0x10,%esp
  8002cc:	85 c0                	test   %eax,%eax
  8002ce:	0f 88 b0 02 00 00    	js     800584 <umain+0x506>
		panic("file_read after file_write: %e", r);
	if (r != strlen(msg))
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	ff 35 00 40 80 00    	pushl  0x804000
  8002dd:	e8 bd 0a 00 00       	call   800d9f <strlen>
  8002e2:	83 c4 10             	add    $0x10,%esp
  8002e5:	39 d8                	cmp    %ebx,%eax
  8002e7:	0f 85 a9 02 00 00    	jne    800596 <umain+0x518>
		panic("file_read after file_write returned wrong length: %d", r);
	if (strcmp(buf, msg) != 0)
  8002ed:	83 ec 08             	sub    $0x8,%esp
  8002f0:	ff 35 00 40 80 00    	pushl  0x804000
  8002f6:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8002fc:	50                   	push   %eax
  8002fd:	e8 9f 0b 00 00       	call   800ea1 <strcmp>
  800302:	83 c4 10             	add    $0x10,%esp
  800305:	85 c0                	test   %eax,%eax
  800307:	0f 85 9b 02 00 00    	jne    8005a8 <umain+0x52a>
		panic("file_read after file_write returned wrong data");
	cprintf("file_read after file_write is good\n");
  80030d:	83 ec 0c             	sub    $0xc,%esp
  800310:	68 9c 2c 80 00       	push   $0x802c9c
  800315:	e8 be 04 00 00       	call   8007d8 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80031a:	83 c4 08             	add    $0x8,%esp
  80031d:	6a 00                	push   $0x0
  80031f:	68 a0 29 80 00       	push   $0x8029a0
  800324:	e8 63 19 00 00       	call   801c8c <open>
  800329:	83 c4 10             	add    $0x10,%esp
  80032c:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80032f:	74 08                	je     800339 <umain+0x2bb>
  800331:	85 c0                	test   %eax,%eax
  800333:	0f 88 83 02 00 00    	js     8005bc <umain+0x53e>
		panic("open /not-found: %e", r);
	else if (r >= 0)
  800339:	85 c0                	test   %eax,%eax
  80033b:	0f 89 8d 02 00 00    	jns    8005ce <umain+0x550>
		panic("open /not-found succeeded!");

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800341:	83 ec 08             	sub    $0x8,%esp
  800344:	6a 00                	push   $0x0
  800346:	68 d5 29 80 00       	push   $0x8029d5
  80034b:	e8 3c 19 00 00       	call   801c8c <open>
  800350:	83 c4 10             	add    $0x10,%esp
  800353:	85 c0                	test   %eax,%eax
  800355:	0f 88 87 02 00 00    	js     8005e2 <umain+0x564>
		panic("open /newmotd: %e", r);
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  80035b:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  80035e:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  800365:	0f 85 89 02 00 00    	jne    8005f4 <umain+0x576>
  80036b:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  800372:	0f 85 7c 02 00 00    	jne    8005f4 <umain+0x576>
  800378:	8b 98 08 00 00 d0    	mov    -0x2ffffff8(%eax),%ebx
  80037e:	85 db                	test   %ebx,%ebx
  800380:	0f 85 6e 02 00 00    	jne    8005f4 <umain+0x576>
		panic("open did not fill struct Fd correctly\n");
	cprintf("open is good\n");
  800386:	83 ec 0c             	sub    $0xc,%esp
  800389:	68 fc 29 80 00       	push   $0x8029fc
  80038e:	e8 45 04 00 00       	call   8007d8 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  800393:	83 c4 08             	add    $0x8,%esp
  800396:	68 01 01 00 00       	push   $0x101
  80039b:	68 04 2b 80 00       	push   $0x802b04
  8003a0:	e8 e7 18 00 00       	call   801c8c <open>
  8003a5:	89 c7                	mov    %eax,%edi
  8003a7:	83 c4 10             	add    $0x10,%esp
  8003aa:	85 c0                	test   %eax,%eax
  8003ac:	0f 88 56 02 00 00    	js     800608 <umain+0x58a>
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
  8003b2:	83 ec 04             	sub    $0x4,%esp
  8003b5:	68 00 02 00 00       	push   $0x200
  8003ba:	6a 00                	push   $0x0
  8003bc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003c2:	50                   	push   %eax
  8003c3:	e8 cc 0b 00 00       	call   800f94 <memset>
  8003c8:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8003cb:	89 de                	mov    %ebx,%esi
		*(int*)buf = i;
  8003cd:	89 b5 4c fd ff ff    	mov    %esi,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8003d3:	83 ec 04             	sub    $0x4,%esp
  8003d6:	68 00 02 00 00       	push   $0x200
  8003db:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003e1:	50                   	push   %eax
  8003e2:	57                   	push   %edi
  8003e3:	e8 df 14 00 00       	call   8018c7 <write>
  8003e8:	83 c4 10             	add    $0x10,%esp
  8003eb:	85 c0                	test   %eax,%eax
  8003ed:	0f 88 27 02 00 00    	js     80061a <umain+0x59c>
  8003f3:	81 c6 00 02 00 00    	add    $0x200,%esi
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8003f9:	81 fe 00 e0 01 00    	cmp    $0x1e000,%esi
  8003ff:	75 cc                	jne    8003cd <umain+0x34f>
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800401:	83 ec 0c             	sub    $0xc,%esp
  800404:	57                   	push   %edi
  800405:	e8 9d 12 00 00       	call   8016a7 <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80040a:	83 c4 08             	add    $0x8,%esp
  80040d:	6a 00                	push   $0x0
  80040f:	68 04 2b 80 00       	push   $0x802b04
  800414:	e8 73 18 00 00       	call   801c8c <open>
  800419:	89 c6                	mov    %eax,%esi
  80041b:	83 c4 10             	add    $0x10,%esp
  80041e:	85 c0                	test   %eax,%eax
  800420:	0f 88 0a 02 00 00    	js     800630 <umain+0x5b2>
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800426:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
		*(int*)buf = i;
  80042c:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800432:	83 ec 04             	sub    $0x4,%esp
  800435:	68 00 02 00 00       	push   $0x200
  80043a:	57                   	push   %edi
  80043b:	56                   	push   %esi
  80043c:	e8 3b 14 00 00       	call   80187c <readn>
  800441:	83 c4 10             	add    $0x10,%esp
  800444:	85 c0                	test   %eax,%eax
  800446:	0f 88 f6 01 00 00    	js     800642 <umain+0x5c4>
			panic("read /big@%d: %e", i, r);
		if (r != sizeof(buf))
  80044c:	3d 00 02 00 00       	cmp    $0x200,%eax
  800451:	0f 85 01 02 00 00    	jne    800658 <umain+0x5da>
			panic("read /big from %d returned %d < %d bytes",
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  800457:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  80045d:	39 d8                	cmp    %ebx,%eax
  80045f:	0f 85 0e 02 00 00    	jne    800673 <umain+0x5f5>
  800465:	81 c3 00 02 00 00    	add    $0x200,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80046b:	81 fb 00 e0 01 00    	cmp    $0x1e000,%ebx
  800471:	75 b9                	jne    80042c <umain+0x3ae>
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800473:	83 ec 0c             	sub    $0xc,%esp
  800476:	56                   	push   %esi
  800477:	e8 2b 12 00 00       	call   8016a7 <close>
	cprintf("large file is good\n");
  80047c:	c7 04 24 49 2b 80 00 	movl   $0x802b49,(%esp)
  800483:	e8 50 03 00 00       	call   8007d8 <cprintf>
}
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80048e:	5b                   	pop    %ebx
  80048f:	5e                   	pop    %esi
  800490:	5f                   	pop    %edi
  800491:	5d                   	pop    %ebp
  800492:	c3                   	ret    
		panic("serve_open /not-found: %e", r);
  800493:	50                   	push   %eax
  800494:	68 ab 29 80 00       	push   $0x8029ab
  800499:	6a 20                	push   $0x20
  80049b:	68 c5 29 80 00       	push   $0x8029c5
  8004a0:	e8 4c 02 00 00       	call   8006f1 <_panic>
		panic("serve_open /not-found succeeded!");
  8004a5:	83 ec 04             	sub    $0x4,%esp
  8004a8:	68 60 2b 80 00       	push   $0x802b60
  8004ad:	6a 22                	push   $0x22
  8004af:	68 c5 29 80 00       	push   $0x8029c5
  8004b4:	e8 38 02 00 00       	call   8006f1 <_panic>
		panic("serve_open /newmotd: %e", r);
  8004b9:	50                   	push   %eax
  8004ba:	68 de 29 80 00       	push   $0x8029de
  8004bf:	6a 25                	push   $0x25
  8004c1:	68 c5 29 80 00       	push   $0x8029c5
  8004c6:	e8 26 02 00 00       	call   8006f1 <_panic>
		panic("serve_open did not fill struct Fd correctly\n");
  8004cb:	83 ec 04             	sub    $0x4,%esp
  8004ce:	68 84 2b 80 00       	push   $0x802b84
  8004d3:	6a 27                	push   $0x27
  8004d5:	68 c5 29 80 00       	push   $0x8029c5
  8004da:	e8 12 02 00 00       	call   8006f1 <_panic>
		panic("file_stat: %e", r);
  8004df:	50                   	push   %eax
  8004e0:	68 0a 2a 80 00       	push   $0x802a0a
  8004e5:	6a 2b                	push   $0x2b
  8004e7:	68 c5 29 80 00       	push   $0x8029c5
  8004ec:	e8 00 02 00 00       	call   8006f1 <_panic>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8004f1:	83 ec 0c             	sub    $0xc,%esp
  8004f4:	ff 35 00 40 80 00    	pushl  0x804000
  8004fa:	e8 a0 08 00 00       	call   800d9f <strlen>
  8004ff:	89 04 24             	mov    %eax,(%esp)
  800502:	ff 75 cc             	pushl  -0x34(%ebp)
  800505:	68 b4 2b 80 00       	push   $0x802bb4
  80050a:	6a 2d                	push   $0x2d
  80050c:	68 c5 29 80 00       	push   $0x8029c5
  800511:	e8 db 01 00 00       	call   8006f1 <_panic>
		panic("file_read: %e", r);
  800516:	50                   	push   %eax
  800517:	68 2b 2a 80 00       	push   $0x802a2b
  80051c:	6a 32                	push   $0x32
  80051e:	68 c5 29 80 00       	push   $0x8029c5
  800523:	e8 c9 01 00 00       	call   8006f1 <_panic>
		panic("file_read returned wrong data");
  800528:	83 ec 04             	sub    $0x4,%esp
  80052b:	68 39 2a 80 00       	push   $0x802a39
  800530:	6a 34                	push   $0x34
  800532:	68 c5 29 80 00       	push   $0x8029c5
  800537:	e8 b5 01 00 00       	call   8006f1 <_panic>
		panic("file_close: %e", r);
  80053c:	50                   	push   %eax
  80053d:	68 6a 2a 80 00       	push   $0x802a6a
  800542:	6a 38                	push   $0x38
  800544:	68 c5 29 80 00       	push   $0x8029c5
  800549:	e8 a3 01 00 00       	call   8006f1 <_panic>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  80054e:	50                   	push   %eax
  80054f:	68 dc 2b 80 00       	push   $0x802bdc
  800554:	6a 43                	push   $0x43
  800556:	68 c5 29 80 00       	push   $0x8029c5
  80055b:	e8 91 01 00 00       	call   8006f1 <_panic>
		panic("serve_open /new-file: %e", r);
  800560:	50                   	push   %eax
  800561:	68 ad 2a 80 00       	push   $0x802aad
  800566:	6a 48                	push   $0x48
  800568:	68 c5 29 80 00       	push   $0x8029c5
  80056d:	e8 7f 01 00 00       	call   8006f1 <_panic>
		panic("file_write: %e", r);
  800572:	53                   	push   %ebx
  800573:	68 c6 2a 80 00       	push   $0x802ac6
  800578:	6a 4b                	push   $0x4b
  80057a:	68 c5 29 80 00       	push   $0x8029c5
  80057f:	e8 6d 01 00 00       	call   8006f1 <_panic>
		panic("file_read after file_write: %e", r);
  800584:	50                   	push   %eax
  800585:	68 14 2c 80 00       	push   $0x802c14
  80058a:	6a 51                	push   $0x51
  80058c:	68 c5 29 80 00       	push   $0x8029c5
  800591:	e8 5b 01 00 00       	call   8006f1 <_panic>
		panic("file_read after file_write returned wrong length: %d", r);
  800596:	53                   	push   %ebx
  800597:	68 34 2c 80 00       	push   $0x802c34
  80059c:	6a 53                	push   $0x53
  80059e:	68 c5 29 80 00       	push   $0x8029c5
  8005a3:	e8 49 01 00 00       	call   8006f1 <_panic>
		panic("file_read after file_write returned wrong data");
  8005a8:	83 ec 04             	sub    $0x4,%esp
  8005ab:	68 6c 2c 80 00       	push   $0x802c6c
  8005b0:	6a 55                	push   $0x55
  8005b2:	68 c5 29 80 00       	push   $0x8029c5
  8005b7:	e8 35 01 00 00       	call   8006f1 <_panic>
		panic("open /not-found: %e", r);
  8005bc:	50                   	push   %eax
  8005bd:	68 b1 29 80 00       	push   $0x8029b1
  8005c2:	6a 5a                	push   $0x5a
  8005c4:	68 c5 29 80 00       	push   $0x8029c5
  8005c9:	e8 23 01 00 00       	call   8006f1 <_panic>
		panic("open /not-found succeeded!");
  8005ce:	83 ec 04             	sub    $0x4,%esp
  8005d1:	68 e9 2a 80 00       	push   $0x802ae9
  8005d6:	6a 5c                	push   $0x5c
  8005d8:	68 c5 29 80 00       	push   $0x8029c5
  8005dd:	e8 0f 01 00 00       	call   8006f1 <_panic>
		panic("open /newmotd: %e", r);
  8005e2:	50                   	push   %eax
  8005e3:	68 e4 29 80 00       	push   $0x8029e4
  8005e8:	6a 5f                	push   $0x5f
  8005ea:	68 c5 29 80 00       	push   $0x8029c5
  8005ef:	e8 fd 00 00 00       	call   8006f1 <_panic>
		panic("open did not fill struct Fd correctly\n");
  8005f4:	83 ec 04             	sub    $0x4,%esp
  8005f7:	68 c0 2c 80 00       	push   $0x802cc0
  8005fc:	6a 62                	push   $0x62
  8005fe:	68 c5 29 80 00       	push   $0x8029c5
  800603:	e8 e9 00 00 00       	call   8006f1 <_panic>
		panic("creat /big: %e", f);
  800608:	50                   	push   %eax
  800609:	68 09 2b 80 00       	push   $0x802b09
  80060e:	6a 67                	push   $0x67
  800610:	68 c5 29 80 00       	push   $0x8029c5
  800615:	e8 d7 00 00 00       	call   8006f1 <_panic>
			panic("write /big@%d: %e", i, r);
  80061a:	83 ec 0c             	sub    $0xc,%esp
  80061d:	50                   	push   %eax
  80061e:	56                   	push   %esi
  80061f:	68 18 2b 80 00       	push   $0x802b18
  800624:	6a 6c                	push   $0x6c
  800626:	68 c5 29 80 00       	push   $0x8029c5
  80062b:	e8 c1 00 00 00       	call   8006f1 <_panic>
		panic("open /big: %e", f);
  800630:	50                   	push   %eax
  800631:	68 2a 2b 80 00       	push   $0x802b2a
  800636:	6a 71                	push   $0x71
  800638:	68 c5 29 80 00       	push   $0x8029c5
  80063d:	e8 af 00 00 00       	call   8006f1 <_panic>
			panic("read /big@%d: %e", i, r);
  800642:	83 ec 0c             	sub    $0xc,%esp
  800645:	50                   	push   %eax
  800646:	53                   	push   %ebx
  800647:	68 38 2b 80 00       	push   $0x802b38
  80064c:	6a 75                	push   $0x75
  80064e:	68 c5 29 80 00       	push   $0x8029c5
  800653:	e8 99 00 00 00       	call   8006f1 <_panic>
			panic("read /big from %d returned %d < %d bytes",
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	68 00 02 00 00       	push   $0x200
  800660:	50                   	push   %eax
  800661:	53                   	push   %ebx
  800662:	68 e8 2c 80 00       	push   $0x802ce8
  800667:	6a 77                	push   $0x77
  800669:	68 c5 29 80 00       	push   $0x8029c5
  80066e:	e8 7e 00 00 00       	call   8006f1 <_panic>
			panic("read /big from %d returned bad data %d",
  800673:	83 ec 0c             	sub    $0xc,%esp
  800676:	50                   	push   %eax
  800677:	53                   	push   %ebx
  800678:	68 14 2d 80 00       	push   $0x802d14
  80067d:	6a 7a                	push   $0x7a
  80067f:	68 c5 29 80 00       	push   $0x8029c5
  800684:	e8 68 00 00 00       	call   8006f1 <_panic>

00800689 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800689:	f3 0f 1e fb          	endbr32 
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	56                   	push   %esi
  800691:	53                   	push   %ebx
  800692:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800695:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800698:	e8 68 0b 00 00       	call   801205 <sys_getenvid>
  80069d:	25 ff 03 00 00       	and    $0x3ff,%eax
  8006a2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8006a5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8006aa:	a3 08 50 80 00       	mov    %eax,0x805008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8006af:	85 db                	test   %ebx,%ebx
  8006b1:	7e 07                	jle    8006ba <libmain+0x31>
		binaryname = argv[0];
  8006b3:	8b 06                	mov    (%esi),%eax
  8006b5:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  8006ba:	83 ec 08             	sub    $0x8,%esp
  8006bd:	56                   	push   %esi
  8006be:	53                   	push   %ebx
  8006bf:	e8 ba f9 ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  8006c4:	e8 0a 00 00 00       	call   8006d3 <exit>
}
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006cf:	5b                   	pop    %ebx
  8006d0:	5e                   	pop    %esi
  8006d1:	5d                   	pop    %ebp
  8006d2:	c3                   	ret    

008006d3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8006d3:	f3 0f 1e fb          	endbr32 
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  8006dd:	e8 f6 0f 00 00       	call   8016d8 <close_all>
	sys_env_destroy(0);
  8006e2:	83 ec 0c             	sub    $0xc,%esp
  8006e5:	6a 00                	push   $0x0
  8006e7:	e8 f5 0a 00 00       	call   8011e1 <sys_env_destroy>
}
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	c9                   	leave  
  8006f0:	c3                   	ret    

008006f1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8006f1:	f3 0f 1e fb          	endbr32 
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	56                   	push   %esi
  8006f9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8006fa:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8006fd:	8b 35 04 40 80 00    	mov    0x804004,%esi
  800703:	e8 fd 0a 00 00       	call   801205 <sys_getenvid>
  800708:	83 ec 0c             	sub    $0xc,%esp
  80070b:	ff 75 0c             	pushl  0xc(%ebp)
  80070e:	ff 75 08             	pushl  0x8(%ebp)
  800711:	56                   	push   %esi
  800712:	50                   	push   %eax
  800713:	68 6c 2d 80 00       	push   $0x802d6c
  800718:	e8 bb 00 00 00       	call   8007d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80071d:	83 c4 18             	add    $0x18,%esp
  800720:	53                   	push   %ebx
  800721:	ff 75 10             	pushl  0x10(%ebp)
  800724:	e8 5a 00 00 00       	call   800783 <vcprintf>
	cprintf("\n");
  800729:	c7 04 24 2c 32 80 00 	movl   $0x80322c,(%esp)
  800730:	e8 a3 00 00 00       	call   8007d8 <cprintf>
  800735:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800738:	cc                   	int3   
  800739:	eb fd                	jmp    800738 <_panic+0x47>

0080073b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80073b:	f3 0f 1e fb          	endbr32 
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	53                   	push   %ebx
  800743:	83 ec 04             	sub    $0x4,%esp
  800746:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800749:	8b 13                	mov    (%ebx),%edx
  80074b:	8d 42 01             	lea    0x1(%edx),%eax
  80074e:	89 03                	mov    %eax,(%ebx)
  800750:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800753:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800757:	3d ff 00 00 00       	cmp    $0xff,%eax
  80075c:	74 09                	je     800767 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80075e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800762:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800765:	c9                   	leave  
  800766:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800767:	83 ec 08             	sub    $0x8,%esp
  80076a:	68 ff 00 00 00       	push   $0xff
  80076f:	8d 43 08             	lea    0x8(%ebx),%eax
  800772:	50                   	push   %eax
  800773:	e8 24 0a 00 00       	call   80119c <sys_cputs>
		b->idx = 0;
  800778:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80077e:	83 c4 10             	add    $0x10,%esp
  800781:	eb db                	jmp    80075e <putch+0x23>

00800783 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800783:	f3 0f 1e fb          	endbr32 
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800790:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800797:	00 00 00 
	b.cnt = 0;
  80079a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8007a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8007a4:	ff 75 0c             	pushl  0xc(%ebp)
  8007a7:	ff 75 08             	pushl  0x8(%ebp)
  8007aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8007b0:	50                   	push   %eax
  8007b1:	68 3b 07 80 00       	push   $0x80073b
  8007b6:	e8 20 01 00 00       	call   8008db <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8007bb:	83 c4 08             	add    $0x8,%esp
  8007be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8007c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8007ca:	50                   	push   %eax
  8007cb:	e8 cc 09 00 00       	call   80119c <sys_cputs>

	return b.cnt;
}
  8007d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8007d8:	f3 0f 1e fb          	endbr32 
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8007e2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8007e5:	50                   	push   %eax
  8007e6:	ff 75 08             	pushl  0x8(%ebp)
  8007e9:	e8 95 ff ff ff       	call   800783 <vcprintf>
	va_end(ap);

	return cnt;
}
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	57                   	push   %edi
  8007f4:	56                   	push   %esi
  8007f5:	53                   	push   %ebx
  8007f6:	83 ec 1c             	sub    $0x1c,%esp
  8007f9:	89 c7                	mov    %eax,%edi
  8007fb:	89 d6                	mov    %edx,%esi
  8007fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800800:	8b 55 0c             	mov    0xc(%ebp),%edx
  800803:	89 d1                	mov    %edx,%ecx
  800805:	89 c2                	mov    %eax,%edx
  800807:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80080a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80080d:	8b 45 10             	mov    0x10(%ebp),%eax
  800810:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800813:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800816:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80081d:	39 c2                	cmp    %eax,%edx
  80081f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800822:	72 3e                	jb     800862 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800824:	83 ec 0c             	sub    $0xc,%esp
  800827:	ff 75 18             	pushl  0x18(%ebp)
  80082a:	83 eb 01             	sub    $0x1,%ebx
  80082d:	53                   	push   %ebx
  80082e:	50                   	push   %eax
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	ff 75 e4             	pushl  -0x1c(%ebp)
  800835:	ff 75 e0             	pushl  -0x20(%ebp)
  800838:	ff 75 dc             	pushl  -0x24(%ebp)
  80083b:	ff 75 d8             	pushl  -0x28(%ebp)
  80083e:	e8 ed 1e 00 00       	call   802730 <__udivdi3>
  800843:	83 c4 18             	add    $0x18,%esp
  800846:	52                   	push   %edx
  800847:	50                   	push   %eax
  800848:	89 f2                	mov    %esi,%edx
  80084a:	89 f8                	mov    %edi,%eax
  80084c:	e8 9f ff ff ff       	call   8007f0 <printnum>
  800851:	83 c4 20             	add    $0x20,%esp
  800854:	eb 13                	jmp    800869 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800856:	83 ec 08             	sub    $0x8,%esp
  800859:	56                   	push   %esi
  80085a:	ff 75 18             	pushl  0x18(%ebp)
  80085d:	ff d7                	call   *%edi
  80085f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800862:	83 eb 01             	sub    $0x1,%ebx
  800865:	85 db                	test   %ebx,%ebx
  800867:	7f ed                	jg     800856 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800869:	83 ec 08             	sub    $0x8,%esp
  80086c:	56                   	push   %esi
  80086d:	83 ec 04             	sub    $0x4,%esp
  800870:	ff 75 e4             	pushl  -0x1c(%ebp)
  800873:	ff 75 e0             	pushl  -0x20(%ebp)
  800876:	ff 75 dc             	pushl  -0x24(%ebp)
  800879:	ff 75 d8             	pushl  -0x28(%ebp)
  80087c:	e8 bf 1f 00 00       	call   802840 <__umoddi3>
  800881:	83 c4 14             	add    $0x14,%esp
  800884:	0f be 80 8f 2d 80 00 	movsbl 0x802d8f(%eax),%eax
  80088b:	50                   	push   %eax
  80088c:	ff d7                	call   *%edi
}
  80088e:	83 c4 10             	add    $0x10,%esp
  800891:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800894:	5b                   	pop    %ebx
  800895:	5e                   	pop    %esi
  800896:	5f                   	pop    %edi
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800899:	f3 0f 1e fb          	endbr32 
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8008a3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8008a7:	8b 10                	mov    (%eax),%edx
  8008a9:	3b 50 04             	cmp    0x4(%eax),%edx
  8008ac:	73 0a                	jae    8008b8 <sprintputch+0x1f>
		*b->buf++ = ch;
  8008ae:	8d 4a 01             	lea    0x1(%edx),%ecx
  8008b1:	89 08                	mov    %ecx,(%eax)
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	88 02                	mov    %al,(%edx)
}
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <printfmt>:
{
  8008ba:	f3 0f 1e fb          	endbr32 
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8008c4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8008c7:	50                   	push   %eax
  8008c8:	ff 75 10             	pushl  0x10(%ebp)
  8008cb:	ff 75 0c             	pushl  0xc(%ebp)
  8008ce:	ff 75 08             	pushl  0x8(%ebp)
  8008d1:	e8 05 00 00 00       	call   8008db <vprintfmt>
}
  8008d6:	83 c4 10             	add    $0x10,%esp
  8008d9:	c9                   	leave  
  8008da:	c3                   	ret    

008008db <vprintfmt>:
{
  8008db:	f3 0f 1e fb          	endbr32 
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	57                   	push   %edi
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
  8008e5:	83 ec 3c             	sub    $0x3c,%esp
  8008e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008f1:	e9 8e 03 00 00       	jmp    800c84 <vprintfmt+0x3a9>
		padc = ' ';
  8008f6:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8008fa:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800901:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800908:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80090f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800914:	8d 47 01             	lea    0x1(%edi),%eax
  800917:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80091a:	0f b6 17             	movzbl (%edi),%edx
  80091d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800920:	3c 55                	cmp    $0x55,%al
  800922:	0f 87 df 03 00 00    	ja     800d07 <vprintfmt+0x42c>
  800928:	0f b6 c0             	movzbl %al,%eax
  80092b:	3e ff 24 85 e0 2e 80 	notrack jmp *0x802ee0(,%eax,4)
  800932:	00 
  800933:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800936:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80093a:	eb d8                	jmp    800914 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80093c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80093f:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800943:	eb cf                	jmp    800914 <vprintfmt+0x39>
  800945:	0f b6 d2             	movzbl %dl,%edx
  800948:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80094b:	b8 00 00 00 00       	mov    $0x0,%eax
  800950:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800953:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800956:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80095a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80095d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800960:	83 f9 09             	cmp    $0x9,%ecx
  800963:	77 55                	ja     8009ba <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800965:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800968:	eb e9                	jmp    800953 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80096a:	8b 45 14             	mov    0x14(%ebp),%eax
  80096d:	8b 00                	mov    (%eax),%eax
  80096f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800972:	8b 45 14             	mov    0x14(%ebp),%eax
  800975:	8d 40 04             	lea    0x4(%eax),%eax
  800978:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80097b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80097e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800982:	79 90                	jns    800914 <vprintfmt+0x39>
				width = precision, precision = -1;
  800984:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800987:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80098a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800991:	eb 81                	jmp    800914 <vprintfmt+0x39>
  800993:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800996:	85 c0                	test   %eax,%eax
  800998:	ba 00 00 00 00       	mov    $0x0,%edx
  80099d:	0f 49 d0             	cmovns %eax,%edx
  8009a0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8009a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8009a6:	e9 69 ff ff ff       	jmp    800914 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8009ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8009ae:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8009b5:	e9 5a ff ff ff       	jmp    800914 <vprintfmt+0x39>
  8009ba:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8009bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009c0:	eb bc                	jmp    80097e <vprintfmt+0xa3>
			lflag++;
  8009c2:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8009c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8009c8:	e9 47 ff ff ff       	jmp    800914 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8009cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d0:	8d 78 04             	lea    0x4(%eax),%edi
  8009d3:	83 ec 08             	sub    $0x8,%esp
  8009d6:	53                   	push   %ebx
  8009d7:	ff 30                	pushl  (%eax)
  8009d9:	ff d6                	call   *%esi
			break;
  8009db:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8009de:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8009e1:	e9 9b 02 00 00       	jmp    800c81 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8009e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e9:	8d 78 04             	lea    0x4(%eax),%edi
  8009ec:	8b 00                	mov    (%eax),%eax
  8009ee:	99                   	cltd   
  8009ef:	31 d0                	xor    %edx,%eax
  8009f1:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009f3:	83 f8 0f             	cmp    $0xf,%eax
  8009f6:	7f 23                	jg     800a1b <vprintfmt+0x140>
  8009f8:	8b 14 85 40 30 80 00 	mov    0x803040(,%eax,4),%edx
  8009ff:	85 d2                	test   %edx,%edx
  800a01:	74 18                	je     800a1b <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800a03:	52                   	push   %edx
  800a04:	68 61 31 80 00       	push   $0x803161
  800a09:	53                   	push   %ebx
  800a0a:	56                   	push   %esi
  800a0b:	e8 aa fe ff ff       	call   8008ba <printfmt>
  800a10:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800a13:	89 7d 14             	mov    %edi,0x14(%ebp)
  800a16:	e9 66 02 00 00       	jmp    800c81 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800a1b:	50                   	push   %eax
  800a1c:	68 a7 2d 80 00       	push   $0x802da7
  800a21:	53                   	push   %ebx
  800a22:	56                   	push   %esi
  800a23:	e8 92 fe ff ff       	call   8008ba <printfmt>
  800a28:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800a2b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800a2e:	e9 4e 02 00 00       	jmp    800c81 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800a33:	8b 45 14             	mov    0x14(%ebp),%eax
  800a36:	83 c0 04             	add    $0x4,%eax
  800a39:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800a3c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a3f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800a41:	85 d2                	test   %edx,%edx
  800a43:	b8 a0 2d 80 00       	mov    $0x802da0,%eax
  800a48:	0f 45 c2             	cmovne %edx,%eax
  800a4b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800a4e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a52:	7e 06                	jle    800a5a <vprintfmt+0x17f>
  800a54:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800a58:	75 0d                	jne    800a67 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a5a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800a5d:	89 c7                	mov    %eax,%edi
  800a5f:	03 45 e0             	add    -0x20(%ebp),%eax
  800a62:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a65:	eb 55                	jmp    800abc <vprintfmt+0x1e1>
  800a67:	83 ec 08             	sub    $0x8,%esp
  800a6a:	ff 75 d8             	pushl  -0x28(%ebp)
  800a6d:	ff 75 cc             	pushl  -0x34(%ebp)
  800a70:	e8 46 03 00 00       	call   800dbb <strnlen>
  800a75:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800a78:	29 c2                	sub    %eax,%edx
  800a7a:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800a7d:	83 c4 10             	add    $0x10,%esp
  800a80:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800a82:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800a86:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800a89:	85 ff                	test   %edi,%edi
  800a8b:	7e 11                	jle    800a9e <vprintfmt+0x1c3>
					putch(padc, putdat);
  800a8d:	83 ec 08             	sub    $0x8,%esp
  800a90:	53                   	push   %ebx
  800a91:	ff 75 e0             	pushl  -0x20(%ebp)
  800a94:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800a96:	83 ef 01             	sub    $0x1,%edi
  800a99:	83 c4 10             	add    $0x10,%esp
  800a9c:	eb eb                	jmp    800a89 <vprintfmt+0x1ae>
  800a9e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800aa1:	85 d2                	test   %edx,%edx
  800aa3:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa8:	0f 49 c2             	cmovns %edx,%eax
  800aab:	29 c2                	sub    %eax,%edx
  800aad:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800ab0:	eb a8                	jmp    800a5a <vprintfmt+0x17f>
					putch(ch, putdat);
  800ab2:	83 ec 08             	sub    $0x8,%esp
  800ab5:	53                   	push   %ebx
  800ab6:	52                   	push   %edx
  800ab7:	ff d6                	call   *%esi
  800ab9:	83 c4 10             	add    $0x10,%esp
  800abc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800abf:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ac1:	83 c7 01             	add    $0x1,%edi
  800ac4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ac8:	0f be d0             	movsbl %al,%edx
  800acb:	85 d2                	test   %edx,%edx
  800acd:	74 4b                	je     800b1a <vprintfmt+0x23f>
  800acf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800ad3:	78 06                	js     800adb <vprintfmt+0x200>
  800ad5:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800ad9:	78 1e                	js     800af9 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  800adb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800adf:	74 d1                	je     800ab2 <vprintfmt+0x1d7>
  800ae1:	0f be c0             	movsbl %al,%eax
  800ae4:	83 e8 20             	sub    $0x20,%eax
  800ae7:	83 f8 5e             	cmp    $0x5e,%eax
  800aea:	76 c6                	jbe    800ab2 <vprintfmt+0x1d7>
					putch('?', putdat);
  800aec:	83 ec 08             	sub    $0x8,%esp
  800aef:	53                   	push   %ebx
  800af0:	6a 3f                	push   $0x3f
  800af2:	ff d6                	call   *%esi
  800af4:	83 c4 10             	add    $0x10,%esp
  800af7:	eb c3                	jmp    800abc <vprintfmt+0x1e1>
  800af9:	89 cf                	mov    %ecx,%edi
  800afb:	eb 0e                	jmp    800b0b <vprintfmt+0x230>
				putch(' ', putdat);
  800afd:	83 ec 08             	sub    $0x8,%esp
  800b00:	53                   	push   %ebx
  800b01:	6a 20                	push   $0x20
  800b03:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800b05:	83 ef 01             	sub    $0x1,%edi
  800b08:	83 c4 10             	add    $0x10,%esp
  800b0b:	85 ff                	test   %edi,%edi
  800b0d:	7f ee                	jg     800afd <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800b0f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800b12:	89 45 14             	mov    %eax,0x14(%ebp)
  800b15:	e9 67 01 00 00       	jmp    800c81 <vprintfmt+0x3a6>
  800b1a:	89 cf                	mov    %ecx,%edi
  800b1c:	eb ed                	jmp    800b0b <vprintfmt+0x230>
	if (lflag >= 2)
  800b1e:	83 f9 01             	cmp    $0x1,%ecx
  800b21:	7f 1b                	jg     800b3e <vprintfmt+0x263>
	else if (lflag)
  800b23:	85 c9                	test   %ecx,%ecx
  800b25:	74 63                	je     800b8a <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800b27:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2a:	8b 00                	mov    (%eax),%eax
  800b2c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b2f:	99                   	cltd   
  800b30:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b33:	8b 45 14             	mov    0x14(%ebp),%eax
  800b36:	8d 40 04             	lea    0x4(%eax),%eax
  800b39:	89 45 14             	mov    %eax,0x14(%ebp)
  800b3c:	eb 17                	jmp    800b55 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800b3e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b41:	8b 50 04             	mov    0x4(%eax),%edx
  800b44:	8b 00                	mov    (%eax),%eax
  800b46:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b49:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b4c:	8b 45 14             	mov    0x14(%ebp),%eax
  800b4f:	8d 40 08             	lea    0x8(%eax),%eax
  800b52:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800b55:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b58:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800b5b:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800b60:	85 c9                	test   %ecx,%ecx
  800b62:	0f 89 ff 00 00 00    	jns    800c67 <vprintfmt+0x38c>
				putch('-', putdat);
  800b68:	83 ec 08             	sub    $0x8,%esp
  800b6b:	53                   	push   %ebx
  800b6c:	6a 2d                	push   $0x2d
  800b6e:	ff d6                	call   *%esi
				num = -(long long) num;
  800b70:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b73:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b76:	f7 da                	neg    %edx
  800b78:	83 d1 00             	adc    $0x0,%ecx
  800b7b:	f7 d9                	neg    %ecx
  800b7d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800b80:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b85:	e9 dd 00 00 00       	jmp    800c67 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800b8a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b8d:	8b 00                	mov    (%eax),%eax
  800b8f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b92:	99                   	cltd   
  800b93:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b96:	8b 45 14             	mov    0x14(%ebp),%eax
  800b99:	8d 40 04             	lea    0x4(%eax),%eax
  800b9c:	89 45 14             	mov    %eax,0x14(%ebp)
  800b9f:	eb b4                	jmp    800b55 <vprintfmt+0x27a>
	if (lflag >= 2)
  800ba1:	83 f9 01             	cmp    $0x1,%ecx
  800ba4:	7f 1e                	jg     800bc4 <vprintfmt+0x2e9>
	else if (lflag)
  800ba6:	85 c9                	test   %ecx,%ecx
  800ba8:	74 32                	je     800bdc <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800baa:	8b 45 14             	mov    0x14(%ebp),%eax
  800bad:	8b 10                	mov    (%eax),%edx
  800baf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb4:	8d 40 04             	lea    0x4(%eax),%eax
  800bb7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800bba:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800bbf:	e9 a3 00 00 00       	jmp    800c67 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800bc4:	8b 45 14             	mov    0x14(%ebp),%eax
  800bc7:	8b 10                	mov    (%eax),%edx
  800bc9:	8b 48 04             	mov    0x4(%eax),%ecx
  800bcc:	8d 40 08             	lea    0x8(%eax),%eax
  800bcf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800bd2:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800bd7:	e9 8b 00 00 00       	jmp    800c67 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800bdc:	8b 45 14             	mov    0x14(%ebp),%eax
  800bdf:	8b 10                	mov    (%eax),%edx
  800be1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be6:	8d 40 04             	lea    0x4(%eax),%eax
  800be9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800bec:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800bf1:	eb 74                	jmp    800c67 <vprintfmt+0x38c>
	if (lflag >= 2)
  800bf3:	83 f9 01             	cmp    $0x1,%ecx
  800bf6:	7f 1b                	jg     800c13 <vprintfmt+0x338>
	else if (lflag)
  800bf8:	85 c9                	test   %ecx,%ecx
  800bfa:	74 2c                	je     800c28 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800bfc:	8b 45 14             	mov    0x14(%ebp),%eax
  800bff:	8b 10                	mov    (%eax),%edx
  800c01:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c06:	8d 40 04             	lea    0x4(%eax),%eax
  800c09:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800c0c:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800c11:	eb 54                	jmp    800c67 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800c13:	8b 45 14             	mov    0x14(%ebp),%eax
  800c16:	8b 10                	mov    (%eax),%edx
  800c18:	8b 48 04             	mov    0x4(%eax),%ecx
  800c1b:	8d 40 08             	lea    0x8(%eax),%eax
  800c1e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800c21:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800c26:	eb 3f                	jmp    800c67 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800c28:	8b 45 14             	mov    0x14(%ebp),%eax
  800c2b:	8b 10                	mov    (%eax),%edx
  800c2d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c32:	8d 40 04             	lea    0x4(%eax),%eax
  800c35:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800c38:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800c3d:	eb 28                	jmp    800c67 <vprintfmt+0x38c>
			putch('0', putdat);
  800c3f:	83 ec 08             	sub    $0x8,%esp
  800c42:	53                   	push   %ebx
  800c43:	6a 30                	push   $0x30
  800c45:	ff d6                	call   *%esi
			putch('x', putdat);
  800c47:	83 c4 08             	add    $0x8,%esp
  800c4a:	53                   	push   %ebx
  800c4b:	6a 78                	push   $0x78
  800c4d:	ff d6                	call   *%esi
			num = (unsigned long long)
  800c4f:	8b 45 14             	mov    0x14(%ebp),%eax
  800c52:	8b 10                	mov    (%eax),%edx
  800c54:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800c59:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800c5c:	8d 40 04             	lea    0x4(%eax),%eax
  800c5f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c62:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800c6e:	57                   	push   %edi
  800c6f:	ff 75 e0             	pushl  -0x20(%ebp)
  800c72:	50                   	push   %eax
  800c73:	51                   	push   %ecx
  800c74:	52                   	push   %edx
  800c75:	89 da                	mov    %ebx,%edx
  800c77:	89 f0                	mov    %esi,%eax
  800c79:	e8 72 fb ff ff       	call   8007f0 <printnum>
			break;
  800c7e:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800c81:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  800c84:	83 c7 01             	add    $0x1,%edi
  800c87:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c8b:	83 f8 25             	cmp    $0x25,%eax
  800c8e:	0f 84 62 fc ff ff    	je     8008f6 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  800c94:	85 c0                	test   %eax,%eax
  800c96:	0f 84 8b 00 00 00    	je     800d27 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  800c9c:	83 ec 08             	sub    $0x8,%esp
  800c9f:	53                   	push   %ebx
  800ca0:	50                   	push   %eax
  800ca1:	ff d6                	call   *%esi
  800ca3:	83 c4 10             	add    $0x10,%esp
  800ca6:	eb dc                	jmp    800c84 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800ca8:	83 f9 01             	cmp    $0x1,%ecx
  800cab:	7f 1b                	jg     800cc8 <vprintfmt+0x3ed>
	else if (lflag)
  800cad:	85 c9                	test   %ecx,%ecx
  800caf:	74 2c                	je     800cdd <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800cb1:	8b 45 14             	mov    0x14(%ebp),%eax
  800cb4:	8b 10                	mov    (%eax),%edx
  800cb6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cbb:	8d 40 04             	lea    0x4(%eax),%eax
  800cbe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800cc1:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800cc6:	eb 9f                	jmp    800c67 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800cc8:	8b 45 14             	mov    0x14(%ebp),%eax
  800ccb:	8b 10                	mov    (%eax),%edx
  800ccd:	8b 48 04             	mov    0x4(%eax),%ecx
  800cd0:	8d 40 08             	lea    0x8(%eax),%eax
  800cd3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800cd6:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800cdb:	eb 8a                	jmp    800c67 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800cdd:	8b 45 14             	mov    0x14(%ebp),%eax
  800ce0:	8b 10                	mov    (%eax),%edx
  800ce2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce7:	8d 40 04             	lea    0x4(%eax),%eax
  800cea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800ced:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800cf2:	e9 70 ff ff ff       	jmp    800c67 <vprintfmt+0x38c>
			putch(ch, putdat);
  800cf7:	83 ec 08             	sub    $0x8,%esp
  800cfa:	53                   	push   %ebx
  800cfb:	6a 25                	push   $0x25
  800cfd:	ff d6                	call   *%esi
			break;
  800cff:	83 c4 10             	add    $0x10,%esp
  800d02:	e9 7a ff ff ff       	jmp    800c81 <vprintfmt+0x3a6>
			putch('%', putdat);
  800d07:	83 ec 08             	sub    $0x8,%esp
  800d0a:	53                   	push   %ebx
  800d0b:	6a 25                	push   $0x25
  800d0d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800d0f:	83 c4 10             	add    $0x10,%esp
  800d12:	89 f8                	mov    %edi,%eax
  800d14:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800d18:	74 05                	je     800d1f <vprintfmt+0x444>
  800d1a:	83 e8 01             	sub    $0x1,%eax
  800d1d:	eb f5                	jmp    800d14 <vprintfmt+0x439>
  800d1f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800d22:	e9 5a ff ff ff       	jmp    800c81 <vprintfmt+0x3a6>
}
  800d27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2a:	5b                   	pop    %ebx
  800d2b:	5e                   	pop    %esi
  800d2c:	5f                   	pop    %edi
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    

00800d2f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d2f:	f3 0f 1e fb          	endbr32 
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	83 ec 18             	sub    $0x18,%esp
  800d39:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d3f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d42:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d46:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d50:	85 c0                	test   %eax,%eax
  800d52:	74 26                	je     800d7a <vsnprintf+0x4b>
  800d54:	85 d2                	test   %edx,%edx
  800d56:	7e 22                	jle    800d7a <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d58:	ff 75 14             	pushl  0x14(%ebp)
  800d5b:	ff 75 10             	pushl  0x10(%ebp)
  800d5e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d61:	50                   	push   %eax
  800d62:	68 99 08 80 00       	push   $0x800899
  800d67:	e8 6f fb ff ff       	call   8008db <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d6f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d75:	83 c4 10             	add    $0x10,%esp
}
  800d78:	c9                   	leave  
  800d79:	c3                   	ret    
		return -E_INVAL;
  800d7a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d7f:	eb f7                	jmp    800d78 <vsnprintf+0x49>

00800d81 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d81:	f3 0f 1e fb          	endbr32 
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  800d8b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d8e:	50                   	push   %eax
  800d8f:	ff 75 10             	pushl  0x10(%ebp)
  800d92:	ff 75 0c             	pushl  0xc(%ebp)
  800d95:	ff 75 08             	pushl  0x8(%ebp)
  800d98:	e8 92 ff ff ff       	call   800d2f <vsnprintf>
	va_end(ap);

	return rc;
}
  800d9d:	c9                   	leave  
  800d9e:	c3                   	ret    

00800d9f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d9f:	f3 0f 1e fb          	endbr32 
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800da9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800db2:	74 05                	je     800db9 <strlen+0x1a>
		n++;
  800db4:	83 c0 01             	add    $0x1,%eax
  800db7:	eb f5                	jmp    800dae <strlen+0xf>
	return n;
}
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800dbb:	f3 0f 1e fb          	endbr32 
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800dc8:	b8 00 00 00 00       	mov    $0x0,%eax
  800dcd:	39 d0                	cmp    %edx,%eax
  800dcf:	74 0d                	je     800dde <strnlen+0x23>
  800dd1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800dd5:	74 05                	je     800ddc <strnlen+0x21>
		n++;
  800dd7:	83 c0 01             	add    $0x1,%eax
  800dda:	eb f1                	jmp    800dcd <strnlen+0x12>
  800ddc:	89 c2                	mov    %eax,%edx
	return n;
}
  800dde:	89 d0                	mov    %edx,%eax
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800de2:	f3 0f 1e fb          	endbr32 
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	53                   	push   %ebx
  800dea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ded:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800df0:	b8 00 00 00 00       	mov    $0x0,%eax
  800df5:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800df9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800dfc:	83 c0 01             	add    $0x1,%eax
  800dff:	84 d2                	test   %dl,%dl
  800e01:	75 f2                	jne    800df5 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800e03:	89 c8                	mov    %ecx,%eax
  800e05:	5b                   	pop    %ebx
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    

00800e08 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800e08:	f3 0f 1e fb          	endbr32 
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 10             	sub    $0x10,%esp
  800e13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800e16:	53                   	push   %ebx
  800e17:	e8 83 ff ff ff       	call   800d9f <strlen>
  800e1c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800e1f:	ff 75 0c             	pushl  0xc(%ebp)
  800e22:	01 d8                	add    %ebx,%eax
  800e24:	50                   	push   %eax
  800e25:	e8 b8 ff ff ff       	call   800de2 <strcpy>
	return dst;
}
  800e2a:	89 d8                	mov    %ebx,%eax
  800e2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e2f:	c9                   	leave  
  800e30:	c3                   	ret    

00800e31 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e31:	f3 0f 1e fb          	endbr32 
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	56                   	push   %esi
  800e39:	53                   	push   %ebx
  800e3a:	8b 75 08             	mov    0x8(%ebp),%esi
  800e3d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e40:	89 f3                	mov    %esi,%ebx
  800e42:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e45:	89 f0                	mov    %esi,%eax
  800e47:	39 d8                	cmp    %ebx,%eax
  800e49:	74 11                	je     800e5c <strncpy+0x2b>
		*dst++ = *src;
  800e4b:	83 c0 01             	add    $0x1,%eax
  800e4e:	0f b6 0a             	movzbl (%edx),%ecx
  800e51:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800e54:	80 f9 01             	cmp    $0x1,%cl
  800e57:	83 da ff             	sbb    $0xffffffff,%edx
  800e5a:	eb eb                	jmp    800e47 <strncpy+0x16>
	}
	return ret;
}
  800e5c:	89 f0                	mov    %esi,%eax
  800e5e:	5b                   	pop    %ebx
  800e5f:	5e                   	pop    %esi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e62:	f3 0f 1e fb          	endbr32 
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	56                   	push   %esi
  800e6a:	53                   	push   %ebx
  800e6b:	8b 75 08             	mov    0x8(%ebp),%esi
  800e6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e71:	8b 55 10             	mov    0x10(%ebp),%edx
  800e74:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e76:	85 d2                	test   %edx,%edx
  800e78:	74 21                	je     800e9b <strlcpy+0x39>
  800e7a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800e7e:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800e80:	39 c2                	cmp    %eax,%edx
  800e82:	74 14                	je     800e98 <strlcpy+0x36>
  800e84:	0f b6 19             	movzbl (%ecx),%ebx
  800e87:	84 db                	test   %bl,%bl
  800e89:	74 0b                	je     800e96 <strlcpy+0x34>
			*dst++ = *src++;
  800e8b:	83 c1 01             	add    $0x1,%ecx
  800e8e:	83 c2 01             	add    $0x1,%edx
  800e91:	88 5a ff             	mov    %bl,-0x1(%edx)
  800e94:	eb ea                	jmp    800e80 <strlcpy+0x1e>
  800e96:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800e98:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e9b:	29 f0                	sub    %esi,%eax
}
  800e9d:	5b                   	pop    %ebx
  800e9e:	5e                   	pop    %esi
  800e9f:	5d                   	pop    %ebp
  800ea0:	c3                   	ret    

00800ea1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ea1:	f3 0f 1e fb          	endbr32 
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eab:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800eae:	0f b6 01             	movzbl (%ecx),%eax
  800eb1:	84 c0                	test   %al,%al
  800eb3:	74 0c                	je     800ec1 <strcmp+0x20>
  800eb5:	3a 02                	cmp    (%edx),%al
  800eb7:	75 08                	jne    800ec1 <strcmp+0x20>
		p++, q++;
  800eb9:	83 c1 01             	add    $0x1,%ecx
  800ebc:	83 c2 01             	add    $0x1,%edx
  800ebf:	eb ed                	jmp    800eae <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ec1:	0f b6 c0             	movzbl %al,%eax
  800ec4:	0f b6 12             	movzbl (%edx),%edx
  800ec7:	29 d0                	sub    %edx,%eax
}
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ecb:	f3 0f 1e fb          	endbr32 
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	53                   	push   %ebx
  800ed3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed9:	89 c3                	mov    %eax,%ebx
  800edb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ede:	eb 06                	jmp    800ee6 <strncmp+0x1b>
		n--, p++, q++;
  800ee0:	83 c0 01             	add    $0x1,%eax
  800ee3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ee6:	39 d8                	cmp    %ebx,%eax
  800ee8:	74 16                	je     800f00 <strncmp+0x35>
  800eea:	0f b6 08             	movzbl (%eax),%ecx
  800eed:	84 c9                	test   %cl,%cl
  800eef:	74 04                	je     800ef5 <strncmp+0x2a>
  800ef1:	3a 0a                	cmp    (%edx),%cl
  800ef3:	74 eb                	je     800ee0 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ef5:	0f b6 00             	movzbl (%eax),%eax
  800ef8:	0f b6 12             	movzbl (%edx),%edx
  800efb:	29 d0                	sub    %edx,%eax
}
  800efd:	5b                   	pop    %ebx
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    
		return 0;
  800f00:	b8 00 00 00 00       	mov    $0x0,%eax
  800f05:	eb f6                	jmp    800efd <strncmp+0x32>

00800f07 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800f07:	f3 0f 1e fb          	endbr32 
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f15:	0f b6 10             	movzbl (%eax),%edx
  800f18:	84 d2                	test   %dl,%dl
  800f1a:	74 09                	je     800f25 <strchr+0x1e>
		if (*s == c)
  800f1c:	38 ca                	cmp    %cl,%dl
  800f1e:	74 0a                	je     800f2a <strchr+0x23>
	for (; *s; s++)
  800f20:	83 c0 01             	add    $0x1,%eax
  800f23:	eb f0                	jmp    800f15 <strchr+0xe>
			return (char *) s;
	return 0;
  800f25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800f2c:	f3 0f 1e fb          	endbr32 
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800f36:	6a 78                	push   $0x78
  800f38:	ff 75 08             	pushl  0x8(%ebp)
  800f3b:	e8 c7 ff ff ff       	call   800f07 <strchr>
  800f40:	83 c4 10             	add    $0x10,%esp
  800f43:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  800f46:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800f4b:	eb 0d                	jmp    800f5a <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800f4d:	c1 e0 04             	shl    $0x4,%eax
  800f50:	0f be d2             	movsbl %dl,%edx
  800f53:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800f57:	83 c1 01             	add    $0x1,%ecx
  800f5a:	0f b6 11             	movzbl (%ecx),%edx
  800f5d:	84 d2                	test   %dl,%dl
  800f5f:	74 11                	je     800f72 <atox+0x46>
		if (*p>='a'){
  800f61:	80 fa 60             	cmp    $0x60,%dl
  800f64:	7e e7                	jle    800f4d <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800f66:	c1 e0 04             	shl    $0x4,%eax
  800f69:	0f be d2             	movsbl %dl,%edx
  800f6c:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800f70:	eb e5                	jmp    800f57 <atox+0x2b>
	}

	return v;

}
  800f72:	c9                   	leave  
  800f73:	c3                   	ret    

00800f74 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f74:	f3 0f 1e fb          	endbr32 
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f82:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800f85:	38 ca                	cmp    %cl,%dl
  800f87:	74 09                	je     800f92 <strfind+0x1e>
  800f89:	84 d2                	test   %dl,%dl
  800f8b:	74 05                	je     800f92 <strfind+0x1e>
	for (; *s; s++)
  800f8d:	83 c0 01             	add    $0x1,%eax
  800f90:	eb f0                	jmp    800f82 <strfind+0xe>
			break;
	return (char *) s;
}
  800f92:	5d                   	pop    %ebp
  800f93:	c3                   	ret    

00800f94 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f94:	f3 0f 1e fb          	endbr32 
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	57                   	push   %edi
  800f9c:	56                   	push   %esi
  800f9d:	53                   	push   %ebx
  800f9e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800fa1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800fa4:	85 c9                	test   %ecx,%ecx
  800fa6:	74 31                	je     800fd9 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800fa8:	89 f8                	mov    %edi,%eax
  800faa:	09 c8                	or     %ecx,%eax
  800fac:	a8 03                	test   $0x3,%al
  800fae:	75 23                	jne    800fd3 <memset+0x3f>
		c &= 0xFF;
  800fb0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800fb4:	89 d3                	mov    %edx,%ebx
  800fb6:	c1 e3 08             	shl    $0x8,%ebx
  800fb9:	89 d0                	mov    %edx,%eax
  800fbb:	c1 e0 18             	shl    $0x18,%eax
  800fbe:	89 d6                	mov    %edx,%esi
  800fc0:	c1 e6 10             	shl    $0x10,%esi
  800fc3:	09 f0                	or     %esi,%eax
  800fc5:	09 c2                	or     %eax,%edx
  800fc7:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800fc9:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800fcc:	89 d0                	mov    %edx,%eax
  800fce:	fc                   	cld    
  800fcf:	f3 ab                	rep stos %eax,%es:(%edi)
  800fd1:	eb 06                	jmp    800fd9 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800fd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd6:	fc                   	cld    
  800fd7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800fd9:	89 f8                	mov    %edi,%eax
  800fdb:	5b                   	pop    %ebx
  800fdc:	5e                   	pop    %esi
  800fdd:	5f                   	pop    %edi
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    

00800fe0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800fe0:	f3 0f 1e fb          	endbr32 
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	57                   	push   %edi
  800fe8:	56                   	push   %esi
  800fe9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ff2:	39 c6                	cmp    %eax,%esi
  800ff4:	73 32                	jae    801028 <memmove+0x48>
  800ff6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ff9:	39 c2                	cmp    %eax,%edx
  800ffb:	76 2b                	jbe    801028 <memmove+0x48>
		s += n;
		d += n;
  800ffd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801000:	89 fe                	mov    %edi,%esi
  801002:	09 ce                	or     %ecx,%esi
  801004:	09 d6                	or     %edx,%esi
  801006:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80100c:	75 0e                	jne    80101c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80100e:	83 ef 04             	sub    $0x4,%edi
  801011:	8d 72 fc             	lea    -0x4(%edx),%esi
  801014:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801017:	fd                   	std    
  801018:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80101a:	eb 09                	jmp    801025 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80101c:	83 ef 01             	sub    $0x1,%edi
  80101f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801022:	fd                   	std    
  801023:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801025:	fc                   	cld    
  801026:	eb 1a                	jmp    801042 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801028:	89 c2                	mov    %eax,%edx
  80102a:	09 ca                	or     %ecx,%edx
  80102c:	09 f2                	or     %esi,%edx
  80102e:	f6 c2 03             	test   $0x3,%dl
  801031:	75 0a                	jne    80103d <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801033:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801036:	89 c7                	mov    %eax,%edi
  801038:	fc                   	cld    
  801039:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80103b:	eb 05                	jmp    801042 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  80103d:	89 c7                	mov    %eax,%edi
  80103f:	fc                   	cld    
  801040:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801042:	5e                   	pop    %esi
  801043:	5f                   	pop    %edi
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    

00801046 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801046:	f3 0f 1e fb          	endbr32 
  80104a:	55                   	push   %ebp
  80104b:	89 e5                	mov    %esp,%ebp
  80104d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801050:	ff 75 10             	pushl  0x10(%ebp)
  801053:	ff 75 0c             	pushl  0xc(%ebp)
  801056:	ff 75 08             	pushl  0x8(%ebp)
  801059:	e8 82 ff ff ff       	call   800fe0 <memmove>
}
  80105e:	c9                   	leave  
  80105f:	c3                   	ret    

00801060 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801060:	f3 0f 1e fb          	endbr32 
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	56                   	push   %esi
  801068:	53                   	push   %ebx
  801069:	8b 45 08             	mov    0x8(%ebp),%eax
  80106c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80106f:	89 c6                	mov    %eax,%esi
  801071:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801074:	39 f0                	cmp    %esi,%eax
  801076:	74 1c                	je     801094 <memcmp+0x34>
		if (*s1 != *s2)
  801078:	0f b6 08             	movzbl (%eax),%ecx
  80107b:	0f b6 1a             	movzbl (%edx),%ebx
  80107e:	38 d9                	cmp    %bl,%cl
  801080:	75 08                	jne    80108a <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801082:	83 c0 01             	add    $0x1,%eax
  801085:	83 c2 01             	add    $0x1,%edx
  801088:	eb ea                	jmp    801074 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  80108a:	0f b6 c1             	movzbl %cl,%eax
  80108d:	0f b6 db             	movzbl %bl,%ebx
  801090:	29 d8                	sub    %ebx,%eax
  801092:	eb 05                	jmp    801099 <memcmp+0x39>
	}

	return 0;
  801094:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801099:	5b                   	pop    %ebx
  80109a:	5e                   	pop    %esi
  80109b:	5d                   	pop    %ebp
  80109c:	c3                   	ret    

0080109d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80109d:	f3 0f 1e fb          	endbr32 
  8010a1:	55                   	push   %ebp
  8010a2:	89 e5                	mov    %esp,%ebp
  8010a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8010aa:	89 c2                	mov    %eax,%edx
  8010ac:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8010af:	39 d0                	cmp    %edx,%eax
  8010b1:	73 09                	jae    8010bc <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  8010b3:	38 08                	cmp    %cl,(%eax)
  8010b5:	74 05                	je     8010bc <memfind+0x1f>
	for (; s < ends; s++)
  8010b7:	83 c0 01             	add    $0x1,%eax
  8010ba:	eb f3                	jmp    8010af <memfind+0x12>
			break;
	return (void *) s;
}
  8010bc:	5d                   	pop    %ebp
  8010bd:	c3                   	ret    

008010be <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010be:	f3 0f 1e fb          	endbr32 
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	57                   	push   %edi
  8010c6:	56                   	push   %esi
  8010c7:	53                   	push   %ebx
  8010c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010ce:	eb 03                	jmp    8010d3 <strtol+0x15>
		s++;
  8010d0:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8010d3:	0f b6 01             	movzbl (%ecx),%eax
  8010d6:	3c 20                	cmp    $0x20,%al
  8010d8:	74 f6                	je     8010d0 <strtol+0x12>
  8010da:	3c 09                	cmp    $0x9,%al
  8010dc:	74 f2                	je     8010d0 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  8010de:	3c 2b                	cmp    $0x2b,%al
  8010e0:	74 2a                	je     80110c <strtol+0x4e>
	int neg = 0;
  8010e2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8010e7:	3c 2d                	cmp    $0x2d,%al
  8010e9:	74 2b                	je     801116 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010eb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8010f1:	75 0f                	jne    801102 <strtol+0x44>
  8010f3:	80 39 30             	cmpb   $0x30,(%ecx)
  8010f6:	74 28                	je     801120 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010f8:	85 db                	test   %ebx,%ebx
  8010fa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010ff:	0f 44 d8             	cmove  %eax,%ebx
  801102:	b8 00 00 00 00       	mov    $0x0,%eax
  801107:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80110a:	eb 46                	jmp    801152 <strtol+0x94>
		s++;
  80110c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  80110f:	bf 00 00 00 00       	mov    $0x0,%edi
  801114:	eb d5                	jmp    8010eb <strtol+0x2d>
		s++, neg = 1;
  801116:	83 c1 01             	add    $0x1,%ecx
  801119:	bf 01 00 00 00       	mov    $0x1,%edi
  80111e:	eb cb                	jmp    8010eb <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801120:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801124:	74 0e                	je     801134 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801126:	85 db                	test   %ebx,%ebx
  801128:	75 d8                	jne    801102 <strtol+0x44>
		s++, base = 8;
  80112a:	83 c1 01             	add    $0x1,%ecx
  80112d:	bb 08 00 00 00       	mov    $0x8,%ebx
  801132:	eb ce                	jmp    801102 <strtol+0x44>
		s += 2, base = 16;
  801134:	83 c1 02             	add    $0x2,%ecx
  801137:	bb 10 00 00 00       	mov    $0x10,%ebx
  80113c:	eb c4                	jmp    801102 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  80113e:	0f be d2             	movsbl %dl,%edx
  801141:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801144:	3b 55 10             	cmp    0x10(%ebp),%edx
  801147:	7d 3a                	jge    801183 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801149:	83 c1 01             	add    $0x1,%ecx
  80114c:	0f af 45 10          	imul   0x10(%ebp),%eax
  801150:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801152:	0f b6 11             	movzbl (%ecx),%edx
  801155:	8d 72 d0             	lea    -0x30(%edx),%esi
  801158:	89 f3                	mov    %esi,%ebx
  80115a:	80 fb 09             	cmp    $0x9,%bl
  80115d:	76 df                	jbe    80113e <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  80115f:	8d 72 9f             	lea    -0x61(%edx),%esi
  801162:	89 f3                	mov    %esi,%ebx
  801164:	80 fb 19             	cmp    $0x19,%bl
  801167:	77 08                	ja     801171 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801169:	0f be d2             	movsbl %dl,%edx
  80116c:	83 ea 57             	sub    $0x57,%edx
  80116f:	eb d3                	jmp    801144 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801171:	8d 72 bf             	lea    -0x41(%edx),%esi
  801174:	89 f3                	mov    %esi,%ebx
  801176:	80 fb 19             	cmp    $0x19,%bl
  801179:	77 08                	ja     801183 <strtol+0xc5>
			dig = *s - 'A' + 10;
  80117b:	0f be d2             	movsbl %dl,%edx
  80117e:	83 ea 37             	sub    $0x37,%edx
  801181:	eb c1                	jmp    801144 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801183:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801187:	74 05                	je     80118e <strtol+0xd0>
		*endptr = (char *) s;
  801189:	8b 75 0c             	mov    0xc(%ebp),%esi
  80118c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  80118e:	89 c2                	mov    %eax,%edx
  801190:	f7 da                	neg    %edx
  801192:	85 ff                	test   %edi,%edi
  801194:	0f 45 c2             	cmovne %edx,%eax
}
  801197:	5b                   	pop    %ebx
  801198:	5e                   	pop    %esi
  801199:	5f                   	pop    %edi
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    

0080119c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80119c:	f3 0f 1e fb          	endbr32 
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	57                   	push   %edi
  8011a4:	56                   	push   %esi
  8011a5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b1:	89 c3                	mov    %eax,%ebx
  8011b3:	89 c7                	mov    %eax,%edi
  8011b5:	89 c6                	mov    %eax,%esi
  8011b7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8011b9:	5b                   	pop    %ebx
  8011ba:	5e                   	pop    %esi
  8011bb:	5f                   	pop    %edi
  8011bc:	5d                   	pop    %ebp
  8011bd:	c3                   	ret    

008011be <sys_cgetc>:

int
sys_cgetc(void)
{
  8011be:	f3 0f 1e fb          	endbr32 
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	57                   	push   %edi
  8011c6:	56                   	push   %esi
  8011c7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8011cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d2:	89 d1                	mov    %edx,%ecx
  8011d4:	89 d3                	mov    %edx,%ebx
  8011d6:	89 d7                	mov    %edx,%edi
  8011d8:	89 d6                	mov    %edx,%esi
  8011da:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8011dc:	5b                   	pop    %ebx
  8011dd:	5e                   	pop    %esi
  8011de:	5f                   	pop    %edi
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    

008011e1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8011e1:	f3 0f 1e fb          	endbr32 
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	57                   	push   %edi
  8011e9:	56                   	push   %esi
  8011ea:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f3:	b8 03 00 00 00       	mov    $0x3,%eax
  8011f8:	89 cb                	mov    %ecx,%ebx
  8011fa:	89 cf                	mov    %ecx,%edi
  8011fc:	89 ce                	mov    %ecx,%esi
  8011fe:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801200:	5b                   	pop    %ebx
  801201:	5e                   	pop    %esi
  801202:	5f                   	pop    %edi
  801203:	5d                   	pop    %ebp
  801204:	c3                   	ret    

00801205 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801205:	f3 0f 1e fb          	endbr32 
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	57                   	push   %edi
  80120d:	56                   	push   %esi
  80120e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80120f:	ba 00 00 00 00       	mov    $0x0,%edx
  801214:	b8 02 00 00 00       	mov    $0x2,%eax
  801219:	89 d1                	mov    %edx,%ecx
  80121b:	89 d3                	mov    %edx,%ebx
  80121d:	89 d7                	mov    %edx,%edi
  80121f:	89 d6                	mov    %edx,%esi
  801221:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801223:	5b                   	pop    %ebx
  801224:	5e                   	pop    %esi
  801225:	5f                   	pop    %edi
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    

00801228 <sys_yield>:

void
sys_yield(void)
{
  801228:	f3 0f 1e fb          	endbr32 
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	57                   	push   %edi
  801230:	56                   	push   %esi
  801231:	53                   	push   %ebx
	asm volatile("int %1\n"
  801232:	ba 00 00 00 00       	mov    $0x0,%edx
  801237:	b8 0b 00 00 00       	mov    $0xb,%eax
  80123c:	89 d1                	mov    %edx,%ecx
  80123e:	89 d3                	mov    %edx,%ebx
  801240:	89 d7                	mov    %edx,%edi
  801242:	89 d6                	mov    %edx,%esi
  801244:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801246:	5b                   	pop    %ebx
  801247:	5e                   	pop    %esi
  801248:	5f                   	pop    %edi
  801249:	5d                   	pop    %ebp
  80124a:	c3                   	ret    

0080124b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80124b:	f3 0f 1e fb          	endbr32 
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	57                   	push   %edi
  801253:	56                   	push   %esi
  801254:	53                   	push   %ebx
	asm volatile("int %1\n"
  801255:	be 00 00 00 00       	mov    $0x0,%esi
  80125a:	8b 55 08             	mov    0x8(%ebp),%edx
  80125d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801260:	b8 04 00 00 00       	mov    $0x4,%eax
  801265:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801268:	89 f7                	mov    %esi,%edi
  80126a:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80126c:	5b                   	pop    %ebx
  80126d:	5e                   	pop    %esi
  80126e:	5f                   	pop    %edi
  80126f:	5d                   	pop    %ebp
  801270:	c3                   	ret    

00801271 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801271:	f3 0f 1e fb          	endbr32 
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	57                   	push   %edi
  801279:	56                   	push   %esi
  80127a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80127b:	8b 55 08             	mov    0x8(%ebp),%edx
  80127e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801281:	b8 05 00 00 00       	mov    $0x5,%eax
  801286:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801289:	8b 7d 14             	mov    0x14(%ebp),%edi
  80128c:	8b 75 18             	mov    0x18(%ebp),%esi
  80128f:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801291:	5b                   	pop    %ebx
  801292:	5e                   	pop    %esi
  801293:	5f                   	pop    %edi
  801294:	5d                   	pop    %ebp
  801295:	c3                   	ret    

00801296 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801296:	f3 0f 1e fb          	endbr32 
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	57                   	push   %edi
  80129e:	56                   	push   %esi
  80129f:	53                   	push   %ebx
	asm volatile("int %1\n"
  8012a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ab:	b8 06 00 00 00       	mov    $0x6,%eax
  8012b0:	89 df                	mov    %ebx,%edi
  8012b2:	89 de                	mov    %ebx,%esi
  8012b4:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8012b6:	5b                   	pop    %ebx
  8012b7:	5e                   	pop    %esi
  8012b8:	5f                   	pop    %edi
  8012b9:	5d                   	pop    %ebp
  8012ba:	c3                   	ret    

008012bb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012bb:	f3 0f 1e fb          	endbr32 
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	57                   	push   %edi
  8012c3:	56                   	push   %esi
  8012c4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8012c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8012cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d0:	b8 08 00 00 00       	mov    $0x8,%eax
  8012d5:	89 df                	mov    %ebx,%edi
  8012d7:	89 de                	mov    %ebx,%esi
  8012d9:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012db:	5b                   	pop    %ebx
  8012dc:	5e                   	pop    %esi
  8012dd:	5f                   	pop    %edi
  8012de:	5d                   	pop    %ebp
  8012df:	c3                   	ret    

008012e0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8012e0:	f3 0f 1e fb          	endbr32 
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	57                   	push   %edi
  8012e8:	56                   	push   %esi
  8012e9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8012ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f5:	b8 09 00 00 00       	mov    $0x9,%eax
  8012fa:	89 df                	mov    %ebx,%edi
  8012fc:	89 de                	mov    %ebx,%esi
  8012fe:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801300:	5b                   	pop    %ebx
  801301:	5e                   	pop    %esi
  801302:	5f                   	pop    %edi
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    

00801305 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801305:	f3 0f 1e fb          	endbr32 
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	57                   	push   %edi
  80130d:	56                   	push   %esi
  80130e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80130f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801314:	8b 55 08             	mov    0x8(%ebp),%edx
  801317:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80131a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80131f:	89 df                	mov    %ebx,%edi
  801321:	89 de                	mov    %ebx,%esi
  801323:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801325:	5b                   	pop    %ebx
  801326:	5e                   	pop    %esi
  801327:	5f                   	pop    %edi
  801328:	5d                   	pop    %ebp
  801329:	c3                   	ret    

0080132a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80132a:	f3 0f 1e fb          	endbr32 
  80132e:	55                   	push   %ebp
  80132f:	89 e5                	mov    %esp,%ebp
  801331:	57                   	push   %edi
  801332:	56                   	push   %esi
  801333:	53                   	push   %ebx
	asm volatile("int %1\n"
  801334:	8b 55 08             	mov    0x8(%ebp),%edx
  801337:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80133a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80133f:	be 00 00 00 00       	mov    $0x0,%esi
  801344:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801347:	8b 7d 14             	mov    0x14(%ebp),%edi
  80134a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80134c:	5b                   	pop    %ebx
  80134d:	5e                   	pop    %esi
  80134e:	5f                   	pop    %edi
  80134f:	5d                   	pop    %ebp
  801350:	c3                   	ret    

00801351 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801351:	f3 0f 1e fb          	endbr32 
  801355:	55                   	push   %ebp
  801356:	89 e5                	mov    %esp,%ebp
  801358:	57                   	push   %edi
  801359:	56                   	push   %esi
  80135a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80135b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801360:	8b 55 08             	mov    0x8(%ebp),%edx
  801363:	b8 0d 00 00 00       	mov    $0xd,%eax
  801368:	89 cb                	mov    %ecx,%ebx
  80136a:	89 cf                	mov    %ecx,%edi
  80136c:	89 ce                	mov    %ecx,%esi
  80136e:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801370:	5b                   	pop    %ebx
  801371:	5e                   	pop    %esi
  801372:	5f                   	pop    %edi
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    

00801375 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801375:	f3 0f 1e fb          	endbr32 
  801379:	55                   	push   %ebp
  80137a:	89 e5                	mov    %esp,%ebp
  80137c:	57                   	push   %edi
  80137d:	56                   	push   %esi
  80137e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80137f:	ba 00 00 00 00       	mov    $0x0,%edx
  801384:	b8 0e 00 00 00       	mov    $0xe,%eax
  801389:	89 d1                	mov    %edx,%ecx
  80138b:	89 d3                	mov    %edx,%ebx
  80138d:	89 d7                	mov    %edx,%edi
  80138f:	89 d6                	mov    %edx,%esi
  801391:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801393:	5b                   	pop    %ebx
  801394:	5e                   	pop    %esi
  801395:	5f                   	pop    %edi
  801396:	5d                   	pop    %ebp
  801397:	c3                   	ret    

00801398 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  801398:	f3 0f 1e fb          	endbr32 
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	57                   	push   %edi
  8013a0:	56                   	push   %esi
  8013a1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8013a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8013aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ad:	b8 0f 00 00 00       	mov    $0xf,%eax
  8013b2:	89 df                	mov    %ebx,%edi
  8013b4:	89 de                	mov    %ebx,%esi
  8013b6:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  8013b8:	5b                   	pop    %ebx
  8013b9:	5e                   	pop    %esi
  8013ba:	5f                   	pop    %edi
  8013bb:	5d                   	pop    %ebp
  8013bc:	c3                   	ret    

008013bd <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  8013bd:	f3 0f 1e fb          	endbr32 
  8013c1:	55                   	push   %ebp
  8013c2:	89 e5                	mov    %esp,%ebp
  8013c4:	57                   	push   %edi
  8013c5:	56                   	push   %esi
  8013c6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8013c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8013cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d2:	b8 10 00 00 00       	mov    $0x10,%eax
  8013d7:	89 df                	mov    %ebx,%edi
  8013d9:	89 de                	mov    %ebx,%esi
  8013db:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  8013dd:	5b                   	pop    %ebx
  8013de:	5e                   	pop    %esi
  8013df:	5f                   	pop    %edi
  8013e0:	5d                   	pop    %ebp
  8013e1:	c3                   	ret    

008013e2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8013e2:	f3 0f 1e fb          	endbr32 
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	56                   	push   %esi
  8013ea:	53                   	push   %ebx
  8013eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8013ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8013fb:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  8013fe:	83 ec 0c             	sub    $0xc,%esp
  801401:	50                   	push   %eax
  801402:	e8 4a ff ff ff       	call   801351 <sys_ipc_recv>
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	85 c0                	test   %eax,%eax
  80140c:	75 2b                	jne    801439 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  80140e:	85 f6                	test   %esi,%esi
  801410:	74 0a                	je     80141c <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  801412:	a1 08 50 80 00       	mov    0x805008,%eax
  801417:	8b 40 74             	mov    0x74(%eax),%eax
  80141a:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  80141c:	85 db                	test   %ebx,%ebx
  80141e:	74 0a                	je     80142a <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  801420:	a1 08 50 80 00       	mov    0x805008,%eax
  801425:	8b 40 78             	mov    0x78(%eax),%eax
  801428:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  80142a:	a1 08 50 80 00       	mov    0x805008,%eax
  80142f:	8b 40 70             	mov    0x70(%eax),%eax
}
  801432:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801435:	5b                   	pop    %ebx
  801436:	5e                   	pop    %esi
  801437:	5d                   	pop    %ebp
  801438:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  801439:	85 f6                	test   %esi,%esi
  80143b:	74 06                	je     801443 <ipc_recv+0x61>
  80143d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801443:	85 db                	test   %ebx,%ebx
  801445:	74 eb                	je     801432 <ipc_recv+0x50>
  801447:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80144d:	eb e3                	jmp    801432 <ipc_recv+0x50>

0080144f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80144f:	f3 0f 1e fb          	endbr32 
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	57                   	push   %edi
  801457:	56                   	push   %esi
  801458:	53                   	push   %ebx
  801459:	83 ec 0c             	sub    $0xc,%esp
  80145c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80145f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801462:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  801465:	85 db                	test   %ebx,%ebx
  801467:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80146c:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  80146f:	ff 75 14             	pushl  0x14(%ebp)
  801472:	53                   	push   %ebx
  801473:	56                   	push   %esi
  801474:	57                   	push   %edi
  801475:	e8 b0 fe ff ff       	call   80132a <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  80147a:	83 c4 10             	add    $0x10,%esp
  80147d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801480:	75 07                	jne    801489 <ipc_send+0x3a>
			sys_yield();
  801482:	e8 a1 fd ff ff       	call   801228 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  801487:	eb e6                	jmp    80146f <ipc_send+0x20>
		}
		else if (ret == 0)
  801489:	85 c0                	test   %eax,%eax
  80148b:	75 08                	jne    801495 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  80148d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801490:	5b                   	pop    %ebx
  801491:	5e                   	pop    %esi
  801492:	5f                   	pop    %edi
  801493:	5d                   	pop    %ebp
  801494:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  801495:	50                   	push   %eax
  801496:	68 9f 30 80 00       	push   $0x80309f
  80149b:	6a 48                	push   $0x48
  80149d:	68 ad 30 80 00       	push   $0x8030ad
  8014a2:	e8 4a f2 ff ff       	call   8006f1 <_panic>

008014a7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8014a7:	f3 0f 1e fb          	endbr32 
  8014ab:	55                   	push   %ebp
  8014ac:	89 e5                	mov    %esp,%ebp
  8014ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8014b1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8014b6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8014b9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8014bf:	8b 52 50             	mov    0x50(%edx),%edx
  8014c2:	39 ca                	cmp    %ecx,%edx
  8014c4:	74 11                	je     8014d7 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8014c6:	83 c0 01             	add    $0x1,%eax
  8014c9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8014ce:	75 e6                	jne    8014b6 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8014d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d5:	eb 0b                	jmp    8014e2 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8014d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8014da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8014df:	8b 40 48             	mov    0x48(%eax),%eax
}
  8014e2:	5d                   	pop    %ebp
  8014e3:	c3                   	ret    

008014e4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014e4:	f3 0f 1e fb          	endbr32 
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ee:	05 00 00 00 30       	add    $0x30000000,%eax
  8014f3:	c1 e8 0c             	shr    $0xc,%eax
}
  8014f6:	5d                   	pop    %ebp
  8014f7:	c3                   	ret    

008014f8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014f8:	f3 0f 1e fb          	endbr32 
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801502:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801507:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80150c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801511:	5d                   	pop    %ebp
  801512:	c3                   	ret    

00801513 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801513:	f3 0f 1e fb          	endbr32 
  801517:	55                   	push   %ebp
  801518:	89 e5                	mov    %esp,%ebp
  80151a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80151f:	89 c2                	mov    %eax,%edx
  801521:	c1 ea 16             	shr    $0x16,%edx
  801524:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80152b:	f6 c2 01             	test   $0x1,%dl
  80152e:	74 2d                	je     80155d <fd_alloc+0x4a>
  801530:	89 c2                	mov    %eax,%edx
  801532:	c1 ea 0c             	shr    $0xc,%edx
  801535:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80153c:	f6 c2 01             	test   $0x1,%dl
  80153f:	74 1c                	je     80155d <fd_alloc+0x4a>
  801541:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801546:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80154b:	75 d2                	jne    80151f <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  80154d:	8b 45 08             	mov    0x8(%ebp),%eax
  801550:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801556:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80155b:	eb 0a                	jmp    801567 <fd_alloc+0x54>
			*fd_store = fd;
  80155d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801560:	89 01                	mov    %eax,(%ecx)
			return 0;
  801562:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801567:	5d                   	pop    %ebp
  801568:	c3                   	ret    

00801569 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801569:	f3 0f 1e fb          	endbr32 
  80156d:	55                   	push   %ebp
  80156e:	89 e5                	mov    %esp,%ebp
  801570:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801573:	83 f8 1f             	cmp    $0x1f,%eax
  801576:	77 30                	ja     8015a8 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801578:	c1 e0 0c             	shl    $0xc,%eax
  80157b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801580:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801586:	f6 c2 01             	test   $0x1,%dl
  801589:	74 24                	je     8015af <fd_lookup+0x46>
  80158b:	89 c2                	mov    %eax,%edx
  80158d:	c1 ea 0c             	shr    $0xc,%edx
  801590:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801597:	f6 c2 01             	test   $0x1,%dl
  80159a:	74 1a                	je     8015b6 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80159c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80159f:	89 02                	mov    %eax,(%edx)
	return 0;
  8015a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015a6:	5d                   	pop    %ebp
  8015a7:	c3                   	ret    
		return -E_INVAL;
  8015a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ad:	eb f7                	jmp    8015a6 <fd_lookup+0x3d>
		return -E_INVAL;
  8015af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b4:	eb f0                	jmp    8015a6 <fd_lookup+0x3d>
  8015b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015bb:	eb e9                	jmp    8015a6 <fd_lookup+0x3d>

008015bd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015bd:	f3 0f 1e fb          	endbr32 
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	83 ec 08             	sub    $0x8,%esp
  8015c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8015ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8015cf:	b8 20 40 80 00       	mov    $0x804020,%eax
		if (devtab[i]->dev_id == dev_id) {
  8015d4:	39 08                	cmp    %ecx,(%eax)
  8015d6:	74 38                	je     801610 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8015d8:	83 c2 01             	add    $0x1,%edx
  8015db:	8b 04 95 34 31 80 00 	mov    0x803134(,%edx,4),%eax
  8015e2:	85 c0                	test   %eax,%eax
  8015e4:	75 ee                	jne    8015d4 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015e6:	a1 08 50 80 00       	mov    0x805008,%eax
  8015eb:	8b 40 48             	mov    0x48(%eax),%eax
  8015ee:	83 ec 04             	sub    $0x4,%esp
  8015f1:	51                   	push   %ecx
  8015f2:	50                   	push   %eax
  8015f3:	68 b8 30 80 00       	push   $0x8030b8
  8015f8:	e8 db f1 ff ff       	call   8007d8 <cprintf>
	*dev = 0;
  8015fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801600:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801606:	83 c4 10             	add    $0x10,%esp
  801609:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80160e:	c9                   	leave  
  80160f:	c3                   	ret    
			*dev = devtab[i];
  801610:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801613:	89 01                	mov    %eax,(%ecx)
			return 0;
  801615:	b8 00 00 00 00       	mov    $0x0,%eax
  80161a:	eb f2                	jmp    80160e <dev_lookup+0x51>

0080161c <fd_close>:
{
  80161c:	f3 0f 1e fb          	endbr32 
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	57                   	push   %edi
  801624:	56                   	push   %esi
  801625:	53                   	push   %ebx
  801626:	83 ec 24             	sub    $0x24,%esp
  801629:	8b 75 08             	mov    0x8(%ebp),%esi
  80162c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80162f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801632:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801633:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801639:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80163c:	50                   	push   %eax
  80163d:	e8 27 ff ff ff       	call   801569 <fd_lookup>
  801642:	89 c3                	mov    %eax,%ebx
  801644:	83 c4 10             	add    $0x10,%esp
  801647:	85 c0                	test   %eax,%eax
  801649:	78 05                	js     801650 <fd_close+0x34>
	    || fd != fd2)
  80164b:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80164e:	74 16                	je     801666 <fd_close+0x4a>
		return (must_exist ? r : 0);
  801650:	89 f8                	mov    %edi,%eax
  801652:	84 c0                	test   %al,%al
  801654:	b8 00 00 00 00       	mov    $0x0,%eax
  801659:	0f 44 d8             	cmove  %eax,%ebx
}
  80165c:	89 d8                	mov    %ebx,%eax
  80165e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801661:	5b                   	pop    %ebx
  801662:	5e                   	pop    %esi
  801663:	5f                   	pop    %edi
  801664:	5d                   	pop    %ebp
  801665:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801666:	83 ec 08             	sub    $0x8,%esp
  801669:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80166c:	50                   	push   %eax
  80166d:	ff 36                	pushl  (%esi)
  80166f:	e8 49 ff ff ff       	call   8015bd <dev_lookup>
  801674:	89 c3                	mov    %eax,%ebx
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	85 c0                	test   %eax,%eax
  80167b:	78 1a                	js     801697 <fd_close+0x7b>
		if (dev->dev_close)
  80167d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801680:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801683:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801688:	85 c0                	test   %eax,%eax
  80168a:	74 0b                	je     801697 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80168c:	83 ec 0c             	sub    $0xc,%esp
  80168f:	56                   	push   %esi
  801690:	ff d0                	call   *%eax
  801692:	89 c3                	mov    %eax,%ebx
  801694:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801697:	83 ec 08             	sub    $0x8,%esp
  80169a:	56                   	push   %esi
  80169b:	6a 00                	push   $0x0
  80169d:	e8 f4 fb ff ff       	call   801296 <sys_page_unmap>
	return r;
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	eb b5                	jmp    80165c <fd_close+0x40>

008016a7 <close>:

int
close(int fdnum)
{
  8016a7:	f3 0f 1e fb          	endbr32 
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b4:	50                   	push   %eax
  8016b5:	ff 75 08             	pushl  0x8(%ebp)
  8016b8:	e8 ac fe ff ff       	call   801569 <fd_lookup>
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	79 02                	jns    8016c6 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8016c4:	c9                   	leave  
  8016c5:	c3                   	ret    
		return fd_close(fd, 1);
  8016c6:	83 ec 08             	sub    $0x8,%esp
  8016c9:	6a 01                	push   $0x1
  8016cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8016ce:	e8 49 ff ff ff       	call   80161c <fd_close>
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	eb ec                	jmp    8016c4 <close+0x1d>

008016d8 <close_all>:

void
close_all(void)
{
  8016d8:	f3 0f 1e fb          	endbr32 
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	53                   	push   %ebx
  8016e0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016e3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016e8:	83 ec 0c             	sub    $0xc,%esp
  8016eb:	53                   	push   %ebx
  8016ec:	e8 b6 ff ff ff       	call   8016a7 <close>
	for (i = 0; i < MAXFD; i++)
  8016f1:	83 c3 01             	add    $0x1,%ebx
  8016f4:	83 c4 10             	add    $0x10,%esp
  8016f7:	83 fb 20             	cmp    $0x20,%ebx
  8016fa:	75 ec                	jne    8016e8 <close_all+0x10>
}
  8016fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ff:	c9                   	leave  
  801700:	c3                   	ret    

00801701 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801701:	f3 0f 1e fb          	endbr32 
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	57                   	push   %edi
  801709:	56                   	push   %esi
  80170a:	53                   	push   %ebx
  80170b:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80170e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801711:	50                   	push   %eax
  801712:	ff 75 08             	pushl  0x8(%ebp)
  801715:	e8 4f fe ff ff       	call   801569 <fd_lookup>
  80171a:	89 c3                	mov    %eax,%ebx
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	85 c0                	test   %eax,%eax
  801721:	0f 88 81 00 00 00    	js     8017a8 <dup+0xa7>
		return r;
	close(newfdnum);
  801727:	83 ec 0c             	sub    $0xc,%esp
  80172a:	ff 75 0c             	pushl  0xc(%ebp)
  80172d:	e8 75 ff ff ff       	call   8016a7 <close>

	newfd = INDEX2FD(newfdnum);
  801732:	8b 75 0c             	mov    0xc(%ebp),%esi
  801735:	c1 e6 0c             	shl    $0xc,%esi
  801738:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80173e:	83 c4 04             	add    $0x4,%esp
  801741:	ff 75 e4             	pushl  -0x1c(%ebp)
  801744:	e8 af fd ff ff       	call   8014f8 <fd2data>
  801749:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80174b:	89 34 24             	mov    %esi,(%esp)
  80174e:	e8 a5 fd ff ff       	call   8014f8 <fd2data>
  801753:	83 c4 10             	add    $0x10,%esp
  801756:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801758:	89 d8                	mov    %ebx,%eax
  80175a:	c1 e8 16             	shr    $0x16,%eax
  80175d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801764:	a8 01                	test   $0x1,%al
  801766:	74 11                	je     801779 <dup+0x78>
  801768:	89 d8                	mov    %ebx,%eax
  80176a:	c1 e8 0c             	shr    $0xc,%eax
  80176d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801774:	f6 c2 01             	test   $0x1,%dl
  801777:	75 39                	jne    8017b2 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801779:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80177c:	89 d0                	mov    %edx,%eax
  80177e:	c1 e8 0c             	shr    $0xc,%eax
  801781:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801788:	83 ec 0c             	sub    $0xc,%esp
  80178b:	25 07 0e 00 00       	and    $0xe07,%eax
  801790:	50                   	push   %eax
  801791:	56                   	push   %esi
  801792:	6a 00                	push   $0x0
  801794:	52                   	push   %edx
  801795:	6a 00                	push   $0x0
  801797:	e8 d5 fa ff ff       	call   801271 <sys_page_map>
  80179c:	89 c3                	mov    %eax,%ebx
  80179e:	83 c4 20             	add    $0x20,%esp
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	78 31                	js     8017d6 <dup+0xd5>
		goto err;

	return newfdnum;
  8017a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8017a8:	89 d8                	mov    %ebx,%eax
  8017aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ad:	5b                   	pop    %ebx
  8017ae:	5e                   	pop    %esi
  8017af:	5f                   	pop    %edi
  8017b0:	5d                   	pop    %ebp
  8017b1:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8017b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017b9:	83 ec 0c             	sub    $0xc,%esp
  8017bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8017c1:	50                   	push   %eax
  8017c2:	57                   	push   %edi
  8017c3:	6a 00                	push   $0x0
  8017c5:	53                   	push   %ebx
  8017c6:	6a 00                	push   $0x0
  8017c8:	e8 a4 fa ff ff       	call   801271 <sys_page_map>
  8017cd:	89 c3                	mov    %eax,%ebx
  8017cf:	83 c4 20             	add    $0x20,%esp
  8017d2:	85 c0                	test   %eax,%eax
  8017d4:	79 a3                	jns    801779 <dup+0x78>
	sys_page_unmap(0, newfd);
  8017d6:	83 ec 08             	sub    $0x8,%esp
  8017d9:	56                   	push   %esi
  8017da:	6a 00                	push   $0x0
  8017dc:	e8 b5 fa ff ff       	call   801296 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017e1:	83 c4 08             	add    $0x8,%esp
  8017e4:	57                   	push   %edi
  8017e5:	6a 00                	push   $0x0
  8017e7:	e8 aa fa ff ff       	call   801296 <sys_page_unmap>
	return r;
  8017ec:	83 c4 10             	add    $0x10,%esp
  8017ef:	eb b7                	jmp    8017a8 <dup+0xa7>

008017f1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017f1:	f3 0f 1e fb          	endbr32 
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	53                   	push   %ebx
  8017f9:	83 ec 1c             	sub    $0x1c,%esp
  8017fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801802:	50                   	push   %eax
  801803:	53                   	push   %ebx
  801804:	e8 60 fd ff ff       	call   801569 <fd_lookup>
  801809:	83 c4 10             	add    $0x10,%esp
  80180c:	85 c0                	test   %eax,%eax
  80180e:	78 3f                	js     80184f <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801810:	83 ec 08             	sub    $0x8,%esp
  801813:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801816:	50                   	push   %eax
  801817:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181a:	ff 30                	pushl  (%eax)
  80181c:	e8 9c fd ff ff       	call   8015bd <dev_lookup>
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	85 c0                	test   %eax,%eax
  801826:	78 27                	js     80184f <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801828:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80182b:	8b 42 08             	mov    0x8(%edx),%eax
  80182e:	83 e0 03             	and    $0x3,%eax
  801831:	83 f8 01             	cmp    $0x1,%eax
  801834:	74 1e                	je     801854 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801836:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801839:	8b 40 08             	mov    0x8(%eax),%eax
  80183c:	85 c0                	test   %eax,%eax
  80183e:	74 35                	je     801875 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801840:	83 ec 04             	sub    $0x4,%esp
  801843:	ff 75 10             	pushl  0x10(%ebp)
  801846:	ff 75 0c             	pushl  0xc(%ebp)
  801849:	52                   	push   %edx
  80184a:	ff d0                	call   *%eax
  80184c:	83 c4 10             	add    $0x10,%esp
}
  80184f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801852:	c9                   	leave  
  801853:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801854:	a1 08 50 80 00       	mov    0x805008,%eax
  801859:	8b 40 48             	mov    0x48(%eax),%eax
  80185c:	83 ec 04             	sub    $0x4,%esp
  80185f:	53                   	push   %ebx
  801860:	50                   	push   %eax
  801861:	68 f9 30 80 00       	push   $0x8030f9
  801866:	e8 6d ef ff ff       	call   8007d8 <cprintf>
		return -E_INVAL;
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801873:	eb da                	jmp    80184f <read+0x5e>
		return -E_NOT_SUPP;
  801875:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80187a:	eb d3                	jmp    80184f <read+0x5e>

0080187c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80187c:	f3 0f 1e fb          	endbr32 
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	57                   	push   %edi
  801884:	56                   	push   %esi
  801885:	53                   	push   %ebx
  801886:	83 ec 0c             	sub    $0xc,%esp
  801889:	8b 7d 08             	mov    0x8(%ebp),%edi
  80188c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80188f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801894:	eb 02                	jmp    801898 <readn+0x1c>
  801896:	01 c3                	add    %eax,%ebx
  801898:	39 f3                	cmp    %esi,%ebx
  80189a:	73 21                	jae    8018bd <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80189c:	83 ec 04             	sub    $0x4,%esp
  80189f:	89 f0                	mov    %esi,%eax
  8018a1:	29 d8                	sub    %ebx,%eax
  8018a3:	50                   	push   %eax
  8018a4:	89 d8                	mov    %ebx,%eax
  8018a6:	03 45 0c             	add    0xc(%ebp),%eax
  8018a9:	50                   	push   %eax
  8018aa:	57                   	push   %edi
  8018ab:	e8 41 ff ff ff       	call   8017f1 <read>
		if (m < 0)
  8018b0:	83 c4 10             	add    $0x10,%esp
  8018b3:	85 c0                	test   %eax,%eax
  8018b5:	78 04                	js     8018bb <readn+0x3f>
			return m;
		if (m == 0)
  8018b7:	75 dd                	jne    801896 <readn+0x1a>
  8018b9:	eb 02                	jmp    8018bd <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018bb:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8018bd:	89 d8                	mov    %ebx,%eax
  8018bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018c2:	5b                   	pop    %ebx
  8018c3:	5e                   	pop    %esi
  8018c4:	5f                   	pop    %edi
  8018c5:	5d                   	pop    %ebp
  8018c6:	c3                   	ret    

008018c7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018c7:	f3 0f 1e fb          	endbr32 
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	53                   	push   %ebx
  8018cf:	83 ec 1c             	sub    $0x1c,%esp
  8018d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018d8:	50                   	push   %eax
  8018d9:	53                   	push   %ebx
  8018da:	e8 8a fc ff ff       	call   801569 <fd_lookup>
  8018df:	83 c4 10             	add    $0x10,%esp
  8018e2:	85 c0                	test   %eax,%eax
  8018e4:	78 3a                	js     801920 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018e6:	83 ec 08             	sub    $0x8,%esp
  8018e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ec:	50                   	push   %eax
  8018ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f0:	ff 30                	pushl  (%eax)
  8018f2:	e8 c6 fc ff ff       	call   8015bd <dev_lookup>
  8018f7:	83 c4 10             	add    $0x10,%esp
  8018fa:	85 c0                	test   %eax,%eax
  8018fc:	78 22                	js     801920 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801901:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801905:	74 1e                	je     801925 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801907:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80190a:	8b 52 0c             	mov    0xc(%edx),%edx
  80190d:	85 d2                	test   %edx,%edx
  80190f:	74 35                	je     801946 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801911:	83 ec 04             	sub    $0x4,%esp
  801914:	ff 75 10             	pushl  0x10(%ebp)
  801917:	ff 75 0c             	pushl  0xc(%ebp)
  80191a:	50                   	push   %eax
  80191b:	ff d2                	call   *%edx
  80191d:	83 c4 10             	add    $0x10,%esp
}
  801920:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801923:	c9                   	leave  
  801924:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801925:	a1 08 50 80 00       	mov    0x805008,%eax
  80192a:	8b 40 48             	mov    0x48(%eax),%eax
  80192d:	83 ec 04             	sub    $0x4,%esp
  801930:	53                   	push   %ebx
  801931:	50                   	push   %eax
  801932:	68 15 31 80 00       	push   $0x803115
  801937:	e8 9c ee ff ff       	call   8007d8 <cprintf>
		return -E_INVAL;
  80193c:	83 c4 10             	add    $0x10,%esp
  80193f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801944:	eb da                	jmp    801920 <write+0x59>
		return -E_NOT_SUPP;
  801946:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80194b:	eb d3                	jmp    801920 <write+0x59>

0080194d <seek>:

int
seek(int fdnum, off_t offset)
{
  80194d:	f3 0f 1e fb          	endbr32 
  801951:	55                   	push   %ebp
  801952:	89 e5                	mov    %esp,%ebp
  801954:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801957:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195a:	50                   	push   %eax
  80195b:	ff 75 08             	pushl  0x8(%ebp)
  80195e:	e8 06 fc ff ff       	call   801569 <fd_lookup>
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	85 c0                	test   %eax,%eax
  801968:	78 0e                	js     801978 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80196a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80196d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801970:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801973:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801978:	c9                   	leave  
  801979:	c3                   	ret    

0080197a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80197a:	f3 0f 1e fb          	endbr32 
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	53                   	push   %ebx
  801982:	83 ec 1c             	sub    $0x1c,%esp
  801985:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801988:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80198b:	50                   	push   %eax
  80198c:	53                   	push   %ebx
  80198d:	e8 d7 fb ff ff       	call   801569 <fd_lookup>
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	85 c0                	test   %eax,%eax
  801997:	78 37                	js     8019d0 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801999:	83 ec 08             	sub    $0x8,%esp
  80199c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199f:	50                   	push   %eax
  8019a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019a3:	ff 30                	pushl  (%eax)
  8019a5:	e8 13 fc ff ff       	call   8015bd <dev_lookup>
  8019aa:	83 c4 10             	add    $0x10,%esp
  8019ad:	85 c0                	test   %eax,%eax
  8019af:	78 1f                	js     8019d0 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019b8:	74 1b                	je     8019d5 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8019ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019bd:	8b 52 18             	mov    0x18(%edx),%edx
  8019c0:	85 d2                	test   %edx,%edx
  8019c2:	74 32                	je     8019f6 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019c4:	83 ec 08             	sub    $0x8,%esp
  8019c7:	ff 75 0c             	pushl  0xc(%ebp)
  8019ca:	50                   	push   %eax
  8019cb:	ff d2                	call   *%edx
  8019cd:	83 c4 10             	add    $0x10,%esp
}
  8019d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d3:	c9                   	leave  
  8019d4:	c3                   	ret    
			thisenv->env_id, fdnum);
  8019d5:	a1 08 50 80 00       	mov    0x805008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019da:	8b 40 48             	mov    0x48(%eax),%eax
  8019dd:	83 ec 04             	sub    $0x4,%esp
  8019e0:	53                   	push   %ebx
  8019e1:	50                   	push   %eax
  8019e2:	68 d8 30 80 00       	push   $0x8030d8
  8019e7:	e8 ec ed ff ff       	call   8007d8 <cprintf>
		return -E_INVAL;
  8019ec:	83 c4 10             	add    $0x10,%esp
  8019ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019f4:	eb da                	jmp    8019d0 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8019f6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019fb:	eb d3                	jmp    8019d0 <ftruncate+0x56>

008019fd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019fd:	f3 0f 1e fb          	endbr32 
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	53                   	push   %ebx
  801a05:	83 ec 1c             	sub    $0x1c,%esp
  801a08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a0b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a0e:	50                   	push   %eax
  801a0f:	ff 75 08             	pushl  0x8(%ebp)
  801a12:	e8 52 fb ff ff       	call   801569 <fd_lookup>
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	78 4b                	js     801a69 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a1e:	83 ec 08             	sub    $0x8,%esp
  801a21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a24:	50                   	push   %eax
  801a25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a28:	ff 30                	pushl  (%eax)
  801a2a:	e8 8e fb ff ff       	call   8015bd <dev_lookup>
  801a2f:	83 c4 10             	add    $0x10,%esp
  801a32:	85 c0                	test   %eax,%eax
  801a34:	78 33                	js     801a69 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a39:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a3d:	74 2f                	je     801a6e <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a3f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a42:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a49:	00 00 00 
	stat->st_isdir = 0;
  801a4c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a53:	00 00 00 
	stat->st_dev = dev;
  801a56:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a5c:	83 ec 08             	sub    $0x8,%esp
  801a5f:	53                   	push   %ebx
  801a60:	ff 75 f0             	pushl  -0x10(%ebp)
  801a63:	ff 50 14             	call   *0x14(%eax)
  801a66:	83 c4 10             	add    $0x10,%esp
}
  801a69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a6c:	c9                   	leave  
  801a6d:	c3                   	ret    
		return -E_NOT_SUPP;
  801a6e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a73:	eb f4                	jmp    801a69 <fstat+0x6c>

00801a75 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a75:	f3 0f 1e fb          	endbr32 
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	56                   	push   %esi
  801a7d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a7e:	83 ec 08             	sub    $0x8,%esp
  801a81:	6a 00                	push   $0x0
  801a83:	ff 75 08             	pushl  0x8(%ebp)
  801a86:	e8 01 02 00 00       	call   801c8c <open>
  801a8b:	89 c3                	mov    %eax,%ebx
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	85 c0                	test   %eax,%eax
  801a92:	78 1b                	js     801aaf <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801a94:	83 ec 08             	sub    $0x8,%esp
  801a97:	ff 75 0c             	pushl  0xc(%ebp)
  801a9a:	50                   	push   %eax
  801a9b:	e8 5d ff ff ff       	call   8019fd <fstat>
  801aa0:	89 c6                	mov    %eax,%esi
	close(fd);
  801aa2:	89 1c 24             	mov    %ebx,(%esp)
  801aa5:	e8 fd fb ff ff       	call   8016a7 <close>
	return r;
  801aaa:	83 c4 10             	add    $0x10,%esp
  801aad:	89 f3                	mov    %esi,%ebx
}
  801aaf:	89 d8                	mov    %ebx,%eax
  801ab1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab4:	5b                   	pop    %ebx
  801ab5:	5e                   	pop    %esi
  801ab6:	5d                   	pop    %ebp
  801ab7:	c3                   	ret    

00801ab8 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	56                   	push   %esi
  801abc:	53                   	push   %ebx
  801abd:	89 c6                	mov    %eax,%esi
  801abf:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801ac1:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801ac8:	74 27                	je     801af1 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801aca:	6a 07                	push   $0x7
  801acc:	68 00 60 80 00       	push   $0x806000
  801ad1:	56                   	push   %esi
  801ad2:	ff 35 00 50 80 00    	pushl  0x805000
  801ad8:	e8 72 f9 ff ff       	call   80144f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801add:	83 c4 0c             	add    $0xc,%esp
  801ae0:	6a 00                	push   $0x0
  801ae2:	53                   	push   %ebx
  801ae3:	6a 00                	push   $0x0
  801ae5:	e8 f8 f8 ff ff       	call   8013e2 <ipc_recv>
}
  801aea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aed:	5b                   	pop    %ebx
  801aee:	5e                   	pop    %esi
  801aef:	5d                   	pop    %ebp
  801af0:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801af1:	83 ec 0c             	sub    $0xc,%esp
  801af4:	6a 01                	push   $0x1
  801af6:	e8 ac f9 ff ff       	call   8014a7 <ipc_find_env>
  801afb:	a3 00 50 80 00       	mov    %eax,0x805000
  801b00:	83 c4 10             	add    $0x10,%esp
  801b03:	eb c5                	jmp    801aca <fsipc+0x12>

00801b05 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b05:	f3 0f 1e fb          	endbr32 
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b12:	8b 40 0c             	mov    0xc(%eax),%eax
  801b15:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801b1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b22:	ba 00 00 00 00       	mov    $0x0,%edx
  801b27:	b8 02 00 00 00       	mov    $0x2,%eax
  801b2c:	e8 87 ff ff ff       	call   801ab8 <fsipc>
}
  801b31:	c9                   	leave  
  801b32:	c3                   	ret    

00801b33 <devfile_flush>:
{
  801b33:	f3 0f 1e fb          	endbr32 
  801b37:	55                   	push   %ebp
  801b38:	89 e5                	mov    %esp,%ebp
  801b3a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b40:	8b 40 0c             	mov    0xc(%eax),%eax
  801b43:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b48:	ba 00 00 00 00       	mov    $0x0,%edx
  801b4d:	b8 06 00 00 00       	mov    $0x6,%eax
  801b52:	e8 61 ff ff ff       	call   801ab8 <fsipc>
}
  801b57:	c9                   	leave  
  801b58:	c3                   	ret    

00801b59 <devfile_stat>:
{
  801b59:	f3 0f 1e fb          	endbr32 
  801b5d:	55                   	push   %ebp
  801b5e:	89 e5                	mov    %esp,%ebp
  801b60:	53                   	push   %ebx
  801b61:	83 ec 04             	sub    $0x4,%esp
  801b64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b67:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b6d:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b72:	ba 00 00 00 00       	mov    $0x0,%edx
  801b77:	b8 05 00 00 00       	mov    $0x5,%eax
  801b7c:	e8 37 ff ff ff       	call   801ab8 <fsipc>
  801b81:	85 c0                	test   %eax,%eax
  801b83:	78 2c                	js     801bb1 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b85:	83 ec 08             	sub    $0x8,%esp
  801b88:	68 00 60 80 00       	push   $0x806000
  801b8d:	53                   	push   %ebx
  801b8e:	e8 4f f2 ff ff       	call   800de2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b93:	a1 80 60 80 00       	mov    0x806080,%eax
  801b98:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b9e:	a1 84 60 80 00       	mov    0x806084,%eax
  801ba3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ba9:	83 c4 10             	add    $0x10,%esp
  801bac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb4:	c9                   	leave  
  801bb5:	c3                   	ret    

00801bb6 <devfile_write>:
{
  801bb6:	f3 0f 1e fb          	endbr32 
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
  801bbd:	83 ec 0c             	sub    $0xc,%esp
  801bc0:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801bc8:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801bcd:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  801bd3:	8b 52 0c             	mov    0xc(%edx),%edx
  801bd6:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801bdc:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801be1:	50                   	push   %eax
  801be2:	ff 75 0c             	pushl  0xc(%ebp)
  801be5:	68 08 60 80 00       	push   $0x806008
  801bea:	e8 f1 f3 ff ff       	call   800fe0 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801bef:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf4:	b8 04 00 00 00       	mov    $0x4,%eax
  801bf9:	e8 ba fe ff ff       	call   801ab8 <fsipc>
}
  801bfe:	c9                   	leave  
  801bff:	c3                   	ret    

00801c00 <devfile_read>:
{
  801c00:	f3 0f 1e fb          	endbr32 
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	56                   	push   %esi
  801c08:	53                   	push   %ebx
  801c09:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0f:	8b 40 0c             	mov    0xc(%eax),%eax
  801c12:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801c17:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c1d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c22:	b8 03 00 00 00       	mov    $0x3,%eax
  801c27:	e8 8c fe ff ff       	call   801ab8 <fsipc>
  801c2c:	89 c3                	mov    %eax,%ebx
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	78 1f                	js     801c51 <devfile_read+0x51>
	assert(r <= n);
  801c32:	39 f0                	cmp    %esi,%eax
  801c34:	77 24                	ja     801c5a <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801c36:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c3b:	7f 36                	jg     801c73 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c3d:	83 ec 04             	sub    $0x4,%esp
  801c40:	50                   	push   %eax
  801c41:	68 00 60 80 00       	push   $0x806000
  801c46:	ff 75 0c             	pushl  0xc(%ebp)
  801c49:	e8 92 f3 ff ff       	call   800fe0 <memmove>
	return r;
  801c4e:	83 c4 10             	add    $0x10,%esp
}
  801c51:	89 d8                	mov    %ebx,%eax
  801c53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c56:	5b                   	pop    %ebx
  801c57:	5e                   	pop    %esi
  801c58:	5d                   	pop    %ebp
  801c59:	c3                   	ret    
	assert(r <= n);
  801c5a:	68 48 31 80 00       	push   $0x803148
  801c5f:	68 4f 31 80 00       	push   $0x80314f
  801c64:	68 8c 00 00 00       	push   $0x8c
  801c69:	68 64 31 80 00       	push   $0x803164
  801c6e:	e8 7e ea ff ff       	call   8006f1 <_panic>
	assert(r <= PGSIZE);
  801c73:	68 6f 31 80 00       	push   $0x80316f
  801c78:	68 4f 31 80 00       	push   $0x80314f
  801c7d:	68 8d 00 00 00       	push   $0x8d
  801c82:	68 64 31 80 00       	push   $0x803164
  801c87:	e8 65 ea ff ff       	call   8006f1 <_panic>

00801c8c <open>:
{
  801c8c:	f3 0f 1e fb          	endbr32 
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	56                   	push   %esi
  801c94:	53                   	push   %ebx
  801c95:	83 ec 1c             	sub    $0x1c,%esp
  801c98:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801c9b:	56                   	push   %esi
  801c9c:	e8 fe f0 ff ff       	call   800d9f <strlen>
  801ca1:	83 c4 10             	add    $0x10,%esp
  801ca4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ca9:	7f 6c                	jg     801d17 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801cab:	83 ec 0c             	sub    $0xc,%esp
  801cae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb1:	50                   	push   %eax
  801cb2:	e8 5c f8 ff ff       	call   801513 <fd_alloc>
  801cb7:	89 c3                	mov    %eax,%ebx
  801cb9:	83 c4 10             	add    $0x10,%esp
  801cbc:	85 c0                	test   %eax,%eax
  801cbe:	78 3c                	js     801cfc <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801cc0:	83 ec 08             	sub    $0x8,%esp
  801cc3:	56                   	push   %esi
  801cc4:	68 00 60 80 00       	push   $0x806000
  801cc9:	e8 14 f1 ff ff       	call   800de2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801cce:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd1:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801cd6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cd9:	b8 01 00 00 00       	mov    $0x1,%eax
  801cde:	e8 d5 fd ff ff       	call   801ab8 <fsipc>
  801ce3:	89 c3                	mov    %eax,%ebx
  801ce5:	83 c4 10             	add    $0x10,%esp
  801ce8:	85 c0                	test   %eax,%eax
  801cea:	78 19                	js     801d05 <open+0x79>
	return fd2num(fd);
  801cec:	83 ec 0c             	sub    $0xc,%esp
  801cef:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf2:	e8 ed f7 ff ff       	call   8014e4 <fd2num>
  801cf7:	89 c3                	mov    %eax,%ebx
  801cf9:	83 c4 10             	add    $0x10,%esp
}
  801cfc:	89 d8                	mov    %ebx,%eax
  801cfe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d01:	5b                   	pop    %ebx
  801d02:	5e                   	pop    %esi
  801d03:	5d                   	pop    %ebp
  801d04:	c3                   	ret    
		fd_close(fd, 0);
  801d05:	83 ec 08             	sub    $0x8,%esp
  801d08:	6a 00                	push   $0x0
  801d0a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0d:	e8 0a f9 ff ff       	call   80161c <fd_close>
		return r;
  801d12:	83 c4 10             	add    $0x10,%esp
  801d15:	eb e5                	jmp    801cfc <open+0x70>
		return -E_BAD_PATH;
  801d17:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801d1c:	eb de                	jmp    801cfc <open+0x70>

00801d1e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d1e:	f3 0f 1e fb          	endbr32 
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d28:	ba 00 00 00 00       	mov    $0x0,%edx
  801d2d:	b8 08 00 00 00       	mov    $0x8,%eax
  801d32:	e8 81 fd ff ff       	call   801ab8 <fsipc>
}
  801d37:	c9                   	leave  
  801d38:	c3                   	ret    

00801d39 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d39:	f3 0f 1e fb          	endbr32 
  801d3d:	55                   	push   %ebp
  801d3e:	89 e5                	mov    %esp,%ebp
  801d40:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801d43:	68 db 31 80 00       	push   $0x8031db
  801d48:	ff 75 0c             	pushl  0xc(%ebp)
  801d4b:	e8 92 f0 ff ff       	call   800de2 <strcpy>
	return 0;
}
  801d50:	b8 00 00 00 00       	mov    $0x0,%eax
  801d55:	c9                   	leave  
  801d56:	c3                   	ret    

00801d57 <devsock_close>:
{
  801d57:	f3 0f 1e fb          	endbr32 
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	53                   	push   %ebx
  801d5f:	83 ec 10             	sub    $0x10,%esp
  801d62:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d65:	53                   	push   %ebx
  801d66:	e8 81 09 00 00       	call   8026ec <pageref>
  801d6b:	89 c2                	mov    %eax,%edx
  801d6d:	83 c4 10             	add    $0x10,%esp
		return 0;
  801d70:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801d75:	83 fa 01             	cmp    $0x1,%edx
  801d78:	74 05                	je     801d7f <devsock_close+0x28>
}
  801d7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d7d:	c9                   	leave  
  801d7e:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801d7f:	83 ec 0c             	sub    $0xc,%esp
  801d82:	ff 73 0c             	pushl  0xc(%ebx)
  801d85:	e8 e3 02 00 00       	call   80206d <nsipc_close>
  801d8a:	83 c4 10             	add    $0x10,%esp
  801d8d:	eb eb                	jmp    801d7a <devsock_close+0x23>

00801d8f <devsock_write>:
{
  801d8f:	f3 0f 1e fb          	endbr32 
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
  801d96:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d99:	6a 00                	push   $0x0
  801d9b:	ff 75 10             	pushl  0x10(%ebp)
  801d9e:	ff 75 0c             	pushl  0xc(%ebp)
  801da1:	8b 45 08             	mov    0x8(%ebp),%eax
  801da4:	ff 70 0c             	pushl  0xc(%eax)
  801da7:	e8 b5 03 00 00       	call   802161 <nsipc_send>
}
  801dac:	c9                   	leave  
  801dad:	c3                   	ret    

00801dae <devsock_read>:
{
  801dae:	f3 0f 1e fb          	endbr32 
  801db2:	55                   	push   %ebp
  801db3:	89 e5                	mov    %esp,%ebp
  801db5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801db8:	6a 00                	push   $0x0
  801dba:	ff 75 10             	pushl  0x10(%ebp)
  801dbd:	ff 75 0c             	pushl  0xc(%ebp)
  801dc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc3:	ff 70 0c             	pushl  0xc(%eax)
  801dc6:	e8 1f 03 00 00       	call   8020ea <nsipc_recv>
}
  801dcb:	c9                   	leave  
  801dcc:	c3                   	ret    

00801dcd <fd2sockid>:
{
  801dcd:	55                   	push   %ebp
  801dce:	89 e5                	mov    %esp,%ebp
  801dd0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801dd3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801dd6:	52                   	push   %edx
  801dd7:	50                   	push   %eax
  801dd8:	e8 8c f7 ff ff       	call   801569 <fd_lookup>
  801ddd:	83 c4 10             	add    $0x10,%esp
  801de0:	85 c0                	test   %eax,%eax
  801de2:	78 10                	js     801df4 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801de4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de7:	8b 0d 60 40 80 00    	mov    0x804060,%ecx
  801ded:	39 08                	cmp    %ecx,(%eax)
  801def:	75 05                	jne    801df6 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801df1:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801df4:	c9                   	leave  
  801df5:	c3                   	ret    
		return -E_NOT_SUPP;
  801df6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801dfb:	eb f7                	jmp    801df4 <fd2sockid+0x27>

00801dfd <alloc_sockfd>:
{
  801dfd:	55                   	push   %ebp
  801dfe:	89 e5                	mov    %esp,%ebp
  801e00:	56                   	push   %esi
  801e01:	53                   	push   %ebx
  801e02:	83 ec 1c             	sub    $0x1c,%esp
  801e05:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801e07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e0a:	50                   	push   %eax
  801e0b:	e8 03 f7 ff ff       	call   801513 <fd_alloc>
  801e10:	89 c3                	mov    %eax,%ebx
  801e12:	83 c4 10             	add    $0x10,%esp
  801e15:	85 c0                	test   %eax,%eax
  801e17:	78 43                	js     801e5c <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801e19:	83 ec 04             	sub    $0x4,%esp
  801e1c:	68 07 04 00 00       	push   $0x407
  801e21:	ff 75 f4             	pushl  -0xc(%ebp)
  801e24:	6a 00                	push   $0x0
  801e26:	e8 20 f4 ff ff       	call   80124b <sys_page_alloc>
  801e2b:	89 c3                	mov    %eax,%ebx
  801e2d:	83 c4 10             	add    $0x10,%esp
  801e30:	85 c0                	test   %eax,%eax
  801e32:	78 28                	js     801e5c <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e37:	8b 15 60 40 80 00    	mov    0x804060,%edx
  801e3d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e42:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801e49:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801e4c:	83 ec 0c             	sub    $0xc,%esp
  801e4f:	50                   	push   %eax
  801e50:	e8 8f f6 ff ff       	call   8014e4 <fd2num>
  801e55:	89 c3                	mov    %eax,%ebx
  801e57:	83 c4 10             	add    $0x10,%esp
  801e5a:	eb 0c                	jmp    801e68 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801e5c:	83 ec 0c             	sub    $0xc,%esp
  801e5f:	56                   	push   %esi
  801e60:	e8 08 02 00 00       	call   80206d <nsipc_close>
		return r;
  801e65:	83 c4 10             	add    $0x10,%esp
}
  801e68:	89 d8                	mov    %ebx,%eax
  801e6a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e6d:	5b                   	pop    %ebx
  801e6e:	5e                   	pop    %esi
  801e6f:	5d                   	pop    %ebp
  801e70:	c3                   	ret    

00801e71 <accept>:
{
  801e71:	f3 0f 1e fb          	endbr32 
  801e75:	55                   	push   %ebp
  801e76:	89 e5                	mov    %esp,%ebp
  801e78:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7e:	e8 4a ff ff ff       	call   801dcd <fd2sockid>
  801e83:	85 c0                	test   %eax,%eax
  801e85:	78 1b                	js     801ea2 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e87:	83 ec 04             	sub    $0x4,%esp
  801e8a:	ff 75 10             	pushl  0x10(%ebp)
  801e8d:	ff 75 0c             	pushl  0xc(%ebp)
  801e90:	50                   	push   %eax
  801e91:	e8 22 01 00 00       	call   801fb8 <nsipc_accept>
  801e96:	83 c4 10             	add    $0x10,%esp
  801e99:	85 c0                	test   %eax,%eax
  801e9b:	78 05                	js     801ea2 <accept+0x31>
	return alloc_sockfd(r);
  801e9d:	e8 5b ff ff ff       	call   801dfd <alloc_sockfd>
}
  801ea2:	c9                   	leave  
  801ea3:	c3                   	ret    

00801ea4 <bind>:
{
  801ea4:	f3 0f 1e fb          	endbr32 
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801eae:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb1:	e8 17 ff ff ff       	call   801dcd <fd2sockid>
  801eb6:	85 c0                	test   %eax,%eax
  801eb8:	78 12                	js     801ecc <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801eba:	83 ec 04             	sub    $0x4,%esp
  801ebd:	ff 75 10             	pushl  0x10(%ebp)
  801ec0:	ff 75 0c             	pushl  0xc(%ebp)
  801ec3:	50                   	push   %eax
  801ec4:	e8 45 01 00 00       	call   80200e <nsipc_bind>
  801ec9:	83 c4 10             	add    $0x10,%esp
}
  801ecc:	c9                   	leave  
  801ecd:	c3                   	ret    

00801ece <shutdown>:
{
  801ece:	f3 0f 1e fb          	endbr32 
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ed8:	8b 45 08             	mov    0x8(%ebp),%eax
  801edb:	e8 ed fe ff ff       	call   801dcd <fd2sockid>
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	78 0f                	js     801ef3 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801ee4:	83 ec 08             	sub    $0x8,%esp
  801ee7:	ff 75 0c             	pushl  0xc(%ebp)
  801eea:	50                   	push   %eax
  801eeb:	e8 57 01 00 00       	call   802047 <nsipc_shutdown>
  801ef0:	83 c4 10             	add    $0x10,%esp
}
  801ef3:	c9                   	leave  
  801ef4:	c3                   	ret    

00801ef5 <connect>:
{
  801ef5:	f3 0f 1e fb          	endbr32 
  801ef9:	55                   	push   %ebp
  801efa:	89 e5                	mov    %esp,%ebp
  801efc:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801eff:	8b 45 08             	mov    0x8(%ebp),%eax
  801f02:	e8 c6 fe ff ff       	call   801dcd <fd2sockid>
  801f07:	85 c0                	test   %eax,%eax
  801f09:	78 12                	js     801f1d <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801f0b:	83 ec 04             	sub    $0x4,%esp
  801f0e:	ff 75 10             	pushl  0x10(%ebp)
  801f11:	ff 75 0c             	pushl  0xc(%ebp)
  801f14:	50                   	push   %eax
  801f15:	e8 71 01 00 00       	call   80208b <nsipc_connect>
  801f1a:	83 c4 10             	add    $0x10,%esp
}
  801f1d:	c9                   	leave  
  801f1e:	c3                   	ret    

00801f1f <listen>:
{
  801f1f:	f3 0f 1e fb          	endbr32 
  801f23:	55                   	push   %ebp
  801f24:	89 e5                	mov    %esp,%ebp
  801f26:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801f29:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2c:	e8 9c fe ff ff       	call   801dcd <fd2sockid>
  801f31:	85 c0                	test   %eax,%eax
  801f33:	78 0f                	js     801f44 <listen+0x25>
	return nsipc_listen(r, backlog);
  801f35:	83 ec 08             	sub    $0x8,%esp
  801f38:	ff 75 0c             	pushl  0xc(%ebp)
  801f3b:	50                   	push   %eax
  801f3c:	e8 83 01 00 00       	call   8020c4 <nsipc_listen>
  801f41:	83 c4 10             	add    $0x10,%esp
}
  801f44:	c9                   	leave  
  801f45:	c3                   	ret    

00801f46 <socket>:

int
socket(int domain, int type, int protocol)
{
  801f46:	f3 0f 1e fb          	endbr32 
  801f4a:	55                   	push   %ebp
  801f4b:	89 e5                	mov    %esp,%ebp
  801f4d:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f50:	ff 75 10             	pushl  0x10(%ebp)
  801f53:	ff 75 0c             	pushl  0xc(%ebp)
  801f56:	ff 75 08             	pushl  0x8(%ebp)
  801f59:	e8 65 02 00 00       	call   8021c3 <nsipc_socket>
  801f5e:	83 c4 10             	add    $0x10,%esp
  801f61:	85 c0                	test   %eax,%eax
  801f63:	78 05                	js     801f6a <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801f65:	e8 93 fe ff ff       	call   801dfd <alloc_sockfd>
}
  801f6a:	c9                   	leave  
  801f6b:	c3                   	ret    

00801f6c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801f6c:	55                   	push   %ebp
  801f6d:	89 e5                	mov    %esp,%ebp
  801f6f:	53                   	push   %ebx
  801f70:	83 ec 04             	sub    $0x4,%esp
  801f73:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801f75:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801f7c:	74 26                	je     801fa4 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f7e:	6a 07                	push   $0x7
  801f80:	68 00 70 80 00       	push   $0x807000
  801f85:	53                   	push   %ebx
  801f86:	ff 35 04 50 80 00    	pushl  0x805004
  801f8c:	e8 be f4 ff ff       	call   80144f <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f91:	83 c4 0c             	add    $0xc,%esp
  801f94:	6a 00                	push   $0x0
  801f96:	6a 00                	push   $0x0
  801f98:	6a 00                	push   $0x0
  801f9a:	e8 43 f4 ff ff       	call   8013e2 <ipc_recv>
}
  801f9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fa2:	c9                   	leave  
  801fa3:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801fa4:	83 ec 0c             	sub    $0xc,%esp
  801fa7:	6a 02                	push   $0x2
  801fa9:	e8 f9 f4 ff ff       	call   8014a7 <ipc_find_env>
  801fae:	a3 04 50 80 00       	mov    %eax,0x805004
  801fb3:	83 c4 10             	add    $0x10,%esp
  801fb6:	eb c6                	jmp    801f7e <nsipc+0x12>

00801fb8 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801fb8:	f3 0f 1e fb          	endbr32 
  801fbc:	55                   	push   %ebp
  801fbd:	89 e5                	mov    %esp,%ebp
  801fbf:	56                   	push   %esi
  801fc0:	53                   	push   %ebx
  801fc1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801fc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801fcc:	8b 06                	mov    (%esi),%eax
  801fce:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801fd3:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd8:	e8 8f ff ff ff       	call   801f6c <nsipc>
  801fdd:	89 c3                	mov    %eax,%ebx
  801fdf:	85 c0                	test   %eax,%eax
  801fe1:	79 09                	jns    801fec <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801fe3:	89 d8                	mov    %ebx,%eax
  801fe5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fe8:	5b                   	pop    %ebx
  801fe9:	5e                   	pop    %esi
  801fea:	5d                   	pop    %ebp
  801feb:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801fec:	83 ec 04             	sub    $0x4,%esp
  801fef:	ff 35 10 70 80 00    	pushl  0x807010
  801ff5:	68 00 70 80 00       	push   $0x807000
  801ffa:	ff 75 0c             	pushl  0xc(%ebp)
  801ffd:	e8 de ef ff ff       	call   800fe0 <memmove>
		*addrlen = ret->ret_addrlen;
  802002:	a1 10 70 80 00       	mov    0x807010,%eax
  802007:	89 06                	mov    %eax,(%esi)
  802009:	83 c4 10             	add    $0x10,%esp
	return r;
  80200c:	eb d5                	jmp    801fe3 <nsipc_accept+0x2b>

0080200e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80200e:	f3 0f 1e fb          	endbr32 
  802012:	55                   	push   %ebp
  802013:	89 e5                	mov    %esp,%ebp
  802015:	53                   	push   %ebx
  802016:	83 ec 08             	sub    $0x8,%esp
  802019:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80201c:	8b 45 08             	mov    0x8(%ebp),%eax
  80201f:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802024:	53                   	push   %ebx
  802025:	ff 75 0c             	pushl  0xc(%ebp)
  802028:	68 04 70 80 00       	push   $0x807004
  80202d:	e8 ae ef ff ff       	call   800fe0 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802032:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802038:	b8 02 00 00 00       	mov    $0x2,%eax
  80203d:	e8 2a ff ff ff       	call   801f6c <nsipc>
}
  802042:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802045:	c9                   	leave  
  802046:	c3                   	ret    

00802047 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802047:	f3 0f 1e fb          	endbr32 
  80204b:	55                   	push   %ebp
  80204c:	89 e5                	mov    %esp,%ebp
  80204e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802051:	8b 45 08             	mov    0x8(%ebp),%eax
  802054:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802059:	8b 45 0c             	mov    0xc(%ebp),%eax
  80205c:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802061:	b8 03 00 00 00       	mov    $0x3,%eax
  802066:	e8 01 ff ff ff       	call   801f6c <nsipc>
}
  80206b:	c9                   	leave  
  80206c:	c3                   	ret    

0080206d <nsipc_close>:

int
nsipc_close(int s)
{
  80206d:	f3 0f 1e fb          	endbr32 
  802071:	55                   	push   %ebp
  802072:	89 e5                	mov    %esp,%ebp
  802074:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802077:	8b 45 08             	mov    0x8(%ebp),%eax
  80207a:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80207f:	b8 04 00 00 00       	mov    $0x4,%eax
  802084:	e8 e3 fe ff ff       	call   801f6c <nsipc>
}
  802089:	c9                   	leave  
  80208a:	c3                   	ret    

0080208b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80208b:	f3 0f 1e fb          	endbr32 
  80208f:	55                   	push   %ebp
  802090:	89 e5                	mov    %esp,%ebp
  802092:	53                   	push   %ebx
  802093:	83 ec 08             	sub    $0x8,%esp
  802096:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802099:	8b 45 08             	mov    0x8(%ebp),%eax
  80209c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8020a1:	53                   	push   %ebx
  8020a2:	ff 75 0c             	pushl  0xc(%ebp)
  8020a5:	68 04 70 80 00       	push   $0x807004
  8020aa:	e8 31 ef ff ff       	call   800fe0 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8020af:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8020b5:	b8 05 00 00 00       	mov    $0x5,%eax
  8020ba:	e8 ad fe ff ff       	call   801f6c <nsipc>
}
  8020bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020c2:	c9                   	leave  
  8020c3:	c3                   	ret    

008020c4 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8020c4:	f3 0f 1e fb          	endbr32 
  8020c8:	55                   	push   %ebp
  8020c9:	89 e5                	mov    %esp,%ebp
  8020cb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8020ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d1:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8020d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d9:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8020de:	b8 06 00 00 00       	mov    $0x6,%eax
  8020e3:	e8 84 fe ff ff       	call   801f6c <nsipc>
}
  8020e8:	c9                   	leave  
  8020e9:	c3                   	ret    

008020ea <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8020ea:	f3 0f 1e fb          	endbr32 
  8020ee:	55                   	push   %ebp
  8020ef:	89 e5                	mov    %esp,%ebp
  8020f1:	56                   	push   %esi
  8020f2:	53                   	push   %ebx
  8020f3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8020f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8020fe:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802104:	8b 45 14             	mov    0x14(%ebp),%eax
  802107:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80210c:	b8 07 00 00 00       	mov    $0x7,%eax
  802111:	e8 56 fe ff ff       	call   801f6c <nsipc>
  802116:	89 c3                	mov    %eax,%ebx
  802118:	85 c0                	test   %eax,%eax
  80211a:	78 26                	js     802142 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  80211c:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  802122:	b8 3f 06 00 00       	mov    $0x63f,%eax
  802127:	0f 4e c6             	cmovle %esi,%eax
  80212a:	39 c3                	cmp    %eax,%ebx
  80212c:	7f 1d                	jg     80214b <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80212e:	83 ec 04             	sub    $0x4,%esp
  802131:	53                   	push   %ebx
  802132:	68 00 70 80 00       	push   $0x807000
  802137:	ff 75 0c             	pushl  0xc(%ebp)
  80213a:	e8 a1 ee ff ff       	call   800fe0 <memmove>
  80213f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802142:	89 d8                	mov    %ebx,%eax
  802144:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802147:	5b                   	pop    %ebx
  802148:	5e                   	pop    %esi
  802149:	5d                   	pop    %ebp
  80214a:	c3                   	ret    
		assert(r < 1600 && r <= len);
  80214b:	68 e7 31 80 00       	push   $0x8031e7
  802150:	68 4f 31 80 00       	push   $0x80314f
  802155:	6a 62                	push   $0x62
  802157:	68 fc 31 80 00       	push   $0x8031fc
  80215c:	e8 90 e5 ff ff       	call   8006f1 <_panic>

00802161 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802161:	f3 0f 1e fb          	endbr32 
  802165:	55                   	push   %ebp
  802166:	89 e5                	mov    %esp,%ebp
  802168:	53                   	push   %ebx
  802169:	83 ec 04             	sub    $0x4,%esp
  80216c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80216f:	8b 45 08             	mov    0x8(%ebp),%eax
  802172:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802177:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80217d:	7f 2e                	jg     8021ad <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80217f:	83 ec 04             	sub    $0x4,%esp
  802182:	53                   	push   %ebx
  802183:	ff 75 0c             	pushl  0xc(%ebp)
  802186:	68 0c 70 80 00       	push   $0x80700c
  80218b:	e8 50 ee ff ff       	call   800fe0 <memmove>
	nsipcbuf.send.req_size = size;
  802190:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802196:	8b 45 14             	mov    0x14(%ebp),%eax
  802199:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80219e:	b8 08 00 00 00       	mov    $0x8,%eax
  8021a3:	e8 c4 fd ff ff       	call   801f6c <nsipc>
}
  8021a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021ab:	c9                   	leave  
  8021ac:	c3                   	ret    
	assert(size < 1600);
  8021ad:	68 08 32 80 00       	push   $0x803208
  8021b2:	68 4f 31 80 00       	push   $0x80314f
  8021b7:	6a 6d                	push   $0x6d
  8021b9:	68 fc 31 80 00       	push   $0x8031fc
  8021be:	e8 2e e5 ff ff       	call   8006f1 <_panic>

008021c3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8021c3:	f3 0f 1e fb          	endbr32 
  8021c7:	55                   	push   %ebp
  8021c8:	89 e5                	mov    %esp,%ebp
  8021ca:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8021cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8021d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d8:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8021dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8021e0:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8021e5:	b8 09 00 00 00       	mov    $0x9,%eax
  8021ea:	e8 7d fd ff ff       	call   801f6c <nsipc>
}
  8021ef:	c9                   	leave  
  8021f0:	c3                   	ret    

008021f1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8021f1:	f3 0f 1e fb          	endbr32 
  8021f5:	55                   	push   %ebp
  8021f6:	89 e5                	mov    %esp,%ebp
  8021f8:	56                   	push   %esi
  8021f9:	53                   	push   %ebx
  8021fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8021fd:	83 ec 0c             	sub    $0xc,%esp
  802200:	ff 75 08             	pushl  0x8(%ebp)
  802203:	e8 f0 f2 ff ff       	call   8014f8 <fd2data>
  802208:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80220a:	83 c4 08             	add    $0x8,%esp
  80220d:	68 14 32 80 00       	push   $0x803214
  802212:	53                   	push   %ebx
  802213:	e8 ca eb ff ff       	call   800de2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802218:	8b 46 04             	mov    0x4(%esi),%eax
  80221b:	2b 06                	sub    (%esi),%eax
  80221d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802223:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80222a:	00 00 00 
	stat->st_dev = &devpipe;
  80222d:	c7 83 88 00 00 00 7c 	movl   $0x80407c,0x88(%ebx)
  802234:	40 80 00 
	return 0;
}
  802237:	b8 00 00 00 00       	mov    $0x0,%eax
  80223c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80223f:	5b                   	pop    %ebx
  802240:	5e                   	pop    %esi
  802241:	5d                   	pop    %ebp
  802242:	c3                   	ret    

00802243 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802243:	f3 0f 1e fb          	endbr32 
  802247:	55                   	push   %ebp
  802248:	89 e5                	mov    %esp,%ebp
  80224a:	53                   	push   %ebx
  80224b:	83 ec 0c             	sub    $0xc,%esp
  80224e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802251:	53                   	push   %ebx
  802252:	6a 00                	push   $0x0
  802254:	e8 3d f0 ff ff       	call   801296 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802259:	89 1c 24             	mov    %ebx,(%esp)
  80225c:	e8 97 f2 ff ff       	call   8014f8 <fd2data>
  802261:	83 c4 08             	add    $0x8,%esp
  802264:	50                   	push   %eax
  802265:	6a 00                	push   $0x0
  802267:	e8 2a f0 ff ff       	call   801296 <sys_page_unmap>
}
  80226c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80226f:	c9                   	leave  
  802270:	c3                   	ret    

00802271 <_pipeisclosed>:
{
  802271:	55                   	push   %ebp
  802272:	89 e5                	mov    %esp,%ebp
  802274:	57                   	push   %edi
  802275:	56                   	push   %esi
  802276:	53                   	push   %ebx
  802277:	83 ec 1c             	sub    $0x1c,%esp
  80227a:	89 c7                	mov    %eax,%edi
  80227c:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80227e:	a1 08 50 80 00       	mov    0x805008,%eax
  802283:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802286:	83 ec 0c             	sub    $0xc,%esp
  802289:	57                   	push   %edi
  80228a:	e8 5d 04 00 00       	call   8026ec <pageref>
  80228f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802292:	89 34 24             	mov    %esi,(%esp)
  802295:	e8 52 04 00 00       	call   8026ec <pageref>
		nn = thisenv->env_runs;
  80229a:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8022a0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8022a3:	83 c4 10             	add    $0x10,%esp
  8022a6:	39 cb                	cmp    %ecx,%ebx
  8022a8:	74 1b                	je     8022c5 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8022aa:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8022ad:	75 cf                	jne    80227e <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8022af:	8b 42 58             	mov    0x58(%edx),%eax
  8022b2:	6a 01                	push   $0x1
  8022b4:	50                   	push   %eax
  8022b5:	53                   	push   %ebx
  8022b6:	68 1b 32 80 00       	push   $0x80321b
  8022bb:	e8 18 e5 ff ff       	call   8007d8 <cprintf>
  8022c0:	83 c4 10             	add    $0x10,%esp
  8022c3:	eb b9                	jmp    80227e <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8022c5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8022c8:	0f 94 c0             	sete   %al
  8022cb:	0f b6 c0             	movzbl %al,%eax
}
  8022ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022d1:	5b                   	pop    %ebx
  8022d2:	5e                   	pop    %esi
  8022d3:	5f                   	pop    %edi
  8022d4:	5d                   	pop    %ebp
  8022d5:	c3                   	ret    

008022d6 <devpipe_write>:
{
  8022d6:	f3 0f 1e fb          	endbr32 
  8022da:	55                   	push   %ebp
  8022db:	89 e5                	mov    %esp,%ebp
  8022dd:	57                   	push   %edi
  8022de:	56                   	push   %esi
  8022df:	53                   	push   %ebx
  8022e0:	83 ec 28             	sub    $0x28,%esp
  8022e3:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8022e6:	56                   	push   %esi
  8022e7:	e8 0c f2 ff ff       	call   8014f8 <fd2data>
  8022ec:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8022ee:	83 c4 10             	add    $0x10,%esp
  8022f1:	bf 00 00 00 00       	mov    $0x0,%edi
  8022f6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8022f9:	74 4f                	je     80234a <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022fb:	8b 43 04             	mov    0x4(%ebx),%eax
  8022fe:	8b 0b                	mov    (%ebx),%ecx
  802300:	8d 51 20             	lea    0x20(%ecx),%edx
  802303:	39 d0                	cmp    %edx,%eax
  802305:	72 14                	jb     80231b <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  802307:	89 da                	mov    %ebx,%edx
  802309:	89 f0                	mov    %esi,%eax
  80230b:	e8 61 ff ff ff       	call   802271 <_pipeisclosed>
  802310:	85 c0                	test   %eax,%eax
  802312:	75 3b                	jne    80234f <devpipe_write+0x79>
			sys_yield();
  802314:	e8 0f ef ff ff       	call   801228 <sys_yield>
  802319:	eb e0                	jmp    8022fb <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80231b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80231e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802322:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802325:	89 c2                	mov    %eax,%edx
  802327:	c1 fa 1f             	sar    $0x1f,%edx
  80232a:	89 d1                	mov    %edx,%ecx
  80232c:	c1 e9 1b             	shr    $0x1b,%ecx
  80232f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802332:	83 e2 1f             	and    $0x1f,%edx
  802335:	29 ca                	sub    %ecx,%edx
  802337:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80233b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80233f:	83 c0 01             	add    $0x1,%eax
  802342:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802345:	83 c7 01             	add    $0x1,%edi
  802348:	eb ac                	jmp    8022f6 <devpipe_write+0x20>
	return i;
  80234a:	8b 45 10             	mov    0x10(%ebp),%eax
  80234d:	eb 05                	jmp    802354 <devpipe_write+0x7e>
				return 0;
  80234f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802354:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802357:	5b                   	pop    %ebx
  802358:	5e                   	pop    %esi
  802359:	5f                   	pop    %edi
  80235a:	5d                   	pop    %ebp
  80235b:	c3                   	ret    

0080235c <devpipe_read>:
{
  80235c:	f3 0f 1e fb          	endbr32 
  802360:	55                   	push   %ebp
  802361:	89 e5                	mov    %esp,%ebp
  802363:	57                   	push   %edi
  802364:	56                   	push   %esi
  802365:	53                   	push   %ebx
  802366:	83 ec 18             	sub    $0x18,%esp
  802369:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80236c:	57                   	push   %edi
  80236d:	e8 86 f1 ff ff       	call   8014f8 <fd2data>
  802372:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802374:	83 c4 10             	add    $0x10,%esp
  802377:	be 00 00 00 00       	mov    $0x0,%esi
  80237c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80237f:	75 14                	jne    802395 <devpipe_read+0x39>
	return i;
  802381:	8b 45 10             	mov    0x10(%ebp),%eax
  802384:	eb 02                	jmp    802388 <devpipe_read+0x2c>
				return i;
  802386:	89 f0                	mov    %esi,%eax
}
  802388:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80238b:	5b                   	pop    %ebx
  80238c:	5e                   	pop    %esi
  80238d:	5f                   	pop    %edi
  80238e:	5d                   	pop    %ebp
  80238f:	c3                   	ret    
			sys_yield();
  802390:	e8 93 ee ff ff       	call   801228 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802395:	8b 03                	mov    (%ebx),%eax
  802397:	3b 43 04             	cmp    0x4(%ebx),%eax
  80239a:	75 18                	jne    8023b4 <devpipe_read+0x58>
			if (i > 0)
  80239c:	85 f6                	test   %esi,%esi
  80239e:	75 e6                	jne    802386 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8023a0:	89 da                	mov    %ebx,%edx
  8023a2:	89 f8                	mov    %edi,%eax
  8023a4:	e8 c8 fe ff ff       	call   802271 <_pipeisclosed>
  8023a9:	85 c0                	test   %eax,%eax
  8023ab:	74 e3                	je     802390 <devpipe_read+0x34>
				return 0;
  8023ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8023b2:	eb d4                	jmp    802388 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8023b4:	99                   	cltd   
  8023b5:	c1 ea 1b             	shr    $0x1b,%edx
  8023b8:	01 d0                	add    %edx,%eax
  8023ba:	83 e0 1f             	and    $0x1f,%eax
  8023bd:	29 d0                	sub    %edx,%eax
  8023bf:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8023c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023c7:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8023ca:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8023cd:	83 c6 01             	add    $0x1,%esi
  8023d0:	eb aa                	jmp    80237c <devpipe_read+0x20>

008023d2 <pipe>:
{
  8023d2:	f3 0f 1e fb          	endbr32 
  8023d6:	55                   	push   %ebp
  8023d7:	89 e5                	mov    %esp,%ebp
  8023d9:	56                   	push   %esi
  8023da:	53                   	push   %ebx
  8023db:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8023de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023e1:	50                   	push   %eax
  8023e2:	e8 2c f1 ff ff       	call   801513 <fd_alloc>
  8023e7:	89 c3                	mov    %eax,%ebx
  8023e9:	83 c4 10             	add    $0x10,%esp
  8023ec:	85 c0                	test   %eax,%eax
  8023ee:	0f 88 23 01 00 00    	js     802517 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023f4:	83 ec 04             	sub    $0x4,%esp
  8023f7:	68 07 04 00 00       	push   $0x407
  8023fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8023ff:	6a 00                	push   $0x0
  802401:	e8 45 ee ff ff       	call   80124b <sys_page_alloc>
  802406:	89 c3                	mov    %eax,%ebx
  802408:	83 c4 10             	add    $0x10,%esp
  80240b:	85 c0                	test   %eax,%eax
  80240d:	0f 88 04 01 00 00    	js     802517 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  802413:	83 ec 0c             	sub    $0xc,%esp
  802416:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802419:	50                   	push   %eax
  80241a:	e8 f4 f0 ff ff       	call   801513 <fd_alloc>
  80241f:	89 c3                	mov    %eax,%ebx
  802421:	83 c4 10             	add    $0x10,%esp
  802424:	85 c0                	test   %eax,%eax
  802426:	0f 88 db 00 00 00    	js     802507 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80242c:	83 ec 04             	sub    $0x4,%esp
  80242f:	68 07 04 00 00       	push   $0x407
  802434:	ff 75 f0             	pushl  -0x10(%ebp)
  802437:	6a 00                	push   $0x0
  802439:	e8 0d ee ff ff       	call   80124b <sys_page_alloc>
  80243e:	89 c3                	mov    %eax,%ebx
  802440:	83 c4 10             	add    $0x10,%esp
  802443:	85 c0                	test   %eax,%eax
  802445:	0f 88 bc 00 00 00    	js     802507 <pipe+0x135>
	va = fd2data(fd0);
  80244b:	83 ec 0c             	sub    $0xc,%esp
  80244e:	ff 75 f4             	pushl  -0xc(%ebp)
  802451:	e8 a2 f0 ff ff       	call   8014f8 <fd2data>
  802456:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802458:	83 c4 0c             	add    $0xc,%esp
  80245b:	68 07 04 00 00       	push   $0x407
  802460:	50                   	push   %eax
  802461:	6a 00                	push   $0x0
  802463:	e8 e3 ed ff ff       	call   80124b <sys_page_alloc>
  802468:	89 c3                	mov    %eax,%ebx
  80246a:	83 c4 10             	add    $0x10,%esp
  80246d:	85 c0                	test   %eax,%eax
  80246f:	0f 88 82 00 00 00    	js     8024f7 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802475:	83 ec 0c             	sub    $0xc,%esp
  802478:	ff 75 f0             	pushl  -0x10(%ebp)
  80247b:	e8 78 f0 ff ff       	call   8014f8 <fd2data>
  802480:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802487:	50                   	push   %eax
  802488:	6a 00                	push   $0x0
  80248a:	56                   	push   %esi
  80248b:	6a 00                	push   $0x0
  80248d:	e8 df ed ff ff       	call   801271 <sys_page_map>
  802492:	89 c3                	mov    %eax,%ebx
  802494:	83 c4 20             	add    $0x20,%esp
  802497:	85 c0                	test   %eax,%eax
  802499:	78 4e                	js     8024e9 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  80249b:	a1 7c 40 80 00       	mov    0x80407c,%eax
  8024a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8024a3:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8024a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8024a8:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8024af:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8024b2:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8024b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024b7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8024be:	83 ec 0c             	sub    $0xc,%esp
  8024c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8024c4:	e8 1b f0 ff ff       	call   8014e4 <fd2num>
  8024c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024cc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8024ce:	83 c4 04             	add    $0x4,%esp
  8024d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8024d4:	e8 0b f0 ff ff       	call   8014e4 <fd2num>
  8024d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024dc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8024df:	83 c4 10             	add    $0x10,%esp
  8024e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024e7:	eb 2e                	jmp    802517 <pipe+0x145>
	sys_page_unmap(0, va);
  8024e9:	83 ec 08             	sub    $0x8,%esp
  8024ec:	56                   	push   %esi
  8024ed:	6a 00                	push   $0x0
  8024ef:	e8 a2 ed ff ff       	call   801296 <sys_page_unmap>
  8024f4:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8024f7:	83 ec 08             	sub    $0x8,%esp
  8024fa:	ff 75 f0             	pushl  -0x10(%ebp)
  8024fd:	6a 00                	push   $0x0
  8024ff:	e8 92 ed ff ff       	call   801296 <sys_page_unmap>
  802504:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802507:	83 ec 08             	sub    $0x8,%esp
  80250a:	ff 75 f4             	pushl  -0xc(%ebp)
  80250d:	6a 00                	push   $0x0
  80250f:	e8 82 ed ff ff       	call   801296 <sys_page_unmap>
  802514:	83 c4 10             	add    $0x10,%esp
}
  802517:	89 d8                	mov    %ebx,%eax
  802519:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80251c:	5b                   	pop    %ebx
  80251d:	5e                   	pop    %esi
  80251e:	5d                   	pop    %ebp
  80251f:	c3                   	ret    

00802520 <pipeisclosed>:
{
  802520:	f3 0f 1e fb          	endbr32 
  802524:	55                   	push   %ebp
  802525:	89 e5                	mov    %esp,%ebp
  802527:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80252a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80252d:	50                   	push   %eax
  80252e:	ff 75 08             	pushl  0x8(%ebp)
  802531:	e8 33 f0 ff ff       	call   801569 <fd_lookup>
  802536:	83 c4 10             	add    $0x10,%esp
  802539:	85 c0                	test   %eax,%eax
  80253b:	78 18                	js     802555 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  80253d:	83 ec 0c             	sub    $0xc,%esp
  802540:	ff 75 f4             	pushl  -0xc(%ebp)
  802543:	e8 b0 ef ff ff       	call   8014f8 <fd2data>
  802548:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80254a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80254d:	e8 1f fd ff ff       	call   802271 <_pipeisclosed>
  802552:	83 c4 10             	add    $0x10,%esp
}
  802555:	c9                   	leave  
  802556:	c3                   	ret    

00802557 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802557:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  80255b:	b8 00 00 00 00       	mov    $0x0,%eax
  802560:	c3                   	ret    

00802561 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802561:	f3 0f 1e fb          	endbr32 
  802565:	55                   	push   %ebp
  802566:	89 e5                	mov    %esp,%ebp
  802568:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80256b:	68 33 32 80 00       	push   $0x803233
  802570:	ff 75 0c             	pushl  0xc(%ebp)
  802573:	e8 6a e8 ff ff       	call   800de2 <strcpy>
	return 0;
}
  802578:	b8 00 00 00 00       	mov    $0x0,%eax
  80257d:	c9                   	leave  
  80257e:	c3                   	ret    

0080257f <devcons_write>:
{
  80257f:	f3 0f 1e fb          	endbr32 
  802583:	55                   	push   %ebp
  802584:	89 e5                	mov    %esp,%ebp
  802586:	57                   	push   %edi
  802587:	56                   	push   %esi
  802588:	53                   	push   %ebx
  802589:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80258f:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802594:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80259a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80259d:	73 31                	jae    8025d0 <devcons_write+0x51>
		m = n - tot;
  80259f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025a2:	29 f3                	sub    %esi,%ebx
  8025a4:	83 fb 7f             	cmp    $0x7f,%ebx
  8025a7:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8025ac:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8025af:	83 ec 04             	sub    $0x4,%esp
  8025b2:	53                   	push   %ebx
  8025b3:	89 f0                	mov    %esi,%eax
  8025b5:	03 45 0c             	add    0xc(%ebp),%eax
  8025b8:	50                   	push   %eax
  8025b9:	57                   	push   %edi
  8025ba:	e8 21 ea ff ff       	call   800fe0 <memmove>
		sys_cputs(buf, m);
  8025bf:	83 c4 08             	add    $0x8,%esp
  8025c2:	53                   	push   %ebx
  8025c3:	57                   	push   %edi
  8025c4:	e8 d3 eb ff ff       	call   80119c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8025c9:	01 de                	add    %ebx,%esi
  8025cb:	83 c4 10             	add    $0x10,%esp
  8025ce:	eb ca                	jmp    80259a <devcons_write+0x1b>
}
  8025d0:	89 f0                	mov    %esi,%eax
  8025d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025d5:	5b                   	pop    %ebx
  8025d6:	5e                   	pop    %esi
  8025d7:	5f                   	pop    %edi
  8025d8:	5d                   	pop    %ebp
  8025d9:	c3                   	ret    

008025da <devcons_read>:
{
  8025da:	f3 0f 1e fb          	endbr32 
  8025de:	55                   	push   %ebp
  8025df:	89 e5                	mov    %esp,%ebp
  8025e1:	83 ec 08             	sub    $0x8,%esp
  8025e4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8025e9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025ed:	74 21                	je     802610 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8025ef:	e8 ca eb ff ff       	call   8011be <sys_cgetc>
  8025f4:	85 c0                	test   %eax,%eax
  8025f6:	75 07                	jne    8025ff <devcons_read+0x25>
		sys_yield();
  8025f8:	e8 2b ec ff ff       	call   801228 <sys_yield>
  8025fd:	eb f0                	jmp    8025ef <devcons_read+0x15>
	if (c < 0)
  8025ff:	78 0f                	js     802610 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  802601:	83 f8 04             	cmp    $0x4,%eax
  802604:	74 0c                	je     802612 <devcons_read+0x38>
	*(char*)vbuf = c;
  802606:	8b 55 0c             	mov    0xc(%ebp),%edx
  802609:	88 02                	mov    %al,(%edx)
	return 1;
  80260b:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802610:	c9                   	leave  
  802611:	c3                   	ret    
		return 0;
  802612:	b8 00 00 00 00       	mov    $0x0,%eax
  802617:	eb f7                	jmp    802610 <devcons_read+0x36>

00802619 <cputchar>:
{
  802619:	f3 0f 1e fb          	endbr32 
  80261d:	55                   	push   %ebp
  80261e:	89 e5                	mov    %esp,%ebp
  802620:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802623:	8b 45 08             	mov    0x8(%ebp),%eax
  802626:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802629:	6a 01                	push   $0x1
  80262b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80262e:	50                   	push   %eax
  80262f:	e8 68 eb ff ff       	call   80119c <sys_cputs>
}
  802634:	83 c4 10             	add    $0x10,%esp
  802637:	c9                   	leave  
  802638:	c3                   	ret    

00802639 <getchar>:
{
  802639:	f3 0f 1e fb          	endbr32 
  80263d:	55                   	push   %ebp
  80263e:	89 e5                	mov    %esp,%ebp
  802640:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802643:	6a 01                	push   $0x1
  802645:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802648:	50                   	push   %eax
  802649:	6a 00                	push   $0x0
  80264b:	e8 a1 f1 ff ff       	call   8017f1 <read>
	if (r < 0)
  802650:	83 c4 10             	add    $0x10,%esp
  802653:	85 c0                	test   %eax,%eax
  802655:	78 06                	js     80265d <getchar+0x24>
	if (r < 1)
  802657:	74 06                	je     80265f <getchar+0x26>
	return c;
  802659:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80265d:	c9                   	leave  
  80265e:	c3                   	ret    
		return -E_EOF;
  80265f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802664:	eb f7                	jmp    80265d <getchar+0x24>

00802666 <iscons>:
{
  802666:	f3 0f 1e fb          	endbr32 
  80266a:	55                   	push   %ebp
  80266b:	89 e5                	mov    %esp,%ebp
  80266d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802670:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802673:	50                   	push   %eax
  802674:	ff 75 08             	pushl  0x8(%ebp)
  802677:	e8 ed ee ff ff       	call   801569 <fd_lookup>
  80267c:	83 c4 10             	add    $0x10,%esp
  80267f:	85 c0                	test   %eax,%eax
  802681:	78 11                	js     802694 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  802683:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802686:	8b 15 98 40 80 00    	mov    0x804098,%edx
  80268c:	39 10                	cmp    %edx,(%eax)
  80268e:	0f 94 c0             	sete   %al
  802691:	0f b6 c0             	movzbl %al,%eax
}
  802694:	c9                   	leave  
  802695:	c3                   	ret    

00802696 <opencons>:
{
  802696:	f3 0f 1e fb          	endbr32 
  80269a:	55                   	push   %ebp
  80269b:	89 e5                	mov    %esp,%ebp
  80269d:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8026a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026a3:	50                   	push   %eax
  8026a4:	e8 6a ee ff ff       	call   801513 <fd_alloc>
  8026a9:	83 c4 10             	add    $0x10,%esp
  8026ac:	85 c0                	test   %eax,%eax
  8026ae:	78 3a                	js     8026ea <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8026b0:	83 ec 04             	sub    $0x4,%esp
  8026b3:	68 07 04 00 00       	push   $0x407
  8026b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8026bb:	6a 00                	push   $0x0
  8026bd:	e8 89 eb ff ff       	call   80124b <sys_page_alloc>
  8026c2:	83 c4 10             	add    $0x10,%esp
  8026c5:	85 c0                	test   %eax,%eax
  8026c7:	78 21                	js     8026ea <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8026c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026cc:	8b 15 98 40 80 00    	mov    0x804098,%edx
  8026d2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8026d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026d7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8026de:	83 ec 0c             	sub    $0xc,%esp
  8026e1:	50                   	push   %eax
  8026e2:	e8 fd ed ff ff       	call   8014e4 <fd2num>
  8026e7:	83 c4 10             	add    $0x10,%esp
}
  8026ea:	c9                   	leave  
  8026eb:	c3                   	ret    

008026ec <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026ec:	f3 0f 1e fb          	endbr32 
  8026f0:	55                   	push   %ebp
  8026f1:	89 e5                	mov    %esp,%ebp
  8026f3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026f6:	89 c2                	mov    %eax,%edx
  8026f8:	c1 ea 16             	shr    $0x16,%edx
  8026fb:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802702:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802707:	f6 c1 01             	test   $0x1,%cl
  80270a:	74 1c                	je     802728 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  80270c:	c1 e8 0c             	shr    $0xc,%eax
  80270f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802716:	a8 01                	test   $0x1,%al
  802718:	74 0e                	je     802728 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80271a:	c1 e8 0c             	shr    $0xc,%eax
  80271d:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802724:	ef 
  802725:	0f b7 d2             	movzwl %dx,%edx
}
  802728:	89 d0                	mov    %edx,%eax
  80272a:	5d                   	pop    %ebp
  80272b:	c3                   	ret    
  80272c:	66 90                	xchg   %ax,%ax
  80272e:	66 90                	xchg   %ax,%ax

00802730 <__udivdi3>:
  802730:	f3 0f 1e fb          	endbr32 
  802734:	55                   	push   %ebp
  802735:	57                   	push   %edi
  802736:	56                   	push   %esi
  802737:	53                   	push   %ebx
  802738:	83 ec 1c             	sub    $0x1c,%esp
  80273b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80273f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802743:	8b 74 24 34          	mov    0x34(%esp),%esi
  802747:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80274b:	85 d2                	test   %edx,%edx
  80274d:	75 19                	jne    802768 <__udivdi3+0x38>
  80274f:	39 f3                	cmp    %esi,%ebx
  802751:	76 4d                	jbe    8027a0 <__udivdi3+0x70>
  802753:	31 ff                	xor    %edi,%edi
  802755:	89 e8                	mov    %ebp,%eax
  802757:	89 f2                	mov    %esi,%edx
  802759:	f7 f3                	div    %ebx
  80275b:	89 fa                	mov    %edi,%edx
  80275d:	83 c4 1c             	add    $0x1c,%esp
  802760:	5b                   	pop    %ebx
  802761:	5e                   	pop    %esi
  802762:	5f                   	pop    %edi
  802763:	5d                   	pop    %ebp
  802764:	c3                   	ret    
  802765:	8d 76 00             	lea    0x0(%esi),%esi
  802768:	39 f2                	cmp    %esi,%edx
  80276a:	76 14                	jbe    802780 <__udivdi3+0x50>
  80276c:	31 ff                	xor    %edi,%edi
  80276e:	31 c0                	xor    %eax,%eax
  802770:	89 fa                	mov    %edi,%edx
  802772:	83 c4 1c             	add    $0x1c,%esp
  802775:	5b                   	pop    %ebx
  802776:	5e                   	pop    %esi
  802777:	5f                   	pop    %edi
  802778:	5d                   	pop    %ebp
  802779:	c3                   	ret    
  80277a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802780:	0f bd fa             	bsr    %edx,%edi
  802783:	83 f7 1f             	xor    $0x1f,%edi
  802786:	75 48                	jne    8027d0 <__udivdi3+0xa0>
  802788:	39 f2                	cmp    %esi,%edx
  80278a:	72 06                	jb     802792 <__udivdi3+0x62>
  80278c:	31 c0                	xor    %eax,%eax
  80278e:	39 eb                	cmp    %ebp,%ebx
  802790:	77 de                	ja     802770 <__udivdi3+0x40>
  802792:	b8 01 00 00 00       	mov    $0x1,%eax
  802797:	eb d7                	jmp    802770 <__udivdi3+0x40>
  802799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027a0:	89 d9                	mov    %ebx,%ecx
  8027a2:	85 db                	test   %ebx,%ebx
  8027a4:	75 0b                	jne    8027b1 <__udivdi3+0x81>
  8027a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027ab:	31 d2                	xor    %edx,%edx
  8027ad:	f7 f3                	div    %ebx
  8027af:	89 c1                	mov    %eax,%ecx
  8027b1:	31 d2                	xor    %edx,%edx
  8027b3:	89 f0                	mov    %esi,%eax
  8027b5:	f7 f1                	div    %ecx
  8027b7:	89 c6                	mov    %eax,%esi
  8027b9:	89 e8                	mov    %ebp,%eax
  8027bb:	89 f7                	mov    %esi,%edi
  8027bd:	f7 f1                	div    %ecx
  8027bf:	89 fa                	mov    %edi,%edx
  8027c1:	83 c4 1c             	add    $0x1c,%esp
  8027c4:	5b                   	pop    %ebx
  8027c5:	5e                   	pop    %esi
  8027c6:	5f                   	pop    %edi
  8027c7:	5d                   	pop    %ebp
  8027c8:	c3                   	ret    
  8027c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027d0:	89 f9                	mov    %edi,%ecx
  8027d2:	b8 20 00 00 00       	mov    $0x20,%eax
  8027d7:	29 f8                	sub    %edi,%eax
  8027d9:	d3 e2                	shl    %cl,%edx
  8027db:	89 54 24 08          	mov    %edx,0x8(%esp)
  8027df:	89 c1                	mov    %eax,%ecx
  8027e1:	89 da                	mov    %ebx,%edx
  8027e3:	d3 ea                	shr    %cl,%edx
  8027e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8027e9:	09 d1                	or     %edx,%ecx
  8027eb:	89 f2                	mov    %esi,%edx
  8027ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027f1:	89 f9                	mov    %edi,%ecx
  8027f3:	d3 e3                	shl    %cl,%ebx
  8027f5:	89 c1                	mov    %eax,%ecx
  8027f7:	d3 ea                	shr    %cl,%edx
  8027f9:	89 f9                	mov    %edi,%ecx
  8027fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8027ff:	89 eb                	mov    %ebp,%ebx
  802801:	d3 e6                	shl    %cl,%esi
  802803:	89 c1                	mov    %eax,%ecx
  802805:	d3 eb                	shr    %cl,%ebx
  802807:	09 de                	or     %ebx,%esi
  802809:	89 f0                	mov    %esi,%eax
  80280b:	f7 74 24 08          	divl   0x8(%esp)
  80280f:	89 d6                	mov    %edx,%esi
  802811:	89 c3                	mov    %eax,%ebx
  802813:	f7 64 24 0c          	mull   0xc(%esp)
  802817:	39 d6                	cmp    %edx,%esi
  802819:	72 15                	jb     802830 <__udivdi3+0x100>
  80281b:	89 f9                	mov    %edi,%ecx
  80281d:	d3 e5                	shl    %cl,%ebp
  80281f:	39 c5                	cmp    %eax,%ebp
  802821:	73 04                	jae    802827 <__udivdi3+0xf7>
  802823:	39 d6                	cmp    %edx,%esi
  802825:	74 09                	je     802830 <__udivdi3+0x100>
  802827:	89 d8                	mov    %ebx,%eax
  802829:	31 ff                	xor    %edi,%edi
  80282b:	e9 40 ff ff ff       	jmp    802770 <__udivdi3+0x40>
  802830:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802833:	31 ff                	xor    %edi,%edi
  802835:	e9 36 ff ff ff       	jmp    802770 <__udivdi3+0x40>
  80283a:	66 90                	xchg   %ax,%ax
  80283c:	66 90                	xchg   %ax,%ax
  80283e:	66 90                	xchg   %ax,%ax

00802840 <__umoddi3>:
  802840:	f3 0f 1e fb          	endbr32 
  802844:	55                   	push   %ebp
  802845:	57                   	push   %edi
  802846:	56                   	push   %esi
  802847:	53                   	push   %ebx
  802848:	83 ec 1c             	sub    $0x1c,%esp
  80284b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80284f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802853:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802857:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80285b:	85 c0                	test   %eax,%eax
  80285d:	75 19                	jne    802878 <__umoddi3+0x38>
  80285f:	39 df                	cmp    %ebx,%edi
  802861:	76 5d                	jbe    8028c0 <__umoddi3+0x80>
  802863:	89 f0                	mov    %esi,%eax
  802865:	89 da                	mov    %ebx,%edx
  802867:	f7 f7                	div    %edi
  802869:	89 d0                	mov    %edx,%eax
  80286b:	31 d2                	xor    %edx,%edx
  80286d:	83 c4 1c             	add    $0x1c,%esp
  802870:	5b                   	pop    %ebx
  802871:	5e                   	pop    %esi
  802872:	5f                   	pop    %edi
  802873:	5d                   	pop    %ebp
  802874:	c3                   	ret    
  802875:	8d 76 00             	lea    0x0(%esi),%esi
  802878:	89 f2                	mov    %esi,%edx
  80287a:	39 d8                	cmp    %ebx,%eax
  80287c:	76 12                	jbe    802890 <__umoddi3+0x50>
  80287e:	89 f0                	mov    %esi,%eax
  802880:	89 da                	mov    %ebx,%edx
  802882:	83 c4 1c             	add    $0x1c,%esp
  802885:	5b                   	pop    %ebx
  802886:	5e                   	pop    %esi
  802887:	5f                   	pop    %edi
  802888:	5d                   	pop    %ebp
  802889:	c3                   	ret    
  80288a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802890:	0f bd e8             	bsr    %eax,%ebp
  802893:	83 f5 1f             	xor    $0x1f,%ebp
  802896:	75 50                	jne    8028e8 <__umoddi3+0xa8>
  802898:	39 d8                	cmp    %ebx,%eax
  80289a:	0f 82 e0 00 00 00    	jb     802980 <__umoddi3+0x140>
  8028a0:	89 d9                	mov    %ebx,%ecx
  8028a2:	39 f7                	cmp    %esi,%edi
  8028a4:	0f 86 d6 00 00 00    	jbe    802980 <__umoddi3+0x140>
  8028aa:	89 d0                	mov    %edx,%eax
  8028ac:	89 ca                	mov    %ecx,%edx
  8028ae:	83 c4 1c             	add    $0x1c,%esp
  8028b1:	5b                   	pop    %ebx
  8028b2:	5e                   	pop    %esi
  8028b3:	5f                   	pop    %edi
  8028b4:	5d                   	pop    %ebp
  8028b5:	c3                   	ret    
  8028b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028bd:	8d 76 00             	lea    0x0(%esi),%esi
  8028c0:	89 fd                	mov    %edi,%ebp
  8028c2:	85 ff                	test   %edi,%edi
  8028c4:	75 0b                	jne    8028d1 <__umoddi3+0x91>
  8028c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8028cb:	31 d2                	xor    %edx,%edx
  8028cd:	f7 f7                	div    %edi
  8028cf:	89 c5                	mov    %eax,%ebp
  8028d1:	89 d8                	mov    %ebx,%eax
  8028d3:	31 d2                	xor    %edx,%edx
  8028d5:	f7 f5                	div    %ebp
  8028d7:	89 f0                	mov    %esi,%eax
  8028d9:	f7 f5                	div    %ebp
  8028db:	89 d0                	mov    %edx,%eax
  8028dd:	31 d2                	xor    %edx,%edx
  8028df:	eb 8c                	jmp    80286d <__umoddi3+0x2d>
  8028e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028e8:	89 e9                	mov    %ebp,%ecx
  8028ea:	ba 20 00 00 00       	mov    $0x20,%edx
  8028ef:	29 ea                	sub    %ebp,%edx
  8028f1:	d3 e0                	shl    %cl,%eax
  8028f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8028f7:	89 d1                	mov    %edx,%ecx
  8028f9:	89 f8                	mov    %edi,%eax
  8028fb:	d3 e8                	shr    %cl,%eax
  8028fd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802901:	89 54 24 04          	mov    %edx,0x4(%esp)
  802905:	8b 54 24 04          	mov    0x4(%esp),%edx
  802909:	09 c1                	or     %eax,%ecx
  80290b:	89 d8                	mov    %ebx,%eax
  80290d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802911:	89 e9                	mov    %ebp,%ecx
  802913:	d3 e7                	shl    %cl,%edi
  802915:	89 d1                	mov    %edx,%ecx
  802917:	d3 e8                	shr    %cl,%eax
  802919:	89 e9                	mov    %ebp,%ecx
  80291b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80291f:	d3 e3                	shl    %cl,%ebx
  802921:	89 c7                	mov    %eax,%edi
  802923:	89 d1                	mov    %edx,%ecx
  802925:	89 f0                	mov    %esi,%eax
  802927:	d3 e8                	shr    %cl,%eax
  802929:	89 e9                	mov    %ebp,%ecx
  80292b:	89 fa                	mov    %edi,%edx
  80292d:	d3 e6                	shl    %cl,%esi
  80292f:	09 d8                	or     %ebx,%eax
  802931:	f7 74 24 08          	divl   0x8(%esp)
  802935:	89 d1                	mov    %edx,%ecx
  802937:	89 f3                	mov    %esi,%ebx
  802939:	f7 64 24 0c          	mull   0xc(%esp)
  80293d:	89 c6                	mov    %eax,%esi
  80293f:	89 d7                	mov    %edx,%edi
  802941:	39 d1                	cmp    %edx,%ecx
  802943:	72 06                	jb     80294b <__umoddi3+0x10b>
  802945:	75 10                	jne    802957 <__umoddi3+0x117>
  802947:	39 c3                	cmp    %eax,%ebx
  802949:	73 0c                	jae    802957 <__umoddi3+0x117>
  80294b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80294f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802953:	89 d7                	mov    %edx,%edi
  802955:	89 c6                	mov    %eax,%esi
  802957:	89 ca                	mov    %ecx,%edx
  802959:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80295e:	29 f3                	sub    %esi,%ebx
  802960:	19 fa                	sbb    %edi,%edx
  802962:	89 d0                	mov    %edx,%eax
  802964:	d3 e0                	shl    %cl,%eax
  802966:	89 e9                	mov    %ebp,%ecx
  802968:	d3 eb                	shr    %cl,%ebx
  80296a:	d3 ea                	shr    %cl,%edx
  80296c:	09 d8                	or     %ebx,%eax
  80296e:	83 c4 1c             	add    $0x1c,%esp
  802971:	5b                   	pop    %ebx
  802972:	5e                   	pop    %esi
  802973:	5f                   	pop    %edi
  802974:	5d                   	pop    %ebp
  802975:	c3                   	ret    
  802976:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80297d:	8d 76 00             	lea    0x0(%esi),%esi
  802980:	29 fe                	sub    %edi,%esi
  802982:	19 c3                	sbb    %eax,%ebx
  802984:	89 f2                	mov    %esi,%edx
  802986:	89 d9                	mov    %ebx,%ecx
  802988:	e9 1d ff ff ff       	jmp    8028aa <__umoddi3+0x6a>
