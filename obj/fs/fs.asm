
obj/fs/fs:     file format elf32-i386


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
  80002c:	e8 cf 18 00 00       	call   801900 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	f3 0f 1e fb          	endbr32 
  800063:	55                   	push   %ebp
  800064:	89 e5                	mov    %esp,%ebp
  800066:	53                   	push   %ebx
  800067:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  80006a:	b8 00 00 00 00       	mov    $0x0,%eax
  80006f:	e8 bf ff ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800074:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  800079:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80007e:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007f:	b9 00 00 00 00       	mov    $0x0,%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800084:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800089:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  80008a:	a8 a1                	test   $0xa1,%al
  80008c:	74 0b                	je     800099 <ide_probe_disk1+0x3a>
	     x++)
  80008e:	83 c1 01             	add    $0x1,%ecx
	for (x = 0;
  800091:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800097:	75 f0                	jne    800089 <ide_probe_disk1+0x2a>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800099:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  80009e:	ba f6 01 00 00       	mov    $0x1f6,%edx
  8000a3:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a4:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000aa:	0f 9e c3             	setle  %bl
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	0f b6 c3             	movzbl %bl,%eax
  8000b3:	50                   	push   %eax
  8000b4:	68 a0 3c 80 00       	push   $0x803ca0
  8000b9:	e8 91 19 00 00       	call   801a4f <cprintf>
	return (x < 1000);
}
  8000be:	89 d8                	mov    %ebx,%eax
  8000c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c5:	f3 0f 1e fb          	endbr32 
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000d2:	83 f8 01             	cmp    $0x1,%eax
  8000d5:	77 07                	ja     8000de <ide_set_disk+0x19>
		panic("bad disk number");
	diskno = d;
  8000d7:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000dc:	c9                   	leave  
  8000dd:	c3                   	ret    
		panic("bad disk number");
  8000de:	83 ec 04             	sub    $0x4,%esp
  8000e1:	68 b7 3c 80 00       	push   $0x803cb7
  8000e6:	6a 3a                	push   $0x3a
  8000e8:	68 c7 3c 80 00       	push   $0x803cc7
  8000ed:	e8 76 18 00 00       	call   801968 <_panic>

008000f2 <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000f2:	f3 0f 1e fb          	endbr32 
  8000f6:	55                   	push   %ebp
  8000f7:	89 e5                	mov    %esp,%ebp
  8000f9:	57                   	push   %edi
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	83 ec 0c             	sub    $0xc,%esp
  8000ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  800102:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800105:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  800108:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  80010e:	77 60                	ja     800170 <ide_read+0x7e>

	ide_wait_ready(0);
  800110:	b8 00 00 00 00       	mov    $0x0,%eax
  800115:	e8 19 ff ff ff       	call   800033 <ide_wait_ready>
  80011a:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80011f:	89 f0                	mov    %esi,%eax
  800121:	ee                   	out    %al,(%dx)
  800122:	ba f3 01 00 00       	mov    $0x1f3,%edx
  800127:	89 f8                	mov    %edi,%eax
  800129:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  80012a:	89 f8                	mov    %edi,%eax
  80012c:	c1 e8 08             	shr    $0x8,%eax
  80012f:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800134:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  800135:	89 f8                	mov    %edi,%eax
  800137:	c1 e8 10             	shr    $0x10,%eax
  80013a:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80013f:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800140:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800147:	c1 e0 04             	shl    $0x4,%eax
  80014a:	83 e0 10             	and    $0x10,%eax
  80014d:	c1 ef 18             	shr    $0x18,%edi
  800150:	83 e7 0f             	and    $0xf,%edi
  800153:	09 f8                	or     %edi,%eax
  800155:	83 c8 e0             	or     $0xffffffe0,%eax
  800158:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80015d:	ee                   	out    %al,(%dx)
  80015e:	b8 20 00 00 00       	mov    $0x20,%eax
  800163:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800168:	ee                   	out    %al,(%dx)
  800169:	c1 e6 09             	shl    $0x9,%esi
  80016c:	01 de                	add    %ebx,%esi
}
  80016e:	eb 2b                	jmp    80019b <ide_read+0xa9>
	assert(nsecs <= 256);
  800170:	68 d0 3c 80 00       	push   $0x803cd0
  800175:	68 dd 3c 80 00       	push   $0x803cdd
  80017a:	6a 44                	push   $0x44
  80017c:	68 c7 3c 80 00       	push   $0x803cc7
  800181:	e8 e2 17 00 00       	call   801968 <_panic>
	asm volatile("cld\n\trepne\n\tinsl"
  800186:	89 df                	mov    %ebx,%edi
  800188:	b9 80 00 00 00       	mov    $0x80,%ecx
  80018d:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800192:	fc                   	cld    
  800193:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800195:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80019b:	39 f3                	cmp    %esi,%ebx
  80019d:	74 10                	je     8001af <ide_read+0xbd>
		if ((r = ide_wait_ready(1)) < 0)
  80019f:	b8 01 00 00 00       	mov    $0x1,%eax
  8001a4:	e8 8a fe ff ff       	call   800033 <ide_wait_ready>
  8001a9:	85 c0                	test   %eax,%eax
  8001ab:	79 d9                	jns    800186 <ide_read+0x94>
  8001ad:	eb 05                	jmp    8001b4 <ide_read+0xc2>
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b7:	5b                   	pop    %ebx
  8001b8:	5e                   	pop    %esi
  8001b9:	5f                   	pop    %edi
  8001ba:	5d                   	pop    %ebp
  8001bb:	c3                   	ret    

008001bc <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001bc:	f3 0f 1e fb          	endbr32 
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 0c             	sub    $0xc,%esp
  8001c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001cf:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001d2:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001d8:	77 60                	ja     80023a <ide_write+0x7e>

	ide_wait_ready(0);
  8001da:	b8 00 00 00 00       	mov    $0x0,%eax
  8001df:	e8 4f fe ff ff       	call   800033 <ide_wait_ready>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001e4:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001e9:	89 f8                	mov    %edi,%eax
  8001eb:	ee                   	out    %al,(%dx)
  8001ec:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001f1:	89 f0                	mov    %esi,%eax
  8001f3:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  8001f4:	89 f0                	mov    %esi,%eax
  8001f6:	c1 e8 08             	shr    $0x8,%eax
  8001f9:	ba f4 01 00 00       	mov    $0x1f4,%edx
  8001fe:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  8001ff:	89 f0                	mov    %esi,%eax
  800201:	c1 e8 10             	shr    $0x10,%eax
  800204:	ba f5 01 00 00       	mov    $0x1f5,%edx
  800209:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  80020a:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800211:	c1 e0 04             	shl    $0x4,%eax
  800214:	83 e0 10             	and    $0x10,%eax
  800217:	c1 ee 18             	shr    $0x18,%esi
  80021a:	83 e6 0f             	and    $0xf,%esi
  80021d:	09 f0                	or     %esi,%eax
  80021f:	83 c8 e0             	or     $0xffffffe0,%eax
  800222:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800227:	ee                   	out    %al,(%dx)
  800228:	b8 30 00 00 00       	mov    $0x30,%eax
  80022d:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800232:	ee                   	out    %al,(%dx)
  800233:	c1 e7 09             	shl    $0x9,%edi
  800236:	01 df                	add    %ebx,%edi
}
  800238:	eb 2b                	jmp    800265 <ide_write+0xa9>
	assert(nsecs <= 256);
  80023a:	68 d0 3c 80 00       	push   $0x803cd0
  80023f:	68 dd 3c 80 00       	push   $0x803cdd
  800244:	6a 5d                	push   $0x5d
  800246:	68 c7 3c 80 00       	push   $0x803cc7
  80024b:	e8 18 17 00 00       	call   801968 <_panic>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  800250:	89 de                	mov    %ebx,%esi
  800252:	b9 80 00 00 00       	mov    $0x80,%ecx
  800257:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80025c:	fc                   	cld    
  80025d:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80025f:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800265:	39 fb                	cmp    %edi,%ebx
  800267:	74 10                	je     800279 <ide_write+0xbd>
		if ((r = ide_wait_ready(1)) < 0)
  800269:	b8 01 00 00 00       	mov    $0x1,%eax
  80026e:	e8 c0 fd ff ff       	call   800033 <ide_wait_ready>
  800273:	85 c0                	test   %eax,%eax
  800275:	79 d9                	jns    800250 <ide_write+0x94>
  800277:	eb 05                	jmp    80027e <ide_write+0xc2>
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800279:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80027e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800281:	5b                   	pop    %ebx
  800282:	5e                   	pop    %esi
  800283:	5f                   	pop    %edi
  800284:	5d                   	pop    %ebp
  800285:	c3                   	ret    

00800286 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800286:	f3 0f 1e fb          	endbr32 
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	56                   	push   %esi
  80028e:	53                   	push   %ebx
  80028f:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800292:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800294:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80029a:	89 c6                	mov    %eax,%esi
  80029c:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80029f:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  8002a4:	0f 87 95 00 00 00    	ja     80033f <bc_pgfault+0xb9>
		panic("page fault in FS: eip %08x, va %08x, err %04x\n",
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002aa:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8002af:	85 c0                	test   %eax,%eax
  8002b1:	74 09                	je     8002bc <bc_pgfault+0x36>
  8002b3:	39 70 04             	cmp    %esi,0x4(%eax)
  8002b6:	0f 86 9e 00 00 00    	jbe    80035a <bc_pgfault+0xd4>
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
	addr =ROUNDDOWN(addr, PGSIZE);
  8002bc:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// allocate一个page在addr上
	if ((r = sys_page_alloc(0, addr, PTE_P|PTE_U|PTE_W)))
  8002c2:	83 ec 04             	sub    $0x4,%esp
  8002c5:	6a 07                	push   $0x7
  8002c7:	53                   	push   %ebx
  8002c8:	6a 00                	push   $0x0
  8002ca:	e8 f3 21 00 00       	call   8024c2 <sys_page_alloc>
  8002cf:	83 c4 10             	add    $0x10,%esp
  8002d2:	85 c0                	test   %eax,%eax
  8002d4:	0f 85 92 00 00 00    	jne    80036c <bc_pgfault+0xe6>
		panic("in bc_pgfault, sys_page_alloc: %e\n", r);
	// secno 的计算方式是 blockno*8
	// 每一个block是4kB 一个sector是512bytes = 8分之1的block
	// read into the memory
	if ((r = ide_read(blockno*BLKSECTS, addr, BLKSECTS))<0)
  8002da:	83 ec 04             	sub    $0x4,%esp
  8002dd:	6a 08                	push   $0x8
  8002df:	53                   	push   %ebx
  8002e0:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  8002e7:	50                   	push   %eax
  8002e8:	e8 05 fe ff ff       	call   8000f2 <ide_read>
  8002ed:	83 c4 10             	add    $0x10,%esp
  8002f0:	85 c0                	test   %eax,%eax
  8002f2:	0f 88 86 00 00 00    	js     80037e <bc_pgfault+0xf8>
		panic("in bc_pgfault, ide_read: %e\n", r);

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  8002f8:	89 d8                	mov    %ebx,%eax
  8002fa:	c1 e8 0c             	shr    $0xc,%eax
  8002fd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800304:	83 ec 0c             	sub    $0xc,%esp
  800307:	25 07 0e 00 00       	and    $0xe07,%eax
  80030c:	50                   	push   %eax
  80030d:	53                   	push   %ebx
  80030e:	6a 00                	push   $0x0
  800310:	53                   	push   %ebx
  800311:	6a 00                	push   $0x0
  800313:	e8 d0 21 00 00       	call   8024e8 <sys_page_map>
  800318:	83 c4 20             	add    $0x20,%esp
  80031b:	85 c0                	test   %eax,%eax
  80031d:	78 71                	js     800390 <bc_pgfault+0x10a>
		panic("in bc_pgfault, sys_page_map: %e\n", r);

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  80031f:	83 3d 08 a0 80 00 00 	cmpl   $0x0,0x80a008
  800326:	74 10                	je     800338 <bc_pgfault+0xb2>
  800328:	83 ec 0c             	sub    $0xc,%esp
  80032b:	56                   	push   %esi
  80032c:	e8 54 02 00 00       	call   800585 <block_is_free>
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	84 c0                	test   %al,%al
  800336:	75 6a                	jne    8003a2 <bc_pgfault+0x11c>
		panic("reading free block %08x\n", blockno);

}
  800338:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80033b:	5b                   	pop    %ebx
  80033c:	5e                   	pop    %esi
  80033d:	5d                   	pop    %ebp
  80033e:	c3                   	ret    
		panic("page fault in FS: eip %08x, va %08x, err %04x\n",
  80033f:	83 ec 08             	sub    $0x8,%esp
  800342:	ff 72 04             	pushl  0x4(%edx)
  800345:	53                   	push   %ebx
  800346:	ff 72 28             	pushl  0x28(%edx)
  800349:	68 f4 3c 80 00       	push   $0x803cf4
  80034e:	6a 26                	push   $0x26
  800350:	68 f6 3d 80 00       	push   $0x803df6
  800355:	e8 0e 16 00 00       	call   801968 <_panic>
		panic("reading non-existent block %08x\n", blockno);
  80035a:	56                   	push   %esi
  80035b:	68 24 3d 80 00       	push   $0x803d24
  800360:	6a 2b                	push   $0x2b
  800362:	68 f6 3d 80 00       	push   $0x803df6
  800367:	e8 fc 15 00 00       	call   801968 <_panic>
		panic("in bc_pgfault, sys_page_alloc: %e\n", r);
  80036c:	50                   	push   %eax
  80036d:	68 48 3d 80 00       	push   $0x803d48
  800372:	6a 36                	push   $0x36
  800374:	68 f6 3d 80 00       	push   $0x803df6
  800379:	e8 ea 15 00 00       	call   801968 <_panic>
		panic("in bc_pgfault, ide_read: %e\n", r);
  80037e:	50                   	push   %eax
  80037f:	68 fe 3d 80 00       	push   $0x803dfe
  800384:	6a 3b                	push   $0x3b
  800386:	68 f6 3d 80 00       	push   $0x803df6
  80038b:	e8 d8 15 00 00       	call   801968 <_panic>
		panic("in bc_pgfault, sys_page_map: %e\n", r);
  800390:	50                   	push   %eax
  800391:	68 6c 3d 80 00       	push   $0x803d6c
  800396:	6a 40                	push   $0x40
  800398:	68 f6 3d 80 00       	push   $0x803df6
  80039d:	e8 c6 15 00 00       	call   801968 <_panic>
		panic("reading free block %08x\n", blockno);
  8003a2:	56                   	push   %esi
  8003a3:	68 1b 3e 80 00       	push   $0x803e1b
  8003a8:	6a 46                	push   $0x46
  8003aa:	68 f6 3d 80 00       	push   $0x803df6
  8003af:	e8 b4 15 00 00       	call   801968 <_panic>

008003b4 <diskaddr>:
{
  8003b4:	f3 0f 1e fb          	endbr32 
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
  8003bb:	83 ec 08             	sub    $0x8,%esp
  8003be:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  8003c1:	85 c0                	test   %eax,%eax
  8003c3:	74 19                	je     8003de <diskaddr+0x2a>
  8003c5:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8003cb:	85 d2                	test   %edx,%edx
  8003cd:	74 05                	je     8003d4 <diskaddr+0x20>
  8003cf:	39 42 04             	cmp    %eax,0x4(%edx)
  8003d2:	76 0a                	jbe    8003de <diskaddr+0x2a>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003d4:	05 00 00 01 00       	add    $0x10000,%eax
  8003d9:	c1 e0 0c             	shl    $0xc,%eax
}
  8003dc:	c9                   	leave  
  8003dd:	c3                   	ret    
		panic("bad block number %08x in diskaddr", blockno);
  8003de:	50                   	push   %eax
  8003df:	68 90 3d 80 00       	push   $0x803d90
  8003e4:	6a 09                	push   $0x9
  8003e6:	68 f6 3d 80 00       	push   $0x803df6
  8003eb:	e8 78 15 00 00       	call   801968 <_panic>

008003f0 <va_is_mapped>:
{
  8003f0:	f3 0f 1e fb          	endbr32 
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003fa:	89 d0                	mov    %edx,%eax
  8003fc:	c1 e8 16             	shr    $0x16,%eax
  8003ff:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  800406:	b8 00 00 00 00       	mov    $0x0,%eax
  80040b:	f6 c1 01             	test   $0x1,%cl
  80040e:	74 0d                	je     80041d <va_is_mapped+0x2d>
  800410:	c1 ea 0c             	shr    $0xc,%edx
  800413:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80041a:	83 e0 01             	and    $0x1,%eax
  80041d:	83 e0 01             	and    $0x1,%eax
}
  800420:	5d                   	pop    %ebp
  800421:	c3                   	ret    

00800422 <va_is_dirty>:
{
  800422:	f3 0f 1e fb          	endbr32 
  800426:	55                   	push   %ebp
  800427:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  800429:	8b 45 08             	mov    0x8(%ebp),%eax
  80042c:	c1 e8 0c             	shr    $0xc,%eax
  80042f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800436:	c1 e8 06             	shr    $0x6,%eax
  800439:	83 e0 01             	and    $0x1,%eax
}
  80043c:	5d                   	pop    %ebp
  80043d:	c3                   	ret    

0080043e <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  80043e:	f3 0f 1e fb          	endbr32 
  800442:	55                   	push   %ebp
  800443:	89 e5                	mov    %esp,%ebp
  800445:	56                   	push   %esi
  800446:	53                   	push   %ebx
  800447:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  80044a:	8d b3 00 00 00 f0    	lea    -0x10000000(%ebx),%esi

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800450:	81 fe ff ff ff bf    	cmp    $0xbfffffff,%esi
  800456:	77 17                	ja     80046f <flush_block+0x31>
		panic("flush_block of bad va %08x", addr);

	// LAB 5: Your code here.
	if (!va_is_mapped(addr)||!va_is_dirty(addr)){
  800458:	83 ec 0c             	sub    $0xc,%esp
  80045b:	53                   	push   %ebx
  80045c:	e8 8f ff ff ff       	call   8003f0 <va_is_mapped>
  800461:	83 c4 10             	add    $0x10,%esp
  800464:	84 c0                	test   %al,%al
  800466:	75 19                	jne    800481 <flush_block+0x43>
		panic("in flush_block, ide_write: %e\n", r);
	// clear the dirty bit
	if ((r = sys_page_map(0, addr, 0 , addr, PTE_SYSCALL&~PTE_D))<0)
		panic("in flush_block, sys_page_map: %e\n", r);
	
}
  800468:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80046b:	5b                   	pop    %ebx
  80046c:	5e                   	pop    %esi
  80046d:	5d                   	pop    %ebp
  80046e:	c3                   	ret    
		panic("flush_block of bad va %08x", addr);
  80046f:	53                   	push   %ebx
  800470:	68 34 3e 80 00       	push   $0x803e34
  800475:	6a 58                	push   $0x58
  800477:	68 f6 3d 80 00       	push   $0x803df6
  80047c:	e8 e7 14 00 00       	call   801968 <_panic>
	if (!va_is_mapped(addr)||!va_is_dirty(addr)){
  800481:	83 ec 0c             	sub    $0xc,%esp
  800484:	53                   	push   %ebx
  800485:	e8 98 ff ff ff       	call   800422 <va_is_dirty>
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	84 c0                	test   %al,%al
  80048f:	74 d7                	je     800468 <flush_block+0x2a>
	addr = ROUNDDOWN(addr, PGSIZE);
  800491:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = ide_write(blockno*BLKSECTS, addr, BLKSECTS))<0)
  800497:	83 ec 04             	sub    $0x4,%esp
  80049a:	6a 08                	push   $0x8
  80049c:	53                   	push   %ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  80049d:	c1 ee 0c             	shr    $0xc,%esi
	if ((r = ide_write(blockno*BLKSECTS, addr, BLKSECTS))<0)
  8004a0:	c1 e6 03             	shl    $0x3,%esi
  8004a3:	56                   	push   %esi
  8004a4:	e8 13 fd ff ff       	call   8001bc <ide_write>
  8004a9:	83 c4 10             	add    $0x10,%esp
  8004ac:	85 c0                	test   %eax,%eax
  8004ae:	78 2c                	js     8004dc <flush_block+0x9e>
	if ((r = sys_page_map(0, addr, 0 , addr, PTE_SYSCALL&~PTE_D))<0)
  8004b0:	83 ec 0c             	sub    $0xc,%esp
  8004b3:	68 07 0e 00 00       	push   $0xe07
  8004b8:	53                   	push   %ebx
  8004b9:	6a 00                	push   $0x0
  8004bb:	53                   	push   %ebx
  8004bc:	6a 00                	push   $0x0
  8004be:	e8 25 20 00 00       	call   8024e8 <sys_page_map>
  8004c3:	83 c4 20             	add    $0x20,%esp
  8004c6:	85 c0                	test   %eax,%eax
  8004c8:	79 9e                	jns    800468 <flush_block+0x2a>
		panic("in flush_block, sys_page_map: %e\n", r);
  8004ca:	50                   	push   %eax
  8004cb:	68 d4 3d 80 00       	push   $0x803dd4
  8004d0:	6a 64                	push   $0x64
  8004d2:	68 f6 3d 80 00       	push   $0x803df6
  8004d7:	e8 8c 14 00 00       	call   801968 <_panic>
		panic("in flush_block, ide_write: %e\n", r);
  8004dc:	50                   	push   %eax
  8004dd:	68 b4 3d 80 00       	push   $0x803db4
  8004e2:	6a 61                	push   $0x61
  8004e4:	68 f6 3d 80 00       	push   $0x803df6
  8004e9:	e8 7a 14 00 00       	call   801968 <_panic>

008004ee <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004ee:	f3 0f 1e fb          	endbr32 
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
  8004f5:	81 ec 24 01 00 00    	sub    $0x124,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004fb:	68 86 02 80 00       	push   $0x800286
  800500:	e8 54 21 00 00       	call   802659 <set_pgfault_handler>
	// check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800505:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80050c:	e8 a3 fe ff ff       	call   8003b4 <diskaddr>
  800511:	83 c4 0c             	add    $0xc,%esp
  800514:	68 08 01 00 00       	push   $0x108
  800519:	50                   	push   %eax
  80051a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800520:	50                   	push   %eax
  800521:	e8 31 1d 00 00       	call   802257 <memmove>
}
  800526:	83 c4 10             	add    $0x10,%esp
  800529:	c9                   	leave  
  80052a:	c3                   	ret    

0080052b <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  80052b:	f3 0f 1e fb          	endbr32 
  80052f:	55                   	push   %ebp
  800530:	89 e5                	mov    %esp,%ebp
  800532:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  800535:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80053a:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800540:	75 1b                	jne    80055d <check_super+0x32>
		panic("bad file system magic number");

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  800542:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  800549:	77 26                	ja     800571 <check_super+0x46>
		panic("file system is too large");

	cprintf("superblock is good\n");
  80054b:	83 ec 0c             	sub    $0xc,%esp
  80054e:	68 8d 3e 80 00       	push   $0x803e8d
  800553:	e8 f7 14 00 00       	call   801a4f <cprintf>
}
  800558:	83 c4 10             	add    $0x10,%esp
  80055b:	c9                   	leave  
  80055c:	c3                   	ret    
		panic("bad file system magic number");
  80055d:	83 ec 04             	sub    $0x4,%esp
  800560:	68 4f 3e 80 00       	push   $0x803e4f
  800565:	6a 0f                	push   $0xf
  800567:	68 6c 3e 80 00       	push   $0x803e6c
  80056c:	e8 f7 13 00 00       	call   801968 <_panic>
		panic("file system is too large");
  800571:	83 ec 04             	sub    $0x4,%esp
  800574:	68 74 3e 80 00       	push   $0x803e74
  800579:	6a 12                	push   $0x12
  80057b:	68 6c 3e 80 00       	push   $0x803e6c
  800580:	e8 e3 13 00 00       	call   801968 <_panic>

00800585 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  800585:	f3 0f 1e fb          	endbr32 
  800589:	55                   	push   %ebp
  80058a:	89 e5                	mov    %esp,%ebp
  80058c:	53                   	push   %ebx
  80058d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  800590:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800595:	85 c0                	test   %eax,%eax
  800597:	74 27                	je     8005c0 <block_is_free+0x3b>
		return 0;
  800599:	ba 00 00 00 00       	mov    $0x0,%edx
	if (super == 0 || blockno >= super->s_nblocks)
  80059e:	39 48 04             	cmp    %ecx,0x4(%eax)
  8005a1:	76 18                	jbe    8005bb <block_is_free+0x36>
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  8005a3:	89 cb                	mov    %ecx,%ebx
  8005a5:	c1 eb 05             	shr    $0x5,%ebx
  8005a8:	b8 01 00 00 00       	mov    $0x1,%eax
  8005ad:	d3 e0                	shl    %cl,%eax
  8005af:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8005b5:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  8005b8:	0f 95 c2             	setne  %dl
		return 1;
	return 0;
}
  8005bb:	89 d0                	mov    %edx,%eax
  8005bd:	5b                   	pop    %ebx
  8005be:	5d                   	pop    %ebp
  8005bf:	c3                   	ret    
		return 0;
  8005c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c5:	eb f4                	jmp    8005bb <block_is_free+0x36>

008005c7 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  8005c7:	f3 0f 1e fb          	endbr32 
  8005cb:	55                   	push   %ebp
  8005cc:	89 e5                	mov    %esp,%ebp
  8005ce:	53                   	push   %ebx
  8005cf:	83 ec 04             	sub    $0x4,%esp
  8005d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  8005d5:	85 c9                	test   %ecx,%ecx
  8005d7:	74 1a                	je     8005f3 <free_block+0x2c>
		panic("attempt to free zero block");
	bitmap[blockno/32] |= 1<<(blockno%32);
  8005d9:	89 cb                	mov    %ecx,%ebx
  8005db:	c1 eb 05             	shr    $0x5,%ebx
  8005de:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8005e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8005e9:	d3 e0                	shl    %cl,%eax
  8005eb:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  8005ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005f1:	c9                   	leave  
  8005f2:	c3                   	ret    
		panic("attempt to free zero block");
  8005f3:	83 ec 04             	sub    $0x4,%esp
  8005f6:	68 a1 3e 80 00       	push   $0x803ea1
  8005fb:	6a 2d                	push   $0x2d
  8005fd:	68 6c 3e 80 00       	push   $0x803e6c
  800602:	e8 61 13 00 00       	call   801968 <_panic>

