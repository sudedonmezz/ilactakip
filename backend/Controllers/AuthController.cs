using Google.Apis.Auth;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using IlacTakipApi.Models;

namespace IlacTakipApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly AppDbContext _context;

    public AuthController(AppDbContext context)
    {
        _context = context;
    }

    [HttpPost("google")]
    public async Task<IActionResult> GoogleLogin(
        [FromBody] GoogleLoginRequest request)
    {
        try
        {
            var payload =
                await GoogleJsonWebSignature.ValidateAsync(request.IdToken);

            var email = payload.Email;
            var fullname = payload.Name ?? "Google Kullanıcısı";

            var user = await _context.Users
                .FirstOrDefaultAsync(x => x.Email == email);

            if (user == null)
            {
                user = new User
                {
                    Fullname = fullname,
                    Email = email,
                    Password = "GOOGLE_LOGIN",
                    Createdat = DateTime.UtcNow
                };

                _context.Users.Add(user);
                await _context.SaveChangesAsync();
            }

           return Ok(new
              {
                  id = user.Id,
                  fullname = user.Fullname,
                  email = user.Email,
                  age = user.Age,
                  gender = user.Gender,
                  weight = user.Weight,
                  height = user.Height,
                  chronicDisease = user.ChronicDisease,
                  createdat = user.Createdat
              });
        }
        catch
        {
            return BadRequest("Geçersiz Google Token");
        }
    }
}