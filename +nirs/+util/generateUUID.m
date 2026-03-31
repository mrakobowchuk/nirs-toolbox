function uuid = generateUUID()
% generateUUID  Generate a UUID v4 string without Java dependencies.
%
% Returns a random UUID string in the standard 8-4-4-4-12 hexadecimal
% format, e.g. '550e8400-e29b-41d4-a716-446655440000'.
%
% This function provides a pure-MATLAB alternative to java.util.UUID.randomUUID
% for compatibility with MATLAB R2025a and later, which no longer support
% Java-based UUID generation in all configurations.

data = uint8(randi([0 255], 1, 16));
data(7) = bitor(bitand(data(7), uint8(15)), uint8(64));   % Set version to 4
data(9) = bitor(bitand(data(9), uint8(63)), uint8(128));  % Set variant bits

uuid = sprintf('%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x', ...
    data(1), data(2), data(3), data(4), ...
    data(5), data(6), ...
    data(7), data(8), ...
    data(9), data(10), ...
    data(11), data(12), data(13), data(14), data(15), data(16));
end
