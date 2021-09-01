
obj/net/testoutput:     file format elf32-i386


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
  80002c:	e8 9d 02 00 00       	call   8002ce <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
static struct jif_pkt *pkt = (struct jif_pkt*)REQVA;


void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
	envid_t ns_envid = sys_getenvid();
  80003c:	e8 09 0e 00 00       	call   800e4a <sys_getenvid>
  800041:	89 c6                	mov    %eax,%esi
	int i, r;

	binaryname = "testoutput";
  800043:	c7 05 00 40 80 00 00 	movl   $0x802900,0x804000
  80004a:	29 80 00 

	output_envid = fork();
  80004d:	e8 d1 10 00 00       	call   801123 <fork>
  800052:	a3 00 50 80 00       	mov    %eax,0x805000
	if (output_envid < 0)
  800057:	85 c0                	test   %eax,%eax
  800059:	0f 88 93 00 00 00    	js     8000f2 <umain+0xbf>
	else if (output_envid == 0) {
		output(ns_envid);
		return;
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
  80005f:	bb 00 00 00 00       	mov    $0x0,%ebx
	else if (output_envid == 0) {
  800064:	0f 84 9c 00 00 00    	je     800106 <umain+0xd3>
		if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  80006a:	83 ec 04             	sub    $0x4,%esp
  80006d:	6a 07                	push   $0x7
  80006f:	68 00 b0 fe 0f       	push   $0xffeb000
  800074:	6a 00                	push   $0x0
  800076:	e8 15 0e 00 00       	call   800e90 <sys_page_alloc>
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	85 c0                	test   %eax,%eax
  800080:	0f 88 8e 00 00 00    	js     800114 <umain+0xe1>
			panic("sys_page_alloc: %e", r);
		pkt->jp_len = snprintf(pkt->jp_data,
  800086:	53                   	push   %ebx
  800087:	68 3d 29 80 00       	push   $0x80293d
  80008c:	68 fc 0f 00 00       	push   $0xffc
  800091:	68 04 b0 fe 0f       	push   $0xffeb004
  800096:	e8 2b 09 00 00       	call   8009c6 <snprintf>
  80009b:	a3 00 b0 fe 0f       	mov    %eax,0xffeb000
				       PGSIZE - sizeof(pkt->jp_len),
				       "Packet %02d", i);
		cprintf("Transmitting packet %d\n", i);
  8000a0:	83 c4 08             	add    $0x8,%esp
  8000a3:	53                   	push   %ebx
  8000a4:	68 49 29 80 00       	push   $0x802949
  8000a9:	e8 6f 03 00 00       	call   80041d <cprintf>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8000ae:	6a 07                	push   $0x7
  8000b0:	68 00 b0 fe 0f       	push   $0xffeb000
  8000b5:	6a 0b                	push   $0xb
  8000b7:	ff 35 00 50 80 00    	pushl  0x805000
  8000bd:	e8 5f 12 00 00       	call   801321 <ipc_send>
		sys_page_unmap(0, pkt);
  8000c2:	83 c4 18             	add    $0x18,%esp
  8000c5:	68 00 b0 fe 0f       	push   $0xffeb000
  8000ca:	6a 00                	push   $0x0
  8000cc:	e8 0a 0e 00 00       	call   800edb <sys_page_unmap>
	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
  8000d1:	83 c3 01             	add    $0x1,%ebx
  8000d4:	83 c4 10             	add    $0x10,%esp
  8000d7:	83 fb 0a             	cmp    $0xa,%ebx
  8000da:	75 8e                	jne    80006a <umain+0x37>
  8000dc:	bb 14 00 00 00       	mov    $0x14,%ebx
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
		sys_yield();
  8000e1:	e8 87 0d 00 00       	call   800e6d <sys_yield>
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
  8000e6:	83 eb 01             	sub    $0x1,%ebx
  8000e9:	75 f6                	jne    8000e1 <umain+0xae>
}
  8000eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ee:	5b                   	pop    %ebx
  8000ef:	5e                   	pop    %esi
  8000f0:	5d                   	pop    %ebp
  8000f1:	c3                   	ret    
		panic("error forking");
  8000f2:	83 ec 04             	sub    $0x4,%esp
  8000f5:	68 0b 29 80 00       	push   $0x80290b
  8000fa:	6a 16                	push   $0x16
  8000fc:	68 19 29 80 00       	push   $0x802919
  800101:	e8 30 02 00 00       	call   800336 <_panic>
		output(ns_envid);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	56                   	push   %esi
  80010a:	e8 69 01 00 00       	call   800278 <output>
		return;
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb d7                	jmp    8000eb <umain+0xb8>
			panic("sys_page_alloc: %e", r);
  800114:	50                   	push   %eax
  800115:	68 2a 29 80 00       	push   $0x80292a
  80011a:	6a 1e                	push   $0x1e
  80011c:	68 19 29 80 00       	push   $0x802919
  800121:	e8 10 02 00 00       	call   800336 <_panic>

00800126 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  800126:	f3 0f 1e fb          	endbr32 
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
  800130:	83 ec 1c             	sub    $0x1c,%esp
  800133:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  800136:	e8 7f 0e 00 00       	call   800fba <sys_time_msec>
  80013b:	03 45 0c             	add    0xc(%ebp),%eax
  80013e:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  800140:	c7 05 00 40 80 00 61 	movl   $0x802961,0x804000
  800147:	29 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  80014a:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80014d:	eb 33                	jmp    800182 <timer+0x5c>
		if (r < 0)
  80014f:	85 c0                	test   %eax,%eax
  800151:	78 45                	js     800198 <timer+0x72>
		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  800153:	6a 00                	push   $0x0
  800155:	6a 00                	push   $0x0
  800157:	6a 0c                	push   $0xc
  800159:	56                   	push   %esi
  80015a:	e8 c2 11 00 00       	call   801321 <ipc_send>
  80015f:	83 c4 10             	add    $0x10,%esp
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800162:	83 ec 04             	sub    $0x4,%esp
  800165:	6a 00                	push   $0x0
  800167:	6a 00                	push   $0x0
  800169:	57                   	push   %edi
  80016a:	e8 45 11 00 00       	call   8012b4 <ipc_recv>
  80016f:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  800171:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800174:	83 c4 10             	add    $0x10,%esp
  800177:	39 f0                	cmp    %esi,%eax
  800179:	75 2f                	jne    8001aa <timer+0x84>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
				continue;
			}

			stop = sys_time_msec() + to;
  80017b:	e8 3a 0e 00 00       	call   800fba <sys_time_msec>
  800180:	01 c3                	add    %eax,%ebx
		while((r = sys_time_msec()) < stop && r >= 0) {
  800182:	e8 33 0e 00 00       	call   800fba <sys_time_msec>
  800187:	89 c2                	mov    %eax,%edx
  800189:	85 c0                	test   %eax,%eax
  80018b:	78 c2                	js     80014f <timer+0x29>
  80018d:	39 d8                	cmp    %ebx,%eax
  80018f:	73 be                	jae    80014f <timer+0x29>
			sys_yield();
  800191:	e8 d7 0c 00 00       	call   800e6d <sys_yield>
  800196:	eb ea                	jmp    800182 <timer+0x5c>
			panic("sys_time_msec: %e", r);
  800198:	52                   	push   %edx
  800199:	68 6a 29 80 00       	push   $0x80296a
  80019e:	6a 0f                	push   $0xf
  8001a0:	68 7c 29 80 00       	push   $0x80297c
  8001a5:	e8 8c 01 00 00       	call   800336 <_panic>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  8001aa:	83 ec 08             	sub    $0x8,%esp
  8001ad:	50                   	push   %eax
  8001ae:	68 88 29 80 00       	push   $0x802988
  8001b3:	e8 65 02 00 00       	call   80041d <cprintf>
				continue;
  8001b8:	83 c4 10             	add    $0x10,%esp
  8001bb:	eb a5                	jmp    800162 <timer+0x3c>

008001bd <input>:
// 这里值得注意的一点是 有可能收包（sys_netpacket_recv）太快, 
// 发送给服务器时 服务器可能读取速度慢了 导致相应的内容被冲刷, 所以这里用一个临时存储
// 将收到的数据保存在input helper environment里
void
input(envid_t ns_envid)
{
  8001bd:	f3 0f 1e fb          	endbr32 
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	57                   	push   %edi
  8001c5:	56                   	push   %esi
  8001c6:	53                   	push   %ebx
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	8b 7d 08             	mov    0x8(%ebp),%edi
	binaryname = "ns_input";
  8001cd:	c7 05 00 40 80 00 c3 	movl   $0x8029c3,0x804000
  8001d4:	29 80 00 
  8001d7:	bb 00 b0 fe 0f       	mov    $0xffeb000,%ebx
	int i, r;
	int32_t length;
	struct jif_pkt *cpkt = pkt;
	
	for(i = 0; i < 10; i++)
		if ((r = sys_page_alloc(0, (void*)((uintptr_t)pkt + i * PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8001dc:	83 ec 04             	sub    $0x4,%esp
  8001df:	6a 07                	push   $0x7
  8001e1:	53                   	push   %ebx
  8001e2:	6a 00                	push   $0x0
  8001e4:	e8 a7 0c 00 00       	call   800e90 <sys_page_alloc>
  8001e9:	83 c4 10             	add    $0x10,%esp
  8001ec:	85 c0                	test   %eax,%eax
  8001ee:	78 1a                	js     80020a <input+0x4d>
  8001f0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for(i = 0; i < 10; i++)
  8001f6:	81 fb 00 50 ff 0f    	cmp    $0xfff5000,%ebx
  8001fc:	75 de                	jne    8001dc <input+0x1f>
	struct jif_pkt *cpkt = pkt;
  8001fe:	be 00 b0 fe 0f       	mov    $0xffeb000,%esi
			panic("sys_page_alloc: %e", r);
	
	i = 0;
  800203:	bb 00 00 00 00       	mov    $0x0,%ebx
  800208:	eb 17                	jmp    800221 <input+0x64>
			panic("sys_page_alloc: %e", r);
  80020a:	50                   	push   %eax
  80020b:	68 2a 29 80 00       	push   $0x80292a
  800210:	6a 34                	push   $0x34
  800212:	68 cc 29 80 00       	push   $0x8029cc
  800217:	e8 1a 01 00 00       	call   800336 <_panic>
	while(1) {
		while((length = sys_netpacket_recv((void*)((uintptr_t)cpkt + sizeof(cpkt->jp_len)), PGSIZE - sizeof(cpkt->jp_len))) < 0) {
			// cprintf("len: %d\n", length);
			sys_yield();
  80021c:	e8 4c 0c 00 00       	call   800e6d <sys_yield>
		while((length = sys_netpacket_recv((void*)((uintptr_t)cpkt + sizeof(cpkt->jp_len)), PGSIZE - sizeof(cpkt->jp_len))) < 0) {
  800221:	83 ec 08             	sub    $0x8,%esp
  800224:	68 fc 0f 00 00       	push   $0xffc
  800229:	8d 46 04             	lea    0x4(%esi),%eax
  80022c:	50                   	push   %eax
  80022d:	e8 d0 0d 00 00       	call   801002 <sys_netpacket_recv>
  800232:	83 c4 10             	add    $0x10,%esp
  800235:	85 c0                	test   %eax,%eax
  800237:	78 e3                	js     80021c <input+0x5f>
		}

		cpkt->jp_len = length;
  800239:	89 06                	mov    %eax,(%esi)
		ipc_send(ns_envid, NSREQ_INPUT, cpkt, PTE_P | PTE_U);
  80023b:	6a 05                	push   $0x5
  80023d:	56                   	push   %esi
  80023e:	6a 0a                	push   $0xa
  800240:	57                   	push   %edi
  800241:	e8 db 10 00 00       	call   801321 <ipc_send>
		i = (i + 1) % 10;
  800246:	8d 4b 01             	lea    0x1(%ebx),%ecx
  800249:	b8 67 66 66 66       	mov    $0x66666667,%eax
  80024e:	f7 e9                	imul   %ecx
  800250:	c1 fa 02             	sar    $0x2,%edx
  800253:	89 c8                	mov    %ecx,%eax
  800255:	c1 f8 1f             	sar    $0x1f,%eax
  800258:	29 c2                	sub    %eax,%edx
  80025a:	8d 04 92             	lea    (%edx,%edx,4),%eax
  80025d:	01 c0                	add    %eax,%eax
  80025f:	29 c1                	sub    %eax,%ecx
  800261:	89 cb                	mov    %ecx,%ebx
		cpkt = (struct jif_pkt*)((uintptr_t)pkt + i * PGSIZE);
  800263:	89 ce                	mov    %ecx,%esi
  800265:	c1 e6 0c             	shl    $0xc,%esi
  800268:	81 c6 00 b0 fe 0f    	add    $0xffeb000,%esi
		sys_yield();
  80026e:	e8 fa 0b 00 00       	call   800e6d <sys_yield>
		while((length = sys_netpacket_recv((void*)((uintptr_t)cpkt + sizeof(cpkt->jp_len)), PGSIZE - sizeof(cpkt->jp_len))) < 0) {
  800273:	83 c4 10             	add    $0x10,%esp
  800276:	eb a9                	jmp    800221 <input+0x64>

00800278 <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  800278:	f3 0f 1e fb          	endbr32 
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	56                   	push   %esi
  800280:	53                   	push   %ebx
  800281:	83 ec 10             	sub    $0x10,%esp
	binaryname = "ns_output";
  800284:	c7 05 00 40 80 00 d8 	movl   $0x8029d8,0x804000
  80028b:	29 80 00 
	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
	int perm; envid_t envid;
	while(1){
		if (ipc_recv(&envid, &nsipcbuf, &perm) != NSREQ_OUTPUT)
  80028e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800291:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  800294:	eb 1f                	jmp    8002b5 <output+0x3d>
			continue;
		while(sys_netpacket_try_send(&nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len)<0){
			// 说明tx_desc_ring还没准备/队列已满
			sys_yield();
  800296:	e8 d2 0b 00 00       	call   800e6d <sys_yield>
		while(sys_netpacket_try_send(&nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len)<0){
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	ff 35 00 70 80 00    	pushl  0x807000
  8002a4:	68 04 70 80 00       	push   $0x807004
  8002a9:	e8 2f 0d 00 00       	call   800fdd <sys_netpacket_try_send>
  8002ae:	83 c4 10             	add    $0x10,%esp
  8002b1:	85 c0                	test   %eax,%eax
  8002b3:	78 e1                	js     800296 <output+0x1e>
		if (ipc_recv(&envid, &nsipcbuf, &perm) != NSREQ_OUTPUT)
  8002b5:	83 ec 04             	sub    $0x4,%esp
  8002b8:	56                   	push   %esi
  8002b9:	68 00 70 80 00       	push   $0x807000
  8002be:	53                   	push   %ebx
  8002bf:	e8 f0 0f 00 00       	call   8012b4 <ipc_recv>
  8002c4:	83 c4 10             	add    $0x10,%esp
  8002c7:	83 f8 0b             	cmp    $0xb,%eax
  8002ca:	75 e9                	jne    8002b5 <output+0x3d>
  8002cc:	eb cd                	jmp    80029b <output+0x23>

008002ce <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002ce:	f3 0f 1e fb          	endbr32 
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	56                   	push   %esi
  8002d6:	53                   	push   %ebx
  8002d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002da:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002dd:	e8 68 0b 00 00       	call   800e4a <sys_getenvid>
  8002e2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002e7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002ea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002ef:	a3 0c 50 80 00       	mov    %eax,0x80500c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002f4:	85 db                	test   %ebx,%ebx
  8002f6:	7e 07                	jle    8002ff <libmain+0x31>
		binaryname = argv[0];
  8002f8:	8b 06                	mov    (%esi),%eax
  8002fa:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	56                   	push   %esi
  800303:	53                   	push   %ebx
  800304:	e8 2a fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800309:	e8 0a 00 00 00       	call   800318 <exit>
}
  80030e:	83 c4 10             	add    $0x10,%esp
  800311:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800314:	5b                   	pop    %ebx
  800315:	5e                   	pop    %esi
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800318:	f3 0f 1e fb          	endbr32 
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  800322:	e8 83 12 00 00       	call   8015aa <close_all>
	sys_env_destroy(0);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	6a 00                	push   $0x0
  80032c:	e8 f5 0a 00 00       	call   800e26 <sys_env_destroy>
}
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	c9                   	leave  
  800335:	c3                   	ret    

00800336 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800336:	f3 0f 1e fb          	endbr32 
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
  80033d:	56                   	push   %esi
  80033e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80033f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800342:	8b 35 00 40 80 00    	mov    0x804000,%esi
  800348:	e8 fd 0a 00 00       	call   800e4a <sys_getenvid>
  80034d:	83 ec 0c             	sub    $0xc,%esp
  800350:	ff 75 0c             	pushl  0xc(%ebp)
  800353:	ff 75 08             	pushl  0x8(%ebp)
  800356:	56                   	push   %esi
  800357:	50                   	push   %eax
  800358:	68 ec 29 80 00       	push   $0x8029ec
  80035d:	e8 bb 00 00 00       	call   80041d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800362:	83 c4 18             	add    $0x18,%esp
  800365:	53                   	push   %ebx
  800366:	ff 75 10             	pushl  0x10(%ebp)
  800369:	e8 5a 00 00 00       	call   8003c8 <vcprintf>
	cprintf("\n");
  80036e:	c7 04 24 5f 29 80 00 	movl   $0x80295f,(%esp)
  800375:	e8 a3 00 00 00       	call   80041d <cprintf>
  80037a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80037d:	cc                   	int3   
  80037e:	eb fd                	jmp    80037d <_panic+0x47>

00800380 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800380:	f3 0f 1e fb          	endbr32 
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	53                   	push   %ebx
  800388:	83 ec 04             	sub    $0x4,%esp
  80038b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038e:	8b 13                	mov    (%ebx),%edx
  800390:	8d 42 01             	lea    0x1(%edx),%eax
  800393:	89 03                	mov    %eax,(%ebx)
  800395:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800398:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80039c:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a1:	74 09                	je     8003ac <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003aa:	c9                   	leave  
  8003ab:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003ac:	83 ec 08             	sub    $0x8,%esp
  8003af:	68 ff 00 00 00       	push   $0xff
  8003b4:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b7:	50                   	push   %eax
  8003b8:	e8 24 0a 00 00       	call   800de1 <sys_cputs>
		b->idx = 0;
  8003bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003c3:	83 c4 10             	add    $0x10,%esp
  8003c6:	eb db                	jmp    8003a3 <putch+0x23>

008003c8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c8:	f3 0f 1e fb          	endbr32 
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003dc:	00 00 00 
	b.cnt = 0;
  8003df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e9:	ff 75 0c             	pushl  0xc(%ebp)
  8003ec:	ff 75 08             	pushl  0x8(%ebp)
  8003ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f5:	50                   	push   %eax
  8003f6:	68 80 03 80 00       	push   $0x800380
  8003fb:	e8 20 01 00 00       	call   800520 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800409:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80040f:	50                   	push   %eax
  800410:	e8 cc 09 00 00       	call   800de1 <sys_cputs>

	return b.cnt;
}
  800415:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80041b:	c9                   	leave  
  80041c:	c3                   	ret    

0080041d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80041d:	f3 0f 1e fb          	endbr32 
  800421:	55                   	push   %ebp
  800422:	89 e5                	mov    %esp,%ebp
  800424:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800427:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80042a:	50                   	push   %eax
  80042b:	ff 75 08             	pushl  0x8(%ebp)
  80042e:	e8 95 ff ff ff       	call   8003c8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800433:	c9                   	leave  
  800434:	c3                   	ret    

00800435 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800435:	55                   	push   %ebp
  800436:	89 e5                	mov    %esp,%ebp
  800438:	57                   	push   %edi
  800439:	56                   	push   %esi
  80043a:	53                   	push   %ebx
  80043b:	83 ec 1c             	sub    $0x1c,%esp
  80043e:	89 c7                	mov    %eax,%edi
  800440:	89 d6                	mov    %edx,%esi
  800442:	8b 45 08             	mov    0x8(%ebp),%eax
  800445:	8b 55 0c             	mov    0xc(%ebp),%edx
  800448:	89 d1                	mov    %edx,%ecx
  80044a:	89 c2                	mov    %eax,%edx
  80044c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80044f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800452:	8b 45 10             	mov    0x10(%ebp),%eax
  800455:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800458:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800462:	39 c2                	cmp    %eax,%edx
  800464:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800467:	72 3e                	jb     8004a7 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800469:	83 ec 0c             	sub    $0xc,%esp
  80046c:	ff 75 18             	pushl  0x18(%ebp)
  80046f:	83 eb 01             	sub    $0x1,%ebx
  800472:	53                   	push   %ebx
  800473:	50                   	push   %eax
  800474:	83 ec 08             	sub    $0x8,%esp
  800477:	ff 75 e4             	pushl  -0x1c(%ebp)
  80047a:	ff 75 e0             	pushl  -0x20(%ebp)
  80047d:	ff 75 dc             	pushl  -0x24(%ebp)
  800480:	ff 75 d8             	pushl  -0x28(%ebp)
  800483:	e8 18 22 00 00       	call   8026a0 <__udivdi3>
  800488:	83 c4 18             	add    $0x18,%esp
  80048b:	52                   	push   %edx
  80048c:	50                   	push   %eax
  80048d:	89 f2                	mov    %esi,%edx
  80048f:	89 f8                	mov    %edi,%eax
  800491:	e8 9f ff ff ff       	call   800435 <printnum>
  800496:	83 c4 20             	add    $0x20,%esp
  800499:	eb 13                	jmp    8004ae <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	56                   	push   %esi
  80049f:	ff 75 18             	pushl  0x18(%ebp)
  8004a2:	ff d7                	call   *%edi
  8004a4:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004a7:	83 eb 01             	sub    $0x1,%ebx
  8004aa:	85 db                	test   %ebx,%ebx
  8004ac:	7f ed                	jg     80049b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	56                   	push   %esi
  8004b2:	83 ec 04             	sub    $0x4,%esp
  8004b5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004bb:	ff 75 dc             	pushl  -0x24(%ebp)
  8004be:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c1:	e8 ea 22 00 00       	call   8027b0 <__umoddi3>
  8004c6:	83 c4 14             	add    $0x14,%esp
  8004c9:	0f be 80 0f 2a 80 00 	movsbl 0x802a0f(%eax),%eax
  8004d0:	50                   	push   %eax
  8004d1:	ff d7                	call   *%edi
}
  8004d3:	83 c4 10             	add    $0x10,%esp
  8004d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d9:	5b                   	pop    %ebx
  8004da:	5e                   	pop    %esi
  8004db:	5f                   	pop    %edi
  8004dc:	5d                   	pop    %ebp
  8004dd:	c3                   	ret    

008004de <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004de:	f3 0f 1e fb          	endbr32 
  8004e2:	55                   	push   %ebp
  8004e3:	89 e5                	mov    %esp,%ebp
  8004e5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ec:	8b 10                	mov    (%eax),%edx
  8004ee:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f1:	73 0a                	jae    8004fd <sprintputch+0x1f>
		*b->buf++ = ch;
  8004f3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f6:	89 08                	mov    %ecx,(%eax)
  8004f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fb:	88 02                	mov    %al,(%edx)
}
  8004fd:	5d                   	pop    %ebp
  8004fe:	c3                   	ret    

008004ff <printfmt>:
{
  8004ff:	f3 0f 1e fb          	endbr32 
  800503:	55                   	push   %ebp
  800504:	89 e5                	mov    %esp,%ebp
  800506:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800509:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050c:	50                   	push   %eax
  80050d:	ff 75 10             	pushl  0x10(%ebp)
  800510:	ff 75 0c             	pushl  0xc(%ebp)
  800513:	ff 75 08             	pushl  0x8(%ebp)
  800516:	e8 05 00 00 00       	call   800520 <vprintfmt>
}
  80051b:	83 c4 10             	add    $0x10,%esp
  80051e:	c9                   	leave  
  80051f:	c3                   	ret    

00800520 <vprintfmt>:
{
  800520:	f3 0f 1e fb          	endbr32 
  800524:	55                   	push   %ebp
  800525:	89 e5                	mov    %esp,%ebp
  800527:	57                   	push   %edi
  800528:	56                   	push   %esi
  800529:	53                   	push   %ebx
  80052a:	83 ec 3c             	sub    $0x3c,%esp
  80052d:	8b 75 08             	mov    0x8(%ebp),%esi
  800530:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800533:	8b 7d 10             	mov    0x10(%ebp),%edi
  800536:	e9 8e 03 00 00       	jmp    8008c9 <vprintfmt+0x3a9>
		padc = ' ';
  80053b:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80053f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800546:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80054d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800554:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800559:	8d 47 01             	lea    0x1(%edi),%eax
  80055c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80055f:	0f b6 17             	movzbl (%edi),%edx
  800562:	8d 42 dd             	lea    -0x23(%edx),%eax
  800565:	3c 55                	cmp    $0x55,%al
  800567:	0f 87 df 03 00 00    	ja     80094c <vprintfmt+0x42c>
  80056d:	0f b6 c0             	movzbl %al,%eax
  800570:	3e ff 24 85 60 2b 80 	notrack jmp *0x802b60(,%eax,4)
  800577:	00 
  800578:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80057b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80057f:	eb d8                	jmp    800559 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800581:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800584:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800588:	eb cf                	jmp    800559 <vprintfmt+0x39>
  80058a:	0f b6 d2             	movzbl %dl,%edx
  80058d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800590:	b8 00 00 00 00       	mov    $0x0,%eax
  800595:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800598:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80059b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80059f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005a2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005a5:	83 f9 09             	cmp    $0x9,%ecx
  8005a8:	77 55                	ja     8005ff <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005aa:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8005ad:	eb e9                	jmp    800598 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8b 00                	mov    (%eax),%eax
  8005b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8d 40 04             	lea    0x4(%eax),%eax
  8005bd:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c7:	79 90                	jns    800559 <vprintfmt+0x39>
				width = precision, precision = -1;
  8005c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005cf:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005d6:	eb 81                	jmp    800559 <vprintfmt+0x39>
  8005d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005db:	85 c0                	test   %eax,%eax
  8005dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e2:	0f 49 d0             	cmovns %eax,%edx
  8005e5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005eb:	e9 69 ff ff ff       	jmp    800559 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005f3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005fa:	e9 5a ff ff ff       	jmp    800559 <vprintfmt+0x39>
  8005ff:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800602:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800605:	eb bc                	jmp    8005c3 <vprintfmt+0xa3>
			lflag++;
  800607:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80060a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80060d:	e9 47 ff ff ff       	jmp    800559 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 78 04             	lea    0x4(%eax),%edi
  800618:	83 ec 08             	sub    $0x8,%esp
  80061b:	53                   	push   %ebx
  80061c:	ff 30                	pushl  (%eax)
  80061e:	ff d6                	call   *%esi
			break;
  800620:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800623:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800626:	e9 9b 02 00 00       	jmp    8008c6 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8d 78 04             	lea    0x4(%eax),%edi
  800631:	8b 00                	mov    (%eax),%eax
  800633:	99                   	cltd   
  800634:	31 d0                	xor    %edx,%eax
  800636:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800638:	83 f8 0f             	cmp    $0xf,%eax
  80063b:	7f 23                	jg     800660 <vprintfmt+0x140>
  80063d:	8b 14 85 c0 2c 80 00 	mov    0x802cc0(,%eax,4),%edx
  800644:	85 d2                	test   %edx,%edx
  800646:	74 18                	je     800660 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800648:	52                   	push   %edx
  800649:	68 dd 2e 80 00       	push   $0x802edd
  80064e:	53                   	push   %ebx
  80064f:	56                   	push   %esi
  800650:	e8 aa fe ff ff       	call   8004ff <printfmt>
  800655:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800658:	89 7d 14             	mov    %edi,0x14(%ebp)
  80065b:	e9 66 02 00 00       	jmp    8008c6 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800660:	50                   	push   %eax
  800661:	68 27 2a 80 00       	push   $0x802a27
  800666:	53                   	push   %ebx
  800667:	56                   	push   %esi
  800668:	e8 92 fe ff ff       	call   8004ff <printfmt>
  80066d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800670:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800673:	e9 4e 02 00 00       	jmp    8008c6 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	83 c0 04             	add    $0x4,%eax
  80067e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800686:	85 d2                	test   %edx,%edx
  800688:	b8 20 2a 80 00       	mov    $0x802a20,%eax
  80068d:	0f 45 c2             	cmovne %edx,%eax
  800690:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800693:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800697:	7e 06                	jle    80069f <vprintfmt+0x17f>
  800699:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80069d:	75 0d                	jne    8006ac <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80069f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006a2:	89 c7                	mov    %eax,%edi
  8006a4:	03 45 e0             	add    -0x20(%ebp),%eax
  8006a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006aa:	eb 55                	jmp    800701 <vprintfmt+0x1e1>
  8006ac:	83 ec 08             	sub    $0x8,%esp
  8006af:	ff 75 d8             	pushl  -0x28(%ebp)
  8006b2:	ff 75 cc             	pushl  -0x34(%ebp)
  8006b5:	e8 46 03 00 00       	call   800a00 <strnlen>
  8006ba:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006bd:	29 c2                	sub    %eax,%edx
  8006bf:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006c2:	83 c4 10             	add    $0x10,%esp
  8006c5:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006c7:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ce:	85 ff                	test   %edi,%edi
  8006d0:	7e 11                	jle    8006e3 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	53                   	push   %ebx
  8006d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d9:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006db:	83 ef 01             	sub    $0x1,%edi
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	eb eb                	jmp    8006ce <vprintfmt+0x1ae>
  8006e3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006e6:	85 d2                	test   %edx,%edx
  8006e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ed:	0f 49 c2             	cmovns %edx,%eax
  8006f0:	29 c2                	sub    %eax,%edx
  8006f2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006f5:	eb a8                	jmp    80069f <vprintfmt+0x17f>
					putch(ch, putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	53                   	push   %ebx
  8006fb:	52                   	push   %edx
  8006fc:	ff d6                	call   *%esi
  8006fe:	83 c4 10             	add    $0x10,%esp
  800701:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800704:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800706:	83 c7 01             	add    $0x1,%edi
  800709:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80070d:	0f be d0             	movsbl %al,%edx
  800710:	85 d2                	test   %edx,%edx
  800712:	74 4b                	je     80075f <vprintfmt+0x23f>
  800714:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800718:	78 06                	js     800720 <vprintfmt+0x200>
  80071a:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80071e:	78 1e                	js     80073e <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  800720:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800724:	74 d1                	je     8006f7 <vprintfmt+0x1d7>
  800726:	0f be c0             	movsbl %al,%eax
  800729:	83 e8 20             	sub    $0x20,%eax
  80072c:	83 f8 5e             	cmp    $0x5e,%eax
  80072f:	76 c6                	jbe    8006f7 <vprintfmt+0x1d7>
					putch('?', putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	53                   	push   %ebx
  800735:	6a 3f                	push   $0x3f
  800737:	ff d6                	call   *%esi
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	eb c3                	jmp    800701 <vprintfmt+0x1e1>
  80073e:	89 cf                	mov    %ecx,%edi
  800740:	eb 0e                	jmp    800750 <vprintfmt+0x230>
				putch(' ', putdat);
  800742:	83 ec 08             	sub    $0x8,%esp
  800745:	53                   	push   %ebx
  800746:	6a 20                	push   $0x20
  800748:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80074a:	83 ef 01             	sub    $0x1,%edi
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	85 ff                	test   %edi,%edi
  800752:	7f ee                	jg     800742 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800754:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800757:	89 45 14             	mov    %eax,0x14(%ebp)
  80075a:	e9 67 01 00 00       	jmp    8008c6 <vprintfmt+0x3a6>
  80075f:	89 cf                	mov    %ecx,%edi
  800761:	eb ed                	jmp    800750 <vprintfmt+0x230>
	if (lflag >= 2)
  800763:	83 f9 01             	cmp    $0x1,%ecx
  800766:	7f 1b                	jg     800783 <vprintfmt+0x263>
	else if (lflag)
  800768:	85 c9                	test   %ecx,%ecx
  80076a:	74 63                	je     8007cf <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8b 00                	mov    (%eax),%eax
  800771:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800774:	99                   	cltd   
  800775:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800778:	8b 45 14             	mov    0x14(%ebp),%eax
  80077b:	8d 40 04             	lea    0x4(%eax),%eax
  80077e:	89 45 14             	mov    %eax,0x14(%ebp)
  800781:	eb 17                	jmp    80079a <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8b 50 04             	mov    0x4(%eax),%edx
  800789:	8b 00                	mov    (%eax),%eax
  80078b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 40 08             	lea    0x8(%eax),%eax
  800797:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80079a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80079d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007a0:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007a5:	85 c9                	test   %ecx,%ecx
  8007a7:	0f 89 ff 00 00 00    	jns    8008ac <vprintfmt+0x38c>
				putch('-', putdat);
  8007ad:	83 ec 08             	sub    $0x8,%esp
  8007b0:	53                   	push   %ebx
  8007b1:	6a 2d                	push   $0x2d
  8007b3:	ff d6                	call   *%esi
				num = -(long long) num;
  8007b5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007b8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007bb:	f7 da                	neg    %edx
  8007bd:	83 d1 00             	adc    $0x0,%ecx
  8007c0:	f7 d9                	neg    %ecx
  8007c2:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007ca:	e9 dd 00 00 00       	jmp    8008ac <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8b 00                	mov    (%eax),%eax
  8007d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d7:	99                   	cltd   
  8007d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	8d 40 04             	lea    0x4(%eax),%eax
  8007e1:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e4:	eb b4                	jmp    80079a <vprintfmt+0x27a>
	if (lflag >= 2)
  8007e6:	83 f9 01             	cmp    $0x1,%ecx
  8007e9:	7f 1e                	jg     800809 <vprintfmt+0x2e9>
	else if (lflag)
  8007eb:	85 c9                	test   %ecx,%ecx
  8007ed:	74 32                	je     800821 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8b 10                	mov    (%eax),%edx
  8007f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f9:	8d 40 04             	lea    0x4(%eax),%eax
  8007fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007ff:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800804:	e9 a3 00 00 00       	jmp    8008ac <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800809:	8b 45 14             	mov    0x14(%ebp),%eax
  80080c:	8b 10                	mov    (%eax),%edx
  80080e:	8b 48 04             	mov    0x4(%eax),%ecx
  800811:	8d 40 08             	lea    0x8(%eax),%eax
  800814:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800817:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80081c:	e9 8b 00 00 00       	jmp    8008ac <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800821:	8b 45 14             	mov    0x14(%ebp),%eax
  800824:	8b 10                	mov    (%eax),%edx
  800826:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082b:	8d 40 04             	lea    0x4(%eax),%eax
  80082e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800831:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800836:	eb 74                	jmp    8008ac <vprintfmt+0x38c>
	if (lflag >= 2)
  800838:	83 f9 01             	cmp    $0x1,%ecx
  80083b:	7f 1b                	jg     800858 <vprintfmt+0x338>
	else if (lflag)
  80083d:	85 c9                	test   %ecx,%ecx
  80083f:	74 2c                	je     80086d <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800841:	8b 45 14             	mov    0x14(%ebp),%eax
  800844:	8b 10                	mov    (%eax),%edx
  800846:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084b:	8d 40 04             	lea    0x4(%eax),%eax
  80084e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800851:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800856:	eb 54                	jmp    8008ac <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800858:	8b 45 14             	mov    0x14(%ebp),%eax
  80085b:	8b 10                	mov    (%eax),%edx
  80085d:	8b 48 04             	mov    0x4(%eax),%ecx
  800860:	8d 40 08             	lea    0x8(%eax),%eax
  800863:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800866:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  80086b:	eb 3f                	jmp    8008ac <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80086d:	8b 45 14             	mov    0x14(%ebp),%eax
  800870:	8b 10                	mov    (%eax),%edx
  800872:	b9 00 00 00 00       	mov    $0x0,%ecx
  800877:	8d 40 04             	lea    0x4(%eax),%eax
  80087a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80087d:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800882:	eb 28                	jmp    8008ac <vprintfmt+0x38c>
			putch('0', putdat);
  800884:	83 ec 08             	sub    $0x8,%esp
  800887:	53                   	push   %ebx
  800888:	6a 30                	push   $0x30
  80088a:	ff d6                	call   *%esi
			putch('x', putdat);
  80088c:	83 c4 08             	add    $0x8,%esp
  80088f:	53                   	push   %ebx
  800890:	6a 78                	push   $0x78
  800892:	ff d6                	call   *%esi
			num = (unsigned long long)
  800894:	8b 45 14             	mov    0x14(%ebp),%eax
  800897:	8b 10                	mov    (%eax),%edx
  800899:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80089e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008a1:	8d 40 04             	lea    0x4(%eax),%eax
  8008a4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008a7:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008ac:	83 ec 0c             	sub    $0xc,%esp
  8008af:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008b3:	57                   	push   %edi
  8008b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8008b7:	50                   	push   %eax
  8008b8:	51                   	push   %ecx
  8008b9:	52                   	push   %edx
  8008ba:	89 da                	mov    %ebx,%edx
  8008bc:	89 f0                	mov    %esi,%eax
  8008be:	e8 72 fb ff ff       	call   800435 <printnum>
			break;
  8008c3:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  8008c9:	83 c7 01             	add    $0x1,%edi
  8008cc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008d0:	83 f8 25             	cmp    $0x25,%eax
  8008d3:	0f 84 62 fc ff ff    	je     80053b <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  8008d9:	85 c0                	test   %eax,%eax
  8008db:	0f 84 8b 00 00 00    	je     80096c <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	53                   	push   %ebx
  8008e5:	50                   	push   %eax
  8008e6:	ff d6                	call   *%esi
  8008e8:	83 c4 10             	add    $0x10,%esp
  8008eb:	eb dc                	jmp    8008c9 <vprintfmt+0x3a9>
	if (lflag >= 2)
  8008ed:	83 f9 01             	cmp    $0x1,%ecx
  8008f0:	7f 1b                	jg     80090d <vprintfmt+0x3ed>
	else if (lflag)
  8008f2:	85 c9                	test   %ecx,%ecx
  8008f4:	74 2c                	je     800922 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  8008f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f9:	8b 10                	mov    (%eax),%edx
  8008fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800900:	8d 40 04             	lea    0x4(%eax),%eax
  800903:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800906:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80090b:	eb 9f                	jmp    8008ac <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80090d:	8b 45 14             	mov    0x14(%ebp),%eax
  800910:	8b 10                	mov    (%eax),%edx
  800912:	8b 48 04             	mov    0x4(%eax),%ecx
  800915:	8d 40 08             	lea    0x8(%eax),%eax
  800918:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80091b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800920:	eb 8a                	jmp    8008ac <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800922:	8b 45 14             	mov    0x14(%ebp),%eax
  800925:	8b 10                	mov    (%eax),%edx
  800927:	b9 00 00 00 00       	mov    $0x0,%ecx
  80092c:	8d 40 04             	lea    0x4(%eax),%eax
  80092f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800932:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800937:	e9 70 ff ff ff       	jmp    8008ac <vprintfmt+0x38c>
			putch(ch, putdat);
  80093c:	83 ec 08             	sub    $0x8,%esp
  80093f:	53                   	push   %ebx
  800940:	6a 25                	push   $0x25
  800942:	ff d6                	call   *%esi
			break;
  800944:	83 c4 10             	add    $0x10,%esp
  800947:	e9 7a ff ff ff       	jmp    8008c6 <vprintfmt+0x3a6>
			putch('%', putdat);
  80094c:	83 ec 08             	sub    $0x8,%esp
  80094f:	53                   	push   %ebx
  800950:	6a 25                	push   $0x25
  800952:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800954:	83 c4 10             	add    $0x10,%esp
  800957:	89 f8                	mov    %edi,%eax
  800959:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80095d:	74 05                	je     800964 <vprintfmt+0x444>
  80095f:	83 e8 01             	sub    $0x1,%eax
  800962:	eb f5                	jmp    800959 <vprintfmt+0x439>
  800964:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800967:	e9 5a ff ff ff       	jmp    8008c6 <vprintfmt+0x3a6>
}
  80096c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80096f:	5b                   	pop    %ebx
  800970:	5e                   	pop    %esi
  800971:	5f                   	pop    %edi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800974:	f3 0f 1e fb          	endbr32 
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	83 ec 18             	sub    $0x18,%esp
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800984:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800987:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80098b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80098e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800995:	85 c0                	test   %eax,%eax
  800997:	74 26                	je     8009bf <vsnprintf+0x4b>
  800999:	85 d2                	test   %edx,%edx
  80099b:	7e 22                	jle    8009bf <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80099d:	ff 75 14             	pushl  0x14(%ebp)
  8009a0:	ff 75 10             	pushl  0x10(%ebp)
  8009a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009a6:	50                   	push   %eax
  8009a7:	68 de 04 80 00       	push   $0x8004de
  8009ac:	e8 6f fb ff ff       	call   800520 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009b4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ba:	83 c4 10             	add    $0x10,%esp
}
  8009bd:	c9                   	leave  
  8009be:	c3                   	ret    
		return -E_INVAL;
  8009bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009c4:	eb f7                	jmp    8009bd <vsnprintf+0x49>

008009c6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009c6:	f3 0f 1e fb          	endbr32 
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  8009d0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009d3:	50                   	push   %eax
  8009d4:	ff 75 10             	pushl  0x10(%ebp)
  8009d7:	ff 75 0c             	pushl  0xc(%ebp)
  8009da:	ff 75 08             	pushl  0x8(%ebp)
  8009dd:	e8 92 ff ff ff       	call   800974 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009e2:	c9                   	leave  
  8009e3:	c3                   	ret    

008009e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009e4:	f3 0f 1e fb          	endbr32 
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009f7:	74 05                	je     8009fe <strlen+0x1a>
		n++;
  8009f9:	83 c0 01             	add    $0x1,%eax
  8009fc:	eb f5                	jmp    8009f3 <strlen+0xf>
	return n;
}
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a00:	f3 0f 1e fb          	endbr32 
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a12:	39 d0                	cmp    %edx,%eax
  800a14:	74 0d                	je     800a23 <strnlen+0x23>
  800a16:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a1a:	74 05                	je     800a21 <strnlen+0x21>
		n++;
  800a1c:	83 c0 01             	add    $0x1,%eax
  800a1f:	eb f1                	jmp    800a12 <strnlen+0x12>
  800a21:	89 c2                	mov    %eax,%edx
	return n;
}
  800a23:	89 d0                	mov    %edx,%eax
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a27:	f3 0f 1e fb          	endbr32 
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	53                   	push   %ebx
  800a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a35:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a3e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a41:	83 c0 01             	add    $0x1,%eax
  800a44:	84 d2                	test   %dl,%dl
  800a46:	75 f2                	jne    800a3a <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a48:	89 c8                	mov    %ecx,%eax
  800a4a:	5b                   	pop    %ebx
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a4d:	f3 0f 1e fb          	endbr32 
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	53                   	push   %ebx
  800a55:	83 ec 10             	sub    $0x10,%esp
  800a58:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a5b:	53                   	push   %ebx
  800a5c:	e8 83 ff ff ff       	call   8009e4 <strlen>
  800a61:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a64:	ff 75 0c             	pushl  0xc(%ebp)
  800a67:	01 d8                	add    %ebx,%eax
  800a69:	50                   	push   %eax
  800a6a:	e8 b8 ff ff ff       	call   800a27 <strcpy>
	return dst;
}
  800a6f:	89 d8                	mov    %ebx,%eax
  800a71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a74:	c9                   	leave  
  800a75:	c3                   	ret    

00800a76 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a76:	f3 0f 1e fb          	endbr32 
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	56                   	push   %esi
  800a7e:	53                   	push   %ebx
  800a7f:	8b 75 08             	mov    0x8(%ebp),%esi
  800a82:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a85:	89 f3                	mov    %esi,%ebx
  800a87:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a8a:	89 f0                	mov    %esi,%eax
  800a8c:	39 d8                	cmp    %ebx,%eax
  800a8e:	74 11                	je     800aa1 <strncpy+0x2b>
		*dst++ = *src;
  800a90:	83 c0 01             	add    $0x1,%eax
  800a93:	0f b6 0a             	movzbl (%edx),%ecx
  800a96:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a99:	80 f9 01             	cmp    $0x1,%cl
  800a9c:	83 da ff             	sbb    $0xffffffff,%edx
  800a9f:	eb eb                	jmp    800a8c <strncpy+0x16>
	}
	return ret;
}
  800aa1:	89 f0                	mov    %esi,%eax
  800aa3:	5b                   	pop    %ebx
  800aa4:	5e                   	pop    %esi
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aa7:	f3 0f 1e fb          	endbr32 
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
  800ab0:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab6:	8b 55 10             	mov    0x10(%ebp),%edx
  800ab9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800abb:	85 d2                	test   %edx,%edx
  800abd:	74 21                	je     800ae0 <strlcpy+0x39>
  800abf:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ac3:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800ac5:	39 c2                	cmp    %eax,%edx
  800ac7:	74 14                	je     800add <strlcpy+0x36>
  800ac9:	0f b6 19             	movzbl (%ecx),%ebx
  800acc:	84 db                	test   %bl,%bl
  800ace:	74 0b                	je     800adb <strlcpy+0x34>
			*dst++ = *src++;
  800ad0:	83 c1 01             	add    $0x1,%ecx
  800ad3:	83 c2 01             	add    $0x1,%edx
  800ad6:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ad9:	eb ea                	jmp    800ac5 <strlcpy+0x1e>
  800adb:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800add:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ae0:	29 f0                	sub    %esi,%eax
}
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ae6:	f3 0f 1e fb          	endbr32 
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800af3:	0f b6 01             	movzbl (%ecx),%eax
  800af6:	84 c0                	test   %al,%al
  800af8:	74 0c                	je     800b06 <strcmp+0x20>
  800afa:	3a 02                	cmp    (%edx),%al
  800afc:	75 08                	jne    800b06 <strcmp+0x20>
		p++, q++;
  800afe:	83 c1 01             	add    $0x1,%ecx
  800b01:	83 c2 01             	add    $0x1,%edx
  800b04:	eb ed                	jmp    800af3 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b06:	0f b6 c0             	movzbl %al,%eax
  800b09:	0f b6 12             	movzbl (%edx),%edx
  800b0c:	29 d0                	sub    %edx,%eax
}
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b10:	f3 0f 1e fb          	endbr32 
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	53                   	push   %ebx
  800b18:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1e:	89 c3                	mov    %eax,%ebx
  800b20:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b23:	eb 06                	jmp    800b2b <strncmp+0x1b>
		n--, p++, q++;
  800b25:	83 c0 01             	add    $0x1,%eax
  800b28:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b2b:	39 d8                	cmp    %ebx,%eax
  800b2d:	74 16                	je     800b45 <strncmp+0x35>
  800b2f:	0f b6 08             	movzbl (%eax),%ecx
  800b32:	84 c9                	test   %cl,%cl
  800b34:	74 04                	je     800b3a <strncmp+0x2a>
  800b36:	3a 0a                	cmp    (%edx),%cl
  800b38:	74 eb                	je     800b25 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b3a:	0f b6 00             	movzbl (%eax),%eax
  800b3d:	0f b6 12             	movzbl (%edx),%edx
  800b40:	29 d0                	sub    %edx,%eax
}
  800b42:	5b                   	pop    %ebx
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    
		return 0;
  800b45:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4a:	eb f6                	jmp    800b42 <strncmp+0x32>

