const std = @import("std");

pub fn main() !void {
    const result = try invalidIds2("input.txt");
    std.debug.print("{d}\n", .{result});
}

pub fn invalidIds1(path: []const u8) !u64 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = (try file.stat()).size;
    const alloc = std.heap.page_allocator;
    const content = try alloc.alloc(u8, file_size);
    defer alloc.free(content);

    _ = try file.readAll(content);
    var lines = std.mem.splitScalar(u8, content, ',');
    var sum: u64 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var parts = std.mem.splitScalar(u8, line, '-');
        var start = parts.next() orelse continue;
        start = std.mem.trim(u8, start, "\r\n\t");
        var end = parts.next() orelse continue;
        end = std.mem.trim(u8, end, "\r\n\t");
        const s = try std.fmt.parseInt(u64, start, 10);
        const e = try std.fmt.parseInt(u64, end, 10);
        var x = s;
        while (x <= e) : (x += 1) {
            if (try isInvalidId1(x)) {
                sum += x;
            }
        }
    }

    return sum;
}

pub fn invalidIds2(path: []const u8) !u64 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = (try file.stat()).size;
    const alloc = std.heap.page_allocator;
    const content = try alloc.alloc(u8, file_size);
    defer alloc.free(content);

    _ = try file.readAll(content);
    var lines = std.mem.splitScalar(u8, content, ',');
    var sum: u64 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var parts = std.mem.splitScalar(u8, line, '-');
        var start = parts.next() orelse continue;
        start = std.mem.trim(u8, start, "\r\n\t");
        var end = parts.next() orelse continue;
        end = std.mem.trim(u8, end, "\r\n\t");
        const s = try std.fmt.parseInt(u64, start, 10);
        const e = try std.fmt.parseInt(u64, end, 10);
        var x = s;
        while (x <= e) : (x += 1) {
            if (try isInvalidId2(x)) {
                sum += x;
            }
        }
    }

    return sum;
}

fn isInvalidId1(n: u64) !bool {
    var buf: [32]u8 = undefined;
    const s = try std.fmt.bufPrint(&buf, "{d}", .{n});
    if (s.len % 2 != 0) return false;

    const half = s.len / 2;
    const first = s[0..half];
    const second = s[half..];
    return std.mem.eql(u8, first, second);
}

fn isInvalidId2(n: u64) !bool {
    var buf: [32]u8 = undefined;
    const s = try std.fmt.bufPrint(&buf, "{d}", .{n});
    const len = s.len;
    if (len < 2) return false;

    var block: usize = 1;
    while (block <= len / 2) : (block += 1) {
        if (len % block != 0) continue;

        const repeat_count = len / block;
        if (repeat_count < 2) continue;

        const T = s[0..block];
        var good = true;
        var i: usize = block;
        while (i < len) : (i += block) {
            if (!std.mem.eql(u8, T, s[i .. i + block])) {
                good = false;
                break;
            }
        }

        if (good) return true;
    }
    return false;
}
