using Microsoft.AspNetCore.Mvc;
using StringService;

namespace Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ReverseController : ControllerBase
    {
        [HttpPost]
        public IActionResult Reverse([FromBody] ReverseRequest request)
        {
            if (request?.Text == null)
                return BadRequest(new { Error = "'text' field is required." });

            var result = StringReverser.Reverse(request.Text);
            return Ok(new { Reversed = result });
        }
    }

    public class ReverseRequest
    {
        public string? Text { get; set; }
    }
}