00800b4c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b4c:	f3 0f 1e fb          	endbr32 
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	8b 45 08             	mov    0x8(%ebp),%eax
  800b56:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b5a:	0f b6 10             	movzbl (%eax),%edx
  800b5d:	84 d2                	test   %dl,%dl
  800b5f:	74 09                	je     800b6a <strchr+0x1e>
		if (*s == c)
  800b61:	38 ca                	cmp    %cl,%dl
  800b63:	74 0a                	je     800b6f <strchr+0x23>
	for (; *s; s++)
  800b65:	83 c0 01             	add    $0x1,%eax
  800b68:	eb f0                	jmp    800b5a <strchr+0xe>
			return (char *) s;
	return 0;
  800b6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800b71:	f3 0f 1e fb          	endbr32 
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800b7b:	6a 78                	push   $0x78
  800b7d:	ff 75 08             	pushl  0x8(%ebp)
  800b80:	e8 c7 ff ff ff       	call   800b4c <strchr>
  800b85:	83 c4 10             	add    $0x10,%esp
  800b88:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  800b8b:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800b90:	eb 0d                	jmp    800b9f <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800b92:	c1 e0 04             	shl    $0x4,%eax
  800b95:	0f be d2             	movsbl %dl,%edx
  800b98:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800b9c:	83 c1 01             	add    $0x1,%ecx
  800b9f:	0f b6 11             	movzbl (%ecx),%edx
  800ba2:	84 d2                	test   %dl,%dl
  800ba4:	74 11                	je     800bb7 <atox+0x46>
		if (*p>='a'){
  800ba6:	80 fa 60             	cmp    $0x60,%dl
  800ba9:	7e e7                	jle    800b92 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800bab:	c1 e0 04             	shl    $0x4,%eax
  800bae:	0f be d2             	movsbl %dl,%edx
  800bb1:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800bb5:	eb e5                	jmp    800b9c <atox+0x2b>
	}

	return v;

}
  800bb7:	c9                   	leave  
  800bb8:	c3                   	ret    

