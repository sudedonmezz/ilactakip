using System;
using System.Collections.Generic;

namespace IlacTakipApi.Models;

public partial class Medicationschedule
{
    public int Id { get; set; }

    public int Medicationid { get; set; }

    public int Hour { get; set; }

    public int Minute { get; set; }

    public string Frequencytype { get; set; } = null!;

    public DateOnly Startdate { get; set; }

    public DateOnly? Enddate { get; set; }

    public bool Isactive { get; set; }

    public virtual Medication Medication { get; set; } = null!;
}
