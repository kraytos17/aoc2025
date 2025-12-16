const std = @import("std");
const fs = std.fs;

pub fn main() !void {
    const result = try paperRolls2("input.txt");
    std.debug.print("{d}\n", .{result});
}

pub fn paperRolls1(path: []const u8) !u64 {
    const file = try fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = (try file.stat()).size;
    const alloc = std.heap.page_allocator;

    var reader_buf: [4096]u8 = undefined;
    var reader = file.reader(&reader_buf);
    const content = try reader.interface.readAlloc(alloc, file_size);
    defer alloc.free(content);

    var lines = try std.ArrayList([]const u8).initCapacity(alloc, 0);
    defer lines.deinit(alloc);

    var it = std.mem.tokenizeScalar(u8, content, '\n');
    while (it.next()) |l| try lines.append(alloc, l);

    const rows = lines.items.len;
    const cols = lines.items[0].len;
    var cnt: u64 = 0;
    for (lines.items, 0..) |row, r| {
        for (row, 0..) |cell, c| {
            if (cell != '@') continue;

            var adj: u8 = 0;
            inline for (.{ -1, 0, 1 }) |dr| {
                inline for (.{ -1, 0, 1 }) |dc| {
                    if (dr == 0 and dc == 0) continue;

                    const nr = @as(i32, @intCast(r)) + dr;
                    const nc = @as(i32, @intCast(c)) + dc;
                    if (nr >= 0 and nc >= 0 and nr < rows and nc < cols) {
                        if (lines.items[@intCast(nr)][@intCast(nc)] == '@') adj += 1;
                    }
                }
            }
            if (adj < 4) cnt += 1;
        }
    }
    return cnt;
}

const Point = struct {
    r: isize,
    c: isize,
};

pub fn paperRolls2(path: []const u8) !u64 {
    const file = try fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = (try file.stat()).size;
    const alloc = std.heap.page_allocator;

    var reader_buf: [4096]u8 = undefined;
    var reader = file.reader(&reader_buf);
    const content = try reader.interface.readAlloc(alloc, file_size);
    defer alloc.free(content);

    var grid = try std.ArrayList([]u8).initCapacity(alloc, 0);
    defer grid.deinit(alloc);

    var it = std.mem.tokenizeScalar(u8, content, '\n');
    while (it.next()) |l| try grid.append(alloc, try alloc.dupe(u8, l));

    const h: isize = @intCast(grid.items.len);
    const w: isize = @intCast(grid.items[0].len);

    var queue = try std.ArrayList(Point).initCapacity(alloc, 0);
    var total_removed: u64 = 0;

    for (0..grid.items.len) |r| {
        for (0..grid.items[0].len) |c| {
            if (grid.items[r][c] == '@') {
                if (countNbors(grid.items, @intCast(r), @intCast(c), h, w) < 4) {
                    grid.items[r][c] = 'x';
                    try queue.append(alloc, Point{ .r = @intCast(r), .c = @intCast(c) });
                }
            }
        }
    }

    var head: usize = 0;
    while (head < queue.items.len) : (head += 1) {
        const p = queue.items[head];
        total_removed += 1;
        grid.items[@intCast(p.r)][@intCast(p.c)] = '.';
        inline for (.{ -1, 0, 1 }) |dr| {
            inline for (.{ -1, 0, 1 }) |dc| {
                if (dr == 0 and dc == 0) continue;
                const nr = p.r + dr;
                const nc = p.c + dc;
                if (nr >= 0 and nc >= 0 and nr < h and nc < w) {
                    const ur: usize = @intCast(nr);
                    const uc: usize = @intCast(nc);
                    if (grid.items[ur][uc] == '@') {
                        if (countNbors(grid.items, nr, nc, h, w) < 4) {
                            grid.items[ur][uc] = 'x';
                            try queue.append(alloc, Point{ .r = nr, .c = nc });
                        }
                    }
                }
            }
        }
    }
    return total_removed;
}

fn countNbors(g: [][]u8, r: isize, c: isize, h: isize, w: isize) u8 {
    var adj: u8 = 0;
    inline for (.{ -1, 0, 1 }) |dr| {
        inline for (.{ -1, 0, 1 }) |dc| {
            if (dr == 0 and dc == 0) continue;
            const nr = r + dr;
            const nc = c + dc;
            if (nr >= 0 and nc >= 0 and nr < h and nc < w) {
                // Count both active '@' and queued 'x' as neighbors
                // bcs 'x' hasn't been physically removed yet logically
                const cell = g[@intCast(nr)][@intCast(nc)];
                if (cell == '@' or cell == 'x') adj += 1;
            }
        }
    }
    return adj;
}
