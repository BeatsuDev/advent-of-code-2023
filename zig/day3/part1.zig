const std = @import("std");

/// This program assumes that numbers cannot occur adjacent to two different symbols
/// Or if they do, then the numbers are counted twice. E.g. #205* 205 gets counted twice.
pub fn main() !void {
    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buffered_reader = std.io.bufferedReader(file.reader());
    var reader = buffered_reader.reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // Parse lines to a 2D array
    var lines = try readLines(allocator, reader);
    defer {
        for (lines) |line_pointer| {
            allocator.free(line_pointer);
        }
        allocator.free(lines);
    }

    var total: usize = 0;
    for (0..lines.len) |y| {
        for (0..lines[y].len) |x| {
            const char: u8 = lines[y].*[x];
            if (std.ascii.isDigit(char) or char == '.') continue;
            total += try getAdjacentNumberSum(&lines, x, y);
        }
    }

    std.debug.print("Sum: {d}\n", .{total});
}

/// Returns a slice of lines
fn readLines(allocator: std.mem.Allocator, reader: anytype) ![]*[]const u8 {
    var lines = try allocator.alloc(*[]const u8, 1024);
    var line_buffer: [1024]u8 = undefined;

    var i: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&line_buffer, '\n')) |line| : (i += 1) {
        var line_pointer = try allocator.alloc(u8, line.len);
        lines[i] = &line_pointer;
        std.mem.copy(u8, line_pointer, line);
    }

    return lines[0..i];
}

fn getAdjacentNumberSum(lines: *[]*[]const u8, x: usize, y: usize) !usize {
    var total: usize = 0;
    var dy = if (y > 0) y - 1 else 0;
    while (dy <= y + 1) : (dy += 1) {
        var dx = if (x > 0) x - 1 else 0;
        while (dx <= x + 1) : (dx += 1) {
            if (dy >= lines.len or dx >= lines.*[dy].len) continue;
            if (std.ascii.isDigit(lines.*[dy].*[dx])) {
                const indexes = getNumber(lines.*[dy], dx);
                total += try std.fmt.parseInt(usize, lines.*[dy].*[indexes[0]..indexes[1]], 10);
                dx = indexes[1] - 1;
            }
        }
    }
    return total;
}

fn getNumber(line: *[]const u8, start_index: usize) [2]usize {
    var i = start_index;
    var j = start_index;

    while (i >= 0 and std.ascii.isDigit(line.*[i])) : (i -= 1) {}
    while (j < line.len and std.ascii.isDigit(line.*[j])) : (j += 1) {}

    return [2]usize{ i + 1, j };
}
