using System.Net;
using System.Net.Mail;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using IlacTakipApi.Models;
using System.Security.Cryptography;
using System.Text;

namespace IlacTakipApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class EmailVerificationController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly IConfiguration _configuration;

    public EmailVerificationController(
        AppDbContext context,
        IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

        private string HashCode(string code)
{
    using var sha256 = SHA256.Create();

    var bytes = sha256.ComputeHash(
        Encoding.UTF8.GetBytes(code)
    );

    return Convert.ToHexString(bytes);
}

    [HttpPost("send-code")]
    public async Task<IActionResult> SendCode(
        [FromBody] EmailVerificationRequest request)
    {
        var exists = await _context.Users
            .AnyAsync(x => x.Email == request.Email);

        if (exists)
            return BadRequest(new { message = "Bu email zaten kayıtlı." });

            var code = new Random().Next(100000, 999999).ToString();

        var hashedCode = HashCode(code);

        var verification = new Emailverificationcode
        {
            Fullname = request.Fullname,
            Email = request.Email,
            Password = request.Password,
            Code = hashedCode,
            Expiresat = DateTime.UtcNow.AddMinutes(10),
Isused = false,
Createdat = DateTime.UtcNow
        };

        _context.Emailverificationcodes.Add(verification);
        await _context.SaveChangesAsync();

        await SendEmailAsync(request.Email, code);

        return Ok(new { message = "Doğrulama kodu email adresinize gönderildi." });
    }



    [HttpPost("verify-code")]
    public async Task<IActionResult> VerifyCode(
        [FromBody] VerifyCodeRequest request)
    {
      var hashedCode = HashCode(request.Code);
        var verification = await _context.Emailverificationcodes
           .Where(x =>
    x.Email == request.Email &&
    x.Code == hashedCode &&
    !x.Isused)
            .OrderByDescending(x => x.Createdat)
            .FirstOrDefaultAsync();

        if (verification == null)
            return BadRequest(new { message = "Doğrulama kodu hatalı." });

        if (verification.Expiresat < DateTime.UtcNow)
            return BadRequest(new { message = "Doğrulama kodunun süresi doldu." });

        var exists = await _context.Users
            .AnyAsync(x => x.Email == request.Email);

        if (exists)
            return BadRequest(new { message = "Bu email zaten kayıtlı." });

        var user = new User
{
    Fullname = verification.Fullname,
    Email = verification.Email,
    Password = verification.Password,
    Createdat = DateTime.SpecifyKind(DateTime.Now, DateTimeKind.Unspecified)
};

        verification.Isused = true;

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

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

    private async Task SendEmailAsync(string toEmail, string code)
    {
        var fromEmail = _configuration["EmailSettings:Email"];
        var appPassword = _configuration["EmailSettings:AppPassword"];

        var smtp = new SmtpClient("smtp.gmail.com")
        {
            Port = 587,
            Credentials = new NetworkCredential(fromEmail, appPassword),
            EnableSsl = true
        };

        var mail = new MailMessage
        {
            From = new MailAddress(fromEmail!),
            Subject = "İlaç Takip Doğrulama Kodu",
            Body = $"Doğrulama kodunuz: {code}\n\nBu kod 10 dakika geçerlidir.",
            IsBodyHtml = false
        };

        mail.To.Add(toEmail);

        await smtp.SendMailAsync(mail);
    }
}