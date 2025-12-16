const std = @import("std");

pub fn main() !void {
    const result = try computePassword2("input.txt");
    std.debug.print("{d}\n", .{result});
}

pub fn computePassword1(path: []const u8) !u64 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = (try file.stat()).size;
    const allocator = std.heap.page_allocator;
    const content = try allocator.alloc(u8, file_size);
    defer allocator.free(content);

    _ = try file.readAll(content);

    var pos: i32 = 50;
    var count_zero: u64 = 0;
    var lines = std.mem.splitScalar(u8, content, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        const dir = line[0];
        const dist = std.fmt.parseInt(i32, line[1..], 10) catch continue;
        switch (dir) {
            'R' => pos = @rem(pos + dist + 100, 100),
            'L' => pos = @rem(pos - dist + 100, 100),
            else => continue,
        }
        if (pos == 0) count_zero += 1;
    }

    return count_zero;
}

pub fn computePassword2(path: []const u8) !u64 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = (try file.stat()).size;
    const allocator = std.heap.page_allocator;
    const content = try allocator.alloc(u8, file_size);
    defer allocator.free(content);

    _ = try file.readAll(content);

    var pos: i32 = 50;
    var count_zero: u64 = 0;
    var lines = std.mem.splitScalar(u8, content, '\n');
    while (lines.next()) |line| {
        if (line.len < 2) continue;

        const dir = line[0];
        const dist = std.fmt.parseInt(i32, line[1..], 10) catch continue;

        if (dist == 0) continue;
        const old_pos = pos;
        const steps = dist;
        switch (dir) {
            'R' => {
                var k: i32 = @intCast(@mod(100 - old_pos, 100));
                if (k == 0) k = 100;
                if (k <= steps) {
                    const hits_i32: i32 = 1 + @divTrunc(steps - k, 100);
                    count_zero += @intCast(hits_i32);
                }

                pos = @mod(old_pos + steps, 100);
            },
            'L' => {
                var k: i32 = @intCast(@mod(old_pos, 100));
                if (k == 0) k = 100;
                if (k <= steps) {
                    const hits_i32: i32 = 1 + @divTrunc(steps - k, 100);
                    count_zero += @intCast(hits_i32);
                }

                pos = @rem(old_pos - steps, 100);
                if (pos < 0) pos += 100;
            },
            else => continue,
        }
    }
    return count_zero;
}