00800607 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800607:	f3 0f 1e fb          	endbr32 
  80060b:	55                   	push   %ebp
  80060c:	89 e5                	mov    %esp,%ebp
  80060e:	56                   	push   %esi
  80060f:	53                   	push   %ebx
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	uint32_t blockno;
	for (blockno = 0; blockno < super->s_nblocks; blockno++){
  800610:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800615:	8b 70 04             	mov    0x4(%eax),%esi
  800618:	bb 00 00 00 00       	mov    $0x0,%ebx
  80061d:	39 de                	cmp    %ebx,%esi
  80061f:	74 41                	je     800662 <alloc_block+0x5b>
		// block 0  是boot sector 和 partition table
		// block 1 是SuperBlock
		if (block_is_free(blockno)){
  800621:	83 ec 0c             	sub    $0xc,%esp
  800624:	53                   	push   %ebx
  800625:	e8 5b ff ff ff       	call   800585 <block_is_free>
  80062a:	83 c4 10             	add    $0x10,%esp
  80062d:	84 c0                	test   %al,%al
  80062f:	75 05                	jne    800636 <alloc_block+0x2f>
	for (blockno = 0; blockno < super->s_nblocks; blockno++){
  800631:	83 c3 01             	add    $0x1,%ebx
  800634:	eb e7                	jmp    80061d <alloc_block+0x16>
			// mark the block as in-use
			bitmap[blockno/32]^=1<<(blockno%32);
  800636:	89 de                	mov    %ebx,%esi
  800638:	c1 ee 05             	shr    $0x5,%esi
  80063b:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  800641:	b8 01 00 00 00       	mov    $0x1,%eax
  800646:	89 d9                	mov    %ebx,%ecx
  800648:	d3 e0                	shl    %cl,%eax
  80064a:	31 04 b2             	xor    %eax,(%edx,%esi,4)
			// flush it back to disk
			flush_block(bitmap);
  80064d:	83 ec 0c             	sub    $0xc,%esp
  800650:	ff 35 08 a0 80 00    	pushl  0x80a008
  800656:	e8 e3 fd ff ff       	call   80043e <flush_block>
			return blockno;
  80065b:	89 d8                	mov    %ebx,%eax
  80065d:	83 c4 10             	add    $0x10,%esp
  800660:	eb 05                	jmp    800667 <alloc_block+0x60>
		}
	}
	return -E_NO_DISK;
  800662:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  800667:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80066a:	5b                   	pop    %ebx
  80066b:	5e                   	pop    %esi
  80066c:	5d                   	pop    %ebp
  80066d:	c3                   	ret    

0080066e <file_block_walk>:
// diskbno 是offset on the disk
// 在手册中写道： for simiplicity we will use this one File structure to represent file meta-data 
// 				as it appears *both on disk and in memory*
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	57                   	push   %edi
  800672:	56                   	push   %esi
  800673:	53                   	push   %ebx
  800674:	83 ec 0c             	sub    $0xc,%esp
  800677:	89 c6                	mov    %eax,%esi
  800679:	8b 45 08             	mov    0x8(%ebp),%eax
       // LAB 5: Your code here
	   // out of bound
	   int r;
	   if (filebno >= NDIRECT + NINDIRECT) return -E_INVAL;
  80067c:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  800682:	0f 87 a9 00 00 00    	ja     800731 <file_block_walk+0xc3>
  800688:	89 d3                	mov    %edx,%ebx
  80068a:	89 cf                	mov    %ecx,%edi

	   if (filebno<NDIRECT){
  80068c:	83 fa 09             	cmp    $0x9,%edx
  80068f:	0f 86 83 00 00 00    	jbe    800718 <file_block_walk+0xaa>
		   		*ppdiskbno = &f->f_direct[filebno];
			return 0;
	   }
	   else {
		   // filebno 在 NINDIRECT 里
		   if (f->f_indirect==0){
  800695:	83 be b0 00 00 00 00 	cmpl   $0x0,0xb0(%esi)
  80069c:	75 4d                	jne    8006eb <file_block_walk+0x7d>
			   // 还未分配一个indirect block给这个file
			   if(alloc){
  80069e:	84 c0                	test   %al,%al
  8006a0:	0f 84 92 00 00 00    	je     800738 <file_block_walk+0xca>
				   // 分配一个block来hold indirect pointers
				   if ((r = alloc_block())<0)
  8006a6:	e8 5c ff ff ff       	call   800607 <alloc_block>
  8006ab:	85 c0                	test   %eax,%eax
  8006ad:	0f 88 8c 00 00 00    	js     80073f <file_block_walk+0xd1>
						return -E_NO_DISK;
					f->f_indirect = r;
  8006b3:	89 86 b0 00 00 00    	mov    %eax,0xb0(%esi)
				   memset(diskaddr(f->f_indirect), 0, BLKSIZE);
  8006b9:	83 ec 0c             	sub    $0xc,%esp
  8006bc:	50                   	push   %eax
  8006bd:	e8 f2 fc ff ff       	call   8003b4 <diskaddr>
  8006c2:	83 c4 0c             	add    $0xc,%esp
  8006c5:	68 00 10 00 00       	push   $0x1000
  8006ca:	6a 00                	push   $0x0
  8006cc:	50                   	push   %eax
  8006cd:	e8 39 1b 00 00       	call   80220b <memset>
				   flush_block(diskaddr(f->f_indirect));
  8006d2:	83 c4 04             	add    $0x4,%esp
  8006d5:	ff b6 b0 00 00 00    	pushl  0xb0(%esi)
  8006db:	e8 d4 fc ff ff       	call   8003b4 <diskaddr>
  8006e0:	89 04 24             	mov    %eax,(%esp)
  8006e3:	e8 56 fd ff ff       	call   80043e <flush_block>
  8006e8:	83 c4 10             	add    $0x10,%esp
		// 已经分配了一个indirect block
	if (ppdiskbno){
		uint32_t* f_indirect_ptr = diskaddr(f->f_indirect);
		*ppdiskbno = &f_indirect_ptr[filebno-NDIRECT];
	}
	return 0;
  8006eb:	b8 00 00 00 00       	mov    $0x0,%eax
	if (ppdiskbno){
  8006f0:	85 ff                	test   %edi,%edi
  8006f2:	74 1c                	je     800710 <file_block_walk+0xa2>
		uint32_t* f_indirect_ptr = diskaddr(f->f_indirect);
  8006f4:	83 ec 0c             	sub    $0xc,%esp
  8006f7:	ff b6 b0 00 00 00    	pushl  0xb0(%esi)
  8006fd:	e8 b2 fc ff ff       	call   8003b4 <diskaddr>
		*ppdiskbno = &f_indirect_ptr[filebno-NDIRECT];
  800702:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800706:	89 07                	mov    %eax,(%edi)
  800708:	83 c4 10             	add    $0x10,%esp
	return 0;
  80070b:	b8 00 00 00 00       	mov    $0x0,%eax
      
}
  800710:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800713:	5b                   	pop    %ebx
  800714:	5e                   	pop    %esi
  800715:	5f                   	pop    %edi
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    
			return 0;
  800718:	b8 00 00 00 00       	mov    $0x0,%eax
		   if (ppdiskbno)
  80071d:	85 c9                	test   %ecx,%ecx
  80071f:	74 ef                	je     800710 <file_block_walk+0xa2>
		   		*ppdiskbno = &f->f_direct[filebno];
  800721:	8d 84 96 88 00 00 00 	lea    0x88(%esi,%edx,4),%eax
  800728:	89 01                	mov    %eax,(%ecx)
			return 0;
  80072a:	b8 00 00 00 00       	mov    $0x0,%eax
  80072f:	eb df                	jmp    800710 <file_block_walk+0xa2>
	   if (filebno >= NDIRECT + NINDIRECT) return -E_INVAL;
  800731:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800736:	eb d8                	jmp    800710 <file_block_walk+0xa2>
			   		return -E_NOT_FOUND;
  800738:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  80073d:	eb d1                	jmp    800710 <file_block_walk+0xa2>
						return -E_NO_DISK;
  80073f:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
  800744:	eb ca                	jmp    800710 <file_block_walk+0xa2>

00800746 <check_bitmap>:
{
  800746:	f3 0f 1e fb          	endbr32 
  80074a:	55                   	push   %ebp
  80074b:	89 e5                	mov    %esp,%ebp
  80074d:	56                   	push   %esi
  80074e:	53                   	push   %ebx
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  80074f:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800754:	8b 70 04             	mov    0x4(%eax),%esi
  800757:	bb 00 00 00 00       	mov    $0x0,%ebx
  80075c:	89 d8                	mov    %ebx,%eax
  80075e:	c1 e0 0f             	shl    $0xf,%eax
  800761:	39 c6                	cmp    %eax,%esi
  800763:	76 2e                	jbe    800793 <check_bitmap+0x4d>
		assert(!block_is_free(2+i));
  800765:	83 ec 0c             	sub    $0xc,%esp
  800768:	8d 43 02             	lea    0x2(%ebx),%eax
  80076b:	50                   	push   %eax
  80076c:	e8 14 fe ff ff       	call   800585 <block_is_free>
  800771:	83 c4 10             	add    $0x10,%esp
  800774:	84 c0                	test   %al,%al
  800776:	75 05                	jne    80077d <check_bitmap+0x37>
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800778:	83 c3 01             	add    $0x1,%ebx
  80077b:	eb df                	jmp    80075c <check_bitmap+0x16>
		assert(!block_is_free(2+i));
  80077d:	68 bc 3e 80 00       	push   $0x803ebc
  800782:	68 dd 3c 80 00       	push   $0x803cdd
  800787:	6a 5b                	push   $0x5b
  800789:	68 6c 3e 80 00       	push   $0x803e6c
  80078e:	e8 d5 11 00 00       	call   801968 <_panic>
	assert(!block_is_free(0));
  800793:	83 ec 0c             	sub    $0xc,%esp
  800796:	6a 00                	push   $0x0
  800798:	e8 e8 fd ff ff       	call   800585 <block_is_free>
  80079d:	83 c4 10             	add    $0x10,%esp
  8007a0:	84 c0                	test   %al,%al
  8007a2:	75 28                	jne    8007cc <check_bitmap+0x86>
	assert(!block_is_free(1));
  8007a4:	83 ec 0c             	sub    $0xc,%esp
  8007a7:	6a 01                	push   $0x1
  8007a9:	e8 d7 fd ff ff       	call   800585 <block_is_free>
  8007ae:	83 c4 10             	add    $0x10,%esp
  8007b1:	84 c0                	test   %al,%al
  8007b3:	75 2d                	jne    8007e2 <check_bitmap+0x9c>
	cprintf("bitmap is good\n");
  8007b5:	83 ec 0c             	sub    $0xc,%esp
  8007b8:	68 f4 3e 80 00       	push   $0x803ef4
  8007bd:	e8 8d 12 00 00       	call   801a4f <cprintf>
}
  8007c2:	83 c4 10             	add    $0x10,%esp
  8007c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007c8:	5b                   	pop    %ebx
  8007c9:	5e                   	pop    %esi
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    
	assert(!block_is_free(0));
  8007cc:	68 d0 3e 80 00       	push   $0x803ed0
  8007d1:	68 dd 3c 80 00       	push   $0x803cdd
  8007d6:	6a 5e                	push   $0x5e
  8007d8:	68 6c 3e 80 00       	push   $0x803e6c
  8007dd:	e8 86 11 00 00       	call   801968 <_panic>
	assert(!block_is_free(1));
  8007e2:	68 e2 3e 80 00       	push   $0x803ee2
  8007e7:	68 dd 3c 80 00       	push   $0x803cdd
  8007ec:	6a 5f                	push   $0x5f
  8007ee:	68 6c 3e 80 00       	push   $0x803e6c
  8007f3:	e8 70 11 00 00       	call   801968 <_panic>

008007f8 <fs_init>:
{
  8007f8:	f3 0f 1e fb          	endbr32 
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	83 ec 08             	sub    $0x8,%esp
	if (ide_probe_disk1())
  800802:	e8 58 f8 ff ff       	call   80005f <ide_probe_disk1>
  800807:	84 c0                	test   %al,%al
  800809:	74 37                	je     800842 <fs_init+0x4a>
		ide_set_disk(1);
  80080b:	83 ec 0c             	sub    $0xc,%esp
  80080e:	6a 01                	push   $0x1
  800810:	e8 b0 f8 ff ff       	call   8000c5 <ide_set_disk>
  800815:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800818:	e8 d1 fc ff ff       	call   8004ee <bc_init>
	super = diskaddr(1);
  80081d:	83 ec 0c             	sub    $0xc,%esp
  800820:	6a 01                	push   $0x1
  800822:	e8 8d fb ff ff       	call   8003b4 <diskaddr>
  800827:	a3 0c a0 80 00       	mov    %eax,0x80a00c
	bitmap = diskaddr(2);
  80082c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800833:	e8 7c fb ff ff       	call   8003b4 <diskaddr>
  800838:	a3 08 a0 80 00       	mov    %eax,0x80a008
}
  80083d:	83 c4 10             	add    $0x10,%esp
  800840:	c9                   	leave  
  800841:	c3                   	ret    
		ide_set_disk(0);
  800842:	83 ec 0c             	sub    $0xc,%esp
  800845:	6a 00                	push   $0x0
  800847:	e8 79 f8 ff ff       	call   8000c5 <ide_set_disk>
  80084c:	83 c4 10             	add    $0x10,%esp
  80084f:	eb c7                	jmp    800818 <fs_init+0x20>

00800851 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800851:	f3 0f 1e fb          	endbr32 
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	83 ec 24             	sub    $0x24,%esp
    // LAB 5: Your code here.
	uint32_t* pdiskbno; int r;
	if ((r = file_block_walk(f,filebno, &pdiskbno, 1))<0){
  80085b:	6a 01                	push   $0x1
  80085d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800860:	8b 55 0c             	mov    0xc(%ebp),%edx
  800863:	8b 45 08             	mov    0x8(%ebp),%eax
  800866:	e8 03 fe ff ff       	call   80066e <file_block_walk>
  80086b:	83 c4 10             	add    $0x10,%esp
  80086e:	85 c0                	test   %eax,%eax
  800870:	78 65                	js     8008d7 <file_get_block+0x86>
		return r;
	}
	if (*pdiskbno==0){
  800872:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800875:	83 38 00             	cmpl   $0x0,(%eax)
  800878:	75 43                	jne    8008bd <file_get_block+0x6c>
		if ((r = alloc_block())<0){
  80087a:	e8 88 fd ff ff       	call   800607 <alloc_block>
  80087f:	85 c0                	test   %eax,%eax
  800881:	78 56                	js     8008d9 <file_get_block+0x88>
			return -E_NO_DISK;
		}
		*pdiskbno = r;
  800883:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800886:	89 02                	mov    %eax,(%edx)
		memset(diskaddr(*pdiskbno), 0, BLKSIZE);
  800888:	83 ec 0c             	sub    $0xc,%esp
  80088b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80088e:	ff 30                	pushl  (%eax)
  800890:	e8 1f fb ff ff       	call   8003b4 <diskaddr>
  800895:	83 c4 0c             	add    $0xc,%esp
  800898:	68 00 10 00 00       	push   $0x1000
  80089d:	6a 00                	push   $0x0
  80089f:	50                   	push   %eax
  8008a0:	e8 66 19 00 00       	call   80220b <memset>
		flush_block(diskaddr(*pdiskbno));
  8008a5:	83 c4 04             	add    $0x4,%esp
  8008a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ab:	ff 30                	pushl  (%eax)
  8008ad:	e8 02 fb ff ff       	call   8003b4 <diskaddr>
  8008b2:	89 04 24             	mov    %eax,(%esp)
  8008b5:	e8 84 fb ff ff       	call   80043e <flush_block>
  8008ba:	83 c4 10             	add    $0x10,%esp
	}
	*blk = diskaddr(*pdiskbno);
  8008bd:	83 ec 0c             	sub    $0xc,%esp
  8008c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c3:	ff 30                	pushl  (%eax)
  8008c5:	e8 ea fa ff ff       	call   8003b4 <diskaddr>
  8008ca:	8b 55 10             	mov    0x10(%ebp),%edx
  8008cd:	89 02                	mov    %eax,(%edx)
    return 0;
  8008cf:	83 c4 10             	add    $0x10,%esp
  8008d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d7:	c9                   	leave  
  8008d8:	c3                   	ret    
			return -E_NO_DISK;
  8008d9:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
  8008de:	eb f7                	jmp    8008d7 <file_get_block+0x86>

008008e0 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	57                   	push   %edi
  8008e4:	56                   	push   %esi
  8008e5:	53                   	push   %ebx
  8008e6:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  8008ec:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  8008f2:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
	while (*p == '/')
  8008f8:	80 38 2f             	cmpb   $0x2f,(%eax)
  8008fb:	75 05                	jne    800902 <walk_path+0x22>
		p++;
  8008fd:	83 c0 01             	add    $0x1,%eax
  800900:	eb f6                	jmp    8008f8 <walk_path+0x18>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800902:	8b 0d 0c a0 80 00    	mov    0x80a00c,%ecx
  800908:	83 c1 08             	add    $0x8,%ecx
  80090b:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  800911:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800918:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  80091e:	85 c9                	test   %ecx,%ecx
  800920:	74 06                	je     800928 <walk_path+0x48>
		*pdir = 0;
  800922:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800928:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  80092e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	dir = 0;
  800934:	ba 00 00 00 00       	mov    $0x0,%edx
	while (*path != '\0') {
  800939:	e9 c5 01 00 00       	jmp    800b03 <walk_path+0x223>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  80093e:	83 c6 01             	add    $0x1,%esi
		while (*path != '/' && *path != '\0')
  800941:	0f b6 16             	movzbl (%esi),%edx
  800944:	80 fa 2f             	cmp    $0x2f,%dl
  800947:	74 04                	je     80094d <walk_path+0x6d>
  800949:	84 d2                	test   %dl,%dl
  80094b:	75 f1                	jne    80093e <walk_path+0x5e>
		if (path - p >= MAXNAMELEN)
  80094d:	89 f3                	mov    %esi,%ebx
  80094f:	29 c3                	sub    %eax,%ebx
  800951:	83 fb 7f             	cmp    $0x7f,%ebx
  800954:	0f 8f 71 01 00 00    	jg     800acb <walk_path+0x1eb>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  80095a:	83 ec 04             	sub    $0x4,%esp
  80095d:	53                   	push   %ebx
  80095e:	50                   	push   %eax
  80095f:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800965:	50                   	push   %eax
  800966:	e8 ec 18 00 00       	call   802257 <memmove>
		name[path - p] = '\0';
  80096b:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800972:	00 
	while (*p == '/')
  800973:	83 c4 10             	add    $0x10,%esp
  800976:	80 3e 2f             	cmpb   $0x2f,(%esi)
  800979:	75 05                	jne    800980 <walk_path+0xa0>
		p++;
  80097b:	83 c6 01             	add    $0x1,%esi
  80097e:	eb f6                	jmp    800976 <walk_path+0x96>
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800980:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800986:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  80098d:	0f 85 3f 01 00 00    	jne    800ad2 <walk_path+0x1f2>
	assert((dir->f_size % BLKSIZE) == 0);
  800993:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800999:	89 c1                	mov    %eax,%ecx
  80099b:	81 e1 ff 0f 00 00    	and    $0xfff,%ecx
  8009a1:	89 8d 50 ff ff ff    	mov    %ecx,-0xb0(%ebp)
  8009a7:	0f 85 8e 00 00 00    	jne    800a3b <walk_path+0x15b>
	nblock = dir->f_size / BLKSIZE;
  8009ad:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  8009b3:	85 c0                	test   %eax,%eax
  8009b5:	0f 48 c2             	cmovs  %edx,%eax
  8009b8:	c1 f8 0c             	sar    $0xc,%eax
  8009bb:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
			if (strcmp(f[j].f_name, name) == 0) {
  8009c1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
  8009c7:	89 b5 44 ff ff ff    	mov    %esi,-0xbc(%ebp)
	for (i = 0; i < nblock; i++) {
  8009cd:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  8009d3:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  8009d9:	74 79                	je     800a54 <walk_path+0x174>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  8009db:	83 ec 04             	sub    $0x4,%esp
  8009de:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  8009e4:	50                   	push   %eax
  8009e5:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  8009eb:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  8009f1:	e8 5b fe ff ff       	call   800851 <file_get_block>
  8009f6:	83 c4 10             	add    $0x10,%esp
  8009f9:	85 c0                	test   %eax,%eax
  8009fb:	0f 88 d8 00 00 00    	js     800ad9 <walk_path+0x1f9>
  800a01:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800a07:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
			if (strcmp(f[j].f_name, name) == 0) {
  800a0d:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800a13:	83 ec 08             	sub    $0x8,%esp
  800a16:	57                   	push   %edi
  800a17:	53                   	push   %ebx
  800a18:	e8 fb 16 00 00       	call   802118 <strcmp>
  800a1d:	83 c4 10             	add    $0x10,%esp
  800a20:	85 c0                	test   %eax,%eax
  800a22:	0f 84 c1 00 00 00    	je     800ae9 <walk_path+0x209>
  800a28:	81 c3 00 01 00 00    	add    $0x100,%ebx
		for (j = 0; j < BLKFILES; j++)
  800a2e:	39 f3                	cmp    %esi,%ebx
  800a30:	75 db                	jne    800a0d <walk_path+0x12d>
	for (i = 0; i < nblock; i++) {
  800a32:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800a39:	eb 92                	jmp    8009cd <walk_path+0xed>
	assert((dir->f_size % BLKSIZE) == 0);
  800a3b:	68 04 3f 80 00       	push   $0x803f04
  800a40:	68 dd 3c 80 00       	push   $0x803cdd
  800a45:	68 ed 00 00 00       	push   $0xed
  800a4a:	68 6c 3e 80 00       	push   $0x803e6c
  800a4f:	e8 14 0f 00 00       	call   801968 <_panic>
  800a54:	8b b5 44 ff ff ff    	mov    -0xbc(%ebp),%esi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800a5a:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
			if (r == -E_NOT_FOUND && *path == '\0') {
  800a5f:	80 3e 00             	cmpb   $0x0,(%esi)
  800a62:	75 5f                	jne    800ac3 <walk_path+0x1e3>
				if (pdir)
  800a64:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800a6a:	85 c0                	test   %eax,%eax
  800a6c:	74 08                	je     800a76 <walk_path+0x196>
					*pdir = dir;
  800a6e:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800a74:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800a76:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800a7a:	74 15                	je     800a91 <walk_path+0x1b1>
					strcpy(lastelem, name);
  800a7c:	83 ec 08             	sub    $0x8,%esp
  800a7f:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800a85:	50                   	push   %eax
  800a86:	ff 75 08             	pushl  0x8(%ebp)
  800a89:	e8 cb 15 00 00       	call   802059 <strcpy>
  800a8e:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800a91:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800a97:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			return r;
  800a9d:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800aa2:	eb 1f                	jmp    800ac3 <walk_path+0x1e3>
		}
	}

	if (pdir)
  800aa4:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800aaa:	85 c0                	test   %eax,%eax
  800aac:	74 02                	je     800ab0 <walk_path+0x1d0>
		*pdir = dir;
  800aae:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800ab0:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800ab6:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800abc:	89 08                	mov    %ecx,(%eax)
	return 0;
  800abe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac6:	5b                   	pop    %ebx
  800ac7:	5e                   	pop    %esi
  800ac8:	5f                   	pop    %edi
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    
			return -E_BAD_PATH;
  800acb:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800ad0:	eb f1                	jmp    800ac3 <walk_path+0x1e3>
			return -E_NOT_FOUND;
  800ad2:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800ad7:	eb ea                	jmp    800ac3 <walk_path+0x1e3>
  800ad9:	8b b5 44 ff ff ff    	mov    -0xbc(%ebp),%esi
			if (r == -E_NOT_FOUND && *path == '\0') {
  800adf:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800ae2:	75 df                	jne    800ac3 <walk_path+0x1e3>
  800ae4:	e9 71 ff ff ff       	jmp    800a5a <walk_path+0x17a>
  800ae9:	8b b5 44 ff ff ff    	mov    -0xbc(%ebp),%esi
  800aef:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
			if (strcmp(f[j].f_name, name) == 0) {
  800af5:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800afb:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800b01:	89 f0                	mov    %esi,%eax
	while (*path != '\0') {
  800b03:	80 38 00             	cmpb   $0x0,(%eax)
  800b06:	74 9c                	je     800aa4 <walk_path+0x1c4>
  800b08:	89 c6                	mov    %eax,%esi
  800b0a:	e9 32 fe ff ff       	jmp    800941 <walk_path+0x61>

00800b0f <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800b0f:	f3 0f 1e fb          	endbr32 
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800b19:	6a 00                	push   $0x0
  800b1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b23:	8b 45 08             	mov    0x8(%ebp),%eax
  800b26:	e8 b5 fd ff ff       	call   8008e0 <walk_path>
}
  800b2b:	c9                   	leave  
  800b2c:	c3                   	ret    

00800b2d <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800b2d:	f3 0f 1e fb          	endbr32 
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	57                   	push   %edi
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
  800b37:	83 ec 2c             	sub    $0x2c,%esp
  800b3a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b40:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800b43:	8b 45 08             	mov    0x8(%ebp),%eax
  800b46:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800b4c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (offset >= f->f_size)
  800b51:	39 ca                	cmp    %ecx,%edx
  800b53:	7e 7e                	jle    800bd3 <file_read+0xa6>

	count = MIN(count, f->f_size - offset);
  800b55:	29 ca                	sub    %ecx,%edx
  800b57:	39 da                	cmp    %ebx,%edx
  800b59:	89 d8                	mov    %ebx,%eax
  800b5b:	0f 46 c2             	cmovbe %edx,%eax
  800b5e:	89 45 d0             	mov    %eax,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800b61:	89 cb                	mov    %ecx,%ebx
  800b63:	01 c1                	add    %eax,%ecx
  800b65:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800b68:	89 de                	mov    %ebx,%esi
  800b6a:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  800b6d:	76 61                	jbe    800bd0 <file_read+0xa3>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800b6f:	83 ec 04             	sub    $0x4,%esp
  800b72:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800b75:	50                   	push   %eax
  800b76:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  800b7c:	85 db                	test   %ebx,%ebx
  800b7e:	0f 49 c3             	cmovns %ebx,%eax
  800b81:	c1 f8 0c             	sar    $0xc,%eax
  800b84:	50                   	push   %eax
  800b85:	ff 75 08             	pushl  0x8(%ebp)
  800b88:	e8 c4 fc ff ff       	call   800851 <file_get_block>
  800b8d:	83 c4 10             	add    $0x10,%esp
  800b90:	85 c0                	test   %eax,%eax
  800b92:	78 3f                	js     800bd3 <file_read+0xa6>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800b94:	89 da                	mov    %ebx,%edx
  800b96:	c1 fa 1f             	sar    $0x1f,%edx
  800b99:	c1 ea 14             	shr    $0x14,%edx
  800b9c:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800b9f:	25 ff 0f 00 00       	and    $0xfff,%eax
  800ba4:	29 d0                	sub    %edx,%eax
  800ba6:	ba 00 10 00 00       	mov    $0x1000,%edx
  800bab:	29 c2                	sub    %eax,%edx
  800bad:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800bb0:	29 f1                	sub    %esi,%ecx
  800bb2:	89 ce                	mov    %ecx,%esi
  800bb4:	39 ca                	cmp    %ecx,%edx
  800bb6:	0f 46 f2             	cmovbe %edx,%esi
		memmove(buf, blk + pos % BLKSIZE, bn);
  800bb9:	83 ec 04             	sub    $0x4,%esp
  800bbc:	56                   	push   %esi
  800bbd:	03 45 e4             	add    -0x1c(%ebp),%eax
  800bc0:	50                   	push   %eax
  800bc1:	57                   	push   %edi
  800bc2:	e8 90 16 00 00       	call   802257 <memmove>
		pos += bn;
  800bc7:	01 f3                	add    %esi,%ebx
		buf += bn;
  800bc9:	01 f7                	add    %esi,%edi
  800bcb:	83 c4 10             	add    $0x10,%esp
  800bce:	eb 98                	jmp    800b68 <file_read+0x3b>
	}

	return count;
  800bd0:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800bd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800bdb:	f3 0f 1e fb          	endbr32 
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
  800be5:	83 ec 2c             	sub    $0x2c,%esp
  800be8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800beb:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if (f->f_size > newsize)
  800bee:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  800bf4:	39 f8                	cmp    %edi,%eax
  800bf6:	7f 1c                	jg     800c14 <file_set_size+0x39>
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800bf8:	89 bb 80 00 00 00    	mov    %edi,0x80(%ebx)
	flush_block(f);
  800bfe:	83 ec 0c             	sub    $0xc,%esp
  800c01:	53                   	push   %ebx
  800c02:	e8 37 f8 ff ff       	call   80043e <flush_block>
	return 0;
}
  800c07:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    
	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800c14:	8d 90 fe 1f 00 00    	lea    0x1ffe(%eax),%edx
  800c1a:	05 ff 0f 00 00       	add    $0xfff,%eax
  800c1f:	0f 48 c2             	cmovs  %edx,%eax
  800c22:	c1 f8 0c             	sar    $0xc,%eax
  800c25:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800c28:	8d 87 fe 1f 00 00    	lea    0x1ffe(%edi),%eax
  800c2e:	89 fa                	mov    %edi,%edx
  800c30:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800c36:	0f 49 c2             	cmovns %edx,%eax
  800c39:	c1 f8 0c             	sar    $0xc,%eax
  800c3c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800c3f:	89 c6                	mov    %eax,%esi
  800c41:	eb 3c                	jmp    800c7f <file_set_size+0xa4>
	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800c43:	83 7d d0 0a          	cmpl   $0xa,-0x30(%ebp)
  800c47:	77 af                	ja     800bf8 <file_set_size+0x1d>
  800c49:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  800c4f:	85 c0                	test   %eax,%eax
  800c51:	74 a5                	je     800bf8 <file_set_size+0x1d>
		free_block(f->f_indirect);
  800c53:	83 ec 0c             	sub    $0xc,%esp
  800c56:	50                   	push   %eax
  800c57:	e8 6b f9 ff ff       	call   8005c7 <free_block>
		f->f_indirect = 0;
  800c5c:	c7 83 b0 00 00 00 00 	movl   $0x0,0xb0(%ebx)
  800c63:	00 00 00 
  800c66:	83 c4 10             	add    $0x10,%esp
  800c69:	eb 8d                	jmp    800bf8 <file_set_size+0x1d>
			cprintf("warning: file_free_block: %e", r);
  800c6b:	83 ec 08             	sub    $0x8,%esp
  800c6e:	50                   	push   %eax
  800c6f:	68 21 3f 80 00       	push   $0x803f21
  800c74:	e8 d6 0d 00 00       	call   801a4f <cprintf>
  800c79:	83 c4 10             	add    $0x10,%esp
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800c7c:	83 c6 01             	add    $0x1,%esi
  800c7f:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800c82:	76 bf                	jbe    800c43 <file_set_size+0x68>
	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800c84:	83 ec 0c             	sub    $0xc,%esp
  800c87:	6a 00                	push   $0x0
  800c89:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800c8c:	89 f2                	mov    %esi,%edx
  800c8e:	89 d8                	mov    %ebx,%eax
  800c90:	e8 d9 f9 ff ff       	call   80066e <file_block_walk>
  800c95:	83 c4 10             	add    $0x10,%esp
  800c98:	85 c0                	test   %eax,%eax
  800c9a:	78 cf                	js     800c6b <file_set_size+0x90>
	if (*ptr) {
  800c9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c9f:	8b 00                	mov    (%eax),%eax
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	74 d7                	je     800c7c <file_set_size+0xa1>
		free_block(*ptr);
  800ca5:	83 ec 0c             	sub    $0xc,%esp
  800ca8:	50                   	push   %eax
  800ca9:	e8 19 f9 ff ff       	call   8005c7 <free_block>
		*ptr = 0;
  800cae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cb1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800cb7:	83 c4 10             	add    $0x10,%esp
  800cba:	eb c0                	jmp    800c7c <file_set_size+0xa1>

00800cbc <file_write>:
{
  800cbc:	f3 0f 1e fb          	endbr32 
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	57                   	push   %edi
  800cc4:	56                   	push   %esi
  800cc5:	53                   	push   %ebx
  800cc6:	83 ec 2c             	sub    $0x2c,%esp
  800cc9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ccc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	if (offset + count > f->f_size)
  800ccf:	89 d8                	mov    %ebx,%eax
  800cd1:	03 45 10             	add    0x10(%ebp),%eax
  800cd4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800cd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cda:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800ce0:	77 68                	ja     800d4a <file_write+0x8e>
	for (pos = offset; pos < offset + count; ) {
  800ce2:	89 de                	mov    %ebx,%esi
  800ce4:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  800ce7:	76 74                	jbe    800d5d <file_write+0xa1>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800ce9:	83 ec 04             	sub    $0x4,%esp
  800cec:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800cef:	50                   	push   %eax
  800cf0:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  800cf6:	85 db                	test   %ebx,%ebx
  800cf8:	0f 49 c3             	cmovns %ebx,%eax
  800cfb:	c1 f8 0c             	sar    $0xc,%eax
  800cfe:	50                   	push   %eax
  800cff:	ff 75 08             	pushl  0x8(%ebp)
  800d02:	e8 4a fb ff ff       	call   800851 <file_get_block>
  800d07:	83 c4 10             	add    $0x10,%esp
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	78 52                	js     800d60 <file_write+0xa4>
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800d0e:	89 da                	mov    %ebx,%edx
  800d10:	c1 fa 1f             	sar    $0x1f,%edx
  800d13:	c1 ea 14             	shr    $0x14,%edx
  800d16:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800d19:	25 ff 0f 00 00       	and    $0xfff,%eax
  800d1e:	29 d0                	sub    %edx,%eax
  800d20:	b9 00 10 00 00       	mov    $0x1000,%ecx
  800d25:	29 c1                	sub    %eax,%ecx
  800d27:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800d2a:	29 f2                	sub    %esi,%edx
  800d2c:	39 d1                	cmp    %edx,%ecx
  800d2e:	89 d6                	mov    %edx,%esi
  800d30:	0f 46 f1             	cmovbe %ecx,%esi
		memmove(blk + pos % BLKSIZE, buf, bn);
  800d33:	83 ec 04             	sub    $0x4,%esp
  800d36:	56                   	push   %esi
  800d37:	57                   	push   %edi
  800d38:	03 45 e4             	add    -0x1c(%ebp),%eax
  800d3b:	50                   	push   %eax
  800d3c:	e8 16 15 00 00       	call   802257 <memmove>
		pos += bn;
  800d41:	01 f3                	add    %esi,%ebx
		buf += bn;
  800d43:	01 f7                	add    %esi,%edi
  800d45:	83 c4 10             	add    $0x10,%esp
  800d48:	eb 98                	jmp    800ce2 <file_write+0x26>
		if ((r = file_set_size(f, offset + count)) < 0)
  800d4a:	83 ec 08             	sub    $0x8,%esp
  800d4d:	50                   	push   %eax
  800d4e:	51                   	push   %ecx
  800d4f:	e8 87 fe ff ff       	call   800bdb <file_set_size>
  800d54:	83 c4 10             	add    $0x10,%esp
  800d57:	85 c0                	test   %eax,%eax
  800d59:	79 87                	jns    800ce2 <file_write+0x26>
  800d5b:	eb 03                	jmp    800d60 <file_write+0xa4>
	return count;
  800d5d:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800d60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800d68:	f3 0f 1e fb          	endbr32 
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
  800d71:	83 ec 10             	sub    $0x10,%esp
  800d74:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800d77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7c:	eb 03                	jmp    800d81 <file_flush+0x19>
  800d7e:	83 c3 01             	add    $0x1,%ebx
  800d81:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800d87:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  800d8d:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800d93:	0f 49 c2             	cmovns %edx,%eax
  800d96:	c1 f8 0c             	sar    $0xc,%eax
  800d99:	39 d8                	cmp    %ebx,%eax
  800d9b:	7e 3b                	jle    800dd8 <file_flush+0x70>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800d9d:	83 ec 0c             	sub    $0xc,%esp
  800da0:	6a 00                	push   $0x0
  800da2:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800da5:	89 da                	mov    %ebx,%edx
  800da7:	89 f0                	mov    %esi,%eax
  800da9:	e8 c0 f8 ff ff       	call   80066e <file_block_walk>
  800dae:	83 c4 10             	add    $0x10,%esp
  800db1:	85 c0                	test   %eax,%eax
  800db3:	78 c9                	js     800d7e <file_flush+0x16>
		    pdiskbno == NULL || *pdiskbno == 0)
  800db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800db8:	85 c0                	test   %eax,%eax
  800dba:	74 c2                	je     800d7e <file_flush+0x16>
		    pdiskbno == NULL || *pdiskbno == 0)
  800dbc:	8b 00                	mov    (%eax),%eax
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	74 bc                	je     800d7e <file_flush+0x16>
			continue;
		flush_block(diskaddr(*pdiskbno));
  800dc2:	83 ec 0c             	sub    $0xc,%esp
  800dc5:	50                   	push   %eax
  800dc6:	e8 e9 f5 ff ff       	call   8003b4 <diskaddr>
  800dcb:	89 04 24             	mov    %eax,(%esp)
  800dce:	e8 6b f6 ff ff       	call   80043e <flush_block>
  800dd3:	83 c4 10             	add    $0x10,%esp
  800dd6:	eb a6                	jmp    800d7e <file_flush+0x16>
	}
	// flush the meta data of the file f
	flush_block(f);
  800dd8:	83 ec 0c             	sub    $0xc,%esp
  800ddb:	56                   	push   %esi
  800ddc:	e8 5d f6 ff ff       	call   80043e <flush_block>
	if (f->f_indirect)
  800de1:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800de7:	83 c4 10             	add    $0x10,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	75 07                	jne    800df5 <file_flush+0x8d>
		flush_block(diskaddr(f->f_indirect));
}
  800dee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    
		flush_block(diskaddr(f->f_indirect));
  800df5:	83 ec 0c             	sub    $0xc,%esp
  800df8:	50                   	push   %eax
  800df9:	e8 b6 f5 ff ff       	call   8003b4 <diskaddr>
  800dfe:	89 04 24             	mov    %eax,(%esp)
  800e01:	e8 38 f6 ff ff       	call   80043e <flush_block>
  800e06:	83 c4 10             	add    $0x10,%esp
}
  800e09:	eb e3                	jmp    800dee <file_flush+0x86>

00800e0b <file_create>:
{
  800e0b:	f3 0f 1e fb          	endbr32 
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	57                   	push   %edi
  800e13:	56                   	push   %esi
  800e14:	53                   	push   %ebx
  800e15:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	if ((r = walk_path(path, &dir, &f, name)) == 0)
  800e1b:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800e21:	50                   	push   %eax
  800e22:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  800e28:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  800e2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e31:	e8 aa fa ff ff       	call   8008e0 <walk_path>
  800e36:	83 c4 10             	add    $0x10,%esp
  800e39:	85 c0                	test   %eax,%eax
  800e3b:	0f 84 0b 01 00 00    	je     800f4c <file_create+0x141>
	if (r != -E_NOT_FOUND || dir == 0)
  800e41:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800e44:	0f 85 ca 00 00 00    	jne    800f14 <file_create+0x109>
  800e4a:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  800e50:	85 f6                	test   %esi,%esi
  800e52:	0f 84 bc 00 00 00    	je     800f14 <file_create+0x109>
	assert((dir->f_size % BLKSIZE) == 0);
  800e58:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800e5e:	89 c3                	mov    %eax,%ebx
  800e60:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
  800e66:	75 57                	jne    800ebf <file_create+0xb4>
	nblock = dir->f_size / BLKSIZE;
  800e68:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800e6e:	85 c0                	test   %eax,%eax
  800e70:	0f 48 c2             	cmovs  %edx,%eax
  800e73:	c1 f8 0c             	sar    $0xc,%eax
  800e76:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800e7c:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
	for (i = 0; i < nblock; i++) {
  800e82:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  800e88:	0f 84 8e 00 00 00    	je     800f1c <file_create+0x111>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800e8e:	83 ec 04             	sub    $0x4,%esp
  800e91:	57                   	push   %edi
  800e92:	53                   	push   %ebx
  800e93:	56                   	push   %esi
  800e94:	e8 b8 f9 ff ff       	call   800851 <file_get_block>
  800e99:	83 c4 10             	add    $0x10,%esp
  800e9c:	85 c0                	test   %eax,%eax
  800e9e:	78 74                	js     800f14 <file_create+0x109>
  800ea0:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800ea6:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
			if (f[j].f_name[0] == '\0') {
  800eac:	80 38 00             	cmpb   $0x0,(%eax)
  800eaf:	74 27                	je     800ed8 <file_create+0xcd>
  800eb1:	05 00 01 00 00       	add    $0x100,%eax
		for (j = 0; j < BLKFILES; j++)
  800eb6:	39 d0                	cmp    %edx,%eax
  800eb8:	75 f2                	jne    800eac <file_create+0xa1>
	for (i = 0; i < nblock; i++) {
  800eba:	83 c3 01             	add    $0x1,%ebx
  800ebd:	eb c3                	jmp    800e82 <file_create+0x77>
	assert((dir->f_size % BLKSIZE) == 0);
  800ebf:	68 04 3f 80 00       	push   $0x803f04
  800ec4:	68 dd 3c 80 00       	push   $0x803cdd
  800ec9:	68 06 01 00 00       	push   $0x106
  800ece:	68 6c 3e 80 00       	push   $0x803e6c
  800ed3:	e8 90 0a 00 00       	call   801968 <_panic>
				*file = &f[j];
  800ed8:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
	strcpy(f->f_name, name);
  800ede:	83 ec 08             	sub    $0x8,%esp
  800ee1:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800ee7:	50                   	push   %eax
  800ee8:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  800eee:	e8 66 11 00 00       	call   802059 <strcpy>
	*pf = f;
  800ef3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef6:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  800efc:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  800efe:	83 c4 04             	add    $0x4,%esp
  800f01:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  800f07:	e8 5c fe ff ff       	call   800d68 <file_flush>
	return 0;
  800f0c:	83 c4 10             	add    $0x10,%esp
  800f0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f17:	5b                   	pop    %ebx
  800f18:	5e                   	pop    %esi
  800f19:	5f                   	pop    %edi
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    
	dir->f_size += BLKSIZE;
  800f1c:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  800f23:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  800f26:	83 ec 04             	sub    $0x4,%esp
  800f29:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  800f2f:	50                   	push   %eax
  800f30:	53                   	push   %ebx
  800f31:	56                   	push   %esi
  800f32:	e8 1a f9 ff ff       	call   800851 <file_get_block>
  800f37:	83 c4 10             	add    $0x10,%esp
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	78 d6                	js     800f14 <file_create+0x109>
	*file = &f[0];
  800f3e:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800f44:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
	return 0;
  800f4a:	eb 92                	jmp    800ede <file_create+0xd3>
		return -E_FILE_EXISTS;
  800f4c:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  800f51:	eb c1                	jmp    800f14 <file_create+0x109>

00800f53 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  800f53:	f3 0f 1e fb          	endbr32 
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	53                   	push   %ebx
  800f5b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800f5e:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f63:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800f68:	39 58 04             	cmp    %ebx,0x4(%eax)
  800f6b:	76 19                	jbe    800f86 <fs_sync+0x33>
		flush_block(diskaddr(i));
  800f6d:	83 ec 0c             	sub    $0xc,%esp
  800f70:	53                   	push   %ebx
  800f71:	e8 3e f4 ff ff       	call   8003b4 <diskaddr>
  800f76:	89 04 24             	mov    %eax,(%esp)
  800f79:	e8 c0 f4 ff ff       	call   80043e <flush_block>
	for (i = 1; i < super->s_nblocks; i++)
  800f7e:	83 c3 01             	add    $0x1,%ebx
  800f81:	83 c4 10             	add    $0x10,%esp
  800f84:	eb dd                	jmp    800f63 <fs_sync+0x10>
}
  800f86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f89:	c9                   	leave  
  800f8a:	c3                   	ret    

00800f8b <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  800f8b:	f3 0f 1e fb          	endbr32 
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  800f95:	e8 b9 ff ff ff       	call   800f53 <fs_sync>
	return 0;
}
  800f9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f9f:	c9                   	leave  
  800fa0:	c3                   	ret    

00800fa1 <serve_init>:
{
  800fa1:	f3 0f 1e fb          	endbr32 
  800fa5:	ba 60 50 80 00       	mov    $0x805060,%edx
	uintptr_t va = FILEVA;
  800faa:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  800faf:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  800fb4:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  800fb6:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  800fb9:	81 c1 00 10 00 00    	add    $0x1000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  800fbf:	83 c0 01             	add    $0x1,%eax
  800fc2:	83 c2 10             	add    $0x10,%edx
  800fc5:	3d 00 04 00 00       	cmp    $0x400,%eax
  800fca:	75 e8                	jne    800fb4 <serve_init+0x13>
}
  800fcc:	c3                   	ret    

00800fcd <openfile_alloc>:
{
  800fcd:	f3 0f 1e fb          	endbr32 
  800fd1:	55                   	push   %ebp
  800fd2:	89 e5                	mov    %esp,%ebp
  800fd4:	57                   	push   %edi
  800fd5:	56                   	push   %esi
  800fd6:	53                   	push   %ebx
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	8b 7d 08             	mov    0x8(%ebp),%edi
	for (i = 0; i < MAXOPEN; i++) {
  800fdd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe2:	89 de                	mov    %ebx,%esi
  800fe4:	c1 e6 04             	shl    $0x4,%esi
		switch (pageref(opentab[i].o_fd)) {
  800fe7:	83 ec 0c             	sub    $0xc,%esp
  800fea:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
  800ff0:	e8 52 20 00 00       	call   803047 <pageref>
  800ff5:	83 c4 10             	add    $0x10,%esp
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	74 17                	je     801013 <openfile_alloc+0x46>
  800ffc:	83 f8 01             	cmp    $0x1,%eax
  800fff:	74 30                	je     801031 <openfile_alloc+0x64>
	for (i = 0; i < MAXOPEN; i++) {
  801001:	83 c3 01             	add    $0x1,%ebx
  801004:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  80100a:	75 d6                	jne    800fe2 <openfile_alloc+0x15>
	return -E_MAX_OPEN;
  80100c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801011:	eb 4f                	jmp    801062 <openfile_alloc+0x95>
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  801013:	83 ec 04             	sub    $0x4,%esp
  801016:	6a 07                	push   $0x7
  801018:	89 d8                	mov    %ebx,%eax
  80101a:	c1 e0 04             	shl    $0x4,%eax
  80101d:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  801023:	6a 00                	push   $0x0
  801025:	e8 98 14 00 00       	call   8024c2 <sys_page_alloc>
  80102a:	83 c4 10             	add    $0x10,%esp
  80102d:	85 c0                	test   %eax,%eax
  80102f:	78 31                	js     801062 <openfile_alloc+0x95>
			opentab[i].o_fileid += MAXOPEN;
  801031:	c1 e3 04             	shl    $0x4,%ebx
  801034:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  80103b:	04 00 00 
			*o = &opentab[i];
  80103e:	81 c6 60 50 80 00    	add    $0x805060,%esi
  801044:	89 37                	mov    %esi,(%edi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  801046:	83 ec 04             	sub    $0x4,%esp
  801049:	68 00 10 00 00       	push   $0x1000
  80104e:	6a 00                	push   $0x0
  801050:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  801056:	e8 b0 11 00 00       	call   80220b <memset>
			return (*o)->o_fileid;
  80105b:	8b 07                	mov    (%edi),%eax
  80105d:	8b 00                	mov    (%eax),%eax
  80105f:	83 c4 10             	add    $0x10,%esp
}
  801062:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801065:	5b                   	pop    %ebx
  801066:	5e                   	pop    %esi
  801067:	5f                   	pop    %edi
  801068:	5d                   	pop    %ebp
  801069:	c3                   	ret    

0080106a <openfile_lookup>:
{
  80106a:	f3 0f 1e fb          	endbr32 
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	57                   	push   %edi
  801072:	56                   	push   %esi
  801073:	53                   	push   %ebx
  801074:	83 ec 18             	sub    $0x18,%esp
  801077:	8b 7d 0c             	mov    0xc(%ebp),%edi
	o = &opentab[fileid % MAXOPEN];
  80107a:	89 fb                	mov    %edi,%ebx
  80107c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801082:	89 de                	mov    %ebx,%esi
  801084:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801087:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
	o = &opentab[fileid % MAXOPEN];
  80108d:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801093:	e8 af 1f 00 00       	call   803047 <pageref>
  801098:	83 c4 10             	add    $0x10,%esp
  80109b:	83 f8 01             	cmp    $0x1,%eax
  80109e:	7e 1d                	jle    8010bd <openfile_lookup+0x53>
  8010a0:	c1 e3 04             	shl    $0x4,%ebx
  8010a3:	39 bb 60 50 80 00    	cmp    %edi,0x805060(%ebx)
  8010a9:	75 19                	jne    8010c4 <openfile_lookup+0x5a>
	*po = o;
  8010ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8010ae:	89 30                	mov    %esi,(%eax)
	return 0;
  8010b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b8:	5b                   	pop    %ebx
  8010b9:	5e                   	pop    %esi
  8010ba:	5f                   	pop    %edi
  8010bb:	5d                   	pop    %ebp
  8010bc:	c3                   	ret    
		return -E_INVAL;
  8010bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010c2:	eb f1                	jmp    8010b5 <openfile_lookup+0x4b>
  8010c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010c9:	eb ea                	jmp    8010b5 <openfile_lookup+0x4b>

008010cb <serve_set_size>:
{
  8010cb:	f3 0f 1e fb          	endbr32 
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	53                   	push   %ebx
  8010d3:	83 ec 18             	sub    $0x18,%esp
  8010d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8010d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010dc:	50                   	push   %eax
  8010dd:	ff 33                	pushl  (%ebx)
  8010df:	ff 75 08             	pushl  0x8(%ebp)
  8010e2:	e8 83 ff ff ff       	call   80106a <openfile_lookup>
  8010e7:	83 c4 10             	add    $0x10,%esp
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	78 14                	js     801102 <serve_set_size+0x37>
	return file_set_size(o->o_file, req->req_size);
  8010ee:	83 ec 08             	sub    $0x8,%esp
  8010f1:	ff 73 04             	pushl  0x4(%ebx)
  8010f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010f7:	ff 70 04             	pushl  0x4(%eax)
  8010fa:	e8 dc fa ff ff       	call   800bdb <file_set_size>
  8010ff:	83 c4 10             	add    $0x10,%esp
}
  801102:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801105:	c9                   	leave  
  801106:	c3                   	ret    

00801107 <serve_read>:
{
  801107:	f3 0f 1e fb          	endbr32 
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	53                   	push   %ebx
  80110f:	83 ec 18             	sub    $0x18,%esp
  801112:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = openfile_lookup(envid, req->req_fileid, &of))<0)
  801115:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801118:	50                   	push   %eax
  801119:	ff 33                	pushl  (%ebx)
  80111b:	ff 75 08             	pushl  0x8(%ebp)
  80111e:	e8 47 ff ff ff       	call   80106a <openfile_lookup>
  801123:	83 c4 10             	add    $0x10,%esp
  801126:	85 c0                	test   %eax,%eax
  801128:	78 33                	js     80115d <serve_read+0x56>
	if ((r = file_read(of->o_file, ret->ret_buf ,req_n, of->o_fd->fd_offset))<0)
  80112a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80112d:	8b 42 0c             	mov    0xc(%edx),%eax
  801130:	ff 70 04             	pushl  0x4(%eax)
	size_t req_n = req->req_n>PGSIZE?PGSIZE:req->req_n;
  801133:	81 7b 04 00 10 00 00 	cmpl   $0x1000,0x4(%ebx)
  80113a:	b8 00 10 00 00       	mov    $0x1000,%eax
  80113f:	0f 46 43 04          	cmovbe 0x4(%ebx),%eax
	if ((r = file_read(of->o_file, ret->ret_buf ,req_n, of->o_fd->fd_offset))<0)
  801143:	50                   	push   %eax
  801144:	53                   	push   %ebx
  801145:	ff 72 04             	pushl  0x4(%edx)
  801148:	e8 e0 f9 ff ff       	call   800b2d <file_read>
  80114d:	83 c4 10             	add    $0x10,%esp
  801150:	85 c0                	test   %eax,%eax
  801152:	78 09                	js     80115d <serve_read+0x56>
	of->o_fd->fd_offset += r;
  801154:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801157:	8b 52 0c             	mov    0xc(%edx),%edx
  80115a:	01 42 04             	add    %eax,0x4(%edx)
}
  80115d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801160:	c9                   	leave  
  801161:	c3                   	ret    

00801162 <serve_write>:
{
  801162:	f3 0f 1e fb          	endbr32 
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	56                   	push   %esi
  80116a:	53                   	push   %ebx
  80116b:	83 ec 14             	sub    $0x14,%esp
  80116e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = openfile_lookup(envid, req->req_fileid, &of))<0)
  801171:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801174:	50                   	push   %eax
  801175:	ff 33                	pushl  (%ebx)
  801177:	ff 75 08             	pushl  0x8(%ebp)
  80117a:	e8 eb fe ff ff       	call   80106a <openfile_lookup>
  80117f:	83 c4 10             	add    $0x10,%esp
  801182:	85 c0                	test   %eax,%eax
  801184:	78 4e                	js     8011d4 <serve_write+0x72>
	if ((req->req_n+of->o_fd->fd_offset%BLKSIZE)>BLKSIZE)
  801186:	8b 53 04             	mov    0x4(%ebx),%edx
  801189:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  80118c:	8b 41 0c             	mov    0xc(%ecx),%eax
  80118f:	8b 40 04             	mov    0x4(%eax),%eax
  801192:	89 c6                	mov    %eax,%esi
  801194:	c1 fe 1f             	sar    $0x1f,%esi
  801197:	c1 ee 14             	shr    $0x14,%esi
  80119a:	01 f0                	add    %esi,%eax
  80119c:	25 ff 0f 00 00       	and    $0xfff,%eax
  8011a1:	29 f0                	sub    %esi,%eax
  8011a3:	01 d0                	add    %edx,%eax
  8011a5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8011aa:	77 2f                	ja     8011db <serve_write+0x79>
	if((r = file_write(of->o_file, req->req_buf, req->req_n, of->o_fd->fd_offset))<0)
  8011ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011af:	8b 50 0c             	mov    0xc(%eax),%edx
  8011b2:	ff 72 04             	pushl  0x4(%edx)
  8011b5:	ff 73 04             	pushl  0x4(%ebx)
  8011b8:	83 c3 08             	add    $0x8,%ebx
  8011bb:	53                   	push   %ebx
  8011bc:	ff 70 04             	pushl  0x4(%eax)
  8011bf:	e8 f8 fa ff ff       	call   800cbc <file_write>
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	78 09                	js     8011d4 <serve_write+0x72>
	of->o_fd->fd_offset+=r;
  8011cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011ce:	8b 52 0c             	mov    0xc(%edx),%edx
  8011d1:	01 42 04             	add    %eax,0x4(%edx)
}
  8011d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011d7:	5b                   	pop    %ebx
  8011d8:	5e                   	pop    %esi
  8011d9:	5d                   	pop    %ebp
  8011da:	c3                   	ret    
		file_set_size(of->o_file, of->o_file->f_size+req->req_n);
  8011db:	8b 41 04             	mov    0x4(%ecx),%eax
  8011de:	83 ec 08             	sub    $0x8,%esp
  8011e1:	03 90 80 00 00 00    	add    0x80(%eax),%edx
  8011e7:	52                   	push   %edx
  8011e8:	50                   	push   %eax
  8011e9:	e8 ed f9 ff ff       	call   800bdb <file_set_size>
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	eb b9                	jmp    8011ac <serve_write+0x4a>

008011f3 <serve_stat>:
{
  8011f3:	f3 0f 1e fb          	endbr32 
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	53                   	push   %ebx
  8011fb:	83 ec 18             	sub    $0x18,%esp
  8011fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801201:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801204:	50                   	push   %eax
  801205:	ff 33                	pushl  (%ebx)
  801207:	ff 75 08             	pushl  0x8(%ebp)
  80120a:	e8 5b fe ff ff       	call   80106a <openfile_lookup>
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	85 c0                	test   %eax,%eax
  801214:	78 3f                	js     801255 <serve_stat+0x62>
	strcpy(ret->ret_name, o->o_file->f_name);
  801216:	83 ec 08             	sub    $0x8,%esp
  801219:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80121c:	ff 70 04             	pushl  0x4(%eax)
  80121f:	53                   	push   %ebx
  801220:	e8 34 0e 00 00       	call   802059 <strcpy>
	ret->ret_size = o->o_file->f_size;
  801225:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801228:	8b 50 04             	mov    0x4(%eax),%edx
  80122b:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  801231:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  801237:	8b 40 04             	mov    0x4(%eax),%eax
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  801244:	0f 94 c0             	sete   %al
  801247:	0f b6 c0             	movzbl %al,%eax
  80124a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801250:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801255:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801258:	c9                   	leave  
  801259:	c3                   	ret    

0080125a <serve_flush>:
{
  80125a:	f3 0f 1e fb          	endbr32 
  80125e:	55                   	push   %ebp
  80125f:	89 e5                	mov    %esp,%ebp
  801261:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801264:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801267:	50                   	push   %eax
  801268:	8b 45 0c             	mov    0xc(%ebp),%eax
  80126b:	ff 30                	pushl  (%eax)
  80126d:	ff 75 08             	pushl  0x8(%ebp)
  801270:	e8 f5 fd ff ff       	call   80106a <openfile_lookup>
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	85 c0                	test   %eax,%eax
  80127a:	78 16                	js     801292 <serve_flush+0x38>
	file_flush(o->o_file);
  80127c:	83 ec 0c             	sub    $0xc,%esp
  80127f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801282:	ff 70 04             	pushl  0x4(%eax)
  801285:	e8 de fa ff ff       	call   800d68 <file_flush>
	return 0;
  80128a:	83 c4 10             	add    $0x10,%esp
  80128d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801292:	c9                   	leave  
  801293:	c3                   	ret    

00801294 <serve_open>:
{
  801294:	f3 0f 1e fb          	endbr32 
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	53                   	push   %ebx
  80129c:	81 ec 18 04 00 00    	sub    $0x418,%esp
  8012a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	memmove(path, req->req_path, MAXPATHLEN);
  8012a5:	68 00 04 00 00       	push   $0x400
  8012aa:	53                   	push   %ebx
  8012ab:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8012b1:	50                   	push   %eax
  8012b2:	e8 a0 0f 00 00       	call   802257 <memmove>
	path[MAXPATHLEN-1] = 0;
  8012b7:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
	if ((r = openfile_alloc(&o)) < 0) {
  8012bb:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  8012c1:	89 04 24             	mov    %eax,(%esp)
  8012c4:	e8 04 fd ff ff       	call   800fcd <openfile_alloc>
  8012c9:	83 c4 10             	add    $0x10,%esp
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	0f 88 f0 00 00 00    	js     8013c4 <serve_open+0x130>
	if (req->req_omode & O_CREAT) {
  8012d4:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  8012db:	74 33                	je     801310 <serve_open+0x7c>
		if ((r = file_create(path, &f)) < 0) {
  8012dd:	83 ec 08             	sub    $0x8,%esp
  8012e0:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8012e6:	50                   	push   %eax
  8012e7:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8012ed:	50                   	push   %eax
  8012ee:	e8 18 fb ff ff       	call   800e0b <file_create>
  8012f3:	83 c4 10             	add    $0x10,%esp
  8012f6:	85 c0                	test   %eax,%eax
  8012f8:	79 37                	jns    801331 <serve_open+0x9d>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  8012fa:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  801301:	0f 85 bd 00 00 00    	jne    8013c4 <serve_open+0x130>
  801307:	83 f8 f3             	cmp    $0xfffffff3,%eax
  80130a:	0f 85 b4 00 00 00    	jne    8013c4 <serve_open+0x130>
		if ((r = file_open(path, &f)) < 0) {
  801310:	83 ec 08             	sub    $0x8,%esp
  801313:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801319:	50                   	push   %eax
  80131a:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801320:	50                   	push   %eax
  801321:	e8 e9 f7 ff ff       	call   800b0f <file_open>
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	85 c0                	test   %eax,%eax
  80132b:	0f 88 93 00 00 00    	js     8013c4 <serve_open+0x130>
	if (req->req_omode & O_TRUNC) {
  801331:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  801338:	74 17                	je     801351 <serve_open+0xbd>
		if ((r = file_set_size(f, 0)) < 0) {
  80133a:	83 ec 08             	sub    $0x8,%esp
  80133d:	6a 00                	push   $0x0
  80133f:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  801345:	e8 91 f8 ff ff       	call   800bdb <file_set_size>
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	85 c0                	test   %eax,%eax
  80134f:	78 73                	js     8013c4 <serve_open+0x130>
	if ((r = file_open(path, &f)) < 0) {
  801351:	83 ec 08             	sub    $0x8,%esp
  801354:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80135a:	50                   	push   %eax
  80135b:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801361:	50                   	push   %eax
  801362:	e8 a8 f7 ff ff       	call   800b0f <file_open>
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	85 c0                	test   %eax,%eax
  80136c:	78 56                	js     8013c4 <serve_open+0x130>
	o->o_file = f;
  80136e:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801374:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  80137a:	89 50 04             	mov    %edx,0x4(%eax)
	o->o_fd->fd_file.id = o->o_fileid;
  80137d:	8b 50 0c             	mov    0xc(%eax),%edx
  801380:	8b 08                	mov    (%eax),%ecx
  801382:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801385:	8b 48 0c             	mov    0xc(%eax),%ecx
  801388:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80138e:	83 e2 03             	and    $0x3,%edx
  801391:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801394:	8b 40 0c             	mov    0xc(%eax),%eax
  801397:	8b 15 80 90 80 00    	mov    0x809080,%edx
  80139d:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  80139f:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8013a5:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  8013ab:	89 50 08             	mov    %edx,0x8(%eax)
	*pg_store = o->o_fd;
  8013ae:	8b 50 0c             	mov    0xc(%eax),%edx
  8013b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8013b4:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  8013b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b9:	c7 00 07 04 00 00    	movl   $0x407,(%eax)
	return 0;
  8013bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c7:	c9                   	leave  
  8013c8:	c3                   	ret    

008013c9 <serve>:
};

// 循环监听其他env的request
void
serve(void)
{
  8013c9:	f3 0f 1e fb          	endbr32 
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	56                   	push   %esi
  8013d1:	53                   	push   %ebx
  8013d2:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8013d5:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  8013d8:	8d 75 f4             	lea    -0xc(%ebp),%esi
  8013db:	e9 82 00 00 00       	jmp    801462 <serve+0x99>
			cprintf("Invalid request from %08x: no argument page\n",
				whom);
			continue; // just leave it hanging...
		}

		pg = NULL;
  8013e0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  8013e7:	83 f8 01             	cmp    $0x1,%eax
  8013ea:	74 23                	je     80140f <serve+0x46>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  8013ec:	83 f8 08             	cmp    $0x8,%eax
  8013ef:	77 36                	ja     801427 <serve+0x5e>
  8013f1:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  8013f8:	85 d2                	test   %edx,%edx
  8013fa:	74 2b                	je     801427 <serve+0x5e>
			r = handlers[req](whom, fsreq);
  8013fc:	83 ec 08             	sub    $0x8,%esp
  8013ff:	ff 35 44 50 80 00    	pushl  0x805044
  801405:	ff 75 f4             	pushl  -0xc(%ebp)
  801408:	ff d2                	call   *%edx
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	eb 31                	jmp    801440 <serve+0x77>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  80140f:	53                   	push   %ebx
  801410:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801413:	50                   	push   %eax
  801414:	ff 35 44 50 80 00    	pushl  0x805044
  80141a:	ff 75 f4             	pushl  -0xc(%ebp)
  80141d:	e8 72 fe ff ff       	call   801294 <serve_open>
  801422:	83 c4 10             	add    $0x10,%esp
  801425:	eb 19                	jmp    801440 <serve+0x77>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  801427:	83 ec 04             	sub    $0x4,%esp
  80142a:	ff 75 f4             	pushl  -0xc(%ebp)
  80142d:	50                   	push   %eax
  80142e:	68 70 3f 80 00       	push   $0x803f70
  801433:	e8 17 06 00 00       	call   801a4f <cprintf>
  801438:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  80143b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  801440:	ff 75 f0             	pushl  -0x10(%ebp)
  801443:	ff 75 ec             	pushl  -0x14(%ebp)
  801446:	50                   	push   %eax
  801447:	ff 75 f4             	pushl  -0xc(%ebp)
  80144a:	e8 0e 13 00 00       	call   80275d <ipc_send>
		sys_page_unmap(0, fsreq);
  80144f:	83 c4 08             	add    $0x8,%esp
  801452:	ff 35 44 50 80 00    	pushl  0x805044
  801458:	6a 00                	push   $0x0
  80145a:	e8 ae 10 00 00       	call   80250d <sys_page_unmap>
  80145f:	83 c4 10             	add    $0x10,%esp
		perm = 0;
  801462:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801469:	83 ec 04             	sub    $0x4,%esp
  80146c:	53                   	push   %ebx
  80146d:	ff 35 44 50 80 00    	pushl  0x805044
  801473:	56                   	push   %esi
  801474:	e8 77 12 00 00       	call   8026f0 <ipc_recv>
		if (!(perm & PTE_P)) {
  801479:	83 c4 10             	add    $0x10,%esp
  80147c:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801480:	0f 85 5a ff ff ff    	jne    8013e0 <serve+0x17>
			cprintf("Invalid request from %08x: no argument page\n",
  801486:	83 ec 08             	sub    $0x8,%esp
  801489:	ff 75 f4             	pushl  -0xc(%ebp)
  80148c:	68 40 3f 80 00       	push   $0x803f40
  801491:	e8 b9 05 00 00       	call   801a4f <cprintf>
			continue; // just leave it hanging...
  801496:	83 c4 10             	add    $0x10,%esp
  801499:	eb c7                	jmp    801462 <serve+0x99>

0080149b <umain>:
	}
}

void
umain(int argc, char **argv)
{
  80149b:	f3 0f 1e fb          	endbr32 
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  8014a5:	c7 05 60 90 80 00 93 	movl   $0x803f93,0x809060
  8014ac:	3f 80 00 
	cprintf("FS is running\n");
  8014af:	68 96 3f 80 00       	push   $0x803f96
  8014b4:	e8 96 05 00 00       	call   801a4f <cprintf>
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  8014b9:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  8014be:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  8014c3:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  8014c5:	c7 04 24 a5 3f 80 00 	movl   $0x803fa5,(%esp)
  8014cc:	e8 7e 05 00 00       	call   801a4f <cprintf>

	serve_init(); // init OpenFile array
  8014d1:	e8 cb fa ff ff       	call   800fa1 <serve_init>
	fs_init();
  8014d6:	e8 1d f3 ff ff       	call   8007f8 <fs_init>
	serve();
  8014db:	e8 e9 fe ff ff       	call   8013c9 <serve>

008014e0 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  8014e0:	f3 0f 1e fb          	endbr32 
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	53                   	push   %ebx
  8014e8:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  8014eb:	6a 07                	push   $0x7
  8014ed:	68 00 10 00 00       	push   $0x1000
  8014f2:	6a 00                	push   $0x0
  8014f4:	e8 c9 0f 00 00       	call   8024c2 <sys_page_alloc>
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	85 c0                	test   %eax,%eax
  8014fe:	0f 88 68 02 00 00    	js     80176c <fs_test+0x28c>
		panic("sys_page_alloc: %e", r);
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  801504:	83 ec 04             	sub    $0x4,%esp
  801507:	68 00 10 00 00       	push   $0x1000
  80150c:	ff 35 08 a0 80 00    	pushl  0x80a008
  801512:	68 00 10 00 00       	push   $0x1000
  801517:	e8 3b 0d 00 00       	call   802257 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  80151c:	e8 e6 f0 ff ff       	call   800607 <alloc_block>
  801521:	83 c4 10             	add    $0x10,%esp
  801524:	85 c0                	test   %eax,%eax
  801526:	0f 88 52 02 00 00    	js     80177e <fs_test+0x29e>
		panic("alloc_block: %e", r);
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  80152c:	8d 50 1f             	lea    0x1f(%eax),%edx
  80152f:	0f 49 d0             	cmovns %eax,%edx
  801532:	c1 fa 05             	sar    $0x5,%edx
  801535:	89 c3                	mov    %eax,%ebx
  801537:	c1 fb 1f             	sar    $0x1f,%ebx
  80153a:	c1 eb 1b             	shr    $0x1b,%ebx
  80153d:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  801540:	83 e1 1f             	and    $0x1f,%ecx
  801543:	29 d9                	sub    %ebx,%ecx
  801545:	b8 01 00 00 00       	mov    $0x1,%eax
  80154a:	d3 e0                	shl    %cl,%eax
  80154c:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  801553:	0f 84 37 02 00 00    	je     801790 <fs_test+0x2b0>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801559:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  80155f:	85 04 91             	test   %eax,(%ecx,%edx,4)
  801562:	0f 85 3e 02 00 00    	jne    8017a6 <fs_test+0x2c6>
	cprintf("alloc_block is good\n");
  801568:	83 ec 0c             	sub    $0xc,%esp
  80156b:	68 fc 3f 80 00       	push   $0x803ffc
  801570:	e8 da 04 00 00       	call   801a4f <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801575:	83 c4 08             	add    $0x8,%esp
  801578:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157b:	50                   	push   %eax
  80157c:	68 11 40 80 00       	push   $0x804011
  801581:	e8 89 f5 ff ff       	call   800b0f <file_open>
  801586:	83 c4 10             	add    $0x10,%esp
  801589:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80158c:	74 08                	je     801596 <fs_test+0xb6>
  80158e:	85 c0                	test   %eax,%eax
  801590:	0f 88 26 02 00 00    	js     8017bc <fs_test+0x2dc>
		panic("file_open /not-found: %e", r);
	else if (r == 0)
  801596:	85 c0                	test   %eax,%eax
  801598:	0f 84 30 02 00 00    	je     8017ce <fs_test+0x2ee>
		panic("file_open /not-found succeeded!");
	if ((r = file_open("/newmotd", &f)) < 0)
  80159e:	83 ec 08             	sub    $0x8,%esp
  8015a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a4:	50                   	push   %eax
  8015a5:	68 35 40 80 00       	push   $0x804035
  8015aa:	e8 60 f5 ff ff       	call   800b0f <file_open>
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	0f 88 28 02 00 00    	js     8017e2 <fs_test+0x302>
		panic("file_open /newmotd: %e", r);
	cprintf("file_open is good\n");
  8015ba:	83 ec 0c             	sub    $0xc,%esp
  8015bd:	68 55 40 80 00       	push   $0x804055
  8015c2:	e8 88 04 00 00       	call   801a4f <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8015c7:	83 c4 0c             	add    $0xc,%esp
  8015ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015cd:	50                   	push   %eax
  8015ce:	6a 00                	push   $0x0
  8015d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d3:	e8 79 f2 ff ff       	call   800851 <file_get_block>
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	85 c0                	test   %eax,%eax
  8015dd:	0f 88 11 02 00 00    	js     8017f4 <fs_test+0x314>
		panic("file_get_block: %e", r);
	if (strcmp(blk, msg) != 0)
  8015e3:	83 ec 08             	sub    $0x8,%esp
  8015e6:	68 9c 41 80 00       	push   $0x80419c
  8015eb:	ff 75 f0             	pushl  -0x10(%ebp)
  8015ee:	e8 25 0b 00 00       	call   802118 <strcmp>
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	0f 85 08 02 00 00    	jne    801806 <fs_test+0x326>
		panic("file_get_block returned wrong data");
	cprintf("file_get_block is good\n");
  8015fe:	83 ec 0c             	sub    $0xc,%esp
  801601:	68 7b 40 80 00       	push   $0x80407b
  801606:	e8 44 04 00 00       	call   801a4f <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  80160b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160e:	0f b6 10             	movzbl (%eax),%edx
  801611:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801613:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801616:	c1 e8 0c             	shr    $0xc,%eax
  801619:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	a8 40                	test   $0x40,%al
  801625:	0f 84 ef 01 00 00    	je     80181a <fs_test+0x33a>
	file_flush(f);
  80162b:	83 ec 0c             	sub    $0xc,%esp
  80162e:	ff 75 f4             	pushl  -0xc(%ebp)
  801631:	e8 32 f7 ff ff       	call   800d68 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801636:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801639:	c1 e8 0c             	shr    $0xc,%eax
  80163c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	a8 40                	test   $0x40,%al
  801648:	0f 85 e2 01 00 00    	jne    801830 <fs_test+0x350>
	cprintf("file_flush is good\n");
  80164e:	83 ec 0c             	sub    $0xc,%esp
  801651:	68 af 40 80 00       	push   $0x8040af
  801656:	e8 f4 03 00 00       	call   801a4f <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  80165b:	83 c4 08             	add    $0x8,%esp
  80165e:	6a 00                	push   $0x0
  801660:	ff 75 f4             	pushl  -0xc(%ebp)
  801663:	e8 73 f5 ff ff       	call   800bdb <file_set_size>
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	85 c0                	test   %eax,%eax
  80166d:	0f 88 d3 01 00 00    	js     801846 <fs_test+0x366>
		panic("file_set_size: %e", r);
	assert(f->f_direct[0] == 0);
  801673:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801676:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  80167d:	0f 85 d5 01 00 00    	jne    801858 <fs_test+0x378>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801683:	c1 e8 0c             	shr    $0xc,%eax
  801686:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80168d:	a8 40                	test   $0x40,%al
  80168f:	0f 85 d9 01 00 00    	jne    80186e <fs_test+0x38e>
	cprintf("file_truncate is good\n");
  801695:	83 ec 0c             	sub    $0xc,%esp
  801698:	68 03 41 80 00       	push   $0x804103
  80169d:	e8 ad 03 00 00       	call   801a4f <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8016a2:	c7 04 24 9c 41 80 00 	movl   $0x80419c,(%esp)
  8016a9:	e8 68 09 00 00       	call   802016 <strlen>
  8016ae:	83 c4 08             	add    $0x8,%esp
  8016b1:	50                   	push   %eax
  8016b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b5:	e8 21 f5 ff ff       	call   800bdb <file_set_size>
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	85 c0                	test   %eax,%eax
  8016bf:	0f 88 bf 01 00 00    	js     801884 <fs_test+0x3a4>
		panic("file_set_size 2: %e", r);
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8016c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c8:	89 c2                	mov    %eax,%edx
  8016ca:	c1 ea 0c             	shr    $0xc,%edx
  8016cd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016d4:	f6 c2 40             	test   $0x40,%dl
  8016d7:	0f 85 b9 01 00 00    	jne    801896 <fs_test+0x3b6>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  8016dd:	83 ec 04             	sub    $0x4,%esp
  8016e0:	8d 55 f0             	lea    -0x10(%ebp),%edx
  8016e3:	52                   	push   %edx
  8016e4:	6a 00                	push   $0x0
  8016e6:	50                   	push   %eax
  8016e7:	e8 65 f1 ff ff       	call   800851 <file_get_block>
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	0f 88 b5 01 00 00    	js     8018ac <fs_test+0x3cc>
		panic("file_get_block 2: %e", r);
	strcpy(blk, msg);
  8016f7:	83 ec 08             	sub    $0x8,%esp
  8016fa:	68 9c 41 80 00       	push   $0x80419c
  8016ff:	ff 75 f0             	pushl  -0x10(%ebp)
  801702:	e8 52 09 00 00       	call   802059 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801707:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170a:	c1 e8 0c             	shr    $0xc,%eax
  80170d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	a8 40                	test   $0x40,%al
  801719:	0f 84 9f 01 00 00    	je     8018be <fs_test+0x3de>
	file_flush(f);
  80171f:	83 ec 0c             	sub    $0xc,%esp
  801722:	ff 75 f4             	pushl  -0xc(%ebp)
  801725:	e8 3e f6 ff ff       	call   800d68 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  80172a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172d:	c1 e8 0c             	shr    $0xc,%eax
  801730:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	a8 40                	test   $0x40,%al
  80173c:	0f 85 92 01 00 00    	jne    8018d4 <fs_test+0x3f4>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801742:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801745:	c1 e8 0c             	shr    $0xc,%eax
  801748:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80174f:	a8 40                	test   $0x40,%al
  801751:	0f 85 93 01 00 00    	jne    8018ea <fs_test+0x40a>
	cprintf("file rewrite is good\n");
  801757:	83 ec 0c             	sub    $0xc,%esp
  80175a:	68 43 41 80 00       	push   $0x804143
  80175f:	e8 eb 02 00 00       	call   801a4f <cprintf>
}
  801764:	83 c4 10             	add    $0x10,%esp
  801767:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176a:	c9                   	leave  
  80176b:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  80176c:	50                   	push   %eax
  80176d:	68 b4 3f 80 00       	push   $0x803fb4
  801772:	6a 12                	push   $0x12
  801774:	68 c7 3f 80 00       	push   $0x803fc7
  801779:	e8 ea 01 00 00       	call   801968 <_panic>
		panic("alloc_block: %e", r);
  80177e:	50                   	push   %eax
  80177f:	68 d1 3f 80 00       	push   $0x803fd1
  801784:	6a 17                	push   $0x17
  801786:	68 c7 3f 80 00       	push   $0x803fc7
  80178b:	e8 d8 01 00 00       	call   801968 <_panic>
	assert(bits[r/32] & (1 << (r%32)));
  801790:	68 e1 3f 80 00       	push   $0x803fe1
  801795:	68 dd 3c 80 00       	push   $0x803cdd
  80179a:	6a 19                	push   $0x19
  80179c:	68 c7 3f 80 00       	push   $0x803fc7
  8017a1:	e8 c2 01 00 00       	call   801968 <_panic>
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8017a6:	68 5c 41 80 00       	push   $0x80415c
  8017ab:	68 dd 3c 80 00       	push   $0x803cdd
  8017b0:	6a 1b                	push   $0x1b
  8017b2:	68 c7 3f 80 00       	push   $0x803fc7
  8017b7:	e8 ac 01 00 00       	call   801968 <_panic>
		panic("file_open /not-found: %e", r);
  8017bc:	50                   	push   %eax
  8017bd:	68 1c 40 80 00       	push   $0x80401c
  8017c2:	6a 1f                	push   $0x1f
  8017c4:	68 c7 3f 80 00       	push   $0x803fc7
  8017c9:	e8 9a 01 00 00       	call   801968 <_panic>
		panic("file_open /not-found succeeded!");
  8017ce:	83 ec 04             	sub    $0x4,%esp
  8017d1:	68 7c 41 80 00       	push   $0x80417c
  8017d6:	6a 21                	push   $0x21
  8017d8:	68 c7 3f 80 00       	push   $0x803fc7
  8017dd:	e8 86 01 00 00       	call   801968 <_panic>
		panic("file_open /newmotd: %e", r);
  8017e2:	50                   	push   %eax
  8017e3:	68 3e 40 80 00       	push   $0x80403e
  8017e8:	6a 23                	push   $0x23
  8017ea:	68 c7 3f 80 00       	push   $0x803fc7
  8017ef:	e8 74 01 00 00       	call   801968 <_panic>
		panic("file_get_block: %e", r);
  8017f4:	50                   	push   %eax
  8017f5:	68 68 40 80 00       	push   $0x804068
  8017fa:	6a 27                	push   $0x27
  8017fc:	68 c7 3f 80 00       	push   $0x803fc7
  801801:	e8 62 01 00 00       	call   801968 <_panic>
		panic("file_get_block returned wrong data");
  801806:	83 ec 04             	sub    $0x4,%esp
  801809:	68 c4 41 80 00       	push   $0x8041c4
  80180e:	6a 29                	push   $0x29
  801810:	68 c7 3f 80 00       	push   $0x803fc7
  801815:	e8 4e 01 00 00       	call   801968 <_panic>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  80181a:	68 94 40 80 00       	push   $0x804094
  80181f:	68 dd 3c 80 00       	push   $0x803cdd
  801824:	6a 2d                	push   $0x2d
  801826:	68 c7 3f 80 00       	push   $0x803fc7
  80182b:	e8 38 01 00 00       	call   801968 <_panic>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801830:	68 93 40 80 00       	push   $0x804093
  801835:	68 dd 3c 80 00       	push   $0x803cdd
  80183a:	6a 2f                	push   $0x2f
  80183c:	68 c7 3f 80 00       	push   $0x803fc7
  801841:	e8 22 01 00 00       	call   801968 <_panic>
		panic("file_set_size: %e", r);
  801846:	50                   	push   %eax
  801847:	68 c3 40 80 00       	push   $0x8040c3
  80184c:	6a 33                	push   $0x33
  80184e:	68 c7 3f 80 00       	push   $0x803fc7
  801853:	e8 10 01 00 00       	call   801968 <_panic>
	assert(f->f_direct[0] == 0);
  801858:	68 d5 40 80 00       	push   $0x8040d5
  80185d:	68 dd 3c 80 00       	push   $0x803cdd
  801862:	6a 34                	push   $0x34
  801864:	68 c7 3f 80 00       	push   $0x803fc7
  801869:	e8 fa 00 00 00       	call   801968 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  80186e:	68 e9 40 80 00       	push   $0x8040e9
  801873:	68 dd 3c 80 00       	push   $0x803cdd
  801878:	6a 35                	push   $0x35
  80187a:	68 c7 3f 80 00       	push   $0x803fc7
  80187f:	e8 e4 00 00 00       	call   801968 <_panic>
		panic("file_set_size 2: %e", r);
  801884:	50                   	push   %eax
  801885:	68 1a 41 80 00       	push   $0x80411a
  80188a:	6a 39                	push   $0x39
  80188c:	68 c7 3f 80 00       	push   $0x803fc7
  801891:	e8 d2 00 00 00       	call   801968 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801896:	68 e9 40 80 00       	push   $0x8040e9
  80189b:	68 dd 3c 80 00       	push   $0x803cdd
  8018a0:	6a 3a                	push   $0x3a
  8018a2:	68 c7 3f 80 00       	push   $0x803fc7
  8018a7:	e8 bc 00 00 00       	call   801968 <_panic>
		panic("file_get_block 2: %e", r);
  8018ac:	50                   	push   %eax
  8018ad:	68 2e 41 80 00       	push   $0x80412e
  8018b2:	6a 3c                	push   $0x3c
  8018b4:	68 c7 3f 80 00       	push   $0x803fc7
  8018b9:	e8 aa 00 00 00       	call   801968 <_panic>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8018be:	68 94 40 80 00       	push   $0x804094
  8018c3:	68 dd 3c 80 00       	push   $0x803cdd
  8018c8:	6a 3e                	push   $0x3e
  8018ca:	68 c7 3f 80 00       	push   $0x803fc7
  8018cf:	e8 94 00 00 00       	call   801968 <_panic>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8018d4:	68 93 40 80 00       	push   $0x804093
  8018d9:	68 dd 3c 80 00       	push   $0x803cdd
  8018de:	6a 40                	push   $0x40
  8018e0:	68 c7 3f 80 00       	push   $0x803fc7
  8018e5:	e8 7e 00 00 00       	call   801968 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8018ea:	68 e9 40 80 00       	push   $0x8040e9
  8018ef:	68 dd 3c 80 00       	push   $0x803cdd
  8018f4:	6a 41                	push   $0x41
  8018f6:	68 c7 3f 80 00       	push   $0x803fc7
  8018fb:	e8 68 00 00 00       	call   801968 <_panic>

00801900 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801900:	f3 0f 1e fb          	endbr32 
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	56                   	push   %esi
  801908:	53                   	push   %ebx
  801909:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80190c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80190f:	e8 68 0b 00 00       	call   80247c <sys_getenvid>
  801914:	25 ff 03 00 00       	and    $0x3ff,%eax
  801919:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80191c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801921:	a3 10 a0 80 00       	mov    %eax,0x80a010
	// save the name of the program so that panic() can use it
	if (argc > 0)
  801926:	85 db                	test   %ebx,%ebx
  801928:	7e 07                	jle    801931 <libmain+0x31>
		binaryname = argv[0];
  80192a:	8b 06                	mov    (%esi),%eax
  80192c:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801931:	83 ec 08             	sub    $0x8,%esp
  801934:	56                   	push   %esi
  801935:	53                   	push   %ebx
  801936:	e8 60 fb ff ff       	call   80149b <umain>

	// exit gracefully
	exit();
  80193b:	e8 0a 00 00 00       	call   80194a <exit>
}
  801940:	83 c4 10             	add    $0x10,%esp
  801943:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801946:	5b                   	pop    %ebx
  801947:	5e                   	pop    %esi
  801948:	5d                   	pop    %ebp
  801949:	c3                   	ret    

0080194a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80194a:	f3 0f 1e fb          	endbr32 
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  801954:	e8 8d 10 00 00       	call   8029e6 <close_all>
	sys_env_destroy(0);
  801959:	83 ec 0c             	sub    $0xc,%esp
  80195c:	6a 00                	push   $0x0
  80195e:	e8 f5 0a 00 00       	call   802458 <sys_env_destroy>
}
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	c9                   	leave  
  801967:	c3                   	ret    

00801968 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801968:	f3 0f 1e fb          	endbr32 
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	56                   	push   %esi
  801970:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801971:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801974:	8b 35 60 90 80 00    	mov    0x809060,%esi
  80197a:	e8 fd 0a 00 00       	call   80247c <sys_getenvid>
  80197f:	83 ec 0c             	sub    $0xc,%esp
  801982:	ff 75 0c             	pushl  0xc(%ebp)
  801985:	ff 75 08             	pushl  0x8(%ebp)
  801988:	56                   	push   %esi
  801989:	50                   	push   %eax
  80198a:	68 f4 41 80 00       	push   $0x8041f4
  80198f:	e8 bb 00 00 00       	call   801a4f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801994:	83 c4 18             	add    $0x18,%esp
  801997:	53                   	push   %ebx
  801998:	ff 75 10             	pushl  0x10(%ebp)
  80199b:	e8 5a 00 00 00       	call   8019fa <vcprintf>
	cprintf("\n");
  8019a0:	c7 04 24 b2 3f 80 00 	movl   $0x803fb2,(%esp)
  8019a7:	e8 a3 00 00 00       	call   801a4f <cprintf>
  8019ac:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019af:	cc                   	int3   
  8019b0:	eb fd                	jmp    8019af <_panic+0x47>

008019b2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8019b2:	f3 0f 1e fb          	endbr32 
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	53                   	push   %ebx
  8019ba:	83 ec 04             	sub    $0x4,%esp
  8019bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8019c0:	8b 13                	mov    (%ebx),%edx
  8019c2:	8d 42 01             	lea    0x1(%edx),%eax
  8019c5:	89 03                	mov    %eax,(%ebx)
  8019c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019ca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8019ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8019d3:	74 09                	je     8019de <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8019d5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8019d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019dc:	c9                   	leave  
  8019dd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8019de:	83 ec 08             	sub    $0x8,%esp
  8019e1:	68 ff 00 00 00       	push   $0xff
  8019e6:	8d 43 08             	lea    0x8(%ebx),%eax
  8019e9:	50                   	push   %eax
  8019ea:	e8 24 0a 00 00       	call   802413 <sys_cputs>
		b->idx = 0;
  8019ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8019f5:	83 c4 10             	add    $0x10,%esp
  8019f8:	eb db                	jmp    8019d5 <putch+0x23>

008019fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8019fa:	f3 0f 1e fb          	endbr32 
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801a07:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a0e:	00 00 00 
	b.cnt = 0;
  801a11:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801a18:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801a1b:	ff 75 0c             	pushl  0xc(%ebp)
  801a1e:	ff 75 08             	pushl  0x8(%ebp)
  801a21:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801a27:	50                   	push   %eax
  801a28:	68 b2 19 80 00       	push   $0x8019b2
  801a2d:	e8 20 01 00 00       	call   801b52 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801a32:	83 c4 08             	add    $0x8,%esp
  801a35:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801a3b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801a41:	50                   	push   %eax
  801a42:	e8 cc 09 00 00       	call   802413 <sys_cputs>

	return b.cnt;
}
  801a47:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801a4d:	c9                   	leave  
  801a4e:	c3                   	ret    

00801a4f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801a4f:	f3 0f 1e fb          	endbr32 
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a59:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801a5c:	50                   	push   %eax
  801a5d:	ff 75 08             	pushl  0x8(%ebp)
  801a60:	e8 95 ff ff ff       	call   8019fa <vcprintf>
	va_end(ap);

	return cnt;
}
  801a65:	c9                   	leave  
  801a66:	c3                   	ret    

00801a67 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801a67:	55                   	push   %ebp
  801a68:	89 e5                	mov    %esp,%ebp
  801a6a:	57                   	push   %edi
  801a6b:	56                   	push   %esi
  801a6c:	53                   	push   %ebx
  801a6d:	83 ec 1c             	sub    $0x1c,%esp
  801a70:	89 c7                	mov    %eax,%edi
  801a72:	89 d6                	mov    %edx,%esi
  801a74:	8b 45 08             	mov    0x8(%ebp),%eax
  801a77:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a7a:	89 d1                	mov    %edx,%ecx
  801a7c:	89 c2                	mov    %eax,%edx
  801a7e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a81:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a84:	8b 45 10             	mov    0x10(%ebp),%eax
  801a87:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  801a8a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a8d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801a94:	39 c2                	cmp    %eax,%edx
  801a96:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801a99:	72 3e                	jb     801ad9 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801a9b:	83 ec 0c             	sub    $0xc,%esp
  801a9e:	ff 75 18             	pushl  0x18(%ebp)
  801aa1:	83 eb 01             	sub    $0x1,%ebx
  801aa4:	53                   	push   %ebx
  801aa5:	50                   	push   %eax
  801aa6:	83 ec 08             	sub    $0x8,%esp
  801aa9:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aac:	ff 75 e0             	pushl  -0x20(%ebp)
  801aaf:	ff 75 dc             	pushl  -0x24(%ebp)
  801ab2:	ff 75 d8             	pushl  -0x28(%ebp)
  801ab5:	e8 86 1f 00 00       	call   803a40 <__udivdi3>
  801aba:	83 c4 18             	add    $0x18,%esp
  801abd:	52                   	push   %edx
  801abe:	50                   	push   %eax
  801abf:	89 f2                	mov    %esi,%edx
  801ac1:	89 f8                	mov    %edi,%eax
  801ac3:	e8 9f ff ff ff       	call   801a67 <printnum>
  801ac8:	83 c4 20             	add    $0x20,%esp
  801acb:	eb 13                	jmp    801ae0 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801acd:	83 ec 08             	sub    $0x8,%esp
  801ad0:	56                   	push   %esi
  801ad1:	ff 75 18             	pushl  0x18(%ebp)
  801ad4:	ff d7                	call   *%edi
  801ad6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801ad9:	83 eb 01             	sub    $0x1,%ebx
  801adc:	85 db                	test   %ebx,%ebx
  801ade:	7f ed                	jg     801acd <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801ae0:	83 ec 08             	sub    $0x8,%esp
  801ae3:	56                   	push   %esi
  801ae4:	83 ec 04             	sub    $0x4,%esp
  801ae7:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aea:	ff 75 e0             	pushl  -0x20(%ebp)
  801aed:	ff 75 dc             	pushl  -0x24(%ebp)
  801af0:	ff 75 d8             	pushl  -0x28(%ebp)
  801af3:	e8 58 20 00 00       	call   803b50 <__umoddi3>
  801af8:	83 c4 14             	add    $0x14,%esp
  801afb:	0f be 80 17 42 80 00 	movsbl 0x804217(%eax),%eax
  801b02:	50                   	push   %eax
  801b03:	ff d7                	call   *%edi
}
  801b05:	83 c4 10             	add    $0x10,%esp
  801b08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0b:	5b                   	pop    %ebx
  801b0c:	5e                   	pop    %esi
  801b0d:	5f                   	pop    %edi
  801b0e:	5d                   	pop    %ebp
  801b0f:	c3                   	ret    

00801b10 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801b10:	f3 0f 1e fb          	endbr32 
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801b1a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801b1e:	8b 10                	mov    (%eax),%edx
  801b20:	3b 50 04             	cmp    0x4(%eax),%edx
  801b23:	73 0a                	jae    801b2f <sprintputch+0x1f>
		*b->buf++ = ch;
  801b25:	8d 4a 01             	lea    0x1(%edx),%ecx
  801b28:	89 08                	mov    %ecx,(%eax)
  801b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2d:	88 02                	mov    %al,(%edx)
}
  801b2f:	5d                   	pop    %ebp
  801b30:	c3                   	ret    

00801b31 <printfmt>:
{
  801b31:	f3 0f 1e fb          	endbr32 
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801b3b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801b3e:	50                   	push   %eax
  801b3f:	ff 75 10             	pushl  0x10(%ebp)
  801b42:	ff 75 0c             	pushl  0xc(%ebp)
  801b45:	ff 75 08             	pushl  0x8(%ebp)
  801b48:	e8 05 00 00 00       	call   801b52 <vprintfmt>
}
  801b4d:	83 c4 10             	add    $0x10,%esp
  801b50:	c9                   	leave  
  801b51:	c3                   	ret    

00801b52 <vprintfmt>:
{
  801b52:	f3 0f 1e fb          	endbr32 
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	57                   	push   %edi
  801b5a:	56                   	push   %esi
  801b5b:	53                   	push   %ebx
  801b5c:	83 ec 3c             	sub    $0x3c,%esp
  801b5f:	8b 75 08             	mov    0x8(%ebp),%esi
  801b62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b65:	8b 7d 10             	mov    0x10(%ebp),%edi
  801b68:	e9 8e 03 00 00       	jmp    801efb <vprintfmt+0x3a9>
		padc = ' ';
  801b6d:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  801b71:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801b78:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801b7f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801b86:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801b8b:	8d 47 01             	lea    0x1(%edi),%eax
  801b8e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b91:	0f b6 17             	movzbl (%edi),%edx
  801b94:	8d 42 dd             	lea    -0x23(%edx),%eax
  801b97:	3c 55                	cmp    $0x55,%al
  801b99:	0f 87 df 03 00 00    	ja     801f7e <vprintfmt+0x42c>
  801b9f:	0f b6 c0             	movzbl %al,%eax
  801ba2:	3e ff 24 85 60 43 80 	notrack jmp *0x804360(,%eax,4)
  801ba9:	00 
  801baa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801bad:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801bb1:	eb d8                	jmp    801b8b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801bb3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801bb6:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801bba:	eb cf                	jmp    801b8b <vprintfmt+0x39>
  801bbc:	0f b6 d2             	movzbl %dl,%edx
  801bbf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801bc2:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  801bca:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801bcd:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801bd1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801bd4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801bd7:	83 f9 09             	cmp    $0x9,%ecx
  801bda:	77 55                	ja     801c31 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  801bdc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  801bdf:	eb e9                	jmp    801bca <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801be1:	8b 45 14             	mov    0x14(%ebp),%eax
  801be4:	8b 00                	mov    (%eax),%eax
  801be6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801be9:	8b 45 14             	mov    0x14(%ebp),%eax
  801bec:	8d 40 04             	lea    0x4(%eax),%eax
  801bef:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801bf2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801bf5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801bf9:	79 90                	jns    801b8b <vprintfmt+0x39>
				width = precision, precision = -1;
  801bfb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801bfe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c01:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801c08:	eb 81                	jmp    801b8b <vprintfmt+0x39>
  801c0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c0d:	85 c0                	test   %eax,%eax
  801c0f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c14:	0f 49 d0             	cmovns %eax,%edx
  801c17:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801c1a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801c1d:	e9 69 ff ff ff       	jmp    801b8b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801c22:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801c25:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801c2c:	e9 5a ff ff ff       	jmp    801b8b <vprintfmt+0x39>
  801c31:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801c34:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801c37:	eb bc                	jmp    801bf5 <vprintfmt+0xa3>
			lflag++;
  801c39:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801c3c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801c3f:	e9 47 ff ff ff       	jmp    801b8b <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  801c44:	8b 45 14             	mov    0x14(%ebp),%eax
  801c47:	8d 78 04             	lea    0x4(%eax),%edi
  801c4a:	83 ec 08             	sub    $0x8,%esp
  801c4d:	53                   	push   %ebx
  801c4e:	ff 30                	pushl  (%eax)
  801c50:	ff d6                	call   *%esi
			break;
  801c52:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801c55:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801c58:	e9 9b 02 00 00       	jmp    801ef8 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  801c5d:	8b 45 14             	mov    0x14(%ebp),%eax
  801c60:	8d 78 04             	lea    0x4(%eax),%edi
  801c63:	8b 00                	mov    (%eax),%eax
  801c65:	99                   	cltd   
  801c66:	31 d0                	xor    %edx,%eax
  801c68:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801c6a:	83 f8 0f             	cmp    $0xf,%eax
  801c6d:	7f 23                	jg     801c92 <vprintfmt+0x140>
  801c6f:	8b 14 85 c0 44 80 00 	mov    0x8044c0(,%eax,4),%edx
  801c76:	85 d2                	test   %edx,%edx
  801c78:	74 18                	je     801c92 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  801c7a:	52                   	push   %edx
  801c7b:	68 ef 3c 80 00       	push   $0x803cef
  801c80:	53                   	push   %ebx
  801c81:	56                   	push   %esi
  801c82:	e8 aa fe ff ff       	call   801b31 <printfmt>
  801c87:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801c8a:	89 7d 14             	mov    %edi,0x14(%ebp)
  801c8d:	e9 66 02 00 00       	jmp    801ef8 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  801c92:	50                   	push   %eax
  801c93:	68 2f 42 80 00       	push   $0x80422f
  801c98:	53                   	push   %ebx
  801c99:	56                   	push   %esi
  801c9a:	e8 92 fe ff ff       	call   801b31 <printfmt>
  801c9f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801ca2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801ca5:	e9 4e 02 00 00       	jmp    801ef8 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  801caa:	8b 45 14             	mov    0x14(%ebp),%eax
  801cad:	83 c0 04             	add    $0x4,%eax
  801cb0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801cb3:	8b 45 14             	mov    0x14(%ebp),%eax
  801cb6:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801cb8:	85 d2                	test   %edx,%edx
  801cba:	b8 28 42 80 00       	mov    $0x804228,%eax
  801cbf:	0f 45 c2             	cmovne %edx,%eax
  801cc2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801cc5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801cc9:	7e 06                	jle    801cd1 <vprintfmt+0x17f>
  801ccb:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801ccf:	75 0d                	jne    801cde <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  801cd1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801cd4:	89 c7                	mov    %eax,%edi
  801cd6:	03 45 e0             	add    -0x20(%ebp),%eax
  801cd9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801cdc:	eb 55                	jmp    801d33 <vprintfmt+0x1e1>
  801cde:	83 ec 08             	sub    $0x8,%esp
  801ce1:	ff 75 d8             	pushl  -0x28(%ebp)
  801ce4:	ff 75 cc             	pushl  -0x34(%ebp)
  801ce7:	e8 46 03 00 00       	call   802032 <strnlen>
  801cec:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801cef:	29 c2                	sub    %eax,%edx
  801cf1:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801cf4:	83 c4 10             	add    $0x10,%esp
  801cf7:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  801cf9:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801cfd:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801d00:	85 ff                	test   %edi,%edi
  801d02:	7e 11                	jle    801d15 <vprintfmt+0x1c3>
					putch(padc, putdat);
  801d04:	83 ec 08             	sub    $0x8,%esp
  801d07:	53                   	push   %ebx
  801d08:	ff 75 e0             	pushl  -0x20(%ebp)
  801d0b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801d0d:	83 ef 01             	sub    $0x1,%edi
  801d10:	83 c4 10             	add    $0x10,%esp
  801d13:	eb eb                	jmp    801d00 <vprintfmt+0x1ae>
  801d15:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801d18:	85 d2                	test   %edx,%edx
  801d1a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1f:	0f 49 c2             	cmovns %edx,%eax
  801d22:	29 c2                	sub    %eax,%edx
  801d24:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801d27:	eb a8                	jmp    801cd1 <vprintfmt+0x17f>
					putch(ch, putdat);
  801d29:	83 ec 08             	sub    $0x8,%esp
  801d2c:	53                   	push   %ebx
  801d2d:	52                   	push   %edx
  801d2e:	ff d6                	call   *%esi
  801d30:	83 c4 10             	add    $0x10,%esp
  801d33:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801d36:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801d38:	83 c7 01             	add    $0x1,%edi
  801d3b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801d3f:	0f be d0             	movsbl %al,%edx
  801d42:	85 d2                	test   %edx,%edx
  801d44:	74 4b                	je     801d91 <vprintfmt+0x23f>
  801d46:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801d4a:	78 06                	js     801d52 <vprintfmt+0x200>
  801d4c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  801d50:	78 1e                	js     801d70 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  801d52:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801d56:	74 d1                	je     801d29 <vprintfmt+0x1d7>
  801d58:	0f be c0             	movsbl %al,%eax
  801d5b:	83 e8 20             	sub    $0x20,%eax
  801d5e:	83 f8 5e             	cmp    $0x5e,%eax
  801d61:	76 c6                	jbe    801d29 <vprintfmt+0x1d7>
					putch('?', putdat);
  801d63:	83 ec 08             	sub    $0x8,%esp
  801d66:	53                   	push   %ebx
  801d67:	6a 3f                	push   $0x3f
  801d69:	ff d6                	call   *%esi
  801d6b:	83 c4 10             	add    $0x10,%esp
  801d6e:	eb c3                	jmp    801d33 <vprintfmt+0x1e1>
  801d70:	89 cf                	mov    %ecx,%edi
  801d72:	eb 0e                	jmp    801d82 <vprintfmt+0x230>
				putch(' ', putdat);
  801d74:	83 ec 08             	sub    $0x8,%esp
  801d77:	53                   	push   %ebx
  801d78:	6a 20                	push   $0x20
  801d7a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801d7c:	83 ef 01             	sub    $0x1,%edi
  801d7f:	83 c4 10             	add    $0x10,%esp
  801d82:	85 ff                	test   %edi,%edi
  801d84:	7f ee                	jg     801d74 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  801d86:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801d89:	89 45 14             	mov    %eax,0x14(%ebp)
  801d8c:	e9 67 01 00 00       	jmp    801ef8 <vprintfmt+0x3a6>
  801d91:	89 cf                	mov    %ecx,%edi
  801d93:	eb ed                	jmp    801d82 <vprintfmt+0x230>
	if (lflag >= 2)
  801d95:	83 f9 01             	cmp    $0x1,%ecx
  801d98:	7f 1b                	jg     801db5 <vprintfmt+0x263>
	else if (lflag)
  801d9a:	85 c9                	test   %ecx,%ecx
  801d9c:	74 63                	je     801e01 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  801d9e:	8b 45 14             	mov    0x14(%ebp),%eax
  801da1:	8b 00                	mov    (%eax),%eax
  801da3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801da6:	99                   	cltd   
  801da7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801daa:	8b 45 14             	mov    0x14(%ebp),%eax
  801dad:	8d 40 04             	lea    0x4(%eax),%eax
  801db0:	89 45 14             	mov    %eax,0x14(%ebp)
  801db3:	eb 17                	jmp    801dcc <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  801db5:	8b 45 14             	mov    0x14(%ebp),%eax
  801db8:	8b 50 04             	mov    0x4(%eax),%edx
  801dbb:	8b 00                	mov    (%eax),%eax
  801dbd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801dc0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801dc3:	8b 45 14             	mov    0x14(%ebp),%eax
  801dc6:	8d 40 08             	lea    0x8(%eax),%eax
  801dc9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801dcc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801dcf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801dd2:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  801dd7:	85 c9                	test   %ecx,%ecx
  801dd9:	0f 89 ff 00 00 00    	jns    801ede <vprintfmt+0x38c>
				putch('-', putdat);
  801ddf:	83 ec 08             	sub    $0x8,%esp
  801de2:	53                   	push   %ebx
  801de3:	6a 2d                	push   $0x2d
  801de5:	ff d6                	call   *%esi
				num = -(long long) num;
  801de7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801dea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801ded:	f7 da                	neg    %edx
  801def:	83 d1 00             	adc    $0x0,%ecx
  801df2:	f7 d9                	neg    %ecx
  801df4:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801df7:	b8 0a 00 00 00       	mov    $0xa,%eax
  801dfc:	e9 dd 00 00 00       	jmp    801ede <vprintfmt+0x38c>
		return va_arg(*ap, int);
  801e01:	8b 45 14             	mov    0x14(%ebp),%eax
  801e04:	8b 00                	mov    (%eax),%eax
  801e06:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e09:	99                   	cltd   
  801e0a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801e0d:	8b 45 14             	mov    0x14(%ebp),%eax
  801e10:	8d 40 04             	lea    0x4(%eax),%eax
  801e13:	89 45 14             	mov    %eax,0x14(%ebp)
  801e16:	eb b4                	jmp    801dcc <vprintfmt+0x27a>
	if (lflag >= 2)
  801e18:	83 f9 01             	cmp    $0x1,%ecx
  801e1b:	7f 1e                	jg     801e3b <vprintfmt+0x2e9>
	else if (lflag)
  801e1d:	85 c9                	test   %ecx,%ecx
  801e1f:	74 32                	je     801e53 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  801e21:	8b 45 14             	mov    0x14(%ebp),%eax
  801e24:	8b 10                	mov    (%eax),%edx
  801e26:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e2b:	8d 40 04             	lea    0x4(%eax),%eax
  801e2e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801e31:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  801e36:	e9 a3 00 00 00       	jmp    801ede <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801e3b:	8b 45 14             	mov    0x14(%ebp),%eax
  801e3e:	8b 10                	mov    (%eax),%edx
  801e40:	8b 48 04             	mov    0x4(%eax),%ecx
  801e43:	8d 40 08             	lea    0x8(%eax),%eax
  801e46:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801e49:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  801e4e:	e9 8b 00 00 00       	jmp    801ede <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801e53:	8b 45 14             	mov    0x14(%ebp),%eax
  801e56:	8b 10                	mov    (%eax),%edx
  801e58:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e5d:	8d 40 04             	lea    0x4(%eax),%eax
  801e60:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801e63:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  801e68:	eb 74                	jmp    801ede <vprintfmt+0x38c>
	if (lflag >= 2)
  801e6a:	83 f9 01             	cmp    $0x1,%ecx
  801e6d:	7f 1b                	jg     801e8a <vprintfmt+0x338>
	else if (lflag)
  801e6f:	85 c9                	test   %ecx,%ecx
  801e71:	74 2c                	je     801e9f <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  801e73:	8b 45 14             	mov    0x14(%ebp),%eax
  801e76:	8b 10                	mov    (%eax),%edx
  801e78:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e7d:	8d 40 04             	lea    0x4(%eax),%eax
  801e80:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801e83:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  801e88:	eb 54                	jmp    801ede <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801e8a:	8b 45 14             	mov    0x14(%ebp),%eax
  801e8d:	8b 10                	mov    (%eax),%edx
  801e8f:	8b 48 04             	mov    0x4(%eax),%ecx
  801e92:	8d 40 08             	lea    0x8(%eax),%eax
  801e95:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801e98:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  801e9d:	eb 3f                	jmp    801ede <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801e9f:	8b 45 14             	mov    0x14(%ebp),%eax
  801ea2:	8b 10                	mov    (%eax),%edx
  801ea4:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ea9:	8d 40 04             	lea    0x4(%eax),%eax
  801eac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801eaf:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  801eb4:	eb 28                	jmp    801ede <vprintfmt+0x38c>
			putch('0', putdat);
  801eb6:	83 ec 08             	sub    $0x8,%esp
  801eb9:	53                   	push   %ebx
  801eba:	6a 30                	push   $0x30
  801ebc:	ff d6                	call   *%esi
			putch('x', putdat);
  801ebe:	83 c4 08             	add    $0x8,%esp
  801ec1:	53                   	push   %ebx
  801ec2:	6a 78                	push   $0x78
  801ec4:	ff d6                	call   *%esi
			num = (unsigned long long)
  801ec6:	8b 45 14             	mov    0x14(%ebp),%eax
  801ec9:	8b 10                	mov    (%eax),%edx
  801ecb:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801ed0:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801ed3:	8d 40 04             	lea    0x4(%eax),%eax
  801ed6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ed9:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  801ede:	83 ec 0c             	sub    $0xc,%esp
  801ee1:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801ee5:	57                   	push   %edi
  801ee6:	ff 75 e0             	pushl  -0x20(%ebp)
  801ee9:	50                   	push   %eax
  801eea:	51                   	push   %ecx
  801eeb:	52                   	push   %edx
  801eec:	89 da                	mov    %ebx,%edx
  801eee:	89 f0                	mov    %esi,%eax
  801ef0:	e8 72 fb ff ff       	call   801a67 <printnum>
			break;
  801ef5:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  801ef8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  801efb:	83 c7 01             	add    $0x1,%edi
  801efe:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801f02:	83 f8 25             	cmp    $0x25,%eax
  801f05:	0f 84 62 fc ff ff    	je     801b6d <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	0f 84 8b 00 00 00    	je     801f9e <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  801f13:	83 ec 08             	sub    $0x8,%esp
  801f16:	53                   	push   %ebx
  801f17:	50                   	push   %eax
  801f18:	ff d6                	call   *%esi
  801f1a:	83 c4 10             	add    $0x10,%esp
  801f1d:	eb dc                	jmp    801efb <vprintfmt+0x3a9>
	if (lflag >= 2)
  801f1f:	83 f9 01             	cmp    $0x1,%ecx
  801f22:	7f 1b                	jg     801f3f <vprintfmt+0x3ed>
	else if (lflag)
  801f24:	85 c9                	test   %ecx,%ecx
  801f26:	74 2c                	je     801f54 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  801f28:	8b 45 14             	mov    0x14(%ebp),%eax
  801f2b:	8b 10                	mov    (%eax),%edx
  801f2d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801f32:	8d 40 04             	lea    0x4(%eax),%eax
  801f35:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801f38:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  801f3d:	eb 9f                	jmp    801ede <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801f3f:	8b 45 14             	mov    0x14(%ebp),%eax
  801f42:	8b 10                	mov    (%eax),%edx
  801f44:	8b 48 04             	mov    0x4(%eax),%ecx
  801f47:	8d 40 08             	lea    0x8(%eax),%eax
  801f4a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801f4d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  801f52:	eb 8a                	jmp    801ede <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801f54:	8b 45 14             	mov    0x14(%ebp),%eax
  801f57:	8b 10                	mov    (%eax),%edx
  801f59:	b9 00 00 00 00       	mov    $0x0,%ecx
  801f5e:	8d 40 04             	lea    0x4(%eax),%eax
  801f61:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801f64:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  801f69:	e9 70 ff ff ff       	jmp    801ede <vprintfmt+0x38c>
			putch(ch, putdat);
  801f6e:	83 ec 08             	sub    $0x8,%esp
  801f71:	53                   	push   %ebx
  801f72:	6a 25                	push   $0x25
  801f74:	ff d6                	call   *%esi
			break;
  801f76:	83 c4 10             	add    $0x10,%esp
  801f79:	e9 7a ff ff ff       	jmp    801ef8 <vprintfmt+0x3a6>
			putch('%', putdat);
  801f7e:	83 ec 08             	sub    $0x8,%esp
  801f81:	53                   	push   %ebx
  801f82:	6a 25                	push   $0x25
  801f84:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  801f86:	83 c4 10             	add    $0x10,%esp
  801f89:	89 f8                	mov    %edi,%eax
  801f8b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801f8f:	74 05                	je     801f96 <vprintfmt+0x444>
  801f91:	83 e8 01             	sub    $0x1,%eax
  801f94:	eb f5                	jmp    801f8b <vprintfmt+0x439>
  801f96:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f99:	e9 5a ff ff ff       	jmp    801ef8 <vprintfmt+0x3a6>
}
  801f9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa1:	5b                   	pop    %ebx
  801fa2:	5e                   	pop    %esi
  801fa3:	5f                   	pop    %edi
  801fa4:	5d                   	pop    %ebp
  801fa5:	c3                   	ret    

00801fa6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801fa6:	f3 0f 1e fb          	endbr32 
  801faa:	55                   	push   %ebp
  801fab:	89 e5                	mov    %esp,%ebp
  801fad:	83 ec 18             	sub    $0x18,%esp
  801fb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801fb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801fb9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801fbd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801fc0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	74 26                	je     801ff1 <vsnprintf+0x4b>
  801fcb:	85 d2                	test   %edx,%edx
  801fcd:	7e 22                	jle    801ff1 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801fcf:	ff 75 14             	pushl  0x14(%ebp)
  801fd2:	ff 75 10             	pushl  0x10(%ebp)
  801fd5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801fd8:	50                   	push   %eax
  801fd9:	68 10 1b 80 00       	push   $0x801b10
  801fde:	e8 6f fb ff ff       	call   801b52 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801fe3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801fe6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fec:	83 c4 10             	add    $0x10,%esp
}
  801fef:	c9                   	leave  
  801ff0:	c3                   	ret    
		return -E_INVAL;
  801ff1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ff6:	eb f7                	jmp    801fef <vsnprintf+0x49>

00801ff8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801ff8:	f3 0f 1e fb          	endbr32 
  801ffc:	55                   	push   %ebp
  801ffd:	89 e5                	mov    %esp,%ebp
  801fff:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  802002:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  802005:	50                   	push   %eax
  802006:	ff 75 10             	pushl  0x10(%ebp)
  802009:	ff 75 0c             	pushl  0xc(%ebp)
  80200c:	ff 75 08             	pushl  0x8(%ebp)
  80200f:	e8 92 ff ff ff       	call   801fa6 <vsnprintf>
	va_end(ap);

	return rc;
}
  802014:	c9                   	leave  
  802015:	c3                   	ret    

00802016 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802016:	f3 0f 1e fb          	endbr32 
  80201a:	55                   	push   %ebp
  80201b:	89 e5                	mov    %esp,%ebp
  80201d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  802020:	b8 00 00 00 00       	mov    $0x0,%eax
  802025:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  802029:	74 05                	je     802030 <strlen+0x1a>
		n++;
  80202b:	83 c0 01             	add    $0x1,%eax
  80202e:	eb f5                	jmp    802025 <strlen+0xf>
	return n;
}
  802030:	5d                   	pop    %ebp
  802031:	c3                   	ret    

00802032 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  802032:	f3 0f 1e fb          	endbr32 
  802036:	55                   	push   %ebp
  802037:	89 e5                	mov    %esp,%ebp
  802039:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80203c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80203f:	b8 00 00 00 00       	mov    $0x0,%eax
  802044:	39 d0                	cmp    %edx,%eax
  802046:	74 0d                	je     802055 <strnlen+0x23>
  802048:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80204c:	74 05                	je     802053 <strnlen+0x21>
		n++;
  80204e:	83 c0 01             	add    $0x1,%eax
  802051:	eb f1                	jmp    802044 <strnlen+0x12>
  802053:	89 c2                	mov    %eax,%edx
	return n;
}
  802055:	89 d0                	mov    %edx,%eax
  802057:	5d                   	pop    %ebp
  802058:	c3                   	ret    

00802059 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802059:	f3 0f 1e fb          	endbr32 
  80205d:	55                   	push   %ebp
  80205e:	89 e5                	mov    %esp,%ebp
  802060:	53                   	push   %ebx
  802061:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802064:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  802067:	b8 00 00 00 00       	mov    $0x0,%eax
  80206c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  802070:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  802073:	83 c0 01             	add    $0x1,%eax
  802076:	84 d2                	test   %dl,%dl
  802078:	75 f2                	jne    80206c <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80207a:	89 c8                	mov    %ecx,%eax
  80207c:	5b                   	pop    %ebx
  80207d:	5d                   	pop    %ebp
  80207e:	c3                   	ret    

0080207f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80207f:	f3 0f 1e fb          	endbr32 
  802083:	55                   	push   %ebp
  802084:	89 e5                	mov    %esp,%ebp
  802086:	53                   	push   %ebx
  802087:	83 ec 10             	sub    $0x10,%esp
  80208a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80208d:	53                   	push   %ebx
  80208e:	e8 83 ff ff ff       	call   802016 <strlen>
  802093:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  802096:	ff 75 0c             	pushl  0xc(%ebp)
  802099:	01 d8                	add    %ebx,%eax
  80209b:	50                   	push   %eax
  80209c:	e8 b8 ff ff ff       	call   802059 <strcpy>
	return dst;
}
  8020a1:	89 d8                	mov    %ebx,%eax
  8020a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020a6:	c9                   	leave  
  8020a7:	c3                   	ret    

008020a8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8020a8:	f3 0f 1e fb          	endbr32 
  8020ac:	55                   	push   %ebp
  8020ad:	89 e5                	mov    %esp,%ebp
  8020af:	56                   	push   %esi
  8020b0:	53                   	push   %ebx
  8020b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8020b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020b7:	89 f3                	mov    %esi,%ebx
  8020b9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8020bc:	89 f0                	mov    %esi,%eax
  8020be:	39 d8                	cmp    %ebx,%eax
  8020c0:	74 11                	je     8020d3 <strncpy+0x2b>
		*dst++ = *src;
  8020c2:	83 c0 01             	add    $0x1,%eax
  8020c5:	0f b6 0a             	movzbl (%edx),%ecx
  8020c8:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8020cb:	80 f9 01             	cmp    $0x1,%cl
  8020ce:	83 da ff             	sbb    $0xffffffff,%edx
  8020d1:	eb eb                	jmp    8020be <strncpy+0x16>
	}
	return ret;
}
  8020d3:	89 f0                	mov    %esi,%eax
  8020d5:	5b                   	pop    %ebx
  8020d6:	5e                   	pop    %esi
  8020d7:	5d                   	pop    %ebp
  8020d8:	c3                   	ret    

008020d9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8020d9:	f3 0f 1e fb          	endbr32 
  8020dd:	55                   	push   %ebp
  8020de:	89 e5                	mov    %esp,%ebp
  8020e0:	56                   	push   %esi
  8020e1:	53                   	push   %ebx
  8020e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8020e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020e8:	8b 55 10             	mov    0x10(%ebp),%edx
  8020eb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8020ed:	85 d2                	test   %edx,%edx
  8020ef:	74 21                	je     802112 <strlcpy+0x39>
  8020f1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8020f5:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8020f7:	39 c2                	cmp    %eax,%edx
  8020f9:	74 14                	je     80210f <strlcpy+0x36>
  8020fb:	0f b6 19             	movzbl (%ecx),%ebx
  8020fe:	84 db                	test   %bl,%bl
  802100:	74 0b                	je     80210d <strlcpy+0x34>
			*dst++ = *src++;
  802102:	83 c1 01             	add    $0x1,%ecx
  802105:	83 c2 01             	add    $0x1,%edx
  802108:	88 5a ff             	mov    %bl,-0x1(%edx)
  80210b:	eb ea                	jmp    8020f7 <strlcpy+0x1e>
  80210d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80210f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  802112:	29 f0                	sub    %esi,%eax
}
  802114:	5b                   	pop    %ebx
  802115:	5e                   	pop    %esi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    

00802118 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  802118:	f3 0f 1e fb          	endbr32 
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802122:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  802125:	0f b6 01             	movzbl (%ecx),%eax
  802128:	84 c0                	test   %al,%al
  80212a:	74 0c                	je     802138 <strcmp+0x20>
  80212c:	3a 02                	cmp    (%edx),%al
  80212e:	75 08                	jne    802138 <strcmp+0x20>
		p++, q++;
  802130:	83 c1 01             	add    $0x1,%ecx
  802133:	83 c2 01             	add    $0x1,%edx
  802136:	eb ed                	jmp    802125 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  802138:	0f b6 c0             	movzbl %al,%eax
  80213b:	0f b6 12             	movzbl (%edx),%edx
  80213e:	29 d0                	sub    %edx,%eax
}
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    

00802142 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  802142:	f3 0f 1e fb          	endbr32 
  802146:	55                   	push   %ebp
  802147:	89 e5                	mov    %esp,%ebp
  802149:	53                   	push   %ebx
  80214a:	8b 45 08             	mov    0x8(%ebp),%eax
  80214d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802150:	89 c3                	mov    %eax,%ebx
  802152:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  802155:	eb 06                	jmp    80215d <strncmp+0x1b>
		n--, p++, q++;
  802157:	83 c0 01             	add    $0x1,%eax
  80215a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80215d:	39 d8                	cmp    %ebx,%eax
  80215f:	74 16                	je     802177 <strncmp+0x35>
  802161:	0f b6 08             	movzbl (%eax),%ecx
  802164:	84 c9                	test   %cl,%cl
  802166:	74 04                	je     80216c <strncmp+0x2a>
  802168:	3a 0a                	cmp    (%edx),%cl
  80216a:	74 eb                	je     802157 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80216c:	0f b6 00             	movzbl (%eax),%eax
  80216f:	0f b6 12             	movzbl (%edx),%edx
  802172:	29 d0                	sub    %edx,%eax
}
  802174:	5b                   	pop    %ebx
  802175:	5d                   	pop    %ebp
  802176:	c3                   	ret    
		return 0;
  802177:	b8 00 00 00 00       	mov    $0x0,%eax
  80217c:	eb f6                	jmp    802174 <strncmp+0x32>

0080217e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80217e:	f3 0f 1e fb          	endbr32 
  802182:	55                   	push   %ebp
  802183:	89 e5                	mov    %esp,%ebp
  802185:	8b 45 08             	mov    0x8(%ebp),%eax
  802188:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80218c:	0f b6 10             	movzbl (%eax),%edx
  80218f:	84 d2                	test   %dl,%dl
  802191:	74 09                	je     80219c <strchr+0x1e>
		if (*s == c)
  802193:	38 ca                	cmp    %cl,%dl
  802195:	74 0a                	je     8021a1 <strchr+0x23>
	for (; *s; s++)
  802197:	83 c0 01             	add    $0x1,%eax
  80219a:	eb f0                	jmp    80218c <strchr+0xe>
			return (char *) s;
	return 0;
  80219c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021a1:	5d                   	pop    %ebp
  8021a2:	c3                   	ret    

008021a3 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  8021a3:	f3 0f 1e fb          	endbr32 
  8021a7:	55                   	push   %ebp
  8021a8:	89 e5                	mov    %esp,%ebp
  8021aa:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  8021ad:	6a 78                	push   $0x78
  8021af:	ff 75 08             	pushl  0x8(%ebp)
  8021b2:	e8 c7 ff ff ff       	call   80217e <strchr>
  8021b7:	83 c4 10             	add    $0x10,%esp
  8021ba:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  8021bd:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  8021c2:	eb 0d                	jmp    8021d1 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  8021c4:	c1 e0 04             	shl    $0x4,%eax
  8021c7:	0f be d2             	movsbl %dl,%edx
  8021ca:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  8021ce:	83 c1 01             	add    $0x1,%ecx
  8021d1:	0f b6 11             	movzbl (%ecx),%edx
  8021d4:	84 d2                	test   %dl,%dl
  8021d6:	74 11                	je     8021e9 <atox+0x46>
		if (*p>='a'){
  8021d8:	80 fa 60             	cmp    $0x60,%dl
  8021db:	7e e7                	jle    8021c4 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  8021dd:	c1 e0 04             	shl    $0x4,%eax
  8021e0:	0f be d2             	movsbl %dl,%edx
  8021e3:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  8021e7:	eb e5                	jmp    8021ce <atox+0x2b>
	}

	return v;

}
  8021e9:	c9                   	leave  
  8021ea:	c3                   	ret    

008021eb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8021eb:	f3 0f 1e fb          	endbr32 
  8021ef:	55                   	push   %ebp
  8021f0:	89 e5                	mov    %esp,%ebp
  8021f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8021f9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8021fc:	38 ca                	cmp    %cl,%dl
  8021fe:	74 09                	je     802209 <strfind+0x1e>
  802200:	84 d2                	test   %dl,%dl
  802202:	74 05                	je     802209 <strfind+0x1e>
	for (; *s; s++)
  802204:	83 c0 01             	add    $0x1,%eax
  802207:	eb f0                	jmp    8021f9 <strfind+0xe>
			break;
	return (char *) s;
}
  802209:	5d                   	pop    %ebp
  80220a:	c3                   	ret    

