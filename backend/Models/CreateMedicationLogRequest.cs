namespace IlacTakipApi.Models;

public class CreateMedicationLogRequest
{
    public int MedicationId { get; set; }
    public DateTime ScheduledDateTime { get; set; }
    public string? Note { get; set; }
}