#include <kern/e1000.h>
#include <kern/pmap.h>
#include <inc/string.h>

// LAB 6: Your driver code here
// 定义volatile原因: 
    // otherwise the compiler is allowed 
    // to cache values and reorder accesses 
    // to this memory
    // 为E1000分配了一个物理的MMIO region并将存储再BAR0中
volatile uint32_t* e1000;
// QEMU 默认mac地址
uint32_t mac[6] = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};

struct tx_desc tx_desc_ring[TX_RING_SIZE] __attribute__((aligned(PGSIZE)))
                = {{0, 0, 0, 0, 0, 0, 0}};
char tx_pbuf[TX_RING_SIZE][TX_PACKET_SIZE] __attribute__((aligned(PGSIZE)));

struct rx_desc rx_desc_ring[RX_RING_SIZE] __attribute__((aligned(PGSIZE)))
                = {{0, 0, 0, 0, 0, 0}};
char rx_pbuf[RX_RING_SIZE][RX_PACKET_SIZE] __attribute__((aligned(PGSIZE)));

// Allocate a region of memory for the transmit descriptor list. 
// Software should insure this memory is aligned on a paragraph (16-byte) boundary. 
// Program the Transmit Descriptor Base Address (TDBAL/TDBAH) register(s) with the 
// address of the region. 
// TDBAL is used for 32-bit addresses and both TDBAL and TDBAH are used for 64-bit addresses.
// The Transmit Descriptor Head and Tail (TDH/TDT) registers are initialized (by hardware) to 0b
// after a power-on or a software initiated Ethernet controller reset. 
// Software should write 0b to both these registers to ensure this.
// Initialize the Transmit Control Register (TCTL) for desired operation to include the following:
// Set the Enable (TCTL.EN) bit to 1b for normal operation.
// Set the Pad Short Packets (TCTL.PSP) bit to 1b
// Configure the Collision Threshold (TCTL.CT) to the desired value. 
// Ethernet standard is 10h.
// This setting only has meaning in half duplex mode.
// Configure the Collision Distance (TCTL.COLD) to its expected value. For full duplex
// operation, this value should be set to 40h. For gigabit half duplex, this value should be set to
// 200h. For 10/100 half duplex, this value should be set to 40h.
void e1000_tx_desc_init()
{
    int i;
    memset(tx_desc_ring, 0, sizeof(struct tx_desc)*TX_RING_SIZE);
    for (i=0;i<TX_RING_SIZE; i++){
        // 物理地址
        tx_desc_ring[i].buffer_addr = PADDR(tx_pbuf[i]);
        tx_desc_ring[i].status = E1000_TXD_STAT_DD;
        tx_desc_ring[i].cmd = E1000_TXD_CMD_RS|E1000_TXD_CMD_EOP;
    }
    return;
}
void e1000_rx_desc_init()
{
    int i;
    memset(rx_desc_ring, 0, sizeof(struct rx_desc)*RX_RING_SIZE);
    for (i=0; i<RX_RING_SIZE;i++){
        rx_desc_ring[i].buffer_addr = PADDR(rx_pbuf[i]);
        rx_desc_ring[i].status = 0;
    }
}
void 
e1000_set_mac_addr(uint32_t mac[])
{
    uint32_t low = 0, high = 0; int i;
    for (i=0; i<4; i++) low |= mac[i]<<(8*i);
    for (;i<6;i++) high |= mac[i]<<(8*i);
    
    // hard code receive address
    *(uint32_t* )((uint8_t* )e1000 + E1000_RAL) = low;
    *(uint32_t* )((uint8_t* )e1000 + E1000_RAH) = high|E1000_RAH_AV;
}
int
pci_e1000_attach(struct pci_func* pcif)
{
	pci_func_enable(pcif);
    e1000_tx_desc_init();
    e1000_rx_desc_init();
    // 将E1000的物理地址映射到虚拟地址
    e1000 = mmio_map_region(pcif->reg_base[0], pcif->reg_size[0]);
    // transmitter
    *(uint32_t* )((uint8_t* )e1000+E1000_TDBAL) = PADDR(tx_desc_ring); 
    *(uint32_t* )((uint8_t* )e1000+E1000_TDBAH) = 0;
    *(uint32_t* )((uint8_t* )e1000+E1000_TDH) = 0;
    *(uint32_t* )((uint8_t* )e1000+E1000_TDT) = 0;
    *(uint32_t* )((uint8_t* )e1000+E1000_TDLEN) = TX_RING_SIZE*sizeof(struct tx_desc);

    *(uint32_t* )((uint8_t*)e1000+E1000_TCTL) = E1000_TCTL_EN|
                        E1000_TCTL_PSP|
                        (E1000_TCTL_CT&(0x10<<4))|
                        (E1000_TCTL_COLD&(0x40<<12));

    // 这里的值需要查看IEEE 802.3 section 13.4.34 table 13-77
    *(uint32_t* )((uint8_t* )e1000+E1000_TIPG) = 10 |(8<<10)|(12<<20);
    // receiver
    e1000_set_mac_addr(mac);
    *(uint32_t* )((uint8_t* )e1000+E1000_MTA) = 0;
    *(uint32_t* )((uint8_t* )e1000+E1000_IMS) = E1000_IMS_RXT|
                            E1000_IMS_RXO|
                            E1000_IMS_RXDMT|
                            E1000_IMS_RXSEQ|
                            E1000_IMS_LSC;
    *(uint32_t* )((uint8_t* )e1000+E1000_RDBAL) = PADDR(rx_desc_ring);
    *(uint32_t* )((uint8_t* )e1000+E1000_RDBAH) = 0;
    *(uint32_t* )((uint8_t* )e1000+E1000_RDLEN) = RX_RING_SIZE*sizeof(struct rx_desc);
    *(uint32_t* )((uint8_t* )e1000+E1000_RDH) = 0;
    /*
     * 这里需要将rx tail设置为最后一个可用的描述符即RX_RING_SIZE-1
     * 否则RDH=RDT, 硬件会判断为循环队列已满
    */
    *(uint32_t* )((uint8_t* )e1000+E1000_RDT) = RX_RING_SIZE-1;
    *(uint32_t* )((uint8_t* )e1000+E1000_RCTL) = E1000_RCTL_EN|
                            E1000_RCTL_LBM_NO|
                            E1000_RCTL_SZ_2048|
                            E1000_RCTL_SECRC;


    // cprintf("e1000 device status: [%08x]\n", *(uint32_t* )((uint8_t*)e1000+E1000_STATUS));

	return 1;

}

