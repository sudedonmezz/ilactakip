using System.Net;
using System.Net.Mail;
using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using IlacTakipApi.Models;

namespace IlacTakipApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PasswordResetController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly IConfiguration _configuration;

    public PasswordResetController(
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
        [FromBody] PasswordResetSendCodeRequest request)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(x => x.Email == request.Email);

        if (user == null)
            return BadRequest(new { message = "Bu email adresiyle kayıtlı kullanıcı bulunamadı." });

        var code = new Random().Next(100000, 999999).ToString();
        var hashedCode = HashCode(code);

        var resetCode = new Passwordresetcode
        {
            Email = request.Email,
            Code = hashedCode,
            Expiresat = DateTime.UtcNow.AddMinutes(10),
            Isused = false,
            Attemptcount = 0,
            Createdat = DateTime.UtcNow
        };

        _context.Passwordresetcodes.Add(resetCode);
        await _context.SaveChangesAsync();

        await SendEmailAsync(request.Email, code);

        return Ok(new
        {
            message = "Şifre sıfırlama kodu email adresinize gönderildi."
        });
    }

    [HttpPost("verify-code")]
    public async Task<IActionResult> VerifyCode(
        [FromBody] PasswordResetVerifyCodeRequest request)
    {
        var hashedCode = HashCode(request.Code);

        var resetCode = await _context.Passwordresetcodes
            .Where(x =>
                x.Email == request.Email &&
                x.Code == hashedCode &&
                !x.Isused)
            .OrderByDescending(x => x.Createdat)
            .FirstOrDefaultAsync();

        if (resetCode == null)
            return BadRequest(new { message = "Kod hatalı." });

        if (resetCode.Expiresat < DateTime.UtcNow)
            return BadRequest(new { message = "Kodun süresi doldu." });

        return Ok(new
        {
            message = "Kod doğrulandı."
        });
    }

    [HttpPost("change-password")]
    public async Task<IActionResult> ChangePassword(
        [FromBody] PasswordResetChangePasswordRequest request)
    {
        var hashedCode = HashCode(request.Code);

        var resetCode = await _context.Passwordresetcodes
            .Where(x =>
                x.Email == request.Email &&
                x.Code == hashedCode &&
                !x.Isused)
            .OrderByDescending(x => x.Createdat)
            .FirstOrDefaultAsync();

        if (resetCode == null)
            return BadRequest(new { message = "Kod hatalı." });

        if (resetCode.Expiresat < DateTime.UtcNow)
            return BadRequest(new { message = "Kodun süresi doldu." });

        var user = await _context.Users
            .FirstOrDefaultAsync(x => x.Email == request.Email);

        if (user == null)
            return BadRequest(new { message = "Kullanıcı bulunamadı." });

        user.Password = request.NewPassword;
        resetCode.Isused = true;

        await _context.SaveChangesAsync();

        return Ok(new
        {
            message = "Şifre başarıyla güncellendi."
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
            Subject = "İlaç Takip Şifre Sıfırlama Kodu",
            Body = $"Şifre sıfırlama kodunuz: {code}\n\nBu kod 10 dakika geçerlidir.",
            IsBodyHtml = false
        };

        mail.To.Add(toEmail);

        await smtp.SendMailAsync(mail);
    }
}