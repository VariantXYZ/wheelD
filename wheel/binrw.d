module wheel.binrw;

/// Reads an unsigned 16-bit big endian integer from a byte array.
ushort dataToU16B(in ubyte[] ptr)
{
   return ptr[0] << 8 | ptr[1];
}

/// Reads an unsigned 32-bit big endian integer from a byte array.
uint dataToU32B(in ubyte[] ptr)
{
   return ptr[0] << 24 | ptr[1] << 16 | ptr[2] << 8 | ptr[3];
}

/// Reads an unsigned 64-bit big endian integer from a byte array.
ulong dataToU64B(in ubyte[] ptr)
{
   return cast(ulong)ptr[0] << 56 | cast(ulong)ptr[1] << 48 | cast(ulong)ptr[2] << 40 | cast(ulong)ptr[3] << 32 |
                     ptr[4] << 24 |            ptr[5] << 16 |            ptr[6] << 8  |            ptr[7];
}

/// Reads a signed 16-bit big endian integer from a byte array.
short dataToS16B(in ubyte[] ptr)
{
   return cast(short)ptr.dataToU16B;
}

/// Reads a signed 32-bit big endian integer from a byte array.
int dataToS32B(in ubyte[] ptr)
{
   return cast(int)ptr.dataToU32B;
}

/// Reads a signed 64-bit big endian integer from a byte array.
long dataToS64B(in ubyte[] ptr)
{
   return cast(long)ptr.dataToU64B;
}

/// Writes a big endian byte array from an unsigned 16-bit integer.
immutable(ubyte[2]) dataFromU16B(ushort ptr) pure
{
   return [(ptr & 0xFF00) >> 8, ptr & 0xFF];
}

/// Writes a big endian byte array from an unsigned 32-bit integer.
immutable(ubyte[4]) dataFromU32B(uint ptr) pure
{
   return [(ptr & 0xFF000000) >> 24, (ptr & 0xFF0000) >> 16, (ptr & 0xFF00) >> 8, ptr & 0xFF];
}

/// Writes a big endian byte array from an unsigned 64-bit integer.
immutable(ubyte[8]) dataFromU64B(ulong ptr) pure
{
   return [(ptr & 0xFF00000000000000) >> 56, (ptr & 0xFF000000000000) >> 48, (ptr & 0xFF0000000000) >> 40, (ptr & 0xFF00000000) >> 32,
           (ptr & 0xFF000000)         >> 24, (ptr & 0xFF0000)         >> 16, (ptr & 0xFF00)         >> 8, ptr & 0xFF];
}

/// Writes a big endian byte array from a signed 16-bit integer.
immutable(ubyte[2]) dataFromS16B(short ptr) pure
{
   return dataFromU16B(cast(ushort)ptr);
}

/// Writes a big endian byte array from a signed 32-bit integer.
immutable(ubyte[4]) dataFromS32B(int ptr) pure
{
   return dataFromU32B(cast(uint)ptr);
}

/// Writes a big endian byte array from a signed 64-bit integer.
immutable(ubyte[8]) dataFromS64B(long ptr) pure
{
   return dataFromU64B(cast(ulong)ptr);
}

/// Reads an unsigned 16-bit little endian integer from a byte array.
ushort dataToU16L(in ubyte[] ptr)
{
   return ptr[1] << 8 | ptr[0];
}

/// Reads an unsigned 32-bit little endian integer from a byte array.
uint dataToU32L(in ubyte[] ptr)
{
   return ptr[3] << 24 | ptr[2] << 16 | ptr[1] << 8 | ptr[0];
}

/// Reads an unsigned 64-bit little endian integer from a byte array.
ulong dataToU64L(in ubyte[] ptr)
{
   return cast(ulong)ptr[7] << 56 | cast(ulong)ptr[6] << 48 | cast(ulong)ptr[5] << 40 | cast(ulong)ptr[4] << 32 |
                     ptr[3] << 24 |            ptr[2] << 16 |            ptr[1] << 8  |            ptr[0];
}

/// Reads a signed 16-bit little endian integer from a byte array.
short dataToS16L(in ubyte[] ptr)
{
   return cast(short)ptr.dataToU16L;
}

/// Reads a signed 32-bit little endian integer from a byte array.
int dataToS32L(in ubyte[] ptr)
{
   return cast(int)ptr.dataToU32L;
}

/// Reads a signed 64-bit little endian integer from a byte array.
long dataToS64L(in ubyte[] ptr)
{
   return cast(long)ptr.dataToU64L;
}

/// Writes a little endian byte array from an unsigned 16-bit integer.
immutable(ubyte[2]) dataFromU16L(ushort ptr) pure
{
   return [ptr & 0xFF, (ptr & 0xFF00) >> 8];
}

/// Writes a little endian byte array from an unsigned 32-bit integer.
immutable(ubyte[4]) dataFromU32L(uint ptr) pure
{
   return [ptr & 0xFF, (ptr & 0xFF00) >> 8, (ptr & 0xFF0000) >> 16, (ptr & 0xFF000000) >> 24];
}

