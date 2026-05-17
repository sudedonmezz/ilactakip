using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using IlacTakipApi.Models;

namespace IlacTakipApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TreatmentsController : ControllerBase
{
    private readonly AppDbContext _context;

    public TreatmentsController(AppDbContext context)
    {
        _context = context;
    }

    [HttpPost]
    public async Task<IActionResult> AddTreatment([FromBody] CreateTreatmentRequest request)
    {
        var treatment = new Treatment
        {
            Userid = request.UserId,
            Treatmenttype = request.TreatmentType,
            Name = request.Name,
            Dose = request.Dose,
            Unit = request.Unit,
            Takentime = request.TakenTime,
            Note = request.Note
        };

        _context.Treatments.Add(treatment);
        await _context.SaveChangesAsync();

        return Ok(treatment);
    }

    [HttpGet("user/{userId}")]
    public async Task<IActionResult> GetTreatments(int userId)
    {
        var data = await _context.Treatments
            .Where(x => x.Userid == userId)
            .OrderByDescending(x => x.Takentime)
            .ToListAsync();

        return Ok(data);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteTreatment(int id)
    {
        var treatment = await _context.Treatments.FindAsync(id);

        if (treatment == null)
        {
            return NotFound(new { message = "Tedavi kaydı bulunamadı" });
        }

        _context.Treatments.Remove(treatment);
        await _context.SaveChangesAsync();

        return Ok(new { message = "Tedavi kaydı silindi" });
    }

    
}