namespace IlacTakipApi.Models;

public partial class BloodPressureMeasurement
{
    public int Id { get; set; }

    public int Userid { get; set; }

    public int Systolic { get; set; }

    public int Diastolic { get; set; }

    public int? Pulse { get; set; }

    public DateTime Measurementtime { get; set; }

    public string? Note { get; set; }
}