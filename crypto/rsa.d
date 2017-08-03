module wheel.crypto.rsa;

import core.stdc.stdlib;

import std.string;

import deimos.openssl.rsa;
import deimos.openssl.pem;
import deimos.openssl.err;

ubyte[] rsaEncrypt(const string key, const ubyte[] text)
{
    BIO* b = BIO_new_mem_buf(cast(void*)(toStringz(key)), cast(int)(key.length));
    if(!b)
        return null;
    RSA* rsa = PEM_read_bio_RSA_PUBKEY(b, null, null, null);
    if(!rsa)
        return null;

    auto ptr = cast(ubyte*)(malloc(RSA_size(rsa)));

    scope(exit)
    {
        BIO_free(b);
        RSA_free(rsa);
        free(ptr);
    }

    return ptr[0..RSA_public_encrypt(cast(int)(text.length), text.ptr, ptr, rsa, RSA_PKCS1_PADDING)].dup;
}

ubyte[] rsaDecrypt(const string key, const ubyte[] cipherText)
{
    BIO* b = BIO_new_mem_buf(cast(void*)(toStringz(key)), cast(int)(key.length));
    if(!b)
        return null;
    RSA* rsa = PEM_read_bio_RSAPrivateKey(b, null, null, null);
    if(!rsa)
        return null;

    auto ptr = cast(ubyte*)(malloc(RSA_size(rsa)));
    
    scope(exit)
    {
        BIO_free(b);
        RSA_free(rsa);
        free(ptr);
    }

    return ptr[0..RSA_private_decrypt(cast(int)(cipherText.length), cipherText.ptr, ptr, rsa, RSA_PKCS1_PADDING)].dup;
}

unittest
{
    string RSAPrivateKey = "-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQC27VbQkfEgxm113jYV3BuBCSK6l+GyEmAfk9ApGhkKgjlAh4Cd
EOHLRd4AcQQIXkxT73i1VimG2C5Vs14bDzwePp5fCsIqjtz0fP+u5eJCeuDffCwQ
Ep3sqz9QXpPh4MN0B0WsTD0Yo4189f0B4jxN2cBnK+ip3G8vBbBPyAqJdQIDAQAB
AoGAA8lYE54AawXYebO1abtCPCf2K/0dWvbbk65sWmbJJRPK1MMJSUGydCdN1V4B
hUfTFiYImQj/zTlX2jEfOKRWgZ5yqioE8Wcq/SykRa5XihU4Osz8LZpTq1vFe/rE
kn8Z6Czp1d5BCN9q47rhrRMwOdjVww1/C56xlST6sXuf/PECQQDo8bMFahnPtuw2
JRkvzkPJl/cImnbCG8xXE2zuyTKy8TgimMIY/pbY+N2OuPAzT0wP8ne4u+VDaSYW
ScWk//2xAkEAyQhQ/yzNf37JdYW2+y7KQtSwzfbrUtDYlU5L1vl7RFPLLF4DPAWS
S/RJRPBCRSUD+niMwNuBs8w94058fWAlBQJASw0Ma7Mqi8TYx/0d50wihQIEIm55
0sJYDLoCf9CtGAAl4OesqZblDRTpdUFain2C+SRatFc9X4GyNr4gArBDkQJAZjIY
GuCHxxyJBXloP+DVaYv+JXY0wvDwaVZYL3y8MUv3qSJRup2KdZpF9Qm+ZrAeiaHm
y9PK58AYZglsN8A8kQJBAIgzdfgBeE41rsEHbo7OeCVsj/L8iB+gDxqKQkKHzH2m
Cb28qaF9vSZzLUkAOFtA8EUE4/EH38xDa/rCrrPv5F4=
-----END RSA PRIVATE KEY-----";

    string RSAPublicKey = "-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC27VbQkfEgxm113jYV3BuBCSK6
l+GyEmAfk9ApGhkKgjlAh4CdEOHLRd4AcQQIXkxT73i1VimG2C5Vs14bDzwePp5f
CsIqjtz0fP+u5eJCeuDffCwQEp3sqz9QXpPh4MN0B0WsTD0Yo4189f0B4jxN2cBn
K+ip3G8vBbBPyAqJdQIDAQAB
-----END PUBLIC KEY-----";

    const ubyte[] text = [ 'h', 'e', 'l', 'l', 'o' ];
    import std.algorithm : equal;
    auto a = rsaEncrypt(RSAPublicKey, text);
    auto b = rsaDecrypt(RSAPrivateKey, a);
    assert(equal!((a, b) => a == b)(text, b));
}