// Hardware fetches the descriptor indicated by the hardware head register. The
// hardware tail register points one beyond the last valid descriptor.
int
e1000_transmit(void* srcaddr, size_t len)
{
    size_t tx_tail = *(uint32_t* )((uint8_t* )e1000+E1000_TDT); // offset from the base
    struct tx_desc* tail_desc = &tx_desc_ring[tx_tail];
    if (!(tail_desc->status & E1000_TXD_STAT_DD)){
        return -1;
    }
    if (len>TX_PACKET_SIZE){
        len = TX_PACKET_SIZE;
    }
    // descriptor done --> available
    // 这里memmove不可使用 tx_desc_ring[i].buffer_addr as dstaddr 因为是物理地址
    memmove(&tx_pbuf[tx_tail], srcaddr, len);
    tail_desc->length = len;
    tail_desc->status &= (~E1000_TXD_STAT_DD);
    // update TDT
    *(uint32_t* )((uint8_t* )e1000+E1000_TDT) = (tx_tail + 1)%TX_RING_SIZE;
    return 0;

}
// As packets arrive, they are stored in memory and the head pointer is
// incremented by hardware. When the head pointer is equal to the tail pointer, the ring is empty.
// Hardware stops storing packets in system memory until software advances the tail pointer, making
// more receive buffers available. 
// 当有新的packet received, head pointer incremented
// 从rx_desc_ring中读取后 需要increment tail pointer
int
e1000_receive(void* buf, size_t buflen)
{
    // rx_tail 指向下一个可读的descriptor
    size_t rx_tail = (*(uint32_t* )((uint8_t* )e1000+E1000_RDT)+1)% RX_RING_SIZE;
    struct rx_desc* tail_desc = &rx_desc_ring[rx_tail];
    if (!(tail_desc->status&E1000_RXD_STAT_DD))
        return -1;

    if (buflen>tail_desc->length)
        buflen = tail_desc->length;

    memmove(buf, &rx_pbuf[rx_tail], buflen);

    tail_desc->status &= (~E1000_RXD_STAT_DD);
    // update tail
    *(uint32_t* )((uint8_t* )e1000+E1000_RDT) = rx_tail;
    
    return buflen;
}