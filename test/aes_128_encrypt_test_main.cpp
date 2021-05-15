#include "../build/Vaes_128_encrypt.h"
#include "verilated.h"

int main(int argc, char **argv, char **env)
{
    VerilatedContext *contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    Vaes_128_encrypt *top = new Vaes_128_encrypt{contextp};
    while (!contextp->gotFinish())
    {
        top->clk_in = !top->clk_in;
        top->eval();
    }
    delete top;
    delete contextp;
    return 0;
}