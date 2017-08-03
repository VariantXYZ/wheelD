module wheel.server.server;

import std.socket;
import std.string;

import wheel.server.base;
import wheel.socket;

class BaseServer : Basewheel
{
private:
    void _listen(const string ip, const ushort port, void delegate(Connection s) fn)
    {
        auto address = new InternetAddress(cast(const char[])ip, port);
        auto listener = new TcpSocket();
        log("Listening on %s:%u".format(ip, port));
        listener.blocking = false;
        listener.bind(address);
        listener.listen(1);
        while(isActive)
        {
            auto s = acceptAsync(listener);
            if(s && isActive) { s.blocking = false; schedule( { fn(new Connection(s, &isActive)); } ); }
            //TODO: The isActive check here seems unnecessary, should just make accept return null if condition is invalid
        }
        listener.shutdown(SocketShutdown.BOTH);
        listener.destroy();
    }

    void _comm(const string ip, const ushort port, void delegate(Connection s) fn)
    {
        auto address = new InternetAddress(cast(const char[])ip, port);
        auto c = new TcpSocket();
        log("Connecting to %s:%u".format(ip, port));
        c.blocking = false;
        connectAsync(c, address);
        log("Connected to %s:%u".format(ip, port));
        if(isActive) 
        {
            fn(new Connection(c, &isActive));
        } 
    }

protected:
    this(string name)
    {
        super(name);
    }

    ~this()
    {
    }

    ptrdiff_t receiveAsync(scope Socket socket, scope void[] buffer)
    {
        return socket.receiveAsync(buffer, &isActive);
    }

    ptrdiff_t sendAsync(scope Socket socket, scope const(void)[] buffer)
    {
        return socket.sendAsync(buffer, &isActive);
    }

    Socket acceptAsync(scope Socket socket)
    {
        return socket.acceptAsync(&isActive);
    }

    void connectAsync(scope Socket socket, scope Address to)
    {
        socket.connectAsync(to, &isActive);
    }

public:
    ///While active, listen on a specific ip and port for a TCP connection and pass incoming connections to a delegate
    void listen(const string ip, const ushort port, void delegate(Connection s) fn)
    {
        schedule({ this._listen(ip, port, fn); });
    }

    //Initiate a connection with a specific IP and port, and then execute a delegate
    void initComm(const string ip, const ushort port, void delegate(Connection s) fn)
    {
        schedule({ this._comm(ip, port, fn); });
    }

}
