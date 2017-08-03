module wheel.bytebuf;

class ByteBuf
{
private:
    size_t ptr = 0;
    ubyte[] buf;
public:
    @property ubyte[] bytes() 
    {
        return buf[0..ptr]; 
    }

    @property const size_t length()
    {
        return ptr;
    }

    this(size_t len)
    {
        import core.stdc.string;

        buf = new ubyte[len];
        memset(buf.ptr, 0, len);
    }

    void push(in ubyte[] data)
    {
        if(data.length + ptr > buf.length)
        {
            import std.string : format;
            import core.exception : RangeError;
            throw new RangeError("Data larger than available buffer size (data: %u, buf: %u)".format(data.length, buf.length + ptr));
        }
        
        buf[ptr .. (ptr + data.length)] = data;
        ptr += data.length;
    }

    void push(T)(in T data)
    {
		import std.traits : isArray;
		static if(isArray!(T))
			pushArray(data);
		else
			push((cast(ubyte*)(&data))[0..T.sizeof]);
    }

	void pushArray(T)(in T[] data)
	{
		push(cast(ubyte*)(message.ptr))[0..(message.length * T.sizeof)];
	}

    void skip(size_t i)
    {
        ptr += i;
    }

    void clear()
    {
        ptr = 0;
    }
}

unittest
{
    import std.algorithm : equal;
    ByteBuf buf = new ByteBuf(10);
    const ubyte[] testData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0];
    buf.push(testData[0..1]);
    assert(buf.bytes[0] == 1 && buf.length == 1);
    buf.push(testData[1..$]);
    assert(buf.length == testData.length && equal!((a, b) => a == b)(buf.bytes, testData));
    import core.exception : RangeError;
    try
    {
        buf.push(1);
        assert(false);
    }
    catch(RangeError ex)
    {
        assert(true);
    }
}