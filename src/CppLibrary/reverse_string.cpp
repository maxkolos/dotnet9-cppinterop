#include "reverse_string.h"

#include <algorithm>

void reverse_char16_array(char16_t* char_array, size_t length) {
    if (!char_array) return;

    for (size_t index = 0; index < length / 2; ++index) {
        std::swap(char_array[index], char_array[length - index - 1]);
    }
}