0080220b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80220b:	f3 0f 1e fb          	endbr32 
  80220f:	55                   	push   %ebp
  802210:	89 e5                	mov    %esp,%ebp
  802212:	57                   	push   %edi
  802213:	56                   	push   %esi
  802214:	53                   	push   %ebx
  802215:	8b 7d 08             	mov    0x8(%ebp),%edi
  802218:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80221b:	85 c9                	test   %ecx,%ecx
  80221d:	74 31                	je     802250 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80221f:	89 f8                	mov    %edi,%eax
  802221:	09 c8                	or     %ecx,%eax
  802223:	a8 03                	test   $0x3,%al
  802225:	75 23                	jne    80224a <memset+0x3f>
		c &= 0xFF;
  802227:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80222b:	89 d3                	mov    %edx,%ebx
  80222d:	c1 e3 08             	shl    $0x8,%ebx
  802230:	89 d0                	mov    %edx,%eax
  802232:	c1 e0 18             	shl    $0x18,%eax
  802235:	89 d6                	mov    %edx,%esi
  802237:	c1 e6 10             	shl    $0x10,%esi
  80223a:	09 f0                	or     %esi,%eax
  80223c:	09 c2                	or     %eax,%edx
  80223e:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  802240:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  802243:	89 d0                	mov    %edx,%eax
  802245:	fc                   	cld    
  802246:	f3 ab                	rep stos %eax,%es:(%edi)
  802248:	eb 06                	jmp    802250 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80224a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80224d:	fc                   	cld    
  80224e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802250:	89 f8                	mov    %edi,%eax
  802252:	5b                   	pop    %ebx
  802253:	5e                   	pop    %esi
  802254:	5f                   	pop    %edi
  802255:	5d                   	pop    %ebp
  802256:	c3                   	ret    

