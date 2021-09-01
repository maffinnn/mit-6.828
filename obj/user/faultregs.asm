
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 b8 05 00 00       	call   8005e9 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 d1 29 80 00       	push   $0x8029d1
  800049:	68 a0 29 80 00       	push   $0x8029a0
  80004e:	e8 e5 06 00 00       	call   800738 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 b0 29 80 00       	push   $0x8029b0
  80005c:	68 b4 29 80 00       	push   $0x8029b4
  800061:	e8 d2 06 00 00       	call   800738 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	0f 84 2e 02 00 00    	je     8002a1 <check_regs+0x26e>
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	68 c8 29 80 00       	push   $0x8029c8
  80007b:	e8 b8 06 00 00       	call   800738 <cprintf>
  800080:	83 c4 10             	add    $0x10,%esp
  800083:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  800088:	ff 73 04             	pushl  0x4(%ebx)
  80008b:	ff 76 04             	pushl  0x4(%esi)
  80008e:	68 d2 29 80 00       	push   $0x8029d2
  800093:	68 b4 29 80 00       	push   $0x8029b4
  800098:	e8 9b 06 00 00       	call   800738 <cprintf>
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8000a3:	39 46 04             	cmp    %eax,0x4(%esi)
  8000a6:	0f 84 0f 02 00 00    	je     8002bb <check_regs+0x288>
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 c8 29 80 00       	push   $0x8029c8
  8000b4:	e8 7f 06 00 00       	call   800738 <cprintf>
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000c1:	ff 73 08             	pushl  0x8(%ebx)
  8000c4:	ff 76 08             	pushl  0x8(%esi)
  8000c7:	68 d6 29 80 00       	push   $0x8029d6
  8000cc:	68 b4 29 80 00       	push   $0x8029b4
  8000d1:	e8 62 06 00 00       	call   800738 <cprintf>
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8b 43 08             	mov    0x8(%ebx),%eax
  8000dc:	39 46 08             	cmp    %eax,0x8(%esi)
  8000df:	0f 84 eb 01 00 00    	je     8002d0 <check_regs+0x29d>
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	68 c8 29 80 00       	push   $0x8029c8
  8000ed:	e8 46 06 00 00       	call   800738 <cprintf>
  8000f2:	83 c4 10             	add    $0x10,%esp
  8000f5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  8000fa:	ff 73 10             	pushl  0x10(%ebx)
  8000fd:	ff 76 10             	pushl  0x10(%esi)
  800100:	68 da 29 80 00       	push   $0x8029da
  800105:	68 b4 29 80 00       	push   $0x8029b4
  80010a:	e8 29 06 00 00       	call   800738 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	8b 43 10             	mov    0x10(%ebx),%eax
  800115:	39 46 10             	cmp    %eax,0x10(%esi)
  800118:	0f 84 c7 01 00 00    	je     8002e5 <check_regs+0x2b2>
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	68 c8 29 80 00       	push   $0x8029c8
  800126:	e8 0d 06 00 00       	call   800738 <cprintf>
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800133:	ff 73 14             	pushl  0x14(%ebx)
  800136:	ff 76 14             	pushl  0x14(%esi)
  800139:	68 de 29 80 00       	push   $0x8029de
  80013e:	68 b4 29 80 00       	push   $0x8029b4
  800143:	e8 f0 05 00 00       	call   800738 <cprintf>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	8b 43 14             	mov    0x14(%ebx),%eax
  80014e:	39 46 14             	cmp    %eax,0x14(%esi)
  800151:	0f 84 a3 01 00 00    	je     8002fa <check_regs+0x2c7>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	68 c8 29 80 00       	push   $0x8029c8
  80015f:	e8 d4 05 00 00       	call   800738 <cprintf>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  80016c:	ff 73 18             	pushl  0x18(%ebx)
  80016f:	ff 76 18             	pushl  0x18(%esi)
  800172:	68 e2 29 80 00       	push   $0x8029e2
  800177:	68 b4 29 80 00       	push   $0x8029b4
  80017c:	e8 b7 05 00 00       	call   800738 <cprintf>
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	8b 43 18             	mov    0x18(%ebx),%eax
  800187:	39 46 18             	cmp    %eax,0x18(%esi)
  80018a:	0f 84 7f 01 00 00    	je     80030f <check_regs+0x2dc>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 c8 29 80 00       	push   $0x8029c8
  800198:	e8 9b 05 00 00       	call   800738 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001a5:	ff 73 1c             	pushl  0x1c(%ebx)
  8001a8:	ff 76 1c             	pushl  0x1c(%esi)
  8001ab:	68 e6 29 80 00       	push   $0x8029e6
  8001b0:	68 b4 29 80 00       	push   $0x8029b4
  8001b5:	e8 7e 05 00 00       	call   800738 <cprintf>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	8b 43 1c             	mov    0x1c(%ebx),%eax
  8001c0:	39 46 1c             	cmp    %eax,0x1c(%esi)
  8001c3:	0f 84 5b 01 00 00    	je     800324 <check_regs+0x2f1>
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	68 c8 29 80 00       	push   $0x8029c8
  8001d1:	e8 62 05 00 00       	call   800738 <cprintf>
  8001d6:	83 c4 10             	add    $0x10,%esp
  8001d9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  8001de:	ff 73 20             	pushl  0x20(%ebx)
  8001e1:	ff 76 20             	pushl  0x20(%esi)
  8001e4:	68 ea 29 80 00       	push   $0x8029ea
  8001e9:	68 b4 29 80 00       	push   $0x8029b4
  8001ee:	e8 45 05 00 00       	call   800738 <cprintf>
  8001f3:	83 c4 10             	add    $0x10,%esp
  8001f6:	8b 43 20             	mov    0x20(%ebx),%eax
  8001f9:	39 46 20             	cmp    %eax,0x20(%esi)
  8001fc:	0f 84 37 01 00 00    	je     800339 <check_regs+0x306>
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	68 c8 29 80 00       	push   $0x8029c8
  80020a:	e8 29 05 00 00       	call   800738 <cprintf>
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  800217:	ff 73 24             	pushl  0x24(%ebx)
  80021a:	ff 76 24             	pushl  0x24(%esi)
  80021d:	68 ee 29 80 00       	push   $0x8029ee
  800222:	68 b4 29 80 00       	push   $0x8029b4
  800227:	e8 0c 05 00 00       	call   800738 <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8b 43 24             	mov    0x24(%ebx),%eax
  800232:	39 46 24             	cmp    %eax,0x24(%esi)
  800235:	0f 84 13 01 00 00    	je     80034e <check_regs+0x31b>
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	68 c8 29 80 00       	push   $0x8029c8
  800243:	e8 f0 04 00 00       	call   800738 <cprintf>
	CHECK(esp, esp);
  800248:	ff 73 28             	pushl  0x28(%ebx)
  80024b:	ff 76 28             	pushl  0x28(%esi)
  80024e:	68 f5 29 80 00       	push   $0x8029f5
  800253:	68 b4 29 80 00       	push   $0x8029b4
  800258:	e8 db 04 00 00       	call   800738 <cprintf>
  80025d:	83 c4 20             	add    $0x20,%esp
  800260:	8b 43 28             	mov    0x28(%ebx),%eax
  800263:	39 46 28             	cmp    %eax,0x28(%esi)
  800266:	0f 84 53 01 00 00    	je     8003bf <check_regs+0x38c>
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	68 c8 29 80 00       	push   $0x8029c8
  800274:	e8 bf 04 00 00       	call   800738 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800279:	83 c4 08             	add    $0x8,%esp
  80027c:	ff 75 0c             	pushl  0xc(%ebp)
  80027f:	68 f9 29 80 00       	push   $0x8029f9
  800284:	e8 af 04 00 00       	call   800738 <cprintf>
  800289:	83 c4 10             	add    $0x10,%esp
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	68 c8 29 80 00       	push   $0x8029c8
  800294:	e8 9f 04 00 00       	call   800738 <cprintf>
  800299:	83 c4 10             	add    $0x10,%esp
}
  80029c:	e9 16 01 00 00       	jmp    8003b7 <check_regs+0x384>
	CHECK(edi, regs.reg_edi);
  8002a1:	83 ec 0c             	sub    $0xc,%esp
  8002a4:	68 c4 29 80 00       	push   $0x8029c4
  8002a9:	e8 8a 04 00 00       	call   800738 <cprintf>
  8002ae:	83 c4 10             	add    $0x10,%esp
	int mismatch = 0;
  8002b1:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b6:	e9 cd fd ff ff       	jmp    800088 <check_regs+0x55>
	CHECK(esi, regs.reg_esi);
  8002bb:	83 ec 0c             	sub    $0xc,%esp
  8002be:	68 c4 29 80 00       	push   $0x8029c4
  8002c3:	e8 70 04 00 00       	call   800738 <cprintf>
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	e9 f1 fd ff ff       	jmp    8000c1 <check_regs+0x8e>
	CHECK(ebp, regs.reg_ebp);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	68 c4 29 80 00       	push   $0x8029c4
  8002d8:	e8 5b 04 00 00       	call   800738 <cprintf>
  8002dd:	83 c4 10             	add    $0x10,%esp
  8002e0:	e9 15 fe ff ff       	jmp    8000fa <check_regs+0xc7>
	CHECK(ebx, regs.reg_ebx);
  8002e5:	83 ec 0c             	sub    $0xc,%esp
  8002e8:	68 c4 29 80 00       	push   $0x8029c4
  8002ed:	e8 46 04 00 00       	call   800738 <cprintf>
  8002f2:	83 c4 10             	add    $0x10,%esp
  8002f5:	e9 39 fe ff ff       	jmp    800133 <check_regs+0x100>
	CHECK(edx, regs.reg_edx);
  8002fa:	83 ec 0c             	sub    $0xc,%esp
  8002fd:	68 c4 29 80 00       	push   $0x8029c4
  800302:	e8 31 04 00 00       	call   800738 <cprintf>
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	e9 5d fe ff ff       	jmp    80016c <check_regs+0x139>
	CHECK(ecx, regs.reg_ecx);
  80030f:	83 ec 0c             	sub    $0xc,%esp
  800312:	68 c4 29 80 00       	push   $0x8029c4
  800317:	e8 1c 04 00 00       	call   800738 <cprintf>
  80031c:	83 c4 10             	add    $0x10,%esp
  80031f:	e9 81 fe ff ff       	jmp    8001a5 <check_regs+0x172>
	CHECK(eax, regs.reg_eax);
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	68 c4 29 80 00       	push   $0x8029c4
  80032c:	e8 07 04 00 00       	call   800738 <cprintf>
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	e9 a5 fe ff ff       	jmp    8001de <check_regs+0x1ab>
	CHECK(eip, eip);
  800339:	83 ec 0c             	sub    $0xc,%esp
  80033c:	68 c4 29 80 00       	push   $0x8029c4
  800341:	e8 f2 03 00 00       	call   800738 <cprintf>
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	e9 c9 fe ff ff       	jmp    800217 <check_regs+0x1e4>
	CHECK(eflags, eflags);
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	68 c4 29 80 00       	push   $0x8029c4
  800356:	e8 dd 03 00 00       	call   800738 <cprintf>
	CHECK(esp, esp);
  80035b:	ff 73 28             	pushl  0x28(%ebx)
  80035e:	ff 76 28             	pushl  0x28(%esi)
  800361:	68 f5 29 80 00       	push   $0x8029f5
  800366:	68 b4 29 80 00       	push   $0x8029b4
  80036b:	e8 c8 03 00 00       	call   800738 <cprintf>
  800370:	83 c4 20             	add    $0x20,%esp
  800373:	8b 43 28             	mov    0x28(%ebx),%eax
  800376:	39 46 28             	cmp    %eax,0x28(%esi)
  800379:	0f 85 ed fe ff ff    	jne    80026c <check_regs+0x239>
  80037f:	83 ec 0c             	sub    $0xc,%esp
  800382:	68 c4 29 80 00       	push   $0x8029c4
  800387:	e8 ac 03 00 00       	call   800738 <cprintf>
	cprintf("Registers %s ", testname);
  80038c:	83 c4 08             	add    $0x8,%esp
  80038f:	ff 75 0c             	pushl  0xc(%ebp)
  800392:	68 f9 29 80 00       	push   $0x8029f9
  800397:	e8 9c 03 00 00       	call   800738 <cprintf>
	if (!mismatch)
  80039c:	83 c4 10             	add    $0x10,%esp
  80039f:	85 ff                	test   %edi,%edi
  8003a1:	0f 85 e5 fe ff ff    	jne    80028c <check_regs+0x259>
		cprintf("OK\n");
  8003a7:	83 ec 0c             	sub    $0xc,%esp
  8003aa:	68 c4 29 80 00       	push   $0x8029c4
  8003af:	e8 84 03 00 00       	call   800738 <cprintf>
  8003b4:	83 c4 10             	add    $0x10,%esp
}
  8003b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ba:	5b                   	pop    %ebx
  8003bb:	5e                   	pop    %esi
  8003bc:	5f                   	pop    %edi
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    
	CHECK(esp, esp);
  8003bf:	83 ec 0c             	sub    $0xc,%esp
  8003c2:	68 c4 29 80 00       	push   $0x8029c4
  8003c7:	e8 6c 03 00 00       	call   800738 <cprintf>
	cprintf("Registers %s ", testname);
  8003cc:	83 c4 08             	add    $0x8,%esp
  8003cf:	ff 75 0c             	pushl  0xc(%ebp)
  8003d2:	68 f9 29 80 00       	push   $0x8029f9
  8003d7:	e8 5c 03 00 00       	call   800738 <cprintf>
  8003dc:	83 c4 10             	add    $0x10,%esp
  8003df:	e9 a8 fe ff ff       	jmp    80028c <check_regs+0x259>

008003e4 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003e4:	f3 0f 1e fb          	endbr32 
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	83 ec 08             	sub    $0x8,%esp
  8003ee:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003f1:	8b 10                	mov    (%eax),%edx
  8003f3:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003f9:	0f 85 a3 00 00 00    	jne    8004a2 <pgfault+0xbe>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003ff:	8b 50 08             	mov    0x8(%eax),%edx
  800402:	89 15 40 40 80 00    	mov    %edx,0x804040
  800408:	8b 50 0c             	mov    0xc(%eax),%edx
  80040b:	89 15 44 40 80 00    	mov    %edx,0x804044
  800411:	8b 50 10             	mov    0x10(%eax),%edx
  800414:	89 15 48 40 80 00    	mov    %edx,0x804048
  80041a:	8b 50 14             	mov    0x14(%eax),%edx
  80041d:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  800423:	8b 50 18             	mov    0x18(%eax),%edx
  800426:	89 15 50 40 80 00    	mov    %edx,0x804050
  80042c:	8b 50 1c             	mov    0x1c(%eax),%edx
  80042f:	89 15 54 40 80 00    	mov    %edx,0x804054
  800435:	8b 50 20             	mov    0x20(%eax),%edx
  800438:	89 15 58 40 80 00    	mov    %edx,0x804058
  80043e:	8b 50 24             	mov    0x24(%eax),%edx
  800441:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800447:	8b 50 28             	mov    0x28(%eax),%edx
  80044a:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags & ~FL_RF;
  800450:	8b 50 2c             	mov    0x2c(%eax),%edx
  800453:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800459:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  80045f:	8b 40 30             	mov    0x30(%eax),%eax
  800462:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	68 1f 2a 80 00       	push   $0x802a1f
  80046f:	68 2d 2a 80 00       	push   $0x802a2d
  800474:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800479:	ba 18 2a 80 00       	mov    $0x802a18,%edx
  80047e:	b8 80 40 80 00       	mov    $0x804080,%eax
  800483:	e8 ab fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800488:	83 c4 0c             	add    $0xc,%esp
  80048b:	6a 07                	push   $0x7
  80048d:	68 00 00 40 00       	push   $0x400000
  800492:	6a 00                	push   $0x0
  800494:	e8 12 0d 00 00       	call   8011ab <sys_page_alloc>
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	85 c0                	test   %eax,%eax
  80049e:	78 1a                	js     8004ba <pgfault+0xd6>
		panic("sys_page_alloc: %e", r);
}
  8004a0:	c9                   	leave  
  8004a1:	c3                   	ret    
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8004a2:	83 ec 0c             	sub    $0xc,%esp
  8004a5:	ff 70 28             	pushl  0x28(%eax)
  8004a8:	52                   	push   %edx
  8004a9:	68 60 2a 80 00       	push   $0x802a60
  8004ae:	6a 50                	push   $0x50
  8004b0:	68 07 2a 80 00       	push   $0x802a07
  8004b5:	e8 97 01 00 00       	call   800651 <_panic>
		panic("sys_page_alloc: %e", r);
  8004ba:	50                   	push   %eax
  8004bb:	68 34 2a 80 00       	push   $0x802a34
  8004c0:	6a 5c                	push   $0x5c
  8004c2:	68 07 2a 80 00       	push   $0x802a07
  8004c7:	e8 85 01 00 00       	call   800651 <_panic>

008004cc <umain>:

void
umain(int argc, char **argv)
{
  8004cc:	f3 0f 1e fb          	endbr32 
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  8004d6:	68 e4 03 80 00       	push   $0x8003e4
  8004db:	e8 62 0e 00 00       	call   801342 <set_pgfault_handler>

	asm volatile(
  8004e0:	50                   	push   %eax
  8004e1:	9c                   	pushf  
  8004e2:	58                   	pop    %eax
  8004e3:	0d d5 08 00 00       	or     $0x8d5,%eax
  8004e8:	50                   	push   %eax
  8004e9:	9d                   	popf   
  8004ea:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  8004ef:	8d 05 2a 05 80 00    	lea    0x80052a,%eax
  8004f5:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004fa:	58                   	pop    %eax
  8004fb:	89 3d 80 40 80 00    	mov    %edi,0x804080
  800501:	89 35 84 40 80 00    	mov    %esi,0x804084
  800507:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  80050d:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  800513:	89 15 94 40 80 00    	mov    %edx,0x804094
  800519:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  80051f:	a3 9c 40 80 00       	mov    %eax,0x80409c
  800524:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  80052a:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  800531:	00 00 00 
  800534:	89 3d 00 40 80 00    	mov    %edi,0x804000
  80053a:	89 35 04 40 80 00    	mov    %esi,0x804004
  800540:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  800546:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  80054c:	89 15 14 40 80 00    	mov    %edx,0x804014
  800552:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  800558:	a3 1c 40 80 00       	mov    %eax,0x80401c
  80055d:	89 25 28 40 80 00    	mov    %esp,0x804028
  800563:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  800569:	8b 35 84 40 80 00    	mov    0x804084,%esi
  80056f:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  800575:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  80057b:	8b 15 94 40 80 00    	mov    0x804094,%edx
  800581:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  800587:	a1 9c 40 80 00       	mov    0x80409c,%eax
  80058c:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  800592:	50                   	push   %eax
  800593:	9c                   	pushf  
  800594:	58                   	pop    %eax
  800595:	a3 24 40 80 00       	mov    %eax,0x804024
  80059a:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80059b:	83 c4 10             	add    $0x10,%esp
  80059e:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  8005a5:	75 30                	jne    8005d7 <umain+0x10b>
		cprintf("EIP after page-fault MISMATCH\n");
	after.eip = before.eip;
  8005a7:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  8005ac:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	68 47 2a 80 00       	push   $0x802a47
  8005b9:	68 58 2a 80 00       	push   $0x802a58
  8005be:	b9 00 40 80 00       	mov    $0x804000,%ecx
  8005c3:	ba 18 2a 80 00       	mov    $0x802a18,%edx
  8005c8:	b8 80 40 80 00       	mov    $0x804080,%eax
  8005cd:	e8 61 fa ff ff       	call   800033 <check_regs>
}
  8005d2:	83 c4 10             	add    $0x10,%esp
  8005d5:	c9                   	leave  
  8005d6:	c3                   	ret    
		cprintf("EIP after page-fault MISMATCH\n");
  8005d7:	83 ec 0c             	sub    $0xc,%esp
  8005da:	68 94 2a 80 00       	push   $0x802a94
  8005df:	e8 54 01 00 00       	call   800738 <cprintf>
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	eb be                	jmp    8005a7 <umain+0xdb>

008005e9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8005e9:	f3 0f 1e fb          	endbr32 
  8005ed:	55                   	push   %ebp
  8005ee:	89 e5                	mov    %esp,%ebp
  8005f0:	56                   	push   %esi
  8005f1:	53                   	push   %ebx
  8005f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8005f8:	e8 68 0b 00 00       	call   801165 <sys_getenvid>
  8005fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800602:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800605:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80060a:	a3 b4 40 80 00       	mov    %eax,0x8040b4
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80060f:	85 db                	test   %ebx,%ebx
  800611:	7e 07                	jle    80061a <libmain+0x31>
		binaryname = argv[0];
  800613:	8b 06                	mov    (%esi),%eax
  800615:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80061a:	83 ec 08             	sub    $0x8,%esp
  80061d:	56                   	push   %esi
  80061e:	53                   	push   %ebx
  80061f:	e8 a8 fe ff ff       	call   8004cc <umain>

	// exit gracefully
	exit();
  800624:	e8 0a 00 00 00       	call   800633 <exit>
}
  800629:	83 c4 10             	add    $0x10,%esp
  80062c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80062f:	5b                   	pop    %ebx
  800630:	5e                   	pop    %esi
  800631:	5d                   	pop    %ebp
  800632:	c3                   	ret    

