#include <iostream>
#include <bitset>
#include <memory>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <chrono>
#include <thread>
#include <unistd.h>
#include <iomanip>
#include <mutex>
#include <typeinfo>

#include "logger.h"

import scheduler;

class FooTask: public scheduler::Task {
    public:
        void exe() {
            logger::logger << logger::debug << "FooTask.exe()" << logger::endl;
            usleep(5);
        }

};

class FooTask1: public scheduler::Task {
    public:
        void exe() {
            logger::logger << logger::debug << "FooTask1.exe()" << logger::endl;
            sleep(1);
        }

};

int main() {
    logger::logger.setLogLevel(logger::debug);

    logger::logger << logger::info << "cpp scheduler test app" << logger::endl;
    
    scheduler::Scheduler sch( std::chrono::seconds(10));
    FooTask fooTask;
    FooTask1 fooTask1;

    sch.registerTask(&fooTask, 10, std::chrono::seconds(1));
    sch.registerTask(&fooTask1, 20, std::chrono::seconds(4));

    sch.mainloop();


    logger::logger << logger::info << "main end" << logger::endl;
    return 0;
}