00802257 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802257:	f3 0f 1e fb          	endbr32 
  80225b:	55                   	push   %ebp
  80225c:	89 e5                	mov    %esp,%ebp
  80225e:	57                   	push   %edi
  80225f:	56                   	push   %esi
  802260:	8b 45 08             	mov    0x8(%ebp),%eax
  802263:	8b 75 0c             	mov    0xc(%ebp),%esi
  802266:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802269:	39 c6                	cmp    %eax,%esi
  80226b:	73 32                	jae    80229f <memmove+0x48>
  80226d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802270:	39 c2                	cmp    %eax,%edx
  802272:	76 2b                	jbe    80229f <memmove+0x48>
		s += n;
		d += n;
  802274:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802277:	89 fe                	mov    %edi,%esi
  802279:	09 ce                	or     %ecx,%esi
  80227b:	09 d6                	or     %edx,%esi
  80227d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802283:	75 0e                	jne    802293 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  802285:	83 ef 04             	sub    $0x4,%edi
  802288:	8d 72 fc             	lea    -0x4(%edx),%esi
  80228b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80228e:	fd                   	std    
  80228f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802291:	eb 09                	jmp    80229c <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  802293:	83 ef 01             	sub    $0x1,%edi
  802296:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  802299:	fd                   	std    
  80229a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80229c:	fc                   	cld    
  80229d:	eb 1a                	jmp    8022b9 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80229f:	89 c2                	mov    %eax,%edx
  8022a1:	09 ca                	or     %ecx,%edx
  8022a3:	09 f2                	or     %esi,%edx
  8022a5:	f6 c2 03             	test   $0x3,%dl
  8022a8:	75 0a                	jne    8022b4 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8022aa:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8022ad:	89 c7                	mov    %eax,%edi
  8022af:	fc                   	cld    
  8022b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8022b2:	eb 05                	jmp    8022b9 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8022b4:	89 c7                	mov    %eax,%edi
  8022b6:	fc                   	cld    
  8022b7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8022b9:	5e                   	pop    %esi
  8022ba:	5f                   	pop    %edi
  8022bb:	5d                   	pop    %ebp
  8022bc:	c3                   	ret    

