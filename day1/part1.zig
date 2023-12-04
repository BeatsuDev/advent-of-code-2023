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

        sum += try std.fmt.parseInt(u64, &[2]u8{ line[i], line[j] }, 10);
    }

    std.debug.print("Sum: {}\n", .{sum});
}