/// Writes a little endian byte array from an unsigned 64-bit integer.
immutable(ubyte[8]) dataFromU64L(ulong ptr) pure
{
   return [ptr & 0xFF,                (ptr & 0xFF00)         >> 8,  (ptr & 0xFF0000)         >> 16, (ptr & 0xFF000000)         >> 24,
          (ptr & 0xFF00000000) >> 32, (ptr & 0xFF0000000000) >> 40, (ptr & 0xFF000000000000) >> 48, (ptr & 0xFF00000000000000) >> 56];
}

/// Writes a little endian byte array from a signed 16-bit integer.
immutable(ubyte[2]) dataFromS16L(short ptr) pure
{
   return dataFromU16L(cast(ushort)ptr);
}

/// Writes a little endian byte array from a signed 32-bit integer.
immutable(ubyte[4]) dataFromS32L(int ptr) pure
{
   return dataFromU32L(cast(uint)ptr);
}

/// Writes a little endian byte array from a signed 64-bit integer.
immutable(ubyte[8]) dataFromS64L(long ptr) pure
{
   return dataFromU64L(cast(ulong)ptr);
}

/// Reads a UTF-8 string from a byte array.
string dataToStrn(in ubyte[] ptr, size_t len)
{
    return cast(string)(ptr[0..len].idup);
}

/// Reads a UTF-16 string from a byte array.
wstring dataToWStr(in ubyte[] ptr, size_t len)
{
    wchar[] outp;
    outp.length = len;
    for(size_t i; i < len; i++)
        outp[i] = ptr[i..i+2].dataToU16L;
    return cast(wstring)(outp);
}

/// Reads a UTF-32 string from a byte array.
dstring dataToDStr(in ubyte[] ptr, size_t len)
{
    dchar[] outp;
    outp.length = len;
    for(size_t i; i < len; i++)
        outp[i] = ptr[i..i+4].dataToU32L;
    return cast(dstring)(outp);
}

/// Writes a UTF-8 string to a byte array.
ubyte[] dataFromStrn(string ptr)
{
    return cast(ubyte[])(ptr.dup);
}

/// Writes a big endian UTF-16 string to a byte array.
ubyte[] dataFromWStrB(wstring ptr)
{
    ubyte[] outp;
    outp.length = ptr.length * 2;
    for(size_t i; i < ptr.length; i++)
    {
        outp[i + 0] = (ptr[i] & 0xFF00) >> 8;
        outp[i + 1] = (ptr[i] & 0x00FF) >> 0;
    }
    return outp;
}

/// Writes a little endian UTF-16 string to a byte array.
ubyte[] dataFromWStrL(wstring ptr)
{
    ubyte[] outp;
    outp.length = ptr.length * 2;
    for(size_t i; i < ptr.length; i++)
    {
        outp[i + 0] = (ptr[i] & 0x00FF) >> 0;
        outp[i + 1] = (ptr[i] & 0xFF00) >> 8;
    }
    return outp;
}

/// Writes a big endian UTF-32 string to a byte array.
ubyte[] dataFromDStrB(dstring ptr)
{
    ubyte[] outp;
    outp.length = ptr.length * 4;
    for(size_t i; i < ptr.length; i++)
    {
        outp[i + 0] = (ptr[i] & 0xFF000000) >> 24;
        outp[i + 1] = (ptr[i] & 0x00FF0000) >> 16;
        outp[i + 2] = (ptr[i] & 0x0000FF00) >> 8;
        outp[i + 3] = (ptr[i] & 0x000000FF) >> 0;
    }
    return outp;
}

/// Writes a little endian UTF-32 string to a byte array.
ubyte[] dataFromDStrL(dstring ptr)
{
    ubyte[] outp;
    outp.length = ptr.length * 2;
    for(size_t i; i < ptr.length; i++)
    {
        outp[i + 0] = (ptr[i] & 0x000000FF) >> 0;
        outp[i + 1] = (ptr[i] & 0x0000FF00) >> 8;
        outp[i + 2] = (ptr[i] & 0x00FF0000) >> 16;
        outp[i + 3] = (ptr[i] & 0xFF000000) >> 24;
    }
    return outp;
}

private union FloatUint
{
    float f;
    uint  u;
}

private union FloatUlong
{
    float d;
    ulong ul;
}

/// Reads a little endian float32 from a byte array.
float dataToF32L(ubyte[] ptr)
{
    FloatUint data;
    data.u = ptr.dataToU32L;
    return data.f;
}

/// Reads a big endian float32 from a byte array.
float dataToF32B(ubyte[] ptr)
{
    FloatUint data;
    data.u = ptr.dataToU32B;
    return data.f;
}

/// Reads a little endian float64 from a byte array.
double dataToF64L(ubyte[] ptr)
{
    FloatUlong data;
    data.ul = ptr.dataToU64L;
    return data.d;
}

/// Reads a big endian float64 from a byte array.
double dataToF64B(ubyte[] ptr)
{
    FloatUlong data;
    data.ul = ptr.dataToU64B;
    return data.d;
}
