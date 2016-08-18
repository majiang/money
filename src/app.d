void main()
{
    import std.stdio;
    import money;
    Record[] records;
    foreach (line; stdin.byLine)
        records ~= Record(line.idup);
    foreach (record; records)
        record.writeln;
    foreach (cycle; [2, 4, 7])
        records.expensePerDays(cycle).writeln;
}
