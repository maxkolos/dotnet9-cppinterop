#include <cstddef>
#include <cstdint>
#include <vector>
#include <string>
#include <cassert>
#include "reverse_string.h"

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    if (size == 0) return 0;

    // преобразуем входные данные в массив char16_t
    size_t length = size / sizeof(char16_t);
    if (length == 0) return 0;

    std::vector<char16_t> arr(length);
    for (size_t i = 0; i < length; ++i) {
        // читаем по 2 байта
        arr[i] = static_cast<char16_t>(
            (static_cast<uint16_t>(data[2*i]) << 8) |
             static_cast<uint16_t>(data[2*i+1])
        );
    }

    // создаем копию, чтобы проверить "двойной реверс"
    std::vector<char16_t> original = arr;

    // первый реверс
    reverse_char16_array(arr.data(), arr.size());

    // второй реверс
    reverse_char16_array(arr.data(), arr.size());

    // массив должен совпасть с оригиналом
    assert(arr == original);

    return 0;
}