00800bb9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bb9:	f3 0f 1e fb          	endbr32 
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bc7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bca:	38 ca                	cmp    %cl,%dl
  800bcc:	74 09                	je     800bd7 <strfind+0x1e>
  800bce:	84 d2                	test   %dl,%dl
  800bd0:	74 05                	je     800bd7 <strfind+0x1e>
	for (; *s; s++)
  800bd2:	83 c0 01             	add    $0x1,%eax
  800bd5:	eb f0                	jmp    800bc7 <strfind+0xe>
			break;
	return (char *) s;
}
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bd9:	f3 0f 1e fb          	endbr32 
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800be6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800be9:	85 c9                	test   %ecx,%ecx
  800beb:	74 31                	je     800c1e <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bed:	89 f8                	mov    %edi,%eax
  800bef:	09 c8                	or     %ecx,%eax
  800bf1:	a8 03                	test   $0x3,%al
  800bf3:	75 23                	jne    800c18 <memset+0x3f>
		c &= 0xFF;
  800bf5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bf9:	89 d3                	mov    %edx,%ebx
  800bfb:	c1 e3 08             	shl    $0x8,%ebx
  800bfe:	89 d0                	mov    %edx,%eax
  800c00:	c1 e0 18             	shl    $0x18,%eax
  800c03:	89 d6                	mov    %edx,%esi
  800c05:	c1 e6 10             	shl    $0x10,%esi
  800c08:	09 f0                	or     %esi,%eax
  800c0a:	09 c2                	or     %eax,%edx
  800c0c:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c0e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c11:	89 d0                	mov    %edx,%eax
  800c13:	fc                   	cld    
  800c14:	f3 ab                	rep stos %eax,%es:(%edi)
  800c16:	eb 06                	jmp    800c1e <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1b:	fc                   	cld    
  800c1c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c1e:	89 f8                	mov    %edi,%eax
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c25:	f3 0f 1e fb          	endbr32 
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c31:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c34:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c37:	39 c6                	cmp    %eax,%esi
  800c39:	73 32                	jae    800c6d <memmove+0x48>
  800c3b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c3e:	39 c2                	cmp    %eax,%edx
  800c40:	76 2b                	jbe    800c6d <memmove+0x48>
		s += n;
		d += n;
  800c42:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c45:	89 fe                	mov    %edi,%esi
  800c47:	09 ce                	or     %ecx,%esi
  800c49:	09 d6                	or     %edx,%esi
  800c4b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c51:	75 0e                	jne    800c61 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c53:	83 ef 04             	sub    $0x4,%edi
  800c56:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c59:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c5c:	fd                   	std    
  800c5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c5f:	eb 09                	jmp    800c6a <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c61:	83 ef 01             	sub    $0x1,%edi
  800c64:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c67:	fd                   	std    
  800c68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c6a:	fc                   	cld    
  800c6b:	eb 1a                	jmp    800c87 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c6d:	89 c2                	mov    %eax,%edx
  800c6f:	09 ca                	or     %ecx,%edx
  800c71:	09 f2                	or     %esi,%edx
  800c73:	f6 c2 03             	test   $0x3,%dl
  800c76:	75 0a                	jne    800c82 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c78:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c7b:	89 c7                	mov    %eax,%edi
  800c7d:	fc                   	cld    
  800c7e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c80:	eb 05                	jmp    800c87 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c82:	89 c7                	mov    %eax,%edi
  800c84:	fc                   	cld    
  800c85:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c8b:	f3 0f 1e fb          	endbr32 
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c95:	ff 75 10             	pushl  0x10(%ebp)
  800c98:	ff 75 0c             	pushl  0xc(%ebp)
  800c9b:	ff 75 08             	pushl  0x8(%ebp)
  800c9e:	e8 82 ff ff ff       	call   800c25 <memmove>
}
  800ca3:	c9                   	leave  
  800ca4:	c3                   	ret    

00800ca5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ca5:	f3 0f 1e fb          	endbr32 
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
  800cae:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cb4:	89 c6                	mov    %eax,%esi
  800cb6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb9:	39 f0                	cmp    %esi,%eax
  800cbb:	74 1c                	je     800cd9 <memcmp+0x34>
		if (*s1 != *s2)
  800cbd:	0f b6 08             	movzbl (%eax),%ecx
  800cc0:	0f b6 1a             	movzbl (%edx),%ebx
  800cc3:	38 d9                	cmp    %bl,%cl
  800cc5:	75 08                	jne    800ccf <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cc7:	83 c0 01             	add    $0x1,%eax
  800cca:	83 c2 01             	add    $0x1,%edx
  800ccd:	eb ea                	jmp    800cb9 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ccf:	0f b6 c1             	movzbl %cl,%eax
  800cd2:	0f b6 db             	movzbl %bl,%ebx
  800cd5:	29 d8                	sub    %ebx,%eax
  800cd7:	eb 05                	jmp    800cde <memcmp+0x39>
	}

	return 0;
  800cd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ce2:	f3 0f 1e fb          	endbr32 
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cef:	89 c2                	mov    %eax,%edx
  800cf1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cf4:	39 d0                	cmp    %edx,%eax
  800cf6:	73 09                	jae    800d01 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf8:	38 08                	cmp    %cl,(%eax)
  800cfa:	74 05                	je     800d01 <memfind+0x1f>
	for (; s < ends; s++)
  800cfc:	83 c0 01             	add    $0x1,%eax
  800cff:	eb f3                	jmp    800cf4 <memfind+0x12>
			break;
	return (void *) s;
}
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d03:	f3 0f 1e fb          	endbr32 
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d10:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d13:	eb 03                	jmp    800d18 <strtol+0x15>
		s++;
  800d15:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d18:	0f b6 01             	movzbl (%ecx),%eax
  800d1b:	3c 20                	cmp    $0x20,%al
  800d1d:	74 f6                	je     800d15 <strtol+0x12>
  800d1f:	3c 09                	cmp    $0x9,%al
  800d21:	74 f2                	je     800d15 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d23:	3c 2b                	cmp    $0x2b,%al
  800d25:	74 2a                	je     800d51 <strtol+0x4e>
	int neg = 0;
  800d27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d2c:	3c 2d                	cmp    $0x2d,%al
  800d2e:	74 2b                	je     800d5b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d30:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d36:	75 0f                	jne    800d47 <strtol+0x44>
  800d38:	80 39 30             	cmpb   $0x30,(%ecx)
  800d3b:	74 28                	je     800d65 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d3d:	85 db                	test   %ebx,%ebx
  800d3f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d44:	0f 44 d8             	cmove  %eax,%ebx
  800d47:	b8 00 00 00 00       	mov    $0x0,%eax
  800d4c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d4f:	eb 46                	jmp    800d97 <strtol+0x94>
		s++;
  800d51:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d54:	bf 00 00 00 00       	mov    $0x0,%edi
  800d59:	eb d5                	jmp    800d30 <strtol+0x2d>
		s++, neg = 1;
  800d5b:	83 c1 01             	add    $0x1,%ecx
  800d5e:	bf 01 00 00 00       	mov    $0x1,%edi
  800d63:	eb cb                	jmp    800d30 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d65:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d69:	74 0e                	je     800d79 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d6b:	85 db                	test   %ebx,%ebx
  800d6d:	75 d8                	jne    800d47 <strtol+0x44>
		s++, base = 8;
  800d6f:	83 c1 01             	add    $0x1,%ecx
  800d72:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d77:	eb ce                	jmp    800d47 <strtol+0x44>
		s += 2, base = 16;
  800d79:	83 c1 02             	add    $0x2,%ecx
  800d7c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d81:	eb c4                	jmp    800d47 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d83:	0f be d2             	movsbl %dl,%edx
  800d86:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d89:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d8c:	7d 3a                	jge    800dc8 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d8e:	83 c1 01             	add    $0x1,%ecx
  800d91:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d95:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d97:	0f b6 11             	movzbl (%ecx),%edx
  800d9a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d9d:	89 f3                	mov    %esi,%ebx
  800d9f:	80 fb 09             	cmp    $0x9,%bl
  800da2:	76 df                	jbe    800d83 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800da4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800da7:	89 f3                	mov    %esi,%ebx
  800da9:	80 fb 19             	cmp    $0x19,%bl
  800dac:	77 08                	ja     800db6 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800dae:	0f be d2             	movsbl %dl,%edx
  800db1:	83 ea 57             	sub    $0x57,%edx
  800db4:	eb d3                	jmp    800d89 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800db6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800db9:	89 f3                	mov    %esi,%ebx
  800dbb:	80 fb 19             	cmp    $0x19,%bl
  800dbe:	77 08                	ja     800dc8 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dc0:	0f be d2             	movsbl %dl,%edx
  800dc3:	83 ea 37             	sub    $0x37,%edx
  800dc6:	eb c1                	jmp    800d89 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dc8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dcc:	74 05                	je     800dd3 <strtol+0xd0>
		*endptr = (char *) s;
  800dce:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dd1:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800dd3:	89 c2                	mov    %eax,%edx
  800dd5:	f7 da                	neg    %edx
  800dd7:	85 ff                	test   %edi,%edi
  800dd9:	0f 45 c2             	cmovne %edx,%eax
}
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800de1:	f3 0f 1e fb          	endbr32 
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	57                   	push   %edi
  800de9:	56                   	push   %esi
  800dea:	53                   	push   %ebx
	asm volatile("int %1\n"
  800deb:	b8 00 00 00 00       	mov    $0x0,%eax
  800df0:	8b 55 08             	mov    0x8(%ebp),%edx
  800df3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df6:	89 c3                	mov    %eax,%ebx
  800df8:	89 c7                	mov    %eax,%edi
  800dfa:	89 c6                	mov    %eax,%esi
  800dfc:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    

00800e03 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e03:	f3 0f 1e fb          	endbr32 
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	57                   	push   %edi
  800e0b:	56                   	push   %esi
  800e0c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e12:	b8 01 00 00 00       	mov    $0x1,%eax
  800e17:	89 d1                	mov    %edx,%ecx
  800e19:	89 d3                	mov    %edx,%ebx
  800e1b:	89 d7                	mov    %edx,%edi
  800e1d:	89 d6                	mov    %edx,%esi
  800e1f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e21:	5b                   	pop    %ebx
  800e22:	5e                   	pop    %esi
  800e23:	5f                   	pop    %edi
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    

00800e26 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e26:	f3 0f 1e fb          	endbr32 
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e35:	8b 55 08             	mov    0x8(%ebp),%edx
  800e38:	b8 03 00 00 00       	mov    $0x3,%eax
  800e3d:	89 cb                	mov    %ecx,%ebx
  800e3f:	89 cf                	mov    %ecx,%edi
  800e41:	89 ce                	mov    %ecx,%esi
  800e43:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e4a:	f3 0f 1e fb          	endbr32 
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e54:	ba 00 00 00 00       	mov    $0x0,%edx
  800e59:	b8 02 00 00 00       	mov    $0x2,%eax
  800e5e:	89 d1                	mov    %edx,%ecx
  800e60:	89 d3                	mov    %edx,%ebx
  800e62:	89 d7                	mov    %edx,%edi
  800e64:	89 d6                	mov    %edx,%esi
  800e66:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e68:	5b                   	pop    %ebx
  800e69:	5e                   	pop    %esi
  800e6a:	5f                   	pop    %edi
  800e6b:	5d                   	pop    %ebp
  800e6c:	c3                   	ret    

00800e6d <sys_yield>:

void
sys_yield(void)
{
  800e6d:	f3 0f 1e fb          	endbr32 
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	57                   	push   %edi
  800e75:	56                   	push   %esi
  800e76:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e77:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e81:	89 d1                	mov    %edx,%ecx
  800e83:	89 d3                	mov    %edx,%ebx
  800e85:	89 d7                	mov    %edx,%edi
  800e87:	89 d6                	mov    %edx,%esi
  800e89:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e8b:	5b                   	pop    %ebx
  800e8c:	5e                   	pop    %esi
  800e8d:	5f                   	pop    %edi
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e90:	f3 0f 1e fb          	endbr32 
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	57                   	push   %edi
  800e98:	56                   	push   %esi
  800e99:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e9a:	be 00 00 00 00       	mov    $0x0,%esi
  800e9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea5:	b8 04 00 00 00       	mov    $0x4,%eax
  800eaa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ead:	89 f7                	mov    %esi,%edi
  800eaf:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800eb1:	5b                   	pop    %ebx
  800eb2:	5e                   	pop    %esi
  800eb3:	5f                   	pop    %edi
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    

00800eb6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800eb6:	f3 0f 1e fb          	endbr32 
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	57                   	push   %edi
  800ebe:	56                   	push   %esi
  800ebf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ec0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec6:	b8 05 00 00 00       	mov    $0x5,%eax
  800ecb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ece:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ed1:	8b 75 18             	mov    0x18(%ebp),%esi
  800ed4:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ed6:	5b                   	pop    %ebx
  800ed7:	5e                   	pop    %esi
  800ed8:	5f                   	pop    %edi
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    

00800edb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800edb:	f3 0f 1e fb          	endbr32 
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	57                   	push   %edi
  800ee3:	56                   	push   %esi
  800ee4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ee5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eea:	8b 55 08             	mov    0x8(%ebp),%edx
  800eed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef0:	b8 06 00 00 00       	mov    $0x6,%eax
  800ef5:	89 df                	mov    %ebx,%edi
  800ef7:	89 de                	mov    %ebx,%esi
  800ef9:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5f                   	pop    %edi
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f00:	f3 0f 1e fb          	endbr32 
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	57                   	push   %edi
  800f08:	56                   	push   %esi
  800f09:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f15:	b8 08 00 00 00       	mov    $0x8,%eax
  800f1a:	89 df                	mov    %ebx,%edi
  800f1c:	89 de                	mov    %ebx,%esi
  800f1e:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f20:	5b                   	pop    %ebx
  800f21:	5e                   	pop    %esi
  800f22:	5f                   	pop    %edi
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    

00800f25 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f25:	f3 0f 1e fb          	endbr32 
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	57                   	push   %edi
  800f2d:	56                   	push   %esi
  800f2e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f34:	8b 55 08             	mov    0x8(%ebp),%edx
  800f37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3a:	b8 09 00 00 00       	mov    $0x9,%eax
  800f3f:	89 df                	mov    %ebx,%edi
  800f41:	89 de                	mov    %ebx,%esi
  800f43:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f45:	5b                   	pop    %ebx
  800f46:	5e                   	pop    %esi
  800f47:	5f                   	pop    %edi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    

00800f4a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f4a:	f3 0f 1e fb          	endbr32 
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	57                   	push   %edi
  800f52:	56                   	push   %esi
  800f53:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f59:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f64:	89 df                	mov    %ebx,%edi
  800f66:	89 de                	mov    %ebx,%esi
  800f68:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f6a:	5b                   	pop    %ebx
  800f6b:	5e                   	pop    %esi
  800f6c:	5f                   	pop    %edi
  800f6d:	5d                   	pop    %ebp
  800f6e:	c3                   	ret    

00800f6f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f6f:	f3 0f 1e fb          	endbr32 
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	57                   	push   %edi
  800f77:	56                   	push   %esi
  800f78:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f79:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f84:	be 00 00 00 00       	mov    $0x0,%esi
  800f89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f8c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f8f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f91:	5b                   	pop    %ebx
  800f92:	5e                   	pop    %esi
  800f93:	5f                   	pop    %edi
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    

00800f96 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f96:	f3 0f 1e fb          	endbr32 
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	57                   	push   %edi
  800f9e:	56                   	push   %esi
  800f9f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fa0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fad:	89 cb                	mov    %ecx,%ebx
  800faf:	89 cf                	mov    %ecx,%edi
  800fb1:	89 ce                	mov    %ecx,%esi
  800fb3:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fb5:	5b                   	pop    %ebx
  800fb6:	5e                   	pop    %esi
  800fb7:	5f                   	pop    %edi
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    

00800fba <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800fba:	f3 0f 1e fb          	endbr32 
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	57                   	push   %edi
  800fc2:	56                   	push   %esi
  800fc3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc9:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fce:	89 d1                	mov    %edx,%ecx
  800fd0:	89 d3                	mov    %edx,%ebx
  800fd2:	89 d7                	mov    %edx,%edi
  800fd4:	89 d6                	mov    %edx,%esi
  800fd6:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800fd8:	5b                   	pop    %ebx
  800fd9:	5e                   	pop    %esi
  800fda:	5f                   	pop    %edi
  800fdb:	5d                   	pop    %ebp
  800fdc:	c3                   	ret    

00800fdd <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800fdd:	f3 0f 1e fb          	endbr32 
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	57                   	push   %edi
  800fe5:	56                   	push   %esi
  800fe6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fe7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fec:	8b 55 08             	mov    0x8(%ebp),%edx
  800fef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff2:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ff7:	89 df                	mov    %ebx,%edi
  800ff9:	89 de                	mov    %ebx,%esi
  800ffb:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800ffd:	5b                   	pop    %ebx
  800ffe:	5e                   	pop    %esi
  800fff:	5f                   	pop    %edi
  801000:	5d                   	pop    %ebp
  801001:	c3                   	ret    

00801002 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  801002:	f3 0f 1e fb          	endbr32 
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	57                   	push   %edi
  80100a:	56                   	push   %esi
  80100b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80100c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801011:	8b 55 08             	mov    0x8(%ebp),%edx
  801014:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801017:	b8 10 00 00 00       	mov    $0x10,%eax
  80101c:	89 df                	mov    %ebx,%edi
  80101e:	89 de                	mov    %ebx,%esi
  801020:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  801022:	5b                   	pop    %ebx
  801023:	5e                   	pop    %esi
  801024:	5f                   	pop    %edi
  801025:	5d                   	pop    %ebp
  801026:	c3                   	ret    

00801027 <pgfault>:
// map in our own private writable copy.
//
extern int cnt;
static void
pgfault(struct UTrapframe *utf)
{
  801027:	f3 0f 1e fb          	endbr32 
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	53                   	push   %ebx
  80102f:	83 ec 04             	sub    $0x4,%esp
  801032:	8b 45 08             	mov    0x8(%ebp),%eax
	// cprintf("[%08x] called pgfault\n", sys_getenvid());
	void *addr = (void *) utf->utf_fault_va;
  801035:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err&FEC_WR)&&(uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_COW))){
  801037:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80103b:	0f 84 9a 00 00 00    	je     8010db <pgfault+0xb4>
  801041:	89 d8                	mov    %ebx,%eax
  801043:	c1 e8 16             	shr    $0x16,%eax
  801046:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80104d:	a8 01                	test   $0x1,%al
  80104f:	0f 84 86 00 00 00    	je     8010db <pgfault+0xb4>
  801055:	89 d8                	mov    %ebx,%eax
  801057:	c1 e8 0c             	shr    $0xc,%eax
  80105a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801061:	f6 c2 01             	test   $0x1,%dl
  801064:	74 75                	je     8010db <pgfault+0xb4>
  801066:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106d:	f6 c4 08             	test   $0x8,%ah
  801070:	74 69                	je     8010db <pgfault+0xb4>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 在PFTEMP这里给一个物理地址的mapping 相当于store一个物理地址
	if((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W))<0){
  801072:	83 ec 04             	sub    $0x4,%esp
  801075:	6a 07                	push   $0x7
  801077:	68 00 f0 7f 00       	push   $0x7ff000
  80107c:	6a 00                	push   $0x0
  80107e:	e8 0d fe ff ff       	call   800e90 <sys_page_alloc>
  801083:	83 c4 10             	add    $0x10,%esp
  801086:	85 c0                	test   %eax,%eax
  801088:	78 63                	js     8010ed <pgfault+0xc6>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80108a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// 先复制addr里的content
	memcpy((void*)PFTEMP, addr, PGSIZE);
  801090:	83 ec 04             	sub    $0x4,%esp
  801093:	68 00 10 00 00       	push   $0x1000
  801098:	53                   	push   %ebx
  801099:	68 00 f0 7f 00       	push   $0x7ff000
  80109e:	e8 e8 fb ff ff       	call   800c8b <memcpy>
	// 在remap addr到PFTEMP位置 即addr与PFTEMP指向同一个物理内存
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))<0){
  8010a3:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8010aa:	53                   	push   %ebx
  8010ab:	6a 00                	push   $0x0
  8010ad:	68 00 f0 7f 00       	push   $0x7ff000
  8010b2:	6a 00                	push   $0x0
  8010b4:	e8 fd fd ff ff       	call   800eb6 <sys_page_map>
  8010b9:	83 c4 20             	add    $0x20,%esp
  8010bc:	85 c0                	test   %eax,%eax
  8010be:	78 3f                	js     8010ff <pgfault+0xd8>
		panic("pgfault: sys_page_map failed due to %e\n", r);
	}
	if ((r = sys_page_unmap(0, (void*)PFTEMP))<0){
  8010c0:	83 ec 08             	sub    $0x8,%esp
  8010c3:	68 00 f0 7f 00       	push   $0x7ff000
  8010c8:	6a 00                	push   $0x0
  8010ca:	e8 0c fe ff ff       	call   800edb <sys_page_unmap>
  8010cf:	83 c4 10             	add    $0x10,%esp
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	78 3b                	js     801111 <pgfault+0xea>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
	}
	
	
}
  8010d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    
		panic("pgfault: page access at %08x is not a write to a copy-on-write\n", addr);
  8010db:	53                   	push   %ebx
  8010dc:	68 20 2d 80 00       	push   $0x802d20
  8010e1:	6a 20                	push   $0x20
  8010e3:	68 de 2d 80 00       	push   $0x802dde
  8010e8:	e8 49 f2 ff ff       	call   800336 <_panic>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
  8010ed:	50                   	push   %eax
  8010ee:	68 60 2d 80 00       	push   $0x802d60
  8010f3:	6a 2c                	push   $0x2c
  8010f5:	68 de 2d 80 00       	push   $0x802dde
  8010fa:	e8 37 f2 ff ff       	call   800336 <_panic>
		panic("pgfault: sys_page_map failed due to %e\n", r);
  8010ff:	50                   	push   %eax
  801100:	68 8c 2d 80 00       	push   $0x802d8c
  801105:	6a 33                	push   $0x33
  801107:	68 de 2d 80 00       	push   $0x802dde
  80110c:	e8 25 f2 ff ff       	call   800336 <_panic>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
  801111:	50                   	push   %eax
  801112:	68 b4 2d 80 00       	push   $0x802db4
  801117:	6a 36                	push   $0x36
  801119:	68 de 2d 80 00       	push   $0x802dde
  80111e:	e8 13 f2 ff ff       	call   800336 <_panic>

