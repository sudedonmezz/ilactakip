namespace IlacTakipApi.Models;

public partial class Passwordresetcode
{
    public int Id { get; set; }

    public string Email { get; set; } = null!;

    public string Code { get; set; } = null!;

    public DateTime Expiresat { get; set; }

    public bool Isused { get; set; }

    public int Attemptcount { get; set; }

    public DateTime Createdat { get; set; }
}