namespace IlacTakipApi.Models;

public class CreateTreatmentRequest
{
    public int UserId { get; set; }
    public string TreatmentType { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public decimal? Dose { get; set; }
    public string? Unit { get; set; }
    public DateTime TakenTime { get; set; } = DateTime.Now;
    public string? Note { get; set; }
}