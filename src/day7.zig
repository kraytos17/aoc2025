const std = @import("std");
const fs = std.fs;

const Point = struct {
    x: usize,
    y: usize,
};

pub fn main() !void {
    const result = try splitCount2("input.txt");
    std.debug.print("{d}\n", .{result});
}

pub fn splitCount1(path: []const u8) !u64 {
    const file = try fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = (try file.stat()).size;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var reader_buf: [4096]u8 = undefined;
    var reader = file.reader(&reader_buf);
    const content = try reader.interface.readAlloc(allocator, file_size);

    var grid = try std.ArrayList([]const u8).initCapacity(allocator, 0);
    var lines = std.mem.tokenizeScalar(u8, content, '\n');
    var start: Point = undefined;
    var row: usize = 0;
    while (lines.next()) |line| : (row += 1) {
        try grid.append(allocator, line);
        if (std.mem.indexOfScalar(u8, line, 'S')) |idx| {
            start = Point{ .x = idx, .y = row };
        }
    }

    if (grid.items.len == 0) return 0;
    const h = grid.items.len;
    const w = grid.items[0].len;
    var queue = try std.ArrayList(Point).initCapacity(allocator, 0);
    try queue.append(allocator, start);

    var vis = try allocator.alloc(bool, h * w);
    @memset(vis, false);
    vis[start.y * w + start.x] = true;

    var split_cnt: u64 = 0;
    var q_idx: usize = 0;
    while (q_idx < queue.items.len) : (q_idx += 1) {
        const curr = queue.items[q_idx];
        const next_x = curr.x;
        const next_y = curr.y + 1;
        if (next_y >= h) continue;
        if (next_x < 0 or next_x >= w) continue;

        const flat_idx = next_y * w + next_x;
        if (vis[flat_idx]) continue;
        vis[flat_idx] = true;

        const char = grid.items[next_y][next_x];
        if (char == '^') {
            split_cnt += 1;
            const left = Point{ .x = next_x - 1, .y = next_y };
            const right = Point{ .x = next_x + 1, .y = next_y };
            try queue.append(allocator, left);
            try queue.append(allocator, right);
        } else {
            try queue.append(allocator, Point{ .x = next_x, .y = next_y });
        }
    }
    return split_cnt;
}

pub fn splitCount2(path: []const u8) !u128 {
    const file = try fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = (try file.stat()).size;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var reader_buf: [4096]u8 = undefined;
    var reader = file.reader(&reader_buf);
    const content = try reader.interface.readAlloc(allocator, file_size);

    var grid = try std.ArrayList([]const u8).initCapacity(allocator, 0);
    var lines = std.mem.tokenizeScalar(u8, content, '\n');
    var start: Point = undefined;
    var row: usize = 0;
    while (lines.next()) |line| : (row += 1) {
        try grid.append(allocator, line);
        if (std.mem.indexOfScalar(u8, line, 'S')) |idx| {
            start = Point{ .x = idx, .y = row };
        }
    }

    if (grid.items.len == 0) return 0;
    const h = grid.items.len;
    const w = grid.items[0].len;
    const memo = try allocator.alloc(?u128, h * w);
    @memset(memo, null);

    return countPaths(grid.items, memo, start);
}

fn countPaths(grid: [][]const u8, memo: []?u128, p: Point) u128 {
    const h = grid.len;
    const w = grid[0].len;

    if (p.y >= h or p.x < 0 or p.x >= w) return 1;
    const idx = p.y * w + p.x;
    if (memo[idx]) |val| {
        return val;
    }

    const char = grid[p.y][p.x];
    var res: u128 = 0;
    if (char == '^') {
        const left = Point{ .x = p.x - 1, .y = p.y + 1 };
        const right = Point{ .x = p.x + 1, .y = p.y + 1 };
        res = countPaths(grid, memo, left) + countPaths(grid, memo, right);
    } else {
        const next = Point{ .x = p.x, .y = p.y + 1 };
        res = countPaths(grid, memo, next);
    }

    memo[idx] = res;
    return res;
}
