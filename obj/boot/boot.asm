
obj/boot/boot.out:     file format elf32-i386


Disassembly of section .text:

00007c00 <start>:
.set CR0_PE_ON,      0x1         # protected mode enable flag

.globl start
start:
  .code16                     # Assemble for 16-bit mode
  cli                         # Disable interrupts
    7c00:	fa                   	cli    
  cld                         # String operations increment
    7c01:	fc                   	cld    

  # Set up the important data segment registers (DS, ES, SS).
  xorw    %ax,%ax             # Segment number zero
    7c02:	31 c0                	xor    %eax,%eax
  movw    %ax,%ds             # -> Data Segment
    7c04:	8e d8                	mov    %eax,%ds
  movw    %ax,%es             # -> Extra Segment
    7c06:	8e c0                	mov    %eax,%es
  movw    %ax,%ss             # -> Stack Segment
    7c08:	8e d0                	mov    %eax,%ss

00007c0a <seta20.1>:
  # Enable A20:
  #   For backwards compatibility with the earliest PCs, physical
  #   address line 20 is tied low, so that addresses higher than
  #   1MB wrap around to zero by default.  This code undoes this.
seta20.1:
  inb     $0x64,%al               # Wait for not busy
    7c0a:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c0c:	a8 02                	test   $0x2,%al
  jnz     seta20.1
    7c0e:	75 fa                	jne    7c0a <seta20.1>

  movb    $0xd1,%al               # 0xd1 -> port 0x64
    7c10:	b0 d1                	mov    $0xd1,%al
  outb    %al,$0x64
    7c12:	e6 64                	out    %al,$0x64

00007c14 <seta20.2>:

seta20.2:
  inb     $0x64,%al               # Wait for not busy
    7c14:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c16:	a8 02                	test   $0x2,%al
  jnz     seta20.2
    7c18:	75 fa                	jne    7c14 <seta20.2>

  movb    $0xdf,%al               # 0xdf -> port 0x60
    7c1a:	b0 df                	mov    $0xdf,%al
  outb    %al,$0x60
    7c1c:	e6 60                	out    %al,$0x60

  # Switch from real to protected mode, using a bootstrap GDT
  # and segment translation that makes virtual addresses 
  # identical to their physical addresses, so that the 
  # effective memory map does not change during the switch.
  lgdt    gdtdesc
    7c1e:	0f 01 16             	lgdtl  (%esi)
    7c21:	64 7c 0f             	fs jl  7c33 <protcseg+0x1>
  movl    %cr0, %eax
    7c24:	20 c0                	and    %al,%al
  orl     $CR0_PE_ON, %eax
    7c26:	66 83 c8 01          	or     $0x1,%ax
  movl    %eax, %cr0
    7c2a:	0f 22 c0             	mov    %eax,%cr0
  
  # Jump to next instruction, but in 32-bit code segment.
  # Switches processor into 32-bit mode.
  ljmp    $PROT_MODE_CSEG, $protcseg
    7c2d:	ea                   	.byte 0xea
    7c2e:	32 7c 08 00          	xor    0x0(%eax,%ecx,1),%bh

00007c32 <protcseg>:

  .code32                     # Assemble for 32-bit mode
protcseg:
  # Set up the protected-mode data segment registers
  movw    $PROT_MODE_DSEG, %ax    # Our data segment selector
    7c32:	66 b8 10 00          	mov    $0x10,%ax
  movw    %ax, %ds                # -> DS: Data Segment
    7c36:	8e d8                	mov    %eax,%ds
  movw    %ax, %es                # -> ES: Extra Segment
    7c38:	8e c0                	mov    %eax,%es
  movw    %ax, %fs                # -> FS
    7c3a:	8e e0                	mov    %eax,%fs
  movw    %ax, %gs                # -> GS
    7c3c:	8e e8                	mov    %eax,%gs
  movw    %ax, %ss                # -> SS: Stack Segment
    7c3e:	8e d0                	mov    %eax,%ss
  
  # Set up the stack pointer and call into C.
  movl    $start, %esp
    7c40:	bc 00 7c 00 00       	mov    $0x7c00,%esp
  call bootmain
    7c45:	e8 db 00 00 00       	call   7d25 <bootmain>

00007c4a <spin>:

  # If bootmain returns (it shouldn't), loop.
spin:
  jmp spin
    7c4a:	eb fe                	jmp    7c4a <spin>

00007c4c <gdt>:
	...
    7c54:	ff                   	(bad)  
    7c55:	ff 00                	incl   (%eax)
    7c57:	00 00                	add    %al,(%eax)
    7c59:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c60:	00                   	.byte 0x0
    7c61:	92                   	xchg   %eax,%edx
    7c62:	cf                   	iret   
	...

00007c64 <gdtdesc>:
    7c64:	17                   	pop    %ss
    7c65:	00 4c 7c 00          	add    %cl,0x0(%esp,%edi,2)
	...

