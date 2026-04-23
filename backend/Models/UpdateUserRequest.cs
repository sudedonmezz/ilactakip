namespace IlacTakipApi.Models;

public class UpdateUserRequest
{
    public string Fullname { get; set; } = string.Empty;
    public int? Age { get; set; }
    public string? Gender { get; set; }
    public decimal? Weight { get; set; }
    public decimal? Height { get; set; }
    public string? ChronicDisease { get; set; }
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}