const std = @import("std");

pub fn main() !void {
    const data = try readInput(140, 140, "input.txt");

    var sum: u64 = 0;

    for (0..140) |y| {
        for (0..140) |x| {
            for (adjacencySlice(x, y, 0, 140, 0, 140)) |adjacent| {
                if (data[adjacent.y][adjacent.x] != '.' and !std.ascii.isdigit(data[adjacent.y][adjacent.x])) {
                    sum += try parseNumberAt(data[y], x);
                }
            }
        }
    }
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

fn parseNumberAt(line: []const u8, index: usize) !u64 {
    var start: usize = index;
    var end = index;

    while (start > 0 and std.ascii.isDigit(line[start])) : (start -= 1) {}
    if (start == 0 and !std.ascii.isDigit(line[start])) {
        start += 1;
    }
    while (end < line.len and std.ascii.isDigit(line[end])) : (end += 1) {}
}

const Position = struct {
    x: usize,
    y: usize,
};
fn adjacencySlice(x: usize, y: usize, min_x: usize, max_x: usize, min_y: usize, max_y: usize) []Position {
    var adjacents: [8]Position = undefined;

    const start_x = if (x == min_x) min_x else x - 1;
    const end_x = if (x == max_x) max_x else x + 1;

    const start_y = if (y == min_y) min_y else y - 1;
    const end_y = if (y == max_y) max_y else y + 1;

    var i: usize = 0;
    for (start_y..end_y) |inner_y| {
        for (start_x..end_x) |inner_x| {
            if (inner_x == inner_x and inner_y == inner_y) continue;
            adjacents[i] = {
                .x = inner_x,
                .y = inner_y,
            };
            i += 1;
        }
    }

    return adjacents[0..i];
}
