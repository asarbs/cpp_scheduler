module;

#include <iostream>
#include <chrono>
#include <map>
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

            void registerTask(Task* task, uint32_t priority, std::chrono::microseconds period) {
                __tasks[priority] = TaskConfiguration(task, period);
            }

            void mainloop(){
                uint64_t x = 0;
                bool exe = false;
                while(true) {
                    
                    const std::chrono::time_point<std::chrono::system_clock> now = std::chrono::system_clock::now();
                    auto start = std::chrono::high_resolution_clock::now();

                    for(std::map<uint32_t, TaskConfiguration>::iterator itr = __tasks.begin(); itr != __tasks.end(); itr++ ) {
                        
                        TaskConfiguration* task = &itr->second;
                        if(now > task->__next_exe_time) {

                            task->__task->exe();
                            task->__next_exe_time = now + task->__period;
                            exe = true;
                        }
                    }
                    auto end = std::chrono::high_resolution_clock::now();

                    if(exe) {
                        std::chrono::duration<double> duration = end - start;
                        logger::logger << logger::info << "Czas wykonania funkcji:" << duration.count() << " sekund" << logger::endl;
                        exe = false;
                    }
                    x++;
                }
            }

        protected:

        private:
            struct TaskConfiguration {
                    TaskConfiguration(): __task(NULL), __period(0), __next_exe_time(std::chrono::system_clock::now()) {

                    }
                    TaskConfiguration(Task* task, const std::chrono::microseconds period): __task(task), __period(period), __next_exe_time(std::chrono::system_clock::now()) {

                    }
                    TaskConfiguration& operator=(const TaskConfiguration& other) {
                        this->__task = other.__task;
                        this->__period = other.__period;
                        this->__next_exe_time = other.__next_exe_time;
                        return *this;
                    }

                    Task* __task;
                    std::chrono::microseconds __period;
                    std::chrono::time_point<std::chrono::system_clock> __next_exe_time;
            };

            std::map<uint32_t, TaskConfiguration> __tasks;

    };

};