00801123 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801123:	f3 0f 1e fb          	endbr32 
  801127:	55                   	push   %ebp
  801128:	89 e5                	mov    %esp,%ebp
  80112a:	57                   	push   %edi
  80112b:	56                   	push   %esi
  80112c:	53                   	push   %ebx
  80112d:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[%08x] called fork\n", sys_getenvid());
	int r; uintptr_t addr;
	set_pgfault_handler(pgfault);
  801130:	68 27 10 80 00       	push   $0x801027
  801135:	e8 84 14 00 00       	call   8025be <set_pgfault_handler>
*/
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80113a:	b8 07 00 00 00       	mov    $0x7,%eax
  80113f:	cd 30                	int    $0x30
  801141:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();
		
	if (envid<0){
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	85 c0                	test   %eax,%eax
  801149:	78 29                	js     801174 <fork+0x51>
  80114b:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	// duplicate parent address space
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  80114d:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid==0){
  801152:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801156:	75 60                	jne    8011b8 <fork+0x95>
		thisenv = &envs[ENVX(sys_getenvid())];
  801158:	e8 ed fc ff ff       	call   800e4a <sys_getenvid>
  80115d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801162:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801165:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80116a:	a3 0c 50 80 00       	mov    %eax,0x80500c
		return 0;
  80116f:	e9 14 01 00 00       	jmp    801288 <fork+0x165>
		panic("fork: sys_exofork error %e\n", envid);
  801174:	50                   	push   %eax
  801175:	68 e9 2d 80 00       	push   $0x802de9
  80117a:	68 90 00 00 00       	push   $0x90
  80117f:	68 de 2d 80 00       	push   $0x802dde
  801184:	e8 ad f1 ff ff       	call   800336 <_panic>
		r = sys_page_map(0, addr, envid, addr, (uvpt[pn]&PTE_SYSCALL));
  801189:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801190:	83 ec 0c             	sub    $0xc,%esp
  801193:	25 07 0e 00 00       	and    $0xe07,%eax
  801198:	50                   	push   %eax
  801199:	56                   	push   %esi
  80119a:	57                   	push   %edi
  80119b:	56                   	push   %esi
  80119c:	6a 00                	push   $0x0
  80119e:	e8 13 fd ff ff       	call   800eb6 <sys_page_map>
  8011a3:	83 c4 20             	add    $0x20,%esp
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  8011a6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011ac:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011b2:	0f 84 95 00 00 00    	je     80124d <fork+0x12a>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  8011b8:	89 d8                	mov    %ebx,%eax
  8011ba:	c1 e8 16             	shr    $0x16,%eax
  8011bd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011c4:	a8 01                	test   $0x1,%al
  8011c6:	74 de                	je     8011a6 <fork+0x83>
  8011c8:	89 d8                	mov    %ebx,%eax
  8011ca:	c1 e8 0c             	shr    $0xc,%eax
  8011cd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011d4:	f6 c2 01             	test   $0x1,%dl
  8011d7:	74 cd                	je     8011a6 <fork+0x83>
	void* addr = (void*)(pn*PGSIZE);
  8011d9:	89 c6                	mov    %eax,%esi
  8011db:	c1 e6 0c             	shl    $0xc,%esi
	if (uvpt[pn]&PTE_SHARE){
  8011de:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011e5:	f6 c6 04             	test   $0x4,%dh
  8011e8:	75 9f                	jne    801189 <fork+0x66>
		if (uvpt[pn]&PTE_W||uvpt[pn]&PTE_COW){
  8011ea:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011f1:	f6 c2 02             	test   $0x2,%dl
  8011f4:	75 0c                	jne    801202 <fork+0xdf>
  8011f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011fd:	f6 c4 08             	test   $0x8,%ah
  801200:	74 34                	je     801236 <fork+0x113>
			r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P); // not writable
  801202:	83 ec 0c             	sub    $0xc,%esp
  801205:	68 05 08 00 00       	push   $0x805
  80120a:	56                   	push   %esi
  80120b:	57                   	push   %edi
  80120c:	56                   	push   %esi
  80120d:	6a 00                	push   $0x0
  80120f:	e8 a2 fc ff ff       	call   800eb6 <sys_page_map>
			if (r<0) return r;
  801214:	83 c4 20             	add    $0x20,%esp
  801217:	85 c0                	test   %eax,%eax
  801219:	78 8b                	js     8011a6 <fork+0x83>
			r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P); // not writable
  80121b:	83 ec 0c             	sub    $0xc,%esp
  80121e:	68 05 08 00 00       	push   $0x805
  801223:	56                   	push   %esi
  801224:	6a 00                	push   $0x0
  801226:	56                   	push   %esi
  801227:	6a 00                	push   $0x0
  801229:	e8 88 fc ff ff       	call   800eb6 <sys_page_map>
  80122e:	83 c4 20             	add    $0x20,%esp
  801231:	e9 70 ff ff ff       	jmp    8011a6 <fork+0x83>
			if ((r=sys_page_map(0, addr, envid, addr, PTE_P|PTE_U)<0))// read only
  801236:	83 ec 0c             	sub    $0xc,%esp
  801239:	6a 05                	push   $0x5
  80123b:	56                   	push   %esi
  80123c:	57                   	push   %edi
  80123d:	56                   	push   %esi
  80123e:	6a 00                	push   $0x0
  801240:	e8 71 fc ff ff       	call   800eb6 <sys_page_map>
  801245:	83 c4 20             	add    $0x20,%esp
  801248:	e9 59 ff ff ff       	jmp    8011a6 <fork+0x83>
			duppage(envid, PGNUM(addr));
		}
	}
	// allocate user exception stack
	// cprintf("alloc user expection stack\n");
	if ((r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_W|PTE_U))<0)
  80124d:	83 ec 04             	sub    $0x4,%esp
  801250:	6a 07                	push   $0x7
  801252:	68 00 f0 bf ee       	push   $0xeebff000
  801257:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80125a:	56                   	push   %esi
  80125b:	e8 30 fc ff ff       	call   800e90 <sys_page_alloc>
  801260:	83 c4 10             	add    $0x10,%esp
  801263:	85 c0                	test   %eax,%eax
  801265:	78 2b                	js     801292 <fork+0x16f>
		return r;
	
	extern void* _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801267:	83 ec 08             	sub    $0x8,%esp
  80126a:	68 31 26 80 00       	push   $0x802631
  80126f:	56                   	push   %esi
  801270:	e8 d5 fc ff ff       	call   800f4a <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE))<0)
  801275:	83 c4 08             	add    $0x8,%esp
  801278:	6a 02                	push   $0x2
  80127a:	56                   	push   %esi
  80127b:	e8 80 fc ff ff       	call   800f00 <sys_env_set_status>
  801280:	83 c4 10             	add    $0x10,%esp
		return r;
  801283:	85 c0                	test   %eax,%eax
  801285:	0f 48 f8             	cmovs  %eax,%edi

	return envid;
	
}
  801288:	89 f8                	mov    %edi,%eax
  80128a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80128d:	5b                   	pop    %ebx
  80128e:	5e                   	pop    %esi
  80128f:	5f                   	pop    %edi
  801290:	5d                   	pop    %ebp
  801291:	c3                   	ret    
		return r;
  801292:	89 c7                	mov    %eax,%edi
  801294:	eb f2                	jmp    801288 <fork+0x165>

00801296 <sfork>:

// Challenge(not sure yet)
int
sfork(void)
{
  801296:	f3 0f 1e fb          	endbr32 
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8012a0:	68 05 2e 80 00       	push   $0x802e05
  8012a5:	68 b2 00 00 00       	push   $0xb2
  8012aa:	68 de 2d 80 00       	push   $0x802dde
  8012af:	e8 82 f0 ff ff       	call   800336 <_panic>

008012b4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012b4:	f3 0f 1e fb          	endbr32 
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	56                   	push   %esi
  8012bc:	53                   	push   %ebx
  8012bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8012c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  8012c6:	85 c0                	test   %eax,%eax
  8012c8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8012cd:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  8012d0:	83 ec 0c             	sub    $0xc,%esp
  8012d3:	50                   	push   %eax
  8012d4:	e8 bd fc ff ff       	call   800f96 <sys_ipc_recv>
  8012d9:	83 c4 10             	add    $0x10,%esp
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	75 2b                	jne    80130b <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  8012e0:	85 f6                	test   %esi,%esi
  8012e2:	74 0a                	je     8012ee <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  8012e4:	a1 0c 50 80 00       	mov    0x80500c,%eax
  8012e9:	8b 40 74             	mov    0x74(%eax),%eax
  8012ec:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  8012ee:	85 db                	test   %ebx,%ebx
  8012f0:	74 0a                	je     8012fc <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  8012f2:	a1 0c 50 80 00       	mov    0x80500c,%eax
  8012f7:	8b 40 78             	mov    0x78(%eax),%eax
  8012fa:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  8012fc:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801301:	8b 40 70             	mov    0x70(%eax),%eax
}
  801304:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801307:	5b                   	pop    %ebx
  801308:	5e                   	pop    %esi
  801309:	5d                   	pop    %ebp
  80130a:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  80130b:	85 f6                	test   %esi,%esi
  80130d:	74 06                	je     801315 <ipc_recv+0x61>
  80130f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801315:	85 db                	test   %ebx,%ebx
  801317:	74 eb                	je     801304 <ipc_recv+0x50>
  801319:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80131f:	eb e3                	jmp    801304 <ipc_recv+0x50>

00801321 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801321:	f3 0f 1e fb          	endbr32 
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	57                   	push   %edi
  801329:	56                   	push   %esi
  80132a:	53                   	push   %ebx
  80132b:	83 ec 0c             	sub    $0xc,%esp
  80132e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801331:	8b 75 0c             	mov    0xc(%ebp),%esi
  801334:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  801337:	85 db                	test   %ebx,%ebx
  801339:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80133e:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  801341:	ff 75 14             	pushl  0x14(%ebp)
  801344:	53                   	push   %ebx
  801345:	56                   	push   %esi
  801346:	57                   	push   %edi
  801347:	e8 23 fc ff ff       	call   800f6f <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  80134c:	83 c4 10             	add    $0x10,%esp
  80134f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801352:	75 07                	jne    80135b <ipc_send+0x3a>
			sys_yield();
  801354:	e8 14 fb ff ff       	call   800e6d <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  801359:	eb e6                	jmp    801341 <ipc_send+0x20>
		}
		else if (ret == 0)
  80135b:	85 c0                	test   %eax,%eax
  80135d:	75 08                	jne    801367 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  80135f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801362:	5b                   	pop    %ebx
  801363:	5e                   	pop    %esi
  801364:	5f                   	pop    %edi
  801365:	5d                   	pop    %ebp
  801366:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  801367:	50                   	push   %eax
  801368:	68 1b 2e 80 00       	push   $0x802e1b
  80136d:	6a 48                	push   $0x48
  80136f:	68 29 2e 80 00       	push   $0x802e29
  801374:	e8 bd ef ff ff       	call   800336 <_panic>

00801379 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801379:	f3 0f 1e fb          	endbr32 
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801383:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801388:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80138b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801391:	8b 52 50             	mov    0x50(%edx),%edx
  801394:	39 ca                	cmp    %ecx,%edx
  801396:	74 11                	je     8013a9 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801398:	83 c0 01             	add    $0x1,%eax
  80139b:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013a0:	75 e6                	jne    801388 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8013a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a7:	eb 0b                	jmp    8013b4 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8013a9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013ac:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8013b1:	8b 40 48             	mov    0x48(%eax),%eax
}
  8013b4:	5d                   	pop    %ebp
  8013b5:	c3                   	ret    

008013b6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013b6:	f3 0f 1e fb          	endbr32 
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c0:	05 00 00 00 30       	add    $0x30000000,%eax
  8013c5:	c1 e8 0c             	shr    $0xc,%eax
}
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    

008013ca <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013ca:	f3 0f 1e fb          	endbr32 
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d4:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8013d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013de:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013e3:	5d                   	pop    %ebp
  8013e4:	c3                   	ret    

008013e5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013e5:	f3 0f 1e fb          	endbr32 
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
  8013ec:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013f1:	89 c2                	mov    %eax,%edx
  8013f3:	c1 ea 16             	shr    $0x16,%edx
  8013f6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013fd:	f6 c2 01             	test   $0x1,%dl
  801400:	74 2d                	je     80142f <fd_alloc+0x4a>
  801402:	89 c2                	mov    %eax,%edx
  801404:	c1 ea 0c             	shr    $0xc,%edx
  801407:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80140e:	f6 c2 01             	test   $0x1,%dl
  801411:	74 1c                	je     80142f <fd_alloc+0x4a>
  801413:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801418:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80141d:	75 d2                	jne    8013f1 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  80141f:	8b 45 08             	mov    0x8(%ebp),%eax
  801422:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801428:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80142d:	eb 0a                	jmp    801439 <fd_alloc+0x54>
			*fd_store = fd;
  80142f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801432:	89 01                	mov    %eax,(%ecx)
			return 0;
  801434:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801439:	5d                   	pop    %ebp
  80143a:	c3                   	ret    

0080143b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80143b:	f3 0f 1e fb          	endbr32 
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801445:	83 f8 1f             	cmp    $0x1f,%eax
  801448:	77 30                	ja     80147a <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80144a:	c1 e0 0c             	shl    $0xc,%eax
  80144d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801452:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801458:	f6 c2 01             	test   $0x1,%dl
  80145b:	74 24                	je     801481 <fd_lookup+0x46>
  80145d:	89 c2                	mov    %eax,%edx
  80145f:	c1 ea 0c             	shr    $0xc,%edx
  801462:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801469:	f6 c2 01             	test   $0x1,%dl
  80146c:	74 1a                	je     801488 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80146e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801471:	89 02                	mov    %eax,(%edx)
	return 0;
  801473:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801478:	5d                   	pop    %ebp
  801479:	c3                   	ret    
		return -E_INVAL;
  80147a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80147f:	eb f7                	jmp    801478 <fd_lookup+0x3d>
		return -E_INVAL;
  801481:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801486:	eb f0                	jmp    801478 <fd_lookup+0x3d>
  801488:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80148d:	eb e9                	jmp    801478 <fd_lookup+0x3d>

0080148f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80148f:	f3 0f 1e fb          	endbr32 
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	83 ec 08             	sub    $0x8,%esp
  801499:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  80149c:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a1:	b8 20 40 80 00       	mov    $0x804020,%eax
		if (devtab[i]->dev_id == dev_id) {
  8014a6:	39 08                	cmp    %ecx,(%eax)
  8014a8:	74 38                	je     8014e2 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8014aa:	83 c2 01             	add    $0x1,%edx
  8014ad:	8b 04 95 b0 2e 80 00 	mov    0x802eb0(,%edx,4),%eax
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	75 ee                	jne    8014a6 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014b8:	a1 0c 50 80 00       	mov    0x80500c,%eax
  8014bd:	8b 40 48             	mov    0x48(%eax),%eax
  8014c0:	83 ec 04             	sub    $0x4,%esp
  8014c3:	51                   	push   %ecx
  8014c4:	50                   	push   %eax
  8014c5:	68 34 2e 80 00       	push   $0x802e34
  8014ca:	e8 4e ef ff ff       	call   80041d <cprintf>
	*dev = 0;
  8014cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014d8:	83 c4 10             	add    $0x10,%esp
  8014db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014e0:	c9                   	leave  
  8014e1:	c3                   	ret    
			*dev = devtab[i];
  8014e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014e5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ec:	eb f2                	jmp    8014e0 <dev_lookup+0x51>

008014ee <fd_close>:
{
  8014ee:	f3 0f 1e fb          	endbr32 
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	57                   	push   %edi
  8014f6:	56                   	push   %esi
  8014f7:	53                   	push   %ebx
  8014f8:	83 ec 24             	sub    $0x24,%esp
  8014fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8014fe:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801501:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801504:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801505:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80150b:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80150e:	50                   	push   %eax
  80150f:	e8 27 ff ff ff       	call   80143b <fd_lookup>
  801514:	89 c3                	mov    %eax,%ebx
  801516:	83 c4 10             	add    $0x10,%esp
  801519:	85 c0                	test   %eax,%eax
  80151b:	78 05                	js     801522 <fd_close+0x34>
	    || fd != fd2)
  80151d:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801520:	74 16                	je     801538 <fd_close+0x4a>
		return (must_exist ? r : 0);
  801522:	89 f8                	mov    %edi,%eax
  801524:	84 c0                	test   %al,%al
  801526:	b8 00 00 00 00       	mov    $0x0,%eax
  80152b:	0f 44 d8             	cmove  %eax,%ebx
}
  80152e:	89 d8                	mov    %ebx,%eax
  801530:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801533:	5b                   	pop    %ebx
  801534:	5e                   	pop    %esi
  801535:	5f                   	pop    %edi
  801536:	5d                   	pop    %ebp
  801537:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801538:	83 ec 08             	sub    $0x8,%esp
  80153b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80153e:	50                   	push   %eax
  80153f:	ff 36                	pushl  (%esi)
  801541:	e8 49 ff ff ff       	call   80148f <dev_lookup>
  801546:	89 c3                	mov    %eax,%ebx
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	85 c0                	test   %eax,%eax
  80154d:	78 1a                	js     801569 <fd_close+0x7b>
		if (dev->dev_close)
  80154f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801552:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801555:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80155a:	85 c0                	test   %eax,%eax
  80155c:	74 0b                	je     801569 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80155e:	83 ec 0c             	sub    $0xc,%esp
  801561:	56                   	push   %esi
  801562:	ff d0                	call   *%eax
  801564:	89 c3                	mov    %eax,%ebx
  801566:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801569:	83 ec 08             	sub    $0x8,%esp
  80156c:	56                   	push   %esi
  80156d:	6a 00                	push   $0x0
  80156f:	e8 67 f9 ff ff       	call   800edb <sys_page_unmap>
	return r;
  801574:	83 c4 10             	add    $0x10,%esp
  801577:	eb b5                	jmp    80152e <fd_close+0x40>

