using System;
using System.Collections.Generic;

namespace IlacTakipApi.Models;

public partial class User
{
    public int Id { get; set; }

    public string Fullname { get; set; } = null!;

    public int? Age { get; set; }

    public string? Gender { get; set; }

    public decimal? Weight { get; set; }

    public decimal? Height { get; set; }

    public string? ChronicDisease { get; set; }

    public string Email { get; set; } = null!;

    public string Password { get; set; } = null!;

    public DateTime? Createdat { get; set; }

    public virtual ICollection<Glucosemeasurement> Glucosemeasurements { get; set; } = new List<Glucosemeasurement>();

    public virtual ICollection<Medication> Medications { get; set; } = new List<Medication>();
}
