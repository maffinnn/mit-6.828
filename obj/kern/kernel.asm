
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	// 在kernel正式init自己的vm前 需要set up kernel自己的page directory
	// $(RELOC(entry_pgdir)) 的值是entry_pgdir的物理地址
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 50 12 00       	mov    $0x125000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 50 12 f0       	mov    $0xf0125000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 62 00 00 00       	call   f01000a0 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	f3 0f 1e fb          	endbr32 
f0100044:	55                   	push   %ebp
f0100045:	89 e5                	mov    %esp,%ebp
f0100047:	56                   	push   %esi
f0100048:	53                   	push   %ebx
f0100049:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004c:	83 3d 0c f4 2b f0 00 	cmpl   $0x0,0xf02bf40c
f0100053:	74 0f                	je     f0100064 <_panic+0x24>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100055:	83 ec 0c             	sub    $0xc,%esp
f0100058:	6a 00                	push   $0x0
f010005a:	e8 b3 0c 00 00       	call   f0100d12 <monitor>
f010005f:	83 c4 10             	add    $0x10,%esp
f0100062:	eb f1                	jmp    f0100055 <_panic+0x15>
	panicstr = fmt;
f0100064:	89 35 0c f4 2b f0    	mov    %esi,0xf02bf40c
	asm volatile("cli; cld");
f010006a:	fa                   	cli    
f010006b:	fc                   	cld    
	va_start(ap, fmt);
f010006c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006f:	e8 1a 64 00 00       	call   f010648e <cpunum>
f0100074:	ff 75 0c             	pushl  0xc(%ebp)
f0100077:	ff 75 08             	pushl  0x8(%ebp)
f010007a:	50                   	push   %eax
f010007b:	68 20 74 10 f0       	push   $0xf0107420
f0100080:	e8 ab 3d 00 00       	call   f0103e30 <cprintf>
	vcprintf(fmt, ap);
f0100085:	83 c4 08             	add    $0x8,%esp
f0100088:	53                   	push   %ebx
f0100089:	56                   	push   %esi
f010008a:	e8 77 3d 00 00       	call   f0103e06 <vcprintf>
	cprintf("\n");
f010008f:	c7 04 24 08 8a 10 f0 	movl   $0xf0108a08,(%esp)
f0100096:	e8 95 3d 00 00       	call   f0103e30 <cprintf>
f010009b:	83 c4 10             	add    $0x10,%esp
f010009e:	eb b5                	jmp    f0100055 <_panic+0x15>

f01000a0 <i386_init>:
{
f01000a0:	f3 0f 1e fb          	endbr32 
f01000a4:	55                   	push   %ebp
f01000a5:	89 e5                	mov    %esp,%ebp
f01000a7:	53                   	push   %ebx
f01000a8:	83 ec 04             	sub    $0x4,%esp
	cons_init();
f01000ab:	e8 c2 05 00 00       	call   f0100672 <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b0:	83 ec 08             	sub    $0x8,%esp
f01000b3:	68 ac 1a 00 00       	push   $0x1aac
f01000b8:	68 8c 74 10 f0       	push   $0xf010748c
f01000bd:	e8 6e 3d 00 00       	call   f0103e30 <cprintf>
	mem_init();
f01000c2:	e8 56 17 00 00       	call   f010181d <mem_init>
	env_init();
f01000c7:	e8 c6 35 00 00       	call   f0103692 <env_init>
	trap_init();
f01000cc:	e8 81 3e 00 00       	call   f0103f52 <trap_init>
	mp_init();
f01000d1:	e8 b9 60 00 00       	call   f010618f <mp_init>
	lapic_init();
f01000d6:	e8 cd 63 00 00       	call   f01064a8 <lapic_init>
	pic_init();
f01000db:	e8 4f 3c 00 00       	call   f0103d2f <pic_init>
	time_init();
f01000e0:	e8 7a 70 00 00       	call   f010715f <time_init>
	pci_init();
f01000e5:	e8 51 70 00 00       	call   f010713b <pci_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ea:	c7 04 24 c0 73 12 f0 	movl   $0xf01273c0,(%esp)
f01000f1:	e8 20 66 00 00       	call   f0106716 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f6:	83 c4 10             	add    $0x10,%esp
f01000f9:	83 3d 14 f4 2b f0 07 	cmpl   $0x7,0xf02bf414
f0100100:	76 27                	jbe    f0100129 <i386_init+0x89>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100102:	83 ec 04             	sub    $0x4,%esp
f0100105:	b8 f2 60 10 f0       	mov    $0xf01060f2,%eax
f010010a:	2d 78 60 10 f0       	sub    $0xf0106078,%eax
f010010f:	50                   	push   %eax
f0100110:	68 78 60 10 f0       	push   $0xf0106078
f0100115:	68 00 70 00 f0       	push   $0xf0007000
f010011a:	e8 9a 5d 00 00       	call   f0105eb9 <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f010011f:	83 c4 10             	add    $0x10,%esp
f0100122:	bb 20 00 2c f0       	mov    $0xf02c0020,%ebx
f0100127:	eb 53                	jmp    f010017c <i386_init+0xdc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100129:	68 00 70 00 00       	push   $0x7000
f010012e:	68 44 74 10 f0       	push   $0xf0107444
f0100133:	6a 5e                	push   $0x5e
f0100135:	68 a7 74 10 f0       	push   $0xf01074a7
f010013a:	e8 01 ff ff ff       	call   f0100040 <_panic>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010013f:	89 d8                	mov    %ebx,%eax
f0100141:	2d 20 00 2c f0       	sub    $0xf02c0020,%eax
f0100146:	c1 f8 02             	sar    $0x2,%eax
f0100149:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010014f:	c1 e0 0f             	shl    $0xf,%eax
f0100152:	8d 80 00 90 2c f0    	lea    -0xfd37000(%eax),%eax
f0100158:	a3 10 f4 2b f0       	mov    %eax,0xf02bf410
		lapic_startap(c->cpu_id, PADDR(code));
f010015d:	83 ec 08             	sub    $0x8,%esp
f0100160:	68 00 70 00 00       	push   $0x7000
f0100165:	0f b6 03             	movzbl (%ebx),%eax
f0100168:	50                   	push   %eax
f0100169:	e8 94 64 00 00       	call   f0106602 <lapic_startap>
		while(c->cpu_status != CPU_STARTED)
f010016e:	83 c4 10             	add    $0x10,%esp
f0100171:	8b 43 04             	mov    0x4(%ebx),%eax
f0100174:	83 f8 01             	cmp    $0x1,%eax
f0100177:	75 f8                	jne    f0100171 <i386_init+0xd1>
	for (c = cpus; c < cpus + ncpu; c++) {
f0100179:	83 c3 74             	add    $0x74,%ebx
f010017c:	6b 05 c4 03 2c f0 74 	imul   $0x74,0xf02c03c4,%eax
f0100183:	05 20 00 2c f0       	add    $0xf02c0020,%eax
f0100188:	39 c3                	cmp    %eax,%ebx
f010018a:	73 13                	jae    f010019f <i386_init+0xff>
		if (c == cpus + cpunum())  // We've started already.
f010018c:	e8 fd 62 00 00       	call   f010648e <cpunum>
f0100191:	6b c0 74             	imul   $0x74,%eax,%eax
f0100194:	05 20 00 2c f0       	add    $0xf02c0020,%eax
f0100199:	39 c3                	cmp    %eax,%ebx
f010019b:	74 dc                	je     f0100179 <i386_init+0xd9>
f010019d:	eb a0                	jmp    f010013f <i386_init+0x9f>
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010019f:	83 ec 08             	sub    $0x8,%esp
f01001a2:	6a 01                	push   $0x1
f01001a4:	68 b4 17 1e f0       	push   $0xf01e17b4
f01001a9:	e8 8e 36 00 00       	call   f010383c <env_create>
	ENV_CREATE(net_ns, ENV_TYPE_NS);
f01001ae:	83 c4 08             	add    $0x8,%esp
f01001b1:	6a 02                	push   $0x2
f01001b3:	68 f8 f1 23 f0       	push   $0xf023f1f8
f01001b8:	e8 7f 36 00 00       	call   f010383c <env_create>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001bd:	83 c4 08             	add    $0x8,%esp
f01001c0:	6a 00                	push   $0x0
f01001c2:	68 40 41 20 f0       	push   $0xf0204140
f01001c7:	e8 70 36 00 00       	call   f010383c <env_create>
	kbd_intr();
f01001cc:	e8 45 04 00 00       	call   f0100616 <kbd_intr>
	sched_yield();
f01001d1:	e8 fc 48 00 00       	call   f0104ad2 <sched_yield>

f01001d6 <mp_main>:
{
f01001d6:	f3 0f 1e fb          	endbr32 
f01001da:	55                   	push   %ebp
f01001db:	89 e5                	mov    %esp,%ebp
f01001dd:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01001e0:	a1 18 f4 2b f0       	mov    0xf02bf418,%eax
	if ((uint32_t)kva < KERNBASE)
f01001e5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001ea:	76 52                	jbe    f010023e <mp_main+0x68>
	return (physaddr_t)kva - KERNBASE;
f01001ec:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001f1:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001f4:	e8 95 62 00 00       	call   f010648e <cpunum>
f01001f9:	83 ec 08             	sub    $0x8,%esp
f01001fc:	50                   	push   %eax
f01001fd:	68 b3 74 10 f0       	push   $0xf01074b3
f0100202:	e8 29 3c 00 00       	call   f0103e30 <cprintf>
	lapic_init();
f0100207:	e8 9c 62 00 00       	call   f01064a8 <lapic_init>
	env_init_percpu();
f010020c:	e8 51 34 00 00       	call   f0103662 <env_init_percpu>
	trap_init_percpu();
f0100211:	e8 32 3c 00 00       	call   f0103e48 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100216:	e8 73 62 00 00       	call   f010648e <cpunum>
f010021b:	6b d0 74             	imul   $0x74,%eax,%edx
f010021e:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100221:	b8 01 00 00 00       	mov    $0x1,%eax
f0100226:	f0 87 82 20 00 2c f0 	lock xchg %eax,-0xfd3ffe0(%edx)
f010022d:	c7 04 24 c0 73 12 f0 	movl   $0xf01273c0,(%esp)
f0100234:	e8 dd 64 00 00       	call   f0106716 <spin_lock>
	sched_yield();
f0100239:	e8 94 48 00 00       	call   f0104ad2 <sched_yield>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010023e:	50                   	push   %eax
f010023f:	68 68 74 10 f0       	push   $0xf0107468
f0100244:	6a 75                	push   $0x75
f0100246:	68 a7 74 10 f0       	push   $0xf01074a7
f010024b:	e8 f0 fd ff ff       	call   f0100040 <_panic>

f0100250 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100250:	f3 0f 1e fb          	endbr32 
f0100254:	55                   	push   %ebp
f0100255:	89 e5                	mov    %esp,%ebp
f0100257:	53                   	push   %ebx
f0100258:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010025b:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010025e:	ff 75 0c             	pushl  0xc(%ebp)
f0100261:	ff 75 08             	pushl  0x8(%ebp)
f0100264:	68 c9 74 10 f0       	push   $0xf01074c9
f0100269:	e8 c2 3b 00 00       	call   f0103e30 <cprintf>
	vcprintf(fmt, ap);
f010026e:	83 c4 08             	add    $0x8,%esp
f0100271:	53                   	push   %ebx
f0100272:	ff 75 10             	pushl  0x10(%ebp)
f0100275:	e8 8c 3b 00 00       	call   f0103e06 <vcprintf>
	cprintf("\n");
f010027a:	c7 04 24 08 8a 10 f0 	movl   $0xf0108a08,(%esp)
f0100281:	e8 aa 3b 00 00       	call   f0103e30 <cprintf>
	va_end(ap);
}
f0100286:	83 c4 10             	add    $0x10,%esp
f0100289:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010028c:	c9                   	leave  
f010028d:	c3                   	ret    

f010028e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010028e:	f3 0f 1e fb          	endbr32 
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100292:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100297:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100298:	a8 01                	test   $0x1,%al
f010029a:	74 0a                	je     f01002a6 <serial_proc_data+0x18>
f010029c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002a1:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002a2:	0f b6 c0             	movzbl %al,%eax
f01002a5:	c3                   	ret    
		return -1;
f01002a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01002ab:	c3                   	ret    

f01002ac <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002ac:	55                   	push   %ebp
f01002ad:	89 e5                	mov    %esp,%ebp
f01002af:	53                   	push   %ebx
f01002b0:	83 ec 04             	sub    $0x4,%esp
f01002b3:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002b5:	ff d3                	call   *%ebx
f01002b7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002ba:	74 29                	je     f01002e5 <cons_intr+0x39>
		if (c == 0)
f01002bc:	85 c0                	test   %eax,%eax
f01002be:	74 f5                	je     f01002b5 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f01002c0:	8b 0d 24 d2 2b f0    	mov    0xf02bd224,%ecx
f01002c6:	8d 51 01             	lea    0x1(%ecx),%edx
f01002c9:	88 81 20 d0 2b f0    	mov    %al,-0xfd42fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002cf:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01002d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01002da:	0f 44 d0             	cmove  %eax,%edx
f01002dd:	89 15 24 d2 2b f0    	mov    %edx,0xf02bd224
f01002e3:	eb d0                	jmp    f01002b5 <cons_intr+0x9>
	}
}
f01002e5:	83 c4 04             	add    $0x4,%esp
f01002e8:	5b                   	pop    %ebx
f01002e9:	5d                   	pop    %ebp
f01002ea:	c3                   	ret    

f01002eb <kbd_proc_data>:
{
f01002eb:	f3 0f 1e fb          	endbr32 
f01002ef:	55                   	push   %ebp
f01002f0:	89 e5                	mov    %esp,%ebp
f01002f2:	53                   	push   %ebx
f01002f3:	83 ec 04             	sub    $0x4,%esp
f01002f6:	ba 64 00 00 00       	mov    $0x64,%edx
f01002fb:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01002fc:	a8 01                	test   $0x1,%al
f01002fe:	0f 84 f2 00 00 00    	je     f01003f6 <kbd_proc_data+0x10b>
	if (stat & KBS_TERR)
f0100304:	a8 20                	test   $0x20,%al
f0100306:	0f 85 f1 00 00 00    	jne    f01003fd <kbd_proc_data+0x112>
f010030c:	ba 60 00 00 00       	mov    $0x60,%edx
f0100311:	ec                   	in     (%dx),%al
f0100312:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100314:	3c e0                	cmp    $0xe0,%al
f0100316:	74 61                	je     f0100379 <kbd_proc_data+0x8e>
	} else if (data & 0x80) {
f0100318:	84 c0                	test   %al,%al
f010031a:	78 70                	js     f010038c <kbd_proc_data+0xa1>
	} else if (shift & E0ESC) {
f010031c:	8b 0d 00 d0 2b f0    	mov    0xf02bd000,%ecx
f0100322:	f6 c1 40             	test   $0x40,%cl
f0100325:	74 0e                	je     f0100335 <kbd_proc_data+0x4a>
		data |= 0x80;
f0100327:	83 c8 80             	or     $0xffffff80,%eax
f010032a:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010032c:	83 e1 bf             	and    $0xffffffbf,%ecx
f010032f:	89 0d 00 d0 2b f0    	mov    %ecx,0xf02bd000
	shift |= shiftcode[data];
f0100335:	0f b6 d2             	movzbl %dl,%edx
f0100338:	0f b6 82 40 76 10 f0 	movzbl -0xfef89c0(%edx),%eax
f010033f:	0b 05 00 d0 2b f0    	or     0xf02bd000,%eax
	shift ^= togglecode[data];
f0100345:	0f b6 8a 40 75 10 f0 	movzbl -0xfef8ac0(%edx),%ecx
f010034c:	31 c8                	xor    %ecx,%eax
f010034e:	a3 00 d0 2b f0       	mov    %eax,0xf02bd000
	c = charcode[shift & (CTL | SHIFT)][data];
f0100353:	89 c1                	mov    %eax,%ecx
f0100355:	83 e1 03             	and    $0x3,%ecx
f0100358:	8b 0c 8d 20 75 10 f0 	mov    -0xfef8ae0(,%ecx,4),%ecx
f010035f:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100363:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100366:	a8 08                	test   $0x8,%al
f0100368:	74 61                	je     f01003cb <kbd_proc_data+0xe0>
		if ('a' <= c && c <= 'z')
f010036a:	89 da                	mov    %ebx,%edx
f010036c:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010036f:	83 f9 19             	cmp    $0x19,%ecx
f0100372:	77 4b                	ja     f01003bf <kbd_proc_data+0xd4>
			c += 'A' - 'a';
f0100374:	83 eb 20             	sub    $0x20,%ebx
f0100377:	eb 0c                	jmp    f0100385 <kbd_proc_data+0x9a>
		shift |= E0ESC;
f0100379:	83 0d 00 d0 2b f0 40 	orl    $0x40,0xf02bd000
		return 0;
f0100380:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100385:	89 d8                	mov    %ebx,%eax
f0100387:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010038a:	c9                   	leave  
f010038b:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010038c:	8b 0d 00 d0 2b f0    	mov    0xf02bd000,%ecx
f0100392:	89 cb                	mov    %ecx,%ebx
f0100394:	83 e3 40             	and    $0x40,%ebx
f0100397:	83 e0 7f             	and    $0x7f,%eax
f010039a:	85 db                	test   %ebx,%ebx
f010039c:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010039f:	0f b6 d2             	movzbl %dl,%edx
f01003a2:	0f b6 82 40 76 10 f0 	movzbl -0xfef89c0(%edx),%eax
f01003a9:	83 c8 40             	or     $0x40,%eax
f01003ac:	0f b6 c0             	movzbl %al,%eax
f01003af:	f7 d0                	not    %eax
f01003b1:	21 c8                	and    %ecx,%eax
f01003b3:	a3 00 d0 2b f0       	mov    %eax,0xf02bd000
		return 0;
f01003b8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003bd:	eb c6                	jmp    f0100385 <kbd_proc_data+0x9a>
		else if ('A' <= c && c <= 'Z')
f01003bf:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003c2:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003c5:	83 fa 1a             	cmp    $0x1a,%edx
f01003c8:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003cb:	f7 d0                	not    %eax
f01003cd:	a8 06                	test   $0x6,%al
f01003cf:	75 b4                	jne    f0100385 <kbd_proc_data+0x9a>
f01003d1:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003d7:	75 ac                	jne    f0100385 <kbd_proc_data+0x9a>
		cprintf("Rebooting!\n");
f01003d9:	83 ec 0c             	sub    $0xc,%esp
f01003dc:	68 e3 74 10 f0       	push   $0xf01074e3
f01003e1:	e8 4a 3a 00 00       	call   f0103e30 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003e6:	b8 03 00 00 00       	mov    $0x3,%eax
f01003eb:	ba 92 00 00 00       	mov    $0x92,%edx
f01003f0:	ee                   	out    %al,(%dx)
}
f01003f1:	83 c4 10             	add    $0x10,%esp
f01003f4:	eb 8f                	jmp    f0100385 <kbd_proc_data+0x9a>
		return -1;
f01003f6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003fb:	eb 88                	jmp    f0100385 <kbd_proc_data+0x9a>
		return -1;
f01003fd:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100402:	eb 81                	jmp    f0100385 <kbd_proc_data+0x9a>

f0100404 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100404:	55                   	push   %ebp
f0100405:	89 e5                	mov    %esp,%ebp
f0100407:	57                   	push   %edi
f0100408:	56                   	push   %esi
f0100409:	53                   	push   %ebx
f010040a:	83 ec 1c             	sub    $0x1c,%esp
f010040d:	89 c1                	mov    %eax,%ecx
	for (i = 0;
f010040f:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100414:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100419:	bb 84 00 00 00       	mov    $0x84,%ebx
f010041e:	89 fa                	mov    %edi,%edx
f0100420:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100421:	a8 20                	test   $0x20,%al
f0100423:	75 13                	jne    f0100438 <cons_putc+0x34>
f0100425:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010042b:	7f 0b                	jg     f0100438 <cons_putc+0x34>
f010042d:	89 da                	mov    %ebx,%edx
f010042f:	ec                   	in     (%dx),%al
f0100430:	ec                   	in     (%dx),%al
f0100431:	ec                   	in     (%dx),%al
f0100432:	ec                   	in     (%dx),%al
	     i++)
f0100433:	83 c6 01             	add    $0x1,%esi
f0100436:	eb e6                	jmp    f010041e <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f0100438:	88 4d e7             	mov    %cl,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010043b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100440:	89 c8                	mov    %ecx,%eax
f0100442:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100443:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100448:	bf 79 03 00 00       	mov    $0x379,%edi
f010044d:	bb 84 00 00 00       	mov    $0x84,%ebx
f0100452:	89 fa                	mov    %edi,%edx
f0100454:	ec                   	in     (%dx),%al
f0100455:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010045b:	7f 0f                	jg     f010046c <cons_putc+0x68>
f010045d:	84 c0                	test   %al,%al
f010045f:	78 0b                	js     f010046c <cons_putc+0x68>
f0100461:	89 da                	mov    %ebx,%edx
f0100463:	ec                   	in     (%dx),%al
f0100464:	ec                   	in     (%dx),%al
f0100465:	ec                   	in     (%dx),%al
f0100466:	ec                   	in     (%dx),%al
f0100467:	83 c6 01             	add    $0x1,%esi
f010046a:	eb e6                	jmp    f0100452 <cons_putc+0x4e>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010046c:	ba 78 03 00 00       	mov    $0x378,%edx
f0100471:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100475:	ee                   	out    %al,(%dx)
f0100476:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010047b:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100480:	ee                   	out    %al,(%dx)
f0100481:	b8 08 00 00 00       	mov    $0x8,%eax
f0100486:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f0100487:	89 c8                	mov    %ecx,%eax
f0100489:	80 cc 07             	or     $0x7,%ah
f010048c:	f7 c1 00 ff ff ff    	test   $0xffffff00,%ecx
f0100492:	0f 44 c8             	cmove  %eax,%ecx
	switch (c & 0xff) {
f0100495:	0f b6 c1             	movzbl %cl,%eax
f0100498:	80 f9 0a             	cmp    $0xa,%cl
f010049b:	0f 84 dd 00 00 00    	je     f010057e <cons_putc+0x17a>
f01004a1:	83 f8 0a             	cmp    $0xa,%eax
f01004a4:	7f 46                	jg     f01004ec <cons_putc+0xe8>
f01004a6:	83 f8 08             	cmp    $0x8,%eax
f01004a9:	0f 84 a7 00 00 00    	je     f0100556 <cons_putc+0x152>
f01004af:	83 f8 09             	cmp    $0x9,%eax
f01004b2:	0f 85 d3 00 00 00    	jne    f010058b <cons_putc+0x187>
		cons_putc(' ');
f01004b8:	b8 20 00 00 00       	mov    $0x20,%eax
f01004bd:	e8 42 ff ff ff       	call   f0100404 <cons_putc>
		cons_putc(' ');
f01004c2:	b8 20 00 00 00       	mov    $0x20,%eax
f01004c7:	e8 38 ff ff ff       	call   f0100404 <cons_putc>
		cons_putc(' ');
f01004cc:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d1:	e8 2e ff ff ff       	call   f0100404 <cons_putc>
		cons_putc(' ');
f01004d6:	b8 20 00 00 00       	mov    $0x20,%eax
f01004db:	e8 24 ff ff ff       	call   f0100404 <cons_putc>
		cons_putc(' ');
f01004e0:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e5:	e8 1a ff ff ff       	call   f0100404 <cons_putc>
		break;
f01004ea:	eb 25                	jmp    f0100511 <cons_putc+0x10d>
	switch (c & 0xff) {
f01004ec:	83 f8 0d             	cmp    $0xd,%eax
f01004ef:	0f 85 96 00 00 00    	jne    f010058b <cons_putc+0x187>
		crt_pos -= (crt_pos % CRT_COLS);
f01004f5:	0f b7 05 28 d2 2b f0 	movzwl 0xf02bd228,%eax
f01004fc:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100502:	c1 e8 16             	shr    $0x16,%eax
f0100505:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100508:	c1 e0 04             	shl    $0x4,%eax
f010050b:	66 a3 28 d2 2b f0    	mov    %ax,0xf02bd228
	if (crt_pos >= CRT_SIZE) {
f0100511:	66 81 3d 28 d2 2b f0 	cmpw   $0x7cf,0xf02bd228
f0100518:	cf 07 
f010051a:	0f 87 8e 00 00 00    	ja     f01005ae <cons_putc+0x1aa>
	outb(addr_6845, 14);
f0100520:	8b 0d 30 d2 2b f0    	mov    0xf02bd230,%ecx
f0100526:	b8 0e 00 00 00       	mov    $0xe,%eax
f010052b:	89 ca                	mov    %ecx,%edx
f010052d:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010052e:	0f b7 1d 28 d2 2b f0 	movzwl 0xf02bd228,%ebx
f0100535:	8d 71 01             	lea    0x1(%ecx),%esi
f0100538:	89 d8                	mov    %ebx,%eax
f010053a:	66 c1 e8 08          	shr    $0x8,%ax
f010053e:	89 f2                	mov    %esi,%edx
f0100540:	ee                   	out    %al,(%dx)
f0100541:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100546:	89 ca                	mov    %ecx,%edx
f0100548:	ee                   	out    %al,(%dx)
f0100549:	89 d8                	mov    %ebx,%eax
f010054b:	89 f2                	mov    %esi,%edx
f010054d:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010054e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100551:	5b                   	pop    %ebx
f0100552:	5e                   	pop    %esi
f0100553:	5f                   	pop    %edi
f0100554:	5d                   	pop    %ebp
f0100555:	c3                   	ret    
		if (crt_pos > 0) {
f0100556:	0f b7 05 28 d2 2b f0 	movzwl 0xf02bd228,%eax
f010055d:	66 85 c0             	test   %ax,%ax
f0100560:	74 be                	je     f0100520 <cons_putc+0x11c>
			crt_pos--;
f0100562:	83 e8 01             	sub    $0x1,%eax
f0100565:	66 a3 28 d2 2b f0    	mov    %ax,0xf02bd228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010056b:	0f b7 d0             	movzwl %ax,%edx
f010056e:	b1 00                	mov    $0x0,%cl
f0100570:	83 c9 20             	or     $0x20,%ecx
f0100573:	a1 2c d2 2b f0       	mov    0xf02bd22c,%eax
f0100578:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f010057c:	eb 93                	jmp    f0100511 <cons_putc+0x10d>
		crt_pos += CRT_COLS;
f010057e:	66 83 05 28 d2 2b f0 	addw   $0x50,0xf02bd228
f0100585:	50 
f0100586:	e9 6a ff ff ff       	jmp    f01004f5 <cons_putc+0xf1>
		crt_buf[crt_pos++] = c;		/* write the character to buffer */
f010058b:	0f b7 05 28 d2 2b f0 	movzwl 0xf02bd228,%eax
f0100592:	8d 50 01             	lea    0x1(%eax),%edx
f0100595:	66 89 15 28 d2 2b f0 	mov    %dx,0xf02bd228
f010059c:	0f b7 c0             	movzwl %ax,%eax
f010059f:	8b 15 2c d2 2b f0    	mov    0xf02bd22c,%edx
f01005a5:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
		break;
f01005a9:	e9 63 ff ff ff       	jmp    f0100511 <cons_putc+0x10d>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005ae:	a1 2c d2 2b f0       	mov    0xf02bd22c,%eax
f01005b3:	83 ec 04             	sub    $0x4,%esp
f01005b6:	68 00 0f 00 00       	push   $0xf00
f01005bb:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005c1:	52                   	push   %edx
f01005c2:	50                   	push   %eax
f01005c3:	e8 f1 58 00 00       	call   f0105eb9 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01005c8:	8b 15 2c d2 2b f0    	mov    0xf02bd22c,%edx
f01005ce:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005d4:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005da:	83 c4 10             	add    $0x10,%esp
f01005dd:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005e2:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005e5:	39 d0                	cmp    %edx,%eax
f01005e7:	75 f4                	jne    f01005dd <cons_putc+0x1d9>
		crt_pos -= CRT_COLS;
f01005e9:	66 83 2d 28 d2 2b f0 	subw   $0x50,0xf02bd228
f01005f0:	50 
f01005f1:	e9 2a ff ff ff       	jmp    f0100520 <cons_putc+0x11c>

f01005f6 <serial_intr>:
{
f01005f6:	f3 0f 1e fb          	endbr32 
	if (serial_exists)
f01005fa:	80 3d 34 d2 2b f0 00 	cmpb   $0x0,0xf02bd234
f0100601:	75 01                	jne    f0100604 <serial_intr+0xe>
f0100603:	c3                   	ret    
{
f0100604:	55                   	push   %ebp
f0100605:	89 e5                	mov    %esp,%ebp
f0100607:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010060a:	b8 8e 02 10 f0       	mov    $0xf010028e,%eax
f010060f:	e8 98 fc ff ff       	call   f01002ac <cons_intr>
}
f0100614:	c9                   	leave  
f0100615:	c3                   	ret    

f0100616 <kbd_intr>:
{
f0100616:	f3 0f 1e fb          	endbr32 
f010061a:	55                   	push   %ebp
f010061b:	89 e5                	mov    %esp,%ebp
f010061d:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100620:	b8 eb 02 10 f0       	mov    $0xf01002eb,%eax
f0100625:	e8 82 fc ff ff       	call   f01002ac <cons_intr>
}
f010062a:	c9                   	leave  
f010062b:	c3                   	ret    

f010062c <cons_getc>:
{
f010062c:	f3 0f 1e fb          	endbr32 
f0100630:	55                   	push   %ebp
f0100631:	89 e5                	mov    %esp,%ebp
f0100633:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f0100636:	e8 bb ff ff ff       	call   f01005f6 <serial_intr>
	kbd_intr();
f010063b:	e8 d6 ff ff ff       	call   f0100616 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100640:	a1 20 d2 2b f0       	mov    0xf02bd220,%eax
	return 0;
f0100645:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f010064a:	3b 05 24 d2 2b f0    	cmp    0xf02bd224,%eax
f0100650:	74 1c                	je     f010066e <cons_getc+0x42>
		c = cons.buf[cons.rpos++];
f0100652:	8d 48 01             	lea    0x1(%eax),%ecx
f0100655:	0f b6 90 20 d0 2b f0 	movzbl -0xfd42fe0(%eax),%edx
			cons.rpos = 0;
f010065c:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f0100661:	b8 00 00 00 00       	mov    $0x0,%eax
f0100666:	0f 45 c1             	cmovne %ecx,%eax
f0100669:	a3 20 d2 2b f0       	mov    %eax,0xf02bd220
}
f010066e:	89 d0                	mov    %edx,%eax
f0100670:	c9                   	leave  
f0100671:	c3                   	ret    

f0100672 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100672:	f3 0f 1e fb          	endbr32 
f0100676:	55                   	push   %ebp
f0100677:	89 e5                	mov    %esp,%ebp
f0100679:	57                   	push   %edi
f010067a:	56                   	push   %esi
f010067b:	53                   	push   %ebx
f010067c:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f010067f:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100686:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010068d:	5a a5 
	if (*cp != 0xA55A) {
f010068f:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100696:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010069a:	0f 84 de 00 00 00    	je     f010077e <cons_init+0x10c>
		addr_6845 = MONO_BASE;
f01006a0:	c7 05 30 d2 2b f0 b4 	movl   $0x3b4,0xf02bd230
f01006a7:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006aa:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f01006af:	8b 3d 30 d2 2b f0    	mov    0xf02bd230,%edi
f01006b5:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006ba:	89 fa                	mov    %edi,%edx
f01006bc:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006bd:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006c0:	89 ca                	mov    %ecx,%edx
f01006c2:	ec                   	in     (%dx),%al
f01006c3:	0f b6 c0             	movzbl %al,%eax
f01006c6:	c1 e0 08             	shl    $0x8,%eax
f01006c9:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006cb:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006d0:	89 fa                	mov    %edi,%edx
f01006d2:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d3:	89 ca                	mov    %ecx,%edx
f01006d5:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01006d6:	89 35 2c d2 2b f0    	mov    %esi,0xf02bd22c
	pos |= inb(addr_6845 + 1);
f01006dc:	0f b6 c0             	movzbl %al,%eax
f01006df:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01006e1:	66 a3 28 d2 2b f0    	mov    %ax,0xf02bd228
	kbd_intr();
f01006e7:	e8 2a ff ff ff       	call   f0100616 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006ec:	83 ec 0c             	sub    $0xc,%esp
f01006ef:	0f b7 05 a8 73 12 f0 	movzwl 0xf01273a8,%eax
f01006f6:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006fb:	50                   	push   %eax
f01006fc:	e8 ac 35 00 00       	call   f0103cad <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100701:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100706:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f010070b:	89 d8                	mov    %ebx,%eax
f010070d:	89 ca                	mov    %ecx,%edx
f010070f:	ee                   	out    %al,(%dx)
f0100710:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100715:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010071a:	89 fa                	mov    %edi,%edx
f010071c:	ee                   	out    %al,(%dx)
f010071d:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100722:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100727:	ee                   	out    %al,(%dx)
f0100728:	be f9 03 00 00       	mov    $0x3f9,%esi
f010072d:	89 d8                	mov    %ebx,%eax
f010072f:	89 f2                	mov    %esi,%edx
f0100731:	ee                   	out    %al,(%dx)
f0100732:	b8 03 00 00 00       	mov    $0x3,%eax
f0100737:	89 fa                	mov    %edi,%edx
f0100739:	ee                   	out    %al,(%dx)
f010073a:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010073f:	89 d8                	mov    %ebx,%eax
f0100741:	ee                   	out    %al,(%dx)
f0100742:	b8 01 00 00 00       	mov    $0x1,%eax
f0100747:	89 f2                	mov    %esi,%edx
f0100749:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010074a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010074f:	ec                   	in     (%dx),%al
f0100750:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100752:	83 c4 10             	add    $0x10,%esp
f0100755:	3c ff                	cmp    $0xff,%al
f0100757:	0f 95 05 34 d2 2b f0 	setne  0xf02bd234
f010075e:	89 ca                	mov    %ecx,%edx
f0100760:	ec                   	in     (%dx),%al
f0100761:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100766:	ec                   	in     (%dx),%al
	if (serial_exists)
f0100767:	80 fb ff             	cmp    $0xff,%bl
f010076a:	75 2d                	jne    f0100799 <cons_init+0x127>
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
		cprintf("Serial port does not exist!\n");
f010076c:	83 ec 0c             	sub    $0xc,%esp
f010076f:	68 ef 74 10 f0       	push   $0xf01074ef
f0100774:	e8 b7 36 00 00       	call   f0103e30 <cprintf>
f0100779:	83 c4 10             	add    $0x10,%esp
}
f010077c:	eb 3c                	jmp    f01007ba <cons_init+0x148>
		*cp = was;
f010077e:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100785:	c7 05 30 d2 2b f0 d4 	movl   $0x3d4,0xf02bd230
f010078c:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010078f:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100794:	e9 16 ff ff ff       	jmp    f01006af <cons_init+0x3d>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100799:	83 ec 0c             	sub    $0xc,%esp
f010079c:	0f b7 05 a8 73 12 f0 	movzwl 0xf01273a8,%eax
f01007a3:	25 ef ff 00 00       	and    $0xffef,%eax
f01007a8:	50                   	push   %eax
f01007a9:	e8 ff 34 00 00       	call   f0103cad <irq_setmask_8259A>
	if (!serial_exists)
f01007ae:	83 c4 10             	add    $0x10,%esp
f01007b1:	80 3d 34 d2 2b f0 00 	cmpb   $0x0,0xf02bd234
f01007b8:	74 b2                	je     f010076c <cons_init+0xfa>
}
f01007ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007bd:	5b                   	pop    %ebx
f01007be:	5e                   	pop    %esi
f01007bf:	5f                   	pop    %edi
f01007c0:	5d                   	pop    %ebp
f01007c1:	c3                   	ret    

f01007c2 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007c2:	f3 0f 1e fb          	endbr32 
f01007c6:	55                   	push   %ebp
f01007c7:	89 e5                	mov    %esp,%ebp
f01007c9:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01007cf:	e8 30 fc ff ff       	call   f0100404 <cons_putc>
}
f01007d4:	c9                   	leave  
f01007d5:	c3                   	ret    

f01007d6 <getchar>:

int
getchar(void)
{
f01007d6:	f3 0f 1e fb          	endbr32 
f01007da:	55                   	push   %ebp
f01007db:	89 e5                	mov    %esp,%ebp
f01007dd:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007e0:	e8 47 fe ff ff       	call   f010062c <cons_getc>
f01007e5:	85 c0                	test   %eax,%eax
f01007e7:	74 f7                	je     f01007e0 <getchar+0xa>
		/* do nothing */;
	return c;
}
f01007e9:	c9                   	leave  
f01007ea:	c3                   	ret    

f01007eb <iscons>:

int
iscons(int fdnum)
{
f01007eb:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f01007ef:	b8 01 00 00 00       	mov    $0x1,%eax
f01007f4:	c3                   	ret    

f01007f5 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007f5:	f3 0f 1e fb          	endbr32 
f01007f9:	55                   	push   %ebp
f01007fa:	89 e5                	mov    %esp,%ebp
f01007fc:	56                   	push   %esi
f01007fd:	53                   	push   %ebx
f01007fe:	bb 20 7c 10 f0       	mov    $0xf0107c20,%ebx
f0100803:	be 68 7c 10 f0       	mov    $0xf0107c68,%esi
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100808:	83 ec 04             	sub    $0x4,%esp
f010080b:	ff 73 04             	pushl  0x4(%ebx)
f010080e:	ff 33                	pushl  (%ebx)
f0100810:	68 40 77 10 f0       	push   $0xf0107740
f0100815:	e8 16 36 00 00       	call   f0103e30 <cprintf>
f010081a:	83 c3 0c             	add    $0xc,%ebx
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f010081d:	83 c4 10             	add    $0x10,%esp
f0100820:	39 f3                	cmp    %esi,%ebx
f0100822:	75 e4                	jne    f0100808 <mon_help+0x13>
	return 0;
}
f0100824:	b8 00 00 00 00       	mov    $0x0,%eax
f0100829:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010082c:	5b                   	pop    %ebx
f010082d:	5e                   	pop    %esi
f010082e:	5d                   	pop    %ebp
f010082f:	c3                   	ret    

f0100830 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100830:	f3 0f 1e fb          	endbr32 
f0100834:	55                   	push   %ebp
f0100835:	89 e5                	mov    %esp,%ebp
f0100837:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010083a:	68 49 77 10 f0       	push   $0xf0107749
f010083f:	e8 ec 35 00 00       	call   f0103e30 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100844:	83 c4 08             	add    $0x8,%esp
f0100847:	68 0c 00 10 00       	push   $0x10000c
f010084c:	68 84 78 10 f0       	push   $0xf0107884
f0100851:	e8 da 35 00 00       	call   f0103e30 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100856:	83 c4 0c             	add    $0xc,%esp
f0100859:	68 0c 00 10 00       	push   $0x10000c
f010085e:	68 0c 00 10 f0       	push   $0xf010000c
f0100863:	68 ac 78 10 f0       	push   $0xf01078ac
f0100868:	e8 c3 35 00 00       	call   f0103e30 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010086d:	83 c4 0c             	add    $0xc,%esp
f0100870:	68 0d 74 10 00       	push   $0x10740d
f0100875:	68 0d 74 10 f0       	push   $0xf010740d
f010087a:	68 d0 78 10 f0       	push   $0xf01078d0
f010087f:	e8 ac 35 00 00       	call   f0103e30 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100884:	83 c4 0c             	add    $0xc,%esp
f0100887:	68 00 d0 2b 00       	push   $0x2bd000
f010088c:	68 00 d0 2b f0       	push   $0xf02bd000
f0100891:	68 f4 78 10 f0       	push   $0xf01078f4
f0100896:	e8 95 35 00 00       	call   f0103e30 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010089b:	83 c4 0c             	add    $0xc,%esp
f010089e:	68 00 a7 34 00       	push   $0x34a700
f01008a3:	68 00 a7 34 f0       	push   $0xf034a700
f01008a8:	68 18 79 10 f0       	push   $0xf0107918
f01008ad:	e8 7e 35 00 00       	call   f0103e30 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008b2:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01008b5:	b8 00 a7 34 f0       	mov    $0xf034a700,%eax
f01008ba:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008bf:	c1 f8 0a             	sar    $0xa,%eax
f01008c2:	50                   	push   %eax
f01008c3:	68 3c 79 10 f0       	push   $0xf010793c
f01008c8:	e8 63 35 00 00       	call   f0103e30 <cprintf>
	return 0;
}
f01008cd:	b8 00 00 00 00       	mov    $0x0,%eax
f01008d2:	c9                   	leave  
f01008d3:	c3                   	ret    

f01008d4 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008d4:	f3 0f 1e fb          	endbr32 
f01008d8:	55                   	push   %ebp
f01008d9:	89 e5                	mov    %esp,%ebp
f01008db:	57                   	push   %edi
f01008dc:	56                   	push   %esi
f01008dd:	53                   	push   %ebx
f01008de:	83 ec 38             	sub    $0x38,%esp
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008e1:	89 eb                	mov    %ebp,%ebx
	 *
	*/

	uint32_t* ebp = (uint32_t*) read_ebp();

	cprintf("Stack backtrace:\n");
f01008e3:	68 62 77 10 f0       	push   $0xf0107762
f01008e8:	e8 43 35 00 00       	call   f0103e30 <cprintf>
	// while loop的返回条件：
	// 		在entry.S中， 
	//				movl  $0x0,%ebp  # nuke frame pointer
	while(ebp)
f01008ed:	83 c4 10             	add    $0x10,%esp
	{	
		uint32_t eip = *(ebp+1);
		struct Eipdebuginfo info; 
		debuginfo_eip(eip, &info);
f01008f0:	8d 7d d0             	lea    -0x30(%ebp),%edi
	while(ebp)
f01008f3:	85 db                	test   %ebx,%ebx
f01008f5:	74 4c                	je     f0100943 <mon_backtrace+0x6f>
		uint32_t eip = *(ebp+1);
f01008f7:	8b 73 04             	mov    0x4(%ebx),%esi
		debuginfo_eip(eip, &info);
f01008fa:	83 ec 08             	sub    $0x8,%esp
f01008fd:	57                   	push   %edi
f01008fe:	56                   	push   %esi
f01008ff:	e8 d9 49 00 00       	call   f01052dd <debuginfo_eip>
		
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",ebp, eip,
f0100904:	ff 73 18             	pushl  0x18(%ebx)
f0100907:	ff 73 14             	pushl  0x14(%ebx)
f010090a:	ff 73 10             	pushl  0x10(%ebx)
f010090d:	ff 73 0c             	pushl  0xc(%ebx)
f0100910:	ff 73 08             	pushl  0x8(%ebx)
f0100913:	56                   	push   %esi
f0100914:	53                   	push   %ebx
f0100915:	68 68 79 10 f0       	push   $0xf0107968
f010091a:	e8 11 35 00 00       	call   f0103e30 <cprintf>
			*(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6));
		
		cprintf("\t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, eip-info.eip_fn_addr);
f010091f:	83 c4 28             	add    $0x28,%esp
f0100922:	2b 75 e0             	sub    -0x20(%ebp),%esi
f0100925:	56                   	push   %esi
f0100926:	ff 75 d8             	pushl  -0x28(%ebp)
f0100929:	ff 75 dc             	pushl  -0x24(%ebp)
f010092c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010092f:	ff 75 d0             	pushl  -0x30(%ebp)
f0100932:	68 74 77 10 f0       	push   $0xf0107774
f0100937:	e8 f4 34 00 00       	call   f0103e30 <cprintf>
		
		// *ebp 取%ebp指向的old ebp值是一个地址 再强转成指针而类型
		ebp = (uint32_t*)*ebp; 
f010093c:	8b 1b                	mov    (%ebx),%ebx
f010093e:	83 c4 20             	add    $0x20,%esp
f0100941:	eb b0                	jmp    f01008f3 <mon_backtrace+0x1f>
	}
	
	return 0;
}
f0100943:	b8 00 00 00 00       	mov    $0x0,%eax
f0100948:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010094b:	5b                   	pop    %ebx
f010094c:	5e                   	pop    %esi
f010094d:	5f                   	pop    %edi
f010094e:	5d                   	pop    %ebp
f010094f:	c3                   	ret    

f0100950 <mon_showmapping>:

// showmapping [va_start, va_end)
int
mon_showmapping(int argc, char** argv, struct Trapframe* tf)
{
f0100950:	f3 0f 1e fb          	endbr32 
f0100954:	55                   	push   %ebp
f0100955:	89 e5                	mov    %esp,%ebp
f0100957:	57                   	push   %edi
f0100958:	56                   	push   %esi
f0100959:	53                   	push   %ebx
f010095a:	83 ec 0c             	sub    $0xc,%esp
f010095d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (argc < 3) { cprintf("Usage: showmapping [virtual addr] [virtual addr]\n"); return 0;}
f0100960:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100964:	7e 33                	jle    f0100999 <mon_showmapping+0x49>

	pte_t* pg_tbl_entry;
	uint32_t va_start = 0x0, va_end=0x0; 

	va_start = atox(argv[1]);
f0100966:	83 ec 0c             	sub    $0xc,%esp
f0100969:	ff 73 04             	pushl  0x4(%ebx)
f010096c:	e8 94 54 00 00       	call   f0105e05 <atox>
f0100971:	89 c6                	mov    %eax,%esi
	va_end = atox(argv[2]);
f0100973:	83 c4 04             	add    $0x4,%esp
f0100976:	ff 73 08             	pushl  0x8(%ebx)
f0100979:	e8 87 54 00 00       	call   f0105e05 <atox>
	va_end = ROUNDDOWN(va_end, PGSIZE);
f010097e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100983:	89 c7                	mov    %eax,%edi

	cprintf("VA               PA                 PERMISSION\n");
f0100985:	c7 04 24 d4 79 10 f0 	movl   $0xf01079d4,(%esp)
f010098c:	e8 9f 34 00 00       	call   f0103e30 <cprintf>
	for (;va_start<=va_end; va_start+=PGSIZE){
f0100991:	83 c4 10             	add    $0x10,%esp
f0100994:	e9 82 00 00 00       	jmp    f0100a1b <mon_showmapping+0xcb>
	if (argc < 3) { cprintf("Usage: showmapping [virtual addr] [virtual addr]\n"); return 0;}
f0100999:	83 ec 0c             	sub    $0xc,%esp
f010099c:	68 a0 79 10 f0       	push   $0xf01079a0
f01009a1:	e8 8a 34 00 00       	call   f0103e30 <cprintf>
f01009a6:	83 c4 10             	add    $0x10,%esp
			cprintf("\n");
		} 

	}
	return 0;
}
f01009a9:	b8 00 00 00 00       	mov    $0x0,%eax
f01009ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009b1:	5b                   	pop    %ebx
f01009b2:	5e                   	pop    %esi
f01009b3:	5f                   	pop    %edi
f01009b4:	5d                   	pop    %ebp
f01009b5:	c3                   	ret    
			cprintf("%08x         %08x           ---\n", 
f01009b6:	83 ec 04             	sub    $0x4,%esp
f01009b9:	6a ff                	push   $0xffffffff
f01009bb:	56                   	push   %esi
f01009bc:	68 04 7a 10 f0       	push   $0xf0107a04
f01009c1:	e8 6a 34 00 00       	call   f0103e30 <cprintf>
f01009c6:	83 c4 10             	add    $0x10,%esp
f01009c9:	eb 4a                	jmp    f0100a15 <mon_showmapping+0xc5>
			else cprintf("-");
f01009cb:	83 ec 0c             	sub    $0xc,%esp
f01009ce:	68 a2 77 10 f0       	push   $0xf01077a2
f01009d3:	e8 58 34 00 00       	call   f0103e30 <cprintf>
f01009d8:	83 c4 10             	add    $0x10,%esp
f01009db:	e9 9a 00 00 00       	jmp    f0100a7a <mon_showmapping+0x12a>
			else cprintf("-");
f01009e0:	83 ec 0c             	sub    $0xc,%esp
f01009e3:	68 a2 77 10 f0       	push   $0xf01077a2
f01009e8:	e8 43 34 00 00       	call   f0103e30 <cprintf>
f01009ed:	83 c4 10             	add    $0x10,%esp
f01009f0:	e9 9e 00 00 00       	jmp    f0100a93 <mon_showmapping+0x143>
			else cprintf("-");
f01009f5:	83 ec 0c             	sub    $0xc,%esp
f01009f8:	68 a2 77 10 f0       	push   $0xf01077a2
f01009fd:	e8 2e 34 00 00       	call   f0103e30 <cprintf>
f0100a02:	83 c4 10             	add    $0x10,%esp
			cprintf("\n");
f0100a05:	83 ec 0c             	sub    $0xc,%esp
f0100a08:	68 08 8a 10 f0       	push   $0xf0108a08
f0100a0d:	e8 1e 34 00 00       	call   f0103e30 <cprintf>
f0100a12:	83 c4 10             	add    $0x10,%esp
	for (;va_start<=va_end; va_start+=PGSIZE){
f0100a15:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0100a1b:	39 fe                	cmp    %edi,%esi
f0100a1d:	77 8a                	ja     f01009a9 <mon_showmapping+0x59>
		pg_tbl_entry = pgdir_walk(kern_pgdir, (void*)va_start, 0);
f0100a1f:	83 ec 04             	sub    $0x4,%esp
f0100a22:	6a 00                	push   $0x0
f0100a24:	56                   	push   %esi
f0100a25:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f0100a2b:	e8 6c 0a 00 00       	call   f010149c <pgdir_walk>
f0100a30:	89 c3                	mov    %eax,%ebx
		if (pg_tbl_entry == NULL){
f0100a32:	83 c4 10             	add    $0x10,%esp
f0100a35:	85 c0                	test   %eax,%eax
f0100a37:	0f 84 79 ff ff ff    	je     f01009b6 <mon_showmapping+0x66>
			cprintf("%08x         %08x           ", 
f0100a3d:	83 ec 04             	sub    $0x4,%esp
					PTE_ADDR(pg_tbl_entry[PTX(va_start)]));
f0100a40:	89 f0                	mov    %esi,%eax
f0100a42:	c1 e8 0c             	shr    $0xc,%eax
f0100a45:	25 ff 03 00 00       	and    $0x3ff,%eax
			cprintf("%08x         %08x           ", 
f0100a4a:	8b 04 83             	mov    (%ebx,%eax,4),%eax
f0100a4d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a52:	50                   	push   %eax
f0100a53:	56                   	push   %esi
f0100a54:	68 85 77 10 f0       	push   $0xf0107785
f0100a59:	e8 d2 33 00 00       	call   f0103e30 <cprintf>
			if ((*pg_tbl_entry)&PTE_P) cprintf("p");
f0100a5e:	83 c4 10             	add    $0x10,%esp
f0100a61:	f6 03 01             	testb  $0x1,(%ebx)
f0100a64:	0f 84 61 ff ff ff    	je     f01009cb <mon_showmapping+0x7b>
f0100a6a:	83 ec 0c             	sub    $0xc,%esp
f0100a6d:	68 1f 78 10 f0       	push   $0xf010781f
f0100a72:	e8 b9 33 00 00       	call   f0103e30 <cprintf>
f0100a77:	83 c4 10             	add    $0x10,%esp
			if ((*pg_tbl_entry)&PTE_W) cprintf("w");
f0100a7a:	f6 03 02             	testb  $0x2,(%ebx)
f0100a7d:	0f 84 5d ff ff ff    	je     f01009e0 <mon_showmapping+0x90>
f0100a83:	83 ec 0c             	sub    $0xc,%esp
f0100a86:	68 ad 8d 10 f0       	push   $0xf0108dad
f0100a8b:	e8 a0 33 00 00       	call   f0103e30 <cprintf>
f0100a90:	83 c4 10             	add    $0x10,%esp
			if ((*pg_tbl_entry)&PTE_U) cprintf("u");
f0100a93:	f6 03 04             	testb  $0x4,(%ebx)
f0100a96:	0f 84 59 ff ff ff    	je     f01009f5 <mon_showmapping+0xa5>
f0100a9c:	83 ec 0c             	sub    $0xc,%esp
f0100a9f:	68 a4 77 10 f0       	push   $0xf01077a4
f0100aa4:	e8 87 33 00 00       	call   f0103e30 <cprintf>
f0100aa9:	83 c4 10             	add    $0x10,%esp
f0100aac:	e9 54 ff ff ff       	jmp    f0100a05 <mon_showmapping+0xb5>

f0100ab1 <mon_chmod>:

// + add - remove = set
// e.g. chmod +pw va0 --> to add PTE_P and PTE_W to page at va0
int 
mon_chmod(int argc, char** argv, struct Trapframe* tf)
{
f0100ab1:	f3 0f 1e fb          	endbr32 
f0100ab5:	55                   	push   %ebp
f0100ab6:	89 e5                	mov    %esp,%ebp
f0100ab8:	56                   	push   %esi
f0100ab9:	53                   	push   %ebx
f0100aba:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc < 3) { cprintf("Usage: chmod [+/-/=PERMISSIONS] [virtual addr]\n"); return 0;}
f0100abd:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100ac1:	7e 4e                	jle    f0100b11 <mon_chmod+0x60>

	char* p = argv[1];
f0100ac3:	8b 5e 04             	mov    0x4(%esi),%ebx
	uint32_t va = atox(argv[2]);
f0100ac6:	83 ec 0c             	sub    $0xc,%esp
f0100ac9:	ff 76 08             	pushl  0x8(%esi)
f0100acc:	e8 34 53 00 00       	call   f0105e05 <atox>
	va = ROUNDDOWN(va, PGSIZE);

	pte_t* pg_tbl_entry = pgdir_walk(kern_pgdir, (void*)va, 1);// 如果不存在这样一个page就create一个page并修改权限
f0100ad1:	83 c4 0c             	add    $0xc,%esp
f0100ad4:	6a 01                	push   $0x1
	va = ROUNDDOWN(va, PGSIZE);
f0100ad6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	pte_t* pg_tbl_entry = pgdir_walk(kern_pgdir, (void*)va, 1);// 如果不存在这样一个page就create一个page并修改权限
f0100adb:	50                   	push   %eax
f0100adc:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f0100ae2:	e8 b5 09 00 00       	call   f010149c <pgdir_walk>
	switch (argv[1][0])
f0100ae7:	8b 56 04             	mov    0x4(%esi),%edx
f0100aea:	0f b6 12             	movzbl (%edx),%edx
f0100aed:	83 c4 10             	add    $0x10,%esp
f0100af0:	80 fa 2d             	cmp    $0x2d,%dl
f0100af3:	74 38                	je     f0100b2d <mon_chmod+0x7c>
f0100af5:	80 fa 3d             	cmp    $0x3d,%dl
f0100af8:	74 60                	je     f0100b5a <mon_chmod+0xa9>
f0100afa:	80 fa 2b             	cmp    $0x2b,%dl
f0100afd:	74 61                	je     f0100b60 <mon_chmod+0xaf>
				*pg_tbl_entry |= PTE_U;
			if (*p=='-') continue;
		}
		break;
	default:
		cprintf("please enter correct command\n");
f0100aff:	83 ec 0c             	sub    $0xc,%esp
f0100b02:	68 a6 77 10 f0       	push   $0xf01077a6
f0100b07:	e8 24 33 00 00       	call   f0103e30 <cprintf>
		break;
f0100b0c:	83 c4 10             	add    $0x10,%esp
f0100b0f:	eb 10                	jmp    f0100b21 <mon_chmod+0x70>
	if (argc < 3) { cprintf("Usage: chmod [+/-/=PERMISSIONS] [virtual addr]\n"); return 0;}
f0100b11:	83 ec 0c             	sub    $0xc,%esp
f0100b14:	68 28 7a 10 f0       	push   $0xf0107a28
f0100b19:	e8 12 33 00 00       	call   f0103e30 <cprintf>
f0100b1e:	83 c4 10             	add    $0x10,%esp
	}

	return 0;
}
f0100b21:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b26:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b29:	5b                   	pop    %ebx
f0100b2a:	5e                   	pop    %esi
f0100b2b:	5d                   	pop    %ebp
f0100b2c:	c3                   	ret    
		for(p=p+1;*p!='\0'; p++){
f0100b2d:	8d 53 01             	lea    0x1(%ebx),%edx
f0100b30:	eb 0d                	jmp    f0100b3f <mon_chmod+0x8e>
				*pg_tbl_entry &= ~PTE_P;
f0100b32:	83 20 fe             	andl   $0xfffffffe,(%eax)
f0100b35:	eb 14                	jmp    f0100b4b <mon_chmod+0x9a>
				*pg_tbl_entry &= ~PTE_W;
f0100b37:	83 20 fd             	andl   $0xfffffffd,(%eax)
f0100b3a:	eb 14                	jmp    f0100b50 <mon_chmod+0x9f>
		for(p=p+1;*p!='\0'; p++){
f0100b3c:	83 c2 01             	add    $0x1,%edx
f0100b3f:	0f b6 0a             	movzbl (%edx),%ecx
f0100b42:	84 c9                	test   %cl,%cl
f0100b44:	74 db                	je     f0100b21 <mon_chmod+0x70>
			if (*p=='p')
f0100b46:	80 f9 70             	cmp    $0x70,%cl
f0100b49:	74 e7                	je     f0100b32 <mon_chmod+0x81>
			if (*p=='w')
f0100b4b:	80 3a 77             	cmpb   $0x77,(%edx)
f0100b4e:	74 e7                	je     f0100b37 <mon_chmod+0x86>
			if (*p=='u')
f0100b50:	80 3a 75             	cmpb   $0x75,(%edx)
f0100b53:	75 e7                	jne    f0100b3c <mon_chmod+0x8b>
				*pg_tbl_entry &= ~PTE_U;
f0100b55:	83 20 fb             	andl   $0xfffffffb,(%eax)
f0100b58:	eb e2                	jmp    f0100b3c <mon_chmod+0x8b>
		*pg_tbl_entry &= ~0xFFF;
f0100b5a:	81 20 00 f0 ff ff    	andl   $0xfffff000,(%eax)
		for(p=p+1;*p!='\0'; p++){
f0100b60:	8d 53 01             	lea    0x1(%ebx),%edx
f0100b63:	eb 0d                	jmp    f0100b72 <mon_chmod+0xc1>
				*pg_tbl_entry |= PTE_P;
f0100b65:	83 08 01             	orl    $0x1,(%eax)
f0100b68:	eb 14                	jmp    f0100b7e <mon_chmod+0xcd>
				*pg_tbl_entry |= PTE_W;
f0100b6a:	83 08 02             	orl    $0x2,(%eax)
f0100b6d:	eb 14                	jmp    f0100b83 <mon_chmod+0xd2>
		for(p=p+1;*p!='\0'; p++){
f0100b6f:	83 c2 01             	add    $0x1,%edx
f0100b72:	0f b6 0a             	movzbl (%edx),%ecx
f0100b75:	84 c9                	test   %cl,%cl
f0100b77:	74 a8                	je     f0100b21 <mon_chmod+0x70>
			if (*p=='p')
f0100b79:	80 f9 70             	cmp    $0x70,%cl
f0100b7c:	74 e7                	je     f0100b65 <mon_chmod+0xb4>
			if (*p=='w')
f0100b7e:	80 3a 77             	cmpb   $0x77,(%edx)
f0100b81:	74 e7                	je     f0100b6a <mon_chmod+0xb9>
			if (*p=='u')
f0100b83:	80 3a 75             	cmpb   $0x75,(%edx)
f0100b86:	75 e7                	jne    f0100b6f <mon_chmod+0xbe>
				*pg_tbl_entry |= PTE_U;
f0100b88:	83 08 04             	orl    $0x4,(%eax)
f0100b8b:	eb e2                	jmp    f0100b6f <mon_chmod+0xbe>

f0100b8d <mon_dump>:

// dump -v [va0, va1)
// dump -p [pa0, pa1)
int
mon_dump(int argc, char** argv, struct Trapframe* tf)
{
f0100b8d:	f3 0f 1e fb          	endbr32 
f0100b91:	55                   	push   %ebp
f0100b92:	89 e5                	mov    %esp,%ebp
f0100b94:	57                   	push   %edi
f0100b95:	56                   	push   %esi
f0100b96:	53                   	push   %ebx
f0100b97:	83 ec 1c             	sub    $0x1c,%esp
f0100b9a:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc < 4) { cprintf("Usage: dump [-v/p] [addr] [addr]\n"); return 0;}
f0100b9d:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100ba1:	7e 46                	jle    f0100be9 <mon_dump+0x5c>
	 * 这里p的类型必须是unsigned char* 而不是单单char* 
	 * 原因：有一些内存值会超过CHAR_MAX i.e. char的range在[-2^8, 2^8-1], 会自动sign extension一堆ffff 
	 * 		 需要使用unsigned char来hold这些value
	*/
	unsigned char* p;
	if (argv[1][1]=='p'){
f0100ba3:	8b 46 04             	mov    0x4(%esi),%eax
f0100ba6:	80 78 01 70          	cmpb   $0x70,0x1(%eax)
f0100baa:	74 5a                	je     f0100c06 <mon_dump+0x79>
		// translate physical address into virtual address
		va_start = (uint32_t)KADDR(atox(argv[2]));
		va_end = (uint32_t)KADDR(atox(argv[3]));
	}else{
		va_start = atox(argv[2]);
f0100bac:	83 ec 0c             	sub    $0xc,%esp
f0100baf:	ff 76 08             	pushl  0x8(%esi)
f0100bb2:	e8 4e 52 00 00       	call   f0105e05 <atox>
f0100bb7:	89 c3                	mov    %eax,%ebx
		va_end = atox(argv[3]);
f0100bb9:	83 c4 04             	add    $0x4,%esp
f0100bbc:	ff 76 0c             	pushl  0xc(%esi)
f0100bbf:	e8 41 52 00 00       	call   f0105e05 <atox>
f0100bc4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100bc7:	83 c4 10             	add    $0x10,%esp
	}

	va_start = ROUNDDOWN(va_start, PGSIZE);
f0100bca:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0100bd0:	89 5d e0             	mov    %ebx,-0x20(%ebp)
f0100bd3:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi

	// 指针内存的是地址 而指针的偏移量由其type决定
	for (; va_start<= ROUNDDOWN(va_end, PGSIZE); va_start+=PGSIZE){
f0100bd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bdc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100be1:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100be4:	e9 b0 00 00 00       	jmp    f0100c99 <mon_dump+0x10c>
	if (argc < 4) { cprintf("Usage: dump [-v/p] [addr] [addr]\n"); return 0;}
f0100be9:	83 ec 0c             	sub    $0xc,%esp
f0100bec:	68 58 7a 10 f0       	push   $0xf0107a58
f0100bf1:	e8 3a 32 00 00       	call   f0103e30 <cprintf>
f0100bf6:	83 c4 10             	add    $0x10,%esp
			cprintf("\n");
		}
	}

	return 0;
}
f0100bf9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c01:	5b                   	pop    %ebx
f0100c02:	5e                   	pop    %esi
f0100c03:	5f                   	pop    %edi
f0100c04:	5d                   	pop    %ebp
f0100c05:	c3                   	ret    
		va_start = (uint32_t)KADDR(atox(argv[2]));
f0100c06:	83 ec 0c             	sub    $0xc,%esp
f0100c09:	ff 76 08             	pushl  0x8(%esi)
f0100c0c:	e8 f4 51 00 00       	call   f0105e05 <atox>
f0100c11:	89 c3                	mov    %eax,%ebx
	if (PGNUM(pa) >= npages)
f0100c13:	c1 e8 0c             	shr    $0xc,%eax
f0100c16:	83 c4 10             	add    $0x10,%esp
f0100c19:	3b 05 14 f4 2b f0    	cmp    0xf02bf414,%eax
f0100c1f:	73 2e                	jae    f0100c4f <mon_dump+0xc2>
	return (void *)(pa + KERNBASE);
f0100c21:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
		va_end = (uint32_t)KADDR(atox(argv[3]));
f0100c27:	83 ec 0c             	sub    $0xc,%esp
f0100c2a:	ff 76 0c             	pushl  0xc(%esi)
f0100c2d:	e8 d3 51 00 00       	call   f0105e05 <atox>
	if (PGNUM(pa) >= npages)
f0100c32:	89 c2                	mov    %eax,%edx
f0100c34:	c1 ea 0c             	shr    $0xc,%edx
f0100c37:	83 c4 10             	add    $0x10,%esp
f0100c3a:	39 15 14 f4 2b f0    	cmp    %edx,0xf02bf414
f0100c40:	76 22                	jbe    f0100c64 <mon_dump+0xd7>
	return (void *)(pa + KERNBASE);
f0100c42:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c47:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100c4a:	e9 7b ff ff ff       	jmp    f0100bca <mon_dump+0x3d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c4f:	53                   	push   %ebx
f0100c50:	68 44 74 10 f0       	push   $0xf0107444
f0100c55:	68 dc 00 00 00       	push   $0xdc
f0100c5a:	68 c4 77 10 f0       	push   $0xf01077c4
f0100c5f:	e8 dc f3 ff ff       	call   f0100040 <_panic>
f0100c64:	50                   	push   %eax
f0100c65:	68 44 74 10 f0       	push   $0xf0107444
f0100c6a:	68 dd 00 00 00       	push   $0xdd
f0100c6f:	68 c4 77 10 f0       	push   $0xf01077c4
f0100c74:	e8 c7 f3 ff ff       	call   f0100040 <_panic>
		if (pg_tbl_entry == NULL){ cprintf("illegal access of paged memory at %08x\n", va_start); continue;}
f0100c79:	83 ec 08             	sub    $0x8,%esp
f0100c7c:	ff 75 e0             	pushl  -0x20(%ebp)
f0100c7f:	68 7c 7a 10 f0       	push   $0xf0107a7c
f0100c84:	e8 a7 31 00 00       	call   f0103e30 <cprintf>
f0100c89:	83 c4 10             	add    $0x10,%esp
	for (; va_start<= ROUNDDOWN(va_end, PGSIZE); va_start+=PGSIZE){
f0100c8c:	81 45 e0 00 10 00 00 	addl   $0x1000,-0x20(%ebp)
f0100c93:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0100c99:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100c9c:	39 4d e0             	cmp    %ecx,-0x20(%ebp)
f0100c9f:	0f 87 54 ff ff ff    	ja     f0100bf9 <mon_dump+0x6c>
		pg_tbl_entry = pgdir_walk(kern_pgdir, (void*)va_start, 0);
f0100ca5:	83 ec 04             	sub    $0x4,%esp
f0100ca8:	6a 00                	push   $0x0
f0100caa:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100cad:	56                   	push   %esi
f0100cae:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f0100cb4:	e8 e3 07 00 00       	call   f010149c <pgdir_walk>
		if (pg_tbl_entry == NULL){ cprintf("illegal access of paged memory at %08x\n", va_start); continue;}
f0100cb9:	83 c4 10             	add    $0x10,%esp
f0100cbc:	83 c6 08             	add    $0x8,%esi
f0100cbf:	85 c0                	test   %eax,%eax
f0100cc1:	75 30                	jne    f0100cf3 <mon_dump+0x166>
f0100cc3:	eb b4                	jmp    f0100c79 <mon_dump+0xec>
				cprintf("%02x ", *p);
f0100cc5:	83 ec 08             	sub    $0x8,%esp
f0100cc8:	0f b6 03             	movzbl (%ebx),%eax
f0100ccb:	50                   	push   %eax
f0100ccc:	68 da 77 10 f0       	push   $0xf01077da
f0100cd1:	e8 5a 31 00 00       	call   f0103e30 <cprintf>
			for (p=(unsigned char*)line; p<(unsigned char*)(line+1); p++){
f0100cd6:	83 c3 01             	add    $0x1,%ebx
f0100cd9:	83 c4 10             	add    $0x10,%esp
f0100cdc:	39 f3                	cmp    %esi,%ebx
f0100cde:	75 e5                	jne    f0100cc5 <mon_dump+0x138>
			cprintf("\n");
f0100ce0:	83 ec 0c             	sub    $0xc,%esp
f0100ce3:	68 08 8a 10 f0       	push   $0xf0108a08
f0100ce8:	e8 43 31 00 00       	call   f0103e30 <cprintf>
f0100ced:	83 c6 08             	add    $0x8,%esi
f0100cf0:	83 c4 10             	add    $0x10,%esp
f0100cf3:	8d 5e f8             	lea    -0x8(%esi),%ebx
		for (line=(uint64_t*)va_start; (va_start+PGSIZE<=va_end)&&line<(uint64_t*)(va_start+PGSIZE); line++){
f0100cf6:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
f0100cf9:	72 91                	jb     f0100c8c <mon_dump+0xff>
f0100cfb:	39 fb                	cmp    %edi,%ebx
f0100cfd:	73 8d                	jae    f0100c8c <mon_dump+0xff>
			cprintf("%08x  ", line);
f0100cff:	83 ec 08             	sub    $0x8,%esp
f0100d02:	53                   	push   %ebx
f0100d03:	68 d3 77 10 f0       	push   $0xf01077d3
f0100d08:	e8 23 31 00 00       	call   f0103e30 <cprintf>
			for (p=(unsigned char*)line; p<(unsigned char*)(line+1); p++){
f0100d0d:	83 c4 10             	add    $0x10,%esp
f0100d10:	eb ca                	jmp    f0100cdc <mon_dump+0x14f>

f0100d12 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100d12:	f3 0f 1e fb          	endbr32 
f0100d16:	55                   	push   %ebp
f0100d17:	89 e5                	mov    %esp,%ebp
f0100d19:	57                   	push   %edi
f0100d1a:	56                   	push   %esi
f0100d1b:	53                   	push   %ebx
f0100d1c:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100d1f:	68 a4 7a 10 f0       	push   $0xf0107aa4
f0100d24:	e8 07 31 00 00       	call   f0103e30 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100d29:	c7 04 24 c8 7a 10 f0 	movl   $0xf0107ac8,(%esp)
f0100d30:	e8 fb 30 00 00       	call   f0103e30 <cprintf>
f0100d35:	83 c4 10             	add    $0x10,%esp
f0100d38:	eb 47                	jmp    f0100d81 <monitor+0x6f>
		while (*buf && strchr(WHITESPACE, *buf))
f0100d3a:	83 ec 08             	sub    $0x8,%esp
f0100d3d:	0f be c0             	movsbl %al,%eax
f0100d40:	50                   	push   %eax
f0100d41:	68 e4 77 10 f0       	push   $0xf01077e4
f0100d46:	e8 95 50 00 00       	call   f0105de0 <strchr>
f0100d4b:	83 c4 10             	add    $0x10,%esp
f0100d4e:	85 c0                	test   %eax,%eax
f0100d50:	74 0a                	je     f0100d5c <monitor+0x4a>
			*buf++ = 0;
f0100d52:	c6 03 00             	movb   $0x0,(%ebx)
f0100d55:	89 f7                	mov    %esi,%edi
f0100d57:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100d5a:	eb 6b                	jmp    f0100dc7 <monitor+0xb5>
		if (*buf == 0)
f0100d5c:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100d5f:	74 73                	je     f0100dd4 <monitor+0xc2>
		if (argc == MAXARGS-1) {
f0100d61:	83 fe 0f             	cmp    $0xf,%esi
f0100d64:	74 09                	je     f0100d6f <monitor+0x5d>
		argv[argc++] = buf;
f0100d66:	8d 7e 01             	lea    0x1(%esi),%edi
f0100d69:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100d6d:	eb 39                	jmp    f0100da8 <monitor+0x96>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100d6f:	83 ec 08             	sub    $0x8,%esp
f0100d72:	6a 10                	push   $0x10
f0100d74:	68 e9 77 10 f0       	push   $0xf01077e9
f0100d79:	e8 b2 30 00 00       	call   f0103e30 <cprintf>
			return 0;
f0100d7e:	83 c4 10             	add    $0x10,%esp
	// cprintf("x=%d y=%d\n", 3); // inserted

	// 测试
	// mon_backtrace(0, 0, 0);
	while (1) {
		buf = readline("K> ");
f0100d81:	83 ec 0c             	sub    $0xc,%esp
f0100d84:	68 e0 77 10 f0       	push   $0xf01077e0
f0100d89:	e8 f8 4d 00 00       	call   f0105b86 <readline>
f0100d8e:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100d90:	83 c4 10             	add    $0x10,%esp
f0100d93:	85 c0                	test   %eax,%eax
f0100d95:	74 ea                	je     f0100d81 <monitor+0x6f>
	argv[argc] = 0;
f0100d97:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100d9e:	be 00 00 00 00       	mov    $0x0,%esi
f0100da3:	eb 24                	jmp    f0100dc9 <monitor+0xb7>
			buf++;
f0100da5:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100da8:	0f b6 03             	movzbl (%ebx),%eax
f0100dab:	84 c0                	test   %al,%al
f0100dad:	74 18                	je     f0100dc7 <monitor+0xb5>
f0100daf:	83 ec 08             	sub    $0x8,%esp
f0100db2:	0f be c0             	movsbl %al,%eax
f0100db5:	50                   	push   %eax
f0100db6:	68 e4 77 10 f0       	push   $0xf01077e4
f0100dbb:	e8 20 50 00 00       	call   f0105de0 <strchr>
f0100dc0:	83 c4 10             	add    $0x10,%esp
f0100dc3:	85 c0                	test   %eax,%eax
f0100dc5:	74 de                	je     f0100da5 <monitor+0x93>
			*buf++ = 0;
f0100dc7:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100dc9:	0f b6 03             	movzbl (%ebx),%eax
f0100dcc:	84 c0                	test   %al,%al
f0100dce:	0f 85 66 ff ff ff    	jne    f0100d3a <monitor+0x28>
	argv[argc] = 0;
f0100dd4:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100ddb:	00 
	if (argc == 0){
f0100ddc:	85 f6                	test   %esi,%esi
f0100dde:	74 a1                	je     f0100d81 <monitor+0x6f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100de0:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0){
f0100de5:	83 ec 08             	sub    $0x8,%esp
f0100de8:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100deb:	ff 34 85 20 7c 10 f0 	pushl  -0xfef83e0(,%eax,4)
f0100df2:	ff 75 a8             	pushl  -0x58(%ebp)
f0100df5:	e8 80 4f 00 00       	call   f0105d7a <strcmp>
f0100dfa:	83 c4 10             	add    $0x10,%esp
f0100dfd:	85 c0                	test   %eax,%eax
f0100dff:	74 20                	je     f0100e21 <monitor+0x10f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100e01:	83 c3 01             	add    $0x1,%ebx
f0100e04:	83 fb 06             	cmp    $0x6,%ebx
f0100e07:	75 dc                	jne    f0100de5 <monitor+0xd3>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100e09:	83 ec 08             	sub    $0x8,%esp
f0100e0c:	ff 75 a8             	pushl  -0x58(%ebp)
f0100e0f:	68 06 78 10 f0       	push   $0xf0107806
f0100e14:	e8 17 30 00 00       	call   f0103e30 <cprintf>
	return 0;
f0100e19:	83 c4 10             	add    $0x10,%esp
f0100e1c:	e9 60 ff ff ff       	jmp    f0100d81 <monitor+0x6f>
			return commands[i].func(argc, argv, tf);
f0100e21:	83 ec 04             	sub    $0x4,%esp
f0100e24:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100e27:	ff 75 08             	pushl  0x8(%ebp)
f0100e2a:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100e2d:	52                   	push   %edx
f0100e2e:	56                   	push   %esi
f0100e2f:	ff 14 85 28 7c 10 f0 	call   *-0xfef83d8(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100e36:	83 c4 10             	add    $0x10,%esp
f0100e39:	85 c0                	test   %eax,%eax
f0100e3b:	0f 89 40 ff ff ff    	jns    f0100d81 <monitor+0x6f>
				break;
	}
}
f0100e41:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e44:	5b                   	pop    %ebx
f0100e45:	5e                   	pop    %esi
f0100e46:	5f                   	pop    %edi
f0100e47:	5d                   	pop    %ebp
f0100e48:	c3                   	ret    

f0100e49 <boot_alloc>:
	// to any kernel code or global variables.
	// nextfree指针初始化: 在确定了内核本身在内存中的位置后, 让boot_alloc在内核所占空间的内存之后的第一个page开始分配
	// end指针是链接器产生的 可以查看配置文件kern/kernel.ld  
	// end指向内核最后一个字节的下一个字节
	// 这里从链接器中拿到内核的最后一个字节的地址end, 并将这个指针的数值roundUp到PGSIZE的整数倍
	if (!nextfree) {
f0100e49:	83 3d 3c d2 2b f0 00 	cmpl   $0x0,0xf02bd23c
f0100e50:	74 1a                	je     f0100e6c <boot_alloc+0x23>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE -->由ROUNDUP来完成
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100e52:	8b 15 3c d2 2b f0    	mov    0xf02bd23c,%edx
	nextfree = ROUNDUP((char*)(nextfree+n), PGSIZE);
f0100e58:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100e5f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100e64:	a3 3c d2 2b f0       	mov    %eax,0xf02bd23c

	return result;
}
f0100e69:	89 d0                	mov    %edx,%eax
f0100e6b:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100e6c:	ba ff b6 34 f0       	mov    $0xf034b6ff,%edx
f0100e71:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100e77:	89 15 3c d2 2b f0    	mov    %edx,0xf02bd23c
f0100e7d:	eb d3                	jmp    f0100e52 <boot_alloc+0x9>

f0100e7f <nvram_read>:
{
f0100e7f:	55                   	push   %ebp
f0100e80:	89 e5                	mov    %esp,%ebp
f0100e82:	56                   	push   %esi
f0100e83:	53                   	push   %ebx
f0100e84:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100e86:	83 ec 0c             	sub    $0xc,%esp
f0100e89:	50                   	push   %eax
f0100e8a:	e8 e8 2d 00 00       	call   f0103c77 <mc146818_read>
f0100e8f:	89 c6                	mov    %eax,%esi
f0100e91:	83 c3 01             	add    $0x1,%ebx
f0100e94:	89 1c 24             	mov    %ebx,(%esp)
f0100e97:	e8 db 2d 00 00       	call   f0103c77 <mc146818_read>
f0100e9c:	c1 e0 08             	shl    $0x8,%eax
f0100e9f:	09 f0                	or     %esi,%eax
}
f0100ea1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ea4:	5b                   	pop    %ebx
f0100ea5:	5e                   	pop    %esi
f0100ea6:	5d                   	pop    %ebp
f0100ea7:	c3                   	ret    

f0100ea8 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)]; // page_directory_entry
f0100ea8:	89 d1                	mov    %edx,%ecx
f0100eaa:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100ead:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100eb0:	a8 01                	test   $0x1,%al
f0100eb2:	74 51                	je     f0100f05 <check_va2pa+0x5d>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir)); // page_table_page_base_addr
f0100eb4:	89 c1                	mov    %eax,%ecx
f0100eb6:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	if (PGNUM(pa) >= npages)
f0100ebc:	c1 e8 0c             	shr    $0xc,%eax
f0100ebf:	3b 05 14 f4 2b f0    	cmp    0xf02bf414,%eax
f0100ec5:	73 23                	jae    f0100eea <check_va2pa+0x42>
	if (!(p[PTX(va)] & PTE_P)) //
f0100ec7:	c1 ea 0c             	shr    $0xc,%edx
f0100eca:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100ed0:	8b 94 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100ed7:	89 d0                	mov    %edx,%eax
f0100ed9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ede:	f6 c2 01             	test   $0x1,%dl
f0100ee1:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100ee6:	0f 44 c2             	cmove  %edx,%eax
f0100ee9:	c3                   	ret    
{
f0100eea:	55                   	push   %ebp
f0100eeb:	89 e5                	mov    %esp,%ebp
f0100eed:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ef0:	51                   	push   %ecx
f0100ef1:	68 44 74 10 f0       	push   $0xf0107444
f0100ef6:	68 30 04 00 00       	push   $0x430
f0100efb:	68 0d 87 10 f0       	push   $0xf010870d
f0100f00:	e8 3b f1 ff ff       	call   f0100040 <_panic>
		return ~0;
f0100f05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100f0a:	c3                   	ret    

f0100f0b <check_page_free_list>:
{
f0100f0b:	55                   	push   %ebp
f0100f0c:	89 e5                	mov    %esp,%ebp
f0100f0e:	57                   	push   %edi
f0100f0f:	56                   	push   %esi
f0100f10:	53                   	push   %ebx
f0100f11:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f14:	84 c0                	test   %al,%al
f0100f16:	0f 85 77 02 00 00    	jne    f0101193 <check_page_free_list+0x288>
	if (!page_free_list)
f0100f1c:	83 3d 44 d2 2b f0 00 	cmpl   $0x0,0xf02bd244
f0100f23:	74 0a                	je     f0100f2f <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f25:	be 00 04 00 00       	mov    $0x400,%esi
f0100f2a:	e9 bf 02 00 00       	jmp    f01011ee <check_page_free_list+0x2e3>
		panic("'page_free_list' is a null pointer!");
f0100f2f:	83 ec 04             	sub    $0x4,%esp
f0100f32:	68 68 7c 10 f0       	push   $0xf0107c68
f0100f37:	68 5f 03 00 00       	push   $0x35f
f0100f3c:	68 0d 87 10 f0       	push   $0xf010870d
f0100f41:	e8 fa f0 ff ff       	call   f0100040 <_panic>
f0100f46:	50                   	push   %eax
f0100f47:	68 44 74 10 f0       	push   $0xf0107444
f0100f4c:	6a 58                	push   $0x58
f0100f4e:	68 19 87 10 f0       	push   $0xf0108719
f0100f53:	e8 e8 f0 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0100f58:	8b 1b                	mov    (%ebx),%ebx
f0100f5a:	85 db                	test   %ebx,%ebx
f0100f5c:	74 41                	je     f0100f9f <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f5e:	89 d8                	mov    %ebx,%eax
f0100f60:	2b 05 1c f4 2b f0    	sub    0xf02bf41c,%eax
f0100f66:	c1 f8 03             	sar    $0x3,%eax
f0100f69:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit){
f0100f6c:	89 c2                	mov    %eax,%edx
f0100f6e:	c1 ea 16             	shr    $0x16,%edx
f0100f71:	39 f2                	cmp    %esi,%edx
f0100f73:	73 e3                	jae    f0100f58 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100f75:	89 c2                	mov    %eax,%edx
f0100f77:	c1 ea 0c             	shr    $0xc,%edx
f0100f7a:	3b 15 14 f4 2b f0    	cmp    0xf02bf414,%edx
f0100f80:	73 c4                	jae    f0100f46 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100f82:	83 ec 04             	sub    $0x4,%esp
f0100f85:	68 80 00 00 00       	push   $0x80
f0100f8a:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100f8f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f94:	50                   	push   %eax
f0100f95:	e8 d3 4e 00 00       	call   f0105e6d <memset>
f0100f9a:	83 c4 10             	add    $0x10,%esp
f0100f9d:	eb b9                	jmp    f0100f58 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100f9f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fa4:	e8 a0 fe ff ff       	call   f0100e49 <boot_alloc>
f0100fa9:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100fac:	8b 15 44 d2 2b f0    	mov    0xf02bd244,%edx
		assert(pp >= pages);
f0100fb2:	8b 0d 1c f4 2b f0    	mov    0xf02bf41c,%ecx
		assert(pp < pages + npages);
f0100fb8:	a1 14 f4 2b f0       	mov    0xf02bf414,%eax
f0100fbd:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100fc0:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100fc3:	bf 00 00 00 00       	mov    $0x0,%edi
f0100fc8:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100fcb:	e9 f9 00 00 00       	jmp    f01010c9 <check_page_free_list+0x1be>
		assert(pp >= pages);
f0100fd0:	68 27 87 10 f0       	push   $0xf0108727
f0100fd5:	68 33 87 10 f0       	push   $0xf0108733
f0100fda:	68 7c 03 00 00       	push   $0x37c
f0100fdf:	68 0d 87 10 f0       	push   $0xf010870d
f0100fe4:	e8 57 f0 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100fe9:	68 48 87 10 f0       	push   $0xf0108748
f0100fee:	68 33 87 10 f0       	push   $0xf0108733
f0100ff3:	68 7d 03 00 00       	push   $0x37d
f0100ff8:	68 0d 87 10 f0       	push   $0xf010870d
f0100ffd:	e8 3e f0 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101002:	68 8c 7c 10 f0       	push   $0xf0107c8c
f0101007:	68 33 87 10 f0       	push   $0xf0108733
f010100c:	68 7e 03 00 00       	push   $0x37e
f0101011:	68 0d 87 10 f0       	push   $0xf010870d
f0101016:	e8 25 f0 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f010101b:	68 5c 87 10 f0       	push   $0xf010875c
f0101020:	68 33 87 10 f0       	push   $0xf0108733
f0101025:	68 81 03 00 00       	push   $0x381
f010102a:	68 0d 87 10 f0       	push   $0xf010870d
f010102f:	e8 0c f0 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101034:	68 6d 87 10 f0       	push   $0xf010876d
f0101039:	68 33 87 10 f0       	push   $0xf0108733
f010103e:	68 82 03 00 00       	push   $0x382
f0101043:	68 0d 87 10 f0       	push   $0xf010870d
f0101048:	e8 f3 ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010104d:	68 c0 7c 10 f0       	push   $0xf0107cc0
f0101052:	68 33 87 10 f0       	push   $0xf0108733
f0101057:	68 83 03 00 00       	push   $0x383
f010105c:	68 0d 87 10 f0       	push   $0xf010870d
f0101061:	e8 da ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101066:	68 86 87 10 f0       	push   $0xf0108786
f010106b:	68 33 87 10 f0       	push   $0xf0108733
f0101070:	68 84 03 00 00       	push   $0x384
f0101075:	68 0d 87 10 f0       	push   $0xf010870d
f010107a:	e8 c1 ef ff ff       	call   f0100040 <_panic>
	if (PGNUM(pa) >= npages)
f010107f:	89 c3                	mov    %eax,%ebx
f0101081:	c1 eb 0c             	shr    $0xc,%ebx
f0101084:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0101087:	76 0f                	jbe    f0101098 <check_page_free_list+0x18d>
	return (void *)(pa + KERNBASE);
f0101089:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010108e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101091:	77 17                	ja     f01010aa <check_page_free_list+0x19f>
			++nfree_extmem;
f0101093:	83 c7 01             	add    $0x1,%edi
f0101096:	eb 2f                	jmp    f01010c7 <check_page_free_list+0x1bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101098:	50                   	push   %eax
f0101099:	68 44 74 10 f0       	push   $0xf0107444
f010109e:	6a 58                	push   $0x58
f01010a0:	68 19 87 10 f0       	push   $0xf0108719
f01010a5:	e8 96 ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01010aa:	68 e4 7c 10 f0       	push   $0xf0107ce4
f01010af:	68 33 87 10 f0       	push   $0xf0108733
f01010b4:	68 85 03 00 00       	push   $0x385
f01010b9:	68 0d 87 10 f0       	push   $0xf010870d
f01010be:	e8 7d ef ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f01010c3:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010c7:	8b 12                	mov    (%edx),%edx
f01010c9:	85 d2                	test   %edx,%edx
f01010cb:	74 74                	je     f0101141 <check_page_free_list+0x236>
		assert(pp >= pages);
f01010cd:	39 d1                	cmp    %edx,%ecx
f01010cf:	0f 87 fb fe ff ff    	ja     f0100fd0 <check_page_free_list+0xc5>
		assert(pp < pages + npages);
f01010d5:	39 d6                	cmp    %edx,%esi
f01010d7:	0f 86 0c ff ff ff    	jbe    f0100fe9 <check_page_free_list+0xde>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01010dd:	89 d0                	mov    %edx,%eax
f01010df:	29 c8                	sub    %ecx,%eax
f01010e1:	a8 07                	test   $0x7,%al
f01010e3:	0f 85 19 ff ff ff    	jne    f0101002 <check_page_free_list+0xf7>
	return (pp - pages) << PGSHIFT;
f01010e9:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f01010ec:	c1 e0 0c             	shl    $0xc,%eax
f01010ef:	0f 84 26 ff ff ff    	je     f010101b <check_page_free_list+0x110>
		assert(page2pa(pp) != IOPHYSMEM);
f01010f5:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01010fa:	0f 84 34 ff ff ff    	je     f0101034 <check_page_free_list+0x129>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101100:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101105:	0f 84 42 ff ff ff    	je     f010104d <check_page_free_list+0x142>
		assert(page2pa(pp) != EXTPHYSMEM);
f010110b:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101110:	0f 84 50 ff ff ff    	je     f0101066 <check_page_free_list+0x15b>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101116:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f010111b:	0f 87 5e ff ff ff    	ja     f010107f <check_page_free_list+0x174>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101121:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101126:	75 9b                	jne    f01010c3 <check_page_free_list+0x1b8>
f0101128:	68 a0 87 10 f0       	push   $0xf01087a0
f010112d:	68 33 87 10 f0       	push   $0xf0108733
f0101132:	68 87 03 00 00       	push   $0x387
f0101137:	68 0d 87 10 f0       	push   $0xf010870d
f010113c:	e8 ff ee ff ff       	call   f0100040 <_panic>
f0101141:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
	assert(nfree_basemem > 0);
f0101144:	85 db                	test   %ebx,%ebx
f0101146:	7e 19                	jle    f0101161 <check_page_free_list+0x256>
	assert(nfree_extmem > 0);
f0101148:	85 ff                	test   %edi,%edi
f010114a:	7e 2e                	jle    f010117a <check_page_free_list+0x26f>
	cprintf("check_page_free_list() succeeded!\n");
f010114c:	83 ec 0c             	sub    $0xc,%esp
f010114f:	68 2c 7d 10 f0       	push   $0xf0107d2c
f0101154:	e8 d7 2c 00 00       	call   f0103e30 <cprintf>
}
f0101159:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010115c:	5b                   	pop    %ebx
f010115d:	5e                   	pop    %esi
f010115e:	5f                   	pop    %edi
f010115f:	5d                   	pop    %ebp
f0101160:	c3                   	ret    
	assert(nfree_basemem > 0);
f0101161:	68 bd 87 10 f0       	push   $0xf01087bd
f0101166:	68 33 87 10 f0       	push   $0xf0108733
f010116b:	68 8f 03 00 00       	push   $0x38f
f0101170:	68 0d 87 10 f0       	push   $0xf010870d
f0101175:	e8 c6 ee ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f010117a:	68 cf 87 10 f0       	push   $0xf01087cf
f010117f:	68 33 87 10 f0       	push   $0xf0108733
f0101184:	68 90 03 00 00       	push   $0x390
f0101189:	68 0d 87 10 f0       	push   $0xf010870d
f010118e:	e8 ad ee ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0101193:	a1 44 d2 2b f0       	mov    0xf02bd244,%eax
f0101198:	85 c0                	test   %eax,%eax
f010119a:	0f 84 8f fd ff ff    	je     f0100f2f <check_page_free_list+0x24>
		struct PageInfo** tp[2] = { &pp1, &pp2 };
f01011a0:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01011a3:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01011a6:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01011a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01011ac:	89 c2                	mov    %eax,%edx
f01011ae:	2b 15 1c f4 2b f0    	sub    0xf02bf41c,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;// either true or false
f01011b4:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f01011ba:	0f 95 c2             	setne  %dl
f01011bd:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f01011c0:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f01011c4:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f01011c6:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01011ca:	8b 00                	mov    (%eax),%eax
f01011cc:	85 c0                	test   %eax,%eax
f01011ce:	75 dc                	jne    f01011ac <check_page_free_list+0x2a1>
		*tp[1] = 0;
f01011d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01011d3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01011d9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01011dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011df:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01011e1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01011e4:	a3 44 d2 2b f0       	mov    %eax,0xf02bd244
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01011e9:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link){
f01011ee:	8b 1d 44 d2 2b f0    	mov    0xf02bd244,%ebx
f01011f4:	e9 61 fd ff ff       	jmp    f0100f5a <check_page_free_list+0x4f>

f01011f9 <page_init>:
{
f01011f9:	f3 0f 1e fb          	endbr32 
f01011fd:	55                   	push   %ebp
f01011fe:	89 e5                	mov    %esp,%ebp
f0101200:	57                   	push   %edi
f0101201:	56                   	push   %esi
f0101202:	53                   	push   %ebx
f0101203:	83 ec 0c             	sub    $0xc,%esp
	pages[0].pp_ref = 1;
f0101206:	a1 1c f4 2b f0       	mov    0xf02bf41c,%eax
f010120b:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
f0101211:	8b 15 44 d2 2b f0    	mov    0xf02bd244,%edx
f0101217:	b8 08 00 00 00       	mov    $0x8,%eax
		pages[i].pp_ref = 0;
f010121c:	89 c1                	mov    %eax,%ecx
f010121e:	03 0d 1c f4 2b f0    	add    0xf02bf41c,%ecx
f0101224:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f010122a:	89 11                	mov    %edx,(%ecx)
		page_free_list = &pages[i];
f010122c:	8b 1d 1c f4 2b f0    	mov    0xf02bf41c,%ebx
f0101232:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0101235:	83 c0 08             	add    $0x8,%eax
	for (; i<MPENTRY_PADDR/PGSIZE; i++){
f0101238:	83 f8 38             	cmp    $0x38,%eax
f010123b:	75 df                	jne    f010121c <page_init+0x23>
f010123d:	89 15 44 d2 2b f0    	mov    %edx,0xf02bd244
	size_t size = ROUNDUP((mpentry_end-mpentry_start), PGSIZE);
f0101243:	b9 f2 60 10 f0       	mov    $0xf01060f2,%ecx
f0101248:	81 e9 79 50 10 f0    	sub    $0xf0105079,%ecx
	for (; i<(MPENTRY_PADDR+size)/PGSIZE; i++){
f010124e:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101254:	81 c1 00 70 00 00    	add    $0x7000,%ecx
f010125a:	c1 e9 0c             	shr    $0xc,%ecx
	for (; i<MPENTRY_PADDR/PGSIZE; i++){
f010125d:	b8 07 00 00 00       	mov    $0x7,%eax
	for (; i<(MPENTRY_PADDR+size)/PGSIZE; i++){
f0101262:	39 c1                	cmp    %eax,%ecx
f0101264:	76 0c                	jbe    f0101272 <page_init+0x79>
		pages[i].pp_ref = 1;
f0101266:	66 c7 44 c3 04 01 00 	movw   $0x1,0x4(%ebx,%eax,8)
	for (; i<(MPENTRY_PADDR+size)/PGSIZE; i++){
f010126d:	83 c0 01             	add    $0x1,%eax
f0101270:	eb f0                	jmp    f0101262 <page_init+0x69>
f0101272:	83 f9 07             	cmp    $0x7,%ecx
f0101275:	b8 07 00 00 00       	mov    $0x7,%eax
f010127a:	0f 42 c8             	cmovb  %eax,%ecx
	for (; i<npages_basemem; i++){
f010127d:	8b 3d 48 d2 2b f0    	mov    0xf02bd248,%edi
f0101283:	89 c8                	mov    %ecx,%eax
f0101285:	bb 00 00 00 00       	mov    $0x0,%ebx
f010128a:	39 c7                	cmp    %eax,%edi
f010128c:	76 29                	jbe    f01012b7 <page_init+0xbe>
f010128e:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
		pages[i].pp_ref = 0;
f0101295:	89 de                	mov    %ebx,%esi
f0101297:	03 35 1c f4 2b f0    	add    0xf02bf41c,%esi
f010129d:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
		pages[i].pp_link = page_free_list;
f01012a3:	89 16                	mov    %edx,(%esi)
		page_free_list = &pages[i];
f01012a5:	03 1d 1c f4 2b f0    	add    0xf02bf41c,%ebx
f01012ab:	89 da                	mov    %ebx,%edx
	for (; i<npages_basemem; i++){
f01012ad:	83 c0 01             	add    $0x1,%eax
f01012b0:	bb 01 00 00 00       	mov    $0x1,%ebx
f01012b5:	eb d3                	jmp    f010128a <page_init+0x91>
f01012b7:	89 fe                	mov    %edi,%esi
f01012b9:	29 ce                	sub    %ecx,%esi
f01012bb:	39 cf                	cmp    %ecx,%edi
f01012bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01012c2:	0f 42 f0             	cmovb  %eax,%esi
f01012c5:	01 ce                	add    %ecx,%esi
f01012c7:	84 db                	test   %bl,%bl
f01012c9:	74 06                	je     f01012d1 <page_init+0xd8>
f01012cb:	89 15 44 d2 2b f0    	mov    %edx,0xf02bd244
		pages[i].pp_ref = 1;
f01012d1:	8b 15 1c f4 2b f0    	mov    0xf02bf41c,%edx
f01012d7:	89 f0                	mov    %esi,%eax
f01012d9:	eb 0a                	jmp    f01012e5 <page_init+0xec>
f01012db:	66 c7 44 c2 04 01 00 	movw   $0x1,0x4(%edx,%eax,8)
	for (; i<EXTPHYSMEM/PGSIZE; i++){
f01012e2:	83 c0 01             	add    $0x1,%eax
f01012e5:	3d ff 00 00 00       	cmp    $0xff,%eax
f01012ea:	76 ef                	jbe    f01012db <page_init+0xe2>
f01012ec:	b9 00 01 00 00       	mov    $0x100,%ecx
f01012f1:	29 f1                	sub    %esi,%ecx
f01012f3:	81 fe 00 01 00 00    	cmp    $0x100,%esi
f01012f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01012fe:	0f 47 c8             	cmova  %eax,%ecx
f0101301:	01 ce                	add    %ecx,%esi
	physaddr_t first_free_page = PADDR(boot_alloc(0));
f0101303:	e8 41 fb ff ff       	call   f0100e49 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0101308:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010130d:	76 21                	jbe    f0101330 <page_init+0x137>
	return (physaddr_t)kva - KERNBASE;
f010130f:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
	for (; i<first_free_page/PGSIZE; i++){
f0101315:	c1 ea 0c             	shr    $0xc,%edx
		pages[i].pp_ref = 1;
f0101318:	8b 0d 1c f4 2b f0    	mov    0xf02bf41c,%ecx
	for (; i<first_free_page/PGSIZE; i++){
f010131e:	89 f0                	mov    %esi,%eax
f0101320:	39 c2                	cmp    %eax,%edx
f0101322:	76 21                	jbe    f0101345 <page_init+0x14c>
		pages[i].pp_ref = 1;
f0101324:	66 c7 44 c1 04 01 00 	movw   $0x1,0x4(%ecx,%eax,8)
	for (; i<first_free_page/PGSIZE; i++){
f010132b:	83 c0 01             	add    $0x1,%eax
f010132e:	eb f0                	jmp    f0101320 <page_init+0x127>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101330:	50                   	push   %eax
f0101331:	68 68 74 10 f0       	push   $0xf0107468
f0101336:	68 a3 01 00 00       	push   $0x1a3
f010133b:	68 0d 87 10 f0       	push   $0xf010870d
f0101340:	e8 fb ec ff ff       	call   f0100040 <_panic>
f0101345:	89 d1                	mov    %edx,%ecx
f0101347:	29 f1                	sub    %esi,%ecx
f0101349:	39 f2                	cmp    %esi,%edx
f010134b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101350:	0f 42 c8             	cmovb  %eax,%ecx
f0101353:	01 f1                	add    %esi,%ecx
f0101355:	8b 1d 44 d2 2b f0    	mov    0xf02bd244,%ebx
	for (; i<npages; i++){
f010135b:	be 01 00 00 00       	mov    $0x1,%esi
f0101360:	39 0d 14 f4 2b f0    	cmp    %ecx,0xf02bf414
f0101366:	76 26                	jbe    f010138e <page_init+0x195>
f0101368:	8d 04 cd 00 00 00 00 	lea    0x0(,%ecx,8),%eax
		pages[i].pp_ref = 0;
f010136f:	89 c2                	mov    %eax,%edx
f0101371:	03 15 1c f4 2b f0    	add    0xf02bf41c,%edx
f0101377:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f010137d:	89 1a                	mov    %ebx,(%edx)
		page_free_list = &pages[i];
f010137f:	03 05 1c f4 2b f0    	add    0xf02bf41c,%eax
f0101385:	89 c3                	mov    %eax,%ebx
	for (; i<npages; i++){
f0101387:	83 c1 01             	add    $0x1,%ecx
f010138a:	89 f0                	mov    %esi,%eax
f010138c:	eb d2                	jmp    f0101360 <page_init+0x167>
f010138e:	84 c0                	test   %al,%al
f0101390:	74 06                	je     f0101398 <page_init+0x19f>
f0101392:	89 1d 44 d2 2b f0    	mov    %ebx,0xf02bd244
}
f0101398:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010139b:	5b                   	pop    %ebx
f010139c:	5e                   	pop    %esi
f010139d:	5f                   	pop    %edi
f010139e:	5d                   	pop    %ebp
f010139f:	c3                   	ret    

f01013a0 <page_alloc>:
{
f01013a0:	f3 0f 1e fb          	endbr32 
f01013a4:	55                   	push   %ebp
f01013a5:	89 e5                	mov    %esp,%ebp
f01013a7:	53                   	push   %ebx
f01013a8:	83 ec 04             	sub    $0x4,%esp
	if (page_free_list){
f01013ab:	8b 1d 44 d2 2b f0    	mov    0xf02bd244,%ebx
f01013b1:	85 db                	test   %ebx,%ebx
f01013b3:	74 13                	je     f01013c8 <page_alloc+0x28>
		page_free_list = page_free_list->pp_link;
f01013b5:	8b 03                	mov    (%ebx),%eax
f01013b7:	a3 44 d2 2b f0       	mov    %eax,0xf02bd244
		cur->pp_link = NULL;
f01013bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(alloc_flags & ALLOC_ZERO){
f01013c2:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01013c6:	75 07                	jne    f01013cf <page_alloc+0x2f>
}
f01013c8:	89 d8                	mov    %ebx,%eax
f01013ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01013cd:	c9                   	leave  
f01013ce:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f01013cf:	89 d8                	mov    %ebx,%eax
f01013d1:	2b 05 1c f4 2b f0    	sub    0xf02bf41c,%eax
f01013d7:	c1 f8 03             	sar    $0x3,%eax
f01013da:	89 c2                	mov    %eax,%edx
f01013dc:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01013df:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01013e4:	3b 05 14 f4 2b f0    	cmp    0xf02bf414,%eax
f01013ea:	73 1b                	jae    f0101407 <page_alloc+0x67>
			memset(page2kva(cur), 0, PGSIZE);
f01013ec:	83 ec 04             	sub    $0x4,%esp
f01013ef:	68 00 10 00 00       	push   $0x1000
f01013f4:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01013f6:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01013fc:	52                   	push   %edx
f01013fd:	e8 6b 4a 00 00       	call   f0105e6d <memset>
f0101402:	83 c4 10             	add    $0x10,%esp
f0101405:	eb c1                	jmp    f01013c8 <page_alloc+0x28>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101407:	52                   	push   %edx
f0101408:	68 44 74 10 f0       	push   $0xf0107444
f010140d:	6a 58                	push   $0x58
f010140f:	68 19 87 10 f0       	push   $0xf0108719
f0101414:	e8 27 ec ff ff       	call   f0100040 <_panic>

f0101419 <page_free>:
{
f0101419:	f3 0f 1e fb          	endbr32 
f010141d:	55                   	push   %ebp
f010141e:	89 e5                	mov    %esp,%ebp
f0101420:	83 ec 08             	sub    $0x8,%esp
f0101423:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_link!=NULL) 
f0101426:	83 38 00             	cmpl   $0x0,(%eax)
f0101429:	75 16                	jne    f0101441 <page_free+0x28>
	if (pp->pp_ref!=0)
f010142b:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101430:	75 26                	jne    f0101458 <page_free+0x3f>
	pp->pp_link = page_free_list;
f0101432:	8b 15 44 d2 2b f0    	mov    0xf02bd244,%edx
f0101438:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f010143a:	a3 44 d2 2b f0       	mov    %eax,0xf02bd244
}
f010143f:	c9                   	leave  
f0101440:	c3                   	ret    
		panic("page_free: ths page is on the page_free_list, invalid free operation\n");
f0101441:	83 ec 04             	sub    $0x4,%esp
f0101444:	68 50 7d 10 f0       	push   $0xf0107d50
f0101449:	68 d9 01 00 00       	push   $0x1d9
f010144e:	68 0d 87 10 f0       	push   $0xf010870d
f0101453:	e8 e8 eb ff ff       	call   f0100040 <_panic>
		panic("page_free: the page is in use and should not be freed!\n");
f0101458:	83 ec 04             	sub    $0x4,%esp
f010145b:	68 98 7d 10 f0       	push   $0xf0107d98
f0101460:	68 db 01 00 00       	push   $0x1db
f0101465:	68 0d 87 10 f0       	push   $0xf010870d
f010146a:	e8 d1 eb ff ff       	call   f0100040 <_panic>

f010146f <page_decref>:
{
f010146f:	f3 0f 1e fb          	endbr32 
f0101473:	55                   	push   %ebp
f0101474:	89 e5                	mov    %esp,%ebp
f0101476:	83 ec 08             	sub    $0x8,%esp
f0101479:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010147c:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101480:	83 e8 01             	sub    $0x1,%eax
f0101483:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101487:	66 85 c0             	test   %ax,%ax
f010148a:	74 02                	je     f010148e <page_decref+0x1f>
}
f010148c:	c9                   	leave  
f010148d:	c3                   	ret    
		page_free(pp);
f010148e:	83 ec 0c             	sub    $0xc,%esp
f0101491:	52                   	push   %edx
f0101492:	e8 82 ff ff ff       	call   f0101419 <page_free>
f0101497:	83 c4 10             	add    $0x10,%esp
}
f010149a:	eb f0                	jmp    f010148c <page_decref+0x1d>

f010149c <pgdir_walk>:
{
f010149c:	f3 0f 1e fb          	endbr32 
f01014a0:	55                   	push   %ebp
f01014a1:	89 e5                	mov    %esp,%ebp
f01014a3:	57                   	push   %edi
f01014a4:	56                   	push   %esi
f01014a5:	53                   	push   %ebx
f01014a6:	83 ec 0c             	sub    $0xc,%esp
f01014a9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	pde_t* pg_dir_entry = &pgdir[PDX(va)];
f01014ac:	89 fe                	mov    %edi,%esi
f01014ae:	c1 ee 16             	shr    $0x16,%esi
f01014b1:	c1 e6 02             	shl    $0x2,%esi
f01014b4:	03 75 08             	add    0x8(%ebp),%esi
	if ((*pg_dir_entry)&PTE_P){
f01014b7:	8b 0e                	mov    (%esi),%ecx
f01014b9:	f6 c1 01             	test   $0x1,%cl
f01014bc:	74 44                	je     f0101502 <pgdir_walk+0x66>
	    pg_tbl = (pte_t* )KADDR(PTE_ADDR(*pg_dir_entry));
f01014be:	89 cb                	mov    %ecx,%ebx
f01014c0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (PGNUM(pa) >= npages)
f01014c6:	c1 e9 0c             	shr    $0xc,%ecx
f01014c9:	39 0d 14 f4 2b f0    	cmp    %ecx,0xf02bf414
f01014cf:	76 1c                	jbe    f01014ed <pgdir_walk+0x51>
	return (void *)(pa + KERNBASE);
f01014d1:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
	return &pg_tbl[PTX(va)]; // 虚拟地址
f01014d7:	c1 ef 0a             	shr    $0xa,%edi
f01014da:	81 e7 fc 0f 00 00    	and    $0xffc,%edi
f01014e0:	8d 1c 3a             	lea    (%edx,%edi,1),%ebx
}
f01014e3:	89 d8                	mov    %ebx,%eax
f01014e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014e8:	5b                   	pop    %ebx
f01014e9:	5e                   	pop    %esi
f01014ea:	5f                   	pop    %edi
f01014eb:	5d                   	pop    %ebp
f01014ec:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014ed:	53                   	push   %ebx
f01014ee:	68 44 74 10 f0       	push   $0xf0107444
f01014f3:	68 27 02 00 00       	push   $0x227
f01014f8:	68 0d 87 10 f0       	push   $0xf010870d
f01014fd:	e8 3e eb ff ff       	call   f0100040 <_panic>
		if (create == 0)
f0101502:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101506:	0f 84 87 00 00 00    	je     f0101593 <pgdir_walk+0xf7>
		struct PageInfo* new_page = page_alloc(ALLOC_ZERO);
f010150c:	83 ec 0c             	sub    $0xc,%esp
f010150f:	6a 01                	push   $0x1
f0101511:	e8 8a fe ff ff       	call   f01013a0 <page_alloc>
f0101516:	89 c3                	mov    %eax,%ebx
		if (new_page == NULL){
f0101518:	83 c4 10             	add    $0x10,%esp
f010151b:	85 c0                	test   %eax,%eax
f010151d:	74 38                	je     f0101557 <pgdir_walk+0xbb>
		new_page->pp_ref++;
f010151f:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101524:	2b 1d 1c f4 2b f0    	sub    0xf02bf41c,%ebx
f010152a:	c1 fb 03             	sar    $0x3,%ebx
f010152d:	89 d8                	mov    %ebx,%eax
f010152f:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101532:	81 e3 ff ff 0f 00    	and    $0xfffff,%ebx
f0101538:	3b 1d 14 f4 2b f0    	cmp    0xf02bf414,%ebx
f010153e:	73 2c                	jae    f010156c <pgdir_walk+0xd0>
	return (void *)(pa + KERNBASE);
f0101540:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f0101546:	89 ca                	mov    %ecx,%edx
	if ((uint32_t)kva < KERNBASE)
f0101548:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f010154e:	76 2e                	jbe    f010157e <pgdir_walk+0xe2>
		 *pg_dir_entry = PADDR(pg_tbl)|PTE_P|PTE_W|PTE_U;
f0101550:	83 c8 07             	or     $0x7,%eax
f0101553:	89 06                	mov    %eax,(%esi)
f0101555:	eb 80                	jmp    f01014d7 <pgdir_walk+0x3b>
			cprintf("pgdir_walk: fail to allocate a new page table\n");
f0101557:	83 ec 0c             	sub    $0xc,%esp
f010155a:	68 d0 7d 10 f0       	push   $0xf0107dd0
f010155f:	e8 cc 28 00 00       	call   f0103e30 <cprintf>
			return NULL;
f0101564:	83 c4 10             	add    $0x10,%esp
f0101567:	e9 77 ff ff ff       	jmp    f01014e3 <pgdir_walk+0x47>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010156c:	50                   	push   %eax
f010156d:	68 44 74 10 f0       	push   $0xf0107444
f0101572:	6a 58                	push   $0x58
f0101574:	68 19 87 10 f0       	push   $0xf0108719
f0101579:	e8 c2 ea ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010157e:	51                   	push   %ecx
f010157f:	68 68 74 10 f0       	push   $0xf0107468
f0101584:	68 3d 02 00 00       	push   $0x23d
f0101589:	68 0d 87 10 f0       	push   $0xf010870d
f010158e:	e8 ad ea ff ff       	call   f0100040 <_panic>
			return NULL;
f0101593:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101598:	e9 46 ff ff ff       	jmp    f01014e3 <pgdir_walk+0x47>

f010159d <boot_map_region>:
{
f010159d:	55                   	push   %ebp
f010159e:	89 e5                	mov    %esp,%ebp
f01015a0:	57                   	push   %edi
f01015a1:	56                   	push   %esi
f01015a2:	53                   	push   %ebx
f01015a3:	83 ec 1c             	sub    $0x1c,%esp
f01015a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01015a9:	8b 45 08             	mov    0x8(%ebp),%eax
	int num = ROUNDUP(size,PGSIZE)/PGSIZE; 
f01015ac:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f01015b2:	c1 e9 0c             	shr    $0xc,%ecx
f01015b5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (i=1; i<=num; i++){
f01015b8:	89 c3                	mov    %eax,%ebx
f01015ba:	be 01 00 00 00       	mov    $0x1,%esi
		pte_t* pg_tbl_entry = pgdir_walk(pgdir, (void* )va, 1);
f01015bf:	89 d7                	mov    %edx,%edi
f01015c1:	29 c7                	sub    %eax,%edi
	for (i=1; i<=num; i++){
f01015c3:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01015c6:	7f 44                	jg     f010160c <boot_map_region+0x6f>
		pte_t* pg_tbl_entry = pgdir_walk(pgdir, (void* )va, 1);
f01015c8:	83 ec 04             	sub    $0x4,%esp
f01015cb:	6a 01                	push   $0x1
f01015cd:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01015d0:	50                   	push   %eax
f01015d1:	ff 75 e0             	pushl  -0x20(%ebp)
f01015d4:	e8 c3 fe ff ff       	call   f010149c <pgdir_walk>
		if (!pg_tbl_entry) {
f01015d9:	83 c4 10             	add    $0x10,%esp
f01015dc:	85 c0                	test   %eax,%eax
f01015de:	74 15                	je     f01015f5 <boot_map_region+0x58>
		*pg_tbl_entry = pa|perm|PTE_P;
f01015e0:	89 da                	mov    %ebx,%edx
f01015e2:	0b 55 0c             	or     0xc(%ebp),%edx
f01015e5:	83 ca 01             	or     $0x1,%edx
f01015e8:	89 10                	mov    %edx,(%eax)
		pa += PGSIZE;
f01015ea:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i=1; i<=num; i++){
f01015f0:	83 c6 01             	add    $0x1,%esi
f01015f3:	eb ce                	jmp    f01015c3 <boot_map_region+0x26>
			panic("boot_map_region panic, out of memory\n");
f01015f5:	83 ec 04             	sub    $0x4,%esp
f01015f8:	68 00 7e 10 f0       	push   $0xf0107e00
f01015fd:	68 5a 02 00 00       	push   $0x25a
f0101602:	68 0d 87 10 f0       	push   $0xf010870d
f0101607:	e8 34 ea ff ff       	call   f0100040 <_panic>
}
f010160c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010160f:	5b                   	pop    %ebx
f0101610:	5e                   	pop    %esi
f0101611:	5f                   	pop    %edi
f0101612:	5d                   	pop    %ebp
f0101613:	c3                   	ret    

f0101614 <page_lookup>:
{
f0101614:	f3 0f 1e fb          	endbr32 
f0101618:	55                   	push   %ebp
f0101619:	89 e5                	mov    %esp,%ebp
f010161b:	56                   	push   %esi
f010161c:	53                   	push   %ebx
f010161d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101620:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t* pg_tbl_entry =  pgdir_walk(pgdir, va, 0); // 不需要create
f0101623:	83 ec 04             	sub    $0x4,%esp
f0101626:	6a 00                	push   $0x0
f0101628:	56                   	push   %esi
f0101629:	ff 75 08             	pushl  0x8(%ebp)
f010162c:	e8 6b fe ff ff       	call   f010149c <pgdir_walk>
	if (pte_store != NULL){
f0101631:	83 c4 10             	add    $0x10,%esp
f0101634:	85 db                	test   %ebx,%ebx
f0101636:	74 02                	je     f010163a <page_lookup+0x26>
		*pte_store = pg_tbl_entry;
f0101638:	89 03                	mov    %eax,(%ebx)
	if (pg_tbl_entry == NULL||!((*pg_tbl_entry)&PTE_P)) {
f010163a:	85 c0                	test   %eax,%eax
f010163c:	74 21                	je     f010165f <page_lookup+0x4b>
f010163e:	8b 00                	mov    (%eax),%eax
f0101640:	a8 01                	test   $0x1,%al
f0101642:	74 1b                	je     f010165f <page_lookup+0x4b>
f0101644:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101647:	39 05 14 f4 2b f0    	cmp    %eax,0xf02bf414
f010164d:	76 28                	jbe    f0101677 <page_lookup+0x63>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f010164f:	8b 15 1c f4 2b f0    	mov    0xf02bf41c,%edx
f0101655:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0101658:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010165b:	5b                   	pop    %ebx
f010165c:	5e                   	pop    %esi
f010165d:	5d                   	pop    %ebp
f010165e:	c3                   	ret    
		cprintf("page_lookup: no corresponding page at va:%08x\n", va);
f010165f:	83 ec 08             	sub    $0x8,%esp
f0101662:	56                   	push   %esi
f0101663:	68 28 7e 10 f0       	push   $0xf0107e28
f0101668:	e8 c3 27 00 00       	call   f0103e30 <cprintf>
		return NULL; // 如果没有page映射在va这个位置
f010166d:	83 c4 10             	add    $0x10,%esp
f0101670:	b8 00 00 00 00       	mov    $0x0,%eax
f0101675:	eb e1                	jmp    f0101658 <page_lookup+0x44>
		panic("pa2page called with invalid pa");
f0101677:	83 ec 04             	sub    $0x4,%esp
f010167a:	68 58 7e 10 f0       	push   $0xf0107e58
f010167f:	6a 51                	push   $0x51
f0101681:	68 19 87 10 f0       	push   $0xf0108719
f0101686:	e8 b5 e9 ff ff       	call   f0100040 <_panic>

f010168b <tlb_invalidate>:
{
f010168b:	f3 0f 1e fb          	endbr32 
f010168f:	55                   	push   %ebp
f0101690:	89 e5                	mov    %esp,%ebp
f0101692:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f0101695:	e8 f4 4d 00 00       	call   f010648e <cpunum>
f010169a:	6b c0 74             	imul   $0x74,%eax,%eax
f010169d:	83 b8 28 00 2c f0 00 	cmpl   $0x0,-0xfd3ffd8(%eax)
f01016a4:	74 16                	je     f01016bc <tlb_invalidate+0x31>
f01016a6:	e8 e3 4d 00 00       	call   f010648e <cpunum>
f01016ab:	6b c0 74             	imul   $0x74,%eax,%eax
f01016ae:	8b 80 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%eax
f01016b4:	8b 55 08             	mov    0x8(%ebp),%edx
f01016b7:	39 50 60             	cmp    %edx,0x60(%eax)
f01016ba:	75 06                	jne    f01016c2 <tlb_invalidate+0x37>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01016bc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016bf:	0f 01 38             	invlpg (%eax)
}
f01016c2:	c9                   	leave  
f01016c3:	c3                   	ret    

f01016c4 <page_remove>:
{
f01016c4:	f3 0f 1e fb          	endbr32 
f01016c8:	55                   	push   %ebp
f01016c9:	89 e5                	mov    %esp,%ebp
f01016cb:	56                   	push   %esi
f01016cc:	53                   	push   %ebx
f01016cd:	83 ec 14             	sub    $0x14,%esp
f01016d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01016d3:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo* pp = page_lookup(pgdir, va, &pte_store);
f01016d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01016d9:	50                   	push   %eax
f01016da:	56                   	push   %esi
f01016db:	53                   	push   %ebx
f01016dc:	e8 33 ff ff ff       	call   f0101614 <page_lookup>
	if (pp){
f01016e1:	83 c4 10             	add    $0x10,%esp
f01016e4:	85 c0                	test   %eax,%eax
f01016e6:	74 1f                	je     f0101707 <page_remove+0x43>
		page_decref(pp);// page_decref()内部会free这个page如果count==0
f01016e8:	83 ec 0c             	sub    $0xc,%esp
f01016eb:	50                   	push   %eax
f01016ec:	e8 7e fd ff ff       	call   f010146f <page_decref>
		*pte_store = 0;
f01016f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01016f4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va);
f01016fa:	83 c4 08             	add    $0x8,%esp
f01016fd:	56                   	push   %esi
f01016fe:	53                   	push   %ebx
f01016ff:	e8 87 ff ff ff       	call   f010168b <tlb_invalidate>
f0101704:	83 c4 10             	add    $0x10,%esp
}
f0101707:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010170a:	5b                   	pop    %ebx
f010170b:	5e                   	pop    %esi
f010170c:	5d                   	pop    %ebp
f010170d:	c3                   	ret    

f010170e <page_insert>:
{
f010170e:	f3 0f 1e fb          	endbr32 
f0101712:	55                   	push   %ebp
f0101713:	89 e5                	mov    %esp,%ebp
f0101715:	57                   	push   %edi
f0101716:	56                   	push   %esi
f0101717:	53                   	push   %ebx
f0101718:	83 ec 10             	sub    $0x10,%esp
f010171b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010171e:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t* pg_tbl_entry = pgdir_walk(pgdir, va, 1);
f0101721:	6a 01                	push   $0x1
f0101723:	57                   	push   %edi
f0101724:	ff 75 08             	pushl  0x8(%ebp)
f0101727:	e8 70 fd ff ff       	call   f010149c <pgdir_walk>
	if (pg_tbl_entry == NULL){
f010172c:	83 c4 10             	add    $0x10,%esp
f010172f:	85 c0                	test   %eax,%eax
f0101731:	74 56                	je     f0101789 <page_insert+0x7b>
f0101733:	89 c3                	mov    %eax,%ebx
	if ((*pg_tbl_entry)&PTE_P){
f0101735:	8b 00                	mov    (%eax),%eax
f0101737:	a8 01                	test   $0x1,%al
f0101739:	74 26                	je     f0101761 <page_insert+0x53>
		if (page2pa(pp)==PTE_ADDR(*pg_tbl_entry)){
f010173b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	return (pp - pages) << PGSHIFT;
f0101740:	89 f2                	mov    %esi,%edx
f0101742:	2b 15 1c f4 2b f0    	sub    0xf02bf41c,%edx
f0101748:	c1 fa 03             	sar    $0x3,%edx
f010174b:	c1 e2 0c             	shl    $0xc,%edx
f010174e:	39 d0                	cmp    %edx,%eax
f0101750:	74 4e                	je     f01017a0 <page_insert+0x92>
		else page_remove(pgdir, va); // 内部已经调用了tlb_invalidate
f0101752:	83 ec 08             	sub    $0x8,%esp
f0101755:	57                   	push   %edi
f0101756:	ff 75 08             	pushl  0x8(%ebp)
f0101759:	e8 66 ff ff ff       	call   f01016c4 <page_remove>
f010175e:	83 c4 10             	add    $0x10,%esp
f0101761:	89 f0                	mov    %esi,%eax
f0101763:	2b 05 1c f4 2b f0    	sub    0xf02bf41c,%eax
f0101769:	c1 f8 03             	sar    $0x3,%eax
f010176c:	c1 e0 0c             	shl    $0xc,%eax
	*pg_tbl_entry = page2pa(pp)|perm|PTE_P;
f010176f:	0b 45 14             	or     0x14(%ebp),%eax
f0101772:	83 c8 01             	or     $0x1,%eax
f0101775:	89 03                	mov    %eax,(%ebx)
	pp->pp_ref++;
f0101777:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	return 0;
f010177c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101781:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101784:	5b                   	pop    %ebx
f0101785:	5e                   	pop    %esi
f0101786:	5f                   	pop    %edi
f0101787:	5d                   	pop    %ebp
f0101788:	c3                   	ret    
		cprintf("page_insert: fail to insert a new page table\n");
f0101789:	83 ec 0c             	sub    $0xc,%esp
f010178c:	68 78 7e 10 f0       	push   $0xf0107e78
f0101791:	e8 9a 26 00 00       	call   f0103e30 <cprintf>
		return -E_NO_MEM;
f0101796:	83 c4 10             	add    $0x10,%esp
f0101799:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010179e:	eb e1                	jmp    f0101781 <page_insert+0x73>
			tlb_invalidate(pgdir, va);
f01017a0:	83 ec 08             	sub    $0x8,%esp
f01017a3:	57                   	push   %edi
f01017a4:	ff 75 08             	pushl  0x8(%ebp)
f01017a7:	e8 df fe ff ff       	call   f010168b <tlb_invalidate>
			pp->pp_ref--;
f01017ac:	66 83 6e 04 01       	subw   $0x1,0x4(%esi)
f01017b1:	83 c4 10             	add    $0x10,%esp
f01017b4:	eb ab                	jmp    f0101761 <page_insert+0x53>

f01017b6 <mmio_map_region>:
{
f01017b6:	f3 0f 1e fb          	endbr32 
f01017ba:	55                   	push   %ebp
f01017bb:	89 e5                	mov    %esp,%ebp
f01017bd:	53                   	push   %ebx
f01017be:	83 ec 04             	sub    $0x4,%esp
	size = ROUNDUP(size, PGSIZE);
f01017c1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017c4:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01017ca:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base+size>=MMIOLIM)
f01017d0:	8b 15 00 73 12 f0    	mov    0xf0127300,%edx
f01017d6:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f01017d9:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01017de:	77 26                	ja     f0101806 <mmio_map_region+0x50>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f01017e0:	83 ec 08             	sub    $0x8,%esp
f01017e3:	6a 1a                	push   $0x1a
f01017e5:	ff 75 08             	pushl  0x8(%ebp)
f01017e8:	89 d9                	mov    %ebx,%ecx
f01017ea:	a1 18 f4 2b f0       	mov    0xf02bf418,%eax
f01017ef:	e8 a9 fd ff ff       	call   f010159d <boot_map_region>
	base+=size;
f01017f4:	a1 00 73 12 f0       	mov    0xf0127300,%eax
f01017f9:	01 c3                	add    %eax,%ebx
f01017fb:	89 1d 00 73 12 f0    	mov    %ebx,0xf0127300
}
f0101801:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101804:	c9                   	leave  
f0101805:	c3                   	ret    
		panic("mmio_map_region: overflow MMIOLIM\n");
f0101806:	83 ec 04             	sub    $0x4,%esp
f0101809:	68 a8 7e 10 f0       	push   $0xf0107ea8
f010180e:	68 0b 03 00 00       	push   $0x30b
f0101813:	68 0d 87 10 f0       	push   $0xf010870d
f0101818:	e8 23 e8 ff ff       	call   f0100040 <_panic>

f010181d <mem_init>:
{
f010181d:	f3 0f 1e fb          	endbr32 
f0101821:	55                   	push   %ebp
f0101822:	89 e5                	mov    %esp,%ebp
f0101824:	57                   	push   %edi
f0101825:	56                   	push   %esi
f0101826:	53                   	push   %ebx
f0101827:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f010182a:	b8 15 00 00 00       	mov    $0x15,%eax
f010182f:	e8 4b f6 ff ff       	call   f0100e7f <nvram_read>
f0101834:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101836:	b8 17 00 00 00       	mov    $0x17,%eax
f010183b:	e8 3f f6 ff ff       	call   f0100e7f <nvram_read>
f0101840:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101842:	b8 34 00 00 00       	mov    $0x34,%eax
f0101847:	e8 33 f6 ff ff       	call   f0100e7f <nvram_read>
	if (ext16mem)
f010184c:	c1 e0 06             	shl    $0x6,%eax
f010184f:	0f 84 09 01 00 00    	je     f010195e <mem_init+0x141>
		totalmem = 16 * 1024 + ext16mem;
f0101855:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f010185a:	89 c2                	mov    %eax,%edx
f010185c:	c1 ea 02             	shr    $0x2,%edx
f010185f:	89 15 14 f4 2b f0    	mov    %edx,0xf02bf414
	npages_basemem = basemem / (PGSIZE / 1024);
f0101865:	89 da                	mov    %ebx,%edx
f0101867:	c1 ea 02             	shr    $0x2,%edx
f010186a:	89 15 48 d2 2b f0    	mov    %edx,0xf02bd248
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101870:	89 c2                	mov    %eax,%edx
f0101872:	29 da                	sub    %ebx,%edx
f0101874:	52                   	push   %edx
f0101875:	53                   	push   %ebx
f0101876:	50                   	push   %eax
f0101877:	68 cc 7e 10 f0       	push   $0xf0107ecc
f010187c:	e8 af 25 00 00       	call   f0103e30 <cprintf>
	cprintf("npages at the initialization point: %d\n", npages);
f0101881:	83 c4 08             	add    $0x8,%esp
f0101884:	ff 35 14 f4 2b f0    	pushl  0xf02bf414
f010188a:	68 08 7f 10 f0       	push   $0xf0107f08
f010188f:	e8 9c 25 00 00       	call   f0103e30 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101894:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101899:	e8 ab f5 ff ff       	call   f0100e49 <boot_alloc>
f010189e:	a3 18 f4 2b f0       	mov    %eax,0xf02bf418
	memset(kern_pgdir, 0, PGSIZE);
f01018a3:	83 c4 0c             	add    $0xc,%esp
f01018a6:	68 00 10 00 00       	push   $0x1000
f01018ab:	6a 00                	push   $0x0
f01018ad:	50                   	push   %eax
f01018ae:	e8 ba 45 00 00       	call   f0105e6d <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01018b3:	a1 18 f4 2b f0       	mov    0xf02bf418,%eax
	if ((uint32_t)kva < KERNBASE)
f01018b8:	83 c4 10             	add    $0x10,%esp
f01018bb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01018c0:	0f 86 a8 00 00 00    	jbe    f010196e <mem_init+0x151>
	return (physaddr_t)kva - KERNBASE;
f01018c6:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01018cc:	83 ca 05             	or     $0x5,%edx
f01018cf:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo* ) boot_alloc(sizeof(struct PageInfo)*npages);
f01018d5:	a1 14 f4 2b f0       	mov    0xf02bf414,%eax
f01018da:	c1 e0 03             	shl    $0x3,%eax
f01018dd:	e8 67 f5 ff ff       	call   f0100e49 <boot_alloc>
f01018e2:	a3 1c f4 2b f0       	mov    %eax,0xf02bf41c
	memset(pages, 0, sizeof(struct PageInfo)*npages);
f01018e7:	83 ec 04             	sub    $0x4,%esp
f01018ea:	8b 0d 14 f4 2b f0    	mov    0xf02bf414,%ecx
f01018f0:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01018f7:	52                   	push   %edx
f01018f8:	6a 00                	push   $0x0
f01018fa:	50                   	push   %eax
f01018fb:	e8 6d 45 00 00       	call   f0105e6d <memset>
	envs = (struct Env*) boot_alloc(sizeof(struct Env)*NENV);
f0101900:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101905:	e8 3f f5 ff ff       	call   f0100e49 <boot_alloc>
f010190a:	a3 4c d2 2b f0       	mov    %eax,0xf02bd24c
	memset(envs, 0, sizeof(struct Env)*NENV);
f010190f:	83 c4 0c             	add    $0xc,%esp
f0101912:	68 00 f0 01 00       	push   $0x1f000
f0101917:	6a 00                	push   $0x0
f0101919:	50                   	push   %eax
f010191a:	e8 4e 45 00 00       	call   f0105e6d <memset>
	page_init();
f010191f:	e8 d5 f8 ff ff       	call   f01011f9 <page_init>
	check_page_free_list(1);
f0101924:	b8 01 00 00 00       	mov    $0x1,%eax
f0101929:	e8 dd f5 ff ff       	call   f0100f0b <check_page_free_list>
	cprintf("entering check_page_alloc\n");
f010192e:	c7 04 24 e0 87 10 f0 	movl   $0xf01087e0,(%esp)
f0101935:	e8 f6 24 00 00       	call   f0103e30 <cprintf>
	if (!pages)
f010193a:	83 c4 10             	add    $0x10,%esp
f010193d:	83 3d 1c f4 2b f0 00 	cmpl   $0x0,0xf02bf41c
f0101944:	74 3d                	je     f0101983 <mem_init+0x166>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101946:	a1 44 d2 2b f0       	mov    0xf02bd244,%eax
f010194b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0101952:	85 c0                	test   %eax,%eax
f0101954:	74 44                	je     f010199a <mem_init+0x17d>
		++nfree;
f0101956:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010195a:	8b 00                	mov    (%eax),%eax
f010195c:	eb f4                	jmp    f0101952 <mem_init+0x135>
		totalmem = 1 * 1024 + extmem;
f010195e:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101964:	85 f6                	test   %esi,%esi
f0101966:	0f 44 c3             	cmove  %ebx,%eax
f0101969:	e9 ec fe ff ff       	jmp    f010185a <mem_init+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010196e:	50                   	push   %eax
f010196f:	68 68 74 10 f0       	push   $0xf0107468
f0101974:	68 9a 00 00 00       	push   $0x9a
f0101979:	68 0d 87 10 f0       	push   $0xf010870d
f010197e:	e8 bd e6 ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f0101983:	83 ec 04             	sub    $0x4,%esp
f0101986:	68 fb 87 10 f0       	push   $0xf01087fb
f010198b:	68 a4 03 00 00       	push   $0x3a4
f0101990:	68 0d 87 10 f0       	push   $0xf010870d
f0101995:	e8 a6 e6 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f010199a:	83 ec 0c             	sub    $0xc,%esp
f010199d:	6a 00                	push   $0x0
f010199f:	e8 fc f9 ff ff       	call   f01013a0 <page_alloc>
f01019a4:	89 c3                	mov    %eax,%ebx
f01019a6:	83 c4 10             	add    $0x10,%esp
f01019a9:	85 c0                	test   %eax,%eax
f01019ab:	0f 84 11 02 00 00    	je     f0101bc2 <mem_init+0x3a5>
	assert((pp1 = page_alloc(0)));
f01019b1:	83 ec 0c             	sub    $0xc,%esp
f01019b4:	6a 00                	push   $0x0
f01019b6:	e8 e5 f9 ff ff       	call   f01013a0 <page_alloc>
f01019bb:	89 c6                	mov    %eax,%esi
f01019bd:	83 c4 10             	add    $0x10,%esp
f01019c0:	85 c0                	test   %eax,%eax
f01019c2:	0f 84 13 02 00 00    	je     f0101bdb <mem_init+0x3be>
	assert((pp2 = page_alloc(0)));
f01019c8:	83 ec 0c             	sub    $0xc,%esp
f01019cb:	6a 00                	push   $0x0
f01019cd:	e8 ce f9 ff ff       	call   f01013a0 <page_alloc>
f01019d2:	89 c7                	mov    %eax,%edi
f01019d4:	83 c4 10             	add    $0x10,%esp
f01019d7:	85 c0                	test   %eax,%eax
f01019d9:	0f 84 15 02 00 00    	je     f0101bf4 <mem_init+0x3d7>
	assert(pp1 && pp1 != pp0);
f01019df:	39 f3                	cmp    %esi,%ebx
f01019e1:	0f 84 26 02 00 00    	je     f0101c0d <mem_init+0x3f0>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019e7:	39 c6                	cmp    %eax,%esi
f01019e9:	0f 84 37 02 00 00    	je     f0101c26 <mem_init+0x409>
f01019ef:	39 c3                	cmp    %eax,%ebx
f01019f1:	0f 84 2f 02 00 00    	je     f0101c26 <mem_init+0x409>
	return (pp - pages) << PGSHIFT;
f01019f7:	8b 0d 1c f4 2b f0    	mov    0xf02bf41c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01019fd:	8b 15 14 f4 2b f0    	mov    0xf02bf414,%edx
f0101a03:	c1 e2 0c             	shl    $0xc,%edx
f0101a06:	89 d8                	mov    %ebx,%eax
f0101a08:	29 c8                	sub    %ecx,%eax
f0101a0a:	c1 f8 03             	sar    $0x3,%eax
f0101a0d:	c1 e0 0c             	shl    $0xc,%eax
f0101a10:	39 d0                	cmp    %edx,%eax
f0101a12:	0f 83 27 02 00 00    	jae    f0101c3f <mem_init+0x422>
f0101a18:	89 f0                	mov    %esi,%eax
f0101a1a:	29 c8                	sub    %ecx,%eax
f0101a1c:	c1 f8 03             	sar    $0x3,%eax
f0101a1f:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101a22:	39 c2                	cmp    %eax,%edx
f0101a24:	0f 86 2e 02 00 00    	jbe    f0101c58 <mem_init+0x43b>
f0101a2a:	89 f8                	mov    %edi,%eax
f0101a2c:	29 c8                	sub    %ecx,%eax
f0101a2e:	c1 f8 03             	sar    $0x3,%eax
f0101a31:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101a34:	39 c2                	cmp    %eax,%edx
f0101a36:	0f 86 35 02 00 00    	jbe    f0101c71 <mem_init+0x454>
	fl = page_free_list;
f0101a3c:	a1 44 d2 2b f0       	mov    0xf02bd244,%eax
f0101a41:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101a44:	c7 05 44 d2 2b f0 00 	movl   $0x0,0xf02bd244
f0101a4b:	00 00 00 
	assert(!page_alloc(0));
f0101a4e:	83 ec 0c             	sub    $0xc,%esp
f0101a51:	6a 00                	push   $0x0
f0101a53:	e8 48 f9 ff ff       	call   f01013a0 <page_alloc>
f0101a58:	83 c4 10             	add    $0x10,%esp
f0101a5b:	85 c0                	test   %eax,%eax
f0101a5d:	0f 85 27 02 00 00    	jne    f0101c8a <mem_init+0x46d>
	page_free(pp0);
f0101a63:	83 ec 0c             	sub    $0xc,%esp
f0101a66:	53                   	push   %ebx
f0101a67:	e8 ad f9 ff ff       	call   f0101419 <page_free>
	page_free(pp1);
f0101a6c:	89 34 24             	mov    %esi,(%esp)
f0101a6f:	e8 a5 f9 ff ff       	call   f0101419 <page_free>
	page_free(pp2);
f0101a74:	89 3c 24             	mov    %edi,(%esp)
f0101a77:	e8 9d f9 ff ff       	call   f0101419 <page_free>
	assert((pp0 = page_alloc(0)));
f0101a7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a83:	e8 18 f9 ff ff       	call   f01013a0 <page_alloc>
f0101a88:	89 c3                	mov    %eax,%ebx
f0101a8a:	83 c4 10             	add    $0x10,%esp
f0101a8d:	85 c0                	test   %eax,%eax
f0101a8f:	0f 84 0e 02 00 00    	je     f0101ca3 <mem_init+0x486>
	assert((pp1 = page_alloc(0)));
f0101a95:	83 ec 0c             	sub    $0xc,%esp
f0101a98:	6a 00                	push   $0x0
f0101a9a:	e8 01 f9 ff ff       	call   f01013a0 <page_alloc>
f0101a9f:	89 c6                	mov    %eax,%esi
f0101aa1:	83 c4 10             	add    $0x10,%esp
f0101aa4:	85 c0                	test   %eax,%eax
f0101aa6:	0f 84 10 02 00 00    	je     f0101cbc <mem_init+0x49f>
	assert((pp2 = page_alloc(0)));
f0101aac:	83 ec 0c             	sub    $0xc,%esp
f0101aaf:	6a 00                	push   $0x0
f0101ab1:	e8 ea f8 ff ff       	call   f01013a0 <page_alloc>
f0101ab6:	89 c7                	mov    %eax,%edi
f0101ab8:	83 c4 10             	add    $0x10,%esp
f0101abb:	85 c0                	test   %eax,%eax
f0101abd:	0f 84 12 02 00 00    	je     f0101cd5 <mem_init+0x4b8>
	assert(pp1 && pp1 != pp0);
f0101ac3:	39 f3                	cmp    %esi,%ebx
f0101ac5:	0f 84 23 02 00 00    	je     f0101cee <mem_init+0x4d1>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101acb:	39 c3                	cmp    %eax,%ebx
f0101acd:	0f 84 34 02 00 00    	je     f0101d07 <mem_init+0x4ea>
f0101ad3:	39 c6                	cmp    %eax,%esi
f0101ad5:	0f 84 2c 02 00 00    	je     f0101d07 <mem_init+0x4ea>
	assert(!page_alloc(0));
f0101adb:	83 ec 0c             	sub    $0xc,%esp
f0101ade:	6a 00                	push   $0x0
f0101ae0:	e8 bb f8 ff ff       	call   f01013a0 <page_alloc>
f0101ae5:	83 c4 10             	add    $0x10,%esp
f0101ae8:	85 c0                	test   %eax,%eax
f0101aea:	0f 85 30 02 00 00    	jne    f0101d20 <mem_init+0x503>
f0101af0:	89 d8                	mov    %ebx,%eax
f0101af2:	2b 05 1c f4 2b f0    	sub    0xf02bf41c,%eax
f0101af8:	c1 f8 03             	sar    $0x3,%eax
f0101afb:	89 c2                	mov    %eax,%edx
f0101afd:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101b00:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101b05:	3b 05 14 f4 2b f0    	cmp    0xf02bf414,%eax
f0101b0b:	0f 83 28 02 00 00    	jae    f0101d39 <mem_init+0x51c>
	memset(page2kva(pp0), 1, PGSIZE);
f0101b11:	83 ec 04             	sub    $0x4,%esp
f0101b14:	68 00 10 00 00       	push   $0x1000
f0101b19:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101b1b:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101b21:	52                   	push   %edx
f0101b22:	e8 46 43 00 00       	call   f0105e6d <memset>
	page_free(pp0);
f0101b27:	89 1c 24             	mov    %ebx,(%esp)
f0101b2a:	e8 ea f8 ff ff       	call   f0101419 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101b2f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101b36:	e8 65 f8 ff ff       	call   f01013a0 <page_alloc>
f0101b3b:	83 c4 10             	add    $0x10,%esp
f0101b3e:	85 c0                	test   %eax,%eax
f0101b40:	0f 84 05 02 00 00    	je     f0101d4b <mem_init+0x52e>
	assert(pp && pp0 == pp);
f0101b46:	39 c3                	cmp    %eax,%ebx
f0101b48:	0f 85 16 02 00 00    	jne    f0101d64 <mem_init+0x547>
	return (pp - pages) << PGSHIFT;
f0101b4e:	2b 05 1c f4 2b f0    	sub    0xf02bf41c,%eax
f0101b54:	c1 f8 03             	sar    $0x3,%eax
f0101b57:	89 c2                	mov    %eax,%edx
f0101b59:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101b5c:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101b61:	3b 05 14 f4 2b f0    	cmp    0xf02bf414,%eax
f0101b67:	0f 83 10 02 00 00    	jae    f0101d7d <mem_init+0x560>
	return (void *)(pa + KERNBASE);
f0101b6d:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101b73:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101b79:	80 38 00             	cmpb   $0x0,(%eax)
f0101b7c:	0f 85 0d 02 00 00    	jne    f0101d8f <mem_init+0x572>
f0101b82:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101b85:	39 d0                	cmp    %edx,%eax
f0101b87:	75 f0                	jne    f0101b79 <mem_init+0x35c>
	page_free_list = fl;
f0101b89:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b8c:	a3 44 d2 2b f0       	mov    %eax,0xf02bd244
	page_free(pp0);
f0101b91:	83 ec 0c             	sub    $0xc,%esp
f0101b94:	53                   	push   %ebx
f0101b95:	e8 7f f8 ff ff       	call   f0101419 <page_free>
	page_free(pp1);
f0101b9a:	89 34 24             	mov    %esi,(%esp)
f0101b9d:	e8 77 f8 ff ff       	call   f0101419 <page_free>
	page_free(pp2);
f0101ba2:	89 3c 24             	mov    %edi,(%esp)
f0101ba5:	e8 6f f8 ff ff       	call   f0101419 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101baa:	a1 44 d2 2b f0       	mov    0xf02bd244,%eax
f0101baf:	83 c4 10             	add    $0x10,%esp
f0101bb2:	85 c0                	test   %eax,%eax
f0101bb4:	0f 84 ee 01 00 00    	je     f0101da8 <mem_init+0x58b>
		--nfree;
f0101bba:	83 6d d4 01          	subl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101bbe:	8b 00                	mov    (%eax),%eax
f0101bc0:	eb f0                	jmp    f0101bb2 <mem_init+0x395>
	assert((pp0 = page_alloc(0)));
f0101bc2:	68 16 88 10 f0       	push   $0xf0108816
f0101bc7:	68 33 87 10 f0       	push   $0xf0108733
f0101bcc:	68 ac 03 00 00       	push   $0x3ac
f0101bd1:	68 0d 87 10 f0       	push   $0xf010870d
f0101bd6:	e8 65 e4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101bdb:	68 2c 88 10 f0       	push   $0xf010882c
f0101be0:	68 33 87 10 f0       	push   $0xf0108733
f0101be5:	68 ad 03 00 00       	push   $0x3ad
f0101bea:	68 0d 87 10 f0       	push   $0xf010870d
f0101bef:	e8 4c e4 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101bf4:	68 42 88 10 f0       	push   $0xf0108842
f0101bf9:	68 33 87 10 f0       	push   $0xf0108733
f0101bfe:	68 ae 03 00 00       	push   $0x3ae
f0101c03:	68 0d 87 10 f0       	push   $0xf010870d
f0101c08:	e8 33 e4 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101c0d:	68 58 88 10 f0       	push   $0xf0108858
f0101c12:	68 33 87 10 f0       	push   $0xf0108733
f0101c17:	68 b1 03 00 00       	push   $0x3b1
f0101c1c:	68 0d 87 10 f0       	push   $0xf010870d
f0101c21:	e8 1a e4 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c26:	68 30 7f 10 f0       	push   $0xf0107f30
f0101c2b:	68 33 87 10 f0       	push   $0xf0108733
f0101c30:	68 b2 03 00 00       	push   $0x3b2
f0101c35:	68 0d 87 10 f0       	push   $0xf010870d
f0101c3a:	e8 01 e4 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101c3f:	68 6a 88 10 f0       	push   $0xf010886a
f0101c44:	68 33 87 10 f0       	push   $0xf0108733
f0101c49:	68 b3 03 00 00       	push   $0x3b3
f0101c4e:	68 0d 87 10 f0       	push   $0xf010870d
f0101c53:	e8 e8 e3 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101c58:	68 87 88 10 f0       	push   $0xf0108887
f0101c5d:	68 33 87 10 f0       	push   $0xf0108733
f0101c62:	68 b4 03 00 00       	push   $0x3b4
f0101c67:	68 0d 87 10 f0       	push   $0xf010870d
f0101c6c:	e8 cf e3 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101c71:	68 a4 88 10 f0       	push   $0xf01088a4
f0101c76:	68 33 87 10 f0       	push   $0xf0108733
f0101c7b:	68 b5 03 00 00       	push   $0x3b5
f0101c80:	68 0d 87 10 f0       	push   $0xf010870d
f0101c85:	e8 b6 e3 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101c8a:	68 c1 88 10 f0       	push   $0xf01088c1
f0101c8f:	68 33 87 10 f0       	push   $0xf0108733
f0101c94:	68 bc 03 00 00       	push   $0x3bc
f0101c99:	68 0d 87 10 f0       	push   $0xf010870d
f0101c9e:	e8 9d e3 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0101ca3:	68 16 88 10 f0       	push   $0xf0108816
f0101ca8:	68 33 87 10 f0       	push   $0xf0108733
f0101cad:	68 c3 03 00 00       	push   $0x3c3
f0101cb2:	68 0d 87 10 f0       	push   $0xf010870d
f0101cb7:	e8 84 e3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101cbc:	68 2c 88 10 f0       	push   $0xf010882c
f0101cc1:	68 33 87 10 f0       	push   $0xf0108733
f0101cc6:	68 c4 03 00 00       	push   $0x3c4
f0101ccb:	68 0d 87 10 f0       	push   $0xf010870d
f0101cd0:	e8 6b e3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101cd5:	68 42 88 10 f0       	push   $0xf0108842
f0101cda:	68 33 87 10 f0       	push   $0xf0108733
f0101cdf:	68 c5 03 00 00       	push   $0x3c5
f0101ce4:	68 0d 87 10 f0       	push   $0xf010870d
f0101ce9:	e8 52 e3 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101cee:	68 58 88 10 f0       	push   $0xf0108858
f0101cf3:	68 33 87 10 f0       	push   $0xf0108733
f0101cf8:	68 c7 03 00 00       	push   $0x3c7
f0101cfd:	68 0d 87 10 f0       	push   $0xf010870d
f0101d02:	e8 39 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d07:	68 30 7f 10 f0       	push   $0xf0107f30
f0101d0c:	68 33 87 10 f0       	push   $0xf0108733
f0101d11:	68 c8 03 00 00       	push   $0x3c8
f0101d16:	68 0d 87 10 f0       	push   $0xf010870d
f0101d1b:	e8 20 e3 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101d20:	68 c1 88 10 f0       	push   $0xf01088c1
f0101d25:	68 33 87 10 f0       	push   $0xf0108733
f0101d2a:	68 c9 03 00 00       	push   $0x3c9
f0101d2f:	68 0d 87 10 f0       	push   $0xf010870d
f0101d34:	e8 07 e3 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d39:	52                   	push   %edx
f0101d3a:	68 44 74 10 f0       	push   $0xf0107444
f0101d3f:	6a 58                	push   $0x58
f0101d41:	68 19 87 10 f0       	push   $0xf0108719
f0101d46:	e8 f5 e2 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101d4b:	68 d0 88 10 f0       	push   $0xf01088d0
f0101d50:	68 33 87 10 f0       	push   $0xf0108733
f0101d55:	68 ce 03 00 00       	push   $0x3ce
f0101d5a:	68 0d 87 10 f0       	push   $0xf010870d
f0101d5f:	e8 dc e2 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101d64:	68 ee 88 10 f0       	push   $0xf01088ee
f0101d69:	68 33 87 10 f0       	push   $0xf0108733
f0101d6e:	68 cf 03 00 00       	push   $0x3cf
f0101d73:	68 0d 87 10 f0       	push   $0xf010870d
f0101d78:	e8 c3 e2 ff ff       	call   f0100040 <_panic>
f0101d7d:	52                   	push   %edx
f0101d7e:	68 44 74 10 f0       	push   $0xf0107444
f0101d83:	6a 58                	push   $0x58
f0101d85:	68 19 87 10 f0       	push   $0xf0108719
f0101d8a:	e8 b1 e2 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f0101d8f:	68 fe 88 10 f0       	push   $0xf01088fe
f0101d94:	68 33 87 10 f0       	push   $0xf0108733
f0101d99:	68 d2 03 00 00       	push   $0x3d2
f0101d9e:	68 0d 87 10 f0       	push   $0xf010870d
f0101da3:	e8 98 e2 ff ff       	call   f0100040 <_panic>
	assert(nfree == 0);
f0101da8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101dac:	0f 85 5e 09 00 00    	jne    f0102710 <mem_init+0xef3>
	cprintf("check_page_alloc() succeeded!\n");
f0101db2:	83 ec 0c             	sub    $0xc,%esp
f0101db5:	68 50 7f 10 f0       	push   $0xf0107f50
f0101dba:	e8 71 20 00 00       	call   f0103e30 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101dbf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101dc6:	e8 d5 f5 ff ff       	call   f01013a0 <page_alloc>
f0101dcb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101dce:	83 c4 10             	add    $0x10,%esp
f0101dd1:	85 c0                	test   %eax,%eax
f0101dd3:	0f 84 50 09 00 00    	je     f0102729 <mem_init+0xf0c>
	assert((pp1 = page_alloc(0)));
f0101dd9:	83 ec 0c             	sub    $0xc,%esp
f0101ddc:	6a 00                	push   $0x0
f0101dde:	e8 bd f5 ff ff       	call   f01013a0 <page_alloc>
f0101de3:	89 c7                	mov    %eax,%edi
f0101de5:	83 c4 10             	add    $0x10,%esp
f0101de8:	85 c0                	test   %eax,%eax
f0101dea:	0f 84 52 09 00 00    	je     f0102742 <mem_init+0xf25>
	assert((pp2 = page_alloc(0)));
f0101df0:	83 ec 0c             	sub    $0xc,%esp
f0101df3:	6a 00                	push   $0x0
f0101df5:	e8 a6 f5 ff ff       	call   f01013a0 <page_alloc>
f0101dfa:	89 c3                	mov    %eax,%ebx
f0101dfc:	83 c4 10             	add    $0x10,%esp
f0101dff:	85 c0                	test   %eax,%eax
f0101e01:	0f 84 54 09 00 00    	je     f010275b <mem_init+0xf3e>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101e07:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f0101e0a:	0f 84 64 09 00 00    	je     f0102774 <mem_init+0xf57>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101e10:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101e13:	0f 84 74 09 00 00    	je     f010278d <mem_init+0xf70>
f0101e19:	39 c7                	cmp    %eax,%edi
f0101e1b:	0f 84 6c 09 00 00    	je     f010278d <mem_init+0xf70>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101e21:	a1 44 d2 2b f0       	mov    0xf02bd244,%eax
f0101e26:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101e29:	c7 05 44 d2 2b f0 00 	movl   $0x0,0xf02bd244
f0101e30:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101e33:	83 ec 0c             	sub    $0xc,%esp
f0101e36:	6a 00                	push   $0x0
f0101e38:	e8 63 f5 ff ff       	call   f01013a0 <page_alloc>
f0101e3d:	83 c4 10             	add    $0x10,%esp
f0101e40:	85 c0                	test   %eax,%eax
f0101e42:	0f 85 5e 09 00 00    	jne    f01027a6 <mem_init+0xf89>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101e48:	83 ec 04             	sub    $0x4,%esp
f0101e4b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101e4e:	50                   	push   %eax
f0101e4f:	6a 00                	push   $0x0
f0101e51:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f0101e57:	e8 b8 f7 ff ff       	call   f0101614 <page_lookup>
f0101e5c:	83 c4 10             	add    $0x10,%esp
f0101e5f:	85 c0                	test   %eax,%eax
f0101e61:	0f 85 58 09 00 00    	jne    f01027bf <mem_init+0xfa2>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101e67:	6a 02                	push   $0x2
f0101e69:	6a 00                	push   $0x0
f0101e6b:	57                   	push   %edi
f0101e6c:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f0101e72:	e8 97 f8 ff ff       	call   f010170e <page_insert>
f0101e77:	83 c4 10             	add    $0x10,%esp
f0101e7a:	85 c0                	test   %eax,%eax
f0101e7c:	0f 89 56 09 00 00    	jns    f01027d8 <mem_init+0xfbb>
	
	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101e82:	83 ec 0c             	sub    $0xc,%esp
f0101e85:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101e88:	e8 8c f5 ff ff       	call   f0101419 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101e8d:	6a 02                	push   $0x2
f0101e8f:	6a 00                	push   $0x0
f0101e91:	57                   	push   %edi
f0101e92:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f0101e98:	e8 71 f8 ff ff       	call   f010170e <page_insert>
f0101e9d:	83 c4 20             	add    $0x20,%esp
f0101ea0:	85 c0                	test   %eax,%eax
f0101ea2:	0f 85 49 09 00 00    	jne    f01027f1 <mem_init+0xfd4>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ea8:	8b 35 18 f4 2b f0    	mov    0xf02bf418,%esi
	return (pp - pages) << PGSHIFT;
f0101eae:	8b 0d 1c f4 2b f0    	mov    0xf02bf41c,%ecx
f0101eb4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101eb7:	8b 16                	mov    (%esi),%edx
f0101eb9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ebf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ec2:	29 c8                	sub    %ecx,%eax
f0101ec4:	c1 f8 03             	sar    $0x3,%eax
f0101ec7:	c1 e0 0c             	shl    $0xc,%eax
f0101eca:	39 c2                	cmp    %eax,%edx
f0101ecc:	0f 85 38 09 00 00    	jne    f010280a <mem_init+0xfed>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101ed2:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ed7:	89 f0                	mov    %esi,%eax
f0101ed9:	e8 ca ef ff ff       	call   f0100ea8 <check_va2pa>
f0101ede:	89 c2                	mov    %eax,%edx
f0101ee0:	89 f8                	mov    %edi,%eax
f0101ee2:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101ee5:	c1 f8 03             	sar    $0x3,%eax
f0101ee8:	c1 e0 0c             	shl    $0xc,%eax
f0101eeb:	39 c2                	cmp    %eax,%edx
f0101eed:	0f 85 30 09 00 00    	jne    f0102823 <mem_init+0x1006>
	assert(pp1->pp_ref == 1);
f0101ef3:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101ef8:	0f 85 3e 09 00 00    	jne    f010283c <mem_init+0x101f>
	assert(pp0->pp_ref == 1);
f0101efe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f01:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101f06:	0f 85 49 09 00 00    	jne    f0102855 <mem_init+0x1038>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f0c:	6a 02                	push   $0x2
f0101f0e:	68 00 10 00 00       	push   $0x1000
f0101f13:	53                   	push   %ebx
f0101f14:	56                   	push   %esi
f0101f15:	e8 f4 f7 ff ff       	call   f010170e <page_insert>
f0101f1a:	83 c4 10             	add    $0x10,%esp
f0101f1d:	85 c0                	test   %eax,%eax
f0101f1f:	0f 85 49 09 00 00    	jne    f010286e <mem_init+0x1051>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f25:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f2a:	a1 18 f4 2b f0       	mov    0xf02bf418,%eax
f0101f2f:	e8 74 ef ff ff       	call   f0100ea8 <check_va2pa>
f0101f34:	89 c2                	mov    %eax,%edx
f0101f36:	89 d8                	mov    %ebx,%eax
f0101f38:	2b 05 1c f4 2b f0    	sub    0xf02bf41c,%eax
f0101f3e:	c1 f8 03             	sar    $0x3,%eax
f0101f41:	c1 e0 0c             	shl    $0xc,%eax
f0101f44:	39 c2                	cmp    %eax,%edx
f0101f46:	0f 85 3b 09 00 00    	jne    f0102887 <mem_init+0x106a>
	assert(pp2->pp_ref == 1);
f0101f4c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f51:	0f 85 49 09 00 00    	jne    f01028a0 <mem_init+0x1083>

	// should be no free memory
	assert(!page_alloc(0));
f0101f57:	83 ec 0c             	sub    $0xc,%esp
f0101f5a:	6a 00                	push   $0x0
f0101f5c:	e8 3f f4 ff ff       	call   f01013a0 <page_alloc>
f0101f61:	83 c4 10             	add    $0x10,%esp
f0101f64:	85 c0                	test   %eax,%eax
f0101f66:	0f 85 4d 09 00 00    	jne    f01028b9 <mem_init+0x109c>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f6c:	6a 02                	push   $0x2
f0101f6e:	68 00 10 00 00       	push   $0x1000
f0101f73:	53                   	push   %ebx
f0101f74:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f0101f7a:	e8 8f f7 ff ff       	call   f010170e <page_insert>
f0101f7f:	83 c4 10             	add    $0x10,%esp
f0101f82:	85 c0                	test   %eax,%eax
f0101f84:	0f 85 48 09 00 00    	jne    f01028d2 <mem_init+0x10b5>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f8a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f8f:	a1 18 f4 2b f0       	mov    0xf02bf418,%eax
f0101f94:	e8 0f ef ff ff       	call   f0100ea8 <check_va2pa>
f0101f99:	89 c2                	mov    %eax,%edx
f0101f9b:	89 d8                	mov    %ebx,%eax
f0101f9d:	2b 05 1c f4 2b f0    	sub    0xf02bf41c,%eax
f0101fa3:	c1 f8 03             	sar    $0x3,%eax
f0101fa6:	c1 e0 0c             	shl    $0xc,%eax
f0101fa9:	39 c2                	cmp    %eax,%edx
f0101fab:	0f 85 3a 09 00 00    	jne    f01028eb <mem_init+0x10ce>
	assert(pp2->pp_ref == 1);
f0101fb1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101fb6:	0f 85 48 09 00 00    	jne    f0102904 <mem_init+0x10e7>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101fbc:	83 ec 0c             	sub    $0xc,%esp
f0101fbf:	6a 00                	push   $0x0
f0101fc1:	e8 da f3 ff ff       	call   f01013a0 <page_alloc>
f0101fc6:	83 c4 10             	add    $0x10,%esp
f0101fc9:	85 c0                	test   %eax,%eax
f0101fcb:	0f 85 4c 09 00 00    	jne    f010291d <mem_init+0x1100>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101fd1:	8b 0d 18 f4 2b f0    	mov    0xf02bf418,%ecx
f0101fd7:	8b 01                	mov    (%ecx),%eax
f0101fd9:	89 c2                	mov    %eax,%edx
f0101fdb:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101fe1:	c1 e8 0c             	shr    $0xc,%eax
f0101fe4:	3b 05 14 f4 2b f0    	cmp    0xf02bf414,%eax
f0101fea:	0f 83 46 09 00 00    	jae    f0102936 <mem_init+0x1119>
	return (void *)(pa + KERNBASE);
f0101ff0:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101ff6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ff9:	83 ec 04             	sub    $0x4,%esp
f0101ffc:	6a 00                	push   $0x0
f0101ffe:	68 00 10 00 00       	push   $0x1000
f0102003:	51                   	push   %ecx
f0102004:	e8 93 f4 ff ff       	call   f010149c <pgdir_walk>
f0102009:	89 c2                	mov    %eax,%edx
f010200b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010200e:	83 c0 04             	add    $0x4,%eax
f0102011:	83 c4 10             	add    $0x10,%esp
f0102014:	39 d0                	cmp    %edx,%eax
f0102016:	0f 85 2f 09 00 00    	jne    f010294b <mem_init+0x112e>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010201c:	6a 06                	push   $0x6
f010201e:	68 00 10 00 00       	push   $0x1000
f0102023:	53                   	push   %ebx
f0102024:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f010202a:	e8 df f6 ff ff       	call   f010170e <page_insert>
f010202f:	83 c4 10             	add    $0x10,%esp
f0102032:	85 c0                	test   %eax,%eax
f0102034:	0f 85 2a 09 00 00    	jne    f0102964 <mem_init+0x1147>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010203a:	8b 35 18 f4 2b f0    	mov    0xf02bf418,%esi
f0102040:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102045:	89 f0                	mov    %esi,%eax
f0102047:	e8 5c ee ff ff       	call   f0100ea8 <check_va2pa>
f010204c:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f010204e:	89 d8                	mov    %ebx,%eax
f0102050:	2b 05 1c f4 2b f0    	sub    0xf02bf41c,%eax
f0102056:	c1 f8 03             	sar    $0x3,%eax
f0102059:	c1 e0 0c             	shl    $0xc,%eax
f010205c:	39 c2                	cmp    %eax,%edx
f010205e:	0f 85 19 09 00 00    	jne    f010297d <mem_init+0x1160>
	assert(pp2->pp_ref == 1);
f0102064:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102069:	0f 85 27 09 00 00    	jne    f0102996 <mem_init+0x1179>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010206f:	83 ec 04             	sub    $0x4,%esp
f0102072:	6a 00                	push   $0x0
f0102074:	68 00 10 00 00       	push   $0x1000
f0102079:	56                   	push   %esi
f010207a:	e8 1d f4 ff ff       	call   f010149c <pgdir_walk>
f010207f:	83 c4 10             	add    $0x10,%esp
f0102082:	f6 00 04             	testb  $0x4,(%eax)
f0102085:	0f 84 24 09 00 00    	je     f01029af <mem_init+0x1192>
	assert(kern_pgdir[0] & PTE_U);
f010208b:	a1 18 f4 2b f0       	mov    0xf02bf418,%eax
f0102090:	f6 00 04             	testb  $0x4,(%eax)
f0102093:	0f 84 2f 09 00 00    	je     f01029c8 <mem_init+0x11ab>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102099:	6a 02                	push   $0x2
f010209b:	68 00 10 00 00       	push   $0x1000
f01020a0:	53                   	push   %ebx
f01020a1:	50                   	push   %eax
f01020a2:	e8 67 f6 ff ff       	call   f010170e <page_insert>
f01020a7:	83 c4 10             	add    $0x10,%esp
f01020aa:	85 c0                	test   %eax,%eax
f01020ac:	0f 85 2f 09 00 00    	jne    f01029e1 <mem_init+0x11c4>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01020b2:	83 ec 04             	sub    $0x4,%esp
f01020b5:	6a 00                	push   $0x0
f01020b7:	68 00 10 00 00       	push   $0x1000
f01020bc:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f01020c2:	e8 d5 f3 ff ff       	call   f010149c <pgdir_walk>
f01020c7:	83 c4 10             	add    $0x10,%esp
f01020ca:	f6 00 02             	testb  $0x2,(%eax)
f01020cd:	0f 84 27 09 00 00    	je     f01029fa <mem_init+0x11dd>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020d3:	83 ec 04             	sub    $0x4,%esp
f01020d6:	6a 00                	push   $0x0
f01020d8:	68 00 10 00 00       	push   $0x1000
f01020dd:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f01020e3:	e8 b4 f3 ff ff       	call   f010149c <pgdir_walk>
f01020e8:	83 c4 10             	add    $0x10,%esp
f01020eb:	f6 00 04             	testb  $0x4,(%eax)
f01020ee:	0f 85 1f 09 00 00    	jne    f0102a13 <mem_init+0x11f6>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01020f4:	6a 02                	push   $0x2
f01020f6:	68 00 00 40 00       	push   $0x400000
f01020fb:	ff 75 d4             	pushl  -0x2c(%ebp)
f01020fe:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f0102104:	e8 05 f6 ff ff       	call   f010170e <page_insert>
f0102109:	83 c4 10             	add    $0x10,%esp
f010210c:	85 c0                	test   %eax,%eax
f010210e:	0f 89 18 09 00 00    	jns    f0102a2c <mem_init+0x120f>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102114:	6a 02                	push   $0x2
f0102116:	68 00 10 00 00       	push   $0x1000
f010211b:	57                   	push   %edi
f010211c:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f0102122:	e8 e7 f5 ff ff       	call   f010170e <page_insert>
f0102127:	83 c4 10             	add    $0x10,%esp
f010212a:	85 c0                	test   %eax,%eax
f010212c:	0f 85 13 09 00 00    	jne    f0102a45 <mem_init+0x1228>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102132:	83 ec 04             	sub    $0x4,%esp
f0102135:	6a 00                	push   $0x0
f0102137:	68 00 10 00 00       	push   $0x1000
f010213c:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f0102142:	e8 55 f3 ff ff       	call   f010149c <pgdir_walk>
f0102147:	83 c4 10             	add    $0x10,%esp
f010214a:	f6 00 04             	testb  $0x4,(%eax)
f010214d:	0f 85 0b 09 00 00    	jne    f0102a5e <mem_init+0x1241>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102153:	a1 18 f4 2b f0       	mov    0xf02bf418,%eax
f0102158:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010215b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102160:	e8 43 ed ff ff       	call   f0100ea8 <check_va2pa>
f0102165:	89 fe                	mov    %edi,%esi
f0102167:	2b 35 1c f4 2b f0    	sub    0xf02bf41c,%esi
f010216d:	c1 fe 03             	sar    $0x3,%esi
f0102170:	c1 e6 0c             	shl    $0xc,%esi
f0102173:	39 f0                	cmp    %esi,%eax
f0102175:	0f 85 fc 08 00 00    	jne    f0102a77 <mem_init+0x125a>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010217b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102180:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102183:	e8 20 ed ff ff       	call   f0100ea8 <check_va2pa>
f0102188:	39 c6                	cmp    %eax,%esi
f010218a:	0f 85 00 09 00 00    	jne    f0102a90 <mem_init+0x1273>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102190:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0102195:	0f 85 0e 09 00 00    	jne    f0102aa9 <mem_init+0x128c>
	assert(pp2->pp_ref == 0);
f010219b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021a0:	0f 85 1c 09 00 00    	jne    f0102ac2 <mem_init+0x12a5>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01021a6:	83 ec 0c             	sub    $0xc,%esp
f01021a9:	6a 00                	push   $0x0
f01021ab:	e8 f0 f1 ff ff       	call   f01013a0 <page_alloc>
f01021b0:	83 c4 10             	add    $0x10,%esp
f01021b3:	85 c0                	test   %eax,%eax
f01021b5:	0f 84 20 09 00 00    	je     f0102adb <mem_init+0x12be>
f01021bb:	39 c3                	cmp    %eax,%ebx
f01021bd:	0f 85 18 09 00 00    	jne    f0102adb <mem_init+0x12be>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01021c3:	83 ec 08             	sub    $0x8,%esp
f01021c6:	6a 00                	push   $0x0
f01021c8:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f01021ce:	e8 f1 f4 ff ff       	call   f01016c4 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01021d3:	8b 35 18 f4 2b f0    	mov    0xf02bf418,%esi
f01021d9:	ba 00 00 00 00       	mov    $0x0,%edx
f01021de:	89 f0                	mov    %esi,%eax
f01021e0:	e8 c3 ec ff ff       	call   f0100ea8 <check_va2pa>
f01021e5:	83 c4 10             	add    $0x10,%esp
f01021e8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021eb:	0f 85 03 09 00 00    	jne    f0102af4 <mem_init+0x12d7>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01021f1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021f6:	89 f0                	mov    %esi,%eax
f01021f8:	e8 ab ec ff ff       	call   f0100ea8 <check_va2pa>
f01021fd:	89 c2                	mov    %eax,%edx
f01021ff:	89 f8                	mov    %edi,%eax
f0102201:	2b 05 1c f4 2b f0    	sub    0xf02bf41c,%eax
f0102207:	c1 f8 03             	sar    $0x3,%eax
f010220a:	c1 e0 0c             	shl    $0xc,%eax
f010220d:	39 c2                	cmp    %eax,%edx
f010220f:	0f 85 f8 08 00 00    	jne    f0102b0d <mem_init+0x12f0>
	assert(pp1->pp_ref == 1);
f0102215:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010221a:	0f 85 06 09 00 00    	jne    f0102b26 <mem_init+0x1309>
	assert(pp2->pp_ref == 0);
f0102220:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102225:	0f 85 14 09 00 00    	jne    f0102b3f <mem_init+0x1322>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010222b:	6a 00                	push   $0x0
f010222d:	68 00 10 00 00       	push   $0x1000
f0102232:	57                   	push   %edi
f0102233:	56                   	push   %esi
f0102234:	e8 d5 f4 ff ff       	call   f010170e <page_insert>
f0102239:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010223c:	83 c4 10             	add    $0x10,%esp
f010223f:	85 c0                	test   %eax,%eax
f0102241:	0f 85 11 09 00 00    	jne    f0102b58 <mem_init+0x133b>
	assert(pp1->pp_ref);
f0102247:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010224c:	0f 84 1f 09 00 00    	je     f0102b71 <mem_init+0x1354>
	assert(pp1->pp_link == NULL);
f0102252:	83 3f 00             	cmpl   $0x0,(%edi)
f0102255:	0f 85 2f 09 00 00    	jne    f0102b8a <mem_init+0x136d>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010225b:	83 ec 08             	sub    $0x8,%esp
f010225e:	68 00 10 00 00       	push   $0x1000
f0102263:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f0102269:	e8 56 f4 ff ff       	call   f01016c4 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010226e:	8b 35 18 f4 2b f0    	mov    0xf02bf418,%esi
f0102274:	ba 00 00 00 00       	mov    $0x0,%edx
f0102279:	89 f0                	mov    %esi,%eax
f010227b:	e8 28 ec ff ff       	call   f0100ea8 <check_va2pa>
f0102280:	83 c4 10             	add    $0x10,%esp
f0102283:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102286:	0f 85 17 09 00 00    	jne    f0102ba3 <mem_init+0x1386>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010228c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102291:	89 f0                	mov    %esi,%eax
f0102293:	e8 10 ec ff ff       	call   f0100ea8 <check_va2pa>
f0102298:	83 f8 ff             	cmp    $0xffffffff,%eax
f010229b:	0f 85 1b 09 00 00    	jne    f0102bbc <mem_init+0x139f>
	assert(pp1->pp_ref == 0);
f01022a1:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01022a6:	0f 85 29 09 00 00    	jne    f0102bd5 <mem_init+0x13b8>
	assert(pp2->pp_ref == 0);
f01022ac:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022b1:	0f 85 37 09 00 00    	jne    f0102bee <mem_init+0x13d1>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01022b7:	83 ec 0c             	sub    $0xc,%esp
f01022ba:	6a 00                	push   $0x0
f01022bc:	e8 df f0 ff ff       	call   f01013a0 <page_alloc>
f01022c1:	83 c4 10             	add    $0x10,%esp
f01022c4:	39 c7                	cmp    %eax,%edi
f01022c6:	0f 85 3b 09 00 00    	jne    f0102c07 <mem_init+0x13ea>
f01022cc:	85 c0                	test   %eax,%eax
f01022ce:	0f 84 33 09 00 00    	je     f0102c07 <mem_init+0x13ea>

	// should be no free memory
	assert(!page_alloc(0));
f01022d4:	83 ec 0c             	sub    $0xc,%esp
f01022d7:	6a 00                	push   $0x0
f01022d9:	e8 c2 f0 ff ff       	call   f01013a0 <page_alloc>
f01022de:	83 c4 10             	add    $0x10,%esp
f01022e1:	85 c0                	test   %eax,%eax
f01022e3:	0f 85 37 09 00 00    	jne    f0102c20 <mem_init+0x1403>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022e9:	8b 0d 18 f4 2b f0    	mov    0xf02bf418,%ecx
f01022ef:	8b 11                	mov    (%ecx),%edx
f01022f1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01022f7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022fa:	2b 05 1c f4 2b f0    	sub    0xf02bf41c,%eax
f0102300:	c1 f8 03             	sar    $0x3,%eax
f0102303:	c1 e0 0c             	shl    $0xc,%eax
f0102306:	39 c2                	cmp    %eax,%edx
f0102308:	0f 85 2b 09 00 00    	jne    f0102c39 <mem_init+0x141c>
	kern_pgdir[0] = 0;
f010230e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102314:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102317:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010231c:	0f 85 30 09 00 00    	jne    f0102c52 <mem_init+0x1435>
	pp0->pp_ref = 0;
f0102322:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102325:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010232b:	83 ec 0c             	sub    $0xc,%esp
f010232e:	50                   	push   %eax
f010232f:	e8 e5 f0 ff ff       	call   f0101419 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102334:	83 c4 0c             	add    $0xc,%esp
f0102337:	6a 01                	push   $0x1
f0102339:	68 00 10 40 00       	push   $0x401000
f010233e:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f0102344:	e8 53 f1 ff ff       	call   f010149c <pgdir_walk>
f0102349:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010234c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010234f:	8b 0d 18 f4 2b f0    	mov    0xf02bf418,%ecx
f0102355:	8b 41 04             	mov    0x4(%ecx),%eax
f0102358:	89 c2                	mov    %eax,%edx
f010235a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0102360:	8b 35 14 f4 2b f0    	mov    0xf02bf414,%esi
f0102366:	c1 e8 0c             	shr    $0xc,%eax
f0102369:	83 c4 10             	add    $0x10,%esp
f010236c:	39 f0                	cmp    %esi,%eax
f010236e:	0f 83 f7 08 00 00    	jae    f0102c6b <mem_init+0x144e>
	assert(ptep == ptep1 + PTX(va));
f0102374:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f010237a:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f010237d:	0f 85 fd 08 00 00    	jne    f0102c80 <mem_init+0x1463>
	kern_pgdir[PDX(va)] = 0;
f0102383:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f010238a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010238d:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0102393:	2b 05 1c f4 2b f0    	sub    0xf02bf41c,%eax
f0102399:	c1 f8 03             	sar    $0x3,%eax
f010239c:	89 c2                	mov    %eax,%edx
f010239e:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01023a1:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01023a6:	39 c6                	cmp    %eax,%esi
f01023a8:	0f 86 eb 08 00 00    	jbe    f0102c99 <mem_init+0x147c>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01023ae:	83 ec 04             	sub    $0x4,%esp
f01023b1:	68 00 10 00 00       	push   $0x1000
f01023b6:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01023bb:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01023c1:	52                   	push   %edx
f01023c2:	e8 a6 3a 00 00       	call   f0105e6d <memset>
	page_free(pp0);
f01023c7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01023ca:	89 34 24             	mov    %esi,(%esp)
f01023cd:	e8 47 f0 ff ff       	call   f0101419 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01023d2:	83 c4 0c             	add    $0xc,%esp
f01023d5:	6a 01                	push   $0x1
f01023d7:	6a 00                	push   $0x0
f01023d9:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f01023df:	e8 b8 f0 ff ff       	call   f010149c <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f01023e4:	89 f0                	mov    %esi,%eax
f01023e6:	2b 05 1c f4 2b f0    	sub    0xf02bf41c,%eax
f01023ec:	c1 f8 03             	sar    $0x3,%eax
f01023ef:	89 c2                	mov    %eax,%edx
f01023f1:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01023f4:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01023f9:	83 c4 10             	add    $0x10,%esp
f01023fc:	3b 05 14 f4 2b f0    	cmp    0xf02bf414,%eax
f0102402:	0f 83 a3 08 00 00    	jae    f0102cab <mem_init+0x148e>
	return (void *)(pa + KERNBASE);
f0102408:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010240e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102411:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102417:	f6 00 01             	testb  $0x1,(%eax)
f010241a:	0f 85 9d 08 00 00    	jne    f0102cbd <mem_init+0x14a0>
f0102420:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0102423:	39 d0                	cmp    %edx,%eax
f0102425:	75 f0                	jne    f0102417 <mem_init+0xbfa>
	kern_pgdir[0] = 0;
f0102427:	a1 18 f4 2b f0       	mov    0xf02bf418,%eax
f010242c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102432:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102435:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f010243b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010243e:	89 0d 44 d2 2b f0    	mov    %ecx,0xf02bd244

	// free the pages we took
	page_free(pp0);
f0102444:	83 ec 0c             	sub    $0xc,%esp
f0102447:	50                   	push   %eax
f0102448:	e8 cc ef ff ff       	call   f0101419 <page_free>
	page_free(pp1);
f010244d:	89 3c 24             	mov    %edi,(%esp)
f0102450:	e8 c4 ef ff ff       	call   f0101419 <page_free>
	page_free(pp2);
f0102455:	89 1c 24             	mov    %ebx,(%esp)
f0102458:	e8 bc ef ff ff       	call   f0101419 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010245d:	83 c4 08             	add    $0x8,%esp
f0102460:	68 01 10 00 00       	push   $0x1001
f0102465:	6a 00                	push   $0x0
f0102467:	e8 4a f3 ff ff       	call   f01017b6 <mmio_map_region>
f010246c:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f010246e:	83 c4 08             	add    $0x8,%esp
f0102471:	68 00 10 00 00       	push   $0x1000
f0102476:	6a 00                	push   $0x0
f0102478:	e8 39 f3 ff ff       	call   f01017b6 <mmio_map_region>
f010247d:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f010247f:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0102485:	83 c4 10             	add    $0x10,%esp
f0102488:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010248e:	0f 86 42 08 00 00    	jbe    f0102cd6 <mem_init+0x14b9>
f0102494:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102499:	0f 87 37 08 00 00    	ja     f0102cd6 <mem_init+0x14b9>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f010249f:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f01024a5:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01024ab:	0f 87 3e 08 00 00    	ja     f0102cef <mem_init+0x14d2>
f01024b1:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01024b7:	0f 86 32 08 00 00    	jbe    f0102cef <mem_init+0x14d2>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01024bd:	89 da                	mov    %ebx,%edx
f01024bf:	09 f2                	or     %esi,%edx
f01024c1:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01024c7:	0f 85 3b 08 00 00    	jne    f0102d08 <mem_init+0x14eb>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f01024cd:	39 c6                	cmp    %eax,%esi
f01024cf:	0f 82 4c 08 00 00    	jb     f0102d21 <mem_init+0x1504>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01024d5:	8b 3d 18 f4 2b f0    	mov    0xf02bf418,%edi
f01024db:	89 da                	mov    %ebx,%edx
f01024dd:	89 f8                	mov    %edi,%eax
f01024df:	e8 c4 e9 ff ff       	call   f0100ea8 <check_va2pa>
f01024e4:	85 c0                	test   %eax,%eax
f01024e6:	0f 85 4e 08 00 00    	jne    f0102d3a <mem_init+0x151d>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01024ec:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01024f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01024f5:	89 c2                	mov    %eax,%edx
f01024f7:	89 f8                	mov    %edi,%eax
f01024f9:	e8 aa e9 ff ff       	call   f0100ea8 <check_va2pa>
f01024fe:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102503:	0f 85 4a 08 00 00    	jne    f0102d53 <mem_init+0x1536>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102509:	89 f2                	mov    %esi,%edx
f010250b:	89 f8                	mov    %edi,%eax
f010250d:	e8 96 e9 ff ff       	call   f0100ea8 <check_va2pa>
f0102512:	85 c0                	test   %eax,%eax
f0102514:	0f 85 52 08 00 00    	jne    f0102d6c <mem_init+0x154f>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010251a:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102520:	89 f8                	mov    %edi,%eax
f0102522:	e8 81 e9 ff ff       	call   f0100ea8 <check_va2pa>
f0102527:	83 f8 ff             	cmp    $0xffffffff,%eax
f010252a:	0f 85 55 08 00 00    	jne    f0102d85 <mem_init+0x1568>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102530:	83 ec 04             	sub    $0x4,%esp
f0102533:	6a 00                	push   $0x0
f0102535:	53                   	push   %ebx
f0102536:	57                   	push   %edi
f0102537:	e8 60 ef ff ff       	call   f010149c <pgdir_walk>
f010253c:	83 c4 10             	add    $0x10,%esp
f010253f:	f6 00 1a             	testb  $0x1a,(%eax)
f0102542:	0f 84 56 08 00 00    	je     f0102d9e <mem_init+0x1581>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102548:	83 ec 04             	sub    $0x4,%esp
f010254b:	6a 00                	push   $0x0
f010254d:	53                   	push   %ebx
f010254e:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f0102554:	e8 43 ef ff ff       	call   f010149c <pgdir_walk>
f0102559:	8b 00                	mov    (%eax),%eax
f010255b:	83 c4 10             	add    $0x10,%esp
f010255e:	83 e0 04             	and    $0x4,%eax
f0102561:	89 c7                	mov    %eax,%edi
f0102563:	0f 85 4e 08 00 00    	jne    f0102db7 <mem_init+0x159a>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102569:	83 ec 04             	sub    $0x4,%esp
f010256c:	6a 00                	push   $0x0
f010256e:	53                   	push   %ebx
f010256f:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f0102575:	e8 22 ef ff ff       	call   f010149c <pgdir_walk>
f010257a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102580:	83 c4 0c             	add    $0xc,%esp
f0102583:	6a 00                	push   $0x0
f0102585:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102588:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f010258e:	e8 09 ef ff ff       	call   f010149c <pgdir_walk>
f0102593:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102599:	83 c4 0c             	add    $0xc,%esp
f010259c:	6a 00                	push   $0x0
f010259e:	56                   	push   %esi
f010259f:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f01025a5:	e8 f2 ee ff ff       	call   f010149c <pgdir_walk>
f01025aa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f01025b0:	c7 04 24 f1 89 10 f0 	movl   $0xf01089f1,(%esp)
f01025b7:	e8 74 18 00 00       	call   f0103e30 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages),PTE_U|PTE_P);
f01025bc:	a1 1c f4 2b f0       	mov    0xf02bf41c,%eax
	if ((uint32_t)kva < KERNBASE)
f01025c1:	83 c4 10             	add    $0x10,%esp
f01025c4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025c9:	0f 86 01 08 00 00    	jbe    f0102dd0 <mem_init+0x15b3>
f01025cf:	83 ec 08             	sub    $0x8,%esp
f01025d2:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01025d4:	05 00 00 00 10       	add    $0x10000000,%eax
f01025d9:	50                   	push   %eax
f01025da:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01025df:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01025e4:	a1 18 f4 2b f0       	mov    0xf02bf418,%eax
f01025e9:	e8 af ef ff ff       	call   f010159d <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, ROUNDUP(sizeof(struct Env) * NENV, PGSIZE), PADDR(envs), PTE_U|PTE_P);
f01025ee:	a1 4c d2 2b f0       	mov    0xf02bd24c,%eax
	if ((uint32_t)kva < KERNBASE)
f01025f3:	83 c4 10             	add    $0x10,%esp
f01025f6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025fb:	0f 86 e4 07 00 00    	jbe    f0102de5 <mem_init+0x15c8>
f0102601:	83 ec 08             	sub    $0x8,%esp
f0102604:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102606:	05 00 00 00 10       	add    $0x10000000,%eax
f010260b:	50                   	push   %eax
f010260c:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102611:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102616:	a1 18 f4 2b f0       	mov    0xf02bf418,%eax
f010261b:	e8 7d ef ff ff       	call   f010159d <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102620:	83 c4 10             	add    $0x10,%esp
f0102623:	b8 00 d0 11 f0       	mov    $0xf011d000,%eax
f0102628:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010262d:	0f 86 c7 07 00 00    	jbe    f0102dfa <mem_init+0x15dd>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W|PTE_P);
f0102633:	83 ec 08             	sub    $0x8,%esp
f0102636:	6a 03                	push   $0x3
f0102638:	68 00 d0 11 00       	push   $0x11d000
f010263d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102642:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102647:	a1 18 f4 2b f0       	mov    0xf02bf418,%eax
f010264c:	e8 4c ef ff ff       	call   f010159d <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, ~KERNBASE, 0, PTE_P|PTE_W);
f0102651:	83 c4 08             	add    $0x8,%esp
f0102654:	6a 03                	push   $0x3
f0102656:	6a 00                	push   $0x0
f0102658:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f010265d:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102662:	a1 18 f4 2b f0       	mov    0xf02bf418,%eax
f0102667:	e8 31 ef ff ff       	call   f010159d <boot_map_region>
f010266c:	c7 45 d0 00 10 2c f0 	movl   $0xf02c1000,-0x30(%ebp)
f0102673:	83 c4 10             	add    $0x10,%esp
f0102676:	bb 00 10 2c f0       	mov    $0xf02c1000,%ebx
f010267b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010267e:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0102681:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102687:	0f 86 82 07 00 00    	jbe    f0102e0f <mem_init+0x15f2>
f010268d:	8d b3 00 00 00 10    	lea    0x10000000(%ebx),%esi
		boot_map_region(kern_pgdir, 
f0102693:	89 fa                	mov    %edi,%edx
f0102695:	f7 da                	neg    %edx
f0102697:	c1 e2 10             	shl    $0x10,%edx
f010269a:	81 ea 00 80 00 10    	sub    $0x10008000,%edx
f01026a0:	83 ec 08             	sub    $0x8,%esp
f01026a3:	6a 03                	push   $0x3
f01026a5:	56                   	push   %esi
f01026a6:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01026ab:	a1 18 f4 2b f0       	mov    0xf02bf418,%eax
f01026b0:	e8 e8 ee ff ff       	call   f010159d <boot_map_region>
		cprintf("cpu%d's stack at pa = %08x\n", i, PADDR(percpu_kstacks[i]));
f01026b5:	83 c4 0c             	add    $0xc,%esp
f01026b8:	56                   	push   %esi
f01026b9:	57                   	push   %edi
f01026ba:	68 0a 8a 10 f0       	push   $0xf0108a0a
f01026bf:	e8 6c 17 00 00       	call   f0103e30 <cprintf>
	for (int i=0; i<NCPU; i++){
f01026c4:	83 c7 01             	add    $0x1,%edi
f01026c7:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01026cd:	83 c4 10             	add    $0x10,%esp
f01026d0:	83 ff 08             	cmp    $0x8,%edi
f01026d3:	75 ac                	jne    f0102681 <mem_init+0xe64>
f01026d5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
	pgdir = kern_pgdir;
f01026d8:	a1 18 f4 2b f0       	mov    0xf02bf418,%eax
f01026dd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01026e0:	a1 14 f4 2b f0       	mov    0xf02bf414,%eax
f01026e5:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01026e8:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01026ef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01026f4:	89 45 cc             	mov    %eax,-0x34(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026f7:	8b 35 1c f4 2b f0    	mov    0xf02bf41c,%esi
f01026fd:	89 75 c8             	mov    %esi,-0x38(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102700:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0102706:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0102709:	89 fb                	mov    %edi,%ebx
f010270b:	e9 2f 07 00 00       	jmp    f0102e3f <mem_init+0x1622>
	assert(nfree == 0);
f0102710:	68 08 89 10 f0       	push   $0xf0108908
f0102715:	68 33 87 10 f0       	push   $0xf0108733
f010271a:	68 df 03 00 00       	push   $0x3df
f010271f:	68 0d 87 10 f0       	push   $0xf010870d
f0102724:	e8 17 d9 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102729:	68 16 88 10 f0       	push   $0xf0108816
f010272e:	68 33 87 10 f0       	push   $0xf0108733
f0102733:	68 45 04 00 00       	push   $0x445
f0102738:	68 0d 87 10 f0       	push   $0xf010870d
f010273d:	e8 fe d8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102742:	68 2c 88 10 f0       	push   $0xf010882c
f0102747:	68 33 87 10 f0       	push   $0xf0108733
f010274c:	68 46 04 00 00       	push   $0x446
f0102751:	68 0d 87 10 f0       	push   $0xf010870d
f0102756:	e8 e5 d8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010275b:	68 42 88 10 f0       	push   $0xf0108842
f0102760:	68 33 87 10 f0       	push   $0xf0108733
f0102765:	68 47 04 00 00       	push   $0x447
f010276a:	68 0d 87 10 f0       	push   $0xf010870d
f010276f:	e8 cc d8 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0102774:	68 58 88 10 f0       	push   $0xf0108858
f0102779:	68 33 87 10 f0       	push   $0xf0108733
f010277e:	68 4a 04 00 00       	push   $0x44a
f0102783:	68 0d 87 10 f0       	push   $0xf010870d
f0102788:	e8 b3 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010278d:	68 30 7f 10 f0       	push   $0xf0107f30
f0102792:	68 33 87 10 f0       	push   $0xf0108733
f0102797:	68 4b 04 00 00       	push   $0x44b
f010279c:	68 0d 87 10 f0       	push   $0xf010870d
f01027a1:	e8 9a d8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01027a6:	68 c1 88 10 f0       	push   $0xf01088c1
f01027ab:	68 33 87 10 f0       	push   $0xf0108733
f01027b0:	68 52 04 00 00       	push   $0x452
f01027b5:	68 0d 87 10 f0       	push   $0xf010870d
f01027ba:	e8 81 d8 ff ff       	call   f0100040 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01027bf:	68 70 7f 10 f0       	push   $0xf0107f70
f01027c4:	68 33 87 10 f0       	push   $0xf0108733
f01027c9:	68 55 04 00 00       	push   $0x455
f01027ce:	68 0d 87 10 f0       	push   $0xf010870d
f01027d3:	e8 68 d8 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01027d8:	68 a8 7f 10 f0       	push   $0xf0107fa8
f01027dd:	68 33 87 10 f0       	push   $0xf0108733
f01027e2:	68 58 04 00 00       	push   $0x458
f01027e7:	68 0d 87 10 f0       	push   $0xf010870d
f01027ec:	e8 4f d8 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01027f1:	68 d8 7f 10 f0       	push   $0xf0107fd8
f01027f6:	68 33 87 10 f0       	push   $0xf0108733
f01027fb:	68 5c 04 00 00       	push   $0x45c
f0102800:	68 0d 87 10 f0       	push   $0xf010870d
f0102805:	e8 36 d8 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010280a:	68 08 80 10 f0       	push   $0xf0108008
f010280f:	68 33 87 10 f0       	push   $0xf0108733
f0102814:	68 5d 04 00 00       	push   $0x45d
f0102819:	68 0d 87 10 f0       	push   $0xf010870d
f010281e:	e8 1d d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102823:	68 30 80 10 f0       	push   $0xf0108030
f0102828:	68 33 87 10 f0       	push   $0xf0108733
f010282d:	68 5e 04 00 00       	push   $0x45e
f0102832:	68 0d 87 10 f0       	push   $0xf010870d
f0102837:	e8 04 d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010283c:	68 13 89 10 f0       	push   $0xf0108913
f0102841:	68 33 87 10 f0       	push   $0xf0108733
f0102846:	68 5f 04 00 00       	push   $0x45f
f010284b:	68 0d 87 10 f0       	push   $0xf010870d
f0102850:	e8 eb d7 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102855:	68 24 89 10 f0       	push   $0xf0108924
f010285a:	68 33 87 10 f0       	push   $0xf0108733
f010285f:	68 60 04 00 00       	push   $0x460
f0102864:	68 0d 87 10 f0       	push   $0xf010870d
f0102869:	e8 d2 d7 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010286e:	68 60 80 10 f0       	push   $0xf0108060
f0102873:	68 33 87 10 f0       	push   $0xf0108733
f0102878:	68 63 04 00 00       	push   $0x463
f010287d:	68 0d 87 10 f0       	push   $0xf010870d
f0102882:	e8 b9 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102887:	68 9c 80 10 f0       	push   $0xf010809c
f010288c:	68 33 87 10 f0       	push   $0xf0108733
f0102891:	68 64 04 00 00       	push   $0x464
f0102896:	68 0d 87 10 f0       	push   $0xf010870d
f010289b:	e8 a0 d7 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01028a0:	68 35 89 10 f0       	push   $0xf0108935
f01028a5:	68 33 87 10 f0       	push   $0xf0108733
f01028aa:	68 65 04 00 00       	push   $0x465
f01028af:	68 0d 87 10 f0       	push   $0xf010870d
f01028b4:	e8 87 d7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01028b9:	68 c1 88 10 f0       	push   $0xf01088c1
f01028be:	68 33 87 10 f0       	push   $0xf0108733
f01028c3:	68 68 04 00 00       	push   $0x468
f01028c8:	68 0d 87 10 f0       	push   $0xf010870d
f01028cd:	e8 6e d7 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01028d2:	68 60 80 10 f0       	push   $0xf0108060
f01028d7:	68 33 87 10 f0       	push   $0xf0108733
f01028dc:	68 6b 04 00 00       	push   $0x46b
f01028e1:	68 0d 87 10 f0       	push   $0xf010870d
f01028e6:	e8 55 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01028eb:	68 9c 80 10 f0       	push   $0xf010809c
f01028f0:	68 33 87 10 f0       	push   $0xf0108733
f01028f5:	68 6c 04 00 00       	push   $0x46c
f01028fa:	68 0d 87 10 f0       	push   $0xf010870d
f01028ff:	e8 3c d7 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102904:	68 35 89 10 f0       	push   $0xf0108935
f0102909:	68 33 87 10 f0       	push   $0xf0108733
f010290e:	68 6d 04 00 00       	push   $0x46d
f0102913:	68 0d 87 10 f0       	push   $0xf010870d
f0102918:	e8 23 d7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010291d:	68 c1 88 10 f0       	push   $0xf01088c1
f0102922:	68 33 87 10 f0       	push   $0xf0108733
f0102927:	68 71 04 00 00       	push   $0x471
f010292c:	68 0d 87 10 f0       	push   $0xf010870d
f0102931:	e8 0a d7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102936:	52                   	push   %edx
f0102937:	68 44 74 10 f0       	push   $0xf0107444
f010293c:	68 74 04 00 00       	push   $0x474
f0102941:	68 0d 87 10 f0       	push   $0xf010870d
f0102946:	e8 f5 d6 ff ff       	call   f0100040 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010294b:	68 cc 80 10 f0       	push   $0xf01080cc
f0102950:	68 33 87 10 f0       	push   $0xf0108733
f0102955:	68 75 04 00 00       	push   $0x475
f010295a:	68 0d 87 10 f0       	push   $0xf010870d
f010295f:	e8 dc d6 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102964:	68 0c 81 10 f0       	push   $0xf010810c
f0102969:	68 33 87 10 f0       	push   $0xf0108733
f010296e:	68 78 04 00 00       	push   $0x478
f0102973:	68 0d 87 10 f0       	push   $0xf010870d
f0102978:	e8 c3 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010297d:	68 9c 80 10 f0       	push   $0xf010809c
f0102982:	68 33 87 10 f0       	push   $0xf0108733
f0102987:	68 79 04 00 00       	push   $0x479
f010298c:	68 0d 87 10 f0       	push   $0xf010870d
f0102991:	e8 aa d6 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102996:	68 35 89 10 f0       	push   $0xf0108935
f010299b:	68 33 87 10 f0       	push   $0xf0108733
f01029a0:	68 7a 04 00 00       	push   $0x47a
f01029a5:	68 0d 87 10 f0       	push   $0xf010870d
f01029aa:	e8 91 d6 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01029af:	68 4c 81 10 f0       	push   $0xf010814c
f01029b4:	68 33 87 10 f0       	push   $0xf0108733
f01029b9:	68 7b 04 00 00       	push   $0x47b
f01029be:	68 0d 87 10 f0       	push   $0xf010870d
f01029c3:	e8 78 d6 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01029c8:	68 46 89 10 f0       	push   $0xf0108946
f01029cd:	68 33 87 10 f0       	push   $0xf0108733
f01029d2:	68 7c 04 00 00       	push   $0x47c
f01029d7:	68 0d 87 10 f0       	push   $0xf010870d
f01029dc:	e8 5f d6 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01029e1:	68 60 80 10 f0       	push   $0xf0108060
f01029e6:	68 33 87 10 f0       	push   $0xf0108733
f01029eb:	68 7f 04 00 00       	push   $0x47f
f01029f0:	68 0d 87 10 f0       	push   $0xf010870d
f01029f5:	e8 46 d6 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01029fa:	68 80 81 10 f0       	push   $0xf0108180
f01029ff:	68 33 87 10 f0       	push   $0xf0108733
f0102a04:	68 80 04 00 00       	push   $0x480
f0102a09:	68 0d 87 10 f0       	push   $0xf010870d
f0102a0e:	e8 2d d6 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102a13:	68 b4 81 10 f0       	push   $0xf01081b4
f0102a18:	68 33 87 10 f0       	push   $0xf0108733
f0102a1d:	68 81 04 00 00       	push   $0x481
f0102a22:	68 0d 87 10 f0       	push   $0xf010870d
f0102a27:	e8 14 d6 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102a2c:	68 ec 81 10 f0       	push   $0xf01081ec
f0102a31:	68 33 87 10 f0       	push   $0xf0108733
f0102a36:	68 84 04 00 00       	push   $0x484
f0102a3b:	68 0d 87 10 f0       	push   $0xf010870d
f0102a40:	e8 fb d5 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102a45:	68 24 82 10 f0       	push   $0xf0108224
f0102a4a:	68 33 87 10 f0       	push   $0xf0108733
f0102a4f:	68 87 04 00 00       	push   $0x487
f0102a54:	68 0d 87 10 f0       	push   $0xf010870d
f0102a59:	e8 e2 d5 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102a5e:	68 b4 81 10 f0       	push   $0xf01081b4
f0102a63:	68 33 87 10 f0       	push   $0xf0108733
f0102a68:	68 88 04 00 00       	push   $0x488
f0102a6d:	68 0d 87 10 f0       	push   $0xf010870d
f0102a72:	e8 c9 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102a77:	68 60 82 10 f0       	push   $0xf0108260
f0102a7c:	68 33 87 10 f0       	push   $0xf0108733
f0102a81:	68 8b 04 00 00       	push   $0x48b
f0102a86:	68 0d 87 10 f0       	push   $0xf010870d
f0102a8b:	e8 b0 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102a90:	68 8c 82 10 f0       	push   $0xf010828c
f0102a95:	68 33 87 10 f0       	push   $0xf0108733
f0102a9a:	68 8c 04 00 00       	push   $0x48c
f0102a9f:	68 0d 87 10 f0       	push   $0xf010870d
f0102aa4:	e8 97 d5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 2);
f0102aa9:	68 5c 89 10 f0       	push   $0xf010895c
f0102aae:	68 33 87 10 f0       	push   $0xf0108733
f0102ab3:	68 8e 04 00 00       	push   $0x48e
f0102ab8:	68 0d 87 10 f0       	push   $0xf010870d
f0102abd:	e8 7e d5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102ac2:	68 6d 89 10 f0       	push   $0xf010896d
f0102ac7:	68 33 87 10 f0       	push   $0xf0108733
f0102acc:	68 8f 04 00 00       	push   $0x48f
f0102ad1:	68 0d 87 10 f0       	push   $0xf010870d
f0102ad6:	e8 65 d5 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102adb:	68 bc 82 10 f0       	push   $0xf01082bc
f0102ae0:	68 33 87 10 f0       	push   $0xf0108733
f0102ae5:	68 92 04 00 00       	push   $0x492
f0102aea:	68 0d 87 10 f0       	push   $0xf010870d
f0102aef:	e8 4c d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102af4:	68 e0 82 10 f0       	push   $0xf01082e0
f0102af9:	68 33 87 10 f0       	push   $0xf0108733
f0102afe:	68 96 04 00 00       	push   $0x496
f0102b03:	68 0d 87 10 f0       	push   $0xf010870d
f0102b08:	e8 33 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102b0d:	68 8c 82 10 f0       	push   $0xf010828c
f0102b12:	68 33 87 10 f0       	push   $0xf0108733
f0102b17:	68 97 04 00 00       	push   $0x497
f0102b1c:	68 0d 87 10 f0       	push   $0xf010870d
f0102b21:	e8 1a d5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102b26:	68 13 89 10 f0       	push   $0xf0108913
f0102b2b:	68 33 87 10 f0       	push   $0xf0108733
f0102b30:	68 98 04 00 00       	push   $0x498
f0102b35:	68 0d 87 10 f0       	push   $0xf010870d
f0102b3a:	e8 01 d5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102b3f:	68 6d 89 10 f0       	push   $0xf010896d
f0102b44:	68 33 87 10 f0       	push   $0xf0108733
f0102b49:	68 99 04 00 00       	push   $0x499
f0102b4e:	68 0d 87 10 f0       	push   $0xf010870d
f0102b53:	e8 e8 d4 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102b58:	68 04 83 10 f0       	push   $0xf0108304
f0102b5d:	68 33 87 10 f0       	push   $0xf0108733
f0102b62:	68 9c 04 00 00       	push   $0x49c
f0102b67:	68 0d 87 10 f0       	push   $0xf010870d
f0102b6c:	e8 cf d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102b71:	68 7e 89 10 f0       	push   $0xf010897e
f0102b76:	68 33 87 10 f0       	push   $0xf0108733
f0102b7b:	68 9d 04 00 00       	push   $0x49d
f0102b80:	68 0d 87 10 f0       	push   $0xf010870d
f0102b85:	e8 b6 d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102b8a:	68 8a 89 10 f0       	push   $0xf010898a
f0102b8f:	68 33 87 10 f0       	push   $0xf0108733
f0102b94:	68 9e 04 00 00       	push   $0x49e
f0102b99:	68 0d 87 10 f0       	push   $0xf010870d
f0102b9e:	e8 9d d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102ba3:	68 e0 82 10 f0       	push   $0xf01082e0
f0102ba8:	68 33 87 10 f0       	push   $0xf0108733
f0102bad:	68 a2 04 00 00       	push   $0x4a2
f0102bb2:	68 0d 87 10 f0       	push   $0xf010870d
f0102bb7:	e8 84 d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102bbc:	68 3c 83 10 f0       	push   $0xf010833c
f0102bc1:	68 33 87 10 f0       	push   $0xf0108733
f0102bc6:	68 a3 04 00 00       	push   $0x4a3
f0102bcb:	68 0d 87 10 f0       	push   $0xf010870d
f0102bd0:	e8 6b d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102bd5:	68 9f 89 10 f0       	push   $0xf010899f
f0102bda:	68 33 87 10 f0       	push   $0xf0108733
f0102bdf:	68 a4 04 00 00       	push   $0x4a4
f0102be4:	68 0d 87 10 f0       	push   $0xf010870d
f0102be9:	e8 52 d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102bee:	68 6d 89 10 f0       	push   $0xf010896d
f0102bf3:	68 33 87 10 f0       	push   $0xf0108733
f0102bf8:	68 a5 04 00 00       	push   $0x4a5
f0102bfd:	68 0d 87 10 f0       	push   $0xf010870d
f0102c02:	e8 39 d4 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102c07:	68 64 83 10 f0       	push   $0xf0108364
f0102c0c:	68 33 87 10 f0       	push   $0xf0108733
f0102c11:	68 a8 04 00 00       	push   $0x4a8
f0102c16:	68 0d 87 10 f0       	push   $0xf010870d
f0102c1b:	e8 20 d4 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102c20:	68 c1 88 10 f0       	push   $0xf01088c1
f0102c25:	68 33 87 10 f0       	push   $0xf0108733
f0102c2a:	68 ab 04 00 00       	push   $0x4ab
f0102c2f:	68 0d 87 10 f0       	push   $0xf010870d
f0102c34:	e8 07 d4 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c39:	68 08 80 10 f0       	push   $0xf0108008
f0102c3e:	68 33 87 10 f0       	push   $0xf0108733
f0102c43:	68 ae 04 00 00       	push   $0x4ae
f0102c48:	68 0d 87 10 f0       	push   $0xf010870d
f0102c4d:	e8 ee d3 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102c52:	68 24 89 10 f0       	push   $0xf0108924
f0102c57:	68 33 87 10 f0       	push   $0xf0108733
f0102c5c:	68 b0 04 00 00       	push   $0x4b0
f0102c61:	68 0d 87 10 f0       	push   $0xf010870d
f0102c66:	e8 d5 d3 ff ff       	call   f0100040 <_panic>
f0102c6b:	52                   	push   %edx
f0102c6c:	68 44 74 10 f0       	push   $0xf0107444
f0102c71:	68 b7 04 00 00       	push   $0x4b7
f0102c76:	68 0d 87 10 f0       	push   $0xf010870d
f0102c7b:	e8 c0 d3 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102c80:	68 b0 89 10 f0       	push   $0xf01089b0
f0102c85:	68 33 87 10 f0       	push   $0xf0108733
f0102c8a:	68 b8 04 00 00       	push   $0x4b8
f0102c8f:	68 0d 87 10 f0       	push   $0xf010870d
f0102c94:	e8 a7 d3 ff ff       	call   f0100040 <_panic>
f0102c99:	52                   	push   %edx
f0102c9a:	68 44 74 10 f0       	push   $0xf0107444
f0102c9f:	6a 58                	push   $0x58
f0102ca1:	68 19 87 10 f0       	push   $0xf0108719
f0102ca6:	e8 95 d3 ff ff       	call   f0100040 <_panic>
f0102cab:	52                   	push   %edx
f0102cac:	68 44 74 10 f0       	push   $0xf0107444
f0102cb1:	6a 58                	push   $0x58
f0102cb3:	68 19 87 10 f0       	push   $0xf0108719
f0102cb8:	e8 83 d3 ff ff       	call   f0100040 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102cbd:	68 c8 89 10 f0       	push   $0xf01089c8
f0102cc2:	68 33 87 10 f0       	push   $0xf0108733
f0102cc7:	68 c2 04 00 00       	push   $0x4c2
f0102ccc:	68 0d 87 10 f0       	push   $0xf010870d
f0102cd1:	e8 6a d3 ff ff       	call   f0100040 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102cd6:	68 88 83 10 f0       	push   $0xf0108388
f0102cdb:	68 33 87 10 f0       	push   $0xf0108733
f0102ce0:	68 d2 04 00 00       	push   $0x4d2
f0102ce5:	68 0d 87 10 f0       	push   $0xf010870d
f0102cea:	e8 51 d3 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102cef:	68 b0 83 10 f0       	push   $0xf01083b0
f0102cf4:	68 33 87 10 f0       	push   $0xf0108733
f0102cf9:	68 d3 04 00 00       	push   $0x4d3
f0102cfe:	68 0d 87 10 f0       	push   $0xf010870d
f0102d03:	e8 38 d3 ff ff       	call   f0100040 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102d08:	68 d8 83 10 f0       	push   $0xf01083d8
f0102d0d:	68 33 87 10 f0       	push   $0xf0108733
f0102d12:	68 d5 04 00 00       	push   $0x4d5
f0102d17:	68 0d 87 10 f0       	push   $0xf010870d
f0102d1c:	e8 1f d3 ff ff       	call   f0100040 <_panic>
	assert(mm1 + 8192 <= mm2);
f0102d21:	68 df 89 10 f0       	push   $0xf01089df
f0102d26:	68 33 87 10 f0       	push   $0xf0108733
f0102d2b:	68 d7 04 00 00       	push   $0x4d7
f0102d30:	68 0d 87 10 f0       	push   $0xf010870d
f0102d35:	e8 06 d3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102d3a:	68 00 84 10 f0       	push   $0xf0108400
f0102d3f:	68 33 87 10 f0       	push   $0xf0108733
f0102d44:	68 d9 04 00 00       	push   $0x4d9
f0102d49:	68 0d 87 10 f0       	push   $0xf010870d
f0102d4e:	e8 ed d2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102d53:	68 24 84 10 f0       	push   $0xf0108424
f0102d58:	68 33 87 10 f0       	push   $0xf0108733
f0102d5d:	68 da 04 00 00       	push   $0x4da
f0102d62:	68 0d 87 10 f0       	push   $0xf010870d
f0102d67:	e8 d4 d2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102d6c:	68 54 84 10 f0       	push   $0xf0108454
f0102d71:	68 33 87 10 f0       	push   $0xf0108733
f0102d76:	68 db 04 00 00       	push   $0x4db
f0102d7b:	68 0d 87 10 f0       	push   $0xf010870d
f0102d80:	e8 bb d2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102d85:	68 78 84 10 f0       	push   $0xf0108478
f0102d8a:	68 33 87 10 f0       	push   $0xf0108733
f0102d8f:	68 dc 04 00 00       	push   $0x4dc
f0102d94:	68 0d 87 10 f0       	push   $0xf010870d
f0102d99:	e8 a2 d2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102d9e:	68 a4 84 10 f0       	push   $0xf01084a4
f0102da3:	68 33 87 10 f0       	push   $0xf0108733
f0102da8:	68 de 04 00 00       	push   $0x4de
f0102dad:	68 0d 87 10 f0       	push   $0xf010870d
f0102db2:	e8 89 d2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102db7:	68 e8 84 10 f0       	push   $0xf01084e8
f0102dbc:	68 33 87 10 f0       	push   $0xf0108733
f0102dc1:	68 df 04 00 00       	push   $0x4df
f0102dc6:	68 0d 87 10 f0       	push   $0xf010870d
f0102dcb:	e8 70 d2 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dd0:	50                   	push   %eax
f0102dd1:	68 68 74 10 f0       	push   $0xf0107468
f0102dd6:	68 c7 00 00 00       	push   $0xc7
f0102ddb:	68 0d 87 10 f0       	push   $0xf010870d
f0102de0:	e8 5b d2 ff ff       	call   f0100040 <_panic>
f0102de5:	50                   	push   %eax
f0102de6:	68 68 74 10 f0       	push   $0xf0107468
f0102deb:	68 d1 00 00 00       	push   $0xd1
f0102df0:	68 0d 87 10 f0       	push   $0xf010870d
f0102df5:	e8 46 d2 ff ff       	call   f0100040 <_panic>
f0102dfa:	50                   	push   %eax
f0102dfb:	68 68 74 10 f0       	push   $0xf0107468
f0102e00:	68 df 00 00 00       	push   $0xdf
f0102e05:	68 0d 87 10 f0       	push   $0xf010870d
f0102e0a:	e8 31 d2 ff ff       	call   f0100040 <_panic>
f0102e0f:	53                   	push   %ebx
f0102e10:	68 68 74 10 f0       	push   $0xf0107468
f0102e15:	68 2a 01 00 00       	push   $0x12a
f0102e1a:	68 0d 87 10 f0       	push   $0xf010870d
f0102e1f:	e8 1c d2 ff ff       	call   f0100040 <_panic>
f0102e24:	56                   	push   %esi
f0102e25:	68 68 74 10 f0       	push   $0xf0107468
f0102e2a:	68 f7 03 00 00       	push   $0x3f7
f0102e2f:	68 0d 87 10 f0       	push   $0xf010870d
f0102e34:	e8 07 d2 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f0102e39:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e3f:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f0102e42:	76 3a                	jbe    f0102e7e <mem_init+0x1661>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e44:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102e4a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e4d:	e8 56 e0 ff ff       	call   f0100ea8 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102e52:	81 7d c8 ff ff ff ef 	cmpl   $0xefffffff,-0x38(%ebp)
f0102e59:	76 c9                	jbe    f0102e24 <mem_init+0x1607>
f0102e5b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0102e5e:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102e61:	39 d0                	cmp    %edx,%eax
f0102e63:	74 d4                	je     f0102e39 <mem_init+0x161c>
f0102e65:	68 1c 85 10 f0       	push   $0xf010851c
f0102e6a:	68 33 87 10 f0       	push   $0xf0108733
f0102e6f:	68 f7 03 00 00       	push   $0x3f7
f0102e74:	68 0d 87 10 f0       	push   $0xf010870d
f0102e79:	e8 c2 d1 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e7e:	a1 4c d2 2b f0       	mov    0xf02bd24c,%eax
f0102e83:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102e86:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102e89:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102e8e:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f0102e94:	89 da                	mov    %ebx,%edx
f0102e96:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e99:	e8 0a e0 ff ff       	call   f0100ea8 <check_va2pa>
f0102e9e:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102ea5:	76 3b                	jbe    f0102ee2 <mem_init+0x16c5>
f0102ea7:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102eaa:	39 d0                	cmp    %edx,%eax
f0102eac:	75 4b                	jne    f0102ef9 <mem_init+0x16dc>
f0102eae:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f0102eb4:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102eba:	75 d8                	jne    f0102e94 <mem_init+0x1677>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102ebc:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0102ebf:	c1 e6 0c             	shl    $0xc,%esi
f0102ec2:	89 fb                	mov    %edi,%ebx
f0102ec4:	39 f3                	cmp    %esi,%ebx
f0102ec6:	73 63                	jae    f0102f2b <mem_init+0x170e>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102ec8:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102ece:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ed1:	e8 d2 df ff ff       	call   f0100ea8 <check_va2pa>
f0102ed6:	39 c3                	cmp    %eax,%ebx
f0102ed8:	75 38                	jne    f0102f12 <mem_init+0x16f5>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102eda:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ee0:	eb e2                	jmp    f0102ec4 <mem_init+0x16a7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ee2:	ff 75 c8             	pushl  -0x38(%ebp)
f0102ee5:	68 68 74 10 f0       	push   $0xf0107468
f0102eea:	68 fc 03 00 00       	push   $0x3fc
f0102eef:	68 0d 87 10 f0       	push   $0xf010870d
f0102ef4:	e8 47 d1 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102ef9:	68 50 85 10 f0       	push   $0xf0108550
f0102efe:	68 33 87 10 f0       	push   $0xf0108733
f0102f03:	68 fc 03 00 00       	push   $0x3fc
f0102f08:	68 0d 87 10 f0       	push   $0xf010870d
f0102f0d:	e8 2e d1 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102f12:	68 84 85 10 f0       	push   $0xf0108584
f0102f17:	68 33 87 10 f0       	push   $0xf0108733
f0102f1c:	68 00 04 00 00       	push   $0x400
f0102f21:	68 0d 87 10 f0       	push   $0xf010870d
f0102f26:	e8 15 d1 ff ff       	call   f0100040 <_panic>
f0102f2b:	c7 45 cc 00 10 2d 00 	movl   $0x2d1000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102f32:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
f0102f37:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0102f3a:	8d bb 00 80 ff ff    	lea    -0x8000(%ebx),%edi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102f40:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102f43:	89 45 bc             	mov    %eax,-0x44(%ebp)
f0102f46:	89 de                	mov    %ebx,%esi
f0102f48:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102f4b:	05 00 80 ff 0f       	add    $0xfff8000,%eax
f0102f50:	89 45 c8             	mov    %eax,-0x38(%ebp)
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102f53:	8d 83 00 80 00 00    	lea    0x8000(%ebx),%eax
f0102f59:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102f5c:	89 f2                	mov    %esi,%edx
f0102f5e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f61:	e8 42 df ff ff       	call   f0100ea8 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102f66:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102f6d:	76 58                	jbe    f0102fc7 <mem_init+0x17aa>
f0102f6f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102f72:	8d 14 31             	lea    (%ecx,%esi,1),%edx
f0102f75:	39 d0                	cmp    %edx,%eax
f0102f77:	75 65                	jne    f0102fde <mem_init+0x17c1>
f0102f79:	81 c6 00 10 00 00    	add    $0x1000,%esi
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102f7f:	3b 75 c4             	cmp    -0x3c(%ebp),%esi
f0102f82:	75 d8                	jne    f0102f5c <mem_init+0x173f>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102f84:	89 fa                	mov    %edi,%edx
f0102f86:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f89:	e8 1a df ff ff       	call   f0100ea8 <check_va2pa>
f0102f8e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f91:	75 64                	jne    f0102ff7 <mem_init+0x17da>
f0102f93:	81 c7 00 10 00 00    	add    $0x1000,%edi
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102f99:	39 df                	cmp    %ebx,%edi
f0102f9b:	75 e7                	jne    f0102f84 <mem_init+0x1767>
f0102f9d:	81 eb 00 00 01 00    	sub    $0x10000,%ebx
f0102fa3:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
f0102faa:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102fad:	81 45 cc 00 80 01 00 	addl   $0x18000,-0x34(%ebp)
	for (n = 0; n < NCPU; n++) {
f0102fb4:	3d 00 10 30 f0       	cmp    $0xf0301000,%eax
f0102fb9:	0f 85 7b ff ff ff    	jne    f0102f3a <mem_init+0x171d>
f0102fbf:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0102fc2:	e9 84 00 00 00       	jmp    f010304b <mem_init+0x182e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fc7:	ff 75 bc             	pushl  -0x44(%ebp)
f0102fca:	68 68 74 10 f0       	push   $0xf0107468
f0102fcf:	68 08 04 00 00       	push   $0x408
f0102fd4:	68 0d 87 10 f0       	push   $0xf010870d
f0102fd9:	e8 62 d0 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102fde:	68 ac 85 10 f0       	push   $0xf01085ac
f0102fe3:	68 33 87 10 f0       	push   $0xf0108733
f0102fe8:	68 07 04 00 00       	push   $0x407
f0102fed:	68 0d 87 10 f0       	push   $0xf010870d
f0102ff2:	e8 49 d0 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102ff7:	68 f4 85 10 f0       	push   $0xf01085f4
f0102ffc:	68 33 87 10 f0       	push   $0xf0108733
f0103001:	68 0a 04 00 00       	push   $0x40a
f0103006:	68 0d 87 10 f0       	push   $0xf010870d
f010300b:	e8 30 d0 ff ff       	call   f0100040 <_panic>
			assert(pgdir[i] & PTE_P);
f0103010:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103013:	f6 04 b8 01          	testb  $0x1,(%eax,%edi,4)
f0103017:	75 4e                	jne    f0103067 <mem_init+0x184a>
f0103019:	68 26 8a 10 f0       	push   $0xf0108a26
f010301e:	68 33 87 10 f0       	push   $0xf0108733
f0103023:	68 15 04 00 00       	push   $0x415
f0103028:	68 0d 87 10 f0       	push   $0xf010870d
f010302d:	e8 0e d0 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0103032:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103035:	8b 04 b8             	mov    (%eax,%edi,4),%eax
f0103038:	a8 01                	test   $0x1,%al
f010303a:	74 30                	je     f010306c <mem_init+0x184f>
				assert(pgdir[i] & PTE_W);
f010303c:	a8 02                	test   $0x2,%al
f010303e:	74 45                	je     f0103085 <mem_init+0x1868>
	for (i = 0; i < NPDENTRIES; i++) {
f0103040:	83 c7 01             	add    $0x1,%edi
f0103043:	81 ff 00 04 00 00    	cmp    $0x400,%edi
f0103049:	74 6c                	je     f01030b7 <mem_init+0x189a>
		switch (i) {
f010304b:	8d 87 45 fc ff ff    	lea    -0x3bb(%edi),%eax
f0103051:	83 f8 04             	cmp    $0x4,%eax
f0103054:	76 ba                	jbe    f0103010 <mem_init+0x17f3>
			if (i >= PDX(KERNBASE)) {
f0103056:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f010305c:	77 d4                	ja     f0103032 <mem_init+0x1815>
				assert(pgdir[i] == 0);
f010305e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103061:	83 3c b8 00          	cmpl   $0x0,(%eax,%edi,4)
f0103065:	75 37                	jne    f010309e <mem_init+0x1881>
	for (i = 0; i < NPDENTRIES; i++) {
f0103067:	83 c7 01             	add    $0x1,%edi
f010306a:	eb df                	jmp    f010304b <mem_init+0x182e>
				assert(pgdir[i] & PTE_P);
f010306c:	68 26 8a 10 f0       	push   $0xf0108a26
f0103071:	68 33 87 10 f0       	push   $0xf0108733
f0103076:	68 19 04 00 00       	push   $0x419
f010307b:	68 0d 87 10 f0       	push   $0xf010870d
f0103080:	e8 bb cf ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0103085:	68 37 8a 10 f0       	push   $0xf0108a37
f010308a:	68 33 87 10 f0       	push   $0xf0108733
f010308f:	68 1a 04 00 00       	push   $0x41a
f0103094:	68 0d 87 10 f0       	push   $0xf010870d
f0103099:	e8 a2 cf ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f010309e:	68 48 8a 10 f0       	push   $0xf0108a48
f01030a3:	68 33 87 10 f0       	push   $0xf0108733
f01030a8:	68 1c 04 00 00       	push   $0x41c
f01030ad:	68 0d 87 10 f0       	push   $0xf010870d
f01030b2:	e8 89 cf ff ff       	call   f0100040 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f01030b7:	83 ec 0c             	sub    $0xc,%esp
f01030ba:	68 18 86 10 f0       	push   $0xf0108618
f01030bf:	e8 6c 0d 00 00       	call   f0103e30 <cprintf>
	lcr3(PADDR(kern_pgdir));
f01030c4:	a1 18 f4 2b f0       	mov    0xf02bf418,%eax
	if ((uint32_t)kva < KERNBASE)
f01030c9:	83 c4 10             	add    $0x10,%esp
f01030cc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030d1:	0f 86 03 02 00 00    	jbe    f01032da <mem_init+0x1abd>
	return (physaddr_t)kva - KERNBASE;
f01030d7:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01030dc:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f01030df:	b8 00 00 00 00       	mov    $0x0,%eax
f01030e4:	e8 22 de ff ff       	call   f0100f0b <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01030e9:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);// unset TS and EM
f01030ec:	83 e0 f3             	and    $0xfffffff3,%eax
f01030ef:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01030f4:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01030f7:	83 ec 0c             	sub    $0xc,%esp
f01030fa:	6a 00                	push   $0x0
f01030fc:	e8 9f e2 ff ff       	call   f01013a0 <page_alloc>
f0103101:	89 c6                	mov    %eax,%esi
f0103103:	83 c4 10             	add    $0x10,%esp
f0103106:	85 c0                	test   %eax,%eax
f0103108:	0f 84 e1 01 00 00    	je     f01032ef <mem_init+0x1ad2>
	assert((pp1 = page_alloc(0)));
f010310e:	83 ec 0c             	sub    $0xc,%esp
f0103111:	6a 00                	push   $0x0
f0103113:	e8 88 e2 ff ff       	call   f01013a0 <page_alloc>
f0103118:	89 c7                	mov    %eax,%edi
f010311a:	83 c4 10             	add    $0x10,%esp
f010311d:	85 c0                	test   %eax,%eax
f010311f:	0f 84 e3 01 00 00    	je     f0103308 <mem_init+0x1aeb>
	assert((pp2 = page_alloc(0)));
f0103125:	83 ec 0c             	sub    $0xc,%esp
f0103128:	6a 00                	push   $0x0
f010312a:	e8 71 e2 ff ff       	call   f01013a0 <page_alloc>
f010312f:	89 c3                	mov    %eax,%ebx
f0103131:	83 c4 10             	add    $0x10,%esp
f0103134:	85 c0                	test   %eax,%eax
f0103136:	0f 84 e5 01 00 00    	je     f0103321 <mem_init+0x1b04>
	page_free(pp0);
f010313c:	83 ec 0c             	sub    $0xc,%esp
f010313f:	56                   	push   %esi
f0103140:	e8 d4 e2 ff ff       	call   f0101419 <page_free>
	return (pp - pages) << PGSHIFT;
f0103145:	89 f8                	mov    %edi,%eax
f0103147:	2b 05 1c f4 2b f0    	sub    0xf02bf41c,%eax
f010314d:	c1 f8 03             	sar    $0x3,%eax
f0103150:	89 c2                	mov    %eax,%edx
f0103152:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0103155:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010315a:	83 c4 10             	add    $0x10,%esp
f010315d:	3b 05 14 f4 2b f0    	cmp    0xf02bf414,%eax
f0103163:	0f 83 d1 01 00 00    	jae    f010333a <mem_init+0x1b1d>
	memset(page2kva(pp1), 1, PGSIZE);
f0103169:	83 ec 04             	sub    $0x4,%esp
f010316c:	68 00 10 00 00       	push   $0x1000
f0103171:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0103173:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103179:	52                   	push   %edx
f010317a:	e8 ee 2c 00 00       	call   f0105e6d <memset>
	return (pp - pages) << PGSHIFT;
f010317f:	89 d8                	mov    %ebx,%eax
f0103181:	2b 05 1c f4 2b f0    	sub    0xf02bf41c,%eax
f0103187:	c1 f8 03             	sar    $0x3,%eax
f010318a:	89 c2                	mov    %eax,%edx
f010318c:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010318f:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0103194:	83 c4 10             	add    $0x10,%esp
f0103197:	3b 05 14 f4 2b f0    	cmp    0xf02bf414,%eax
f010319d:	0f 83 a9 01 00 00    	jae    f010334c <mem_init+0x1b2f>
	memset(page2kva(pp2), 2, PGSIZE);
f01031a3:	83 ec 04             	sub    $0x4,%esp
f01031a6:	68 00 10 00 00       	push   $0x1000
f01031ab:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f01031ad:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01031b3:	52                   	push   %edx
f01031b4:	e8 b4 2c 00 00       	call   f0105e6d <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01031b9:	6a 02                	push   $0x2
f01031bb:	68 00 10 00 00       	push   $0x1000
f01031c0:	57                   	push   %edi
f01031c1:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f01031c7:	e8 42 e5 ff ff       	call   f010170e <page_insert>
	assert(pp1->pp_ref == 1);
f01031cc:	83 c4 20             	add    $0x20,%esp
f01031cf:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01031d4:	0f 85 84 01 00 00    	jne    f010335e <mem_init+0x1b41>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01031da:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01031e1:	01 01 01 
f01031e4:	0f 85 8d 01 00 00    	jne    f0103377 <mem_init+0x1b5a>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01031ea:	6a 02                	push   $0x2
f01031ec:	68 00 10 00 00       	push   $0x1000
f01031f1:	53                   	push   %ebx
f01031f2:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f01031f8:	e8 11 e5 ff ff       	call   f010170e <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01031fd:	83 c4 10             	add    $0x10,%esp
f0103200:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103207:	02 02 02 
f010320a:	0f 85 80 01 00 00    	jne    f0103390 <mem_init+0x1b73>
	assert(pp2->pp_ref == 1);
f0103210:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103215:	0f 85 8e 01 00 00    	jne    f01033a9 <mem_init+0x1b8c>
	assert(pp1->pp_ref == 0);
f010321b:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103220:	0f 85 9c 01 00 00    	jne    f01033c2 <mem_init+0x1ba5>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103226:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010322d:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0103230:	89 d8                	mov    %ebx,%eax
f0103232:	2b 05 1c f4 2b f0    	sub    0xf02bf41c,%eax
f0103238:	c1 f8 03             	sar    $0x3,%eax
f010323b:	89 c2                	mov    %eax,%edx
f010323d:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0103240:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0103245:	3b 05 14 f4 2b f0    	cmp    0xf02bf414,%eax
f010324b:	0f 83 8a 01 00 00    	jae    f01033db <mem_init+0x1bbe>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103251:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0103258:	03 03 03 
f010325b:	0f 85 8c 01 00 00    	jne    f01033ed <mem_init+0x1bd0>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103261:	83 ec 08             	sub    $0x8,%esp
f0103264:	68 00 10 00 00       	push   $0x1000
f0103269:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f010326f:	e8 50 e4 ff ff       	call   f01016c4 <page_remove>
	assert(pp2->pp_ref == 0);
f0103274:	83 c4 10             	add    $0x10,%esp
f0103277:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010327c:	0f 85 84 01 00 00    	jne    f0103406 <mem_init+0x1be9>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103282:	8b 0d 18 f4 2b f0    	mov    0xf02bf418,%ecx
f0103288:	8b 11                	mov    (%ecx),%edx
f010328a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0103290:	89 f0                	mov    %esi,%eax
f0103292:	2b 05 1c f4 2b f0    	sub    0xf02bf41c,%eax
f0103298:	c1 f8 03             	sar    $0x3,%eax
f010329b:	c1 e0 0c             	shl    $0xc,%eax
f010329e:	39 c2                	cmp    %eax,%edx
f01032a0:	0f 85 79 01 00 00    	jne    f010341f <mem_init+0x1c02>
	kern_pgdir[0] = 0;
f01032a6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01032ac:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01032b1:	0f 85 81 01 00 00    	jne    f0103438 <mem_init+0x1c1b>
	pp0->pp_ref = 0;
f01032b7:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f01032bd:	83 ec 0c             	sub    $0xc,%esp
f01032c0:	56                   	push   %esi
f01032c1:	e8 53 e1 ff ff       	call   f0101419 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01032c6:	c7 04 24 ac 86 10 f0 	movl   $0xf01086ac,(%esp)
f01032cd:	e8 5e 0b 00 00       	call   f0103e30 <cprintf>
}
f01032d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01032d5:	5b                   	pop    %ebx
f01032d6:	5e                   	pop    %esi
f01032d7:	5f                   	pop    %edi
f01032d8:	5d                   	pop    %ebp
f01032d9:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032da:	50                   	push   %eax
f01032db:	68 68 74 10 f0       	push   $0xf0107468
f01032e0:	68 fa 00 00 00       	push   $0xfa
f01032e5:	68 0d 87 10 f0       	push   $0xf010870d
f01032ea:	e8 51 cd ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01032ef:	68 16 88 10 f0       	push   $0xf0108816
f01032f4:	68 33 87 10 f0       	push   $0xf0108733
f01032f9:	68 f4 04 00 00       	push   $0x4f4
f01032fe:	68 0d 87 10 f0       	push   $0xf010870d
f0103303:	e8 38 cd ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0103308:	68 2c 88 10 f0       	push   $0xf010882c
f010330d:	68 33 87 10 f0       	push   $0xf0108733
f0103312:	68 f5 04 00 00       	push   $0x4f5
f0103317:	68 0d 87 10 f0       	push   $0xf010870d
f010331c:	e8 1f cd ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0103321:	68 42 88 10 f0       	push   $0xf0108842
f0103326:	68 33 87 10 f0       	push   $0xf0108733
f010332b:	68 f6 04 00 00       	push   $0x4f6
f0103330:	68 0d 87 10 f0       	push   $0xf010870d
f0103335:	e8 06 cd ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010333a:	52                   	push   %edx
f010333b:	68 44 74 10 f0       	push   $0xf0107444
f0103340:	6a 58                	push   $0x58
f0103342:	68 19 87 10 f0       	push   $0xf0108719
f0103347:	e8 f4 cc ff ff       	call   f0100040 <_panic>
f010334c:	52                   	push   %edx
f010334d:	68 44 74 10 f0       	push   $0xf0107444
f0103352:	6a 58                	push   $0x58
f0103354:	68 19 87 10 f0       	push   $0xf0108719
f0103359:	e8 e2 cc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010335e:	68 13 89 10 f0       	push   $0xf0108913
f0103363:	68 33 87 10 f0       	push   $0xf0108733
f0103368:	68 fb 04 00 00       	push   $0x4fb
f010336d:	68 0d 87 10 f0       	push   $0xf010870d
f0103372:	e8 c9 cc ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103377:	68 38 86 10 f0       	push   $0xf0108638
f010337c:	68 33 87 10 f0       	push   $0xf0108733
f0103381:	68 fc 04 00 00       	push   $0x4fc
f0103386:	68 0d 87 10 f0       	push   $0xf010870d
f010338b:	e8 b0 cc ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103390:	68 5c 86 10 f0       	push   $0xf010865c
f0103395:	68 33 87 10 f0       	push   $0xf0108733
f010339a:	68 fe 04 00 00       	push   $0x4fe
f010339f:	68 0d 87 10 f0       	push   $0xf010870d
f01033a4:	e8 97 cc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01033a9:	68 35 89 10 f0       	push   $0xf0108935
f01033ae:	68 33 87 10 f0       	push   $0xf0108733
f01033b3:	68 ff 04 00 00       	push   $0x4ff
f01033b8:	68 0d 87 10 f0       	push   $0xf010870d
f01033bd:	e8 7e cc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01033c2:	68 9f 89 10 f0       	push   $0xf010899f
f01033c7:	68 33 87 10 f0       	push   $0xf0108733
f01033cc:	68 00 05 00 00       	push   $0x500
f01033d1:	68 0d 87 10 f0       	push   $0xf010870d
f01033d6:	e8 65 cc ff ff       	call   f0100040 <_panic>
f01033db:	52                   	push   %edx
f01033dc:	68 44 74 10 f0       	push   $0xf0107444
f01033e1:	6a 58                	push   $0x58
f01033e3:	68 19 87 10 f0       	push   $0xf0108719
f01033e8:	e8 53 cc ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01033ed:	68 80 86 10 f0       	push   $0xf0108680
f01033f2:	68 33 87 10 f0       	push   $0xf0108733
f01033f7:	68 02 05 00 00       	push   $0x502
f01033fc:	68 0d 87 10 f0       	push   $0xf010870d
f0103401:	e8 3a cc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0103406:	68 6d 89 10 f0       	push   $0xf010896d
f010340b:	68 33 87 10 f0       	push   $0xf0108733
f0103410:	68 04 05 00 00       	push   $0x504
f0103415:	68 0d 87 10 f0       	push   $0xf010870d
f010341a:	e8 21 cc ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010341f:	68 08 80 10 f0       	push   $0xf0108008
f0103424:	68 33 87 10 f0       	push   $0xf0108733
f0103429:	68 07 05 00 00       	push   $0x507
f010342e:	68 0d 87 10 f0       	push   $0xf010870d
f0103433:	e8 08 cc ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0103438:	68 24 89 10 f0       	push   $0xf0108924
f010343d:	68 33 87 10 f0       	push   $0xf0108733
f0103442:	68 09 05 00 00       	push   $0x509
f0103447:	68 0d 87 10 f0       	push   $0xf010870d
f010344c:	e8 ef cb ff ff       	call   f0100040 <_panic>

f0103451 <user_mem_check>:
{
f0103451:	f3 0f 1e fb          	endbr32 
f0103455:	55                   	push   %ebp
f0103456:	89 e5                	mov    %esp,%ebp
f0103458:	57                   	push   %edi
f0103459:	56                   	push   %esi
f010345a:	53                   	push   %ebx
f010345b:	83 ec 0c             	sub    $0xc,%esp
	uintptr_t va0 = (uintptr_t)ROUNDDOWN(va, PGSIZE);
f010345e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103461:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uintptr_t va_end = (uintptr_t) ROUNDUP(va+len, PGSIZE);
f0103467:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010346a:	03 7d 10             	add    0x10(%ebp),%edi
f010346d:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f0103473:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	perm |= PTE_P;
f0103479:	8b 75 14             	mov    0x14(%ebp),%esi
f010347c:	83 ce 01             	or     $0x1,%esi
	for (; va0<va_end; va0 +=PGSIZE){
f010347f:	eb 06                	jmp    f0103487 <user_mem_check+0x36>
f0103481:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103487:	39 fb                	cmp    %edi,%ebx
f0103489:	73 42                	jae    f01034cd <user_mem_check+0x7c>
		pte = pgdir_walk(env->env_pgdir, (void*)va0, 0);
f010348b:	83 ec 04             	sub    $0x4,%esp
f010348e:	6a 00                	push   $0x0
f0103490:	53                   	push   %ebx
f0103491:	8b 45 08             	mov    0x8(%ebp),%eax
f0103494:	ff 70 60             	pushl  0x60(%eax)
f0103497:	e8 00 e0 ff ff       	call   f010149c <pgdir_walk>
		if ((va0>=ULIM)||!pte||((*pte&perm)!=perm)) {
f010349c:	83 c4 10             	add    $0x10,%esp
f010349f:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01034a5:	77 0c                	ja     f01034b3 <user_mem_check+0x62>
f01034a7:	85 c0                	test   %eax,%eax
f01034a9:	74 08                	je     f01034b3 <user_mem_check+0x62>
f01034ab:	89 f2                	mov    %esi,%edx
f01034ad:	23 10                	and    (%eax),%edx
f01034af:	39 d6                	cmp    %edx,%esi
f01034b1:	74 ce                	je     f0103481 <user_mem_check+0x30>
			user_mem_check_addr = va0<(uintptr_t)va?(uintptr_t)va:va0;
f01034b3:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f01034b6:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f01034ba:	89 1d 40 d2 2b f0    	mov    %ebx,0xf02bd240
			return -E_FAULT;
f01034c0:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f01034c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034c8:	5b                   	pop    %ebx
f01034c9:	5e                   	pop    %esi
f01034ca:	5f                   	pop    %edi
f01034cb:	5d                   	pop    %ebp
f01034cc:	c3                   	ret    
	return 0;
f01034cd:	b8 00 00 00 00       	mov    $0x0,%eax
f01034d2:	eb f1                	jmp    f01034c5 <user_mem_check+0x74>

f01034d4 <user_mem_assert>:
{
f01034d4:	f3 0f 1e fb          	endbr32 
f01034d8:	55                   	push   %ebp
f01034d9:	89 e5                	mov    %esp,%ebp
f01034db:	53                   	push   %ebx
f01034dc:	83 ec 04             	sub    $0x4,%esp
f01034df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01034e2:	8b 45 14             	mov    0x14(%ebp),%eax
f01034e5:	83 c8 04             	or     $0x4,%eax
f01034e8:	50                   	push   %eax
f01034e9:	ff 75 10             	pushl  0x10(%ebp)
f01034ec:	ff 75 0c             	pushl  0xc(%ebp)
f01034ef:	53                   	push   %ebx
f01034f0:	e8 5c ff ff ff       	call   f0103451 <user_mem_check>
f01034f5:	83 c4 10             	add    $0x10,%esp
f01034f8:	85 c0                	test   %eax,%eax
f01034fa:	78 05                	js     f0103501 <user_mem_assert+0x2d>
}
f01034fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01034ff:	c9                   	leave  
f0103500:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0103501:	83 ec 04             	sub    $0x4,%esp
f0103504:	ff 35 40 d2 2b f0    	pushl  0xf02bd240
f010350a:	ff 73 48             	pushl  0x48(%ebx)
f010350d:	68 d8 86 10 f0       	push   $0xf01086d8
f0103512:	e8 19 09 00 00       	call   f0103e30 <cprintf>
		env_destroy(env);	// may not return
f0103517:	89 1c 24             	mov    %ebx,(%esp)
f010351a:	e8 00 06 00 00       	call   f0103b1f <env_destroy>
f010351f:	83 c4 10             	add    $0x10,%esp
}
f0103522:	eb d8                	jmp    f01034fc <user_mem_assert+0x28>

f0103524 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103524:	55                   	push   %ebp
f0103525:	89 e5                	mov    %esp,%ebp
f0103527:	57                   	push   %edi
f0103528:	56                   	push   %esi
f0103529:	53                   	push   %ebx
f010352a:	83 ec 1c             	sub    $0x1c,%esp
f010352d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	va = ROUNDDOWN(va, PGSIZE); int ret;
f0103530:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0103536:	89 d6                	mov    %edx,%esi
	int num = ((uint32_t)ROUNDUP(len, PGSIZE))/PGSIZE;
f0103538:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f010353e:	c1 e9 0c             	shr    $0xc,%ecx
f0103541:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	struct PageInfo* pp;
	for (int i = 0; i<num; i++, va+=PGSIZE){
f0103544:	bf 00 00 00 00       	mov    $0x0,%edi
f0103549:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f010354c:	7d 6e                	jge    f01035bc <region_alloc+0x98>
		if (!(pp = page_alloc(ALLOC_ZERO))){
f010354e:	83 ec 0c             	sub    $0xc,%esp
f0103551:	6a 01                	push   $0x1
f0103553:	e8 48 de ff ff       	call   f01013a0 <page_alloc>
f0103558:	89 c3                	mov    %eax,%ebx
f010355a:	83 c4 10             	add    $0x10,%esp
f010355d:	85 c0                	test   %eax,%eax
f010355f:	74 21                	je     f0103582 <region_alloc+0x5e>
			panic("region_alloc: page allocation for env_id : %d fails", e->env_id);
			return;
		}
		if ((ret = page_insert(e->env_pgdir, pp, va, PTE_P|PTE_U|PTE_W))<0){
f0103561:	6a 07                	push   $0x7
f0103563:	56                   	push   %esi
f0103564:	50                   	push   %eax
f0103565:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103568:	ff 70 60             	pushl  0x60(%eax)
f010356b:	e8 9e e1 ff ff       	call   f010170e <page_insert>
f0103570:	83 c4 10             	add    $0x10,%esp
f0103573:	85 c0                	test   %eax,%eax
f0103575:	78 25                	js     f010359c <region_alloc+0x78>
	for (int i = 0; i<num; i++, va+=PGSIZE){
f0103577:	83 c7 01             	add    $0x1,%edi
f010357a:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103580:	eb c7                	jmp    f0103549 <region_alloc+0x25>
			panic("region_alloc: page allocation for env_id : %d fails", e->env_id);
f0103582:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103585:	ff 70 48             	pushl  0x48(%eax)
f0103588:	68 58 8a 10 f0       	push   $0xf0108a58
f010358d:	68 33 01 00 00       	push   $0x133
f0103592:	68 e0 8a 10 f0       	push   $0xf0108ae0
f0103597:	e8 a4 ca ff ff       	call   f0100040 <_panic>
			page_free(pp);
f010359c:	83 ec 0c             	sub    $0xc,%esp
f010359f:	53                   	push   %ebx
f01035a0:	e8 74 de ff ff       	call   f0101419 <page_free>
			panic("region_alloc: fail to insert a page\n");
f01035a5:	83 c4 0c             	add    $0xc,%esp
f01035a8:	68 8c 8a 10 f0       	push   $0xf0108a8c
f01035ad:	68 38 01 00 00       	push   $0x138
f01035b2:	68 e0 8a 10 f0       	push   $0xf0108ae0
f01035b7:	e8 84 ca ff ff       	call   f0100040 <_panic>
			return;
		}

	}

}
f01035bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01035bf:	5b                   	pop    %ebx
f01035c0:	5e                   	pop    %esi
f01035c1:	5f                   	pop    %edi
f01035c2:	5d                   	pop    %ebp
f01035c3:	c3                   	ret    

f01035c4 <envid2env>:
{
f01035c4:	f3 0f 1e fb          	endbr32 
f01035c8:	55                   	push   %ebp
f01035c9:	89 e5                	mov    %esp,%ebp
f01035cb:	56                   	push   %esi
f01035cc:	53                   	push   %ebx
f01035cd:	8b 75 08             	mov    0x8(%ebp),%esi
f01035d0:	8b 45 10             	mov    0x10(%ebp),%eax
	if (envid == 0) {
f01035d3:	85 f6                	test   %esi,%esi
f01035d5:	74 2e                	je     f0103605 <envid2env+0x41>
	e = &envs[ENVX(envid)];
f01035d7:	89 f3                	mov    %esi,%ebx
f01035d9:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01035df:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f01035e2:	03 1d 4c d2 2b f0    	add    0xf02bd24c,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01035e8:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01035ec:	74 2e                	je     f010361c <envid2env+0x58>
f01035ee:	39 73 48             	cmp    %esi,0x48(%ebx)
f01035f1:	75 29                	jne    f010361c <envid2env+0x58>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01035f3:	84 c0                	test   %al,%al
f01035f5:	75 35                	jne    f010362c <envid2env+0x68>
	*env_store = e;
f01035f7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035fa:	89 18                	mov    %ebx,(%eax)
	return 0;
f01035fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103601:	5b                   	pop    %ebx
f0103602:	5e                   	pop    %esi
f0103603:	5d                   	pop    %ebp
f0103604:	c3                   	ret    
		*env_store = curenv;
f0103605:	e8 84 2e 00 00       	call   f010648e <cpunum>
f010360a:	6b c0 74             	imul   $0x74,%eax,%eax
f010360d:	8b 80 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%eax
f0103613:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103616:	89 02                	mov    %eax,(%edx)
		return 0;
f0103618:	89 f0                	mov    %esi,%eax
f010361a:	eb e5                	jmp    f0103601 <envid2env+0x3d>
		*env_store = 0;
f010361c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010361f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103625:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010362a:	eb d5                	jmp    f0103601 <envid2env+0x3d>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010362c:	e8 5d 2e 00 00       	call   f010648e <cpunum>
f0103631:	6b c0 74             	imul   $0x74,%eax,%eax
f0103634:	39 98 28 00 2c f0    	cmp    %ebx,-0xfd3ffd8(%eax)
f010363a:	74 bb                	je     f01035f7 <envid2env+0x33>
f010363c:	8b 73 4c             	mov    0x4c(%ebx),%esi
f010363f:	e8 4a 2e 00 00       	call   f010648e <cpunum>
f0103644:	6b c0 74             	imul   $0x74,%eax,%eax
f0103647:	8b 80 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%eax
f010364d:	3b 70 48             	cmp    0x48(%eax),%esi
f0103650:	74 a5                	je     f01035f7 <envid2env+0x33>
		*env_store = 0;
f0103652:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103655:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010365b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103660:	eb 9f                	jmp    f0103601 <envid2env+0x3d>

f0103662 <env_init_percpu>:
{
f0103662:	f3 0f 1e fb          	endbr32 
	asm volatile("lgdt (%0)" : : "r" (p));
f0103666:	b8 20 73 12 f0       	mov    $0xf0127320,%eax
f010366b:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f010366e:	b8 23 00 00 00       	mov    $0x23,%eax
f0103673:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103675:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103677:	b8 10 00 00 00       	mov    $0x10,%eax
f010367c:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f010367e:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103680:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103682:	ea 89 36 10 f0 08 00 	ljmp   $0x8,$0xf0103689
	asm volatile("lldt %0" : : "r" (sel));
f0103689:	b8 00 00 00 00       	mov    $0x0,%eax
f010368e:	0f 00 d0             	lldt   %ax
}
f0103691:	c3                   	ret    

f0103692 <env_init>:
{
f0103692:	f3 0f 1e fb          	endbr32 
f0103696:	55                   	push   %ebp
f0103697:	89 e5                	mov    %esp,%ebp
f0103699:	56                   	push   %esi
f010369a:	53                   	push   %ebx
		envs[i].env_id = 0;
f010369b:	8b 35 4c d2 2b f0    	mov    0xf02bd24c,%esi
f01036a1:	8b 15 50 d2 2b f0    	mov    0xf02bd250,%edx
f01036a7:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f01036ad:	89 f3                	mov    %esi,%ebx
f01036af:	89 d1                	mov    %edx,%ecx
f01036b1:	89 c2                	mov    %eax,%edx
f01036b3:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_status = ENV_FREE;
f01036ba:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link = env_free_list;
f01036c1:	89 48 44             	mov    %ecx,0x44(%eax)
f01036c4:	83 e8 7c             	sub    $0x7c,%eax
	for (int i=NENV-1; i>=0; i--){
f01036c7:	39 da                	cmp    %ebx,%edx
f01036c9:	75 e4                	jne    f01036af <env_init+0x1d>
f01036cb:	89 35 50 d2 2b f0    	mov    %esi,0xf02bd250
	env_init_percpu();
f01036d1:	e8 8c ff ff ff       	call   f0103662 <env_init_percpu>
}
f01036d6:	5b                   	pop    %ebx
f01036d7:	5e                   	pop    %esi
f01036d8:	5d                   	pop    %ebp
f01036d9:	c3                   	ret    

f01036da <env_alloc>:
{
f01036da:	f3 0f 1e fb          	endbr32 
f01036de:	55                   	push   %ebp
f01036df:	89 e5                	mov    %esp,%ebp
f01036e1:	53                   	push   %ebx
f01036e2:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f01036e5:	8b 1d 50 d2 2b f0    	mov    0xf02bd250,%ebx
f01036eb:	85 db                	test   %ebx,%ebx
f01036ed:	0f 84 3b 01 00 00    	je     f010382e <env_alloc+0x154>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01036f3:	83 ec 0c             	sub    $0xc,%esp
f01036f6:	6a 01                	push   $0x1
f01036f8:	e8 a3 dc ff ff       	call   f01013a0 <page_alloc>
f01036fd:	83 c4 10             	add    $0x10,%esp
f0103700:	85 c0                	test   %eax,%eax
f0103702:	0f 84 2d 01 00 00    	je     f0103835 <env_alloc+0x15b>
	p->pp_ref++;
f0103708:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f010370d:	2b 05 1c f4 2b f0    	sub    0xf02bf41c,%eax
f0103713:	c1 f8 03             	sar    $0x3,%eax
f0103716:	89 c2                	mov    %eax,%edx
f0103718:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010371b:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0103720:	3b 05 14 f4 2b f0    	cmp    0xf02bf414,%eax
f0103726:	0f 83 db 00 00 00    	jae    f0103807 <env_alloc+0x12d>
	return (void *)(pa + KERNBASE);
f010372c:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	e->env_pgdir = (pte_t*)page2kva(p);
f0103732:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103735:	83 ec 04             	sub    $0x4,%esp
f0103738:	68 00 10 00 00       	push   $0x1000
f010373d:	ff 35 18 f4 2b f0    	pushl  0xf02bf418
f0103743:	50                   	push   %eax
f0103744:	e8 d6 27 00 00       	call   f0105f1f <memcpy>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103749:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f010374c:	83 c4 10             	add    $0x10,%esp
f010374f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103754:	0f 86 bf 00 00 00    	jbe    f0103819 <env_alloc+0x13f>
	return (physaddr_t)kva - KERNBASE;
f010375a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103760:	83 ca 05             	or     $0x5,%edx
f0103763:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103769:	8b 43 48             	mov    0x48(%ebx),%eax
f010376c:	05 00 10 00 00       	add    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
f0103771:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103776:	ba 00 10 00 00       	mov    $0x1000,%edx
f010377b:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010377e:	89 da                	mov    %ebx,%edx
f0103780:	2b 15 4c d2 2b f0    	sub    0xf02bd24c,%edx
f0103786:	c1 fa 02             	sar    $0x2,%edx
f0103789:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f010378f:	09 d0                	or     %edx,%eax
f0103791:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f0103794:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103797:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010379a:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01037a1:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01037a8:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01037af:	83 ec 04             	sub    $0x4,%esp
f01037b2:	6a 44                	push   $0x44
f01037b4:	6a 00                	push   $0x0
f01037b6:	53                   	push   %ebx
f01037b7:	e8 b1 26 00 00       	call   f0105e6d <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f01037bc:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01037c2:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01037c8:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01037ce:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01037d5:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_tf.tf_eflags |= FL_IF; 
f01037db:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f01037e2:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f01037e9:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f01037ed:	8b 43 44             	mov    0x44(%ebx),%eax
f01037f0:	a3 50 d2 2b f0       	mov    %eax,0xf02bd250
	*newenv_store = e;
f01037f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01037f8:	89 18                	mov    %ebx,(%eax)
	return 0;
f01037fa:	83 c4 10             	add    $0x10,%esp
f01037fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103802:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103805:	c9                   	leave  
f0103806:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103807:	52                   	push   %edx
f0103808:	68 44 74 10 f0       	push   $0xf0107444
f010380d:	6a 58                	push   $0x58
f010380f:	68 19 87 10 f0       	push   $0xf0108719
f0103814:	e8 27 c8 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103819:	50                   	push   %eax
f010381a:	68 68 74 10 f0       	push   $0xf0107468
f010381f:	68 cf 00 00 00       	push   $0xcf
f0103824:	68 e0 8a 10 f0       	push   $0xf0108ae0
f0103829:	e8 12 c8 ff ff       	call   f0100040 <_panic>
		return -E_NO_FREE_ENV;
f010382e:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103833:	eb cd                	jmp    f0103802 <env_alloc+0x128>
		return -E_NO_MEM;
f0103835:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010383a:	eb c6                	jmp    f0103802 <env_alloc+0x128>

f010383c <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010383c:	f3 0f 1e fb          	endbr32 
f0103840:	55                   	push   %ebp
f0103841:	89 e5                	mov    %esp,%ebp
f0103843:	57                   	push   %edi
f0103844:	56                   	push   %esi
f0103845:	53                   	push   %ebx
f0103846:	83 ec 34             	sub    $0x34,%esp
f0103849:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	struct Env* e;
	int ret;
	if ((ret = env_alloc(&e, 0))<0){
f010384c:	6a 00                	push   $0x0
f010384e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103851:	50                   	push   %eax
f0103852:	e8 83 fe ff ff       	call   f01036da <env_alloc>
f0103857:	83 c4 10             	add    $0x10,%esp
f010385a:	85 c0                	test   %eax,%eax
f010385c:	78 30                	js     f010388e <env_create+0x52>
		panic("env_alloc: %e", ret);
		return;
	}
	load_icode(e, binary);
f010385e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	if (elf_hdr->e_magic!=ELF_MAGIC){
f0103861:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f0103867:	75 3a                	jne    f01038a3 <env_create+0x67>
	lcr3(PADDR(e->env_pgdir));
f0103869:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f010386c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103871:	76 47                	jbe    f01038ba <env_create+0x7e>
	return (physaddr_t)kva - KERNBASE;
f0103873:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103878:	0f 22 d8             	mov    %eax,%cr3
	struct Proghdr* ph = (struct Proghdr*) ((uint8_t*)elf_hdr + elf_hdr->e_phoff);
f010387b:	89 f3                	mov    %esi,%ebx
f010387d:	03 5e 1c             	add    0x1c(%esi),%ebx
	struct Proghdr* eph = ph+elf_hdr->e_phnum;
f0103880:	0f b7 46 2c          	movzwl 0x2c(%esi),%eax
f0103884:	c1 e0 05             	shl    $0x5,%eax
f0103887:	01 d8                	add    %ebx,%eax
f0103889:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for(; ph < eph; ph++){
f010388c:	eb 78                	jmp    f0103906 <env_create+0xca>
		panic("env_alloc: %e", ret);
f010388e:	50                   	push   %eax
f010388f:	68 eb 8a 10 f0       	push   $0xf0108aeb
f0103894:	68 af 01 00 00       	push   $0x1af
f0103899:	68 e0 8a 10 f0       	push   $0xf0108ae0
f010389e:	e8 9d c7 ff ff       	call   f0100040 <_panic>
		panic("load_icode: binary is not a valid elf file\n");
f01038a3:	83 ec 04             	sub    $0x4,%esp
f01038a6:	68 b4 8a 10 f0       	push   $0xf0108ab4
f01038ab:	68 7d 01 00 00       	push   $0x17d
f01038b0:	68 e0 8a 10 f0       	push   $0xf0108ae0
f01038b5:	e8 86 c7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01038ba:	50                   	push   %eax
f01038bb:	68 68 74 10 f0       	push   $0xf0107468
f01038c0:	68 81 01 00 00       	push   $0x181
f01038c5:	68 e0 8a 10 f0       	push   $0xf0108ae0
f01038ca:	e8 71 c7 ff ff       	call   f0100040 <_panic>
			region_alloc(e, (void*)ph->p_va, ph->p_memsz);
f01038cf:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01038d2:	8b 53 08             	mov    0x8(%ebx),%edx
f01038d5:	89 f8                	mov    %edi,%eax
f01038d7:	e8 48 fc ff ff       	call   f0103524 <region_alloc>
			memset((void*)ph->p_va, 0, ph->p_memsz);
f01038dc:	83 ec 04             	sub    $0x4,%esp
f01038df:	ff 73 14             	pushl  0x14(%ebx)
f01038e2:	6a 00                	push   $0x0
f01038e4:	ff 73 08             	pushl  0x8(%ebx)
f01038e7:	e8 81 25 00 00       	call   f0105e6d <memset>
			memcpy((void*)ph->p_va, (uint8_t*)elf_hdr + ph->p_offset, ph->p_filesz);	
f01038ec:	83 c4 0c             	add    $0xc,%esp
f01038ef:	ff 73 10             	pushl  0x10(%ebx)
f01038f2:	89 f0                	mov    %esi,%eax
f01038f4:	03 43 04             	add    0x4(%ebx),%eax
f01038f7:	50                   	push   %eax
f01038f8:	ff 73 08             	pushl  0x8(%ebx)
f01038fb:	e8 1f 26 00 00       	call   f0105f1f <memcpy>
f0103900:	83 c4 10             	add    $0x10,%esp
	for(; ph < eph; ph++){
f0103903:	83 c3 20             	add    $0x20,%ebx
f0103906:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0103909:	76 07                	jbe    f0103912 <env_create+0xd6>
		if (ph->p_type == ELF_PROG_LOAD){
f010390b:	83 3b 01             	cmpl   $0x1,(%ebx)
f010390e:	75 f3                	jne    f0103903 <env_create+0xc7>
f0103910:	eb bd                	jmp    f01038cf <env_create+0x93>
	e->env_tf.tf_eip = elf_hdr->e_entry;
f0103912:	8b 46 18             	mov    0x18(%esi),%eax
f0103915:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void*)(USTACKTOP-PGSIZE), PGSIZE);
f0103918:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010391d:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103922:	89 f8                	mov    %edi,%eax
f0103924:	e8 fb fb ff ff       	call   f0103524 <region_alloc>
	lcr3(PADDR(kern_pgdir));
f0103929:	a1 18 f4 2b f0       	mov    0xf02bf418,%eax
	if ((uint32_t)kva < KERNBASE)
f010392e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103933:	76 1e                	jbe    f0103953 <env_create+0x117>
	return (physaddr_t)kva - KERNBASE;
f0103935:	05 00 00 00 10       	add    $0x10000000,%eax
f010393a:	0f 22 d8             	mov    %eax,%cr3
	e->env_type = type;
f010393d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103940:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103943:	89 50 50             	mov    %edx,0x50(%eax)
	// setting io previlege level for file system environment
	if (type == ENV_TYPE_FS)
f0103946:	83 fa 01             	cmp    $0x1,%edx
f0103949:	74 1d                	je     f0103968 <env_create+0x12c>
		e->env_tf.tf_eflags |= FL_IOPL_3;
	else 
		e->env_tf.tf_eflags |= FL_IOPL_0;

}
f010394b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010394e:	5b                   	pop    %ebx
f010394f:	5e                   	pop    %esi
f0103950:	5f                   	pop    %edi
f0103951:	5d                   	pop    %ebp
f0103952:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103953:	50                   	push   %eax
f0103954:	68 68 74 10 f0       	push   $0xf0107468
f0103959:	68 9e 01 00 00       	push   $0x19e
f010395e:	68 e0 8a 10 f0       	push   $0xf0108ae0
f0103963:	e8 d8 c6 ff ff       	call   f0100040 <_panic>
		e->env_tf.tf_eflags |= FL_IOPL_3;
f0103968:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
f010396f:	eb da                	jmp    f010394b <env_create+0x10f>

f0103971 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103971:	f3 0f 1e fb          	endbr32 
f0103975:	55                   	push   %ebp
f0103976:	89 e5                	mov    %esp,%ebp
f0103978:	57                   	push   %edi
f0103979:	56                   	push   %esi
f010397a:	53                   	push   %ebx
f010397b:	83 ec 1c             	sub    $0x1c,%esp
f010397e:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103981:	e8 08 2b 00 00       	call   f010648e <cpunum>
f0103986:	6b c0 74             	imul   $0x74,%eax,%eax
f0103989:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103990:	39 b8 28 00 2c f0    	cmp    %edi,-0xfd3ffd8(%eax)
f0103996:	0f 85 b3 00 00 00    	jne    f0103a4f <env_free+0xde>
		lcr3(PADDR(kern_pgdir));
f010399c:	a1 18 f4 2b f0       	mov    0xf02bf418,%eax
	if ((uint32_t)kva < KERNBASE)
f01039a1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039a6:	76 14                	jbe    f01039bc <env_free+0x4b>
	return (physaddr_t)kva - KERNBASE;
f01039a8:	05 00 00 00 10       	add    $0x10000000,%eax
f01039ad:	0f 22 d8             	mov    %eax,%cr3
}
f01039b0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01039b7:	e9 93 00 00 00       	jmp    f0103a4f <env_free+0xde>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039bc:	50                   	push   %eax
f01039bd:	68 68 74 10 f0       	push   $0xf0107468
f01039c2:	68 ca 01 00 00       	push   $0x1ca
f01039c7:	68 e0 8a 10 f0       	push   $0xf0108ae0
f01039cc:	e8 6f c6 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01039d1:	56                   	push   %esi
f01039d2:	68 44 74 10 f0       	push   $0xf0107444
f01039d7:	68 d9 01 00 00       	push   $0x1d9
f01039dc:	68 e0 8a 10 f0       	push   $0xf0108ae0
f01039e1:	e8 5a c6 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01039e6:	83 ec 08             	sub    $0x8,%esp
f01039e9:	89 d8                	mov    %ebx,%eax
f01039eb:	c1 e0 0c             	shl    $0xc,%eax
f01039ee:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01039f1:	50                   	push   %eax
f01039f2:	ff 77 60             	pushl  0x60(%edi)
f01039f5:	e8 ca dc ff ff       	call   f01016c4 <page_remove>
f01039fa:	83 c4 10             	add    $0x10,%esp
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01039fd:	83 c3 01             	add    $0x1,%ebx
f0103a00:	83 c6 04             	add    $0x4,%esi
f0103a03:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103a09:	74 07                	je     f0103a12 <env_free+0xa1>
			if (pt[pteno] & PTE_P)
f0103a0b:	f6 06 01             	testb  $0x1,(%esi)
f0103a0e:	74 ed                	je     f01039fd <env_free+0x8c>
f0103a10:	eb d4                	jmp    f01039e6 <env_free+0x75>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103a12:	8b 47 60             	mov    0x60(%edi),%eax
f0103a15:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103a18:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103a1f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103a22:	3b 05 14 f4 2b f0    	cmp    0xf02bf414,%eax
f0103a28:	73 65                	jae    f0103a8f <env_free+0x11e>
		page_decref(pa2page(pa));
f0103a2a:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103a2d:	a1 1c f4 2b f0       	mov    0xf02bf41c,%eax
f0103a32:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103a35:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103a38:	50                   	push   %eax
f0103a39:	e8 31 da ff ff       	call   f010146f <page_decref>
f0103a3e:	83 c4 10             	add    $0x10,%esp
f0103a41:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f0103a45:	8b 45 e0             	mov    -0x20(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103a48:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103a4d:	74 54                	je     f0103aa3 <env_free+0x132>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103a4f:	8b 47 60             	mov    0x60(%edi),%eax
f0103a52:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103a55:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0103a58:	a8 01                	test   $0x1,%al
f0103a5a:	74 e5                	je     f0103a41 <env_free+0xd0>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103a5c:	89 c6                	mov    %eax,%esi
f0103a5e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0103a64:	c1 e8 0c             	shr    $0xc,%eax
f0103a67:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103a6a:	39 05 14 f4 2b f0    	cmp    %eax,0xf02bf414
f0103a70:	0f 86 5b ff ff ff    	jbe    f01039d1 <env_free+0x60>
	return (void *)(pa + KERNBASE);
f0103a76:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0103a7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103a7f:	c1 e0 14             	shl    $0x14,%eax
f0103a82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103a85:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103a8a:	e9 7c ff ff ff       	jmp    f0103a0b <env_free+0x9a>
		panic("pa2page called with invalid pa");
f0103a8f:	83 ec 04             	sub    $0x4,%esp
f0103a92:	68 58 7e 10 f0       	push   $0xf0107e58
f0103a97:	6a 51                	push   $0x51
f0103a99:	68 19 87 10 f0       	push   $0xf0108719
f0103a9e:	e8 9d c5 ff ff       	call   f0100040 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103aa3:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103aa6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103aab:	76 49                	jbe    f0103af6 <env_free+0x185>
	e->env_pgdir = 0;
f0103aad:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103ab4:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103ab9:	c1 e8 0c             	shr    $0xc,%eax
f0103abc:	3b 05 14 f4 2b f0    	cmp    0xf02bf414,%eax
f0103ac2:	73 47                	jae    f0103b0b <env_free+0x19a>
	page_decref(pa2page(pa));
f0103ac4:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103ac7:	8b 15 1c f4 2b f0    	mov    0xf02bf41c,%edx
f0103acd:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103ad0:	50                   	push   %eax
f0103ad1:	e8 99 d9 ff ff       	call   f010146f <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103ad6:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103add:	a1 50 d2 2b f0       	mov    0xf02bd250,%eax
f0103ae2:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103ae5:	89 3d 50 d2 2b f0    	mov    %edi,0xf02bd250
}
f0103aeb:	83 c4 10             	add    $0x10,%esp
f0103aee:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103af1:	5b                   	pop    %ebx
f0103af2:	5e                   	pop    %esi
f0103af3:	5f                   	pop    %edi
f0103af4:	5d                   	pop    %ebp
f0103af5:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103af6:	50                   	push   %eax
f0103af7:	68 68 74 10 f0       	push   $0xf0107468
f0103afc:	68 e7 01 00 00       	push   $0x1e7
f0103b01:	68 e0 8a 10 f0       	push   $0xf0108ae0
f0103b06:	e8 35 c5 ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f0103b0b:	83 ec 04             	sub    $0x4,%esp
f0103b0e:	68 58 7e 10 f0       	push   $0xf0107e58
f0103b13:	6a 51                	push   $0x51
f0103b15:	68 19 87 10 f0       	push   $0xf0108719
f0103b1a:	e8 21 c5 ff ff       	call   f0100040 <_panic>

f0103b1f <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103b1f:	f3 0f 1e fb          	endbr32 
f0103b23:	55                   	push   %ebp
f0103b24:	89 e5                	mov    %esp,%ebp
f0103b26:	53                   	push   %ebx
f0103b27:	83 ec 04             	sub    $0x4,%esp
f0103b2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103b2d:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103b31:	74 21                	je     f0103b54 <env_destroy+0x35>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f0103b33:	83 ec 0c             	sub    $0xc,%esp
f0103b36:	53                   	push   %ebx
f0103b37:	e8 35 fe ff ff       	call   f0103971 <env_free>

	if (curenv == e) {
f0103b3c:	e8 4d 29 00 00       	call   f010648e <cpunum>
f0103b41:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b44:	83 c4 10             	add    $0x10,%esp
f0103b47:	39 98 28 00 2c f0    	cmp    %ebx,-0xfd3ffd8(%eax)
f0103b4d:	74 1e                	je     f0103b6d <env_destroy+0x4e>
		curenv = NULL;
		sched_yield();
	}
}
f0103b4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103b52:	c9                   	leave  
f0103b53:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103b54:	e8 35 29 00 00       	call   f010648e <cpunum>
f0103b59:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b5c:	39 98 28 00 2c f0    	cmp    %ebx,-0xfd3ffd8(%eax)
f0103b62:	74 cf                	je     f0103b33 <env_destroy+0x14>
		e->env_status = ENV_DYING;
f0103b64:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103b6b:	eb e2                	jmp    f0103b4f <env_destroy+0x30>
		curenv = NULL;
f0103b6d:	e8 1c 29 00 00       	call   f010648e <cpunum>
f0103b72:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b75:	c7 80 28 00 2c f0 00 	movl   $0x0,-0xfd3ffd8(%eax)
f0103b7c:	00 00 00 
		sched_yield();
f0103b7f:	e8 4e 0f 00 00       	call   f0104ad2 <sched_yield>

f0103b84 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103b84:	f3 0f 1e fb          	endbr32 
f0103b88:	55                   	push   %ebp
f0103b89:	89 e5                	mov    %esp,%ebp
f0103b8b:	53                   	push   %ebx
f0103b8c:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103b8f:	e8 fa 28 00 00       	call   f010648e <cpunum>
f0103b94:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b97:	8b 98 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%ebx
f0103b9d:	e8 ec 28 00 00       	call   f010648e <cpunum>
f0103ba2:	89 43 5c             	mov    %eax,0x5c(%ebx)
	asm volatile(
f0103ba5:	8b 65 08             	mov    0x8(%ebp),%esp
f0103ba8:	61                   	popa   
f0103ba9:	07                   	pop    %es
f0103baa:	1f                   	pop    %ds
f0103bab:	83 c4 08             	add    $0x8,%esp
f0103bae:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103baf:	83 ec 04             	sub    $0x4,%esp
f0103bb2:	68 f9 8a 10 f0       	push   $0xf0108af9
f0103bb7:	68 1d 02 00 00       	push   $0x21d
f0103bbc:	68 e0 8a 10 f0       	push   $0xf0108ae0
f0103bc1:	e8 7a c4 ff ff       	call   f0100040 <_panic>

f0103bc6 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103bc6:	f3 0f 1e fb          	endbr32 
f0103bca:	55                   	push   %ebp
f0103bcb:	89 e5                	mov    %esp,%ebp
f0103bcd:	53                   	push   %ebx
f0103bce:	83 ec 04             	sub    $0x4,%esp
f0103bd1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv!=e){
f0103bd4:	e8 b5 28 00 00       	call   f010648e <cpunum>
f0103bd9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bdc:	39 98 28 00 2c f0    	cmp    %ebx,-0xfd3ffd8(%eax)
f0103be2:	74 50                	je     f0103c34 <env_run+0x6e>
		if (curenv&&curenv->env_status == ENV_RUNNING){
f0103be4:	e8 a5 28 00 00       	call   f010648e <cpunum>
f0103be9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bec:	83 b8 28 00 2c f0 00 	cmpl   $0x0,-0xfd3ffd8(%eax)
f0103bf3:	74 14                	je     f0103c09 <env_run+0x43>
f0103bf5:	e8 94 28 00 00       	call   f010648e <cpunum>
f0103bfa:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bfd:	8b 80 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%eax
f0103c03:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103c07:	74 42                	je     f0103c4b <env_run+0x85>
			curenv->env_status = ENV_RUNNABLE;
		}
		e->env_status = ENV_RUNNING;
f0103c09:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
		e->env_runs++;
f0103c10:	83 43 58 01          	addl   $0x1,0x58(%ebx)
		lcr3(PADDR(e->env_pgdir));
f0103c14:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103c17:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103c1c:	76 44                	jbe    f0103c62 <env_run+0x9c>
	return (physaddr_t)kva - KERNBASE;
f0103c1e:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103c23:	0f 22 d8             	mov    %eax,%cr3
		curenv = e;
f0103c26:	e8 63 28 00 00       	call   f010648e <cpunum>
f0103c2b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c2e:	89 98 28 00 2c f0    	mov    %ebx,-0xfd3ffd8(%eax)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103c34:	83 ec 0c             	sub    $0xc,%esp
f0103c37:	68 c0 73 12 f0       	push   $0xf01273c0
f0103c3c:	e8 73 2b 00 00       	call   f01067b4 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103c41:	f3 90                	pause  
	}
	// release lock
	unlock_kernel();
	// drop into the env e
	env_pop_tf(&e->env_tf);
f0103c43:	89 1c 24             	mov    %ebx,(%esp)
f0103c46:	e8 39 ff ff ff       	call   f0103b84 <env_pop_tf>
			curenv->env_status = ENV_RUNNABLE;
f0103c4b:	e8 3e 28 00 00       	call   f010648e <cpunum>
f0103c50:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c53:	8b 80 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%eax
f0103c59:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0103c60:	eb a7                	jmp    f0103c09 <env_run+0x43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c62:	50                   	push   %eax
f0103c63:	68 68 74 10 f0       	push   $0xf0107468
f0103c68:	68 42 02 00 00       	push   $0x242
f0103c6d:	68 e0 8a 10 f0       	push   $0xf0108ae0
f0103c72:	e8 c9 c3 ff ff       	call   f0100040 <_panic>

f0103c77 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103c77:	f3 0f 1e fb          	endbr32 
f0103c7b:	55                   	push   %ebp
f0103c7c:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103c7e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c81:	ba 70 00 00 00       	mov    $0x70,%edx
f0103c86:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103c87:	ba 71 00 00 00       	mov    $0x71,%edx
f0103c8c:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103c8d:	0f b6 c0             	movzbl %al,%eax
}
f0103c90:	5d                   	pop    %ebp
f0103c91:	c3                   	ret    

f0103c92 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103c92:	f3 0f 1e fb          	endbr32 
f0103c96:	55                   	push   %ebp
f0103c97:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103c99:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c9c:	ba 70 00 00 00       	mov    $0x70,%edx
f0103ca1:	ee                   	out    %al,(%dx)
f0103ca2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103ca5:	ba 71 00 00 00       	mov    $0x71,%edx
f0103caa:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103cab:	5d                   	pop    %ebp
f0103cac:	c3                   	ret    

f0103cad <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103cad:	f3 0f 1e fb          	endbr32 
f0103cb1:	55                   	push   %ebp
f0103cb2:	89 e5                	mov    %esp,%ebp
f0103cb4:	56                   	push   %esi
f0103cb5:	53                   	push   %ebx
f0103cb6:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103cb9:	66 a3 a8 73 12 f0    	mov    %ax,0xf01273a8
	if (!didinit)
f0103cbf:	80 3d 54 d2 2b f0 00 	cmpb   $0x0,0xf02bd254
f0103cc6:	75 07                	jne    f0103ccf <irq_setmask_8259A+0x22>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f0103cc8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103ccb:	5b                   	pop    %ebx
f0103ccc:	5e                   	pop    %esi
f0103ccd:	5d                   	pop    %ebp
f0103cce:	c3                   	ret    
f0103ccf:	89 c6                	mov    %eax,%esi
f0103cd1:	ba 21 00 00 00       	mov    $0x21,%edx
f0103cd6:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103cd7:	66 c1 e8 08          	shr    $0x8,%ax
f0103cdb:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103ce0:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103ce1:	83 ec 0c             	sub    $0xc,%esp
f0103ce4:	68 05 8b 10 f0       	push   $0xf0108b05
f0103ce9:	e8 42 01 00 00       	call   f0103e30 <cprintf>
f0103cee:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103cf1:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103cf6:	0f b7 f6             	movzwl %si,%esi
f0103cf9:	f7 d6                	not    %esi
f0103cfb:	eb 19                	jmp    f0103d16 <irq_setmask_8259A+0x69>
			cprintf(" %d", i);
f0103cfd:	83 ec 08             	sub    $0x8,%esp
f0103d00:	53                   	push   %ebx
f0103d01:	68 f3 8f 10 f0       	push   $0xf0108ff3
f0103d06:	e8 25 01 00 00       	call   f0103e30 <cprintf>
f0103d0b:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103d0e:	83 c3 01             	add    $0x1,%ebx
f0103d11:	83 fb 10             	cmp    $0x10,%ebx
f0103d14:	74 07                	je     f0103d1d <irq_setmask_8259A+0x70>
		if (~mask & (1<<i))
f0103d16:	0f a3 de             	bt     %ebx,%esi
f0103d19:	73 f3                	jae    f0103d0e <irq_setmask_8259A+0x61>
f0103d1b:	eb e0                	jmp    f0103cfd <irq_setmask_8259A+0x50>
	cprintf("\n");
f0103d1d:	83 ec 0c             	sub    $0xc,%esp
f0103d20:	68 08 8a 10 f0       	push   $0xf0108a08
f0103d25:	e8 06 01 00 00       	call   f0103e30 <cprintf>
f0103d2a:	83 c4 10             	add    $0x10,%esp
f0103d2d:	eb 99                	jmp    f0103cc8 <irq_setmask_8259A+0x1b>

f0103d2f <pic_init>:
{
f0103d2f:	f3 0f 1e fb          	endbr32 
f0103d33:	55                   	push   %ebp
f0103d34:	89 e5                	mov    %esp,%ebp
f0103d36:	57                   	push   %edi
f0103d37:	56                   	push   %esi
f0103d38:	53                   	push   %ebx
f0103d39:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f0103d3c:	c6 05 54 d2 2b f0 01 	movb   $0x1,0xf02bd254
f0103d43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103d48:	bb 21 00 00 00       	mov    $0x21,%ebx
f0103d4d:	89 da                	mov    %ebx,%edx
f0103d4f:	ee                   	out    %al,(%dx)
f0103d50:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103d55:	89 ca                	mov    %ecx,%edx
f0103d57:	ee                   	out    %al,(%dx)
f0103d58:	bf 11 00 00 00       	mov    $0x11,%edi
f0103d5d:	be 20 00 00 00       	mov    $0x20,%esi
f0103d62:	89 f8                	mov    %edi,%eax
f0103d64:	89 f2                	mov    %esi,%edx
f0103d66:	ee                   	out    %al,(%dx)
f0103d67:	b8 20 00 00 00       	mov    $0x20,%eax
f0103d6c:	89 da                	mov    %ebx,%edx
f0103d6e:	ee                   	out    %al,(%dx)
f0103d6f:	b8 04 00 00 00       	mov    $0x4,%eax
f0103d74:	ee                   	out    %al,(%dx)
f0103d75:	b8 03 00 00 00       	mov    $0x3,%eax
f0103d7a:	ee                   	out    %al,(%dx)
f0103d7b:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0103d80:	89 f8                	mov    %edi,%eax
f0103d82:	89 da                	mov    %ebx,%edx
f0103d84:	ee                   	out    %al,(%dx)
f0103d85:	b8 28 00 00 00       	mov    $0x28,%eax
f0103d8a:	89 ca                	mov    %ecx,%edx
f0103d8c:	ee                   	out    %al,(%dx)
f0103d8d:	b8 02 00 00 00       	mov    $0x2,%eax
f0103d92:	ee                   	out    %al,(%dx)
f0103d93:	b8 01 00 00 00       	mov    $0x1,%eax
f0103d98:	ee                   	out    %al,(%dx)
f0103d99:	bf 68 00 00 00       	mov    $0x68,%edi
f0103d9e:	89 f8                	mov    %edi,%eax
f0103da0:	89 f2                	mov    %esi,%edx
f0103da2:	ee                   	out    %al,(%dx)
f0103da3:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103da8:	89 c8                	mov    %ecx,%eax
f0103daa:	ee                   	out    %al,(%dx)
f0103dab:	89 f8                	mov    %edi,%eax
f0103dad:	89 da                	mov    %ebx,%edx
f0103daf:	ee                   	out    %al,(%dx)
f0103db0:	89 c8                	mov    %ecx,%eax
f0103db2:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103db3:	0f b7 05 a8 73 12 f0 	movzwl 0xf01273a8,%eax
f0103dba:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103dbe:	75 08                	jne    f0103dc8 <pic_init+0x99>
}
f0103dc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103dc3:	5b                   	pop    %ebx
f0103dc4:	5e                   	pop    %esi
f0103dc5:	5f                   	pop    %edi
f0103dc6:	5d                   	pop    %ebp
f0103dc7:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f0103dc8:	83 ec 0c             	sub    $0xc,%esp
f0103dcb:	0f b7 c0             	movzwl %ax,%eax
f0103dce:	50                   	push   %eax
f0103dcf:	e8 d9 fe ff ff       	call   f0103cad <irq_setmask_8259A>
f0103dd4:	83 c4 10             	add    $0x10,%esp
}
f0103dd7:	eb e7                	jmp    f0103dc0 <pic_init+0x91>

f0103dd9 <irq_eoi>:

void
irq_eoi(void)
{
f0103dd9:	f3 0f 1e fb          	endbr32 
f0103ddd:	b8 20 00 00 00       	mov    $0x20,%eax
f0103de2:	ba 20 00 00 00       	mov    $0x20,%edx
f0103de7:	ee                   	out    %al,(%dx)
f0103de8:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103ded:	ee                   	out    %al,(%dx)
	//   s: specific
	//   e: end-of-interrupt
	// xxx: specific interrupt line
	outb(IO_PIC1, 0x20);
	outb(IO_PIC2, 0x20);
}
f0103dee:	c3                   	ret    

f0103def <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103def:	f3 0f 1e fb          	endbr32 
f0103df3:	55                   	push   %ebp
f0103df4:	89 e5                	mov    %esp,%ebp
f0103df6:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103df9:	ff 75 08             	pushl  0x8(%ebp)
f0103dfc:	e8 c1 c9 ff ff       	call   f01007c2 <cputchar>
	*cnt++;
}
f0103e01:	83 c4 10             	add    $0x10,%esp
f0103e04:	c9                   	leave  
f0103e05:	c3                   	ret    

f0103e06 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103e06:	f3 0f 1e fb          	endbr32 
f0103e0a:	55                   	push   %ebp
f0103e0b:	89 e5                	mov    %esp,%ebp
f0103e0d:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103e10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103e17:	ff 75 0c             	pushl  0xc(%ebp)
f0103e1a:	ff 75 08             	pushl  0x8(%ebp)
f0103e1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103e20:	50                   	push   %eax
f0103e21:	68 ef 3d 10 f0       	push   $0xf0103def
f0103e26:	e8 97 18 00 00       	call   f01056c2 <vprintfmt>
	return cnt;
}
f0103e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103e2e:	c9                   	leave  
f0103e2f:	c3                   	ret    

f0103e30 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103e30:	f3 0f 1e fb          	endbr32 
f0103e34:	55                   	push   %ebp
f0103e35:	89 e5                	mov    %esp,%ebp
f0103e37:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103e3a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103e3d:	50                   	push   %eax
f0103e3e:	ff 75 08             	pushl  0x8(%ebp)
f0103e41:	e8 c0 ff ff ff       	call   f0103e06 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103e46:	c9                   	leave  
f0103e47:	c3                   	ret    

f0103e48 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103e48:	f3 0f 1e fb          	endbr32 
f0103e4c:	55                   	push   %ebp
f0103e4d:	89 e5                	mov    %esp,%ebp
f0103e4f:	57                   	push   %edi
f0103e50:	56                   	push   %esi
f0103e51:	53                   	push   %ebx
f0103e52:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = (uintptr_t)percpu_kstacks[thiscpu->cpu_id];
f0103e55:	e8 34 26 00 00       	call   f010648e <cpunum>
f0103e5a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e5d:	0f b6 98 20 00 2c f0 	movzbl -0xfd3ffe0(%eax),%ebx
f0103e64:	c1 e3 0f             	shl    $0xf,%ebx
f0103e67:	81 c3 00 10 2c f0    	add    $0xf02c1000,%ebx
f0103e6d:	e8 1c 26 00 00       	call   f010648e <cpunum>
f0103e72:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e75:	89 98 30 00 2c f0    	mov    %ebx,-0xfd3ffd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103e7b:	e8 0e 26 00 00       	call   f010648e <cpunum>
f0103e80:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e83:	66 c7 80 34 00 2c f0 	movw   $0x10,-0xfd3ffcc(%eax)
f0103e8a:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103e8c:	e8 fd 25 00 00       	call   f010648e <cpunum>
f0103e91:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e94:	66 c7 80 92 00 2c f0 	movw   $0x68,-0xfd3ff6e(%eax)
f0103e9b:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0103e9d:	e8 ec 25 00 00       	call   f010648e <cpunum>
f0103ea2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ea5:	0f b6 b0 20 00 2c f0 	movzbl -0xfd3ffe0(%eax),%esi
f0103eac:	83 c6 05             	add    $0x5,%esi
f0103eaf:	e8 da 25 00 00       	call   f010648e <cpunum>
f0103eb4:	89 c7                	mov    %eax,%edi
f0103eb6:	e8 d3 25 00 00       	call   f010648e <cpunum>
f0103ebb:	89 c3                	mov    %eax,%ebx
f0103ebd:	e8 cc 25 00 00       	call   f010648e <cpunum>
f0103ec2:	66 c7 04 f5 40 73 12 	movw   $0x67,-0xfed8cc0(,%esi,8)
f0103ec9:	f0 67 00 
f0103ecc:	6b ff 74             	imul   $0x74,%edi,%edi
f0103ecf:	81 c7 2c 00 2c f0    	add    $0xf02c002c,%edi
f0103ed5:	66 89 3c f5 42 73 12 	mov    %di,-0xfed8cbe(,%esi,8)
f0103edc:	f0 
f0103edd:	6b db 74             	imul   $0x74,%ebx,%ebx
f0103ee0:	81 c3 2c 00 2c f0    	add    $0xf02c002c,%ebx
f0103ee6:	c1 eb 10             	shr    $0x10,%ebx
f0103ee9:	88 1c f5 44 73 12 f0 	mov    %bl,-0xfed8cbc(,%esi,8)
f0103ef0:	c6 04 f5 45 73 12 f0 	movb   $0x99,-0xfed8cbb(,%esi,8)
f0103ef7:	99 
f0103ef8:	c6 04 f5 46 73 12 f0 	movb   $0x40,-0xfed8cba(,%esi,8)
f0103eff:	40 
f0103f00:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f03:	05 2c 00 2c f0       	add    $0xf02c002c,%eax
f0103f08:	c1 e8 18             	shr    $0x18,%eax
f0103f0b:	88 04 f5 47 73 12 f0 	mov    %al,-0xfed8cb9(,%esi,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id].sd_s = 0;
f0103f12:	e8 77 25 00 00       	call   f010648e <cpunum>
f0103f17:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f1a:	0f b6 80 20 00 2c f0 	movzbl -0xfd3ffe0(%eax),%eax
f0103f21:	80 24 c5 6d 73 12 f0 	andb   $0xef,-0xfed8c93(,%eax,8)
f0103f28:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (thiscpu->cpu_id<<3));
f0103f29:	e8 60 25 00 00       	call   f010648e <cpunum>
f0103f2e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f31:	0f b6 80 20 00 2c f0 	movzbl -0xfd3ffe0(%eax),%eax
f0103f38:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
	asm volatile("ltr %0" : : "r" (sel));
f0103f3f:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0103f42:	b8 ac 73 12 f0       	mov    $0xf01273ac,%eax
f0103f47:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103f4a:	83 c4 0c             	add    $0xc,%esp
f0103f4d:	5b                   	pop    %ebx
f0103f4e:	5e                   	pop    %esi
f0103f4f:	5f                   	pop    %edi
f0103f50:	5d                   	pop    %ebp
f0103f51:	c3                   	ret    

f0103f52 <trap_init>:
{
f0103f52:	f3 0f 1e fb          	endbr32 
f0103f56:	55                   	push   %ebp
f0103f57:	89 e5                	mov    %esp,%ebp
f0103f59:	83 ec 08             	sub    $0x8,%esp
	if ((uint32_t)kva < KERNBASE)
f0103f5c:	b8 40 73 12 f0       	mov    $0xf0127340,%eax
f0103f61:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103f66:	0f 86 f3 03 00 00    	jbe    f010435f <trap_init+0x40d>
	cprintf("gdt: %08x\n", PADDR(gdt));
f0103f6c:	83 ec 08             	sub    $0x8,%esp
f0103f6f:	68 40 73 12 00       	push   $0x127340
f0103f74:	68 4b 8b 10 f0       	push   $0xf0108b4b
f0103f79:	e8 b2 fe ff ff       	call   f0103e30 <cprintf>
f0103f7e:	83 c4 10             	add    $0x10,%esp
f0103f81:	b8 60 d2 2b f0       	mov    $0xf02bd260,%eax
f0103f86:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103f8b:	0f 86 e0 03 00 00    	jbe    f0104371 <trap_init+0x41f>
	cprintf("idt: %08x\n", PADDR(idt));
f0103f91:	83 ec 08             	sub    $0x8,%esp
f0103f94:	68 60 d2 2b 00       	push   $0x2bd260
f0103f99:	68 56 8b 10 f0       	push   $0xf0108b56
f0103f9e:	e8 8d fe ff ff       	call   f0103e30 <cprintf>
	SETGATE(idt[T_DIVIDE], 0, GD_KT, int_divide, 0);
f0103fa3:	b8 7a 49 10 f0       	mov    $0xf010497a,%eax
f0103fa8:	66 a3 60 d2 2b f0    	mov    %ax,0xf02bd260
f0103fae:	66 c7 05 62 d2 2b f0 	movw   $0x8,0xf02bd262
f0103fb5:	08 00 
f0103fb7:	c6 05 64 d2 2b f0 00 	movb   $0x0,0xf02bd264
f0103fbe:	c6 05 65 d2 2b f0 8e 	movb   $0x8e,0xf02bd265
f0103fc5:	c1 e8 10             	shr    $0x10,%eax
f0103fc8:	66 a3 66 d2 2b f0    	mov    %ax,0xf02bd266
	SETGATE(idt[T_DEBUG], 0, GD_KT, int_debug, 3);
f0103fce:	b8 80 49 10 f0       	mov    $0xf0104980,%eax
f0103fd3:	66 a3 68 d2 2b f0    	mov    %ax,0xf02bd268
f0103fd9:	66 c7 05 6a d2 2b f0 	movw   $0x8,0xf02bd26a
f0103fe0:	08 00 
f0103fe2:	c6 05 6c d2 2b f0 00 	movb   $0x0,0xf02bd26c
f0103fe9:	c6 05 6d d2 2b f0 ee 	movb   $0xee,0xf02bd26d
f0103ff0:	c1 e8 10             	shr    $0x10,%eax
f0103ff3:	66 a3 6e d2 2b f0    	mov    %ax,0xf02bd26e
	SETGATE(idt[T_NMI], 0, GD_KT,int_nmi, 0);
f0103ff9:	b8 86 49 10 f0       	mov    $0xf0104986,%eax
f0103ffe:	66 a3 70 d2 2b f0    	mov    %ax,0xf02bd270
f0104004:	66 c7 05 72 d2 2b f0 	movw   $0x8,0xf02bd272
f010400b:	08 00 
f010400d:	c6 05 74 d2 2b f0 00 	movb   $0x0,0xf02bd274
f0104014:	c6 05 75 d2 2b f0 8e 	movb   $0x8e,0xf02bd275
f010401b:	c1 e8 10             	shr    $0x10,%eax
f010401e:	66 a3 76 d2 2b f0    	mov    %ax,0xf02bd276
	SETGATE(idt[T_BRKPT], 0, GD_KT, int_brkpt, 3); 
f0104024:	b8 8c 49 10 f0       	mov    $0xf010498c,%eax
f0104029:	66 a3 78 d2 2b f0    	mov    %ax,0xf02bd278
f010402f:	66 c7 05 7a d2 2b f0 	movw   $0x8,0xf02bd27a
f0104036:	08 00 
f0104038:	c6 05 7c d2 2b f0 00 	movb   $0x0,0xf02bd27c
f010403f:	c6 05 7d d2 2b f0 ee 	movb   $0xee,0xf02bd27d
f0104046:	c1 e8 10             	shr    $0x10,%eax
f0104049:	66 a3 7e d2 2b f0    	mov    %ax,0xf02bd27e
	SETGATE(idt[T_OFLOW], 0, GD_KT, int_oflow, 0);
f010404f:	b8 92 49 10 f0       	mov    $0xf0104992,%eax
f0104054:	66 a3 80 d2 2b f0    	mov    %ax,0xf02bd280
f010405a:	66 c7 05 82 d2 2b f0 	movw   $0x8,0xf02bd282
f0104061:	08 00 
f0104063:	c6 05 84 d2 2b f0 00 	movb   $0x0,0xf02bd284
f010406a:	c6 05 85 d2 2b f0 8e 	movb   $0x8e,0xf02bd285
f0104071:	c1 e8 10             	shr    $0x10,%eax
f0104074:	66 a3 86 d2 2b f0    	mov    %ax,0xf02bd286
	SETGATE(idt[T_BOUND], 0, GD_KT, int_bound, 0);
f010407a:	b8 98 49 10 f0       	mov    $0xf0104998,%eax
f010407f:	66 a3 88 d2 2b f0    	mov    %ax,0xf02bd288
f0104085:	66 c7 05 8a d2 2b f0 	movw   $0x8,0xf02bd28a
f010408c:	08 00 
f010408e:	c6 05 8c d2 2b f0 00 	movb   $0x0,0xf02bd28c
f0104095:	c6 05 8d d2 2b f0 8e 	movb   $0x8e,0xf02bd28d
f010409c:	c1 e8 10             	shr    $0x10,%eax
f010409f:	66 a3 8e d2 2b f0    	mov    %ax,0xf02bd28e
	SETGATE(idt[T_ILLOP], 0, GD_KT, int_illop, 0);
f01040a5:	b8 9e 49 10 f0       	mov    $0xf010499e,%eax
f01040aa:	66 a3 90 d2 2b f0    	mov    %ax,0xf02bd290
f01040b0:	66 c7 05 92 d2 2b f0 	movw   $0x8,0xf02bd292
f01040b7:	08 00 
f01040b9:	c6 05 94 d2 2b f0 00 	movb   $0x0,0xf02bd294
f01040c0:	c6 05 95 d2 2b f0 8e 	movb   $0x8e,0xf02bd295
f01040c7:	c1 e8 10             	shr    $0x10,%eax
f01040ca:	66 a3 96 d2 2b f0    	mov    %ax,0xf02bd296
	SETGATE(idt[T_DEVICE], 0, GD_KT, int_device, 0);
f01040d0:	b8 a4 49 10 f0       	mov    $0xf01049a4,%eax
f01040d5:	66 a3 98 d2 2b f0    	mov    %ax,0xf02bd298
f01040db:	66 c7 05 9a d2 2b f0 	movw   $0x8,0xf02bd29a
f01040e2:	08 00 
f01040e4:	c6 05 9c d2 2b f0 00 	movb   $0x0,0xf02bd29c
f01040eb:	c6 05 9d d2 2b f0 8e 	movb   $0x8e,0xf02bd29d
f01040f2:	c1 e8 10             	shr    $0x10,%eax
f01040f5:	66 a3 9e d2 2b f0    	mov    %ax,0xf02bd29e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, int_dblflt, 0);
f01040fb:	b8 aa 49 10 f0       	mov    $0xf01049aa,%eax
f0104100:	66 a3 a0 d2 2b f0    	mov    %ax,0xf02bd2a0
f0104106:	66 c7 05 a2 d2 2b f0 	movw   $0x8,0xf02bd2a2
f010410d:	08 00 
f010410f:	c6 05 a4 d2 2b f0 00 	movb   $0x0,0xf02bd2a4
f0104116:	c6 05 a5 d2 2b f0 8e 	movb   $0x8e,0xf02bd2a5
f010411d:	c1 e8 10             	shr    $0x10,%eax
f0104120:	66 a3 a6 d2 2b f0    	mov    %ax,0xf02bd2a6
	SETGATE(idt[T_TSS], 0, GD_KT, int_tss, 0);
f0104126:	b8 ae 49 10 f0       	mov    $0xf01049ae,%eax
f010412b:	66 a3 b0 d2 2b f0    	mov    %ax,0xf02bd2b0
f0104131:	66 c7 05 b2 d2 2b f0 	movw   $0x8,0xf02bd2b2
f0104138:	08 00 
f010413a:	c6 05 b4 d2 2b f0 00 	movb   $0x0,0xf02bd2b4
f0104141:	c6 05 b5 d2 2b f0 8e 	movb   $0x8e,0xf02bd2b5
f0104148:	c1 e8 10             	shr    $0x10,%eax
f010414b:	66 a3 b6 d2 2b f0    	mov    %ax,0xf02bd2b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, int_segnp, 0);
f0104151:	b8 b2 49 10 f0       	mov    $0xf01049b2,%eax
f0104156:	66 a3 b8 d2 2b f0    	mov    %ax,0xf02bd2b8
f010415c:	66 c7 05 ba d2 2b f0 	movw   $0x8,0xf02bd2ba
f0104163:	08 00 
f0104165:	c6 05 bc d2 2b f0 00 	movb   $0x0,0xf02bd2bc
f010416c:	c6 05 bd d2 2b f0 8e 	movb   $0x8e,0xf02bd2bd
f0104173:	c1 e8 10             	shr    $0x10,%eax
f0104176:	66 a3 be d2 2b f0    	mov    %ax,0xf02bd2be
	SETGATE(idt[T_STACK], 0, GD_KT, int_stack, 0);
f010417c:	b8 b6 49 10 f0       	mov    $0xf01049b6,%eax
f0104181:	66 a3 c0 d2 2b f0    	mov    %ax,0xf02bd2c0
f0104187:	66 c7 05 c2 d2 2b f0 	movw   $0x8,0xf02bd2c2
f010418e:	08 00 
f0104190:	c6 05 c4 d2 2b f0 00 	movb   $0x0,0xf02bd2c4
f0104197:	c6 05 c5 d2 2b f0 8e 	movb   $0x8e,0xf02bd2c5
f010419e:	c1 e8 10             	shr    $0x10,%eax
f01041a1:	66 a3 c6 d2 2b f0    	mov    %ax,0xf02bd2c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, int_gpflt, 0);
f01041a7:	b8 ba 49 10 f0       	mov    $0xf01049ba,%eax
f01041ac:	66 a3 c8 d2 2b f0    	mov    %ax,0xf02bd2c8
f01041b2:	66 c7 05 ca d2 2b f0 	movw   $0x8,0xf02bd2ca
f01041b9:	08 00 
f01041bb:	c6 05 cc d2 2b f0 00 	movb   $0x0,0xf02bd2cc
f01041c2:	c6 05 cd d2 2b f0 8e 	movb   $0x8e,0xf02bd2cd
f01041c9:	c1 e8 10             	shr    $0x10,%eax
f01041cc:	66 a3 ce d2 2b f0    	mov    %ax,0xf02bd2ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, int_pgflt, 0);
f01041d2:	b8 be 49 10 f0       	mov    $0xf01049be,%eax
f01041d7:	66 a3 d0 d2 2b f0    	mov    %ax,0xf02bd2d0
f01041dd:	66 c7 05 d2 d2 2b f0 	movw   $0x8,0xf02bd2d2
f01041e4:	08 00 
f01041e6:	c6 05 d4 d2 2b f0 00 	movb   $0x0,0xf02bd2d4
f01041ed:	c6 05 d5 d2 2b f0 8e 	movb   $0x8e,0xf02bd2d5
f01041f4:	c1 e8 10             	shr    $0x10,%eax
f01041f7:	66 a3 d6 d2 2b f0    	mov    %ax,0xf02bd2d6
	SETGATE(idt[T_FPERR], 0, GD_KT, int_fperr, 0);
f01041fd:	b8 c2 49 10 f0       	mov    $0xf01049c2,%eax
f0104202:	66 a3 e0 d2 2b f0    	mov    %ax,0xf02bd2e0
f0104208:	66 c7 05 e2 d2 2b f0 	movw   $0x8,0xf02bd2e2
f010420f:	08 00 
f0104211:	c6 05 e4 d2 2b f0 00 	movb   $0x0,0xf02bd2e4
f0104218:	c6 05 e5 d2 2b f0 8e 	movb   $0x8e,0xf02bd2e5
f010421f:	c1 e8 10             	shr    $0x10,%eax
f0104222:	66 a3 e6 d2 2b f0    	mov    %ax,0xf02bd2e6
	SETGATE(idt[T_SYSCALL], 0, GD_KT, int_syscall, 3);
f0104228:	b8 c8 49 10 f0       	mov    $0xf01049c8,%eax
f010422d:	66 a3 e0 d3 2b f0    	mov    %ax,0xf02bd3e0
f0104233:	66 c7 05 e2 d3 2b f0 	movw   $0x8,0xf02bd3e2
f010423a:	08 00 
f010423c:	c6 05 e4 d3 2b f0 00 	movb   $0x0,0xf02bd3e4
f0104243:	c6 05 e5 d3 2b f0 ee 	movb   $0xee,0xf02bd3e5
f010424a:	c1 e8 10             	shr    $0x10,%eax
f010424d:	66 a3 e6 d3 2b f0    	mov    %ax,0xf02bd3e6
	SETGATE(idt[IRQ_OFFSET+IRQ_TIMER], 0, GD_KT, int_timer, 0);
f0104253:	b8 ce 49 10 f0       	mov    $0xf01049ce,%eax
f0104258:	66 a3 60 d3 2b f0    	mov    %ax,0xf02bd360
f010425e:	66 c7 05 62 d3 2b f0 	movw   $0x8,0xf02bd362
f0104265:	08 00 
f0104267:	c6 05 64 d3 2b f0 00 	movb   $0x0,0xf02bd364
f010426e:	c6 05 65 d3 2b f0 8e 	movb   $0x8e,0xf02bd365
f0104275:	c1 e8 10             	shr    $0x10,%eax
f0104278:	66 a3 66 d3 2b f0    	mov    %ax,0xf02bd366
	SETGATE(idt[IRQ_OFFSET+IRQ_KBD], 0, GD_KT, int_kbd, 0);
f010427e:	b8 d4 49 10 f0       	mov    $0xf01049d4,%eax
f0104283:	66 a3 68 d3 2b f0    	mov    %ax,0xf02bd368
f0104289:	66 c7 05 6a d3 2b f0 	movw   $0x8,0xf02bd36a
f0104290:	08 00 
f0104292:	c6 05 6c d3 2b f0 00 	movb   $0x0,0xf02bd36c
f0104299:	c6 05 6d d3 2b f0 8e 	movb   $0x8e,0xf02bd36d
f01042a0:	c1 e8 10             	shr    $0x10,%eax
f01042a3:	66 a3 6e d3 2b f0    	mov    %ax,0xf02bd36e
	SETGATE(idt[IRQ_OFFSET+IRQ_SERIAL], 0, GD_KT, int_serial, 0);
f01042a9:	b8 da 49 10 f0       	mov    $0xf01049da,%eax
f01042ae:	66 a3 80 d3 2b f0    	mov    %ax,0xf02bd380
f01042b4:	66 c7 05 82 d3 2b f0 	movw   $0x8,0xf02bd382
f01042bb:	08 00 
f01042bd:	c6 05 84 d3 2b f0 00 	movb   $0x0,0xf02bd384
f01042c4:	c6 05 85 d3 2b f0 8e 	movb   $0x8e,0xf02bd385
f01042cb:	c1 e8 10             	shr    $0x10,%eax
f01042ce:	66 a3 86 d3 2b f0    	mov    %ax,0xf02bd386
	SETGATE(idt[IRQ_OFFSET+IRQ_SPURIOUS], 0, GD_KT, int_spurious, 0);
f01042d4:	b8 e0 49 10 f0       	mov    $0xf01049e0,%eax
f01042d9:	66 a3 98 d3 2b f0    	mov    %ax,0xf02bd398
f01042df:	66 c7 05 9a d3 2b f0 	movw   $0x8,0xf02bd39a
f01042e6:	08 00 
f01042e8:	c6 05 9c d3 2b f0 00 	movb   $0x0,0xf02bd39c
f01042ef:	c6 05 9d d3 2b f0 8e 	movb   $0x8e,0xf02bd39d
f01042f6:	c1 e8 10             	shr    $0x10,%eax
f01042f9:	66 a3 9e d3 2b f0    	mov    %ax,0xf02bd39e
	SETGATE(idt[IRQ_OFFSET+IRQ_IDE], 0, GD_KT, int_ide, 0);
f01042ff:	b8 e6 49 10 f0       	mov    $0xf01049e6,%eax
f0104304:	66 a3 d0 d3 2b f0    	mov    %ax,0xf02bd3d0
f010430a:	66 c7 05 d2 d3 2b f0 	movw   $0x8,0xf02bd3d2
f0104311:	08 00 
f0104313:	c6 05 d4 d3 2b f0 00 	movb   $0x0,0xf02bd3d4
f010431a:	c6 05 d5 d3 2b f0 8e 	movb   $0x8e,0xf02bd3d5
f0104321:	c1 e8 10             	shr    $0x10,%eax
f0104324:	66 a3 d6 d3 2b f0    	mov    %ax,0xf02bd3d6
	SETGATE(idt[IRQ_OFFSET+IRQ_ERROR], 0, GD_KT, int_error, 0);
f010432a:	b8 ec 49 10 f0       	mov    $0xf01049ec,%eax
f010432f:	66 a3 f8 d3 2b f0    	mov    %ax,0xf02bd3f8
f0104335:	66 c7 05 fa d3 2b f0 	movw   $0x8,0xf02bd3fa
f010433c:	08 00 
f010433e:	c6 05 fc d3 2b f0 00 	movb   $0x0,0xf02bd3fc
f0104345:	c6 05 fd d3 2b f0 8e 	movb   $0x8e,0xf02bd3fd
f010434c:	c1 e8 10             	shr    $0x10,%eax
f010434f:	66 a3 fe d3 2b f0    	mov    %ax,0xf02bd3fe
	trap_init_percpu();
f0104355:	e8 ee fa ff ff       	call   f0103e48 <trap_init_percpu>
}
f010435a:	83 c4 10             	add    $0x10,%esp
f010435d:	c9                   	leave  
f010435e:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010435f:	50                   	push   %eax
f0104360:	68 68 74 10 f0       	push   $0xf0107468
f0104365:	6a 4a                	push   $0x4a
f0104367:	68 3f 8b 10 f0       	push   $0xf0108b3f
f010436c:	e8 cf bc ff ff       	call   f0100040 <_panic>
f0104371:	50                   	push   %eax
f0104372:	68 68 74 10 f0       	push   $0xf0107468
f0104377:	6a 4b                	push   $0x4b
f0104379:	68 3f 8b 10 f0       	push   $0xf0108b3f
f010437e:	e8 bd bc ff ff       	call   f0100040 <_panic>

f0104383 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104383:	f3 0f 1e fb          	endbr32 
f0104387:	55                   	push   %ebp
f0104388:	89 e5                	mov    %esp,%ebp
f010438a:	53                   	push   %ebx
f010438b:	83 ec 0c             	sub    $0xc,%esp
f010438e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104391:	ff 33                	pushl  (%ebx)
f0104393:	68 61 8b 10 f0       	push   $0xf0108b61
f0104398:	e8 93 fa ff ff       	call   f0103e30 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010439d:	83 c4 08             	add    $0x8,%esp
f01043a0:	ff 73 04             	pushl  0x4(%ebx)
f01043a3:	68 70 8b 10 f0       	push   $0xf0108b70
f01043a8:	e8 83 fa ff ff       	call   f0103e30 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01043ad:	83 c4 08             	add    $0x8,%esp
f01043b0:	ff 73 08             	pushl  0x8(%ebx)
f01043b3:	68 7f 8b 10 f0       	push   $0xf0108b7f
f01043b8:	e8 73 fa ff ff       	call   f0103e30 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01043bd:	83 c4 08             	add    $0x8,%esp
f01043c0:	ff 73 0c             	pushl  0xc(%ebx)
f01043c3:	68 8e 8b 10 f0       	push   $0xf0108b8e
f01043c8:	e8 63 fa ff ff       	call   f0103e30 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01043cd:	83 c4 08             	add    $0x8,%esp
f01043d0:	ff 73 10             	pushl  0x10(%ebx)
f01043d3:	68 9d 8b 10 f0       	push   $0xf0108b9d
f01043d8:	e8 53 fa ff ff       	call   f0103e30 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01043dd:	83 c4 08             	add    $0x8,%esp
f01043e0:	ff 73 14             	pushl  0x14(%ebx)
f01043e3:	68 ac 8b 10 f0       	push   $0xf0108bac
f01043e8:	e8 43 fa ff ff       	call   f0103e30 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01043ed:	83 c4 08             	add    $0x8,%esp
f01043f0:	ff 73 18             	pushl  0x18(%ebx)
f01043f3:	68 bb 8b 10 f0       	push   $0xf0108bbb
f01043f8:	e8 33 fa ff ff       	call   f0103e30 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01043fd:	83 c4 08             	add    $0x8,%esp
f0104400:	ff 73 1c             	pushl  0x1c(%ebx)
f0104403:	68 ca 8b 10 f0       	push   $0xf0108bca
f0104408:	e8 23 fa ff ff       	call   f0103e30 <cprintf>
}
f010440d:	83 c4 10             	add    $0x10,%esp
f0104410:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104413:	c9                   	leave  
f0104414:	c3                   	ret    

f0104415 <print_trapframe>:
{
f0104415:	f3 0f 1e fb          	endbr32 
f0104419:	55                   	push   %ebp
f010441a:	89 e5                	mov    %esp,%ebp
f010441c:	56                   	push   %esi
f010441d:	53                   	push   %ebx
f010441e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104421:	e8 68 20 00 00       	call   f010648e <cpunum>
f0104426:	83 ec 04             	sub    $0x4,%esp
f0104429:	50                   	push   %eax
f010442a:	53                   	push   %ebx
f010442b:	68 2e 8c 10 f0       	push   $0xf0108c2e
f0104430:	e8 fb f9 ff ff       	call   f0103e30 <cprintf>
	print_regs(&tf->tf_regs);
f0104435:	89 1c 24             	mov    %ebx,(%esp)
f0104438:	e8 46 ff ff ff       	call   f0104383 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010443d:	83 c4 08             	add    $0x8,%esp
f0104440:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104444:	50                   	push   %eax
f0104445:	68 4c 8c 10 f0       	push   $0xf0108c4c
f010444a:	e8 e1 f9 ff ff       	call   f0103e30 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010444f:	83 c4 08             	add    $0x8,%esp
f0104452:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104456:	50                   	push   %eax
f0104457:	68 5f 8c 10 f0       	push   $0xf0108c5f
f010445c:	e8 cf f9 ff ff       	call   f0103e30 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104461:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0104464:	83 c4 10             	add    $0x10,%esp
f0104467:	83 f8 13             	cmp    $0x13,%eax
f010446a:	0f 86 da 00 00 00    	jbe    f010454a <print_trapframe+0x135>
		return "System call";
f0104470:	ba d9 8b 10 f0       	mov    $0xf0108bd9,%edx
	if (trapno == T_SYSCALL)
f0104475:	83 f8 30             	cmp    $0x30,%eax
f0104478:	74 13                	je     f010448d <print_trapframe+0x78>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f010447a:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f010447d:	83 fa 0f             	cmp    $0xf,%edx
f0104480:	ba e5 8b 10 f0       	mov    $0xf0108be5,%edx
f0104485:	b9 f4 8b 10 f0       	mov    $0xf0108bf4,%ecx
f010448a:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010448d:	83 ec 04             	sub    $0x4,%esp
f0104490:	52                   	push   %edx
f0104491:	50                   	push   %eax
f0104492:	68 72 8c 10 f0       	push   $0xf0108c72
f0104497:	e8 94 f9 ff ff       	call   f0103e30 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010449c:	83 c4 10             	add    $0x10,%esp
f010449f:	39 1d 60 da 2b f0    	cmp    %ebx,0xf02bda60
f01044a5:	0f 84 ab 00 00 00    	je     f0104556 <print_trapframe+0x141>
	cprintf("  err  0x%08x", tf->tf_err);
f01044ab:	83 ec 08             	sub    $0x8,%esp
f01044ae:	ff 73 2c             	pushl  0x2c(%ebx)
f01044b1:	68 93 8c 10 f0       	push   $0xf0108c93
f01044b6:	e8 75 f9 ff ff       	call   f0103e30 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f01044bb:	83 c4 10             	add    $0x10,%esp
f01044be:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01044c2:	0f 85 b1 00 00 00    	jne    f0104579 <print_trapframe+0x164>
			tf->tf_err & 1 ? "protection" : "not-present");
f01044c8:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f01044cb:	a8 01                	test   $0x1,%al
f01044cd:	b9 07 8c 10 f0       	mov    $0xf0108c07,%ecx
f01044d2:	ba 12 8c 10 f0       	mov    $0xf0108c12,%edx
f01044d7:	0f 44 ca             	cmove  %edx,%ecx
f01044da:	a8 02                	test   $0x2,%al
f01044dc:	be 1e 8c 10 f0       	mov    $0xf0108c1e,%esi
f01044e1:	ba 24 8c 10 f0       	mov    $0xf0108c24,%edx
f01044e6:	0f 45 d6             	cmovne %esi,%edx
f01044e9:	a8 04                	test   $0x4,%al
f01044eb:	b8 29 8c 10 f0       	mov    $0xf0108c29,%eax
f01044f0:	be 6a 8d 10 f0       	mov    $0xf0108d6a,%esi
f01044f5:	0f 44 c6             	cmove  %esi,%eax
f01044f8:	51                   	push   %ecx
f01044f9:	52                   	push   %edx
f01044fa:	50                   	push   %eax
f01044fb:	68 a1 8c 10 f0       	push   $0xf0108ca1
f0104500:	e8 2b f9 ff ff       	call   f0103e30 <cprintf>
f0104505:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104508:	83 ec 08             	sub    $0x8,%esp
f010450b:	ff 73 30             	pushl  0x30(%ebx)
f010450e:	68 b0 8c 10 f0       	push   $0xf0108cb0
f0104513:	e8 18 f9 ff ff       	call   f0103e30 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104518:	83 c4 08             	add    $0x8,%esp
f010451b:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010451f:	50                   	push   %eax
f0104520:	68 bf 8c 10 f0       	push   $0xf0108cbf
f0104525:	e8 06 f9 ff ff       	call   f0103e30 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010452a:	83 c4 08             	add    $0x8,%esp
f010452d:	ff 73 38             	pushl  0x38(%ebx)
f0104530:	68 d2 8c 10 f0       	push   $0xf0108cd2
f0104535:	e8 f6 f8 ff ff       	call   f0103e30 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010453a:	83 c4 10             	add    $0x10,%esp
f010453d:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104541:	75 4b                	jne    f010458e <print_trapframe+0x179>
}
f0104543:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104546:	5b                   	pop    %ebx
f0104547:	5e                   	pop    %esi
f0104548:	5d                   	pop    %ebp
f0104549:	c3                   	ret    
		return excnames[trapno];
f010454a:	8b 14 85 c0 8e 10 f0 	mov    -0xfef7140(,%eax,4),%edx
f0104551:	e9 37 ff ff ff       	jmp    f010448d <print_trapframe+0x78>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104556:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010455a:	0f 85 4b ff ff ff    	jne    f01044ab <print_trapframe+0x96>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0104560:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104563:	83 ec 08             	sub    $0x8,%esp
f0104566:	50                   	push   %eax
f0104567:	68 84 8c 10 f0       	push   $0xf0108c84
f010456c:	e8 bf f8 ff ff       	call   f0103e30 <cprintf>
f0104571:	83 c4 10             	add    $0x10,%esp
f0104574:	e9 32 ff ff ff       	jmp    f01044ab <print_trapframe+0x96>
		cprintf("\n");
f0104579:	83 ec 0c             	sub    $0xc,%esp
f010457c:	68 08 8a 10 f0       	push   $0xf0108a08
f0104581:	e8 aa f8 ff ff       	call   f0103e30 <cprintf>
f0104586:	83 c4 10             	add    $0x10,%esp
f0104589:	e9 7a ff ff ff       	jmp    f0104508 <print_trapframe+0xf3>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010458e:	83 ec 08             	sub    $0x8,%esp
f0104591:	ff 73 3c             	pushl  0x3c(%ebx)
f0104594:	68 e1 8c 10 f0       	push   $0xf0108ce1
f0104599:	e8 92 f8 ff ff       	call   f0103e30 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010459e:	83 c4 08             	add    $0x8,%esp
f01045a1:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01045a5:	50                   	push   %eax
f01045a6:	68 f0 8c 10 f0       	push   $0xf0108cf0
f01045ab:	e8 80 f8 ff ff       	call   f0103e30 <cprintf>
f01045b0:	83 c4 10             	add    $0x10,%esp
}
f01045b3:	eb 8e                	jmp    f0104543 <print_trapframe+0x12e>

f01045b5 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01045b5:	f3 0f 1e fb          	endbr32 
f01045b9:	55                   	push   %ebp
f01045ba:	89 e5                	mov    %esp,%ebp
f01045bc:	57                   	push   %edi
f01045bd:	56                   	push   %esi
f01045be:	53                   	push   %ebx
f01045bf:	83 ec 0c             	sub    $0xc,%esp
f01045c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01045c5:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();
	// cprintf("[%08x] fault_va = %08x\n", curenv->env_id, fault_va);
	// Handle kernel-mode page faults.
	// LAB 3: Your code here.
	// 检查code segment register的lower 2 bits 的privilege level
	if ((tf->tf_cs & 3) == 0){
f01045c8:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01045cc:	74 5d                	je     f010462b <page_fault_handler+0x76>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// 如果已经给curenv设置了env_pgfault_upcall的话 
	if (curenv->env_pgfault_upcall){
f01045ce:	e8 bb 1e 00 00       	call   f010648e <cpunum>
f01045d3:	6b c0 74             	imul   $0x74,%eax,%eax
f01045d6:	8b 80 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%eax
f01045dc:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f01045e0:	75 60                	jne    f0104642 <page_fault_handler+0x8d>
		curenv->env_tf.tf_esp = (uintptr_t)utf;
		env_run(curenv);

	}else{
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01045e2:	8b 7b 30             	mov    0x30(%ebx),%edi
			curenv->env_id, fault_va, tf->tf_eip);
f01045e5:	e8 a4 1e 00 00       	call   f010648e <cpunum>
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01045ea:	57                   	push   %edi
f01045eb:	56                   	push   %esi
			curenv->env_id, fault_va, tf->tf_eip);
f01045ec:	6b c0 74             	imul   $0x74,%eax,%eax
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01045ef:	8b 80 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%eax
f01045f5:	ff 70 48             	pushl  0x48(%eax)
f01045f8:	68 1c 8b 10 f0       	push   $0xf0108b1c
f01045fd:	e8 2e f8 ff ff       	call   f0103e30 <cprintf>
		print_trapframe(tf);
f0104602:	89 1c 24             	mov    %ebx,(%esp)
f0104605:	e8 0b fe ff ff       	call   f0104415 <print_trapframe>
		env_destroy(curenv);
f010460a:	e8 7f 1e 00 00       	call   f010648e <cpunum>
f010460f:	83 c4 04             	add    $0x4,%esp
f0104612:	6b c0 74             	imul   $0x74,%eax,%eax
f0104615:	ff b0 28 00 2c f0    	pushl  -0xfd3ffd8(%eax)
f010461b:	e8 ff f4 ff ff       	call   f0103b1f <env_destroy>
	}
}
f0104620:	83 c4 10             	add    $0x10,%esp
f0104623:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104626:	5b                   	pop    %ebx
f0104627:	5e                   	pop    %esi
f0104628:	5f                   	pop    %edi
f0104629:	5d                   	pop    %ebp
f010462a:	c3                   	ret    
		panic("kernel-mode page fault\n");
f010462b:	83 ec 04             	sub    $0x4,%esp
f010462e:	68 03 8d 10 f0       	push   $0xf0108d03
f0104633:	68 88 01 00 00       	push   $0x188
f0104638:	68 3f 8b 10 f0       	push   $0xf0108b3f
f010463d:	e8 fe b9 ff ff       	call   f0100040 <_panic>
		if (tf->tf_esp<UXSTACKTOP && tf->tf_esp>=UXSTACKTOP-PGSIZE){
f0104642:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104645:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			utf = (struct UTrapframe *)(UXSTACKTOP-sizeof(struct UTrapframe));
f010464b:	bf cc ff bf ee       	mov    $0xeebfffcc,%edi
		if (tf->tf_esp<UXSTACKTOP && tf->tf_esp>=UXSTACKTOP-PGSIZE){
f0104650:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104656:	77 05                	ja     f010465d <page_fault_handler+0xa8>
			utf =(struct UTrapframe *)(tf->tf_esp-sizeof(struct UTrapframe)-4);
f0104658:	83 e8 38             	sub    $0x38,%eax
f010465b:	89 c7                	mov    %eax,%edi
		user_mem_assert(curenv, (void*)utf, sizeof(struct UTrapframe), PTE_W);
f010465d:	e8 2c 1e 00 00       	call   f010648e <cpunum>
f0104662:	6a 02                	push   $0x2
f0104664:	6a 34                	push   $0x34
f0104666:	57                   	push   %edi
f0104667:	6b c0 74             	imul   $0x74,%eax,%eax
f010466a:	ff b0 28 00 2c f0    	pushl  -0xfd3ffd8(%eax)
f0104670:	e8 5f ee ff ff       	call   f01034d4 <user_mem_assert>
		utf->utf_fault_va = fault_va;
f0104675:	89 fa                	mov    %edi,%edx
f0104677:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_err;
f0104679:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010467c:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f010467f:	8d 7f 08             	lea    0x8(%edi),%edi
f0104682:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104687:	89 de                	mov    %ebx,%esi
f0104689:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f010468b:	8b 43 30             	mov    0x30(%ebx),%eax
f010468e:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f0104691:	8b 43 38             	mov    0x38(%ebx),%eax
f0104694:	89 d7                	mov    %edx,%edi
f0104696:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f0104699:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010469c:	89 42 30             	mov    %eax,0x30(%edx)
		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f010469f:	e8 ea 1d 00 00       	call   f010648e <cpunum>
f01046a4:	6b c0 74             	imul   $0x74,%eax,%eax
f01046a7:	8b 80 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%eax
f01046ad:	8b 58 64             	mov    0x64(%eax),%ebx
f01046b0:	e8 d9 1d 00 00       	call   f010648e <cpunum>
f01046b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01046b8:	8b 80 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%eax
f01046be:	89 58 30             	mov    %ebx,0x30(%eax)
		curenv->env_tf.tf_esp = (uintptr_t)utf;
f01046c1:	e8 c8 1d 00 00       	call   f010648e <cpunum>
f01046c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01046c9:	8b 80 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%eax
f01046cf:	89 78 3c             	mov    %edi,0x3c(%eax)
		env_run(curenv);
f01046d2:	e8 b7 1d 00 00       	call   f010648e <cpunum>
f01046d7:	83 c4 04             	add    $0x4,%esp
f01046da:	6b c0 74             	imul   $0x74,%eax,%eax
f01046dd:	ff b0 28 00 2c f0    	pushl  -0xfd3ffd8(%eax)
f01046e3:	e8 de f4 ff ff       	call   f0103bc6 <env_run>

f01046e8 <trap>:
{
f01046e8:	f3 0f 1e fb          	endbr32 
f01046ec:	55                   	push   %ebp
f01046ed:	89 e5                	mov    %esp,%ebp
f01046ef:	57                   	push   %edi
f01046f0:	56                   	push   %esi
f01046f1:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f01046f4:	fc                   	cld    
	if (panicstr)
f01046f5:	83 3d 0c f4 2b f0 00 	cmpl   $0x0,0xf02bf40c
f01046fc:	74 01                	je     f01046ff <trap+0x17>
		asm volatile("hlt");
f01046fe:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01046ff:	e8 8a 1d 00 00       	call   f010648e <cpunum>
f0104704:	6b d0 74             	imul   $0x74,%eax,%edx
f0104707:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f010470a:	b8 01 00 00 00       	mov    $0x1,%eax
f010470f:	f0 87 82 20 00 2c f0 	lock xchg %eax,-0xfd3ffe0(%edx)
f0104716:	83 f8 02             	cmp    $0x2,%eax
f0104719:	0f 84 c2 00 00 00    	je     f01047e1 <trap+0xf9>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f010471f:	9c                   	pushf  
f0104720:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF)); 
f0104721:	f6 c4 02             	test   $0x2,%ah
f0104724:	0f 85 cc 00 00 00    	jne    f01047f6 <trap+0x10e>
	if ((tf->tf_cs & 3) == 3) {
f010472a:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010472e:	83 e0 03             	and    $0x3,%eax
f0104731:	66 83 f8 03          	cmp    $0x3,%ax
f0104735:	0f 84 d4 00 00 00    	je     f010480f <trap+0x127>
	last_tf = tf;
f010473b:	89 35 60 da 2b f0    	mov    %esi,0xf02bda60
	if (tf->tf_trapno == T_PGFLT){
f0104741:	8b 46 28             	mov    0x28(%esi),%eax
f0104744:	83 f8 0e             	cmp    $0xe,%eax
f0104747:	0f 84 67 01 00 00    	je     f01048b4 <trap+0x1cc>
	if (tf->tf_trapno == T_BRKPT){
f010474d:	83 f8 03             	cmp    $0x3,%eax
f0104750:	0f 84 6f 01 00 00    	je     f01048c5 <trap+0x1dd>
	if (tf->tf_trapno == T_SYSCALL){
f0104756:	83 f8 30             	cmp    $0x30,%eax
f0104759:	0f 84 7f 01 00 00    	je     f01048de <trap+0x1f6>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f010475f:	83 f8 27             	cmp    $0x27,%eax
f0104762:	0f 84 9a 01 00 00    	je     f0104902 <trap+0x21a>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER){
f0104768:	83 f8 20             	cmp    $0x20,%eax
f010476b:	0f 84 ae 01 00 00    	je     f010491f <trap+0x237>
	if (tf->tf_trapno== IRQ_OFFSET+IRQ_KBD){
f0104771:	83 f8 21             	cmp    $0x21,%eax
f0104774:	0f 84 b4 01 00 00    	je     f010492e <trap+0x246>
	if (tf->tf_trapno == IRQ_OFFSET+IRQ_SERIAL){
f010477a:	83 f8 24             	cmp    $0x24,%eax
f010477d:	0f 84 ba 01 00 00    	je     f010493d <trap+0x255>
	print_trapframe(tf);
f0104783:	83 ec 0c             	sub    $0xc,%esp
f0104786:	56                   	push   %esi
f0104787:	e8 89 fc ff ff       	call   f0104415 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010478c:	83 c4 10             	add    $0x10,%esp
f010478f:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104794:	0f 84 b2 01 00 00    	je     f010494c <trap+0x264>
		env_destroy(curenv);
f010479a:	e8 ef 1c 00 00       	call   f010648e <cpunum>
f010479f:	83 ec 0c             	sub    $0xc,%esp
f01047a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01047a5:	ff b0 28 00 2c f0    	pushl  -0xfd3ffd8(%eax)
f01047ab:	e8 6f f3 ff ff       	call   f0103b1f <env_destroy>
		return;
f01047b0:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING){
f01047b3:	e8 d6 1c 00 00       	call   f010648e <cpunum>
f01047b8:	6b c0 74             	imul   $0x74,%eax,%eax
f01047bb:	83 b8 28 00 2c f0 00 	cmpl   $0x0,-0xfd3ffd8(%eax)
f01047c2:	74 18                	je     f01047dc <trap+0xf4>
f01047c4:	e8 c5 1c 00 00       	call   f010648e <cpunum>
f01047c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01047cc:	8b 80 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%eax
f01047d2:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01047d6:	0f 84 87 01 00 00    	je     f0104963 <trap+0x27b>
		sched_yield();
f01047dc:	e8 f1 02 00 00       	call   f0104ad2 <sched_yield>
	spin_lock(&kernel_lock);
f01047e1:	83 ec 0c             	sub    $0xc,%esp
f01047e4:	68 c0 73 12 f0       	push   $0xf01273c0
f01047e9:	e8 28 1f 00 00       	call   f0106716 <spin_lock>
}
f01047ee:	83 c4 10             	add    $0x10,%esp
f01047f1:	e9 29 ff ff ff       	jmp    f010471f <trap+0x37>
	assert(!(read_eflags() & FL_IF)); 
f01047f6:	68 1b 8d 10 f0       	push   $0xf0108d1b
f01047fb:	68 33 87 10 f0       	push   $0xf0108733
f0104800:	68 4d 01 00 00       	push   $0x14d
f0104805:	68 3f 8b 10 f0       	push   $0xf0108b3f
f010480a:	e8 31 b8 ff ff       	call   f0100040 <_panic>
	spin_lock(&kernel_lock);
f010480f:	83 ec 0c             	sub    $0xc,%esp
f0104812:	68 c0 73 12 f0       	push   $0xf01273c0
f0104817:	e8 fa 1e 00 00       	call   f0106716 <spin_lock>
		assert(curenv);
f010481c:	e8 6d 1c 00 00       	call   f010648e <cpunum>
f0104821:	6b c0 74             	imul   $0x74,%eax,%eax
f0104824:	83 c4 10             	add    $0x10,%esp
f0104827:	83 b8 28 00 2c f0 00 	cmpl   $0x0,-0xfd3ffd8(%eax)
f010482e:	74 3e                	je     f010486e <trap+0x186>
		if (curenv->env_status == ENV_DYING) {
f0104830:	e8 59 1c 00 00       	call   f010648e <cpunum>
f0104835:	6b c0 74             	imul   $0x74,%eax,%eax
f0104838:	8b 80 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%eax
f010483e:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104842:	74 43                	je     f0104887 <trap+0x19f>
		curenv->env_tf = *tf;
f0104844:	e8 45 1c 00 00       	call   f010648e <cpunum>
f0104849:	6b c0 74             	imul   $0x74,%eax,%eax
f010484c:	8b 80 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%eax
f0104852:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104857:	89 c7                	mov    %eax,%edi
f0104859:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f010485b:	e8 2e 1c 00 00       	call   f010648e <cpunum>
f0104860:	6b c0 74             	imul   $0x74,%eax,%eax
f0104863:	8b b0 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%esi
f0104869:	e9 cd fe ff ff       	jmp    f010473b <trap+0x53>
		assert(curenv);
f010486e:	68 34 8d 10 f0       	push   $0xf0108d34
f0104873:	68 33 87 10 f0       	push   $0xf0108733
f0104878:	68 56 01 00 00       	push   $0x156
f010487d:	68 3f 8b 10 f0       	push   $0xf0108b3f
f0104882:	e8 b9 b7 ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f0104887:	e8 02 1c 00 00       	call   f010648e <cpunum>
f010488c:	83 ec 0c             	sub    $0xc,%esp
f010488f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104892:	ff b0 28 00 2c f0    	pushl  -0xfd3ffd8(%eax)
f0104898:	e8 d4 f0 ff ff       	call   f0103971 <env_free>
			curenv = NULL;
f010489d:	e8 ec 1b 00 00       	call   f010648e <cpunum>
f01048a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01048a5:	c7 80 28 00 2c f0 00 	movl   $0x0,-0xfd3ffd8(%eax)
f01048ac:	00 00 00 
			sched_yield();
f01048af:	e8 1e 02 00 00       	call   f0104ad2 <sched_yield>
		page_fault_handler(tf);
f01048b4:	83 ec 0c             	sub    $0xc,%esp
f01048b7:	56                   	push   %esi
f01048b8:	e8 f8 fc ff ff       	call   f01045b5 <page_fault_handler>
		return;
f01048bd:	83 c4 10             	add    $0x10,%esp
f01048c0:	e9 ee fe ff ff       	jmp    f01047b3 <trap+0xcb>
		print_trapframe(tf);
f01048c5:	83 ec 0c             	sub    $0xc,%esp
f01048c8:	56                   	push   %esi
f01048c9:	e8 47 fb ff ff       	call   f0104415 <print_trapframe>
		monitor(tf);
f01048ce:	89 34 24             	mov    %esi,(%esp)
f01048d1:	e8 3c c4 ff ff       	call   f0100d12 <monitor>
		return;
f01048d6:	83 c4 10             	add    $0x10,%esp
f01048d9:	e9 d5 fe ff ff       	jmp    f01047b3 <trap+0xcb>
			syscall(tf->tf_regs.reg_eax,
f01048de:	83 ec 08             	sub    $0x8,%esp
f01048e1:	ff 76 04             	pushl  0x4(%esi)
f01048e4:	ff 36                	pushl  (%esi)
f01048e6:	ff 76 10             	pushl  0x10(%esi)
f01048e9:	ff 76 18             	pushl  0x18(%esi)
f01048ec:	ff 76 14             	pushl  0x14(%esi)
f01048ef:	ff 76 1c             	pushl  0x1c(%esi)
f01048f2:	e8 92 02 00 00       	call   f0104b89 <syscall>
		tf->tf_regs.reg_eax = 
f01048f7:	89 46 1c             	mov    %eax,0x1c(%esi)
		return;
f01048fa:	83 c4 20             	add    $0x20,%esp
f01048fd:	e9 b1 fe ff ff       	jmp    f01047b3 <trap+0xcb>
		cprintf("Spurious interrupt on irq 7\n");
f0104902:	83 ec 0c             	sub    $0xc,%esp
f0104905:	68 3b 8d 10 f0       	push   $0xf0108d3b
f010490a:	e8 21 f5 ff ff       	call   f0103e30 <cprintf>
		print_trapframe(tf);
f010490f:	89 34 24             	mov    %esi,(%esp)
f0104912:	e8 fe fa ff ff       	call   f0104415 <print_trapframe>
		return;
f0104917:	83 c4 10             	add    $0x10,%esp
f010491a:	e9 94 fe ff ff       	jmp    f01047b3 <trap+0xcb>
		lapic_eoi();
f010491f:	e8 b9 1c 00 00       	call   f01065dd <lapic_eoi>
		time_tick();
f0104924:	e8 45 28 00 00       	call   f010716e <time_tick>
		sched_yield();
f0104929:	e8 a4 01 00 00       	call   f0104ad2 <sched_yield>
		lapic_eoi();
f010492e:	e8 aa 1c 00 00       	call   f01065dd <lapic_eoi>
		kbd_intr();
f0104933:	e8 de bc ff ff       	call   f0100616 <kbd_intr>
		return;
f0104938:	e9 76 fe ff ff       	jmp    f01047b3 <trap+0xcb>
		lapic_eoi();
f010493d:	e8 9b 1c 00 00       	call   f01065dd <lapic_eoi>
		serial_intr();
f0104942:	e8 af bc ff ff       	call   f01005f6 <serial_intr>
		return;
f0104947:	e9 67 fe ff ff       	jmp    f01047b3 <trap+0xcb>
		panic("unhandled trap in kernel");
f010494c:	83 ec 04             	sub    $0x4,%esp
f010494f:	68 58 8d 10 f0       	push   $0xf0108d58
f0104954:	68 30 01 00 00       	push   $0x130
f0104959:	68 3f 8b 10 f0       	push   $0xf0108b3f
f010495e:	e8 dd b6 ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f0104963:	e8 26 1b 00 00       	call   f010648e <cpunum>
f0104968:	83 ec 0c             	sub    $0xc,%esp
f010496b:	6b c0 74             	imul   $0x74,%eax,%eax
f010496e:	ff b0 28 00 2c f0    	pushl  -0xfd3ffd8(%eax)
f0104974:	e8 4d f2 ff ff       	call   f0103bc6 <env_run>
f0104979:	90                   	nop

f010497a <int_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(int_divide, T_DIVIDE)
f010497a:	6a 00                	push   $0x0
f010497c:	6a 00                	push   $0x0
f010497e:	eb 72                	jmp    f01049f2 <_alltraps>

f0104980 <int_debug>:
TRAPHANDLER_NOEC(int_debug, T_DEBUG)
f0104980:	6a 00                	push   $0x0
f0104982:	6a 01                	push   $0x1
f0104984:	eb 6c                	jmp    f01049f2 <_alltraps>

f0104986 <int_nmi>:
TRAPHANDLER_NOEC(int_nmi, T_NMI)
f0104986:	6a 00                	push   $0x0
f0104988:	6a 02                	push   $0x2
f010498a:	eb 66                	jmp    f01049f2 <_alltraps>

f010498c <int_brkpt>:
TRAPHANDLER_NOEC(int_brkpt, T_BRKPT)
f010498c:	6a 00                	push   $0x0
f010498e:	6a 03                	push   $0x3
f0104990:	eb 60                	jmp    f01049f2 <_alltraps>

f0104992 <int_oflow>:
TRAPHANDLER_NOEC(int_oflow, T_OFLOW)
f0104992:	6a 00                	push   $0x0
f0104994:	6a 04                	push   $0x4
f0104996:	eb 5a                	jmp    f01049f2 <_alltraps>

f0104998 <int_bound>:
TRAPHANDLER_NOEC(int_bound, T_BOUND)
f0104998:	6a 00                	push   $0x0
f010499a:	6a 05                	push   $0x5
f010499c:	eb 54                	jmp    f01049f2 <_alltraps>

f010499e <int_illop>:
TRAPHANDLER_NOEC(int_illop, T_ILLOP)
f010499e:	6a 00                	push   $0x0
f01049a0:	6a 06                	push   $0x6
f01049a2:	eb 4e                	jmp    f01049f2 <_alltraps>

f01049a4 <int_device>:
TRAPHANDLER_NOEC(int_device, T_DEVICE)
f01049a4:	6a 00                	push   $0x0
f01049a6:	6a 07                	push   $0x7
f01049a8:	eb 48                	jmp    f01049f2 <_alltraps>

f01049aa <int_dblflt>:
TRAPHANDLER(int_dblflt, T_DBLFLT)
f01049aa:	6a 08                	push   $0x8
f01049ac:	eb 44                	jmp    f01049f2 <_alltraps>

f01049ae <int_tss>:
TRAPHANDLER(int_tss, T_TSS)
f01049ae:	6a 0a                	push   $0xa
f01049b0:	eb 40                	jmp    f01049f2 <_alltraps>

f01049b2 <int_segnp>:
TRAPHANDLER(int_segnp, T_SEGNP)
f01049b2:	6a 0b                	push   $0xb
f01049b4:	eb 3c                	jmp    f01049f2 <_alltraps>

f01049b6 <int_stack>:
TRAPHANDLER(int_stack, T_STACK)
f01049b6:	6a 0c                	push   $0xc
f01049b8:	eb 38                	jmp    f01049f2 <_alltraps>

f01049ba <int_gpflt>:
TRAPHANDLER(int_gpflt, T_GPFLT)
f01049ba:	6a 0d                	push   $0xd
f01049bc:	eb 34                	jmp    f01049f2 <_alltraps>

f01049be <int_pgflt>:
TRAPHANDLER(int_pgflt, T_PGFLT)
f01049be:	6a 0e                	push   $0xe
f01049c0:	eb 30                	jmp    f01049f2 <_alltraps>

f01049c2 <int_fperr>:
TRAPHANDLER_NOEC(int_fperr, T_FPERR)
f01049c2:	6a 00                	push   $0x0
f01049c4:	6a 10                	push   $0x10
f01049c6:	eb 2a                	jmp    f01049f2 <_alltraps>

f01049c8 <int_syscall>:

TRAPHANDLER_NOEC(int_syscall, T_SYSCALL)
f01049c8:	6a 00                	push   $0x0
f01049ca:	6a 30                	push   $0x30
f01049cc:	eb 24                	jmp    f01049f2 <_alltraps>

f01049ce <int_timer>:

TRAPHANDLER_NOEC(int_timer, IRQ_OFFSET+IRQ_TIMER)
f01049ce:	6a 00                	push   $0x0
f01049d0:	6a 20                	push   $0x20
f01049d2:	eb 1e                	jmp    f01049f2 <_alltraps>

f01049d4 <int_kbd>:
TRAPHANDLER_NOEC(int_kbd, IRQ_OFFSET+IRQ_KBD)
f01049d4:	6a 00                	push   $0x0
f01049d6:	6a 21                	push   $0x21
f01049d8:	eb 18                	jmp    f01049f2 <_alltraps>

f01049da <int_serial>:
TRAPHANDLER_NOEC(int_serial, IRQ_OFFSET+IRQ_SERIAL)
f01049da:	6a 00                	push   $0x0
f01049dc:	6a 24                	push   $0x24
f01049de:	eb 12                	jmp    f01049f2 <_alltraps>

f01049e0 <int_spurious>:
TRAPHANDLER_NOEC(int_spurious, IRQ_OFFSET+IRQ_SPURIOUS)
f01049e0:	6a 00                	push   $0x0
f01049e2:	6a 27                	push   $0x27
f01049e4:	eb 0c                	jmp    f01049f2 <_alltraps>

f01049e6 <int_ide>:
TRAPHANDLER_NOEC(int_ide, IRQ_OFFSET+IRQ_IDE)
f01049e6:	6a 00                	push   $0x0
f01049e8:	6a 2e                	push   $0x2e
f01049ea:	eb 06                	jmp    f01049f2 <_alltraps>

f01049ec <int_error>:
TRAPHANDLER_NOEC(int_error, IRQ_OFFSET+IRQ_ERROR)
f01049ec:	6a 00                	push   $0x0
f01049ee:	6a 33                	push   $0x33
f01049f0:	eb 00                	jmp    f01049f2 <_alltraps>

f01049f2 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	// push values to make the stack look like a struct TrapFrame
	pushl	%ds;
f01049f2:	1e                   	push   %ds
	pushl	%es;
f01049f3:	06                   	push   %es
	pushal;
f01049f4:	60                   	pusha  
	// load GD_KD into %ds and %es
	movl	$GD_KD, %eax;
f01049f5:	b8 10 00 00 00       	mov    $0x10,%eax
	movw	%ax, %ds;
f01049fa:	8e d8                	mov    %eax,%ds
	movw	%ax, %es;
f01049fc:	8e c0                	mov    %eax,%es
	// pass a pointer to the Trapframe as an argument to trap
	pushl 	%esp;
f01049fe:	54                   	push   %esp
	call	trap; 
f01049ff:	e8 e4 fc ff ff       	call   f01046e8 <trap>

f0104a04 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104a04:	f3 0f 1e fb          	endbr32 
f0104a08:	55                   	push   %ebp
f0104a09:	89 e5                	mov    %esp,%ebp
f0104a0b:	83 ec 08             	sub    $0x8,%esp
f0104a0e:	a1 4c d2 2b f0       	mov    0xf02bd24c,%eax
f0104a13:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104a16:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104a1b:	8b 02                	mov    (%edx),%eax
f0104a1d:	83 e8 01             	sub    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104a20:	83 f8 02             	cmp    $0x2,%eax
f0104a23:	76 2d                	jbe    f0104a52 <sched_halt+0x4e>
	for (i = 0; i < NENV; i++) {
f0104a25:	83 c1 01             	add    $0x1,%ecx
f0104a28:	83 c2 7c             	add    $0x7c,%edx
f0104a2b:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104a31:	75 e8                	jne    f0104a1b <sched_halt+0x17>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f0104a33:	83 ec 0c             	sub    $0xc,%esp
f0104a36:	68 10 8f 10 f0       	push   $0xf0108f10
f0104a3b:	e8 f0 f3 ff ff       	call   f0103e30 <cprintf>
f0104a40:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104a43:	83 ec 0c             	sub    $0xc,%esp
f0104a46:	6a 00                	push   $0x0
f0104a48:	e8 c5 c2 ff ff       	call   f0100d12 <monitor>
f0104a4d:	83 c4 10             	add    $0x10,%esp
f0104a50:	eb f1                	jmp    f0104a43 <sched_halt+0x3f>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104a52:	e8 37 1a 00 00       	call   f010648e <cpunum>
f0104a57:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a5a:	c7 80 28 00 2c f0 00 	movl   $0x0,-0xfd3ffd8(%eax)
f0104a61:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104a64:	a1 18 f4 2b f0       	mov    0xf02bf418,%eax
	if ((uint32_t)kva < KERNBASE)
f0104a69:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104a6e:	76 50                	jbe    f0104ac0 <sched_halt+0xbc>
	return (physaddr_t)kva - KERNBASE;
f0104a70:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104a75:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104a78:	e8 11 1a 00 00       	call   f010648e <cpunum>
f0104a7d:	6b d0 74             	imul   $0x74,%eax,%edx
f0104a80:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0104a83:	b8 02 00 00 00       	mov    $0x2,%eax
f0104a88:	f0 87 82 20 00 2c f0 	lock xchg %eax,-0xfd3ffe0(%edx)
	spin_unlock(&kernel_lock);
f0104a8f:	83 ec 0c             	sub    $0xc,%esp
f0104a92:	68 c0 73 12 f0       	push   $0xf01273c0
f0104a97:	e8 18 1d 00 00       	call   f01067b4 <spin_unlock>
	asm volatile("pause");
f0104a9c:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n" // unmask interrupts for idle CPUs
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104a9e:	e8 eb 19 00 00       	call   f010648e <cpunum>
f0104aa3:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f0104aa6:	8b 80 30 00 2c f0    	mov    -0xfd3ffd0(%eax),%eax
f0104aac:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104ab1:	89 c4                	mov    %eax,%esp
f0104ab3:	6a 00                	push   $0x0
f0104ab5:	6a 00                	push   $0x0
f0104ab7:	fb                   	sti    
f0104ab8:	f4                   	hlt    
f0104ab9:	eb fd                	jmp    f0104ab8 <sched_halt+0xb4>
}
f0104abb:	83 c4 10             	add    $0x10,%esp
f0104abe:	c9                   	leave  
f0104abf:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104ac0:	50                   	push   %eax
f0104ac1:	68 68 74 10 f0       	push   $0xf0107468
f0104ac6:	6a 4c                	push   $0x4c
f0104ac8:	68 39 8f 10 f0       	push   $0xf0108f39
f0104acd:	e8 6e b5 ff ff       	call   f0100040 <_panic>

f0104ad2 <sched_yield>:
{
f0104ad2:	f3 0f 1e fb          	endbr32 
f0104ad6:	55                   	push   %ebp
f0104ad7:	89 e5                	mov    %esp,%ebp
f0104ad9:	53                   	push   %ebx
f0104ada:	83 ec 04             	sub    $0x4,%esp
	int i = (curenv)?(ENVX(curenv->env_id)+1):0;
f0104add:	e8 ac 19 00 00       	call   f010648e <cpunum>
f0104ae2:	6b d0 74             	imul   $0x74,%eax,%edx
f0104ae5:	b8 00 00 00 00       	mov    $0x0,%eax
f0104aea:	83 ba 28 00 2c f0 00 	cmpl   $0x0,-0xfd3ffd8(%edx)
f0104af1:	74 19                	je     f0104b0c <sched_yield+0x3a>
f0104af3:	e8 96 19 00 00       	call   f010648e <cpunum>
f0104af8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104afb:	8b 80 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%eax
f0104b01:	8b 40 48             	mov    0x48(%eax),%eax
f0104b04:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104b09:	83 c0 01             	add    $0x1,%eax
		if (envs[i].env_status == ENV_RUNNABLE){
f0104b0c:	8b 0d 4c d2 2b f0    	mov    0xf02bd24c,%ecx
f0104b12:	ba 00 04 00 00       	mov    $0x400,%edx
		i = i%NENV;
f0104b17:	89 c3                	mov    %eax,%ebx
f0104b19:	c1 fb 1f             	sar    $0x1f,%ebx
f0104b1c:	c1 eb 16             	shr    $0x16,%ebx
f0104b1f:	01 d8                	add    %ebx,%eax
f0104b21:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104b26:	29 d8                	sub    %ebx,%eax
		if (envs[i].env_status == ENV_RUNNABLE){
f0104b28:	6b d8 7c             	imul   $0x7c,%eax,%ebx
f0104b2b:	01 cb                	add    %ecx,%ebx
f0104b2d:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f0104b31:	74 37                	je     f0104b6a <sched_yield+0x98>
	for (int cnt = 0; cnt<NENV; cnt++, i++){
f0104b33:	83 c0 01             	add    $0x1,%eax
f0104b36:	83 ea 01             	sub    $0x1,%edx
f0104b39:	75 dc                	jne    f0104b17 <sched_yield+0x45>
	if (curenv&&(curenv->env_status == ENV_RUNNING)){ 
f0104b3b:	e8 4e 19 00 00       	call   f010648e <cpunum>
f0104b40:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b43:	83 b8 28 00 2c f0 00 	cmpl   $0x0,-0xfd3ffd8(%eax)
f0104b4a:	74 14                	je     f0104b60 <sched_yield+0x8e>
f0104b4c:	e8 3d 19 00 00       	call   f010648e <cpunum>
f0104b51:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b54:	8b 80 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%eax
f0104b5a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104b5e:	74 13                	je     f0104b73 <sched_yield+0xa1>
	sched_halt();
f0104b60:	e8 9f fe ff ff       	call   f0104a04 <sched_halt>
}
f0104b65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104b68:	c9                   	leave  
f0104b69:	c3                   	ret    
			env_run(&envs[i]);
f0104b6a:	83 ec 0c             	sub    $0xc,%esp
f0104b6d:	53                   	push   %ebx
f0104b6e:	e8 53 f0 ff ff       	call   f0103bc6 <env_run>
		env_run(curenv);
f0104b73:	e8 16 19 00 00       	call   f010648e <cpunum>
f0104b78:	83 ec 0c             	sub    $0xc,%esp
f0104b7b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b7e:	ff b0 28 00 2c f0    	pushl  -0xfd3ffd8(%eax)
f0104b84:	e8 3d f0 ff ff       	call   f0103bc6 <env_run>

f0104b89 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104b89:	f3 0f 1e fb          	endbr32 
f0104b8d:	55                   	push   %ebp
f0104b8e:	89 e5                	mov    %esp,%ebp
f0104b90:	57                   	push   %edi
f0104b91:	56                   	push   %esi
f0104b92:	53                   	push   %ebx
f0104b93:	83 ec 1c             	sub    $0x1c,%esp
f0104b96:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b99:	8b 75 10             	mov    0x10(%ebp),%esi
f0104b9c:	83 f8 10             	cmp    $0x10,%eax
f0104b9f:	0f 87 39 06 00 00    	ja     f01051de <syscall+0x655>
f0104ba5:	3e ff 24 85 88 8f 10 	notrack jmp *-0xfef7078(,%eax,4)
f0104bac:	f0 
	user_mem_assert(curenv, s, len, PTE_U);
f0104bad:	e8 dc 18 00 00       	call   f010648e <cpunum>
f0104bb2:	6a 04                	push   $0x4
f0104bb4:	56                   	push   %esi
f0104bb5:	ff 75 0c             	pushl  0xc(%ebp)
f0104bb8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bbb:	ff b0 28 00 2c f0    	pushl  -0xfd3ffd8(%eax)
f0104bc1:	e8 0e e9 ff ff       	call   f01034d4 <user_mem_assert>
	cprintf("%.*s", len, s);
f0104bc6:	83 c4 0c             	add    $0xc,%esp
f0104bc9:	ff 75 0c             	pushl  0xc(%ebp)
f0104bcc:	56                   	push   %esi
f0104bcd:	68 46 8f 10 f0       	push   $0xf0108f46
f0104bd2:	e8 59 f2 ff ff       	call   f0103e30 <cprintf>
	return;
f0104bd7:	83 c4 10             	add    $0x10,%esp
	// LAB 3: Your code here.
	switch (syscallno) {
	case SYS_cputs: 
		// cprintf("SYS_cputs\n");
		sys_cputs((const char*)a1,(size_t)a2);
		return 0;
f0104bda:	bb 00 00 00 00       	mov    $0x0,%ebx
	default:
		// cprintf("invalid syscall\n");
		return -E_INVAL;
	}

}
f0104bdf:	89 d8                	mov    %ebx,%eax
f0104be1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104be4:	5b                   	pop    %ebx
f0104be5:	5e                   	pop    %esi
f0104be6:	5f                   	pop    %edi
f0104be7:	5d                   	pop    %ebp
f0104be8:	c3                   	ret    
	return cons_getc();
f0104be9:	e8 3e ba ff ff       	call   f010062c <cons_getc>
f0104bee:	89 c3                	mov    %eax,%ebx
		return sys_cgetc();
f0104bf0:	eb ed                	jmp    f0104bdf <syscall+0x56>
	return curenv->env_id;
f0104bf2:	e8 97 18 00 00       	call   f010648e <cpunum>
f0104bf7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bfa:	8b 80 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%eax
f0104c00:	8b 58 48             	mov    0x48(%eax),%ebx
		return sys_getenvid();
f0104c03:	eb da                	jmp    f0104bdf <syscall+0x56>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104c05:	83 ec 04             	sub    $0x4,%esp
f0104c08:	6a 01                	push   $0x1
f0104c0a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104c0d:	50                   	push   %eax
f0104c0e:	ff 75 0c             	pushl  0xc(%ebp)
f0104c11:	e8 ae e9 ff ff       	call   f01035c4 <envid2env>
f0104c16:	89 c3                	mov    %eax,%ebx
f0104c18:	83 c4 10             	add    $0x10,%esp
f0104c1b:	85 c0                	test   %eax,%eax
f0104c1d:	78 c0                	js     f0104bdf <syscall+0x56>
	env_destroy(e);
f0104c1f:	83 ec 0c             	sub    $0xc,%esp
f0104c22:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104c25:	e8 f5 ee ff ff       	call   f0103b1f <env_destroy>
	return 0;
f0104c2a:	83 c4 10             	add    $0x10,%esp
f0104c2d:	bb 00 00 00 00       	mov    $0x0,%ebx
		return sys_env_destroy((envid_t)a1);
f0104c32:	eb ab                	jmp    f0104bdf <syscall+0x56>
	sched_yield();
f0104c34:	e8 99 fe ff ff       	call   f0104ad2 <sched_yield>
	if ((ret = envid2env(envid, &e, 1))<0)
f0104c39:	83 ec 04             	sub    $0x4,%esp
f0104c3c:	6a 01                	push   $0x1
f0104c3e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104c41:	50                   	push   %eax
f0104c42:	ff 75 0c             	pushl  0xc(%ebp)
f0104c45:	e8 7a e9 ff ff       	call   f01035c4 <envid2env>
f0104c4a:	89 c3                	mov    %eax,%ebx
f0104c4c:	83 c4 10             	add    $0x10,%esp
f0104c4f:	85 c0                	test   %eax,%eax
f0104c51:	78 8c                	js     f0104bdf <syscall+0x56>
	if ((uintptr_t)va>=UTOP||(uintptr_t)va%PGSIZE) 
f0104c53:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104c59:	77 5d                	ja     f0104cb8 <syscall+0x12f>
f0104c5b:	89 f0                	mov    %esi,%eax
f0104c5d:	25 ff 0f 00 00       	and    $0xfff,%eax
	if (!(perm&PTE_P)||!(perm&PTE_P))  return -E_INVAL;
f0104c62:	f6 45 14 01          	testb  $0x1,0x14(%ebp)
f0104c66:	74 5a                	je     f0104cc2 <syscall+0x139>
	if (perm&~PTE_SYSCALL) return -E_INVAL;
f0104c68:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104c6b:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f0104c71:	09 c3                	or     %eax,%ebx
f0104c73:	75 57                	jne    f0104ccc <syscall+0x143>
	struct PageInfo* pp = page_alloc(ALLOC_ZERO);
f0104c75:	83 ec 0c             	sub    $0xc,%esp
f0104c78:	6a 01                	push   $0x1
f0104c7a:	e8 21 c7 ff ff       	call   f01013a0 <page_alloc>
f0104c7f:	89 c7                	mov    %eax,%edi
	if (!pp) return -E_NO_MEM;
f0104c81:	83 c4 10             	add    $0x10,%esp
f0104c84:	85 c0                	test   %eax,%eax
f0104c86:	74 4e                	je     f0104cd6 <syscall+0x14d>
	if ((ret = page_insert(e->env_pgdir, pp, va, perm))<0){
f0104c88:	ff 75 14             	pushl  0x14(%ebp)
f0104c8b:	56                   	push   %esi
f0104c8c:	50                   	push   %eax
f0104c8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c90:	ff 70 60             	pushl  0x60(%eax)
f0104c93:	e8 76 ca ff ff       	call   f010170e <page_insert>
f0104c98:	89 c6                	mov    %eax,%esi
f0104c9a:	83 c4 10             	add    $0x10,%esp
f0104c9d:	85 c0                	test   %eax,%eax
f0104c9f:	0f 89 3a ff ff ff    	jns    f0104bdf <syscall+0x56>
		page_free(pp);
f0104ca5:	83 ec 0c             	sub    $0xc,%esp
f0104ca8:	57                   	push   %edi
f0104ca9:	e8 6b c7 ff ff       	call   f0101419 <page_free>
		return ret;
f0104cae:	83 c4 10             	add    $0x10,%esp
f0104cb1:	89 f3                	mov    %esi,%ebx
f0104cb3:	e9 27 ff ff ff       	jmp    f0104bdf <syscall+0x56>
		return -E_INVAL;
f0104cb8:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104cbd:	e9 1d ff ff ff       	jmp    f0104bdf <syscall+0x56>
	if (!(perm&PTE_P)||!(perm&PTE_P))  return -E_INVAL;
f0104cc2:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104cc7:	e9 13 ff ff ff       	jmp    f0104bdf <syscall+0x56>
	if (perm&~PTE_SYSCALL) return -E_INVAL;
f0104ccc:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104cd1:	e9 09 ff ff ff       	jmp    f0104bdf <syscall+0x56>
	if (!pp) return -E_NO_MEM;
f0104cd6:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
		return sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
f0104cdb:	e9 ff fe ff ff       	jmp    f0104bdf <syscall+0x56>
	if (envid2env(srcenvid, &srcenv, 1)<0||envid2env(dstenvid, &dstenv, 1)<0)
f0104ce0:	83 ec 04             	sub    $0x4,%esp
f0104ce3:	6a 01                	push   $0x1
f0104ce5:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104ce8:	50                   	push   %eax
f0104ce9:	ff 75 0c             	pushl  0xc(%ebp)
f0104cec:	e8 d3 e8 ff ff       	call   f01035c4 <envid2env>
f0104cf1:	83 c4 10             	add    $0x10,%esp
f0104cf4:	85 c0                	test   %eax,%eax
f0104cf6:	0f 88 a3 00 00 00    	js     f0104d9f <syscall+0x216>
f0104cfc:	83 ec 04             	sub    $0x4,%esp
f0104cff:	6a 01                	push   $0x1
f0104d01:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104d04:	50                   	push   %eax
f0104d05:	ff 75 14             	pushl  0x14(%ebp)
f0104d08:	e8 b7 e8 ff ff       	call   f01035c4 <envid2env>
f0104d0d:	83 c4 10             	add    $0x10,%esp
f0104d10:	85 c0                	test   %eax,%eax
f0104d12:	0f 88 91 00 00 00    	js     f0104da9 <syscall+0x220>
	if ((uintptr_t)srcva>=UTOP||(uintptr_t)dstva>=UTOP||(uintptr_t)srcva%PGSIZE||(uintptr_t)dstva%PGSIZE)
f0104d18:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104d1e:	0f 87 8f 00 00 00    	ja     f0104db3 <syscall+0x22a>
f0104d24:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104d2b:	0f 87 82 00 00 00    	ja     f0104db3 <syscall+0x22a>
f0104d31:	89 f0                	mov    %esi,%eax
f0104d33:	0b 45 18             	or     0x18(%ebp),%eax
f0104d36:	25 ff 0f 00 00       	and    $0xfff,%eax
	if (!(perm&PTE_U)||!(perm&PTE_P)) return -E_INVAL;
f0104d3b:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0104d3e:	83 e2 05             	and    $0x5,%edx
f0104d41:	83 fa 05             	cmp    $0x5,%edx
f0104d44:	75 77                	jne    f0104dbd <syscall+0x234>
	if (perm&~PTE_SYSCALL) return -E_INVAL;
f0104d46:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f0104d49:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f0104d4f:	09 c3                	or     %eax,%ebx
f0104d51:	75 74                	jne    f0104dc7 <syscall+0x23e>
	struct PageInfo* pp = page_lookup(srcenv->env_pgdir, srcva, &pg_tbl_entry);
f0104d53:	83 ec 04             	sub    $0x4,%esp
f0104d56:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d59:	50                   	push   %eax
f0104d5a:	56                   	push   %esi
f0104d5b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104d5e:	ff 70 60             	pushl  0x60(%eax)
f0104d61:	e8 ae c8 ff ff       	call   f0101614 <page_lookup>
	if (!pp) return -E_INVAL;
f0104d66:	83 c4 10             	add    $0x10,%esp
f0104d69:	85 c0                	test   %eax,%eax
f0104d6b:	74 64                	je     f0104dd1 <syscall+0x248>
	if ((perm&PTE_W)&&(!(*pg_tbl_entry&PTE_W))) return -E_INVAL;
f0104d6d:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104d71:	74 08                	je     f0104d7b <syscall+0x1f2>
f0104d73:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104d76:	f6 02 02             	testb  $0x2,(%edx)
f0104d79:	74 60                	je     f0104ddb <syscall+0x252>
	if((ret = page_insert(dstenv->env_pgdir, pp, dstva, perm))<0)
f0104d7b:	ff 75 1c             	pushl  0x1c(%ebp)
f0104d7e:	ff 75 18             	pushl  0x18(%ebp)
f0104d81:	50                   	push   %eax
f0104d82:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d85:	ff 70 60             	pushl  0x60(%eax)
f0104d88:	e8 81 c9 ff ff       	call   f010170e <page_insert>
f0104d8d:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f0104d90:	85 c0                	test   %eax,%eax
f0104d92:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104d97:	0f 48 d8             	cmovs  %eax,%ebx
f0104d9a:	e9 40 fe ff ff       	jmp    f0104bdf <syscall+0x56>
		return -E_BAD_ENV;
f0104d9f:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104da4:	e9 36 fe ff ff       	jmp    f0104bdf <syscall+0x56>
f0104da9:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104dae:	e9 2c fe ff ff       	jmp    f0104bdf <syscall+0x56>
		return -E_INVAL;
f0104db3:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104db8:	e9 22 fe ff ff       	jmp    f0104bdf <syscall+0x56>
	if (!(perm&PTE_U)||!(perm&PTE_P)) return -E_INVAL;
f0104dbd:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104dc2:	e9 18 fe ff ff       	jmp    f0104bdf <syscall+0x56>
	if (perm&~PTE_SYSCALL) return -E_INVAL;
f0104dc7:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104dcc:	e9 0e fe ff ff       	jmp    f0104bdf <syscall+0x56>
	if (!pp) return -E_INVAL;
f0104dd1:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104dd6:	e9 04 fe ff ff       	jmp    f0104bdf <syscall+0x56>
	if ((perm&PTE_W)&&(!(*pg_tbl_entry&PTE_W))) return -E_INVAL;
f0104ddb:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		return sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3, (void*)a4, (int)a5);
f0104de0:	e9 fa fd ff ff       	jmp    f0104bdf <syscall+0x56>
	if(envid2env(envid, &e, 1)<0) return -E_BAD_ENV;
f0104de5:	83 ec 04             	sub    $0x4,%esp
f0104de8:	6a 01                	push   $0x1
f0104dea:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104ded:	50                   	push   %eax
f0104dee:	ff 75 0c             	pushl  0xc(%ebp)
f0104df1:	e8 ce e7 ff ff       	call   f01035c4 <envid2env>
f0104df6:	83 c4 10             	add    $0x10,%esp
f0104df9:	85 c0                	test   %eax,%eax
f0104dfb:	78 2c                	js     f0104e29 <syscall+0x2a0>
	if ((uintptr_t)va>=UTOP||(uintptr_t)va%PGSIZE) 
f0104dfd:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104e03:	77 2e                	ja     f0104e33 <syscall+0x2aa>
f0104e05:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0104e0b:	75 30                	jne    f0104e3d <syscall+0x2b4>
	page_remove(e->env_pgdir, va);
f0104e0d:	83 ec 08             	sub    $0x8,%esp
f0104e10:	56                   	push   %esi
f0104e11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e14:	ff 70 60             	pushl  0x60(%eax)
f0104e17:	e8 a8 c8 ff ff       	call   f01016c4 <page_remove>
	return 0;
f0104e1c:	83 c4 10             	add    $0x10,%esp
f0104e1f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104e24:	e9 b6 fd ff ff       	jmp    f0104bdf <syscall+0x56>
	if(envid2env(envid, &e, 1)<0) return -E_BAD_ENV;
f0104e29:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104e2e:	e9 ac fd ff ff       	jmp    f0104bdf <syscall+0x56>
		return -E_INVAL;
f0104e33:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104e38:	e9 a2 fd ff ff       	jmp    f0104bdf <syscall+0x56>
f0104e3d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		return sys_page_unmap((envid_t)a1,(void*)a2);
f0104e42:	e9 98 fd ff ff       	jmp    f0104bdf <syscall+0x56>
	if ((ret = env_alloc(&childenv, curenv->env_id))<0){
f0104e47:	e8 42 16 00 00       	call   f010648e <cpunum>
f0104e4c:	83 ec 08             	sub    $0x8,%esp
f0104e4f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e52:	8b 80 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%eax
f0104e58:	ff 70 48             	pushl  0x48(%eax)
f0104e5b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e5e:	50                   	push   %eax
f0104e5f:	e8 76 e8 ff ff       	call   f01036da <env_alloc>
f0104e64:	83 c4 10             	add    $0x10,%esp
f0104e67:	85 c0                	test   %eax,%eax
f0104e69:	78 34                	js     f0104e9f <syscall+0x316>
	childenv->env_status = ENV_NOT_RUNNABLE;
f0104e6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e6e:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	childenv->env_tf = curenv->env_tf;
f0104e75:	e8 14 16 00 00       	call   f010648e <cpunum>
f0104e7a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e7d:	8b b0 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%esi
f0104e83:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104e88:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e8b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	childenv->env_tf.tf_regs.reg_eax = 0; // childenv的返回值
f0104e8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e90:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return childenv->env_id;
f0104e97:	8b 58 48             	mov    0x48(%eax),%ebx
		return sys_exofork();
f0104e9a:	e9 40 fd ff ff       	jmp    f0104bdf <syscall+0x56>
		panic("sys_exofork: env_alloc failed due to %e\n", ret);
f0104e9f:	50                   	push   %eax
f0104ea0:	68 5c 8f 10 f0       	push   $0xf0108f5c
f0104ea5:	6a 5c                	push   $0x5c
f0104ea7:	68 4b 8f 10 f0       	push   $0xf0108f4b
f0104eac:	e8 8f b1 ff ff       	call   f0100040 <_panic>
	if ((ret = envid2env(envid, &e, 1))<0){
f0104eb1:	83 ec 04             	sub    $0x4,%esp
f0104eb4:	6a 01                	push   $0x1
f0104eb6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104eb9:	50                   	push   %eax
f0104eba:	ff 75 0c             	pushl  0xc(%ebp)
f0104ebd:	e8 02 e7 ff ff       	call   f01035c4 <envid2env>
f0104ec2:	89 c3                	mov    %eax,%ebx
f0104ec4:	83 c4 10             	add    $0x10,%esp
f0104ec7:	85 c0                	test   %eax,%eax
f0104ec9:	0f 88 10 fd ff ff    	js     f0104bdf <syscall+0x56>
	if (status != ENV_RUNNABLE && status!=ENV_NOT_RUNNABLE)
f0104ecf:	8d 46 fe             	lea    -0x2(%esi),%eax
f0104ed2:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104ed7:	75 10                	jne    f0104ee9 <syscall+0x360>
	e->env_status = status;
f0104ed9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104edc:	89 70 54             	mov    %esi,0x54(%eax)
	return 0;
f0104edf:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104ee4:	e9 f6 fc ff ff       	jmp    f0104bdf <syscall+0x56>
		return -E_INVAL;
f0104ee9:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		return sys_env_set_status((envid_t)a1,(int)a2);
f0104eee:	e9 ec fc ff ff       	jmp    f0104bdf <syscall+0x56>
	if (envid2env(envid, &e, 1)<0)
f0104ef3:	83 ec 04             	sub    $0x4,%esp
f0104ef6:	6a 01                	push   $0x1
f0104ef8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104efb:	50                   	push   %eax
f0104efc:	ff 75 0c             	pushl  0xc(%ebp)
f0104eff:	e8 c0 e6 ff ff       	call   f01035c4 <envid2env>
f0104f04:	83 c4 10             	add    $0x10,%esp
f0104f07:	85 c0                	test   %eax,%eax
f0104f09:	78 10                	js     f0104f1b <syscall+0x392>
	e->env_pgfault_upcall = func;
f0104f0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f0e:	89 70 64             	mov    %esi,0x64(%eax)
	return 0;
f0104f11:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104f16:	e9 c4 fc ff ff       	jmp    f0104bdf <syscall+0x56>
		return -E_BAD_ENV;
f0104f1b:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
		return sys_env_set_pgfault_upcall((envid_t)a1, (void*)a2);
f0104f20:	e9 ba fc ff ff       	jmp    f0104bdf <syscall+0x56>
	if ((envid2env(envid, &e, 0)<0))// checkperm = 0 means allowed to send IPC messages to any other env
f0104f25:	83 ec 04             	sub    $0x4,%esp
f0104f28:	6a 00                	push   $0x0
f0104f2a:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104f2d:	50                   	push   %eax
f0104f2e:	ff 75 0c             	pushl  0xc(%ebp)
f0104f31:	e8 8e e6 ff ff       	call   f01035c4 <envid2env>
f0104f36:	83 c4 10             	add    $0x10,%esp
f0104f39:	85 c0                	test   %eax,%eax
f0104f3b:	0f 88 f3 00 00 00    	js     f0105034 <syscall+0x4ab>
	if (e->env_ipc_recving == 0||e->env_ipc_from != 0)
f0104f41:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f44:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104f48:	0f 84 f0 00 00 00    	je     f010503e <syscall+0x4b5>
f0104f4e:	8b 58 74             	mov    0x74(%eax),%ebx
f0104f51:	85 db                	test   %ebx,%ebx
f0104f53:	0f 85 ef 00 00 00    	jne    f0105048 <syscall+0x4bf>
	if (srcva<(void*)UTOP){
f0104f59:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104f60:	0f 87 98 00 00 00    	ja     f0104ffe <syscall+0x475>
		if ((uintptr_t)srcva%PGSIZE) return -E_INVAL; // not aligned
f0104f66:	8b 55 14             	mov    0x14(%ebp),%edx
f0104f69:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
		if (!(perm&PTE_U)||!(perm&PTE_P)) return -E_INVAL;
f0104f6f:	8b 45 18             	mov    0x18(%ebp),%eax
f0104f72:	83 e0 05             	and    $0x5,%eax
f0104f75:	83 f8 05             	cmp    $0x5,%eax
f0104f78:	0f 85 d4 00 00 00    	jne    f0105052 <syscall+0x4c9>
		if (perm&~(PTE_SYSCALL)) return -E_INVAL;
f0104f7e:	8b 45 18             	mov    0x18(%ebp),%eax
f0104f81:	25 f8 f1 ff ff       	and    $0xfffff1f8,%eax
f0104f86:	09 d0                	or     %edx,%eax
f0104f88:	0f 85 ce 00 00 00    	jne    f010505c <syscall+0x4d3>
		pp = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104f8e:	e8 fb 14 00 00       	call   f010648e <cpunum>
f0104f93:	83 ec 04             	sub    $0x4,%esp
f0104f96:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104f99:	52                   	push   %edx
f0104f9a:	ff 75 14             	pushl  0x14(%ebp)
f0104f9d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fa0:	8b 80 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%eax
f0104fa6:	ff 70 60             	pushl  0x60(%eax)
f0104fa9:	e8 66 c6 ff ff       	call   f0101614 <page_lookup>
		if (!pte||!pp) return -E_INVAL;
f0104fae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104fb1:	83 c4 10             	add    $0x10,%esp
f0104fb4:	85 c0                	test   %eax,%eax
f0104fb6:	0f 84 aa 00 00 00    	je     f0105066 <syscall+0x4dd>
f0104fbc:	85 d2                	test   %edx,%edx
f0104fbe:	0f 84 a2 00 00 00    	je     f0105066 <syscall+0x4dd>
		if ((perm&PTE_W)&&(!(*pte&PTE_W))) return -E_INVAL;
f0104fc4:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104fc8:	74 09                	je     f0104fd3 <syscall+0x44a>
f0104fca:	f6 02 02             	testb  $0x2,(%edx)
f0104fcd:	0f 84 9d 00 00 00    	je     f0105070 <syscall+0x4e7>
		if (e->env_ipc_dstva){
f0104fd3:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104fd6:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0104fd9:	85 c9                	test   %ecx,%ecx
f0104fdb:	74 21                	je     f0104ffe <syscall+0x475>
			if ((ret = page_insert(e->env_pgdir, pp, e->env_ipc_dstva, perm)<0))
f0104fdd:	ff 75 18             	pushl  0x18(%ebp)
f0104fe0:	51                   	push   %ecx
f0104fe1:	50                   	push   %eax
f0104fe2:	ff 72 60             	pushl  0x60(%edx)
f0104fe5:	e8 24 c7 ff ff       	call   f010170e <page_insert>
f0104fea:	83 c4 10             	add    $0x10,%esp
f0104fed:	85 c0                	test   %eax,%eax
f0104fef:	0f 88 85 00 00 00    	js     f010507a <syscall+0x4f1>
			e->env_ipc_perm = perm;
f0104ff5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ff8:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0104ffb:	89 48 78             	mov    %ecx,0x78(%eax)
	e->env_ipc_recving = 0; // to block future sends
f0104ffe:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105001:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	e->env_ipc_from = curenv->env_id;
f0105005:	e8 84 14 00 00       	call   f010648e <cpunum>
f010500a:	89 c2                	mov    %eax,%edx
f010500c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010500f:	6b d2 74             	imul   $0x74,%edx,%edx
f0105012:	8b 92 28 00 2c f0    	mov    -0xfd3ffd8(%edx),%edx
f0105018:	8b 52 48             	mov    0x48(%edx),%edx
f010501b:	89 50 74             	mov    %edx,0x74(%eax)
	e->env_ipc_value = value;
f010501e:	89 70 70             	mov    %esi,0x70(%eax)
	e->env_status = ENV_RUNNABLE;
f0105021:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	e->env_tf.tf_regs.reg_eax = 0;
f0105028:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f010502f:	e9 ab fb ff ff       	jmp    f0104bdf <syscall+0x56>
		return -E_BAD_ENV;
f0105034:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0105039:	e9 a1 fb ff ff       	jmp    f0104bdf <syscall+0x56>
		return -E_IPC_NOT_RECV;
f010503e:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0105043:	e9 97 fb ff ff       	jmp    f0104bdf <syscall+0x56>
f0105048:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f010504d:	e9 8d fb ff ff       	jmp    f0104bdf <syscall+0x56>
		if (!(perm&PTE_U)||!(perm&PTE_P)) return -E_INVAL;
f0105052:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105057:	e9 83 fb ff ff       	jmp    f0104bdf <syscall+0x56>
		if (perm&~(PTE_SYSCALL)) return -E_INVAL;
f010505c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105061:	e9 79 fb ff ff       	jmp    f0104bdf <syscall+0x56>
		if (!pte||!pp) return -E_INVAL;
f0105066:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010506b:	e9 6f fb ff ff       	jmp    f0104bdf <syscall+0x56>
		if ((perm&PTE_W)&&(!(*pte&PTE_W))) return -E_INVAL;
f0105070:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105075:	e9 65 fb ff ff       	jmp    f0104bdf <syscall+0x56>
				return ret;
f010507a:	bb 01 00 00 00       	mov    $0x1,%ebx
		return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void*)a3, (unsigned int)a4);
f010507f:	e9 5b fb ff ff       	jmp    f0104bdf <syscall+0x56>
	if ((uintptr_t)dstva < UTOP&&((uintptr_t)dstva%PGSIZE)) {
f0105084:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f010508b:	77 13                	ja     f01050a0 <syscall+0x517>
f010508d:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0105094:	74 0a                	je     f01050a0 <syscall+0x517>
		return sys_ipc_recv((void*)a1);
f0105096:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010509b:	e9 3f fb ff ff       	jmp    f0104bdf <syscall+0x56>
	curenv->env_ipc_dstva = dstva;
f01050a0:	e8 e9 13 00 00       	call   f010648e <cpunum>
f01050a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01050a8:	8b 80 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%eax
f01050ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01050b1:	89 48 6c             	mov    %ecx,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f01050b4:	e8 d5 13 00 00       	call   f010648e <cpunum>
f01050b9:	6b c0 74             	imul   $0x74,%eax,%eax
f01050bc:	8b 80 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%eax
f01050c2:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_recving = 1;
f01050c9:	e8 c0 13 00 00       	call   f010648e <cpunum>
f01050ce:	6b c0 74             	imul   $0x74,%eax,%eax
f01050d1:	8b 80 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%eax
f01050d7:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_from = 0;
f01050db:	e8 ae 13 00 00       	call   f010648e <cpunum>
f01050e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01050e3:	8b 80 28 00 2c f0    	mov    -0xfd3ffd8(%eax),%eax
f01050e9:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
	sched_yield();
f01050f0:	e8 dd f9 ff ff       	call   f0104ad2 <sched_yield>
	if ((r = envid2env(envid,&e, 1))<0)
f01050f5:	83 ec 04             	sub    $0x4,%esp
f01050f8:	6a 01                	push   $0x1
f01050fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01050fd:	50                   	push   %eax
f01050fe:	ff 75 0c             	pushl  0xc(%ebp)
f0105101:	e8 be e4 ff ff       	call   f01035c4 <envid2env>
f0105106:	89 c3                	mov    %eax,%ebx
f0105108:	83 c4 10             	add    $0x10,%esp
f010510b:	85 c0                	test   %eax,%eax
f010510d:	0f 88 cc fa ff ff    	js     f0104bdf <syscall+0x56>
	e->env_tf.tf_ds = tf->tf_ds;
f0105113:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105116:	0f b7 56 24          	movzwl 0x24(%esi),%edx
f010511a:	66 89 50 24          	mov    %dx,0x24(%eax)
	e->env_tf.tf_trapno = tf->tf_trapno;
f010511e:	8b 56 28             	mov    0x28(%esi),%edx
f0105121:	89 50 28             	mov    %edx,0x28(%eax)
	e->env_tf.tf_err = tf->tf_err;
f0105124:	8b 56 2c             	mov    0x2c(%esi),%edx
f0105127:	89 50 2c             	mov    %edx,0x2c(%eax)
	e->env_tf.tf_eip = tf->tf_eip;
f010512a:	8b 56 30             	mov    0x30(%esi),%edx
f010512d:	89 50 30             	mov    %edx,0x30(%eax)
	e->env_tf.tf_cs = tf->tf_cs|3;
f0105130:	0f b7 56 34          	movzwl 0x34(%esi),%edx
f0105134:	83 ca 03             	or     $0x3,%edx
f0105137:	66 89 50 34          	mov    %dx,0x34(%eax)
	e->env_tf.tf_eflags = (tf->tf_eflags|FL_IF)&(~FL_IOPL_3);
f010513b:	8b 56 38             	mov    0x38(%esi),%edx
f010513e:	80 e6 cd             	and    $0xcd,%dh
f0105141:	80 ce 02             	or     $0x2,%dh
f0105144:	89 50 38             	mov    %edx,0x38(%eax)
	e->env_tf.tf_esp = tf->tf_esp;
f0105147:	8b 56 3c             	mov    0x3c(%esi),%edx
f010514a:	89 50 3c             	mov    %edx,0x3c(%eax)
	e->env_tf.tf_ss = tf->tf_ss;
f010514d:	0f b7 56 40          	movzwl 0x40(%esi),%edx
f0105151:	66 89 50 40          	mov    %dx,0x40(%eax)
	e->env_tf.tf_regs = tf->tf_regs;
f0105155:	8b 16                	mov    (%esi),%edx
f0105157:	89 10                	mov    %edx,(%eax)
f0105159:	8b 56 04             	mov    0x4(%esi),%edx
f010515c:	89 50 04             	mov    %edx,0x4(%eax)
f010515f:	8b 56 08             	mov    0x8(%esi),%edx
f0105162:	89 50 08             	mov    %edx,0x8(%eax)
f0105165:	8b 56 0c             	mov    0xc(%esi),%edx
f0105168:	89 50 0c             	mov    %edx,0xc(%eax)
f010516b:	8b 56 10             	mov    0x10(%esi),%edx
f010516e:	89 50 10             	mov    %edx,0x10(%eax)
f0105171:	8b 56 14             	mov    0x14(%esi),%edx
f0105174:	89 50 14             	mov    %edx,0x14(%eax)
f0105177:	8b 56 18             	mov    0x18(%esi),%edx
f010517a:	89 50 18             	mov    %edx,0x18(%eax)
f010517d:	8b 56 1c             	mov    0x1c(%esi),%edx
f0105180:	89 50 1c             	mov    %edx,0x1c(%eax)
	return 0;
f0105183:	bb 00 00 00 00       	mov    $0x0,%ebx
		return sys_env_set_trapframe((envid_t)a1, (struct Trapframe* )a2);
f0105188:	e9 52 fa ff ff       	jmp    f0104bdf <syscall+0x56>
	return time_msec();
f010518d:	e8 0e 20 00 00       	call   f01071a0 <time_msec>
f0105192:	89 c3                	mov    %eax,%ebx
		return sys_time_msec();
f0105194:	e9 46 fa ff ff       	jmp    f0104bdf <syscall+0x56>
	user_mem_assert(curenv, buf, len, PTE_P|PTE_U);
f0105199:	e8 f0 12 00 00       	call   f010648e <cpunum>
f010519e:	6a 05                	push   $0x5
f01051a0:	56                   	push   %esi
f01051a1:	ff 75 0c             	pushl  0xc(%ebp)
f01051a4:	6b c0 74             	imul   $0x74,%eax,%eax
f01051a7:	ff b0 28 00 2c f0    	pushl  -0xfd3ffd8(%eax)
f01051ad:	e8 22 e3 ff ff       	call   f01034d4 <user_mem_assert>
	return e1000_transmit(buf, len);
f01051b2:	83 c4 08             	add    $0x8,%esp
f01051b5:	56                   	push   %esi
f01051b6:	ff 75 0c             	pushl  0xc(%ebp)
f01051b9:	e8 5a 19 00 00       	call   f0106b18 <e1000_transmit>
f01051be:	89 c3                	mov    %eax,%ebx
		return sys_netpacket_try_send((void*)a1, (size_t)a2);
f01051c0:	83 c4 10             	add    $0x10,%esp
f01051c3:	e9 17 fa ff ff       	jmp    f0104bdf <syscall+0x56>
	return e1000_receive(buf, len);
f01051c8:	83 ec 08             	sub    $0x8,%esp
f01051cb:	56                   	push   %esi
f01051cc:	ff 75 0c             	pushl  0xc(%ebp)
f01051cf:	e8 cb 19 00 00       	call   f0106b9f <e1000_receive>
f01051d4:	89 c3                	mov    %eax,%ebx
		return sys_netpacket_recv((void*)a1, (size_t)a2);
f01051d6:	83 c4 10             	add    $0x10,%esp
f01051d9:	e9 01 fa ff ff       	jmp    f0104bdf <syscall+0x56>
		return 0;
f01051de:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01051e3:	e9 f7 f9 ff ff       	jmp    f0104bdf <syscall+0x56>

f01051e8 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01051e8:	55                   	push   %ebp
f01051e9:	89 e5                	mov    %esp,%ebp
f01051eb:	57                   	push   %edi
f01051ec:	56                   	push   %esi
f01051ed:	53                   	push   %ebx
f01051ee:	83 ec 14             	sub    $0x14,%esp
f01051f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01051f4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01051f7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01051fa:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01051fd:	8b 1a                	mov    (%edx),%ebx
f01051ff:	8b 01                	mov    (%ecx),%eax
f0105201:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105204:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010520b:	eb 23                	jmp    f0105230 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010520d:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0105210:	eb 1e                	jmp    f0105230 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105212:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105215:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105218:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010521c:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010521f:	73 46                	jae    f0105267 <stab_binsearch+0x7f>
			*region_left = m;
f0105221:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105224:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0105226:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0105229:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0105230:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0105233:	7f 5f                	jg     f0105294 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0105235:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105238:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f010523b:	89 d0                	mov    %edx,%eax
f010523d:	c1 e8 1f             	shr    $0x1f,%eax
f0105240:	01 d0                	add    %edx,%eax
f0105242:	89 c7                	mov    %eax,%edi
f0105244:	d1 ff                	sar    %edi
f0105246:	83 e0 fe             	and    $0xfffffffe,%eax
f0105249:	01 f8                	add    %edi,%eax
f010524b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010524e:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0105252:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0105254:	39 c3                	cmp    %eax,%ebx
f0105256:	7f b5                	jg     f010520d <stab_binsearch+0x25>
f0105258:	0f b6 0a             	movzbl (%edx),%ecx
f010525b:	83 ea 0c             	sub    $0xc,%edx
f010525e:	39 f1                	cmp    %esi,%ecx
f0105260:	74 b0                	je     f0105212 <stab_binsearch+0x2a>
			m--;
f0105262:	83 e8 01             	sub    $0x1,%eax
f0105265:	eb ed                	jmp    f0105254 <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0105267:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010526a:	76 14                	jbe    f0105280 <stab_binsearch+0x98>
			*region_right = m - 1;
f010526c:	83 e8 01             	sub    $0x1,%eax
f010526f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105272:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105275:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0105277:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010527e:	eb b0                	jmp    f0105230 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105280:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105283:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0105285:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105289:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f010528b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105292:	eb 9c                	jmp    f0105230 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0105294:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0105298:	75 15                	jne    f01052af <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f010529a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010529d:	8b 00                	mov    (%eax),%eax
f010529f:	83 e8 01             	sub    $0x1,%eax
f01052a2:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01052a5:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01052a7:	83 c4 14             	add    $0x14,%esp
f01052aa:	5b                   	pop    %ebx
f01052ab:	5e                   	pop    %esi
f01052ac:	5f                   	pop    %edi
f01052ad:	5d                   	pop    %ebp
f01052ae:	c3                   	ret    
		for (l = *region_right;
f01052af:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01052b2:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01052b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01052b7:	8b 0f                	mov    (%edi),%ecx
f01052b9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01052bc:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01052bf:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f01052c3:	eb 03                	jmp    f01052c8 <stab_binsearch+0xe0>
		     l--)
f01052c5:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f01052c8:	39 c1                	cmp    %eax,%ecx
f01052ca:	7d 0a                	jge    f01052d6 <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f01052cc:	0f b6 1a             	movzbl (%edx),%ebx
f01052cf:	83 ea 0c             	sub    $0xc,%edx
f01052d2:	39 f3                	cmp    %esi,%ebx
f01052d4:	75 ef                	jne    f01052c5 <stab_binsearch+0xdd>
		*region_left = l;
f01052d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01052d9:	89 07                	mov    %eax,(%edi)
}
f01052db:	eb ca                	jmp    f01052a7 <stab_binsearch+0xbf>

f01052dd <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01052dd:	f3 0f 1e fb          	endbr32 
f01052e1:	55                   	push   %ebp
f01052e2:	89 e5                	mov    %esp,%ebp
f01052e4:	57                   	push   %edi
f01052e5:	56                   	push   %esi
f01052e6:	53                   	push   %ebx
f01052e7:	83 ec 4c             	sub    $0x4c,%esp
f01052ea:	8b 7d 08             	mov    0x8(%ebp),%edi
f01052ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01052f0:	c7 03 cc 8f 10 f0    	movl   $0xf0108fcc,(%ebx)
	info->eip_line = 0;
f01052f6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01052fd:	c7 43 08 cc 8f 10 f0 	movl   $0xf0108fcc,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0105304:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010530b:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010530e:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105315:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f010531b:	0f 86 24 01 00 00    	jbe    f0105445 <debuginfo_eip+0x168>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105321:	c7 45 b8 11 c9 11 f0 	movl   $0xf011c911,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0105328:	c7 45 b4 15 84 11 f0 	movl   $0xf0118415,-0x4c(%ebp)
		stab_end = __STAB_END__;
f010532f:	be 14 84 11 f0       	mov    $0xf0118414,%esi
		stabs = __STAB_BEGIN__;
f0105334:	c7 45 bc d4 97 10 f0 	movl   $0xf01097d4,-0x44(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U)) return -1;

	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010533b:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f010533e:	39 4d b4             	cmp    %ecx,-0x4c(%ebp)
f0105341:	0f 83 65 02 00 00    	jae    f01055ac <debuginfo_eip+0x2cf>
f0105347:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f010534b:	0f 85 62 02 00 00    	jne    f01055b3 <debuginfo_eip+0x2d6>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105351:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105358:	2b 75 bc             	sub    -0x44(%ebp),%esi
f010535b:	c1 fe 02             	sar    $0x2,%esi
f010535e:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0105364:	83 e8 01             	sub    $0x1,%eax
f0105367:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010536a:	83 ec 08             	sub    $0x8,%esp
f010536d:	57                   	push   %edi
f010536e:	6a 64                	push   $0x64
f0105370:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0105373:	89 d1                	mov    %edx,%ecx
f0105375:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105378:	8b 75 bc             	mov    -0x44(%ebp),%esi
f010537b:	89 f0                	mov    %esi,%eax
f010537d:	e8 66 fe ff ff       	call   f01051e8 <stab_binsearch>
	if (lfile == 0)
f0105382:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105385:	83 c4 10             	add    $0x10,%esp
f0105388:	85 c0                	test   %eax,%eax
f010538a:	0f 84 2a 02 00 00    	je     f01055ba <debuginfo_eip+0x2dd>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105390:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105393:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105396:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105399:	83 ec 08             	sub    $0x8,%esp
f010539c:	57                   	push   %edi
f010539d:	6a 24                	push   $0x24
f010539f:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01053a2:	89 d1                	mov    %edx,%ecx
f01053a4:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01053a7:	89 f0                	mov    %esi,%eax
f01053a9:	e8 3a fe ff ff       	call   f01051e8 <stab_binsearch>

	if (lfun <= rfun) {
f01053ae:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01053b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01053b4:	83 c4 10             	add    $0x10,%esp
f01053b7:	39 d0                	cmp    %edx,%eax
f01053b9:	0f 8f 35 01 00 00    	jg     f01054f4 <debuginfo_eip+0x217>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01053bf:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01053c2:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f01053c5:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f01053c8:	8b 36                	mov    (%esi),%esi
f01053ca:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f01053cd:	2b 4d b4             	sub    -0x4c(%ebp),%ecx
f01053d0:	39 ce                	cmp    %ecx,%esi
f01053d2:	73 06                	jae    f01053da <debuginfo_eip+0xfd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01053d4:	03 75 b4             	add    -0x4c(%ebp),%esi
f01053d7:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01053da:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01053dd:	8b 4e 08             	mov    0x8(%esi),%ecx
f01053e0:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01053e3:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f01053e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01053e8:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01053eb:	83 ec 08             	sub    $0x8,%esp
f01053ee:	6a 3a                	push   $0x3a
f01053f0:	ff 73 08             	pushl  0x8(%ebx)
f01053f3:	e8 55 0a 00 00       	call   f0105e4d <strfind>
f01053f8:	2b 43 08             	sub    0x8(%ebx),%eax
f01053fb:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Lab 1: Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01053fe:	83 c4 08             	add    $0x8,%esp
f0105401:	57                   	push   %edi
f0105402:	6a 44                	push   $0x44
f0105404:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105407:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010540a:	8b 75 bc             	mov    -0x44(%ebp),%esi
f010540d:	89 f0                	mov    %esi,%eax
f010540f:	e8 d4 fd ff ff       	call   f01051e8 <stab_binsearch>
	if (lline<=rline){
f0105414:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105417:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010541a:	83 c4 10             	add    $0x10,%esp
f010541d:	39 c2                	cmp    %eax,%edx
f010541f:	0f 8f 9c 01 00 00    	jg     f01055c1 <debuginfo_eip+0x2e4>
		// An N_SLINE symbol represents the start of a source line.
		// The desc field contains the line number and the value contains the code address for the start of that source line.
		// On most machines the address is absolute; for stabs in sections (see Stab Sections), it is relative to the function in which the N_SLINE symbol occurs.
		// https://sourceware.org/gdb/onlinedocs/stabs.html#Line-Numbers
		info->eip_line = stabs[rline].n_desc;
f0105425:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105428:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f010542d:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105433:	89 d0                	mov    %edx,%eax
f0105435:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105438:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
f010543c:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0105440:	e9 cd 00 00 00       	jmp    f0105512 <debuginfo_eip+0x235>
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U)<0){
f0105445:	e8 44 10 00 00       	call   f010648e <cpunum>
f010544a:	6a 04                	push   $0x4
f010544c:	6a 10                	push   $0x10
f010544e:	68 00 00 20 00       	push   $0x200000
f0105453:	6b c0 74             	imul   $0x74,%eax,%eax
f0105456:	ff b0 28 00 2c f0    	pushl  -0xfd3ffd8(%eax)
f010545c:	e8 f0 df ff ff       	call   f0103451 <user_mem_check>
f0105461:	83 c4 10             	add    $0x10,%esp
f0105464:	85 c0                	test   %eax,%eax
f0105466:	0f 88 32 01 00 00    	js     f010559e <debuginfo_eip+0x2c1>
		stabs = usd->stabs;
f010546c:	8b 0d 00 00 20 00    	mov    0x200000,%ecx
f0105472:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		stab_end = usd->stab_end;
f0105475:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f010547b:	a1 08 00 20 00       	mov    0x200008,%eax
f0105480:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0105483:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0105489:	89 55 b8             	mov    %edx,-0x48(%ebp)
		if (user_mem_check(curenv, stabs, stab_end-stabs, PTE_U)) return -1;
f010548c:	e8 fd 0f 00 00       	call   f010648e <cpunum>
f0105491:	89 c2                	mov    %eax,%edx
f0105493:	6a 04                	push   $0x4
f0105495:	89 f0                	mov    %esi,%eax
f0105497:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f010549a:	29 c8                	sub    %ecx,%eax
f010549c:	c1 f8 02             	sar    $0x2,%eax
f010549f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01054a5:	50                   	push   %eax
f01054a6:	51                   	push   %ecx
f01054a7:	6b d2 74             	imul   $0x74,%edx,%edx
f01054aa:	ff b2 28 00 2c f0    	pushl  -0xfd3ffd8(%edx)
f01054b0:	e8 9c df ff ff       	call   f0103451 <user_mem_check>
f01054b5:	83 c4 10             	add    $0x10,%esp
f01054b8:	85 c0                	test   %eax,%eax
f01054ba:	0f 85 e5 00 00 00    	jne    f01055a5 <debuginfo_eip+0x2c8>
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U)) return -1;
f01054c0:	e8 c9 0f 00 00       	call   f010648e <cpunum>
f01054c5:	6a 04                	push   $0x4
f01054c7:	8b 55 b8             	mov    -0x48(%ebp),%edx
f01054ca:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f01054cd:	29 ca                	sub    %ecx,%edx
f01054cf:	52                   	push   %edx
f01054d0:	51                   	push   %ecx
f01054d1:	6b c0 74             	imul   $0x74,%eax,%eax
f01054d4:	ff b0 28 00 2c f0    	pushl  -0xfd3ffd8(%eax)
f01054da:	e8 72 df ff ff       	call   f0103451 <user_mem_check>
f01054df:	83 c4 10             	add    $0x10,%esp
f01054e2:	85 c0                	test   %eax,%eax
f01054e4:	0f 84 51 fe ff ff    	je     f010533b <debuginfo_eip+0x5e>
f01054ea:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01054ef:	e9 d9 00 00 00       	jmp    f01055cd <debuginfo_eip+0x2f0>
		info->eip_fn_addr = addr;
f01054f4:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f01054f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01054fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105500:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105503:	e9 e3 fe ff ff       	jmp    f01053eb <debuginfo_eip+0x10e>
f0105508:	83 e8 01             	sub    $0x1,%eax
f010550b:	83 ea 0c             	sub    $0xc,%edx
	while (lline >= lfile
f010550e:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0105512:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0105515:	39 c7                	cmp    %eax,%edi
f0105517:	7f 45                	jg     f010555e <debuginfo_eip+0x281>
	       && stabs[lline].n_type != N_SOL
f0105519:	0f b6 0a             	movzbl (%edx),%ecx
f010551c:	80 f9 84             	cmp    $0x84,%cl
f010551f:	74 19                	je     f010553a <debuginfo_eip+0x25d>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105521:	80 f9 64             	cmp    $0x64,%cl
f0105524:	75 e2                	jne    f0105508 <debuginfo_eip+0x22b>
f0105526:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f010552a:	74 dc                	je     f0105508 <debuginfo_eip+0x22b>
f010552c:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105530:	74 11                	je     f0105543 <debuginfo_eip+0x266>
f0105532:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105535:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105538:	eb 09                	jmp    f0105543 <debuginfo_eip+0x266>
f010553a:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f010553e:	74 03                	je     f0105543 <debuginfo_eip+0x266>
f0105540:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105543:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105546:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0105549:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010554c:	8b 45 b8             	mov    -0x48(%ebp),%eax
f010554f:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0105552:	29 f8                	sub    %edi,%eax
f0105554:	39 c2                	cmp    %eax,%edx
f0105556:	73 06                	jae    f010555e <debuginfo_eip+0x281>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105558:	89 f8                	mov    %edi,%eax
f010555a:	01 d0                	add    %edx,%eax
f010555c:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010555e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105561:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105564:	ba 00 00 00 00       	mov    $0x0,%edx
	if (lfun < rfun)
f0105569:	39 f0                	cmp    %esi,%eax
f010556b:	7d 60                	jge    f01055cd <debuginfo_eip+0x2f0>
		for (lline = lfun + 1;
f010556d:	8d 50 01             	lea    0x1(%eax),%edx
f0105570:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105573:	89 d0                	mov    %edx,%eax
f0105575:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105578:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010557b:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f010557f:	eb 04                	jmp    f0105585 <debuginfo_eip+0x2a8>
			info->eip_fn_narg++;
f0105581:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f0105585:	39 c6                	cmp    %eax,%esi
f0105587:	7e 3f                	jle    f01055c8 <debuginfo_eip+0x2eb>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105589:	0f b6 0a             	movzbl (%edx),%ecx
f010558c:	83 c0 01             	add    $0x1,%eax
f010558f:	83 c2 0c             	add    $0xc,%edx
f0105592:	80 f9 a0             	cmp    $0xa0,%cl
f0105595:	74 ea                	je     f0105581 <debuginfo_eip+0x2a4>
	return 0;
f0105597:	ba 00 00 00 00       	mov    $0x0,%edx
f010559c:	eb 2f                	jmp    f01055cd <debuginfo_eip+0x2f0>
			return -1;
f010559e:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01055a3:	eb 28                	jmp    f01055cd <debuginfo_eip+0x2f0>
		if (user_mem_check(curenv, stabs, stab_end-stabs, PTE_U)) return -1;
f01055a5:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01055aa:	eb 21                	jmp    f01055cd <debuginfo_eip+0x2f0>
		return -1;
f01055ac:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01055b1:	eb 1a                	jmp    f01055cd <debuginfo_eip+0x2f0>
f01055b3:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01055b8:	eb 13                	jmp    f01055cd <debuginfo_eip+0x2f0>
		return -1;
f01055ba:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01055bf:	eb 0c                	jmp    f01055cd <debuginfo_eip+0x2f0>
		return -1; //not found
f01055c1:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01055c6:	eb 05                	jmp    f01055cd <debuginfo_eip+0x2f0>
	return 0;
f01055c8:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01055cd:	89 d0                	mov    %edx,%eax
f01055cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01055d2:	5b                   	pop    %ebx
f01055d3:	5e                   	pop    %esi
f01055d4:	5f                   	pop    %edi
f01055d5:	5d                   	pop    %ebp
f01055d6:	c3                   	ret    

f01055d7 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01055d7:	55                   	push   %ebp
f01055d8:	89 e5                	mov    %esp,%ebp
f01055da:	57                   	push   %edi
f01055db:	56                   	push   %esi
f01055dc:	53                   	push   %ebx
f01055dd:	83 ec 1c             	sub    $0x1c,%esp
f01055e0:	89 c7                	mov    %eax,%edi
f01055e2:	89 d6                	mov    %edx,%esi
f01055e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01055e7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01055ea:	89 d1                	mov    %edx,%ecx
f01055ec:	89 c2                	mov    %eax,%edx
f01055ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01055f1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01055f4:	8b 45 10             	mov    0x10(%ebp),%eax
f01055f7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
f01055fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01055fd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0105604:	39 c2                	cmp    %eax,%edx
f0105606:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0105609:	72 3e                	jb     f0105649 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010560b:	83 ec 0c             	sub    $0xc,%esp
f010560e:	ff 75 18             	pushl  0x18(%ebp)
f0105611:	83 eb 01             	sub    $0x1,%ebx
f0105614:	53                   	push   %ebx
f0105615:	50                   	push   %eax
f0105616:	83 ec 08             	sub    $0x8,%esp
f0105619:	ff 75 e4             	pushl  -0x1c(%ebp)
f010561c:	ff 75 e0             	pushl  -0x20(%ebp)
f010561f:	ff 75 dc             	pushl  -0x24(%ebp)
f0105622:	ff 75 d8             	pushl  -0x28(%ebp)
f0105625:	e8 86 1b 00 00       	call   f01071b0 <__udivdi3>
f010562a:	83 c4 18             	add    $0x18,%esp
f010562d:	52                   	push   %edx
f010562e:	50                   	push   %eax
f010562f:	89 f2                	mov    %esi,%edx
f0105631:	89 f8                	mov    %edi,%eax
f0105633:	e8 9f ff ff ff       	call   f01055d7 <printnum>
f0105638:	83 c4 20             	add    $0x20,%esp
f010563b:	eb 13                	jmp    f0105650 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010563d:	83 ec 08             	sub    $0x8,%esp
f0105640:	56                   	push   %esi
f0105641:	ff 75 18             	pushl  0x18(%ebp)
f0105644:	ff d7                	call   *%edi
f0105646:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0105649:	83 eb 01             	sub    $0x1,%ebx
f010564c:	85 db                	test   %ebx,%ebx
f010564e:	7f ed                	jg     f010563d <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105650:	83 ec 08             	sub    $0x8,%esp
f0105653:	56                   	push   %esi
f0105654:	83 ec 04             	sub    $0x4,%esp
f0105657:	ff 75 e4             	pushl  -0x1c(%ebp)
f010565a:	ff 75 e0             	pushl  -0x20(%ebp)
f010565d:	ff 75 dc             	pushl  -0x24(%ebp)
f0105660:	ff 75 d8             	pushl  -0x28(%ebp)
f0105663:	e8 58 1c 00 00       	call   f01072c0 <__umoddi3>
f0105668:	83 c4 14             	add    $0x14,%esp
f010566b:	0f be 80 d6 8f 10 f0 	movsbl -0xfef702a(%eax),%eax
f0105672:	50                   	push   %eax
f0105673:	ff d7                	call   *%edi
}
f0105675:	83 c4 10             	add    $0x10,%esp
f0105678:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010567b:	5b                   	pop    %ebx
f010567c:	5e                   	pop    %esi
f010567d:	5f                   	pop    %edi
f010567e:	5d                   	pop    %ebp
f010567f:	c3                   	ret    

f0105680 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105680:	f3 0f 1e fb          	endbr32 
f0105684:	55                   	push   %ebp
f0105685:	89 e5                	mov    %esp,%ebp
f0105687:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010568a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010568e:	8b 10                	mov    (%eax),%edx
f0105690:	3b 50 04             	cmp    0x4(%eax),%edx
f0105693:	73 0a                	jae    f010569f <sprintputch+0x1f>
		*b->buf++ = ch;
f0105695:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105698:	89 08                	mov    %ecx,(%eax)
f010569a:	8b 45 08             	mov    0x8(%ebp),%eax
f010569d:	88 02                	mov    %al,(%edx)
}
f010569f:	5d                   	pop    %ebp
f01056a0:	c3                   	ret    

f01056a1 <printfmt>:
{
f01056a1:	f3 0f 1e fb          	endbr32 
f01056a5:	55                   	push   %ebp
f01056a6:	89 e5                	mov    %esp,%ebp
f01056a8:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01056ab:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01056ae:	50                   	push   %eax
f01056af:	ff 75 10             	pushl  0x10(%ebp)
f01056b2:	ff 75 0c             	pushl  0xc(%ebp)
f01056b5:	ff 75 08             	pushl  0x8(%ebp)
f01056b8:	e8 05 00 00 00       	call   f01056c2 <vprintfmt>
}
f01056bd:	83 c4 10             	add    $0x10,%esp
f01056c0:	c9                   	leave  
f01056c1:	c3                   	ret    

f01056c2 <vprintfmt>:
{
f01056c2:	f3 0f 1e fb          	endbr32 
f01056c6:	55                   	push   %ebp
f01056c7:	89 e5                	mov    %esp,%ebp
f01056c9:	57                   	push   %edi
f01056ca:	56                   	push   %esi
f01056cb:	53                   	push   %ebx
f01056cc:	83 ec 3c             	sub    $0x3c,%esp
f01056cf:	8b 75 08             	mov    0x8(%ebp),%esi
f01056d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01056d5:	8b 7d 10             	mov    0x10(%ebp),%edi
f01056d8:	e9 8e 03 00 00       	jmp    f0105a6b <vprintfmt+0x3a9>
		padc = ' ';
f01056dd:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f01056e1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f01056e8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f01056ef:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f01056f6:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01056fb:	8d 47 01             	lea    0x1(%edi),%eax
f01056fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105701:	0f b6 17             	movzbl (%edi),%edx
f0105704:	8d 42 dd             	lea    -0x23(%edx),%eax
f0105707:	3c 55                	cmp    $0x55,%al
f0105709:	0f 87 df 03 00 00    	ja     f0105aee <vprintfmt+0x42c>
f010570f:	0f b6 c0             	movzbl %al,%eax
f0105712:	3e ff 24 85 20 91 10 	notrack jmp *-0xfef6ee0(,%eax,4)
f0105719:	f0 
f010571a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f010571d:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f0105721:	eb d8                	jmp    f01056fb <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f0105723:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105726:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f010572a:	eb cf                	jmp    f01056fb <vprintfmt+0x39>
f010572c:	0f b6 d2             	movzbl %dl,%edx
f010572f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0105732:	b8 00 00 00 00       	mov    $0x0,%eax
f0105737:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
f010573a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010573d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0105741:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0105744:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0105747:	83 f9 09             	cmp    $0x9,%ecx
f010574a:	77 55                	ja     f01057a1 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
f010574c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
f010574f:	eb e9                	jmp    f010573a <vprintfmt+0x78>
			precision = va_arg(ap, int);
f0105751:	8b 45 14             	mov    0x14(%ebp),%eax
f0105754:	8b 00                	mov    (%eax),%eax
f0105756:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105759:	8b 45 14             	mov    0x14(%ebp),%eax
f010575c:	8d 40 04             	lea    0x4(%eax),%eax
f010575f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105762:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0105765:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105769:	79 90                	jns    f01056fb <vprintfmt+0x39>
				width = precision, precision = -1;
f010576b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010576e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105771:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0105778:	eb 81                	jmp    f01056fb <vprintfmt+0x39>
f010577a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010577d:	85 c0                	test   %eax,%eax
f010577f:	ba 00 00 00 00       	mov    $0x0,%edx
f0105784:	0f 49 d0             	cmovns %eax,%edx
f0105787:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010578a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f010578d:	e9 69 ff ff ff       	jmp    f01056fb <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f0105792:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0105795:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f010579c:	e9 5a ff ff ff       	jmp    f01056fb <vprintfmt+0x39>
f01057a1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01057a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01057a7:	eb bc                	jmp    f0105765 <vprintfmt+0xa3>
			lflag++;
f01057a9:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01057ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01057af:	e9 47 ff ff ff       	jmp    f01056fb <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
f01057b4:	8b 45 14             	mov    0x14(%ebp),%eax
f01057b7:	8d 78 04             	lea    0x4(%eax),%edi
f01057ba:	83 ec 08             	sub    $0x8,%esp
f01057bd:	53                   	push   %ebx
f01057be:	ff 30                	pushl  (%eax)
f01057c0:	ff d6                	call   *%esi
			break;
f01057c2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01057c5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01057c8:	e9 9b 02 00 00       	jmp    f0105a68 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
f01057cd:	8b 45 14             	mov    0x14(%ebp),%eax
f01057d0:	8d 78 04             	lea    0x4(%eax),%edi
f01057d3:	8b 00                	mov    (%eax),%eax
f01057d5:	99                   	cltd   
f01057d6:	31 d0                	xor    %edx,%eax
f01057d8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01057da:	83 f8 0f             	cmp    $0xf,%eax
f01057dd:	7f 23                	jg     f0105802 <vprintfmt+0x140>
f01057df:	8b 14 85 80 92 10 f0 	mov    -0xfef6d80(,%eax,4),%edx
f01057e6:	85 d2                	test   %edx,%edx
f01057e8:	74 18                	je     f0105802 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
f01057ea:	52                   	push   %edx
f01057eb:	68 45 87 10 f0       	push   $0xf0108745
f01057f0:	53                   	push   %ebx
f01057f1:	56                   	push   %esi
f01057f2:	e8 aa fe ff ff       	call   f01056a1 <printfmt>
f01057f7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01057fa:	89 7d 14             	mov    %edi,0x14(%ebp)
f01057fd:	e9 66 02 00 00       	jmp    f0105a68 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
f0105802:	50                   	push   %eax
f0105803:	68 ee 8f 10 f0       	push   $0xf0108fee
f0105808:	53                   	push   %ebx
f0105809:	56                   	push   %esi
f010580a:	e8 92 fe ff ff       	call   f01056a1 <printfmt>
f010580f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105812:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0105815:	e9 4e 02 00 00       	jmp    f0105a68 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
f010581a:	8b 45 14             	mov    0x14(%ebp),%eax
f010581d:	83 c0 04             	add    $0x4,%eax
f0105820:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0105823:	8b 45 14             	mov    0x14(%ebp),%eax
f0105826:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0105828:	85 d2                	test   %edx,%edx
f010582a:	b8 e7 8f 10 f0       	mov    $0xf0108fe7,%eax
f010582f:	0f 45 c2             	cmovne %edx,%eax
f0105832:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f0105835:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105839:	7e 06                	jle    f0105841 <vprintfmt+0x17f>
f010583b:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f010583f:	75 0d                	jne    f010584e <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105841:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105844:	89 c7                	mov    %eax,%edi
f0105846:	03 45 e0             	add    -0x20(%ebp),%eax
f0105849:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010584c:	eb 55                	jmp    f01058a3 <vprintfmt+0x1e1>
f010584e:	83 ec 08             	sub    $0x8,%esp
f0105851:	ff 75 d8             	pushl  -0x28(%ebp)
f0105854:	ff 75 cc             	pushl  -0x34(%ebp)
f0105857:	e8 38 04 00 00       	call   f0105c94 <strnlen>
f010585c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010585f:	29 c2                	sub    %eax,%edx
f0105861:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0105864:	83 c4 10             	add    $0x10,%esp
f0105867:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
f0105869:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f010586d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0105870:	85 ff                	test   %edi,%edi
f0105872:	7e 11                	jle    f0105885 <vprintfmt+0x1c3>
					putch(padc, putdat);
f0105874:	83 ec 08             	sub    $0x8,%esp
f0105877:	53                   	push   %ebx
f0105878:	ff 75 e0             	pushl  -0x20(%ebp)
f010587b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f010587d:	83 ef 01             	sub    $0x1,%edi
f0105880:	83 c4 10             	add    $0x10,%esp
f0105883:	eb eb                	jmp    f0105870 <vprintfmt+0x1ae>
f0105885:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105888:	85 d2                	test   %edx,%edx
f010588a:	b8 00 00 00 00       	mov    $0x0,%eax
f010588f:	0f 49 c2             	cmovns %edx,%eax
f0105892:	29 c2                	sub    %eax,%edx
f0105894:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0105897:	eb a8                	jmp    f0105841 <vprintfmt+0x17f>
					putch(ch, putdat);
f0105899:	83 ec 08             	sub    $0x8,%esp
f010589c:	53                   	push   %ebx
f010589d:	52                   	push   %edx
f010589e:	ff d6                	call   *%esi
f01058a0:	83 c4 10             	add    $0x10,%esp
f01058a3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01058a6:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01058a8:	83 c7 01             	add    $0x1,%edi
f01058ab:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01058af:	0f be d0             	movsbl %al,%edx
f01058b2:	85 d2                	test   %edx,%edx
f01058b4:	74 4b                	je     f0105901 <vprintfmt+0x23f>
f01058b6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01058ba:	78 06                	js     f01058c2 <vprintfmt+0x200>
f01058bc:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f01058c0:	78 1e                	js     f01058e0 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
f01058c2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01058c6:	74 d1                	je     f0105899 <vprintfmt+0x1d7>
f01058c8:	0f be c0             	movsbl %al,%eax
f01058cb:	83 e8 20             	sub    $0x20,%eax
f01058ce:	83 f8 5e             	cmp    $0x5e,%eax
f01058d1:	76 c6                	jbe    f0105899 <vprintfmt+0x1d7>
					putch('?', putdat);
f01058d3:	83 ec 08             	sub    $0x8,%esp
f01058d6:	53                   	push   %ebx
f01058d7:	6a 3f                	push   $0x3f
f01058d9:	ff d6                	call   *%esi
f01058db:	83 c4 10             	add    $0x10,%esp
f01058de:	eb c3                	jmp    f01058a3 <vprintfmt+0x1e1>
f01058e0:	89 cf                	mov    %ecx,%edi
f01058e2:	eb 0e                	jmp    f01058f2 <vprintfmt+0x230>
				putch(' ', putdat);
f01058e4:	83 ec 08             	sub    $0x8,%esp
f01058e7:	53                   	push   %ebx
f01058e8:	6a 20                	push   $0x20
f01058ea:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01058ec:	83 ef 01             	sub    $0x1,%edi
f01058ef:	83 c4 10             	add    $0x10,%esp
f01058f2:	85 ff                	test   %edi,%edi
f01058f4:	7f ee                	jg     f01058e4 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
f01058f6:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01058f9:	89 45 14             	mov    %eax,0x14(%ebp)
f01058fc:	e9 67 01 00 00       	jmp    f0105a68 <vprintfmt+0x3a6>
f0105901:	89 cf                	mov    %ecx,%edi
f0105903:	eb ed                	jmp    f01058f2 <vprintfmt+0x230>
	if (lflag >= 2)
f0105905:	83 f9 01             	cmp    $0x1,%ecx
f0105908:	7f 1b                	jg     f0105925 <vprintfmt+0x263>
	else if (lflag)
f010590a:	85 c9                	test   %ecx,%ecx
f010590c:	74 63                	je     f0105971 <vprintfmt+0x2af>
		return va_arg(*ap, long);
f010590e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105911:	8b 00                	mov    (%eax),%eax
f0105913:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105916:	99                   	cltd   
f0105917:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010591a:	8b 45 14             	mov    0x14(%ebp),%eax
f010591d:	8d 40 04             	lea    0x4(%eax),%eax
f0105920:	89 45 14             	mov    %eax,0x14(%ebp)
f0105923:	eb 17                	jmp    f010593c <vprintfmt+0x27a>
		return va_arg(*ap, long long);
f0105925:	8b 45 14             	mov    0x14(%ebp),%eax
f0105928:	8b 50 04             	mov    0x4(%eax),%edx
f010592b:	8b 00                	mov    (%eax),%eax
f010592d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105930:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105933:	8b 45 14             	mov    0x14(%ebp),%eax
f0105936:	8d 40 08             	lea    0x8(%eax),%eax
f0105939:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f010593c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010593f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0105942:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0105947:	85 c9                	test   %ecx,%ecx
f0105949:	0f 89 ff 00 00 00    	jns    f0105a4e <vprintfmt+0x38c>
				putch('-', putdat);
f010594f:	83 ec 08             	sub    $0x8,%esp
f0105952:	53                   	push   %ebx
f0105953:	6a 2d                	push   $0x2d
f0105955:	ff d6                	call   *%esi
				num = -(long long) num;
f0105957:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010595a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010595d:	f7 da                	neg    %edx
f010595f:	83 d1 00             	adc    $0x0,%ecx
f0105962:	f7 d9                	neg    %ecx
f0105964:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0105967:	b8 0a 00 00 00       	mov    $0xa,%eax
f010596c:	e9 dd 00 00 00       	jmp    f0105a4e <vprintfmt+0x38c>
		return va_arg(*ap, int);
f0105971:	8b 45 14             	mov    0x14(%ebp),%eax
f0105974:	8b 00                	mov    (%eax),%eax
f0105976:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105979:	99                   	cltd   
f010597a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010597d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105980:	8d 40 04             	lea    0x4(%eax),%eax
f0105983:	89 45 14             	mov    %eax,0x14(%ebp)
f0105986:	eb b4                	jmp    f010593c <vprintfmt+0x27a>
	if (lflag >= 2)
f0105988:	83 f9 01             	cmp    $0x1,%ecx
f010598b:	7f 1e                	jg     f01059ab <vprintfmt+0x2e9>
	else if (lflag)
f010598d:	85 c9                	test   %ecx,%ecx
f010598f:	74 32                	je     f01059c3 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
f0105991:	8b 45 14             	mov    0x14(%ebp),%eax
f0105994:	8b 10                	mov    (%eax),%edx
f0105996:	b9 00 00 00 00       	mov    $0x0,%ecx
f010599b:	8d 40 04             	lea    0x4(%eax),%eax
f010599e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01059a1:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f01059a6:	e9 a3 00 00 00       	jmp    f0105a4e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
f01059ab:	8b 45 14             	mov    0x14(%ebp),%eax
f01059ae:	8b 10                	mov    (%eax),%edx
f01059b0:	8b 48 04             	mov    0x4(%eax),%ecx
f01059b3:	8d 40 08             	lea    0x8(%eax),%eax
f01059b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01059b9:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f01059be:	e9 8b 00 00 00       	jmp    f0105a4e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
f01059c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01059c6:	8b 10                	mov    (%eax),%edx
f01059c8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01059cd:	8d 40 04             	lea    0x4(%eax),%eax
f01059d0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01059d3:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f01059d8:	eb 74                	jmp    f0105a4e <vprintfmt+0x38c>
	if (lflag >= 2)
f01059da:	83 f9 01             	cmp    $0x1,%ecx
f01059dd:	7f 1b                	jg     f01059fa <vprintfmt+0x338>
	else if (lflag)
f01059df:	85 c9                	test   %ecx,%ecx
f01059e1:	74 2c                	je     f0105a0f <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
f01059e3:	8b 45 14             	mov    0x14(%ebp),%eax
f01059e6:	8b 10                	mov    (%eax),%edx
f01059e8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01059ed:	8d 40 04             	lea    0x4(%eax),%eax
f01059f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01059f3:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
f01059f8:	eb 54                	jmp    f0105a4e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
f01059fa:	8b 45 14             	mov    0x14(%ebp),%eax
f01059fd:	8b 10                	mov    (%eax),%edx
f01059ff:	8b 48 04             	mov    0x4(%eax),%ecx
f0105a02:	8d 40 08             	lea    0x8(%eax),%eax
f0105a05:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105a08:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
f0105a0d:	eb 3f                	jmp    f0105a4e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
f0105a0f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a12:	8b 10                	mov    (%eax),%edx
f0105a14:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105a19:	8d 40 04             	lea    0x4(%eax),%eax
f0105a1c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105a1f:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
f0105a24:	eb 28                	jmp    f0105a4e <vprintfmt+0x38c>
			putch('0', putdat);
f0105a26:	83 ec 08             	sub    $0x8,%esp
f0105a29:	53                   	push   %ebx
f0105a2a:	6a 30                	push   $0x30
f0105a2c:	ff d6                	call   *%esi
			putch('x', putdat);
f0105a2e:	83 c4 08             	add    $0x8,%esp
f0105a31:	53                   	push   %ebx
f0105a32:	6a 78                	push   $0x78
f0105a34:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105a36:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a39:	8b 10                	mov    (%eax),%edx
f0105a3b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0105a40:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0105a43:	8d 40 04             	lea    0x4(%eax),%eax
f0105a46:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105a49:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0105a4e:	83 ec 0c             	sub    $0xc,%esp
f0105a51:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f0105a55:	57                   	push   %edi
f0105a56:	ff 75 e0             	pushl  -0x20(%ebp)
f0105a59:	50                   	push   %eax
f0105a5a:	51                   	push   %ecx
f0105a5b:	52                   	push   %edx
f0105a5c:	89 da                	mov    %ebx,%edx
f0105a5e:	89 f0                	mov    %esi,%eax
f0105a60:	e8 72 fb ff ff       	call   f01055d7 <printnum>
			break;
f0105a65:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f0105a68:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
f0105a6b:	83 c7 01             	add    $0x1,%edi
f0105a6e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105a72:	83 f8 25             	cmp    $0x25,%eax
f0105a75:	0f 84 62 fc ff ff    	je     f01056dd <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
f0105a7b:	85 c0                	test   %eax,%eax
f0105a7d:	0f 84 8b 00 00 00    	je     f0105b0e <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
f0105a83:	83 ec 08             	sub    $0x8,%esp
f0105a86:	53                   	push   %ebx
f0105a87:	50                   	push   %eax
f0105a88:	ff d6                	call   *%esi
f0105a8a:	83 c4 10             	add    $0x10,%esp
f0105a8d:	eb dc                	jmp    f0105a6b <vprintfmt+0x3a9>
	if (lflag >= 2)
f0105a8f:	83 f9 01             	cmp    $0x1,%ecx
f0105a92:	7f 1b                	jg     f0105aaf <vprintfmt+0x3ed>
	else if (lflag)
f0105a94:	85 c9                	test   %ecx,%ecx
f0105a96:	74 2c                	je     f0105ac4 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
f0105a98:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a9b:	8b 10                	mov    (%eax),%edx
f0105a9d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105aa2:	8d 40 04             	lea    0x4(%eax),%eax
f0105aa5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105aa8:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f0105aad:	eb 9f                	jmp    f0105a4e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
f0105aaf:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ab2:	8b 10                	mov    (%eax),%edx
f0105ab4:	8b 48 04             	mov    0x4(%eax),%ecx
f0105ab7:	8d 40 08             	lea    0x8(%eax),%eax
f0105aba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105abd:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f0105ac2:	eb 8a                	jmp    f0105a4e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
f0105ac4:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ac7:	8b 10                	mov    (%eax),%edx
f0105ac9:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105ace:	8d 40 04             	lea    0x4(%eax),%eax
f0105ad1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105ad4:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f0105ad9:	e9 70 ff ff ff       	jmp    f0105a4e <vprintfmt+0x38c>
			putch(ch, putdat);
f0105ade:	83 ec 08             	sub    $0x8,%esp
f0105ae1:	53                   	push   %ebx
f0105ae2:	6a 25                	push   $0x25
f0105ae4:	ff d6                	call   *%esi
			break;
f0105ae6:	83 c4 10             	add    $0x10,%esp
f0105ae9:	e9 7a ff ff ff       	jmp    f0105a68 <vprintfmt+0x3a6>
			putch('%', putdat);
f0105aee:	83 ec 08             	sub    $0x8,%esp
f0105af1:	53                   	push   %ebx
f0105af2:	6a 25                	push   $0x25
f0105af4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
f0105af6:	83 c4 10             	add    $0x10,%esp
f0105af9:	89 f8                	mov    %edi,%eax
f0105afb:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0105aff:	74 05                	je     f0105b06 <vprintfmt+0x444>
f0105b01:	83 e8 01             	sub    $0x1,%eax
f0105b04:	eb f5                	jmp    f0105afb <vprintfmt+0x439>
f0105b06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b09:	e9 5a ff ff ff       	jmp    f0105a68 <vprintfmt+0x3a6>
}
f0105b0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105b11:	5b                   	pop    %ebx
f0105b12:	5e                   	pop    %esi
f0105b13:	5f                   	pop    %edi
f0105b14:	5d                   	pop    %ebp
f0105b15:	c3                   	ret    

f0105b16 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105b16:	f3 0f 1e fb          	endbr32 
f0105b1a:	55                   	push   %ebp
f0105b1b:	89 e5                	mov    %esp,%ebp
f0105b1d:	83 ec 18             	sub    $0x18,%esp
f0105b20:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b23:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105b26:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105b29:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105b2d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105b30:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105b37:	85 c0                	test   %eax,%eax
f0105b39:	74 26                	je     f0105b61 <vsnprintf+0x4b>
f0105b3b:	85 d2                	test   %edx,%edx
f0105b3d:	7e 22                	jle    f0105b61 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105b3f:	ff 75 14             	pushl  0x14(%ebp)
f0105b42:	ff 75 10             	pushl  0x10(%ebp)
f0105b45:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105b48:	50                   	push   %eax
f0105b49:	68 80 56 10 f0       	push   $0xf0105680
f0105b4e:	e8 6f fb ff ff       	call   f01056c2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105b53:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105b56:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105b5c:	83 c4 10             	add    $0x10,%esp
}
f0105b5f:	c9                   	leave  
f0105b60:	c3                   	ret    
		return -E_INVAL;
f0105b61:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105b66:	eb f7                	jmp    f0105b5f <vsnprintf+0x49>

f0105b68 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105b68:	f3 0f 1e fb          	endbr32 
f0105b6c:	55                   	push   %ebp
f0105b6d:	89 e5                	mov    %esp,%ebp
f0105b6f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
f0105b72:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105b75:	50                   	push   %eax
f0105b76:	ff 75 10             	pushl  0x10(%ebp)
f0105b79:	ff 75 0c             	pushl  0xc(%ebp)
f0105b7c:	ff 75 08             	pushl  0x8(%ebp)
f0105b7f:	e8 92 ff ff ff       	call   f0105b16 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105b84:	c9                   	leave  
f0105b85:	c3                   	ret    

f0105b86 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105b86:	f3 0f 1e fb          	endbr32 
f0105b8a:	55                   	push   %ebp
f0105b8b:	89 e5                	mov    %esp,%ebp
f0105b8d:	57                   	push   %edi
f0105b8e:	56                   	push   %esi
f0105b8f:	53                   	push   %ebx
f0105b90:	83 ec 0c             	sub    $0xc,%esp
f0105b93:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105b96:	85 c0                	test   %eax,%eax
f0105b98:	74 11                	je     f0105bab <readline+0x25>
		cprintf("%s", prompt);
f0105b9a:	83 ec 08             	sub    $0x8,%esp
f0105b9d:	50                   	push   %eax
f0105b9e:	68 45 87 10 f0       	push   $0xf0108745
f0105ba3:	e8 88 e2 ff ff       	call   f0103e30 <cprintf>
f0105ba8:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105bab:	83 ec 0c             	sub    $0xc,%esp
f0105bae:	6a 00                	push   $0x0
f0105bb0:	e8 36 ac ff ff       	call   f01007eb <iscons>
f0105bb5:	89 c7                	mov    %eax,%edi
f0105bb7:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0105bba:	be 00 00 00 00       	mov    $0x0,%esi
f0105bbf:	eb 57                	jmp    f0105c18 <readline+0x92>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105bc1:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
f0105bc6:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0105bc9:	75 08                	jne    f0105bd3 <readline+0x4d>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105bcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105bce:	5b                   	pop    %ebx
f0105bcf:	5e                   	pop    %esi
f0105bd0:	5f                   	pop    %edi
f0105bd1:	5d                   	pop    %ebp
f0105bd2:	c3                   	ret    
				cprintf("read error: %e\n", c);
f0105bd3:	83 ec 08             	sub    $0x8,%esp
f0105bd6:	53                   	push   %ebx
f0105bd7:	68 df 92 10 f0       	push   $0xf01092df
f0105bdc:	e8 4f e2 ff ff       	call   f0103e30 <cprintf>
f0105be1:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0105be4:	b8 00 00 00 00       	mov    $0x0,%eax
f0105be9:	eb e0                	jmp    f0105bcb <readline+0x45>
			if (echoing)
f0105beb:	85 ff                	test   %edi,%edi
f0105bed:	75 05                	jne    f0105bf4 <readline+0x6e>
			i--;
f0105bef:	83 ee 01             	sub    $0x1,%esi
f0105bf2:	eb 24                	jmp    f0105c18 <readline+0x92>
				cputchar('\b');
f0105bf4:	83 ec 0c             	sub    $0xc,%esp
f0105bf7:	6a 08                	push   $0x8
f0105bf9:	e8 c4 ab ff ff       	call   f01007c2 <cputchar>
f0105bfe:	83 c4 10             	add    $0x10,%esp
f0105c01:	eb ec                	jmp    f0105bef <readline+0x69>
				cputchar(c);
f0105c03:	83 ec 0c             	sub    $0xc,%esp
f0105c06:	53                   	push   %ebx
f0105c07:	e8 b6 ab ff ff       	call   f01007c2 <cputchar>
f0105c0c:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105c0f:	88 9e 80 da 2b f0    	mov    %bl,-0xfd42580(%esi)
f0105c15:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0105c18:	e8 b9 ab ff ff       	call   f01007d6 <getchar>
f0105c1d:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105c1f:	85 c0                	test   %eax,%eax
f0105c21:	78 9e                	js     f0105bc1 <readline+0x3b>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105c23:	83 f8 08             	cmp    $0x8,%eax
f0105c26:	0f 94 c2             	sete   %dl
f0105c29:	83 f8 7f             	cmp    $0x7f,%eax
f0105c2c:	0f 94 c0             	sete   %al
f0105c2f:	08 c2                	or     %al,%dl
f0105c31:	74 04                	je     f0105c37 <readline+0xb1>
f0105c33:	85 f6                	test   %esi,%esi
f0105c35:	7f b4                	jg     f0105beb <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105c37:	83 fb 1f             	cmp    $0x1f,%ebx
f0105c3a:	7e 0e                	jle    f0105c4a <readline+0xc4>
f0105c3c:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105c42:	7f 06                	jg     f0105c4a <readline+0xc4>
			if (echoing)
f0105c44:	85 ff                	test   %edi,%edi
f0105c46:	74 c7                	je     f0105c0f <readline+0x89>
f0105c48:	eb b9                	jmp    f0105c03 <readline+0x7d>
		} else if (c == '\n' || c == '\r') {
f0105c4a:	83 fb 0a             	cmp    $0xa,%ebx
f0105c4d:	74 05                	je     f0105c54 <readline+0xce>
f0105c4f:	83 fb 0d             	cmp    $0xd,%ebx
f0105c52:	75 c4                	jne    f0105c18 <readline+0x92>
			if (echoing)
f0105c54:	85 ff                	test   %edi,%edi
f0105c56:	75 11                	jne    f0105c69 <readline+0xe3>
			buf[i] = 0;
f0105c58:	c6 86 80 da 2b f0 00 	movb   $0x0,-0xfd42580(%esi)
			return buf;
f0105c5f:	b8 80 da 2b f0       	mov    $0xf02bda80,%eax
f0105c64:	e9 62 ff ff ff       	jmp    f0105bcb <readline+0x45>
				cputchar('\n');
f0105c69:	83 ec 0c             	sub    $0xc,%esp
f0105c6c:	6a 0a                	push   $0xa
f0105c6e:	e8 4f ab ff ff       	call   f01007c2 <cputchar>
f0105c73:	83 c4 10             	add    $0x10,%esp
f0105c76:	eb e0                	jmp    f0105c58 <readline+0xd2>

f0105c78 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105c78:	f3 0f 1e fb          	endbr32 
f0105c7c:	55                   	push   %ebp
f0105c7d:	89 e5                	mov    %esp,%ebp
f0105c7f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105c82:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c87:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105c8b:	74 05                	je     f0105c92 <strlen+0x1a>
		n++;
f0105c8d:	83 c0 01             	add    $0x1,%eax
f0105c90:	eb f5                	jmp    f0105c87 <strlen+0xf>
	return n;
}
f0105c92:	5d                   	pop    %ebp
f0105c93:	c3                   	ret    

f0105c94 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105c94:	f3 0f 1e fb          	endbr32 
f0105c98:	55                   	push   %ebp
f0105c99:	89 e5                	mov    %esp,%ebp
f0105c9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105c9e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105ca1:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ca6:	39 d0                	cmp    %edx,%eax
f0105ca8:	74 0d                	je     f0105cb7 <strnlen+0x23>
f0105caa:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105cae:	74 05                	je     f0105cb5 <strnlen+0x21>
		n++;
f0105cb0:	83 c0 01             	add    $0x1,%eax
f0105cb3:	eb f1                	jmp    f0105ca6 <strnlen+0x12>
f0105cb5:	89 c2                	mov    %eax,%edx
	return n;
}
f0105cb7:	89 d0                	mov    %edx,%eax
f0105cb9:	5d                   	pop    %ebp
f0105cba:	c3                   	ret    

f0105cbb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105cbb:	f3 0f 1e fb          	endbr32 
f0105cbf:	55                   	push   %ebp
f0105cc0:	89 e5                	mov    %esp,%ebp
f0105cc2:	53                   	push   %ebx
f0105cc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105cc6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105cc9:	b8 00 00 00 00       	mov    $0x0,%eax
f0105cce:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0105cd2:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0105cd5:	83 c0 01             	add    $0x1,%eax
f0105cd8:	84 d2                	test   %dl,%dl
f0105cda:	75 f2                	jne    f0105cce <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f0105cdc:	89 c8                	mov    %ecx,%eax
f0105cde:	5b                   	pop    %ebx
f0105cdf:	5d                   	pop    %ebp
f0105ce0:	c3                   	ret    

f0105ce1 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105ce1:	f3 0f 1e fb          	endbr32 
f0105ce5:	55                   	push   %ebp
f0105ce6:	89 e5                	mov    %esp,%ebp
f0105ce8:	53                   	push   %ebx
f0105ce9:	83 ec 10             	sub    $0x10,%esp
f0105cec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105cef:	53                   	push   %ebx
f0105cf0:	e8 83 ff ff ff       	call   f0105c78 <strlen>
f0105cf5:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0105cf8:	ff 75 0c             	pushl  0xc(%ebp)
f0105cfb:	01 d8                	add    %ebx,%eax
f0105cfd:	50                   	push   %eax
f0105cfe:	e8 b8 ff ff ff       	call   f0105cbb <strcpy>
	return dst;
}
f0105d03:	89 d8                	mov    %ebx,%eax
f0105d05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105d08:	c9                   	leave  
f0105d09:	c3                   	ret    

f0105d0a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105d0a:	f3 0f 1e fb          	endbr32 
f0105d0e:	55                   	push   %ebp
f0105d0f:	89 e5                	mov    %esp,%ebp
f0105d11:	56                   	push   %esi
f0105d12:	53                   	push   %ebx
f0105d13:	8b 75 08             	mov    0x8(%ebp),%esi
f0105d16:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105d19:	89 f3                	mov    %esi,%ebx
f0105d1b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105d1e:	89 f0                	mov    %esi,%eax
f0105d20:	39 d8                	cmp    %ebx,%eax
f0105d22:	74 11                	je     f0105d35 <strncpy+0x2b>
		*dst++ = *src;
f0105d24:	83 c0 01             	add    $0x1,%eax
f0105d27:	0f b6 0a             	movzbl (%edx),%ecx
f0105d2a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105d2d:	80 f9 01             	cmp    $0x1,%cl
f0105d30:	83 da ff             	sbb    $0xffffffff,%edx
f0105d33:	eb eb                	jmp    f0105d20 <strncpy+0x16>
	}
	return ret;
}
f0105d35:	89 f0                	mov    %esi,%eax
f0105d37:	5b                   	pop    %ebx
f0105d38:	5e                   	pop    %esi
f0105d39:	5d                   	pop    %ebp
f0105d3a:	c3                   	ret    

f0105d3b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105d3b:	f3 0f 1e fb          	endbr32 
f0105d3f:	55                   	push   %ebp
f0105d40:	89 e5                	mov    %esp,%ebp
f0105d42:	56                   	push   %esi
f0105d43:	53                   	push   %ebx
f0105d44:	8b 75 08             	mov    0x8(%ebp),%esi
f0105d47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105d4a:	8b 55 10             	mov    0x10(%ebp),%edx
f0105d4d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105d4f:	85 d2                	test   %edx,%edx
f0105d51:	74 21                	je     f0105d74 <strlcpy+0x39>
f0105d53:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105d57:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0105d59:	39 c2                	cmp    %eax,%edx
f0105d5b:	74 14                	je     f0105d71 <strlcpy+0x36>
f0105d5d:	0f b6 19             	movzbl (%ecx),%ebx
f0105d60:	84 db                	test   %bl,%bl
f0105d62:	74 0b                	je     f0105d6f <strlcpy+0x34>
			*dst++ = *src++;
f0105d64:	83 c1 01             	add    $0x1,%ecx
f0105d67:	83 c2 01             	add    $0x1,%edx
f0105d6a:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105d6d:	eb ea                	jmp    f0105d59 <strlcpy+0x1e>
f0105d6f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0105d71:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105d74:	29 f0                	sub    %esi,%eax
}
f0105d76:	5b                   	pop    %ebx
f0105d77:	5e                   	pop    %esi
f0105d78:	5d                   	pop    %ebp
f0105d79:	c3                   	ret    

f0105d7a <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105d7a:	f3 0f 1e fb          	endbr32 
f0105d7e:	55                   	push   %ebp
f0105d7f:	89 e5                	mov    %esp,%ebp
f0105d81:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105d84:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105d87:	0f b6 01             	movzbl (%ecx),%eax
f0105d8a:	84 c0                	test   %al,%al
f0105d8c:	74 0c                	je     f0105d9a <strcmp+0x20>
f0105d8e:	3a 02                	cmp    (%edx),%al
f0105d90:	75 08                	jne    f0105d9a <strcmp+0x20>
		p++, q++;
f0105d92:	83 c1 01             	add    $0x1,%ecx
f0105d95:	83 c2 01             	add    $0x1,%edx
f0105d98:	eb ed                	jmp    f0105d87 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105d9a:	0f b6 c0             	movzbl %al,%eax
f0105d9d:	0f b6 12             	movzbl (%edx),%edx
f0105da0:	29 d0                	sub    %edx,%eax
}
f0105da2:	5d                   	pop    %ebp
f0105da3:	c3                   	ret    

f0105da4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105da4:	f3 0f 1e fb          	endbr32 
f0105da8:	55                   	push   %ebp
f0105da9:	89 e5                	mov    %esp,%ebp
f0105dab:	53                   	push   %ebx
f0105dac:	8b 45 08             	mov    0x8(%ebp),%eax
f0105daf:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105db2:	89 c3                	mov    %eax,%ebx
f0105db4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105db7:	eb 06                	jmp    f0105dbf <strncmp+0x1b>
		n--, p++, q++;
f0105db9:	83 c0 01             	add    $0x1,%eax
f0105dbc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0105dbf:	39 d8                	cmp    %ebx,%eax
f0105dc1:	74 16                	je     f0105dd9 <strncmp+0x35>
f0105dc3:	0f b6 08             	movzbl (%eax),%ecx
f0105dc6:	84 c9                	test   %cl,%cl
f0105dc8:	74 04                	je     f0105dce <strncmp+0x2a>
f0105dca:	3a 0a                	cmp    (%edx),%cl
f0105dcc:	74 eb                	je     f0105db9 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105dce:	0f b6 00             	movzbl (%eax),%eax
f0105dd1:	0f b6 12             	movzbl (%edx),%edx
f0105dd4:	29 d0                	sub    %edx,%eax
}
f0105dd6:	5b                   	pop    %ebx
f0105dd7:	5d                   	pop    %ebp
f0105dd8:	c3                   	ret    
		return 0;
f0105dd9:	b8 00 00 00 00       	mov    $0x0,%eax
f0105dde:	eb f6                	jmp    f0105dd6 <strncmp+0x32>

f0105de0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105de0:	f3 0f 1e fb          	endbr32 
f0105de4:	55                   	push   %ebp
f0105de5:	89 e5                	mov    %esp,%ebp
f0105de7:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dea:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105dee:	0f b6 10             	movzbl (%eax),%edx
f0105df1:	84 d2                	test   %dl,%dl
f0105df3:	74 09                	je     f0105dfe <strchr+0x1e>
		if (*s == c)
f0105df5:	38 ca                	cmp    %cl,%dl
f0105df7:	74 0a                	je     f0105e03 <strchr+0x23>
	for (; *s; s++)
f0105df9:	83 c0 01             	add    $0x1,%eax
f0105dfc:	eb f0                	jmp    f0105dee <strchr+0xe>
			return (char *) s;
	return 0;
f0105dfe:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105e03:	5d                   	pop    %ebp
f0105e04:	c3                   	ret    

f0105e05 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
f0105e05:	f3 0f 1e fb          	endbr32 
f0105e09:	55                   	push   %ebp
f0105e0a:	89 e5                	mov    %esp,%ebp
f0105e0c:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
f0105e0f:	6a 78                	push   $0x78
f0105e11:	ff 75 08             	pushl  0x8(%ebp)
f0105e14:	e8 c7 ff ff ff       	call   f0105de0 <strchr>
f0105e19:	83 c4 10             	add    $0x10,%esp
f0105e1c:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
f0105e1f:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
f0105e24:	eb 0d                	jmp    f0105e33 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
f0105e26:	c1 e0 04             	shl    $0x4,%eax
f0105e29:	0f be d2             	movsbl %dl,%edx
f0105e2c:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
f0105e30:	83 c1 01             	add    $0x1,%ecx
f0105e33:	0f b6 11             	movzbl (%ecx),%edx
f0105e36:	84 d2                	test   %dl,%dl
f0105e38:	74 11                	je     f0105e4b <atox+0x46>
		if (*p>='a'){
f0105e3a:	80 fa 60             	cmp    $0x60,%dl
f0105e3d:	7e e7                	jle    f0105e26 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
f0105e3f:	c1 e0 04             	shl    $0x4,%eax
f0105e42:	0f be d2             	movsbl %dl,%edx
f0105e45:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
f0105e49:	eb e5                	jmp    f0105e30 <atox+0x2b>
	}

	return v;

}
f0105e4b:	c9                   	leave  
f0105e4c:	c3                   	ret    

f0105e4d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105e4d:	f3 0f 1e fb          	endbr32 
f0105e51:	55                   	push   %ebp
f0105e52:	89 e5                	mov    %esp,%ebp
f0105e54:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e57:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105e5b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105e5e:	38 ca                	cmp    %cl,%dl
f0105e60:	74 09                	je     f0105e6b <strfind+0x1e>
f0105e62:	84 d2                	test   %dl,%dl
f0105e64:	74 05                	je     f0105e6b <strfind+0x1e>
	for (; *s; s++)
f0105e66:	83 c0 01             	add    $0x1,%eax
f0105e69:	eb f0                	jmp    f0105e5b <strfind+0xe>
			break;
	return (char *) s;
}
f0105e6b:	5d                   	pop    %ebp
f0105e6c:	c3                   	ret    

f0105e6d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105e6d:	f3 0f 1e fb          	endbr32 
f0105e71:	55                   	push   %ebp
f0105e72:	89 e5                	mov    %esp,%ebp
f0105e74:	57                   	push   %edi
f0105e75:	56                   	push   %esi
f0105e76:	53                   	push   %ebx
f0105e77:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105e7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105e7d:	85 c9                	test   %ecx,%ecx
f0105e7f:	74 31                	je     f0105eb2 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105e81:	89 f8                	mov    %edi,%eax
f0105e83:	09 c8                	or     %ecx,%eax
f0105e85:	a8 03                	test   $0x3,%al
f0105e87:	75 23                	jne    f0105eac <memset+0x3f>
		c &= 0xFF;
f0105e89:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105e8d:	89 d3                	mov    %edx,%ebx
f0105e8f:	c1 e3 08             	shl    $0x8,%ebx
f0105e92:	89 d0                	mov    %edx,%eax
f0105e94:	c1 e0 18             	shl    $0x18,%eax
f0105e97:	89 d6                	mov    %edx,%esi
f0105e99:	c1 e6 10             	shl    $0x10,%esi
f0105e9c:	09 f0                	or     %esi,%eax
f0105e9e:	09 c2                	or     %eax,%edx
f0105ea0:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105ea2:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0105ea5:	89 d0                	mov    %edx,%eax
f0105ea7:	fc                   	cld    
f0105ea8:	f3 ab                	rep stos %eax,%es:(%edi)
f0105eaa:	eb 06                	jmp    f0105eb2 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105eac:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105eaf:	fc                   	cld    
f0105eb0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105eb2:	89 f8                	mov    %edi,%eax
f0105eb4:	5b                   	pop    %ebx
f0105eb5:	5e                   	pop    %esi
f0105eb6:	5f                   	pop    %edi
f0105eb7:	5d                   	pop    %ebp
f0105eb8:	c3                   	ret    

f0105eb9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105eb9:	f3 0f 1e fb          	endbr32 
f0105ebd:	55                   	push   %ebp
f0105ebe:	89 e5                	mov    %esp,%ebp
f0105ec0:	57                   	push   %edi
f0105ec1:	56                   	push   %esi
f0105ec2:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ec5:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105ec8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105ecb:	39 c6                	cmp    %eax,%esi
f0105ecd:	73 32                	jae    f0105f01 <memmove+0x48>
f0105ecf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105ed2:	39 c2                	cmp    %eax,%edx
f0105ed4:	76 2b                	jbe    f0105f01 <memmove+0x48>
		s += n;
		d += n;
f0105ed6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105ed9:	89 fe                	mov    %edi,%esi
f0105edb:	09 ce                	or     %ecx,%esi
f0105edd:	09 d6                	or     %edx,%esi
f0105edf:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105ee5:	75 0e                	jne    f0105ef5 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105ee7:	83 ef 04             	sub    $0x4,%edi
f0105eea:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105eed:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105ef0:	fd                   	std    
f0105ef1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105ef3:	eb 09                	jmp    f0105efe <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105ef5:	83 ef 01             	sub    $0x1,%edi
f0105ef8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105efb:	fd                   	std    
f0105efc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105efe:	fc                   	cld    
f0105eff:	eb 1a                	jmp    f0105f1b <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105f01:	89 c2                	mov    %eax,%edx
f0105f03:	09 ca                	or     %ecx,%edx
f0105f05:	09 f2                	or     %esi,%edx
f0105f07:	f6 c2 03             	test   $0x3,%dl
f0105f0a:	75 0a                	jne    f0105f16 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105f0c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105f0f:	89 c7                	mov    %eax,%edi
f0105f11:	fc                   	cld    
f0105f12:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105f14:	eb 05                	jmp    f0105f1b <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f0105f16:	89 c7                	mov    %eax,%edi
f0105f18:	fc                   	cld    
f0105f19:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105f1b:	5e                   	pop    %esi
f0105f1c:	5f                   	pop    %edi
f0105f1d:	5d                   	pop    %ebp
f0105f1e:	c3                   	ret    

f0105f1f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105f1f:	f3 0f 1e fb          	endbr32 
f0105f23:	55                   	push   %ebp
f0105f24:	89 e5                	mov    %esp,%ebp
f0105f26:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105f29:	ff 75 10             	pushl  0x10(%ebp)
f0105f2c:	ff 75 0c             	pushl  0xc(%ebp)
f0105f2f:	ff 75 08             	pushl  0x8(%ebp)
f0105f32:	e8 82 ff ff ff       	call   f0105eb9 <memmove>
}
f0105f37:	c9                   	leave  
f0105f38:	c3                   	ret    

f0105f39 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105f39:	f3 0f 1e fb          	endbr32 
f0105f3d:	55                   	push   %ebp
f0105f3e:	89 e5                	mov    %esp,%ebp
f0105f40:	56                   	push   %esi
f0105f41:	53                   	push   %ebx
f0105f42:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f45:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f48:	89 c6                	mov    %eax,%esi
f0105f4a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105f4d:	39 f0                	cmp    %esi,%eax
f0105f4f:	74 1c                	je     f0105f6d <memcmp+0x34>
		if (*s1 != *s2)
f0105f51:	0f b6 08             	movzbl (%eax),%ecx
f0105f54:	0f b6 1a             	movzbl (%edx),%ebx
f0105f57:	38 d9                	cmp    %bl,%cl
f0105f59:	75 08                	jne    f0105f63 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105f5b:	83 c0 01             	add    $0x1,%eax
f0105f5e:	83 c2 01             	add    $0x1,%edx
f0105f61:	eb ea                	jmp    f0105f4d <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f0105f63:	0f b6 c1             	movzbl %cl,%eax
f0105f66:	0f b6 db             	movzbl %bl,%ebx
f0105f69:	29 d8                	sub    %ebx,%eax
f0105f6b:	eb 05                	jmp    f0105f72 <memcmp+0x39>
	}

	return 0;
f0105f6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105f72:	5b                   	pop    %ebx
f0105f73:	5e                   	pop    %esi
f0105f74:	5d                   	pop    %ebp
f0105f75:	c3                   	ret    

f0105f76 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105f76:	f3 0f 1e fb          	endbr32 
f0105f7a:	55                   	push   %ebp
f0105f7b:	89 e5                	mov    %esp,%ebp
f0105f7d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105f83:	89 c2                	mov    %eax,%edx
f0105f85:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105f88:	39 d0                	cmp    %edx,%eax
f0105f8a:	73 09                	jae    f0105f95 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105f8c:	38 08                	cmp    %cl,(%eax)
f0105f8e:	74 05                	je     f0105f95 <memfind+0x1f>
	for (; s < ends; s++)
f0105f90:	83 c0 01             	add    $0x1,%eax
f0105f93:	eb f3                	jmp    f0105f88 <memfind+0x12>
			break;
	return (void *) s;
}
f0105f95:	5d                   	pop    %ebp
f0105f96:	c3                   	ret    

f0105f97 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105f97:	f3 0f 1e fb          	endbr32 
f0105f9b:	55                   	push   %ebp
f0105f9c:	89 e5                	mov    %esp,%ebp
f0105f9e:	57                   	push   %edi
f0105f9f:	56                   	push   %esi
f0105fa0:	53                   	push   %ebx
f0105fa1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105fa4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105fa7:	eb 03                	jmp    f0105fac <strtol+0x15>
		s++;
f0105fa9:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0105fac:	0f b6 01             	movzbl (%ecx),%eax
f0105faf:	3c 20                	cmp    $0x20,%al
f0105fb1:	74 f6                	je     f0105fa9 <strtol+0x12>
f0105fb3:	3c 09                	cmp    $0x9,%al
f0105fb5:	74 f2                	je     f0105fa9 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f0105fb7:	3c 2b                	cmp    $0x2b,%al
f0105fb9:	74 2a                	je     f0105fe5 <strtol+0x4e>
	int neg = 0;
f0105fbb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105fc0:	3c 2d                	cmp    $0x2d,%al
f0105fc2:	74 2b                	je     f0105fef <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105fc4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105fca:	75 0f                	jne    f0105fdb <strtol+0x44>
f0105fcc:	80 39 30             	cmpb   $0x30,(%ecx)
f0105fcf:	74 28                	je     f0105ff9 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105fd1:	85 db                	test   %ebx,%ebx
f0105fd3:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105fd8:	0f 44 d8             	cmove  %eax,%ebx
f0105fdb:	b8 00 00 00 00       	mov    $0x0,%eax
f0105fe0:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105fe3:	eb 46                	jmp    f010602b <strtol+0x94>
		s++;
f0105fe5:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0105fe8:	bf 00 00 00 00       	mov    $0x0,%edi
f0105fed:	eb d5                	jmp    f0105fc4 <strtol+0x2d>
		s++, neg = 1;
f0105fef:	83 c1 01             	add    $0x1,%ecx
f0105ff2:	bf 01 00 00 00       	mov    $0x1,%edi
f0105ff7:	eb cb                	jmp    f0105fc4 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105ff9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105ffd:	74 0e                	je     f010600d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0105fff:	85 db                	test   %ebx,%ebx
f0106001:	75 d8                	jne    f0105fdb <strtol+0x44>
		s++, base = 8;
f0106003:	83 c1 01             	add    $0x1,%ecx
f0106006:	bb 08 00 00 00       	mov    $0x8,%ebx
f010600b:	eb ce                	jmp    f0105fdb <strtol+0x44>
		s += 2, base = 16;
f010600d:	83 c1 02             	add    $0x2,%ecx
f0106010:	bb 10 00 00 00       	mov    $0x10,%ebx
f0106015:	eb c4                	jmp    f0105fdb <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0106017:	0f be d2             	movsbl %dl,%edx
f010601a:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010601d:	3b 55 10             	cmp    0x10(%ebp),%edx
f0106020:	7d 3a                	jge    f010605c <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0106022:	83 c1 01             	add    $0x1,%ecx
f0106025:	0f af 45 10          	imul   0x10(%ebp),%eax
f0106029:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f010602b:	0f b6 11             	movzbl (%ecx),%edx
f010602e:	8d 72 d0             	lea    -0x30(%edx),%esi
f0106031:	89 f3                	mov    %esi,%ebx
f0106033:	80 fb 09             	cmp    $0x9,%bl
f0106036:	76 df                	jbe    f0106017 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f0106038:	8d 72 9f             	lea    -0x61(%edx),%esi
f010603b:	89 f3                	mov    %esi,%ebx
f010603d:	80 fb 19             	cmp    $0x19,%bl
f0106040:	77 08                	ja     f010604a <strtol+0xb3>
			dig = *s - 'a' + 10;
f0106042:	0f be d2             	movsbl %dl,%edx
f0106045:	83 ea 57             	sub    $0x57,%edx
f0106048:	eb d3                	jmp    f010601d <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f010604a:	8d 72 bf             	lea    -0x41(%edx),%esi
f010604d:	89 f3                	mov    %esi,%ebx
f010604f:	80 fb 19             	cmp    $0x19,%bl
f0106052:	77 08                	ja     f010605c <strtol+0xc5>
			dig = *s - 'A' + 10;
f0106054:	0f be d2             	movsbl %dl,%edx
f0106057:	83 ea 37             	sub    $0x37,%edx
f010605a:	eb c1                	jmp    f010601d <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f010605c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0106060:	74 05                	je     f0106067 <strtol+0xd0>
		*endptr = (char *) s;
f0106062:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106065:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0106067:	89 c2                	mov    %eax,%edx
f0106069:	f7 da                	neg    %edx
f010606b:	85 ff                	test   %edi,%edi
f010606d:	0f 45 c2             	cmovne %edx,%eax
}
f0106070:	5b                   	pop    %ebx
f0106071:	5e                   	pop    %esi
f0106072:	5f                   	pop    %edi
f0106073:	5d                   	pop    %ebp
f0106074:	c3                   	ret    
f0106075:	66 90                	xchg   %ax,%ax
f0106077:	90                   	nop

f0106078 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106078:	fa                   	cli    

	xorw    %ax, %ax
f0106079:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010607b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010607d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010607f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106081:	0f 01 16             	lgdtl  (%esi)
f0106084:	74 70                	je     f01060f6 <mpsearch1+0x3>
	movl    %cr0, %eax
f0106086:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106089:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f010608d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106090:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0106096:	08 00                	or     %al,(%eax)

f0106098 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106098:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f010609c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010609e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01060a0:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01060a2:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01060a6:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01060a8:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01060aa:	b8 00 50 12 00       	mov    $0x125000,%eax
	movl    %eax, %cr3
f01060af:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01060b2:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01060b5:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01060ba:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01060bd:	8b 25 10 f4 2b f0    	mov    0xf02bf410,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01060c3:	bd 00 00 00 00       	mov    $0x0,%ebp
	# 	the indirect call uses an instrction call with a register as argument(here rax)
	#	the register is previously loaded either directly with a fixed address of the subroutine that is to be called, or with a value fetched from somewhere else, 
	# 	such as another register or a place in memory where the subroutine's address was previously stored
	# --> indirect call 1）can be used to call differenct subroutines while direct call always call the same subroutine
	#					2) can be used for position independent code, where the address of a function in memory is only known when the program is loaded 
	movl    $mp_main, %eax
f01060c8:	b8 d6 01 10 f0       	mov    $0xf01001d6,%eax
	call    *%eax
f01060cd:	ff d0                	call   *%eax

f01060cf <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01060cf:	eb fe                	jmp    f01060cf <spin>
f01060d1:	8d 76 00             	lea    0x0(%esi),%esi

f01060d4 <gdt>:
	...
f01060dc:	ff                   	(bad)  
f01060dd:	ff 00                	incl   (%eax)
f01060df:	00 00                	add    %al,(%eax)
f01060e1:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01060e8:	00                   	.byte 0x0
f01060e9:	92                   	xchg   %eax,%edx
f01060ea:	cf                   	iret   
	...

f01060ec <gdtdesc>:
f01060ec:	17                   	pop    %ss
f01060ed:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01060f2 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01060f2:	90                   	nop

f01060f3 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01060f3:	55                   	push   %ebp
f01060f4:	89 e5                	mov    %esp,%ebp
f01060f6:	57                   	push   %edi
f01060f7:	56                   	push   %esi
f01060f8:	53                   	push   %ebx
f01060f9:	83 ec 0c             	sub    $0xc,%esp
f01060fc:	89 c7                	mov    %eax,%edi
	if (PGNUM(pa) >= npages)
f01060fe:	a1 14 f4 2b f0       	mov    0xf02bf414,%eax
f0106103:	89 f9                	mov    %edi,%ecx
f0106105:	c1 e9 0c             	shr    $0xc,%ecx
f0106108:	39 c1                	cmp    %eax,%ecx
f010610a:	73 19                	jae    f0106125 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f010610c:	8d 9f 00 00 00 f0    	lea    -0x10000000(%edi),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0106112:	01 d7                	add    %edx,%edi
	if (PGNUM(pa) >= npages)
f0106114:	89 fa                	mov    %edi,%edx
f0106116:	c1 ea 0c             	shr    $0xc,%edx
f0106119:	39 c2                	cmp    %eax,%edx
f010611b:	73 1a                	jae    f0106137 <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f010611d:	81 ef 00 00 00 10    	sub    $0x10000000,%edi

	for (; mp < end; mp++)
f0106123:	eb 27                	jmp    f010614c <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106125:	57                   	push   %edi
f0106126:	68 44 74 10 f0       	push   $0xf0107444
f010612b:	6a 57                	push   $0x57
f010612d:	68 7d 94 10 f0       	push   $0xf010947d
f0106132:	e8 09 9f ff ff       	call   f0100040 <_panic>
f0106137:	57                   	push   %edi
f0106138:	68 44 74 10 f0       	push   $0xf0107444
f010613d:	6a 57                	push   $0x57
f010613f:	68 7d 94 10 f0       	push   $0xf010947d
f0106144:	e8 f7 9e ff ff       	call   f0100040 <_panic>
f0106149:	83 c3 10             	add    $0x10,%ebx
f010614c:	39 fb                	cmp    %edi,%ebx
f010614e:	73 30                	jae    f0106180 <mpsearch1+0x8d>
f0106150:	89 de                	mov    %ebx,%esi
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106152:	83 ec 04             	sub    $0x4,%esp
f0106155:	6a 04                	push   $0x4
f0106157:	68 8d 94 10 f0       	push   $0xf010948d
f010615c:	53                   	push   %ebx
f010615d:	e8 d7 fd ff ff       	call   f0105f39 <memcmp>
f0106162:	83 c4 10             	add    $0x10,%esp
f0106165:	85 c0                	test   %eax,%eax
f0106167:	75 e0                	jne    f0106149 <mpsearch1+0x56>
f0106169:	89 da                	mov    %ebx,%edx
	for (i = 0; i < len; i++)
f010616b:	83 c6 10             	add    $0x10,%esi
		sum += ((uint8_t *)addr)[i];
f010616e:	0f b6 0a             	movzbl (%edx),%ecx
f0106171:	01 c8                	add    %ecx,%eax
f0106173:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f0106176:	39 f2                	cmp    %esi,%edx
f0106178:	75 f4                	jne    f010616e <mpsearch1+0x7b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010617a:	84 c0                	test   %al,%al
f010617c:	75 cb                	jne    f0106149 <mpsearch1+0x56>
f010617e:	eb 05                	jmp    f0106185 <mpsearch1+0x92>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0106180:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0106185:	89 d8                	mov    %ebx,%eax
f0106187:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010618a:	5b                   	pop    %ebx
f010618b:	5e                   	pop    %esi
f010618c:	5f                   	pop    %edi
f010618d:	5d                   	pop    %ebp
f010618e:	c3                   	ret    

f010618f <mp_init>:
// 在booting up APs之前. bootstrap processor需要先收集并记录multiporcessor系统的相关信息
// e.g. cpu个数 它们的APIC id，以及 LAPiC单元的MMIO映射地址
// mp_init这个function就是将放置在BIOS区域内的MP configuration table给读取出来 
void
mp_init(void)
{
f010618f:	f3 0f 1e fb          	endbr32 
f0106193:	55                   	push   %ebp
f0106194:	89 e5                	mov    %esp,%ebp
f0106196:	57                   	push   %edi
f0106197:	56                   	push   %esi
f0106198:	53                   	push   %ebx
f0106199:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f010619c:	c7 05 c0 03 2c f0 20 	movl   $0xf02c0020,0xf02c03c0
f01061a3:	00 2c f0 
	if (PGNUM(pa) >= npages)
f01061a6:	83 3d 14 f4 2b f0 00 	cmpl   $0x0,0xf02bf414
f01061ad:	0f 84 a3 00 00 00    	je     f0106256 <mp_init+0xc7>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01061b3:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01061ba:	85 c0                	test   %eax,%eax
f01061bc:	0f 84 aa 00 00 00    	je     f010626c <mp_init+0xdd>
		p <<= 4;	// Translate from segment to PA
f01061c2:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f01061c5:	ba 00 04 00 00       	mov    $0x400,%edx
f01061ca:	e8 24 ff ff ff       	call   f01060f3 <mpsearch1>
f01061cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01061d2:	85 c0                	test   %eax,%eax
f01061d4:	75 1a                	jne    f01061f0 <mp_init+0x61>
	return mpsearch1(0xF0000, 0x10000);
f01061d6:	ba 00 00 01 00       	mov    $0x10000,%edx
f01061db:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01061e0:	e8 0e ff ff ff       	call   f01060f3 <mpsearch1>
f01061e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f01061e8:	85 c0                	test   %eax,%eax
f01061ea:	0f 84 35 02 00 00    	je     f0106425 <mp_init+0x296>
	if (mp->physaddr == 0 || mp->type != 0) {
f01061f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01061f3:	8b 58 04             	mov    0x4(%eax),%ebx
f01061f6:	85 db                	test   %ebx,%ebx
f01061f8:	0f 84 97 00 00 00    	je     f0106295 <mp_init+0x106>
f01061fe:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106202:	0f 85 8d 00 00 00    	jne    f0106295 <mp_init+0x106>
f0106208:	89 d8                	mov    %ebx,%eax
f010620a:	c1 e8 0c             	shr    $0xc,%eax
f010620d:	3b 05 14 f4 2b f0    	cmp    0xf02bf414,%eax
f0106213:	0f 83 91 00 00 00    	jae    f01062aa <mp_init+0x11b>
	return (void *)(pa + KERNBASE);
f0106219:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f010621f:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106221:	83 ec 04             	sub    $0x4,%esp
f0106224:	6a 04                	push   $0x4
f0106226:	68 92 94 10 f0       	push   $0xf0109492
f010622b:	53                   	push   %ebx
f010622c:	e8 08 fd ff ff       	call   f0105f39 <memcmp>
f0106231:	83 c4 10             	add    $0x10,%esp
f0106234:	85 c0                	test   %eax,%eax
f0106236:	0f 85 83 00 00 00    	jne    f01062bf <mp_init+0x130>
f010623c:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0106240:	01 df                	add    %ebx,%edi
	sum = 0;
f0106242:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f0106244:	39 fb                	cmp    %edi,%ebx
f0106246:	0f 84 88 00 00 00    	je     f01062d4 <mp_init+0x145>
		sum += ((uint8_t *)addr)[i];
f010624c:	0f b6 0b             	movzbl (%ebx),%ecx
f010624f:	01 ca                	add    %ecx,%edx
f0106251:	83 c3 01             	add    $0x1,%ebx
f0106254:	eb ee                	jmp    f0106244 <mp_init+0xb5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106256:	68 00 04 00 00       	push   $0x400
f010625b:	68 44 74 10 f0       	push   $0xf0107444
f0106260:	6a 6f                	push   $0x6f
f0106262:	68 7d 94 10 f0       	push   $0xf010947d
f0106267:	e8 d4 9d ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f010626c:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106273:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0106276:	2d 00 04 00 00       	sub    $0x400,%eax
f010627b:	ba 00 04 00 00       	mov    $0x400,%edx
f0106280:	e8 6e fe ff ff       	call   f01060f3 <mpsearch1>
f0106285:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106288:	85 c0                	test   %eax,%eax
f010628a:	0f 85 60 ff ff ff    	jne    f01061f0 <mp_init+0x61>
f0106290:	e9 41 ff ff ff       	jmp    f01061d6 <mp_init+0x47>
		cprintf("SMP: Default configurations not implemented\n");
f0106295:	83 ec 0c             	sub    $0xc,%esp
f0106298:	68 f0 92 10 f0       	push   $0xf01092f0
f010629d:	e8 8e db ff ff       	call   f0103e30 <cprintf>
		return NULL;
f01062a2:	83 c4 10             	add    $0x10,%esp
f01062a5:	e9 7b 01 00 00       	jmp    f0106425 <mp_init+0x296>
f01062aa:	53                   	push   %ebx
f01062ab:	68 44 74 10 f0       	push   $0xf0107444
f01062b0:	68 90 00 00 00       	push   $0x90
f01062b5:	68 7d 94 10 f0       	push   $0xf010947d
f01062ba:	e8 81 9d ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01062bf:	83 ec 0c             	sub    $0xc,%esp
f01062c2:	68 20 93 10 f0       	push   $0xf0109320
f01062c7:	e8 64 db ff ff       	call   f0103e30 <cprintf>
		return NULL;
f01062cc:	83 c4 10             	add    $0x10,%esp
f01062cf:	e9 51 01 00 00       	jmp    f0106425 <mp_init+0x296>
	if (sum(conf, conf->length) != 0) {
f01062d4:	84 d2                	test   %dl,%dl
f01062d6:	75 22                	jne    f01062fa <mp_init+0x16b>
	if (conf->version != 1 && conf->version != 4) {
f01062d8:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f01062dc:	80 fa 01             	cmp    $0x1,%dl
f01062df:	74 05                	je     f01062e6 <mp_init+0x157>
f01062e1:	80 fa 04             	cmp    $0x4,%dl
f01062e4:	75 29                	jne    f010630f <mp_init+0x180>
f01062e6:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f01062ea:	01 d9                	add    %ebx,%ecx
	for (i = 0; i < len; i++)
f01062ec:	39 d9                	cmp    %ebx,%ecx
f01062ee:	74 38                	je     f0106328 <mp_init+0x199>
		sum += ((uint8_t *)addr)[i];
f01062f0:	0f b6 13             	movzbl (%ebx),%edx
f01062f3:	01 d0                	add    %edx,%eax
f01062f5:	83 c3 01             	add    $0x1,%ebx
f01062f8:	eb f2                	jmp    f01062ec <mp_init+0x15d>
		cprintf("SMP: Bad MP configuration checksum\n");
f01062fa:	83 ec 0c             	sub    $0xc,%esp
f01062fd:	68 54 93 10 f0       	push   $0xf0109354
f0106302:	e8 29 db ff ff       	call   f0103e30 <cprintf>
		return NULL;
f0106307:	83 c4 10             	add    $0x10,%esp
f010630a:	e9 16 01 00 00       	jmp    f0106425 <mp_init+0x296>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f010630f:	83 ec 08             	sub    $0x8,%esp
f0106312:	0f b6 d2             	movzbl %dl,%edx
f0106315:	52                   	push   %edx
f0106316:	68 78 93 10 f0       	push   $0xf0109378
f010631b:	e8 10 db ff ff       	call   f0103e30 <cprintf>
		return NULL;
f0106320:	83 c4 10             	add    $0x10,%esp
f0106323:	e9 fd 00 00 00       	jmp    f0106425 <mp_init+0x296>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106328:	02 46 2a             	add    0x2a(%esi),%al
f010632b:	75 1c                	jne    f0106349 <mp_init+0x1ba>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f010632d:	c7 05 00 00 2c f0 01 	movl   $0x1,0xf02c0000
f0106334:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106337:	8b 46 24             	mov    0x24(%esi),%eax
f010633a:	a3 00 10 30 f0       	mov    %eax,0xf0301000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010633f:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0106342:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106347:	eb 4d                	jmp    f0106396 <mp_init+0x207>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106349:	83 ec 0c             	sub    $0xc,%esp
f010634c:	68 98 93 10 f0       	push   $0xf0109398
f0106351:	e8 da da ff ff       	call   f0103e30 <cprintf>
		return NULL;
f0106356:	83 c4 10             	add    $0x10,%esp
f0106359:	e9 c7 00 00 00       	jmp    f0106425 <mp_init+0x296>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f010635e:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0106362:	74 11                	je     f0106375 <mp_init+0x1e6>
				bootcpu = &cpus[ncpu];
f0106364:	6b 05 c4 03 2c f0 74 	imul   $0x74,0xf02c03c4,%eax
f010636b:	05 20 00 2c f0       	add    $0xf02c0020,%eax
f0106370:	a3 c0 03 2c f0       	mov    %eax,0xf02c03c0
			if (ncpu < NCPU) {
f0106375:	a1 c4 03 2c f0       	mov    0xf02c03c4,%eax
f010637a:	83 f8 07             	cmp    $0x7,%eax
f010637d:	7f 33                	jg     f01063b2 <mp_init+0x223>
				cpus[ncpu].cpu_id = ncpu;
f010637f:	6b d0 74             	imul   $0x74,%eax,%edx
f0106382:	88 82 20 00 2c f0    	mov    %al,-0xfd3ffe0(%edx)
				ncpu++;
f0106388:	83 c0 01             	add    $0x1,%eax
f010638b:	a3 c4 03 2c f0       	mov    %eax,0xf02c03c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106390:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106393:	83 c3 01             	add    $0x1,%ebx
f0106396:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f010639a:	39 d8                	cmp    %ebx,%eax
f010639c:	76 4f                	jbe    f01063ed <mp_init+0x25e>
		switch (*p) {
f010639e:	0f b6 07             	movzbl (%edi),%eax
f01063a1:	84 c0                	test   %al,%al
f01063a3:	74 b9                	je     f010635e <mp_init+0x1cf>
f01063a5:	8d 50 ff             	lea    -0x1(%eax),%edx
f01063a8:	80 fa 03             	cmp    $0x3,%dl
f01063ab:	77 1c                	ja     f01063c9 <mp_init+0x23a>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01063ad:	83 c7 08             	add    $0x8,%edi
			continue;
f01063b0:	eb e1                	jmp    f0106393 <mp_init+0x204>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01063b2:	83 ec 08             	sub    $0x8,%esp
f01063b5:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f01063b9:	50                   	push   %eax
f01063ba:	68 c8 93 10 f0       	push   $0xf01093c8
f01063bf:	e8 6c da ff ff       	call   f0103e30 <cprintf>
f01063c4:	83 c4 10             	add    $0x10,%esp
f01063c7:	eb c7                	jmp    f0106390 <mp_init+0x201>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01063c9:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f01063cc:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f01063cf:	50                   	push   %eax
f01063d0:	68 f0 93 10 f0       	push   $0xf01093f0
f01063d5:	e8 56 da ff ff       	call   f0103e30 <cprintf>
			ismp = 0;
f01063da:	c7 05 00 00 2c f0 00 	movl   $0x0,0xf02c0000
f01063e1:	00 00 00 
			i = conf->entry;
f01063e4:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f01063e8:	83 c4 10             	add    $0x10,%esp
f01063eb:	eb a6                	jmp    f0106393 <mp_init+0x204>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01063ed:	a1 c0 03 2c f0       	mov    0xf02c03c0,%eax
f01063f2:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01063f9:	83 3d 00 00 2c f0 00 	cmpl   $0x0,0xf02c0000
f0106400:	74 2b                	je     f010642d <mp_init+0x29e>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106402:	83 ec 04             	sub    $0x4,%esp
f0106405:	ff 35 c4 03 2c f0    	pushl  0xf02c03c4
f010640b:	0f b6 00             	movzbl (%eax),%eax
f010640e:	50                   	push   %eax
f010640f:	68 97 94 10 f0       	push   $0xf0109497
f0106414:	e8 17 da ff ff       	call   f0103e30 <cprintf>

	if (mp->imcrp) {
f0106419:	83 c4 10             	add    $0x10,%esp
f010641c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010641f:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106423:	75 2e                	jne    f0106453 <mp_init+0x2c4>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0106425:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106428:	5b                   	pop    %ebx
f0106429:	5e                   	pop    %esi
f010642a:	5f                   	pop    %edi
f010642b:	5d                   	pop    %ebp
f010642c:	c3                   	ret    
		ncpu = 1;
f010642d:	c7 05 c4 03 2c f0 01 	movl   $0x1,0xf02c03c4
f0106434:	00 00 00 
		lapicaddr = 0;
f0106437:	c7 05 00 10 30 f0 00 	movl   $0x0,0xf0301000
f010643e:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106441:	83 ec 0c             	sub    $0xc,%esp
f0106444:	68 10 94 10 f0       	push   $0xf0109410
f0106449:	e8 e2 d9 ff ff       	call   f0103e30 <cprintf>
		return;
f010644e:	83 c4 10             	add    $0x10,%esp
f0106451:	eb d2                	jmp    f0106425 <mp_init+0x296>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106453:	83 ec 0c             	sub    $0xc,%esp
f0106456:	68 3c 94 10 f0       	push   $0xf010943c
f010645b:	e8 d0 d9 ff ff       	call   f0103e30 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106460:	b8 70 00 00 00       	mov    $0x70,%eax
f0106465:	ba 22 00 00 00       	mov    $0x22,%edx
f010646a:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010646b:	ba 23 00 00 00       	mov    $0x23,%edx
f0106470:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106471:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106474:	ee                   	out    %al,(%dx)
}
f0106475:	83 c4 10             	add    $0x10,%esp
f0106478:	eb ab                	jmp    f0106425 <mp_init+0x296>

f010647a <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f010647a:	8b 0d 04 10 30 f0    	mov    0xf0301004,%ecx
f0106480:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0106483:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106485:	a1 04 10 30 f0       	mov    0xf0301004,%eax
f010648a:	8b 40 20             	mov    0x20(%eax),%eax
}
f010648d:	c3                   	ret    

f010648e <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f010648e:	f3 0f 1e fb          	endbr32 
	if (lapic)
f0106492:	8b 15 04 10 30 f0    	mov    0xf0301004,%edx
		return lapic[ID] >> 24;
	return 0;
f0106498:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f010649d:	85 d2                	test   %edx,%edx
f010649f:	74 06                	je     f01064a7 <cpunum+0x19>
		return lapic[ID] >> 24;
f01064a1:	8b 42 20             	mov    0x20(%edx),%eax
f01064a4:	c1 e8 18             	shr    $0x18,%eax
}
f01064a7:	c3                   	ret    

f01064a8 <lapic_init>:
{
f01064a8:	f3 0f 1e fb          	endbr32 
	if (!lapicaddr)
f01064ac:	a1 00 10 30 f0       	mov    0xf0301000,%eax
f01064b1:	85 c0                	test   %eax,%eax
f01064b3:	75 01                	jne    f01064b6 <lapic_init+0xe>
f01064b5:	c3                   	ret    
{
f01064b6:	55                   	push   %ebp
f01064b7:	89 e5                	mov    %esp,%ebp
f01064b9:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f01064bc:	68 00 10 00 00       	push   $0x1000
f01064c1:	50                   	push   %eax
f01064c2:	e8 ef b2 ff ff       	call   f01017b6 <mmio_map_region>
f01064c7:	a3 04 10 30 f0       	mov    %eax,0xf0301004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01064cc:	ba 27 01 00 00       	mov    $0x127,%edx
f01064d1:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01064d6:	e8 9f ff ff ff       	call   f010647a <lapicw>
	lapicw(TDCR, X1);
f01064db:	ba 0b 00 00 00       	mov    $0xb,%edx
f01064e0:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01064e5:	e8 90 ff ff ff       	call   f010647a <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01064ea:	ba 20 00 02 00       	mov    $0x20020,%edx
f01064ef:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01064f4:	e8 81 ff ff ff       	call   f010647a <lapicw>
	lapicw(TICR, 10000000); 
f01064f9:	ba 80 96 98 00       	mov    $0x989680,%edx
f01064fe:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106503:	e8 72 ff ff ff       	call   f010647a <lapicw>
	if (thiscpu != bootcpu)
f0106508:	e8 81 ff ff ff       	call   f010648e <cpunum>
f010650d:	6b c0 74             	imul   $0x74,%eax,%eax
f0106510:	05 20 00 2c f0       	add    $0xf02c0020,%eax
f0106515:	83 c4 10             	add    $0x10,%esp
f0106518:	39 05 c0 03 2c f0    	cmp    %eax,0xf02c03c0
f010651e:	74 0f                	je     f010652f <lapic_init+0x87>
		lapicw(LINT0, MASKED);
f0106520:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106525:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010652a:	e8 4b ff ff ff       	call   f010647a <lapicw>
	lapicw(LINT1, MASKED);
f010652f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106534:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106539:	e8 3c ff ff ff       	call   f010647a <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010653e:	a1 04 10 30 f0       	mov    0xf0301004,%eax
f0106543:	8b 40 30             	mov    0x30(%eax),%eax
f0106546:	c1 e8 10             	shr    $0x10,%eax
f0106549:	a8 fc                	test   $0xfc,%al
f010654b:	75 7c                	jne    f01065c9 <lapic_init+0x121>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f010654d:	ba 33 00 00 00       	mov    $0x33,%edx
f0106552:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106557:	e8 1e ff ff ff       	call   f010647a <lapicw>
	lapicw(ESR, 0);
f010655c:	ba 00 00 00 00       	mov    $0x0,%edx
f0106561:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106566:	e8 0f ff ff ff       	call   f010647a <lapicw>
	lapicw(ESR, 0);
f010656b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106570:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106575:	e8 00 ff ff ff       	call   f010647a <lapicw>
	lapicw(EOI, 0);
f010657a:	ba 00 00 00 00       	mov    $0x0,%edx
f010657f:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106584:	e8 f1 fe ff ff       	call   f010647a <lapicw>
	lapicw(ICRHI, 0);
f0106589:	ba 00 00 00 00       	mov    $0x0,%edx
f010658e:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106593:	e8 e2 fe ff ff       	call   f010647a <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106598:	ba 00 85 08 00       	mov    $0x88500,%edx
f010659d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01065a2:	e8 d3 fe ff ff       	call   f010647a <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01065a7:	8b 15 04 10 30 f0    	mov    0xf0301004,%edx
f01065ad:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01065b3:	f6 c4 10             	test   $0x10,%ah
f01065b6:	75 f5                	jne    f01065ad <lapic_init+0x105>
	lapicw(TPR, 0);
f01065b8:	ba 00 00 00 00       	mov    $0x0,%edx
f01065bd:	b8 20 00 00 00       	mov    $0x20,%eax
f01065c2:	e8 b3 fe ff ff       	call   f010647a <lapicw>
}
f01065c7:	c9                   	leave  
f01065c8:	c3                   	ret    
		lapicw(PCINT, MASKED);
f01065c9:	ba 00 00 01 00       	mov    $0x10000,%edx
f01065ce:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01065d3:	e8 a2 fe ff ff       	call   f010647a <lapicw>
f01065d8:	e9 70 ff ff ff       	jmp    f010654d <lapic_init+0xa5>

f01065dd <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01065dd:	f3 0f 1e fb          	endbr32 
	if (lapic)
f01065e1:	83 3d 04 10 30 f0 00 	cmpl   $0x0,0xf0301004
f01065e8:	74 17                	je     f0106601 <lapic_eoi+0x24>
{
f01065ea:	55                   	push   %ebp
f01065eb:	89 e5                	mov    %esp,%ebp
f01065ed:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f01065f0:	ba 00 00 00 00       	mov    $0x0,%edx
f01065f5:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01065fa:	e8 7b fe ff ff       	call   f010647a <lapicw>
}
f01065ff:	c9                   	leave  
f0106600:	c3                   	ret    
f0106601:	c3                   	ret    

f0106602 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106602:	f3 0f 1e fb          	endbr32 
f0106606:	55                   	push   %ebp
f0106607:	89 e5                	mov    %esp,%ebp
f0106609:	56                   	push   %esi
f010660a:	53                   	push   %ebx
f010660b:	8b 75 08             	mov    0x8(%ebp),%esi
f010660e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106611:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106616:	ba 70 00 00 00       	mov    $0x70,%edx
f010661b:	ee                   	out    %al,(%dx)
f010661c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106621:	ba 71 00 00 00       	mov    $0x71,%edx
f0106626:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0106627:	83 3d 14 f4 2b f0 00 	cmpl   $0x0,0xf02bf414
f010662e:	74 7e                	je     f01066ae <lapic_startap+0xac>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106630:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106637:	00 00 
	wrv[1] = addr >> 4;
f0106639:	89 d8                	mov    %ebx,%eax
f010663b:	c1 e8 04             	shr    $0x4,%eax
f010663e:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106644:	c1 e6 18             	shl    $0x18,%esi
f0106647:	89 f2                	mov    %esi,%edx
f0106649:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010664e:	e8 27 fe ff ff       	call   f010647a <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106653:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106658:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010665d:	e8 18 fe ff ff       	call   f010647a <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106662:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106667:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010666c:	e8 09 fe ff ff       	call   f010647a <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106671:	c1 eb 0c             	shr    $0xc,%ebx
f0106674:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f0106677:	89 f2                	mov    %esi,%edx
f0106679:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010667e:	e8 f7 fd ff ff       	call   f010647a <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106683:	89 da                	mov    %ebx,%edx
f0106685:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010668a:	e8 eb fd ff ff       	call   f010647a <lapicw>
		lapicw(ICRHI, apicid << 24);
f010668f:	89 f2                	mov    %esi,%edx
f0106691:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106696:	e8 df fd ff ff       	call   f010647a <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010669b:	89 da                	mov    %ebx,%edx
f010669d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01066a2:	e8 d3 fd ff ff       	call   f010647a <lapicw>
		microdelay(200);
	}
}
f01066a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01066aa:	5b                   	pop    %ebx
f01066ab:	5e                   	pop    %esi
f01066ac:	5d                   	pop    %ebp
f01066ad:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01066ae:	68 67 04 00 00       	push   $0x467
f01066b3:	68 44 74 10 f0       	push   $0xf0107444
f01066b8:	68 98 00 00 00       	push   $0x98
f01066bd:	68 b4 94 10 f0       	push   $0xf01094b4
f01066c2:	e8 79 99 ff ff       	call   f0100040 <_panic>

f01066c7 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01066c7:	f3 0f 1e fb          	endbr32 
f01066cb:	55                   	push   %ebp
f01066cc:	89 e5                	mov    %esp,%ebp
f01066ce:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01066d1:	8b 55 08             	mov    0x8(%ebp),%edx
f01066d4:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01066da:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01066df:	e8 96 fd ff ff       	call   f010647a <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01066e4:	8b 15 04 10 30 f0    	mov    0xf0301004,%edx
f01066ea:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01066f0:	f6 c4 10             	test   $0x10,%ah
f01066f3:	75 f5                	jne    f01066ea <lapic_ipi+0x23>
		;
}
f01066f5:	c9                   	leave  
f01066f6:	c3                   	ret    

f01066f7 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01066f7:	f3 0f 1e fb          	endbr32 
f01066fb:	55                   	push   %ebp
f01066fc:	89 e5                	mov    %esp,%ebp
f01066fe:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106701:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106707:	8b 55 0c             	mov    0xc(%ebp),%edx
f010670a:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010670d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106714:	5d                   	pop    %ebp
f0106715:	c3                   	ret    

f0106716 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106716:	f3 0f 1e fb          	endbr32 
f010671a:	55                   	push   %ebp
f010671b:	89 e5                	mov    %esp,%ebp
f010671d:	56                   	push   %esi
f010671e:	53                   	push   %ebx
f010671f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0106722:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106725:	75 07                	jne    f010672e <spin_lock+0x18>
	asm volatile("lock; xchgl %0, %1"
f0106727:	ba 01 00 00 00       	mov    $0x1,%edx
f010672c:	eb 34                	jmp    f0106762 <spin_lock+0x4c>
f010672e:	8b 73 08             	mov    0x8(%ebx),%esi
f0106731:	e8 58 fd ff ff       	call   f010648e <cpunum>
f0106736:	6b c0 74             	imul   $0x74,%eax,%eax
f0106739:	05 20 00 2c f0       	add    $0xf02c0020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010673e:	39 c6                	cmp    %eax,%esi
f0106740:	75 e5                	jne    f0106727 <spin_lock+0x11>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106742:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106745:	e8 44 fd ff ff       	call   f010648e <cpunum>
f010674a:	83 ec 0c             	sub    $0xc,%esp
f010674d:	53                   	push   %ebx
f010674e:	50                   	push   %eax
f010674f:	68 c4 94 10 f0       	push   $0xf01094c4
f0106754:	6a 41                	push   $0x41
f0106756:	68 26 95 10 f0       	push   $0xf0109526
f010675b:	e8 e0 98 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106760:	f3 90                	pause  
f0106762:	89 d0                	mov    %edx,%eax
f0106764:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f0106767:	85 c0                	test   %eax,%eax
f0106769:	75 f5                	jne    f0106760 <spin_lock+0x4a>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010676b:	e8 1e fd ff ff       	call   f010648e <cpunum>
f0106770:	6b c0 74             	imul   $0x74,%eax,%eax
f0106773:	05 20 00 2c f0       	add    $0xf02c0020,%eax
f0106778:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010677b:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f010677d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106782:	83 f8 09             	cmp    $0x9,%eax
f0106785:	7f 21                	jg     f01067a8 <spin_lock+0x92>
f0106787:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f010678d:	76 19                	jbe    f01067a8 <spin_lock+0x92>
		pcs[i] = ebp[1];          // saved %eip
f010678f:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106792:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106796:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0106798:	83 c0 01             	add    $0x1,%eax
f010679b:	eb e5                	jmp    f0106782 <spin_lock+0x6c>
		pcs[i] = 0;
f010679d:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f01067a4:	00 
	for (; i < 10; i++)
f01067a5:	83 c0 01             	add    $0x1,%eax
f01067a8:	83 f8 09             	cmp    $0x9,%eax
f01067ab:	7e f0                	jle    f010679d <spin_lock+0x87>
	get_caller_pcs(lk->pcs);
#endif
}
f01067ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01067b0:	5b                   	pop    %ebx
f01067b1:	5e                   	pop    %esi
f01067b2:	5d                   	pop    %ebp
f01067b3:	c3                   	ret    

f01067b4 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01067b4:	f3 0f 1e fb          	endbr32 
f01067b8:	55                   	push   %ebp
f01067b9:	89 e5                	mov    %esp,%ebp
f01067bb:	57                   	push   %edi
f01067bc:	56                   	push   %esi
f01067bd:	53                   	push   %ebx
f01067be:	83 ec 4c             	sub    $0x4c,%esp
f01067c1:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f01067c4:	83 3e 00             	cmpl   $0x0,(%esi)
f01067c7:	75 35                	jne    f01067fe <spin_unlock+0x4a>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01067c9:	83 ec 04             	sub    $0x4,%esp
f01067cc:	6a 28                	push   $0x28
f01067ce:	8d 46 0c             	lea    0xc(%esi),%eax
f01067d1:	50                   	push   %eax
f01067d2:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01067d5:	53                   	push   %ebx
f01067d6:	e8 de f6 ff ff       	call   f0105eb9 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01067db:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01067de:	0f b6 38             	movzbl (%eax),%edi
f01067e1:	8b 76 04             	mov    0x4(%esi),%esi
f01067e4:	e8 a5 fc ff ff       	call   f010648e <cpunum>
f01067e9:	57                   	push   %edi
f01067ea:	56                   	push   %esi
f01067eb:	50                   	push   %eax
f01067ec:	68 f0 94 10 f0       	push   $0xf01094f0
f01067f1:	e8 3a d6 ff ff       	call   f0103e30 <cprintf>
f01067f6:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01067f9:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01067fc:	eb 4e                	jmp    f010684c <spin_unlock+0x98>
	return lock->locked && lock->cpu == thiscpu;
f01067fe:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106801:	e8 88 fc ff ff       	call   f010648e <cpunum>
f0106806:	6b c0 74             	imul   $0x74,%eax,%eax
f0106809:	05 20 00 2c f0       	add    $0xf02c0020,%eax
	if (!holding(lk)) {
f010680e:	39 c3                	cmp    %eax,%ebx
f0106810:	75 b7                	jne    f01067c9 <spin_unlock+0x15>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0106812:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106819:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f0106820:	b8 00 00 00 00       	mov    $0x0,%eax
f0106825:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106828:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010682b:	5b                   	pop    %ebx
f010682c:	5e                   	pop    %esi
f010682d:	5f                   	pop    %edi
f010682e:	5d                   	pop    %ebp
f010682f:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f0106830:	83 ec 08             	sub    $0x8,%esp
f0106833:	ff 36                	pushl  (%esi)
f0106835:	68 4d 95 10 f0       	push   $0xf010954d
f010683a:	e8 f1 d5 ff ff       	call   f0103e30 <cprintf>
f010683f:	83 c4 10             	add    $0x10,%esp
f0106842:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106845:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106848:	39 c3                	cmp    %eax,%ebx
f010684a:	74 40                	je     f010688c <spin_unlock+0xd8>
f010684c:	89 de                	mov    %ebx,%esi
f010684e:	8b 03                	mov    (%ebx),%eax
f0106850:	85 c0                	test   %eax,%eax
f0106852:	74 38                	je     f010688c <spin_unlock+0xd8>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106854:	83 ec 08             	sub    $0x8,%esp
f0106857:	57                   	push   %edi
f0106858:	50                   	push   %eax
f0106859:	e8 7f ea ff ff       	call   f01052dd <debuginfo_eip>
f010685e:	83 c4 10             	add    $0x10,%esp
f0106861:	85 c0                	test   %eax,%eax
f0106863:	78 cb                	js     f0106830 <spin_unlock+0x7c>
					pcs[i] - info.eip_fn_addr);
f0106865:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106867:	83 ec 04             	sub    $0x4,%esp
f010686a:	89 c2                	mov    %eax,%edx
f010686c:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010686f:	52                   	push   %edx
f0106870:	ff 75 b0             	pushl  -0x50(%ebp)
f0106873:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106876:	ff 75 ac             	pushl  -0x54(%ebp)
f0106879:	ff 75 a8             	pushl  -0x58(%ebp)
f010687c:	50                   	push   %eax
f010687d:	68 36 95 10 f0       	push   $0xf0109536
f0106882:	e8 a9 d5 ff ff       	call   f0103e30 <cprintf>
f0106887:	83 c4 20             	add    $0x20,%esp
f010688a:	eb b6                	jmp    f0106842 <spin_unlock+0x8e>
		panic("spin_unlock");
f010688c:	83 ec 04             	sub    $0x4,%esp
f010688f:	68 55 95 10 f0       	push   $0xf0109555
f0106894:	6a 67                	push   $0x67
f0106896:	68 26 95 10 f0       	push   $0xf0109526
f010689b:	e8 a0 97 ff ff       	call   f0100040 <_panic>

f01068a0 <e1000_tx_desc_init>:
// This setting only has meaning in half duplex mode.
// Configure the Collision Distance (TCTL.COLD) to its expected value. For full duplex
// operation, this value should be set to 40h. For gigabit half duplex, this value should be set to
// 200h. For 10/100 half duplex, this value should be set to 40h.
void e1000_tx_desc_init()
{
f01068a0:	f3 0f 1e fb          	endbr32 
f01068a4:	55                   	push   %ebp
f01068a5:	89 e5                	mov    %esp,%ebp
f01068a7:	57                   	push   %edi
f01068a8:	56                   	push   %esi
f01068a9:	53                   	push   %ebx
f01068aa:	83 ec 10             	sub    $0x10,%esp
    int i;
    memset(tx_desc_ring, 0, sizeof(struct tx_desc)*TX_RING_SIZE);
f01068ad:	68 00 04 00 00       	push   $0x400
f01068b2:	6a 00                	push   $0x0
f01068b4:	68 00 f0 2b f0       	push   $0xf02bf000
f01068b9:	e8 af f5 ff ff       	call   f0105e6d <memset>
f01068be:	ba 00 30 30 f0       	mov    $0xf0303000,%edx
f01068c3:	b9 00 30 30 00       	mov    $0x303000,%ecx
f01068c8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01068cd:	b8 00 f0 2b f0       	mov    $0xf02bf000,%eax
f01068d2:	be 80 ab 31 f0       	mov    $0xf031ab80,%esi
f01068d7:	83 c4 10             	add    $0x10,%esp
	if ((uint32_t)kva < KERNBASE)
f01068da:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01068e0:	76 2b                	jbe    f010690d <e1000_tx_desc_init+0x6d>
    for (i=0;i<TX_RING_SIZE; i++){
        // 物理地址
        tx_desc_ring[i].buffer_addr = PADDR(tx_pbuf[i]);
f01068e2:	89 08                	mov    %ecx,(%eax)
f01068e4:	89 58 04             	mov    %ebx,0x4(%eax)
        tx_desc_ring[i].status = E1000_TXD_STAT_DD;
f01068e7:	c6 40 0c 01          	movb   $0x1,0xc(%eax)
        tx_desc_ring[i].cmd = E1000_TXD_CMD_RS|E1000_TXD_CMD_EOP;
f01068eb:	c6 40 0b 09          	movb   $0x9,0xb(%eax)
f01068ef:	81 c2 ee 05 00 00    	add    $0x5ee,%edx
f01068f5:	81 c1 ee 05 00 00    	add    $0x5ee,%ecx
f01068fb:	83 d3 00             	adc    $0x0,%ebx
f01068fe:	83 c0 10             	add    $0x10,%eax
    for (i=0;i<TX_RING_SIZE; i++){
f0106901:	39 f2                	cmp    %esi,%edx
f0106903:	75 d5                	jne    f01068da <e1000_tx_desc_init+0x3a>
    }
    return;
}
f0106905:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106908:	5b                   	pop    %ebx
f0106909:	5e                   	pop    %esi
f010690a:	5f                   	pop    %edi
f010690b:	5d                   	pop    %ebp
f010690c:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010690d:	52                   	push   %edx
f010690e:	68 68 74 10 f0       	push   $0xf0107468
f0106913:	6a 2e                	push   $0x2e
f0106915:	68 6d 95 10 f0       	push   $0xf010956d
f010691a:	e8 21 97 ff ff       	call   f0100040 <_panic>

f010691f <e1000_rx_desc_init>:
void e1000_rx_desc_init()
{
f010691f:	f3 0f 1e fb          	endbr32 
f0106923:	55                   	push   %ebp
f0106924:	89 e5                	mov    %esp,%ebp
f0106926:	57                   	push   %edi
f0106927:	56                   	push   %esi
f0106928:	53                   	push   %ebx
f0106929:	83 ec 10             	sub    $0x10,%esp
    int i;
    memset(rx_desc_ring, 0, sizeof(struct rx_desc)*RX_RING_SIZE);
f010692c:	68 00 08 00 00       	push   $0x800
f0106931:	6a 00                	push   $0x0
f0106933:	68 00 e0 2b f0       	push   $0xf02be000
f0106938:	e8 30 f5 ff ff       	call   f0105e6d <memset>
f010693d:	b8 00 b0 31 f0       	mov    $0xf031b000,%eax
f0106942:	b9 00 b0 31 00       	mov    $0x31b000,%ecx
f0106947:	bb 00 00 00 00       	mov    $0x0,%ebx
f010694c:	ba 00 e0 2b f0       	mov    $0xf02be000,%edx
f0106951:	be 00 a7 34 f0       	mov    $0xf034a700,%esi
f0106956:	83 c4 10             	add    $0x10,%esp
	if ((uint32_t)kva < KERNBASE)
f0106959:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010695e:	76 26                	jbe    f0106986 <e1000_rx_desc_init+0x67>
    for (i=0; i<RX_RING_SIZE;i++){
        rx_desc_ring[i].buffer_addr = PADDR(rx_pbuf[i]);
f0106960:	89 0a                	mov    %ecx,(%edx)
f0106962:	89 5a 04             	mov    %ebx,0x4(%edx)
        rx_desc_ring[i].status = 0;
f0106965:	c6 42 0c 00          	movb   $0x0,0xc(%edx)
f0106969:	05 ee 05 00 00       	add    $0x5ee,%eax
f010696e:	81 c1 ee 05 00 00    	add    $0x5ee,%ecx
f0106974:	83 d3 00             	adc    $0x0,%ebx
f0106977:	83 c2 10             	add    $0x10,%edx
    for (i=0; i<RX_RING_SIZE;i++){
f010697a:	39 f0                	cmp    %esi,%eax
f010697c:	75 db                	jne    f0106959 <e1000_rx_desc_init+0x3a>
    }
}
f010697e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106981:	5b                   	pop    %ebx
f0106982:	5e                   	pop    %esi
f0106983:	5f                   	pop    %edi
f0106984:	5d                   	pop    %ebp
f0106985:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0106986:	50                   	push   %eax
f0106987:	68 68 74 10 f0       	push   $0xf0107468
f010698c:	6a 39                	push   $0x39
f010698e:	68 6d 95 10 f0       	push   $0xf010956d
f0106993:	e8 a8 96 ff ff       	call   f0100040 <_panic>

f0106998 <e1000_set_mac_addr>:
void 
e1000_set_mac_addr(uint32_t mac[])
{
f0106998:	f3 0f 1e fb          	endbr32 
f010699c:	55                   	push   %ebp
f010699d:	89 e5                	mov    %esp,%ebp
f010699f:	56                   	push   %esi
f01069a0:	53                   	push   %ebx
f01069a1:	8b 75 08             	mov    0x8(%ebp),%esi
    uint32_t low = 0, high = 0; int i;
    for (i=0; i<4; i++) low |= mac[i]<<(8*i);
f01069a4:	8b 56 08             	mov    0x8(%esi),%edx
f01069a7:	c1 e2 10             	shl    $0x10,%edx
f01069aa:	0b 16                	or     (%esi),%edx
f01069ac:	8b 46 04             	mov    0x4(%esi),%eax
f01069af:	c1 e0 08             	shl    $0x8,%eax
f01069b2:	09 c2                	or     %eax,%edx
    for (;i<6;i++) high |= mac[i]<<(8*i);
f01069b4:	8b 5e 10             	mov    0x10(%esi),%ebx
f01069b7:	b9 20 00 00 00       	mov    $0x20,%ecx
f01069bc:	d3 e3                	shl    %cl,%ebx
f01069be:	8b 46 14             	mov    0x14(%esi),%eax
f01069c1:	b9 28 00 00 00       	mov    $0x28,%ecx
f01069c6:	d3 e0                	shl    %cl,%eax
f01069c8:	09 d8                	or     %ebx,%eax
    
    // hard code receive address
    *(uint32_t* )((uint8_t* )e1000 + E1000_RAL) = low;
f01069ca:	8b 1d 00 20 30 f0    	mov    0xf0302000,%ebx
    for (i=0; i<4; i++) low |= mac[i]<<(8*i);
f01069d0:	8b 4e 0c             	mov    0xc(%esi),%ecx
f01069d3:	c1 e1 18             	shl    $0x18,%ecx
f01069d6:	09 ca                	or     %ecx,%edx
f01069d8:	89 93 00 54 00 00    	mov    %edx,0x5400(%ebx)
    *(uint32_t* )((uint8_t* )e1000 + E1000_RAH) = high|E1000_RAH_AV;
f01069de:	0d 00 00 00 80       	or     $0x80000000,%eax
f01069e3:	89 83 04 54 00 00    	mov    %eax,0x5404(%ebx)
}
f01069e9:	5b                   	pop    %ebx
f01069ea:	5e                   	pop    %esi
f01069eb:	5d                   	pop    %ebp
f01069ec:	c3                   	ret    

f01069ed <pci_e1000_attach>:
int
pci_e1000_attach(struct pci_func* pcif)
{
f01069ed:	f3 0f 1e fb          	endbr32 
f01069f1:	55                   	push   %ebp
f01069f2:	89 e5                	mov    %esp,%ebp
f01069f4:	53                   	push   %ebx
f01069f5:	83 ec 10             	sub    $0x10,%esp
f01069f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	pci_func_enable(pcif);
f01069fb:	53                   	push   %ebx
f01069fc:	e8 ed 05 00 00       	call   f0106fee <pci_func_enable>
    e1000_tx_desc_init();
f0106a01:	e8 9a fe ff ff       	call   f01068a0 <e1000_tx_desc_init>
    e1000_rx_desc_init();
f0106a06:	e8 14 ff ff ff       	call   f010691f <e1000_rx_desc_init>
    // 将E1000的物理地址映射到虚拟地址
    e1000 = mmio_map_region(pcif->reg_base[0], pcif->reg_size[0]);
f0106a0b:	83 c4 08             	add    $0x8,%esp
f0106a0e:	ff 73 2c             	pushl  0x2c(%ebx)
f0106a11:	ff 73 14             	pushl  0x14(%ebx)
f0106a14:	e8 9d ad ff ff       	call   f01017b6 <mmio_map_region>
f0106a19:	a3 00 20 30 f0       	mov    %eax,0xf0302000
	if ((uint32_t)kva < KERNBASE)
f0106a1e:	83 c4 10             	add    $0x10,%esp
f0106a21:	ba 00 f0 2b f0       	mov    $0xf02bf000,%edx
f0106a26:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0106a2c:	0f 86 c2 00 00 00    	jbe    f0106af4 <pci_e1000_attach+0x107>
	return (physaddr_t)kva - KERNBASE;
f0106a32:	c7 80 00 38 00 00 00 	movl   $0x2bf000,0x3800(%eax)
f0106a39:	f0 2b 00 
    // transmitter
    *(uint32_t* )((uint8_t* )e1000+E1000_TDBAL) = PADDR(tx_desc_ring); 
    *(uint32_t* )((uint8_t* )e1000+E1000_TDBAH) = 0;
f0106a3c:	c7 80 04 38 00 00 00 	movl   $0x0,0x3804(%eax)
f0106a43:	00 00 00 
    *(uint32_t* )((uint8_t* )e1000+E1000_TDH) = 0;
f0106a46:	c7 80 10 38 00 00 00 	movl   $0x0,0x3810(%eax)
f0106a4d:	00 00 00 
    *(uint32_t* )((uint8_t* )e1000+E1000_TDT) = 0;
f0106a50:	c7 80 18 38 00 00 00 	movl   $0x0,0x3818(%eax)
f0106a57:	00 00 00 
    *(uint32_t* )((uint8_t* )e1000+E1000_TDLEN) = TX_RING_SIZE*sizeof(struct tx_desc);
f0106a5a:	c7 80 08 38 00 00 00 	movl   $0x400,0x3808(%eax)
f0106a61:	04 00 00 

    *(uint32_t* )((uint8_t*)e1000+E1000_TCTL) = E1000_TCTL_EN|
f0106a64:	c7 80 00 04 00 00 0a 	movl   $0x4010a,0x400(%eax)
f0106a6b:	01 04 00 
                        E1000_TCTL_PSP|
                        (E1000_TCTL_CT&(0x10<<4))|
                        (E1000_TCTL_COLD&(0x40<<12));

    // 这里的值需要查看IEEE 802.3 section 13.4.34 table 13-77
    *(uint32_t* )((uint8_t* )e1000+E1000_TIPG) = 10 |(8<<10)|(12<<20);
f0106a6e:	c7 80 10 04 00 00 0a 	movl   $0xc0200a,0x410(%eax)
f0106a75:	20 c0 00 
    // receiver
    e1000_set_mac_addr(mac);
f0106a78:	83 ec 0c             	sub    $0xc,%esp
f0106a7b:	68 f4 73 12 f0       	push   $0xf01273f4
f0106a80:	e8 13 ff ff ff       	call   f0106998 <e1000_set_mac_addr>
    *(uint32_t* )((uint8_t* )e1000+E1000_MTA) = 0;
f0106a85:	a1 00 20 30 f0       	mov    0xf0302000,%eax
f0106a8a:	c7 80 00 52 00 00 00 	movl   $0x0,0x5200(%eax)
f0106a91:	00 00 00 
    *(uint32_t* )((uint8_t* )e1000+E1000_IMS) = E1000_IMS_RXT|
f0106a94:	c7 80 d0 00 00 00 dc 	movl   $0xdc,0xd0(%eax)
f0106a9b:	00 00 00 
	if ((uint32_t)kva < KERNBASE)
f0106a9e:	83 c4 10             	add    $0x10,%esp
f0106aa1:	ba 00 e0 2b f0       	mov    $0xf02be000,%edx
f0106aa6:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0106aac:	76 58                	jbe    f0106b06 <pci_e1000_attach+0x119>
	return (physaddr_t)kva - KERNBASE;
f0106aae:	c7 80 00 28 00 00 00 	movl   $0x2be000,0x2800(%eax)
f0106ab5:	e0 2b 00 
                            E1000_IMS_RXO|
                            E1000_IMS_RXDMT|
                            E1000_IMS_RXSEQ|
                            E1000_IMS_LSC;
    *(uint32_t* )((uint8_t* )e1000+E1000_RDBAL) = PADDR(rx_desc_ring);
    *(uint32_t* )((uint8_t* )e1000+E1000_RDBAH) = 0;
f0106ab8:	c7 80 04 28 00 00 00 	movl   $0x0,0x2804(%eax)
f0106abf:	00 00 00 
    *(uint32_t* )((uint8_t* )e1000+E1000_RDLEN) = RX_RING_SIZE*sizeof(struct rx_desc);
f0106ac2:	c7 80 08 28 00 00 00 	movl   $0x800,0x2808(%eax)
f0106ac9:	08 00 00 
    *(uint32_t* )((uint8_t* )e1000+E1000_RDH) = 0;
f0106acc:	c7 80 10 28 00 00 00 	movl   $0x0,0x2810(%eax)
f0106ad3:	00 00 00 
    /*
     * 这里需要将rx tail设置为最后一个可用的描述符即RX_RING_SIZE-1
     * 否则RDH=RDT, 硬件会判断为循环队列已满
    */
    *(uint32_t* )((uint8_t* )e1000+E1000_RDT) = RX_RING_SIZE-1;
f0106ad6:	c7 80 18 28 00 00 7f 	movl   $0x7f,0x2818(%eax)
f0106add:	00 00 00 
    *(uint32_t* )((uint8_t* )e1000+E1000_RCTL) = E1000_RCTL_EN|
f0106ae0:	c7 80 00 01 00 00 02 	movl   $0x4000002,0x100(%eax)
f0106ae7:	00 00 04 

    // cprintf("e1000 device status: [%08x]\n", *(uint32_t* )((uint8_t*)e1000+E1000_STATUS));

	return 1;

}
f0106aea:	b8 01 00 00 00       	mov    $0x1,%eax
f0106aef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0106af2:	c9                   	leave  
f0106af3:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0106af4:	52                   	push   %edx
f0106af5:	68 68 74 10 f0       	push   $0xf0107468
f0106afa:	6a 51                	push   $0x51
f0106afc:	68 6d 95 10 f0       	push   $0xf010956d
f0106b01:	e8 3a 95 ff ff       	call   f0100040 <_panic>
f0106b06:	52                   	push   %edx
f0106b07:	68 68 74 10 f0       	push   $0xf0107468
f0106b0c:	6a 66                	push   $0x66
f0106b0e:	68 6d 95 10 f0       	push   $0xf010956d
f0106b13:	e8 28 95 ff ff       	call   f0100040 <_panic>

f0106b18 <e1000_transmit>:

// Hardware fetches the descriptor indicated by the hardware head register. The
// hardware tail register points one beyond the last valid descriptor.
int
e1000_transmit(void* srcaddr, size_t len)
{
f0106b18:	f3 0f 1e fb          	endbr32 
f0106b1c:	55                   	push   %ebp
f0106b1d:	89 e5                	mov    %esp,%ebp
f0106b1f:	56                   	push   %esi
f0106b20:	53                   	push   %ebx
f0106b21:	8b 75 0c             	mov    0xc(%ebp),%esi
    size_t tx_tail = *(uint32_t* )((uint8_t* )e1000+E1000_TDT); // offset from the base
f0106b24:	a1 00 20 30 f0       	mov    0xf0302000,%eax
f0106b29:	8b 98 18 38 00 00    	mov    0x3818(%eax),%ebx
    struct tx_desc* tail_desc = &tx_desc_ring[tx_tail];
    if (!(tail_desc->status & E1000_TXD_STAT_DD)){
f0106b2f:	89 d8                	mov    %ebx,%eax
f0106b31:	c1 e0 04             	shl    $0x4,%eax
f0106b34:	f6 80 0c f0 2b f0 01 	testb  $0x1,-0xfd40ff4(%eax)
f0106b3b:	74 5b                	je     f0106b98 <e1000_transmit+0x80>
f0106b3d:	81 fe ee 05 00 00    	cmp    $0x5ee,%esi
f0106b43:	b8 ee 05 00 00       	mov    $0x5ee,%eax
f0106b48:	0f 47 f0             	cmova  %eax,%esi
    if (len>TX_PACKET_SIZE){
        len = TX_PACKET_SIZE;
    }
    // descriptor done --> available
    // 这里memmove不可使用 tx_desc_ring[i].buffer_addr as dstaddr 因为是物理地址
    memmove(&tx_pbuf[tx_tail], srcaddr, len);
f0106b4b:	83 ec 04             	sub    $0x4,%esp
f0106b4e:	56                   	push   %esi
f0106b4f:	ff 75 08             	pushl  0x8(%ebp)
f0106b52:	69 c3 ee 05 00 00    	imul   $0x5ee,%ebx,%eax
f0106b58:	05 00 30 30 f0       	add    $0xf0303000,%eax
f0106b5d:	50                   	push   %eax
f0106b5e:	e8 56 f3 ff ff       	call   f0105eb9 <memmove>
    tail_desc->length = len;
f0106b63:	89 d8                	mov    %ebx,%eax
f0106b65:	c1 e0 04             	shl    $0x4,%eax
f0106b68:	66 89 b0 08 f0 2b f0 	mov    %si,-0xfd40ff8(%eax)
f0106b6f:	05 00 f0 2b f0       	add    $0xf02bf000,%eax
    tail_desc->status &= (~E1000_TXD_STAT_DD);
f0106b74:	80 60 0c fe          	andb   $0xfe,0xc(%eax)
    // update TDT
    *(uint32_t* )((uint8_t* )e1000+E1000_TDT) = (tx_tail + 1)%TX_RING_SIZE;
f0106b78:	83 c3 01             	add    $0x1,%ebx
f0106b7b:	83 e3 3f             	and    $0x3f,%ebx
f0106b7e:	a1 00 20 30 f0       	mov    0xf0302000,%eax
f0106b83:	89 98 18 38 00 00    	mov    %ebx,0x3818(%eax)
    return 0;
f0106b89:	83 c4 10             	add    $0x10,%esp
f0106b8c:	b8 00 00 00 00       	mov    $0x0,%eax

}
f0106b91:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106b94:	5b                   	pop    %ebx
f0106b95:	5e                   	pop    %esi
f0106b96:	5d                   	pop    %ebp
f0106b97:	c3                   	ret    
        return -1;
f0106b98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0106b9d:	eb f2                	jmp    f0106b91 <e1000_transmit+0x79>

f0106b9f <e1000_receive>:
// more receive buffers available. 
// 当有新的packet received, head pointer incremented
// 从rx_desc_ring中读取后 需要increment tail pointer
int
e1000_receive(void* buf, size_t buflen)
{
f0106b9f:	f3 0f 1e fb          	endbr32 
f0106ba3:	55                   	push   %ebp
f0106ba4:	89 e5                	mov    %esp,%ebp
f0106ba6:	57                   	push   %edi
f0106ba7:	56                   	push   %esi
f0106ba8:	53                   	push   %ebx
f0106ba9:	83 ec 0c             	sub    $0xc,%esp
f0106bac:	8b 45 0c             	mov    0xc(%ebp),%eax
    // rx_tail 指向下一个可读的descriptor
    size_t rx_tail = (*(uint32_t* )((uint8_t* )e1000+E1000_RDT)+1)% RX_RING_SIZE;
f0106baf:	8b 15 00 20 30 f0    	mov    0xf0302000,%edx
f0106bb5:	8b 9a 18 28 00 00    	mov    0x2818(%edx),%ebx
f0106bbb:	83 c3 01             	add    $0x1,%ebx
f0106bbe:	83 e3 7f             	and    $0x7f,%ebx
    struct rx_desc* tail_desc = &rx_desc_ring[rx_tail];
    if (!(tail_desc->status&E1000_RXD_STAT_DD))
f0106bc1:	89 da                	mov    %ebx,%edx
f0106bc3:	c1 e2 04             	shl    $0x4,%edx
f0106bc6:	f6 82 0c e0 2b f0 01 	testb  $0x1,-0xfd41ff4(%edx)
f0106bcd:	74 4b                	je     f0106c1a <e1000_receive+0x7b>
        return -1;

    if (buflen>tail_desc->length)
f0106bcf:	89 da                	mov    %ebx,%edx
f0106bd1:	c1 e2 04             	shl    $0x4,%edx
f0106bd4:	8d ba 00 e0 2b f0    	lea    -0xfd42000(%edx),%edi
f0106bda:	0f b7 b2 08 e0 2b f0 	movzwl -0xfd41ff8(%edx),%esi
f0106be1:	39 c6                	cmp    %eax,%esi
f0106be3:	0f 47 f0             	cmova  %eax,%esi
        buflen = tail_desc->length;

    memmove(buf, &rx_pbuf[rx_tail], buflen);
f0106be6:	83 ec 04             	sub    $0x4,%esp
f0106be9:	56                   	push   %esi
f0106bea:	69 c3 ee 05 00 00    	imul   $0x5ee,%ebx,%eax
f0106bf0:	05 00 b0 31 f0       	add    $0xf031b000,%eax
f0106bf5:	50                   	push   %eax
f0106bf6:	ff 75 08             	pushl  0x8(%ebp)
f0106bf9:	e8 bb f2 ff ff       	call   f0105eb9 <memmove>

    tail_desc->status &= (~E1000_RXD_STAT_DD);
f0106bfe:	80 67 0c fe          	andb   $0xfe,0xc(%edi)
    // update tail
    *(uint32_t* )((uint8_t* )e1000+E1000_RDT) = rx_tail;
f0106c02:	a1 00 20 30 f0       	mov    0xf0302000,%eax
f0106c07:	89 98 18 28 00 00    	mov    %ebx,0x2818(%eax)
    
    return buflen;
f0106c0d:	89 f0                	mov    %esi,%eax
f0106c0f:	83 c4 10             	add    $0x10,%esp
f0106c12:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106c15:	5b                   	pop    %ebx
f0106c16:	5e                   	pop    %esi
f0106c17:	5f                   	pop    %edi
f0106c18:	5d                   	pop    %ebp
f0106c19:	c3                   	ret    
        return -1;
f0106c1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0106c1f:	eb f1                	jmp    f0106c12 <e1000_receive+0x73>

f0106c21 <pci_attach_match>:
}

static int __attribute__((warn_unused_result))
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
f0106c21:	55                   	push   %ebp
f0106c22:	89 e5                	mov    %esp,%ebp
f0106c24:	57                   	push   %edi
f0106c25:	56                   	push   %esi
f0106c26:	53                   	push   %ebx
f0106c27:	83 ec 0c             	sub    $0xc,%esp
f0106c2a:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106c2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f0106c30:	eb 03                	jmp    f0106c35 <pci_attach_match+0x14>
f0106c32:	83 c3 0c             	add    $0xc,%ebx
f0106c35:	89 de                	mov    %ebx,%esi
f0106c37:	8b 43 08             	mov    0x8(%ebx),%eax
f0106c3a:	85 c0                	test   %eax,%eax
f0106c3c:	74 37                	je     f0106c75 <pci_attach_match+0x54>
		if (list[i].key1 == key1 && list[i].key2 == key2) {
f0106c3e:	39 3b                	cmp    %edi,(%ebx)
f0106c40:	75 f0                	jne    f0106c32 <pci_attach_match+0x11>
f0106c42:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106c45:	39 56 04             	cmp    %edx,0x4(%esi)
f0106c48:	75 e8                	jne    f0106c32 <pci_attach_match+0x11>
			int r = list[i].attachfn(pcif);
f0106c4a:	83 ec 0c             	sub    $0xc,%esp
f0106c4d:	ff 75 14             	pushl  0x14(%ebp)
f0106c50:	ff d0                	call   *%eax
			if (r > 0)
f0106c52:	83 c4 10             	add    $0x10,%esp
f0106c55:	85 c0                	test   %eax,%eax
f0106c57:	7f 1c                	jg     f0106c75 <pci_attach_match+0x54>
				return r;
			if (r < 0)
f0106c59:	79 d7                	jns    f0106c32 <pci_attach_match+0x11>
				cprintf("pci_attach_match: attaching "
f0106c5b:	83 ec 0c             	sub    $0xc,%esp
f0106c5e:	50                   	push   %eax
f0106c5f:	ff 76 08             	pushl  0x8(%esi)
f0106c62:	ff 75 0c             	pushl  0xc(%ebp)
f0106c65:	57                   	push   %edi
f0106c66:	68 7c 95 10 f0       	push   $0xf010957c
f0106c6b:	e8 c0 d1 ff ff       	call   f0103e30 <cprintf>
f0106c70:	83 c4 20             	add    $0x20,%esp
f0106c73:	eb bd                	jmp    f0106c32 <pci_attach_match+0x11>
					"%x.%x (%p): e\n",
					key1, key2, list[i].attachfn, r);
		}
	}
	return 0;
}
f0106c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106c78:	5b                   	pop    %ebx
f0106c79:	5e                   	pop    %esi
f0106c7a:	5f                   	pop    %edi
f0106c7b:	5d                   	pop    %ebp
f0106c7c:	c3                   	ret    

f0106c7d <pci_conf1_set_addr>:
{
f0106c7d:	55                   	push   %ebp
f0106c7e:	89 e5                	mov    %esp,%ebp
f0106c80:	53                   	push   %ebx
f0106c81:	83 ec 04             	sub    $0x4,%esp
f0106c84:	8b 5d 08             	mov    0x8(%ebp),%ebx
	assert(bus < 256);
f0106c87:	3d ff 00 00 00       	cmp    $0xff,%eax
f0106c8c:	77 36                	ja     f0106cc4 <pci_conf1_set_addr+0x47>
	assert(dev < 32);
f0106c8e:	83 fa 1f             	cmp    $0x1f,%edx
f0106c91:	77 47                	ja     f0106cda <pci_conf1_set_addr+0x5d>
	assert(func < 8);
f0106c93:	83 f9 07             	cmp    $0x7,%ecx
f0106c96:	77 58                	ja     f0106cf0 <pci_conf1_set_addr+0x73>
	assert(offset < 256);
f0106c98:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0106c9e:	77 66                	ja     f0106d06 <pci_conf1_set_addr+0x89>
	assert((offset & 0x3) == 0);
f0106ca0:	f6 c3 03             	test   $0x3,%bl
f0106ca3:	75 77                	jne    f0106d1c <pci_conf1_set_addr+0x9f>
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
f0106ca5:	c1 e0 10             	shl    $0x10,%eax
f0106ca8:	09 d8                	or     %ebx,%eax
f0106caa:	c1 e1 08             	shl    $0x8,%ecx
f0106cad:	09 c8                	or     %ecx,%eax
f0106caf:	c1 e2 0b             	shl    $0xb,%edx
f0106cb2:	09 d0                	or     %edx,%eax
	uint32_t v = (1 << 31) |		// config-space
f0106cb4:	0d 00 00 00 80       	or     $0x80000000,%eax
	asm volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0106cb9:	ba f8 0c 00 00       	mov    $0xcf8,%edx
f0106cbe:	ef                   	out    %eax,(%dx)
}
f0106cbf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0106cc2:	c9                   	leave  
f0106cc3:	c3                   	ret    
	assert(bus < 256);
f0106cc4:	68 d3 96 10 f0       	push   $0xf01096d3
f0106cc9:	68 33 87 10 f0       	push   $0xf0108733
f0106cce:	6a 34                	push   $0x34
f0106cd0:	68 dd 96 10 f0       	push   $0xf01096dd
f0106cd5:	e8 66 93 ff ff       	call   f0100040 <_panic>
	assert(dev < 32);
f0106cda:	68 e8 96 10 f0       	push   $0xf01096e8
f0106cdf:	68 33 87 10 f0       	push   $0xf0108733
f0106ce4:	6a 35                	push   $0x35
f0106ce6:	68 dd 96 10 f0       	push   $0xf01096dd
f0106ceb:	e8 50 93 ff ff       	call   f0100040 <_panic>
	assert(func < 8);
f0106cf0:	68 f1 96 10 f0       	push   $0xf01096f1
f0106cf5:	68 33 87 10 f0       	push   $0xf0108733
f0106cfa:	6a 36                	push   $0x36
f0106cfc:	68 dd 96 10 f0       	push   $0xf01096dd
f0106d01:	e8 3a 93 ff ff       	call   f0100040 <_panic>
	assert(offset < 256);
f0106d06:	68 fa 96 10 f0       	push   $0xf01096fa
f0106d0b:	68 33 87 10 f0       	push   $0xf0108733
f0106d10:	6a 37                	push   $0x37
f0106d12:	68 dd 96 10 f0       	push   $0xf01096dd
f0106d17:	e8 24 93 ff ff       	call   f0100040 <_panic>
	assert((offset & 0x3) == 0);
f0106d1c:	68 07 97 10 f0       	push   $0xf0109707
f0106d21:	68 33 87 10 f0       	push   $0xf0108733
f0106d26:	6a 38                	push   $0x38
f0106d28:	68 dd 96 10 f0       	push   $0xf01096dd
f0106d2d:	e8 0e 93 ff ff       	call   f0100040 <_panic>

f0106d32 <pci_conf_read>:
{
f0106d32:	55                   	push   %ebp
f0106d33:	89 e5                	mov    %esp,%ebp
f0106d35:	53                   	push   %ebx
f0106d36:	83 ec 10             	sub    $0x10,%esp
f0106d39:	89 d3                	mov    %edx,%ebx
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0106d3b:	8b 48 08             	mov    0x8(%eax),%ecx
f0106d3e:	8b 50 04             	mov    0x4(%eax),%edx
f0106d41:	8b 00                	mov    (%eax),%eax
f0106d43:	8b 40 04             	mov    0x4(%eax),%eax
f0106d46:	53                   	push   %ebx
f0106d47:	e8 31 ff ff ff       	call   f0106c7d <pci_conf1_set_addr>
	asm volatile("inl %w1,%0" : "=a" (data) : "d" (port));
f0106d4c:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f0106d51:	ed                   	in     (%dx),%eax
}
f0106d52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0106d55:	c9                   	leave  
f0106d56:	c3                   	ret    

f0106d57 <pci_scan_bus>:
		f->irq_line);
}

static int
pci_scan_bus(struct pci_bus *bus)
{
f0106d57:	55                   	push   %ebp
f0106d58:	89 e5                	mov    %esp,%ebp
f0106d5a:	57                   	push   %edi
f0106d5b:	56                   	push   %esi
f0106d5c:	53                   	push   %ebx
f0106d5d:	81 ec 00 01 00 00    	sub    $0x100,%esp
f0106d63:	89 c3                	mov    %eax,%ebx
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
f0106d65:	6a 48                	push   $0x48
f0106d67:	6a 00                	push   $0x0
f0106d69:	8d 45 a0             	lea    -0x60(%ebp),%eax
f0106d6c:	50                   	push   %eax
f0106d6d:	e8 fb f0 ff ff       	call   f0105e6d <memset>
	df.bus = bus;
f0106d72:	89 5d a0             	mov    %ebx,-0x60(%ebp)

	for (df.dev = 0; df.dev < 32; df.dev++) {
f0106d75:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0106d7c:	83 c4 10             	add    $0x10,%esp
	int totaldev = 0;
f0106d7f:	c7 85 00 ff ff ff 00 	movl   $0x0,-0x100(%ebp)
f0106d86:	00 00 00 
f0106d89:	e9 27 01 00 00       	jmp    f0106eb5 <pci_scan_bus+0x15e>
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f0106d8e:	8b 95 64 ff ff ff    	mov    -0x9c(%ebp),%edx
	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f0106d94:	83 ec 08             	sub    $0x8,%esp
f0106d97:	0f b6 7d 9c          	movzbl -0x64(%ebp),%edi
f0106d9b:	57                   	push   %edi
f0106d9c:	56                   	push   %esi
		PCI_CLASS(f->dev_class), PCI_SUBCLASS(f->dev_class), class,
f0106d9d:	c1 e8 10             	shr    $0x10,%eax
	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f0106da0:	0f b6 c0             	movzbl %al,%eax
f0106da3:	50                   	push   %eax
f0106da4:	51                   	push   %ecx
f0106da5:	89 d0                	mov    %edx,%eax
f0106da7:	c1 e8 10             	shr    $0x10,%eax
f0106daa:	50                   	push   %eax
f0106dab:	0f b7 d2             	movzwl %dx,%edx
f0106dae:	52                   	push   %edx
f0106daf:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
f0106db5:	ff b5 5c ff ff ff    	pushl  -0xa4(%ebp)
f0106dbb:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
f0106dc1:	ff 70 04             	pushl  0x4(%eax)
f0106dc4:	68 a8 95 10 f0       	push   $0xf01095a8
f0106dc9:	e8 62 d0 ff ff       	call   f0103e30 <cprintf>
				 PCI_SUBCLASS(f->dev_class),
f0106dce:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
		pci_attach_match(PCI_CLASS(f->dev_class),
f0106dd4:	83 c4 30             	add    $0x30,%esp
f0106dd7:	53                   	push   %ebx
f0106dd8:	68 24 74 12 f0       	push   $0xf0127424
				 PCI_SUBCLASS(f->dev_class),
f0106ddd:	89 c2                	mov    %eax,%edx
f0106ddf:	c1 ea 10             	shr    $0x10,%edx
		pci_attach_match(PCI_CLASS(f->dev_class),
f0106de2:	0f b6 d2             	movzbl %dl,%edx
f0106de5:	52                   	push   %edx
f0106de6:	c1 e8 18             	shr    $0x18,%eax
f0106de9:	50                   	push   %eax
f0106dea:	e8 32 fe ff ff       	call   f0106c21 <pci_attach_match>
				 &pci_attach_class[0], f) ||
f0106def:	83 c4 10             	add    $0x10,%esp
f0106df2:	85 c0                	test   %eax,%eax
f0106df4:	0f 84 8a 00 00 00    	je     f0106e84 <pci_scan_bus+0x12d>

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
		     f.func++) {
f0106dfa:	83 85 18 ff ff ff 01 	addl   $0x1,-0xe8(%ebp)
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0106e01:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
f0106e07:	39 85 18 ff ff ff    	cmp    %eax,-0xe8(%ebp)
f0106e0d:	0f 83 94 00 00 00    	jae    f0106ea7 <pci_scan_bus+0x150>
			struct pci_func af = f;
f0106e13:	8d bd 58 ff ff ff    	lea    -0xa8(%ebp),%edi
f0106e19:	8d b5 10 ff ff ff    	lea    -0xf0(%ebp),%esi
f0106e1f:	b9 12 00 00 00       	mov    $0x12,%ecx
f0106e24:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
f0106e26:	ba 00 00 00 00       	mov    $0x0,%edx
f0106e2b:	8d 85 10 ff ff ff    	lea    -0xf0(%ebp),%eax
f0106e31:	e8 fc fe ff ff       	call   f0106d32 <pci_conf_read>
f0106e36:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
			if (PCI_VENDOR(af.dev_id) == 0xffff)
f0106e3c:	66 83 f8 ff          	cmp    $0xffff,%ax
f0106e40:	74 b8                	je     f0106dfa <pci_scan_bus+0xa3>
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f0106e42:	ba 3c 00 00 00       	mov    $0x3c,%edx
f0106e47:	89 d8                	mov    %ebx,%eax
f0106e49:	e8 e4 fe ff ff       	call   f0106d32 <pci_conf_read>
			af.irq_line = PCI_INTERRUPT_LINE(intr);
f0106e4e:	88 45 9c             	mov    %al,-0x64(%ebp)

			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
f0106e51:	ba 08 00 00 00       	mov    $0x8,%edx
f0106e56:	89 d8                	mov    %ebx,%eax
f0106e58:	e8 d5 fe ff ff       	call   f0106d32 <pci_conf_read>
f0106e5d:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
f0106e63:	89 c1                	mov    %eax,%ecx
f0106e65:	c1 e9 18             	shr    $0x18,%ecx
	const char *class = pci_class[0];
f0106e68:	be 1b 97 10 f0       	mov    $0xf010971b,%esi
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
f0106e6d:	3d ff ff ff 06       	cmp    $0x6ffffff,%eax
f0106e72:	0f 87 16 ff ff ff    	ja     f0106d8e <pci_scan_bus+0x37>
		class = pci_class[PCI_CLASS(f->dev_class)];
f0106e78:	8b 34 8d 90 97 10 f0 	mov    -0xfef6870(,%ecx,4),%esi
f0106e7f:	e9 0a ff ff ff       	jmp    f0106d8e <pci_scan_bus+0x37>
				 PCI_PRODUCT(f->dev_id),
f0106e84:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
		pci_attach_match(PCI_VENDOR(f->dev_id),
f0106e8a:	53                   	push   %ebx
f0106e8b:	68 0c 74 12 f0       	push   $0xf012740c
f0106e90:	89 c2                	mov    %eax,%edx
f0106e92:	c1 ea 10             	shr    $0x10,%edx
f0106e95:	52                   	push   %edx
f0106e96:	0f b7 c0             	movzwl %ax,%eax
f0106e99:	50                   	push   %eax
f0106e9a:	e8 82 fd ff ff       	call   f0106c21 <pci_attach_match>
f0106e9f:	83 c4 10             	add    $0x10,%esp
f0106ea2:	e9 53 ff ff ff       	jmp    f0106dfa <pci_scan_bus+0xa3>
	for (df.dev = 0; df.dev < 32; df.dev++) {
f0106ea7:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0106eaa:	83 c0 01             	add    $0x1,%eax
f0106ead:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0106eb0:	83 f8 1f             	cmp    $0x1f,%eax
f0106eb3:	77 59                	ja     f0106f0e <pci_scan_bus+0x1b7>
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
f0106eb5:	ba 0c 00 00 00       	mov    $0xc,%edx
f0106eba:	8d 45 a0             	lea    -0x60(%ebp),%eax
f0106ebd:	e8 70 fe ff ff       	call   f0106d32 <pci_conf_read>
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
f0106ec2:	89 c2                	mov    %eax,%edx
f0106ec4:	c1 ea 10             	shr    $0x10,%edx
f0106ec7:	f6 c2 7e             	test   $0x7e,%dl
f0106eca:	75 db                	jne    f0106ea7 <pci_scan_bus+0x150>
		totaldev++;
f0106ecc:	83 85 00 ff ff ff 01 	addl   $0x1,-0x100(%ebp)
		struct pci_func f = df;
f0106ed3:	8d bd 10 ff ff ff    	lea    -0xf0(%ebp),%edi
f0106ed9:	8d 75 a0             	lea    -0x60(%ebp),%esi
f0106edc:	b9 12 00 00 00       	mov    $0x12,%ecx
f0106ee1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0106ee3:	c7 85 18 ff ff ff 00 	movl   $0x0,-0xe8(%ebp)
f0106eea:	00 00 00 
f0106eed:	25 00 00 80 00       	and    $0x800000,%eax
f0106ef2:	83 f8 01             	cmp    $0x1,%eax
f0106ef5:	19 c0                	sbb    %eax,%eax
f0106ef7:	83 e0 f9             	and    $0xfffffff9,%eax
f0106efa:	83 c0 08             	add    $0x8,%eax
f0106efd:	89 85 04 ff ff ff    	mov    %eax,-0xfc(%ebp)
			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f0106f03:	8d 9d 58 ff ff ff    	lea    -0xa8(%ebp),%ebx
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0106f09:	e9 f3 fe ff ff       	jmp    f0106e01 <pci_scan_bus+0xaa>
			pci_attach(&af);
		}
	}

	return totaldev;
}
f0106f0e:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
f0106f14:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106f17:	5b                   	pop    %ebx
f0106f18:	5e                   	pop    %esi
f0106f19:	5f                   	pop    %edi
f0106f1a:	5d                   	pop    %ebp
f0106f1b:	c3                   	ret    

f0106f1c <pci_bridge_attach>:

static int
pci_bridge_attach(struct pci_func *pcif)
{
f0106f1c:	f3 0f 1e fb          	endbr32 
f0106f20:	55                   	push   %ebp
f0106f21:	89 e5                	mov    %esp,%ebp
f0106f23:	57                   	push   %edi
f0106f24:	56                   	push   %esi
f0106f25:	53                   	push   %ebx
f0106f26:	83 ec 1c             	sub    $0x1c,%esp
f0106f29:	8b 75 08             	mov    0x8(%ebp),%esi
	uint32_t ioreg  = pci_conf_read(pcif, PCI_BRIDGE_STATIO_REG);
f0106f2c:	ba 1c 00 00 00       	mov    $0x1c,%edx
f0106f31:	89 f0                	mov    %esi,%eax
f0106f33:	e8 fa fd ff ff       	call   f0106d32 <pci_conf_read>
f0106f38:	89 c7                	mov    %eax,%edi
	uint32_t busreg = pci_conf_read(pcif, PCI_BRIDGE_BUS_REG);
f0106f3a:	ba 18 00 00 00       	mov    $0x18,%edx
f0106f3f:	89 f0                	mov    %esi,%eax
f0106f41:	e8 ec fd ff ff       	call   f0106d32 <pci_conf_read>

	if (PCI_BRIDGE_IO_32BITS(ioreg)) {
f0106f46:	83 e7 0f             	and    $0xf,%edi
f0106f49:	83 ff 01             	cmp    $0x1,%edi
f0106f4c:	74 52                	je     f0106fa0 <pci_bridge_attach+0x84>
f0106f4e:	89 c3                	mov    %eax,%ebx
			pcif->bus->busno, pcif->dev, pcif->func);
		return 0;
	}

	struct pci_bus nbus;
	memset(&nbus, 0, sizeof(nbus));
f0106f50:	83 ec 04             	sub    $0x4,%esp
f0106f53:	6a 08                	push   $0x8
f0106f55:	6a 00                	push   $0x0
f0106f57:	8d 7d e0             	lea    -0x20(%ebp),%edi
f0106f5a:	57                   	push   %edi
f0106f5b:	e8 0d ef ff ff       	call   f0105e6d <memset>
	nbus.parent_bridge = pcif;
f0106f60:	89 75 e0             	mov    %esi,-0x20(%ebp)
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;
f0106f63:	0f b6 c7             	movzbl %bh,%eax
f0106f66:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f0106f69:	83 c4 08             	add    $0x8,%esp
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);
f0106f6c:	c1 eb 10             	shr    $0x10,%ebx
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f0106f6f:	0f b6 db             	movzbl %bl,%ebx
f0106f72:	53                   	push   %ebx
f0106f73:	50                   	push   %eax
f0106f74:	ff 76 08             	pushl  0x8(%esi)
f0106f77:	ff 76 04             	pushl  0x4(%esi)
f0106f7a:	8b 06                	mov    (%esi),%eax
f0106f7c:	ff 70 04             	pushl  0x4(%eax)
f0106f7f:	68 18 96 10 f0       	push   $0xf0109618
f0106f84:	e8 a7 ce ff ff       	call   f0103e30 <cprintf>

	pci_scan_bus(&nbus);
f0106f89:	83 c4 20             	add    $0x20,%esp
f0106f8c:	89 f8                	mov    %edi,%eax
f0106f8e:	e8 c4 fd ff ff       	call   f0106d57 <pci_scan_bus>
	return 1;
f0106f93:	b8 01 00 00 00       	mov    $0x1,%eax
}
f0106f98:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106f9b:	5b                   	pop    %ebx
f0106f9c:	5e                   	pop    %esi
f0106f9d:	5f                   	pop    %edi
f0106f9e:	5d                   	pop    %ebp
f0106f9f:	c3                   	ret    
		cprintf("PCI: %02x:%02x.%d: 32-bit bridge IO not supported.\n",
f0106fa0:	ff 76 08             	pushl  0x8(%esi)
f0106fa3:	ff 76 04             	pushl  0x4(%esi)
f0106fa6:	8b 06                	mov    (%esi),%eax
f0106fa8:	ff 70 04             	pushl  0x4(%eax)
f0106fab:	68 e4 95 10 f0       	push   $0xf01095e4
f0106fb0:	e8 7b ce ff ff       	call   f0103e30 <cprintf>
		return 0;
f0106fb5:	83 c4 10             	add    $0x10,%esp
f0106fb8:	b8 00 00 00 00       	mov    $0x0,%eax
f0106fbd:	eb d9                	jmp    f0106f98 <pci_bridge_attach+0x7c>

f0106fbf <pci_conf_write>:
{
f0106fbf:	55                   	push   %ebp
f0106fc0:	89 e5                	mov    %esp,%ebp
f0106fc2:	56                   	push   %esi
f0106fc3:	53                   	push   %ebx
f0106fc4:	89 d6                	mov    %edx,%esi
f0106fc6:	89 cb                	mov    %ecx,%ebx
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0106fc8:	8b 48 08             	mov    0x8(%eax),%ecx
f0106fcb:	8b 50 04             	mov    0x4(%eax),%edx
f0106fce:	8b 00                	mov    (%eax),%eax
f0106fd0:	8b 40 04             	mov    0x4(%eax),%eax
f0106fd3:	83 ec 0c             	sub    $0xc,%esp
f0106fd6:	56                   	push   %esi
f0106fd7:	e8 a1 fc ff ff       	call   f0106c7d <pci_conf1_set_addr>
	asm volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0106fdc:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f0106fe1:	89 d8                	mov    %ebx,%eax
f0106fe3:	ef                   	out    %eax,(%dx)
}
f0106fe4:	83 c4 10             	add    $0x10,%esp
f0106fe7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106fea:	5b                   	pop    %ebx
f0106feb:	5e                   	pop    %esi
f0106fec:	5d                   	pop    %ebp
f0106fed:	c3                   	ret    

f0106fee <pci_func_enable>:

// External PCI subsystem interface

void
pci_func_enable(struct pci_func *f)
{
f0106fee:	f3 0f 1e fb          	endbr32 
f0106ff2:	55                   	push   %ebp
f0106ff3:	89 e5                	mov    %esp,%ebp
f0106ff5:	57                   	push   %edi
f0106ff6:	56                   	push   %esi
f0106ff7:	53                   	push   %ebx
f0106ff8:	83 ec 2c             	sub    $0x2c,%esp
f0106ffb:	8b 7d 08             	mov    0x8(%ebp),%edi
	pci_conf_write(f, PCI_COMMAND_STATUS_REG,
f0106ffe:	b9 07 00 00 00       	mov    $0x7,%ecx
f0107003:	ba 04 00 00 00       	mov    $0x4,%edx
f0107008:	89 f8                	mov    %edi,%eax
f010700a:	e8 b0 ff ff ff       	call   f0106fbf <pci_conf_write>
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f010700f:	be 10 00 00 00       	mov    $0x10,%esi
f0107014:	eb 56                	jmp    f010706c <pci_func_enable+0x7e>
			base = PCI_MAPREG_MEM_ADDR(oldv);
			if (pci_show_addrs)
				cprintf("  mem region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		} else {
			size = PCI_MAPREG_IO_SIZE(rv);
f0107016:	83 e0 fc             	and    $0xfffffffc,%eax
f0107019:	f7 d8                	neg    %eax
f010701b:	21 c3                	and    %eax,%ebx
			base = PCI_MAPREG_IO_ADDR(oldv);
f010701d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107020:	83 e0 fc             	and    $0xfffffffc,%eax
f0107023:	89 45 d8             	mov    %eax,-0x28(%ebp)
		bar_width = 4;
f0107026:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
f010702d:	e9 aa 00 00 00       	jmp    f01070dc <pci_func_enable+0xee>
		if (size && !base)
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
				"may be misconfigured: "
				"region %d: base 0x%x, size %d\n",
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f0107032:	8b 47 0c             	mov    0xc(%edi),%eax
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
f0107035:	83 ec 0c             	sub    $0xc,%esp
f0107038:	53                   	push   %ebx
f0107039:	6a 00                	push   $0x0
f010703b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010703e:	89 c2                	mov    %eax,%edx
f0107040:	c1 ea 10             	shr    $0x10,%edx
f0107043:	52                   	push   %edx
f0107044:	0f b7 c0             	movzwl %ax,%eax
f0107047:	50                   	push   %eax
f0107048:	ff 77 08             	pushl  0x8(%edi)
f010704b:	ff 77 04             	pushl  0x4(%edi)
f010704e:	8b 07                	mov    (%edi),%eax
f0107050:	ff 70 04             	pushl  0x4(%eax)
f0107053:	68 48 96 10 f0       	push   $0xf0109648
f0107058:	e8 d3 cd ff ff       	call   f0103e30 <cprintf>
f010705d:	83 c4 30             	add    $0x30,%esp
	     bar += bar_width)
f0107060:	03 75 e4             	add    -0x1c(%ebp),%esi
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f0107063:	83 fe 27             	cmp    $0x27,%esi
f0107066:	0f 87 9f 00 00 00    	ja     f010710b <pci_func_enable+0x11d>
		uint32_t oldv = pci_conf_read(f, bar);
f010706c:	89 f2                	mov    %esi,%edx
f010706e:	89 f8                	mov    %edi,%eax
f0107070:	e8 bd fc ff ff       	call   f0106d32 <pci_conf_read>
f0107075:	89 45 e0             	mov    %eax,-0x20(%ebp)
		pci_conf_write(f, bar, 0xffffffff);
f0107078:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f010707d:	89 f2                	mov    %esi,%edx
f010707f:	89 f8                	mov    %edi,%eax
f0107081:	e8 39 ff ff ff       	call   f0106fbf <pci_conf_write>
		uint32_t rv = pci_conf_read(f, bar);
f0107086:	89 f2                	mov    %esi,%edx
f0107088:	89 f8                	mov    %edi,%eax
f010708a:	e8 a3 fc ff ff       	call   f0106d32 <pci_conf_read>
f010708f:	89 c3                	mov    %eax,%ebx
		bar_width = 4;
f0107091:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
		if (rv == 0)
f0107098:	85 c0                	test   %eax,%eax
f010709a:	74 c4                	je     f0107060 <pci_func_enable+0x72>
		int regnum = PCI_MAPREG_NUM(bar);
f010709c:	8d 4e f0             	lea    -0x10(%esi),%ecx
f010709f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01070a2:	c1 e9 02             	shr    $0x2,%ecx
f01070a5:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		if (PCI_MAPREG_TYPE(rv) == PCI_MAPREG_TYPE_MEM) {
f01070a8:	a8 01                	test   $0x1,%al
f01070aa:	0f 85 66 ff ff ff    	jne    f0107016 <pci_func_enable+0x28>
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
f01070b0:	89 c1                	mov    %eax,%ecx
f01070b2:	83 e1 06             	and    $0x6,%ecx
				bar_width = 8;
f01070b5:	83 f9 04             	cmp    $0x4,%ecx
f01070b8:	0f 94 c1             	sete   %cl
f01070bb:	0f b6 c9             	movzbl %cl,%ecx
f01070be:	8d 14 8d 04 00 00 00 	lea    0x4(,%ecx,4),%edx
f01070c5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
			size = PCI_MAPREG_MEM_SIZE(rv);
f01070c8:	89 c2                	mov    %eax,%edx
f01070ca:	83 e2 f0             	and    $0xfffffff0,%edx
f01070cd:	89 d0                	mov    %edx,%eax
f01070cf:	f7 d8                	neg    %eax
f01070d1:	21 c3                	and    %eax,%ebx
			base = PCI_MAPREG_MEM_ADDR(oldv);
f01070d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01070d6:	83 e0 f0             	and    $0xfffffff0,%eax
f01070d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
		pci_conf_write(f, bar, oldv);
f01070dc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01070df:	89 f2                	mov    %esi,%edx
f01070e1:	89 f8                	mov    %edi,%eax
f01070e3:	e8 d7 fe ff ff       	call   f0106fbf <pci_conf_write>
f01070e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01070eb:	01 f8                	add    %edi,%eax
		f->reg_base[regnum] = base;
f01070ed:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01070f0:	89 50 14             	mov    %edx,0x14(%eax)
		f->reg_size[regnum] = size;
f01070f3:	89 58 2c             	mov    %ebx,0x2c(%eax)
		if (size && !base)
f01070f6:	85 db                	test   %ebx,%ebx
f01070f8:	0f 84 62 ff ff ff    	je     f0107060 <pci_func_enable+0x72>
f01070fe:	85 d2                	test   %edx,%edx
f0107100:	0f 85 5a ff ff ff    	jne    f0107060 <pci_func_enable+0x72>
f0107106:	e9 27 ff ff ff       	jmp    f0107032 <pci_func_enable+0x44>
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
f010710b:	8b 47 0c             	mov    0xc(%edi),%eax
	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
f010710e:	83 ec 08             	sub    $0x8,%esp
f0107111:	89 c2                	mov    %eax,%edx
f0107113:	c1 ea 10             	shr    $0x10,%edx
f0107116:	52                   	push   %edx
f0107117:	0f b7 c0             	movzwl %ax,%eax
f010711a:	50                   	push   %eax
f010711b:	ff 77 08             	pushl  0x8(%edi)
f010711e:	ff 77 04             	pushl  0x4(%edi)
f0107121:	8b 07                	mov    (%edi),%eax
f0107123:	ff 70 04             	pushl  0x4(%eax)
f0107126:	68 a4 96 10 f0       	push   $0xf01096a4
f010712b:	e8 00 cd ff ff       	call   f0103e30 <cprintf>
}
f0107130:	83 c4 20             	add    $0x20,%esp
f0107133:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0107136:	5b                   	pop    %ebx
f0107137:	5e                   	pop    %esi
f0107138:	5f                   	pop    %edi
f0107139:	5d                   	pop    %ebp
f010713a:	c3                   	ret    

f010713b <pci_init>:

int
pci_init(void)
{
f010713b:	f3 0f 1e fb          	endbr32 
f010713f:	55                   	push   %ebp
f0107140:	89 e5                	mov    %esp,%ebp
f0107142:	83 ec 0c             	sub    $0xc,%esp
	static struct pci_bus root_bus;
	memset(&root_bus, 0, sizeof(root_bus));
f0107145:	6a 08                	push   $0x8
f0107147:	6a 00                	push   $0x0
f0107149:	68 00 f4 2b f0       	push   $0xf02bf400
f010714e:	e8 1a ed ff ff       	call   f0105e6d <memset>

	return pci_scan_bus(&root_bus);
f0107153:	b8 00 f4 2b f0       	mov    $0xf02bf400,%eax
f0107158:	e8 fa fb ff ff       	call   f0106d57 <pci_scan_bus>
}
f010715d:	c9                   	leave  
f010715e:	c3                   	ret    

f010715f <time_init>:

static unsigned int ticks;

void
time_init(void)
{
f010715f:	f3 0f 1e fb          	endbr32 
	ticks = 0;
f0107163:	c7 05 08 f4 2b f0 00 	movl   $0x0,0xf02bf408
f010716a:	00 00 00 
}
f010716d:	c3                   	ret    

f010716e <time_tick>:

// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
f010716e:	f3 0f 1e fb          	endbr32 
	ticks++;
f0107172:	a1 08 f4 2b f0       	mov    0xf02bf408,%eax
f0107177:	83 c0 01             	add    $0x1,%eax
f010717a:	a3 08 f4 2b f0       	mov    %eax,0xf02bf408
	if (ticks * 10 < ticks)
f010717f:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0107182:	01 d2                	add    %edx,%edx
f0107184:	39 d0                	cmp    %edx,%eax
f0107186:	77 01                	ja     f0107189 <time_tick+0x1b>
f0107188:	c3                   	ret    
{
f0107189:	55                   	push   %ebp
f010718a:	89 e5                	mov    %esp,%ebp
f010718c:	83 ec 0c             	sub    $0xc,%esp
		panic("time_tick: time overflowed");
f010718f:	68 ac 97 10 f0       	push   $0xf01097ac
f0107194:	6a 13                	push   $0x13
f0107196:	68 c7 97 10 f0       	push   $0xf01097c7
f010719b:	e8 a0 8e ff ff       	call   f0100040 <_panic>

f01071a0 <time_msec>:
}

unsigned int
time_msec(void)
{
f01071a0:	f3 0f 1e fb          	endbr32 
	return ticks * 10;
f01071a4:	a1 08 f4 2b f0       	mov    0xf02bf408,%eax
f01071a9:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01071ac:	01 c0                	add    %eax,%eax
}
f01071ae:	c3                   	ret    
f01071af:	90                   	nop

f01071b0 <__udivdi3>:
f01071b0:	f3 0f 1e fb          	endbr32 
f01071b4:	55                   	push   %ebp
f01071b5:	57                   	push   %edi
f01071b6:	56                   	push   %esi
f01071b7:	53                   	push   %ebx
f01071b8:	83 ec 1c             	sub    $0x1c,%esp
f01071bb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01071bf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01071c3:	8b 74 24 34          	mov    0x34(%esp),%esi
f01071c7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01071cb:	85 d2                	test   %edx,%edx
f01071cd:	75 19                	jne    f01071e8 <__udivdi3+0x38>
f01071cf:	39 f3                	cmp    %esi,%ebx
f01071d1:	76 4d                	jbe    f0107220 <__udivdi3+0x70>
f01071d3:	31 ff                	xor    %edi,%edi
f01071d5:	89 e8                	mov    %ebp,%eax
f01071d7:	89 f2                	mov    %esi,%edx
f01071d9:	f7 f3                	div    %ebx
f01071db:	89 fa                	mov    %edi,%edx
f01071dd:	83 c4 1c             	add    $0x1c,%esp
f01071e0:	5b                   	pop    %ebx
f01071e1:	5e                   	pop    %esi
f01071e2:	5f                   	pop    %edi
f01071e3:	5d                   	pop    %ebp
f01071e4:	c3                   	ret    
f01071e5:	8d 76 00             	lea    0x0(%esi),%esi
f01071e8:	39 f2                	cmp    %esi,%edx
f01071ea:	76 14                	jbe    f0107200 <__udivdi3+0x50>
f01071ec:	31 ff                	xor    %edi,%edi
f01071ee:	31 c0                	xor    %eax,%eax
f01071f0:	89 fa                	mov    %edi,%edx
f01071f2:	83 c4 1c             	add    $0x1c,%esp
f01071f5:	5b                   	pop    %ebx
f01071f6:	5e                   	pop    %esi
f01071f7:	5f                   	pop    %edi
f01071f8:	5d                   	pop    %ebp
f01071f9:	c3                   	ret    
f01071fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0107200:	0f bd fa             	bsr    %edx,%edi
f0107203:	83 f7 1f             	xor    $0x1f,%edi
f0107206:	75 48                	jne    f0107250 <__udivdi3+0xa0>
f0107208:	39 f2                	cmp    %esi,%edx
f010720a:	72 06                	jb     f0107212 <__udivdi3+0x62>
f010720c:	31 c0                	xor    %eax,%eax
f010720e:	39 eb                	cmp    %ebp,%ebx
f0107210:	77 de                	ja     f01071f0 <__udivdi3+0x40>
f0107212:	b8 01 00 00 00       	mov    $0x1,%eax
f0107217:	eb d7                	jmp    f01071f0 <__udivdi3+0x40>
f0107219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0107220:	89 d9                	mov    %ebx,%ecx
f0107222:	85 db                	test   %ebx,%ebx
f0107224:	75 0b                	jne    f0107231 <__udivdi3+0x81>
f0107226:	b8 01 00 00 00       	mov    $0x1,%eax
f010722b:	31 d2                	xor    %edx,%edx
f010722d:	f7 f3                	div    %ebx
f010722f:	89 c1                	mov    %eax,%ecx
f0107231:	31 d2                	xor    %edx,%edx
f0107233:	89 f0                	mov    %esi,%eax
f0107235:	f7 f1                	div    %ecx
f0107237:	89 c6                	mov    %eax,%esi
f0107239:	89 e8                	mov    %ebp,%eax
f010723b:	89 f7                	mov    %esi,%edi
f010723d:	f7 f1                	div    %ecx
f010723f:	89 fa                	mov    %edi,%edx
f0107241:	83 c4 1c             	add    $0x1c,%esp
f0107244:	5b                   	pop    %ebx
f0107245:	5e                   	pop    %esi
f0107246:	5f                   	pop    %edi
f0107247:	5d                   	pop    %ebp
f0107248:	c3                   	ret    
f0107249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0107250:	89 f9                	mov    %edi,%ecx
f0107252:	b8 20 00 00 00       	mov    $0x20,%eax
f0107257:	29 f8                	sub    %edi,%eax
f0107259:	d3 e2                	shl    %cl,%edx
f010725b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010725f:	89 c1                	mov    %eax,%ecx
f0107261:	89 da                	mov    %ebx,%edx
f0107263:	d3 ea                	shr    %cl,%edx
f0107265:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0107269:	09 d1                	or     %edx,%ecx
f010726b:	89 f2                	mov    %esi,%edx
f010726d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0107271:	89 f9                	mov    %edi,%ecx
f0107273:	d3 e3                	shl    %cl,%ebx
f0107275:	89 c1                	mov    %eax,%ecx
f0107277:	d3 ea                	shr    %cl,%edx
f0107279:	89 f9                	mov    %edi,%ecx
f010727b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010727f:	89 eb                	mov    %ebp,%ebx
f0107281:	d3 e6                	shl    %cl,%esi
f0107283:	89 c1                	mov    %eax,%ecx
f0107285:	d3 eb                	shr    %cl,%ebx
f0107287:	09 de                	or     %ebx,%esi
f0107289:	89 f0                	mov    %esi,%eax
f010728b:	f7 74 24 08          	divl   0x8(%esp)
f010728f:	89 d6                	mov    %edx,%esi
f0107291:	89 c3                	mov    %eax,%ebx
f0107293:	f7 64 24 0c          	mull   0xc(%esp)
f0107297:	39 d6                	cmp    %edx,%esi
f0107299:	72 15                	jb     f01072b0 <__udivdi3+0x100>
f010729b:	89 f9                	mov    %edi,%ecx
f010729d:	d3 e5                	shl    %cl,%ebp
f010729f:	39 c5                	cmp    %eax,%ebp
f01072a1:	73 04                	jae    f01072a7 <__udivdi3+0xf7>
f01072a3:	39 d6                	cmp    %edx,%esi
f01072a5:	74 09                	je     f01072b0 <__udivdi3+0x100>
f01072a7:	89 d8                	mov    %ebx,%eax
f01072a9:	31 ff                	xor    %edi,%edi
f01072ab:	e9 40 ff ff ff       	jmp    f01071f0 <__udivdi3+0x40>
f01072b0:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01072b3:	31 ff                	xor    %edi,%edi
f01072b5:	e9 36 ff ff ff       	jmp    f01071f0 <__udivdi3+0x40>
f01072ba:	66 90                	xchg   %ax,%ax
f01072bc:	66 90                	xchg   %ax,%ax
f01072be:	66 90                	xchg   %ax,%ax

f01072c0 <__umoddi3>:
f01072c0:	f3 0f 1e fb          	endbr32 
f01072c4:	55                   	push   %ebp
f01072c5:	57                   	push   %edi
f01072c6:	56                   	push   %esi
f01072c7:	53                   	push   %ebx
f01072c8:	83 ec 1c             	sub    $0x1c,%esp
f01072cb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f01072cf:	8b 74 24 30          	mov    0x30(%esp),%esi
f01072d3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01072d7:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01072db:	85 c0                	test   %eax,%eax
f01072dd:	75 19                	jne    f01072f8 <__umoddi3+0x38>
f01072df:	39 df                	cmp    %ebx,%edi
f01072e1:	76 5d                	jbe    f0107340 <__umoddi3+0x80>
f01072e3:	89 f0                	mov    %esi,%eax
f01072e5:	89 da                	mov    %ebx,%edx
f01072e7:	f7 f7                	div    %edi
f01072e9:	89 d0                	mov    %edx,%eax
f01072eb:	31 d2                	xor    %edx,%edx
f01072ed:	83 c4 1c             	add    $0x1c,%esp
f01072f0:	5b                   	pop    %ebx
f01072f1:	5e                   	pop    %esi
f01072f2:	5f                   	pop    %edi
f01072f3:	5d                   	pop    %ebp
f01072f4:	c3                   	ret    
f01072f5:	8d 76 00             	lea    0x0(%esi),%esi
f01072f8:	89 f2                	mov    %esi,%edx
f01072fa:	39 d8                	cmp    %ebx,%eax
f01072fc:	76 12                	jbe    f0107310 <__umoddi3+0x50>
f01072fe:	89 f0                	mov    %esi,%eax
f0107300:	89 da                	mov    %ebx,%edx
f0107302:	83 c4 1c             	add    $0x1c,%esp
f0107305:	5b                   	pop    %ebx
f0107306:	5e                   	pop    %esi
f0107307:	5f                   	pop    %edi
f0107308:	5d                   	pop    %ebp
f0107309:	c3                   	ret    
f010730a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0107310:	0f bd e8             	bsr    %eax,%ebp
f0107313:	83 f5 1f             	xor    $0x1f,%ebp
f0107316:	75 50                	jne    f0107368 <__umoddi3+0xa8>
f0107318:	39 d8                	cmp    %ebx,%eax
f010731a:	0f 82 e0 00 00 00    	jb     f0107400 <__umoddi3+0x140>
f0107320:	89 d9                	mov    %ebx,%ecx
f0107322:	39 f7                	cmp    %esi,%edi
f0107324:	0f 86 d6 00 00 00    	jbe    f0107400 <__umoddi3+0x140>
f010732a:	89 d0                	mov    %edx,%eax
f010732c:	89 ca                	mov    %ecx,%edx
f010732e:	83 c4 1c             	add    $0x1c,%esp
f0107331:	5b                   	pop    %ebx
f0107332:	5e                   	pop    %esi
f0107333:	5f                   	pop    %edi
f0107334:	5d                   	pop    %ebp
f0107335:	c3                   	ret    
f0107336:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010733d:	8d 76 00             	lea    0x0(%esi),%esi
f0107340:	89 fd                	mov    %edi,%ebp
f0107342:	85 ff                	test   %edi,%edi
f0107344:	75 0b                	jne    f0107351 <__umoddi3+0x91>
f0107346:	b8 01 00 00 00       	mov    $0x1,%eax
f010734b:	31 d2                	xor    %edx,%edx
f010734d:	f7 f7                	div    %edi
f010734f:	89 c5                	mov    %eax,%ebp
f0107351:	89 d8                	mov    %ebx,%eax
f0107353:	31 d2                	xor    %edx,%edx
f0107355:	f7 f5                	div    %ebp
f0107357:	89 f0                	mov    %esi,%eax
f0107359:	f7 f5                	div    %ebp
f010735b:	89 d0                	mov    %edx,%eax
f010735d:	31 d2                	xor    %edx,%edx
f010735f:	eb 8c                	jmp    f01072ed <__umoddi3+0x2d>
f0107361:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0107368:	89 e9                	mov    %ebp,%ecx
f010736a:	ba 20 00 00 00       	mov    $0x20,%edx
f010736f:	29 ea                	sub    %ebp,%edx
f0107371:	d3 e0                	shl    %cl,%eax
f0107373:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107377:	89 d1                	mov    %edx,%ecx
f0107379:	89 f8                	mov    %edi,%eax
f010737b:	d3 e8                	shr    %cl,%eax
f010737d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0107381:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107385:	8b 54 24 04          	mov    0x4(%esp),%edx
f0107389:	09 c1                	or     %eax,%ecx
f010738b:	89 d8                	mov    %ebx,%eax
f010738d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0107391:	89 e9                	mov    %ebp,%ecx
f0107393:	d3 e7                	shl    %cl,%edi
f0107395:	89 d1                	mov    %edx,%ecx
f0107397:	d3 e8                	shr    %cl,%eax
f0107399:	89 e9                	mov    %ebp,%ecx
f010739b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010739f:	d3 e3                	shl    %cl,%ebx
f01073a1:	89 c7                	mov    %eax,%edi
f01073a3:	89 d1                	mov    %edx,%ecx
f01073a5:	89 f0                	mov    %esi,%eax
f01073a7:	d3 e8                	shr    %cl,%eax
f01073a9:	89 e9                	mov    %ebp,%ecx
f01073ab:	89 fa                	mov    %edi,%edx
f01073ad:	d3 e6                	shl    %cl,%esi
f01073af:	09 d8                	or     %ebx,%eax
f01073b1:	f7 74 24 08          	divl   0x8(%esp)
f01073b5:	89 d1                	mov    %edx,%ecx
f01073b7:	89 f3                	mov    %esi,%ebx
f01073b9:	f7 64 24 0c          	mull   0xc(%esp)
f01073bd:	89 c6                	mov    %eax,%esi
f01073bf:	89 d7                	mov    %edx,%edi
f01073c1:	39 d1                	cmp    %edx,%ecx
f01073c3:	72 06                	jb     f01073cb <__umoddi3+0x10b>
f01073c5:	75 10                	jne    f01073d7 <__umoddi3+0x117>
f01073c7:	39 c3                	cmp    %eax,%ebx
f01073c9:	73 0c                	jae    f01073d7 <__umoddi3+0x117>
f01073cb:	2b 44 24 0c          	sub    0xc(%esp),%eax
f01073cf:	1b 54 24 08          	sbb    0x8(%esp),%edx
f01073d3:	89 d7                	mov    %edx,%edi
f01073d5:	89 c6                	mov    %eax,%esi
f01073d7:	89 ca                	mov    %ecx,%edx
f01073d9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01073de:	29 f3                	sub    %esi,%ebx
f01073e0:	19 fa                	sbb    %edi,%edx
f01073e2:	89 d0                	mov    %edx,%eax
f01073e4:	d3 e0                	shl    %cl,%eax
f01073e6:	89 e9                	mov    %ebp,%ecx
f01073e8:	d3 eb                	shr    %cl,%ebx
f01073ea:	d3 ea                	shr    %cl,%edx
f01073ec:	09 d8                	or     %ebx,%eax
f01073ee:	83 c4 1c             	add    $0x1c,%esp
f01073f1:	5b                   	pop    %ebx
f01073f2:	5e                   	pop    %esi
f01073f3:	5f                   	pop    %edi
f01073f4:	5d                   	pop    %ebp
f01073f5:	c3                   	ret    
f01073f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01073fd:	8d 76 00             	lea    0x0(%esi),%esi
f0107400:	29 fe                	sub    %edi,%esi
f0107402:	19 c3                	sbb    %eax,%ebx
f0107404:	89 f2                	mov    %esi,%edx
f0107406:	89 d9                	mov    %ebx,%ecx
f0107408:	e9 1d ff ff ff       	jmp    f010732a <__umoddi3+0x6a>