008022bd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8022bd:	f3 0f 1e fb          	endbr32 
  8022c1:	55                   	push   %ebp
  8022c2:	89 e5                	mov    %esp,%ebp
  8022c4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8022c7:	ff 75 10             	pushl  0x10(%ebp)
  8022ca:	ff 75 0c             	pushl  0xc(%ebp)
  8022cd:	ff 75 08             	pushl  0x8(%ebp)
  8022d0:	e8 82 ff ff ff       	call   802257 <memmove>
}
  8022d5:	c9                   	leave  
  8022d6:	c3                   	ret    

008022d7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8022d7:	f3 0f 1e fb          	endbr32 
  8022db:	55                   	push   %ebp
  8022dc:	89 e5                	mov    %esp,%ebp
  8022de:	56                   	push   %esi
  8022df:	53                   	push   %ebx
  8022e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022e6:	89 c6                	mov    %eax,%esi
  8022e8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8022eb:	39 f0                	cmp    %esi,%eax
  8022ed:	74 1c                	je     80230b <memcmp+0x34>
		if (*s1 != *s2)
  8022ef:	0f b6 08             	movzbl (%eax),%ecx
  8022f2:	0f b6 1a             	movzbl (%edx),%ebx
  8022f5:	38 d9                	cmp    %bl,%cl
  8022f7:	75 08                	jne    802301 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8022f9:	83 c0 01             	add    $0x1,%eax
  8022fc:	83 c2 01             	add    $0x1,%edx
  8022ff:	eb ea                	jmp    8022eb <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  802301:	0f b6 c1             	movzbl %cl,%eax
  802304:	0f b6 db             	movzbl %bl,%ebx
  802307:	29 d8                	sub    %ebx,%eax
  802309:	eb 05                	jmp    802310 <memcmp+0x39>
	}

	return 0;
  80230b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802310:	5b                   	pop    %ebx
  802311:	5e                   	pop    %esi
  802312:	5d                   	pop    %ebp
  802313:	c3                   	ret    

00802314 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802314:	f3 0f 1e fb          	endbr32 
  802318:	55                   	push   %ebp
  802319:	89 e5                	mov    %esp,%ebp
  80231b:	8b 45 08             	mov    0x8(%ebp),%eax
  80231e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  802321:	89 c2                	mov    %eax,%edx
  802323:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  802326:	39 d0                	cmp    %edx,%eax
  802328:	73 09                	jae    802333 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  80232a:	38 08                	cmp    %cl,(%eax)
  80232c:	74 05                	je     802333 <memfind+0x1f>
	for (; s < ends; s++)
  80232e:	83 c0 01             	add    $0x1,%eax
  802331:	eb f3                	jmp    802326 <memfind+0x12>
			break;
	return (void *) s;
}
  802333:	5d                   	pop    %ebp
  802334:	c3                   	ret    

00802335 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802335:	f3 0f 1e fb          	endbr32 
  802339:	55                   	push   %ebp
  80233a:	89 e5                	mov    %esp,%ebp
  80233c:	57                   	push   %edi
  80233d:	56                   	push   %esi
  80233e:	53                   	push   %ebx
  80233f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802342:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802345:	eb 03                	jmp    80234a <strtol+0x15>
		s++;
  802347:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  80234a:	0f b6 01             	movzbl (%ecx),%eax
  80234d:	3c 20                	cmp    $0x20,%al
  80234f:	74 f6                	je     802347 <strtol+0x12>
  802351:	3c 09                	cmp    $0x9,%al
  802353:	74 f2                	je     802347 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  802355:	3c 2b                	cmp    $0x2b,%al
  802357:	74 2a                	je     802383 <strtol+0x4e>
	int neg = 0;
  802359:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80235e:	3c 2d                	cmp    $0x2d,%al
  802360:	74 2b                	je     80238d <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802362:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  802368:	75 0f                	jne    802379 <strtol+0x44>
  80236a:	80 39 30             	cmpb   $0x30,(%ecx)
  80236d:	74 28                	je     802397 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80236f:	85 db                	test   %ebx,%ebx
  802371:	b8 0a 00 00 00       	mov    $0xa,%eax
  802376:	0f 44 d8             	cmove  %eax,%ebx
  802379:	b8 00 00 00 00       	mov    $0x0,%eax
  80237e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  802381:	eb 46                	jmp    8023c9 <strtol+0x94>
		s++;
  802383:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  802386:	bf 00 00 00 00       	mov    $0x0,%edi
  80238b:	eb d5                	jmp    802362 <strtol+0x2d>
		s++, neg = 1;
  80238d:	83 c1 01             	add    $0x1,%ecx
  802390:	bf 01 00 00 00       	mov    $0x1,%edi
  802395:	eb cb                	jmp    802362 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802397:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80239b:	74 0e                	je     8023ab <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80239d:	85 db                	test   %ebx,%ebx
  80239f:	75 d8                	jne    802379 <strtol+0x44>
		s++, base = 8;
  8023a1:	83 c1 01             	add    $0x1,%ecx
  8023a4:	bb 08 00 00 00       	mov    $0x8,%ebx
  8023a9:	eb ce                	jmp    802379 <strtol+0x44>
		s += 2, base = 16;
  8023ab:	83 c1 02             	add    $0x2,%ecx
  8023ae:	bb 10 00 00 00       	mov    $0x10,%ebx
  8023b3:	eb c4                	jmp    802379 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8023b5:	0f be d2             	movsbl %dl,%edx
  8023b8:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8023bb:	3b 55 10             	cmp    0x10(%ebp),%edx
  8023be:	7d 3a                	jge    8023fa <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8023c0:	83 c1 01             	add    $0x1,%ecx
  8023c3:	0f af 45 10          	imul   0x10(%ebp),%eax
  8023c7:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8023c9:	0f b6 11             	movzbl (%ecx),%edx
  8023cc:	8d 72 d0             	lea    -0x30(%edx),%esi
  8023cf:	89 f3                	mov    %esi,%ebx
  8023d1:	80 fb 09             	cmp    $0x9,%bl
  8023d4:	76 df                	jbe    8023b5 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  8023d6:	8d 72 9f             	lea    -0x61(%edx),%esi
  8023d9:	89 f3                	mov    %esi,%ebx
  8023db:	80 fb 19             	cmp    $0x19,%bl
  8023de:	77 08                	ja     8023e8 <strtol+0xb3>
			dig = *s - 'a' + 10;
  8023e0:	0f be d2             	movsbl %dl,%edx
  8023e3:	83 ea 57             	sub    $0x57,%edx
  8023e6:	eb d3                	jmp    8023bb <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  8023e8:	8d 72 bf             	lea    -0x41(%edx),%esi
  8023eb:	89 f3                	mov    %esi,%ebx
  8023ed:	80 fb 19             	cmp    $0x19,%bl
  8023f0:	77 08                	ja     8023fa <strtol+0xc5>
			dig = *s - 'A' + 10;
  8023f2:	0f be d2             	movsbl %dl,%edx
  8023f5:	83 ea 37             	sub    $0x37,%edx
  8023f8:	eb c1                	jmp    8023bb <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  8023fa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8023fe:	74 05                	je     802405 <strtol+0xd0>
		*endptr = (char *) s;
  802400:	8b 75 0c             	mov    0xc(%ebp),%esi
  802403:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  802405:	89 c2                	mov    %eax,%edx
  802407:	f7 da                	neg    %edx
  802409:	85 ff                	test   %edi,%edi
  80240b:	0f 45 c2             	cmovne %edx,%eax
}
  80240e:	5b                   	pop    %ebx
  80240f:	5e                   	pop    %esi
  802410:	5f                   	pop    %edi
  802411:	5d                   	pop    %ebp
  802412:	c3                   	ret    

00802413 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802413:	f3 0f 1e fb          	endbr32 
  802417:	55                   	push   %ebp
  802418:	89 e5                	mov    %esp,%ebp
  80241a:	57                   	push   %edi
  80241b:	56                   	push   %esi
  80241c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80241d:	b8 00 00 00 00       	mov    $0x0,%eax
  802422:	8b 55 08             	mov    0x8(%ebp),%edx
  802425:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802428:	89 c3                	mov    %eax,%ebx
  80242a:	89 c7                	mov    %eax,%edi
  80242c:	89 c6                	mov    %eax,%esi
  80242e:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  802430:	5b                   	pop    %ebx
  802431:	5e                   	pop    %esi
  802432:	5f                   	pop    %edi
  802433:	5d                   	pop    %ebp
  802434:	c3                   	ret    

00802435 <sys_cgetc>:

int
sys_cgetc(void)
{
  802435:	f3 0f 1e fb          	endbr32 
  802439:	55                   	push   %ebp
  80243a:	89 e5                	mov    %esp,%ebp
  80243c:	57                   	push   %edi
  80243d:	56                   	push   %esi
  80243e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80243f:	ba 00 00 00 00       	mov    $0x0,%edx
  802444:	b8 01 00 00 00       	mov    $0x1,%eax
  802449:	89 d1                	mov    %edx,%ecx
  80244b:	89 d3                	mov    %edx,%ebx
  80244d:	89 d7                	mov    %edx,%edi
  80244f:	89 d6                	mov    %edx,%esi
  802451:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802453:	5b                   	pop    %ebx
  802454:	5e                   	pop    %esi
  802455:	5f                   	pop    %edi
  802456:	5d                   	pop    %ebp
  802457:	c3                   	ret    

00802458 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802458:	f3 0f 1e fb          	endbr32 
  80245c:	55                   	push   %ebp
  80245d:	89 e5                	mov    %esp,%ebp
  80245f:	57                   	push   %edi
  802460:	56                   	push   %esi
  802461:	53                   	push   %ebx
	asm volatile("int %1\n"
  802462:	b9 00 00 00 00       	mov    $0x0,%ecx
  802467:	8b 55 08             	mov    0x8(%ebp),%edx
  80246a:	b8 03 00 00 00       	mov    $0x3,%eax
  80246f:	89 cb                	mov    %ecx,%ebx
  802471:	89 cf                	mov    %ecx,%edi
  802473:	89 ce                	mov    %ecx,%esi
  802475:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  802477:	5b                   	pop    %ebx
  802478:	5e                   	pop    %esi
  802479:	5f                   	pop    %edi
  80247a:	5d                   	pop    %ebp
  80247b:	c3                   	ret    

0080247c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80247c:	f3 0f 1e fb          	endbr32 
  802480:	55                   	push   %ebp
  802481:	89 e5                	mov    %esp,%ebp
  802483:	57                   	push   %edi
  802484:	56                   	push   %esi
  802485:	53                   	push   %ebx
	asm volatile("int %1\n"
  802486:	ba 00 00 00 00       	mov    $0x0,%edx
  80248b:	b8 02 00 00 00       	mov    $0x2,%eax
  802490:	89 d1                	mov    %edx,%ecx
  802492:	89 d3                	mov    %edx,%ebx
  802494:	89 d7                	mov    %edx,%edi
  802496:	89 d6                	mov    %edx,%esi
  802498:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80249a:	5b                   	pop    %ebx
  80249b:	5e                   	pop    %esi
  80249c:	5f                   	pop    %edi
  80249d:	5d                   	pop    %ebp
  80249e:	c3                   	ret    

0080249f <sys_yield>:

void
sys_yield(void)
{
  80249f:	f3 0f 1e fb          	endbr32 
  8024a3:	55                   	push   %ebp
  8024a4:	89 e5                	mov    %esp,%ebp
  8024a6:	57                   	push   %edi
  8024a7:	56                   	push   %esi
  8024a8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8024a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8024ae:	b8 0b 00 00 00       	mov    $0xb,%eax
  8024b3:	89 d1                	mov    %edx,%ecx
  8024b5:	89 d3                	mov    %edx,%ebx
  8024b7:	89 d7                	mov    %edx,%edi
  8024b9:	89 d6                	mov    %edx,%esi
  8024bb:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8024bd:	5b                   	pop    %ebx
  8024be:	5e                   	pop    %esi
  8024bf:	5f                   	pop    %edi
  8024c0:	5d                   	pop    %ebp
  8024c1:	c3                   	ret    

008024c2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8024c2:	f3 0f 1e fb          	endbr32 
  8024c6:	55                   	push   %ebp
  8024c7:	89 e5                	mov    %esp,%ebp
  8024c9:	57                   	push   %edi
  8024ca:	56                   	push   %esi
  8024cb:	53                   	push   %ebx
	asm volatile("int %1\n"
  8024cc:	be 00 00 00 00       	mov    $0x0,%esi
  8024d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8024d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024d7:	b8 04 00 00 00       	mov    $0x4,%eax
  8024dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8024df:	89 f7                	mov    %esi,%edi
  8024e1:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8024e3:	5b                   	pop    %ebx
  8024e4:	5e                   	pop    %esi
  8024e5:	5f                   	pop    %edi
  8024e6:	5d                   	pop    %ebp
  8024e7:	c3                   	ret    

008024e8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8024e8:	f3 0f 1e fb          	endbr32 
  8024ec:	55                   	push   %ebp
  8024ed:	89 e5                	mov    %esp,%ebp
  8024ef:	57                   	push   %edi
  8024f0:	56                   	push   %esi
  8024f1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8024f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8024f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024f8:	b8 05 00 00 00       	mov    $0x5,%eax
  8024fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802500:	8b 7d 14             	mov    0x14(%ebp),%edi
  802503:	8b 75 18             	mov    0x18(%ebp),%esi
  802506:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802508:	5b                   	pop    %ebx
  802509:	5e                   	pop    %esi
  80250a:	5f                   	pop    %edi
  80250b:	5d                   	pop    %ebp
  80250c:	c3                   	ret    

0080250d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80250d:	f3 0f 1e fb          	endbr32 
  802511:	55                   	push   %ebp
  802512:	89 e5                	mov    %esp,%ebp
  802514:	57                   	push   %edi
  802515:	56                   	push   %esi
  802516:	53                   	push   %ebx
	asm volatile("int %1\n"
  802517:	bb 00 00 00 00       	mov    $0x0,%ebx
  80251c:	8b 55 08             	mov    0x8(%ebp),%edx
  80251f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802522:	b8 06 00 00 00       	mov    $0x6,%eax
  802527:	89 df                	mov    %ebx,%edi
  802529:	89 de                	mov    %ebx,%esi
  80252b:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80252d:	5b                   	pop    %ebx
  80252e:	5e                   	pop    %esi
  80252f:	5f                   	pop    %edi
  802530:	5d                   	pop    %ebp
  802531:	c3                   	ret    

00802532 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  802532:	f3 0f 1e fb          	endbr32 
  802536:	55                   	push   %ebp
  802537:	89 e5                	mov    %esp,%ebp
  802539:	57                   	push   %edi
  80253a:	56                   	push   %esi
  80253b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80253c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802541:	8b 55 08             	mov    0x8(%ebp),%edx
  802544:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802547:	b8 08 00 00 00       	mov    $0x8,%eax
  80254c:	89 df                	mov    %ebx,%edi
  80254e:	89 de                	mov    %ebx,%esi
  802550:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802552:	5b                   	pop    %ebx
  802553:	5e                   	pop    %esi
  802554:	5f                   	pop    %edi
  802555:	5d                   	pop    %ebp
  802556:	c3                   	ret    

00802557 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802557:	f3 0f 1e fb          	endbr32 
  80255b:	55                   	push   %ebp
  80255c:	89 e5                	mov    %esp,%ebp
  80255e:	57                   	push   %edi
  80255f:	56                   	push   %esi
  802560:	53                   	push   %ebx
	asm volatile("int %1\n"
  802561:	bb 00 00 00 00       	mov    $0x0,%ebx
  802566:	8b 55 08             	mov    0x8(%ebp),%edx
  802569:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80256c:	b8 09 00 00 00       	mov    $0x9,%eax
  802571:	89 df                	mov    %ebx,%edi
  802573:	89 de                	mov    %ebx,%esi
  802575:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802577:	5b                   	pop    %ebx
  802578:	5e                   	pop    %esi
  802579:	5f                   	pop    %edi
  80257a:	5d                   	pop    %ebp
  80257b:	c3                   	ret    

0080257c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80257c:	f3 0f 1e fb          	endbr32 
  802580:	55                   	push   %ebp
  802581:	89 e5                	mov    %esp,%ebp
  802583:	57                   	push   %edi
  802584:	56                   	push   %esi
  802585:	53                   	push   %ebx
	asm volatile("int %1\n"
  802586:	bb 00 00 00 00       	mov    $0x0,%ebx
  80258b:	8b 55 08             	mov    0x8(%ebp),%edx
  80258e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802591:	b8 0a 00 00 00       	mov    $0xa,%eax
  802596:	89 df                	mov    %ebx,%edi
  802598:	89 de                	mov    %ebx,%esi
  80259a:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80259c:	5b                   	pop    %ebx
  80259d:	5e                   	pop    %esi
  80259e:	5f                   	pop    %edi
  80259f:	5d                   	pop    %ebp
  8025a0:	c3                   	ret    

008025a1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8025a1:	f3 0f 1e fb          	endbr32 
  8025a5:	55                   	push   %ebp
  8025a6:	89 e5                	mov    %esp,%ebp
  8025a8:	57                   	push   %edi
  8025a9:	56                   	push   %esi
  8025aa:	53                   	push   %ebx
	asm volatile("int %1\n"
  8025ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8025ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025b1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8025b6:	be 00 00 00 00       	mov    $0x0,%esi
  8025bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025be:	8b 7d 14             	mov    0x14(%ebp),%edi
  8025c1:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8025c3:	5b                   	pop    %ebx
  8025c4:	5e                   	pop    %esi
  8025c5:	5f                   	pop    %edi
  8025c6:	5d                   	pop    %ebp
  8025c7:	c3                   	ret    

008025c8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8025c8:	f3 0f 1e fb          	endbr32 
  8025cc:	55                   	push   %ebp
  8025cd:	89 e5                	mov    %esp,%ebp
  8025cf:	57                   	push   %edi
  8025d0:	56                   	push   %esi
  8025d1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8025d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8025d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8025da:	b8 0d 00 00 00       	mov    $0xd,%eax
  8025df:	89 cb                	mov    %ecx,%ebx
  8025e1:	89 cf                	mov    %ecx,%edi
  8025e3:	89 ce                	mov    %ecx,%esi
  8025e5:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8025e7:	5b                   	pop    %ebx
  8025e8:	5e                   	pop    %esi
  8025e9:	5f                   	pop    %edi
  8025ea:	5d                   	pop    %ebp
  8025eb:	c3                   	ret    

008025ec <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8025ec:	f3 0f 1e fb          	endbr32 
  8025f0:	55                   	push   %ebp
  8025f1:	89 e5                	mov    %esp,%ebp
  8025f3:	57                   	push   %edi
  8025f4:	56                   	push   %esi
  8025f5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8025f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8025fb:	b8 0e 00 00 00       	mov    $0xe,%eax
  802600:	89 d1                	mov    %edx,%ecx
  802602:	89 d3                	mov    %edx,%ebx
  802604:	89 d7                	mov    %edx,%edi
  802606:	89 d6                	mov    %edx,%esi
  802608:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80260a:	5b                   	pop    %ebx
  80260b:	5e                   	pop    %esi
  80260c:	5f                   	pop    %edi
  80260d:	5d                   	pop    %ebp
  80260e:	c3                   	ret    

0080260f <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  80260f:	f3 0f 1e fb          	endbr32 
  802613:	55                   	push   %ebp
  802614:	89 e5                	mov    %esp,%ebp
  802616:	57                   	push   %edi
  802617:	56                   	push   %esi
  802618:	53                   	push   %ebx
	asm volatile("int %1\n"
  802619:	bb 00 00 00 00       	mov    $0x0,%ebx
  80261e:	8b 55 08             	mov    0x8(%ebp),%edx
  802621:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802624:	b8 0f 00 00 00       	mov    $0xf,%eax
  802629:	89 df                	mov    %ebx,%edi
  80262b:	89 de                	mov    %ebx,%esi
  80262d:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  80262f:	5b                   	pop    %ebx
  802630:	5e                   	pop    %esi
  802631:	5f                   	pop    %edi
  802632:	5d                   	pop    %ebp
  802633:	c3                   	ret    

00802634 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  802634:	f3 0f 1e fb          	endbr32 
  802638:	55                   	push   %ebp
  802639:	89 e5                	mov    %esp,%ebp
  80263b:	57                   	push   %edi
  80263c:	56                   	push   %esi
  80263d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80263e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802643:	8b 55 08             	mov    0x8(%ebp),%edx
  802646:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802649:	b8 10 00 00 00       	mov    $0x10,%eax
  80264e:	89 df                	mov    %ebx,%edi
  802650:	89 de                	mov    %ebx,%esi
  802652:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  802654:	5b                   	pop    %ebx
  802655:	5e                   	pop    %esi
  802656:	5f                   	pop    %edi
  802657:	5d                   	pop    %ebp
  802658:	c3                   	ret    

00802659 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802659:	f3 0f 1e fb          	endbr32 
  80265d:	55                   	push   %ebp
  80265e:	89 e5                	mov    %esp,%ebp
  802660:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802663:	83 3d 14 a0 80 00 00 	cmpl   $0x0,0x80a014
  80266a:	74 0a                	je     802676 <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80266c:	8b 45 08             	mov    0x8(%ebp),%eax
  80266f:	a3 14 a0 80 00       	mov    %eax,0x80a014

}
  802674:	c9                   	leave  
  802675:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  802676:	83 ec 04             	sub    $0x4,%esp
  802679:	6a 07                	push   $0x7
  80267b:	68 00 f0 bf ee       	push   $0xeebff000
  802680:	6a 00                	push   $0x0
  802682:	e8 3b fe ff ff       	call   8024c2 <sys_page_alloc>
  802687:	83 c4 10             	add    $0x10,%esp
  80268a:	85 c0                	test   %eax,%eax
  80268c:	78 2a                	js     8026b8 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  80268e:	83 ec 08             	sub    $0x8,%esp
  802691:	68 cc 26 80 00       	push   $0x8026cc
  802696:	6a 00                	push   $0x0
  802698:	e8 df fe ff ff       	call   80257c <sys_env_set_pgfault_upcall>
  80269d:	83 c4 10             	add    $0x10,%esp
  8026a0:	85 c0                	test   %eax,%eax
  8026a2:	79 c8                	jns    80266c <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  8026a4:	83 ec 04             	sub    $0x4,%esp
  8026a7:	68 4c 45 80 00       	push   $0x80454c
  8026ac:	6a 2c                	push   $0x2c
  8026ae:	68 82 45 80 00       	push   $0x804582
  8026b3:	e8 b0 f2 ff ff       	call   801968 <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  8026b8:	83 ec 04             	sub    $0x4,%esp
  8026bb:	68 20 45 80 00       	push   $0x804520
  8026c0:	6a 22                	push   $0x22
  8026c2:	68 82 45 80 00       	push   $0x804582
  8026c7:	e8 9c f2 ff ff       	call   801968 <_panic>

008026cc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8026cc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8026cd:	a1 14 a0 80 00       	mov    0x80a014,%eax
	call *%eax   			// 间接寻址
  8026d2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8026d4:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  8026d7:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  8026db:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  8026e0:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  8026e4:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  8026e6:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  8026e9:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  8026ea:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  8026ed:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  8026ee:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  8026ef:	c3                   	ret    

008026f0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8026f0:	f3 0f 1e fb          	endbr32 
  8026f4:	55                   	push   %ebp
  8026f5:	89 e5                	mov    %esp,%ebp
  8026f7:	56                   	push   %esi
  8026f8:	53                   	push   %ebx
  8026f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8026fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  802702:	85 c0                	test   %eax,%eax
  802704:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802709:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  80270c:	83 ec 0c             	sub    $0xc,%esp
  80270f:	50                   	push   %eax
  802710:	e8 b3 fe ff ff       	call   8025c8 <sys_ipc_recv>
  802715:	83 c4 10             	add    $0x10,%esp
  802718:	85 c0                	test   %eax,%eax
  80271a:	75 2b                	jne    802747 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  80271c:	85 f6                	test   %esi,%esi
  80271e:	74 0a                	je     80272a <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  802720:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802725:	8b 40 74             	mov    0x74(%eax),%eax
  802728:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  80272a:	85 db                	test   %ebx,%ebx
  80272c:	74 0a                	je     802738 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  80272e:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802733:	8b 40 78             	mov    0x78(%eax),%eax
  802736:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  802738:	a1 10 a0 80 00       	mov    0x80a010,%eax
  80273d:	8b 40 70             	mov    0x70(%eax),%eax
}
  802740:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802743:	5b                   	pop    %ebx
  802744:	5e                   	pop    %esi
  802745:	5d                   	pop    %ebp
  802746:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  802747:	85 f6                	test   %esi,%esi
  802749:	74 06                	je     802751 <ipc_recv+0x61>
  80274b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  802751:	85 db                	test   %ebx,%ebx
  802753:	74 eb                	je     802740 <ipc_recv+0x50>
  802755:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80275b:	eb e3                	jmp    802740 <ipc_recv+0x50>

0080275d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80275d:	f3 0f 1e fb          	endbr32 
  802761:	55                   	push   %ebp
  802762:	89 e5                	mov    %esp,%ebp
  802764:	57                   	push   %edi
  802765:	56                   	push   %esi
  802766:	53                   	push   %ebx
  802767:	83 ec 0c             	sub    $0xc,%esp
  80276a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80276d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802770:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  802773:	85 db                	test   %ebx,%ebx
  802775:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80277a:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  80277d:	ff 75 14             	pushl  0x14(%ebp)
  802780:	53                   	push   %ebx
  802781:	56                   	push   %esi
  802782:	57                   	push   %edi
  802783:	e8 19 fe ff ff       	call   8025a1 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  802788:	83 c4 10             	add    $0x10,%esp
  80278b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80278e:	75 07                	jne    802797 <ipc_send+0x3a>
			sys_yield();
  802790:	e8 0a fd ff ff       	call   80249f <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802795:	eb e6                	jmp    80277d <ipc_send+0x20>
		}
		else if (ret == 0)
  802797:	85 c0                	test   %eax,%eax
  802799:	75 08                	jne    8027a3 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  80279b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80279e:	5b                   	pop    %ebx
  80279f:	5e                   	pop    %esi
  8027a0:	5f                   	pop    %edi
  8027a1:	5d                   	pop    %ebp
  8027a2:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  8027a3:	50                   	push   %eax
  8027a4:	68 90 45 80 00       	push   $0x804590
  8027a9:	6a 48                	push   $0x48
  8027ab:	68 9e 45 80 00       	push   $0x80459e
  8027b0:	e8 b3 f1 ff ff       	call   801968 <_panic>

008027b5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8027b5:	f3 0f 1e fb          	endbr32 
  8027b9:	55                   	push   %ebp
  8027ba:	89 e5                	mov    %esp,%ebp
  8027bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8027bf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8027c4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8027c7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8027cd:	8b 52 50             	mov    0x50(%edx),%edx
  8027d0:	39 ca                	cmp    %ecx,%edx
  8027d2:	74 11                	je     8027e5 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8027d4:	83 c0 01             	add    $0x1,%eax
  8027d7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8027dc:	75 e6                	jne    8027c4 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8027de:	b8 00 00 00 00       	mov    $0x0,%eax
  8027e3:	eb 0b                	jmp    8027f0 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8027e5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8027e8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8027ed:	8b 40 48             	mov    0x48(%eax),%eax
}
  8027f0:	5d                   	pop    %ebp
  8027f1:	c3                   	ret    

008027f2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8027f2:	f3 0f 1e fb          	endbr32 
  8027f6:	55                   	push   %ebp
  8027f7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8027f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8027fc:	05 00 00 00 30       	add    $0x30000000,%eax
  802801:	c1 e8 0c             	shr    $0xc,%eax
}
  802804:	5d                   	pop    %ebp
  802805:	c3                   	ret    

00802806 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802806:	f3 0f 1e fb          	endbr32 
  80280a:	55                   	push   %ebp
  80280b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80280d:	8b 45 08             	mov    0x8(%ebp),%eax
  802810:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  802815:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80281a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80281f:	5d                   	pop    %ebp
  802820:	c3                   	ret    

00802821 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802821:	f3 0f 1e fb          	endbr32 
  802825:	55                   	push   %ebp
  802826:	89 e5                	mov    %esp,%ebp
  802828:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80282d:	89 c2                	mov    %eax,%edx
  80282f:	c1 ea 16             	shr    $0x16,%edx
  802832:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802839:	f6 c2 01             	test   $0x1,%dl
  80283c:	74 2d                	je     80286b <fd_alloc+0x4a>
  80283e:	89 c2                	mov    %eax,%edx
  802840:	c1 ea 0c             	shr    $0xc,%edx
  802843:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80284a:	f6 c2 01             	test   $0x1,%dl
  80284d:	74 1c                	je     80286b <fd_alloc+0x4a>
  80284f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  802854:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802859:	75 d2                	jne    80282d <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  80285b:	8b 45 08             	mov    0x8(%ebp),%eax
  80285e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  802864:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  802869:	eb 0a                	jmp    802875 <fd_alloc+0x54>
			*fd_store = fd;
  80286b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80286e:	89 01                	mov    %eax,(%ecx)
			return 0;
  802870:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802875:	5d                   	pop    %ebp
  802876:	c3                   	ret    

00802877 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802877:	f3 0f 1e fb          	endbr32 
  80287b:	55                   	push   %ebp
  80287c:	89 e5                	mov    %esp,%ebp
  80287e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802881:	83 f8 1f             	cmp    $0x1f,%eax
  802884:	77 30                	ja     8028b6 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802886:	c1 e0 0c             	shl    $0xc,%eax
  802889:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80288e:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  802894:	f6 c2 01             	test   $0x1,%dl
  802897:	74 24                	je     8028bd <fd_lookup+0x46>
  802899:	89 c2                	mov    %eax,%edx
  80289b:	c1 ea 0c             	shr    $0xc,%edx
  80289e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8028a5:	f6 c2 01             	test   $0x1,%dl
  8028a8:	74 1a                	je     8028c4 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8028aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8028ad:	89 02                	mov    %eax,(%edx)
	return 0;
  8028af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8028b4:	5d                   	pop    %ebp
  8028b5:	c3                   	ret    
		return -E_INVAL;
  8028b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8028bb:	eb f7                	jmp    8028b4 <fd_lookup+0x3d>
		return -E_INVAL;
  8028bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8028c2:	eb f0                	jmp    8028b4 <fd_lookup+0x3d>
  8028c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8028c9:	eb e9                	jmp    8028b4 <fd_lookup+0x3d>

008028cb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8028cb:	f3 0f 1e fb          	endbr32 
  8028cf:	55                   	push   %ebp
  8028d0:	89 e5                	mov    %esp,%ebp
  8028d2:	83 ec 08             	sub    $0x8,%esp
  8028d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8028d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8028dd:	b8 80 90 80 00       	mov    $0x809080,%eax
		if (devtab[i]->dev_id == dev_id) {
  8028e2:	39 08                	cmp    %ecx,(%eax)
  8028e4:	74 38                	je     80291e <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8028e6:	83 c2 01             	add    $0x1,%edx
  8028e9:	8b 04 95 24 46 80 00 	mov    0x804624(,%edx,4),%eax
  8028f0:	85 c0                	test   %eax,%eax
  8028f2:	75 ee                	jne    8028e2 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8028f4:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8028f9:	8b 40 48             	mov    0x48(%eax),%eax
  8028fc:	83 ec 04             	sub    $0x4,%esp
  8028ff:	51                   	push   %ecx
  802900:	50                   	push   %eax
  802901:	68 a8 45 80 00       	push   $0x8045a8
  802906:	e8 44 f1 ff ff       	call   801a4f <cprintf>
	*dev = 0;
  80290b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80290e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802914:	83 c4 10             	add    $0x10,%esp
  802917:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80291c:	c9                   	leave  
  80291d:	c3                   	ret    
			*dev = devtab[i];
  80291e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802921:	89 01                	mov    %eax,(%ecx)
			return 0;
  802923:	b8 00 00 00 00       	mov    $0x0,%eax
  802928:	eb f2                	jmp    80291c <dev_lookup+0x51>

0080292a <fd_close>:
{
  80292a:	f3 0f 1e fb          	endbr32 
  80292e:	55                   	push   %ebp
  80292f:	89 e5                	mov    %esp,%ebp
  802931:	57                   	push   %edi
  802932:	56                   	push   %esi
  802933:	53                   	push   %ebx
  802934:	83 ec 24             	sub    $0x24,%esp
  802937:	8b 75 08             	mov    0x8(%ebp),%esi
  80293a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80293d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802940:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802941:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802947:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80294a:	50                   	push   %eax
  80294b:	e8 27 ff ff ff       	call   802877 <fd_lookup>
  802950:	89 c3                	mov    %eax,%ebx
  802952:	83 c4 10             	add    $0x10,%esp
  802955:	85 c0                	test   %eax,%eax
  802957:	78 05                	js     80295e <fd_close+0x34>
	    || fd != fd2)
  802959:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80295c:	74 16                	je     802974 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80295e:	89 f8                	mov    %edi,%eax
  802960:	84 c0                	test   %al,%al
  802962:	b8 00 00 00 00       	mov    $0x0,%eax
  802967:	0f 44 d8             	cmove  %eax,%ebx
}
  80296a:	89 d8                	mov    %ebx,%eax
  80296c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80296f:	5b                   	pop    %ebx
  802970:	5e                   	pop    %esi
  802971:	5f                   	pop    %edi
  802972:	5d                   	pop    %ebp
  802973:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802974:	83 ec 08             	sub    $0x8,%esp
  802977:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80297a:	50                   	push   %eax
  80297b:	ff 36                	pushl  (%esi)
  80297d:	e8 49 ff ff ff       	call   8028cb <dev_lookup>
  802982:	89 c3                	mov    %eax,%ebx
  802984:	83 c4 10             	add    $0x10,%esp
  802987:	85 c0                	test   %eax,%eax
  802989:	78 1a                	js     8029a5 <fd_close+0x7b>
		if (dev->dev_close)
  80298b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80298e:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  802991:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  802996:	85 c0                	test   %eax,%eax
  802998:	74 0b                	je     8029a5 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80299a:	83 ec 0c             	sub    $0xc,%esp
  80299d:	56                   	push   %esi
  80299e:	ff d0                	call   *%eax
  8029a0:	89 c3                	mov    %eax,%ebx
  8029a2:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8029a5:	83 ec 08             	sub    $0x8,%esp
  8029a8:	56                   	push   %esi
  8029a9:	6a 00                	push   $0x0
  8029ab:	e8 5d fb ff ff       	call   80250d <sys_page_unmap>
	return r;
  8029b0:	83 c4 10             	add    $0x10,%esp
  8029b3:	eb b5                	jmp    80296a <fd_close+0x40>

008029b5 <close>:

int
close(int fdnum)
{
  8029b5:	f3 0f 1e fb          	endbr32 
  8029b9:	55                   	push   %ebp
  8029ba:	89 e5                	mov    %esp,%ebp
  8029bc:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8029bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029c2:	50                   	push   %eax
  8029c3:	ff 75 08             	pushl  0x8(%ebp)
  8029c6:	e8 ac fe ff ff       	call   802877 <fd_lookup>
  8029cb:	83 c4 10             	add    $0x10,%esp
  8029ce:	85 c0                	test   %eax,%eax
  8029d0:	79 02                	jns    8029d4 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8029d2:	c9                   	leave  
  8029d3:	c3                   	ret    
		return fd_close(fd, 1);
  8029d4:	83 ec 08             	sub    $0x8,%esp
  8029d7:	6a 01                	push   $0x1
  8029d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8029dc:	e8 49 ff ff ff       	call   80292a <fd_close>
  8029e1:	83 c4 10             	add    $0x10,%esp
  8029e4:	eb ec                	jmp    8029d2 <close+0x1d>

008029e6 <close_all>:

void
close_all(void)
{
  8029e6:	f3 0f 1e fb          	endbr32 
  8029ea:	55                   	push   %ebp
  8029eb:	89 e5                	mov    %esp,%ebp
  8029ed:	53                   	push   %ebx
  8029ee:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8029f1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8029f6:	83 ec 0c             	sub    $0xc,%esp
  8029f9:	53                   	push   %ebx
  8029fa:	e8 b6 ff ff ff       	call   8029b5 <close>
	for (i = 0; i < MAXFD; i++)
  8029ff:	83 c3 01             	add    $0x1,%ebx
  802a02:	83 c4 10             	add    $0x10,%esp
  802a05:	83 fb 20             	cmp    $0x20,%ebx
  802a08:	75 ec                	jne    8029f6 <close_all+0x10>
}
  802a0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802a0d:	c9                   	leave  
  802a0e:	c3                   	ret    

00802a0f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802a0f:	f3 0f 1e fb          	endbr32 
  802a13:	55                   	push   %ebp
  802a14:	89 e5                	mov    %esp,%ebp
  802a16:	57                   	push   %edi
  802a17:	56                   	push   %esi
  802a18:	53                   	push   %ebx
  802a19:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802a1c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802a1f:	50                   	push   %eax
  802a20:	ff 75 08             	pushl  0x8(%ebp)
  802a23:	e8 4f fe ff ff       	call   802877 <fd_lookup>
  802a28:	89 c3                	mov    %eax,%ebx
  802a2a:	83 c4 10             	add    $0x10,%esp
  802a2d:	85 c0                	test   %eax,%eax
  802a2f:	0f 88 81 00 00 00    	js     802ab6 <dup+0xa7>
		return r;
	close(newfdnum);
  802a35:	83 ec 0c             	sub    $0xc,%esp
  802a38:	ff 75 0c             	pushl  0xc(%ebp)
  802a3b:	e8 75 ff ff ff       	call   8029b5 <close>

	newfd = INDEX2FD(newfdnum);
  802a40:	8b 75 0c             	mov    0xc(%ebp),%esi
  802a43:	c1 e6 0c             	shl    $0xc,%esi
  802a46:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  802a4c:	83 c4 04             	add    $0x4,%esp
  802a4f:	ff 75 e4             	pushl  -0x1c(%ebp)
  802a52:	e8 af fd ff ff       	call   802806 <fd2data>
  802a57:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802a59:	89 34 24             	mov    %esi,(%esp)
  802a5c:	e8 a5 fd ff ff       	call   802806 <fd2data>
  802a61:	83 c4 10             	add    $0x10,%esp
  802a64:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802a66:	89 d8                	mov    %ebx,%eax
  802a68:	c1 e8 16             	shr    $0x16,%eax
  802a6b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802a72:	a8 01                	test   $0x1,%al
  802a74:	74 11                	je     802a87 <dup+0x78>
  802a76:	89 d8                	mov    %ebx,%eax
  802a78:	c1 e8 0c             	shr    $0xc,%eax
  802a7b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802a82:	f6 c2 01             	test   $0x1,%dl
  802a85:	75 39                	jne    802ac0 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802a87:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802a8a:	89 d0                	mov    %edx,%eax
  802a8c:	c1 e8 0c             	shr    $0xc,%eax
  802a8f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802a96:	83 ec 0c             	sub    $0xc,%esp
  802a99:	25 07 0e 00 00       	and    $0xe07,%eax
  802a9e:	50                   	push   %eax
  802a9f:	56                   	push   %esi
  802aa0:	6a 00                	push   $0x0
  802aa2:	52                   	push   %edx
  802aa3:	6a 00                	push   $0x0
  802aa5:	e8 3e fa ff ff       	call   8024e8 <sys_page_map>
  802aaa:	89 c3                	mov    %eax,%ebx
  802aac:	83 c4 20             	add    $0x20,%esp
  802aaf:	85 c0                	test   %eax,%eax
  802ab1:	78 31                	js     802ae4 <dup+0xd5>
		goto err;

	return newfdnum;
  802ab3:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  802ab6:	89 d8                	mov    %ebx,%eax
  802ab8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802abb:	5b                   	pop    %ebx
  802abc:	5e                   	pop    %esi
  802abd:	5f                   	pop    %edi
  802abe:	5d                   	pop    %ebp
  802abf:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802ac0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802ac7:	83 ec 0c             	sub    $0xc,%esp
  802aca:	25 07 0e 00 00       	and    $0xe07,%eax
  802acf:	50                   	push   %eax
  802ad0:	57                   	push   %edi
  802ad1:	6a 00                	push   $0x0
  802ad3:	53                   	push   %ebx
  802ad4:	6a 00                	push   $0x0
  802ad6:	e8 0d fa ff ff       	call   8024e8 <sys_page_map>
  802adb:	89 c3                	mov    %eax,%ebx
  802add:	83 c4 20             	add    $0x20,%esp
  802ae0:	85 c0                	test   %eax,%eax
  802ae2:	79 a3                	jns    802a87 <dup+0x78>
	sys_page_unmap(0, newfd);
  802ae4:	83 ec 08             	sub    $0x8,%esp
  802ae7:	56                   	push   %esi
  802ae8:	6a 00                	push   $0x0
  802aea:	e8 1e fa ff ff       	call   80250d <sys_page_unmap>
	sys_page_unmap(0, nva);
  802aef:	83 c4 08             	add    $0x8,%esp
  802af2:	57                   	push   %edi
  802af3:	6a 00                	push   $0x0
  802af5:	e8 13 fa ff ff       	call   80250d <sys_page_unmap>
	return r;
  802afa:	83 c4 10             	add    $0x10,%esp
  802afd:	eb b7                	jmp    802ab6 <dup+0xa7>

00802aff <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802aff:	f3 0f 1e fb          	endbr32 
  802b03:	55                   	push   %ebp
  802b04:	89 e5                	mov    %esp,%ebp
  802b06:	53                   	push   %ebx
  802b07:	83 ec 1c             	sub    $0x1c,%esp
  802b0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802b0d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802b10:	50                   	push   %eax
  802b11:	53                   	push   %ebx
  802b12:	e8 60 fd ff ff       	call   802877 <fd_lookup>
  802b17:	83 c4 10             	add    $0x10,%esp
  802b1a:	85 c0                	test   %eax,%eax
  802b1c:	78 3f                	js     802b5d <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802b1e:	83 ec 08             	sub    $0x8,%esp
  802b21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b24:	50                   	push   %eax
  802b25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b28:	ff 30                	pushl  (%eax)
  802b2a:	e8 9c fd ff ff       	call   8028cb <dev_lookup>
  802b2f:	83 c4 10             	add    $0x10,%esp
  802b32:	85 c0                	test   %eax,%eax
  802b34:	78 27                	js     802b5d <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802b36:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802b39:	8b 42 08             	mov    0x8(%edx),%eax
  802b3c:	83 e0 03             	and    $0x3,%eax
  802b3f:	83 f8 01             	cmp    $0x1,%eax
  802b42:	74 1e                	je     802b62 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  802b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b47:	8b 40 08             	mov    0x8(%eax),%eax
  802b4a:	85 c0                	test   %eax,%eax
  802b4c:	74 35                	je     802b83 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802b4e:	83 ec 04             	sub    $0x4,%esp
  802b51:	ff 75 10             	pushl  0x10(%ebp)
  802b54:	ff 75 0c             	pushl  0xc(%ebp)
  802b57:	52                   	push   %edx
  802b58:	ff d0                	call   *%eax
  802b5a:	83 c4 10             	add    $0x10,%esp
}
  802b5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b60:	c9                   	leave  
  802b61:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802b62:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802b67:	8b 40 48             	mov    0x48(%eax),%eax
  802b6a:	83 ec 04             	sub    $0x4,%esp
  802b6d:	53                   	push   %ebx
  802b6e:	50                   	push   %eax
  802b6f:	68 e9 45 80 00       	push   $0x8045e9
  802b74:	e8 d6 ee ff ff       	call   801a4f <cprintf>
		return -E_INVAL;
  802b79:	83 c4 10             	add    $0x10,%esp
  802b7c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802b81:	eb da                	jmp    802b5d <read+0x5e>
		return -E_NOT_SUPP;
  802b83:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802b88:	eb d3                	jmp    802b5d <read+0x5e>

00802b8a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802b8a:	f3 0f 1e fb          	endbr32 
  802b8e:	55                   	push   %ebp
  802b8f:	89 e5                	mov    %esp,%ebp
  802b91:	57                   	push   %edi
  802b92:	56                   	push   %esi
  802b93:	53                   	push   %ebx
  802b94:	83 ec 0c             	sub    $0xc,%esp
  802b97:	8b 7d 08             	mov    0x8(%ebp),%edi
  802b9a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802b9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802ba2:	eb 02                	jmp    802ba6 <readn+0x1c>
  802ba4:	01 c3                	add    %eax,%ebx
  802ba6:	39 f3                	cmp    %esi,%ebx
  802ba8:	73 21                	jae    802bcb <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802baa:	83 ec 04             	sub    $0x4,%esp
  802bad:	89 f0                	mov    %esi,%eax
  802baf:	29 d8                	sub    %ebx,%eax
  802bb1:	50                   	push   %eax
  802bb2:	89 d8                	mov    %ebx,%eax
  802bb4:	03 45 0c             	add    0xc(%ebp),%eax
  802bb7:	50                   	push   %eax
  802bb8:	57                   	push   %edi
  802bb9:	e8 41 ff ff ff       	call   802aff <read>
		if (m < 0)
  802bbe:	83 c4 10             	add    $0x10,%esp
  802bc1:	85 c0                	test   %eax,%eax
  802bc3:	78 04                	js     802bc9 <readn+0x3f>
			return m;
		if (m == 0)
  802bc5:	75 dd                	jne    802ba4 <readn+0x1a>
  802bc7:	eb 02                	jmp    802bcb <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802bc9:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  802bcb:	89 d8                	mov    %ebx,%eax
  802bcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802bd0:	5b                   	pop    %ebx
  802bd1:	5e                   	pop    %esi
  802bd2:	5f                   	pop    %edi
  802bd3:	5d                   	pop    %ebp
  802bd4:	c3                   	ret    

00802bd5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802bd5:	f3 0f 1e fb          	endbr32 
  802bd9:	55                   	push   %ebp
  802bda:	89 e5                	mov    %esp,%ebp
  802bdc:	53                   	push   %ebx
  802bdd:	83 ec 1c             	sub    $0x1c,%esp
  802be0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802be3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802be6:	50                   	push   %eax
  802be7:	53                   	push   %ebx
  802be8:	e8 8a fc ff ff       	call   802877 <fd_lookup>
  802bed:	83 c4 10             	add    $0x10,%esp
  802bf0:	85 c0                	test   %eax,%eax
  802bf2:	78 3a                	js     802c2e <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802bf4:	83 ec 08             	sub    $0x8,%esp
  802bf7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802bfa:	50                   	push   %eax
  802bfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bfe:	ff 30                	pushl  (%eax)
  802c00:	e8 c6 fc ff ff       	call   8028cb <dev_lookup>
  802c05:	83 c4 10             	add    $0x10,%esp
  802c08:	85 c0                	test   %eax,%eax
  802c0a:	78 22                	js     802c2e <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802c0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c0f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802c13:	74 1e                	je     802c33 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802c15:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802c18:	8b 52 0c             	mov    0xc(%edx),%edx
  802c1b:	85 d2                	test   %edx,%edx
  802c1d:	74 35                	je     802c54 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802c1f:	83 ec 04             	sub    $0x4,%esp
  802c22:	ff 75 10             	pushl  0x10(%ebp)
  802c25:	ff 75 0c             	pushl  0xc(%ebp)
  802c28:	50                   	push   %eax
  802c29:	ff d2                	call   *%edx
  802c2b:	83 c4 10             	add    $0x10,%esp
}
  802c2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c31:	c9                   	leave  
  802c32:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802c33:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802c38:	8b 40 48             	mov    0x48(%eax),%eax
  802c3b:	83 ec 04             	sub    $0x4,%esp
  802c3e:	53                   	push   %ebx
  802c3f:	50                   	push   %eax
  802c40:	68 05 46 80 00       	push   $0x804605
  802c45:	e8 05 ee ff ff       	call   801a4f <cprintf>
		return -E_INVAL;
  802c4a:	83 c4 10             	add    $0x10,%esp
  802c4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802c52:	eb da                	jmp    802c2e <write+0x59>
		return -E_NOT_SUPP;
  802c54:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802c59:	eb d3                	jmp    802c2e <write+0x59>

00802c5b <seek>:

int
seek(int fdnum, off_t offset)
{
  802c5b:	f3 0f 1e fb          	endbr32 
  802c5f:	55                   	push   %ebp
  802c60:	89 e5                	mov    %esp,%ebp
  802c62:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802c65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c68:	50                   	push   %eax
  802c69:	ff 75 08             	pushl  0x8(%ebp)
  802c6c:	e8 06 fc ff ff       	call   802877 <fd_lookup>
  802c71:	83 c4 10             	add    $0x10,%esp
  802c74:	85 c0                	test   %eax,%eax
  802c76:	78 0e                	js     802c86 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  802c78:	8b 55 0c             	mov    0xc(%ebp),%edx
  802c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c7e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802c81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802c86:	c9                   	leave  
  802c87:	c3                   	ret    

00802c88 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802c88:	f3 0f 1e fb          	endbr32 
  802c8c:	55                   	push   %ebp
  802c8d:	89 e5                	mov    %esp,%ebp
  802c8f:	53                   	push   %ebx
  802c90:	83 ec 1c             	sub    $0x1c,%esp
  802c93:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c96:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c99:	50                   	push   %eax
  802c9a:	53                   	push   %ebx
  802c9b:	e8 d7 fb ff ff       	call   802877 <fd_lookup>
  802ca0:	83 c4 10             	add    $0x10,%esp
  802ca3:	85 c0                	test   %eax,%eax
  802ca5:	78 37                	js     802cde <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802ca7:	83 ec 08             	sub    $0x8,%esp
  802caa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802cad:	50                   	push   %eax
  802cae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cb1:	ff 30                	pushl  (%eax)
  802cb3:	e8 13 fc ff ff       	call   8028cb <dev_lookup>
  802cb8:	83 c4 10             	add    $0x10,%esp
  802cbb:	85 c0                	test   %eax,%eax
  802cbd:	78 1f                	js     802cde <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802cbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cc2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802cc6:	74 1b                	je     802ce3 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  802cc8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802ccb:	8b 52 18             	mov    0x18(%edx),%edx
  802cce:	85 d2                	test   %edx,%edx
  802cd0:	74 32                	je     802d04 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802cd2:	83 ec 08             	sub    $0x8,%esp
  802cd5:	ff 75 0c             	pushl  0xc(%ebp)
  802cd8:	50                   	push   %eax
  802cd9:	ff d2                	call   *%edx
  802cdb:	83 c4 10             	add    $0x10,%esp
}
  802cde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ce1:	c9                   	leave  
  802ce2:	c3                   	ret    
			thisenv->env_id, fdnum);
  802ce3:	a1 10 a0 80 00       	mov    0x80a010,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802ce8:	8b 40 48             	mov    0x48(%eax),%eax
  802ceb:	83 ec 04             	sub    $0x4,%esp
  802cee:	53                   	push   %ebx
  802cef:	50                   	push   %eax
  802cf0:	68 c8 45 80 00       	push   $0x8045c8
  802cf5:	e8 55 ed ff ff       	call   801a4f <cprintf>
		return -E_INVAL;
  802cfa:	83 c4 10             	add    $0x10,%esp
  802cfd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802d02:	eb da                	jmp    802cde <ftruncate+0x56>
		return -E_NOT_SUPP;
  802d04:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802d09:	eb d3                	jmp    802cde <ftruncate+0x56>

00802d0b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802d0b:	f3 0f 1e fb          	endbr32 
  802d0f:	55                   	push   %ebp
  802d10:	89 e5                	mov    %esp,%ebp
  802d12:	53                   	push   %ebx
  802d13:	83 ec 1c             	sub    $0x1c,%esp
  802d16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d19:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d1c:	50                   	push   %eax
  802d1d:	ff 75 08             	pushl  0x8(%ebp)
  802d20:	e8 52 fb ff ff       	call   802877 <fd_lookup>
  802d25:	83 c4 10             	add    $0x10,%esp
  802d28:	85 c0                	test   %eax,%eax
  802d2a:	78 4b                	js     802d77 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d2c:	83 ec 08             	sub    $0x8,%esp
  802d2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d32:	50                   	push   %eax
  802d33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d36:	ff 30                	pushl  (%eax)
  802d38:	e8 8e fb ff ff       	call   8028cb <dev_lookup>
  802d3d:	83 c4 10             	add    $0x10,%esp
  802d40:	85 c0                	test   %eax,%eax
  802d42:	78 33                	js     802d77 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  802d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d47:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802d4b:	74 2f                	je     802d7c <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802d4d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802d50:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802d57:	00 00 00 
	stat->st_isdir = 0;
  802d5a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802d61:	00 00 00 
	stat->st_dev = dev;
  802d64:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802d6a:	83 ec 08             	sub    $0x8,%esp
  802d6d:	53                   	push   %ebx
  802d6e:	ff 75 f0             	pushl  -0x10(%ebp)
  802d71:	ff 50 14             	call   *0x14(%eax)
  802d74:	83 c4 10             	add    $0x10,%esp
}
  802d77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d7a:	c9                   	leave  
  802d7b:	c3                   	ret    
		return -E_NOT_SUPP;
  802d7c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802d81:	eb f4                	jmp    802d77 <fstat+0x6c>

00802d83 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802d83:	f3 0f 1e fb          	endbr32 
  802d87:	55                   	push   %ebp
  802d88:	89 e5                	mov    %esp,%ebp
  802d8a:	56                   	push   %esi
  802d8b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802d8c:	83 ec 08             	sub    $0x8,%esp
  802d8f:	6a 00                	push   $0x0
  802d91:	ff 75 08             	pushl  0x8(%ebp)
  802d94:	e8 01 02 00 00       	call   802f9a <open>
  802d99:	89 c3                	mov    %eax,%ebx
  802d9b:	83 c4 10             	add    $0x10,%esp
  802d9e:	85 c0                	test   %eax,%eax
  802da0:	78 1b                	js     802dbd <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  802da2:	83 ec 08             	sub    $0x8,%esp
  802da5:	ff 75 0c             	pushl  0xc(%ebp)
  802da8:	50                   	push   %eax
  802da9:	e8 5d ff ff ff       	call   802d0b <fstat>
  802dae:	89 c6                	mov    %eax,%esi
	close(fd);
  802db0:	89 1c 24             	mov    %ebx,(%esp)
  802db3:	e8 fd fb ff ff       	call   8029b5 <close>
	return r;
  802db8:	83 c4 10             	add    $0x10,%esp
  802dbb:	89 f3                	mov    %esi,%ebx
}
  802dbd:	89 d8                	mov    %ebx,%eax
  802dbf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802dc2:	5b                   	pop    %ebx
  802dc3:	5e                   	pop    %esi
  802dc4:	5d                   	pop    %ebp
  802dc5:	c3                   	ret    

00802dc6 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  802dc6:	55                   	push   %ebp
  802dc7:	89 e5                	mov    %esp,%ebp
  802dc9:	56                   	push   %esi
  802dca:	53                   	push   %ebx
  802dcb:	89 c6                	mov    %eax,%esi
  802dcd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802dcf:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802dd6:	74 27                	je     802dff <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802dd8:	6a 07                	push   $0x7
  802dda:	68 00 b0 80 00       	push   $0x80b000
  802ddf:	56                   	push   %esi
  802de0:	ff 35 00 a0 80 00    	pushl  0x80a000
  802de6:	e8 72 f9 ff ff       	call   80275d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802deb:	83 c4 0c             	add    $0xc,%esp
  802dee:	6a 00                	push   $0x0
  802df0:	53                   	push   %ebx
  802df1:	6a 00                	push   $0x0
  802df3:	e8 f8 f8 ff ff       	call   8026f0 <ipc_recv>
}
  802df8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802dfb:	5b                   	pop    %ebx
  802dfc:	5e                   	pop    %esi
  802dfd:	5d                   	pop    %ebp
  802dfe:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802dff:	83 ec 0c             	sub    $0xc,%esp
  802e02:	6a 01                	push   $0x1
  802e04:	e8 ac f9 ff ff       	call   8027b5 <ipc_find_env>
  802e09:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802e0e:	83 c4 10             	add    $0x10,%esp
  802e11:	eb c5                	jmp    802dd8 <fsipc+0x12>

00802e13 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802e13:	f3 0f 1e fb          	endbr32 
  802e17:	55                   	push   %ebp
  802e18:	89 e5                	mov    %esp,%ebp
  802e1a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  802e20:	8b 40 0c             	mov    0xc(%eax),%eax
  802e23:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802e28:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e2b:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802e30:	ba 00 00 00 00       	mov    $0x0,%edx
  802e35:	b8 02 00 00 00       	mov    $0x2,%eax
  802e3a:	e8 87 ff ff ff       	call   802dc6 <fsipc>
}
  802e3f:	c9                   	leave  
  802e40:	c3                   	ret    

