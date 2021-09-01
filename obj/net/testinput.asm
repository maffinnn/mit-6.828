
obj/net/testinput:     file format elf32-i386


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
  80002c:	e8 33 08 00 00       	call   800864 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 7c             	sub    $0x7c,%esp
	envid_t ns_envid = sys_getenvid();
  800040:	e8 9b 13 00 00       	call   8013e0 <sys_getenvid>
  800045:	89 c3                	mov    %eax,%ebx
	int i, r, first = 1;

	binaryname = "testinput";
  800047:	c7 05 00 40 80 00 a0 	movl   $0x802ea0,0x804000
  80004e:	2e 80 00 

	output_envid = fork();
  800051:	e8 63 16 00 00       	call   8016b9 <fork>
  800056:	a3 04 50 80 00       	mov    %eax,0x805004
	if (output_envid < 0)
  80005b:	85 c0                	test   %eax,%eax
  80005d:	0f 88 7b 01 00 00    	js     8001de <umain+0x1ab>
		panic("error forking");
	else if (output_envid == 0) {
  800063:	0f 84 89 01 00 00    	je     8001f2 <umain+0x1bf>
		output(ns_envid);
		return;
	}

	input_envid = fork();
  800069:	e8 4b 16 00 00       	call   8016b9 <fork>
  80006e:	a3 00 50 80 00       	mov    %eax,0x805000
	if (input_envid < 0)
  800073:	85 c0                	test   %eax,%eax
  800075:	0f 88 8b 01 00 00    	js     800206 <umain+0x1d3>
		panic("error forking");
	else if (input_envid == 0) {
  80007b:	0f 84 99 01 00 00    	je     80021a <umain+0x1e7>
		input(ns_envid);
		return;
	}

	cprintf("Sending ARP announcement...\n");
  800081:	83 ec 0c             	sub    $0xc,%esp
  800084:	68 c8 2e 80 00       	push   $0x802ec8
  800089:	e8 25 09 00 00       	call   8009b3 <cprintf>
	uint8_t mac[6] = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};
  80008e:	c7 45 98 52 54 00 12 	movl   $0x12005452,-0x68(%ebp)
  800095:	66 c7 45 9c 34 56    	movw   $0x5634,-0x64(%ebp)
	uint32_t myip = inet_addr(IP);
  80009b:	c7 04 24 e5 2e 80 00 	movl   $0x802ee5,(%esp)
  8000a2:	e8 80 07 00 00       	call   800827 <inet_addr>
  8000a7:	89 45 90             	mov    %eax,-0x70(%ebp)
	uint32_t gwip = inet_addr(DEFAULT);
  8000aa:	c7 04 24 ef 2e 80 00 	movl   $0x802eef,(%esp)
  8000b1:	e8 71 07 00 00       	call   800827 <inet_addr>
  8000b6:	89 45 94             	mov    %eax,-0x6c(%ebp)
	if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  8000b9:	83 c4 0c             	add    $0xc,%esp
  8000bc:	6a 07                	push   $0x7
  8000be:	68 00 b0 fe 0f       	push   $0xffeb000
  8000c3:	6a 00                	push   $0x0
  8000c5:	e8 5c 13 00 00       	call   801426 <sys_page_alloc>
  8000ca:	83 c4 10             	add    $0x10,%esp
  8000cd:	85 c0                	test   %eax,%eax
  8000cf:	0f 88 53 01 00 00    	js     800228 <umain+0x1f5>
	pkt->jp_len = sizeof(*arp);
  8000d5:	c7 05 00 b0 fe 0f 2a 	movl   $0x2a,0xffeb000
  8000dc:	00 00 00 
	memset(arp->ethhdr.dest.addr, 0xff, ETHARP_HWADDR_LEN);
  8000df:	83 ec 04             	sub    $0x4,%esp
  8000e2:	6a 06                	push   $0x6
  8000e4:	68 ff 00 00 00       	push   $0xff
  8000e9:	68 04 b0 fe 0f       	push   $0xffeb004
  8000ee:	e8 7c 10 00 00       	call   80116f <memset>
	memcpy(arp->ethhdr.src.addr,  mac,  ETHARP_HWADDR_LEN);
  8000f3:	83 c4 0c             	add    $0xc,%esp
  8000f6:	6a 06                	push   $0x6
  8000f8:	8d 5d 98             	lea    -0x68(%ebp),%ebx
  8000fb:	53                   	push   %ebx
  8000fc:	68 0a b0 fe 0f       	push   $0xffeb00a
  800101:	e8 1b 11 00 00       	call   801221 <memcpy>
	arp->ethhdr.type = htons(ETHTYPE_ARP);
  800106:	c7 04 24 06 08 00 00 	movl   $0x806,(%esp)
  80010d:	e8 ec 04 00 00       	call   8005fe <htons>
  800112:	66 a3 10 b0 fe 0f    	mov    %ax,0xffeb010
	arp->hwtype = htons(1); // Ethernet
  800118:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80011f:	e8 da 04 00 00       	call   8005fe <htons>
  800124:	66 a3 12 b0 fe 0f    	mov    %ax,0xffeb012
	arp->proto = htons(ETHTYPE_IP);
  80012a:	c7 04 24 00 08 00 00 	movl   $0x800,(%esp)
  800131:	e8 c8 04 00 00       	call   8005fe <htons>
  800136:	66 a3 14 b0 fe 0f    	mov    %ax,0xffeb014
	arp->_hwlen_protolen = htons((ETHARP_HWADDR_LEN << 8) | 4);
  80013c:	c7 04 24 04 06 00 00 	movl   $0x604,(%esp)
  800143:	e8 b6 04 00 00       	call   8005fe <htons>
  800148:	66 a3 16 b0 fe 0f    	mov    %ax,0xffeb016
	arp->opcode = htons(ARP_REQUEST);
  80014e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800155:	e8 a4 04 00 00       	call   8005fe <htons>
  80015a:	66 a3 18 b0 fe 0f    	mov    %ax,0xffeb018
	memcpy(arp->shwaddr.addr,  mac,   ETHARP_HWADDR_LEN);
  800160:	83 c4 0c             	add    $0xc,%esp
  800163:	6a 06                	push   $0x6
  800165:	53                   	push   %ebx
  800166:	68 1a b0 fe 0f       	push   $0xffeb01a
  80016b:	e8 b1 10 00 00       	call   801221 <memcpy>
	memcpy(arp->sipaddr.addrw, &myip, 4);
  800170:	83 c4 0c             	add    $0xc,%esp
  800173:	6a 04                	push   $0x4
  800175:	8d 45 90             	lea    -0x70(%ebp),%eax
  800178:	50                   	push   %eax
  800179:	68 20 b0 fe 0f       	push   $0xffeb020
  80017e:	e8 9e 10 00 00       	call   801221 <memcpy>
	memset(arp->dhwaddr.addr,  0x00,  ETHARP_HWADDR_LEN);
  800183:	83 c4 0c             	add    $0xc,%esp
  800186:	6a 06                	push   $0x6
  800188:	6a 00                	push   $0x0
  80018a:	68 24 b0 fe 0f       	push   $0xffeb024
  80018f:	e8 db 0f 00 00       	call   80116f <memset>
	memcpy(arp->dipaddr.addrw, &gwip, 4);
  800194:	83 c4 0c             	add    $0xc,%esp
  800197:	6a 04                	push   $0x4
  800199:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80019c:	50                   	push   %eax
  80019d:	68 2a b0 fe 0f       	push   $0xffeb02a
  8001a2:	e8 7a 10 00 00       	call   801221 <memcpy>
	ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8001a7:	6a 07                	push   $0x7
  8001a9:	68 00 b0 fe 0f       	push   $0xffeb000
  8001ae:	6a 0b                	push   $0xb
  8001b0:	ff 35 04 50 80 00    	pushl  0x805004
  8001b6:	e8 fc 16 00 00       	call   8018b7 <ipc_send>
	sys_page_unmap(0, pkt);
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	68 00 b0 fe 0f       	push   $0xffeb000
  8001c3:	6a 00                	push   $0x0
  8001c5:	e8 a7 12 00 00       	call   801471 <sys_page_unmap>
}
  8001ca:	83 c4 10             	add    $0x10,%esp
	int i, r, first = 1;
  8001cd:	c7 85 78 ff ff ff 01 	movl   $0x1,-0x88(%ebp)
  8001d4:	00 00 00 
			out = buf + snprintf(buf, end - buf,
  8001d7:	89 df                	mov    %ebx,%edi
}
  8001d9:	e9 6a 01 00 00       	jmp    800348 <umain+0x315>
		panic("error forking");
  8001de:	83 ec 04             	sub    $0x4,%esp
  8001e1:	68 aa 2e 80 00       	push   $0x802eaa
  8001e6:	6a 4d                	push   $0x4d
  8001e8:	68 b8 2e 80 00       	push   $0x802eb8
  8001ed:	e8 da 06 00 00       	call   8008cc <_panic>
		output(ns_envid);
  8001f2:	83 ec 0c             	sub    $0xc,%esp
  8001f5:	53                   	push   %ebx
  8001f6:	e8 09 03 00 00       	call   800504 <output>
		return;
  8001fb:	83 c4 10             	add    $0x10,%esp
		// we've received the ARP reply
		if (first)
			cprintf("Waiting for packets...\n");
		first = 0;
	}
}
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    
		panic("error forking");
  800206:	83 ec 04             	sub    $0x4,%esp
  800209:	68 aa 2e 80 00       	push   $0x802eaa
  80020e:	6a 55                	push   $0x55
  800210:	68 b8 2e 80 00       	push   $0x802eb8
  800215:	e8 b2 06 00 00       	call   8008cc <_panic>
		input(ns_envid);
  80021a:	83 ec 0c             	sub    $0xc,%esp
  80021d:	53                   	push   %ebx
  80021e:	e8 26 02 00 00       	call   800449 <input>
		return;
  800223:	83 c4 10             	add    $0x10,%esp
  800226:	eb d6                	jmp    8001fe <umain+0x1cb>
		panic("sys_page_map: %e", r);
  800228:	50                   	push   %eax
  800229:	68 f8 2e 80 00       	push   $0x802ef8
  80022e:	6a 19                	push   $0x19
  800230:	68 b8 2e 80 00       	push   $0x802eb8
  800235:	e8 92 06 00 00       	call   8008cc <_panic>
			panic("ipc_recv: %e", req);
  80023a:	50                   	push   %eax
  80023b:	68 09 2f 80 00       	push   $0x802f09
  800240:	6a 64                	push   $0x64
  800242:	68 b8 2e 80 00       	push   $0x802eb8
  800247:	e8 80 06 00 00       	call   8008cc <_panic>
			panic("IPC from unexpected environment %08x", whom);
  80024c:	52                   	push   %edx
  80024d:	68 60 2f 80 00       	push   $0x802f60
  800252:	6a 66                	push   $0x66
  800254:	68 b8 2e 80 00       	push   $0x802eb8
  800259:	e8 6e 06 00 00       	call   8008cc <_panic>
			panic("Unexpected IPC %d", req);
  80025e:	50                   	push   %eax
  80025f:	68 16 2f 80 00       	push   $0x802f16
  800264:	6a 68                	push   $0x68
  800266:	68 b8 2e 80 00       	push   $0x802eb8
  80026b:	e8 5c 06 00 00       	call   8008cc <_panic>
			out = buf + snprintf(buf, end - buf,
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	56                   	push   %esi
  800274:	68 28 2f 80 00       	push   $0x802f28
  800279:	68 30 2f 80 00       	push   $0x802f30
  80027e:	6a 50                	push   $0x50
  800280:	57                   	push   %edi
  800281:	e8 d6 0c 00 00       	call   800f5c <snprintf>
  800286:	8d 1c 07             	lea    (%edi,%eax,1),%ebx
  800289:	83 c4 20             	add    $0x20,%esp
  80028c:	eb 41                	jmp    8002cf <umain+0x29c>
			cprintf("%.*s\n", out - buf, buf);
  80028e:	83 ec 04             	sub    $0x4,%esp
  800291:	57                   	push   %edi
  800292:	89 d8                	mov    %ebx,%eax
  800294:	29 f8                	sub    %edi,%eax
  800296:	50                   	push   %eax
  800297:	68 3f 2f 80 00       	push   $0x802f3f
  80029c:	e8 12 07 00 00       	call   8009b3 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
		if (i % 2 == 1)
  8002a4:	89 f2                	mov    %esi,%edx
  8002a6:	c1 ea 1f             	shr    $0x1f,%edx
  8002a9:	8d 04 16             	lea    (%esi,%edx,1),%eax
  8002ac:	83 e0 01             	and    $0x1,%eax
  8002af:	29 d0                	sub    %edx,%eax
  8002b1:	83 f8 01             	cmp    $0x1,%eax
  8002b4:	74 5f                	je     800315 <umain+0x2e2>
		if (i % 16 == 7)
  8002b6:	83 7d 84 07          	cmpl   $0x7,-0x7c(%ebp)
  8002ba:	74 61                	je     80031d <umain+0x2ea>
	for (i = 0; i < len; i++) {
  8002bc:	83 c6 01             	add    $0x1,%esi
  8002bf:	39 75 80             	cmp    %esi,-0x80(%ebp)
  8002c2:	7e 61                	jle    800325 <umain+0x2f2>
  8002c4:	89 75 84             	mov    %esi,-0x7c(%ebp)
		if (i % 16 == 0)
  8002c7:	f7 c6 0f 00 00 00    	test   $0xf,%esi
  8002cd:	74 a1                	je     800270 <umain+0x23d>
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
  8002cf:	8b 45 84             	mov    -0x7c(%ebp),%eax
  8002d2:	0f b6 80 04 b0 fe 0f 	movzbl 0xffeb004(%eax),%eax
  8002d9:	50                   	push   %eax
  8002da:	68 3a 2f 80 00       	push   $0x802f3a
  8002df:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8002e2:	29 d8                	sub    %ebx,%eax
  8002e4:	50                   	push   %eax
  8002e5:	53                   	push   %ebx
  8002e6:	e8 71 0c 00 00       	call   800f5c <snprintf>
  8002eb:	01 c3                	add    %eax,%ebx
		if (i % 16 == 15 || i == len - 1)
  8002ed:	89 f0                	mov    %esi,%eax
  8002ef:	c1 f8 1f             	sar    $0x1f,%eax
  8002f2:	c1 e8 1c             	shr    $0x1c,%eax
  8002f5:	8d 14 06             	lea    (%esi,%eax,1),%edx
  8002f8:	83 e2 0f             	and    $0xf,%edx
  8002fb:	29 c2                	sub    %eax,%edx
  8002fd:	89 55 84             	mov    %edx,-0x7c(%ebp)
  800300:	83 c4 10             	add    $0x10,%esp
  800303:	83 fa 0f             	cmp    $0xf,%edx
  800306:	74 86                	je     80028e <umain+0x25b>
  800308:	3b b5 7c ff ff ff    	cmp    -0x84(%ebp),%esi
  80030e:	75 94                	jne    8002a4 <umain+0x271>
  800310:	e9 79 ff ff ff       	jmp    80028e <umain+0x25b>
			*(out++) = ' ';
  800315:	c6 03 20             	movb   $0x20,(%ebx)
  800318:	8d 5b 01             	lea    0x1(%ebx),%ebx
  80031b:	eb 99                	jmp    8002b6 <umain+0x283>
			*(out++) = ' ';
  80031d:	c6 03 20             	movb   $0x20,(%ebx)
  800320:	8d 5b 01             	lea    0x1(%ebx),%ebx
  800323:	eb 97                	jmp    8002bc <umain+0x289>
		cprintf("\n");
  800325:	83 ec 0c             	sub    $0xc,%esp
  800328:	68 5b 2f 80 00       	push   $0x802f5b
  80032d:	e8 81 06 00 00       	call   8009b3 <cprintf>
		if (first)
  800332:	83 c4 10             	add    $0x10,%esp
  800335:	83 bd 78 ff ff ff 00 	cmpl   $0x0,-0x88(%ebp)
  80033c:	75 62                	jne    8003a0 <umain+0x36d>
		first = 0;
  80033e:	c7 85 78 ff ff ff 00 	movl   $0x0,-0x88(%ebp)
  800345:	00 00 00 
		int32_t req = ipc_recv((int32_t *)&whom, pkt, &perm);
  800348:	83 ec 04             	sub    $0x4,%esp
  80034b:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80034e:	50                   	push   %eax
  80034f:	68 00 b0 fe 0f       	push   $0xffeb000
  800354:	8d 45 90             	lea    -0x70(%ebp),%eax
  800357:	50                   	push   %eax
  800358:	e8 ed 14 00 00       	call   80184a <ipc_recv>
		if (req < 0)
  80035d:	83 c4 10             	add    $0x10,%esp
  800360:	85 c0                	test   %eax,%eax
  800362:	0f 88 d2 fe ff ff    	js     80023a <umain+0x207>
		if (whom != input_envid)
  800368:	8b 55 90             	mov    -0x70(%ebp),%edx
  80036b:	3b 15 00 50 80 00    	cmp    0x805000,%edx
  800371:	0f 85 d5 fe ff ff    	jne    80024c <umain+0x219>
		if (req != NSREQ_INPUT)
  800377:	83 f8 0a             	cmp    $0xa,%eax
  80037a:	0f 85 de fe ff ff    	jne    80025e <umain+0x22b>
		hexdump("input: ", pkt->jp_data, pkt->jp_len);
  800380:	a1 00 b0 fe 0f       	mov    0xffeb000,%eax
  800385:	89 45 80             	mov    %eax,-0x80(%ebp)
	char *out = NULL;
  800388:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++) {
  80038d:	be 00 00 00 00       	mov    $0x0,%esi
		if (i % 16 == 15 || i == len - 1)
  800392:	83 e8 01             	sub    $0x1,%eax
  800395:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
	for (i = 0; i < len; i++) {
  80039b:	e9 1f ff ff ff       	jmp    8002bf <umain+0x28c>
			cprintf("Waiting for packets...\n");
  8003a0:	83 ec 0c             	sub    $0xc,%esp
  8003a3:	68 45 2f 80 00       	push   $0x802f45
  8003a8:	e8 06 06 00 00       	call   8009b3 <cprintf>
  8003ad:	83 c4 10             	add    $0x10,%esp
  8003b0:	eb 8c                	jmp    80033e <umain+0x30b>

008003b2 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  8003b2:	f3 0f 1e fb          	endbr32 
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	57                   	push   %edi
  8003ba:	56                   	push   %esi
  8003bb:	53                   	push   %ebx
  8003bc:	83 ec 1c             	sub    $0x1c,%esp
  8003bf:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  8003c2:	e8 89 11 00 00       	call   801550 <sys_time_msec>
  8003c7:	03 45 0c             	add    0xc(%ebp),%eax
  8003ca:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  8003cc:	c7 05 00 40 80 00 85 	movl   $0x802f85,0x804000
  8003d3:	2f 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8003d6:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8003d9:	eb 33                	jmp    80040e <timer+0x5c>
		if (r < 0)
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	78 45                	js     800424 <timer+0x72>
		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8003df:	6a 00                	push   $0x0
  8003e1:	6a 00                	push   $0x0
  8003e3:	6a 0c                	push   $0xc
  8003e5:	56                   	push   %esi
  8003e6:	e8 cc 14 00 00       	call   8018b7 <ipc_send>
  8003eb:	83 c4 10             	add    $0x10,%esp
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8003ee:	83 ec 04             	sub    $0x4,%esp
  8003f1:	6a 00                	push   $0x0
  8003f3:	6a 00                	push   $0x0
  8003f5:	57                   	push   %edi
  8003f6:	e8 4f 14 00 00       	call   80184a <ipc_recv>
  8003fb:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  8003fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800400:	83 c4 10             	add    $0x10,%esp
  800403:	39 f0                	cmp    %esi,%eax
  800405:	75 2f                	jne    800436 <timer+0x84>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
				continue;
			}

			stop = sys_time_msec() + to;
  800407:	e8 44 11 00 00       	call   801550 <sys_time_msec>
  80040c:	01 c3                	add    %eax,%ebx
		while((r = sys_time_msec()) < stop && r >= 0) {
  80040e:	e8 3d 11 00 00       	call   801550 <sys_time_msec>
  800413:	89 c2                	mov    %eax,%edx
  800415:	85 c0                	test   %eax,%eax
  800417:	78 c2                	js     8003db <timer+0x29>
  800419:	39 d8                	cmp    %ebx,%eax
  80041b:	73 be                	jae    8003db <timer+0x29>
			sys_yield();
  80041d:	e8 e1 0f 00 00       	call   801403 <sys_yield>
  800422:	eb ea                	jmp    80040e <timer+0x5c>
			panic("sys_time_msec: %e", r);
  800424:	52                   	push   %edx
  800425:	68 8e 2f 80 00       	push   $0x802f8e
  80042a:	6a 0f                	push   $0xf
  80042c:	68 a0 2f 80 00       	push   $0x802fa0
  800431:	e8 96 04 00 00       	call   8008cc <_panic>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  800436:	83 ec 08             	sub    $0x8,%esp
  800439:	50                   	push   %eax
  80043a:	68 ac 2f 80 00       	push   $0x802fac
  80043f:	e8 6f 05 00 00       	call   8009b3 <cprintf>
				continue;
  800444:	83 c4 10             	add    $0x10,%esp
  800447:	eb a5                	jmp    8003ee <timer+0x3c>

00800449 <input>:
// 这里值得注意的一点是 有可能收包（sys_netpacket_recv）太快, 
// 发送给服务器时 服务器可能读取速度慢了 导致相应的内容被冲刷, 所以这里用一个临时存储
// 将收到的数据保存在input helper environment里
void
input(envid_t ns_envid)
{
  800449:	f3 0f 1e fb          	endbr32 
  80044d:	55                   	push   %ebp
  80044e:	89 e5                	mov    %esp,%ebp
  800450:	57                   	push   %edi
  800451:	56                   	push   %esi
  800452:	53                   	push   %ebx
  800453:	83 ec 0c             	sub    $0xc,%esp
  800456:	8b 7d 08             	mov    0x8(%ebp),%edi
	binaryname = "ns_input";
  800459:	c7 05 00 40 80 00 e7 	movl   $0x802fe7,0x804000
  800460:	2f 80 00 
  800463:	bb 00 b0 fe 0f       	mov    $0xffeb000,%ebx
	int i, r;
	int32_t length;
	struct jif_pkt *cpkt = pkt;
	
	for(i = 0; i < 10; i++)
		if ((r = sys_page_alloc(0, (void*)((uintptr_t)pkt + i * PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  800468:	83 ec 04             	sub    $0x4,%esp
  80046b:	6a 07                	push   $0x7
  80046d:	53                   	push   %ebx
  80046e:	6a 00                	push   $0x0
  800470:	e8 b1 0f 00 00       	call   801426 <sys_page_alloc>
  800475:	83 c4 10             	add    $0x10,%esp
  800478:	85 c0                	test   %eax,%eax
  80047a:	78 1a                	js     800496 <input+0x4d>
  80047c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for(i = 0; i < 10; i++)
  800482:	81 fb 00 50 ff 0f    	cmp    $0xfff5000,%ebx
  800488:	75 de                	jne    800468 <input+0x1f>
	struct jif_pkt *cpkt = pkt;
  80048a:	be 00 b0 fe 0f       	mov    $0xffeb000,%esi
			panic("sys_page_alloc: %e", r);
	
	i = 0;
  80048f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800494:	eb 17                	jmp    8004ad <input+0x64>
			panic("sys_page_alloc: %e", r);
  800496:	50                   	push   %eax
  800497:	68 f0 2f 80 00       	push   $0x802ff0
  80049c:	6a 34                	push   $0x34
  80049e:	68 03 30 80 00       	push   $0x803003
  8004a3:	e8 24 04 00 00       	call   8008cc <_panic>
	while(1) {
		while((length = sys_netpacket_recv((void*)((uintptr_t)cpkt + sizeof(cpkt->jp_len)), PGSIZE - sizeof(cpkt->jp_len))) < 0) {
			// cprintf("len: %d\n", length);
			sys_yield();
  8004a8:	e8 56 0f 00 00       	call   801403 <sys_yield>
		while((length = sys_netpacket_recv((void*)((uintptr_t)cpkt + sizeof(cpkt->jp_len)), PGSIZE - sizeof(cpkt->jp_len))) < 0) {
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	68 fc 0f 00 00       	push   $0xffc
  8004b5:	8d 46 04             	lea    0x4(%esi),%eax
  8004b8:	50                   	push   %eax
  8004b9:	e8 da 10 00 00       	call   801598 <sys_netpacket_recv>
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	85 c0                	test   %eax,%eax
  8004c3:	78 e3                	js     8004a8 <input+0x5f>
		}

		cpkt->jp_len = length;
  8004c5:	89 06                	mov    %eax,(%esi)
		ipc_send(ns_envid, NSREQ_INPUT, cpkt, PTE_P | PTE_U);
  8004c7:	6a 05                	push   $0x5
  8004c9:	56                   	push   %esi
  8004ca:	6a 0a                	push   $0xa
  8004cc:	57                   	push   %edi
  8004cd:	e8 e5 13 00 00       	call   8018b7 <ipc_send>
		i = (i + 1) % 10;
  8004d2:	8d 4b 01             	lea    0x1(%ebx),%ecx
  8004d5:	b8 67 66 66 66       	mov    $0x66666667,%eax
  8004da:	f7 e9                	imul   %ecx
  8004dc:	c1 fa 02             	sar    $0x2,%edx
  8004df:	89 c8                	mov    %ecx,%eax
  8004e1:	c1 f8 1f             	sar    $0x1f,%eax
  8004e4:	29 c2                	sub    %eax,%edx
  8004e6:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8004e9:	01 c0                	add    %eax,%eax
  8004eb:	29 c1                	sub    %eax,%ecx
  8004ed:	89 cb                	mov    %ecx,%ebx
		cpkt = (struct jif_pkt*)((uintptr_t)pkt + i * PGSIZE);
  8004ef:	89 ce                	mov    %ecx,%esi
  8004f1:	c1 e6 0c             	shl    $0xc,%esi
  8004f4:	81 c6 00 b0 fe 0f    	add    $0xffeb000,%esi
		sys_yield();
  8004fa:	e8 04 0f 00 00       	call   801403 <sys_yield>
		while((length = sys_netpacket_recv((void*)((uintptr_t)cpkt + sizeof(cpkt->jp_len)), PGSIZE - sizeof(cpkt->jp_len))) < 0) {
  8004ff:	83 c4 10             	add    $0x10,%esp
  800502:	eb a9                	jmp    8004ad <input+0x64>

00800504 <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  800504:	f3 0f 1e fb          	endbr32 
  800508:	55                   	push   %ebp
  800509:	89 e5                	mov    %esp,%ebp
  80050b:	56                   	push   %esi
  80050c:	53                   	push   %ebx
  80050d:	83 ec 10             	sub    $0x10,%esp
	binaryname = "ns_output";
  800510:	c7 05 00 40 80 00 0f 	movl   $0x80300f,0x804000
  800517:	30 80 00 
	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
	int perm; envid_t envid;
	while(1){
		if (ipc_recv(&envid, &nsipcbuf, &perm) != NSREQ_OUTPUT)
  80051a:	8d 75 f4             	lea    -0xc(%ebp),%esi
  80051d:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  800520:	eb 1f                	jmp    800541 <output+0x3d>
			continue;
		while(sys_netpacket_try_send(&nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len)<0){
			// 说明tx_desc_ring还没准备/队列已满
			sys_yield();
  800522:	e8 dc 0e 00 00       	call   801403 <sys_yield>
		while(sys_netpacket_try_send(&nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len)<0){
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	ff 35 00 70 80 00    	pushl  0x807000
  800530:	68 04 70 80 00       	push   $0x807004
  800535:	e8 39 10 00 00       	call   801573 <sys_netpacket_try_send>
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	85 c0                	test   %eax,%eax
  80053f:	78 e1                	js     800522 <output+0x1e>
		if (ipc_recv(&envid, &nsipcbuf, &perm) != NSREQ_OUTPUT)
  800541:	83 ec 04             	sub    $0x4,%esp
  800544:	56                   	push   %esi
  800545:	68 00 70 80 00       	push   $0x807000
  80054a:	53                   	push   %ebx
  80054b:	e8 fa 12 00 00       	call   80184a <ipc_recv>
  800550:	83 c4 10             	add    $0x10,%esp
  800553:	83 f8 0b             	cmp    $0xb,%eax
  800556:	75 e9                	jne    800541 <output+0x3d>
  800558:	eb cd                	jmp    800527 <output+0x23>

0080055a <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  80055a:	f3 0f 1e fb          	endbr32 
  80055e:	55                   	push   %ebp
  80055f:	89 e5                	mov    %esp,%ebp
  800561:	57                   	push   %edi
  800562:	56                   	push   %esi
  800563:	53                   	push   %ebx
  800564:	83 ec 18             	sub    $0x18,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800567:	8b 45 08             	mov    0x8(%ebp),%eax
  80056a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  80056d:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
  ap = (u8_t *)&s_addr;
  800571:	8d 75 f0             	lea    -0x10(%ebp),%esi
  rp = str;
  800574:	bf 08 50 80 00       	mov    $0x805008,%edi
  800579:	eb 2e                	jmp    8005a9 <inet_ntoa+0x4f>
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
  80057b:	0f b6 c8             	movzbl %al,%ecx
  80057e:	0f b6 4c 0d ed       	movzbl -0x13(%ebp,%ecx,1),%ecx
  800583:	88 0a                	mov    %cl,(%edx)
  800585:	83 c2 01             	add    $0x1,%edx
    while(i--)
  800588:	83 e8 01             	sub    $0x1,%eax
  80058b:	3c ff                	cmp    $0xff,%al
  80058d:	75 ec                	jne    80057b <inet_ntoa+0x21>
  80058f:	0f b6 db             	movzbl %bl,%ebx
  800592:	01 fb                	add    %edi,%ebx
    *rp++ = '.';
  800594:	8d 7b 01             	lea    0x1(%ebx),%edi
  800597:	c6 03 2e             	movb   $0x2e,(%ebx)
  80059a:	83 c6 01             	add    $0x1,%esi
  for(n = 0; n < 4; n++) {
  80059d:	80 45 df 01          	addb   $0x1,-0x21(%ebp)
  8005a1:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
  8005a5:	3c 04                	cmp    $0x4,%al
  8005a7:	74 45                	je     8005ee <inet_ntoa+0x94>
  rp = str;
  8005a9:	bb 00 00 00 00       	mov    $0x0,%ebx
      rem = *ap % (u8_t)10;
  8005ae:	0f b6 16             	movzbl (%esi),%edx
      *ap /= (u8_t)10;
  8005b1:	0f b6 ca             	movzbl %dl,%ecx
  8005b4:	8d 04 89             	lea    (%ecx,%ecx,4),%eax
  8005b7:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
  8005ba:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005bd:	66 c1 e8 0b          	shr    $0xb,%ax
  8005c1:	88 06                	mov    %al,(%esi)
  8005c3:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  8005c5:	83 c3 01             	add    $0x1,%ebx
  8005c8:	0f b6 c9             	movzbl %cl,%ecx
  8005cb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
      rem = *ap % (u8_t)10;
  8005ce:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005d1:	01 c0                	add    %eax,%eax
  8005d3:	89 d1                	mov    %edx,%ecx
  8005d5:	29 c1                	sub    %eax,%ecx
  8005d7:	89 c8                	mov    %ecx,%eax
      inv[i++] = '0' + rem;
  8005d9:	83 c0 30             	add    $0x30,%eax
  8005dc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005df:	88 44 0d ed          	mov    %al,-0x13(%ebp,%ecx,1)
    } while(*ap);
  8005e3:	80 fa 09             	cmp    $0x9,%dl
  8005e6:	77 c6                	ja     8005ae <inet_ntoa+0x54>
  8005e8:	89 fa                	mov    %edi,%edx
      inv[i++] = '0' + rem;
  8005ea:	89 d8                	mov    %ebx,%eax
  8005ec:	eb 9a                	jmp    800588 <inet_ntoa+0x2e>
    ap++;
  }
  *--rp = 0;
  8005ee:	c6 03 00             	movb   $0x0,(%ebx)
  return str;
}
  8005f1:	b8 08 50 80 00       	mov    $0x805008,%eax
  8005f6:	83 c4 18             	add    $0x18,%esp
  8005f9:	5b                   	pop    %ebx
  8005fa:	5e                   	pop    %esi
  8005fb:	5f                   	pop    %edi
  8005fc:	5d                   	pop    %ebp
  8005fd:	c3                   	ret    

008005fe <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  8005fe:	f3 0f 1e fb          	endbr32 
  800602:	55                   	push   %ebp
  800603:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800605:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800609:	66 c1 c0 08          	rol    $0x8,%ax
}
  80060d:	5d                   	pop    %ebp
  80060e:	c3                   	ret    

0080060f <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  80060f:	f3 0f 1e fb          	endbr32 
  800613:	55                   	push   %ebp
  800614:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800616:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80061a:	66 c1 c0 08          	rol    $0x8,%ax
  return htons(n);
}
  80061e:	5d                   	pop    %ebp
  80061f:	c3                   	ret    

00800620 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  800620:	f3 0f 1e fb          	endbr32 
  800624:	55                   	push   %ebp
  800625:	89 e5                	mov    %esp,%ebp
  800627:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  80062a:	89 d0                	mov    %edx,%eax
  80062c:	c1 e0 18             	shl    $0x18,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
  80062f:	89 d1                	mov    %edx,%ecx
  800631:	c1 e9 18             	shr    $0x18,%ecx
    ((n & 0xff0000UL) >> 8) |
  800634:	09 c8                	or     %ecx,%eax
    ((n & 0xff00) << 8) |
  800636:	89 d1                	mov    %edx,%ecx
  800638:	c1 e1 08             	shl    $0x8,%ecx
  80063b:	81 e1 00 00 ff 00    	and    $0xff0000,%ecx
    ((n & 0xff0000UL) >> 8) |
  800641:	09 c8                	or     %ecx,%eax
  800643:	c1 ea 08             	shr    $0x8,%edx
  800646:	81 e2 00 ff 00 00    	and    $0xff00,%edx
  80064c:	09 d0                	or     %edx,%eax
}
  80064e:	5d                   	pop    %ebp
  80064f:	c3                   	ret    

00800650 <inet_aton>:
{
  800650:	f3 0f 1e fb          	endbr32 
  800654:	55                   	push   %ebp
  800655:	89 e5                	mov    %esp,%ebp
  800657:	57                   	push   %edi
  800658:	56                   	push   %esi
  800659:	53                   	push   %ebx
  80065a:	83 ec 2c             	sub    $0x2c,%esp
  80065d:	8b 55 08             	mov    0x8(%ebp),%edx
  c = *cp;
  800660:	0f be 02             	movsbl (%edx),%eax
  u32_t *pp = parts;
  800663:	8d 75 d8             	lea    -0x28(%ebp),%esi
  800666:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800669:	e9 a7 00 00 00       	jmp    800715 <inet_aton+0xc5>
      c = *++cp;
  80066e:	0f b6 42 01          	movzbl 0x1(%edx),%eax
      if (c == 'x' || c == 'X') {
  800672:	89 c1                	mov    %eax,%ecx
  800674:	83 e1 df             	and    $0xffffffdf,%ecx
  800677:	80 f9 58             	cmp    $0x58,%cl
  80067a:	74 10                	je     80068c <inet_aton+0x3c>
      c = *++cp;
  80067c:	83 c2 01             	add    $0x1,%edx
  80067f:	0f be c0             	movsbl %al,%eax
        base = 8;
  800682:	be 08 00 00 00       	mov    $0x8,%esi
  800687:	e9 a3 00 00 00       	jmp    80072f <inet_aton+0xdf>
        c = *++cp;
  80068c:	0f be 42 02          	movsbl 0x2(%edx),%eax
  800690:	8d 52 02             	lea    0x2(%edx),%edx
        base = 16;
  800693:	be 10 00 00 00       	mov    $0x10,%esi
  800698:	e9 92 00 00 00       	jmp    80072f <inet_aton+0xdf>
      } else if (base == 16 && isxdigit(c)) {
  80069d:	83 fe 10             	cmp    $0x10,%esi
  8006a0:	75 4d                	jne    8006ef <inet_aton+0x9f>
  8006a2:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  8006a5:	88 4d d3             	mov    %cl,-0x2d(%ebp)
  8006a8:	89 c1                	mov    %eax,%ecx
  8006aa:	83 e1 df             	and    $0xffffffdf,%ecx
  8006ad:	83 e9 41             	sub    $0x41,%ecx
  8006b0:	80 f9 05             	cmp    $0x5,%cl
  8006b3:	77 3a                	ja     8006ef <inet_aton+0x9f>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  8006b5:	c1 e3 04             	shl    $0x4,%ebx
  8006b8:	83 c0 0a             	add    $0xa,%eax
  8006bb:	80 7d d3 1a          	cmpb   $0x1a,-0x2d(%ebp)
  8006bf:	19 c9                	sbb    %ecx,%ecx
  8006c1:	83 e1 20             	and    $0x20,%ecx
  8006c4:	83 c1 41             	add    $0x41,%ecx
  8006c7:	29 c8                	sub    %ecx,%eax
  8006c9:	09 c3                	or     %eax,%ebx
        c = *++cp;
  8006cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006ce:	0f be 40 01          	movsbl 0x1(%eax),%eax
  8006d2:	83 c2 01             	add    $0x1,%edx
  8006d5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
      if (isdigit(c)) {
  8006d8:	89 c7                	mov    %eax,%edi
  8006da:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8006dd:	80 f9 09             	cmp    $0x9,%cl
  8006e0:	77 bb                	ja     80069d <inet_aton+0x4d>
        val = (val * base) + (int)(c - '0');
  8006e2:	0f af de             	imul   %esi,%ebx
  8006e5:	8d 5c 18 d0          	lea    -0x30(%eax,%ebx,1),%ebx
        c = *++cp;
  8006e9:	0f be 42 01          	movsbl 0x1(%edx),%eax
  8006ed:	eb e3                	jmp    8006d2 <inet_aton+0x82>
    if (c == '.') {
  8006ef:	83 f8 2e             	cmp    $0x2e,%eax
  8006f2:	75 42                	jne    800736 <inet_aton+0xe6>
      if (pp >= parts + 3)
  8006f4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8006f7:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8006fa:	39 c6                	cmp    %eax,%esi
  8006fc:	0f 84 16 01 00 00    	je     800818 <inet_aton+0x1c8>
      *pp++ = val;
  800702:	83 c6 04             	add    $0x4,%esi
  800705:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800708:	89 5e fc             	mov    %ebx,-0x4(%esi)
      c = *++cp;
  80070b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80070e:	8d 50 01             	lea    0x1(%eax),%edx
  800711:	0f be 40 01          	movsbl 0x1(%eax),%eax
    if (!isdigit(c))
  800715:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800718:	80 f9 09             	cmp    $0x9,%cl
  80071b:	0f 87 f0 00 00 00    	ja     800811 <inet_aton+0x1c1>
    base = 10;
  800721:	be 0a 00 00 00       	mov    $0xa,%esi
    if (c == '0') {
  800726:	83 f8 30             	cmp    $0x30,%eax
  800729:	0f 84 3f ff ff ff    	je     80066e <inet_aton+0x1e>
    base = 10;
  80072f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800734:	eb 9f                	jmp    8006d5 <inet_aton+0x85>
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800736:	85 c0                	test   %eax,%eax
  800738:	74 29                	je     800763 <inet_aton+0x113>
    return (0);
  80073a:	ba 00 00 00 00       	mov    $0x0,%edx
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80073f:	89 f9                	mov    %edi,%ecx
  800741:	80 f9 1f             	cmp    $0x1f,%cl
  800744:	0f 86 d3 00 00 00    	jbe    80081d <inet_aton+0x1cd>
  80074a:	84 c0                	test   %al,%al
  80074c:	0f 88 cb 00 00 00    	js     80081d <inet_aton+0x1cd>
  800752:	83 f8 20             	cmp    $0x20,%eax
  800755:	74 0c                	je     800763 <inet_aton+0x113>
  800757:	83 e8 09             	sub    $0x9,%eax
  80075a:	83 f8 04             	cmp    $0x4,%eax
  80075d:	0f 87 ba 00 00 00    	ja     80081d <inet_aton+0x1cd>
  n = pp - parts + 1;
  800763:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800766:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800769:	29 c6                	sub    %eax,%esi
  80076b:	89 f0                	mov    %esi,%eax
  80076d:	c1 f8 02             	sar    $0x2,%eax
  800770:	8d 50 01             	lea    0x1(%eax),%edx
  switch (n) {
  800773:	83 f8 02             	cmp    $0x2,%eax
  800776:	74 7a                	je     8007f2 <inet_aton+0x1a2>
  800778:	83 fa 03             	cmp    $0x3,%edx
  80077b:	7f 49                	jg     8007c6 <inet_aton+0x176>
  80077d:	85 d2                	test   %edx,%edx
  80077f:	0f 84 98 00 00 00    	je     80081d <inet_aton+0x1cd>
  800785:	83 fa 02             	cmp    $0x2,%edx
  800788:	75 19                	jne    8007a3 <inet_aton+0x153>
      return (0);
  80078a:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xffffffUL)
  80078f:	81 fb ff ff ff 00    	cmp    $0xffffff,%ebx
  800795:	0f 87 82 00 00 00    	ja     80081d <inet_aton+0x1cd>
    val |= parts[0] << 24;
  80079b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80079e:	c1 e0 18             	shl    $0x18,%eax
  8007a1:	09 c3                	or     %eax,%ebx
  return (1);
  8007a3:	ba 01 00 00 00       	mov    $0x1,%edx
  if (addr)
  8007a8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007ac:	74 6f                	je     80081d <inet_aton+0x1cd>
    addr->s_addr = htonl(val);
  8007ae:	83 ec 0c             	sub    $0xc,%esp
  8007b1:	53                   	push   %ebx
  8007b2:	e8 69 fe ff ff       	call   800620 <htonl>
  8007b7:	83 c4 10             	add    $0x10,%esp
  8007ba:	8b 75 0c             	mov    0xc(%ebp),%esi
  8007bd:	89 06                	mov    %eax,(%esi)
  return (1);
  8007bf:	ba 01 00 00 00       	mov    $0x1,%edx
  8007c4:	eb 57                	jmp    80081d <inet_aton+0x1cd>
  switch (n) {
  8007c6:	83 fa 04             	cmp    $0x4,%edx
  8007c9:	75 d8                	jne    8007a3 <inet_aton+0x153>
      return (0);
  8007cb:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xff)
  8007d0:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
  8007d6:	77 45                	ja     80081d <inet_aton+0x1cd>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  8007d8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007db:	c1 e0 18             	shl    $0x18,%eax
  8007de:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007e1:	c1 e2 10             	shl    $0x10,%edx
  8007e4:	09 d0                	or     %edx,%eax
  8007e6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007e9:	c1 e2 08             	shl    $0x8,%edx
  8007ec:	09 d0                	or     %edx,%eax
  8007ee:	09 c3                	or     %eax,%ebx
    break;
  8007f0:	eb b1                	jmp    8007a3 <inet_aton+0x153>
      return (0);
  8007f2:	ba 00 00 00 00       	mov    $0x0,%edx
    if (val > 0xffff)
  8007f7:	81 fb ff ff 00 00    	cmp    $0xffff,%ebx
  8007fd:	77 1e                	ja     80081d <inet_aton+0x1cd>
    val |= (parts[0] << 24) | (parts[1] << 16);
  8007ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800802:	c1 e0 18             	shl    $0x18,%eax
  800805:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800808:	c1 e2 10             	shl    $0x10,%edx
  80080b:	09 d0                	or     %edx,%eax
  80080d:	09 c3                	or     %eax,%ebx
    break;
  80080f:	eb 92                	jmp    8007a3 <inet_aton+0x153>
      return (0);
  800811:	ba 00 00 00 00       	mov    $0x0,%edx
  800816:	eb 05                	jmp    80081d <inet_aton+0x1cd>
        return (0);
  800818:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80081d:	89 d0                	mov    %edx,%eax
  80081f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800822:	5b                   	pop    %ebx
  800823:	5e                   	pop    %esi
  800824:	5f                   	pop    %edi
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <inet_addr>:
{
  800827:	f3 0f 1e fb          	endbr32 
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	83 ec 20             	sub    $0x20,%esp
  if (inet_aton(cp, &val)) {
  800831:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800834:	50                   	push   %eax
  800835:	ff 75 08             	pushl  0x8(%ebp)
  800838:	e8 13 fe ff ff       	call   800650 <inet_aton>
  80083d:	83 c4 10             	add    $0x10,%esp
    return (val.s_addr);
  800840:	85 c0                	test   %eax,%eax
  800842:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800847:	0f 45 45 f4          	cmovne -0xc(%ebp),%eax
}
  80084b:	c9                   	leave  
  80084c:	c3                   	ret    

0080084d <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80084d:	f3 0f 1e fb          	endbr32 
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	83 ec 14             	sub    $0x14,%esp
  return htonl(n);
  800857:	ff 75 08             	pushl  0x8(%ebp)
  80085a:	e8 c1 fd ff ff       	call   800620 <htonl>
  80085f:	83 c4 10             	add    $0x10,%esp
}
  800862:	c9                   	leave  
  800863:	c3                   	ret    

00800864 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800864:	f3 0f 1e fb          	endbr32 
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	56                   	push   %esi
  80086c:	53                   	push   %ebx
  80086d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800870:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800873:	e8 68 0b 00 00       	call   8013e0 <sys_getenvid>
  800878:	25 ff 03 00 00       	and    $0x3ff,%eax
  80087d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800880:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800885:	a3 20 50 80 00       	mov    %eax,0x805020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80088a:	85 db                	test   %ebx,%ebx
  80088c:	7e 07                	jle    800895 <libmain+0x31>
		binaryname = argv[0];
  80088e:	8b 06                	mov    (%esi),%eax
  800890:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800895:	83 ec 08             	sub    $0x8,%esp
  800898:	56                   	push   %esi
  800899:	53                   	push   %ebx
  80089a:	e8 94 f7 ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80089f:	e8 0a 00 00 00       	call   8008ae <exit>
}
  8008a4:	83 c4 10             	add    $0x10,%esp
  8008a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008aa:	5b                   	pop    %ebx
  8008ab:	5e                   	pop    %esi
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8008ae:	f3 0f 1e fb          	endbr32 
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  8008b8:	e8 83 12 00 00       	call   801b40 <close_all>
	sys_env_destroy(0);
  8008bd:	83 ec 0c             	sub    $0xc,%esp
  8008c0:	6a 00                	push   $0x0
  8008c2:	e8 f5 0a 00 00       	call   8013bc <sys_env_destroy>
}
  8008c7:	83 c4 10             	add    $0x10,%esp
  8008ca:	c9                   	leave  
  8008cb:	c3                   	ret    

008008cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8008cc:	f3 0f 1e fb          	endbr32 
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	56                   	push   %esi
  8008d4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8008d5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8008d8:	8b 35 00 40 80 00    	mov    0x804000,%esi
  8008de:	e8 fd 0a 00 00       	call   8013e0 <sys_getenvid>
  8008e3:	83 ec 0c             	sub    $0xc,%esp
  8008e6:	ff 75 0c             	pushl  0xc(%ebp)
  8008e9:	ff 75 08             	pushl  0x8(%ebp)
  8008ec:	56                   	push   %esi
  8008ed:	50                   	push   %eax
  8008ee:	68 24 30 80 00       	push   $0x803024
  8008f3:	e8 bb 00 00 00       	call   8009b3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8008f8:	83 c4 18             	add    $0x18,%esp
  8008fb:	53                   	push   %ebx
  8008fc:	ff 75 10             	pushl  0x10(%ebp)
  8008ff:	e8 5a 00 00 00       	call   80095e <vcprintf>
	cprintf("\n");
  800904:	c7 04 24 5b 2f 80 00 	movl   $0x802f5b,(%esp)
  80090b:	e8 a3 00 00 00       	call   8009b3 <cprintf>
  800910:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800913:	cc                   	int3   
  800914:	eb fd                	jmp    800913 <_panic+0x47>

00800916 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800916:	f3 0f 1e fb          	endbr32 
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	53                   	push   %ebx
  80091e:	83 ec 04             	sub    $0x4,%esp
  800921:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800924:	8b 13                	mov    (%ebx),%edx
  800926:	8d 42 01             	lea    0x1(%edx),%eax
  800929:	89 03                	mov    %eax,(%ebx)
  80092b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800932:	3d ff 00 00 00       	cmp    $0xff,%eax
  800937:	74 09                	je     800942 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800939:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80093d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800940:	c9                   	leave  
  800941:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800942:	83 ec 08             	sub    $0x8,%esp
  800945:	68 ff 00 00 00       	push   $0xff
  80094a:	8d 43 08             	lea    0x8(%ebx),%eax
  80094d:	50                   	push   %eax
  80094e:	e8 24 0a 00 00       	call   801377 <sys_cputs>
		b->idx = 0;
  800953:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800959:	83 c4 10             	add    $0x10,%esp
  80095c:	eb db                	jmp    800939 <putch+0x23>

0080095e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80095e:	f3 0f 1e fb          	endbr32 
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80096b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800972:	00 00 00 
	b.cnt = 0;
  800975:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80097c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80097f:	ff 75 0c             	pushl  0xc(%ebp)
  800982:	ff 75 08             	pushl  0x8(%ebp)
  800985:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80098b:	50                   	push   %eax
  80098c:	68 16 09 80 00       	push   $0x800916
  800991:	e8 20 01 00 00       	call   800ab6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800996:	83 c4 08             	add    $0x8,%esp
  800999:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80099f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8009a5:	50                   	push   %eax
  8009a6:	e8 cc 09 00 00       	call   801377 <sys_cputs>

	return b.cnt;
}
  8009ab:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8009b1:	c9                   	leave  
  8009b2:	c3                   	ret    

008009b3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8009b3:	f3 0f 1e fb          	endbr32 
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8009bd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8009c0:	50                   	push   %eax
  8009c1:	ff 75 08             	pushl  0x8(%ebp)
  8009c4:	e8 95 ff ff ff       	call   80095e <vcprintf>
	va_end(ap);

	return cnt;
}
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	57                   	push   %edi
  8009cf:	56                   	push   %esi
  8009d0:	53                   	push   %ebx
  8009d1:	83 ec 1c             	sub    $0x1c,%esp
  8009d4:	89 c7                	mov    %eax,%edi
  8009d6:	89 d6                	mov    %edx,%esi
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009de:	89 d1                	mov    %edx,%ecx
  8009e0:	89 c2                	mov    %eax,%edx
  8009e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009e5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009eb:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  8009ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009f1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8009f8:	39 c2                	cmp    %eax,%edx
  8009fa:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8009fd:	72 3e                	jb     800a3d <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8009ff:	83 ec 0c             	sub    $0xc,%esp
  800a02:	ff 75 18             	pushl  0x18(%ebp)
  800a05:	83 eb 01             	sub    $0x1,%ebx
  800a08:	53                   	push   %ebx
  800a09:	50                   	push   %eax
  800a0a:	83 ec 08             	sub    $0x8,%esp
  800a0d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800a10:	ff 75 e0             	pushl  -0x20(%ebp)
  800a13:	ff 75 dc             	pushl  -0x24(%ebp)
  800a16:	ff 75 d8             	pushl  -0x28(%ebp)
  800a19:	e8 12 22 00 00       	call   802c30 <__udivdi3>
  800a1e:	83 c4 18             	add    $0x18,%esp
  800a21:	52                   	push   %edx
  800a22:	50                   	push   %eax
  800a23:	89 f2                	mov    %esi,%edx
  800a25:	89 f8                	mov    %edi,%eax
  800a27:	e8 9f ff ff ff       	call   8009cb <printnum>
  800a2c:	83 c4 20             	add    $0x20,%esp
  800a2f:	eb 13                	jmp    800a44 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800a31:	83 ec 08             	sub    $0x8,%esp
  800a34:	56                   	push   %esi
  800a35:	ff 75 18             	pushl  0x18(%ebp)
  800a38:	ff d7                	call   *%edi
  800a3a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800a3d:	83 eb 01             	sub    $0x1,%ebx
  800a40:	85 db                	test   %ebx,%ebx
  800a42:	7f ed                	jg     800a31 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800a44:	83 ec 08             	sub    $0x8,%esp
  800a47:	56                   	push   %esi
  800a48:	83 ec 04             	sub    $0x4,%esp
  800a4b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800a4e:	ff 75 e0             	pushl  -0x20(%ebp)
  800a51:	ff 75 dc             	pushl  -0x24(%ebp)
  800a54:	ff 75 d8             	pushl  -0x28(%ebp)
  800a57:	e8 e4 22 00 00       	call   802d40 <__umoddi3>
  800a5c:	83 c4 14             	add    $0x14,%esp
  800a5f:	0f be 80 47 30 80 00 	movsbl 0x803047(%eax),%eax
  800a66:	50                   	push   %eax
  800a67:	ff d7                	call   *%edi
}
  800a69:	83 c4 10             	add    $0x10,%esp
  800a6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a6f:	5b                   	pop    %ebx
  800a70:	5e                   	pop    %esi
  800a71:	5f                   	pop    %edi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800a74:	f3 0f 1e fb          	endbr32 
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800a7e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800a82:	8b 10                	mov    (%eax),%edx
  800a84:	3b 50 04             	cmp    0x4(%eax),%edx
  800a87:	73 0a                	jae    800a93 <sprintputch+0x1f>
		*b->buf++ = ch;
  800a89:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a8c:	89 08                	mov    %ecx,(%eax)
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a91:	88 02                	mov    %al,(%edx)
}
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <printfmt>:
{
  800a95:	f3 0f 1e fb          	endbr32 
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800a9f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800aa2:	50                   	push   %eax
  800aa3:	ff 75 10             	pushl  0x10(%ebp)
  800aa6:	ff 75 0c             	pushl  0xc(%ebp)
  800aa9:	ff 75 08             	pushl  0x8(%ebp)
  800aac:	e8 05 00 00 00       	call   800ab6 <vprintfmt>
}
  800ab1:	83 c4 10             	add    $0x10,%esp
  800ab4:	c9                   	leave  
  800ab5:	c3                   	ret    

00800ab6 <vprintfmt>:
{
  800ab6:	f3 0f 1e fb          	endbr32 
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
  800ac0:	83 ec 3c             	sub    $0x3c,%esp
  800ac3:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac9:	8b 7d 10             	mov    0x10(%ebp),%edi
  800acc:	e9 8e 03 00 00       	jmp    800e5f <vprintfmt+0x3a9>
		padc = ' ';
  800ad1:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800ad5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800adc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800ae3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800aea:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800aef:	8d 47 01             	lea    0x1(%edi),%eax
  800af2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800af5:	0f b6 17             	movzbl (%edi),%edx
  800af8:	8d 42 dd             	lea    -0x23(%edx),%eax
  800afb:	3c 55                	cmp    $0x55,%al
  800afd:	0f 87 df 03 00 00    	ja     800ee2 <vprintfmt+0x42c>
  800b03:	0f b6 c0             	movzbl %al,%eax
  800b06:	3e ff 24 85 80 31 80 	notrack jmp *0x803180(,%eax,4)
  800b0d:	00 
  800b0e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800b11:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800b15:	eb d8                	jmp    800aef <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800b17:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b1a:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800b1e:	eb cf                	jmp    800aef <vprintfmt+0x39>
  800b20:	0f b6 d2             	movzbl %dl,%edx
  800b23:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800b26:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800b2e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800b31:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800b35:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800b38:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800b3b:	83 f9 09             	cmp    $0x9,%ecx
  800b3e:	77 55                	ja     800b95 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800b40:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800b43:	eb e9                	jmp    800b2e <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800b45:	8b 45 14             	mov    0x14(%ebp),%eax
  800b48:	8b 00                	mov    (%eax),%eax
  800b4a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b4d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b50:	8d 40 04             	lea    0x4(%eax),%eax
  800b53:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800b56:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800b59:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b5d:	79 90                	jns    800aef <vprintfmt+0x39>
				width = precision, precision = -1;
  800b5f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b62:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b65:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800b6c:	eb 81                	jmp    800aef <vprintfmt+0x39>
  800b6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b71:	85 c0                	test   %eax,%eax
  800b73:	ba 00 00 00 00       	mov    $0x0,%edx
  800b78:	0f 49 d0             	cmovns %eax,%edx
  800b7b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800b7e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800b81:	e9 69 ff ff ff       	jmp    800aef <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800b86:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800b89:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800b90:	e9 5a ff ff ff       	jmp    800aef <vprintfmt+0x39>
  800b95:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800b98:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b9b:	eb bc                	jmp    800b59 <vprintfmt+0xa3>
			lflag++;
  800b9d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800ba0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800ba3:	e9 47 ff ff ff       	jmp    800aef <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800ba8:	8b 45 14             	mov    0x14(%ebp),%eax
  800bab:	8d 78 04             	lea    0x4(%eax),%edi
  800bae:	83 ec 08             	sub    $0x8,%esp
  800bb1:	53                   	push   %ebx
  800bb2:	ff 30                	pushl  (%eax)
  800bb4:	ff d6                	call   *%esi
			break;
  800bb6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800bb9:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800bbc:	e9 9b 02 00 00       	jmp    800e5c <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800bc1:	8b 45 14             	mov    0x14(%ebp),%eax
  800bc4:	8d 78 04             	lea    0x4(%eax),%edi
  800bc7:	8b 00                	mov    (%eax),%eax
  800bc9:	99                   	cltd   
  800bca:	31 d0                	xor    %edx,%eax
  800bcc:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800bce:	83 f8 0f             	cmp    $0xf,%eax
  800bd1:	7f 23                	jg     800bf6 <vprintfmt+0x140>
  800bd3:	8b 14 85 e0 32 80 00 	mov    0x8032e0(,%eax,4),%edx
  800bda:	85 d2                	test   %edx,%edx
  800bdc:	74 18                	je     800bf6 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800bde:	52                   	push   %edx
  800bdf:	68 fd 34 80 00       	push   $0x8034fd
  800be4:	53                   	push   %ebx
  800be5:	56                   	push   %esi
  800be6:	e8 aa fe ff ff       	call   800a95 <printfmt>
  800beb:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800bee:	89 7d 14             	mov    %edi,0x14(%ebp)
  800bf1:	e9 66 02 00 00       	jmp    800e5c <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800bf6:	50                   	push   %eax
  800bf7:	68 5f 30 80 00       	push   $0x80305f
  800bfc:	53                   	push   %ebx
  800bfd:	56                   	push   %esi
  800bfe:	e8 92 fe ff ff       	call   800a95 <printfmt>
  800c03:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800c06:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800c09:	e9 4e 02 00 00       	jmp    800e5c <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800c0e:	8b 45 14             	mov    0x14(%ebp),%eax
  800c11:	83 c0 04             	add    $0x4,%eax
  800c14:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800c17:	8b 45 14             	mov    0x14(%ebp),%eax
  800c1a:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800c1c:	85 d2                	test   %edx,%edx
  800c1e:	b8 58 30 80 00       	mov    $0x803058,%eax
  800c23:	0f 45 c2             	cmovne %edx,%eax
  800c26:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800c29:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800c2d:	7e 06                	jle    800c35 <vprintfmt+0x17f>
  800c2f:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800c33:	75 0d                	jne    800c42 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800c35:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800c38:	89 c7                	mov    %eax,%edi
  800c3a:	03 45 e0             	add    -0x20(%ebp),%eax
  800c3d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c40:	eb 55                	jmp    800c97 <vprintfmt+0x1e1>
  800c42:	83 ec 08             	sub    $0x8,%esp
  800c45:	ff 75 d8             	pushl  -0x28(%ebp)
  800c48:	ff 75 cc             	pushl  -0x34(%ebp)
  800c4b:	e8 46 03 00 00       	call   800f96 <strnlen>
  800c50:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800c53:	29 c2                	sub    %eax,%edx
  800c55:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800c58:	83 c4 10             	add    $0x10,%esp
  800c5b:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800c5d:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800c61:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800c64:	85 ff                	test   %edi,%edi
  800c66:	7e 11                	jle    800c79 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800c68:	83 ec 08             	sub    $0x8,%esp
  800c6b:	53                   	push   %ebx
  800c6c:	ff 75 e0             	pushl  -0x20(%ebp)
  800c6f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800c71:	83 ef 01             	sub    $0x1,%edi
  800c74:	83 c4 10             	add    $0x10,%esp
  800c77:	eb eb                	jmp    800c64 <vprintfmt+0x1ae>
  800c79:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800c7c:	85 d2                	test   %edx,%edx
  800c7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c83:	0f 49 c2             	cmovns %edx,%eax
  800c86:	29 c2                	sub    %eax,%edx
  800c88:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800c8b:	eb a8                	jmp    800c35 <vprintfmt+0x17f>
					putch(ch, putdat);
  800c8d:	83 ec 08             	sub    $0x8,%esp
  800c90:	53                   	push   %ebx
  800c91:	52                   	push   %edx
  800c92:	ff d6                	call   *%esi
  800c94:	83 c4 10             	add    $0x10,%esp
  800c97:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800c9a:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c9c:	83 c7 01             	add    $0x1,%edi
  800c9f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ca3:	0f be d0             	movsbl %al,%edx
  800ca6:	85 d2                	test   %edx,%edx
  800ca8:	74 4b                	je     800cf5 <vprintfmt+0x23f>
  800caa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800cae:	78 06                	js     800cb6 <vprintfmt+0x200>
  800cb0:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800cb4:	78 1e                	js     800cd4 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  800cb6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800cba:	74 d1                	je     800c8d <vprintfmt+0x1d7>
  800cbc:	0f be c0             	movsbl %al,%eax
  800cbf:	83 e8 20             	sub    $0x20,%eax
  800cc2:	83 f8 5e             	cmp    $0x5e,%eax
  800cc5:	76 c6                	jbe    800c8d <vprintfmt+0x1d7>
					putch('?', putdat);
  800cc7:	83 ec 08             	sub    $0x8,%esp
  800cca:	53                   	push   %ebx
  800ccb:	6a 3f                	push   $0x3f
  800ccd:	ff d6                	call   *%esi
  800ccf:	83 c4 10             	add    $0x10,%esp
  800cd2:	eb c3                	jmp    800c97 <vprintfmt+0x1e1>
  800cd4:	89 cf                	mov    %ecx,%edi
  800cd6:	eb 0e                	jmp    800ce6 <vprintfmt+0x230>
				putch(' ', putdat);
  800cd8:	83 ec 08             	sub    $0x8,%esp
  800cdb:	53                   	push   %ebx
  800cdc:	6a 20                	push   $0x20
  800cde:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800ce0:	83 ef 01             	sub    $0x1,%edi
  800ce3:	83 c4 10             	add    $0x10,%esp
  800ce6:	85 ff                	test   %edi,%edi
  800ce8:	7f ee                	jg     800cd8 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800cea:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800ced:	89 45 14             	mov    %eax,0x14(%ebp)
  800cf0:	e9 67 01 00 00       	jmp    800e5c <vprintfmt+0x3a6>
  800cf5:	89 cf                	mov    %ecx,%edi
  800cf7:	eb ed                	jmp    800ce6 <vprintfmt+0x230>
	if (lflag >= 2)
  800cf9:	83 f9 01             	cmp    $0x1,%ecx
  800cfc:	7f 1b                	jg     800d19 <vprintfmt+0x263>
	else if (lflag)
  800cfe:	85 c9                	test   %ecx,%ecx
  800d00:	74 63                	je     800d65 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800d02:	8b 45 14             	mov    0x14(%ebp),%eax
  800d05:	8b 00                	mov    (%eax),%eax
  800d07:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d0a:	99                   	cltd   
  800d0b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800d0e:	8b 45 14             	mov    0x14(%ebp),%eax
  800d11:	8d 40 04             	lea    0x4(%eax),%eax
  800d14:	89 45 14             	mov    %eax,0x14(%ebp)
  800d17:	eb 17                	jmp    800d30 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800d19:	8b 45 14             	mov    0x14(%ebp),%eax
  800d1c:	8b 50 04             	mov    0x4(%eax),%edx
  800d1f:	8b 00                	mov    (%eax),%eax
  800d21:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d24:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800d27:	8b 45 14             	mov    0x14(%ebp),%eax
  800d2a:	8d 40 08             	lea    0x8(%eax),%eax
  800d2d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800d30:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800d33:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800d36:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800d3b:	85 c9                	test   %ecx,%ecx
  800d3d:	0f 89 ff 00 00 00    	jns    800e42 <vprintfmt+0x38c>
				putch('-', putdat);
  800d43:	83 ec 08             	sub    $0x8,%esp
  800d46:	53                   	push   %ebx
  800d47:	6a 2d                	push   $0x2d
  800d49:	ff d6                	call   *%esi
				num = -(long long) num;
  800d4b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800d4e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800d51:	f7 da                	neg    %edx
  800d53:	83 d1 00             	adc    $0x0,%ecx
  800d56:	f7 d9                	neg    %ecx
  800d58:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800d5b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d60:	e9 dd 00 00 00       	jmp    800e42 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800d65:	8b 45 14             	mov    0x14(%ebp),%eax
  800d68:	8b 00                	mov    (%eax),%eax
  800d6a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d6d:	99                   	cltd   
  800d6e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800d71:	8b 45 14             	mov    0x14(%ebp),%eax
  800d74:	8d 40 04             	lea    0x4(%eax),%eax
  800d77:	89 45 14             	mov    %eax,0x14(%ebp)
  800d7a:	eb b4                	jmp    800d30 <vprintfmt+0x27a>
	if (lflag >= 2)
  800d7c:	83 f9 01             	cmp    $0x1,%ecx
  800d7f:	7f 1e                	jg     800d9f <vprintfmt+0x2e9>
	else if (lflag)
  800d81:	85 c9                	test   %ecx,%ecx
  800d83:	74 32                	je     800db7 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800d85:	8b 45 14             	mov    0x14(%ebp),%eax
  800d88:	8b 10                	mov    (%eax),%edx
  800d8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8f:	8d 40 04             	lea    0x4(%eax),%eax
  800d92:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800d95:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800d9a:	e9 a3 00 00 00       	jmp    800e42 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800d9f:	8b 45 14             	mov    0x14(%ebp),%eax
  800da2:	8b 10                	mov    (%eax),%edx
  800da4:	8b 48 04             	mov    0x4(%eax),%ecx
  800da7:	8d 40 08             	lea    0x8(%eax),%eax
  800daa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800dad:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800db2:	e9 8b 00 00 00       	jmp    800e42 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800db7:	8b 45 14             	mov    0x14(%ebp),%eax
  800dba:	8b 10                	mov    (%eax),%edx
  800dbc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc1:	8d 40 04             	lea    0x4(%eax),%eax
  800dc4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800dc7:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800dcc:	eb 74                	jmp    800e42 <vprintfmt+0x38c>
	if (lflag >= 2)
  800dce:	83 f9 01             	cmp    $0x1,%ecx
  800dd1:	7f 1b                	jg     800dee <vprintfmt+0x338>
	else if (lflag)
  800dd3:	85 c9                	test   %ecx,%ecx
  800dd5:	74 2c                	je     800e03 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800dd7:	8b 45 14             	mov    0x14(%ebp),%eax
  800dda:	8b 10                	mov    (%eax),%edx
  800ddc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de1:	8d 40 04             	lea    0x4(%eax),%eax
  800de4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800de7:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800dec:	eb 54                	jmp    800e42 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800dee:	8b 45 14             	mov    0x14(%ebp),%eax
  800df1:	8b 10                	mov    (%eax),%edx
  800df3:	8b 48 04             	mov    0x4(%eax),%ecx
  800df6:	8d 40 08             	lea    0x8(%eax),%eax
  800df9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800dfc:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800e01:	eb 3f                	jmp    800e42 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800e03:	8b 45 14             	mov    0x14(%ebp),%eax
  800e06:	8b 10                	mov    (%eax),%edx
  800e08:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0d:	8d 40 04             	lea    0x4(%eax),%eax
  800e10:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800e13:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800e18:	eb 28                	jmp    800e42 <vprintfmt+0x38c>
			putch('0', putdat);
  800e1a:	83 ec 08             	sub    $0x8,%esp
  800e1d:	53                   	push   %ebx
  800e1e:	6a 30                	push   $0x30
  800e20:	ff d6                	call   *%esi
			putch('x', putdat);
  800e22:	83 c4 08             	add    $0x8,%esp
  800e25:	53                   	push   %ebx
  800e26:	6a 78                	push   $0x78
  800e28:	ff d6                	call   *%esi
			num = (unsigned long long)
  800e2a:	8b 45 14             	mov    0x14(%ebp),%eax
  800e2d:	8b 10                	mov    (%eax),%edx
  800e2f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800e34:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800e37:	8d 40 04             	lea    0x4(%eax),%eax
  800e3a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800e3d:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800e42:	83 ec 0c             	sub    $0xc,%esp
  800e45:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800e49:	57                   	push   %edi
  800e4a:	ff 75 e0             	pushl  -0x20(%ebp)
  800e4d:	50                   	push   %eax
  800e4e:	51                   	push   %ecx
  800e4f:	52                   	push   %edx
  800e50:	89 da                	mov    %ebx,%edx
  800e52:	89 f0                	mov    %esi,%eax
  800e54:	e8 72 fb ff ff       	call   8009cb <printnum>
			break;
  800e59:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800e5c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  800e5f:	83 c7 01             	add    $0x1,%edi
  800e62:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e66:	83 f8 25             	cmp    $0x25,%eax
  800e69:	0f 84 62 fc ff ff    	je     800ad1 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	0f 84 8b 00 00 00    	je     800f02 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  800e77:	83 ec 08             	sub    $0x8,%esp
  800e7a:	53                   	push   %ebx
  800e7b:	50                   	push   %eax
  800e7c:	ff d6                	call   *%esi
  800e7e:	83 c4 10             	add    $0x10,%esp
  800e81:	eb dc                	jmp    800e5f <vprintfmt+0x3a9>
	if (lflag >= 2)
  800e83:	83 f9 01             	cmp    $0x1,%ecx
  800e86:	7f 1b                	jg     800ea3 <vprintfmt+0x3ed>
	else if (lflag)
  800e88:	85 c9                	test   %ecx,%ecx
  800e8a:	74 2c                	je     800eb8 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800e8c:	8b 45 14             	mov    0x14(%ebp),%eax
  800e8f:	8b 10                	mov    (%eax),%edx
  800e91:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e96:	8d 40 04             	lea    0x4(%eax),%eax
  800e99:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800e9c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800ea1:	eb 9f                	jmp    800e42 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800ea3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ea6:	8b 10                	mov    (%eax),%edx
  800ea8:	8b 48 04             	mov    0x4(%eax),%ecx
  800eab:	8d 40 08             	lea    0x8(%eax),%eax
  800eae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800eb1:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800eb6:	eb 8a                	jmp    800e42 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800eb8:	8b 45 14             	mov    0x14(%ebp),%eax
  800ebb:	8b 10                	mov    (%eax),%edx
  800ebd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ec2:	8d 40 04             	lea    0x4(%eax),%eax
  800ec5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800ec8:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800ecd:	e9 70 ff ff ff       	jmp    800e42 <vprintfmt+0x38c>
			putch(ch, putdat);
  800ed2:	83 ec 08             	sub    $0x8,%esp
  800ed5:	53                   	push   %ebx
  800ed6:	6a 25                	push   $0x25
  800ed8:	ff d6                	call   *%esi
			break;
  800eda:	83 c4 10             	add    $0x10,%esp
  800edd:	e9 7a ff ff ff       	jmp    800e5c <vprintfmt+0x3a6>
			putch('%', putdat);
  800ee2:	83 ec 08             	sub    $0x8,%esp
  800ee5:	53                   	push   %ebx
  800ee6:	6a 25                	push   $0x25
  800ee8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800eea:	83 c4 10             	add    $0x10,%esp
  800eed:	89 f8                	mov    %edi,%eax
  800eef:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800ef3:	74 05                	je     800efa <vprintfmt+0x444>
  800ef5:	83 e8 01             	sub    $0x1,%eax
  800ef8:	eb f5                	jmp    800eef <vprintfmt+0x439>
  800efa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800efd:	e9 5a ff ff ff       	jmp    800e5c <vprintfmt+0x3a6>
}
  800f02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f05:	5b                   	pop    %ebx
  800f06:	5e                   	pop    %esi
  800f07:	5f                   	pop    %edi
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    

00800f0a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800f0a:	f3 0f 1e fb          	endbr32 
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	83 ec 18             	sub    $0x18,%esp
  800f14:	8b 45 08             	mov    0x8(%ebp),%eax
  800f17:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800f1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f1d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800f21:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f24:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800f2b:	85 c0                	test   %eax,%eax
  800f2d:	74 26                	je     800f55 <vsnprintf+0x4b>
  800f2f:	85 d2                	test   %edx,%edx
  800f31:	7e 22                	jle    800f55 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f33:	ff 75 14             	pushl  0x14(%ebp)
  800f36:	ff 75 10             	pushl  0x10(%ebp)
  800f39:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f3c:	50                   	push   %eax
  800f3d:	68 74 0a 80 00       	push   $0x800a74
  800f42:	e8 6f fb ff ff       	call   800ab6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800f47:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f4a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f50:	83 c4 10             	add    $0x10,%esp
}
  800f53:	c9                   	leave  
  800f54:	c3                   	ret    
		return -E_INVAL;
  800f55:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f5a:	eb f7                	jmp    800f53 <vsnprintf+0x49>

00800f5c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f5c:	f3 0f 1e fb          	endbr32 
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  800f66:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800f69:	50                   	push   %eax
  800f6a:	ff 75 10             	pushl  0x10(%ebp)
  800f6d:	ff 75 0c             	pushl  0xc(%ebp)
  800f70:	ff 75 08             	pushl  0x8(%ebp)
  800f73:	e8 92 ff ff ff       	call   800f0a <vsnprintf>
	va_end(ap);

	return rc;
}
  800f78:	c9                   	leave  
  800f79:	c3                   	ret    

00800f7a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800f7a:	f3 0f 1e fb          	endbr32 
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800f84:	b8 00 00 00 00       	mov    $0x0,%eax
  800f89:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800f8d:	74 05                	je     800f94 <strlen+0x1a>
		n++;
  800f8f:	83 c0 01             	add    $0x1,%eax
  800f92:	eb f5                	jmp    800f89 <strlen+0xf>
	return n;
}
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    

00800f96 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800f96:	f3 0f 1e fb          	endbr32 
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fa3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa8:	39 d0                	cmp    %edx,%eax
  800faa:	74 0d                	je     800fb9 <strnlen+0x23>
  800fac:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800fb0:	74 05                	je     800fb7 <strnlen+0x21>
		n++;
  800fb2:	83 c0 01             	add    $0x1,%eax
  800fb5:	eb f1                	jmp    800fa8 <strnlen+0x12>
  800fb7:	89 c2                	mov    %eax,%edx
	return n;
}
  800fb9:	89 d0                	mov    %edx,%eax
  800fbb:	5d                   	pop    %ebp
  800fbc:	c3                   	ret    

00800fbd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800fbd:	f3 0f 1e fb          	endbr32 
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	53                   	push   %ebx
  800fc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fc8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800fcb:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd0:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800fd4:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800fd7:	83 c0 01             	add    $0x1,%eax
  800fda:	84 d2                	test   %dl,%dl
  800fdc:	75 f2                	jne    800fd0 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800fde:	89 c8                	mov    %ecx,%eax
  800fe0:	5b                   	pop    %ebx
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    

00800fe3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800fe3:	f3 0f 1e fb          	endbr32 
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	53                   	push   %ebx
  800feb:	83 ec 10             	sub    $0x10,%esp
  800fee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ff1:	53                   	push   %ebx
  800ff2:	e8 83 ff ff ff       	call   800f7a <strlen>
  800ff7:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800ffa:	ff 75 0c             	pushl  0xc(%ebp)
  800ffd:	01 d8                	add    %ebx,%eax
  800fff:	50                   	push   %eax
  801000:	e8 b8 ff ff ff       	call   800fbd <strcpy>
	return dst;
}
  801005:	89 d8                	mov    %ebx,%eax
  801007:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80100a:	c9                   	leave  
  80100b:	c3                   	ret    

0080100c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80100c:	f3 0f 1e fb          	endbr32 
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	56                   	push   %esi
  801014:	53                   	push   %ebx
  801015:	8b 75 08             	mov    0x8(%ebp),%esi
  801018:	8b 55 0c             	mov    0xc(%ebp),%edx
  80101b:	89 f3                	mov    %esi,%ebx
  80101d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801020:	89 f0                	mov    %esi,%eax
  801022:	39 d8                	cmp    %ebx,%eax
  801024:	74 11                	je     801037 <strncpy+0x2b>
		*dst++ = *src;
  801026:	83 c0 01             	add    $0x1,%eax
  801029:	0f b6 0a             	movzbl (%edx),%ecx
  80102c:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80102f:	80 f9 01             	cmp    $0x1,%cl
  801032:	83 da ff             	sbb    $0xffffffff,%edx
  801035:	eb eb                	jmp    801022 <strncpy+0x16>
	}
	return ret;
}
  801037:	89 f0                	mov    %esi,%eax
  801039:	5b                   	pop    %ebx
  80103a:	5e                   	pop    %esi
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    

0080103d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80103d:	f3 0f 1e fb          	endbr32 
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	56                   	push   %esi
  801045:	53                   	push   %ebx
  801046:	8b 75 08             	mov    0x8(%ebp),%esi
  801049:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104c:	8b 55 10             	mov    0x10(%ebp),%edx
  80104f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801051:	85 d2                	test   %edx,%edx
  801053:	74 21                	je     801076 <strlcpy+0x39>
  801055:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801059:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80105b:	39 c2                	cmp    %eax,%edx
  80105d:	74 14                	je     801073 <strlcpy+0x36>
  80105f:	0f b6 19             	movzbl (%ecx),%ebx
  801062:	84 db                	test   %bl,%bl
  801064:	74 0b                	je     801071 <strlcpy+0x34>
			*dst++ = *src++;
  801066:	83 c1 01             	add    $0x1,%ecx
  801069:	83 c2 01             	add    $0x1,%edx
  80106c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80106f:	eb ea                	jmp    80105b <strlcpy+0x1e>
  801071:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801073:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801076:	29 f0                	sub    %esi,%eax
}
  801078:	5b                   	pop    %ebx
  801079:	5e                   	pop    %esi
  80107a:	5d                   	pop    %ebp
  80107b:	c3                   	ret    

