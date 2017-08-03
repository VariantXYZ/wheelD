module wheel.async;

import std.concurrency;

T async(bool checkInit, T, A...)(T delegate(T, A) fn, bool delegate(T, A) condition, T init, A a)
{
    T ret = init;
    static if(checkInit)
    {
        if(!condition(ret, a))
            return ret;
    }
    do
    {
        ret = fn(ret, a);
        if(!condition(ret, a))
            break;
        else
            yield();
    } while(1);

    return ret;
}

//NOT a thread-safe lock
//Naive implementation is only good for single-threaded async
T lock(string lockName, T)(T delegate() d)
{
    import std.string : format;
    mixin("static bool %s = false;".format(lockName));
    while(mixin(lockName)) yield();
    mixin("%s = true;".format(lockName));
    static if(is(T == void))
        d();
    else
        return d();
}