module wheel.serialization.serialize;

interface ISerialize(T)
{
    T load(const string data);
    string save(T j);
}