0080107c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80107c:	f3 0f 1e fb          	endbr32 
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801086:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801089:	0f b6 01             	movzbl (%ecx),%eax
  80108c:	84 c0                	test   %al,%al
  80108e:	74 0c                	je     80109c <strcmp+0x20>
  801090:	3a 02                	cmp    (%edx),%al
  801092:	75 08                	jne    80109c <strcmp+0x20>
		p++, q++;
  801094:	83 c1 01             	add    $0x1,%ecx
  801097:	83 c2 01             	add    $0x1,%edx
  80109a:	eb ed                	jmp    801089 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80109c:	0f b6 c0             	movzbl %al,%eax
  80109f:	0f b6 12             	movzbl (%edx),%edx
  8010a2:	29 d0                	sub    %edx,%eax
}
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8010a6:	f3 0f 1e fb          	endbr32 
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	53                   	push   %ebx
  8010ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010b4:	89 c3                	mov    %eax,%ebx
  8010b6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8010b9:	eb 06                	jmp    8010c1 <strncmp+0x1b>
		n--, p++, q++;
  8010bb:	83 c0 01             	add    $0x1,%eax
  8010be:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8010c1:	39 d8                	cmp    %ebx,%eax
  8010c3:	74 16                	je     8010db <strncmp+0x35>
  8010c5:	0f b6 08             	movzbl (%eax),%ecx
  8010c8:	84 c9                	test   %cl,%cl
  8010ca:	74 04                	je     8010d0 <strncmp+0x2a>
  8010cc:	3a 0a                	cmp    (%edx),%cl
  8010ce:	74 eb                	je     8010bb <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8010d0:	0f b6 00             	movzbl (%eax),%eax
  8010d3:	0f b6 12             	movzbl (%edx),%edx
  8010d6:	29 d0                	sub    %edx,%eax
}
  8010d8:	5b                   	pop    %ebx
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    
		return 0;
  8010db:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e0:	eb f6                	jmp    8010d8 <strncmp+0x32>

