#ifndef LOGGER_H
#define LOGGER_H

#include <vector>
#include <string>
#include <chrono>
#include <ctime>
#include <functional>

using namespace std;

struct record
{
    std::chrono::system_clock::duration log_time;
    wstring message;
    enum type
    { 
        ERROR = 1, 
        WARNING = 2, 
        INFO = 3 
    } log_type;
};

class logger
{
private:
    vector <record> history;
    record error, warning, info, &last {error};
    vector <function<void (logger &)>> callbacks;
public:
    void set_error(wstring message, bool hist = true);
    void set_warning(wstring message, bool hist = true);    
    void set_info(wstring message, bool hist = true);

    record get_error () { return error; }
    record get_warning () { return warning; }    
    record get_info () { return info; }    

    const vector <record> & get_history() const;

    void register_callback(function<void(logger&)> func);

    void run_callbacks();
};

#endif