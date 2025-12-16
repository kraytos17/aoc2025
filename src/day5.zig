const std = @import("std");
const fs = std.fs;

const Range = struct {
    start: u64,
    end: u64,

    pub fn lessThan(_: void, a: Range, b: Range) bool {
        return a.start < b.start;
    }
};

pub fn main() !void {
    const result = try freshCnt2("input.txt");
    std.debug.print("{d}\n", .{result});
}

pub fn freshCnt1(path: []const u8) !u64 {
    const file = try fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = (try file.stat()).size;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var reader_buf: [4096]u8 = undefined;
    var reader = file.reader(&reader_buf);
    const content = try reader.interface.readAlloc(allocator, file_size);

    var range_list = try std.ArrayList(Range).initCapacity(allocator, 0);
    var it = std.mem.splitSequence(u8, content, "\n\n");
    if (it.next()) |ranges| {
        var lines = std.mem.tokenizeScalar(u8, ranges, '\n');
        while (lines.next()) |line| {
            var parts = std.mem.tokenizeScalar(u8, line, '-');
            const start = parts.next() orelse continue;
            const end = parts.next() orelse continue;
            const r = Range{
                .start = try std.fmt.parseInt(u64, start, 10),
                .end = try std.fmt.parseInt(u64, end, 10),
            };

            try range_list.append(allocator, r);
        }
    }

    var fresh_cnt: u64 = 0;
    if (it.next()) |ings| {
        var lines = std.mem.tokenizeScalar(u8, ings, '\n');
        while (lines.next()) |line| {
            const id = try std.fmt.parseInt(u64, line, 10);
            var is_fresh = false;
            for (range_list.items) |r| {
                if (id >= r.start and id <= r.end) {
                    is_fresh = true;
                    break;
                }
            }

            if (is_fresh) {
                fresh_cnt += 1;
            }
        }
    }
    return fresh_cnt;
}

pub fn freshCnt2(path: []const u8) !u64 {
    const file = try fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = (try file.stat()).size;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var reader_buf: [4096]u8 = undefined;
    var reader = file.reader(&reader_buf);
    const content = try reader.interface.readAlloc(allocator, file_size);

    var range_list = try std.ArrayList(Range).initCapacity(allocator, 0);
    var it = std.mem.splitSequence(u8, content, "\n\n");
    const range_section = it.next() orelse return 0;
    var lines = std.mem.tokenizeScalar(u8, range_section, '\n');
    while (lines.next()) |line| {
        var parts = std.mem.tokenizeScalar(u8, line, '-');
        const s = parts.next() orelse continue;
        const e = parts.next() orelse continue;
        const r = Range{
            .start = try std.fmt.parseInt(u64, s, 10),
            .end = try std.fmt.parseInt(u64, e, 10),
        };

        try range_list.append(allocator, r);
    }

    const ranges = range_list.items;
    if (ranges.len == 0) return 0;

    std.mem.sortUnstable(Range, ranges, {}, Range.lessThan);
    var fresh_cnt: u64 = 0;
    var curr_s = ranges[0].start;
    var curr_e = ranges[0].end;
    for (ranges[1..]) |r| {
        if (r.start <= curr_e + 1) {
            if (r.end > curr_e) {
                curr_e = r.end;
            }
        } else {
            fresh_cnt += (curr_e - curr_s + 1);
            curr_s = r.start;
            curr_e = r.end;
        }
    }

    fresh_cnt += (curr_e - curr_s + 1);
    return fresh_cnt;
}
