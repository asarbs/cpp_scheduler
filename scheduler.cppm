module;

#include <iostream>
#include <chrono>
#include "logger.h"

export module scheduler;



namespace scheduler {
    export class Scheduler;
    export class Task;

    class Task{
        public:
            virtual void exe() = 0;
        protected:
        private:
    };


    class Scheduler {
        public:
            Scheduler(){

            }

            void registerTask(Task* task, std::chrono::microseconds period) {
                __tasks.push_back(TaskConfiguration(task, period));
            }

            void mainloop(){
                uint64_t x = 0;
                while(true) {
                    // logger::logger << logger::debug << "x=" << x << logger::endl;
                    const std::chrono::time_point<std::chrono::system_clock> now = std::chrono::system_clock::now();
                    for(TaskConfiguration& task: __tasks) {
                        if(now > task.__next_exe_time) {
                            task.__task->exe();
                            task.__next_exe_time = now + task.__period;
                        }
                    }
                    x++;
                }
            }

        protected:

        private:
            struct TaskConfiguration {
                    TaskConfiguration(Task* task, const std::chrono::microseconds period): __task(task), __period(period), __next_exe_time(std::chrono::system_clock::now()) {

                    }

                    Task* __task;
                    const std::chrono::microseconds __period;
                    std::chrono::time_point<std::chrono::system_clock> __next_exe_time;
            };

            std::vector<TaskConfiguration> __tasks;

    };

};
