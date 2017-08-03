module wheel.server.base;

import std.concurrency;
import std.string;

class Basewheel
{
private:
    FiberScheduler scheduler;
    byte logFlag = 1;
    shared bool activeFlag;
    
    static void _log(byte logFlag, string message)
    {
        synchronized
        {
            if(logFlag & 1)
            {
                import std.stdio : writeln;
                writeln(message);
            }
        }       
    }

protected:
    string name;

    this(string name)
    {
        this.name = name;
        activeFlag = false;
        scheduler = new FiberScheduler();
    }

    ~this()
    {
        shutdown();
    }

    void log(string message)
    {
        _log(logFlag, "[%s] %s".format(name, message));
    }

public:
    @property bool isActive() { return activeFlag; }

    void shutdown()
    {
        activeFlag = false;
    }

    void initialize()
    {
        if(!isActive)
        {
            activeFlag = true;
            scheduler.start( { while(isActive) { yield(); } } );
        }
        else
        {
            throw new Exception("Scheduler is already initialized");
        }
    }

    void schedule(void delegate() fn)
    {
        scheduler.spawn(fn);
    }

    void rename(string name)
    {
        this.name = name;
    }

    //Bitmask:
    //0 for no logging
    //1 for console logging
    //2 for file logging
    void setLogMode(byte flag)
    {
        logFlag = flag;
    }
    
}