00800633 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800633:	f3 0f 1e fb          	endbr32 
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  80063d:	e8 8b 0f 00 00       	call   8015cd <close_all>
	sys_env_destroy(0);
  800642:	83 ec 0c             	sub    $0xc,%esp
  800645:	6a 00                	push   $0x0
  800647:	e8 f5 0a 00 00       	call   801141 <sys_env_destroy>
}
  80064c:	83 c4 10             	add    $0x10,%esp
  80064f:	c9                   	leave  
  800650:	c3                   	ret    

00800651 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800651:	f3 0f 1e fb          	endbr32 
  800655:	55                   	push   %ebp
  800656:	89 e5                	mov    %esp,%ebp
  800658:	56                   	push   %esi
  800659:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80065a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80065d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800663:	e8 fd 0a 00 00       	call   801165 <sys_getenvid>
  800668:	83 ec 0c             	sub    $0xc,%esp
  80066b:	ff 75 0c             	pushl  0xc(%ebp)
  80066e:	ff 75 08             	pushl  0x8(%ebp)
  800671:	56                   	push   %esi
  800672:	50                   	push   %eax
  800673:	68 c0 2a 80 00       	push   $0x802ac0
  800678:	e8 bb 00 00 00       	call   800738 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80067d:	83 c4 18             	add    $0x18,%esp
  800680:	53                   	push   %ebx
  800681:	ff 75 10             	pushl  0x10(%ebp)
  800684:	e8 5a 00 00 00       	call   8006e3 <vcprintf>
	cprintf("\n");
  800689:	c7 04 24 d0 29 80 00 	movl   $0x8029d0,(%esp)
  800690:	e8 a3 00 00 00       	call   800738 <cprintf>
  800695:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800698:	cc                   	int3   
  800699:	eb fd                	jmp    800698 <_panic+0x47>

0080069b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80069b:	f3 0f 1e fb          	endbr32 
  80069f:	55                   	push   %ebp
  8006a0:	89 e5                	mov    %esp,%ebp
  8006a2:	53                   	push   %ebx
  8006a3:	83 ec 04             	sub    $0x4,%esp
  8006a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006a9:	8b 13                	mov    (%ebx),%edx
  8006ab:	8d 42 01             	lea    0x1(%edx),%eax
  8006ae:	89 03                	mov    %eax,(%ebx)
  8006b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006b7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006bc:	74 09                	je     8006c7 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8006be:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c5:	c9                   	leave  
  8006c6:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8006c7:	83 ec 08             	sub    $0x8,%esp
  8006ca:	68 ff 00 00 00       	push   $0xff
  8006cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8006d2:	50                   	push   %eax
  8006d3:	e8 24 0a 00 00       	call   8010fc <sys_cputs>
		b->idx = 0;
  8006d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	eb db                	jmp    8006be <putch+0x23>

008006e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006e3:	f3 0f 1e fb          	endbr32 
  8006e7:	55                   	push   %ebp
  8006e8:	89 e5                	mov    %esp,%ebp
  8006ea:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006f0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006f7:	00 00 00 
	b.cnt = 0;
  8006fa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800701:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800704:	ff 75 0c             	pushl  0xc(%ebp)
  800707:	ff 75 08             	pushl  0x8(%ebp)
  80070a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800710:	50                   	push   %eax
  800711:	68 9b 06 80 00       	push   $0x80069b
  800716:	e8 20 01 00 00       	call   80083b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80071b:	83 c4 08             	add    $0x8,%esp
  80071e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800724:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80072a:	50                   	push   %eax
  80072b:	e8 cc 09 00 00       	call   8010fc <sys_cputs>

	return b.cnt;
}
  800730:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800736:	c9                   	leave  
  800737:	c3                   	ret    

00800738 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800738:	f3 0f 1e fb          	endbr32 
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800742:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800745:	50                   	push   %eax
  800746:	ff 75 08             	pushl  0x8(%ebp)
  800749:	e8 95 ff ff ff       	call   8006e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80074e:	c9                   	leave  
  80074f:	c3                   	ret    

00800750 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	57                   	push   %edi
  800754:	56                   	push   %esi
  800755:	53                   	push   %ebx
  800756:	83 ec 1c             	sub    $0x1c,%esp
  800759:	89 c7                	mov    %eax,%edi
  80075b:	89 d6                	mov    %edx,%esi
  80075d:	8b 45 08             	mov    0x8(%ebp),%eax
  800760:	8b 55 0c             	mov    0xc(%ebp),%edx
  800763:	89 d1                	mov    %edx,%ecx
  800765:	89 c2                	mov    %eax,%edx
  800767:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80076a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80076d:	8b 45 10             	mov    0x10(%ebp),%eax
  800770:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800773:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800776:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80077d:	39 c2                	cmp    %eax,%edx
  80077f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800782:	72 3e                	jb     8007c2 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800784:	83 ec 0c             	sub    $0xc,%esp
  800787:	ff 75 18             	pushl  0x18(%ebp)
  80078a:	83 eb 01             	sub    $0x1,%ebx
  80078d:	53                   	push   %ebx
  80078e:	50                   	push   %eax
  80078f:	83 ec 08             	sub    $0x8,%esp
  800792:	ff 75 e4             	pushl  -0x1c(%ebp)
  800795:	ff 75 e0             	pushl  -0x20(%ebp)
  800798:	ff 75 dc             	pushl  -0x24(%ebp)
  80079b:	ff 75 d8             	pushl  -0x28(%ebp)
  80079e:	e8 8d 1f 00 00       	call   802730 <__udivdi3>
  8007a3:	83 c4 18             	add    $0x18,%esp
  8007a6:	52                   	push   %edx
  8007a7:	50                   	push   %eax
  8007a8:	89 f2                	mov    %esi,%edx
  8007aa:	89 f8                	mov    %edi,%eax
  8007ac:	e8 9f ff ff ff       	call   800750 <printnum>
  8007b1:	83 c4 20             	add    $0x20,%esp
  8007b4:	eb 13                	jmp    8007c9 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007b6:	83 ec 08             	sub    $0x8,%esp
  8007b9:	56                   	push   %esi
  8007ba:	ff 75 18             	pushl  0x18(%ebp)
  8007bd:	ff d7                	call   *%edi
  8007bf:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8007c2:	83 eb 01             	sub    $0x1,%ebx
  8007c5:	85 db                	test   %ebx,%ebx
  8007c7:	7f ed                	jg     8007b6 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007c9:	83 ec 08             	sub    $0x8,%esp
  8007cc:	56                   	push   %esi
  8007cd:	83 ec 04             	sub    $0x4,%esp
  8007d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d6:	ff 75 dc             	pushl  -0x24(%ebp)
  8007d9:	ff 75 d8             	pushl  -0x28(%ebp)
  8007dc:	e8 5f 20 00 00       	call   802840 <__umoddi3>
  8007e1:	83 c4 14             	add    $0x14,%esp
  8007e4:	0f be 80 e3 2a 80 00 	movsbl 0x802ae3(%eax),%eax
  8007eb:	50                   	push   %eax
  8007ec:	ff d7                	call   *%edi
}
  8007ee:	83 c4 10             	add    $0x10,%esp
  8007f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f4:	5b                   	pop    %ebx
  8007f5:	5e                   	pop    %esi
  8007f6:	5f                   	pop    %edi
  8007f7:	5d                   	pop    %ebp
  8007f8:	c3                   	ret    

008007f9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007f9:	f3 0f 1e fb          	endbr32 
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800803:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800807:	8b 10                	mov    (%eax),%edx
  800809:	3b 50 04             	cmp    0x4(%eax),%edx
  80080c:	73 0a                	jae    800818 <sprintputch+0x1f>
		*b->buf++ = ch;
  80080e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800811:	89 08                	mov    %ecx,(%eax)
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	88 02                	mov    %al,(%edx)
}
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <printfmt>:
{
  80081a:	f3 0f 1e fb          	endbr32 
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800824:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800827:	50                   	push   %eax
  800828:	ff 75 10             	pushl  0x10(%ebp)
  80082b:	ff 75 0c             	pushl  0xc(%ebp)
  80082e:	ff 75 08             	pushl  0x8(%ebp)
  800831:	e8 05 00 00 00       	call   80083b <vprintfmt>
}
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	c9                   	leave  
  80083a:	c3                   	ret    

0080083b <vprintfmt>:
{
  80083b:	f3 0f 1e fb          	endbr32 
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	57                   	push   %edi
  800843:	56                   	push   %esi
  800844:	53                   	push   %ebx
  800845:	83 ec 3c             	sub    $0x3c,%esp
  800848:	8b 75 08             	mov    0x8(%ebp),%esi
  80084b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80084e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800851:	e9 8e 03 00 00       	jmp    800be4 <vprintfmt+0x3a9>
		padc = ' ';
  800856:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80085a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800861:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800868:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80086f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800874:	8d 47 01             	lea    0x1(%edi),%eax
  800877:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80087a:	0f b6 17             	movzbl (%edi),%edx
  80087d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800880:	3c 55                	cmp    $0x55,%al
  800882:	0f 87 df 03 00 00    	ja     800c67 <vprintfmt+0x42c>
  800888:	0f b6 c0             	movzbl %al,%eax
  80088b:	3e ff 24 85 20 2c 80 	notrack jmp *0x802c20(,%eax,4)
  800892:	00 
  800893:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800896:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80089a:	eb d8                	jmp    800874 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80089c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80089f:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8008a3:	eb cf                	jmp    800874 <vprintfmt+0x39>
  8008a5:	0f b6 d2             	movzbl %dl,%edx
  8008a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8008ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8008b3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8008b6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8008ba:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8008bd:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8008c0:	83 f9 09             	cmp    $0x9,%ecx
  8008c3:	77 55                	ja     80091a <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8008c5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8008c8:	eb e9                	jmp    8008b3 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8008ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cd:	8b 00                	mov    (%eax),%eax
  8008cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d5:	8d 40 04             	lea    0x4(%eax),%eax
  8008d8:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8008de:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008e2:	79 90                	jns    800874 <vprintfmt+0x39>
				width = precision, precision = -1;
  8008e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008ea:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8008f1:	eb 81                	jmp    800874 <vprintfmt+0x39>
  8008f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008f6:	85 c0                	test   %eax,%eax
  8008f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8008fd:	0f 49 d0             	cmovns %eax,%edx
  800900:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800903:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800906:	e9 69 ff ff ff       	jmp    800874 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80090b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80090e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800915:	e9 5a ff ff ff       	jmp    800874 <vprintfmt+0x39>
  80091a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80091d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800920:	eb bc                	jmp    8008de <vprintfmt+0xa3>
			lflag++;
  800922:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800925:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800928:	e9 47 ff ff ff       	jmp    800874 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80092d:	8b 45 14             	mov    0x14(%ebp),%eax
  800930:	8d 78 04             	lea    0x4(%eax),%edi
  800933:	83 ec 08             	sub    $0x8,%esp
  800936:	53                   	push   %ebx
  800937:	ff 30                	pushl  (%eax)
  800939:	ff d6                	call   *%esi
			break;
  80093b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80093e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800941:	e9 9b 02 00 00       	jmp    800be1 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800946:	8b 45 14             	mov    0x14(%ebp),%eax
  800949:	8d 78 04             	lea    0x4(%eax),%edi
  80094c:	8b 00                	mov    (%eax),%eax
  80094e:	99                   	cltd   
  80094f:	31 d0                	xor    %edx,%eax
  800951:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800953:	83 f8 0f             	cmp    $0xf,%eax
  800956:	7f 23                	jg     80097b <vprintfmt+0x140>
  800958:	8b 14 85 80 2d 80 00 	mov    0x802d80(,%eax,4),%edx
  80095f:	85 d2                	test   %edx,%edx
  800961:	74 18                	je     80097b <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800963:	52                   	push   %edx
  800964:	68 f9 2e 80 00       	push   $0x802ef9
  800969:	53                   	push   %ebx
  80096a:	56                   	push   %esi
  80096b:	e8 aa fe ff ff       	call   80081a <printfmt>
  800970:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800973:	89 7d 14             	mov    %edi,0x14(%ebp)
  800976:	e9 66 02 00 00       	jmp    800be1 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80097b:	50                   	push   %eax
  80097c:	68 fb 2a 80 00       	push   $0x802afb
  800981:	53                   	push   %ebx
  800982:	56                   	push   %esi
  800983:	e8 92 fe ff ff       	call   80081a <printfmt>
  800988:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80098b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80098e:	e9 4e 02 00 00       	jmp    800be1 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800993:	8b 45 14             	mov    0x14(%ebp),%eax
  800996:	83 c0 04             	add    $0x4,%eax
  800999:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80099c:	8b 45 14             	mov    0x14(%ebp),%eax
  80099f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8009a1:	85 d2                	test   %edx,%edx
  8009a3:	b8 f4 2a 80 00       	mov    $0x802af4,%eax
  8009a8:	0f 45 c2             	cmovne %edx,%eax
  8009ab:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8009ae:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009b2:	7e 06                	jle    8009ba <vprintfmt+0x17f>
  8009b4:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8009b8:	75 0d                	jne    8009c7 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ba:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009bd:	89 c7                	mov    %eax,%edi
  8009bf:	03 45 e0             	add    -0x20(%ebp),%eax
  8009c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009c5:	eb 55                	jmp    800a1c <vprintfmt+0x1e1>
  8009c7:	83 ec 08             	sub    $0x8,%esp
  8009ca:	ff 75 d8             	pushl  -0x28(%ebp)
  8009cd:	ff 75 cc             	pushl  -0x34(%ebp)
  8009d0:	e8 46 03 00 00       	call   800d1b <strnlen>
  8009d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8009d8:	29 c2                	sub    %eax,%edx
  8009da:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8009dd:	83 c4 10             	add    $0x10,%esp
  8009e0:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8009e2:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8009e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8009e9:	85 ff                	test   %edi,%edi
  8009eb:	7e 11                	jle    8009fe <vprintfmt+0x1c3>
					putch(padc, putdat);
  8009ed:	83 ec 08             	sub    $0x8,%esp
  8009f0:	53                   	push   %ebx
  8009f1:	ff 75 e0             	pushl  -0x20(%ebp)
  8009f4:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8009f6:	83 ef 01             	sub    $0x1,%edi
  8009f9:	83 c4 10             	add    $0x10,%esp
  8009fc:	eb eb                	jmp    8009e9 <vprintfmt+0x1ae>
  8009fe:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800a01:	85 d2                	test   %edx,%edx
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
  800a08:	0f 49 c2             	cmovns %edx,%eax
  800a0b:	29 c2                	sub    %eax,%edx
  800a0d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800a10:	eb a8                	jmp    8009ba <vprintfmt+0x17f>
					putch(ch, putdat);
  800a12:	83 ec 08             	sub    $0x8,%esp
  800a15:	53                   	push   %ebx
  800a16:	52                   	push   %edx
  800a17:	ff d6                	call   *%esi
  800a19:	83 c4 10             	add    $0x10,%esp
  800a1c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a1f:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a21:	83 c7 01             	add    $0x1,%edi
  800a24:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a28:	0f be d0             	movsbl %al,%edx
  800a2b:	85 d2                	test   %edx,%edx
  800a2d:	74 4b                	je     800a7a <vprintfmt+0x23f>
  800a2f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a33:	78 06                	js     800a3b <vprintfmt+0x200>
  800a35:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800a39:	78 1e                	js     800a59 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  800a3b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800a3f:	74 d1                	je     800a12 <vprintfmt+0x1d7>
  800a41:	0f be c0             	movsbl %al,%eax
  800a44:	83 e8 20             	sub    $0x20,%eax
  800a47:	83 f8 5e             	cmp    $0x5e,%eax
  800a4a:	76 c6                	jbe    800a12 <vprintfmt+0x1d7>
					putch('?', putdat);
  800a4c:	83 ec 08             	sub    $0x8,%esp
  800a4f:	53                   	push   %ebx
  800a50:	6a 3f                	push   $0x3f
  800a52:	ff d6                	call   *%esi
  800a54:	83 c4 10             	add    $0x10,%esp
  800a57:	eb c3                	jmp    800a1c <vprintfmt+0x1e1>
  800a59:	89 cf                	mov    %ecx,%edi
  800a5b:	eb 0e                	jmp    800a6b <vprintfmt+0x230>
				putch(' ', putdat);
  800a5d:	83 ec 08             	sub    $0x8,%esp
  800a60:	53                   	push   %ebx
  800a61:	6a 20                	push   $0x20
  800a63:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800a65:	83 ef 01             	sub    $0x1,%edi
  800a68:	83 c4 10             	add    $0x10,%esp
  800a6b:	85 ff                	test   %edi,%edi
  800a6d:	7f ee                	jg     800a5d <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800a6f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800a72:	89 45 14             	mov    %eax,0x14(%ebp)
  800a75:	e9 67 01 00 00       	jmp    800be1 <vprintfmt+0x3a6>
  800a7a:	89 cf                	mov    %ecx,%edi
  800a7c:	eb ed                	jmp    800a6b <vprintfmt+0x230>
	if (lflag >= 2)
  800a7e:	83 f9 01             	cmp    $0x1,%ecx
  800a81:	7f 1b                	jg     800a9e <vprintfmt+0x263>
	else if (lflag)
  800a83:	85 c9                	test   %ecx,%ecx
  800a85:	74 63                	je     800aea <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800a87:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8a:	8b 00                	mov    (%eax),%eax
  800a8c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a8f:	99                   	cltd   
  800a90:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a93:	8b 45 14             	mov    0x14(%ebp),%eax
  800a96:	8d 40 04             	lea    0x4(%eax),%eax
  800a99:	89 45 14             	mov    %eax,0x14(%ebp)
  800a9c:	eb 17                	jmp    800ab5 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800a9e:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa1:	8b 50 04             	mov    0x4(%eax),%edx
  800aa4:	8b 00                	mov    (%eax),%eax
  800aa6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aa9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800aac:	8b 45 14             	mov    0x14(%ebp),%eax
  800aaf:	8d 40 08             	lea    0x8(%eax),%eax
  800ab2:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800ab5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ab8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800abb:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800ac0:	85 c9                	test   %ecx,%ecx
  800ac2:	0f 89 ff 00 00 00    	jns    800bc7 <vprintfmt+0x38c>
				putch('-', putdat);
  800ac8:	83 ec 08             	sub    $0x8,%esp
  800acb:	53                   	push   %ebx
  800acc:	6a 2d                	push   $0x2d
  800ace:	ff d6                	call   *%esi
				num = -(long long) num;
  800ad0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ad3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800ad6:	f7 da                	neg    %edx
  800ad8:	83 d1 00             	adc    $0x0,%ecx
  800adb:	f7 d9                	neg    %ecx
  800add:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800ae0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ae5:	e9 dd 00 00 00       	jmp    800bc7 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800aea:	8b 45 14             	mov    0x14(%ebp),%eax
  800aed:	8b 00                	mov    (%eax),%eax
  800aef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800af2:	99                   	cltd   
  800af3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800af6:	8b 45 14             	mov    0x14(%ebp),%eax
  800af9:	8d 40 04             	lea    0x4(%eax),%eax
  800afc:	89 45 14             	mov    %eax,0x14(%ebp)
  800aff:	eb b4                	jmp    800ab5 <vprintfmt+0x27a>
	if (lflag >= 2)
  800b01:	83 f9 01             	cmp    $0x1,%ecx
  800b04:	7f 1e                	jg     800b24 <vprintfmt+0x2e9>
	else if (lflag)
  800b06:	85 c9                	test   %ecx,%ecx
  800b08:	74 32                	je     800b3c <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800b0a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b0d:	8b 10                	mov    (%eax),%edx
  800b0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b14:	8d 40 04             	lea    0x4(%eax),%eax
  800b17:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b1a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800b1f:	e9 a3 00 00 00       	jmp    800bc7 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800b24:	8b 45 14             	mov    0x14(%ebp),%eax
  800b27:	8b 10                	mov    (%eax),%edx
  800b29:	8b 48 04             	mov    0x4(%eax),%ecx
  800b2c:	8d 40 08             	lea    0x8(%eax),%eax
  800b2f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b32:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800b37:	e9 8b 00 00 00       	jmp    800bc7 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800b3c:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3f:	8b 10                	mov    (%eax),%edx
  800b41:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b46:	8d 40 04             	lea    0x4(%eax),%eax
  800b49:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b4c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800b51:	eb 74                	jmp    800bc7 <vprintfmt+0x38c>
	if (lflag >= 2)
  800b53:	83 f9 01             	cmp    $0x1,%ecx
  800b56:	7f 1b                	jg     800b73 <vprintfmt+0x338>
	else if (lflag)
  800b58:	85 c9                	test   %ecx,%ecx
  800b5a:	74 2c                	je     800b88 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800b5c:	8b 45 14             	mov    0x14(%ebp),%eax
  800b5f:	8b 10                	mov    (%eax),%edx
  800b61:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b66:	8d 40 04             	lea    0x4(%eax),%eax
  800b69:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800b6c:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800b71:	eb 54                	jmp    800bc7 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800b73:	8b 45 14             	mov    0x14(%ebp),%eax
  800b76:	8b 10                	mov    (%eax),%edx
  800b78:	8b 48 04             	mov    0x4(%eax),%ecx
  800b7b:	8d 40 08             	lea    0x8(%eax),%eax
  800b7e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800b81:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800b86:	eb 3f                	jmp    800bc7 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800b88:	8b 45 14             	mov    0x14(%ebp),%eax
  800b8b:	8b 10                	mov    (%eax),%edx
  800b8d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b92:	8d 40 04             	lea    0x4(%eax),%eax
  800b95:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800b98:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800b9d:	eb 28                	jmp    800bc7 <vprintfmt+0x38c>
			putch('0', putdat);
  800b9f:	83 ec 08             	sub    $0x8,%esp
  800ba2:	53                   	push   %ebx
  800ba3:	6a 30                	push   $0x30
  800ba5:	ff d6                	call   *%esi
			putch('x', putdat);
  800ba7:	83 c4 08             	add    $0x8,%esp
  800baa:	53                   	push   %ebx
  800bab:	6a 78                	push   $0x78
  800bad:	ff d6                	call   *%esi
			num = (unsigned long long)
  800baf:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb2:	8b 10                	mov    (%eax),%edx
  800bb4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800bb9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800bbc:	8d 40 04             	lea    0x4(%eax),%eax
  800bbf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800bc2:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800bc7:	83 ec 0c             	sub    $0xc,%esp
  800bca:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800bce:	57                   	push   %edi
  800bcf:	ff 75 e0             	pushl  -0x20(%ebp)
  800bd2:	50                   	push   %eax
  800bd3:	51                   	push   %ecx
  800bd4:	52                   	push   %edx
  800bd5:	89 da                	mov    %ebx,%edx
  800bd7:	89 f0                	mov    %esi,%eax
  800bd9:	e8 72 fb ff ff       	call   800750 <printnum>
			break;
  800bde:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800be1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  800be4:	83 c7 01             	add    $0x1,%edi
  800be7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800beb:	83 f8 25             	cmp    $0x25,%eax
  800bee:	0f 84 62 fc ff ff    	je     800856 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  800bf4:	85 c0                	test   %eax,%eax
  800bf6:	0f 84 8b 00 00 00    	je     800c87 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  800bfc:	83 ec 08             	sub    $0x8,%esp
  800bff:	53                   	push   %ebx
  800c00:	50                   	push   %eax
  800c01:	ff d6                	call   *%esi
  800c03:	83 c4 10             	add    $0x10,%esp
  800c06:	eb dc                	jmp    800be4 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800c08:	83 f9 01             	cmp    $0x1,%ecx
  800c0b:	7f 1b                	jg     800c28 <vprintfmt+0x3ed>
	else if (lflag)
  800c0d:	85 c9                	test   %ecx,%ecx
  800c0f:	74 2c                	je     800c3d <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800c11:	8b 45 14             	mov    0x14(%ebp),%eax
  800c14:	8b 10                	mov    (%eax),%edx
  800c16:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c1b:	8d 40 04             	lea    0x4(%eax),%eax
  800c1e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c21:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800c26:	eb 9f                	jmp    800bc7 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800c28:	8b 45 14             	mov    0x14(%ebp),%eax
  800c2b:	8b 10                	mov    (%eax),%edx
  800c2d:	8b 48 04             	mov    0x4(%eax),%ecx
  800c30:	8d 40 08             	lea    0x8(%eax),%eax
  800c33:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c36:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800c3b:	eb 8a                	jmp    800bc7 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800c3d:	8b 45 14             	mov    0x14(%ebp),%eax
  800c40:	8b 10                	mov    (%eax),%edx
  800c42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c47:	8d 40 04             	lea    0x4(%eax),%eax
  800c4a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c4d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800c52:	e9 70 ff ff ff       	jmp    800bc7 <vprintfmt+0x38c>
			putch(ch, putdat);
  800c57:	83 ec 08             	sub    $0x8,%esp
  800c5a:	53                   	push   %ebx
  800c5b:	6a 25                	push   $0x25
  800c5d:	ff d6                	call   *%esi
			break;
  800c5f:	83 c4 10             	add    $0x10,%esp
  800c62:	e9 7a ff ff ff       	jmp    800be1 <vprintfmt+0x3a6>
			putch('%', putdat);
  800c67:	83 ec 08             	sub    $0x8,%esp
  800c6a:	53                   	push   %ebx
  800c6b:	6a 25                	push   $0x25
  800c6d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800c6f:	83 c4 10             	add    $0x10,%esp
  800c72:	89 f8                	mov    %edi,%eax
  800c74:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800c78:	74 05                	je     800c7f <vprintfmt+0x444>
  800c7a:	83 e8 01             	sub    $0x1,%eax
  800c7d:	eb f5                	jmp    800c74 <vprintfmt+0x439>
  800c7f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c82:	e9 5a ff ff ff       	jmp    800be1 <vprintfmt+0x3a6>
}
  800c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c8f:	f3 0f 1e fb          	endbr32 
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	83 ec 18             	sub    $0x18,%esp
  800c99:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c9f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ca2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ca6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ca9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cb0:	85 c0                	test   %eax,%eax
  800cb2:	74 26                	je     800cda <vsnprintf+0x4b>
  800cb4:	85 d2                	test   %edx,%edx
  800cb6:	7e 22                	jle    800cda <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cb8:	ff 75 14             	pushl  0x14(%ebp)
  800cbb:	ff 75 10             	pushl  0x10(%ebp)
  800cbe:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cc1:	50                   	push   %eax
  800cc2:	68 f9 07 80 00       	push   $0x8007f9
  800cc7:	e8 6f fb ff ff       	call   80083b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ccc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ccf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd5:	83 c4 10             	add    $0x10,%esp
}
  800cd8:	c9                   	leave  
  800cd9:	c3                   	ret    
		return -E_INVAL;
  800cda:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800cdf:	eb f7                	jmp    800cd8 <vsnprintf+0x49>