008010e2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8010e2:	f3 0f 1e fb          	endbr32 
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8010f0:	0f b6 10             	movzbl (%eax),%edx
  8010f3:	84 d2                	test   %dl,%dl
  8010f5:	74 09                	je     801100 <strchr+0x1e>
		if (*s == c)
  8010f7:	38 ca                	cmp    %cl,%dl
  8010f9:	74 0a                	je     801105 <strchr+0x23>
	for (; *s; s++)
  8010fb:	83 c0 01             	add    $0x1,%eax
  8010fe:	eb f0                	jmp    8010f0 <strchr+0xe>
			return (char *) s;
	return 0;
  801100:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801105:	5d                   	pop    %ebp
  801106:	c3                   	ret    

00801107 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  801107:	f3 0f 1e fb          	endbr32 
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  801111:	6a 78                	push   $0x78
  801113:	ff 75 08             	pushl  0x8(%ebp)
  801116:	e8 c7 ff ff ff       	call   8010e2 <strchr>
  80111b:	83 c4 10             	add    $0x10,%esp
  80111e:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  801121:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  801126:	eb 0d                	jmp    801135 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  801128:	c1 e0 04             	shl    $0x4,%eax
  80112b:	0f be d2             	movsbl %dl,%edx
  80112e:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  801132:	83 c1 01             	add    $0x1,%ecx
  801135:	0f b6 11             	movzbl (%ecx),%edx
  801138:	84 d2                	test   %dl,%dl
  80113a:	74 11                	je     80114d <atox+0x46>
		if (*p>='a'){
  80113c:	80 fa 60             	cmp    $0x60,%dl
  80113f:	7e e7                	jle    801128 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  801141:	c1 e0 04             	shl    $0x4,%eax
  801144:	0f be d2             	movsbl %dl,%edx
  801147:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  80114b:	eb e5                	jmp    801132 <atox+0x2b>
	}

	return v;

}
  80114d:	c9                   	leave  
  80114e:	c3                   	ret    

