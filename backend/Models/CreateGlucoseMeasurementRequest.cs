namespace IlacTakipApi.Models;

public class CreateGlucoseMeasurementRequest
{
    public int UserId { get; set; }

    public decimal Value { get; set; }

    public DateTime MeasurementTime { get; set; } = DateTime.Now;

    public string? MeasurementType { get; set; }

    public string? Note { get; set; }
}