module wheel.socket.connection;

import std.container;
import std.functional;
import std.socket;
import std.string;

import wheel.socket.exception;
import wheel.socket.extension;

private static auto _defaultCondition = () => true;

alias DList EventContainer;
alias void delegate(ref ubyte[]) EventDelegate;
alias EventList = EventContainer!EventDelegate;

void AddEvent(ref EventList l, in EventDelegate d)
{
    l.insertBack(d);
}

class Connection
{
private:
    immutable BUFLEN = 8192;
    Socket _socket;
    ubyte[] buffer;
    bool delegate() isActive;
protected:

public:
    this(Socket s, string name, bool delegate() isActive = _defaultCondition.toDelegate())
    {
        this._socket = s;
        this._socket.blocking = false;
        buffer = new ubyte[BUFLEN];
        this.isActive = isActive;
    }

    this(Socket s, bool delegate() isActive = _defaultCondition.toDelegate())
    {
        this._socket = s;
        this._socket.blocking = false;
        buffer = new ubyte[BUFLEN];
        this.isActive = isActive;
    }

    ~this()
    {
        _socket.destroy();
    }  
    
    auto beforeSendEvent = EventList();
    auto afterReceiveEvent = EventList();

    @property const(Socket) socket() { return cast(const Socket)(_socket); }
    @property const(string) remoteAddress() { return _socket.remoteAddress.toAddrString(); }

    const(ubyte)[] pull()
    {
        auto a = _socket.receiveAsync(buffer, isActive);
        if(a > 0)
        {
            auto b = buffer[0..a];
            foreach(fn; afterReceiveEvent)
                fn(b);
            return b;
        }     
        return null;
    }

    bool push(in ubyte[] message)
    {
        auto m = message.dup;
        foreach(fn; beforeSendEvent)
            fn(m);           
        auto i = _socket.sendAsync(m, isActive);
        return i > 0;
    }

    const(ubyte)[] pullExc()
    {
        auto a = pull();
        if(a == null)
            throw new ConnectionException("Failed to receive data, GetLastError: %d".format(GetLastError()));
        return a;
    }

    void pushExc(in ubyte[] message)
    {
        auto i = push(message);
        if(!i)
            throw new ConnectionException("Failed to send data, GetLastError: %d".format(GetLastError()));
    }

    private bool pushArray(T)(in T[] message)
    {
        return push((cast(ubyte*)(message.ptr))[0..(message.length * T.sizeof)]);
    }

    private void pushArrayExc(T)(in T[] message)
    {
        pushExc((cast(ubyte*)(message.ptr))[0..(message.length * T.sizeof)]);
    }

    void pushExc(T)(in T message)
    {
        import std.traits : isArray;
        static if(isArray!(T))
            pushArrayExc(message);
        else
            pushExc((cast(ubyte*)(&message))[0..T.sizeof]);
    }

    bool push(T)(in T message)
    {
        import std.traits : isArray;
        static if(isArray!(T))
            return pushArray(message);
        else
            return push((cast(ubyte*)(&message))[0..T.sizeof]);
    }
}