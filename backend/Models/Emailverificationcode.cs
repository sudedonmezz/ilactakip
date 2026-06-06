namespace IlacTakipApi.Models;

public partial class Emailverificationcode
{
    public int Id { get; set; }

    public string Fullname { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string Password { get; set; } = null!;

    public string Code { get; set; } = null!;

    public DateTime Expiresat { get; set; }

    public bool Isused { get; set; }

    public DateTime Createdat { get; set; }
}