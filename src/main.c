//AXI GPIO driver
#include "xgpio.h"
//send data over UART
#include "xil_printf.h"

//information about AXI peripherals
#include "xparameters.h"

#include "xuartlite.h"
#include "xuartlite_l.h"

#define UARTLITE_DEVICE_ID      XPAR_UARTLITE_0_DEVICE_ID

#define INIT                 0b101010 << 26
#define START                0b000001 << 26
#define RESET                0b000010 << 26
#define MODE_GET             0b001000 << 26
#define MODE_SET_CONT        0b001001 << 26
#define MODE_SET_STEP        0b001010 << 26
#define STEP                 0b100000 << 26
#define GOT_DATA             0b100100 << 26
#define LOAD_INSTR_LSB       0b000100 << 26
#define LOAD_INSTR_MSB       0b000101 << 26
#define REQ                  0b000011 << 26
#define REQ_MEM_DATA         0b0000110000000001 << 16
#define REQ_MEM_INSTR        0b0000110000000010 << 16
#define REQ_REG              0b0000110000000100 << 16
#define REQ_REG_PC           0b0000110000000101 << 16
#define REQ_LATCH_FETCH_DATA 0b0000110000001000 << 16
#define REQ_LATCH_FETCH_CTRL 0b0000110000001001 << 16
#define REQ_LATCH_DECO_DATA  0b0000110000010000 << 16
#define REQ_LATCH_DECO_CTRL  0b0000110000010001 << 16
#define REQ_LATCH_EXEC_DATA  0b0000110000100000 << 16
#define REQ_LATCH_EXEC_CTRL  0b0000110000100001 << 16
#define REQ_LATCH_MEM_DATA   0b0000110001000000 << 16
#define REQ_LATCH_MEM_CTRL   0b0000110001000001 << 16