00007c6a <waitdisk>:
	}
}

void
waitdisk(void)
{
    7c6a:	f3 0f 1e fb          	endbr32 

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
    7c6e:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7c73:	ec                   	in     (%dx),%al
	// wait for disk reaady
	while ((inb(0x1F7) & 0xC0) != 0x40)
    7c74:	83 e0 c0             	and    $0xffffffc0,%eax
    7c77:	3c 40                	cmp    $0x40,%al
    7c79:	75 f8                	jne    7c73 <waitdisk+0x9>
		/* do nothing */;
}
    7c7b:	c3                   	ret    

00007c7c <readsect>:

void
readsect(void *dst, uint32_t offset)
{
    7c7c:	f3 0f 1e fb          	endbr32 
    7c80:	55                   	push   %ebp
    7c81:	89 e5                	mov    %esp,%ebp
    7c83:	57                   	push   %edi
    7c84:	50                   	push   %eax
    7c85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// wait for disk to be ready
	waitdisk();
    7c88:	e8 dd ff ff ff       	call   7c6a <waitdisk>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
    7c8d:	b0 01                	mov    $0x1,%al
    7c8f:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7c94:	ee                   	out    %al,(%dx)
    7c95:	ba f3 01 00 00       	mov    $0x1f3,%edx
    7c9a:	89 c8                	mov    %ecx,%eax
    7c9c:	ee                   	out    %al,(%dx)

	outb(0x1F2, 1);		// count = 1
	outb(0x1F3, offset);
	outb(0x1F4, offset >> 8);
    7c9d:	89 c8                	mov    %ecx,%eax
    7c9f:	ba f4 01 00 00       	mov    $0x1f4,%edx
    7ca4:	c1 e8 08             	shr    $0x8,%eax
    7ca7:	ee                   	out    %al,(%dx)
	outb(0x1F5, offset >> 16);
    7ca8:	89 c8                	mov    %ecx,%eax
    7caa:	ba f5 01 00 00       	mov    $0x1f5,%edx
    7caf:	c1 e8 10             	shr    $0x10,%eax
    7cb2:	ee                   	out    %al,(%dx)
	outb(0x1F6, (offset >> 24) | 0xE0);
    7cb3:	89 c8                	mov    %ecx,%eax
    7cb5:	ba f6 01 00 00       	mov    $0x1f6,%edx
    7cba:	c1 e8 18             	shr    $0x18,%eax
    7cbd:	83 c8 e0             	or     $0xffffffe0,%eax
    7cc0:	ee                   	out    %al,(%dx)
    7cc1:	b0 20                	mov    $0x20,%al
    7cc3:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7cc8:	ee                   	out    %al,(%dx)
	outb(0x1F7, 0x20);	// cmd 0x20 - read sectors

	// wait for disk to be ready
	waitdisk();
    7cc9:	e8 9c ff ff ff       	call   7c6a <waitdisk>
	asm volatile("cld\n\trepne\n\tinsl"
    7cce:	8b 7d 08             	mov    0x8(%ebp),%edi
    7cd1:	b9 80 00 00 00       	mov    $0x80,%ecx
    7cd6:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7cdb:	fc                   	cld    
    7cdc:	f2 6d                	repnz insl (%dx),%es:(%edi)

	// read a sector
	insl(0x1F0, dst, SECTSIZE/4);
}
    7cde:	5a                   	pop    %edx
    7cdf:	5f                   	pop    %edi
    7ce0:	5d                   	pop    %ebp
    7ce1:	c3                   	ret    

00007ce2 <readseg>:
{
    7ce2:	f3 0f 1e fb          	endbr32 
    7ce6:	55                   	push   %ebp
    7ce7:	89 e5                	mov    %esp,%ebp
    7ce9:	57                   	push   %edi
    7cea:	56                   	push   %esi
    7ceb:	53                   	push   %ebx
    7cec:	83 ec 0c             	sub    $0xc,%esp
	offset = (offset / SECTSIZE) + 1;
    7cef:	8b 7d 10             	mov    0x10(%ebp),%edi
{
    7cf2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	end_pa = pa + count;
    7cf5:	8b 75 0c             	mov    0xc(%ebp),%esi
	offset = (offset / SECTSIZE) + 1;
    7cf8:	c1 ef 09             	shr    $0x9,%edi
	end_pa = pa + count;
    7cfb:	01 de                	add    %ebx,%esi
	offset = (offset / SECTSIZE) + 1;
    7cfd:	47                   	inc    %edi
	pa &= ~(SECTSIZE - 1);
    7cfe:	81 e3 00 fe ff ff    	and    $0xfffffe00,%ebx
	while (pa < end_pa) {
    7d04:	39 f3                	cmp    %esi,%ebx
    7d06:	73 15                	jae    7d1d <readseg+0x3b>
		readsect((uint8_t*) pa, offset);
    7d08:	50                   	push   %eax
    7d09:	50                   	push   %eax
    7d0a:	57                   	push   %edi
		offset++;
    7d0b:	47                   	inc    %edi
		readsect((uint8_t*) pa, offset);
    7d0c:	53                   	push   %ebx
		pa += SECTSIZE;
    7d0d:	81 c3 00 02 00 00    	add    $0x200,%ebx
		readsect((uint8_t*) pa, offset);
    7d13:	e8 64 ff ff ff       	call   7c7c <readsect>
		offset++;
    7d18:	83 c4 10             	add    $0x10,%esp
    7d1b:	eb e7                	jmp    7d04 <readseg+0x22>
}
    7d1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
    7d20:	5b                   	pop    %ebx
    7d21:	5e                   	pop    %esi
    7d22:	5f                   	pop    %edi
    7d23:	5d                   	pop    %ebp
    7d24:	c3                   	ret    

00007d25 <bootmain>:
{
    7d25:	f3 0f 1e fb          	endbr32 
    7d29:	55                   	push   %ebp
    7d2a:	89 e5                	mov    %esp,%ebp
    7d2c:	56                   	push   %esi
    7d2d:	53                   	push   %ebx
	readseg((uint32_t) ELFHDR, SECTSIZE*8, 0);
    7d2e:	52                   	push   %edx
    7d2f:	6a 00                	push   $0x0
    7d31:	68 00 10 00 00       	push   $0x1000
    7d36:	68 00 00 01 00       	push   $0x10000
    7d3b:	e8 a2 ff ff ff       	call   7ce2 <readseg>
	if (ELFHDR->e_magic != ELF_MAGIC)
    7d40:	83 c4 10             	add    $0x10,%esp
    7d43:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d4a:	45 4c 46 
    7d4d:	75 51                	jne    7da0 <bootmain+0x7b>
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    7d4f:	a1 1c 00 01 00       	mov    0x1001c,%eax
	eph = ph + ELFHDR->e_phnum;
    7d54:	0f b7 35 2c 00 01 00 	movzwl 0x1002c,%esi
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    7d5b:	8d 98 00 00 01 00    	lea    0x10000(%eax),%ebx
	eph = ph + ELFHDR->e_phnum;
    7d61:	c1 e6 05             	shl    $0x5,%esi
    7d64:	01 de                	add    %ebx,%esi
	for (; ph < eph; ph++) {
    7d66:	39 f3                	cmp    %esi,%ebx
    7d68:	73 30                	jae    7d9a <bootmain+0x75>
		readseg(ph->p_pa, ph->p_memsz, ph->p_offset);
    7d6a:	50                   	push   %eax
    7d6b:	ff 73 04             	pushl  0x4(%ebx)
    7d6e:	ff 73 14             	pushl  0x14(%ebx)
    7d71:	ff 73 0c             	pushl  0xc(%ebx)
    7d74:	e8 69 ff ff ff       	call   7ce2 <readseg>
		for (i = 0; i < ph->p_memsz - ph->p_filesz; i++) {
    7d79:	83 c4 10             	add    $0x10,%esp
    7d7c:	31 d2                	xor    %edx,%edx
    7d7e:	8b 43 10             	mov    0x10(%ebx),%eax
    7d81:	8b 4b 14             	mov    0x14(%ebx),%ecx
    7d84:	29 c1                	sub    %eax,%ecx
    7d86:	39 d1                	cmp    %edx,%ecx
    7d88:	76 0b                	jbe    7d95 <bootmain+0x70>
			*((char *) ph->p_pa + ph->p_filesz + i) = 0;
    7d8a:	01 d0                	add    %edx,%eax
    7d8c:	03 43 0c             	add    0xc(%ebx),%eax
		for (i = 0; i < ph->p_memsz - ph->p_filesz; i++) {
    7d8f:	42                   	inc    %edx
			*((char *) ph->p_pa + ph->p_filesz + i) = 0;
    7d90:	c6 00 00             	movb   $0x0,(%eax)
    7d93:	eb e9                	jmp    7d7e <bootmain+0x59>
	for (; ph < eph; ph++) {
    7d95:	83 c3 20             	add    $0x20,%ebx
    7d98:	eb cc                	jmp    7d66 <bootmain+0x41>
	((void (*)(void)) (ELFHDR->e_entry))();
    7d9a:	ff 15 18 00 01 00    	call   *0x10018
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
    7da0:	ba 00 8a 00 00       	mov    $0x8a00,%edx
    7da5:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
    7daa:	66 ef                	out    %ax,(%dx)
    7dac:	b8 00 8e ff ff       	mov    $0xffff8e00,%eax
    7db1:	66 ef                	out    %ax,(%dx)
    7db3:	eb fe                	jmp    7db3 <bootmain+0x8e>
