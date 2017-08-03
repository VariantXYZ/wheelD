module wheel.crypto.rc4;

@nogc @safe:

struct stream_state
{
    ubyte[256] state;
    ubyte x, y;
}

// Encryption and decryption are symmetric
alias stream_decrypt = stream_encrypt;

void stream_encrypt(ref stream_state self, ubyte[] block)
{
    auto x = self.x;
    auto y = self.y;

    for (size_t i; i < block.length; i++) 
    {
        x = cast(ubyte)(x + 1);
        y = cast(ubyte)(y + self.state[x]);

        // Exchange state[x] and state[y]
        const t = self.state[x];
        self.state[x] = self.state[y];
        self.state[y] = cast(ubyte)t;

        // XOR the data with the stream data
        const xorIndex = (self.state[x] + self.state[y]) % 256;
        block[i] ^= self.state[xorIndex];
    }

    self.x = x;
    self.y = y;
}

void stream_init(ref stream_state self, in ubyte[] key)
{
    for (size_t i; i < 256; i++)
    {
        self.state[i] = cast(ubyte)i;
    }

    size_t index1;
    size_t index2;

    for (size_t i; i < 256; i++) 
    {
        index2 = (key[index1] + self.state[i] + index2) % 256;
        const t = self.state[i];
        self.state[i] = self.state[index2];
        self.state[index2] = t;
        index1 = (index1 + 1) % key.length;
    }
}