00800ce1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ce1:	f3 0f 1e fb          	endbr32 
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  800ceb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cee:	50                   	push   %eax
  800cef:	ff 75 10             	pushl  0x10(%ebp)
  800cf2:	ff 75 0c             	pushl  0xc(%ebp)
  800cf5:	ff 75 08             	pushl  0x8(%ebp)
  800cf8:	e8 92 ff ff ff       	call   800c8f <vsnprintf>
	va_end(ap);

	return rc;
}
  800cfd:	c9                   	leave  
  800cfe:	c3                   	ret    

00800cff <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cff:	f3 0f 1e fb          	endbr32 
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d09:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d12:	74 05                	je     800d19 <strlen+0x1a>
		n++;
  800d14:	83 c0 01             	add    $0x1,%eax
  800d17:	eb f5                	jmp    800d0e <strlen+0xf>
	return n;
}
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d1b:	f3 0f 1e fb          	endbr32 
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d25:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d28:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2d:	39 d0                	cmp    %edx,%eax
  800d2f:	74 0d                	je     800d3e <strnlen+0x23>
  800d31:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d35:	74 05                	je     800d3c <strnlen+0x21>
		n++;
  800d37:	83 c0 01             	add    $0x1,%eax
  800d3a:	eb f1                	jmp    800d2d <strnlen+0x12>
  800d3c:	89 c2                	mov    %eax,%edx
	return n;
}
  800d3e:	89 d0                	mov    %edx,%eax
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d42:	f3 0f 1e fb          	endbr32 
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	53                   	push   %ebx
  800d4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d50:	b8 00 00 00 00       	mov    $0x0,%eax
  800d55:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800d59:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800d5c:	83 c0 01             	add    $0x1,%eax
  800d5f:	84 d2                	test   %dl,%dl
  800d61:	75 f2                	jne    800d55 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800d63:	89 c8                	mov    %ecx,%eax
  800d65:	5b                   	pop    %ebx
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d68:	f3 0f 1e fb          	endbr32 
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	53                   	push   %ebx
  800d70:	83 ec 10             	sub    $0x10,%esp
  800d73:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d76:	53                   	push   %ebx
  800d77:	e8 83 ff ff ff       	call   800cff <strlen>
  800d7c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800d7f:	ff 75 0c             	pushl  0xc(%ebp)
  800d82:	01 d8                	add    %ebx,%eax
  800d84:	50                   	push   %eax
  800d85:	e8 b8 ff ff ff       	call   800d42 <strcpy>
	return dst;
}
  800d8a:	89 d8                	mov    %ebx,%eax
  800d8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d8f:	c9                   	leave  
  800d90:	c3                   	ret    

00800d91 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d91:	f3 0f 1e fb          	endbr32 
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	56                   	push   %esi
  800d99:	53                   	push   %ebx
  800d9a:	8b 75 08             	mov    0x8(%ebp),%esi
  800d9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da0:	89 f3                	mov    %esi,%ebx
  800da2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800da5:	89 f0                	mov    %esi,%eax
  800da7:	39 d8                	cmp    %ebx,%eax
  800da9:	74 11                	je     800dbc <strncpy+0x2b>
		*dst++ = *src;
  800dab:	83 c0 01             	add    $0x1,%eax
  800dae:	0f b6 0a             	movzbl (%edx),%ecx
  800db1:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800db4:	80 f9 01             	cmp    $0x1,%cl
  800db7:	83 da ff             	sbb    $0xffffffff,%edx
  800dba:	eb eb                	jmp    800da7 <strncpy+0x16>
	}
	return ret;
}
  800dbc:	89 f0                	mov    %esi,%eax
  800dbe:	5b                   	pop    %ebx
  800dbf:	5e                   	pop    %esi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dc2:	f3 0f 1e fb          	endbr32 
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	56                   	push   %esi
  800dca:	53                   	push   %ebx
  800dcb:	8b 75 08             	mov    0x8(%ebp),%esi
  800dce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd1:	8b 55 10             	mov    0x10(%ebp),%edx
  800dd4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800dd6:	85 d2                	test   %edx,%edx
  800dd8:	74 21                	je     800dfb <strlcpy+0x39>
  800dda:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800dde:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800de0:	39 c2                	cmp    %eax,%edx
  800de2:	74 14                	je     800df8 <strlcpy+0x36>
  800de4:	0f b6 19             	movzbl (%ecx),%ebx
  800de7:	84 db                	test   %bl,%bl
  800de9:	74 0b                	je     800df6 <strlcpy+0x34>
			*dst++ = *src++;
  800deb:	83 c1 01             	add    $0x1,%ecx
  800dee:	83 c2 01             	add    $0x1,%edx
  800df1:	88 5a ff             	mov    %bl,-0x1(%edx)
  800df4:	eb ea                	jmp    800de0 <strlcpy+0x1e>
  800df6:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800df8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800dfb:	29 f0                	sub    %esi,%eax
}
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e01:	f3 0f 1e fb          	endbr32 
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e0e:	0f b6 01             	movzbl (%ecx),%eax
  800e11:	84 c0                	test   %al,%al
  800e13:	74 0c                	je     800e21 <strcmp+0x20>
  800e15:	3a 02                	cmp    (%edx),%al
  800e17:	75 08                	jne    800e21 <strcmp+0x20>
		p++, q++;
  800e19:	83 c1 01             	add    $0x1,%ecx
  800e1c:	83 c2 01             	add    $0x1,%edx
  800e1f:	eb ed                	jmp    800e0e <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e21:	0f b6 c0             	movzbl %al,%eax
  800e24:	0f b6 12             	movzbl (%edx),%edx
  800e27:	29 d0                	sub    %edx,%eax
}
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e2b:	f3 0f 1e fb          	endbr32 
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	53                   	push   %ebx
  800e33:	8b 45 08             	mov    0x8(%ebp),%eax
  800e36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e39:	89 c3                	mov    %eax,%ebx
  800e3b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e3e:	eb 06                	jmp    800e46 <strncmp+0x1b>
		n--, p++, q++;
  800e40:	83 c0 01             	add    $0x1,%eax
  800e43:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800e46:	39 d8                	cmp    %ebx,%eax
  800e48:	74 16                	je     800e60 <strncmp+0x35>
  800e4a:	0f b6 08             	movzbl (%eax),%ecx
  800e4d:	84 c9                	test   %cl,%cl
  800e4f:	74 04                	je     800e55 <strncmp+0x2a>
  800e51:	3a 0a                	cmp    (%edx),%cl
  800e53:	74 eb                	je     800e40 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e55:	0f b6 00             	movzbl (%eax),%eax
  800e58:	0f b6 12             	movzbl (%edx),%edx
  800e5b:	29 d0                	sub    %edx,%eax
}
  800e5d:	5b                   	pop    %ebx
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    
		return 0;
  800e60:	b8 00 00 00 00       	mov    $0x0,%eax
  800e65:	eb f6                	jmp    800e5d <strncmp+0x32>

00800e67 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e67:	f3 0f 1e fb          	endbr32 
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e75:	0f b6 10             	movzbl (%eax),%edx
  800e78:	84 d2                	test   %dl,%dl
  800e7a:	74 09                	je     800e85 <strchr+0x1e>
		if (*s == c)
  800e7c:	38 ca                	cmp    %cl,%dl
  800e7e:	74 0a                	je     800e8a <strchr+0x23>
	for (; *s; s++)
  800e80:	83 c0 01             	add    $0x1,%eax
  800e83:	eb f0                	jmp    800e75 <strchr+0xe>
			return (char *) s;
	return 0;
  800e85:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800e8c:	f3 0f 1e fb          	endbr32 
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800e96:	6a 78                	push   $0x78
  800e98:	ff 75 08             	pushl  0x8(%ebp)
  800e9b:	e8 c7 ff ff ff       	call   800e67 <strchr>
  800ea0:	83 c4 10             	add    $0x10,%esp
  800ea3:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  800ea6:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800eab:	eb 0d                	jmp    800eba <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800ead:	c1 e0 04             	shl    $0x4,%eax
  800eb0:	0f be d2             	movsbl %dl,%edx
  800eb3:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800eb7:	83 c1 01             	add    $0x1,%ecx
  800eba:	0f b6 11             	movzbl (%ecx),%edx
  800ebd:	84 d2                	test   %dl,%dl
  800ebf:	74 11                	je     800ed2 <atox+0x46>
		if (*p>='a'){
  800ec1:	80 fa 60             	cmp    $0x60,%dl
  800ec4:	7e e7                	jle    800ead <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800ec6:	c1 e0 04             	shl    $0x4,%eax
  800ec9:	0f be d2             	movsbl %dl,%edx
  800ecc:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800ed0:	eb e5                	jmp    800eb7 <atox+0x2b>
	}

	return v;

}
  800ed2:	c9                   	leave  
  800ed3:	c3                   	ret    

00800ed4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ed4:	f3 0f 1e fb          	endbr32 
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ede:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ee2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ee5:	38 ca                	cmp    %cl,%dl
  800ee7:	74 09                	je     800ef2 <strfind+0x1e>
  800ee9:	84 d2                	test   %dl,%dl
  800eeb:	74 05                	je     800ef2 <strfind+0x1e>
	for (; *s; s++)
  800eed:	83 c0 01             	add    $0x1,%eax
  800ef0:	eb f0                	jmp    800ee2 <strfind+0xe>
			break;
	return (char *) s;
}
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ef4:	f3 0f 1e fb          	endbr32 
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	57                   	push   %edi
  800efc:	56                   	push   %esi
  800efd:	53                   	push   %ebx
  800efe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f01:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f04:	85 c9                	test   %ecx,%ecx
  800f06:	74 31                	je     800f39 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f08:	89 f8                	mov    %edi,%eax
  800f0a:	09 c8                	or     %ecx,%eax
  800f0c:	a8 03                	test   $0x3,%al
  800f0e:	75 23                	jne    800f33 <memset+0x3f>
		c &= 0xFF;
  800f10:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f14:	89 d3                	mov    %edx,%ebx
  800f16:	c1 e3 08             	shl    $0x8,%ebx
  800f19:	89 d0                	mov    %edx,%eax
  800f1b:	c1 e0 18             	shl    $0x18,%eax
  800f1e:	89 d6                	mov    %edx,%esi
  800f20:	c1 e6 10             	shl    $0x10,%esi
  800f23:	09 f0                	or     %esi,%eax
  800f25:	09 c2                	or     %eax,%edx
  800f27:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800f29:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800f2c:	89 d0                	mov    %edx,%eax
  800f2e:	fc                   	cld    
  800f2f:	f3 ab                	rep stos %eax,%es:(%edi)
  800f31:	eb 06                	jmp    800f39 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f36:	fc                   	cld    
  800f37:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f39:	89 f8                	mov    %edi,%eax
  800f3b:	5b                   	pop    %ebx
  800f3c:	5e                   	pop    %esi
  800f3d:	5f                   	pop    %edi
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f40:	f3 0f 1e fb          	endbr32 
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	57                   	push   %edi
  800f48:	56                   	push   %esi
  800f49:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f52:	39 c6                	cmp    %eax,%esi
  800f54:	73 32                	jae    800f88 <memmove+0x48>
  800f56:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f59:	39 c2                	cmp    %eax,%edx
  800f5b:	76 2b                	jbe    800f88 <memmove+0x48>
		s += n;
		d += n;
  800f5d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f60:	89 fe                	mov    %edi,%esi
  800f62:	09 ce                	or     %ecx,%esi
  800f64:	09 d6                	or     %edx,%esi
  800f66:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f6c:	75 0e                	jne    800f7c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f6e:	83 ef 04             	sub    $0x4,%edi
  800f71:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f74:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800f77:	fd                   	std    
  800f78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f7a:	eb 09                	jmp    800f85 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f7c:	83 ef 01             	sub    $0x1,%edi
  800f7f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800f82:	fd                   	std    
  800f83:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f85:	fc                   	cld    
  800f86:	eb 1a                	jmp    800fa2 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f88:	89 c2                	mov    %eax,%edx
  800f8a:	09 ca                	or     %ecx,%edx
  800f8c:	09 f2                	or     %esi,%edx
  800f8e:	f6 c2 03             	test   $0x3,%dl
  800f91:	75 0a                	jne    800f9d <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f93:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800f96:	89 c7                	mov    %eax,%edi
  800f98:	fc                   	cld    
  800f99:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f9b:	eb 05                	jmp    800fa2 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800f9d:	89 c7                	mov    %eax,%edi
  800f9f:	fc                   	cld    
  800fa0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fa2:	5e                   	pop    %esi
  800fa3:	5f                   	pop    %edi
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    

00800fa6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800fa6:	f3 0f 1e fb          	endbr32 
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800fb0:	ff 75 10             	pushl  0x10(%ebp)
  800fb3:	ff 75 0c             	pushl  0xc(%ebp)
  800fb6:	ff 75 08             	pushl  0x8(%ebp)
  800fb9:	e8 82 ff ff ff       	call   800f40 <memmove>
}
  800fbe:	c9                   	leave  
  800fbf:	c3                   	ret    

