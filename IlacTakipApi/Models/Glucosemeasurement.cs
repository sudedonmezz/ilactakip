using System;
using System.Collections.Generic;

namespace IlacTakipApi.Models;

public partial class Glucosemeasurement
{
    public int Id { get; set; }

    public int Userid { get; set; }

    public decimal Value { get; set; }

    public DateTime Measurementtime { get; set; }

    public string? Measurementtype { get; set; }

    public string? Note { get; set; }

    public virtual User User { get; set; } = null!;
}
