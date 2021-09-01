#ifndef JOS_KERN_E1000_H
#define JOS_KERN_E1000_H

#include <kern/pci.h>

#define PCI_E1000_VENDOR_ID 0x8086
#define PCI_E1000_DEVICE_ID 0x100E


int pci_e1000_attach(struct pci_func* pcif);
int e1000_transmit(void* srcaddr, size_t len);
int e1000_receive(void* buf, size_t buflen);



/*
 * Legacy Transmit Descriptor  - PCI Developer Manual Section 3.3.3
 *
 *   63            48 47   40 39   32 31   24 23   16 15             0
 *   +---------------------------------------------------------------+
 * 0 |                         Buffer address                        |
 *   +---------------+-------+-------+-------+-------+---------------+
 * 8 |    Special    |  CSS  | Status|  Cmd  |  CSO  |    Length     |
 *   +---------------+-------+-------+-------+-------+---------------+
 * Each transmit descriptor has 64 bits. 
 * Transmit Descriptor Low (TDBAL) contains the base address for the lower 32 bits
 * Transmit Descriptor High (tDBAH) contains the base address for the higher 32 bits
*/
struct tx_desc
{
    uint64_t buffer_addr;
    uint16_t length;
    uint8_t cso;
    uint8_t cmd;
    uint8_t status;
    uint8_t css;
    uint16_t special;
}__attribute__((packed));
#define TX_RING_SIZE    64 // as required on the lab manual
#define TX_PACKET_SIZE  1518 // largest possible standard Ethernet packet

// PCI Developer Manual Section 13.4.2
// the hexidecimal values are the offset in the mmio ethernet controller registers
#define E1000_CTRL     0x00000  /* Device Control - RW */
#define E1000_STATUS   0x00008  /* Device Status - RO */
#define E1000_TDLEN    0x03808  /* TX Descriptor Length - RW */
#define E1000_TDBAL    0x03800  /* TX Descriptor Base Address Low - RW */
#define E1000_TDBAH    0x03804  /* TX Descriptor Base Address High - RW */
#define E1000_TDH      0x03810  /* TX Descriptor Head - RW */
#define E1000_TDT      0x03818  /* TX Descripotr Tail - RW */
#define E1000_TCTL     0x00400  /* TX Control - RW */
#define E1000_TCTL_EXT 0x00404  /* Extended TX Control - RW */

#define E1000_RXCSUM   0x05000  /* RX Checksum Control - RW */
#define E1000_RFCTL    0x05008  /* Receive Filter Control*/
#define E1000_MTA      0x05200  /* Multicast Table Array - RW Array */
#define E1000_ICR      0x000C0  /* Interrupt Cause Read - R/clr */
#define E1000_ITR      0x000C4  /* Interrupt Throttling Rate - RW */
#define E1000_ICS      0x000C8  /* Interrupt Cause Set - WO */
#define E1000_IMS      0x000D0  /* Interrupt Mask Set - RW */
#define E1000_IMC      0x000D8  /* Interrupt Mask Clear - WO */
/* Receive Address */
#define E1000_RAL      0x05400  /* Receive Address Low - RW Array */
#define E1000_RAH      0x05404  /* Receive Address High - RW Array */
#define E1000_RAH_AV  0x80000000        /* Receive descriptor valid */

#define E1000_RDBAL    0x02800  /* RX Descriptor Base Address Low - RW */
#define E1000_RDBAH    0x02804  /* RX Descriptor Base Address High - RW */
#define E1000_RDLEN    0x02808  /* RX Descriptor Length - RW */
#define E1000_RDH      0x02810  /* RX Descriptor Head - RW */
#define E1000_RDT      0x02818  /* RX Descriptor Tail - RW */
#define E1000_RDTR     0x02820  /* RX Delay Timer - RW */
#define E1000_RCTL     0x00100  /* RX Control - RW */