00800fc0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fc0:	f3 0f 1e fb          	endbr32 
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	56                   	push   %esi
  800fc8:	53                   	push   %ebx
  800fc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fcf:	89 c6                	mov    %eax,%esi
  800fd1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fd4:	39 f0                	cmp    %esi,%eax
  800fd6:	74 1c                	je     800ff4 <memcmp+0x34>
		if (*s1 != *s2)
  800fd8:	0f b6 08             	movzbl (%eax),%ecx
  800fdb:	0f b6 1a             	movzbl (%edx),%ebx
  800fde:	38 d9                	cmp    %bl,%cl
  800fe0:	75 08                	jne    800fea <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800fe2:	83 c0 01             	add    $0x1,%eax
  800fe5:	83 c2 01             	add    $0x1,%edx
  800fe8:	eb ea                	jmp    800fd4 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800fea:	0f b6 c1             	movzbl %cl,%eax
  800fed:	0f b6 db             	movzbl %bl,%ebx
  800ff0:	29 d8                	sub    %ebx,%eax
  800ff2:	eb 05                	jmp    800ff9 <memcmp+0x39>
	}

	return 0;
  800ff4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ff9:	5b                   	pop    %ebx
  800ffa:	5e                   	pop    %esi
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    

00800ffd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ffd:	f3 0f 1e fb          	endbr32 
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	8b 45 08             	mov    0x8(%ebp),%eax
  801007:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80100a:	89 c2                	mov    %eax,%edx
  80100c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80100f:	39 d0                	cmp    %edx,%eax
  801011:	73 09                	jae    80101c <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801013:	38 08                	cmp    %cl,(%eax)
  801015:	74 05                	je     80101c <memfind+0x1f>
	for (; s < ends; s++)
  801017:	83 c0 01             	add    $0x1,%eax
  80101a:	eb f3                	jmp    80100f <memfind+0x12>
			break;
	return (void *) s;
}
  80101c:	5d                   	pop    %ebp
  80101d:	c3                   	ret    

0080101e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80101e:	f3 0f 1e fb          	endbr32 
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	57                   	push   %edi
  801026:	56                   	push   %esi
  801027:	53                   	push   %ebx
  801028:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80102b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80102e:	eb 03                	jmp    801033 <strtol+0x15>
		s++;
  801030:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801033:	0f b6 01             	movzbl (%ecx),%eax
  801036:	3c 20                	cmp    $0x20,%al
  801038:	74 f6                	je     801030 <strtol+0x12>
  80103a:	3c 09                	cmp    $0x9,%al
  80103c:	74 f2                	je     801030 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  80103e:	3c 2b                	cmp    $0x2b,%al
  801040:	74 2a                	je     80106c <strtol+0x4e>
	int neg = 0;
  801042:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801047:	3c 2d                	cmp    $0x2d,%al
  801049:	74 2b                	je     801076 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80104b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801051:	75 0f                	jne    801062 <strtol+0x44>
  801053:	80 39 30             	cmpb   $0x30,(%ecx)
  801056:	74 28                	je     801080 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801058:	85 db                	test   %ebx,%ebx
  80105a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80105f:	0f 44 d8             	cmove  %eax,%ebx
  801062:	b8 00 00 00 00       	mov    $0x0,%eax
  801067:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80106a:	eb 46                	jmp    8010b2 <strtol+0x94>
		s++;
  80106c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  80106f:	bf 00 00 00 00       	mov    $0x0,%edi
  801074:	eb d5                	jmp    80104b <strtol+0x2d>
		s++, neg = 1;
  801076:	83 c1 01             	add    $0x1,%ecx
  801079:	bf 01 00 00 00       	mov    $0x1,%edi
  80107e:	eb cb                	jmp    80104b <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801080:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801084:	74 0e                	je     801094 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801086:	85 db                	test   %ebx,%ebx
  801088:	75 d8                	jne    801062 <strtol+0x44>
		s++, base = 8;
  80108a:	83 c1 01             	add    $0x1,%ecx
  80108d:	bb 08 00 00 00       	mov    $0x8,%ebx
  801092:	eb ce                	jmp    801062 <strtol+0x44>
		s += 2, base = 16;
  801094:	83 c1 02             	add    $0x2,%ecx
  801097:	bb 10 00 00 00       	mov    $0x10,%ebx
  80109c:	eb c4                	jmp    801062 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  80109e:	0f be d2             	movsbl %dl,%edx
  8010a1:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8010a4:	3b 55 10             	cmp    0x10(%ebp),%edx
  8010a7:	7d 3a                	jge    8010e3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8010a9:	83 c1 01             	add    $0x1,%ecx
  8010ac:	0f af 45 10          	imul   0x10(%ebp),%eax
  8010b0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8010b2:	0f b6 11             	movzbl (%ecx),%edx
  8010b5:	8d 72 d0             	lea    -0x30(%edx),%esi
  8010b8:	89 f3                	mov    %esi,%ebx
  8010ba:	80 fb 09             	cmp    $0x9,%bl
  8010bd:	76 df                	jbe    80109e <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  8010bf:	8d 72 9f             	lea    -0x61(%edx),%esi
  8010c2:	89 f3                	mov    %esi,%ebx
  8010c4:	80 fb 19             	cmp    $0x19,%bl
  8010c7:	77 08                	ja     8010d1 <strtol+0xb3>
			dig = *s - 'a' + 10;
  8010c9:	0f be d2             	movsbl %dl,%edx
  8010cc:	83 ea 57             	sub    $0x57,%edx
  8010cf:	eb d3                	jmp    8010a4 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  8010d1:	8d 72 bf             	lea    -0x41(%edx),%esi
  8010d4:	89 f3                	mov    %esi,%ebx
  8010d6:	80 fb 19             	cmp    $0x19,%bl
  8010d9:	77 08                	ja     8010e3 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8010db:	0f be d2             	movsbl %dl,%edx
  8010de:	83 ea 37             	sub    $0x37,%edx
  8010e1:	eb c1                	jmp    8010a4 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  8010e3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010e7:	74 05                	je     8010ee <strtol+0xd0>
		*endptr = (char *) s;
  8010e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010ec:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8010ee:	89 c2                	mov    %eax,%edx
  8010f0:	f7 da                	neg    %edx
  8010f2:	85 ff                	test   %edi,%edi
  8010f4:	0f 45 c2             	cmovne %edx,%eax
}
  8010f7:	5b                   	pop    %ebx
  8010f8:	5e                   	pop    %esi
  8010f9:	5f                   	pop    %edi
  8010fa:	5d                   	pop    %ebp
  8010fb:	c3                   	ret    