00801579 <close>:

int
close(int fdnum)
{
  801579:	f3 0f 1e fb          	endbr32 
  80157d:	55                   	push   %ebp
  80157e:	89 e5                	mov    %esp,%ebp
  801580:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801583:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801586:	50                   	push   %eax
  801587:	ff 75 08             	pushl  0x8(%ebp)
  80158a:	e8 ac fe ff ff       	call   80143b <fd_lookup>
  80158f:	83 c4 10             	add    $0x10,%esp
  801592:	85 c0                	test   %eax,%eax
  801594:	79 02                	jns    801598 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801596:	c9                   	leave  
  801597:	c3                   	ret    
		return fd_close(fd, 1);
  801598:	83 ec 08             	sub    $0x8,%esp
  80159b:	6a 01                	push   $0x1
  80159d:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a0:	e8 49 ff ff ff       	call   8014ee <fd_close>
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	eb ec                	jmp    801596 <close+0x1d>

008015aa <close_all>:

void
close_all(void)
{
  8015aa:	f3 0f 1e fb          	endbr32 
  8015ae:	55                   	push   %ebp
  8015af:	89 e5                	mov    %esp,%ebp
  8015b1:	53                   	push   %ebx
  8015b2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015b5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015ba:	83 ec 0c             	sub    $0xc,%esp
  8015bd:	53                   	push   %ebx
  8015be:	e8 b6 ff ff ff       	call   801579 <close>
	for (i = 0; i < MAXFD; i++)
  8015c3:	83 c3 01             	add    $0x1,%ebx
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	83 fb 20             	cmp    $0x20,%ebx
  8015cc:	75 ec                	jne    8015ba <close_all+0x10>
}
  8015ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d1:	c9                   	leave  
  8015d2:	c3                   	ret    

008015d3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015d3:	f3 0f 1e fb          	endbr32 
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	57                   	push   %edi
  8015db:	56                   	push   %esi
  8015dc:	53                   	push   %ebx
  8015dd:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015e0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015e3:	50                   	push   %eax
  8015e4:	ff 75 08             	pushl  0x8(%ebp)
  8015e7:	e8 4f fe ff ff       	call   80143b <fd_lookup>
  8015ec:	89 c3                	mov    %eax,%ebx
  8015ee:	83 c4 10             	add    $0x10,%esp
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	0f 88 81 00 00 00    	js     80167a <dup+0xa7>
		return r;
	close(newfdnum);
  8015f9:	83 ec 0c             	sub    $0xc,%esp
  8015fc:	ff 75 0c             	pushl  0xc(%ebp)
  8015ff:	e8 75 ff ff ff       	call   801579 <close>

	newfd = INDEX2FD(newfdnum);
  801604:	8b 75 0c             	mov    0xc(%ebp),%esi
  801607:	c1 e6 0c             	shl    $0xc,%esi
  80160a:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801610:	83 c4 04             	add    $0x4,%esp
  801613:	ff 75 e4             	pushl  -0x1c(%ebp)
  801616:	e8 af fd ff ff       	call   8013ca <fd2data>
  80161b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80161d:	89 34 24             	mov    %esi,(%esp)
  801620:	e8 a5 fd ff ff       	call   8013ca <fd2data>
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80162a:	89 d8                	mov    %ebx,%eax
  80162c:	c1 e8 16             	shr    $0x16,%eax
  80162f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801636:	a8 01                	test   $0x1,%al
  801638:	74 11                	je     80164b <dup+0x78>
  80163a:	89 d8                	mov    %ebx,%eax
  80163c:	c1 e8 0c             	shr    $0xc,%eax
  80163f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801646:	f6 c2 01             	test   $0x1,%dl
  801649:	75 39                	jne    801684 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80164b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80164e:	89 d0                	mov    %edx,%eax
  801650:	c1 e8 0c             	shr    $0xc,%eax
  801653:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80165a:	83 ec 0c             	sub    $0xc,%esp
  80165d:	25 07 0e 00 00       	and    $0xe07,%eax
  801662:	50                   	push   %eax
  801663:	56                   	push   %esi
  801664:	6a 00                	push   $0x0
  801666:	52                   	push   %edx
  801667:	6a 00                	push   $0x0
  801669:	e8 48 f8 ff ff       	call   800eb6 <sys_page_map>
  80166e:	89 c3                	mov    %eax,%ebx
  801670:	83 c4 20             	add    $0x20,%esp
  801673:	85 c0                	test   %eax,%eax
  801675:	78 31                	js     8016a8 <dup+0xd5>
		goto err;

	return newfdnum;
  801677:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80167a:	89 d8                	mov    %ebx,%eax
  80167c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80167f:	5b                   	pop    %ebx
  801680:	5e                   	pop    %esi
  801681:	5f                   	pop    %edi
  801682:	5d                   	pop    %ebp
  801683:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801684:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80168b:	83 ec 0c             	sub    $0xc,%esp
  80168e:	25 07 0e 00 00       	and    $0xe07,%eax
  801693:	50                   	push   %eax
  801694:	57                   	push   %edi
  801695:	6a 00                	push   $0x0
  801697:	53                   	push   %ebx
  801698:	6a 00                	push   $0x0
  80169a:	e8 17 f8 ff ff       	call   800eb6 <sys_page_map>
  80169f:	89 c3                	mov    %eax,%ebx
  8016a1:	83 c4 20             	add    $0x20,%esp
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	79 a3                	jns    80164b <dup+0x78>
	sys_page_unmap(0, newfd);
  8016a8:	83 ec 08             	sub    $0x8,%esp
  8016ab:	56                   	push   %esi
  8016ac:	6a 00                	push   $0x0
  8016ae:	e8 28 f8 ff ff       	call   800edb <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016b3:	83 c4 08             	add    $0x8,%esp
  8016b6:	57                   	push   %edi
  8016b7:	6a 00                	push   $0x0
  8016b9:	e8 1d f8 ff ff       	call   800edb <sys_page_unmap>
	return r;
  8016be:	83 c4 10             	add    $0x10,%esp
  8016c1:	eb b7                	jmp    80167a <dup+0xa7>

008016c3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016c3:	f3 0f 1e fb          	endbr32 
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	53                   	push   %ebx
  8016cb:	83 ec 1c             	sub    $0x1c,%esp
  8016ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d4:	50                   	push   %eax
  8016d5:	53                   	push   %ebx
  8016d6:	e8 60 fd ff ff       	call   80143b <fd_lookup>
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	78 3f                	js     801721 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e2:	83 ec 08             	sub    $0x8,%esp
  8016e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e8:	50                   	push   %eax
  8016e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ec:	ff 30                	pushl  (%eax)
  8016ee:	e8 9c fd ff ff       	call   80148f <dev_lookup>
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	78 27                	js     801721 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016fd:	8b 42 08             	mov    0x8(%edx),%eax
  801700:	83 e0 03             	and    $0x3,%eax
  801703:	83 f8 01             	cmp    $0x1,%eax
  801706:	74 1e                	je     801726 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801708:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80170b:	8b 40 08             	mov    0x8(%eax),%eax
  80170e:	85 c0                	test   %eax,%eax
  801710:	74 35                	je     801747 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801712:	83 ec 04             	sub    $0x4,%esp
  801715:	ff 75 10             	pushl  0x10(%ebp)
  801718:	ff 75 0c             	pushl  0xc(%ebp)
  80171b:	52                   	push   %edx
  80171c:	ff d0                	call   *%eax
  80171e:	83 c4 10             	add    $0x10,%esp
}
  801721:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801724:	c9                   	leave  
  801725:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801726:	a1 0c 50 80 00       	mov    0x80500c,%eax
  80172b:	8b 40 48             	mov    0x48(%eax),%eax
  80172e:	83 ec 04             	sub    $0x4,%esp
  801731:	53                   	push   %ebx
  801732:	50                   	push   %eax
  801733:	68 75 2e 80 00       	push   $0x802e75
  801738:	e8 e0 ec ff ff       	call   80041d <cprintf>
		return -E_INVAL;
  80173d:	83 c4 10             	add    $0x10,%esp
  801740:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801745:	eb da                	jmp    801721 <read+0x5e>
		return -E_NOT_SUPP;
  801747:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80174c:	eb d3                	jmp    801721 <read+0x5e>

0080174e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80174e:	f3 0f 1e fb          	endbr32 
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	57                   	push   %edi
  801756:	56                   	push   %esi
  801757:	53                   	push   %ebx
  801758:	83 ec 0c             	sub    $0xc,%esp
  80175b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80175e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801761:	bb 00 00 00 00       	mov    $0x0,%ebx
  801766:	eb 02                	jmp    80176a <readn+0x1c>
  801768:	01 c3                	add    %eax,%ebx
  80176a:	39 f3                	cmp    %esi,%ebx
  80176c:	73 21                	jae    80178f <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80176e:	83 ec 04             	sub    $0x4,%esp
  801771:	89 f0                	mov    %esi,%eax
  801773:	29 d8                	sub    %ebx,%eax
  801775:	50                   	push   %eax
  801776:	89 d8                	mov    %ebx,%eax
  801778:	03 45 0c             	add    0xc(%ebp),%eax
  80177b:	50                   	push   %eax
  80177c:	57                   	push   %edi
  80177d:	e8 41 ff ff ff       	call   8016c3 <read>
		if (m < 0)
  801782:	83 c4 10             	add    $0x10,%esp
  801785:	85 c0                	test   %eax,%eax
  801787:	78 04                	js     80178d <readn+0x3f>
			return m;
		if (m == 0)
  801789:	75 dd                	jne    801768 <readn+0x1a>
  80178b:	eb 02                	jmp    80178f <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80178d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80178f:	89 d8                	mov    %ebx,%eax
  801791:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801794:	5b                   	pop    %ebx
  801795:	5e                   	pop    %esi
  801796:	5f                   	pop    %edi
  801797:	5d                   	pop    %ebp
  801798:	c3                   	ret    

00801799 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801799:	f3 0f 1e fb          	endbr32 
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
  8017a0:	53                   	push   %ebx
  8017a1:	83 ec 1c             	sub    $0x1c,%esp
  8017a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017aa:	50                   	push   %eax
  8017ab:	53                   	push   %ebx
  8017ac:	e8 8a fc ff ff       	call   80143b <fd_lookup>
  8017b1:	83 c4 10             	add    $0x10,%esp
  8017b4:	85 c0                	test   %eax,%eax
  8017b6:	78 3a                	js     8017f2 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b8:	83 ec 08             	sub    $0x8,%esp
  8017bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017be:	50                   	push   %eax
  8017bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c2:	ff 30                	pushl  (%eax)
  8017c4:	e8 c6 fc ff ff       	call   80148f <dev_lookup>
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	78 22                	js     8017f2 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017d7:	74 1e                	je     8017f7 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017dc:	8b 52 0c             	mov    0xc(%edx),%edx
  8017df:	85 d2                	test   %edx,%edx
  8017e1:	74 35                	je     801818 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017e3:	83 ec 04             	sub    $0x4,%esp
  8017e6:	ff 75 10             	pushl  0x10(%ebp)
  8017e9:	ff 75 0c             	pushl  0xc(%ebp)
  8017ec:	50                   	push   %eax
  8017ed:	ff d2                	call   *%edx
  8017ef:	83 c4 10             	add    $0x10,%esp
}
  8017f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f5:	c9                   	leave  
  8017f6:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017f7:	a1 0c 50 80 00       	mov    0x80500c,%eax
  8017fc:	8b 40 48             	mov    0x48(%eax),%eax
  8017ff:	83 ec 04             	sub    $0x4,%esp
  801802:	53                   	push   %ebx
  801803:	50                   	push   %eax
  801804:	68 91 2e 80 00       	push   $0x802e91
  801809:	e8 0f ec ff ff       	call   80041d <cprintf>
		return -E_INVAL;
  80180e:	83 c4 10             	add    $0x10,%esp
  801811:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801816:	eb da                	jmp    8017f2 <write+0x59>
		return -E_NOT_SUPP;
  801818:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80181d:	eb d3                	jmp    8017f2 <write+0x59>

0080181f <seek>:

int
seek(int fdnum, off_t offset)
{
  80181f:	f3 0f 1e fb          	endbr32 
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801829:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182c:	50                   	push   %eax
  80182d:	ff 75 08             	pushl  0x8(%ebp)
  801830:	e8 06 fc ff ff       	call   80143b <fd_lookup>
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	85 c0                	test   %eax,%eax
  80183a:	78 0e                	js     80184a <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80183c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80183f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801842:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801845:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80184a:	c9                   	leave  
  80184b:	c3                   	ret    

0080184c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80184c:	f3 0f 1e fb          	endbr32 
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	53                   	push   %ebx
  801854:	83 ec 1c             	sub    $0x1c,%esp
  801857:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80185a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80185d:	50                   	push   %eax
  80185e:	53                   	push   %ebx
  80185f:	e8 d7 fb ff ff       	call   80143b <fd_lookup>
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	85 c0                	test   %eax,%eax
  801869:	78 37                	js     8018a2 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80186b:	83 ec 08             	sub    $0x8,%esp
  80186e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801871:	50                   	push   %eax
  801872:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801875:	ff 30                	pushl  (%eax)
  801877:	e8 13 fc ff ff       	call   80148f <dev_lookup>
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	85 c0                	test   %eax,%eax
  801881:	78 1f                	js     8018a2 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801883:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801886:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80188a:	74 1b                	je     8018a7 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80188c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80188f:	8b 52 18             	mov    0x18(%edx),%edx
  801892:	85 d2                	test   %edx,%edx
  801894:	74 32                	je     8018c8 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801896:	83 ec 08             	sub    $0x8,%esp
  801899:	ff 75 0c             	pushl  0xc(%ebp)
  80189c:	50                   	push   %eax
  80189d:	ff d2                	call   *%edx
  80189f:	83 c4 10             	add    $0x10,%esp
}
  8018a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a5:	c9                   	leave  
  8018a6:	c3                   	ret    
			thisenv->env_id, fdnum);
  8018a7:	a1 0c 50 80 00       	mov    0x80500c,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018ac:	8b 40 48             	mov    0x48(%eax),%eax
  8018af:	83 ec 04             	sub    $0x4,%esp
  8018b2:	53                   	push   %ebx
  8018b3:	50                   	push   %eax
  8018b4:	68 54 2e 80 00       	push   $0x802e54
  8018b9:	e8 5f eb ff ff       	call   80041d <cprintf>
		return -E_INVAL;
  8018be:	83 c4 10             	add    $0x10,%esp
  8018c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018c6:	eb da                	jmp    8018a2 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8018c8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018cd:	eb d3                	jmp    8018a2 <ftruncate+0x56>

008018cf <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018cf:	f3 0f 1e fb          	endbr32 
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	53                   	push   %ebx
  8018d7:	83 ec 1c             	sub    $0x1c,%esp
  8018da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e0:	50                   	push   %eax
  8018e1:	ff 75 08             	pushl  0x8(%ebp)
  8018e4:	e8 52 fb ff ff       	call   80143b <fd_lookup>
  8018e9:	83 c4 10             	add    $0x10,%esp
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	78 4b                	js     80193b <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f0:	83 ec 08             	sub    $0x8,%esp
  8018f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f6:	50                   	push   %eax
  8018f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fa:	ff 30                	pushl  (%eax)
  8018fc:	e8 8e fb ff ff       	call   80148f <dev_lookup>
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	85 c0                	test   %eax,%eax
  801906:	78 33                	js     80193b <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801908:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80190b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80190f:	74 2f                	je     801940 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801911:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801914:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80191b:	00 00 00 
	stat->st_isdir = 0;
  80191e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801925:	00 00 00 
	stat->st_dev = dev;
  801928:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80192e:	83 ec 08             	sub    $0x8,%esp
  801931:	53                   	push   %ebx
  801932:	ff 75 f0             	pushl  -0x10(%ebp)
  801935:	ff 50 14             	call   *0x14(%eax)
  801938:	83 c4 10             	add    $0x10,%esp
}
  80193b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80193e:	c9                   	leave  
  80193f:	c3                   	ret    
		return -E_NOT_SUPP;
  801940:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801945:	eb f4                	jmp    80193b <fstat+0x6c>

00801947 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801947:	f3 0f 1e fb          	endbr32 
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	56                   	push   %esi
  80194f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801950:	83 ec 08             	sub    $0x8,%esp
  801953:	6a 00                	push   $0x0
  801955:	ff 75 08             	pushl  0x8(%ebp)
  801958:	e8 01 02 00 00       	call   801b5e <open>
  80195d:	89 c3                	mov    %eax,%ebx
  80195f:	83 c4 10             	add    $0x10,%esp
  801962:	85 c0                	test   %eax,%eax
  801964:	78 1b                	js     801981 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801966:	83 ec 08             	sub    $0x8,%esp
  801969:	ff 75 0c             	pushl  0xc(%ebp)
  80196c:	50                   	push   %eax
  80196d:	e8 5d ff ff ff       	call   8018cf <fstat>
  801972:	89 c6                	mov    %eax,%esi
	close(fd);
  801974:	89 1c 24             	mov    %ebx,(%esp)
  801977:	e8 fd fb ff ff       	call   801579 <close>
	return r;
  80197c:	83 c4 10             	add    $0x10,%esp
  80197f:	89 f3                	mov    %esi,%ebx
}
  801981:	89 d8                	mov    %ebx,%eax
  801983:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801986:	5b                   	pop    %ebx
  801987:	5e                   	pop    %esi
  801988:	5d                   	pop    %ebp
  801989:	c3                   	ret    

0080198a <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	56                   	push   %esi
  80198e:	53                   	push   %ebx
  80198f:	89 c6                	mov    %eax,%esi
  801991:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801993:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  80199a:	74 27                	je     8019c3 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80199c:	6a 07                	push   $0x7
  80199e:	68 00 60 80 00       	push   $0x806000
  8019a3:	56                   	push   %esi
  8019a4:	ff 35 04 50 80 00    	pushl  0x805004
  8019aa:	e8 72 f9 ff ff       	call   801321 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019af:	83 c4 0c             	add    $0xc,%esp
  8019b2:	6a 00                	push   $0x0
  8019b4:	53                   	push   %ebx
  8019b5:	6a 00                	push   $0x0
  8019b7:	e8 f8 f8 ff ff       	call   8012b4 <ipc_recv>
}
  8019bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019bf:	5b                   	pop    %ebx
  8019c0:	5e                   	pop    %esi
  8019c1:	5d                   	pop    %ebp
  8019c2:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019c3:	83 ec 0c             	sub    $0xc,%esp
  8019c6:	6a 01                	push   $0x1
  8019c8:	e8 ac f9 ff ff       	call   801379 <ipc_find_env>
  8019cd:	a3 04 50 80 00       	mov    %eax,0x805004
  8019d2:	83 c4 10             	add    $0x10,%esp
  8019d5:	eb c5                	jmp    80199c <fsipc+0x12>

008019d7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019d7:	f3 0f 1e fb          	endbr32 
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e7:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8019ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ef:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f9:	b8 02 00 00 00       	mov    $0x2,%eax
  8019fe:	e8 87 ff ff ff       	call   80198a <fsipc>
}
  801a03:	c9                   	leave  
  801a04:	c3                   	ret    

00801a05 <devfile_flush>:
{
  801a05:	f3 0f 1e fb          	endbr32 
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a12:	8b 40 0c             	mov    0xc(%eax),%eax
  801a15:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a1a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1f:	b8 06 00 00 00       	mov    $0x6,%eax
  801a24:	e8 61 ff ff ff       	call   80198a <fsipc>
}
  801a29:	c9                   	leave  
  801a2a:	c3                   	ret    

