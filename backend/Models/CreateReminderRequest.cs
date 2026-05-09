namespace IlacTakipApi.Models;

public class CreateReminderRequest
{
    public int MedicationId { get; set; }
    public int Hour { get; set; }
    public int Minute { get; set; }
    public string FrequencyType { get; set; } = "Daily";
    public DateOnly StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
}