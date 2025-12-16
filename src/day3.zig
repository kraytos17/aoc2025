const std = @import("std");
const fs = std.fs;

pub fn main() !void {
    const result = try maxJoltage2("input.txt");
    std.debug.print("{d}\n", .{result});
}

pub fn maxJoltage1(path: []const u8) !u64 {
    const file = try fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = (try file.stat()).size;
    const alloc = std.heap.page_allocator;
    const content = try alloc.alloc(u8, file_size);
    defer alloc.free(content);

    _ = try file.readAll(content);
    var lines = std.mem.splitScalar(u8, content, '\n');
    var sum: u64 = 0;
    while (lines.next()) |l| {
        const line = std.mem.trimEnd(u8, l, "\r");
        if (line.len < 2) continue;

        var digits = try alloc.alloc(u8, line.len);
        defer alloc.free(digits);

        for (line, 0..) |d, i| {
            digits[i] = d - '0';
        }

        var suffix_max = try alloc.alloc(u8, digits.len);
        defer alloc.free(suffix_max);

        suffix_max[digits.len - 1] = digits[digits.len - 1];
        var i: usize = digits.len - 1;
        while (i > 0) {
            i -= 1;
            suffix_max[i] = @max(digits[i], suffix_max[i + 1]);
        }

        var best: u64 = 0;
        for (digits, 0..) |d, idx| {
            if (idx + 1 >= digits.len) break;
            const value = 10 * @as(u64, d) + suffix_max[idx + 1];
            if (value > best) best = value;
        }
        sum += best;
    }

    return sum;
}

pub fn maxJoltage2(path: []const u8) !u128 {
    const file = try fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = (try file.stat()).size;
    const alloc = std.heap.page_allocator;

    var reader_buf: [4096]u8 = undefined;
    var reader = file.reader(&reader_buf);
    const content = try reader.interface.readAlloc(alloc, file_size);
    
    var lines = std.mem.splitScalar(u8, content, '\n');
    var sum: u128 = 0;
    while (lines.next()) |l| {
        const line = std.mem.trimEnd(u8, l, "\r");
        if (line.len < 12) continue;

        const k = 12;
        const n = line.len;
        var stack = try std.ArrayList(u8).initCapacity(alloc, k);
        var rem = n;

        for (line) |c| {
            const digit = c - '0';
            while (stack.items.len > 0 and
                stack.items[stack.items.len - 1] < digit and
                stack.items.len - 1 + rem >= k)
            {
                _ = stack.pop();
            }

            if (stack.items.len < k) {
                try stack.append(alloc, digit);
            }
            rem -= 1;
        }

        var value: u128 = 0;
        for (stack.items[0..k]) |d| {
            value = value * 10 + d;
        }

        sum += value;
    }
    return sum;
}
