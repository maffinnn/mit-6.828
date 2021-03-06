#include "ns.h"
#include <kern/e1000.h>

#define MAXSTORAGE 8
extern union Nsipc nsipcbuf;
static struct jif_pkt *pkt = (struct jif_pkt *)REQVA;


// input helper environment 通过调用系统调用从网卡驱动里读取数据包,
// 这里值得注意的一点是 有可能收包（sys_netpacket_recv）太快, 
// 发送给服务器时 服务器可能读取速度慢了 导致相应的内容被冲刷, 所以这里用一个临时存储
// 将收到的数据保存在input helper environment里
void
input(envid_t ns_envid)
{
	binaryname = "ns_input";
	// LAB 6: Your code here:
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
	int i, r;
	int len;
	struct jif_pkt *cpkt = pkt;
	
	for(i = 0; i < 10; i++)
		if ((r = sys_page_alloc(0, (void*)((uintptr_t)pkt + i * PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
			panic("sys_page_alloc: %e", r);
	
	i = 0;
	while(1) {
		while((len = sys_netpacket_recv((void*)((uintptr_t)cpkt + sizeof(cpkt->jp_len)), PGSIZE - sizeof(cpkt->jp_len))) < 0) {
			sys_yield();
		}

		cpkt->jp_len = len;
		ipc_send(ns_envid, NSREQ_INPUT, cpkt, PTE_P | PTE_U);
		i = (i + 1) % 10;
		cpkt = (struct jif_pkt*)((uintptr_t)pkt + i * PGSIZE);
		sys_yield();
	}	

	
}
