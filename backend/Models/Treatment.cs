using System;
using System.Collections.Generic;

namespace IlacTakipApi.Models;

public partial class Treatment
{
    public int Id { get; set; }

    public int Userid { get; set; }

    public string Treatmenttype { get; set; } = null!;

    public string Name { get; set; } = null!;

    public decimal? Dose { get; set; }

    public string? Unit { get; set; }

    public DateTime Takentime { get; set; }

    public string? Note { get; set; }
}