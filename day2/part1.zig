const std = @import("std");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input.txt", .{});
    var buffered_reader = std.io.bufferedReader(file.reader());
    var reader = buffered_reader.reader();

    const Configuration = enum(u32) {
        RED = 12,
        GREEN = 13,
        BLUE = 14,
    };

    var game_id_total: u32 = 0;
    var buffer: [1024]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        var it = std.mem.split(u8, line, ": ");
        const game_string = it.next().?;
        const game_id = try std.fmt.parseInt(u32, game_string[5..], 10);

        it = std.mem.split(u8, it.next().?, "; ");

        game_id_total += reveal_iteration: while (it.next()) |reveal| {
            var round_it = std.mem.split(u8, reveal, ", ");
            while (round_it.next()) |colour_string| {
                var colour_it = std.mem.split(u8, colour_string, " ");
                const count = try std.fmt.parseInt(u32, colour_it.next().?, 10);
                const colour = colour_it.next().?;

                // Workaround because strings cannot be used in switch statements :(
                if (std.mem.eql(u8, "red", colour) and count > @intFromEnum(Configuration.RED)) break :reveal_iteration 0;
                if (std.mem.eql(u8, "green", colour) and count > @intFromEnum(Configuration.GREEN)) break :reveal_iteration 0;
                if (std.mem.eql(u8, "blue", colour) and count > @intFromEnum(Configuration.BLUE)) break :reveal_iteration 0;
            }
        } else game_id;
    }

    std.debug.print("Sum: {d}\n", .{game_id_total});
}
