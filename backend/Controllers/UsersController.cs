using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using IlacTakipApi.Models;

namespace IlacTakipApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly AppDbContext _context;

    public UsersController(AppDbContext context)
    {
        _context = context;
    }

   
    [HttpGet]
    public async Task<IActionResult> GetUsers()
    {
        var users = await _context.Users.ToListAsync();
        return Ok(users);
    }

   [HttpPost]
public async Task<IActionResult> CreateUser([FromBody] User user)
{
    try
    {
        var existingUser = await _context.Users
            .FirstOrDefaultAsync(u => u.Email == user.Email);

        if (existingUser != null)
        {
            return BadRequest(new
            {
                message = "Bu email zaten sisteme kayıtlı"
            });
        }

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        return Ok(user);
    }
    catch (Exception)
    {
        return StatusCode(500, new
        {
            message = "Bir hata oluştu"
        });
    }
}

    [HttpPost("login")]
public async Task<IActionResult> Login([FromBody] LoginRequest request)
{
    var user = await _context.Users
        .FirstOrDefaultAsync(u =>
            u.Email == request.Email &&
            u.Password == request.Password
        );

    if (user == null)
    {
        return Unauthorized(new
        {
            message = "Email veya şifre hatalı"
        });
    }

    return Ok(user);
}

[HttpPut("{id}/profile")]
public async Task<IActionResult> UpdateProfile(int id, [FromBody] User updatedUser)
{
    var user = await _context.Users.FindAsync(id);

    if (user == null)
    {
        return NotFound(new { message = "Kullanıcı bulunamadı" });
    }

    user.Age = updatedUser.Age;
    user.Gender = updatedUser.Gender;
    user.Weight = updatedUser.Weight;
    user.Height = updatedUser.Height;
    user.ChronicDisease = updatedUser.ChronicDisease;

    await _context.SaveChangesAsync();

    return Ok(user);
}

[HttpPut("{id}")]
public async Task<IActionResult> UpdateUser(int id, [FromBody] UpdateUserRequest request)
{
    var user = await _context.Users.FindAsync(id);

    if (user == null)
    {
        return NotFound(new { message = "Kullanıcı bulunamadı" });
    }

    var emailExists = await _context.Users
        .AnyAsync(u => u.Email == request.Email && u.Id != id);

    if (emailExists)
    {
        return BadRequest(new { message = "Bu email zaten sisteme kayıtlı" });
    }

    user.Fullname = request.Fullname;
    user.Age = request.Age;
    user.Gender = request.Gender;
    user.Weight = request.Weight;
    user.Height = request.Height;
    user.ChronicDisease = request.ChronicDisease;
    user.Email = request.Email;
    user.Password = request.Password;

    await _context.SaveChangesAsync();

    return Ok(user);
}

[HttpPatch("{id}/profile")]
public async Task<IActionResult> PatchProfile(int id, [FromBody] UpdateProfileRequest request)
{
    var user = await _context.Users.FindAsync(id);

    if (user == null)
    {
        return NotFound(new { message = "Kullanıcı bulunamadı" });
    }

    if (request.Age != null)
        user.Age = request.Age;

    if (request.Gender != null)
        user.Gender = request.Gender;

    if (request.Weight != null)
        user.Weight = request.Weight;

    if (request.Height != null)
        user.Height = request.Height;

    if (request.ChronicDisease != null)
        user.ChronicDisease = request.ChronicDisease;

    await _context.SaveChangesAsync();

    return Ok(user);
}

[HttpGet("{id}")]
public async Task<IActionResult> GetUserById(int id)
{
    var user = await _context.Users.FindAsync(id);

    if (user == null)
    {
        return NotFound(new { message = "Kullanıcı bulunamadı" });
    }

    return Ok(user);
}
}