0080114f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80114f:	f3 0f 1e fb          	endbr32 
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	8b 45 08             	mov    0x8(%ebp),%eax
  801159:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80115d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801160:	38 ca                	cmp    %cl,%dl
  801162:	74 09                	je     80116d <strfind+0x1e>
  801164:	84 d2                	test   %dl,%dl
  801166:	74 05                	je     80116d <strfind+0x1e>
	for (; *s; s++)
  801168:	83 c0 01             	add    $0x1,%eax
  80116b:	eb f0                	jmp    80115d <strfind+0xe>
			break;
	return (char *) s;
}
  80116d:	5d                   	pop    %ebp
  80116e:	c3                   	ret    

0080116f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80116f:	f3 0f 1e fb          	endbr32 
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	57                   	push   %edi
  801177:	56                   	push   %esi
  801178:	53                   	push   %ebx
  801179:	8b 7d 08             	mov    0x8(%ebp),%edi
  80117c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80117f:	85 c9                	test   %ecx,%ecx
  801181:	74 31                	je     8011b4 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801183:	89 f8                	mov    %edi,%eax
  801185:	09 c8                	or     %ecx,%eax
  801187:	a8 03                	test   $0x3,%al
  801189:	75 23                	jne    8011ae <memset+0x3f>
		c &= 0xFF;
  80118b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80118f:	89 d3                	mov    %edx,%ebx
  801191:	c1 e3 08             	shl    $0x8,%ebx
  801194:	89 d0                	mov    %edx,%eax
  801196:	c1 e0 18             	shl    $0x18,%eax
  801199:	89 d6                	mov    %edx,%esi
  80119b:	c1 e6 10             	shl    $0x10,%esi
  80119e:	09 f0                	or     %esi,%eax
  8011a0:	09 c2                	or     %eax,%edx
  8011a2:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8011a4:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8011a7:	89 d0                	mov    %edx,%eax
  8011a9:	fc                   	cld    
  8011aa:	f3 ab                	rep stos %eax,%es:(%edi)
  8011ac:	eb 06                	jmp    8011b4 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8011ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011b1:	fc                   	cld    
  8011b2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8011b4:	89 f8                	mov    %edi,%eax
  8011b6:	5b                   	pop    %ebx
  8011b7:	5e                   	pop    %esi
  8011b8:	5f                   	pop    %edi
  8011b9:	5d                   	pop    %ebp
  8011ba:	c3                   	ret    

008011bb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8011bb:	f3 0f 1e fb          	endbr32 
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	57                   	push   %edi
  8011c3:	56                   	push   %esi
  8011c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8011cd:	39 c6                	cmp    %eax,%esi
  8011cf:	73 32                	jae    801203 <memmove+0x48>
  8011d1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8011d4:	39 c2                	cmp    %eax,%edx
  8011d6:	76 2b                	jbe    801203 <memmove+0x48>
		s += n;
		d += n;
  8011d8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8011db:	89 fe                	mov    %edi,%esi
  8011dd:	09 ce                	or     %ecx,%esi
  8011df:	09 d6                	or     %edx,%esi
  8011e1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8011e7:	75 0e                	jne    8011f7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8011e9:	83 ef 04             	sub    $0x4,%edi
  8011ec:	8d 72 fc             	lea    -0x4(%edx),%esi
  8011ef:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8011f2:	fd                   	std    
  8011f3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8011f5:	eb 09                	jmp    801200 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8011f7:	83 ef 01             	sub    $0x1,%edi
  8011fa:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8011fd:	fd                   	std    
  8011fe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801200:	fc                   	cld    
  801201:	eb 1a                	jmp    80121d <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801203:	89 c2                	mov    %eax,%edx
  801205:	09 ca                	or     %ecx,%edx
  801207:	09 f2                	or     %esi,%edx
  801209:	f6 c2 03             	test   $0x3,%dl
  80120c:	75 0a                	jne    801218 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80120e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801211:	89 c7                	mov    %eax,%edi
  801213:	fc                   	cld    
  801214:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801216:	eb 05                	jmp    80121d <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  801218:	89 c7                	mov    %eax,%edi
  80121a:	fc                   	cld    
  80121b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80121d:	5e                   	pop    %esi
  80121e:	5f                   	pop    %edi
  80121f:	5d                   	pop    %ebp
  801220:	c3                   	ret    

00801221 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801221:	f3 0f 1e fb          	endbr32 
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
  801228:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80122b:	ff 75 10             	pushl  0x10(%ebp)
  80122e:	ff 75 0c             	pushl  0xc(%ebp)
  801231:	ff 75 08             	pushl  0x8(%ebp)
  801234:	e8 82 ff ff ff       	call   8011bb <memmove>
}
  801239:	c9                   	leave  
  80123a:	c3                   	ret    

0080123b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80123b:	f3 0f 1e fb          	endbr32 
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	56                   	push   %esi
  801243:	53                   	push   %ebx
  801244:	8b 45 08             	mov    0x8(%ebp),%eax
  801247:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124a:	89 c6                	mov    %eax,%esi
  80124c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80124f:	39 f0                	cmp    %esi,%eax
  801251:	74 1c                	je     80126f <memcmp+0x34>
		if (*s1 != *s2)
  801253:	0f b6 08             	movzbl (%eax),%ecx
  801256:	0f b6 1a             	movzbl (%edx),%ebx
  801259:	38 d9                	cmp    %bl,%cl
  80125b:	75 08                	jne    801265 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80125d:	83 c0 01             	add    $0x1,%eax
  801260:	83 c2 01             	add    $0x1,%edx
  801263:	eb ea                	jmp    80124f <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801265:	0f b6 c1             	movzbl %cl,%eax
  801268:	0f b6 db             	movzbl %bl,%ebx
  80126b:	29 d8                	sub    %ebx,%eax
  80126d:	eb 05                	jmp    801274 <memcmp+0x39>
	}

	return 0;
  80126f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801274:	5b                   	pop    %ebx
  801275:	5e                   	pop    %esi
  801276:	5d                   	pop    %ebp
  801277:	c3                   	ret    

00801278 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801278:	f3 0f 1e fb          	endbr32 
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	8b 45 08             	mov    0x8(%ebp),%eax
  801282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801285:	89 c2                	mov    %eax,%edx
  801287:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80128a:	39 d0                	cmp    %edx,%eax
  80128c:	73 09                	jae    801297 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  80128e:	38 08                	cmp    %cl,(%eax)
  801290:	74 05                	je     801297 <memfind+0x1f>
	for (; s < ends; s++)
  801292:	83 c0 01             	add    $0x1,%eax
  801295:	eb f3                	jmp    80128a <memfind+0x12>
			break;
	return (void *) s;
}
  801297:	5d                   	pop    %ebp
  801298:	c3                   	ret    

00801299 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801299:	f3 0f 1e fb          	endbr32 
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	57                   	push   %edi
  8012a1:	56                   	push   %esi
  8012a2:	53                   	push   %ebx
  8012a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8012a9:	eb 03                	jmp    8012ae <strtol+0x15>
		s++;
  8012ab:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8012ae:	0f b6 01             	movzbl (%ecx),%eax
  8012b1:	3c 20                	cmp    $0x20,%al
  8012b3:	74 f6                	je     8012ab <strtol+0x12>
  8012b5:	3c 09                	cmp    $0x9,%al
  8012b7:	74 f2                	je     8012ab <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  8012b9:	3c 2b                	cmp    $0x2b,%al
  8012bb:	74 2a                	je     8012e7 <strtol+0x4e>
	int neg = 0;
  8012bd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8012c2:	3c 2d                	cmp    $0x2d,%al
  8012c4:	74 2b                	je     8012f1 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8012c6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8012cc:	75 0f                	jne    8012dd <strtol+0x44>
  8012ce:	80 39 30             	cmpb   $0x30,(%ecx)
  8012d1:	74 28                	je     8012fb <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8012d3:	85 db                	test   %ebx,%ebx
  8012d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012da:	0f 44 d8             	cmove  %eax,%ebx
  8012dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8012e5:	eb 46                	jmp    80132d <strtol+0x94>
		s++;
  8012e7:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8012ea:	bf 00 00 00 00       	mov    $0x0,%edi
  8012ef:	eb d5                	jmp    8012c6 <strtol+0x2d>
		s++, neg = 1;
  8012f1:	83 c1 01             	add    $0x1,%ecx
  8012f4:	bf 01 00 00 00       	mov    $0x1,%edi
  8012f9:	eb cb                	jmp    8012c6 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8012fb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8012ff:	74 0e                	je     80130f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801301:	85 db                	test   %ebx,%ebx
  801303:	75 d8                	jne    8012dd <strtol+0x44>
		s++, base = 8;
  801305:	83 c1 01             	add    $0x1,%ecx
  801308:	bb 08 00 00 00       	mov    $0x8,%ebx
  80130d:	eb ce                	jmp    8012dd <strtol+0x44>
		s += 2, base = 16;
  80130f:	83 c1 02             	add    $0x2,%ecx
  801312:	bb 10 00 00 00       	mov    $0x10,%ebx
  801317:	eb c4                	jmp    8012dd <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801319:	0f be d2             	movsbl %dl,%edx
  80131c:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80131f:	3b 55 10             	cmp    0x10(%ebp),%edx
  801322:	7d 3a                	jge    80135e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801324:	83 c1 01             	add    $0x1,%ecx
  801327:	0f af 45 10          	imul   0x10(%ebp),%eax
  80132b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  80132d:	0f b6 11             	movzbl (%ecx),%edx
  801330:	8d 72 d0             	lea    -0x30(%edx),%esi
  801333:	89 f3                	mov    %esi,%ebx
  801335:	80 fb 09             	cmp    $0x9,%bl
  801338:	76 df                	jbe    801319 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  80133a:	8d 72 9f             	lea    -0x61(%edx),%esi
  80133d:	89 f3                	mov    %esi,%ebx
  80133f:	80 fb 19             	cmp    $0x19,%bl
  801342:	77 08                	ja     80134c <strtol+0xb3>
			dig = *s - 'a' + 10;
  801344:	0f be d2             	movsbl %dl,%edx
  801347:	83 ea 57             	sub    $0x57,%edx
  80134a:	eb d3                	jmp    80131f <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  80134c:	8d 72 bf             	lea    -0x41(%edx),%esi
  80134f:	89 f3                	mov    %esi,%ebx
  801351:	80 fb 19             	cmp    $0x19,%bl
  801354:	77 08                	ja     80135e <strtol+0xc5>
			dig = *s - 'A' + 10;
  801356:	0f be d2             	movsbl %dl,%edx
  801359:	83 ea 37             	sub    $0x37,%edx
  80135c:	eb c1                	jmp    80131f <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  80135e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801362:	74 05                	je     801369 <strtol+0xd0>
		*endptr = (char *) s;
  801364:	8b 75 0c             	mov    0xc(%ebp),%esi
  801367:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801369:	89 c2                	mov    %eax,%edx
  80136b:	f7 da                	neg    %edx
  80136d:	85 ff                	test   %edi,%edi
  80136f:	0f 45 c2             	cmovne %edx,%eax
}
  801372:	5b                   	pop    %ebx
  801373:	5e                   	pop    %esi
  801374:	5f                   	pop    %edi
  801375:	5d                   	pop    %ebp
  801376:	c3                   	ret    

00801377 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801377:	f3 0f 1e fb          	endbr32 
  80137b:	55                   	push   %ebp
  80137c:	89 e5                	mov    %esp,%ebp
  80137e:	57                   	push   %edi
  80137f:	56                   	push   %esi
  801380:	53                   	push   %ebx
	asm volatile("int %1\n"
  801381:	b8 00 00 00 00       	mov    $0x0,%eax
  801386:	8b 55 08             	mov    0x8(%ebp),%edx
  801389:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80138c:	89 c3                	mov    %eax,%ebx
  80138e:	89 c7                	mov    %eax,%edi
  801390:	89 c6                	mov    %eax,%esi
  801392:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801394:	5b                   	pop    %ebx
  801395:	5e                   	pop    %esi
  801396:	5f                   	pop    %edi
  801397:	5d                   	pop    %ebp
  801398:	c3                   	ret    

00801399 <sys_cgetc>:

int
sys_cgetc(void)
{
  801399:	f3 0f 1e fb          	endbr32 
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	57                   	push   %edi
  8013a1:	56                   	push   %esi
  8013a2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8013a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a8:	b8 01 00 00 00       	mov    $0x1,%eax
  8013ad:	89 d1                	mov    %edx,%ecx
  8013af:	89 d3                	mov    %edx,%ebx
  8013b1:	89 d7                	mov    %edx,%edi
  8013b3:	89 d6                	mov    %edx,%esi
  8013b5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8013b7:	5b                   	pop    %ebx
  8013b8:	5e                   	pop    %esi
  8013b9:	5f                   	pop    %edi
  8013ba:	5d                   	pop    %ebp
  8013bb:	c3                   	ret    

008013bc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8013bc:	f3 0f 1e fb          	endbr32 
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	57                   	push   %edi
  8013c4:	56                   	push   %esi
  8013c5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8013c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ce:	b8 03 00 00 00       	mov    $0x3,%eax
  8013d3:	89 cb                	mov    %ecx,%ebx
  8013d5:	89 cf                	mov    %ecx,%edi
  8013d7:	89 ce                	mov    %ecx,%esi
  8013d9:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8013db:	5b                   	pop    %ebx
  8013dc:	5e                   	pop    %esi
  8013dd:	5f                   	pop    %edi
  8013de:	5d                   	pop    %ebp
  8013df:	c3                   	ret    

008013e0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8013e0:	f3 0f 1e fb          	endbr32 
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	57                   	push   %edi
  8013e8:	56                   	push   %esi
  8013e9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8013ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ef:	b8 02 00 00 00       	mov    $0x2,%eax
  8013f4:	89 d1                	mov    %edx,%ecx
  8013f6:	89 d3                	mov    %edx,%ebx
  8013f8:	89 d7                	mov    %edx,%edi
  8013fa:	89 d6                	mov    %edx,%esi
  8013fc:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8013fe:	5b                   	pop    %ebx
  8013ff:	5e                   	pop    %esi
  801400:	5f                   	pop    %edi
  801401:	5d                   	pop    %ebp
  801402:	c3                   	ret    

00801403 <sys_yield>:

void
sys_yield(void)
{
  801403:	f3 0f 1e fb          	endbr32 
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	57                   	push   %edi
  80140b:	56                   	push   %esi
  80140c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80140d:	ba 00 00 00 00       	mov    $0x0,%edx
  801412:	b8 0b 00 00 00       	mov    $0xb,%eax
  801417:	89 d1                	mov    %edx,%ecx
  801419:	89 d3                	mov    %edx,%ebx
  80141b:	89 d7                	mov    %edx,%edi
  80141d:	89 d6                	mov    %edx,%esi
  80141f:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801421:	5b                   	pop    %ebx
  801422:	5e                   	pop    %esi
  801423:	5f                   	pop    %edi
  801424:	5d                   	pop    %ebp
  801425:	c3                   	ret    

00801426 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801426:	f3 0f 1e fb          	endbr32 
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	57                   	push   %edi
  80142e:	56                   	push   %esi
  80142f:	53                   	push   %ebx
	asm volatile("int %1\n"
  801430:	be 00 00 00 00       	mov    $0x0,%esi
  801435:	8b 55 08             	mov    0x8(%ebp),%edx
  801438:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80143b:	b8 04 00 00 00       	mov    $0x4,%eax
  801440:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801443:	89 f7                	mov    %esi,%edi
  801445:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801447:	5b                   	pop    %ebx
  801448:	5e                   	pop    %esi
  801449:	5f                   	pop    %edi
  80144a:	5d                   	pop    %ebp
  80144b:	c3                   	ret    

0080144c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80144c:	f3 0f 1e fb          	endbr32 
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	57                   	push   %edi
  801454:	56                   	push   %esi
  801455:	53                   	push   %ebx
	asm volatile("int %1\n"
  801456:	8b 55 08             	mov    0x8(%ebp),%edx
  801459:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80145c:	b8 05 00 00 00       	mov    $0x5,%eax
  801461:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801464:	8b 7d 14             	mov    0x14(%ebp),%edi
  801467:	8b 75 18             	mov    0x18(%ebp),%esi
  80146a:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80146c:	5b                   	pop    %ebx
  80146d:	5e                   	pop    %esi
  80146e:	5f                   	pop    %edi
  80146f:	5d                   	pop    %ebp
  801470:	c3                   	ret    

00801471 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801471:	f3 0f 1e fb          	endbr32 
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	57                   	push   %edi
  801479:	56                   	push   %esi
  80147a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80147b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801480:	8b 55 08             	mov    0x8(%ebp),%edx
  801483:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801486:	b8 06 00 00 00       	mov    $0x6,%eax
  80148b:	89 df                	mov    %ebx,%edi
  80148d:	89 de                	mov    %ebx,%esi
  80148f:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801491:	5b                   	pop    %ebx
  801492:	5e                   	pop    %esi
  801493:	5f                   	pop    %edi
  801494:	5d                   	pop    %ebp
  801495:	c3                   	ret    

00801496 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801496:	f3 0f 1e fb          	endbr32 
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	57                   	push   %edi
  80149e:	56                   	push   %esi
  80149f:	53                   	push   %ebx
	asm volatile("int %1\n"
  8014a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8014a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8014b0:	89 df                	mov    %ebx,%edi
  8014b2:	89 de                	mov    %ebx,%esi
  8014b4:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8014b6:	5b                   	pop    %ebx
  8014b7:	5e                   	pop    %esi
  8014b8:	5f                   	pop    %edi
  8014b9:	5d                   	pop    %ebp
  8014ba:	c3                   	ret    

008014bb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8014bb:	f3 0f 1e fb          	endbr32 
  8014bf:	55                   	push   %ebp
  8014c0:	89 e5                	mov    %esp,%ebp
  8014c2:	57                   	push   %edi
  8014c3:	56                   	push   %esi
  8014c4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8014c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8014cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014d0:	b8 09 00 00 00       	mov    $0x9,%eax
  8014d5:	89 df                	mov    %ebx,%edi
  8014d7:	89 de                	mov    %ebx,%esi
  8014d9:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8014db:	5b                   	pop    %ebx
  8014dc:	5e                   	pop    %esi
  8014dd:	5f                   	pop    %edi
  8014de:	5d                   	pop    %ebp
  8014df:	c3                   	ret    

008014e0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8014e0:	f3 0f 1e fb          	endbr32 
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	57                   	push   %edi
  8014e8:	56                   	push   %esi
  8014e9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8014ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014f5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014fa:	89 df                	mov    %ebx,%edi
  8014fc:	89 de                	mov    %ebx,%esi
  8014fe:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801500:	5b                   	pop    %ebx
  801501:	5e                   	pop    %esi
  801502:	5f                   	pop    %edi
  801503:	5d                   	pop    %ebp
  801504:	c3                   	ret    

00801505 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801505:	f3 0f 1e fb          	endbr32 
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	57                   	push   %edi
  80150d:	56                   	push   %esi
  80150e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80150f:	8b 55 08             	mov    0x8(%ebp),%edx
  801512:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801515:	b8 0c 00 00 00       	mov    $0xc,%eax
  80151a:	be 00 00 00 00       	mov    $0x0,%esi
  80151f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801522:	8b 7d 14             	mov    0x14(%ebp),%edi
  801525:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801527:	5b                   	pop    %ebx
  801528:	5e                   	pop    %esi
  801529:	5f                   	pop    %edi
  80152a:	5d                   	pop    %ebp
  80152b:	c3                   	ret    

0080152c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80152c:	f3 0f 1e fb          	endbr32 
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	57                   	push   %edi
  801534:	56                   	push   %esi
  801535:	53                   	push   %ebx
	asm volatile("int %1\n"
  801536:	b9 00 00 00 00       	mov    $0x0,%ecx
  80153b:	8b 55 08             	mov    0x8(%ebp),%edx
  80153e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801543:	89 cb                	mov    %ecx,%ebx
  801545:	89 cf                	mov    %ecx,%edi
  801547:	89 ce                	mov    %ecx,%esi
  801549:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80154b:	5b                   	pop    %ebx
  80154c:	5e                   	pop    %esi
  80154d:	5f                   	pop    %edi
  80154e:	5d                   	pop    %ebp
  80154f:	c3                   	ret    

00801550 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801550:	f3 0f 1e fb          	endbr32 
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	57                   	push   %edi
  801558:	56                   	push   %esi
  801559:	53                   	push   %ebx
	asm volatile("int %1\n"
  80155a:	ba 00 00 00 00       	mov    $0x0,%edx
  80155f:	b8 0e 00 00 00       	mov    $0xe,%eax
  801564:	89 d1                	mov    %edx,%ecx
  801566:	89 d3                	mov    %edx,%ebx
  801568:	89 d7                	mov    %edx,%edi
  80156a:	89 d6                	mov    %edx,%esi
  80156c:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80156e:	5b                   	pop    %ebx
  80156f:	5e                   	pop    %esi
  801570:	5f                   	pop    %edi
  801571:	5d                   	pop    %ebp
  801572:	c3                   	ret    

00801573 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  801573:	f3 0f 1e fb          	endbr32 
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	57                   	push   %edi
  80157b:	56                   	push   %esi
  80157c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80157d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801582:	8b 55 08             	mov    0x8(%ebp),%edx
  801585:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801588:	b8 0f 00 00 00       	mov    $0xf,%eax
  80158d:	89 df                	mov    %ebx,%edi
  80158f:	89 de                	mov    %ebx,%esi
  801591:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  801593:	5b                   	pop    %ebx
  801594:	5e                   	pop    %esi
  801595:	5f                   	pop    %edi
  801596:	5d                   	pop    %ebp
  801597:	c3                   	ret    

00801598 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  801598:	f3 0f 1e fb          	endbr32 
  80159c:	55                   	push   %ebp
  80159d:	89 e5                	mov    %esp,%ebp
  80159f:	57                   	push   %edi
  8015a0:	56                   	push   %esi
  8015a1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8015a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8015aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015ad:	b8 10 00 00 00       	mov    $0x10,%eax
  8015b2:	89 df                	mov    %ebx,%edi
  8015b4:	89 de                	mov    %ebx,%esi
  8015b6:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  8015b8:	5b                   	pop    %ebx
  8015b9:	5e                   	pop    %esi
  8015ba:	5f                   	pop    %edi
  8015bb:	5d                   	pop    %ebp
  8015bc:	c3                   	ret    

008015bd <pgfault>:
// map in our own private writable copy.
//
extern int cnt;
static void
pgfault(struct UTrapframe *utf)
{
  8015bd:	f3 0f 1e fb          	endbr32 
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	53                   	push   %ebx
  8015c5:	83 ec 04             	sub    $0x4,%esp
  8015c8:	8b 45 08             	mov    0x8(%ebp),%eax
	// cprintf("[%08x] called pgfault\n", sys_getenvid());
	void *addr = (void *) utf->utf_fault_va;
  8015cb:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err&FEC_WR)&&(uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_COW))){
  8015cd:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8015d1:	0f 84 9a 00 00 00    	je     801671 <pgfault+0xb4>
  8015d7:	89 d8                	mov    %ebx,%eax
  8015d9:	c1 e8 16             	shr    $0x16,%eax
  8015dc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015e3:	a8 01                	test   $0x1,%al
  8015e5:	0f 84 86 00 00 00    	je     801671 <pgfault+0xb4>
  8015eb:	89 d8                	mov    %ebx,%eax
  8015ed:	c1 e8 0c             	shr    $0xc,%eax
  8015f0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015f7:	f6 c2 01             	test   $0x1,%dl
  8015fa:	74 75                	je     801671 <pgfault+0xb4>
  8015fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801603:	f6 c4 08             	test   $0x8,%ah
  801606:	74 69                	je     801671 <pgfault+0xb4>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 在PFTEMP这里给一个物理地址的mapping 相当于store一个物理地址
	if((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W))<0){
  801608:	83 ec 04             	sub    $0x4,%esp
  80160b:	6a 07                	push   $0x7
  80160d:	68 00 f0 7f 00       	push   $0x7ff000
  801612:	6a 00                	push   $0x0
  801614:	e8 0d fe ff ff       	call   801426 <sys_page_alloc>
  801619:	83 c4 10             	add    $0x10,%esp
  80161c:	85 c0                	test   %eax,%eax
  80161e:	78 63                	js     801683 <pgfault+0xc6>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  801620:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// 先复制addr里的content
	memcpy((void*)PFTEMP, addr, PGSIZE);
  801626:	83 ec 04             	sub    $0x4,%esp
  801629:	68 00 10 00 00       	push   $0x1000
  80162e:	53                   	push   %ebx
  80162f:	68 00 f0 7f 00       	push   $0x7ff000
  801634:	e8 e8 fb ff ff       	call   801221 <memcpy>
	// 在remap addr到PFTEMP位置 即addr与PFTEMP指向同一个物理内存
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))<0){
  801639:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801640:	53                   	push   %ebx
  801641:	6a 00                	push   $0x0
  801643:	68 00 f0 7f 00       	push   $0x7ff000
  801648:	6a 00                	push   $0x0
  80164a:	e8 fd fd ff ff       	call   80144c <sys_page_map>
  80164f:	83 c4 20             	add    $0x20,%esp
  801652:	85 c0                	test   %eax,%eax
  801654:	78 3f                	js     801695 <pgfault+0xd8>
		panic("pgfault: sys_page_map failed due to %e\n", r);
	}
	if ((r = sys_page_unmap(0, (void*)PFTEMP))<0){
  801656:	83 ec 08             	sub    $0x8,%esp
  801659:	68 00 f0 7f 00       	push   $0x7ff000
  80165e:	6a 00                	push   $0x0
  801660:	e8 0c fe ff ff       	call   801471 <sys_page_unmap>
  801665:	83 c4 10             	add    $0x10,%esp
  801668:	85 c0                	test   %eax,%eax
  80166a:	78 3b                	js     8016a7 <pgfault+0xea>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
	}
	
	
}
  80166c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166f:	c9                   	leave  
  801670:	c3                   	ret    
		panic("pgfault: page access at %08x is not a write to a copy-on-write\n", addr);
  801671:	53                   	push   %ebx
  801672:	68 40 33 80 00       	push   $0x803340
  801677:	6a 20                	push   $0x20
  801679:	68 fe 33 80 00       	push   $0x8033fe
  80167e:	e8 49 f2 ff ff       	call   8008cc <_panic>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
  801683:	50                   	push   %eax
  801684:	68 80 33 80 00       	push   $0x803380
  801689:	6a 2c                	push   $0x2c
  80168b:	68 fe 33 80 00       	push   $0x8033fe
  801690:	e8 37 f2 ff ff       	call   8008cc <_panic>
		panic("pgfault: sys_page_map failed due to %e\n", r);
  801695:	50                   	push   %eax
  801696:	68 ac 33 80 00       	push   $0x8033ac
  80169b:	6a 33                	push   $0x33
  80169d:	68 fe 33 80 00       	push   $0x8033fe
  8016a2:	e8 25 f2 ff ff       	call   8008cc <_panic>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
  8016a7:	50                   	push   %eax
  8016a8:	68 d4 33 80 00       	push   $0x8033d4
  8016ad:	6a 36                	push   $0x36
  8016af:	68 fe 33 80 00       	push   $0x8033fe
  8016b4:	e8 13 f2 ff ff       	call   8008cc <_panic>

008016b9 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8016b9:	f3 0f 1e fb          	endbr32 
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	57                   	push   %edi
  8016c1:	56                   	push   %esi
  8016c2:	53                   	push   %ebx
  8016c3:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[%08x] called fork\n", sys_getenvid());
	int r; uintptr_t addr;
	set_pgfault_handler(pgfault);
  8016c6:	68 bd 15 80 00       	push   $0x8015bd
  8016cb:	e8 84 14 00 00       	call   802b54 <set_pgfault_handler>
*/
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8016d0:	b8 07 00 00 00       	mov    $0x7,%eax
  8016d5:	cd 30                	int    $0x30
  8016d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();
		
	if (envid<0){
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	78 29                	js     80170a <fork+0x51>
  8016e1:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	// duplicate parent address space
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  8016e3:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid==0){
  8016e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8016ec:	75 60                	jne    80174e <fork+0x95>
		thisenv = &envs[ENVX(sys_getenvid())];
  8016ee:	e8 ed fc ff ff       	call   8013e0 <sys_getenvid>
  8016f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016f8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8016fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801700:	a3 20 50 80 00       	mov    %eax,0x805020
		return 0;
  801705:	e9 14 01 00 00       	jmp    80181e <fork+0x165>
		panic("fork: sys_exofork error %e\n", envid);
  80170a:	50                   	push   %eax
  80170b:	68 09 34 80 00       	push   $0x803409
  801710:	68 90 00 00 00       	push   $0x90
  801715:	68 fe 33 80 00       	push   $0x8033fe
  80171a:	e8 ad f1 ff ff       	call   8008cc <_panic>
		r = sys_page_map(0, addr, envid, addr, (uvpt[pn]&PTE_SYSCALL));
  80171f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801726:	83 ec 0c             	sub    $0xc,%esp
  801729:	25 07 0e 00 00       	and    $0xe07,%eax
  80172e:	50                   	push   %eax
  80172f:	56                   	push   %esi
  801730:	57                   	push   %edi
  801731:	56                   	push   %esi
  801732:	6a 00                	push   $0x0
  801734:	e8 13 fd ff ff       	call   80144c <sys_page_map>
  801739:	83 c4 20             	add    $0x20,%esp
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  80173c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801742:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801748:	0f 84 95 00 00 00    	je     8017e3 <fork+0x12a>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  80174e:	89 d8                	mov    %ebx,%eax
  801750:	c1 e8 16             	shr    $0x16,%eax
  801753:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80175a:	a8 01                	test   $0x1,%al
  80175c:	74 de                	je     80173c <fork+0x83>
  80175e:	89 d8                	mov    %ebx,%eax
  801760:	c1 e8 0c             	shr    $0xc,%eax
  801763:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80176a:	f6 c2 01             	test   $0x1,%dl
  80176d:	74 cd                	je     80173c <fork+0x83>
	void* addr = (void*)(pn*PGSIZE);
  80176f:	89 c6                	mov    %eax,%esi
  801771:	c1 e6 0c             	shl    $0xc,%esi
	if (uvpt[pn]&PTE_SHARE){
  801774:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80177b:	f6 c6 04             	test   $0x4,%dh
  80177e:	75 9f                	jne    80171f <fork+0x66>
		if (uvpt[pn]&PTE_W||uvpt[pn]&PTE_COW){
  801780:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801787:	f6 c2 02             	test   $0x2,%dl
  80178a:	75 0c                	jne    801798 <fork+0xdf>
  80178c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801793:	f6 c4 08             	test   $0x8,%ah
  801796:	74 34                	je     8017cc <fork+0x113>
			r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P); // not writable
  801798:	83 ec 0c             	sub    $0xc,%esp
  80179b:	68 05 08 00 00       	push   $0x805
  8017a0:	56                   	push   %esi
  8017a1:	57                   	push   %edi
  8017a2:	56                   	push   %esi
  8017a3:	6a 00                	push   $0x0
  8017a5:	e8 a2 fc ff ff       	call   80144c <sys_page_map>
			if (r<0) return r;
  8017aa:	83 c4 20             	add    $0x20,%esp
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	78 8b                	js     80173c <fork+0x83>
			r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P); // not writable
  8017b1:	83 ec 0c             	sub    $0xc,%esp
  8017b4:	68 05 08 00 00       	push   $0x805
  8017b9:	56                   	push   %esi
  8017ba:	6a 00                	push   $0x0
  8017bc:	56                   	push   %esi
  8017bd:	6a 00                	push   $0x0
  8017bf:	e8 88 fc ff ff       	call   80144c <sys_page_map>
  8017c4:	83 c4 20             	add    $0x20,%esp
  8017c7:	e9 70 ff ff ff       	jmp    80173c <fork+0x83>
			if ((r=sys_page_map(0, addr, envid, addr, PTE_P|PTE_U)<0))// read only
  8017cc:	83 ec 0c             	sub    $0xc,%esp
  8017cf:	6a 05                	push   $0x5
  8017d1:	56                   	push   %esi
  8017d2:	57                   	push   %edi
  8017d3:	56                   	push   %esi
  8017d4:	6a 00                	push   $0x0
  8017d6:	e8 71 fc ff ff       	call   80144c <sys_page_map>
  8017db:	83 c4 20             	add    $0x20,%esp
  8017de:	e9 59 ff ff ff       	jmp    80173c <fork+0x83>
			duppage(envid, PGNUM(addr));
		}
	}
	// allocate user exception stack
	// cprintf("alloc user expection stack\n");
	if ((r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_W|PTE_U))<0)
  8017e3:	83 ec 04             	sub    $0x4,%esp
  8017e6:	6a 07                	push   $0x7
  8017e8:	68 00 f0 bf ee       	push   $0xeebff000
  8017ed:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8017f0:	56                   	push   %esi
  8017f1:	e8 30 fc ff ff       	call   801426 <sys_page_alloc>
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	78 2b                	js     801828 <fork+0x16f>
		return r;
	
	extern void* _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8017fd:	83 ec 08             	sub    $0x8,%esp
  801800:	68 c7 2b 80 00       	push   $0x802bc7
  801805:	56                   	push   %esi
  801806:	e8 d5 fc ff ff       	call   8014e0 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE))<0)
  80180b:	83 c4 08             	add    $0x8,%esp
  80180e:	6a 02                	push   $0x2
  801810:	56                   	push   %esi
  801811:	e8 80 fc ff ff       	call   801496 <sys_env_set_status>
  801816:	83 c4 10             	add    $0x10,%esp
		return r;
  801819:	85 c0                	test   %eax,%eax
  80181b:	0f 48 f8             	cmovs  %eax,%edi

	return envid;
	
}
  80181e:	89 f8                	mov    %edi,%eax
  801820:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801823:	5b                   	pop    %ebx
  801824:	5e                   	pop    %esi
  801825:	5f                   	pop    %edi
  801826:	5d                   	pop    %ebp
  801827:	c3                   	ret    
		return r;
  801828:	89 c7                	mov    %eax,%edi
  80182a:	eb f2                	jmp    80181e <fork+0x165>

