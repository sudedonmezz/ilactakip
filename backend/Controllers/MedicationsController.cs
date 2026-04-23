using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using IlacTakipApi.Models;

namespace IlacTakipApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MedicationsController : ControllerBase
{
    private readonly AppDbContext _context;

    public MedicationsController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet("user/{userId}")]
    public async Task<IActionResult> GetMedicationsByUser(int userId)
    {
        var medications = await _context.Medications
            .Where(m => m.Userid == userId)
            .ToListAsync();

        return Ok(medications);
    }

   [HttpPost]
public async Task<IActionResult> CreateMedication([FromBody] CreateMedicationRequest request)
{
    if (request.UserId <= 0)
    {
        return BadRequest(new { message = "Geçersiz kullanıcı bilgisi" });
    }

    if (string.IsNullOrWhiteSpace(request.Name))
    {
        return BadRequest(new { message = "İlaç adı boş olamaz" });
    }

    var user = await _context.Users.FindAsync(request.UserId);

    if (user == null)
    {
        return NotFound(new { message = "Kullanıcı bulunamadı" });
    }

    var medication = new Medication
    {
        Userid = request.UserId,
        Name = request.Name,
        Dosage = request.Dosage,
        Type = request.Type,
        Notes = request.Notes,
        Createdat = DateTime.Now
    };

    _context.Medications.Add(medication);
    await _context.SaveChangesAsync();

return Ok(new
{
    id = medication.Id,
    userId = medication.Userid,
    name = medication.Name,
    dosage = medication.Dosage,
    type = medication.Type,
    notes = medication.Notes,
    createdAt = medication.Createdat
});
}
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteMedication(int id)
    {
        var medication = await _context.Medications.FindAsync(id);

        if (medication == null)
        {
            return NotFound(new { message = "İlaç bulunamadı" });
        }

        _context.Medications.Remove(medication);
        await _context.SaveChangesAsync();

        return Ok(new { message = "İlaç silindi" });
    }
}