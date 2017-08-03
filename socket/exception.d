module wheel.socket.exception;

import std.exception;

class ConnectionException : Exception
{
    this(string msg) { super(msg, __FILE__, __LINE__); }
}