00801a2b <devfile_stat>:
{
  801a2b:	f3 0f 1e fb          	endbr32 
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	53                   	push   %ebx
  801a33:	83 ec 04             	sub    $0x4,%esp
  801a36:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a39:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a3f:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a44:	ba 00 00 00 00       	mov    $0x0,%edx
  801a49:	b8 05 00 00 00       	mov    $0x5,%eax
  801a4e:	e8 37 ff ff ff       	call   80198a <fsipc>
  801a53:	85 c0                	test   %eax,%eax
  801a55:	78 2c                	js     801a83 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a57:	83 ec 08             	sub    $0x8,%esp
  801a5a:	68 00 60 80 00       	push   $0x806000
  801a5f:	53                   	push   %ebx
  801a60:	e8 c2 ef ff ff       	call   800a27 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a65:	a1 80 60 80 00       	mov    0x806080,%eax
  801a6a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a70:	a1 84 60 80 00       	mov    0x806084,%eax
  801a75:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a86:	c9                   	leave  
  801a87:	c3                   	ret    

00801a88 <devfile_write>:
{
  801a88:	f3 0f 1e fb          	endbr32 
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	83 ec 0c             	sub    $0xc,%esp
  801a92:	8b 45 10             	mov    0x10(%ebp),%eax
  801a95:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a9a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a9f:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801aa2:	8b 55 08             	mov    0x8(%ebp),%edx
  801aa5:	8b 52 0c             	mov    0xc(%edx),%edx
  801aa8:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801aae:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801ab3:	50                   	push   %eax
  801ab4:	ff 75 0c             	pushl  0xc(%ebp)
  801ab7:	68 08 60 80 00       	push   $0x806008
  801abc:	e8 64 f1 ff ff       	call   800c25 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801ac1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac6:	b8 04 00 00 00       	mov    $0x4,%eax
  801acb:	e8 ba fe ff ff       	call   80198a <fsipc>
}
  801ad0:	c9                   	leave  
  801ad1:	c3                   	ret    

00801ad2 <devfile_read>:
{
  801ad2:	f3 0f 1e fb          	endbr32 
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	56                   	push   %esi
  801ada:	53                   	push   %ebx
  801adb:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ade:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae1:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae4:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801ae9:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801aef:	ba 00 00 00 00       	mov    $0x0,%edx
  801af4:	b8 03 00 00 00       	mov    $0x3,%eax
  801af9:	e8 8c fe ff ff       	call   80198a <fsipc>
  801afe:	89 c3                	mov    %eax,%ebx
  801b00:	85 c0                	test   %eax,%eax
  801b02:	78 1f                	js     801b23 <devfile_read+0x51>
	assert(r <= n);
  801b04:	39 f0                	cmp    %esi,%eax
  801b06:	77 24                	ja     801b2c <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801b08:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b0d:	7f 36                	jg     801b45 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b0f:	83 ec 04             	sub    $0x4,%esp
  801b12:	50                   	push   %eax
  801b13:	68 00 60 80 00       	push   $0x806000
  801b18:	ff 75 0c             	pushl  0xc(%ebp)
  801b1b:	e8 05 f1 ff ff       	call   800c25 <memmove>
	return r;
  801b20:	83 c4 10             	add    $0x10,%esp
}
  801b23:	89 d8                	mov    %ebx,%eax
  801b25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b28:	5b                   	pop    %ebx
  801b29:	5e                   	pop    %esi
  801b2a:	5d                   	pop    %ebp
  801b2b:	c3                   	ret    
	assert(r <= n);
  801b2c:	68 c4 2e 80 00       	push   $0x802ec4
  801b31:	68 cb 2e 80 00       	push   $0x802ecb
  801b36:	68 8c 00 00 00       	push   $0x8c
  801b3b:	68 e0 2e 80 00       	push   $0x802ee0
  801b40:	e8 f1 e7 ff ff       	call   800336 <_panic>
	assert(r <= PGSIZE);
  801b45:	68 eb 2e 80 00       	push   $0x802eeb
  801b4a:	68 cb 2e 80 00       	push   $0x802ecb
  801b4f:	68 8d 00 00 00       	push   $0x8d
  801b54:	68 e0 2e 80 00       	push   $0x802ee0
  801b59:	e8 d8 e7 ff ff       	call   800336 <_panic>

00801b5e <open>:
{
  801b5e:	f3 0f 1e fb          	endbr32 
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	56                   	push   %esi
  801b66:	53                   	push   %ebx
  801b67:	83 ec 1c             	sub    $0x1c,%esp
  801b6a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801b6d:	56                   	push   %esi
  801b6e:	e8 71 ee ff ff       	call   8009e4 <strlen>
  801b73:	83 c4 10             	add    $0x10,%esp
  801b76:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b7b:	7f 6c                	jg     801be9 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801b7d:	83 ec 0c             	sub    $0xc,%esp
  801b80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b83:	50                   	push   %eax
  801b84:	e8 5c f8 ff ff       	call   8013e5 <fd_alloc>
  801b89:	89 c3                	mov    %eax,%ebx
  801b8b:	83 c4 10             	add    $0x10,%esp
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	78 3c                	js     801bce <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801b92:	83 ec 08             	sub    $0x8,%esp
  801b95:	56                   	push   %esi
  801b96:	68 00 60 80 00       	push   $0x806000
  801b9b:	e8 87 ee ff ff       	call   800a27 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ba0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba3:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ba8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bab:	b8 01 00 00 00       	mov    $0x1,%eax
  801bb0:	e8 d5 fd ff ff       	call   80198a <fsipc>
  801bb5:	89 c3                	mov    %eax,%ebx
  801bb7:	83 c4 10             	add    $0x10,%esp
  801bba:	85 c0                	test   %eax,%eax
  801bbc:	78 19                	js     801bd7 <open+0x79>
	return fd2num(fd);
  801bbe:	83 ec 0c             	sub    $0xc,%esp
  801bc1:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc4:	e8 ed f7 ff ff       	call   8013b6 <fd2num>
  801bc9:	89 c3                	mov    %eax,%ebx
  801bcb:	83 c4 10             	add    $0x10,%esp
}
  801bce:	89 d8                	mov    %ebx,%eax
  801bd0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd3:	5b                   	pop    %ebx
  801bd4:	5e                   	pop    %esi
  801bd5:	5d                   	pop    %ebp
  801bd6:	c3                   	ret    
		fd_close(fd, 0);
  801bd7:	83 ec 08             	sub    $0x8,%esp
  801bda:	6a 00                	push   $0x0
  801bdc:	ff 75 f4             	pushl  -0xc(%ebp)
  801bdf:	e8 0a f9 ff ff       	call   8014ee <fd_close>
		return r;
  801be4:	83 c4 10             	add    $0x10,%esp
  801be7:	eb e5                	jmp    801bce <open+0x70>
		return -E_BAD_PATH;
  801be9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801bee:	eb de                	jmp    801bce <open+0x70>

00801bf0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bf0:	f3 0f 1e fb          	endbr32 
  801bf4:	55                   	push   %ebp
  801bf5:	89 e5                	mov    %esp,%ebp
  801bf7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bfa:	ba 00 00 00 00       	mov    $0x0,%edx
  801bff:	b8 08 00 00 00       	mov    $0x8,%eax
  801c04:	e8 81 fd ff ff       	call   80198a <fsipc>
}
  801c09:	c9                   	leave  
  801c0a:	c3                   	ret    

00801c0b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c0b:	f3 0f 1e fb          	endbr32 
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801c15:	68 57 2f 80 00       	push   $0x802f57
  801c1a:	ff 75 0c             	pushl  0xc(%ebp)
  801c1d:	e8 05 ee ff ff       	call   800a27 <strcpy>
	return 0;
}
  801c22:	b8 00 00 00 00       	mov    $0x0,%eax
  801c27:	c9                   	leave  
  801c28:	c3                   	ret    

00801c29 <devsock_close>:
{
  801c29:	f3 0f 1e fb          	endbr32 
  801c2d:	55                   	push   %ebp
  801c2e:	89 e5                	mov    %esp,%ebp
  801c30:	53                   	push   %ebx
  801c31:	83 ec 10             	sub    $0x10,%esp
  801c34:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c37:	53                   	push   %ebx
  801c38:	e8 18 0a 00 00       	call   802655 <pageref>
  801c3d:	89 c2                	mov    %eax,%edx
  801c3f:	83 c4 10             	add    $0x10,%esp
		return 0;
  801c42:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801c47:	83 fa 01             	cmp    $0x1,%edx
  801c4a:	74 05                	je     801c51 <devsock_close+0x28>
}
  801c4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c4f:	c9                   	leave  
  801c50:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801c51:	83 ec 0c             	sub    $0xc,%esp
  801c54:	ff 73 0c             	pushl  0xc(%ebx)
  801c57:	e8 e3 02 00 00       	call   801f3f <nsipc_close>
  801c5c:	83 c4 10             	add    $0x10,%esp
  801c5f:	eb eb                	jmp    801c4c <devsock_close+0x23>

00801c61 <devsock_write>:
{
  801c61:	f3 0f 1e fb          	endbr32 
  801c65:	55                   	push   %ebp
  801c66:	89 e5                	mov    %esp,%ebp
  801c68:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c6b:	6a 00                	push   $0x0
  801c6d:	ff 75 10             	pushl  0x10(%ebp)
  801c70:	ff 75 0c             	pushl  0xc(%ebp)
  801c73:	8b 45 08             	mov    0x8(%ebp),%eax
  801c76:	ff 70 0c             	pushl  0xc(%eax)
  801c79:	e8 b5 03 00 00       	call   802033 <nsipc_send>
}
  801c7e:	c9                   	leave  
  801c7f:	c3                   	ret    

00801c80 <devsock_read>:
{
  801c80:	f3 0f 1e fb          	endbr32 
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c8a:	6a 00                	push   $0x0
  801c8c:	ff 75 10             	pushl  0x10(%ebp)
  801c8f:	ff 75 0c             	pushl  0xc(%ebp)
  801c92:	8b 45 08             	mov    0x8(%ebp),%eax
  801c95:	ff 70 0c             	pushl  0xc(%eax)
  801c98:	e8 1f 03 00 00       	call   801fbc <nsipc_recv>
}
  801c9d:	c9                   	leave  
  801c9e:	c3                   	ret    

00801c9f <fd2sockid>:
{
  801c9f:	55                   	push   %ebp
  801ca0:	89 e5                	mov    %esp,%ebp
  801ca2:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801ca5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ca8:	52                   	push   %edx
  801ca9:	50                   	push   %eax
  801caa:	e8 8c f7 ff ff       	call   80143b <fd_lookup>
  801caf:	83 c4 10             	add    $0x10,%esp
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	78 10                	js     801cc6 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb9:	8b 0d 60 40 80 00    	mov    0x804060,%ecx
  801cbf:	39 08                	cmp    %ecx,(%eax)
  801cc1:	75 05                	jne    801cc8 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801cc3:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801cc6:	c9                   	leave  
  801cc7:	c3                   	ret    
		return -E_NOT_SUPP;
  801cc8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801ccd:	eb f7                	jmp    801cc6 <fd2sockid+0x27>

00801ccf <alloc_sockfd>:
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	56                   	push   %esi
  801cd3:	53                   	push   %ebx
  801cd4:	83 ec 1c             	sub    $0x1c,%esp
  801cd7:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801cd9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cdc:	50                   	push   %eax
  801cdd:	e8 03 f7 ff ff       	call   8013e5 <fd_alloc>
  801ce2:	89 c3                	mov    %eax,%ebx
  801ce4:	83 c4 10             	add    $0x10,%esp
  801ce7:	85 c0                	test   %eax,%eax
  801ce9:	78 43                	js     801d2e <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ceb:	83 ec 04             	sub    $0x4,%esp
  801cee:	68 07 04 00 00       	push   $0x407
  801cf3:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf6:	6a 00                	push   $0x0
  801cf8:	e8 93 f1 ff ff       	call   800e90 <sys_page_alloc>
  801cfd:	89 c3                	mov    %eax,%ebx
  801cff:	83 c4 10             	add    $0x10,%esp
  801d02:	85 c0                	test   %eax,%eax
  801d04:	78 28                	js     801d2e <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d09:	8b 15 60 40 80 00    	mov    0x804060,%edx
  801d0f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d14:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d1b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d1e:	83 ec 0c             	sub    $0xc,%esp
  801d21:	50                   	push   %eax
  801d22:	e8 8f f6 ff ff       	call   8013b6 <fd2num>
  801d27:	89 c3                	mov    %eax,%ebx
  801d29:	83 c4 10             	add    $0x10,%esp
  801d2c:	eb 0c                	jmp    801d3a <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801d2e:	83 ec 0c             	sub    $0xc,%esp
  801d31:	56                   	push   %esi
  801d32:	e8 08 02 00 00       	call   801f3f <nsipc_close>
		return r;
  801d37:	83 c4 10             	add    $0x10,%esp
}
  801d3a:	89 d8                	mov    %ebx,%eax
  801d3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d3f:	5b                   	pop    %ebx
  801d40:	5e                   	pop    %esi
  801d41:	5d                   	pop    %ebp
  801d42:	c3                   	ret    

00801d43 <accept>:
{
  801d43:	f3 0f 1e fb          	endbr32 
  801d47:	55                   	push   %ebp
  801d48:	89 e5                	mov    %esp,%ebp
  801d4a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d50:	e8 4a ff ff ff       	call   801c9f <fd2sockid>
  801d55:	85 c0                	test   %eax,%eax
  801d57:	78 1b                	js     801d74 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d59:	83 ec 04             	sub    $0x4,%esp
  801d5c:	ff 75 10             	pushl  0x10(%ebp)
  801d5f:	ff 75 0c             	pushl  0xc(%ebp)
  801d62:	50                   	push   %eax
  801d63:	e8 22 01 00 00       	call   801e8a <nsipc_accept>
  801d68:	83 c4 10             	add    $0x10,%esp
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	78 05                	js     801d74 <accept+0x31>
	return alloc_sockfd(r);
  801d6f:	e8 5b ff ff ff       	call   801ccf <alloc_sockfd>
}
  801d74:	c9                   	leave  
  801d75:	c3                   	ret    

00801d76 <bind>:
{
  801d76:	f3 0f 1e fb          	endbr32 
  801d7a:	55                   	push   %ebp
  801d7b:	89 e5                	mov    %esp,%ebp
  801d7d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d80:	8b 45 08             	mov    0x8(%ebp),%eax
  801d83:	e8 17 ff ff ff       	call   801c9f <fd2sockid>
  801d88:	85 c0                	test   %eax,%eax
  801d8a:	78 12                	js     801d9e <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801d8c:	83 ec 04             	sub    $0x4,%esp
  801d8f:	ff 75 10             	pushl  0x10(%ebp)
  801d92:	ff 75 0c             	pushl  0xc(%ebp)
  801d95:	50                   	push   %eax
  801d96:	e8 45 01 00 00       	call   801ee0 <nsipc_bind>
  801d9b:	83 c4 10             	add    $0x10,%esp
}
  801d9e:	c9                   	leave  
  801d9f:	c3                   	ret    

00801da0 <shutdown>:
{
  801da0:	f3 0f 1e fb          	endbr32 
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801daa:	8b 45 08             	mov    0x8(%ebp),%eax
  801dad:	e8 ed fe ff ff       	call   801c9f <fd2sockid>
  801db2:	85 c0                	test   %eax,%eax
  801db4:	78 0f                	js     801dc5 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801db6:	83 ec 08             	sub    $0x8,%esp
  801db9:	ff 75 0c             	pushl  0xc(%ebp)
  801dbc:	50                   	push   %eax
  801dbd:	e8 57 01 00 00       	call   801f19 <nsipc_shutdown>
  801dc2:	83 c4 10             	add    $0x10,%esp
}
  801dc5:	c9                   	leave  
  801dc6:	c3                   	ret    

00801dc7 <connect>:
{
  801dc7:	f3 0f 1e fb          	endbr32 
  801dcb:	55                   	push   %ebp
  801dcc:	89 e5                	mov    %esp,%ebp
  801dce:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801dd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd4:	e8 c6 fe ff ff       	call   801c9f <fd2sockid>
  801dd9:	85 c0                	test   %eax,%eax
  801ddb:	78 12                	js     801def <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801ddd:	83 ec 04             	sub    $0x4,%esp
  801de0:	ff 75 10             	pushl  0x10(%ebp)
  801de3:	ff 75 0c             	pushl  0xc(%ebp)
  801de6:	50                   	push   %eax
  801de7:	e8 71 01 00 00       	call   801f5d <nsipc_connect>
  801dec:	83 c4 10             	add    $0x10,%esp
}
  801def:	c9                   	leave  
  801df0:	c3                   	ret    

00801df1 <listen>:
{
  801df1:	f3 0f 1e fb          	endbr32 
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfe:	e8 9c fe ff ff       	call   801c9f <fd2sockid>
  801e03:	85 c0                	test   %eax,%eax
  801e05:	78 0f                	js     801e16 <listen+0x25>
	return nsipc_listen(r, backlog);
  801e07:	83 ec 08             	sub    $0x8,%esp
  801e0a:	ff 75 0c             	pushl  0xc(%ebp)
  801e0d:	50                   	push   %eax
  801e0e:	e8 83 01 00 00       	call   801f96 <nsipc_listen>
  801e13:	83 c4 10             	add    $0x10,%esp
}
  801e16:	c9                   	leave  
  801e17:	c3                   	ret    

00801e18 <socket>:

int
socket(int domain, int type, int protocol)
{
  801e18:	f3 0f 1e fb          	endbr32 
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e22:	ff 75 10             	pushl  0x10(%ebp)
  801e25:	ff 75 0c             	pushl  0xc(%ebp)
  801e28:	ff 75 08             	pushl  0x8(%ebp)
  801e2b:	e8 65 02 00 00       	call   802095 <nsipc_socket>
  801e30:	83 c4 10             	add    $0x10,%esp
  801e33:	85 c0                	test   %eax,%eax
  801e35:	78 05                	js     801e3c <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801e37:	e8 93 fe ff ff       	call   801ccf <alloc_sockfd>
}
  801e3c:	c9                   	leave  
  801e3d:	c3                   	ret    

00801e3e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	53                   	push   %ebx
  801e42:	83 ec 04             	sub    $0x4,%esp
  801e45:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e47:	83 3d 08 50 80 00 00 	cmpl   $0x0,0x805008
  801e4e:	74 26                	je     801e76 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e50:	6a 07                	push   $0x7
  801e52:	68 00 70 80 00       	push   $0x807000
  801e57:	53                   	push   %ebx
  801e58:	ff 35 08 50 80 00    	pushl  0x805008
  801e5e:	e8 be f4 ff ff       	call   801321 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e63:	83 c4 0c             	add    $0xc,%esp
  801e66:	6a 00                	push   $0x0
  801e68:	6a 00                	push   $0x0
  801e6a:	6a 00                	push   $0x0
  801e6c:	e8 43 f4 ff ff       	call   8012b4 <ipc_recv>
}
  801e71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e74:	c9                   	leave  
  801e75:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e76:	83 ec 0c             	sub    $0xc,%esp
  801e79:	6a 02                	push   $0x2
  801e7b:	e8 f9 f4 ff ff       	call   801379 <ipc_find_env>
  801e80:	a3 08 50 80 00       	mov    %eax,0x805008
  801e85:	83 c4 10             	add    $0x10,%esp
  801e88:	eb c6                	jmp    801e50 <nsipc+0x12>

00801e8a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e8a:	f3 0f 1e fb          	endbr32 
  801e8e:	55                   	push   %ebp
  801e8f:	89 e5                	mov    %esp,%ebp
  801e91:	56                   	push   %esi
  801e92:	53                   	push   %ebx
  801e93:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801e96:	8b 45 08             	mov    0x8(%ebp),%eax
  801e99:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e9e:	8b 06                	mov    (%esi),%eax
  801ea0:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ea5:	b8 01 00 00 00       	mov    $0x1,%eax
  801eaa:	e8 8f ff ff ff       	call   801e3e <nsipc>
  801eaf:	89 c3                	mov    %eax,%ebx
  801eb1:	85 c0                	test   %eax,%eax
  801eb3:	79 09                	jns    801ebe <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801eb5:	89 d8                	mov    %ebx,%eax
  801eb7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eba:	5b                   	pop    %ebx
  801ebb:	5e                   	pop    %esi
  801ebc:	5d                   	pop    %ebp
  801ebd:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ebe:	83 ec 04             	sub    $0x4,%esp
  801ec1:	ff 35 10 70 80 00    	pushl  0x807010
  801ec7:	68 00 70 80 00       	push   $0x807000
  801ecc:	ff 75 0c             	pushl  0xc(%ebp)
  801ecf:	e8 51 ed ff ff       	call   800c25 <memmove>
		*addrlen = ret->ret_addrlen;
  801ed4:	a1 10 70 80 00       	mov    0x807010,%eax
  801ed9:	89 06                	mov    %eax,(%esi)
  801edb:	83 c4 10             	add    $0x10,%esp
	return r;
  801ede:	eb d5                	jmp    801eb5 <nsipc_accept+0x2b>

00801ee0 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ee0:	f3 0f 1e fb          	endbr32 
  801ee4:	55                   	push   %ebp
  801ee5:	89 e5                	mov    %esp,%ebp
  801ee7:	53                   	push   %ebx
  801ee8:	83 ec 08             	sub    $0x8,%esp
  801eeb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801eee:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef1:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ef6:	53                   	push   %ebx
  801ef7:	ff 75 0c             	pushl  0xc(%ebp)
  801efa:	68 04 70 80 00       	push   $0x807004
  801eff:	e8 21 ed ff ff       	call   800c25 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f04:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801f0a:	b8 02 00 00 00       	mov    $0x2,%eax
  801f0f:	e8 2a ff ff ff       	call   801e3e <nsipc>
}
  801f14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f17:	c9                   	leave  
  801f18:	c3                   	ret    

00801f19 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f19:	f3 0f 1e fb          	endbr32 
  801f1d:	55                   	push   %ebp
  801f1e:	89 e5                	mov    %esp,%ebp
  801f20:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f23:	8b 45 08             	mov    0x8(%ebp),%eax
  801f26:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801f2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f2e:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801f33:	b8 03 00 00 00       	mov    $0x3,%eax
  801f38:	e8 01 ff ff ff       	call   801e3e <nsipc>
}
  801f3d:	c9                   	leave  
  801f3e:	c3                   	ret    

00801f3f <nsipc_close>:

int
nsipc_close(int s)
{
  801f3f:	f3 0f 1e fb          	endbr32 
  801f43:	55                   	push   %ebp
  801f44:	89 e5                	mov    %esp,%ebp
  801f46:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f49:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4c:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801f51:	b8 04 00 00 00       	mov    $0x4,%eax
  801f56:	e8 e3 fe ff ff       	call   801e3e <nsipc>
}
  801f5b:	c9                   	leave  
  801f5c:	c3                   	ret    

00801f5d <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f5d:	f3 0f 1e fb          	endbr32 
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	53                   	push   %ebx
  801f65:	83 ec 08             	sub    $0x8,%esp
  801f68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f73:	53                   	push   %ebx
  801f74:	ff 75 0c             	pushl  0xc(%ebp)
  801f77:	68 04 70 80 00       	push   $0x807004
  801f7c:	e8 a4 ec ff ff       	call   800c25 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f81:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801f87:	b8 05 00 00 00       	mov    $0x5,%eax
  801f8c:	e8 ad fe ff ff       	call   801e3e <nsipc>
}
  801f91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f94:	c9                   	leave  
  801f95:	c3                   	ret    

00801f96 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801f96:	f3 0f 1e fb          	endbr32 
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801fa0:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa3:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801fa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fab:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801fb0:	b8 06 00 00 00       	mov    $0x6,%eax
  801fb5:	e8 84 fe ff ff       	call   801e3e <nsipc>
}
  801fba:	c9                   	leave  
  801fbb:	c3                   	ret    

