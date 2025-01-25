const std = @import("std");

pub fn main() !void {
    const data: [140][140]u8 = try readInput(140, 140, "input.txt");

    var sum: u64 = 0;
    for (1..140) |x| {
        for (1..140) |y| {
            if (!(data[y][x] == '*')) continue;
            const adjacentNumbers = try getAdjacentNumbers(data, x, y);

            if (adjacentNumbers.len == 2) {
                sum += adjacentNumbers[0] * adjacentNumbers[1];
            }
        }
    }

    std.debug.print("Sum: {d}\n", .{sum});
}

fn readInput(comptime x_size: usize, comptime y_size: usize, file_name: []const u8) ![y_size][x_size]u8 {
    var file = try std.fs.cwd().openFile(file_name, .{});
    var buffered_reader = std.io.bufferedReader(file.reader());
    var reader = buffered_reader.reader();

    var lines: [y_size][x_size]u8 = undefined;
    var read_buffer: [x_size + 1]u8 = undefined;

    var i: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&read_buffer, '\n')) |line| : (i += 1)
        lines[i] = line[0..x_size].*;

    return lines;
}

/// Gets the index of the first digit in the number that "index" is inside.
/// e.g. ".123.5" and index 2 will return 1, because 1 is the first digit of 123
fn getNumberStartIndex(line: []const u8, index: usize) usize {
    std.debug.assert(index < line.len);
    var i: usize = index;
    return while (i > 0) : (i -= 1) {
        if (!std.ascii.isDigit(line[i]))
            break (i + 1);
    } else @intFromBool(!std.ascii.isDigit(line[0]));
}

test "Get first index of number in a string" {
    const test1 = getNumberStartIndex(".123.5", 2);
    const test2 = getNumberStartIndex("01234567890", 10);
    const test3 = getNumberStartIndex("...345", 5);

    try std.testing.expectEqual(@as(usize, 1), test1);
    try std.testing.expectEqual(@as(usize, 0), test2);
    try std.testing.expectEqual(@as(usize, 3), test3);
}

/// Gets the index of the last digit in the number that "index" is inside
/// e.g. ".123.5" and index 2 will return 3, because 3 is the last digit of 123
fn getNumberEndIndex(line: []const u8, index: usize) usize {
    std.debug.assert(index < line.len);
    var i: usize = index;
    return while (i < line.len and std.ascii.isDigit(line[i])) : (i += 1) {} else i - 1;
}

test "Get last index of number in a string" {
    const test1 = getNumberEndIndex(".123.5", 2);
    const test2 = getNumberEndIndex("01234567890", 0);
    const test3 = getNumberEndIndex("0123..", 0);

    try std.testing.expectEqual(@as(usize, 3), test1);
    try std.testing.expectEqual(@as(usize, 10), test2);
    try std.testing.expectEqual(@as(usize, 3), test3);
}

// TODO: [][]u8 does not work here so I need to use anytype. Can this be fixed?
fn getAdjacentNumbers(data: anytype, x: usize, y: usize) ![]u64 {
    var numbers: [6]u64 = undefined;
    var number_length: u16 = 0;

    var y_index: usize = if (y == 0) 0 else y - 1;
    while (y_index <= @min(y + 1, data.len - 1)) : (y_index += 1) {
        const line = data[y_index];
        var x_index: usize = if (x == 0) 0 else x - 1;
        while (x_index <= @min(x + 1, data[y_index].len - 1)) : (x_index += 1) {
            if (!std.ascii.isDigit(line[x_index])) continue;

            const start = getNumberStartIndex(&line, x_index);
            const end = getNumberEndIndex(&line, x_index);

            x_index = end;
            const number = try std.fmt.parseInt(u64, line[start .. end + 1], 10);
            numbers[number_length] = number;
            number_length += 1;
        }
    }
    return numbers[0..number_length];
}

test "Get adjacent number sum" {
    const data = [_][5]u8{
        [_]u8{ '1', '0', '0', '0', '0' },
        [_]u8{ '.', '.', '.', '#', '5' },
        [_]u8{ '.', '2', '2', '.', '9' },
    };

    const test1 = try getAdjacentNumbers(data, 3, 1);
    try std.testing.expectEqual(@as([]const u64, &[_]u64{ 10000, 5, 22, 9 }), test1);

    const test2 = try getAdjacentNumbers(data, 3, 2);
    try std.testing.expectEqual(@as([]const u64, &[_]u64{ 5, 22, 9 }), test2);
}