008010fc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010fc:	f3 0f 1e fb          	endbr32 
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	57                   	push   %edi
  801104:	56                   	push   %esi
  801105:	53                   	push   %ebx
	asm volatile("int %1\n"
  801106:	b8 00 00 00 00       	mov    $0x0,%eax
  80110b:	8b 55 08             	mov    0x8(%ebp),%edx
  80110e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801111:	89 c3                	mov    %eax,%ebx
  801113:	89 c7                	mov    %eax,%edi
  801115:	89 c6                	mov    %eax,%esi
  801117:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801119:	5b                   	pop    %ebx
  80111a:	5e                   	pop    %esi
  80111b:	5f                   	pop    %edi
  80111c:	5d                   	pop    %ebp
  80111d:	c3                   	ret    

0080111e <sys_cgetc>:

int
sys_cgetc(void)
{
  80111e:	f3 0f 1e fb          	endbr32 
  801122:	55                   	push   %ebp
  801123:	89 e5                	mov    %esp,%ebp
  801125:	57                   	push   %edi
  801126:	56                   	push   %esi
  801127:	53                   	push   %ebx
	asm volatile("int %1\n"
  801128:	ba 00 00 00 00       	mov    $0x0,%edx
  80112d:	b8 01 00 00 00       	mov    $0x1,%eax
  801132:	89 d1                	mov    %edx,%ecx
  801134:	89 d3                	mov    %edx,%ebx
  801136:	89 d7                	mov    %edx,%edi
  801138:	89 d6                	mov    %edx,%esi
  80113a:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80113c:	5b                   	pop    %ebx
  80113d:	5e                   	pop    %esi
  80113e:	5f                   	pop    %edi
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    

00801141 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801141:	f3 0f 1e fb          	endbr32 
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	57                   	push   %edi
  801149:	56                   	push   %esi
  80114a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80114b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801150:	8b 55 08             	mov    0x8(%ebp),%edx
  801153:	b8 03 00 00 00       	mov    $0x3,%eax
  801158:	89 cb                	mov    %ecx,%ebx
  80115a:	89 cf                	mov    %ecx,%edi
  80115c:	89 ce                	mov    %ecx,%esi
  80115e:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801160:	5b                   	pop    %ebx
  801161:	5e                   	pop    %esi
  801162:	5f                   	pop    %edi
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    

00801165 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801165:	f3 0f 1e fb          	endbr32 
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	57                   	push   %edi
  80116d:	56                   	push   %esi
  80116e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80116f:	ba 00 00 00 00       	mov    $0x0,%edx
  801174:	b8 02 00 00 00       	mov    $0x2,%eax
  801179:	89 d1                	mov    %edx,%ecx
  80117b:	89 d3                	mov    %edx,%ebx
  80117d:	89 d7                	mov    %edx,%edi
  80117f:	89 d6                	mov    %edx,%esi
  801181:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801183:	5b                   	pop    %ebx
  801184:	5e                   	pop    %esi
  801185:	5f                   	pop    %edi
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    

00801188 <sys_yield>:

void
sys_yield(void)
{
  801188:	f3 0f 1e fb          	endbr32 
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	57                   	push   %edi
  801190:	56                   	push   %esi
  801191:	53                   	push   %ebx
	asm volatile("int %1\n"
  801192:	ba 00 00 00 00       	mov    $0x0,%edx
  801197:	b8 0b 00 00 00       	mov    $0xb,%eax
  80119c:	89 d1                	mov    %edx,%ecx
  80119e:	89 d3                	mov    %edx,%ebx
  8011a0:	89 d7                	mov    %edx,%edi
  8011a2:	89 d6                	mov    %edx,%esi
  8011a4:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8011a6:	5b                   	pop    %ebx
  8011a7:	5e                   	pop    %esi
  8011a8:	5f                   	pop    %edi
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    

008011ab <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8011ab:	f3 0f 1e fb          	endbr32 
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	57                   	push   %edi
  8011b3:	56                   	push   %esi
  8011b4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011b5:	be 00 00 00 00       	mov    $0x0,%esi
  8011ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8011bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c0:	b8 04 00 00 00       	mov    $0x4,%eax
  8011c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011c8:	89 f7                	mov    %esi,%edi
  8011ca:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011cc:	5b                   	pop    %ebx
  8011cd:	5e                   	pop    %esi
  8011ce:	5f                   	pop    %edi
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    

008011d1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011d1:	f3 0f 1e fb          	endbr32 
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	57                   	push   %edi
  8011d9:	56                   	push   %esi
  8011da:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011db:	8b 55 08             	mov    0x8(%ebp),%edx
  8011de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e1:	b8 05 00 00 00       	mov    $0x5,%eax
  8011e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011e9:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011ec:	8b 75 18             	mov    0x18(%ebp),%esi
  8011ef:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8011f1:	5b                   	pop    %ebx
  8011f2:	5e                   	pop    %esi
  8011f3:	5f                   	pop    %edi
  8011f4:	5d                   	pop    %ebp
  8011f5:	c3                   	ret    

008011f6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8011f6:	f3 0f 1e fb          	endbr32 
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	57                   	push   %edi
  8011fe:	56                   	push   %esi
  8011ff:	53                   	push   %ebx
	asm volatile("int %1\n"
  801200:	bb 00 00 00 00       	mov    $0x0,%ebx
  801205:	8b 55 08             	mov    0x8(%ebp),%edx
  801208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120b:	b8 06 00 00 00       	mov    $0x6,%eax
  801210:	89 df                	mov    %ebx,%edi
  801212:	89 de                	mov    %ebx,%esi
  801214:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801216:	5b                   	pop    %ebx
  801217:	5e                   	pop    %esi
  801218:	5f                   	pop    %edi
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    

0080121b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80121b:	f3 0f 1e fb          	endbr32 
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	57                   	push   %edi
  801223:	56                   	push   %esi
  801224:	53                   	push   %ebx
	asm volatile("int %1\n"
  801225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80122a:	8b 55 08             	mov    0x8(%ebp),%edx
  80122d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801230:	b8 08 00 00 00       	mov    $0x8,%eax
  801235:	89 df                	mov    %ebx,%edi
  801237:	89 de                	mov    %ebx,%esi
  801239:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80123b:	5b                   	pop    %ebx
  80123c:	5e                   	pop    %esi
  80123d:	5f                   	pop    %edi
  80123e:	5d                   	pop    %ebp
  80123f:	c3                   	ret    

00801240 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801240:	f3 0f 1e fb          	endbr32 
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	57                   	push   %edi
  801248:	56                   	push   %esi
  801249:	53                   	push   %ebx
	asm volatile("int %1\n"
  80124a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124f:	8b 55 08             	mov    0x8(%ebp),%edx
  801252:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801255:	b8 09 00 00 00       	mov    $0x9,%eax
  80125a:	89 df                	mov    %ebx,%edi
  80125c:	89 de                	mov    %ebx,%esi
  80125e:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801260:	5b                   	pop    %ebx
  801261:	5e                   	pop    %esi
  801262:	5f                   	pop    %edi
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    

00801265 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801265:	f3 0f 1e fb          	endbr32 
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
  80126c:	57                   	push   %edi
  80126d:	56                   	push   %esi
  80126e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80126f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801274:	8b 55 08             	mov    0x8(%ebp),%edx
  801277:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80127a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80127f:	89 df                	mov    %ebx,%edi
  801281:	89 de                	mov    %ebx,%esi
  801283:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801285:	5b                   	pop    %ebx
  801286:	5e                   	pop    %esi
  801287:	5f                   	pop    %edi
  801288:	5d                   	pop    %ebp
  801289:	c3                   	ret    

0080128a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80128a:	f3 0f 1e fb          	endbr32 
  80128e:	55                   	push   %ebp
  80128f:	89 e5                	mov    %esp,%ebp
  801291:	57                   	push   %edi
  801292:	56                   	push   %esi
  801293:	53                   	push   %ebx
	asm volatile("int %1\n"
  801294:	8b 55 08             	mov    0x8(%ebp),%edx
  801297:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80129a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80129f:	be 00 00 00 00       	mov    $0x0,%esi
  8012a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012a7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012aa:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012ac:	5b                   	pop    %ebx
  8012ad:	5e                   	pop    %esi
  8012ae:	5f                   	pop    %edi
  8012af:	5d                   	pop    %ebp
  8012b0:	c3                   	ret    

008012b1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012b1:	f3 0f 1e fb          	endbr32 
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	57                   	push   %edi
  8012b9:	56                   	push   %esi
  8012ba:	53                   	push   %ebx
	asm volatile("int %1\n"
  8012bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c3:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012c8:	89 cb                	mov    %ecx,%ebx
  8012ca:	89 cf                	mov    %ecx,%edi
  8012cc:	89 ce                	mov    %ecx,%esi
  8012ce:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012d0:	5b                   	pop    %ebx
  8012d1:	5e                   	pop    %esi
  8012d2:	5f                   	pop    %edi
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    

008012d5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8012d5:	f3 0f 1e fb          	endbr32 
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	57                   	push   %edi
  8012dd:	56                   	push   %esi
  8012de:	53                   	push   %ebx
	asm volatile("int %1\n"
  8012df:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e4:	b8 0e 00 00 00       	mov    $0xe,%eax
  8012e9:	89 d1                	mov    %edx,%ecx
  8012eb:	89 d3                	mov    %edx,%ebx
  8012ed:	89 d7                	mov    %edx,%edi
  8012ef:	89 d6                	mov    %edx,%esi
  8012f1:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8012f3:	5b                   	pop    %ebx
  8012f4:	5e                   	pop    %esi
  8012f5:	5f                   	pop    %edi
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    

008012f8 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  8012f8:	f3 0f 1e fb          	endbr32 
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	57                   	push   %edi
  801300:	56                   	push   %esi
  801301:	53                   	push   %ebx
	asm volatile("int %1\n"
  801302:	bb 00 00 00 00       	mov    $0x0,%ebx
  801307:	8b 55 08             	mov    0x8(%ebp),%edx
  80130a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80130d:	b8 0f 00 00 00       	mov    $0xf,%eax
  801312:	89 df                	mov    %ebx,%edi
  801314:	89 de                	mov    %ebx,%esi
  801316:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  801318:	5b                   	pop    %ebx
  801319:	5e                   	pop    %esi
  80131a:	5f                   	pop    %edi
  80131b:	5d                   	pop    %ebp
  80131c:	c3                   	ret    

0080131d <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  80131d:	f3 0f 1e fb          	endbr32 
  801321:	55                   	push   %ebp
  801322:	89 e5                	mov    %esp,%ebp
  801324:	57                   	push   %edi
  801325:	56                   	push   %esi
  801326:	53                   	push   %ebx
	asm volatile("int %1\n"
  801327:	bb 00 00 00 00       	mov    $0x0,%ebx
  80132c:	8b 55 08             	mov    0x8(%ebp),%edx
  80132f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801332:	b8 10 00 00 00       	mov    $0x10,%eax
  801337:	89 df                	mov    %ebx,%edi
  801339:	89 de                	mov    %ebx,%esi
  80133b:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  80133d:	5b                   	pop    %ebx
  80133e:	5e                   	pop    %esi
  80133f:	5f                   	pop    %edi
  801340:	5d                   	pop    %ebp
  801341:	c3                   	ret    

00801342 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801342:	f3 0f 1e fb          	endbr32 
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80134c:	83 3d b8 40 80 00 00 	cmpl   $0x0,0x8040b8
  801353:	74 0a                	je     80135f <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801355:	8b 45 08             	mov    0x8(%ebp),%eax
  801358:	a3 b8 40 80 00       	mov    %eax,0x8040b8

}
  80135d:	c9                   	leave  
  80135e:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  80135f:	83 ec 04             	sub    $0x4,%esp
  801362:	6a 07                	push   $0x7
  801364:	68 00 f0 bf ee       	push   $0xeebff000
  801369:	6a 00                	push   $0x0
  80136b:	e8 3b fe ff ff       	call   8011ab <sys_page_alloc>
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	85 c0                	test   %eax,%eax
  801375:	78 2a                	js     8013a1 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  801377:	83 ec 08             	sub    $0x8,%esp
  80137a:	68 b5 13 80 00       	push   $0x8013b5
  80137f:	6a 00                	push   $0x0
  801381:	e8 df fe ff ff       	call   801265 <sys_env_set_pgfault_upcall>
  801386:	83 c4 10             	add    $0x10,%esp
  801389:	85 c0                	test   %eax,%eax
  80138b:	79 c8                	jns    801355 <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  80138d:	83 ec 04             	sub    $0x4,%esp
  801390:	68 0c 2e 80 00       	push   $0x802e0c
  801395:	6a 2c                	push   $0x2c
  801397:	68 42 2e 80 00       	push   $0x802e42
  80139c:	e8 b0 f2 ff ff       	call   800651 <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  8013a1:	83 ec 04             	sub    $0x4,%esp
  8013a4:	68 e0 2d 80 00       	push   $0x802de0
  8013a9:	6a 22                	push   $0x22
  8013ab:	68 42 2e 80 00       	push   $0x802e42
  8013b0:	e8 9c f2 ff ff       	call   800651 <_panic>

008013b5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8013b5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8013b6:	a1 b8 40 80 00       	mov    0x8040b8,%eax
	call *%eax   			// 间接寻址
  8013bb:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8013bd:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  8013c0:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  8013c4:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  8013c9:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  8013cd:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  8013cf:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  8013d2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  8013d3:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  8013d6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  8013d7:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  8013d8:	c3                   	ret    

008013d9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013d9:	f3 0f 1e fb          	endbr32 
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e3:	05 00 00 00 30       	add    $0x30000000,%eax
  8013e8:	c1 e8 0c             	shr    $0xc,%eax
}
  8013eb:	5d                   	pop    %ebp
  8013ec:	c3                   	ret    

008013ed <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013ed:	f3 0f 1e fb          	endbr32 
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f7:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8013fc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801401:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801406:	5d                   	pop    %ebp
  801407:	c3                   	ret    

00801408 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801408:	f3 0f 1e fb          	endbr32 
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801414:	89 c2                	mov    %eax,%edx
  801416:	c1 ea 16             	shr    $0x16,%edx
  801419:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801420:	f6 c2 01             	test   $0x1,%dl
  801423:	74 2d                	je     801452 <fd_alloc+0x4a>
  801425:	89 c2                	mov    %eax,%edx
  801427:	c1 ea 0c             	shr    $0xc,%edx
  80142a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801431:	f6 c2 01             	test   $0x1,%dl
  801434:	74 1c                	je     801452 <fd_alloc+0x4a>
  801436:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80143b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801440:	75 d2                	jne    801414 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  801442:	8b 45 08             	mov    0x8(%ebp),%eax
  801445:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80144b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801450:	eb 0a                	jmp    80145c <fd_alloc+0x54>
			*fd_store = fd;
  801452:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801455:	89 01                	mov    %eax,(%ecx)
			return 0;
  801457:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80145c:	5d                   	pop    %ebp
  80145d:	c3                   	ret    

0080145e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80145e:	f3 0f 1e fb          	endbr32 
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801468:	83 f8 1f             	cmp    $0x1f,%eax
  80146b:	77 30                	ja     80149d <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80146d:	c1 e0 0c             	shl    $0xc,%eax
  801470:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801475:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80147b:	f6 c2 01             	test   $0x1,%dl
  80147e:	74 24                	je     8014a4 <fd_lookup+0x46>
  801480:	89 c2                	mov    %eax,%edx
  801482:	c1 ea 0c             	shr    $0xc,%edx
  801485:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80148c:	f6 c2 01             	test   $0x1,%dl
  80148f:	74 1a                	je     8014ab <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801491:	8b 55 0c             	mov    0xc(%ebp),%edx
  801494:	89 02                	mov    %eax,(%edx)
	return 0;
  801496:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80149b:	5d                   	pop    %ebp
  80149c:	c3                   	ret    
		return -E_INVAL;
  80149d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a2:	eb f7                	jmp    80149b <fd_lookup+0x3d>
		return -E_INVAL;
  8014a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a9:	eb f0                	jmp    80149b <fd_lookup+0x3d>
  8014ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014b0:	eb e9                	jmp    80149b <fd_lookup+0x3d>

008014b2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014b2:	f3 0f 1e fb          	endbr32 
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	83 ec 08             	sub    $0x8,%esp
  8014bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8014bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c4:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  8014c9:	39 08                	cmp    %ecx,(%eax)
  8014cb:	74 38                	je     801505 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8014cd:	83 c2 01             	add    $0x1,%edx
  8014d0:	8b 04 95 cc 2e 80 00 	mov    0x802ecc(,%edx,4),%eax
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	75 ee                	jne    8014c9 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014db:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8014e0:	8b 40 48             	mov    0x48(%eax),%eax
  8014e3:	83 ec 04             	sub    $0x4,%esp
  8014e6:	51                   	push   %ecx
  8014e7:	50                   	push   %eax
  8014e8:	68 50 2e 80 00       	push   $0x802e50
  8014ed:	e8 46 f2 ff ff       	call   800738 <cprintf>
	*dev = 0;
  8014f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014fb:	83 c4 10             	add    $0x10,%esp
  8014fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801503:	c9                   	leave  
  801504:	c3                   	ret    
			*dev = devtab[i];
  801505:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801508:	89 01                	mov    %eax,(%ecx)
			return 0;
  80150a:	b8 00 00 00 00       	mov    $0x0,%eax
  80150f:	eb f2                	jmp    801503 <dev_lookup+0x51>

00801511 <fd_close>:
{
  801511:	f3 0f 1e fb          	endbr32 
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	57                   	push   %edi
  801519:	56                   	push   %esi
  80151a:	53                   	push   %ebx
  80151b:	83 ec 24             	sub    $0x24,%esp
  80151e:	8b 75 08             	mov    0x8(%ebp),%esi
  801521:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801524:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801527:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801528:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80152e:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801531:	50                   	push   %eax
  801532:	e8 27 ff ff ff       	call   80145e <fd_lookup>
  801537:	89 c3                	mov    %eax,%ebx
  801539:	83 c4 10             	add    $0x10,%esp
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 05                	js     801545 <fd_close+0x34>
	    || fd != fd2)
  801540:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801543:	74 16                	je     80155b <fd_close+0x4a>
		return (must_exist ? r : 0);
  801545:	89 f8                	mov    %edi,%eax
  801547:	84 c0                	test   %al,%al
  801549:	b8 00 00 00 00       	mov    $0x0,%eax
  80154e:	0f 44 d8             	cmove  %eax,%ebx
}
  801551:	89 d8                	mov    %ebx,%eax
  801553:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801556:	5b                   	pop    %ebx
  801557:	5e                   	pop    %esi
  801558:	5f                   	pop    %edi
  801559:	5d                   	pop    %ebp
  80155a:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80155b:	83 ec 08             	sub    $0x8,%esp
  80155e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801561:	50                   	push   %eax
  801562:	ff 36                	pushl  (%esi)
  801564:	e8 49 ff ff ff       	call   8014b2 <dev_lookup>
  801569:	89 c3                	mov    %eax,%ebx
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	85 c0                	test   %eax,%eax
  801570:	78 1a                	js     80158c <fd_close+0x7b>
		if (dev->dev_close)
  801572:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801575:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801578:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80157d:	85 c0                	test   %eax,%eax
  80157f:	74 0b                	je     80158c <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801581:	83 ec 0c             	sub    $0xc,%esp
  801584:	56                   	push   %esi
  801585:	ff d0                	call   *%eax
  801587:	89 c3                	mov    %eax,%ebx
  801589:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80158c:	83 ec 08             	sub    $0x8,%esp
  80158f:	56                   	push   %esi
  801590:	6a 00                	push   $0x0
  801592:	e8 5f fc ff ff       	call   8011f6 <sys_page_unmap>
	return r;
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	eb b5                	jmp    801551 <fd_close+0x40>

0080159c <close>:

int
close(int fdnum)
{
  80159c:	f3 0f 1e fb          	endbr32 
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
  8015a3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a9:	50                   	push   %eax
  8015aa:	ff 75 08             	pushl  0x8(%ebp)
  8015ad:	e8 ac fe ff ff       	call   80145e <fd_lookup>
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	85 c0                	test   %eax,%eax
  8015b7:	79 02                	jns    8015bb <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8015b9:	c9                   	leave  
  8015ba:	c3                   	ret    
		return fd_close(fd, 1);
  8015bb:	83 ec 08             	sub    $0x8,%esp
  8015be:	6a 01                	push   $0x1
  8015c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8015c3:	e8 49 ff ff ff       	call   801511 <fd_close>
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	eb ec                	jmp    8015b9 <close+0x1d>

008015cd <close_all>:

void
close_all(void)
{
  8015cd:	f3 0f 1e fb          	endbr32 
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	53                   	push   %ebx
  8015d5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015d8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015dd:	83 ec 0c             	sub    $0xc,%esp
  8015e0:	53                   	push   %ebx
  8015e1:	e8 b6 ff ff ff       	call   80159c <close>
	for (i = 0; i < MAXFD; i++)
  8015e6:	83 c3 01             	add    $0x1,%ebx
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	83 fb 20             	cmp    $0x20,%ebx
  8015ef:	75 ec                	jne    8015dd <close_all+0x10>
}
  8015f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f4:	c9                   	leave  
  8015f5:	c3                   	ret    

008015f6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015f6:	f3 0f 1e fb          	endbr32 
  8015fa:	55                   	push   %ebp
  8015fb:	89 e5                	mov    %esp,%ebp
  8015fd:	57                   	push   %edi
  8015fe:	56                   	push   %esi
  8015ff:	53                   	push   %ebx
  801600:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801603:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801606:	50                   	push   %eax
  801607:	ff 75 08             	pushl  0x8(%ebp)
  80160a:	e8 4f fe ff ff       	call   80145e <fd_lookup>
  80160f:	89 c3                	mov    %eax,%ebx
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	85 c0                	test   %eax,%eax
  801616:	0f 88 81 00 00 00    	js     80169d <dup+0xa7>
		return r;
	close(newfdnum);
  80161c:	83 ec 0c             	sub    $0xc,%esp
  80161f:	ff 75 0c             	pushl  0xc(%ebp)
  801622:	e8 75 ff ff ff       	call   80159c <close>

	newfd = INDEX2FD(newfdnum);
  801627:	8b 75 0c             	mov    0xc(%ebp),%esi
  80162a:	c1 e6 0c             	shl    $0xc,%esi
  80162d:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801633:	83 c4 04             	add    $0x4,%esp
  801636:	ff 75 e4             	pushl  -0x1c(%ebp)
  801639:	e8 af fd ff ff       	call   8013ed <fd2data>
  80163e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801640:	89 34 24             	mov    %esi,(%esp)
  801643:	e8 a5 fd ff ff       	call   8013ed <fd2data>
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80164d:	89 d8                	mov    %ebx,%eax
  80164f:	c1 e8 16             	shr    $0x16,%eax
  801652:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801659:	a8 01                	test   $0x1,%al
  80165b:	74 11                	je     80166e <dup+0x78>
  80165d:	89 d8                	mov    %ebx,%eax
  80165f:	c1 e8 0c             	shr    $0xc,%eax
  801662:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801669:	f6 c2 01             	test   $0x1,%dl
  80166c:	75 39                	jne    8016a7 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80166e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801671:	89 d0                	mov    %edx,%eax
  801673:	c1 e8 0c             	shr    $0xc,%eax
  801676:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80167d:	83 ec 0c             	sub    $0xc,%esp
  801680:	25 07 0e 00 00       	and    $0xe07,%eax
  801685:	50                   	push   %eax
  801686:	56                   	push   %esi
  801687:	6a 00                	push   $0x0
  801689:	52                   	push   %edx
  80168a:	6a 00                	push   $0x0
  80168c:	e8 40 fb ff ff       	call   8011d1 <sys_page_map>
  801691:	89 c3                	mov    %eax,%ebx
  801693:	83 c4 20             	add    $0x20,%esp
  801696:	85 c0                	test   %eax,%eax
  801698:	78 31                	js     8016cb <dup+0xd5>
		goto err;

	return newfdnum;
  80169a:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80169d:	89 d8                	mov    %ebx,%eax
  80169f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a2:	5b                   	pop    %ebx
  8016a3:	5e                   	pop    %esi
  8016a4:	5f                   	pop    %edi
  8016a5:	5d                   	pop    %ebp
  8016a6:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016a7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016ae:	83 ec 0c             	sub    $0xc,%esp
  8016b1:	25 07 0e 00 00       	and    $0xe07,%eax
  8016b6:	50                   	push   %eax
  8016b7:	57                   	push   %edi
  8016b8:	6a 00                	push   $0x0
  8016ba:	53                   	push   %ebx
  8016bb:	6a 00                	push   $0x0
  8016bd:	e8 0f fb ff ff       	call   8011d1 <sys_page_map>
  8016c2:	89 c3                	mov    %eax,%ebx
  8016c4:	83 c4 20             	add    $0x20,%esp
  8016c7:	85 c0                	test   %eax,%eax
  8016c9:	79 a3                	jns    80166e <dup+0x78>
	sys_page_unmap(0, newfd);
  8016cb:	83 ec 08             	sub    $0x8,%esp
  8016ce:	56                   	push   %esi
  8016cf:	6a 00                	push   $0x0
  8016d1:	e8 20 fb ff ff       	call   8011f6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016d6:	83 c4 08             	add    $0x8,%esp
  8016d9:	57                   	push   %edi
  8016da:	6a 00                	push   $0x0
  8016dc:	e8 15 fb ff ff       	call   8011f6 <sys_page_unmap>
	return r;
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	eb b7                	jmp    80169d <dup+0xa7>

008016e6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016e6:	f3 0f 1e fb          	endbr32 
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	53                   	push   %ebx
  8016ee:	83 ec 1c             	sub    $0x1c,%esp
  8016f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f7:	50                   	push   %eax
  8016f8:	53                   	push   %ebx
  8016f9:	e8 60 fd ff ff       	call   80145e <fd_lookup>
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	85 c0                	test   %eax,%eax
  801703:	78 3f                	js     801744 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801705:	83 ec 08             	sub    $0x8,%esp
  801708:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170b:	50                   	push   %eax
  80170c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170f:	ff 30                	pushl  (%eax)
  801711:	e8 9c fd ff ff       	call   8014b2 <dev_lookup>
  801716:	83 c4 10             	add    $0x10,%esp
  801719:	85 c0                	test   %eax,%eax
  80171b:	78 27                	js     801744 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80171d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801720:	8b 42 08             	mov    0x8(%edx),%eax
  801723:	83 e0 03             	and    $0x3,%eax
  801726:	83 f8 01             	cmp    $0x1,%eax
  801729:	74 1e                	je     801749 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80172b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80172e:	8b 40 08             	mov    0x8(%eax),%eax
  801731:	85 c0                	test   %eax,%eax
  801733:	74 35                	je     80176a <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801735:	83 ec 04             	sub    $0x4,%esp
  801738:	ff 75 10             	pushl  0x10(%ebp)
  80173b:	ff 75 0c             	pushl  0xc(%ebp)
  80173e:	52                   	push   %edx
  80173f:	ff d0                	call   *%eax
  801741:	83 c4 10             	add    $0x10,%esp
}
  801744:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801747:	c9                   	leave  
  801748:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801749:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  80174e:	8b 40 48             	mov    0x48(%eax),%eax
  801751:	83 ec 04             	sub    $0x4,%esp
  801754:	53                   	push   %ebx
  801755:	50                   	push   %eax
  801756:	68 91 2e 80 00       	push   $0x802e91
  80175b:	e8 d8 ef ff ff       	call   800738 <cprintf>
		return -E_INVAL;
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801768:	eb da                	jmp    801744 <read+0x5e>
		return -E_NOT_SUPP;
  80176a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80176f:	eb d3                	jmp    801744 <read+0x5e>

00801771 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801771:	f3 0f 1e fb          	endbr32 
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	57                   	push   %edi
  801779:	56                   	push   %esi
  80177a:	53                   	push   %ebx
  80177b:	83 ec 0c             	sub    $0xc,%esp
  80177e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801781:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801784:	bb 00 00 00 00       	mov    $0x0,%ebx
  801789:	eb 02                	jmp    80178d <readn+0x1c>
  80178b:	01 c3                	add    %eax,%ebx
  80178d:	39 f3                	cmp    %esi,%ebx
  80178f:	73 21                	jae    8017b2 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801791:	83 ec 04             	sub    $0x4,%esp
  801794:	89 f0                	mov    %esi,%eax
  801796:	29 d8                	sub    %ebx,%eax
  801798:	50                   	push   %eax
  801799:	89 d8                	mov    %ebx,%eax
  80179b:	03 45 0c             	add    0xc(%ebp),%eax
  80179e:	50                   	push   %eax
  80179f:	57                   	push   %edi
  8017a0:	e8 41 ff ff ff       	call   8016e6 <read>
		if (m < 0)
  8017a5:	83 c4 10             	add    $0x10,%esp
  8017a8:	85 c0                	test   %eax,%eax
  8017aa:	78 04                	js     8017b0 <readn+0x3f>
			return m;
		if (m == 0)
  8017ac:	75 dd                	jne    80178b <readn+0x1a>
  8017ae:	eb 02                	jmp    8017b2 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017b0:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8017b2:	89 d8                	mov    %ebx,%eax
  8017b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b7:	5b                   	pop    %ebx
  8017b8:	5e                   	pop    %esi
  8017b9:	5f                   	pop    %edi
  8017ba:	5d                   	pop    %ebp
  8017bb:	c3                   	ret    

008017bc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017bc:	f3 0f 1e fb          	endbr32 
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	53                   	push   %ebx
  8017c4:	83 ec 1c             	sub    $0x1c,%esp
  8017c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017cd:	50                   	push   %eax
  8017ce:	53                   	push   %ebx
  8017cf:	e8 8a fc ff ff       	call   80145e <fd_lookup>
  8017d4:	83 c4 10             	add    $0x10,%esp
  8017d7:	85 c0                	test   %eax,%eax
  8017d9:	78 3a                	js     801815 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017db:	83 ec 08             	sub    $0x8,%esp
  8017de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e1:	50                   	push   %eax
  8017e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e5:	ff 30                	pushl  (%eax)
  8017e7:	e8 c6 fc ff ff       	call   8014b2 <dev_lookup>
  8017ec:	83 c4 10             	add    $0x10,%esp
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	78 22                	js     801815 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017fa:	74 1e                	je     80181a <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ff:	8b 52 0c             	mov    0xc(%edx),%edx
  801802:	85 d2                	test   %edx,%edx
  801804:	74 35                	je     80183b <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801806:	83 ec 04             	sub    $0x4,%esp
  801809:	ff 75 10             	pushl  0x10(%ebp)
  80180c:	ff 75 0c             	pushl  0xc(%ebp)
  80180f:	50                   	push   %eax
  801810:	ff d2                	call   *%edx
  801812:	83 c4 10             	add    $0x10,%esp
}
  801815:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801818:	c9                   	leave  
  801819:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80181a:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  80181f:	8b 40 48             	mov    0x48(%eax),%eax
  801822:	83 ec 04             	sub    $0x4,%esp
  801825:	53                   	push   %ebx
  801826:	50                   	push   %eax
  801827:	68 ad 2e 80 00       	push   $0x802ead
  80182c:	e8 07 ef ff ff       	call   800738 <cprintf>
		return -E_INVAL;
  801831:	83 c4 10             	add    $0x10,%esp
  801834:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801839:	eb da                	jmp    801815 <write+0x59>
		return -E_NOT_SUPP;
  80183b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801840:	eb d3                	jmp    801815 <write+0x59>

00801842 <seek>:

int
seek(int fdnum, off_t offset)
{
  801842:	f3 0f 1e fb          	endbr32 
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80184c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184f:	50                   	push   %eax
  801850:	ff 75 08             	pushl  0x8(%ebp)
  801853:	e8 06 fc ff ff       	call   80145e <fd_lookup>
  801858:	83 c4 10             	add    $0x10,%esp
  80185b:	85 c0                	test   %eax,%eax
  80185d:	78 0e                	js     80186d <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80185f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801862:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801865:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801868:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80186d:	c9                   	leave  
  80186e:	c3                   	ret    

0080186f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80186f:	f3 0f 1e fb          	endbr32 
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	53                   	push   %ebx
  801877:	83 ec 1c             	sub    $0x1c,%esp
  80187a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80187d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801880:	50                   	push   %eax
  801881:	53                   	push   %ebx
  801882:	e8 d7 fb ff ff       	call   80145e <fd_lookup>
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	85 c0                	test   %eax,%eax
  80188c:	78 37                	js     8018c5 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80188e:	83 ec 08             	sub    $0x8,%esp
  801891:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801894:	50                   	push   %eax
  801895:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801898:	ff 30                	pushl  (%eax)
  80189a:	e8 13 fc ff ff       	call   8014b2 <dev_lookup>
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	78 1f                	js     8018c5 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018ad:	74 1b                	je     8018ca <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8018af:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018b2:	8b 52 18             	mov    0x18(%edx),%edx
  8018b5:	85 d2                	test   %edx,%edx
  8018b7:	74 32                	je     8018eb <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018b9:	83 ec 08             	sub    $0x8,%esp
  8018bc:	ff 75 0c             	pushl  0xc(%ebp)
  8018bf:	50                   	push   %eax
  8018c0:	ff d2                	call   *%edx
  8018c2:	83 c4 10             	add    $0x10,%esp
}
  8018c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c8:	c9                   	leave  
  8018c9:	c3                   	ret    
			thisenv->env_id, fdnum);
  8018ca:	a1 b4 40 80 00       	mov    0x8040b4,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018cf:	8b 40 48             	mov    0x48(%eax),%eax
  8018d2:	83 ec 04             	sub    $0x4,%esp
  8018d5:	53                   	push   %ebx
  8018d6:	50                   	push   %eax
  8018d7:	68 70 2e 80 00       	push   $0x802e70
  8018dc:	e8 57 ee ff ff       	call   800738 <cprintf>
		return -E_INVAL;
  8018e1:	83 c4 10             	add    $0x10,%esp
  8018e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018e9:	eb da                	jmp    8018c5 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8018eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018f0:	eb d3                	jmp    8018c5 <ftruncate+0x56>

008018f2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018f2:	f3 0f 1e fb          	endbr32 
  8018f6:	55                   	push   %ebp
  8018f7:	89 e5                	mov    %esp,%ebp
  8018f9:	53                   	push   %ebx
  8018fa:	83 ec 1c             	sub    $0x1c,%esp
  8018fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801900:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801903:	50                   	push   %eax
  801904:	ff 75 08             	pushl  0x8(%ebp)
  801907:	e8 52 fb ff ff       	call   80145e <fd_lookup>
  80190c:	83 c4 10             	add    $0x10,%esp
  80190f:	85 c0                	test   %eax,%eax
  801911:	78 4b                	js     80195e <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801913:	83 ec 08             	sub    $0x8,%esp
  801916:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801919:	50                   	push   %eax
  80191a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191d:	ff 30                	pushl  (%eax)
  80191f:	e8 8e fb ff ff       	call   8014b2 <dev_lookup>
  801924:	83 c4 10             	add    $0x10,%esp
  801927:	85 c0                	test   %eax,%eax
  801929:	78 33                	js     80195e <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80192b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801932:	74 2f                	je     801963 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801934:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801937:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80193e:	00 00 00 
	stat->st_isdir = 0;
  801941:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801948:	00 00 00 
	stat->st_dev = dev;
  80194b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801951:	83 ec 08             	sub    $0x8,%esp
  801954:	53                   	push   %ebx
  801955:	ff 75 f0             	pushl  -0x10(%ebp)
  801958:	ff 50 14             	call   *0x14(%eax)
  80195b:	83 c4 10             	add    $0x10,%esp
}
  80195e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801961:	c9                   	leave  
  801962:	c3                   	ret    
		return -E_NOT_SUPP;
  801963:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801968:	eb f4                	jmp    80195e <fstat+0x6c>

0080196a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80196a:	f3 0f 1e fb          	endbr32 
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	56                   	push   %esi
  801972:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801973:	83 ec 08             	sub    $0x8,%esp
  801976:	6a 00                	push   $0x0
  801978:	ff 75 08             	pushl  0x8(%ebp)
  80197b:	e8 01 02 00 00       	call   801b81 <open>
  801980:	89 c3                	mov    %eax,%ebx
  801982:	83 c4 10             	add    $0x10,%esp
  801985:	85 c0                	test   %eax,%eax
  801987:	78 1b                	js     8019a4 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801989:	83 ec 08             	sub    $0x8,%esp
  80198c:	ff 75 0c             	pushl  0xc(%ebp)
  80198f:	50                   	push   %eax
  801990:	e8 5d ff ff ff       	call   8018f2 <fstat>
  801995:	89 c6                	mov    %eax,%esi
	close(fd);
  801997:	89 1c 24             	mov    %ebx,(%esp)
  80199a:	e8 fd fb ff ff       	call   80159c <close>
	return r;
  80199f:	83 c4 10             	add    $0x10,%esp
  8019a2:	89 f3                	mov    %esi,%ebx
}
  8019a4:	89 d8                	mov    %ebx,%eax
  8019a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a9:	5b                   	pop    %ebx
  8019aa:	5e                   	pop    %esi
  8019ab:	5d                   	pop    %ebp
  8019ac:	c3                   	ret    

008019ad <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  8019ad:	55                   	push   %ebp
  8019ae:	89 e5                	mov    %esp,%ebp
  8019b0:	56                   	push   %esi
  8019b1:	53                   	push   %ebx
  8019b2:	89 c6                	mov    %eax,%esi
  8019b4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019b6:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  8019bd:	74 27                	je     8019e6 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019bf:	6a 07                	push   $0x7
  8019c1:	68 00 50 80 00       	push   $0x805000
  8019c6:	56                   	push   %esi
  8019c7:	ff 35 ac 40 80 00    	pushl  0x8040ac
  8019cd:	e8 7c 0c 00 00       	call   80264e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019d2:	83 c4 0c             	add    $0xc,%esp
  8019d5:	6a 00                	push   $0x0
  8019d7:	53                   	push   %ebx
  8019d8:	6a 00                	push   $0x0
  8019da:	e8 02 0c 00 00       	call   8025e1 <ipc_recv>
}
  8019df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e2:	5b                   	pop    %ebx
  8019e3:	5e                   	pop    %esi
  8019e4:	5d                   	pop    %ebp
  8019e5:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019e6:	83 ec 0c             	sub    $0xc,%esp
  8019e9:	6a 01                	push   $0x1
  8019eb:	e8 b6 0c 00 00       	call   8026a6 <ipc_find_env>
  8019f0:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  8019f5:	83 c4 10             	add    $0x10,%esp
  8019f8:	eb c5                	jmp    8019bf <fsipc+0x12>

008019fa <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019fa:	f3 0f 1e fb          	endbr32 
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a04:	8b 45 08             	mov    0x8(%ebp),%eax
  801a07:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a12:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a17:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1c:	b8 02 00 00 00       	mov    $0x2,%eax
  801a21:	e8 87 ff ff ff       	call   8019ad <fsipc>
}
  801a26:	c9                   	leave  
  801a27:	c3                   	ret    

00801a28 <devfile_flush>:
{
  801a28:	f3 0f 1e fb          	endbr32 
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a32:	8b 45 08             	mov    0x8(%ebp),%eax
  801a35:	8b 40 0c             	mov    0xc(%eax),%eax
  801a38:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a3d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a42:	b8 06 00 00 00       	mov    $0x6,%eax
  801a47:	e8 61 ff ff ff       	call   8019ad <fsipc>
}
  801a4c:	c9                   	leave  
  801a4d:	c3                   	ret    

00801a4e <devfile_stat>:
{
  801a4e:	f3 0f 1e fb          	endbr32 
  801a52:	55                   	push   %ebp
  801a53:	89 e5                	mov    %esp,%ebp
  801a55:	53                   	push   %ebx
  801a56:	83 ec 04             	sub    $0x4,%esp
  801a59:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a62:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a67:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6c:	b8 05 00 00 00       	mov    $0x5,%eax
  801a71:	e8 37 ff ff ff       	call   8019ad <fsipc>
  801a76:	85 c0                	test   %eax,%eax
  801a78:	78 2c                	js     801aa6 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a7a:	83 ec 08             	sub    $0x8,%esp
  801a7d:	68 00 50 80 00       	push   $0x805000
  801a82:	53                   	push   %ebx
  801a83:	e8 ba f2 ff ff       	call   800d42 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a88:	a1 80 50 80 00       	mov    0x805080,%eax
  801a8d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a93:	a1 84 50 80 00       	mov    0x805084,%eax
  801a98:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a9e:	83 c4 10             	add    $0x10,%esp
  801aa1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aa6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa9:	c9                   	leave  
  801aaa:	c3                   	ret    

00801aab <devfile_write>:
{
  801aab:	f3 0f 1e fb          	endbr32 
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	83 ec 0c             	sub    $0xc,%esp
  801ab5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ab8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801abd:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801ac2:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ac5:	8b 55 08             	mov    0x8(%ebp),%edx
  801ac8:	8b 52 0c             	mov    0xc(%edx),%edx
  801acb:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801ad1:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801ad6:	50                   	push   %eax
  801ad7:	ff 75 0c             	pushl  0xc(%ebp)
  801ada:	68 08 50 80 00       	push   $0x805008
  801adf:	e8 5c f4 ff ff       	call   800f40 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801ae4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae9:	b8 04 00 00 00       	mov    $0x4,%eax
  801aee:	e8 ba fe ff ff       	call   8019ad <fsipc>
}
  801af3:	c9                   	leave  
  801af4:	c3                   	ret    

00801af5 <devfile_read>:
{
  801af5:	f3 0f 1e fb          	endbr32 
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	56                   	push   %esi
  801afd:	53                   	push   %ebx
  801afe:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b01:	8b 45 08             	mov    0x8(%ebp),%eax
  801b04:	8b 40 0c             	mov    0xc(%eax),%eax
  801b07:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b0c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b12:	ba 00 00 00 00       	mov    $0x0,%edx
  801b17:	b8 03 00 00 00       	mov    $0x3,%eax
  801b1c:	e8 8c fe ff ff       	call   8019ad <fsipc>
  801b21:	89 c3                	mov    %eax,%ebx
  801b23:	85 c0                	test   %eax,%eax
  801b25:	78 1f                	js     801b46 <devfile_read+0x51>
	assert(r <= n);
  801b27:	39 f0                	cmp    %esi,%eax
  801b29:	77 24                	ja     801b4f <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801b2b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b30:	7f 36                	jg     801b68 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b32:	83 ec 04             	sub    $0x4,%esp
  801b35:	50                   	push   %eax
  801b36:	68 00 50 80 00       	push   $0x805000
  801b3b:	ff 75 0c             	pushl  0xc(%ebp)
  801b3e:	e8 fd f3 ff ff       	call   800f40 <memmove>
	return r;
  801b43:	83 c4 10             	add    $0x10,%esp
}
  801b46:	89 d8                	mov    %ebx,%eax
  801b48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b4b:	5b                   	pop    %ebx
  801b4c:	5e                   	pop    %esi
  801b4d:	5d                   	pop    %ebp
  801b4e:	c3                   	ret    
	assert(r <= n);
  801b4f:	68 e0 2e 80 00       	push   $0x802ee0
  801b54:	68 e7 2e 80 00       	push   $0x802ee7
  801b59:	68 8c 00 00 00       	push   $0x8c
  801b5e:	68 fc 2e 80 00       	push   $0x802efc
  801b63:	e8 e9 ea ff ff       	call   800651 <_panic>
	assert(r <= PGSIZE);
  801b68:	68 07 2f 80 00       	push   $0x802f07
  801b6d:	68 e7 2e 80 00       	push   $0x802ee7
  801b72:	68 8d 00 00 00       	push   $0x8d
  801b77:	68 fc 2e 80 00       	push   $0x802efc
  801b7c:	e8 d0 ea ff ff       	call   800651 <_panic>

00801b81 <open>:
{
  801b81:	f3 0f 1e fb          	endbr32 
  801b85:	55                   	push   %ebp
  801b86:	89 e5                	mov    %esp,%ebp
  801b88:	56                   	push   %esi
  801b89:	53                   	push   %ebx
  801b8a:	83 ec 1c             	sub    $0x1c,%esp
  801b8d:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801b90:	56                   	push   %esi
  801b91:	e8 69 f1 ff ff       	call   800cff <strlen>
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b9e:	7f 6c                	jg     801c0c <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801ba0:	83 ec 0c             	sub    $0xc,%esp
  801ba3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba6:	50                   	push   %eax
  801ba7:	e8 5c f8 ff ff       	call   801408 <fd_alloc>
  801bac:	89 c3                	mov    %eax,%ebx
  801bae:	83 c4 10             	add    $0x10,%esp
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	78 3c                	js     801bf1 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801bb5:	83 ec 08             	sub    $0x8,%esp
  801bb8:	56                   	push   %esi
  801bb9:	68 00 50 80 00       	push   $0x805000
  801bbe:	e8 7f f1 ff ff       	call   800d42 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc6:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bcb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bce:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd3:	e8 d5 fd ff ff       	call   8019ad <fsipc>
  801bd8:	89 c3                	mov    %eax,%ebx
  801bda:	83 c4 10             	add    $0x10,%esp
  801bdd:	85 c0                	test   %eax,%eax
  801bdf:	78 19                	js     801bfa <open+0x79>
	return fd2num(fd);
  801be1:	83 ec 0c             	sub    $0xc,%esp
  801be4:	ff 75 f4             	pushl  -0xc(%ebp)
  801be7:	e8 ed f7 ff ff       	call   8013d9 <fd2num>
  801bec:	89 c3                	mov    %eax,%ebx
  801bee:	83 c4 10             	add    $0x10,%esp
}
  801bf1:	89 d8                	mov    %ebx,%eax
  801bf3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bf6:	5b                   	pop    %ebx
  801bf7:	5e                   	pop    %esi
  801bf8:	5d                   	pop    %ebp
  801bf9:	c3                   	ret    
		fd_close(fd, 0);
  801bfa:	83 ec 08             	sub    $0x8,%esp
  801bfd:	6a 00                	push   $0x0
  801bff:	ff 75 f4             	pushl  -0xc(%ebp)
  801c02:	e8 0a f9 ff ff       	call   801511 <fd_close>
		return r;
  801c07:	83 c4 10             	add    $0x10,%esp
  801c0a:	eb e5                	jmp    801bf1 <open+0x70>
		return -E_BAD_PATH;
  801c0c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801c11:	eb de                	jmp    801bf1 <open+0x70>

00801c13 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c13:	f3 0f 1e fb          	endbr32 
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c1d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c22:	b8 08 00 00 00       	mov    $0x8,%eax
  801c27:	e8 81 fd ff ff       	call   8019ad <fsipc>
}
  801c2c:	c9                   	leave  
  801c2d:	c3                   	ret    

00801c2e <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c2e:	f3 0f 1e fb          	endbr32 
  801c32:	55                   	push   %ebp
  801c33:	89 e5                	mov    %esp,%ebp
  801c35:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801c38:	68 73 2f 80 00       	push   $0x802f73
  801c3d:	ff 75 0c             	pushl  0xc(%ebp)
  801c40:	e8 fd f0 ff ff       	call   800d42 <strcpy>
	return 0;
}
  801c45:	b8 00 00 00 00       	mov    $0x0,%eax
  801c4a:	c9                   	leave  
  801c4b:	c3                   	ret    

00801c4c <devsock_close>:
{
  801c4c:	f3 0f 1e fb          	endbr32 
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	53                   	push   %ebx
  801c54:	83 ec 10             	sub    $0x10,%esp
  801c57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c5a:	53                   	push   %ebx
  801c5b:	e8 83 0a 00 00       	call   8026e3 <pageref>
  801c60:	89 c2                	mov    %eax,%edx
  801c62:	83 c4 10             	add    $0x10,%esp
		return 0;
  801c65:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801c6a:	83 fa 01             	cmp    $0x1,%edx
  801c6d:	74 05                	je     801c74 <devsock_close+0x28>
}
  801c6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c72:	c9                   	leave  
  801c73:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801c74:	83 ec 0c             	sub    $0xc,%esp
  801c77:	ff 73 0c             	pushl  0xc(%ebx)
  801c7a:	e8 e3 02 00 00       	call   801f62 <nsipc_close>
  801c7f:	83 c4 10             	add    $0x10,%esp
  801c82:	eb eb                	jmp    801c6f <devsock_close+0x23>

00801c84 <devsock_write>:
{
  801c84:	f3 0f 1e fb          	endbr32 
  801c88:	55                   	push   %ebp
  801c89:	89 e5                	mov    %esp,%ebp
  801c8b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c8e:	6a 00                	push   $0x0
  801c90:	ff 75 10             	pushl  0x10(%ebp)
  801c93:	ff 75 0c             	pushl  0xc(%ebp)
  801c96:	8b 45 08             	mov    0x8(%ebp),%eax
  801c99:	ff 70 0c             	pushl  0xc(%eax)
  801c9c:	e8 b5 03 00 00       	call   802056 <nsipc_send>
}
  801ca1:	c9                   	leave  
  801ca2:	c3                   	ret    

00801ca3 <devsock_read>:
{
  801ca3:	f3 0f 1e fb          	endbr32 
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801cad:	6a 00                	push   $0x0
  801caf:	ff 75 10             	pushl  0x10(%ebp)
  801cb2:	ff 75 0c             	pushl  0xc(%ebp)
  801cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb8:	ff 70 0c             	pushl  0xc(%eax)
  801cbb:	e8 1f 03 00 00       	call   801fdf <nsipc_recv>
}
  801cc0:	c9                   	leave  
  801cc1:	c3                   	ret    

00801cc2 <fd2sockid>:
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801cc8:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ccb:	52                   	push   %edx
  801ccc:	50                   	push   %eax
  801ccd:	e8 8c f7 ff ff       	call   80145e <fd_lookup>
  801cd2:	83 c4 10             	add    $0x10,%esp
  801cd5:	85 c0                	test   %eax,%eax
  801cd7:	78 10                	js     801ce9 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdc:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  801ce2:	39 08                	cmp    %ecx,(%eax)
  801ce4:	75 05                	jne    801ceb <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801ce6:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801ce9:	c9                   	leave  
  801cea:	c3                   	ret    
		return -E_NOT_SUPP;
  801ceb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801cf0:	eb f7                	jmp    801ce9 <fd2sockid+0x27>

00801cf2 <alloc_sockfd>:
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	56                   	push   %esi
  801cf6:	53                   	push   %ebx
  801cf7:	83 ec 1c             	sub    $0x1c,%esp
  801cfa:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801cfc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cff:	50                   	push   %eax
  801d00:	e8 03 f7 ff ff       	call   801408 <fd_alloc>
  801d05:	89 c3                	mov    %eax,%ebx
  801d07:	83 c4 10             	add    $0x10,%esp
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	78 43                	js     801d51 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d0e:	83 ec 04             	sub    $0x4,%esp
  801d11:	68 07 04 00 00       	push   $0x407
  801d16:	ff 75 f4             	pushl  -0xc(%ebp)
  801d19:	6a 00                	push   $0x0
  801d1b:	e8 8b f4 ff ff       	call   8011ab <sys_page_alloc>
  801d20:	89 c3                	mov    %eax,%ebx
  801d22:	83 c4 10             	add    $0x10,%esp
  801d25:	85 c0                	test   %eax,%eax
  801d27:	78 28                	js     801d51 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801d29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2c:	8b 15 60 30 80 00    	mov    0x803060,%edx
  801d32:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d37:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d3e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d41:	83 ec 0c             	sub    $0xc,%esp
  801d44:	50                   	push   %eax
  801d45:	e8 8f f6 ff ff       	call   8013d9 <fd2num>
  801d4a:	89 c3                	mov    %eax,%ebx
  801d4c:	83 c4 10             	add    $0x10,%esp
  801d4f:	eb 0c                	jmp    801d5d <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801d51:	83 ec 0c             	sub    $0xc,%esp
  801d54:	56                   	push   %esi
  801d55:	e8 08 02 00 00       	call   801f62 <nsipc_close>
		return r;
  801d5a:	83 c4 10             	add    $0x10,%esp
}
  801d5d:	89 d8                	mov    %ebx,%eax
  801d5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d62:	5b                   	pop    %ebx
  801d63:	5e                   	pop    %esi
  801d64:	5d                   	pop    %ebp
  801d65:	c3                   	ret    

00801d66 <accept>:
{
  801d66:	f3 0f 1e fb          	endbr32 
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d70:	8b 45 08             	mov    0x8(%ebp),%eax
  801d73:	e8 4a ff ff ff       	call   801cc2 <fd2sockid>
  801d78:	85 c0                	test   %eax,%eax
  801d7a:	78 1b                	js     801d97 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d7c:	83 ec 04             	sub    $0x4,%esp
  801d7f:	ff 75 10             	pushl  0x10(%ebp)
  801d82:	ff 75 0c             	pushl  0xc(%ebp)
  801d85:	50                   	push   %eax
  801d86:	e8 22 01 00 00       	call   801ead <nsipc_accept>
  801d8b:	83 c4 10             	add    $0x10,%esp
  801d8e:	85 c0                	test   %eax,%eax
  801d90:	78 05                	js     801d97 <accept+0x31>
	return alloc_sockfd(r);
  801d92:	e8 5b ff ff ff       	call   801cf2 <alloc_sockfd>
}
  801d97:	c9                   	leave  
  801d98:	c3                   	ret    

00801d99 <bind>:
{
  801d99:	f3 0f 1e fb          	endbr32 
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801da3:	8b 45 08             	mov    0x8(%ebp),%eax
  801da6:	e8 17 ff ff ff       	call   801cc2 <fd2sockid>
  801dab:	85 c0                	test   %eax,%eax
  801dad:	78 12                	js     801dc1 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801daf:	83 ec 04             	sub    $0x4,%esp
  801db2:	ff 75 10             	pushl  0x10(%ebp)
  801db5:	ff 75 0c             	pushl  0xc(%ebp)
  801db8:	50                   	push   %eax
  801db9:	e8 45 01 00 00       	call   801f03 <nsipc_bind>
  801dbe:	83 c4 10             	add    $0x10,%esp
}
  801dc1:	c9                   	leave  
  801dc2:	c3                   	ret    

00801dc3 <shutdown>:
{
  801dc3:	f3 0f 1e fb          	endbr32 
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801dcd:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd0:	e8 ed fe ff ff       	call   801cc2 <fd2sockid>
  801dd5:	85 c0                	test   %eax,%eax
  801dd7:	78 0f                	js     801de8 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801dd9:	83 ec 08             	sub    $0x8,%esp
  801ddc:	ff 75 0c             	pushl  0xc(%ebp)
  801ddf:	50                   	push   %eax
  801de0:	e8 57 01 00 00       	call   801f3c <nsipc_shutdown>
  801de5:	83 c4 10             	add    $0x10,%esp
}
  801de8:	c9                   	leave  
  801de9:	c3                   	ret    

00801dea <connect>:
{
  801dea:	f3 0f 1e fb          	endbr32 
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801df4:	8b 45 08             	mov    0x8(%ebp),%eax
  801df7:	e8 c6 fe ff ff       	call   801cc2 <fd2sockid>
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	78 12                	js     801e12 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801e00:	83 ec 04             	sub    $0x4,%esp
  801e03:	ff 75 10             	pushl  0x10(%ebp)
  801e06:	ff 75 0c             	pushl  0xc(%ebp)
  801e09:	50                   	push   %eax
  801e0a:	e8 71 01 00 00       	call   801f80 <nsipc_connect>
  801e0f:	83 c4 10             	add    $0x10,%esp
}
  801e12:	c9                   	leave  
  801e13:	c3                   	ret    

00801e14 <listen>:
{
  801e14:	f3 0f 1e fb          	endbr32 
  801e18:	55                   	push   %ebp
  801e19:	89 e5                	mov    %esp,%ebp
  801e1b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e21:	e8 9c fe ff ff       	call   801cc2 <fd2sockid>
  801e26:	85 c0                	test   %eax,%eax
  801e28:	78 0f                	js     801e39 <listen+0x25>
	return nsipc_listen(r, backlog);
  801e2a:	83 ec 08             	sub    $0x8,%esp
  801e2d:	ff 75 0c             	pushl  0xc(%ebp)
  801e30:	50                   	push   %eax
  801e31:	e8 83 01 00 00       	call   801fb9 <nsipc_listen>
  801e36:	83 c4 10             	add    $0x10,%esp
}
  801e39:	c9                   	leave  
  801e3a:	c3                   	ret    

00801e3b <socket>:

int
socket(int domain, int type, int protocol)
{
  801e3b:	f3 0f 1e fb          	endbr32 
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
  801e42:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e45:	ff 75 10             	pushl  0x10(%ebp)
  801e48:	ff 75 0c             	pushl  0xc(%ebp)
  801e4b:	ff 75 08             	pushl  0x8(%ebp)
  801e4e:	e8 65 02 00 00       	call   8020b8 <nsipc_socket>
  801e53:	83 c4 10             	add    $0x10,%esp
  801e56:	85 c0                	test   %eax,%eax
  801e58:	78 05                	js     801e5f <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801e5a:	e8 93 fe ff ff       	call   801cf2 <alloc_sockfd>
}
  801e5f:	c9                   	leave  
  801e60:	c3                   	ret    

00801e61 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e61:	55                   	push   %ebp
  801e62:	89 e5                	mov    %esp,%ebp
  801e64:	53                   	push   %ebx
  801e65:	83 ec 04             	sub    $0x4,%esp
  801e68:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e6a:	83 3d b0 40 80 00 00 	cmpl   $0x0,0x8040b0
  801e71:	74 26                	je     801e99 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e73:	6a 07                	push   $0x7
  801e75:	68 00 60 80 00       	push   $0x806000
  801e7a:	53                   	push   %ebx
  801e7b:	ff 35 b0 40 80 00    	pushl  0x8040b0
  801e81:	e8 c8 07 00 00       	call   80264e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e86:	83 c4 0c             	add    $0xc,%esp
  801e89:	6a 00                	push   $0x0
  801e8b:	6a 00                	push   $0x0
  801e8d:	6a 00                	push   $0x0
  801e8f:	e8 4d 07 00 00       	call   8025e1 <ipc_recv>
}
  801e94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e97:	c9                   	leave  
  801e98:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e99:	83 ec 0c             	sub    $0xc,%esp
  801e9c:	6a 02                	push   $0x2
  801e9e:	e8 03 08 00 00       	call   8026a6 <ipc_find_env>
  801ea3:	a3 b0 40 80 00       	mov    %eax,0x8040b0
  801ea8:	83 c4 10             	add    $0x10,%esp
  801eab:	eb c6                	jmp    801e73 <nsipc+0x12>

00801ead <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ead:	f3 0f 1e fb          	endbr32 
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	56                   	push   %esi
  801eb5:	53                   	push   %ebx
  801eb6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801eb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ec1:	8b 06                	mov    (%esi),%eax
  801ec3:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ec8:	b8 01 00 00 00       	mov    $0x1,%eax
  801ecd:	e8 8f ff ff ff       	call   801e61 <nsipc>
  801ed2:	89 c3                	mov    %eax,%ebx
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	79 09                	jns    801ee1 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801ed8:	89 d8                	mov    %ebx,%eax
  801eda:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801edd:	5b                   	pop    %ebx
  801ede:	5e                   	pop    %esi
  801edf:	5d                   	pop    %ebp
  801ee0:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ee1:	83 ec 04             	sub    $0x4,%esp
  801ee4:	ff 35 10 60 80 00    	pushl  0x806010
  801eea:	68 00 60 80 00       	push   $0x806000
  801eef:	ff 75 0c             	pushl  0xc(%ebp)
  801ef2:	e8 49 f0 ff ff       	call   800f40 <memmove>
		*addrlen = ret->ret_addrlen;
  801ef7:	a1 10 60 80 00       	mov    0x806010,%eax
  801efc:	89 06                	mov    %eax,(%esi)
  801efe:	83 c4 10             	add    $0x10,%esp
	return r;
  801f01:	eb d5                	jmp    801ed8 <nsipc_accept+0x2b>

00801f03 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f03:	f3 0f 1e fb          	endbr32 
  801f07:	55                   	push   %ebp
  801f08:	89 e5                	mov    %esp,%ebp
  801f0a:	53                   	push   %ebx
  801f0b:	83 ec 08             	sub    $0x8,%esp
  801f0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f11:	8b 45 08             	mov    0x8(%ebp),%eax
  801f14:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f19:	53                   	push   %ebx
  801f1a:	ff 75 0c             	pushl  0xc(%ebp)
  801f1d:	68 04 60 80 00       	push   $0x806004
  801f22:	e8 19 f0 ff ff       	call   800f40 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f27:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f2d:	b8 02 00 00 00       	mov    $0x2,%eax
  801f32:	e8 2a ff ff ff       	call   801e61 <nsipc>
}
  801f37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f3a:	c9                   	leave  
  801f3b:	c3                   	ret    

