#include <cstdarg>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>

#include "ic_data/ic_input_data.h"
#include "ic_data/ic_model_data.h"
#include "ic_data/ic_model_settings.h"
#include "ic_data/ic_output_data_ref.h"
#include "tensorflow/lite/micro/tflite_bridge/micro_error_reporter.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/micro/micro_mutable_op_resolver.h"
#include "tensorflow/lite/schema/schema_generated.h"

constexpr size_t tensor_arena_size = 256 * 1024;
alignas(16) uint8_t tensor_arena[tensor_arena_size];

#if defined(USE_VEXT)
    static volatile long *const uart_data   = (volatile long *const) 0xFF000000;
    static volatile long *const uart_status = (volatile long *const) 0xFF000004;

    void uart_putc(char c)
    {
        // wait until transmitter ready:
        while (((*uart_status) & 1))
            ;
        *uart_data = c;
    }

    char uart_getc(void)
    {
        int data;
        // wait until a character was received:
        while ((data = *uart_data) < 0)
            ;
        return data;
    }

    void uart_write(int n, const char *buf)
    {
        for ( ; n > 0; n--)
            uart_putc(*(buf++));
    }

    void uart_read(int n, char *buf)
    {
        for ( ; n > 0; n--)
            *(buf++) = uart_getc();
    }

    int uart_puts(const char *str)
    {
        for ( ; *str != 0; str++)
            uart_putc(*str);

        return 1;
    }

    void uart_gets(char *buf, int size)
    {
        char c = 0;
        for ( ; size > 1 && c != '\n' && c != '\r'; size--)
            *(buf++) = c = uart_getc();
        *buf = 0;
    }

    int print_unsigned(unsigned value, int width, char pad)
    {
        char buffer[20];
        int charCount = 0;

        do
        {
        char c = '0' + (value % 10);
        value = value / 10;
        buffer[charCount++] = c;
        }
        while (value);

        for (int i = charCount; i < width; ++i)
            uart_putc(pad);

        char* p = buffer + charCount - 1;
        for (int i = 0; i < charCount; ++i)
            uart_putc(*p--);

        return charCount;
    }


    int print_decimal(int value, int width, char pad)
    {
        char buffer[20];
        int charCount = 0;

        unsigned neg = value < 0;
        if (neg)
            {
            value = -value;
            uart_putc('-');
            width--;
            }

        do
            {
            char c = '0' + (value % 10);
            value = value / 10;
            buffer[charCount++] = c;
            }
        while (value);

        for (int i = charCount; i < width; ++i)
            uart_putc(pad);

        char* p = buffer + charCount - 1;
        for (int i = 0; i < charCount; ++i)
            uart_putc(*p--);

        if (neg)
            charCount++;

        return charCount; 
    }


    int print_int(int value, int width, int pad, int base)
    {
        if (base == 10)
            return print_decimal(value, width, pad);

        char buffer[20];
        int charCount = 0;

        unsigned uu = value;

        if (base == 8)
            {
            do
                {
                char c = '0' + (uu & 7);
                buffer[charCount++] = c;
                uu >>= 3;
                }
            while (uu);
            }
        else if (base == 16)
            {
            do
                {
                int digit = uu & 0xf;
                char c = digit < 10 ? '0' + digit : 'a' + digit - 10;
                buffer[charCount++] = c;
                uu >>= 4;
                }
            while (uu);
            }
        else
            return -1;

        char* p = buffer + charCount - 1;
        for (unsigned i = 0; i < charCount; ++i)
            uart_putc(*p--);

        return charCount;
    }

    int printf_impl(const char* format, va_list ap)
    {
        int count = 0;  // Printed character count

        for (const char* fp = format; *fp; fp++)
            {
            char pad = ' ';
            int width = 0;  // Field width

            if (*fp != '%')
                {
                uart_putc(*fp);
                ++count;
                continue;
                }

            ++fp;  // Skip %

            if (*fp == 0)
                break;

            if (*fp == '%')
                {
                uart_putc('%');
                continue;
                }

            while (*fp == '0')
                {
                pad = '0';
                fp++;  // Pad zero not yet implented.
                }

            if (*fp == '-')
                {
                fp++;  // Pad right not yet implemented.
                }

            if (*fp == '*')
                {
                //int outWidth = va_arg(ap, int);
                fp++;  // Width not yet implemented.
                }
            else if (*fp >= '0' && *fp <= '9')
                {    // Width not yet implemented.
                while (*fp >= '0' && *fp <= '9')
                    width = width * 10 + (*fp++ - '0');
                }

            switch (*fp)
                {
                case 'd':
                count += print_decimal(va_arg(ap, int), width, pad);
                break;

                case 'u':
                count += print_unsigned((unsigned) va_arg(ap, unsigned), width, pad);
                break;

                case 'x':
                case 'X':
                count += print_int(va_arg(ap, int), width, pad, 16);
                break;

                case 'o':
                count += print_int(va_arg(ap, int), width, pad, 8);
                break;

                case 'c':
                uart_putc(va_arg(ap, int));
                ++count;
                break;

                case 's':
                count += uart_puts(va_arg(ap, char*));
                break;
        /*
                case 'g':
                count += whisperPrintDoubleG(va_arg(ap, double));
                break;
                case 'f':
                count += whisperPrintDoubleF(va_arg(ap, double));
        */
                }
        }

    return count;
    }

    int uart_printf(const char* format, ...)
    {
    va_list ap;

    va_start(ap, format);
    int code = printf_impl(format, ap);
    va_end(ap);

    return code;
    }
