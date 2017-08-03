module wheel.socket.extension;

import core.time;

import std.exception;
import std.functional;
import std.socket;

import wheel.async;

private static auto _defaultCondition = () => true;

version(Windows)
{
    private int _lasterr() nothrow @nogc
    {
        return WSAGetLastError();
    }

    private const int _SOCKET_ERROR = SOCKET_ERROR;
}
else version(Posix)
{
    private import core.sys.posix.sys.socket;
    private import core.stdc.errno;

    private int _lasterr() nothrow @nogc
    {
        return errno;
    }
    private const int _SOCKET_ERROR = -1;
}
else
{
    static assert(0);     // No socket support yet.
}

private bool connect_(scope Socket s, scope Address to)
{
    auto c = .connect(s.handle(), to.name, to.nameLen);

    version(Windows)
    {
        return (c != _SOCKET_ERROR || _lasterr() == WSAEISCONN);
    }
    else version(Posix)
    {
        return !(_SOCKET_ERROR == c);
    }
    else
    {
        static assert(0);
    }
}

int GetLastError()
{
    return _lasterr();
}

void connectAsync(scope Socket socket, scope Address to, bool delegate() condition = _defaultCondition.toDelegate() )
{
    bool delegate(bool, Socket, Address) fn = (bool t, Socket s, Address a) { return s.connect_(a); };
    bool delegate(bool, Socket, Address) c = (bool t, Socket s, Address a) { return (s && s.isAlive && !t && condition()); };

    async!(false, bool, Socket, Address)(fn, c, false, socket, to);
    return;
}

ptrdiff_t receiveAsync(scope Socket socket, scope void[] buffer, bool delegate() condition = _defaultCondition.toDelegate() )
{
    ptrdiff_t delegate(ptrdiff_t t, Socket s, void[] b) fn = (ptrdiff_t t, Socket s, void[] b) { if(s && s.isAlive) return s.receive(b); else return Socket.ERROR; };
    bool delegate(ptrdiff_t t, Socket s, void[] b) c = (ptrdiff_t t, Socket s, void[] b) { return ((t == Socket.ERROR && wouldHaveBlocked())) && condition(); };

    return async!(false, ptrdiff_t, Socket, void[])(fn, c, 0, socket, buffer);
}

ptrdiff_t sendAsync(scope Socket socket, scope const(void)[] buffer, bool delegate() condition = _defaultCondition.toDelegate() )
{
    ptrdiff_t delegate(ptrdiff_t t, Socket s, const(void)[] b) fn = (ptrdiff_t t, Socket s, const(void)[] b) { if(s && s.isAlive) return t + s.send(b); else return 0; };
    bool delegate(ptrdiff_t t, Socket s, const(void)[] b) c = (ptrdiff_t t, Socket s, const(void)[] b) { return ((t == Socket.ERROR || !t) && wouldHaveBlocked() && t < b.length) && condition(); };

    return async!(false, ptrdiff_t, Socket, const(void)[])(fn, c, 0, socket, buffer);
}

Socket acceptAsync(scope Socket socket, bool delegate() condition = _defaultCondition.toDelegate())
{
    SocketSet set = new SocketSet();
    int delegate(int, SocketSet) fn = (int t, SocketSet ss)
    {
        ss.add(socket);
        return Socket.select(ss, null, null, 1.msecs);
    };
    bool delegate(int, SocketSet) c = (int t, SocketSet ss) { return socket && socket.isAlive && !t && condition(); };

    try
    {
        if(async!(false, int, SocketSet)(fn, c, Socket.ERROR, set) == Socket.ERROR)
            return null;
        else
            return socket.accept(); 
    }
    catch(SocketAcceptException)
    {
        return null;
    }
}