00801f3c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f3c:	f3 0f 1e fb          	endbr32 
  801f40:	55                   	push   %ebp
  801f41:	89 e5                	mov    %esp,%ebp
  801f43:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f46:	8b 45 08             	mov    0x8(%ebp),%eax
  801f49:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f51:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801f56:	b8 03 00 00 00       	mov    $0x3,%eax
  801f5b:	e8 01 ff ff ff       	call   801e61 <nsipc>
}
  801f60:	c9                   	leave  
  801f61:	c3                   	ret    

00801f62 <nsipc_close>:

int
nsipc_close(int s)
{
  801f62:	f3 0f 1e fb          	endbr32 
  801f66:	55                   	push   %ebp
  801f67:	89 e5                	mov    %esp,%ebp
  801f69:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6f:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801f74:	b8 04 00 00 00       	mov    $0x4,%eax
  801f79:	e8 e3 fe ff ff       	call   801e61 <nsipc>
}
  801f7e:	c9                   	leave  
  801f7f:	c3                   	ret    

00801f80 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f80:	f3 0f 1e fb          	endbr32 
  801f84:	55                   	push   %ebp
  801f85:	89 e5                	mov    %esp,%ebp
  801f87:	53                   	push   %ebx
  801f88:	83 ec 08             	sub    $0x8,%esp
  801f8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f91:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f96:	53                   	push   %ebx
  801f97:	ff 75 0c             	pushl  0xc(%ebp)
  801f9a:	68 04 60 80 00       	push   $0x806004
  801f9f:	e8 9c ef ff ff       	call   800f40 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fa4:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801faa:	b8 05 00 00 00       	mov    $0x5,%eax
  801faf:	e8 ad fe ff ff       	call   801e61 <nsipc>
}
  801fb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fb7:	c9                   	leave  
  801fb8:	c3                   	ret    