#endif

int run_test()
{
    tflite::MicroErrorReporter micro_error_reporter;
    tflite::ErrorReporter *error_reporter = &micro_error_reporter;

    const tflite::Model *model = tflite::GetModel(ic_model_data);

    static tflite::MicroMutableOpResolver<7> resolver;
    resolver.AddFullyConnected();
    resolver.AddConv2D();
    resolver.AddAveragePool2D();
    resolver.AddReshape();
    resolver.AddSoftmax();
    resolver.AddAdd();

    tflite::MicroInterpreter interpreter(model, resolver, tensor_arena, tensor_arena_size);

    if (interpreter.AllocateTensors() != kTfLiteOk)
    {
        TF_LITE_REPORT_ERROR(error_reporter, "ERROR: In AllocateTensors().");
        return -1;
    }

    for (size_t i = 0; i < ic_data_sample_cnt; i++)
    {
        // Plain memcpy does not suffice as we need to add 128 to every value of the
        // input tensor
        for (size_t j = 0; j < ic_input_data_len[i]; j++)
        {
            interpreter.input(0)->data.int8[j] = (int8_t)ic_input_data[i][j] + 128;
        }

        if (interpreter.Invoke() != kTfLiteOk)
        {
            TF_LITE_REPORT_ERROR(error_reporter, "ERROR: In Invoke().");
            return -1;
        }

        int8_t top_index = 0;
        for (size_t j = 0; j < ic_model_label_cnt; j++)
        {
            if (interpreter.output(0)->data.int8[j] > interpreter.output(0)->data.int8[top_index])
            {
                top_index = j;
            }
        }

        if (top_index != ic_output_data_ref[i])
        {
            #if defined(SPIKE)
                printf("ERROR\n");
            #elif defined(USE_VEXT)
                uart_printf("ERROR\n");
            #else
                puts("ERROR\n");
            #endif

            return -1;
        }
        else
        {
            #if defined(SPIKE)
                printf("PASS\n");
            #elif defined(USE_VEXT)
                uart_printf("PASS\n");
            #else
                puts("PASS\n");
            #endif
        }
    }

    return 0;
}

