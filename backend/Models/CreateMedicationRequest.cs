namespace IlacTakipApi.Models;

public class CreateMedicationRequest
{
    public int UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Dosage { get; set; }
    public string? Type { get; set; }
    public string? Notes { get; set; }
}