0080182c <sfork>:

// Challenge(not sure yet)
int
sfork(void)
{
  80182c:	f3 0f 1e fb          	endbr32 
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801836:	68 25 34 80 00       	push   $0x803425
  80183b:	68 b2 00 00 00       	push   $0xb2
  801840:	68 fe 33 80 00       	push   $0x8033fe
  801845:	e8 82 f0 ff ff       	call   8008cc <_panic>

0080184a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80184a:	f3 0f 1e fb          	endbr32 
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	56                   	push   %esi
  801852:	53                   	push   %ebx
  801853:	8b 75 08             	mov    0x8(%ebp),%esi
  801856:	8b 45 0c             	mov    0xc(%ebp),%eax
  801859:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  80185c:	85 c0                	test   %eax,%eax
  80185e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801863:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  801866:	83 ec 0c             	sub    $0xc,%esp
  801869:	50                   	push   %eax
  80186a:	e8 bd fc ff ff       	call   80152c <sys_ipc_recv>
  80186f:	83 c4 10             	add    $0x10,%esp
  801872:	85 c0                	test   %eax,%eax
  801874:	75 2b                	jne    8018a1 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  801876:	85 f6                	test   %esi,%esi
  801878:	74 0a                	je     801884 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  80187a:	a1 20 50 80 00       	mov    0x805020,%eax
  80187f:	8b 40 74             	mov    0x74(%eax),%eax
  801882:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  801884:	85 db                	test   %ebx,%ebx
  801886:	74 0a                	je     801892 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  801888:	a1 20 50 80 00       	mov    0x805020,%eax
  80188d:	8b 40 78             	mov    0x78(%eax),%eax
  801890:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  801892:	a1 20 50 80 00       	mov    0x805020,%eax
  801897:	8b 40 70             	mov    0x70(%eax),%eax
}
  80189a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80189d:	5b                   	pop    %ebx
  80189e:	5e                   	pop    %esi
  80189f:	5d                   	pop    %ebp
  8018a0:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  8018a1:	85 f6                	test   %esi,%esi
  8018a3:	74 06                	je     8018ab <ipc_recv+0x61>
  8018a5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8018ab:	85 db                	test   %ebx,%ebx
  8018ad:	74 eb                	je     80189a <ipc_recv+0x50>
  8018af:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8018b5:	eb e3                	jmp    80189a <ipc_recv+0x50>

008018b7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8018b7:	f3 0f 1e fb          	endbr32 
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	57                   	push   %edi
  8018bf:	56                   	push   %esi
  8018c0:	53                   	push   %ebx
  8018c1:	83 ec 0c             	sub    $0xc,%esp
  8018c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018c7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  8018cd:	85 db                	test   %ebx,%ebx
  8018cf:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8018d4:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8018d7:	ff 75 14             	pushl  0x14(%ebp)
  8018da:	53                   	push   %ebx
  8018db:	56                   	push   %esi
  8018dc:	57                   	push   %edi
  8018dd:	e8 23 fc ff ff       	call   801505 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  8018e2:	83 c4 10             	add    $0x10,%esp
  8018e5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8018e8:	75 07                	jne    8018f1 <ipc_send+0x3a>
			sys_yield();
  8018ea:	e8 14 fb ff ff       	call   801403 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8018ef:	eb e6                	jmp    8018d7 <ipc_send+0x20>
		}
		else if (ret == 0)
  8018f1:	85 c0                	test   %eax,%eax
  8018f3:	75 08                	jne    8018fd <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  8018f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018f8:	5b                   	pop    %ebx
  8018f9:	5e                   	pop    %esi
  8018fa:	5f                   	pop    %edi
  8018fb:	5d                   	pop    %ebp
  8018fc:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  8018fd:	50                   	push   %eax
  8018fe:	68 3b 34 80 00       	push   $0x80343b
  801903:	6a 48                	push   $0x48
  801905:	68 49 34 80 00       	push   $0x803449
  80190a:	e8 bd ef ff ff       	call   8008cc <_panic>

0080190f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80190f:	f3 0f 1e fb          	endbr32 
  801913:	55                   	push   %ebp
  801914:	89 e5                	mov    %esp,%ebp
  801916:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801919:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80191e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801921:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801927:	8b 52 50             	mov    0x50(%edx),%edx
  80192a:	39 ca                	cmp    %ecx,%edx
  80192c:	74 11                	je     80193f <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  80192e:	83 c0 01             	add    $0x1,%eax
  801931:	3d 00 04 00 00       	cmp    $0x400,%eax
  801936:	75 e6                	jne    80191e <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801938:	b8 00 00 00 00       	mov    $0x0,%eax
  80193d:	eb 0b                	jmp    80194a <ipc_find_env+0x3b>
			return envs[i].env_id;
  80193f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801942:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801947:	8b 40 48             	mov    0x48(%eax),%eax
}
  80194a:	5d                   	pop    %ebp
  80194b:	c3                   	ret    

0080194c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80194c:	f3 0f 1e fb          	endbr32 
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801953:	8b 45 08             	mov    0x8(%ebp),%eax
  801956:	05 00 00 00 30       	add    $0x30000000,%eax
  80195b:	c1 e8 0c             	shr    $0xc,%eax
}
  80195e:	5d                   	pop    %ebp
  80195f:	c3                   	ret    

00801960 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801960:	f3 0f 1e fb          	endbr32 
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801967:	8b 45 08             	mov    0x8(%ebp),%eax
  80196a:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80196f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801974:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801979:	5d                   	pop    %ebp
  80197a:	c3                   	ret    

0080197b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80197b:	f3 0f 1e fb          	endbr32 
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801987:	89 c2                	mov    %eax,%edx
  801989:	c1 ea 16             	shr    $0x16,%edx
  80198c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801993:	f6 c2 01             	test   $0x1,%dl
  801996:	74 2d                	je     8019c5 <fd_alloc+0x4a>
  801998:	89 c2                	mov    %eax,%edx
  80199a:	c1 ea 0c             	shr    $0xc,%edx
  80199d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019a4:	f6 c2 01             	test   $0x1,%dl
  8019a7:	74 1c                	je     8019c5 <fd_alloc+0x4a>
  8019a9:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8019ae:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8019b3:	75 d2                	jne    801987 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  8019b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8019be:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8019c3:	eb 0a                	jmp    8019cf <fd_alloc+0x54>
			*fd_store = fd;
  8019c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019c8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8019ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019cf:	5d                   	pop    %ebp
  8019d0:	c3                   	ret    

008019d1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8019d1:	f3 0f 1e fb          	endbr32 
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8019db:	83 f8 1f             	cmp    $0x1f,%eax
  8019de:	77 30                	ja     801a10 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8019e0:	c1 e0 0c             	shl    $0xc,%eax
  8019e3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8019e8:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8019ee:	f6 c2 01             	test   $0x1,%dl
  8019f1:	74 24                	je     801a17 <fd_lookup+0x46>
  8019f3:	89 c2                	mov    %eax,%edx
  8019f5:	c1 ea 0c             	shr    $0xc,%edx
  8019f8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019ff:	f6 c2 01             	test   $0x1,%dl
  801a02:	74 1a                	je     801a1e <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801a04:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a07:	89 02                	mov    %eax,(%edx)
	return 0;
  801a09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a0e:	5d                   	pop    %ebp
  801a0f:	c3                   	ret    
		return -E_INVAL;
  801a10:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a15:	eb f7                	jmp    801a0e <fd_lookup+0x3d>
		return -E_INVAL;
  801a17:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a1c:	eb f0                	jmp    801a0e <fd_lookup+0x3d>
  801a1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a23:	eb e9                	jmp    801a0e <fd_lookup+0x3d>

00801a25 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801a25:	f3 0f 1e fb          	endbr32 
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	83 ec 08             	sub    $0x8,%esp
  801a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801a32:	ba 00 00 00 00       	mov    $0x0,%edx
  801a37:	b8 20 40 80 00       	mov    $0x804020,%eax
		if (devtab[i]->dev_id == dev_id) {
  801a3c:	39 08                	cmp    %ecx,(%eax)
  801a3e:	74 38                	je     801a78 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  801a40:	83 c2 01             	add    $0x1,%edx
  801a43:	8b 04 95 d0 34 80 00 	mov    0x8034d0(,%edx,4),%eax
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	75 ee                	jne    801a3c <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801a4e:	a1 20 50 80 00       	mov    0x805020,%eax
  801a53:	8b 40 48             	mov    0x48(%eax),%eax
  801a56:	83 ec 04             	sub    $0x4,%esp
  801a59:	51                   	push   %ecx
  801a5a:	50                   	push   %eax
  801a5b:	68 54 34 80 00       	push   $0x803454
  801a60:	e8 4e ef ff ff       	call   8009b3 <cprintf>
	*dev = 0;
  801a65:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a68:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801a6e:	83 c4 10             	add    $0x10,%esp
  801a71:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801a76:	c9                   	leave  
  801a77:	c3                   	ret    
			*dev = devtab[i];
  801a78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a7b:	89 01                	mov    %eax,(%ecx)
			return 0;
  801a7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a82:	eb f2                	jmp    801a76 <dev_lookup+0x51>

00801a84 <fd_close>:
{
  801a84:	f3 0f 1e fb          	endbr32 
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	57                   	push   %edi
  801a8c:	56                   	push   %esi
  801a8d:	53                   	push   %ebx
  801a8e:	83 ec 24             	sub    $0x24,%esp
  801a91:	8b 75 08             	mov    0x8(%ebp),%esi
  801a94:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801a97:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a9a:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801a9b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801aa1:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801aa4:	50                   	push   %eax
  801aa5:	e8 27 ff ff ff       	call   8019d1 <fd_lookup>
  801aaa:	89 c3                	mov    %eax,%ebx
  801aac:	83 c4 10             	add    $0x10,%esp
  801aaf:	85 c0                	test   %eax,%eax
  801ab1:	78 05                	js     801ab8 <fd_close+0x34>
	    || fd != fd2)
  801ab3:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801ab6:	74 16                	je     801ace <fd_close+0x4a>
		return (must_exist ? r : 0);
  801ab8:	89 f8                	mov    %edi,%eax
  801aba:	84 c0                	test   %al,%al
  801abc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ac1:	0f 44 d8             	cmove  %eax,%ebx
}
  801ac4:	89 d8                	mov    %ebx,%eax
  801ac6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac9:	5b                   	pop    %ebx
  801aca:	5e                   	pop    %esi
  801acb:	5f                   	pop    %edi
  801acc:	5d                   	pop    %ebp
  801acd:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801ace:	83 ec 08             	sub    $0x8,%esp
  801ad1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801ad4:	50                   	push   %eax
  801ad5:	ff 36                	pushl  (%esi)
  801ad7:	e8 49 ff ff ff       	call   801a25 <dev_lookup>
  801adc:	89 c3                	mov    %eax,%ebx
  801ade:	83 c4 10             	add    $0x10,%esp
  801ae1:	85 c0                	test   %eax,%eax
  801ae3:	78 1a                	js     801aff <fd_close+0x7b>
		if (dev->dev_close)
  801ae5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ae8:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801aeb:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801af0:	85 c0                	test   %eax,%eax
  801af2:	74 0b                	je     801aff <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801af4:	83 ec 0c             	sub    $0xc,%esp
  801af7:	56                   	push   %esi
  801af8:	ff d0                	call   *%eax
  801afa:	89 c3                	mov    %eax,%ebx
  801afc:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801aff:	83 ec 08             	sub    $0x8,%esp
  801b02:	56                   	push   %esi
  801b03:	6a 00                	push   $0x0
  801b05:	e8 67 f9 ff ff       	call   801471 <sys_page_unmap>
	return r;
  801b0a:	83 c4 10             	add    $0x10,%esp
  801b0d:	eb b5                	jmp    801ac4 <fd_close+0x40>

00801b0f <close>:

int
close(int fdnum)
{
  801b0f:	f3 0f 1e fb          	endbr32 
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b1c:	50                   	push   %eax
  801b1d:	ff 75 08             	pushl  0x8(%ebp)
  801b20:	e8 ac fe ff ff       	call   8019d1 <fd_lookup>
  801b25:	83 c4 10             	add    $0x10,%esp
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	79 02                	jns    801b2e <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801b2c:	c9                   	leave  
  801b2d:	c3                   	ret    
		return fd_close(fd, 1);
  801b2e:	83 ec 08             	sub    $0x8,%esp
  801b31:	6a 01                	push   $0x1
  801b33:	ff 75 f4             	pushl  -0xc(%ebp)
  801b36:	e8 49 ff ff ff       	call   801a84 <fd_close>
  801b3b:	83 c4 10             	add    $0x10,%esp
  801b3e:	eb ec                	jmp    801b2c <close+0x1d>

00801b40 <close_all>:

void
close_all(void)
{
  801b40:	f3 0f 1e fb          	endbr32 
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	53                   	push   %ebx
  801b48:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801b4b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801b50:	83 ec 0c             	sub    $0xc,%esp
  801b53:	53                   	push   %ebx
  801b54:	e8 b6 ff ff ff       	call   801b0f <close>
	for (i = 0; i < MAXFD; i++)
  801b59:	83 c3 01             	add    $0x1,%ebx
  801b5c:	83 c4 10             	add    $0x10,%esp
  801b5f:	83 fb 20             	cmp    $0x20,%ebx
  801b62:	75 ec                	jne    801b50 <close_all+0x10>
}
  801b64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b67:	c9                   	leave  
  801b68:	c3                   	ret    

00801b69 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801b69:	f3 0f 1e fb          	endbr32 
  801b6d:	55                   	push   %ebp
  801b6e:	89 e5                	mov    %esp,%ebp
  801b70:	57                   	push   %edi
  801b71:	56                   	push   %esi
  801b72:	53                   	push   %ebx
  801b73:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801b76:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b79:	50                   	push   %eax
  801b7a:	ff 75 08             	pushl  0x8(%ebp)
  801b7d:	e8 4f fe ff ff       	call   8019d1 <fd_lookup>
  801b82:	89 c3                	mov    %eax,%ebx
  801b84:	83 c4 10             	add    $0x10,%esp
  801b87:	85 c0                	test   %eax,%eax
  801b89:	0f 88 81 00 00 00    	js     801c10 <dup+0xa7>
		return r;
	close(newfdnum);
  801b8f:	83 ec 0c             	sub    $0xc,%esp
  801b92:	ff 75 0c             	pushl  0xc(%ebp)
  801b95:	e8 75 ff ff ff       	call   801b0f <close>

	newfd = INDEX2FD(newfdnum);
  801b9a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b9d:	c1 e6 0c             	shl    $0xc,%esi
  801ba0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801ba6:	83 c4 04             	add    $0x4,%esp
  801ba9:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bac:	e8 af fd ff ff       	call   801960 <fd2data>
  801bb1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801bb3:	89 34 24             	mov    %esi,(%esp)
  801bb6:	e8 a5 fd ff ff       	call   801960 <fd2data>
  801bbb:	83 c4 10             	add    $0x10,%esp
  801bbe:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801bc0:	89 d8                	mov    %ebx,%eax
  801bc2:	c1 e8 16             	shr    $0x16,%eax
  801bc5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801bcc:	a8 01                	test   $0x1,%al
  801bce:	74 11                	je     801be1 <dup+0x78>
  801bd0:	89 d8                	mov    %ebx,%eax
  801bd2:	c1 e8 0c             	shr    $0xc,%eax
  801bd5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801bdc:	f6 c2 01             	test   $0x1,%dl
  801bdf:	75 39                	jne    801c1a <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801be1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801be4:	89 d0                	mov    %edx,%eax
  801be6:	c1 e8 0c             	shr    $0xc,%eax
  801be9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801bf0:	83 ec 0c             	sub    $0xc,%esp
  801bf3:	25 07 0e 00 00       	and    $0xe07,%eax
  801bf8:	50                   	push   %eax
  801bf9:	56                   	push   %esi
  801bfa:	6a 00                	push   $0x0
  801bfc:	52                   	push   %edx
  801bfd:	6a 00                	push   $0x0
  801bff:	e8 48 f8 ff ff       	call   80144c <sys_page_map>
  801c04:	89 c3                	mov    %eax,%ebx
  801c06:	83 c4 20             	add    $0x20,%esp
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	78 31                	js     801c3e <dup+0xd5>
		goto err;

	return newfdnum;
  801c0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801c10:	89 d8                	mov    %ebx,%eax
  801c12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c15:	5b                   	pop    %ebx
  801c16:	5e                   	pop    %esi
  801c17:	5f                   	pop    %edi
  801c18:	5d                   	pop    %ebp
  801c19:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801c1a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801c21:	83 ec 0c             	sub    $0xc,%esp
  801c24:	25 07 0e 00 00       	and    $0xe07,%eax
  801c29:	50                   	push   %eax
  801c2a:	57                   	push   %edi
  801c2b:	6a 00                	push   $0x0
  801c2d:	53                   	push   %ebx
  801c2e:	6a 00                	push   $0x0
  801c30:	e8 17 f8 ff ff       	call   80144c <sys_page_map>
  801c35:	89 c3                	mov    %eax,%ebx
  801c37:	83 c4 20             	add    $0x20,%esp
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	79 a3                	jns    801be1 <dup+0x78>
	sys_page_unmap(0, newfd);
  801c3e:	83 ec 08             	sub    $0x8,%esp
  801c41:	56                   	push   %esi
  801c42:	6a 00                	push   $0x0
  801c44:	e8 28 f8 ff ff       	call   801471 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801c49:	83 c4 08             	add    $0x8,%esp
  801c4c:	57                   	push   %edi
  801c4d:	6a 00                	push   $0x0
  801c4f:	e8 1d f8 ff ff       	call   801471 <sys_page_unmap>
	return r;
  801c54:	83 c4 10             	add    $0x10,%esp
  801c57:	eb b7                	jmp    801c10 <dup+0xa7>

00801c59 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801c59:	f3 0f 1e fb          	endbr32 
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	53                   	push   %ebx
  801c61:	83 ec 1c             	sub    $0x1c,%esp
  801c64:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c67:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c6a:	50                   	push   %eax
  801c6b:	53                   	push   %ebx
  801c6c:	e8 60 fd ff ff       	call   8019d1 <fd_lookup>
  801c71:	83 c4 10             	add    $0x10,%esp
  801c74:	85 c0                	test   %eax,%eax
  801c76:	78 3f                	js     801cb7 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c78:	83 ec 08             	sub    $0x8,%esp
  801c7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7e:	50                   	push   %eax
  801c7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c82:	ff 30                	pushl  (%eax)
  801c84:	e8 9c fd ff ff       	call   801a25 <dev_lookup>
  801c89:	83 c4 10             	add    $0x10,%esp
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	78 27                	js     801cb7 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801c90:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c93:	8b 42 08             	mov    0x8(%edx),%eax
  801c96:	83 e0 03             	and    $0x3,%eax
  801c99:	83 f8 01             	cmp    $0x1,%eax
  801c9c:	74 1e                	je     801cbc <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca1:	8b 40 08             	mov    0x8(%eax),%eax
  801ca4:	85 c0                	test   %eax,%eax
  801ca6:	74 35                	je     801cdd <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801ca8:	83 ec 04             	sub    $0x4,%esp
  801cab:	ff 75 10             	pushl  0x10(%ebp)
  801cae:	ff 75 0c             	pushl  0xc(%ebp)
  801cb1:	52                   	push   %edx
  801cb2:	ff d0                	call   *%eax
  801cb4:	83 c4 10             	add    $0x10,%esp
}
  801cb7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cba:	c9                   	leave  
  801cbb:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801cbc:	a1 20 50 80 00       	mov    0x805020,%eax
  801cc1:	8b 40 48             	mov    0x48(%eax),%eax
  801cc4:	83 ec 04             	sub    $0x4,%esp
  801cc7:	53                   	push   %ebx
  801cc8:	50                   	push   %eax
  801cc9:	68 95 34 80 00       	push   $0x803495
  801cce:	e8 e0 ec ff ff       	call   8009b3 <cprintf>
		return -E_INVAL;
  801cd3:	83 c4 10             	add    $0x10,%esp
  801cd6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801cdb:	eb da                	jmp    801cb7 <read+0x5e>
		return -E_NOT_SUPP;
  801cdd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801ce2:	eb d3                	jmp    801cb7 <read+0x5e>

00801ce4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801ce4:	f3 0f 1e fb          	endbr32 
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	57                   	push   %edi
  801cec:	56                   	push   %esi
  801ced:	53                   	push   %ebx
  801cee:	83 ec 0c             	sub    $0xc,%esp
  801cf1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cf4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801cf7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cfc:	eb 02                	jmp    801d00 <readn+0x1c>
  801cfe:	01 c3                	add    %eax,%ebx
  801d00:	39 f3                	cmp    %esi,%ebx
  801d02:	73 21                	jae    801d25 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801d04:	83 ec 04             	sub    $0x4,%esp
  801d07:	89 f0                	mov    %esi,%eax
  801d09:	29 d8                	sub    %ebx,%eax
  801d0b:	50                   	push   %eax
  801d0c:	89 d8                	mov    %ebx,%eax
  801d0e:	03 45 0c             	add    0xc(%ebp),%eax
  801d11:	50                   	push   %eax
  801d12:	57                   	push   %edi
  801d13:	e8 41 ff ff ff       	call   801c59 <read>
		if (m < 0)
  801d18:	83 c4 10             	add    $0x10,%esp
  801d1b:	85 c0                	test   %eax,%eax
  801d1d:	78 04                	js     801d23 <readn+0x3f>
			return m;
		if (m == 0)
  801d1f:	75 dd                	jne    801cfe <readn+0x1a>
  801d21:	eb 02                	jmp    801d25 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801d23:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801d25:	89 d8                	mov    %ebx,%eax
  801d27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d2a:	5b                   	pop    %ebx
  801d2b:	5e                   	pop    %esi
  801d2c:	5f                   	pop    %edi
  801d2d:	5d                   	pop    %ebp
  801d2e:	c3                   	ret    