void pcount_reset() {
__asm__ volatile(
    "csrw minstret,       x0\n"
    "csrw mcycle,         x0\n"
    "csrw mhpmcounter3,   x0\n"
    "csrw mhpmcounter4,   x0\n"
    "csrw mhpmcounter5,   x0\n"
    "csrw mhpmcounter6,   x0\n"
    "csrw mhpmcounter7,   x0\n"
    "csrw mhpmcounter8,   x0\n"
    "csrw mhpmcounter9,   x0\n"
    "csrw mhpmcounter10,  x0\n"
    "csrw mhpmcounter11,  x0\n"
    "csrw mhpmcounter12,  x0\n"
    "csrw mhpmcounter13,  x0\n"
    "csrw mhpmcounter14,  x0\n"
    "csrw mhpmcounter15,  x0\n"
    "csrw mhpmcounter16,  x0\n"
    "csrw mhpmcounter17,  x0\n"
    "csrw mhpmcounter18,  x0\n"
    "csrw mhpmcounter19,  x0\n"
    "csrw mhpmcounter20,  x0\n"
    "csrw mhpmcounter21,  x0\n"
    "csrw mhpmcounter22,  x0\n"
    "csrw mhpmcounter23,  x0\n"
    "csrw mhpmcounter24,  x0\n"
    "csrw mhpmcounter25,  x0\n"
    "csrw mhpmcounter26,  x0\n"
    "csrw mhpmcounter27,  x0\n"
    "csrw mhpmcounter28,  x0\n"
    "csrw mhpmcounter29,  x0\n"
    "csrw mhpmcounter30,  x0\n"
    "csrw mhpmcounter31,  x0\n"
    "csrw minstreth,      x0\n"
    "csrw mcycleh,        x0\n"
    "csrw mhpmcounter3h,  x0\n"
    "csrw mhpmcounter4h,  x0\n"
    "csrw mhpmcounter5h,  x0\n"
    "csrw mhpmcounter6h,  x0\n"
    "csrw mhpmcounter7h,  x0\n"
    "csrw mhpmcounter8h,  x0\n"
    "csrw mhpmcounter9h,  x0\n"
    "csrw mhpmcounter10h, x0\n"
    "csrw mhpmcounter11h, x0\n"
    "csrw mhpmcounter12h, x0\n"
    "csrw mhpmcounter13h, x0\n"
    "csrw mhpmcounter14h, x0\n"
    "csrw mhpmcounter15h, x0\n"
    "csrw mhpmcounter16h, x0\n"
    "csrw mhpmcounter17h, x0\n"
    "csrw mhpmcounter18h, x0\n"
    "csrw mhpmcounter19h, x0\n"
    "csrw mhpmcounter20h, x0\n"
    "csrw mhpmcounter21h, x0\n"
    "csrw mhpmcounter22h, x0\n"
    "csrw mhpmcounter23h, x0\n"
    "csrw mhpmcounter24h, x0\n"
    "csrw mhpmcounter25h, x0\n"
    "csrw mhpmcounter26h, x0\n"
    "csrw mhpmcounter27h, x0\n"
    "csrw mhpmcounter28h, x0\n"
    "csrw mhpmcounter29h, x0\n"
    "csrw mhpmcounter30h, x0\n"
    "csrw mhpmcounter31h, x0\n");
}

#if defined(SPIKE)
    unsigned long read_cycles(void) 
    {
        unsigned long cycles;
        asm volatile ("rdcycle %0" : "=r" (cycles));
        return cycles;
    }

    int main(int argc, char *argv[])
    {
        printf("Starting test!\n");
        printf("%ld\n", read_cycles());
        int ret = run_test();
        printf("%ld\n", read_cycles());
        if (ret != 0)
        {
            printf("Test Failed!\n");
            // Make sure RISC-V simulators detect a failed test
    #if defined(__riscv) || defined(__riscv__)
            __asm__ volatile("unimp");
    #endif
        }
        else
        {
            printf("Test Success!\n");
        }

        return ret;
    }
#elif defined(USE_VEXT)
    unsigned int get_pcount() {
        uint32_t result;
        __asm__ volatile("csrr %0, mcycle;" : "=r"(result));
        return result;
    }

    unsigned int get_icount() {
        uint32_t result;
        __asm__ volatile("csrr %0, minstret;" : "=r"(result));
        return result;
    }

    int main(int argc, char *argv[])
    {
        __asm__ volatile("csrw  0x320, %0\n" : : "r"(0xFFFFFFFF));
        pcount_reset();
        uart_printf("Cycles: %x\n", get_pcount());
        uart_printf("Instructions: %x\n", get_icount());
        uart_printf("Starting test!\n");
        __asm__ volatile("csrw  0x320, %0\n" : : "r"(0x0));
        int ret = run_test();
        __asm__ volatile("csrw  0x320, %0\n" : : "r"(0xFFFFFFFF));
        uart_printf("Cycles: %x\n", get_pcount());
        uart_printf("Instructions: %x\n", get_icount());
        if (ret != 0)
        {
            uart_printf("Test Failed!\n");
            // Make sure RISC-V simulators detect a failed test
    #if defined(__riscv) || defined(__riscv__)
            __asm__ volatile("unimp");
    #endif
        }
        else
        {
            uart_printf("Test Success!\n");
        }

        return ret;
    }
#else
    int main(int argc, char *argv[])
    {
        __asm__ volatile("csrw  0x320, %0\n" : : "r"(0xFFFFFFFF));
        pcount_reset();
        puts("Starting test!\n");
        __asm__ volatile("csrw  0x320, %0\n" : : "r"(0x0));
        int ret = run_test();
        __asm__ volatile("csrw  0x320, %0\n" : : "r"(0xFFFFFFFF));
        if (ret != 0)
        {
            puts("Test Failed!\n");
            // Make sure RISC-V simulators detect a failed test
    #if defined(__riscv) || defined(__riscv__)
            __asm__ volatile("unimp");
    #endif
        }
        else
        {
            puts("Test Success!\n");
        }

        return ret;
    }
#endif