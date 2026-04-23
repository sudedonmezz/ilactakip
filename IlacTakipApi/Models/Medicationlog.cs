using System;
using System.Collections.Generic;

namespace IlacTakipApi.Models;

public partial class Medicationlog
{
    public int Id { get; set; }

    public int Medicationid { get; set; }

    public DateTime Scheduleddatetime { get; set; }

    public DateTime? Takendatetime { get; set; }

    public string Status { get; set; } = null!;

    public string? Note { get; set; }

    public virtual Medication Medication { get; set; } = null!;
}
