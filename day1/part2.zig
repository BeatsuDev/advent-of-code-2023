const std = @import("std");

// Task: Find the first and the last digit of each line in the input file, and return the sum of all numbers.
pub fn main() !void {
    var file = try std.fs.cwd().openFile("input.txt", .{});
    var buffered_reader = std.io.bufferedReader(file.reader());
    var reader = buffered_reader.reader();

    var sum: u64 = 0;
    var read_buffer: [1024]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&read_buffer, '\n')) |line| {
        var i: usize = 0;
        var j: usize = line.len - 1;

        while (!std.ascii.isDigit(line[i])) : (i += 1) {}
        while (!std.ascii.isDigit(line[j])) : (j -= 1) {}

        var tens: u64 = @as(u64, line[i] - '0');
        var ones: u64 = @as(u64, line[j] - '0');

        // See if there are solutions that exist outside the scope of [i..j].
        if (i >= 3) {
            if (findTextDigit(&line[0..i], false)) |new_tens| {
                tens = new_tens;
            }
        }

        if (line.len - j >= 3) {
            if (findTextDigit(&line[(j + 1)..], true)) |new_ones| {
                ones = new_ones;
            }
        }

        sum += 10 * tens + ones;
    }

    std.debug.print("Sum: {}\n", .{sum});
}

/// Finds the first or last (given by the last boolean flag) textual representation of a digit in a given string slice.
fn findTextDigit(text: *const []u8, last: bool) ?u64 {
    if (text.len < 3) return null;
    const tests = [10][]const u8{ "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

    var i: usize = if (last) text.len - 3 else 0;
    while (if (last) i >= 0 else text.len - i >= 3) {
        for (0..10) |j| {
            const slice = text.*[i..@min((i + tests[j].len), text.len)];
            if (std.mem.eql(u8, tests[j], slice)) {
                return j;
            }
        }

        if (i == 0 and last) break;
        if (last) i -= 1 else i += 1;
    }

    return null;
}

test "find first textual representation of a digit" {
    var test1 = [7]u8{ 'o', 'n', 'e', 't', 'w', 'o', '3' };
    var i: usize = 7;
    const digit = findTextDigit(&test1[0..i], false);

    try std.testing.expectEqual(@as(u64, 1), digit.?);
}

test "find LAST textual representation of a digit" {
    std.debug.print("\n", .{});
    var test1 = [8]u8{ 'o', 'n', 'e', '3', 'n', 'i', 'n', 'e' };
    var i: usize = 8;
    const digit = findTextDigit(&test1[0..i], true);

    try std.testing.expectEqual(@as(u64, 9), digit.?);
}