00801d2f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801d2f:	f3 0f 1e fb          	endbr32 
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	53                   	push   %ebx
  801d37:	83 ec 1c             	sub    $0x1c,%esp
  801d3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d3d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d40:	50                   	push   %eax
  801d41:	53                   	push   %ebx
  801d42:	e8 8a fc ff ff       	call   8019d1 <fd_lookup>
  801d47:	83 c4 10             	add    $0x10,%esp
  801d4a:	85 c0                	test   %eax,%eax
  801d4c:	78 3a                	js     801d88 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d4e:	83 ec 08             	sub    $0x8,%esp
  801d51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d54:	50                   	push   %eax
  801d55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d58:	ff 30                	pushl  (%eax)
  801d5a:	e8 c6 fc ff ff       	call   801a25 <dev_lookup>
  801d5f:	83 c4 10             	add    $0x10,%esp
  801d62:	85 c0                	test   %eax,%eax
  801d64:	78 22                	js     801d88 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801d66:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d69:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801d6d:	74 1e                	je     801d8d <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801d6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d72:	8b 52 0c             	mov    0xc(%edx),%edx
  801d75:	85 d2                	test   %edx,%edx
  801d77:	74 35                	je     801dae <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801d79:	83 ec 04             	sub    $0x4,%esp
  801d7c:	ff 75 10             	pushl  0x10(%ebp)
  801d7f:	ff 75 0c             	pushl  0xc(%ebp)
  801d82:	50                   	push   %eax
  801d83:	ff d2                	call   *%edx
  801d85:	83 c4 10             	add    $0x10,%esp
}
  801d88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d8b:	c9                   	leave  
  801d8c:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801d8d:	a1 20 50 80 00       	mov    0x805020,%eax
  801d92:	8b 40 48             	mov    0x48(%eax),%eax
  801d95:	83 ec 04             	sub    $0x4,%esp
  801d98:	53                   	push   %ebx
  801d99:	50                   	push   %eax
  801d9a:	68 b1 34 80 00       	push   $0x8034b1
  801d9f:	e8 0f ec ff ff       	call   8009b3 <cprintf>
		return -E_INVAL;
  801da4:	83 c4 10             	add    $0x10,%esp
  801da7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801dac:	eb da                	jmp    801d88 <write+0x59>
		return -E_NOT_SUPP;
  801dae:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801db3:	eb d3                	jmp    801d88 <write+0x59>

00801db5 <seek>:

int
seek(int fdnum, off_t offset)
{
  801db5:	f3 0f 1e fb          	endbr32 
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
  801dbc:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dbf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc2:	50                   	push   %eax
  801dc3:	ff 75 08             	pushl  0x8(%ebp)
  801dc6:	e8 06 fc ff ff       	call   8019d1 <fd_lookup>
  801dcb:	83 c4 10             	add    $0x10,%esp
  801dce:	85 c0                	test   %eax,%eax
  801dd0:	78 0e                	js     801de0 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801dd2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801ddb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801de0:	c9                   	leave  
  801de1:	c3                   	ret    

00801de2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801de2:	f3 0f 1e fb          	endbr32 
  801de6:	55                   	push   %ebp
  801de7:	89 e5                	mov    %esp,%ebp
  801de9:	53                   	push   %ebx
  801dea:	83 ec 1c             	sub    $0x1c,%esp
  801ded:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801df0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801df3:	50                   	push   %eax
  801df4:	53                   	push   %ebx
  801df5:	e8 d7 fb ff ff       	call   8019d1 <fd_lookup>
  801dfa:	83 c4 10             	add    $0x10,%esp
  801dfd:	85 c0                	test   %eax,%eax
  801dff:	78 37                	js     801e38 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e01:	83 ec 08             	sub    $0x8,%esp
  801e04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e07:	50                   	push   %eax
  801e08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e0b:	ff 30                	pushl  (%eax)
  801e0d:	e8 13 fc ff ff       	call   801a25 <dev_lookup>
  801e12:	83 c4 10             	add    $0x10,%esp
  801e15:	85 c0                	test   %eax,%eax
  801e17:	78 1f                	js     801e38 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801e19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e1c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801e20:	74 1b                	je     801e3d <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801e22:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e25:	8b 52 18             	mov    0x18(%edx),%edx
  801e28:	85 d2                	test   %edx,%edx
  801e2a:	74 32                	je     801e5e <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801e2c:	83 ec 08             	sub    $0x8,%esp
  801e2f:	ff 75 0c             	pushl  0xc(%ebp)
  801e32:	50                   	push   %eax
  801e33:	ff d2                	call   *%edx
  801e35:	83 c4 10             	add    $0x10,%esp
}
  801e38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e3b:	c9                   	leave  
  801e3c:	c3                   	ret    
			thisenv->env_id, fdnum);
  801e3d:	a1 20 50 80 00       	mov    0x805020,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801e42:	8b 40 48             	mov    0x48(%eax),%eax
  801e45:	83 ec 04             	sub    $0x4,%esp
  801e48:	53                   	push   %ebx
  801e49:	50                   	push   %eax
  801e4a:	68 74 34 80 00       	push   $0x803474
  801e4f:	e8 5f eb ff ff       	call   8009b3 <cprintf>
		return -E_INVAL;
  801e54:	83 c4 10             	add    $0x10,%esp
  801e57:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e5c:	eb da                	jmp    801e38 <ftruncate+0x56>
		return -E_NOT_SUPP;
  801e5e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801e63:	eb d3                	jmp    801e38 <ftruncate+0x56>

00801e65 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801e65:	f3 0f 1e fb          	endbr32 
  801e69:	55                   	push   %ebp
  801e6a:	89 e5                	mov    %esp,%ebp
  801e6c:	53                   	push   %ebx
  801e6d:	83 ec 1c             	sub    $0x1c,%esp
  801e70:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e73:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e76:	50                   	push   %eax
  801e77:	ff 75 08             	pushl  0x8(%ebp)
  801e7a:	e8 52 fb ff ff       	call   8019d1 <fd_lookup>
  801e7f:	83 c4 10             	add    $0x10,%esp
  801e82:	85 c0                	test   %eax,%eax
  801e84:	78 4b                	js     801ed1 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e86:	83 ec 08             	sub    $0x8,%esp
  801e89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e8c:	50                   	push   %eax
  801e8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e90:	ff 30                	pushl  (%eax)
  801e92:	e8 8e fb ff ff       	call   801a25 <dev_lookup>
  801e97:	83 c4 10             	add    $0x10,%esp
  801e9a:	85 c0                	test   %eax,%eax
  801e9c:	78 33                	js     801ed1 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801ea5:	74 2f                	je     801ed6 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801ea7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801eaa:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801eb1:	00 00 00 
	stat->st_isdir = 0;
  801eb4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ebb:	00 00 00 
	stat->st_dev = dev;
  801ebe:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801ec4:	83 ec 08             	sub    $0x8,%esp
  801ec7:	53                   	push   %ebx
  801ec8:	ff 75 f0             	pushl  -0x10(%ebp)
  801ecb:	ff 50 14             	call   *0x14(%eax)
  801ece:	83 c4 10             	add    $0x10,%esp
}
  801ed1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ed4:	c9                   	leave  
  801ed5:	c3                   	ret    
		return -E_NOT_SUPP;
  801ed6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801edb:	eb f4                	jmp    801ed1 <fstat+0x6c>

00801edd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801edd:	f3 0f 1e fb          	endbr32 
  801ee1:	55                   	push   %ebp
  801ee2:	89 e5                	mov    %esp,%ebp
  801ee4:	56                   	push   %esi
  801ee5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801ee6:	83 ec 08             	sub    $0x8,%esp
  801ee9:	6a 00                	push   $0x0
  801eeb:	ff 75 08             	pushl  0x8(%ebp)
  801eee:	e8 01 02 00 00       	call   8020f4 <open>
  801ef3:	89 c3                	mov    %eax,%ebx
  801ef5:	83 c4 10             	add    $0x10,%esp
  801ef8:	85 c0                	test   %eax,%eax
  801efa:	78 1b                	js     801f17 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801efc:	83 ec 08             	sub    $0x8,%esp
  801eff:	ff 75 0c             	pushl  0xc(%ebp)
  801f02:	50                   	push   %eax
  801f03:	e8 5d ff ff ff       	call   801e65 <fstat>
  801f08:	89 c6                	mov    %eax,%esi
	close(fd);
  801f0a:	89 1c 24             	mov    %ebx,(%esp)
  801f0d:	e8 fd fb ff ff       	call   801b0f <close>
	return r;
  801f12:	83 c4 10             	add    $0x10,%esp
  801f15:	89 f3                	mov    %esi,%ebx
}
  801f17:	89 d8                	mov    %ebx,%eax
  801f19:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f1c:	5b                   	pop    %ebx
  801f1d:	5e                   	pop    %esi
  801f1e:	5d                   	pop    %ebp
  801f1f:	c3                   	ret    

00801f20 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  801f20:	55                   	push   %ebp
  801f21:	89 e5                	mov    %esp,%ebp
  801f23:	56                   	push   %esi
  801f24:	53                   	push   %ebx
  801f25:	89 c6                	mov    %eax,%esi
  801f27:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801f29:	83 3d 18 50 80 00 00 	cmpl   $0x0,0x805018
  801f30:	74 27                	je     801f59 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801f32:	6a 07                	push   $0x7
  801f34:	68 00 60 80 00       	push   $0x806000
  801f39:	56                   	push   %esi
  801f3a:	ff 35 18 50 80 00    	pushl  0x805018
  801f40:	e8 72 f9 ff ff       	call   8018b7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801f45:	83 c4 0c             	add    $0xc,%esp
  801f48:	6a 00                	push   $0x0
  801f4a:	53                   	push   %ebx
  801f4b:	6a 00                	push   $0x0
  801f4d:	e8 f8 f8 ff ff       	call   80184a <ipc_recv>
}
  801f52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f55:	5b                   	pop    %ebx
  801f56:	5e                   	pop    %esi
  801f57:	5d                   	pop    %ebp
  801f58:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801f59:	83 ec 0c             	sub    $0xc,%esp
  801f5c:	6a 01                	push   $0x1
  801f5e:	e8 ac f9 ff ff       	call   80190f <ipc_find_env>
  801f63:	a3 18 50 80 00       	mov    %eax,0x805018
  801f68:	83 c4 10             	add    $0x10,%esp
  801f6b:	eb c5                	jmp    801f32 <fsipc+0x12>

00801f6d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801f6d:	f3 0f 1e fb          	endbr32 
  801f71:	55                   	push   %ebp
  801f72:	89 e5                	mov    %esp,%ebp
  801f74:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801f77:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7a:	8b 40 0c             	mov    0xc(%eax),%eax
  801f7d:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801f82:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f85:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801f8a:	ba 00 00 00 00       	mov    $0x0,%edx
  801f8f:	b8 02 00 00 00       	mov    $0x2,%eax
  801f94:	e8 87 ff ff ff       	call   801f20 <fsipc>
}
  801f99:	c9                   	leave  
  801f9a:	c3                   	ret    

00801f9b <devfile_flush>:
{
  801f9b:	f3 0f 1e fb          	endbr32 
  801f9f:	55                   	push   %ebp
  801fa0:	89 e5                	mov    %esp,%ebp
  801fa2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801fa5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa8:	8b 40 0c             	mov    0xc(%eax),%eax
  801fab:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801fb0:	ba 00 00 00 00       	mov    $0x0,%edx
  801fb5:	b8 06 00 00 00       	mov    $0x6,%eax
  801fba:	e8 61 ff ff ff       	call   801f20 <fsipc>
}
  801fbf:	c9                   	leave  
  801fc0:	c3                   	ret    

00801fc1 <devfile_stat>:
{
  801fc1:	f3 0f 1e fb          	endbr32 
  801fc5:	55                   	push   %ebp
  801fc6:	89 e5                	mov    %esp,%ebp
  801fc8:	53                   	push   %ebx
  801fc9:	83 ec 04             	sub    $0x4,%esp
  801fcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801fcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd2:	8b 40 0c             	mov    0xc(%eax),%eax
  801fd5:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801fda:	ba 00 00 00 00       	mov    $0x0,%edx
  801fdf:	b8 05 00 00 00       	mov    $0x5,%eax
  801fe4:	e8 37 ff ff ff       	call   801f20 <fsipc>
  801fe9:	85 c0                	test   %eax,%eax
  801feb:	78 2c                	js     802019 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801fed:	83 ec 08             	sub    $0x8,%esp
  801ff0:	68 00 60 80 00       	push   $0x806000
  801ff5:	53                   	push   %ebx
  801ff6:	e8 c2 ef ff ff       	call   800fbd <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ffb:	a1 80 60 80 00       	mov    0x806080,%eax
  802000:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802006:	a1 84 60 80 00       	mov    0x806084,%eax
  80200b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802011:	83 c4 10             	add    $0x10,%esp
  802014:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802019:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80201c:	c9                   	leave  
  80201d:	c3                   	ret    

0080201e <devfile_write>:
{
  80201e:	f3 0f 1e fb          	endbr32 
  802022:	55                   	push   %ebp
  802023:	89 e5                	mov    %esp,%ebp
  802025:	83 ec 0c             	sub    $0xc,%esp
  802028:	8b 45 10             	mov    0x10(%ebp),%eax
  80202b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802030:	ba f8 0f 00 00       	mov    $0xff8,%edx
  802035:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802038:	8b 55 08             	mov    0x8(%ebp),%edx
  80203b:	8b 52 0c             	mov    0xc(%edx),%edx
  80203e:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  802044:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  802049:	50                   	push   %eax
  80204a:	ff 75 0c             	pushl  0xc(%ebp)
  80204d:	68 08 60 80 00       	push   $0x806008
  802052:	e8 64 f1 ff ff       	call   8011bb <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  802057:	ba 00 00 00 00       	mov    $0x0,%edx
  80205c:	b8 04 00 00 00       	mov    $0x4,%eax
  802061:	e8 ba fe ff ff       	call   801f20 <fsipc>
}
  802066:	c9                   	leave  
  802067:	c3                   	ret    

00802068 <devfile_read>:
{
  802068:	f3 0f 1e fb          	endbr32 
  80206c:	55                   	push   %ebp
  80206d:	89 e5                	mov    %esp,%ebp
  80206f:	56                   	push   %esi
  802070:	53                   	push   %ebx
  802071:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802074:	8b 45 08             	mov    0x8(%ebp),%eax
  802077:	8b 40 0c             	mov    0xc(%eax),%eax
  80207a:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80207f:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802085:	ba 00 00 00 00       	mov    $0x0,%edx
  80208a:	b8 03 00 00 00       	mov    $0x3,%eax
  80208f:	e8 8c fe ff ff       	call   801f20 <fsipc>
  802094:	89 c3                	mov    %eax,%ebx
  802096:	85 c0                	test   %eax,%eax
  802098:	78 1f                	js     8020b9 <devfile_read+0x51>
	assert(r <= n);
  80209a:	39 f0                	cmp    %esi,%eax
  80209c:	77 24                	ja     8020c2 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  80209e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8020a3:	7f 36                	jg     8020db <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8020a5:	83 ec 04             	sub    $0x4,%esp
  8020a8:	50                   	push   %eax
  8020a9:	68 00 60 80 00       	push   $0x806000
  8020ae:	ff 75 0c             	pushl  0xc(%ebp)
  8020b1:	e8 05 f1 ff ff       	call   8011bb <memmove>
	return r;
  8020b6:	83 c4 10             	add    $0x10,%esp
}
  8020b9:	89 d8                	mov    %ebx,%eax
  8020bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020be:	5b                   	pop    %ebx
  8020bf:	5e                   	pop    %esi
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    
	assert(r <= n);
  8020c2:	68 e4 34 80 00       	push   $0x8034e4
  8020c7:	68 eb 34 80 00       	push   $0x8034eb
  8020cc:	68 8c 00 00 00       	push   $0x8c
  8020d1:	68 00 35 80 00       	push   $0x803500
  8020d6:	e8 f1 e7 ff ff       	call   8008cc <_panic>
	assert(r <= PGSIZE);
  8020db:	68 0b 35 80 00       	push   $0x80350b
  8020e0:	68 eb 34 80 00       	push   $0x8034eb
  8020e5:	68 8d 00 00 00       	push   $0x8d
  8020ea:	68 00 35 80 00       	push   $0x803500
  8020ef:	e8 d8 e7 ff ff       	call   8008cc <_panic>

008020f4 <open>:
{
  8020f4:	f3 0f 1e fb          	endbr32 
  8020f8:	55                   	push   %ebp
  8020f9:	89 e5                	mov    %esp,%ebp
  8020fb:	56                   	push   %esi
  8020fc:	53                   	push   %ebx
  8020fd:	83 ec 1c             	sub    $0x1c,%esp
  802100:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  802103:	56                   	push   %esi
  802104:	e8 71 ee ff ff       	call   800f7a <strlen>
  802109:	83 c4 10             	add    $0x10,%esp
  80210c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802111:	7f 6c                	jg     80217f <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  802113:	83 ec 0c             	sub    $0xc,%esp
  802116:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802119:	50                   	push   %eax
  80211a:	e8 5c f8 ff ff       	call   80197b <fd_alloc>
  80211f:	89 c3                	mov    %eax,%ebx
  802121:	83 c4 10             	add    $0x10,%esp
  802124:	85 c0                	test   %eax,%eax
  802126:	78 3c                	js     802164 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  802128:	83 ec 08             	sub    $0x8,%esp
  80212b:	56                   	push   %esi
  80212c:	68 00 60 80 00       	push   $0x806000
  802131:	e8 87 ee ff ff       	call   800fbd <strcpy>
	fsipcbuf.open.req_omode = mode;
  802136:	8b 45 0c             	mov    0xc(%ebp),%eax
  802139:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80213e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802141:	b8 01 00 00 00       	mov    $0x1,%eax
  802146:	e8 d5 fd ff ff       	call   801f20 <fsipc>
  80214b:	89 c3                	mov    %eax,%ebx
  80214d:	83 c4 10             	add    $0x10,%esp
  802150:	85 c0                	test   %eax,%eax
  802152:	78 19                	js     80216d <open+0x79>
	return fd2num(fd);
  802154:	83 ec 0c             	sub    $0xc,%esp
  802157:	ff 75 f4             	pushl  -0xc(%ebp)
  80215a:	e8 ed f7 ff ff       	call   80194c <fd2num>
  80215f:	89 c3                	mov    %eax,%ebx
  802161:	83 c4 10             	add    $0x10,%esp
}
  802164:	89 d8                	mov    %ebx,%eax
  802166:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802169:	5b                   	pop    %ebx
  80216a:	5e                   	pop    %esi
  80216b:	5d                   	pop    %ebp
  80216c:	c3                   	ret    
		fd_close(fd, 0);
  80216d:	83 ec 08             	sub    $0x8,%esp
  802170:	6a 00                	push   $0x0
  802172:	ff 75 f4             	pushl  -0xc(%ebp)
  802175:	e8 0a f9 ff ff       	call   801a84 <fd_close>
		return r;
  80217a:	83 c4 10             	add    $0x10,%esp
  80217d:	eb e5                	jmp    802164 <open+0x70>
		return -E_BAD_PATH;
  80217f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  802184:	eb de                	jmp    802164 <open+0x70>

00802186 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802186:	f3 0f 1e fb          	endbr32 
  80218a:	55                   	push   %ebp
  80218b:	89 e5                	mov    %esp,%ebp
  80218d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802190:	ba 00 00 00 00       	mov    $0x0,%edx
  802195:	b8 08 00 00 00       	mov    $0x8,%eax
  80219a:	e8 81 fd ff ff       	call   801f20 <fsipc>
}
  80219f:	c9                   	leave  
  8021a0:	c3                   	ret    

008021a1 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8021a1:	f3 0f 1e fb          	endbr32 
  8021a5:	55                   	push   %ebp
  8021a6:	89 e5                	mov    %esp,%ebp
  8021a8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8021ab:	68 77 35 80 00       	push   $0x803577
  8021b0:	ff 75 0c             	pushl  0xc(%ebp)
  8021b3:	e8 05 ee ff ff       	call   800fbd <strcpy>
	return 0;
}
  8021b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8021bd:	c9                   	leave  
  8021be:	c3                   	ret    

008021bf <devsock_close>:
{
  8021bf:	f3 0f 1e fb          	endbr32 
  8021c3:	55                   	push   %ebp
  8021c4:	89 e5                	mov    %esp,%ebp
  8021c6:	53                   	push   %ebx
  8021c7:	83 ec 10             	sub    $0x10,%esp
  8021ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8021cd:	53                   	push   %ebx
  8021ce:	e8 18 0a 00 00       	call   802beb <pageref>
  8021d3:	89 c2                	mov    %eax,%edx
  8021d5:	83 c4 10             	add    $0x10,%esp
		return 0;
  8021d8:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8021dd:	83 fa 01             	cmp    $0x1,%edx
  8021e0:	74 05                	je     8021e7 <devsock_close+0x28>
}
  8021e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021e5:	c9                   	leave  
  8021e6:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8021e7:	83 ec 0c             	sub    $0xc,%esp
  8021ea:	ff 73 0c             	pushl  0xc(%ebx)
  8021ed:	e8 e3 02 00 00       	call   8024d5 <nsipc_close>
  8021f2:	83 c4 10             	add    $0x10,%esp
  8021f5:	eb eb                	jmp    8021e2 <devsock_close+0x23>

008021f7 <devsock_write>:
{
  8021f7:	f3 0f 1e fb          	endbr32 
  8021fb:	55                   	push   %ebp
  8021fc:	89 e5                	mov    %esp,%ebp
  8021fe:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802201:	6a 00                	push   $0x0
  802203:	ff 75 10             	pushl  0x10(%ebp)
  802206:	ff 75 0c             	pushl  0xc(%ebp)
  802209:	8b 45 08             	mov    0x8(%ebp),%eax
  80220c:	ff 70 0c             	pushl  0xc(%eax)
  80220f:	e8 b5 03 00 00       	call   8025c9 <nsipc_send>
}
  802214:	c9                   	leave  
  802215:	c3                   	ret    

00802216 <devsock_read>:
{
  802216:	f3 0f 1e fb          	endbr32 
  80221a:	55                   	push   %ebp
  80221b:	89 e5                	mov    %esp,%ebp
  80221d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802220:	6a 00                	push   $0x0
  802222:	ff 75 10             	pushl  0x10(%ebp)
  802225:	ff 75 0c             	pushl  0xc(%ebp)
  802228:	8b 45 08             	mov    0x8(%ebp),%eax
  80222b:	ff 70 0c             	pushl  0xc(%eax)
  80222e:	e8 1f 03 00 00       	call   802552 <nsipc_recv>
}
  802233:	c9                   	leave  
  802234:	c3                   	ret    

00802235 <fd2sockid>:
{
  802235:	55                   	push   %ebp
  802236:	89 e5                	mov    %esp,%ebp
  802238:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  80223b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80223e:	52                   	push   %edx
  80223f:	50                   	push   %eax
  802240:	e8 8c f7 ff ff       	call   8019d1 <fd_lookup>
  802245:	83 c4 10             	add    $0x10,%esp
  802248:	85 c0                	test   %eax,%eax
  80224a:	78 10                	js     80225c <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  80224c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80224f:	8b 0d 60 40 80 00    	mov    0x804060,%ecx
  802255:	39 08                	cmp    %ecx,(%eax)
  802257:	75 05                	jne    80225e <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  802259:	8b 40 0c             	mov    0xc(%eax),%eax
}
  80225c:	c9                   	leave  
  80225d:	c3                   	ret    
		return -E_NOT_SUPP;
  80225e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802263:	eb f7                	jmp    80225c <fd2sockid+0x27>

00802265 <alloc_sockfd>:
{
  802265:	55                   	push   %ebp
  802266:	89 e5                	mov    %esp,%ebp
  802268:	56                   	push   %esi
  802269:	53                   	push   %ebx
  80226a:	83 ec 1c             	sub    $0x1c,%esp
  80226d:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  80226f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802272:	50                   	push   %eax
  802273:	e8 03 f7 ff ff       	call   80197b <fd_alloc>
  802278:	89 c3                	mov    %eax,%ebx
  80227a:	83 c4 10             	add    $0x10,%esp
  80227d:	85 c0                	test   %eax,%eax
  80227f:	78 43                	js     8022c4 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802281:	83 ec 04             	sub    $0x4,%esp
  802284:	68 07 04 00 00       	push   $0x407
  802289:	ff 75 f4             	pushl  -0xc(%ebp)
  80228c:	6a 00                	push   $0x0
  80228e:	e8 93 f1 ff ff       	call   801426 <sys_page_alloc>
  802293:	89 c3                	mov    %eax,%ebx
  802295:	83 c4 10             	add    $0x10,%esp
  802298:	85 c0                	test   %eax,%eax
  80229a:	78 28                	js     8022c4 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  80229c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80229f:	8b 15 60 40 80 00    	mov    0x804060,%edx
  8022a5:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8022a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022aa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8022b1:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8022b4:	83 ec 0c             	sub    $0xc,%esp
  8022b7:	50                   	push   %eax
  8022b8:	e8 8f f6 ff ff       	call   80194c <fd2num>
  8022bd:	89 c3                	mov    %eax,%ebx
  8022bf:	83 c4 10             	add    $0x10,%esp
  8022c2:	eb 0c                	jmp    8022d0 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8022c4:	83 ec 0c             	sub    $0xc,%esp
  8022c7:	56                   	push   %esi
  8022c8:	e8 08 02 00 00       	call   8024d5 <nsipc_close>
		return r;
  8022cd:	83 c4 10             	add    $0x10,%esp
}
  8022d0:	89 d8                	mov    %ebx,%eax
  8022d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022d5:	5b                   	pop    %ebx
  8022d6:	5e                   	pop    %esi
  8022d7:	5d                   	pop    %ebp
  8022d8:	c3                   	ret    

008022d9 <accept>:
{
  8022d9:	f3 0f 1e fb          	endbr32 
  8022dd:	55                   	push   %ebp
  8022de:	89 e5                	mov    %esp,%ebp
  8022e0:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8022e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e6:	e8 4a ff ff ff       	call   802235 <fd2sockid>
  8022eb:	85 c0                	test   %eax,%eax
  8022ed:	78 1b                	js     80230a <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8022ef:	83 ec 04             	sub    $0x4,%esp
  8022f2:	ff 75 10             	pushl  0x10(%ebp)
  8022f5:	ff 75 0c             	pushl  0xc(%ebp)
  8022f8:	50                   	push   %eax
  8022f9:	e8 22 01 00 00       	call   802420 <nsipc_accept>
  8022fe:	83 c4 10             	add    $0x10,%esp
  802301:	85 c0                	test   %eax,%eax
  802303:	78 05                	js     80230a <accept+0x31>
	return alloc_sockfd(r);
  802305:	e8 5b ff ff ff       	call   802265 <alloc_sockfd>
}
  80230a:	c9                   	leave  
  80230b:	c3                   	ret    