int send_word(XUartLite *UartLite, u32 *buff, size_t buff_size);
int send_data(XUartLite *UartLite, u32 *buff, size_t buff_size);
int recv_word(XUartLite *UartLite, u32 *buff, size_t buff_size);
void send(u32 frame, XGpio* gpio, int id);
size_t req(u32 frame, XGpio* gpio, int id_send, int id_recv, u32* buffer, size_t buffer_size);
int main()
{

        XGpio gpio;
        u32 recv_msg = 0, recv_data = 0;
        u32 latch_buffer[3];

        XUartLite UartLite;

        XUartLite_Initialize(&UartLite, UARTLITE_DEVICE_ID);
        XUartLite_ResetFifos(&UartLite);

        while(recv_msg != INIT){
                recv_word(&UartLite, &recv_msg, sizeof(recv_msg));
        }
        xil_printf("Microblaze ON\n");

        xil_printf("Inicializado GPIO\n");
        XGpio_Initialize(&gpio, 0);
        xil_printf("GPIO inicializado\n");

        xil_printf("Configurando GPIO\n");
        XGpio_SetDataDirection(&gpio, 2, 0x00000000);
        XGpio_SetDataDirection(&gpio, 1, 0xFFFFFFFF);
        xil_printf("GPIO configurado\n\n");

        while(1){
                recv_word(&UartLite, &recv_msg, sizeof(recv_msg));
                switch(recv_msg & 0xFC000000){
                case START:
                        send(START, &gpio, 2);
                        break;
                case RESET:
                        send(RESET, &gpio, 2);
                        break;
                case MODE_GET:
                        send(MODE_GET, &gpio, 2);
                        recv_data = XGpio_DiscreteRead(&gpio, 1);
                        send_data(&UartLite, &recv_data, sizeof(recv_data));
                        break;
                case MODE_SET_CONT:
                        send(MODE_SET_CONT, &gpio, 2);
                        break;
                case MODE_SET_STEP:
                        send(MODE_SET_STEP, &gpio, 2);
                        break;
                case STEP:
                        send(STEP, &gpio, 2);
                        break;
                case LOAD_INSTR_LSB:
                        send(recv_msg, &gpio, 2);
                        break;
                case LOAD_INSTR_MSB:
                        send(recv_msg, &gpio, 2);
                        break;
                case REQ:
                        switch(recv_msg & 0xFFFF0000){
                        case REQ_MEM_DATA:
                                req(recv_msg, &gpio, 2, 1, &recv_data, sizeof(recv_data));
                                send_data(&UartLite, &recv_data, sizeof(recv_data));
                                break;
                        case REQ_MEM_INSTR:
                                req(recv_msg, &gpio, 2, 1, &recv_data, sizeof(recv_data));
                                send_data(&UartLite, &recv_data, sizeof(recv_data));
                                break;
                        case REQ_REG:
                                req(recv_msg, &gpio, 2, 1, &recv_data, sizeof(recv_data));
                                send_data(&UartLite, &recv_data, sizeof(recv_data));
                                break;
                        case REQ_REG_PC:
                                xil_printf("NONO");
                                break;
                        case REQ_LATCH_FETCH_DATA:
                                req(recv_msg, &gpio, 2, 1, &latch_buffer[0], sizeof(latch_buffer));
                                send_data(&UartLite, &latch_buffer[0], sizeof(latch_buffer[0]));
                                break;
                        case REQ_LATCH_FETCH_CTRL:
                                req(recv_msg, &gpio, 2, 1, &latch_buffer[0], sizeof(latch_buffer));
                                send_data(&UartLite, &latch_buffer[0], 2*sizeof(latch_buffer[0]));
                                break;
                        case REQ_LATCH_DECO_DATA:
                                req(recv_msg, &gpio, 2, 1, &latch_buffer[0], sizeof(latch_buffer));
                                send_data(&UartLite, &latch_buffer[0], 3*sizeof(latch_buffer[0]));
                                break;
                        case REQ_LATCH_DECO_CTRL:
                                req(recv_msg, &gpio, 2, 1, &latch_buffer[0], sizeof(latch_buffer));
                                send_data(&UartLite, &latch_buffer[0], 2*sizeof(latch_buffer[0]));
                                break;
                        case REQ_LATCH_EXEC_DATA:
                                req(recv_msg, &gpio, 2, 1, &latch_buffer[0], sizeof(latch_buffer));
                                send_data(&UartLite, &latch_buffer[0], 2*sizeof(latch_buffer[0]));
                                break;
                        case REQ_LATCH_EXEC_CTRL:
                                req(recv_msg, &gpio, 2, 1, &latch_buffer[0], sizeof(latch_buffer));
                                send_data(&UartLite, &latch_buffer[0], 2*sizeof(latch_buffer[0]));
                                break;
                        case REQ_LATCH_MEM_DATA:
                                req(recv_msg, &gpio, 2, 1, &latch_buffer[0], sizeof(latch_buffer));
                                send_data(&UartLite, &latch_buffer[0], 2*sizeof(latch_buffer[0]));
                                break;
                        case REQ_LATCH_MEM_CTRL:
                                req(recv_msg, &gpio, 2, 1, &latch_buffer[0], sizeof(latch_buffer));
                                send_data(&UartLite, &latch_buffer[0], 2*sizeof(latch_buffer[0]));
                                break;
                        }
                }
        }

        /* /\* xil_printf("Reseteando MIPS\n"); *\/ */
        /* /\* send_data = 0x08000000; *\/ */
        /* /\* send(send_data, &gpio, 2); *\/ */

        /* /\* xil_printf("Obteniendo modo\n"); *\/ */
        /* /\* send_data = 0x20000000; *\/ */
        /* /\* send(send_data, &gpio, 2); *\/ */
        /* /\* recv_data = XGpio_DiscreteRead(&gpio, 1); *\/ */
        /* /\* xil_printf("Recv: %08x\n", recv_data); *\/ */

        /* /\* xil_printf("Seteando modo\n"); *\/ */
        /* /\* send_data = 0x28000000; *\/ */
        /* /\* send(send_data, &gpio, 2); *\/ */

        /* xil_printf("Obteniendo modo\n"); */
        /* send_data = 0x20000000; */
        /* send(send_data, &gpio, 2); */
        /* recv_data = XGpio_DiscreteRead(&gpio, 1); */
        /* xil_printf("Recv: %08x\n", recv_data); */

        /* xil_printf("Req MEM INSTR\n"); */
        /* frame = 0x0C020000; */
        /* for(u32 i = 0; i < 15; i++){ */
        /*         send_data = frame + i; */
        /*         req(send_data, &gpio, 2, 1, &recv_data, sizeof(send_data)); */
        /*         xil_printf("Recv in pos %d: %08x\n", i, recv_data); */
        /* } */


        /* xil_printf("Iniciando MIPS\n"); */
        /* send_data = 0x04000000; */
        /* send(send_data, &gpio, 2); */


        /* u32 latch_buffer[2]; */
        /* for(int i = 0; i < 15; i++){ */
        /*         xil_printf("Req LATCH CTRL\n"); */
        /*         send_data = 0x0C090000; */
        /*         req(send_data, &gpio, 2, 1, &latch_buffer[0], sizeof(latch_buffer)); */
        /*         xil_printf("Recv %d: %08x\n", 0, latch_buffer[0]); */
        /*         xil_printf("Recv %d: %08x\n", 1, latch_buffer[1]); */

        /*         send_data = 0x0C010000; */
        /*         req(send_data, &gpio, 2, 1, &recv_data, sizeof(u32)); */
        /*         xil_printf("Recv in pos %d: %08x\n", 0, recv_data); */

        /*         send_data = 0x0C040000 + 0xB; */
        /*         req(send_data, &gpio, 2, 1, &recv_data, sizeof(u32)); */
        /*         xil_printf("Recv in REG : %08x\n", recv_data); */

        /*         xil_printf("STEP\n"); */
        /*         send_data = 0x80000000; */
        /*         send(send_data, &gpio, 2); */
        /* } */

        /* xil_printf("Req MEM DATA\n"); */
        /* frame = 0x0C010000; */
        /* for(u32 i = 0; i < 20; i++){ */
        /*         send_data = frame + i; */
        /*         req(send_data, &gpio, 2, 1, &recv_data, sizeof(u32)); */
        /*         xil_printf("Recv in pos %d: %08x\n", i, recv_data); */
        /* } */


        /* xil_printf("Finish\n"); */
        /* while (1); */
}

