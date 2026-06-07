namespace IlacTakipApi.Models;

public class PasswordResetChangePasswordRequest
{
    public string Email { get; set; } = null!;
    public string Code { get; set; } = null!;
    public string NewPassword { get; set; } = null!;
}