0080230c <bind>:
{
  80230c:	f3 0f 1e fb          	endbr32 
  802310:	55                   	push   %ebp
  802311:	89 e5                	mov    %esp,%ebp
  802313:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802316:	8b 45 08             	mov    0x8(%ebp),%eax
  802319:	e8 17 ff ff ff       	call   802235 <fd2sockid>
  80231e:	85 c0                	test   %eax,%eax
  802320:	78 12                	js     802334 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  802322:	83 ec 04             	sub    $0x4,%esp
  802325:	ff 75 10             	pushl  0x10(%ebp)
  802328:	ff 75 0c             	pushl  0xc(%ebp)
  80232b:	50                   	push   %eax
  80232c:	e8 45 01 00 00       	call   802476 <nsipc_bind>
  802331:	83 c4 10             	add    $0x10,%esp
}
  802334:	c9                   	leave  
  802335:	c3                   	ret    

00802336 <shutdown>:
{
  802336:	f3 0f 1e fb          	endbr32 
  80233a:	55                   	push   %ebp
  80233b:	89 e5                	mov    %esp,%ebp
  80233d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802340:	8b 45 08             	mov    0x8(%ebp),%eax
  802343:	e8 ed fe ff ff       	call   802235 <fd2sockid>
  802348:	85 c0                	test   %eax,%eax
  80234a:	78 0f                	js     80235b <shutdown+0x25>
	return nsipc_shutdown(r, how);
  80234c:	83 ec 08             	sub    $0x8,%esp
  80234f:	ff 75 0c             	pushl  0xc(%ebp)
  802352:	50                   	push   %eax
  802353:	e8 57 01 00 00       	call   8024af <nsipc_shutdown>
  802358:	83 c4 10             	add    $0x10,%esp
}
  80235b:	c9                   	leave  
  80235c:	c3                   	ret    

0080235d <connect>:
{
  80235d:	f3 0f 1e fb          	endbr32 
  802361:	55                   	push   %ebp
  802362:	89 e5                	mov    %esp,%ebp
  802364:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802367:	8b 45 08             	mov    0x8(%ebp),%eax
  80236a:	e8 c6 fe ff ff       	call   802235 <fd2sockid>
  80236f:	85 c0                	test   %eax,%eax
  802371:	78 12                	js     802385 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  802373:	83 ec 04             	sub    $0x4,%esp
  802376:	ff 75 10             	pushl  0x10(%ebp)
  802379:	ff 75 0c             	pushl  0xc(%ebp)
  80237c:	50                   	push   %eax
  80237d:	e8 71 01 00 00       	call   8024f3 <nsipc_connect>
  802382:	83 c4 10             	add    $0x10,%esp
}
  802385:	c9                   	leave  
  802386:	c3                   	ret    

00802387 <listen>:
{
  802387:	f3 0f 1e fb          	endbr32 
  80238b:	55                   	push   %ebp
  80238c:	89 e5                	mov    %esp,%ebp
  80238e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802391:	8b 45 08             	mov    0x8(%ebp),%eax
  802394:	e8 9c fe ff ff       	call   802235 <fd2sockid>
  802399:	85 c0                	test   %eax,%eax
  80239b:	78 0f                	js     8023ac <listen+0x25>
	return nsipc_listen(r, backlog);
  80239d:	83 ec 08             	sub    $0x8,%esp
  8023a0:	ff 75 0c             	pushl  0xc(%ebp)
  8023a3:	50                   	push   %eax
  8023a4:	e8 83 01 00 00       	call   80252c <nsipc_listen>
  8023a9:	83 c4 10             	add    $0x10,%esp
}
  8023ac:	c9                   	leave  
  8023ad:	c3                   	ret    

008023ae <socket>:

int
socket(int domain, int type, int protocol)
{
  8023ae:	f3 0f 1e fb          	endbr32 
  8023b2:	55                   	push   %ebp
  8023b3:	89 e5                	mov    %esp,%ebp
  8023b5:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8023b8:	ff 75 10             	pushl  0x10(%ebp)
  8023bb:	ff 75 0c             	pushl  0xc(%ebp)
  8023be:	ff 75 08             	pushl  0x8(%ebp)
  8023c1:	e8 65 02 00 00       	call   80262b <nsipc_socket>
  8023c6:	83 c4 10             	add    $0x10,%esp
  8023c9:	85 c0                	test   %eax,%eax
  8023cb:	78 05                	js     8023d2 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  8023cd:	e8 93 fe ff ff       	call   802265 <alloc_sockfd>
}
  8023d2:	c9                   	leave  
  8023d3:	c3                   	ret    

008023d4 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8023d4:	55                   	push   %ebp
  8023d5:	89 e5                	mov    %esp,%ebp
  8023d7:	53                   	push   %ebx
  8023d8:	83 ec 04             	sub    $0x4,%esp
  8023db:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8023dd:	83 3d 1c 50 80 00 00 	cmpl   $0x0,0x80501c
  8023e4:	74 26                	je     80240c <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8023e6:	6a 07                	push   $0x7
  8023e8:	68 00 70 80 00       	push   $0x807000
  8023ed:	53                   	push   %ebx
  8023ee:	ff 35 1c 50 80 00    	pushl  0x80501c
  8023f4:	e8 be f4 ff ff       	call   8018b7 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8023f9:	83 c4 0c             	add    $0xc,%esp
  8023fc:	6a 00                	push   $0x0
  8023fe:	6a 00                	push   $0x0
  802400:	6a 00                	push   $0x0
  802402:	e8 43 f4 ff ff       	call   80184a <ipc_recv>
}
  802407:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80240a:	c9                   	leave  
  80240b:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80240c:	83 ec 0c             	sub    $0xc,%esp
  80240f:	6a 02                	push   $0x2
  802411:	e8 f9 f4 ff ff       	call   80190f <ipc_find_env>
  802416:	a3 1c 50 80 00       	mov    %eax,0x80501c
  80241b:	83 c4 10             	add    $0x10,%esp
  80241e:	eb c6                	jmp    8023e6 <nsipc+0x12>

00802420 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802420:	f3 0f 1e fb          	endbr32 
  802424:	55                   	push   %ebp
  802425:	89 e5                	mov    %esp,%ebp
  802427:	56                   	push   %esi
  802428:	53                   	push   %ebx
  802429:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80242c:	8b 45 08             	mov    0x8(%ebp),%eax
  80242f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802434:	8b 06                	mov    (%esi),%eax
  802436:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80243b:	b8 01 00 00 00       	mov    $0x1,%eax
  802440:	e8 8f ff ff ff       	call   8023d4 <nsipc>
  802445:	89 c3                	mov    %eax,%ebx
  802447:	85 c0                	test   %eax,%eax
  802449:	79 09                	jns    802454 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  80244b:	89 d8                	mov    %ebx,%eax
  80244d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802450:	5b                   	pop    %ebx
  802451:	5e                   	pop    %esi
  802452:	5d                   	pop    %ebp
  802453:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802454:	83 ec 04             	sub    $0x4,%esp
  802457:	ff 35 10 70 80 00    	pushl  0x807010
  80245d:	68 00 70 80 00       	push   $0x807000
  802462:	ff 75 0c             	pushl  0xc(%ebp)
  802465:	e8 51 ed ff ff       	call   8011bb <memmove>
		*addrlen = ret->ret_addrlen;
  80246a:	a1 10 70 80 00       	mov    0x807010,%eax
  80246f:	89 06                	mov    %eax,(%esi)
  802471:	83 c4 10             	add    $0x10,%esp
	return r;
  802474:	eb d5                	jmp    80244b <nsipc_accept+0x2b>

00802476 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802476:	f3 0f 1e fb          	endbr32 
  80247a:	55                   	push   %ebp
  80247b:	89 e5                	mov    %esp,%ebp
  80247d:	53                   	push   %ebx
  80247e:	83 ec 08             	sub    $0x8,%esp
  802481:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802484:	8b 45 08             	mov    0x8(%ebp),%eax
  802487:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80248c:	53                   	push   %ebx
  80248d:	ff 75 0c             	pushl  0xc(%ebp)
  802490:	68 04 70 80 00       	push   $0x807004
  802495:	e8 21 ed ff ff       	call   8011bb <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80249a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8024a0:	b8 02 00 00 00       	mov    $0x2,%eax
  8024a5:	e8 2a ff ff ff       	call   8023d4 <nsipc>
}
  8024aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024ad:	c9                   	leave  
  8024ae:	c3                   	ret    

008024af <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8024af:	f3 0f 1e fb          	endbr32 
  8024b3:	55                   	push   %ebp
  8024b4:	89 e5                	mov    %esp,%ebp
  8024b6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8024b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8024bc:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8024c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024c4:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8024c9:	b8 03 00 00 00       	mov    $0x3,%eax
  8024ce:	e8 01 ff ff ff       	call   8023d4 <nsipc>
}
  8024d3:	c9                   	leave  
  8024d4:	c3                   	ret    

008024d5 <nsipc_close>:

int
nsipc_close(int s)
{
  8024d5:	f3 0f 1e fb          	endbr32 
  8024d9:	55                   	push   %ebp
  8024da:	89 e5                	mov    %esp,%ebp
  8024dc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8024df:	8b 45 08             	mov    0x8(%ebp),%eax
  8024e2:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8024e7:	b8 04 00 00 00       	mov    $0x4,%eax
  8024ec:	e8 e3 fe ff ff       	call   8023d4 <nsipc>
}
  8024f1:	c9                   	leave  
  8024f2:	c3                   	ret    

008024f3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8024f3:	f3 0f 1e fb          	endbr32 
  8024f7:	55                   	push   %ebp
  8024f8:	89 e5                	mov    %esp,%ebp
  8024fa:	53                   	push   %ebx
  8024fb:	83 ec 08             	sub    $0x8,%esp
  8024fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802501:	8b 45 08             	mov    0x8(%ebp),%eax
  802504:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802509:	53                   	push   %ebx
  80250a:	ff 75 0c             	pushl  0xc(%ebp)
  80250d:	68 04 70 80 00       	push   $0x807004
  802512:	e8 a4 ec ff ff       	call   8011bb <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802517:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  80251d:	b8 05 00 00 00       	mov    $0x5,%eax
  802522:	e8 ad fe ff ff       	call   8023d4 <nsipc>
}
  802527:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80252a:	c9                   	leave  
  80252b:	c3                   	ret    

0080252c <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80252c:	f3 0f 1e fb          	endbr32 
  802530:	55                   	push   %ebp
  802531:	89 e5                	mov    %esp,%ebp
  802533:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802536:	8b 45 08             	mov    0x8(%ebp),%eax
  802539:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80253e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802541:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802546:	b8 06 00 00 00       	mov    $0x6,%eax
  80254b:	e8 84 fe ff ff       	call   8023d4 <nsipc>
}
  802550:	c9                   	leave  
  802551:	c3                   	ret    

00802552 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802552:	f3 0f 1e fb          	endbr32 
  802556:	55                   	push   %ebp
  802557:	89 e5                	mov    %esp,%ebp
  802559:	56                   	push   %esi
  80255a:	53                   	push   %ebx
  80255b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80255e:	8b 45 08             	mov    0x8(%ebp),%eax
  802561:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802566:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80256c:	8b 45 14             	mov    0x14(%ebp),%eax
  80256f:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802574:	b8 07 00 00 00       	mov    $0x7,%eax
  802579:	e8 56 fe ff ff       	call   8023d4 <nsipc>
  80257e:	89 c3                	mov    %eax,%ebx
  802580:	85 c0                	test   %eax,%eax
  802582:	78 26                	js     8025aa <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  802584:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  80258a:	b8 3f 06 00 00       	mov    $0x63f,%eax
  80258f:	0f 4e c6             	cmovle %esi,%eax
  802592:	39 c3                	cmp    %eax,%ebx
  802594:	7f 1d                	jg     8025b3 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802596:	83 ec 04             	sub    $0x4,%esp
  802599:	53                   	push   %ebx
  80259a:	68 00 70 80 00       	push   $0x807000
  80259f:	ff 75 0c             	pushl  0xc(%ebp)
  8025a2:	e8 14 ec ff ff       	call   8011bb <memmove>
  8025a7:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8025aa:	89 d8                	mov    %ebx,%eax
  8025ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025af:	5b                   	pop    %ebx
  8025b0:	5e                   	pop    %esi
  8025b1:	5d                   	pop    %ebp
  8025b2:	c3                   	ret    
		assert(r < 1600 && r <= len);
  8025b3:	68 83 35 80 00       	push   $0x803583
  8025b8:	68 eb 34 80 00       	push   $0x8034eb
  8025bd:	6a 62                	push   $0x62
  8025bf:	68 98 35 80 00       	push   $0x803598
  8025c4:	e8 03 e3 ff ff       	call   8008cc <_panic>

008025c9 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8025c9:	f3 0f 1e fb          	endbr32 
  8025cd:	55                   	push   %ebp
  8025ce:	89 e5                	mov    %esp,%ebp
  8025d0:	53                   	push   %ebx
  8025d1:	83 ec 04             	sub    $0x4,%esp
  8025d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8025d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8025da:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8025df:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8025e5:	7f 2e                	jg     802615 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8025e7:	83 ec 04             	sub    $0x4,%esp
  8025ea:	53                   	push   %ebx
  8025eb:	ff 75 0c             	pushl  0xc(%ebp)
  8025ee:	68 0c 70 80 00       	push   $0x80700c
  8025f3:	e8 c3 eb ff ff       	call   8011bb <memmove>
	nsipcbuf.send.req_size = size;
  8025f8:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8025fe:	8b 45 14             	mov    0x14(%ebp),%eax
  802601:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802606:	b8 08 00 00 00       	mov    $0x8,%eax
  80260b:	e8 c4 fd ff ff       	call   8023d4 <nsipc>
}
  802610:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802613:	c9                   	leave  
  802614:	c3                   	ret    
	assert(size < 1600);
  802615:	68 a4 35 80 00       	push   $0x8035a4
  80261a:	68 eb 34 80 00       	push   $0x8034eb
  80261f:	6a 6d                	push   $0x6d
  802621:	68 98 35 80 00       	push   $0x803598
  802626:	e8 a1 e2 ff ff       	call   8008cc <_panic>

0080262b <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80262b:	f3 0f 1e fb          	endbr32 
  80262f:	55                   	push   %ebp
  802630:	89 e5                	mov    %esp,%ebp
  802632:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802635:	8b 45 08             	mov    0x8(%ebp),%eax
  802638:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80263d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802640:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802645:	8b 45 10             	mov    0x10(%ebp),%eax
  802648:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80264d:	b8 09 00 00 00       	mov    $0x9,%eax
  802652:	e8 7d fd ff ff       	call   8023d4 <nsipc>
}
  802657:	c9                   	leave  
  802658:	c3                   	ret    

00802659 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802659:	f3 0f 1e fb          	endbr32 
  80265d:	55                   	push   %ebp
  80265e:	89 e5                	mov    %esp,%ebp
  802660:	56                   	push   %esi
  802661:	53                   	push   %ebx
  802662:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802665:	83 ec 0c             	sub    $0xc,%esp
  802668:	ff 75 08             	pushl  0x8(%ebp)
  80266b:	e8 f0 f2 ff ff       	call   801960 <fd2data>
  802670:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802672:	83 c4 08             	add    $0x8,%esp
  802675:	68 b0 35 80 00       	push   $0x8035b0
  80267a:	53                   	push   %ebx
  80267b:	e8 3d e9 ff ff       	call   800fbd <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802680:	8b 46 04             	mov    0x4(%esi),%eax
  802683:	2b 06                	sub    (%esi),%eax
  802685:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80268b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802692:	00 00 00 
	stat->st_dev = &devpipe;
  802695:	c7 83 88 00 00 00 7c 	movl   $0x80407c,0x88(%ebx)
  80269c:	40 80 00 
	return 0;
}
  80269f:	b8 00 00 00 00       	mov    $0x0,%eax
  8026a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026a7:	5b                   	pop    %ebx
  8026a8:	5e                   	pop    %esi
  8026a9:	5d                   	pop    %ebp
  8026aa:	c3                   	ret    

008026ab <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8026ab:	f3 0f 1e fb          	endbr32 
  8026af:	55                   	push   %ebp
  8026b0:	89 e5                	mov    %esp,%ebp
  8026b2:	53                   	push   %ebx
  8026b3:	83 ec 0c             	sub    $0xc,%esp
  8026b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8026b9:	53                   	push   %ebx
  8026ba:	6a 00                	push   $0x0
  8026bc:	e8 b0 ed ff ff       	call   801471 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8026c1:	89 1c 24             	mov    %ebx,(%esp)
  8026c4:	e8 97 f2 ff ff       	call   801960 <fd2data>
  8026c9:	83 c4 08             	add    $0x8,%esp
  8026cc:	50                   	push   %eax
  8026cd:	6a 00                	push   $0x0
  8026cf:	e8 9d ed ff ff       	call   801471 <sys_page_unmap>
}
  8026d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8026d7:	c9                   	leave  
  8026d8:	c3                   	ret    

008026d9 <_pipeisclosed>:
{
  8026d9:	55                   	push   %ebp
  8026da:	89 e5                	mov    %esp,%ebp
  8026dc:	57                   	push   %edi
  8026dd:	56                   	push   %esi
  8026de:	53                   	push   %ebx
  8026df:	83 ec 1c             	sub    $0x1c,%esp
  8026e2:	89 c7                	mov    %eax,%edi
  8026e4:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8026e6:	a1 20 50 80 00       	mov    0x805020,%eax
  8026eb:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8026ee:	83 ec 0c             	sub    $0xc,%esp
  8026f1:	57                   	push   %edi
  8026f2:	e8 f4 04 00 00       	call   802beb <pageref>
  8026f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8026fa:	89 34 24             	mov    %esi,(%esp)
  8026fd:	e8 e9 04 00 00       	call   802beb <pageref>
		nn = thisenv->env_runs;
  802702:	8b 15 20 50 80 00    	mov    0x805020,%edx
  802708:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80270b:	83 c4 10             	add    $0x10,%esp
  80270e:	39 cb                	cmp    %ecx,%ebx
  802710:	74 1b                	je     80272d <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802712:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802715:	75 cf                	jne    8026e6 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802717:	8b 42 58             	mov    0x58(%edx),%eax
  80271a:	6a 01                	push   $0x1
  80271c:	50                   	push   %eax
  80271d:	53                   	push   %ebx
  80271e:	68 b7 35 80 00       	push   $0x8035b7
  802723:	e8 8b e2 ff ff       	call   8009b3 <cprintf>
  802728:	83 c4 10             	add    $0x10,%esp
  80272b:	eb b9                	jmp    8026e6 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80272d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802730:	0f 94 c0             	sete   %al
  802733:	0f b6 c0             	movzbl %al,%eax
}
  802736:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802739:	5b                   	pop    %ebx
  80273a:	5e                   	pop    %esi
  80273b:	5f                   	pop    %edi
  80273c:	5d                   	pop    %ebp
  80273d:	c3                   	ret    

0080273e <devpipe_write>:
{
  80273e:	f3 0f 1e fb          	endbr32 
  802742:	55                   	push   %ebp
  802743:	89 e5                	mov    %esp,%ebp
  802745:	57                   	push   %edi
  802746:	56                   	push   %esi
  802747:	53                   	push   %ebx
  802748:	83 ec 28             	sub    $0x28,%esp
  80274b:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80274e:	56                   	push   %esi
  80274f:	e8 0c f2 ff ff       	call   801960 <fd2data>
  802754:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802756:	83 c4 10             	add    $0x10,%esp
  802759:	bf 00 00 00 00       	mov    $0x0,%edi
  80275e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802761:	74 4f                	je     8027b2 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802763:	8b 43 04             	mov    0x4(%ebx),%eax
  802766:	8b 0b                	mov    (%ebx),%ecx
  802768:	8d 51 20             	lea    0x20(%ecx),%edx
  80276b:	39 d0                	cmp    %edx,%eax
  80276d:	72 14                	jb     802783 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  80276f:	89 da                	mov    %ebx,%edx
  802771:	89 f0                	mov    %esi,%eax
  802773:	e8 61 ff ff ff       	call   8026d9 <_pipeisclosed>
  802778:	85 c0                	test   %eax,%eax
  80277a:	75 3b                	jne    8027b7 <devpipe_write+0x79>
			sys_yield();
  80277c:	e8 82 ec ff ff       	call   801403 <sys_yield>
  802781:	eb e0                	jmp    802763 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802783:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802786:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80278a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80278d:	89 c2                	mov    %eax,%edx
  80278f:	c1 fa 1f             	sar    $0x1f,%edx
  802792:	89 d1                	mov    %edx,%ecx
  802794:	c1 e9 1b             	shr    $0x1b,%ecx
  802797:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80279a:	83 e2 1f             	and    $0x1f,%edx
  80279d:	29 ca                	sub    %ecx,%edx
  80279f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8027a3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8027a7:	83 c0 01             	add    $0x1,%eax
  8027aa:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8027ad:	83 c7 01             	add    $0x1,%edi
  8027b0:	eb ac                	jmp    80275e <devpipe_write+0x20>
	return i;
  8027b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8027b5:	eb 05                	jmp    8027bc <devpipe_write+0x7e>
				return 0;
  8027b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8027bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027bf:	5b                   	pop    %ebx
  8027c0:	5e                   	pop    %esi
  8027c1:	5f                   	pop    %edi
  8027c2:	5d                   	pop    %ebp
  8027c3:	c3                   	ret    

008027c4 <devpipe_read>:
{
  8027c4:	f3 0f 1e fb          	endbr32 
  8027c8:	55                   	push   %ebp
  8027c9:	89 e5                	mov    %esp,%ebp
  8027cb:	57                   	push   %edi
  8027cc:	56                   	push   %esi
  8027cd:	53                   	push   %ebx
  8027ce:	83 ec 18             	sub    $0x18,%esp
  8027d1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8027d4:	57                   	push   %edi
  8027d5:	e8 86 f1 ff ff       	call   801960 <fd2data>
  8027da:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8027dc:	83 c4 10             	add    $0x10,%esp
  8027df:	be 00 00 00 00       	mov    $0x0,%esi
  8027e4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8027e7:	75 14                	jne    8027fd <devpipe_read+0x39>
	return i;
  8027e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8027ec:	eb 02                	jmp    8027f0 <devpipe_read+0x2c>
				return i;
  8027ee:	89 f0                	mov    %esi,%eax
}
  8027f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027f3:	5b                   	pop    %ebx
  8027f4:	5e                   	pop    %esi
  8027f5:	5f                   	pop    %edi
  8027f6:	5d                   	pop    %ebp
  8027f7:	c3                   	ret    
			sys_yield();
  8027f8:	e8 06 ec ff ff       	call   801403 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8027fd:	8b 03                	mov    (%ebx),%eax
  8027ff:	3b 43 04             	cmp    0x4(%ebx),%eax
  802802:	75 18                	jne    80281c <devpipe_read+0x58>
			if (i > 0)
  802804:	85 f6                	test   %esi,%esi
  802806:	75 e6                	jne    8027ee <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  802808:	89 da                	mov    %ebx,%edx
  80280a:	89 f8                	mov    %edi,%eax
  80280c:	e8 c8 fe ff ff       	call   8026d9 <_pipeisclosed>
  802811:	85 c0                	test   %eax,%eax
  802813:	74 e3                	je     8027f8 <devpipe_read+0x34>
				return 0;
  802815:	b8 00 00 00 00       	mov    $0x0,%eax
  80281a:	eb d4                	jmp    8027f0 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80281c:	99                   	cltd   
  80281d:	c1 ea 1b             	shr    $0x1b,%edx
  802820:	01 d0                	add    %edx,%eax
  802822:	83 e0 1f             	and    $0x1f,%eax
  802825:	29 d0                	sub    %edx,%eax
  802827:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80282c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80282f:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802832:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802835:	83 c6 01             	add    $0x1,%esi
  802838:	eb aa                	jmp    8027e4 <devpipe_read+0x20>

0080283a <pipe>:
{
  80283a:	f3 0f 1e fb          	endbr32 
  80283e:	55                   	push   %ebp
  80283f:	89 e5                	mov    %esp,%ebp
  802841:	56                   	push   %esi
  802842:	53                   	push   %ebx
  802843:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802846:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802849:	50                   	push   %eax
  80284a:	e8 2c f1 ff ff       	call   80197b <fd_alloc>
  80284f:	89 c3                	mov    %eax,%ebx
  802851:	83 c4 10             	add    $0x10,%esp
  802854:	85 c0                	test   %eax,%eax
  802856:	0f 88 23 01 00 00    	js     80297f <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80285c:	83 ec 04             	sub    $0x4,%esp
  80285f:	68 07 04 00 00       	push   $0x407
  802864:	ff 75 f4             	pushl  -0xc(%ebp)
  802867:	6a 00                	push   $0x0
  802869:	e8 b8 eb ff ff       	call   801426 <sys_page_alloc>
  80286e:	89 c3                	mov    %eax,%ebx
  802870:	83 c4 10             	add    $0x10,%esp
  802873:	85 c0                	test   %eax,%eax
  802875:	0f 88 04 01 00 00    	js     80297f <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  80287b:	83 ec 0c             	sub    $0xc,%esp
  80287e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802881:	50                   	push   %eax
  802882:	e8 f4 f0 ff ff       	call   80197b <fd_alloc>
  802887:	89 c3                	mov    %eax,%ebx
  802889:	83 c4 10             	add    $0x10,%esp
  80288c:	85 c0                	test   %eax,%eax
  80288e:	0f 88 db 00 00 00    	js     80296f <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802894:	83 ec 04             	sub    $0x4,%esp
  802897:	68 07 04 00 00       	push   $0x407
  80289c:	ff 75 f0             	pushl  -0x10(%ebp)
  80289f:	6a 00                	push   $0x0
  8028a1:	e8 80 eb ff ff       	call   801426 <sys_page_alloc>
  8028a6:	89 c3                	mov    %eax,%ebx
  8028a8:	83 c4 10             	add    $0x10,%esp
  8028ab:	85 c0                	test   %eax,%eax
  8028ad:	0f 88 bc 00 00 00    	js     80296f <pipe+0x135>
	va = fd2data(fd0);
  8028b3:	83 ec 0c             	sub    $0xc,%esp
  8028b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8028b9:	e8 a2 f0 ff ff       	call   801960 <fd2data>
  8028be:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8028c0:	83 c4 0c             	add    $0xc,%esp
  8028c3:	68 07 04 00 00       	push   $0x407
  8028c8:	50                   	push   %eax
  8028c9:	6a 00                	push   $0x0
  8028cb:	e8 56 eb ff ff       	call   801426 <sys_page_alloc>
  8028d0:	89 c3                	mov    %eax,%ebx
  8028d2:	83 c4 10             	add    $0x10,%esp
  8028d5:	85 c0                	test   %eax,%eax
  8028d7:	0f 88 82 00 00 00    	js     80295f <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8028dd:	83 ec 0c             	sub    $0xc,%esp
  8028e0:	ff 75 f0             	pushl  -0x10(%ebp)
  8028e3:	e8 78 f0 ff ff       	call   801960 <fd2data>
  8028e8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8028ef:	50                   	push   %eax
  8028f0:	6a 00                	push   $0x0
  8028f2:	56                   	push   %esi
  8028f3:	6a 00                	push   $0x0
  8028f5:	e8 52 eb ff ff       	call   80144c <sys_page_map>
  8028fa:	89 c3                	mov    %eax,%ebx
  8028fc:	83 c4 20             	add    $0x20,%esp
  8028ff:	85 c0                	test   %eax,%eax
  802901:	78 4e                	js     802951 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  802903:	a1 7c 40 80 00       	mov    0x80407c,%eax
  802908:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80290b:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80290d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802910:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802917:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80291a:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80291c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80291f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802926:	83 ec 0c             	sub    $0xc,%esp
  802929:	ff 75 f4             	pushl  -0xc(%ebp)
  80292c:	e8 1b f0 ff ff       	call   80194c <fd2num>
  802931:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802934:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802936:	83 c4 04             	add    $0x4,%esp
  802939:	ff 75 f0             	pushl  -0x10(%ebp)
  80293c:	e8 0b f0 ff ff       	call   80194c <fd2num>
  802941:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802944:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802947:	83 c4 10             	add    $0x10,%esp
  80294a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80294f:	eb 2e                	jmp    80297f <pipe+0x145>
	sys_page_unmap(0, va);
  802951:	83 ec 08             	sub    $0x8,%esp
  802954:	56                   	push   %esi
  802955:	6a 00                	push   $0x0
  802957:	e8 15 eb ff ff       	call   801471 <sys_page_unmap>
  80295c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80295f:	83 ec 08             	sub    $0x8,%esp
  802962:	ff 75 f0             	pushl  -0x10(%ebp)
  802965:	6a 00                	push   $0x0
  802967:	e8 05 eb ff ff       	call   801471 <sys_page_unmap>
  80296c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80296f:	83 ec 08             	sub    $0x8,%esp
  802972:	ff 75 f4             	pushl  -0xc(%ebp)
  802975:	6a 00                	push   $0x0
  802977:	e8 f5 ea ff ff       	call   801471 <sys_page_unmap>
  80297c:	83 c4 10             	add    $0x10,%esp
}
  80297f:	89 d8                	mov    %ebx,%eax
  802981:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802984:	5b                   	pop    %ebx
  802985:	5e                   	pop    %esi
  802986:	5d                   	pop    %ebp
  802987:	c3                   	ret    

00802988 <pipeisclosed>:
{
  802988:	f3 0f 1e fb          	endbr32 
  80298c:	55                   	push   %ebp
  80298d:	89 e5                	mov    %esp,%ebp
  80298f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802992:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802995:	50                   	push   %eax
  802996:	ff 75 08             	pushl  0x8(%ebp)
  802999:	e8 33 f0 ff ff       	call   8019d1 <fd_lookup>
  80299e:	83 c4 10             	add    $0x10,%esp
  8029a1:	85 c0                	test   %eax,%eax
  8029a3:	78 18                	js     8029bd <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  8029a5:	83 ec 0c             	sub    $0xc,%esp
  8029a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8029ab:	e8 b0 ef ff ff       	call   801960 <fd2data>
  8029b0:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8029b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029b5:	e8 1f fd ff ff       	call   8026d9 <_pipeisclosed>
  8029ba:	83 c4 10             	add    $0x10,%esp
}
  8029bd:	c9                   	leave  
  8029be:	c3                   	ret    

008029bf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8029bf:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  8029c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8029c8:	c3                   	ret    

008029c9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8029c9:	f3 0f 1e fb          	endbr32 
  8029cd:	55                   	push   %ebp
  8029ce:	89 e5                	mov    %esp,%ebp
  8029d0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8029d3:	68 cf 35 80 00       	push   $0x8035cf
  8029d8:	ff 75 0c             	pushl  0xc(%ebp)
  8029db:	e8 dd e5 ff ff       	call   800fbd <strcpy>
	return 0;
}
  8029e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8029e5:	c9                   	leave  
  8029e6:	c3                   	ret    