00801fb9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801fb9:	f3 0f 1e fb          	endbr32 
  801fbd:	55                   	push   %ebp
  801fbe:	89 e5                	mov    %esp,%ebp
  801fc0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801fc3:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801fcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fce:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801fd3:	b8 06 00 00 00       	mov    $0x6,%eax
  801fd8:	e8 84 fe ff ff       	call   801e61 <nsipc>
}
  801fdd:	c9                   	leave  
  801fde:	c3                   	ret    

00801fdf <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801fdf:	f3 0f 1e fb          	endbr32 
  801fe3:	55                   	push   %ebp
  801fe4:	89 e5                	mov    %esp,%ebp
  801fe6:	56                   	push   %esi
  801fe7:	53                   	push   %ebx
  801fe8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801feb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fee:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ff3:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801ff9:	8b 45 14             	mov    0x14(%ebp),%eax
  801ffc:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802001:	b8 07 00 00 00       	mov    $0x7,%eax
  802006:	e8 56 fe ff ff       	call   801e61 <nsipc>
  80200b:	89 c3                	mov    %eax,%ebx
  80200d:	85 c0                	test   %eax,%eax
  80200f:	78 26                	js     802037 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  802011:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  802017:	b8 3f 06 00 00       	mov    $0x63f,%eax
  80201c:	0f 4e c6             	cmovle %esi,%eax
  80201f:	39 c3                	cmp    %eax,%ebx
  802021:	7f 1d                	jg     802040 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802023:	83 ec 04             	sub    $0x4,%esp
  802026:	53                   	push   %ebx
  802027:	68 00 60 80 00       	push   $0x806000
  80202c:	ff 75 0c             	pushl  0xc(%ebp)
  80202f:	e8 0c ef ff ff       	call   800f40 <memmove>
  802034:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802037:	89 d8                	mov    %ebx,%eax
  802039:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80203c:	5b                   	pop    %ebx
  80203d:	5e                   	pop    %esi
  80203e:	5d                   	pop    %ebp
  80203f:	c3                   	ret    
		assert(r < 1600 && r <= len);
  802040:	68 7f 2f 80 00       	push   $0x802f7f
  802045:	68 e7 2e 80 00       	push   $0x802ee7
  80204a:	6a 62                	push   $0x62
  80204c:	68 94 2f 80 00       	push   $0x802f94
  802051:	e8 fb e5 ff ff       	call   800651 <_panic>

00802056 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802056:	f3 0f 1e fb          	endbr32 
  80205a:	55                   	push   %ebp
  80205b:	89 e5                	mov    %esp,%ebp
  80205d:	53                   	push   %ebx
  80205e:	83 ec 04             	sub    $0x4,%esp
  802061:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802064:	8b 45 08             	mov    0x8(%ebp),%eax
  802067:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80206c:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802072:	7f 2e                	jg     8020a2 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802074:	83 ec 04             	sub    $0x4,%esp
  802077:	53                   	push   %ebx
  802078:	ff 75 0c             	pushl  0xc(%ebp)
  80207b:	68 0c 60 80 00       	push   $0x80600c
  802080:	e8 bb ee ff ff       	call   800f40 <memmove>
	nsipcbuf.send.req_size = size;
  802085:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80208b:	8b 45 14             	mov    0x14(%ebp),%eax
  80208e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802093:	b8 08 00 00 00       	mov    $0x8,%eax
  802098:	e8 c4 fd ff ff       	call   801e61 <nsipc>
}
  80209d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020a0:	c9                   	leave  
  8020a1:	c3                   	ret    
	assert(size < 1600);
  8020a2:	68 a0 2f 80 00       	push   $0x802fa0
  8020a7:	68 e7 2e 80 00       	push   $0x802ee7
  8020ac:	6a 6d                	push   $0x6d
  8020ae:	68 94 2f 80 00       	push   $0x802f94
  8020b3:	e8 99 e5 ff ff       	call   800651 <_panic>

008020b8 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020b8:	f3 0f 1e fb          	endbr32 
  8020bc:	55                   	push   %ebp
  8020bd:	89 e5                	mov    %esp,%ebp
  8020bf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8020ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020cd:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8020d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8020d5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8020da:	b8 09 00 00 00       	mov    $0x9,%eax
  8020df:	e8 7d fd ff ff       	call   801e61 <nsipc>
}
  8020e4:	c9                   	leave  
  8020e5:	c3                   	ret    

008020e6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8020e6:	f3 0f 1e fb          	endbr32 
  8020ea:	55                   	push   %ebp
  8020eb:	89 e5                	mov    %esp,%ebp
  8020ed:	56                   	push   %esi
  8020ee:	53                   	push   %ebx
  8020ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8020f2:	83 ec 0c             	sub    $0xc,%esp
  8020f5:	ff 75 08             	pushl  0x8(%ebp)
  8020f8:	e8 f0 f2 ff ff       	call   8013ed <fd2data>
  8020fd:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8020ff:	83 c4 08             	add    $0x8,%esp
  802102:	68 ac 2f 80 00       	push   $0x802fac
  802107:	53                   	push   %ebx
  802108:	e8 35 ec ff ff       	call   800d42 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80210d:	8b 46 04             	mov    0x4(%esi),%eax
  802110:	2b 06                	sub    (%esi),%eax
  802112:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802118:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80211f:	00 00 00 
	stat->st_dev = &devpipe;
  802122:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  802129:	30 80 00 
	return 0;
}
  80212c:	b8 00 00 00 00       	mov    $0x0,%eax
  802131:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802134:	5b                   	pop    %ebx
  802135:	5e                   	pop    %esi
  802136:	5d                   	pop    %ebp
  802137:	c3                   	ret    

00802138 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802138:	f3 0f 1e fb          	endbr32 
  80213c:	55                   	push   %ebp
  80213d:	89 e5                	mov    %esp,%ebp
  80213f:	53                   	push   %ebx
  802140:	83 ec 0c             	sub    $0xc,%esp
  802143:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802146:	53                   	push   %ebx
  802147:	6a 00                	push   $0x0
  802149:	e8 a8 f0 ff ff       	call   8011f6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80214e:	89 1c 24             	mov    %ebx,(%esp)
  802151:	e8 97 f2 ff ff       	call   8013ed <fd2data>
  802156:	83 c4 08             	add    $0x8,%esp
  802159:	50                   	push   %eax
  80215a:	6a 00                	push   $0x0
  80215c:	e8 95 f0 ff ff       	call   8011f6 <sys_page_unmap>
}
  802161:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802164:	c9                   	leave  
  802165:	c3                   	ret    

00802166 <_pipeisclosed>:
{
  802166:	55                   	push   %ebp
  802167:	89 e5                	mov    %esp,%ebp
  802169:	57                   	push   %edi
  80216a:	56                   	push   %esi
  80216b:	53                   	push   %ebx
  80216c:	83 ec 1c             	sub    $0x1c,%esp
  80216f:	89 c7                	mov    %eax,%edi
  802171:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802173:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  802178:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80217b:	83 ec 0c             	sub    $0xc,%esp
  80217e:	57                   	push   %edi
  80217f:	e8 5f 05 00 00       	call   8026e3 <pageref>
  802184:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802187:	89 34 24             	mov    %esi,(%esp)
  80218a:	e8 54 05 00 00       	call   8026e3 <pageref>
		nn = thisenv->env_runs;
  80218f:	8b 15 b4 40 80 00    	mov    0x8040b4,%edx
  802195:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802198:	83 c4 10             	add    $0x10,%esp
  80219b:	39 cb                	cmp    %ecx,%ebx
  80219d:	74 1b                	je     8021ba <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80219f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021a2:	75 cf                	jne    802173 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021a4:	8b 42 58             	mov    0x58(%edx),%eax
  8021a7:	6a 01                	push   $0x1
  8021a9:	50                   	push   %eax
  8021aa:	53                   	push   %ebx
  8021ab:	68 b3 2f 80 00       	push   $0x802fb3
  8021b0:	e8 83 e5 ff ff       	call   800738 <cprintf>
  8021b5:	83 c4 10             	add    $0x10,%esp
  8021b8:	eb b9                	jmp    802173 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8021ba:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021bd:	0f 94 c0             	sete   %al
  8021c0:	0f b6 c0             	movzbl %al,%eax
}
  8021c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021c6:	5b                   	pop    %ebx
  8021c7:	5e                   	pop    %esi
  8021c8:	5f                   	pop    %edi
  8021c9:	5d                   	pop    %ebp
  8021ca:	c3                   	ret    

