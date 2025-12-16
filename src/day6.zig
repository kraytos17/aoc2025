const std = @import("std");
const fs = std.fs;

pub fn main() !void {
    const result = try homework2("input.txt");
    std.debug.print("{d}\n", .{result});
}

pub fn homework1(path: []const u8) !u64 {
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
    var it = std.mem.tokenizeScalar(u8, content, '\n');
    var max_w: usize = 0;
    while (it.next()) |line| {
        try grid.append(allocator, line);
        if (line.len > max_w) max_w = line.len;
    }

    if (grid.items.len == 0) return 0;
    var total: u64 = 0;
    var col: usize = 0;
    while (col < max_w) {
        while (col < max_w and isColEmpty(grid.items, col)) : (col += 1) {}
        if (col >= max_w) break;

        const start_col = col;
        while (col < max_w and !isColEmpty(grid.items, col)) : (col += 1) {}

        const end_col = col;
        total += try solve(allocator, grid.items, start_col, end_col);
    }
    return total;
}

fn solve(allocator: std.mem.Allocator, lines: [][]const u8, start: usize, end: usize) !u64 {
    var nums = try std.ArrayList(u64).initCapacity(allocator, 0);
    var operator: u8 = 0;
    for (lines) |line| {
        if (start >= line.len) continue;
        const e = @min(end, line.len);
        const chunk = line[start..e];
        const trimmed = std.mem.trim(u8, chunk, &std.ascii.whitespace);
        if (trimmed.len == 0) continue;
        if (std.mem.eql(u8, trimmed, "+")) {
            operator = '+';
        } else if (std.mem.eql(u8, trimmed, "*")) {
            operator = '*';
        } else {
            const num = try std.fmt.parseInt(u64, trimmed, 10);
            try nums.append(allocator, num);
        }
    }

    if (nums.items.len == 0) return 0;
    var res: u64 = undefined;
    if (operator == '+') {
        res = 0;
        for (nums.items) |n| res += n;
    } else if (operator == '*') {
        res = 1;
        for (nums.items) |n| res *= n;
    } else {
        if (nums.items.len > 0) res = nums.items[0];
    }

    return res;
}

fn isColEmpty(lines: [][]const u8, col: usize) bool {
    for (lines) |l| {
        if (col < l.len and l[col] != ' ') return false;
    }
    return true;
}

pub fn homework2(path: []const u8) !u64 {
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
    var it = std.mem.tokenizeScalar(u8, content, '\n');
    var max_w: usize = 0;
    while (it.next()) |line| {
        try grid.append(allocator, line);
        if (line.len > max_w) max_w = line.len;
    }

    if (grid.items.len == 0) return 0;
    var total: u64 = 0;
    var col: usize = 0;
    while (col < max_w) {
        while (col < max_w and isColEmpty(grid.items, col)) : (col += 1) {}
        if (col >= max_w) break;

        const start_col = col;
        while (col < max_w and !isColEmpty(grid.items, col)) : (col += 1) {}

        const end_col = col;
        total += try solve2(allocator, grid.items, start_col, end_col);
    }
    return total;
}

fn solve2(allocator: std.mem.Allocator, lines: [][]const u8, start: usize, end: usize) !u64 {
    var nums = try std.ArrayList(u64).initCapacity(allocator, 0);
    var operator: u8 = 0;
    var c = start;
    while (c < end) : (c += 1) {
        var digits = try std.ArrayList(u8).initCapacity(allocator, 0);
        for (lines) |line| {
            if (c >= line.len) continue;
            const char = line[c];
            if (std.ascii.isDigit(char)) {
                try digits.append(allocator, char);
            } else if (char == '+' or char == '*') {
                operator = char;
            }
        }

        if (digits.items.len > 0) {
            const num = try std.fmt.parseInt(u64, digits.items, 10);
            try nums.append(allocator, num);
        }
    }

    if (nums.items.len == 0) return 0;
    var res: u64 = if (operator == '*') 1 else 0;
    for (nums.items) |num| {
        if (operator == '*') res *= num else res += num;
    }
    return res;
}
