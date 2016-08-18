module money;

import std.algorithm, std.array, std.conv, std.datetime, std.exception, std.string;
import std.experimental.logger;
import std.windows.charset;

int includeTax(int amount, Date date=Date.init)
{
    return (amount * real(1.08)).to!int;
}

struct Record
{
    Date when;
    string cat, where;
    int payment;
    string unit;
    real amount = 1;
    size_t count = 1;
    string description;
    this (string line)
    {
        foreach (field; line.chomp.split('\t'))
        {
            (field.count(':') == 1).enforce("malformed field: '%s'".format(field));
            auto
                fieldName = field.findSplit(":")[0],
                fieldValue = field.findSplit(":")[2];
            switch (fieldName)
            {
                break; case "when":
                    auto buf = fieldValue.split('/');
                    when = Date(buf[0].to!int, buf[1].to!int, buf[2].to!int);
                break;case "税込":
                    payment = fieldValue.to!int;
                break;case "税抜":
                    payment = fieldValue.to!int.includeTax;
                break;case "":
                break;default:
            }
        }
    }
    string toString()
    {
        return "%s: %d".format(when.toISOExtString.replace("-", "/"), payment);
    }
}

struct ExpensePerDays
{
    Date dateBegin, dateEndEx;
    int[string] expensePerCat;
}

ExpensePerDays[] expensePerDays(Record[] records, size_t cycleInDays)
{
    if (records.empty)
        return [];
    records.sort!((a, b) => a.when < b.when);
    auto dateBegin = records.front.when;
    auto dateEndEx = dateBegin + cycleInDays.days;
    auto ret = [ExpensePerDays(dateBegin, dateEndEx)];
    foreach (record; records)
    {
        if (dateEndEx <= record.when)
        {
            dateBegin = dateEndEx;
            dateEndEx += cycleInDays.days;
            ret ~= ExpensePerDays(dateBegin, dateEndEx);
        }
        if (auto p = record.cat in ret[$-1].expensePerCat)
            *p += record.payment;
        else
            ret[$-1].expensePerCat[record.cat] = record.payment;
    }
    return ret;
}