/* Interrupt Cause Read */
#define E1000_ICR_TXDW          0x00000001 /* Transmit desc written back */
#define E1000_ICR_TXQE          0x00000002 /* Transmit Queue empty */
#define E1000_ICR_LSC           0x00000004 /* Link Status Change */
#define E1000_ICR_RXSEQ         0x00000008 /* rx sequence error */
#define E1000_ICR_RXDMT         0x00000010 /* rx desc min. threshold (0) */
#define E1000_ICR_RXO           0x00000040 /* rx overrun */
#define E1000_ICR_RXT           0x00000080 /* rx timer intr (ring 0) */
#define E1000_ICR_MDAC          0x00000200 /* MDIO access complete */
#define E1000_ICR_RXCFG         0x00000400 /* RX /c/ ordered set */
#define E1000_ICR_GPI_EN0       0x00000800 /* GP Int 0 */
#define E1000_ICR_GPI_EN1       0x00001000 /* GP Int 1 */
#define E1000_ICR_GPI_EN2       0x00002000 /* GP Int 2 */
#define E1000_ICR_GPI_EN3       0x00004000 /* GP Int 3 */
#define E1000_ICR_TXD_LOW       0x00008000
#define E1000_ICR_SRPD          0x00010000
#define E1000_ICR_ACK           0x00020000 /* Receive Ack frame */
#define E1000_ICR_MNG           0x00040000 /* Manageability event */
#define E1000_ICR_DOCK          0x00080000 /* Dock/Undock */

/* Interrupt Mask Set */
#define E1000_IMS_TXDW      E1000_ICR_TXDW      /* Transmit desc written back */
#define E1000_IMS_TXQE      E1000_ICR_TXQE      /* Transmit Queue empty */
#define E1000_IMS_LSC       E1000_ICR_LSC       /* Link Status Change */
#define E1000_IMS_RXSEQ     E1000_ICR_RXSEQ     /* rx sequence error */
#define E1000_IMS_RXDMT     E1000_ICR_RXDMT     /* rx desc min. threshold */
#define E1000_IMS_RXO       E1000_ICR_RXO       /* rx overrun */
#define E1000_IMS_RXT       E1000_ICR_RXT      /* rx timer intr */
#define E1000_IMS_MDAC      E1000_ICR_MDAC      /* MDIO access complete */
#define E1000_IMS_RXCFG     E1000_ICR_RXCFG     /* RX /c/ ordered set */
#define E1000_IMS_GPI_EN0   E1000_ICR_GPI_EN0   /* GP Int 0 */
#define E1000_IMS_GPI_EN1   E1000_ICR_GPI_EN1   /* GP Int 1 */
#define E1000_IMS_GPI_EN2   E1000_ICR_GPI_EN2   /* GP Int 2 */
#define E1000_IMS_GPI_EN3   E1000_ICR_GPI_EN3   /* GP Int 3 */
#define E1000_IMS_TXD_LOW   E1000_ICR_TXD_LOW
#define E1000_IMS_SRPD      E1000_ICR_SRPD
#define E1000_IMS_ACK       E1000_ICR_ACK       /* Receive Ack frame */
#define E1000_IMS_MNG       E1000_ICR_MNG       /* Manageability event */
#define E1000_IMS_DOCK      E1000_ICR_DOCK      /* Dock/Undock */
/* Interrupt Mask Set */
#define E1000_IMS_TXDW      E1000_ICR_TXDW      /* Transmit desc written back */
#define E1000_IMS_TXQE      E1000_ICR_TXQE      /* Transmit Queue empty */
#define E1000_IMS_LSC       E1000_ICR_LSC       /* Link Status Change */
#define E1000_IMS_RXSEQ     E1000_ICR_RXSEQ     /* rx sequence error */
#define E1000_IMS_RXDMT     E1000_ICR_RXDMT    /* rx desc min. threshold */
#define E1000_IMS_RXO       E1000_ICR_RXO       /* rx overrun */
#define E1000_IMS_RXT       E1000_ICR_RXT      /* rx timer intr */
#define E1000_IMS_MDAC      E1000_ICR_MDAC      /* MDIO access complete */
#define E1000_IMS_RXCFG     E1000_ICR_RXCFG     /* RX /c/ ordered set */
#define E1000_IMS_GPI_EN0   E1000_ICR_GPI_EN0   /* GP Int 0 */
#define E1000_IMS_GPI_EN1   E1000_ICR_GPI_EN1   /* GP Int 1 */
#define E1000_IMS_GPI_EN2   E1000_ICR_GPI_EN2   /* GP Int 2 */
#define E1000_IMS_GPI_EN3   E1000_ICR_GPI_EN3   /* GP Int 3 */
#define E1000_IMS_TXD_LOW   E1000_ICR_TXD_LOW
#define E1000_IMS_SRPD      E1000_ICR_SRPD
#define E1000_IMS_ACK       E1000_ICR_ACK       /* Receive Ack frame */
#define E1000_IMS_MNG       E1000_ICR_MNG       /* Manageability event */
#define E1000_IMS_DOCK      E1000_ICR_DOCK      /* Dock/Undock */

