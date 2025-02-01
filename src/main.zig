const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    // parse ipv4
    const addr = try std.net.Address.parseIp4("0.0.0.0", 8080);

    // tcp listener with backlog of 128 conn
    const listener = std.net.Address.ListenOptions{
        .kernel_backlog = 128,
    };

    // start listening
    var server = try addr.listen(listener);
    defer server.deinit();

    try stdout.print("Server listening on: ", .{});
    try addr.format("", std.fmt.FormatOptions{}, stdout);
    try stdout.print("\n", .{});

    while (true) {
        var connection = try server.accept();
        {
            defer connection.stream.close();

            var buffer: [1024]u8 = undefined;
            const bytesRead = try connection.stream.read(&buffer);
            if (bytesRead > 0) {
                try connection.stream.writeAll(buffer[0..bytesRead]);
            }
        }
    }
}
