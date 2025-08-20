using System.Net.Http.Json;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

public class ReverseControllerTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _app;

    public ReverseControllerTests(WebApplicationFactory<Program> app)
    {
        _app = app;
    }

    [Fact]
    public async Task Reverse_Returns200_AndResult()
    {
        var client = _app.CreateClient();
        var resp = await client.PostAsJsonAsync("/Reverse", new { text = "hello" });
        resp.EnsureSuccessStatusCode();

        var body = await resp.Content.ReadFromJsonAsync<ResponseDto>();
        body!.Reversed.Should().Be("olleh");
    }

    [Fact]
    public async Task Reverse_MissingText_Returns400()
    {
        var client = _app.CreateClient();
        var resp = await client.PostAsJsonAsync("/Reverse", new { });
        ((int)resp.StatusCode).Should().Be(400);
    }

    private record ResponseDto(string Reversed);
}