/*  Transmit IPG Register
*  31     30 29                    20 19                     10 9                    0
*  +--------+------------------------+-------------------------+---------------------+
*  |Reserved|          IPGR2         |          IPGR1          |         IPGT        |
*  +--------+------------------------+-------------------------+---------------------+
*/
#define E1000_TIPG     0x00410  /* TX Inter-packet gap -RW */

/* Transmit Descriptor bit definitions */
/*
 *Transmit Command (TDESC.CMD) Layout
 *   7   6   5      4      3   2   1    0
 * +---+---+----+-------+----+---+----+---+
 * |IDE|VLE|DEXT|RSV RPS| RS |IC |IFCS|EOP|
 * +---+---+----+-------+----+---+----+---+
*/
#define E1000_TXD_DTYP_D     0x00100000 /* Data Descriptor */
#define E1000_TXD_DTYP_C     0x00000000 /* Context Descriptor */
#define E1000_TXD_CMD_EOP    0x01 /* End of Packet */
#define E1000_TXD_CMD_IFCS   0x02 /* Insert FCS (Ethernet CRC) */
#define E1000_TXD_CMD_IC     0x04 /* Insert Checksum */
#define E1000_TXD_CMD_RS     0x08 /* Report Status */
#define E1000_TXD_CMD_RPS    0x10 /* Report Packet Sent */
#define E1000_TXD_CMD_DEXT   0x20 /* Descriptor extension (0 = legacy) */
#define E1000_TXD_CMD_VLE    0x40 /* Add VLAN tag */
#define E1000_TXD_CMD_IDE    0x80 /* Enable Tidv register */
#define E1000_TXD_STAT_DD    0x00000001 /* Descriptor Done */
#define E1000_TXD_STAT_EC    0x00000002 /* Excess Collisions */
#define E1000_TXD_STAT_LC    0x00000004 /* Late Collisions */
#define E1000_TXD_STAT_TU    0x00000008 /* Transmit underrun */
#define E1000_TXD_CMD_TCP    0x01000000 /* TCP packet */
#define E1000_TXD_CMD_IP     0x02000000 /* IP packet */
#define E1000_TXD_CMD_TSE    0x04000000 /* TCP Seg enable */
#define E1000_TXD_STAT_TC    0x00000004 /* Tx Underrun */

/* Transmit Control */
/*  Transmit Control Register
*  31        26 25     22 21                 12 11                  4 3           0
*  +-----------+---------+----------------------+----------------------+------------+
*  | Reserved  |CNTL Bits|         COLD         |          CT          | CNTL Bits  |
*  +-----------+---------+----------------------+----------------------+------------+
*/
#define E1000_TCTL_RST    0x00000001    /* software reset */
#define E1000_TCTL_EN     0x00000002    /* enable tx */
#define E1000_TCTL_BCE    0x00000004    /* busy check enable */
#define E1000_TCTL_PSP    0x00000008    /* pad short packets */
#define E1000_TCTL_CT     0x00000ff0    /* collision threshold */
#define E1000_TCTL_COLD   0x003ff000    /* collision distance */
#define E1000_TCTL_SWXOFF 0x00400000    /* SW Xoff transmission */
#define E1000_TCTL_PBE    0x00800000    /* Packet Burst Enable */
#define E1000_TCTL_RTLC   0x01000000    /* Re-transmit on late collision */
#define E1000_TCTL_NRTU   0x02000000    /* No Re-transmit on underrun */
#define E1000_TCTL_MULR   0x10000000    /* Multiple request support */

/*
* Receive Descriptor 
*
*  63             48 47   40 39  32 31           16 15              0
*   +---------------------------------------------------------------+
* 0 |                         Buffer address                        |
*   +---------------+-------+--------+--------------+---------------+
* 8 |    Special    |Errors | Status |   Checksum   |    Length     |
*   +---------------+-------+--------+--------------+---------------+
*
*/
struct rx_desc {
    uint64_t buffer_addr; /* Address of the descriptor's data buffer */
    uint16_t length;     /* Length of data DMAed into data buffer */
    uint16_t csum;       /* Packet checksum */
    uint8_t status;      /* Descriptor status */
    uint8_t errors;      /* Descriptor Errors */
    uint16_t special;
}__attribute__((packed));

