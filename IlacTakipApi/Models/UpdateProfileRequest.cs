public class UpdateProfileRequest
{
    public int? Age { get; set; }
    public string? Gender { get; set; }
    public decimal? Weight { get; set; }
    public decimal? Height { get; set; }

    public string? ChronicDisease { get; set; } = string.Empty;
}