#ifndef REVERSE_STRING_H
#define REVERSE_STRING_H

#include <cstddef>
#include <cstdint>

#ifdef __cplusplus
extern "C" {
#endif

// Reverses the `char_array` containing string `length` elements in-place. If `char_array` is null,
// it does nothing. Note: the method doesn't handle surrogate pairs correctly, i.e. symbols represented
// by several char16 elements (e.g. emoji).
void reverse_char16_array(char16_t* char_array, size_t length);

#ifdef __cplusplus
}
#endif

#endif // REVERSE_STRING_H