using System;
using System.Collections.Generic;

namespace IlacTakipApi.Models;

public partial class Medication
{
    public int Id { get; set; }

    public int Userid { get; set; }

    public string Name { get; set; } = null!;

    public string? Dosage { get; set; }

    public string? Type { get; set; }

    public string? Notes { get; set; }

    public DateTime? Createdat { get; set; }

    public virtual ICollection<Medicationlog> Medicationlogs { get; set; } = new List<Medicationlog>();

    public virtual ICollection<Medicationschedule> Medicationschedules { get; set; } = new List<Medicationschedule>();

    public virtual User User { get; set; } = null!;
}