00801fbc <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801fbc:	f3 0f 1e fb          	endbr32 
  801fc0:	55                   	push   %ebp
  801fc1:	89 e5                	mov    %esp,%ebp
  801fc3:	56                   	push   %esi
  801fc4:	53                   	push   %ebx
  801fc5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801fc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801fcb:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801fd0:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801fd6:	8b 45 14             	mov    0x14(%ebp),%eax
  801fd9:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801fde:	b8 07 00 00 00       	mov    $0x7,%eax
  801fe3:	e8 56 fe ff ff       	call   801e3e <nsipc>
  801fe8:	89 c3                	mov    %eax,%ebx
  801fea:	85 c0                	test   %eax,%eax
  801fec:	78 26                	js     802014 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801fee:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801ff4:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801ff9:	0f 4e c6             	cmovle %esi,%eax
  801ffc:	39 c3                	cmp    %eax,%ebx
  801ffe:	7f 1d                	jg     80201d <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802000:	83 ec 04             	sub    $0x4,%esp
  802003:	53                   	push   %ebx
  802004:	68 00 70 80 00       	push   $0x807000
  802009:	ff 75 0c             	pushl  0xc(%ebp)
  80200c:	e8 14 ec ff ff       	call   800c25 <memmove>
  802011:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802014:	89 d8                	mov    %ebx,%eax
  802016:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802019:	5b                   	pop    %ebx
  80201a:	5e                   	pop    %esi
  80201b:	5d                   	pop    %ebp
  80201c:	c3                   	ret    
		assert(r < 1600 && r <= len);
  80201d:	68 63 2f 80 00       	push   $0x802f63
  802022:	68 cb 2e 80 00       	push   $0x802ecb
  802027:	6a 62                	push   $0x62
  802029:	68 78 2f 80 00       	push   $0x802f78
  80202e:	e8 03 e3 ff ff       	call   800336 <_panic>

00802033 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802033:	f3 0f 1e fb          	endbr32 
  802037:	55                   	push   %ebp
  802038:	89 e5                	mov    %esp,%ebp
  80203a:	53                   	push   %ebx
  80203b:	83 ec 04             	sub    $0x4,%esp
  80203e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802041:	8b 45 08             	mov    0x8(%ebp),%eax
  802044:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802049:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80204f:	7f 2e                	jg     80207f <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802051:	83 ec 04             	sub    $0x4,%esp
  802054:	53                   	push   %ebx
  802055:	ff 75 0c             	pushl  0xc(%ebp)
  802058:	68 0c 70 80 00       	push   $0x80700c
  80205d:	e8 c3 eb ff ff       	call   800c25 <memmove>
	nsipcbuf.send.req_size = size;
  802062:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802068:	8b 45 14             	mov    0x14(%ebp),%eax
  80206b:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802070:	b8 08 00 00 00       	mov    $0x8,%eax
  802075:	e8 c4 fd ff ff       	call   801e3e <nsipc>
}
  80207a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80207d:	c9                   	leave  
  80207e:	c3                   	ret    
	assert(size < 1600);
  80207f:	68 84 2f 80 00       	push   $0x802f84
  802084:	68 cb 2e 80 00       	push   $0x802ecb
  802089:	6a 6d                	push   $0x6d
  80208b:	68 78 2f 80 00       	push   $0x802f78
  802090:	e8 a1 e2 ff ff       	call   800336 <_panic>

00802095 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802095:	f3 0f 1e fb          	endbr32 
  802099:	55                   	push   %ebp
  80209a:	89 e5                	mov    %esp,%ebp
  80209c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80209f:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8020a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020aa:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8020af:	8b 45 10             	mov    0x10(%ebp),%eax
  8020b2:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8020b7:	b8 09 00 00 00       	mov    $0x9,%eax
  8020bc:	e8 7d fd ff ff       	call   801e3e <nsipc>
}
  8020c1:	c9                   	leave  
  8020c2:	c3                   	ret    

008020c3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8020c3:	f3 0f 1e fb          	endbr32 
  8020c7:	55                   	push   %ebp
  8020c8:	89 e5                	mov    %esp,%ebp
  8020ca:	56                   	push   %esi
  8020cb:	53                   	push   %ebx
  8020cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8020cf:	83 ec 0c             	sub    $0xc,%esp
  8020d2:	ff 75 08             	pushl  0x8(%ebp)
  8020d5:	e8 f0 f2 ff ff       	call   8013ca <fd2data>
  8020da:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8020dc:	83 c4 08             	add    $0x8,%esp
  8020df:	68 90 2f 80 00       	push   $0x802f90
  8020e4:	53                   	push   %ebx
  8020e5:	e8 3d e9 ff ff       	call   800a27 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8020ea:	8b 46 04             	mov    0x4(%esi),%eax
  8020ed:	2b 06                	sub    (%esi),%eax
  8020ef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8020f5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8020fc:	00 00 00 
	stat->st_dev = &devpipe;
  8020ff:	c7 83 88 00 00 00 7c 	movl   $0x80407c,0x88(%ebx)
  802106:	40 80 00 
	return 0;
}
  802109:	b8 00 00 00 00       	mov    $0x0,%eax
  80210e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802111:	5b                   	pop    %ebx
  802112:	5e                   	pop    %esi
  802113:	5d                   	pop    %ebp
  802114:	c3                   	ret    

00802115 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802115:	f3 0f 1e fb          	endbr32 
  802119:	55                   	push   %ebp
  80211a:	89 e5                	mov    %esp,%ebp
  80211c:	53                   	push   %ebx
  80211d:	83 ec 0c             	sub    $0xc,%esp
  802120:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802123:	53                   	push   %ebx
  802124:	6a 00                	push   $0x0
  802126:	e8 b0 ed ff ff       	call   800edb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80212b:	89 1c 24             	mov    %ebx,(%esp)
  80212e:	e8 97 f2 ff ff       	call   8013ca <fd2data>
  802133:	83 c4 08             	add    $0x8,%esp
  802136:	50                   	push   %eax
  802137:	6a 00                	push   $0x0
  802139:	e8 9d ed ff ff       	call   800edb <sys_page_unmap>
}
  80213e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802141:	c9                   	leave  
  802142:	c3                   	ret    

00802143 <_pipeisclosed>:
{
  802143:	55                   	push   %ebp
  802144:	89 e5                	mov    %esp,%ebp
  802146:	57                   	push   %edi
  802147:	56                   	push   %esi
  802148:	53                   	push   %ebx
  802149:	83 ec 1c             	sub    $0x1c,%esp
  80214c:	89 c7                	mov    %eax,%edi
  80214e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802150:	a1 0c 50 80 00       	mov    0x80500c,%eax
  802155:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802158:	83 ec 0c             	sub    $0xc,%esp
  80215b:	57                   	push   %edi
  80215c:	e8 f4 04 00 00       	call   802655 <pageref>
  802161:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802164:	89 34 24             	mov    %esi,(%esp)
  802167:	e8 e9 04 00 00       	call   802655 <pageref>
		nn = thisenv->env_runs;
  80216c:	8b 15 0c 50 80 00    	mov    0x80500c,%edx
  802172:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802175:	83 c4 10             	add    $0x10,%esp
  802178:	39 cb                	cmp    %ecx,%ebx
  80217a:	74 1b                	je     802197 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80217c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80217f:	75 cf                	jne    802150 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802181:	8b 42 58             	mov    0x58(%edx),%eax
  802184:	6a 01                	push   $0x1
  802186:	50                   	push   %eax
  802187:	53                   	push   %ebx
  802188:	68 97 2f 80 00       	push   $0x802f97
  80218d:	e8 8b e2 ff ff       	call   80041d <cprintf>
  802192:	83 c4 10             	add    $0x10,%esp
  802195:	eb b9                	jmp    802150 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  802197:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80219a:	0f 94 c0             	sete   %al
  80219d:	0f b6 c0             	movzbl %al,%eax
}
  8021a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021a3:	5b                   	pop    %ebx
  8021a4:	5e                   	pop    %esi
  8021a5:	5f                   	pop    %edi
  8021a6:	5d                   	pop    %ebp
  8021a7:	c3                   	ret    

008021a8 <devpipe_write>:
{
  8021a8:	f3 0f 1e fb          	endbr32 
  8021ac:	55                   	push   %ebp
  8021ad:	89 e5                	mov    %esp,%ebp
  8021af:	57                   	push   %edi
  8021b0:	56                   	push   %esi
  8021b1:	53                   	push   %ebx
  8021b2:	83 ec 28             	sub    $0x28,%esp
  8021b5:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8021b8:	56                   	push   %esi
  8021b9:	e8 0c f2 ff ff       	call   8013ca <fd2data>
  8021be:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8021c0:	83 c4 10             	add    $0x10,%esp
  8021c3:	bf 00 00 00 00       	mov    $0x0,%edi
  8021c8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021cb:	74 4f                	je     80221c <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8021cd:	8b 43 04             	mov    0x4(%ebx),%eax
  8021d0:	8b 0b                	mov    (%ebx),%ecx
  8021d2:	8d 51 20             	lea    0x20(%ecx),%edx
  8021d5:	39 d0                	cmp    %edx,%eax
  8021d7:	72 14                	jb     8021ed <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8021d9:	89 da                	mov    %ebx,%edx
  8021db:	89 f0                	mov    %esi,%eax
  8021dd:	e8 61 ff ff ff       	call   802143 <_pipeisclosed>
  8021e2:	85 c0                	test   %eax,%eax
  8021e4:	75 3b                	jne    802221 <devpipe_write+0x79>
			sys_yield();
  8021e6:	e8 82 ec ff ff       	call   800e6d <sys_yield>
  8021eb:	eb e0                	jmp    8021cd <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8021ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021f0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8021f4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8021f7:	89 c2                	mov    %eax,%edx
  8021f9:	c1 fa 1f             	sar    $0x1f,%edx
  8021fc:	89 d1                	mov    %edx,%ecx
  8021fe:	c1 e9 1b             	shr    $0x1b,%ecx
  802201:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802204:	83 e2 1f             	and    $0x1f,%edx
  802207:	29 ca                	sub    %ecx,%edx
  802209:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80220d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802211:	83 c0 01             	add    $0x1,%eax
  802214:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802217:	83 c7 01             	add    $0x1,%edi
  80221a:	eb ac                	jmp    8021c8 <devpipe_write+0x20>
	return i;
  80221c:	8b 45 10             	mov    0x10(%ebp),%eax
  80221f:	eb 05                	jmp    802226 <devpipe_write+0x7e>
				return 0;
  802221:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802226:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802229:	5b                   	pop    %ebx
  80222a:	5e                   	pop    %esi
  80222b:	5f                   	pop    %edi
  80222c:	5d                   	pop    %ebp
  80222d:	c3                   	ret    

0080222e <devpipe_read>:
{
  80222e:	f3 0f 1e fb          	endbr32 
  802232:	55                   	push   %ebp
  802233:	89 e5                	mov    %esp,%ebp
  802235:	57                   	push   %edi
  802236:	56                   	push   %esi
  802237:	53                   	push   %ebx
  802238:	83 ec 18             	sub    $0x18,%esp
  80223b:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80223e:	57                   	push   %edi
  80223f:	e8 86 f1 ff ff       	call   8013ca <fd2data>
  802244:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802246:	83 c4 10             	add    $0x10,%esp
  802249:	be 00 00 00 00       	mov    $0x0,%esi
  80224e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802251:	75 14                	jne    802267 <devpipe_read+0x39>
	return i;
  802253:	8b 45 10             	mov    0x10(%ebp),%eax
  802256:	eb 02                	jmp    80225a <devpipe_read+0x2c>
				return i;
  802258:	89 f0                	mov    %esi,%eax
}
  80225a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80225d:	5b                   	pop    %ebx
  80225e:	5e                   	pop    %esi
  80225f:	5f                   	pop    %edi
  802260:	5d                   	pop    %ebp
  802261:	c3                   	ret    
			sys_yield();
  802262:	e8 06 ec ff ff       	call   800e6d <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802267:	8b 03                	mov    (%ebx),%eax
  802269:	3b 43 04             	cmp    0x4(%ebx),%eax
  80226c:	75 18                	jne    802286 <devpipe_read+0x58>
			if (i > 0)
  80226e:	85 f6                	test   %esi,%esi
  802270:	75 e6                	jne    802258 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  802272:	89 da                	mov    %ebx,%edx
  802274:	89 f8                	mov    %edi,%eax
  802276:	e8 c8 fe ff ff       	call   802143 <_pipeisclosed>
  80227b:	85 c0                	test   %eax,%eax
  80227d:	74 e3                	je     802262 <devpipe_read+0x34>
				return 0;
  80227f:	b8 00 00 00 00       	mov    $0x0,%eax
  802284:	eb d4                	jmp    80225a <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802286:	99                   	cltd   
  802287:	c1 ea 1b             	shr    $0x1b,%edx
  80228a:	01 d0                	add    %edx,%eax
  80228c:	83 e0 1f             	and    $0x1f,%eax
  80228f:	29 d0                	sub    %edx,%eax
  802291:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802296:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802299:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80229c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80229f:	83 c6 01             	add    $0x1,%esi
  8022a2:	eb aa                	jmp    80224e <devpipe_read+0x20>

008022a4 <pipe>:
{
  8022a4:	f3 0f 1e fb          	endbr32 
  8022a8:	55                   	push   %ebp
  8022a9:	89 e5                	mov    %esp,%ebp
  8022ab:	56                   	push   %esi
  8022ac:	53                   	push   %ebx
  8022ad:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8022b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022b3:	50                   	push   %eax
  8022b4:	e8 2c f1 ff ff       	call   8013e5 <fd_alloc>
  8022b9:	89 c3                	mov    %eax,%ebx
  8022bb:	83 c4 10             	add    $0x10,%esp
  8022be:	85 c0                	test   %eax,%eax
  8022c0:	0f 88 23 01 00 00    	js     8023e9 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022c6:	83 ec 04             	sub    $0x4,%esp
  8022c9:	68 07 04 00 00       	push   $0x407
  8022ce:	ff 75 f4             	pushl  -0xc(%ebp)
  8022d1:	6a 00                	push   $0x0
  8022d3:	e8 b8 eb ff ff       	call   800e90 <sys_page_alloc>
  8022d8:	89 c3                	mov    %eax,%ebx
  8022da:	83 c4 10             	add    $0x10,%esp
  8022dd:	85 c0                	test   %eax,%eax
  8022df:	0f 88 04 01 00 00    	js     8023e9 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8022e5:	83 ec 0c             	sub    $0xc,%esp
  8022e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8022eb:	50                   	push   %eax
  8022ec:	e8 f4 f0 ff ff       	call   8013e5 <fd_alloc>
  8022f1:	89 c3                	mov    %eax,%ebx
  8022f3:	83 c4 10             	add    $0x10,%esp
  8022f6:	85 c0                	test   %eax,%eax
  8022f8:	0f 88 db 00 00 00    	js     8023d9 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022fe:	83 ec 04             	sub    $0x4,%esp
  802301:	68 07 04 00 00       	push   $0x407
  802306:	ff 75 f0             	pushl  -0x10(%ebp)
  802309:	6a 00                	push   $0x0
  80230b:	e8 80 eb ff ff       	call   800e90 <sys_page_alloc>
  802310:	89 c3                	mov    %eax,%ebx
  802312:	83 c4 10             	add    $0x10,%esp
  802315:	85 c0                	test   %eax,%eax
  802317:	0f 88 bc 00 00 00    	js     8023d9 <pipe+0x135>
	va = fd2data(fd0);
  80231d:	83 ec 0c             	sub    $0xc,%esp
  802320:	ff 75 f4             	pushl  -0xc(%ebp)
  802323:	e8 a2 f0 ff ff       	call   8013ca <fd2data>
  802328:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80232a:	83 c4 0c             	add    $0xc,%esp
  80232d:	68 07 04 00 00       	push   $0x407
  802332:	50                   	push   %eax
  802333:	6a 00                	push   $0x0
  802335:	e8 56 eb ff ff       	call   800e90 <sys_page_alloc>
  80233a:	89 c3                	mov    %eax,%ebx
  80233c:	83 c4 10             	add    $0x10,%esp
  80233f:	85 c0                	test   %eax,%eax
  802341:	0f 88 82 00 00 00    	js     8023c9 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802347:	83 ec 0c             	sub    $0xc,%esp
  80234a:	ff 75 f0             	pushl  -0x10(%ebp)
  80234d:	e8 78 f0 ff ff       	call   8013ca <fd2data>
  802352:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802359:	50                   	push   %eax
  80235a:	6a 00                	push   $0x0
  80235c:	56                   	push   %esi
  80235d:	6a 00                	push   $0x0
  80235f:	e8 52 eb ff ff       	call   800eb6 <sys_page_map>
  802364:	89 c3                	mov    %eax,%ebx
  802366:	83 c4 20             	add    $0x20,%esp
  802369:	85 c0                	test   %eax,%eax
  80236b:	78 4e                	js     8023bb <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  80236d:	a1 7c 40 80 00       	mov    0x80407c,%eax
  802372:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802375:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802377:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80237a:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802381:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802384:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802386:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802389:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802390:	83 ec 0c             	sub    $0xc,%esp
  802393:	ff 75 f4             	pushl  -0xc(%ebp)
  802396:	e8 1b f0 ff ff       	call   8013b6 <fd2num>
  80239b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80239e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8023a0:	83 c4 04             	add    $0x4,%esp
  8023a3:	ff 75 f0             	pushl  -0x10(%ebp)
  8023a6:	e8 0b f0 ff ff       	call   8013b6 <fd2num>
  8023ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023ae:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8023b1:	83 c4 10             	add    $0x10,%esp
  8023b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8023b9:	eb 2e                	jmp    8023e9 <pipe+0x145>
	sys_page_unmap(0, va);
  8023bb:	83 ec 08             	sub    $0x8,%esp
  8023be:	56                   	push   %esi
  8023bf:	6a 00                	push   $0x0
  8023c1:	e8 15 eb ff ff       	call   800edb <sys_page_unmap>
  8023c6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8023c9:	83 ec 08             	sub    $0x8,%esp
  8023cc:	ff 75 f0             	pushl  -0x10(%ebp)
  8023cf:	6a 00                	push   $0x0
  8023d1:	e8 05 eb ff ff       	call   800edb <sys_page_unmap>
  8023d6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8023d9:	83 ec 08             	sub    $0x8,%esp
  8023dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8023df:	6a 00                	push   $0x0
  8023e1:	e8 f5 ea ff ff       	call   800edb <sys_page_unmap>
  8023e6:	83 c4 10             	add    $0x10,%esp
}
  8023e9:	89 d8                	mov    %ebx,%eax
  8023eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023ee:	5b                   	pop    %ebx
  8023ef:	5e                   	pop    %esi
  8023f0:	5d                   	pop    %ebp
  8023f1:	c3                   	ret    

008023f2 <pipeisclosed>:
{
  8023f2:	f3 0f 1e fb          	endbr32 
  8023f6:	55                   	push   %ebp
  8023f7:	89 e5                	mov    %esp,%ebp
  8023f9:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023ff:	50                   	push   %eax
  802400:	ff 75 08             	pushl  0x8(%ebp)
  802403:	e8 33 f0 ff ff       	call   80143b <fd_lookup>
  802408:	83 c4 10             	add    $0x10,%esp
  80240b:	85 c0                	test   %eax,%eax
  80240d:	78 18                	js     802427 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  80240f:	83 ec 0c             	sub    $0xc,%esp
  802412:	ff 75 f4             	pushl  -0xc(%ebp)
  802415:	e8 b0 ef ff ff       	call   8013ca <fd2data>
  80241a:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80241c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80241f:	e8 1f fd ff ff       	call   802143 <_pipeisclosed>
  802424:	83 c4 10             	add    $0x10,%esp
}
  802427:	c9                   	leave  
  802428:	c3                   	ret    

00802429 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802429:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  80242d:	b8 00 00 00 00       	mov    $0x0,%eax
  802432:	c3                   	ret    

00802433 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802433:	f3 0f 1e fb          	endbr32 
  802437:	55                   	push   %ebp
  802438:	89 e5                	mov    %esp,%ebp
  80243a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80243d:	68 af 2f 80 00       	push   $0x802faf
  802442:	ff 75 0c             	pushl  0xc(%ebp)
  802445:	e8 dd e5 ff ff       	call   800a27 <strcpy>
	return 0;
}
  80244a:	b8 00 00 00 00       	mov    $0x0,%eax
  80244f:	c9                   	leave  
  802450:	c3                   	ret    

00802451 <devcons_write>:
{
  802451:	f3 0f 1e fb          	endbr32 
  802455:	55                   	push   %ebp
  802456:	89 e5                	mov    %esp,%ebp
  802458:	57                   	push   %edi
  802459:	56                   	push   %esi
  80245a:	53                   	push   %ebx
  80245b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802461:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802466:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80246c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80246f:	73 31                	jae    8024a2 <devcons_write+0x51>
		m = n - tot;
  802471:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802474:	29 f3                	sub    %esi,%ebx
  802476:	83 fb 7f             	cmp    $0x7f,%ebx
  802479:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80247e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802481:	83 ec 04             	sub    $0x4,%esp
  802484:	53                   	push   %ebx
  802485:	89 f0                	mov    %esi,%eax
  802487:	03 45 0c             	add    0xc(%ebp),%eax
  80248a:	50                   	push   %eax
  80248b:	57                   	push   %edi
  80248c:	e8 94 e7 ff ff       	call   800c25 <memmove>
		sys_cputs(buf, m);
  802491:	83 c4 08             	add    $0x8,%esp
  802494:	53                   	push   %ebx
  802495:	57                   	push   %edi
  802496:	e8 46 e9 ff ff       	call   800de1 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80249b:	01 de                	add    %ebx,%esi
  80249d:	83 c4 10             	add    $0x10,%esp
  8024a0:	eb ca                	jmp    80246c <devcons_write+0x1b>
}
  8024a2:	89 f0                	mov    %esi,%eax
  8024a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024a7:	5b                   	pop    %ebx
  8024a8:	5e                   	pop    %esi
  8024a9:	5f                   	pop    %edi
  8024aa:	5d                   	pop    %ebp
  8024ab:	c3                   	ret    

