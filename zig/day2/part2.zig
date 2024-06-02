const std = @import("std");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input.txt", .{});
    var buffered_reader = std.io.bufferedReader(file.reader());
    var reader = buffered_reader.reader();

    var total_power: u32 = 0;
    var buffer: [1024]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        var it = std.mem.split(u8, line, ": ");
        const game_string = it.next().?;
        const game_id = try std.fmt.parseInt(u32, game_string[5..], 10);
        _ = game_id;

        it = std.mem.split(u8, it.next().?, "; ");

        var highest_red: u32 = 0;
        var highest_green: u32 = 0;
        var highest_blue: u32 = 0;
        while (it.next()) |reveal| {
            var round_it = std.mem.split(u8, reveal, ", ");
            while (round_it.next()) |colour_string| {
                var colour_it = std.mem.split(u8, colour_string, " ");
                const count = try std.fmt.parseInt(u32, colour_it.next().?, 10);
                const colour = colour_it.next().?;

                // Workaround because strings cannot be used in switch statements :(
                if (std.mem.eql(u8, "red", colour) and count > highest_red) highest_red = count;
                if (std.mem.eql(u8, "green", colour) and count > highest_green) highest_green = count;
                if (std.mem.eql(u8, "blue", colour) and count > highest_blue) highest_blue = count;
            }
        }
        std.debug.print("red: {d}, green: {d}, blue: {d}\n", .{ highest_red, highest_green, highest_blue });
        total_power += highest_red * highest_green * highest_blue;
    }

    std.debug.print("Sum: {d}\n", .{total_power});
}