void send(u32 frame, XGpio* gpio, int id){
        XGpio_DiscreteWrite(gpio, id, frame);
        frame = frame | (1 << 25);
        XGpio_DiscreteWrite(gpio, id, frame);
}

int recv_word(XUartLite *UartLite, u32 *buff, size_t buff_size){
        int ReceivedCount = 0;
        while (ReceivedCount < buff_size) {
                ReceivedCount += XUartLite_Recv(UartLite,
                                                ((u8*)buff) + ReceivedCount,
                                                buff_size - ReceivedCount);
        }
        return ReceivedCount;
}

int send_data(XUartLite *UartLite, u32 *buff, size_t buff_size){
        u32 header = GOT_DATA;
        send_word(UartLite, &header, sizeof(header));
        send_word(UartLite, (u32*)&buff_size, 1);
        send_word(UartLite, buff, buff_size);
        return sizeof(GOT_DATA) + 1 + buff_size;
}

int send_word(XUartLite *UartLite, u32 *buff, size_t buff_size){
        int SentCount = 0;
        while (SentCount < buff_size) {
                SentCount += XUartLite_Send(UartLite,
                                                ((u8*)buff) + SentCount,
                                                buff_size - SentCount);
        }
        return SentCount;
}

size_t req(u32 frame, XGpio* gpio, int id_send, int id_recv, u32* buffer, size_t buffer_size){
        u32 got_data = 0x90000000;
        u32 gib_data = 0x94000000;
        u32 ok = 0x0C000000;
        u32 nok = 0x08000000;
        u32 recv;
        u8 NOK_RECV = 0;

        size_t i = 0;
        size_t bufsize = buffer_size/4;

        send(frame, gpio, id_send);
        for (i = 0; (i < bufsize) & !NOK_RECV; i++){
                send(got_data, gpio, id_send);;

                while(1){
                        recv = XGpio_DiscreteRead(gpio, id_recv) & 0xFC000000;
                        if(recv == ok){
                                send(gib_data, gpio, id_send);
                                buffer[i] = XGpio_DiscreteRead(gpio, id_recv);
                                break;
                        }else if(recv == nok){
                                NOK_RECV = 1;
                                break;
                        }else{
                                continue;
                        }

                }
        }
        return i*4;
}
