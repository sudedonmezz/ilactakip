using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using IlacTakipApi.Models;

namespace IlacTakipApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class GlucoseMeasurementsController : ControllerBase
{
    private readonly AppDbContext _context;

    public GlucoseMeasurementsController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet("user/{userId}")]
    public async Task<IActionResult> GetMeasurementsByUser(int userId)
    {
        var measurements = await _context.Glucosemeasurements
            .Where(x => x.Userid == userId)
            .OrderByDescending(x => x.Measurementtime)
            .Select(x => new
            {
                id = x.Id,
                userId = x.Userid,
                value = x.Value,
                measurementTime = x.Measurementtime,
                measurementType = x.Measurementtype,
                note = x.Note
            })
            .ToListAsync();

        return Ok(measurements);
    }

    [HttpPost]
    public async Task<IActionResult> CreateMeasurement([FromBody] CreateGlucoseMeasurementRequest request)
    {
        if (request.UserId <= 0)
        {
            return BadRequest(new { message = "Geçersiz kullanıcı bilgisi" });
        }

        if (request.Value <= 0)
        {
            return BadRequest(new { message = "Kan şekeri değeri geçersiz" });
        }

        var user = await _context.Users.FindAsync(request.UserId);

        if (user == null)
        {
            return NotFound(new { message = "Kullanıcı bulunamadı" });
        }

        var measurement = new Glucosemeasurement
        {
            Userid = request.UserId,
            Value = request.Value,
            Measurementtime = request.MeasurementTime,
            Measurementtype = request.MeasurementType,
            Note = request.Note
        };

        _context.Glucosemeasurements.Add(measurement);
        await _context.SaveChangesAsync();

        return Ok(new
        {
            id = measurement.Id,
            userId = measurement.Userid,
            value = measurement.Value,
            measurementTime = measurement.Measurementtime,
            measurementType = measurement.Measurementtype,
            note = measurement.Note
        });
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteMeasurement(int id)
    {
        var measurement = await _context.Glucosemeasurements.FindAsync(id);

        if (measurement == null)
        {
            return NotFound(new { message = "Ölçüm bulunamadı" });
        }

        _context.Glucosemeasurements.Remove(measurement);
        await _context.SaveChangesAsync();

        return Ok(new { message = "Ölçüm silindi" });
    }
}