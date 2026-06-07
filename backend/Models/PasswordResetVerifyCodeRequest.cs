namespace IlacTakipApi.Models;

public class PasswordResetVerifyCodeRequest
{
    public string Email { get; set; } = null!;
    public string Code { get; set; } = null!;
}