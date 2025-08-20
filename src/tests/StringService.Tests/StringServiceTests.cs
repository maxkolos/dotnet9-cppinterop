
using FluentAssertions;
using Xunit;
using StringService;

public class StringServiceTests
{
    [Fact]
    public void Reverse_Ascii()
    {
        StringReverser.Reverse("hello").Should().Be("olleh");
    }

    [Fact]
    public void Reverse_NonAscii()
    {
        StringReverser.Reverse("привет").Should().Be("тевирп");
    }

    [Fact]
    public void Reverse_Empty()
    {
        StringReverser.Reverse("").Should().Be("");
    }

    [Fact]
    public void Reverse_Null_ReturnsNull()
    {
        StringReverser.Reverse(null!).Should().BeNull();
    }

    [Fact]
    public void Reverse_DoubleReverse_Restores()
    {
        var input = "abc def";
        var reversed = StringReverser.Reverse(input);
        reversed.Should().NotBeNull();
        var doubly_reversed = StringReverser.Reverse(reversed!);
        doubly_reversed.Should().Be(input);
    }
}