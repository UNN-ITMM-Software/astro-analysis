#include "logger.h"

void logger::set_error(wstring message, bool hist)
{
    error.log_time = std::chrono::system_clock::now().time_since_epoch();
    error.message = message;
    error.log_type = record::type::ERROR;
    if (hist) history.push_back(error);
    last = error;
    run_callbacks();
}

void logger::set_warning(wstring message, bool hist)
{
    warning.log_time = std::chrono::system_clock::now().time_since_epoch();
    warning.message = message;
    warning.log_type = record::type::WARNING;
    if (hist) history.push_back(warning);
    last = warning;
    run_callbacks();
}

void logger::set_info(wstring message, bool hist)
{
    info.log_time = std::chrono::system_clock::now().time_since_epoch();
    info.message = message;
    info.log_type = record::type::INFO;
    if (hist) history.push_back(info);
    last = info;
    run_callbacks();
}

const vector <record> & logger::get_history() const 
{
    return history;
}

void logger::register_callback(function<void(logger&)> func)
{
    callbacks.push_back(func);
}

void logger::run_callbacks()
{
    for (auto x : callbacks) x(*this);
}