00802e41 <devfile_flush>:
{
  802e41:	f3 0f 1e fb          	endbr32 
  802e45:	55                   	push   %ebp
  802e46:	89 e5                	mov    %esp,%ebp
  802e48:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802e4b:	8b 45 08             	mov    0x8(%ebp),%eax
  802e4e:	8b 40 0c             	mov    0xc(%eax),%eax
  802e51:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802e56:	ba 00 00 00 00       	mov    $0x0,%edx
  802e5b:	b8 06 00 00 00       	mov    $0x6,%eax
  802e60:	e8 61 ff ff ff       	call   802dc6 <fsipc>
}
  802e65:	c9                   	leave  
  802e66:	c3                   	ret    

00802e67 <devfile_stat>:
{
  802e67:	f3 0f 1e fb          	endbr32 
  802e6b:	55                   	push   %ebp
  802e6c:	89 e5                	mov    %esp,%ebp
  802e6e:	53                   	push   %ebx
  802e6f:	83 ec 04             	sub    $0x4,%esp
  802e72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802e75:	8b 45 08             	mov    0x8(%ebp),%eax
  802e78:	8b 40 0c             	mov    0xc(%eax),%eax
  802e7b:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802e80:	ba 00 00 00 00       	mov    $0x0,%edx
  802e85:	b8 05 00 00 00       	mov    $0x5,%eax
  802e8a:	e8 37 ff ff ff       	call   802dc6 <fsipc>
  802e8f:	85 c0                	test   %eax,%eax
  802e91:	78 2c                	js     802ebf <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802e93:	83 ec 08             	sub    $0x8,%esp
  802e96:	68 00 b0 80 00       	push   $0x80b000
  802e9b:	53                   	push   %ebx
  802e9c:	e8 b8 f1 ff ff       	call   802059 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802ea1:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802ea6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802eac:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802eb1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802eb7:	83 c4 10             	add    $0x10,%esp
  802eba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802ebf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ec2:	c9                   	leave  
  802ec3:	c3                   	ret    

00802ec4 <devfile_write>:
{
  802ec4:	f3 0f 1e fb          	endbr32 
  802ec8:	55                   	push   %ebp
  802ec9:	89 e5                	mov    %esp,%ebp
  802ecb:	83 ec 0c             	sub    $0xc,%esp
  802ece:	8b 45 10             	mov    0x10(%ebp),%eax
  802ed1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802ed6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  802edb:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802ede:	8b 55 08             	mov    0x8(%ebp),%edx
  802ee1:	8b 52 0c             	mov    0xc(%edx),%edx
  802ee4:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = n;
  802eea:	a3 04 b0 80 00       	mov    %eax,0x80b004
	memmove(fsipcbuf.write.req_buf, buf, n);
  802eef:	50                   	push   %eax
  802ef0:	ff 75 0c             	pushl  0xc(%ebp)
  802ef3:	68 08 b0 80 00       	push   $0x80b008
  802ef8:	e8 5a f3 ff ff       	call   802257 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  802efd:	ba 00 00 00 00       	mov    $0x0,%edx
  802f02:	b8 04 00 00 00       	mov    $0x4,%eax
  802f07:	e8 ba fe ff ff       	call   802dc6 <fsipc>
}
  802f0c:	c9                   	leave  
  802f0d:	c3                   	ret    

00802f0e <devfile_read>:
{
  802f0e:	f3 0f 1e fb          	endbr32 
  802f12:	55                   	push   %ebp
  802f13:	89 e5                	mov    %esp,%ebp
  802f15:	56                   	push   %esi
  802f16:	53                   	push   %ebx
  802f17:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802f1a:	8b 45 08             	mov    0x8(%ebp),%eax
  802f1d:	8b 40 0c             	mov    0xc(%eax),%eax
  802f20:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802f25:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802f2b:	ba 00 00 00 00       	mov    $0x0,%edx
  802f30:	b8 03 00 00 00       	mov    $0x3,%eax
  802f35:	e8 8c fe ff ff       	call   802dc6 <fsipc>
  802f3a:	89 c3                	mov    %eax,%ebx
  802f3c:	85 c0                	test   %eax,%eax
  802f3e:	78 1f                	js     802f5f <devfile_read+0x51>
	assert(r <= n);
  802f40:	39 f0                	cmp    %esi,%eax
  802f42:	77 24                	ja     802f68 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  802f44:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802f49:	7f 36                	jg     802f81 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802f4b:	83 ec 04             	sub    $0x4,%esp
  802f4e:	50                   	push   %eax
  802f4f:	68 00 b0 80 00       	push   $0x80b000
  802f54:	ff 75 0c             	pushl  0xc(%ebp)
  802f57:	e8 fb f2 ff ff       	call   802257 <memmove>
	return r;
  802f5c:	83 c4 10             	add    $0x10,%esp
}
  802f5f:	89 d8                	mov    %ebx,%eax
  802f61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f64:	5b                   	pop    %ebx
  802f65:	5e                   	pop    %esi
  802f66:	5d                   	pop    %ebp
  802f67:	c3                   	ret    
	assert(r <= n);
  802f68:	68 38 46 80 00       	push   $0x804638
  802f6d:	68 dd 3c 80 00       	push   $0x803cdd
  802f72:	68 8c 00 00 00       	push   $0x8c
  802f77:	68 3f 46 80 00       	push   $0x80463f
  802f7c:	e8 e7 e9 ff ff       	call   801968 <_panic>
	assert(r <= PGSIZE);
  802f81:	68 4a 46 80 00       	push   $0x80464a
  802f86:	68 dd 3c 80 00       	push   $0x803cdd
  802f8b:	68 8d 00 00 00       	push   $0x8d
  802f90:	68 3f 46 80 00       	push   $0x80463f
  802f95:	e8 ce e9 ff ff       	call   801968 <_panic>

00802f9a <open>:
{
  802f9a:	f3 0f 1e fb          	endbr32 
  802f9e:	55                   	push   %ebp
  802f9f:	89 e5                	mov    %esp,%ebp
  802fa1:	56                   	push   %esi
  802fa2:	53                   	push   %ebx
  802fa3:	83 ec 1c             	sub    $0x1c,%esp
  802fa6:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  802fa9:	56                   	push   %esi
  802faa:	e8 67 f0 ff ff       	call   802016 <strlen>
  802faf:	83 c4 10             	add    $0x10,%esp
  802fb2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802fb7:	7f 6c                	jg     803025 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  802fb9:	83 ec 0c             	sub    $0xc,%esp
  802fbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802fbf:	50                   	push   %eax
  802fc0:	e8 5c f8 ff ff       	call   802821 <fd_alloc>
  802fc5:	89 c3                	mov    %eax,%ebx
  802fc7:	83 c4 10             	add    $0x10,%esp
  802fca:	85 c0                	test   %eax,%eax
  802fcc:	78 3c                	js     80300a <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  802fce:	83 ec 08             	sub    $0x8,%esp
  802fd1:	56                   	push   %esi
  802fd2:	68 00 b0 80 00       	push   $0x80b000
  802fd7:	e8 7d f0 ff ff       	call   802059 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802fdc:	8b 45 0c             	mov    0xc(%ebp),%eax
  802fdf:	a3 00 b4 80 00       	mov    %eax,0x80b400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802fe4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802fe7:	b8 01 00 00 00       	mov    $0x1,%eax
  802fec:	e8 d5 fd ff ff       	call   802dc6 <fsipc>
  802ff1:	89 c3                	mov    %eax,%ebx
  802ff3:	83 c4 10             	add    $0x10,%esp
  802ff6:	85 c0                	test   %eax,%eax
  802ff8:	78 19                	js     803013 <open+0x79>
	return fd2num(fd);
  802ffa:	83 ec 0c             	sub    $0xc,%esp
  802ffd:	ff 75 f4             	pushl  -0xc(%ebp)
  803000:	e8 ed f7 ff ff       	call   8027f2 <fd2num>
  803005:	89 c3                	mov    %eax,%ebx
  803007:	83 c4 10             	add    $0x10,%esp
}
  80300a:	89 d8                	mov    %ebx,%eax
  80300c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80300f:	5b                   	pop    %ebx
  803010:	5e                   	pop    %esi
  803011:	5d                   	pop    %ebp
  803012:	c3                   	ret    
		fd_close(fd, 0);
  803013:	83 ec 08             	sub    $0x8,%esp
  803016:	6a 00                	push   $0x0
  803018:	ff 75 f4             	pushl  -0xc(%ebp)
  80301b:	e8 0a f9 ff ff       	call   80292a <fd_close>
		return r;
  803020:	83 c4 10             	add    $0x10,%esp
  803023:	eb e5                	jmp    80300a <open+0x70>
		return -E_BAD_PATH;
  803025:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80302a:	eb de                	jmp    80300a <open+0x70>

0080302c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80302c:	f3 0f 1e fb          	endbr32 
  803030:	55                   	push   %ebp
  803031:	89 e5                	mov    %esp,%ebp
  803033:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  803036:	ba 00 00 00 00       	mov    $0x0,%edx
  80303b:	b8 08 00 00 00       	mov    $0x8,%eax
  803040:	e8 81 fd ff ff       	call   802dc6 <fsipc>
}
  803045:	c9                   	leave  
  803046:	c3                   	ret    

00803047 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803047:	f3 0f 1e fb          	endbr32 
  80304b:	55                   	push   %ebp
  80304c:	89 e5                	mov    %esp,%ebp
  80304e:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803051:	89 c2                	mov    %eax,%edx
  803053:	c1 ea 16             	shr    $0x16,%edx
  803056:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80305d:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  803062:	f6 c1 01             	test   $0x1,%cl
  803065:	74 1c                	je     803083 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  803067:	c1 e8 0c             	shr    $0xc,%eax
  80306a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  803071:	a8 01                	test   $0x1,%al
  803073:	74 0e                	je     803083 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803075:	c1 e8 0c             	shr    $0xc,%eax
  803078:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80307f:	ef 
  803080:	0f b7 d2             	movzwl %dx,%edx
}
  803083:	89 d0                	mov    %edx,%eax
  803085:	5d                   	pop    %ebp
  803086:	c3                   	ret    

00803087 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  803087:	f3 0f 1e fb          	endbr32 
  80308b:	55                   	push   %ebp
  80308c:	89 e5                	mov    %esp,%ebp
  80308e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  803091:	68 b6 46 80 00       	push   $0x8046b6
  803096:	ff 75 0c             	pushl  0xc(%ebp)
  803099:	e8 bb ef ff ff       	call   802059 <strcpy>
	return 0;
}
  80309e:	b8 00 00 00 00       	mov    $0x0,%eax
  8030a3:	c9                   	leave  
  8030a4:	c3                   	ret    

008030a5 <devsock_close>:
{
  8030a5:	f3 0f 1e fb          	endbr32 
  8030a9:	55                   	push   %ebp
  8030aa:	89 e5                	mov    %esp,%ebp
  8030ac:	53                   	push   %ebx
  8030ad:	83 ec 10             	sub    $0x10,%esp
  8030b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8030b3:	53                   	push   %ebx
  8030b4:	e8 8e ff ff ff       	call   803047 <pageref>
  8030b9:	89 c2                	mov    %eax,%edx
  8030bb:	83 c4 10             	add    $0x10,%esp
		return 0;
  8030be:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8030c3:	83 fa 01             	cmp    $0x1,%edx
  8030c6:	74 05                	je     8030cd <devsock_close+0x28>
}
  8030c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8030cb:	c9                   	leave  
  8030cc:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8030cd:	83 ec 0c             	sub    $0xc,%esp
  8030d0:	ff 73 0c             	pushl  0xc(%ebx)
  8030d3:	e8 e3 02 00 00       	call   8033bb <nsipc_close>
  8030d8:	83 c4 10             	add    $0x10,%esp
  8030db:	eb eb                	jmp    8030c8 <devsock_close+0x23>

008030dd <devsock_write>:
{
  8030dd:	f3 0f 1e fb          	endbr32 
  8030e1:	55                   	push   %ebp
  8030e2:	89 e5                	mov    %esp,%ebp
  8030e4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8030e7:	6a 00                	push   $0x0
  8030e9:	ff 75 10             	pushl  0x10(%ebp)
  8030ec:	ff 75 0c             	pushl  0xc(%ebp)
  8030ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8030f2:	ff 70 0c             	pushl  0xc(%eax)
  8030f5:	e8 b5 03 00 00       	call   8034af <nsipc_send>
}
  8030fa:	c9                   	leave  
  8030fb:	c3                   	ret    

008030fc <devsock_read>:
{
  8030fc:	f3 0f 1e fb          	endbr32 
  803100:	55                   	push   %ebp
  803101:	89 e5                	mov    %esp,%ebp
  803103:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  803106:	6a 00                	push   $0x0
  803108:	ff 75 10             	pushl  0x10(%ebp)
  80310b:	ff 75 0c             	pushl  0xc(%ebp)
  80310e:	8b 45 08             	mov    0x8(%ebp),%eax
  803111:	ff 70 0c             	pushl  0xc(%eax)
  803114:	e8 1f 03 00 00       	call   803438 <nsipc_recv>
}
  803119:	c9                   	leave  
  80311a:	c3                   	ret    

0080311b <fd2sockid>:
{
  80311b:	55                   	push   %ebp
  80311c:	89 e5                	mov    %esp,%ebp
  80311e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  803121:	8d 55 f4             	lea    -0xc(%ebp),%edx
  803124:	52                   	push   %edx
  803125:	50                   	push   %eax
  803126:	e8 4c f7 ff ff       	call   802877 <fd_lookup>
  80312b:	83 c4 10             	add    $0x10,%esp
  80312e:	85 c0                	test   %eax,%eax
  803130:	78 10                	js     803142 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  803132:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803135:	8b 0d c0 90 80 00    	mov    0x8090c0,%ecx
  80313b:	39 08                	cmp    %ecx,(%eax)
  80313d:	75 05                	jne    803144 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  80313f:	8b 40 0c             	mov    0xc(%eax),%eax
}
  803142:	c9                   	leave  
  803143:	c3                   	ret    
		return -E_NOT_SUPP;
  803144:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  803149:	eb f7                	jmp    803142 <fd2sockid+0x27>

0080314b <alloc_sockfd>:
{
  80314b:	55                   	push   %ebp
  80314c:	89 e5                	mov    %esp,%ebp
  80314e:	56                   	push   %esi
  80314f:	53                   	push   %ebx
  803150:	83 ec 1c             	sub    $0x1c,%esp
  803153:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  803155:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803158:	50                   	push   %eax
  803159:	e8 c3 f6 ff ff       	call   802821 <fd_alloc>
  80315e:	89 c3                	mov    %eax,%ebx
  803160:	83 c4 10             	add    $0x10,%esp
  803163:	85 c0                	test   %eax,%eax
  803165:	78 43                	js     8031aa <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  803167:	83 ec 04             	sub    $0x4,%esp
  80316a:	68 07 04 00 00       	push   $0x407
  80316f:	ff 75 f4             	pushl  -0xc(%ebp)
  803172:	6a 00                	push   $0x0
  803174:	e8 49 f3 ff ff       	call   8024c2 <sys_page_alloc>
  803179:	89 c3                	mov    %eax,%ebx
  80317b:	83 c4 10             	add    $0x10,%esp
  80317e:	85 c0                	test   %eax,%eax
  803180:	78 28                	js     8031aa <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  803182:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803185:	8b 15 c0 90 80 00    	mov    0x8090c0,%edx
  80318b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80318d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803190:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  803197:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80319a:	83 ec 0c             	sub    $0xc,%esp
  80319d:	50                   	push   %eax
  80319e:	e8 4f f6 ff ff       	call   8027f2 <fd2num>
  8031a3:	89 c3                	mov    %eax,%ebx
  8031a5:	83 c4 10             	add    $0x10,%esp
  8031a8:	eb 0c                	jmp    8031b6 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8031aa:	83 ec 0c             	sub    $0xc,%esp
  8031ad:	56                   	push   %esi
  8031ae:	e8 08 02 00 00       	call   8033bb <nsipc_close>
		return r;
  8031b3:	83 c4 10             	add    $0x10,%esp
}
  8031b6:	89 d8                	mov    %ebx,%eax
  8031b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8031bb:	5b                   	pop    %ebx
  8031bc:	5e                   	pop    %esi
  8031bd:	5d                   	pop    %ebp
  8031be:	c3                   	ret    

008031bf <accept>:
{
  8031bf:	f3 0f 1e fb          	endbr32 
  8031c3:	55                   	push   %ebp
  8031c4:	89 e5                	mov    %esp,%ebp
  8031c6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8031c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8031cc:	e8 4a ff ff ff       	call   80311b <fd2sockid>
  8031d1:	85 c0                	test   %eax,%eax
  8031d3:	78 1b                	js     8031f0 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8031d5:	83 ec 04             	sub    $0x4,%esp
  8031d8:	ff 75 10             	pushl  0x10(%ebp)
  8031db:	ff 75 0c             	pushl  0xc(%ebp)
  8031de:	50                   	push   %eax
  8031df:	e8 22 01 00 00       	call   803306 <nsipc_accept>
  8031e4:	83 c4 10             	add    $0x10,%esp
  8031e7:	85 c0                	test   %eax,%eax
  8031e9:	78 05                	js     8031f0 <accept+0x31>
	return alloc_sockfd(r);
  8031eb:	e8 5b ff ff ff       	call   80314b <alloc_sockfd>
}
  8031f0:	c9                   	leave  
  8031f1:	c3                   	ret    

008031f2 <bind>:
{
  8031f2:	f3 0f 1e fb          	endbr32 
  8031f6:	55                   	push   %ebp
  8031f7:	89 e5                	mov    %esp,%ebp
  8031f9:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8031fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8031ff:	e8 17 ff ff ff       	call   80311b <fd2sockid>
  803204:	85 c0                	test   %eax,%eax
  803206:	78 12                	js     80321a <bind+0x28>
	return nsipc_bind(r, name, namelen);
  803208:	83 ec 04             	sub    $0x4,%esp
  80320b:	ff 75 10             	pushl  0x10(%ebp)
  80320e:	ff 75 0c             	pushl  0xc(%ebp)
  803211:	50                   	push   %eax
  803212:	e8 45 01 00 00       	call   80335c <nsipc_bind>
  803217:	83 c4 10             	add    $0x10,%esp
}
  80321a:	c9                   	leave  
  80321b:	c3                   	ret    

0080321c <shutdown>:
{
  80321c:	f3 0f 1e fb          	endbr32 
  803220:	55                   	push   %ebp
  803221:	89 e5                	mov    %esp,%ebp
  803223:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  803226:	8b 45 08             	mov    0x8(%ebp),%eax
  803229:	e8 ed fe ff ff       	call   80311b <fd2sockid>
  80322e:	85 c0                	test   %eax,%eax
  803230:	78 0f                	js     803241 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  803232:	83 ec 08             	sub    $0x8,%esp
  803235:	ff 75 0c             	pushl  0xc(%ebp)
  803238:	50                   	push   %eax
  803239:	e8 57 01 00 00       	call   803395 <nsipc_shutdown>
  80323e:	83 c4 10             	add    $0x10,%esp
}
  803241:	c9                   	leave  
  803242:	c3                   	ret    

00803243 <connect>:
{
  803243:	f3 0f 1e fb          	endbr32 
  803247:	55                   	push   %ebp
  803248:	89 e5                	mov    %esp,%ebp
  80324a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80324d:	8b 45 08             	mov    0x8(%ebp),%eax
  803250:	e8 c6 fe ff ff       	call   80311b <fd2sockid>
  803255:	85 c0                	test   %eax,%eax
  803257:	78 12                	js     80326b <connect+0x28>
	return nsipc_connect(r, name, namelen);
  803259:	83 ec 04             	sub    $0x4,%esp
  80325c:	ff 75 10             	pushl  0x10(%ebp)
  80325f:	ff 75 0c             	pushl  0xc(%ebp)
  803262:	50                   	push   %eax
  803263:	e8 71 01 00 00       	call   8033d9 <nsipc_connect>
  803268:	83 c4 10             	add    $0x10,%esp
}
  80326b:	c9                   	leave  
  80326c:	c3                   	ret    

0080326d <listen>:
{
  80326d:	f3 0f 1e fb          	endbr32 
  803271:	55                   	push   %ebp
  803272:	89 e5                	mov    %esp,%ebp
  803274:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  803277:	8b 45 08             	mov    0x8(%ebp),%eax
  80327a:	e8 9c fe ff ff       	call   80311b <fd2sockid>
  80327f:	85 c0                	test   %eax,%eax
  803281:	78 0f                	js     803292 <listen+0x25>
	return nsipc_listen(r, backlog);
  803283:	83 ec 08             	sub    $0x8,%esp
  803286:	ff 75 0c             	pushl  0xc(%ebp)
  803289:	50                   	push   %eax
  80328a:	e8 83 01 00 00       	call   803412 <nsipc_listen>
  80328f:	83 c4 10             	add    $0x10,%esp
}
  803292:	c9                   	leave  
  803293:	c3                   	ret    

00803294 <socket>:

int
socket(int domain, int type, int protocol)
{
  803294:	f3 0f 1e fb          	endbr32 
  803298:	55                   	push   %ebp
  803299:	89 e5                	mov    %esp,%ebp
  80329b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80329e:	ff 75 10             	pushl  0x10(%ebp)
  8032a1:	ff 75 0c             	pushl  0xc(%ebp)
  8032a4:	ff 75 08             	pushl  0x8(%ebp)
  8032a7:	e8 65 02 00 00       	call   803511 <nsipc_socket>
  8032ac:	83 c4 10             	add    $0x10,%esp
  8032af:	85 c0                	test   %eax,%eax
  8032b1:	78 05                	js     8032b8 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  8032b3:	e8 93 fe ff ff       	call   80314b <alloc_sockfd>
}
  8032b8:	c9                   	leave  
  8032b9:	c3                   	ret    

008032ba <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8032ba:	55                   	push   %ebp
  8032bb:	89 e5                	mov    %esp,%ebp
  8032bd:	53                   	push   %ebx
  8032be:	83 ec 04             	sub    $0x4,%esp
  8032c1:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8032c3:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  8032ca:	74 26                	je     8032f2 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8032cc:	6a 07                	push   $0x7
  8032ce:	68 00 c0 80 00       	push   $0x80c000
  8032d3:	53                   	push   %ebx
  8032d4:	ff 35 04 a0 80 00    	pushl  0x80a004
  8032da:	e8 7e f4 ff ff       	call   80275d <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8032df:	83 c4 0c             	add    $0xc,%esp
  8032e2:	6a 00                	push   $0x0
  8032e4:	6a 00                	push   $0x0
  8032e6:	6a 00                	push   $0x0
  8032e8:	e8 03 f4 ff ff       	call   8026f0 <ipc_recv>
}
  8032ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8032f0:	c9                   	leave  
  8032f1:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8032f2:	83 ec 0c             	sub    $0xc,%esp
  8032f5:	6a 02                	push   $0x2
  8032f7:	e8 b9 f4 ff ff       	call   8027b5 <ipc_find_env>
  8032fc:	a3 04 a0 80 00       	mov    %eax,0x80a004
  803301:	83 c4 10             	add    $0x10,%esp
  803304:	eb c6                	jmp    8032cc <nsipc+0x12>

00803306 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  803306:	f3 0f 1e fb          	endbr32 
  80330a:	55                   	push   %ebp
  80330b:	89 e5                	mov    %esp,%ebp
  80330d:	56                   	push   %esi
  80330e:	53                   	push   %ebx
  80330f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  803312:	8b 45 08             	mov    0x8(%ebp),%eax
  803315:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80331a:	8b 06                	mov    (%esi),%eax
  80331c:	a3 04 c0 80 00       	mov    %eax,0x80c004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  803321:	b8 01 00 00 00       	mov    $0x1,%eax
  803326:	e8 8f ff ff ff       	call   8032ba <nsipc>
  80332b:	89 c3                	mov    %eax,%ebx
  80332d:	85 c0                	test   %eax,%eax
  80332f:	79 09                	jns    80333a <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  803331:	89 d8                	mov    %ebx,%eax
  803333:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803336:	5b                   	pop    %ebx
  803337:	5e                   	pop    %esi
  803338:	5d                   	pop    %ebp
  803339:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80333a:	83 ec 04             	sub    $0x4,%esp
  80333d:	ff 35 10 c0 80 00    	pushl  0x80c010
  803343:	68 00 c0 80 00       	push   $0x80c000
  803348:	ff 75 0c             	pushl  0xc(%ebp)
  80334b:	e8 07 ef ff ff       	call   802257 <memmove>
		*addrlen = ret->ret_addrlen;
  803350:	a1 10 c0 80 00       	mov    0x80c010,%eax
  803355:	89 06                	mov    %eax,(%esi)
  803357:	83 c4 10             	add    $0x10,%esp
	return r;
  80335a:	eb d5                	jmp    803331 <nsipc_accept+0x2b>

0080335c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80335c:	f3 0f 1e fb          	endbr32 
  803360:	55                   	push   %ebp
  803361:	89 e5                	mov    %esp,%ebp
  803363:	53                   	push   %ebx
  803364:	83 ec 08             	sub    $0x8,%esp
  803367:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80336a:	8b 45 08             	mov    0x8(%ebp),%eax
  80336d:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  803372:	53                   	push   %ebx
  803373:	ff 75 0c             	pushl  0xc(%ebp)
  803376:	68 04 c0 80 00       	push   $0x80c004
  80337b:	e8 d7 ee ff ff       	call   802257 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  803380:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_BIND);
  803386:	b8 02 00 00 00       	mov    $0x2,%eax
  80338b:	e8 2a ff ff ff       	call   8032ba <nsipc>
}
  803390:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803393:	c9                   	leave  
  803394:	c3                   	ret    

00803395 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  803395:	f3 0f 1e fb          	endbr32 
  803399:	55                   	push   %ebp
  80339a:	89 e5                	mov    %esp,%ebp
  80339c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80339f:	8b 45 08             	mov    0x8(%ebp),%eax
  8033a2:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.shutdown.req_how = how;
  8033a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8033aa:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_SHUTDOWN);
  8033af:	b8 03 00 00 00       	mov    $0x3,%eax
  8033b4:	e8 01 ff ff ff       	call   8032ba <nsipc>
}
  8033b9:	c9                   	leave  
  8033ba:	c3                   	ret    

008033bb <nsipc_close>:

int
nsipc_close(int s)
{
  8033bb:	f3 0f 1e fb          	endbr32 
  8033bf:	55                   	push   %ebp
  8033c0:	89 e5                	mov    %esp,%ebp
  8033c2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8033c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8033c8:	a3 00 c0 80 00       	mov    %eax,0x80c000
	return nsipc(NSREQ_CLOSE);
  8033cd:	b8 04 00 00 00       	mov    $0x4,%eax
  8033d2:	e8 e3 fe ff ff       	call   8032ba <nsipc>
}
  8033d7:	c9                   	leave  
  8033d8:	c3                   	ret    

008033d9 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8033d9:	f3 0f 1e fb          	endbr32 
  8033dd:	55                   	push   %ebp
  8033de:	89 e5                	mov    %esp,%ebp
  8033e0:	53                   	push   %ebx
  8033e1:	83 ec 08             	sub    $0x8,%esp
  8033e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8033e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8033ea:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8033ef:	53                   	push   %ebx
  8033f0:	ff 75 0c             	pushl  0xc(%ebp)
  8033f3:	68 04 c0 80 00       	push   $0x80c004
  8033f8:	e8 5a ee ff ff       	call   802257 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8033fd:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_CONNECT);
  803403:	b8 05 00 00 00       	mov    $0x5,%eax
  803408:	e8 ad fe ff ff       	call   8032ba <nsipc>
}
  80340d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803410:	c9                   	leave  
  803411:	c3                   	ret    

00803412 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  803412:	f3 0f 1e fb          	endbr32 
  803416:	55                   	push   %ebp
  803417:	89 e5                	mov    %esp,%ebp
  803419:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80341c:	8b 45 08             	mov    0x8(%ebp),%eax
  80341f:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.listen.req_backlog = backlog;
  803424:	8b 45 0c             	mov    0xc(%ebp),%eax
  803427:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_LISTEN);
  80342c:	b8 06 00 00 00       	mov    $0x6,%eax
  803431:	e8 84 fe ff ff       	call   8032ba <nsipc>
}
  803436:	c9                   	leave  
  803437:	c3                   	ret    

00803438 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  803438:	f3 0f 1e fb          	endbr32 
  80343c:	55                   	push   %ebp
  80343d:	89 e5                	mov    %esp,%ebp
  80343f:	56                   	push   %esi
  803440:	53                   	push   %ebx
  803441:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  803444:	8b 45 08             	mov    0x8(%ebp),%eax
  803447:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.recv.req_len = len;
  80344c:	89 35 04 c0 80 00    	mov    %esi,0x80c004
	nsipcbuf.recv.req_flags = flags;
  803452:	8b 45 14             	mov    0x14(%ebp),%eax
  803455:	a3 08 c0 80 00       	mov    %eax,0x80c008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80345a:	b8 07 00 00 00       	mov    $0x7,%eax
  80345f:	e8 56 fe ff ff       	call   8032ba <nsipc>
  803464:	89 c3                	mov    %eax,%ebx
  803466:	85 c0                	test   %eax,%eax
  803468:	78 26                	js     803490 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  80346a:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  803470:	b8 3f 06 00 00       	mov    $0x63f,%eax
  803475:	0f 4e c6             	cmovle %esi,%eax
  803478:	39 c3                	cmp    %eax,%ebx
  80347a:	7f 1d                	jg     803499 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80347c:	83 ec 04             	sub    $0x4,%esp
  80347f:	53                   	push   %ebx
  803480:	68 00 c0 80 00       	push   $0x80c000
  803485:	ff 75 0c             	pushl  0xc(%ebp)
  803488:	e8 ca ed ff ff       	call   802257 <memmove>
  80348d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  803490:	89 d8                	mov    %ebx,%eax
  803492:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803495:	5b                   	pop    %ebx
  803496:	5e                   	pop    %esi
  803497:	5d                   	pop    %ebp
  803498:	c3                   	ret    
		assert(r < 1600 && r <= len);
  803499:	68 c2 46 80 00       	push   $0x8046c2
  80349e:	68 dd 3c 80 00       	push   $0x803cdd
  8034a3:	6a 62                	push   $0x62
  8034a5:	68 d7 46 80 00       	push   $0x8046d7
  8034aa:	e8 b9 e4 ff ff       	call   801968 <_panic>

008034af <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8034af:	f3 0f 1e fb          	endbr32 
  8034b3:	55                   	push   %ebp
  8034b4:	89 e5                	mov    %esp,%ebp
  8034b6:	53                   	push   %ebx
  8034b7:	83 ec 04             	sub    $0x4,%esp
  8034ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8034bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8034c0:	a3 00 c0 80 00       	mov    %eax,0x80c000
	assert(size < 1600);
  8034c5:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8034cb:	7f 2e                	jg     8034fb <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8034cd:	83 ec 04             	sub    $0x4,%esp
  8034d0:	53                   	push   %ebx
  8034d1:	ff 75 0c             	pushl  0xc(%ebp)
  8034d4:	68 0c c0 80 00       	push   $0x80c00c
  8034d9:	e8 79 ed ff ff       	call   802257 <memmove>
	nsipcbuf.send.req_size = size;
  8034de:	89 1d 04 c0 80 00    	mov    %ebx,0x80c004
	nsipcbuf.send.req_flags = flags;
  8034e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8034e7:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SEND);
  8034ec:	b8 08 00 00 00       	mov    $0x8,%eax
  8034f1:	e8 c4 fd ff ff       	call   8032ba <nsipc>
}
  8034f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8034f9:	c9                   	leave  
  8034fa:	c3                   	ret    
	assert(size < 1600);
  8034fb:	68 e3 46 80 00       	push   $0x8046e3
  803500:	68 dd 3c 80 00       	push   $0x803cdd
  803505:	6a 6d                	push   $0x6d
  803507:	68 d7 46 80 00       	push   $0x8046d7
  80350c:	e8 57 e4 ff ff       	call   801968 <_panic>

00803511 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  803511:	f3 0f 1e fb          	endbr32 
  803515:	55                   	push   %ebp
  803516:	89 e5                	mov    %esp,%ebp
  803518:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80351b:	8b 45 08             	mov    0x8(%ebp),%eax
  80351e:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.socket.req_type = type;
  803523:	8b 45 0c             	mov    0xc(%ebp),%eax
  803526:	a3 04 c0 80 00       	mov    %eax,0x80c004
	nsipcbuf.socket.req_protocol = protocol;
  80352b:	8b 45 10             	mov    0x10(%ebp),%eax
  80352e:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SOCKET);
  803533:	b8 09 00 00 00       	mov    $0x9,%eax
  803538:	e8 7d fd ff ff       	call   8032ba <nsipc>
}
  80353d:	c9                   	leave  
  80353e:	c3                   	ret    

0080353f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80353f:	f3 0f 1e fb          	endbr32 
  803543:	55                   	push   %ebp
  803544:	89 e5                	mov    %esp,%ebp
  803546:	56                   	push   %esi
  803547:	53                   	push   %ebx
  803548:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80354b:	83 ec 0c             	sub    $0xc,%esp
  80354e:	ff 75 08             	pushl  0x8(%ebp)
  803551:	e8 b0 f2 ff ff       	call   802806 <fd2data>
  803556:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  803558:	83 c4 08             	add    $0x8,%esp
  80355b:	68 ef 46 80 00       	push   $0x8046ef
  803560:	53                   	push   %ebx
  803561:	e8 f3 ea ff ff       	call   802059 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803566:	8b 46 04             	mov    0x4(%esi),%eax
  803569:	2b 06                	sub    (%esi),%eax
  80356b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  803571:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803578:	00 00 00 
	stat->st_dev = &devpipe;
  80357b:	c7 83 88 00 00 00 dc 	movl   $0x8090dc,0x88(%ebx)
  803582:	90 80 00 
	return 0;
}
  803585:	b8 00 00 00 00       	mov    $0x0,%eax
  80358a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80358d:	5b                   	pop    %ebx
  80358e:	5e                   	pop    %esi
  80358f:	5d                   	pop    %ebp
  803590:	c3                   	ret    

00803591 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  803591:	f3 0f 1e fb          	endbr32 
  803595:	55                   	push   %ebp
  803596:	89 e5                	mov    %esp,%ebp
  803598:	53                   	push   %ebx
  803599:	83 ec 0c             	sub    $0xc,%esp
  80359c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80359f:	53                   	push   %ebx
  8035a0:	6a 00                	push   $0x0
  8035a2:	e8 66 ef ff ff       	call   80250d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8035a7:	89 1c 24             	mov    %ebx,(%esp)
  8035aa:	e8 57 f2 ff ff       	call   802806 <fd2data>
  8035af:	83 c4 08             	add    $0x8,%esp
  8035b2:	50                   	push   %eax
  8035b3:	6a 00                	push   $0x0
  8035b5:	e8 53 ef ff ff       	call   80250d <sys_page_unmap>
}
  8035ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8035bd:	c9                   	leave  
  8035be:	c3                   	ret    