008029e7 <devcons_write>:
{
  8029e7:	f3 0f 1e fb          	endbr32 
  8029eb:	55                   	push   %ebp
  8029ec:	89 e5                	mov    %esp,%ebp
  8029ee:	57                   	push   %edi
  8029ef:	56                   	push   %esi
  8029f0:	53                   	push   %ebx
  8029f1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8029f7:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8029fc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802a02:	3b 75 10             	cmp    0x10(%ebp),%esi
  802a05:	73 31                	jae    802a38 <devcons_write+0x51>
		m = n - tot;
  802a07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802a0a:	29 f3                	sub    %esi,%ebx
  802a0c:	83 fb 7f             	cmp    $0x7f,%ebx
  802a0f:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802a14:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802a17:	83 ec 04             	sub    $0x4,%esp
  802a1a:	53                   	push   %ebx
  802a1b:	89 f0                	mov    %esi,%eax
  802a1d:	03 45 0c             	add    0xc(%ebp),%eax
  802a20:	50                   	push   %eax
  802a21:	57                   	push   %edi
  802a22:	e8 94 e7 ff ff       	call   8011bb <memmove>
		sys_cputs(buf, m);
  802a27:	83 c4 08             	add    $0x8,%esp
  802a2a:	53                   	push   %ebx
  802a2b:	57                   	push   %edi
  802a2c:	e8 46 e9 ff ff       	call   801377 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802a31:	01 de                	add    %ebx,%esi
  802a33:	83 c4 10             	add    $0x10,%esp
  802a36:	eb ca                	jmp    802a02 <devcons_write+0x1b>
}
  802a38:	89 f0                	mov    %esi,%eax
  802a3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a3d:	5b                   	pop    %ebx
  802a3e:	5e                   	pop    %esi
  802a3f:	5f                   	pop    %edi
  802a40:	5d                   	pop    %ebp
  802a41:	c3                   	ret    

00802a42 <devcons_read>:
{
  802a42:	f3 0f 1e fb          	endbr32 
  802a46:	55                   	push   %ebp
  802a47:	89 e5                	mov    %esp,%ebp
  802a49:	83 ec 08             	sub    $0x8,%esp
  802a4c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802a51:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802a55:	74 21                	je     802a78 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  802a57:	e8 3d e9 ff ff       	call   801399 <sys_cgetc>
  802a5c:	85 c0                	test   %eax,%eax
  802a5e:	75 07                	jne    802a67 <devcons_read+0x25>
		sys_yield();
  802a60:	e8 9e e9 ff ff       	call   801403 <sys_yield>
  802a65:	eb f0                	jmp    802a57 <devcons_read+0x15>
	if (c < 0)
  802a67:	78 0f                	js     802a78 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  802a69:	83 f8 04             	cmp    $0x4,%eax
  802a6c:	74 0c                	je     802a7a <devcons_read+0x38>
	*(char*)vbuf = c;
  802a6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802a71:	88 02                	mov    %al,(%edx)
	return 1;
  802a73:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802a78:	c9                   	leave  
  802a79:	c3                   	ret    
		return 0;
  802a7a:	b8 00 00 00 00       	mov    $0x0,%eax
  802a7f:	eb f7                	jmp    802a78 <devcons_read+0x36>

00802a81 <cputchar>:
{
  802a81:	f3 0f 1e fb          	endbr32 
  802a85:	55                   	push   %ebp
  802a86:	89 e5                	mov    %esp,%ebp
  802a88:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  802a8e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802a91:	6a 01                	push   $0x1
  802a93:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802a96:	50                   	push   %eax
  802a97:	e8 db e8 ff ff       	call   801377 <sys_cputs>
}
  802a9c:	83 c4 10             	add    $0x10,%esp
  802a9f:	c9                   	leave  
  802aa0:	c3                   	ret    

00802aa1 <getchar>:
{
  802aa1:	f3 0f 1e fb          	endbr32 
  802aa5:	55                   	push   %ebp
  802aa6:	89 e5                	mov    %esp,%ebp
  802aa8:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802aab:	6a 01                	push   $0x1
  802aad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802ab0:	50                   	push   %eax
  802ab1:	6a 00                	push   $0x0
  802ab3:	e8 a1 f1 ff ff       	call   801c59 <read>
	if (r < 0)
  802ab8:	83 c4 10             	add    $0x10,%esp
  802abb:	85 c0                	test   %eax,%eax
  802abd:	78 06                	js     802ac5 <getchar+0x24>
	if (r < 1)
  802abf:	74 06                	je     802ac7 <getchar+0x26>
	return c;
  802ac1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802ac5:	c9                   	leave  
  802ac6:	c3                   	ret    
		return -E_EOF;
  802ac7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802acc:	eb f7                	jmp    802ac5 <getchar+0x24>

00802ace <iscons>:
{
  802ace:	f3 0f 1e fb          	endbr32 
  802ad2:	55                   	push   %ebp
  802ad3:	89 e5                	mov    %esp,%ebp
  802ad5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802ad8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802adb:	50                   	push   %eax
  802adc:	ff 75 08             	pushl  0x8(%ebp)
  802adf:	e8 ed ee ff ff       	call   8019d1 <fd_lookup>
  802ae4:	83 c4 10             	add    $0x10,%esp
  802ae7:	85 c0                	test   %eax,%eax
  802ae9:	78 11                	js     802afc <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  802aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802aee:	8b 15 98 40 80 00    	mov    0x804098,%edx
  802af4:	39 10                	cmp    %edx,(%eax)
  802af6:	0f 94 c0             	sete   %al
  802af9:	0f b6 c0             	movzbl %al,%eax
}
  802afc:	c9                   	leave  
  802afd:	c3                   	ret    

00802afe <opencons>:
{
  802afe:	f3 0f 1e fb          	endbr32 
  802b02:	55                   	push   %ebp
  802b03:	89 e5                	mov    %esp,%ebp
  802b05:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802b08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b0b:	50                   	push   %eax
  802b0c:	e8 6a ee ff ff       	call   80197b <fd_alloc>
  802b11:	83 c4 10             	add    $0x10,%esp
  802b14:	85 c0                	test   %eax,%eax
  802b16:	78 3a                	js     802b52 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802b18:	83 ec 04             	sub    $0x4,%esp
  802b1b:	68 07 04 00 00       	push   $0x407
  802b20:	ff 75 f4             	pushl  -0xc(%ebp)
  802b23:	6a 00                	push   $0x0
  802b25:	e8 fc e8 ff ff       	call   801426 <sys_page_alloc>
  802b2a:	83 c4 10             	add    $0x10,%esp
  802b2d:	85 c0                	test   %eax,%eax
  802b2f:	78 21                	js     802b52 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  802b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b34:	8b 15 98 40 80 00    	mov    0x804098,%edx
  802b3a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b3f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802b46:	83 ec 0c             	sub    $0xc,%esp
  802b49:	50                   	push   %eax
  802b4a:	e8 fd ed ff ff       	call   80194c <fd2num>
  802b4f:	83 c4 10             	add    $0x10,%esp
}
  802b52:	c9                   	leave  
  802b53:	c3                   	ret    

00802b54 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802b54:	f3 0f 1e fb          	endbr32 
  802b58:	55                   	push   %ebp
  802b59:	89 e5                	mov    %esp,%ebp
  802b5b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802b5e:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802b65:	74 0a                	je     802b71 <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802b67:	8b 45 08             	mov    0x8(%ebp),%eax
  802b6a:	a3 00 80 80 00       	mov    %eax,0x808000

}
  802b6f:	c9                   	leave  
  802b70:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  802b71:	83 ec 04             	sub    $0x4,%esp
  802b74:	6a 07                	push   $0x7
  802b76:	68 00 f0 bf ee       	push   $0xeebff000
  802b7b:	6a 00                	push   $0x0
  802b7d:	e8 a4 e8 ff ff       	call   801426 <sys_page_alloc>
  802b82:	83 c4 10             	add    $0x10,%esp
  802b85:	85 c0                	test   %eax,%eax
  802b87:	78 2a                	js     802bb3 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  802b89:	83 ec 08             	sub    $0x8,%esp
  802b8c:	68 c7 2b 80 00       	push   $0x802bc7
  802b91:	6a 00                	push   $0x0
  802b93:	e8 48 e9 ff ff       	call   8014e0 <sys_env_set_pgfault_upcall>
  802b98:	83 c4 10             	add    $0x10,%esp
  802b9b:	85 c0                	test   %eax,%eax
  802b9d:	79 c8                	jns    802b67 <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  802b9f:	83 ec 04             	sub    $0x4,%esp
  802ba2:	68 08 36 80 00       	push   $0x803608
  802ba7:	6a 2c                	push   $0x2c
  802ba9:	68 3e 36 80 00       	push   $0x80363e
  802bae:	e8 19 dd ff ff       	call   8008cc <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  802bb3:	83 ec 04             	sub    $0x4,%esp
  802bb6:	68 dc 35 80 00       	push   $0x8035dc
  802bbb:	6a 22                	push   $0x22
  802bbd:	68 3e 36 80 00       	push   $0x80363e
  802bc2:	e8 05 dd ff ff       	call   8008cc <_panic>

00802bc7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802bc7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802bc8:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax   			// 间接寻址
  802bcd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802bcf:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  802bd2:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  802bd6:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  802bdb:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  802bdf:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  802be1:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  802be4:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  802be5:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  802be8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  802be9:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  802bea:	c3                   	ret    

00802beb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802beb:	f3 0f 1e fb          	endbr32 
  802bef:	55                   	push   %ebp
  802bf0:	89 e5                	mov    %esp,%ebp
  802bf2:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802bf5:	89 c2                	mov    %eax,%edx
  802bf7:	c1 ea 16             	shr    $0x16,%edx
  802bfa:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802c01:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802c06:	f6 c1 01             	test   $0x1,%cl
  802c09:	74 1c                	je     802c27 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802c0b:	c1 e8 0c             	shr    $0xc,%eax
  802c0e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802c15:	a8 01                	test   $0x1,%al
  802c17:	74 0e                	je     802c27 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802c19:	c1 e8 0c             	shr    $0xc,%eax
  802c1c:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802c23:	ef 
  802c24:	0f b7 d2             	movzwl %dx,%edx
}
  802c27:	89 d0                	mov    %edx,%eax
  802c29:	5d                   	pop    %ebp
  802c2a:	c3                   	ret    
  802c2b:	66 90                	xchg   %ax,%ax
  802c2d:	66 90                	xchg   %ax,%ax
  802c2f:	90                   	nop

00802c30 <__udivdi3>:
  802c30:	f3 0f 1e fb          	endbr32 
  802c34:	55                   	push   %ebp
  802c35:	57                   	push   %edi
  802c36:	56                   	push   %esi
  802c37:	53                   	push   %ebx
  802c38:	83 ec 1c             	sub    $0x1c,%esp
  802c3b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802c3f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802c43:	8b 74 24 34          	mov    0x34(%esp),%esi
  802c47:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802c4b:	85 d2                	test   %edx,%edx
  802c4d:	75 19                	jne    802c68 <__udivdi3+0x38>
  802c4f:	39 f3                	cmp    %esi,%ebx
  802c51:	76 4d                	jbe    802ca0 <__udivdi3+0x70>
  802c53:	31 ff                	xor    %edi,%edi
  802c55:	89 e8                	mov    %ebp,%eax
  802c57:	89 f2                	mov    %esi,%edx
  802c59:	f7 f3                	div    %ebx
  802c5b:	89 fa                	mov    %edi,%edx
  802c5d:	83 c4 1c             	add    $0x1c,%esp
  802c60:	5b                   	pop    %ebx
  802c61:	5e                   	pop    %esi
  802c62:	5f                   	pop    %edi
  802c63:	5d                   	pop    %ebp
  802c64:	c3                   	ret    
  802c65:	8d 76 00             	lea    0x0(%esi),%esi
  802c68:	39 f2                	cmp    %esi,%edx
  802c6a:	76 14                	jbe    802c80 <__udivdi3+0x50>
  802c6c:	31 ff                	xor    %edi,%edi
  802c6e:	31 c0                	xor    %eax,%eax
  802c70:	89 fa                	mov    %edi,%edx
  802c72:	83 c4 1c             	add    $0x1c,%esp
  802c75:	5b                   	pop    %ebx
  802c76:	5e                   	pop    %esi
  802c77:	5f                   	pop    %edi
  802c78:	5d                   	pop    %ebp
  802c79:	c3                   	ret    
  802c7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802c80:	0f bd fa             	bsr    %edx,%edi
  802c83:	83 f7 1f             	xor    $0x1f,%edi
  802c86:	75 48                	jne    802cd0 <__udivdi3+0xa0>
  802c88:	39 f2                	cmp    %esi,%edx
  802c8a:	72 06                	jb     802c92 <__udivdi3+0x62>
  802c8c:	31 c0                	xor    %eax,%eax
  802c8e:	39 eb                	cmp    %ebp,%ebx
  802c90:	77 de                	ja     802c70 <__udivdi3+0x40>
  802c92:	b8 01 00 00 00       	mov    $0x1,%eax
  802c97:	eb d7                	jmp    802c70 <__udivdi3+0x40>
  802c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802ca0:	89 d9                	mov    %ebx,%ecx
  802ca2:	85 db                	test   %ebx,%ebx
  802ca4:	75 0b                	jne    802cb1 <__udivdi3+0x81>
  802ca6:	b8 01 00 00 00       	mov    $0x1,%eax
  802cab:	31 d2                	xor    %edx,%edx
  802cad:	f7 f3                	div    %ebx
  802caf:	89 c1                	mov    %eax,%ecx
  802cb1:	31 d2                	xor    %edx,%edx
  802cb3:	89 f0                	mov    %esi,%eax
  802cb5:	f7 f1                	div    %ecx
  802cb7:	89 c6                	mov    %eax,%esi
  802cb9:	89 e8                	mov    %ebp,%eax
  802cbb:	89 f7                	mov    %esi,%edi
  802cbd:	f7 f1                	div    %ecx
  802cbf:	89 fa                	mov    %edi,%edx
  802cc1:	83 c4 1c             	add    $0x1c,%esp
  802cc4:	5b                   	pop    %ebx
  802cc5:	5e                   	pop    %esi
  802cc6:	5f                   	pop    %edi
  802cc7:	5d                   	pop    %ebp
  802cc8:	c3                   	ret    
  802cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802cd0:	89 f9                	mov    %edi,%ecx
  802cd2:	b8 20 00 00 00       	mov    $0x20,%eax
  802cd7:	29 f8                	sub    %edi,%eax
  802cd9:	d3 e2                	shl    %cl,%edx
  802cdb:	89 54 24 08          	mov    %edx,0x8(%esp)
  802cdf:	89 c1                	mov    %eax,%ecx
  802ce1:	89 da                	mov    %ebx,%edx
  802ce3:	d3 ea                	shr    %cl,%edx
  802ce5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802ce9:	09 d1                	or     %edx,%ecx
  802ceb:	89 f2                	mov    %esi,%edx
  802ced:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802cf1:	89 f9                	mov    %edi,%ecx
  802cf3:	d3 e3                	shl    %cl,%ebx
  802cf5:	89 c1                	mov    %eax,%ecx
  802cf7:	d3 ea                	shr    %cl,%edx
  802cf9:	89 f9                	mov    %edi,%ecx
  802cfb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802cff:	89 eb                	mov    %ebp,%ebx
  802d01:	d3 e6                	shl    %cl,%esi
  802d03:	89 c1                	mov    %eax,%ecx
  802d05:	d3 eb                	shr    %cl,%ebx
  802d07:	09 de                	or     %ebx,%esi
  802d09:	89 f0                	mov    %esi,%eax
  802d0b:	f7 74 24 08          	divl   0x8(%esp)
  802d0f:	89 d6                	mov    %edx,%esi
  802d11:	89 c3                	mov    %eax,%ebx
  802d13:	f7 64 24 0c          	mull   0xc(%esp)
  802d17:	39 d6                	cmp    %edx,%esi
  802d19:	72 15                	jb     802d30 <__udivdi3+0x100>
  802d1b:	89 f9                	mov    %edi,%ecx
  802d1d:	d3 e5                	shl    %cl,%ebp
  802d1f:	39 c5                	cmp    %eax,%ebp
  802d21:	73 04                	jae    802d27 <__udivdi3+0xf7>
  802d23:	39 d6                	cmp    %edx,%esi
  802d25:	74 09                	je     802d30 <__udivdi3+0x100>
  802d27:	89 d8                	mov    %ebx,%eax
  802d29:	31 ff                	xor    %edi,%edi
  802d2b:	e9 40 ff ff ff       	jmp    802c70 <__udivdi3+0x40>
  802d30:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802d33:	31 ff                	xor    %edi,%edi
  802d35:	e9 36 ff ff ff       	jmp    802c70 <__udivdi3+0x40>
  802d3a:	66 90                	xchg   %ax,%ax
  802d3c:	66 90                	xchg   %ax,%ax
  802d3e:	66 90                	xchg   %ax,%ax

00802d40 <__umoddi3>:
  802d40:	f3 0f 1e fb          	endbr32 
  802d44:	55                   	push   %ebp
  802d45:	57                   	push   %edi
  802d46:	56                   	push   %esi
  802d47:	53                   	push   %ebx
  802d48:	83 ec 1c             	sub    $0x1c,%esp
  802d4b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802d4f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802d53:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802d57:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802d5b:	85 c0                	test   %eax,%eax
  802d5d:	75 19                	jne    802d78 <__umoddi3+0x38>
  802d5f:	39 df                	cmp    %ebx,%edi
  802d61:	76 5d                	jbe    802dc0 <__umoddi3+0x80>
  802d63:	89 f0                	mov    %esi,%eax
  802d65:	89 da                	mov    %ebx,%edx
  802d67:	f7 f7                	div    %edi
  802d69:	89 d0                	mov    %edx,%eax
  802d6b:	31 d2                	xor    %edx,%edx
  802d6d:	83 c4 1c             	add    $0x1c,%esp
  802d70:	5b                   	pop    %ebx
  802d71:	5e                   	pop    %esi
  802d72:	5f                   	pop    %edi
  802d73:	5d                   	pop    %ebp
  802d74:	c3                   	ret    
  802d75:	8d 76 00             	lea    0x0(%esi),%esi
  802d78:	89 f2                	mov    %esi,%edx
  802d7a:	39 d8                	cmp    %ebx,%eax
  802d7c:	76 12                	jbe    802d90 <__umoddi3+0x50>
  802d7e:	89 f0                	mov    %esi,%eax
  802d80:	89 da                	mov    %ebx,%edx
  802d82:	83 c4 1c             	add    $0x1c,%esp
  802d85:	5b                   	pop    %ebx
  802d86:	5e                   	pop    %esi
  802d87:	5f                   	pop    %edi
  802d88:	5d                   	pop    %ebp
  802d89:	c3                   	ret    
  802d8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802d90:	0f bd e8             	bsr    %eax,%ebp
  802d93:	83 f5 1f             	xor    $0x1f,%ebp
  802d96:	75 50                	jne    802de8 <__umoddi3+0xa8>
  802d98:	39 d8                	cmp    %ebx,%eax
  802d9a:	0f 82 e0 00 00 00    	jb     802e80 <__umoddi3+0x140>
  802da0:	89 d9                	mov    %ebx,%ecx
  802da2:	39 f7                	cmp    %esi,%edi
  802da4:	0f 86 d6 00 00 00    	jbe    802e80 <__umoddi3+0x140>
  802daa:	89 d0                	mov    %edx,%eax
  802dac:	89 ca                	mov    %ecx,%edx
  802dae:	83 c4 1c             	add    $0x1c,%esp
  802db1:	5b                   	pop    %ebx
  802db2:	5e                   	pop    %esi
  802db3:	5f                   	pop    %edi
  802db4:	5d                   	pop    %ebp
  802db5:	c3                   	ret    
  802db6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802dbd:	8d 76 00             	lea    0x0(%esi),%esi
  802dc0:	89 fd                	mov    %edi,%ebp
  802dc2:	85 ff                	test   %edi,%edi
  802dc4:	75 0b                	jne    802dd1 <__umoddi3+0x91>
  802dc6:	b8 01 00 00 00       	mov    $0x1,%eax
  802dcb:	31 d2                	xor    %edx,%edx
  802dcd:	f7 f7                	div    %edi
  802dcf:	89 c5                	mov    %eax,%ebp
  802dd1:	89 d8                	mov    %ebx,%eax
  802dd3:	31 d2                	xor    %edx,%edx
  802dd5:	f7 f5                	div    %ebp
  802dd7:	89 f0                	mov    %esi,%eax
  802dd9:	f7 f5                	div    %ebp
  802ddb:	89 d0                	mov    %edx,%eax
  802ddd:	31 d2                	xor    %edx,%edx
  802ddf:	eb 8c                	jmp    802d6d <__umoddi3+0x2d>
  802de1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802de8:	89 e9                	mov    %ebp,%ecx
  802dea:	ba 20 00 00 00       	mov    $0x20,%edx
  802def:	29 ea                	sub    %ebp,%edx
  802df1:	d3 e0                	shl    %cl,%eax
  802df3:	89 44 24 08          	mov    %eax,0x8(%esp)
  802df7:	89 d1                	mov    %edx,%ecx
  802df9:	89 f8                	mov    %edi,%eax
  802dfb:	d3 e8                	shr    %cl,%eax
  802dfd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802e01:	89 54 24 04          	mov    %edx,0x4(%esp)
  802e05:	8b 54 24 04          	mov    0x4(%esp),%edx
  802e09:	09 c1                	or     %eax,%ecx
  802e0b:	89 d8                	mov    %ebx,%eax
  802e0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802e11:	89 e9                	mov    %ebp,%ecx
  802e13:	d3 e7                	shl    %cl,%edi
  802e15:	89 d1                	mov    %edx,%ecx
  802e17:	d3 e8                	shr    %cl,%eax
  802e19:	89 e9                	mov    %ebp,%ecx
  802e1b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802e1f:	d3 e3                	shl    %cl,%ebx
  802e21:	89 c7                	mov    %eax,%edi
  802e23:	89 d1                	mov    %edx,%ecx
  802e25:	89 f0                	mov    %esi,%eax
  802e27:	d3 e8                	shr    %cl,%eax
  802e29:	89 e9                	mov    %ebp,%ecx
  802e2b:	89 fa                	mov    %edi,%edx
  802e2d:	d3 e6                	shl    %cl,%esi
  802e2f:	09 d8                	or     %ebx,%eax
  802e31:	f7 74 24 08          	divl   0x8(%esp)
  802e35:	89 d1                	mov    %edx,%ecx
  802e37:	89 f3                	mov    %esi,%ebx
  802e39:	f7 64 24 0c          	mull   0xc(%esp)
  802e3d:	89 c6                	mov    %eax,%esi
  802e3f:	89 d7                	mov    %edx,%edi
  802e41:	39 d1                	cmp    %edx,%ecx
  802e43:	72 06                	jb     802e4b <__umoddi3+0x10b>
  802e45:	75 10                	jne    802e57 <__umoddi3+0x117>
  802e47:	39 c3                	cmp    %eax,%ebx
  802e49:	73 0c                	jae    802e57 <__umoddi3+0x117>
  802e4b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  802e4f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802e53:	89 d7                	mov    %edx,%edi
  802e55:	89 c6                	mov    %eax,%esi
  802e57:	89 ca                	mov    %ecx,%edx
  802e59:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802e5e:	29 f3                	sub    %esi,%ebx
  802e60:	19 fa                	sbb    %edi,%edx
  802e62:	89 d0                	mov    %edx,%eax
  802e64:	d3 e0                	shl    %cl,%eax
  802e66:	89 e9                	mov    %ebp,%ecx
  802e68:	d3 eb                	shr    %cl,%ebx
  802e6a:	d3 ea                	shr    %cl,%edx
  802e6c:	09 d8                	or     %ebx,%eax
  802e6e:	83 c4 1c             	add    $0x1c,%esp
  802e71:	5b                   	pop    %ebx
  802e72:	5e                   	pop    %esi
  802e73:	5f                   	pop    %edi
  802e74:	5d                   	pop    %ebp
  802e75:	c3                   	ret    
  802e76:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802e7d:	8d 76 00             	lea    0x0(%esi),%esi
  802e80:	29 fe                	sub    %edi,%esi
  802e82:	19 c3                	sbb    %eax,%ebx
  802e84:	89 f2                	mov    %esi,%edx
  802e86:	89 d9                	mov    %ebx,%ecx
  802e88:	e9 1d ff ff ff       	jmp    802daa <__umoddi3+0x6a>