008024ac <devcons_read>:
{
  8024ac:	f3 0f 1e fb          	endbr32 
  8024b0:	55                   	push   %ebp
  8024b1:	89 e5                	mov    %esp,%ebp
  8024b3:	83 ec 08             	sub    $0x8,%esp
  8024b6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8024bb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8024bf:	74 21                	je     8024e2 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8024c1:	e8 3d e9 ff ff       	call   800e03 <sys_cgetc>
  8024c6:	85 c0                	test   %eax,%eax
  8024c8:	75 07                	jne    8024d1 <devcons_read+0x25>
		sys_yield();
  8024ca:	e8 9e e9 ff ff       	call   800e6d <sys_yield>
  8024cf:	eb f0                	jmp    8024c1 <devcons_read+0x15>
	if (c < 0)
  8024d1:	78 0f                	js     8024e2 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8024d3:	83 f8 04             	cmp    $0x4,%eax
  8024d6:	74 0c                	je     8024e4 <devcons_read+0x38>
	*(char*)vbuf = c;
  8024d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024db:	88 02                	mov    %al,(%edx)
	return 1;
  8024dd:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8024e2:	c9                   	leave  
  8024e3:	c3                   	ret    
		return 0;
  8024e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8024e9:	eb f7                	jmp    8024e2 <devcons_read+0x36>

008024eb <cputchar>:
{
  8024eb:	f3 0f 1e fb          	endbr32 
  8024ef:	55                   	push   %ebp
  8024f0:	89 e5                	mov    %esp,%ebp
  8024f2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8024f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8024f8:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8024fb:	6a 01                	push   $0x1
  8024fd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802500:	50                   	push   %eax
  802501:	e8 db e8 ff ff       	call   800de1 <sys_cputs>
}
  802506:	83 c4 10             	add    $0x10,%esp
  802509:	c9                   	leave  
  80250a:	c3                   	ret    

0080250b <getchar>:
{
  80250b:	f3 0f 1e fb          	endbr32 
  80250f:	55                   	push   %ebp
  802510:	89 e5                	mov    %esp,%ebp
  802512:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802515:	6a 01                	push   $0x1
  802517:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80251a:	50                   	push   %eax
  80251b:	6a 00                	push   $0x0
  80251d:	e8 a1 f1 ff ff       	call   8016c3 <read>
	if (r < 0)
  802522:	83 c4 10             	add    $0x10,%esp
  802525:	85 c0                	test   %eax,%eax
  802527:	78 06                	js     80252f <getchar+0x24>
	if (r < 1)
  802529:	74 06                	je     802531 <getchar+0x26>
	return c;
  80252b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80252f:	c9                   	leave  
  802530:	c3                   	ret    
		return -E_EOF;
  802531:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802536:	eb f7                	jmp    80252f <getchar+0x24>

00802538 <iscons>:
{
  802538:	f3 0f 1e fb          	endbr32 
  80253c:	55                   	push   %ebp
  80253d:	89 e5                	mov    %esp,%ebp
  80253f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802542:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802545:	50                   	push   %eax
  802546:	ff 75 08             	pushl  0x8(%ebp)
  802549:	e8 ed ee ff ff       	call   80143b <fd_lookup>
  80254e:	83 c4 10             	add    $0x10,%esp
  802551:	85 c0                	test   %eax,%eax
  802553:	78 11                	js     802566 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  802555:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802558:	8b 15 98 40 80 00    	mov    0x804098,%edx
  80255e:	39 10                	cmp    %edx,(%eax)
  802560:	0f 94 c0             	sete   %al
  802563:	0f b6 c0             	movzbl %al,%eax
}
  802566:	c9                   	leave  
  802567:	c3                   	ret    

00802568 <opencons>:
{
  802568:	f3 0f 1e fb          	endbr32 
  80256c:	55                   	push   %ebp
  80256d:	89 e5                	mov    %esp,%ebp
  80256f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802572:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802575:	50                   	push   %eax
  802576:	e8 6a ee ff ff       	call   8013e5 <fd_alloc>
  80257b:	83 c4 10             	add    $0x10,%esp
  80257e:	85 c0                	test   %eax,%eax
  802580:	78 3a                	js     8025bc <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802582:	83 ec 04             	sub    $0x4,%esp
  802585:	68 07 04 00 00       	push   $0x407
  80258a:	ff 75 f4             	pushl  -0xc(%ebp)
  80258d:	6a 00                	push   $0x0
  80258f:	e8 fc e8 ff ff       	call   800e90 <sys_page_alloc>
  802594:	83 c4 10             	add    $0x10,%esp
  802597:	85 c0                	test   %eax,%eax
  802599:	78 21                	js     8025bc <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80259b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80259e:	8b 15 98 40 80 00    	mov    0x804098,%edx
  8025a4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8025a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025a9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8025b0:	83 ec 0c             	sub    $0xc,%esp
  8025b3:	50                   	push   %eax
  8025b4:	e8 fd ed ff ff       	call   8013b6 <fd2num>
  8025b9:	83 c4 10             	add    $0x10,%esp
}
  8025bc:	c9                   	leave  
  8025bd:	c3                   	ret    

008025be <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8025be:	f3 0f 1e fb          	endbr32 
  8025c2:	55                   	push   %ebp
  8025c3:	89 e5                	mov    %esp,%ebp
  8025c5:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8025c8:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8025cf:	74 0a                	je     8025db <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8025d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8025d4:	a3 00 80 80 00       	mov    %eax,0x808000

}
  8025d9:	c9                   	leave  
  8025da:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  8025db:	83 ec 04             	sub    $0x4,%esp
  8025de:	6a 07                	push   $0x7
  8025e0:	68 00 f0 bf ee       	push   $0xeebff000
  8025e5:	6a 00                	push   $0x0
  8025e7:	e8 a4 e8 ff ff       	call   800e90 <sys_page_alloc>
  8025ec:	83 c4 10             	add    $0x10,%esp
  8025ef:	85 c0                	test   %eax,%eax
  8025f1:	78 2a                	js     80261d <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  8025f3:	83 ec 08             	sub    $0x8,%esp
  8025f6:	68 31 26 80 00       	push   $0x802631
  8025fb:	6a 00                	push   $0x0
  8025fd:	e8 48 e9 ff ff       	call   800f4a <sys_env_set_pgfault_upcall>
  802602:	83 c4 10             	add    $0x10,%esp
  802605:	85 c0                	test   %eax,%eax
  802607:	79 c8                	jns    8025d1 <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  802609:	83 ec 04             	sub    $0x4,%esp
  80260c:	68 e8 2f 80 00       	push   $0x802fe8
  802611:	6a 2c                	push   $0x2c
  802613:	68 1e 30 80 00       	push   $0x80301e
  802618:	e8 19 dd ff ff       	call   800336 <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  80261d:	83 ec 04             	sub    $0x4,%esp
  802620:	68 bc 2f 80 00       	push   $0x802fbc
  802625:	6a 22                	push   $0x22
  802627:	68 1e 30 80 00       	push   $0x80301e
  80262c:	e8 05 dd ff ff       	call   800336 <_panic>

00802631 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802631:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802632:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax   			// 间接寻址
  802637:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802639:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  80263c:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  802640:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  802645:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  802649:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  80264b:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  80264e:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  80264f:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  802652:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  802653:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  802654:	c3                   	ret    

00802655 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802655:	f3 0f 1e fb          	endbr32 
  802659:	55                   	push   %ebp
  80265a:	89 e5                	mov    %esp,%ebp
  80265c:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80265f:	89 c2                	mov    %eax,%edx
  802661:	c1 ea 16             	shr    $0x16,%edx
  802664:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80266b:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802670:	f6 c1 01             	test   $0x1,%cl
  802673:	74 1c                	je     802691 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802675:	c1 e8 0c             	shr    $0xc,%eax
  802678:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80267f:	a8 01                	test   $0x1,%al
  802681:	74 0e                	je     802691 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802683:	c1 e8 0c             	shr    $0xc,%eax
  802686:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80268d:	ef 
  80268e:	0f b7 d2             	movzwl %dx,%edx
}
  802691:	89 d0                	mov    %edx,%eax
  802693:	5d                   	pop    %ebp
  802694:	c3                   	ret    
  802695:	66 90                	xchg   %ax,%ax
  802697:	66 90                	xchg   %ax,%ax
  802699:	66 90                	xchg   %ax,%ax
  80269b:	66 90                	xchg   %ax,%ax
  80269d:	66 90                	xchg   %ax,%ax
  80269f:	90                   	nop

008026a0 <__udivdi3>:
  8026a0:	f3 0f 1e fb          	endbr32 
  8026a4:	55                   	push   %ebp
  8026a5:	57                   	push   %edi
  8026a6:	56                   	push   %esi
  8026a7:	53                   	push   %ebx
  8026a8:	83 ec 1c             	sub    $0x1c,%esp
  8026ab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026af:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8026b3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026b7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8026bb:	85 d2                	test   %edx,%edx
  8026bd:	75 19                	jne    8026d8 <__udivdi3+0x38>
  8026bf:	39 f3                	cmp    %esi,%ebx
  8026c1:	76 4d                	jbe    802710 <__udivdi3+0x70>
  8026c3:	31 ff                	xor    %edi,%edi
  8026c5:	89 e8                	mov    %ebp,%eax
  8026c7:	89 f2                	mov    %esi,%edx
  8026c9:	f7 f3                	div    %ebx
  8026cb:	89 fa                	mov    %edi,%edx
  8026cd:	83 c4 1c             	add    $0x1c,%esp
  8026d0:	5b                   	pop    %ebx
  8026d1:	5e                   	pop    %esi
  8026d2:	5f                   	pop    %edi
  8026d3:	5d                   	pop    %ebp
  8026d4:	c3                   	ret    
  8026d5:	8d 76 00             	lea    0x0(%esi),%esi
  8026d8:	39 f2                	cmp    %esi,%edx
  8026da:	76 14                	jbe    8026f0 <__udivdi3+0x50>
  8026dc:	31 ff                	xor    %edi,%edi
  8026de:	31 c0                	xor    %eax,%eax
  8026e0:	89 fa                	mov    %edi,%edx
  8026e2:	83 c4 1c             	add    $0x1c,%esp
  8026e5:	5b                   	pop    %ebx
  8026e6:	5e                   	pop    %esi
  8026e7:	5f                   	pop    %edi
  8026e8:	5d                   	pop    %ebp
  8026e9:	c3                   	ret    
  8026ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026f0:	0f bd fa             	bsr    %edx,%edi
  8026f3:	83 f7 1f             	xor    $0x1f,%edi
  8026f6:	75 48                	jne    802740 <__udivdi3+0xa0>
  8026f8:	39 f2                	cmp    %esi,%edx
  8026fa:	72 06                	jb     802702 <__udivdi3+0x62>
  8026fc:	31 c0                	xor    %eax,%eax
  8026fe:	39 eb                	cmp    %ebp,%ebx
  802700:	77 de                	ja     8026e0 <__udivdi3+0x40>
  802702:	b8 01 00 00 00       	mov    $0x1,%eax
  802707:	eb d7                	jmp    8026e0 <__udivdi3+0x40>
  802709:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802710:	89 d9                	mov    %ebx,%ecx
  802712:	85 db                	test   %ebx,%ebx
  802714:	75 0b                	jne    802721 <__udivdi3+0x81>
  802716:	b8 01 00 00 00       	mov    $0x1,%eax
  80271b:	31 d2                	xor    %edx,%edx
  80271d:	f7 f3                	div    %ebx
  80271f:	89 c1                	mov    %eax,%ecx
  802721:	31 d2                	xor    %edx,%edx
  802723:	89 f0                	mov    %esi,%eax
  802725:	f7 f1                	div    %ecx
  802727:	89 c6                	mov    %eax,%esi
  802729:	89 e8                	mov    %ebp,%eax
  80272b:	89 f7                	mov    %esi,%edi
  80272d:	f7 f1                	div    %ecx
  80272f:	89 fa                	mov    %edi,%edx
  802731:	83 c4 1c             	add    $0x1c,%esp
  802734:	5b                   	pop    %ebx
  802735:	5e                   	pop    %esi
  802736:	5f                   	pop    %edi
  802737:	5d                   	pop    %ebp
  802738:	c3                   	ret    
  802739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802740:	89 f9                	mov    %edi,%ecx
  802742:	b8 20 00 00 00       	mov    $0x20,%eax
  802747:	29 f8                	sub    %edi,%eax
  802749:	d3 e2                	shl    %cl,%edx
  80274b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80274f:	89 c1                	mov    %eax,%ecx
  802751:	89 da                	mov    %ebx,%edx
  802753:	d3 ea                	shr    %cl,%edx
  802755:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802759:	09 d1                	or     %edx,%ecx
  80275b:	89 f2                	mov    %esi,%edx
  80275d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802761:	89 f9                	mov    %edi,%ecx
  802763:	d3 e3                	shl    %cl,%ebx
  802765:	89 c1                	mov    %eax,%ecx
  802767:	d3 ea                	shr    %cl,%edx
  802769:	89 f9                	mov    %edi,%ecx
  80276b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80276f:	89 eb                	mov    %ebp,%ebx
  802771:	d3 e6                	shl    %cl,%esi
  802773:	89 c1                	mov    %eax,%ecx
  802775:	d3 eb                	shr    %cl,%ebx
  802777:	09 de                	or     %ebx,%esi
  802779:	89 f0                	mov    %esi,%eax
  80277b:	f7 74 24 08          	divl   0x8(%esp)
  80277f:	89 d6                	mov    %edx,%esi
  802781:	89 c3                	mov    %eax,%ebx
  802783:	f7 64 24 0c          	mull   0xc(%esp)
  802787:	39 d6                	cmp    %edx,%esi
  802789:	72 15                	jb     8027a0 <__udivdi3+0x100>
  80278b:	89 f9                	mov    %edi,%ecx
  80278d:	d3 e5                	shl    %cl,%ebp
  80278f:	39 c5                	cmp    %eax,%ebp
  802791:	73 04                	jae    802797 <__udivdi3+0xf7>
  802793:	39 d6                	cmp    %edx,%esi
  802795:	74 09                	je     8027a0 <__udivdi3+0x100>
  802797:	89 d8                	mov    %ebx,%eax
  802799:	31 ff                	xor    %edi,%edi
  80279b:	e9 40 ff ff ff       	jmp    8026e0 <__udivdi3+0x40>
  8027a0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8027a3:	31 ff                	xor    %edi,%edi
  8027a5:	e9 36 ff ff ff       	jmp    8026e0 <__udivdi3+0x40>
  8027aa:	66 90                	xchg   %ax,%ax
  8027ac:	66 90                	xchg   %ax,%ax
  8027ae:	66 90                	xchg   %ax,%ax

008027b0 <__umoddi3>:
  8027b0:	f3 0f 1e fb          	endbr32 
  8027b4:	55                   	push   %ebp
  8027b5:	57                   	push   %edi
  8027b6:	56                   	push   %esi
  8027b7:	53                   	push   %ebx
  8027b8:	83 ec 1c             	sub    $0x1c,%esp
  8027bb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8027bf:	8b 74 24 30          	mov    0x30(%esp),%esi
  8027c3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8027c7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027cb:	85 c0                	test   %eax,%eax
  8027cd:	75 19                	jne    8027e8 <__umoddi3+0x38>
  8027cf:	39 df                	cmp    %ebx,%edi
  8027d1:	76 5d                	jbe    802830 <__umoddi3+0x80>
  8027d3:	89 f0                	mov    %esi,%eax
  8027d5:	89 da                	mov    %ebx,%edx
  8027d7:	f7 f7                	div    %edi
  8027d9:	89 d0                	mov    %edx,%eax
  8027db:	31 d2                	xor    %edx,%edx
  8027dd:	83 c4 1c             	add    $0x1c,%esp
  8027e0:	5b                   	pop    %ebx
  8027e1:	5e                   	pop    %esi
  8027e2:	5f                   	pop    %edi
  8027e3:	5d                   	pop    %ebp
  8027e4:	c3                   	ret    
  8027e5:	8d 76 00             	lea    0x0(%esi),%esi
  8027e8:	89 f2                	mov    %esi,%edx
  8027ea:	39 d8                	cmp    %ebx,%eax
  8027ec:	76 12                	jbe    802800 <__umoddi3+0x50>
  8027ee:	89 f0                	mov    %esi,%eax
  8027f0:	89 da                	mov    %ebx,%edx
  8027f2:	83 c4 1c             	add    $0x1c,%esp
  8027f5:	5b                   	pop    %ebx
  8027f6:	5e                   	pop    %esi
  8027f7:	5f                   	pop    %edi
  8027f8:	5d                   	pop    %ebp
  8027f9:	c3                   	ret    
  8027fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802800:	0f bd e8             	bsr    %eax,%ebp
  802803:	83 f5 1f             	xor    $0x1f,%ebp
  802806:	75 50                	jne    802858 <__umoddi3+0xa8>
  802808:	39 d8                	cmp    %ebx,%eax
  80280a:	0f 82 e0 00 00 00    	jb     8028f0 <__umoddi3+0x140>
  802810:	89 d9                	mov    %ebx,%ecx
  802812:	39 f7                	cmp    %esi,%edi
  802814:	0f 86 d6 00 00 00    	jbe    8028f0 <__umoddi3+0x140>
  80281a:	89 d0                	mov    %edx,%eax
  80281c:	89 ca                	mov    %ecx,%edx
  80281e:	83 c4 1c             	add    $0x1c,%esp
  802821:	5b                   	pop    %ebx
  802822:	5e                   	pop    %esi
  802823:	5f                   	pop    %edi
  802824:	5d                   	pop    %ebp
  802825:	c3                   	ret    
  802826:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80282d:	8d 76 00             	lea    0x0(%esi),%esi
  802830:	89 fd                	mov    %edi,%ebp
  802832:	85 ff                	test   %edi,%edi
  802834:	75 0b                	jne    802841 <__umoddi3+0x91>
  802836:	b8 01 00 00 00       	mov    $0x1,%eax
  80283b:	31 d2                	xor    %edx,%edx
  80283d:	f7 f7                	div    %edi
  80283f:	89 c5                	mov    %eax,%ebp
  802841:	89 d8                	mov    %ebx,%eax
  802843:	31 d2                	xor    %edx,%edx
  802845:	f7 f5                	div    %ebp
  802847:	89 f0                	mov    %esi,%eax
  802849:	f7 f5                	div    %ebp
  80284b:	89 d0                	mov    %edx,%eax
  80284d:	31 d2                	xor    %edx,%edx
  80284f:	eb 8c                	jmp    8027dd <__umoddi3+0x2d>
  802851:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802858:	89 e9                	mov    %ebp,%ecx
  80285a:	ba 20 00 00 00       	mov    $0x20,%edx
  80285f:	29 ea                	sub    %ebp,%edx
  802861:	d3 e0                	shl    %cl,%eax
  802863:	89 44 24 08          	mov    %eax,0x8(%esp)
  802867:	89 d1                	mov    %edx,%ecx
  802869:	89 f8                	mov    %edi,%eax
  80286b:	d3 e8                	shr    %cl,%eax
  80286d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802871:	89 54 24 04          	mov    %edx,0x4(%esp)
  802875:	8b 54 24 04          	mov    0x4(%esp),%edx
  802879:	09 c1                	or     %eax,%ecx
  80287b:	89 d8                	mov    %ebx,%eax
  80287d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802881:	89 e9                	mov    %ebp,%ecx
  802883:	d3 e7                	shl    %cl,%edi
  802885:	89 d1                	mov    %edx,%ecx
  802887:	d3 e8                	shr    %cl,%eax
  802889:	89 e9                	mov    %ebp,%ecx
  80288b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80288f:	d3 e3                	shl    %cl,%ebx
  802891:	89 c7                	mov    %eax,%edi
  802893:	89 d1                	mov    %edx,%ecx
  802895:	89 f0                	mov    %esi,%eax
  802897:	d3 e8                	shr    %cl,%eax
  802899:	89 e9                	mov    %ebp,%ecx
  80289b:	89 fa                	mov    %edi,%edx
  80289d:	d3 e6                	shl    %cl,%esi
  80289f:	09 d8                	or     %ebx,%eax
  8028a1:	f7 74 24 08          	divl   0x8(%esp)
  8028a5:	89 d1                	mov    %edx,%ecx
  8028a7:	89 f3                	mov    %esi,%ebx
  8028a9:	f7 64 24 0c          	mull   0xc(%esp)
  8028ad:	89 c6                	mov    %eax,%esi
  8028af:	89 d7                	mov    %edx,%edi
  8028b1:	39 d1                	cmp    %edx,%ecx
  8028b3:	72 06                	jb     8028bb <__umoddi3+0x10b>
  8028b5:	75 10                	jne    8028c7 <__umoddi3+0x117>
  8028b7:	39 c3                	cmp    %eax,%ebx
  8028b9:	73 0c                	jae    8028c7 <__umoddi3+0x117>
  8028bb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8028bf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8028c3:	89 d7                	mov    %edx,%edi
  8028c5:	89 c6                	mov    %eax,%esi
  8028c7:	89 ca                	mov    %ecx,%edx
  8028c9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8028ce:	29 f3                	sub    %esi,%ebx
  8028d0:	19 fa                	sbb    %edi,%edx
  8028d2:	89 d0                	mov    %edx,%eax
  8028d4:	d3 e0                	shl    %cl,%eax
  8028d6:	89 e9                	mov    %ebp,%ecx
  8028d8:	d3 eb                	shr    %cl,%ebx
  8028da:	d3 ea                	shr    %cl,%edx
  8028dc:	09 d8                	or     %ebx,%eax
  8028de:	83 c4 1c             	add    $0x1c,%esp
  8028e1:	5b                   	pop    %ebx
  8028e2:	5e                   	pop    %esi
  8028e3:	5f                   	pop    %edi
  8028e4:	5d                   	pop    %ebp
  8028e5:	c3                   	ret    
  8028e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028ed:	8d 76 00             	lea    0x0(%esi),%esi
  8028f0:	29 fe                	sub    %edi,%esi
  8028f2:	19 c3                	sbb    %eax,%ebx
  8028f4:	89 f2                	mov    %esi,%edx
  8028f6:	89 d9                	mov    %ebx,%ecx
  8028f8:	e9 1d ff ff ff       	jmp    80281a <__umoddi3+0x6a>