008035bf <_pipeisclosed>:
{
  8035bf:	55                   	push   %ebp
  8035c0:	89 e5                	mov    %esp,%ebp
  8035c2:	57                   	push   %edi
  8035c3:	56                   	push   %esi
  8035c4:	53                   	push   %ebx
  8035c5:	83 ec 1c             	sub    $0x1c,%esp
  8035c8:	89 c7                	mov    %eax,%edi
  8035ca:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8035cc:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8035d1:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8035d4:	83 ec 0c             	sub    $0xc,%esp
  8035d7:	57                   	push   %edi
  8035d8:	e8 6a fa ff ff       	call   803047 <pageref>
  8035dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8035e0:	89 34 24             	mov    %esi,(%esp)
  8035e3:	e8 5f fa ff ff       	call   803047 <pageref>
		nn = thisenv->env_runs;
  8035e8:	8b 15 10 a0 80 00    	mov    0x80a010,%edx
  8035ee:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8035f1:	83 c4 10             	add    $0x10,%esp
  8035f4:	39 cb                	cmp    %ecx,%ebx
  8035f6:	74 1b                	je     803613 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8035f8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8035fb:	75 cf                	jne    8035cc <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8035fd:	8b 42 58             	mov    0x58(%edx),%eax
  803600:	6a 01                	push   $0x1
  803602:	50                   	push   %eax
  803603:	53                   	push   %ebx
  803604:	68 f6 46 80 00       	push   $0x8046f6
  803609:	e8 41 e4 ff ff       	call   801a4f <cprintf>
  80360e:	83 c4 10             	add    $0x10,%esp
  803611:	eb b9                	jmp    8035cc <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  803613:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  803616:	0f 94 c0             	sete   %al
  803619:	0f b6 c0             	movzbl %al,%eax
}
  80361c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80361f:	5b                   	pop    %ebx
  803620:	5e                   	pop    %esi
  803621:	5f                   	pop    %edi
  803622:	5d                   	pop    %ebp
  803623:	c3                   	ret    

00803624 <devpipe_write>:
{
  803624:	f3 0f 1e fb          	endbr32 
  803628:	55                   	push   %ebp
  803629:	89 e5                	mov    %esp,%ebp
  80362b:	57                   	push   %edi
  80362c:	56                   	push   %esi
  80362d:	53                   	push   %ebx
  80362e:	83 ec 28             	sub    $0x28,%esp
  803631:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  803634:	56                   	push   %esi
  803635:	e8 cc f1 ff ff       	call   802806 <fd2data>
  80363a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80363c:	83 c4 10             	add    $0x10,%esp
  80363f:	bf 00 00 00 00       	mov    $0x0,%edi
  803644:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803647:	74 4f                	je     803698 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803649:	8b 43 04             	mov    0x4(%ebx),%eax
  80364c:	8b 0b                	mov    (%ebx),%ecx
  80364e:	8d 51 20             	lea    0x20(%ecx),%edx
  803651:	39 d0                	cmp    %edx,%eax
  803653:	72 14                	jb     803669 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  803655:	89 da                	mov    %ebx,%edx
  803657:	89 f0                	mov    %esi,%eax
  803659:	e8 61 ff ff ff       	call   8035bf <_pipeisclosed>
  80365e:	85 c0                	test   %eax,%eax
  803660:	75 3b                	jne    80369d <devpipe_write+0x79>
			sys_yield();
  803662:	e8 38 ee ff ff       	call   80249f <sys_yield>
  803667:	eb e0                	jmp    803649 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803669:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80366c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803670:	88 4d e7             	mov    %cl,-0x19(%ebp)
  803673:	89 c2                	mov    %eax,%edx
  803675:	c1 fa 1f             	sar    $0x1f,%edx
  803678:	89 d1                	mov    %edx,%ecx
  80367a:	c1 e9 1b             	shr    $0x1b,%ecx
  80367d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803680:	83 e2 1f             	and    $0x1f,%edx
  803683:	29 ca                	sub    %ecx,%edx
  803685:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  803689:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80368d:	83 c0 01             	add    $0x1,%eax
  803690:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  803693:	83 c7 01             	add    $0x1,%edi
  803696:	eb ac                	jmp    803644 <devpipe_write+0x20>
	return i;
  803698:	8b 45 10             	mov    0x10(%ebp),%eax
  80369b:	eb 05                	jmp    8036a2 <devpipe_write+0x7e>
				return 0;
  80369d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8036a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8036a5:	5b                   	pop    %ebx
  8036a6:	5e                   	pop    %esi
  8036a7:	5f                   	pop    %edi
  8036a8:	5d                   	pop    %ebp
  8036a9:	c3                   	ret    

008036aa <devpipe_read>:
{
  8036aa:	f3 0f 1e fb          	endbr32 
  8036ae:	55                   	push   %ebp
  8036af:	89 e5                	mov    %esp,%ebp
  8036b1:	57                   	push   %edi
  8036b2:	56                   	push   %esi
  8036b3:	53                   	push   %ebx
  8036b4:	83 ec 18             	sub    $0x18,%esp
  8036b7:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8036ba:	57                   	push   %edi
  8036bb:	e8 46 f1 ff ff       	call   802806 <fd2data>
  8036c0:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8036c2:	83 c4 10             	add    $0x10,%esp
  8036c5:	be 00 00 00 00       	mov    $0x0,%esi
  8036ca:	3b 75 10             	cmp    0x10(%ebp),%esi
  8036cd:	75 14                	jne    8036e3 <devpipe_read+0x39>
	return i;
  8036cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8036d2:	eb 02                	jmp    8036d6 <devpipe_read+0x2c>
				return i;
  8036d4:	89 f0                	mov    %esi,%eax
}
  8036d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8036d9:	5b                   	pop    %ebx
  8036da:	5e                   	pop    %esi
  8036db:	5f                   	pop    %edi
  8036dc:	5d                   	pop    %ebp
  8036dd:	c3                   	ret    
			sys_yield();
  8036de:	e8 bc ed ff ff       	call   80249f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8036e3:	8b 03                	mov    (%ebx),%eax
  8036e5:	3b 43 04             	cmp    0x4(%ebx),%eax
  8036e8:	75 18                	jne    803702 <devpipe_read+0x58>
			if (i > 0)
  8036ea:	85 f6                	test   %esi,%esi
  8036ec:	75 e6                	jne    8036d4 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8036ee:	89 da                	mov    %ebx,%edx
  8036f0:	89 f8                	mov    %edi,%eax
  8036f2:	e8 c8 fe ff ff       	call   8035bf <_pipeisclosed>
  8036f7:	85 c0                	test   %eax,%eax
  8036f9:	74 e3                	je     8036de <devpipe_read+0x34>
				return 0;
  8036fb:	b8 00 00 00 00       	mov    $0x0,%eax
  803700:	eb d4                	jmp    8036d6 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803702:	99                   	cltd   
  803703:	c1 ea 1b             	shr    $0x1b,%edx
  803706:	01 d0                	add    %edx,%eax
  803708:	83 e0 1f             	and    $0x1f,%eax
  80370b:	29 d0                	sub    %edx,%eax
  80370d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  803712:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803715:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  803718:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80371b:	83 c6 01             	add    $0x1,%esi
  80371e:	eb aa                	jmp    8036ca <devpipe_read+0x20>

00803720 <pipe>:
{
  803720:	f3 0f 1e fb          	endbr32 
  803724:	55                   	push   %ebp
  803725:	89 e5                	mov    %esp,%ebp
  803727:	56                   	push   %esi
  803728:	53                   	push   %ebx
  803729:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80372c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80372f:	50                   	push   %eax
  803730:	e8 ec f0 ff ff       	call   802821 <fd_alloc>
  803735:	89 c3                	mov    %eax,%ebx
  803737:	83 c4 10             	add    $0x10,%esp
  80373a:	85 c0                	test   %eax,%eax
  80373c:	0f 88 23 01 00 00    	js     803865 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803742:	83 ec 04             	sub    $0x4,%esp
  803745:	68 07 04 00 00       	push   $0x407
  80374a:	ff 75 f4             	pushl  -0xc(%ebp)
  80374d:	6a 00                	push   $0x0
  80374f:	e8 6e ed ff ff       	call   8024c2 <sys_page_alloc>
  803754:	89 c3                	mov    %eax,%ebx
  803756:	83 c4 10             	add    $0x10,%esp
  803759:	85 c0                	test   %eax,%eax
  80375b:	0f 88 04 01 00 00    	js     803865 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  803761:	83 ec 0c             	sub    $0xc,%esp
  803764:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803767:	50                   	push   %eax
  803768:	e8 b4 f0 ff ff       	call   802821 <fd_alloc>
  80376d:	89 c3                	mov    %eax,%ebx
  80376f:	83 c4 10             	add    $0x10,%esp
  803772:	85 c0                	test   %eax,%eax
  803774:	0f 88 db 00 00 00    	js     803855 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80377a:	83 ec 04             	sub    $0x4,%esp
  80377d:	68 07 04 00 00       	push   $0x407
  803782:	ff 75 f0             	pushl  -0x10(%ebp)
  803785:	6a 00                	push   $0x0
  803787:	e8 36 ed ff ff       	call   8024c2 <sys_page_alloc>
  80378c:	89 c3                	mov    %eax,%ebx
  80378e:	83 c4 10             	add    $0x10,%esp
  803791:	85 c0                	test   %eax,%eax
  803793:	0f 88 bc 00 00 00    	js     803855 <pipe+0x135>
	va = fd2data(fd0);
  803799:	83 ec 0c             	sub    $0xc,%esp
  80379c:	ff 75 f4             	pushl  -0xc(%ebp)
  80379f:	e8 62 f0 ff ff       	call   802806 <fd2data>
  8037a4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8037a6:	83 c4 0c             	add    $0xc,%esp
  8037a9:	68 07 04 00 00       	push   $0x407
  8037ae:	50                   	push   %eax
  8037af:	6a 00                	push   $0x0
  8037b1:	e8 0c ed ff ff       	call   8024c2 <sys_page_alloc>
  8037b6:	89 c3                	mov    %eax,%ebx
  8037b8:	83 c4 10             	add    $0x10,%esp
  8037bb:	85 c0                	test   %eax,%eax
  8037bd:	0f 88 82 00 00 00    	js     803845 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8037c3:	83 ec 0c             	sub    $0xc,%esp
  8037c6:	ff 75 f0             	pushl  -0x10(%ebp)
  8037c9:	e8 38 f0 ff ff       	call   802806 <fd2data>
  8037ce:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8037d5:	50                   	push   %eax
  8037d6:	6a 00                	push   $0x0
  8037d8:	56                   	push   %esi
  8037d9:	6a 00                	push   $0x0
  8037db:	e8 08 ed ff ff       	call   8024e8 <sys_page_map>
  8037e0:	89 c3                	mov    %eax,%ebx
  8037e2:	83 c4 20             	add    $0x20,%esp
  8037e5:	85 c0                	test   %eax,%eax
  8037e7:	78 4e                	js     803837 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8037e9:	a1 dc 90 80 00       	mov    0x8090dc,%eax
  8037ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8037f1:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8037f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8037f6:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8037fd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  803800:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  803802:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803805:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80380c:	83 ec 0c             	sub    $0xc,%esp
  80380f:	ff 75 f4             	pushl  -0xc(%ebp)
  803812:	e8 db ef ff ff       	call   8027f2 <fd2num>
  803817:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80381a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80381c:	83 c4 04             	add    $0x4,%esp
  80381f:	ff 75 f0             	pushl  -0x10(%ebp)
  803822:	e8 cb ef ff ff       	call   8027f2 <fd2num>
  803827:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80382a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80382d:	83 c4 10             	add    $0x10,%esp
  803830:	bb 00 00 00 00       	mov    $0x0,%ebx
  803835:	eb 2e                	jmp    803865 <pipe+0x145>
	sys_page_unmap(0, va);
  803837:	83 ec 08             	sub    $0x8,%esp
  80383a:	56                   	push   %esi
  80383b:	6a 00                	push   $0x0
  80383d:	e8 cb ec ff ff       	call   80250d <sys_page_unmap>
  803842:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  803845:	83 ec 08             	sub    $0x8,%esp
  803848:	ff 75 f0             	pushl  -0x10(%ebp)
  80384b:	6a 00                	push   $0x0
  80384d:	e8 bb ec ff ff       	call   80250d <sys_page_unmap>
  803852:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  803855:	83 ec 08             	sub    $0x8,%esp
  803858:	ff 75 f4             	pushl  -0xc(%ebp)
  80385b:	6a 00                	push   $0x0
  80385d:	e8 ab ec ff ff       	call   80250d <sys_page_unmap>
  803862:	83 c4 10             	add    $0x10,%esp
}
  803865:	89 d8                	mov    %ebx,%eax
  803867:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80386a:	5b                   	pop    %ebx
  80386b:	5e                   	pop    %esi
  80386c:	5d                   	pop    %ebp
  80386d:	c3                   	ret    

0080386e <pipeisclosed>:
{
  80386e:	f3 0f 1e fb          	endbr32 
  803872:	55                   	push   %ebp
  803873:	89 e5                	mov    %esp,%ebp
  803875:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803878:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80387b:	50                   	push   %eax
  80387c:	ff 75 08             	pushl  0x8(%ebp)
  80387f:	e8 f3 ef ff ff       	call   802877 <fd_lookup>
  803884:	83 c4 10             	add    $0x10,%esp
  803887:	85 c0                	test   %eax,%eax
  803889:	78 18                	js     8038a3 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  80388b:	83 ec 0c             	sub    $0xc,%esp
  80388e:	ff 75 f4             	pushl  -0xc(%ebp)
  803891:	e8 70 ef ff ff       	call   802806 <fd2data>
  803896:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  803898:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80389b:	e8 1f fd ff ff       	call   8035bf <_pipeisclosed>
  8038a0:	83 c4 10             	add    $0x10,%esp
}
  8038a3:	c9                   	leave  
  8038a4:	c3                   	ret    

008038a5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8038a5:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  8038a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8038ae:	c3                   	ret    

008038af <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8038af:	f3 0f 1e fb          	endbr32 
  8038b3:	55                   	push   %ebp
  8038b4:	89 e5                	mov    %esp,%ebp
  8038b6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8038b9:	68 0e 47 80 00       	push   $0x80470e
  8038be:	ff 75 0c             	pushl  0xc(%ebp)
  8038c1:	e8 93 e7 ff ff       	call   802059 <strcpy>
	return 0;
}
  8038c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8038cb:	c9                   	leave  
  8038cc:	c3                   	ret    

008038cd <devcons_write>:
{
  8038cd:	f3 0f 1e fb          	endbr32 
  8038d1:	55                   	push   %ebp
  8038d2:	89 e5                	mov    %esp,%ebp
  8038d4:	57                   	push   %edi
  8038d5:	56                   	push   %esi
  8038d6:	53                   	push   %ebx
  8038d7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8038dd:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8038e2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8038e8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8038eb:	73 31                	jae    80391e <devcons_write+0x51>
		m = n - tot;
  8038ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8038f0:	29 f3                	sub    %esi,%ebx
  8038f2:	83 fb 7f             	cmp    $0x7f,%ebx
  8038f5:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8038fa:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8038fd:	83 ec 04             	sub    $0x4,%esp
  803900:	53                   	push   %ebx
  803901:	89 f0                	mov    %esi,%eax
  803903:	03 45 0c             	add    0xc(%ebp),%eax
  803906:	50                   	push   %eax
  803907:	57                   	push   %edi
  803908:	e8 4a e9 ff ff       	call   802257 <memmove>
		sys_cputs(buf, m);
  80390d:	83 c4 08             	add    $0x8,%esp
  803910:	53                   	push   %ebx
  803911:	57                   	push   %edi
  803912:	e8 fc ea ff ff       	call   802413 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  803917:	01 de                	add    %ebx,%esi
  803919:	83 c4 10             	add    $0x10,%esp
  80391c:	eb ca                	jmp    8038e8 <devcons_write+0x1b>
}
  80391e:	89 f0                	mov    %esi,%eax
  803920:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803923:	5b                   	pop    %ebx
  803924:	5e                   	pop    %esi
  803925:	5f                   	pop    %edi
  803926:	5d                   	pop    %ebp
  803927:	c3                   	ret    

00803928 <devcons_read>:
{
  803928:	f3 0f 1e fb          	endbr32 
  80392c:	55                   	push   %ebp
  80392d:	89 e5                	mov    %esp,%ebp
  80392f:	83 ec 08             	sub    $0x8,%esp
  803932:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  803937:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80393b:	74 21                	je     80395e <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  80393d:	e8 f3 ea ff ff       	call   802435 <sys_cgetc>
  803942:	85 c0                	test   %eax,%eax
  803944:	75 07                	jne    80394d <devcons_read+0x25>
		sys_yield();
  803946:	e8 54 eb ff ff       	call   80249f <sys_yield>
  80394b:	eb f0                	jmp    80393d <devcons_read+0x15>
	if (c < 0)
  80394d:	78 0f                	js     80395e <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  80394f:	83 f8 04             	cmp    $0x4,%eax
  803952:	74 0c                	je     803960 <devcons_read+0x38>
	*(char*)vbuf = c;
  803954:	8b 55 0c             	mov    0xc(%ebp),%edx
  803957:	88 02                	mov    %al,(%edx)
	return 1;
  803959:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80395e:	c9                   	leave  
  80395f:	c3                   	ret    
		return 0;
  803960:	b8 00 00 00 00       	mov    $0x0,%eax
  803965:	eb f7                	jmp    80395e <devcons_read+0x36>

00803967 <cputchar>:
{
  803967:	f3 0f 1e fb          	endbr32 
  80396b:	55                   	push   %ebp
  80396c:	89 e5                	mov    %esp,%ebp
  80396e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  803971:	8b 45 08             	mov    0x8(%ebp),%eax
  803974:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  803977:	6a 01                	push   $0x1
  803979:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80397c:	50                   	push   %eax
  80397d:	e8 91 ea ff ff       	call   802413 <sys_cputs>
}
  803982:	83 c4 10             	add    $0x10,%esp
  803985:	c9                   	leave  
  803986:	c3                   	ret    

00803987 <getchar>:
{
  803987:	f3 0f 1e fb          	endbr32 
  80398b:	55                   	push   %ebp
  80398c:	89 e5                	mov    %esp,%ebp
  80398e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  803991:	6a 01                	push   $0x1
  803993:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803996:	50                   	push   %eax
  803997:	6a 00                	push   $0x0
  803999:	e8 61 f1 ff ff       	call   802aff <read>
	if (r < 0)
  80399e:	83 c4 10             	add    $0x10,%esp
  8039a1:	85 c0                	test   %eax,%eax
  8039a3:	78 06                	js     8039ab <getchar+0x24>
	if (r < 1)
  8039a5:	74 06                	je     8039ad <getchar+0x26>
	return c;
  8039a7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8039ab:	c9                   	leave  
  8039ac:	c3                   	ret    
		return -E_EOF;
  8039ad:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8039b2:	eb f7                	jmp    8039ab <getchar+0x24>

008039b4 <iscons>:
{
  8039b4:	f3 0f 1e fb          	endbr32 
  8039b8:	55                   	push   %ebp
  8039b9:	89 e5                	mov    %esp,%ebp
  8039bb:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8039be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8039c1:	50                   	push   %eax
  8039c2:	ff 75 08             	pushl  0x8(%ebp)
  8039c5:	e8 ad ee ff ff       	call   802877 <fd_lookup>
  8039ca:	83 c4 10             	add    $0x10,%esp
  8039cd:	85 c0                	test   %eax,%eax
  8039cf:	78 11                	js     8039e2 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8039d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8039d4:	8b 15 f8 90 80 00    	mov    0x8090f8,%edx
  8039da:	39 10                	cmp    %edx,(%eax)
  8039dc:	0f 94 c0             	sete   %al
  8039df:	0f b6 c0             	movzbl %al,%eax
}
  8039e2:	c9                   	leave  
  8039e3:	c3                   	ret    

008039e4 <opencons>:
{
  8039e4:	f3 0f 1e fb          	endbr32 
  8039e8:	55                   	push   %ebp
  8039e9:	89 e5                	mov    %esp,%ebp
  8039eb:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8039ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8039f1:	50                   	push   %eax
  8039f2:	e8 2a ee ff ff       	call   802821 <fd_alloc>
  8039f7:	83 c4 10             	add    $0x10,%esp
  8039fa:	85 c0                	test   %eax,%eax
  8039fc:	78 3a                	js     803a38 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8039fe:	83 ec 04             	sub    $0x4,%esp
  803a01:	68 07 04 00 00       	push   $0x407
  803a06:	ff 75 f4             	pushl  -0xc(%ebp)
  803a09:	6a 00                	push   $0x0
  803a0b:	e8 b2 ea ff ff       	call   8024c2 <sys_page_alloc>
  803a10:	83 c4 10             	add    $0x10,%esp
  803a13:	85 c0                	test   %eax,%eax
  803a15:	78 21                	js     803a38 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  803a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803a1a:	8b 15 f8 90 80 00    	mov    0x8090f8,%edx
  803a20:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803a25:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803a2c:	83 ec 0c             	sub    $0xc,%esp
  803a2f:	50                   	push   %eax
  803a30:	e8 bd ed ff ff       	call   8027f2 <fd2num>
  803a35:	83 c4 10             	add    $0x10,%esp
}
  803a38:	c9                   	leave  
  803a39:	c3                   	ret    
  803a3a:	66 90                	xchg   %ax,%ax
  803a3c:	66 90                	xchg   %ax,%ax
  803a3e:	66 90                	xchg   %ax,%ax

00803a40 <__udivdi3>:
  803a40:	f3 0f 1e fb          	endbr32 
  803a44:	55                   	push   %ebp
  803a45:	57                   	push   %edi
  803a46:	56                   	push   %esi
  803a47:	53                   	push   %ebx
  803a48:	83 ec 1c             	sub    $0x1c,%esp
  803a4b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  803a4f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  803a53:	8b 74 24 34          	mov    0x34(%esp),%esi
  803a57:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  803a5b:	85 d2                	test   %edx,%edx
  803a5d:	75 19                	jne    803a78 <__udivdi3+0x38>
  803a5f:	39 f3                	cmp    %esi,%ebx
  803a61:	76 4d                	jbe    803ab0 <__udivdi3+0x70>
  803a63:	31 ff                	xor    %edi,%edi
  803a65:	89 e8                	mov    %ebp,%eax
  803a67:	89 f2                	mov    %esi,%edx
  803a69:	f7 f3                	div    %ebx
  803a6b:	89 fa                	mov    %edi,%edx
  803a6d:	83 c4 1c             	add    $0x1c,%esp
  803a70:	5b                   	pop    %ebx
  803a71:	5e                   	pop    %esi
  803a72:	5f                   	pop    %edi
  803a73:	5d                   	pop    %ebp
  803a74:	c3                   	ret    
  803a75:	8d 76 00             	lea    0x0(%esi),%esi
  803a78:	39 f2                	cmp    %esi,%edx
  803a7a:	76 14                	jbe    803a90 <__udivdi3+0x50>
  803a7c:	31 ff                	xor    %edi,%edi
  803a7e:	31 c0                	xor    %eax,%eax
  803a80:	89 fa                	mov    %edi,%edx
  803a82:	83 c4 1c             	add    $0x1c,%esp
  803a85:	5b                   	pop    %ebx
  803a86:	5e                   	pop    %esi
  803a87:	5f                   	pop    %edi
  803a88:	5d                   	pop    %ebp
  803a89:	c3                   	ret    
  803a8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803a90:	0f bd fa             	bsr    %edx,%edi
  803a93:	83 f7 1f             	xor    $0x1f,%edi
  803a96:	75 48                	jne    803ae0 <__udivdi3+0xa0>
  803a98:	39 f2                	cmp    %esi,%edx
  803a9a:	72 06                	jb     803aa2 <__udivdi3+0x62>
  803a9c:	31 c0                	xor    %eax,%eax
  803a9e:	39 eb                	cmp    %ebp,%ebx
  803aa0:	77 de                	ja     803a80 <__udivdi3+0x40>
  803aa2:	b8 01 00 00 00       	mov    $0x1,%eax
  803aa7:	eb d7                	jmp    803a80 <__udivdi3+0x40>
  803aa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803ab0:	89 d9                	mov    %ebx,%ecx
  803ab2:	85 db                	test   %ebx,%ebx
  803ab4:	75 0b                	jne    803ac1 <__udivdi3+0x81>
  803ab6:	b8 01 00 00 00       	mov    $0x1,%eax
  803abb:	31 d2                	xor    %edx,%edx
  803abd:	f7 f3                	div    %ebx
  803abf:	89 c1                	mov    %eax,%ecx
  803ac1:	31 d2                	xor    %edx,%edx
  803ac3:	89 f0                	mov    %esi,%eax
  803ac5:	f7 f1                	div    %ecx
  803ac7:	89 c6                	mov    %eax,%esi
  803ac9:	89 e8                	mov    %ebp,%eax
  803acb:	89 f7                	mov    %esi,%edi
  803acd:	f7 f1                	div    %ecx
  803acf:	89 fa                	mov    %edi,%edx
  803ad1:	83 c4 1c             	add    $0x1c,%esp
  803ad4:	5b                   	pop    %ebx
  803ad5:	5e                   	pop    %esi
  803ad6:	5f                   	pop    %edi
  803ad7:	5d                   	pop    %ebp
  803ad8:	c3                   	ret    
  803ad9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803ae0:	89 f9                	mov    %edi,%ecx
  803ae2:	b8 20 00 00 00       	mov    $0x20,%eax
  803ae7:	29 f8                	sub    %edi,%eax
  803ae9:	d3 e2                	shl    %cl,%edx
  803aeb:	89 54 24 08          	mov    %edx,0x8(%esp)
  803aef:	89 c1                	mov    %eax,%ecx
  803af1:	89 da                	mov    %ebx,%edx
  803af3:	d3 ea                	shr    %cl,%edx
  803af5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  803af9:	09 d1                	or     %edx,%ecx
  803afb:	89 f2                	mov    %esi,%edx
  803afd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803b01:	89 f9                	mov    %edi,%ecx
  803b03:	d3 e3                	shl    %cl,%ebx
  803b05:	89 c1                	mov    %eax,%ecx
  803b07:	d3 ea                	shr    %cl,%edx
  803b09:	89 f9                	mov    %edi,%ecx
  803b0b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  803b0f:	89 eb                	mov    %ebp,%ebx
  803b11:	d3 e6                	shl    %cl,%esi
  803b13:	89 c1                	mov    %eax,%ecx
  803b15:	d3 eb                	shr    %cl,%ebx
  803b17:	09 de                	or     %ebx,%esi
  803b19:	89 f0                	mov    %esi,%eax
  803b1b:	f7 74 24 08          	divl   0x8(%esp)
  803b1f:	89 d6                	mov    %edx,%esi
  803b21:	89 c3                	mov    %eax,%ebx
  803b23:	f7 64 24 0c          	mull   0xc(%esp)
  803b27:	39 d6                	cmp    %edx,%esi
  803b29:	72 15                	jb     803b40 <__udivdi3+0x100>
  803b2b:	89 f9                	mov    %edi,%ecx
  803b2d:	d3 e5                	shl    %cl,%ebp
  803b2f:	39 c5                	cmp    %eax,%ebp
  803b31:	73 04                	jae    803b37 <__udivdi3+0xf7>
  803b33:	39 d6                	cmp    %edx,%esi
  803b35:	74 09                	je     803b40 <__udivdi3+0x100>
  803b37:	89 d8                	mov    %ebx,%eax
  803b39:	31 ff                	xor    %edi,%edi
  803b3b:	e9 40 ff ff ff       	jmp    803a80 <__udivdi3+0x40>
  803b40:	8d 43 ff             	lea    -0x1(%ebx),%eax
  803b43:	31 ff                	xor    %edi,%edi
  803b45:	e9 36 ff ff ff       	jmp    803a80 <__udivdi3+0x40>
  803b4a:	66 90                	xchg   %ax,%ax
  803b4c:	66 90                	xchg   %ax,%ax
  803b4e:	66 90                	xchg   %ax,%ax

00803b50 <__umoddi3>:
  803b50:	f3 0f 1e fb          	endbr32 
  803b54:	55                   	push   %ebp
  803b55:	57                   	push   %edi
  803b56:	56                   	push   %esi
  803b57:	53                   	push   %ebx
  803b58:	83 ec 1c             	sub    $0x1c,%esp
  803b5b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  803b5f:	8b 74 24 30          	mov    0x30(%esp),%esi
  803b63:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  803b67:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803b6b:	85 c0                	test   %eax,%eax
  803b6d:	75 19                	jne    803b88 <__umoddi3+0x38>
  803b6f:	39 df                	cmp    %ebx,%edi
  803b71:	76 5d                	jbe    803bd0 <__umoddi3+0x80>
  803b73:	89 f0                	mov    %esi,%eax
  803b75:	89 da                	mov    %ebx,%edx
  803b77:	f7 f7                	div    %edi
  803b79:	89 d0                	mov    %edx,%eax
  803b7b:	31 d2                	xor    %edx,%edx
  803b7d:	83 c4 1c             	add    $0x1c,%esp
  803b80:	5b                   	pop    %ebx
  803b81:	5e                   	pop    %esi
  803b82:	5f                   	pop    %edi
  803b83:	5d                   	pop    %ebp
  803b84:	c3                   	ret    
  803b85:	8d 76 00             	lea    0x0(%esi),%esi
  803b88:	89 f2                	mov    %esi,%edx
  803b8a:	39 d8                	cmp    %ebx,%eax
  803b8c:	76 12                	jbe    803ba0 <__umoddi3+0x50>
  803b8e:	89 f0                	mov    %esi,%eax
  803b90:	89 da                	mov    %ebx,%edx
  803b92:	83 c4 1c             	add    $0x1c,%esp
  803b95:	5b                   	pop    %ebx
  803b96:	5e                   	pop    %esi
  803b97:	5f                   	pop    %edi
  803b98:	5d                   	pop    %ebp
  803b99:	c3                   	ret    
  803b9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803ba0:	0f bd e8             	bsr    %eax,%ebp
  803ba3:	83 f5 1f             	xor    $0x1f,%ebp
  803ba6:	75 50                	jne    803bf8 <__umoddi3+0xa8>
  803ba8:	39 d8                	cmp    %ebx,%eax
  803baa:	0f 82 e0 00 00 00    	jb     803c90 <__umoddi3+0x140>
  803bb0:	89 d9                	mov    %ebx,%ecx
  803bb2:	39 f7                	cmp    %esi,%edi
  803bb4:	0f 86 d6 00 00 00    	jbe    803c90 <__umoddi3+0x140>
  803bba:	89 d0                	mov    %edx,%eax
  803bbc:	89 ca                	mov    %ecx,%edx
  803bbe:	83 c4 1c             	add    $0x1c,%esp
  803bc1:	5b                   	pop    %ebx
  803bc2:	5e                   	pop    %esi
  803bc3:	5f                   	pop    %edi
  803bc4:	5d                   	pop    %ebp
  803bc5:	c3                   	ret    
  803bc6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803bcd:	8d 76 00             	lea    0x0(%esi),%esi
  803bd0:	89 fd                	mov    %edi,%ebp
  803bd2:	85 ff                	test   %edi,%edi
  803bd4:	75 0b                	jne    803be1 <__umoddi3+0x91>
  803bd6:	b8 01 00 00 00       	mov    $0x1,%eax
  803bdb:	31 d2                	xor    %edx,%edx
  803bdd:	f7 f7                	div    %edi
  803bdf:	89 c5                	mov    %eax,%ebp
  803be1:	89 d8                	mov    %ebx,%eax
  803be3:	31 d2                	xor    %edx,%edx
  803be5:	f7 f5                	div    %ebp
  803be7:	89 f0                	mov    %esi,%eax
  803be9:	f7 f5                	div    %ebp
  803beb:	89 d0                	mov    %edx,%eax
  803bed:	31 d2                	xor    %edx,%edx
  803bef:	eb 8c                	jmp    803b7d <__umoddi3+0x2d>
  803bf1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803bf8:	89 e9                	mov    %ebp,%ecx
  803bfa:	ba 20 00 00 00       	mov    $0x20,%edx
  803bff:	29 ea                	sub    %ebp,%edx
  803c01:	d3 e0                	shl    %cl,%eax
  803c03:	89 44 24 08          	mov    %eax,0x8(%esp)
  803c07:	89 d1                	mov    %edx,%ecx
  803c09:	89 f8                	mov    %edi,%eax
  803c0b:	d3 e8                	shr    %cl,%eax
  803c0d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  803c11:	89 54 24 04          	mov    %edx,0x4(%esp)
  803c15:	8b 54 24 04          	mov    0x4(%esp),%edx
  803c19:	09 c1                	or     %eax,%ecx
  803c1b:	89 d8                	mov    %ebx,%eax
  803c1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803c21:	89 e9                	mov    %ebp,%ecx
  803c23:	d3 e7                	shl    %cl,%edi
  803c25:	89 d1                	mov    %edx,%ecx
  803c27:	d3 e8                	shr    %cl,%eax
  803c29:	89 e9                	mov    %ebp,%ecx
  803c2b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803c2f:	d3 e3                	shl    %cl,%ebx
  803c31:	89 c7                	mov    %eax,%edi
  803c33:	89 d1                	mov    %edx,%ecx
  803c35:	89 f0                	mov    %esi,%eax
  803c37:	d3 e8                	shr    %cl,%eax
  803c39:	89 e9                	mov    %ebp,%ecx
  803c3b:	89 fa                	mov    %edi,%edx
  803c3d:	d3 e6                	shl    %cl,%esi
  803c3f:	09 d8                	or     %ebx,%eax
  803c41:	f7 74 24 08          	divl   0x8(%esp)
  803c45:	89 d1                	mov    %edx,%ecx
  803c47:	89 f3                	mov    %esi,%ebx
  803c49:	f7 64 24 0c          	mull   0xc(%esp)
  803c4d:	89 c6                	mov    %eax,%esi
  803c4f:	89 d7                	mov    %edx,%edi
  803c51:	39 d1                	cmp    %edx,%ecx
  803c53:	72 06                	jb     803c5b <__umoddi3+0x10b>
  803c55:	75 10                	jne    803c67 <__umoddi3+0x117>
  803c57:	39 c3                	cmp    %eax,%ebx
  803c59:	73 0c                	jae    803c67 <__umoddi3+0x117>
  803c5b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  803c5f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  803c63:	89 d7                	mov    %edx,%edi
  803c65:	89 c6                	mov    %eax,%esi
  803c67:	89 ca                	mov    %ecx,%edx
  803c69:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  803c6e:	29 f3                	sub    %esi,%ebx
  803c70:	19 fa                	sbb    %edi,%edx
  803c72:	89 d0                	mov    %edx,%eax
  803c74:	d3 e0                	shl    %cl,%eax
  803c76:	89 e9                	mov    %ebp,%ecx
  803c78:	d3 eb                	shr    %cl,%ebx
  803c7a:	d3 ea                	shr    %cl,%edx
  803c7c:	09 d8                	or     %ebx,%eax
  803c7e:	83 c4 1c             	add    $0x1c,%esp
  803c81:	5b                   	pop    %ebx
  803c82:	5e                   	pop    %esi
  803c83:	5f                   	pop    %edi
  803c84:	5d                   	pop    %ebp
  803c85:	c3                   	ret    
  803c86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803c8d:	8d 76 00             	lea    0x0(%esi),%esi
  803c90:	29 fe                	sub    %edi,%esi
  803c92:	19 c3                	sbb    %eax,%ebx
  803c94:	89 f2                	mov    %esi,%edx
  803c96:	89 d9                	mov    %ebx,%ecx
  803c98:	e9 1d ff ff ff       	jmp    803bba <__umoddi3+0x6a>
