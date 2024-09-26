#include <bitset>
#include <chrono>
#include <iomanip>
#include <iostream>
#include <memory>
#include <mutex>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <thread>
#include <typeinfo>
#include <unistd.h>

#include "logger.h"

import scheduler;

class FooTask : public scheduler::Task {
   public:
    FooTask(unsigned int __sleep_time = 0) : __sleep_time(__sleep_time) {
    }
    void exe() {
        logger::logger << logger::debug << "FooTask.exe(): got to sleep " << __sleep_time << "s." << logger::endl;
        sleep(__sleep_time);
    }

   private:
    unsigned int __sleep_time;
};

int main() {
    logger::logger.setLogLevel(logger::debug);

    logger::logger << logger::info << "cpp scheduler test app" << logger::endl;

    scheduler::Scheduler sch(std::chrono::seconds(10));
    FooTask              fooTask(5);
    FooTask              fooTask1(10);

    sch.registerTask(&fooTask, 10, std::chrono::seconds(1));
    sch.registerTask(&fooTask1, 20, std::chrono::seconds(4));

    sch.mainloop();

    logger::logger << logger::info << "main end" << logger::endl;
    return 0;
}
