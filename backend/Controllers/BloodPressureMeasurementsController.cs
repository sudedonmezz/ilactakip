using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using IlacTakipApi.Models;

namespace IlacTakipApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BloodPressureMeasurementsController : ControllerBase
{
    private readonly AppDbContext _context;

    public BloodPressureMeasurementsController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet("user/{userId}")]
    public async Task<IActionResult> GetByUser(int userId)
    {
        var data = await _context.BloodPressureMeasurements
            .Where(x => x.Userid == userId)
            .OrderByDescending(x => x.Measurementtime)
            .ToListAsync();

        return Ok(data);
    }

    [HttpPost]
public async Task<IActionResult> Create([FromBody] BloodPressureMeasurement item)
{
    if (item.Userid <= 0)
        return BadRequest(new { message = "Geçersiz kullanıcı bilgisi" });

    if (item.Systolic <= 0 || item.Diastolic <= 0)
        return BadRequest(new { message = "Tansiyon değerleri geçersiz" });

    item.Measurementtime = item.Measurementtime.ToUniversalTime();

    _context.BloodPressureMeasurements.Add(item);
    await _context.SaveChangesAsync();

    return Ok(item);
}

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var item = await _context.BloodPressureMeasurements.FindAsync(id);

        if (item == null)
            return NotFound(new { message = "Tansiyon ölçümü bulunamadı" });

        _context.BloodPressureMeasurements.Remove(item);
        await _context.SaveChangesAsync();

        return Ok(new { message = "Tansiyon ölçümü silindi" });
    }
}