008021cb <devpipe_write>:
{
  8021cb:	f3 0f 1e fb          	endbr32 
  8021cf:	55                   	push   %ebp
  8021d0:	89 e5                	mov    %esp,%ebp
  8021d2:	57                   	push   %edi
  8021d3:	56                   	push   %esi
  8021d4:	53                   	push   %ebx
  8021d5:	83 ec 28             	sub    $0x28,%esp
  8021d8:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8021db:	56                   	push   %esi
  8021dc:	e8 0c f2 ff ff       	call   8013ed <fd2data>
  8021e1:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8021e3:	83 c4 10             	add    $0x10,%esp
  8021e6:	bf 00 00 00 00       	mov    $0x0,%edi
  8021eb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021ee:	74 4f                	je     80223f <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8021f0:	8b 43 04             	mov    0x4(%ebx),%eax
  8021f3:	8b 0b                	mov    (%ebx),%ecx
  8021f5:	8d 51 20             	lea    0x20(%ecx),%edx
  8021f8:	39 d0                	cmp    %edx,%eax
  8021fa:	72 14                	jb     802210 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8021fc:	89 da                	mov    %ebx,%edx
  8021fe:	89 f0                	mov    %esi,%eax
  802200:	e8 61 ff ff ff       	call   802166 <_pipeisclosed>
  802205:	85 c0                	test   %eax,%eax
  802207:	75 3b                	jne    802244 <devpipe_write+0x79>
			sys_yield();
  802209:	e8 7a ef ff ff       	call   801188 <sys_yield>
  80220e:	eb e0                	jmp    8021f0 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802210:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802213:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802217:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80221a:	89 c2                	mov    %eax,%edx
  80221c:	c1 fa 1f             	sar    $0x1f,%edx
  80221f:	89 d1                	mov    %edx,%ecx
  802221:	c1 e9 1b             	shr    $0x1b,%ecx
  802224:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802227:	83 e2 1f             	and    $0x1f,%edx
  80222a:	29 ca                	sub    %ecx,%edx
  80222c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802230:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802234:	83 c0 01             	add    $0x1,%eax
  802237:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80223a:	83 c7 01             	add    $0x1,%edi
  80223d:	eb ac                	jmp    8021eb <devpipe_write+0x20>
	return i;
  80223f:	8b 45 10             	mov    0x10(%ebp),%eax
  802242:	eb 05                	jmp    802249 <devpipe_write+0x7e>
				return 0;
  802244:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802249:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80224c:	5b                   	pop    %ebx
  80224d:	5e                   	pop    %esi
  80224e:	5f                   	pop    %edi
  80224f:	5d                   	pop    %ebp
  802250:	c3                   	ret    

00802251 <devpipe_read>:
{
  802251:	f3 0f 1e fb          	endbr32 
  802255:	55                   	push   %ebp
  802256:	89 e5                	mov    %esp,%ebp
  802258:	57                   	push   %edi
  802259:	56                   	push   %esi
  80225a:	53                   	push   %ebx
  80225b:	83 ec 18             	sub    $0x18,%esp
  80225e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802261:	57                   	push   %edi
  802262:	e8 86 f1 ff ff       	call   8013ed <fd2data>
  802267:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802269:	83 c4 10             	add    $0x10,%esp
  80226c:	be 00 00 00 00       	mov    $0x0,%esi
  802271:	3b 75 10             	cmp    0x10(%ebp),%esi
  802274:	75 14                	jne    80228a <devpipe_read+0x39>
	return i;
  802276:	8b 45 10             	mov    0x10(%ebp),%eax
  802279:	eb 02                	jmp    80227d <devpipe_read+0x2c>
				return i;
  80227b:	89 f0                	mov    %esi,%eax
}
  80227d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802280:	5b                   	pop    %ebx
  802281:	5e                   	pop    %esi
  802282:	5f                   	pop    %edi
  802283:	5d                   	pop    %ebp
  802284:	c3                   	ret    
			sys_yield();
  802285:	e8 fe ee ff ff       	call   801188 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80228a:	8b 03                	mov    (%ebx),%eax
  80228c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80228f:	75 18                	jne    8022a9 <devpipe_read+0x58>
			if (i > 0)
  802291:	85 f6                	test   %esi,%esi
  802293:	75 e6                	jne    80227b <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  802295:	89 da                	mov    %ebx,%edx
  802297:	89 f8                	mov    %edi,%eax
  802299:	e8 c8 fe ff ff       	call   802166 <_pipeisclosed>
  80229e:	85 c0                	test   %eax,%eax
  8022a0:	74 e3                	je     802285 <devpipe_read+0x34>
				return 0;
  8022a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8022a7:	eb d4                	jmp    80227d <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8022a9:	99                   	cltd   
  8022aa:	c1 ea 1b             	shr    $0x1b,%edx
  8022ad:	01 d0                	add    %edx,%eax
  8022af:	83 e0 1f             	and    $0x1f,%eax
  8022b2:	29 d0                	sub    %edx,%eax
  8022b4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8022b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022bc:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8022bf:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8022c2:	83 c6 01             	add    $0x1,%esi
  8022c5:	eb aa                	jmp    802271 <devpipe_read+0x20>

008022c7 <pipe>:
{
  8022c7:	f3 0f 1e fb          	endbr32 
  8022cb:	55                   	push   %ebp
  8022cc:	89 e5                	mov    %esp,%ebp
  8022ce:	56                   	push   %esi
  8022cf:	53                   	push   %ebx
  8022d0:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8022d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022d6:	50                   	push   %eax
  8022d7:	e8 2c f1 ff ff       	call   801408 <fd_alloc>
  8022dc:	89 c3                	mov    %eax,%ebx
  8022de:	83 c4 10             	add    $0x10,%esp
  8022e1:	85 c0                	test   %eax,%eax
  8022e3:	0f 88 23 01 00 00    	js     80240c <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022e9:	83 ec 04             	sub    $0x4,%esp
  8022ec:	68 07 04 00 00       	push   $0x407
  8022f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8022f4:	6a 00                	push   $0x0
  8022f6:	e8 b0 ee ff ff       	call   8011ab <sys_page_alloc>
  8022fb:	89 c3                	mov    %eax,%ebx
  8022fd:	83 c4 10             	add    $0x10,%esp
  802300:	85 c0                	test   %eax,%eax
  802302:	0f 88 04 01 00 00    	js     80240c <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  802308:	83 ec 0c             	sub    $0xc,%esp
  80230b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80230e:	50                   	push   %eax
  80230f:	e8 f4 f0 ff ff       	call   801408 <fd_alloc>
  802314:	89 c3                	mov    %eax,%ebx
  802316:	83 c4 10             	add    $0x10,%esp
  802319:	85 c0                	test   %eax,%eax
  80231b:	0f 88 db 00 00 00    	js     8023fc <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802321:	83 ec 04             	sub    $0x4,%esp
  802324:	68 07 04 00 00       	push   $0x407
  802329:	ff 75 f0             	pushl  -0x10(%ebp)
  80232c:	6a 00                	push   $0x0
  80232e:	e8 78 ee ff ff       	call   8011ab <sys_page_alloc>
  802333:	89 c3                	mov    %eax,%ebx
  802335:	83 c4 10             	add    $0x10,%esp
  802338:	85 c0                	test   %eax,%eax
  80233a:	0f 88 bc 00 00 00    	js     8023fc <pipe+0x135>
	va = fd2data(fd0);
  802340:	83 ec 0c             	sub    $0xc,%esp
  802343:	ff 75 f4             	pushl  -0xc(%ebp)
  802346:	e8 a2 f0 ff ff       	call   8013ed <fd2data>
  80234b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80234d:	83 c4 0c             	add    $0xc,%esp
  802350:	68 07 04 00 00       	push   $0x407
  802355:	50                   	push   %eax
  802356:	6a 00                	push   $0x0
  802358:	e8 4e ee ff ff       	call   8011ab <sys_page_alloc>
  80235d:	89 c3                	mov    %eax,%ebx
  80235f:	83 c4 10             	add    $0x10,%esp
  802362:	85 c0                	test   %eax,%eax
  802364:	0f 88 82 00 00 00    	js     8023ec <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80236a:	83 ec 0c             	sub    $0xc,%esp
  80236d:	ff 75 f0             	pushl  -0x10(%ebp)
  802370:	e8 78 f0 ff ff       	call   8013ed <fd2data>
  802375:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80237c:	50                   	push   %eax
  80237d:	6a 00                	push   $0x0
  80237f:	56                   	push   %esi
  802380:	6a 00                	push   $0x0
  802382:	e8 4a ee ff ff       	call   8011d1 <sys_page_map>
  802387:	89 c3                	mov    %eax,%ebx
  802389:	83 c4 20             	add    $0x20,%esp
  80238c:	85 c0                	test   %eax,%eax
  80238e:	78 4e                	js     8023de <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  802390:	a1 7c 30 80 00       	mov    0x80307c,%eax
  802395:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802398:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80239a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80239d:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8023a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8023a7:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8023a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023ac:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8023b3:	83 ec 0c             	sub    $0xc,%esp
  8023b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8023b9:	e8 1b f0 ff ff       	call   8013d9 <fd2num>
  8023be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023c1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8023c3:	83 c4 04             	add    $0x4,%esp
  8023c6:	ff 75 f0             	pushl  -0x10(%ebp)
  8023c9:	e8 0b f0 ff ff       	call   8013d9 <fd2num>
  8023ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023d1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8023d4:	83 c4 10             	add    $0x10,%esp
  8023d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8023dc:	eb 2e                	jmp    80240c <pipe+0x145>
	sys_page_unmap(0, va);
  8023de:	83 ec 08             	sub    $0x8,%esp
  8023e1:	56                   	push   %esi
  8023e2:	6a 00                	push   $0x0
  8023e4:	e8 0d ee ff ff       	call   8011f6 <sys_page_unmap>
  8023e9:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8023ec:	83 ec 08             	sub    $0x8,%esp
  8023ef:	ff 75 f0             	pushl  -0x10(%ebp)
  8023f2:	6a 00                	push   $0x0
  8023f4:	e8 fd ed ff ff       	call   8011f6 <sys_page_unmap>
  8023f9:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8023fc:	83 ec 08             	sub    $0x8,%esp
  8023ff:	ff 75 f4             	pushl  -0xc(%ebp)
  802402:	6a 00                	push   $0x0
  802404:	e8 ed ed ff ff       	call   8011f6 <sys_page_unmap>
  802409:	83 c4 10             	add    $0x10,%esp
}
  80240c:	89 d8                	mov    %ebx,%eax
  80240e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802411:	5b                   	pop    %ebx
  802412:	5e                   	pop    %esi
  802413:	5d                   	pop    %ebp
  802414:	c3                   	ret    

00802415 <pipeisclosed>:
{
  802415:	f3 0f 1e fb          	endbr32 
  802419:	55                   	push   %ebp
  80241a:	89 e5                	mov    %esp,%ebp
  80241c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80241f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802422:	50                   	push   %eax
  802423:	ff 75 08             	pushl  0x8(%ebp)
  802426:	e8 33 f0 ff ff       	call   80145e <fd_lookup>
  80242b:	83 c4 10             	add    $0x10,%esp
  80242e:	85 c0                	test   %eax,%eax
  802430:	78 18                	js     80244a <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  802432:	83 ec 0c             	sub    $0xc,%esp
  802435:	ff 75 f4             	pushl  -0xc(%ebp)
  802438:	e8 b0 ef ff ff       	call   8013ed <fd2data>
  80243d:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80243f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802442:	e8 1f fd ff ff       	call   802166 <_pipeisclosed>
  802447:	83 c4 10             	add    $0x10,%esp
}
  80244a:	c9                   	leave  
  80244b:	c3                   	ret    

0080244c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80244c:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  802450:	b8 00 00 00 00       	mov    $0x0,%eax
  802455:	c3                   	ret    

00802456 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802456:	f3 0f 1e fb          	endbr32 
  80245a:	55                   	push   %ebp
  80245b:	89 e5                	mov    %esp,%ebp
  80245d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802460:	68 cb 2f 80 00       	push   $0x802fcb
  802465:	ff 75 0c             	pushl  0xc(%ebp)
  802468:	e8 d5 e8 ff ff       	call   800d42 <strcpy>
	return 0;
}
  80246d:	b8 00 00 00 00       	mov    $0x0,%eax
  802472:	c9                   	leave  
  802473:	c3                   	ret    

00802474 <devcons_write>:
{
  802474:	f3 0f 1e fb          	endbr32 
  802478:	55                   	push   %ebp
  802479:	89 e5                	mov    %esp,%ebp
  80247b:	57                   	push   %edi
  80247c:	56                   	push   %esi
  80247d:	53                   	push   %ebx
  80247e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802484:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802489:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80248f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802492:	73 31                	jae    8024c5 <devcons_write+0x51>
		m = n - tot;
  802494:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802497:	29 f3                	sub    %esi,%ebx
  802499:	83 fb 7f             	cmp    $0x7f,%ebx
  80249c:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8024a1:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8024a4:	83 ec 04             	sub    $0x4,%esp
  8024a7:	53                   	push   %ebx
  8024a8:	89 f0                	mov    %esi,%eax
  8024aa:	03 45 0c             	add    0xc(%ebp),%eax
  8024ad:	50                   	push   %eax
  8024ae:	57                   	push   %edi
  8024af:	e8 8c ea ff ff       	call   800f40 <memmove>
		sys_cputs(buf, m);
  8024b4:	83 c4 08             	add    $0x8,%esp
  8024b7:	53                   	push   %ebx
  8024b8:	57                   	push   %edi
  8024b9:	e8 3e ec ff ff       	call   8010fc <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8024be:	01 de                	add    %ebx,%esi
  8024c0:	83 c4 10             	add    $0x10,%esp
  8024c3:	eb ca                	jmp    80248f <devcons_write+0x1b>
}
  8024c5:	89 f0                	mov    %esi,%eax
  8024c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024ca:	5b                   	pop    %ebx
  8024cb:	5e                   	pop    %esi
  8024cc:	5f                   	pop    %edi
  8024cd:	5d                   	pop    %ebp
  8024ce:	c3                   	ret    

008024cf <devcons_read>:
{
  8024cf:	f3 0f 1e fb          	endbr32 
  8024d3:	55                   	push   %ebp
  8024d4:	89 e5                	mov    %esp,%ebp
  8024d6:	83 ec 08             	sub    $0x8,%esp
  8024d9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8024de:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8024e2:	74 21                	je     802505 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8024e4:	e8 35 ec ff ff       	call   80111e <sys_cgetc>
  8024e9:	85 c0                	test   %eax,%eax
  8024eb:	75 07                	jne    8024f4 <devcons_read+0x25>
		sys_yield();
  8024ed:	e8 96 ec ff ff       	call   801188 <sys_yield>
  8024f2:	eb f0                	jmp    8024e4 <devcons_read+0x15>
	if (c < 0)
  8024f4:	78 0f                	js     802505 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8024f6:	83 f8 04             	cmp    $0x4,%eax
  8024f9:	74 0c                	je     802507 <devcons_read+0x38>
	*(char*)vbuf = c;
  8024fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024fe:	88 02                	mov    %al,(%edx)
	return 1;
  802500:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802505:	c9                   	leave  
  802506:	c3                   	ret    
		return 0;
  802507:	b8 00 00 00 00       	mov    $0x0,%eax
  80250c:	eb f7                	jmp    802505 <devcons_read+0x36>

0080250e <cputchar>:
{
  80250e:	f3 0f 1e fb          	endbr32 
  802512:	55                   	push   %ebp
  802513:	89 e5                	mov    %esp,%ebp
  802515:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802518:	8b 45 08             	mov    0x8(%ebp),%eax
  80251b:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80251e:	6a 01                	push   $0x1
  802520:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802523:	50                   	push   %eax
  802524:	e8 d3 eb ff ff       	call   8010fc <sys_cputs>
}
  802529:	83 c4 10             	add    $0x10,%esp
  80252c:	c9                   	leave  
  80252d:	c3                   	ret    

0080252e <getchar>:
{
  80252e:	f3 0f 1e fb          	endbr32 
  802532:	55                   	push   %ebp
  802533:	89 e5                	mov    %esp,%ebp
  802535:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802538:	6a 01                	push   $0x1
  80253a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80253d:	50                   	push   %eax
  80253e:	6a 00                	push   $0x0
  802540:	e8 a1 f1 ff ff       	call   8016e6 <read>
	if (r < 0)
  802545:	83 c4 10             	add    $0x10,%esp
  802548:	85 c0                	test   %eax,%eax
  80254a:	78 06                	js     802552 <getchar+0x24>
	if (r < 1)
  80254c:	74 06                	je     802554 <getchar+0x26>
	return c;
  80254e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802552:	c9                   	leave  
  802553:	c3                   	ret    
		return -E_EOF;
  802554:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802559:	eb f7                	jmp    802552 <getchar+0x24>

0080255b <iscons>:
{
  80255b:	f3 0f 1e fb          	endbr32 
  80255f:	55                   	push   %ebp
  802560:	89 e5                	mov    %esp,%ebp
  802562:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802565:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802568:	50                   	push   %eax
  802569:	ff 75 08             	pushl  0x8(%ebp)
  80256c:	e8 ed ee ff ff       	call   80145e <fd_lookup>
  802571:	83 c4 10             	add    $0x10,%esp
  802574:	85 c0                	test   %eax,%eax
  802576:	78 11                	js     802589 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  802578:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80257b:	8b 15 98 30 80 00    	mov    0x803098,%edx
  802581:	39 10                	cmp    %edx,(%eax)
  802583:	0f 94 c0             	sete   %al
  802586:	0f b6 c0             	movzbl %al,%eax
}
  802589:	c9                   	leave  
  80258a:	c3                   	ret    

0080258b <opencons>:
{
  80258b:	f3 0f 1e fb          	endbr32 
  80258f:	55                   	push   %ebp
  802590:	89 e5                	mov    %esp,%ebp
  802592:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802595:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802598:	50                   	push   %eax
  802599:	e8 6a ee ff ff       	call   801408 <fd_alloc>
  80259e:	83 c4 10             	add    $0x10,%esp
  8025a1:	85 c0                	test   %eax,%eax
  8025a3:	78 3a                	js     8025df <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025a5:	83 ec 04             	sub    $0x4,%esp
  8025a8:	68 07 04 00 00       	push   $0x407
  8025ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8025b0:	6a 00                	push   $0x0
  8025b2:	e8 f4 eb ff ff       	call   8011ab <sys_page_alloc>
  8025b7:	83 c4 10             	add    $0x10,%esp
  8025ba:	85 c0                	test   %eax,%eax
  8025bc:	78 21                	js     8025df <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8025be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025c1:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8025c7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8025c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025cc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8025d3:	83 ec 0c             	sub    $0xc,%esp
  8025d6:	50                   	push   %eax
  8025d7:	e8 fd ed ff ff       	call   8013d9 <fd2num>
  8025dc:	83 c4 10             	add    $0x10,%esp
}
  8025df:	c9                   	leave  
  8025e0:	c3                   	ret    

008025e1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8025e1:	f3 0f 1e fb          	endbr32 
  8025e5:	55                   	push   %ebp
  8025e6:	89 e5                	mov    %esp,%ebp
  8025e8:	56                   	push   %esi
  8025e9:	53                   	push   %ebx
  8025ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8025ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  8025f3:	85 c0                	test   %eax,%eax
  8025f5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8025fa:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  8025fd:	83 ec 0c             	sub    $0xc,%esp
  802600:	50                   	push   %eax
  802601:	e8 ab ec ff ff       	call   8012b1 <sys_ipc_recv>
  802606:	83 c4 10             	add    $0x10,%esp
  802609:	85 c0                	test   %eax,%eax
  80260b:	75 2b                	jne    802638 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  80260d:	85 f6                	test   %esi,%esi
  80260f:	74 0a                	je     80261b <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  802611:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  802616:	8b 40 74             	mov    0x74(%eax),%eax
  802619:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  80261b:	85 db                	test   %ebx,%ebx
  80261d:	74 0a                	je     802629 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  80261f:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  802624:	8b 40 78             	mov    0x78(%eax),%eax
  802627:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  802629:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  80262e:	8b 40 70             	mov    0x70(%eax),%eax
}
  802631:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802634:	5b                   	pop    %ebx
  802635:	5e                   	pop    %esi
  802636:	5d                   	pop    %ebp
  802637:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  802638:	85 f6                	test   %esi,%esi
  80263a:	74 06                	je     802642 <ipc_recv+0x61>
  80263c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  802642:	85 db                	test   %ebx,%ebx
  802644:	74 eb                	je     802631 <ipc_recv+0x50>
  802646:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80264c:	eb e3                	jmp    802631 <ipc_recv+0x50>

0080264e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80264e:	f3 0f 1e fb          	endbr32 
  802652:	55                   	push   %ebp
  802653:	89 e5                	mov    %esp,%ebp
  802655:	57                   	push   %edi
  802656:	56                   	push   %esi
  802657:	53                   	push   %ebx
  802658:	83 ec 0c             	sub    $0xc,%esp
  80265b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80265e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802661:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  802664:	85 db                	test   %ebx,%ebx
  802666:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80266b:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  80266e:	ff 75 14             	pushl  0x14(%ebp)
  802671:	53                   	push   %ebx
  802672:	56                   	push   %esi
  802673:	57                   	push   %edi
  802674:	e8 11 ec ff ff       	call   80128a <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  802679:	83 c4 10             	add    $0x10,%esp
  80267c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80267f:	75 07                	jne    802688 <ipc_send+0x3a>
			sys_yield();
  802681:	e8 02 eb ff ff       	call   801188 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802686:	eb e6                	jmp    80266e <ipc_send+0x20>
		}
		else if (ret == 0)
  802688:	85 c0                	test   %eax,%eax
  80268a:	75 08                	jne    802694 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  80268c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80268f:	5b                   	pop    %ebx
  802690:	5e                   	pop    %esi
  802691:	5f                   	pop    %edi
  802692:	5d                   	pop    %ebp
  802693:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802694:	50                   	push   %eax
  802695:	68 d7 2f 80 00       	push   $0x802fd7
  80269a:	6a 48                	push   $0x48
  80269c:	68 e5 2f 80 00       	push   $0x802fe5
  8026a1:	e8 ab df ff ff       	call   800651 <_panic>

008026a6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8026a6:	f3 0f 1e fb          	endbr32 
  8026aa:	55                   	push   %ebp
  8026ab:	89 e5                	mov    %esp,%ebp
  8026ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8026b0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8026b5:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8026b8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8026be:	8b 52 50             	mov    0x50(%edx),%edx
  8026c1:	39 ca                	cmp    %ecx,%edx
  8026c3:	74 11                	je     8026d6 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8026c5:	83 c0 01             	add    $0x1,%eax
  8026c8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8026cd:	75 e6                	jne    8026b5 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8026cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8026d4:	eb 0b                	jmp    8026e1 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8026d6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8026d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8026de:	8b 40 48             	mov    0x48(%eax),%eax
}
  8026e1:	5d                   	pop    %ebp
  8026e2:	c3                   	ret    

008026e3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026e3:	f3 0f 1e fb          	endbr32 
  8026e7:	55                   	push   %ebp
  8026e8:	89 e5                	mov    %esp,%ebp
  8026ea:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026ed:	89 c2                	mov    %eax,%edx
  8026ef:	c1 ea 16             	shr    $0x16,%edx
  8026f2:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8026f9:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8026fe:	f6 c1 01             	test   $0x1,%cl
  802701:	74 1c                	je     80271f <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802703:	c1 e8 0c             	shr    $0xc,%eax
  802706:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80270d:	a8 01                	test   $0x1,%al
  80270f:	74 0e                	je     80271f <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802711:	c1 e8 0c             	shr    $0xc,%eax
  802714:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80271b:	ef 
  80271c:	0f b7 d2             	movzwl %dx,%edx
}
  80271f:	89 d0                	mov    %edx,%eax
  802721:	5d                   	pop    %ebp
  802722:	c3                   	ret    
  802723:	66 90                	xchg   %ax,%ax
  802725:	66 90                	xchg   %ax,%ax
  802727:	66 90                	xchg   %ax,%ax
  802729:	66 90                	xchg   %ax,%ax
  80272b:	66 90                	xchg   %ax,%ax
  80272d:	66 90                	xchg   %ax,%ax
  80272f:	90                   	nop

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