#define RX_RING_SIZE    128
#define RX_PACKET_SIZE  1518

/* Receive Descriptor bit definitions */
#define E1000_RXD_STAT_DD       0x01    /* Descriptor Done */
#define E1000_RXD_STAT_EOP      0x02    /* End of Packet */
#define E1000_RXD_STAT_IXSM     0x04    /* Ignore checksum */
#define E1000_RXD_STAT_VP       0x08    /* IEEE VLAN Packet */
#define E1000_RXD_STAT_UDPCS    0x10    /* UDP xsum caculated */
#define E1000_RXD_STAT_TCPCS    0x20    /* TCP xsum calculated */
#define E1000_RXD_STAT_IPCS     0x40    /* IP xsum calculated */
#define E1000_RXD_STAT_PIF      0x80    /* passed in-exact filter */
#define E1000_RXD_STAT_IPIDV    0x200   /* IP identification valid */
#define E1000_RXD_STAT_UDPV     0x400   /* Valid UDP checksum */
#define E1000_RXD_STAT_ACK      0x8000  /* ACK Packet indication */
#define E1000_RXD_ERR_CE        0x01    /* CRC Error */
#define E1000_RXD_ERR_SE        0x02    /* Symbol Error */
#define E1000_RXD_ERR_SEQ       0x04    /* Sequence Error */
#define E1000_RXD_ERR_CXE       0x10    /* Carrier Extension Error */
#define E1000_RXD_ERR_TCPE      0x20    /* TCP/UDP Checksum Error */
#define E1000_RXD_ERR_IPE       0x40    /* IP Checksum Error */
#define E1000_RXD_ERR_RXE       0x80    /* Rx Data Error */
#define E1000_RXD_SPC_VLAN_MASK 0x0FFF  /* VLAN ID is in lower 12 bits */
#define E1000_RXD_SPC_PRI_MASK  0xE000  /* Priority is in upper 3 bits */
#define E1000_RXD_SPC_PRI_SHIFT 13
#define E1000_RXD_SPC_CFI_MASK  0x1000  /* CFI is bit 12 */
#define E1000_RXD_SPC_CFI_SHIFT 12
 
 /* Receive Control */
#define E1000_RCTL_RST            0x00000001    /* Software reset */
#define E1000_RCTL_EN             0x00000002    /* enable */
#define E1000_RCTL_SBP            0x00000004    /* store bad packet */
#define E1000_RCTL_UPE            0x00000008    /* unicast promiscuous enable */
#define E1000_RCTL_MPE            0x00000010    /* multicast promiscuous enab */
#define E1000_RCTL_LPE            0x00000020    /* long packet enable */
#define E1000_RCTL_LBM_NO         0x00000000    /* no loopback mode */
#define E1000_RCTL_LBM_MAC        0x00000040    /* MAC loopback mode */
#define E1000_RCTL_LBM_SLP        0x00000080    /* serial link loopback mode */
#define E1000_RCTL_LBM_TCVR       0x000000C0    /* tcvr loopback mode */
#define E1000_RCTL_DTYP_MASK      0x00000C00    /* Descriptor type mask */
#define E1000_RCTL_DTYP_PS        0x00000400    /* Packet Split descriptor */
#define E1000_RCTL_RDMTS_HALF     0x00000000    /* rx desc min threshold size */
#define E1000_RCTL_RDMTS_QUAT     0x00000100    /* rx desc min threshold size */
#define E1000_RCTL_RDMTS_EIGTH    0x00000200    /* rx desc min threshold size */
 /* these buffer sizes are valid if E1000_RCTL_BSEX is 0 */
#define E1000_RCTL_SZ_2048        0x00000000    /* rx buffer size 2048 */
#define E1000_RCTL_SZ_1024        0x00010000    /* rx buffer size 1024 */
#define E1000_RCTL_SZ_512         0x00020000    /* rx buffer size 512 */
#define E1000_RCTL_SZ_256         0x00030000    /* rx buffer size 256 */

#define E1000_RCTL_BSEX           0x02000000    /* Buffer size extension */
#define E1000_RCTL_SECRC          0x04000000    /* Strip Ethernet CRC */

#endif  // SOL >= 6
