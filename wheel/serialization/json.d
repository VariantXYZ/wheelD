module wheel.serialization.json;

import std.json;

import painlessjson;

import wheel.serialization.serialize;

class JSONSerializer(T) : ISerialize!T
{
public:
    T load(const string data)
    {
        T j = T();
        j = fromJSON!T(parseJSON(data));
        return j;
    }
    string save(T j)
    {
        return toJSON!T(j).toPrettyString();
    }
}