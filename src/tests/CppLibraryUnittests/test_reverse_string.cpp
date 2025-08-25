#define CATCH_CONFIG_MAIN
#include <codecvt>
#include <iterator>
#include <locale>
#include <string>
#include <vector>

#include "catch2/catch.hpp" 

#include "reverse_string.h"

std::string char16_array_to_utf8(const char16_t* arr, size_t len) {
    if (!arr || len == 0) return "";
    std::u16string tmp(arr, len);
    std::wstring_convert<std::codecvt_utf8_utf16<char16_t>, char16_t> convert;
    return convert.to_bytes(tmp);
}

// Helper macros for informative output in case of failure (e.g. "ABC == AAA").

#define REQUIRE_ARRAY_EQ(actual_array, actual_len, expected_u8_literal) \
    REQUIRE(char16_array_to_utf8(actual_array, actual_len) == expected_u8_literal)

TEST_CASE("Handles null pointer") {
    REQUIRE_NOTHROW(reverse_char16_array(nullptr, 10));
}

TEST_CASE("Reverses empty array") {
    std::vector<char16_t> actual;
    reverse_char16_array(actual.data(), 0);
    REQUIRE_ARRAY_EQ(actual.data(), 0, u8"");
}

TEST_CASE("Reverses single char") {
    char16_t actual[] = {u'A'};
    reverse_char16_array(actual, 1);
    REQUIRE_ARRAY_EQ(actual, 1, u8"A");
}

TEST_CASE("Reverses even length array") {
    char16_t actual[] = {u'A', u'B', u'C', u'D'};
    reverse_char16_array(actual, 4);
    REQUIRE_ARRAY_EQ(actual, 4, u8"DCBA");
}

TEST_CASE("Reverses odd length array") {
    char16_t actual[] = {u'A', u'B', u'C', u'D', u'E'};
    reverse_char16_array(actual, 5);
    REQUIRE_ARRAY_EQ(actual, 5, u8"EDCBA");
}

TEST_CASE("Works digits and symbols") {
    char16_t actual[] = {u'A', u'B', u'1', u'+'};
    reverse_char16_array(actual, 4);
    REQUIRE_ARRAY_EQ(actual, 4, u8"+1BA");
}

TEST_CASE("Works with Unicode") {
    char16_t actual[] = { 0x0410, 0x0411, 0x0412 }; // Non-latin characters АБВ.
    reverse_char16_array(actual, 3);
    REQUIRE_ARRAY_EQ(actual, 3, u8"ВБА");
}

TEST_CASE("Doesn't work with surrogate pair (emoji)") {
     // Emoji 😃 (U+1F603) is encoded in UTF-16 as two char16_t elements.
    char16_t actual[] = { 0xD83D, 0xDE03, u'A', u'B' }; // 😃AB
    reverse_char16_array(actual, 4);

    // The surrogate pair will be separated.
    char16_t expected[] = { u'B', u'A', 0xDE03, 0xD83D };
    REQUIRE(std::equal(std::begin(actual), std::end(actual), std::begin(expected)));
}
