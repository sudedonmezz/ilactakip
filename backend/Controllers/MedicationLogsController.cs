using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using IlacTakipApi.Models;

namespace IlacTakipApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MedicationLogsController : ControllerBase
{
    private readonly AppDbContext _context;

    public MedicationLogsController(AppDbContext context)
    {
        _context = context;
    }

   [HttpPost("taken")]
public async Task<IActionResult> MarkAsTaken([FromBody] CreateMedicationLogRequest request)
{
    var medication = await _context.Medications.FindAsync(request.MedicationId);

    if (medication == null)
    {
        return NotFound(new { message = "İlaç bulunamadı" });
    }

    var alreadyTaken = await _context.Medicationlogs
        .AnyAsync(x =>
            x.Medicationid == request.MedicationId &&
            x.Scheduleddatetime == request.ScheduledDateTime &&
            x.Status == "Taken"
        );

    if (alreadyTaken)
    {
        return BadRequest(new { message = "Bu hatırlatma zaten alındı olarak işaretlenmiş" });
    }

    var log = new Medicationlog
    {
        Medicationid = request.MedicationId,
        Scheduleddatetime = request.ScheduledDateTime,
        Takendatetime = DateTime.Now,
        Status = "Taken",
        Note = request.Note
    };

    _context.Medicationlogs.Add(log);
    await _context.SaveChangesAsync();

    return Ok(new
    {
        id = log.Id,
        medicationId = log.Medicationid,
        medicationName = medication.Name,
        scheduledDateTime = log.Scheduleddatetime,
        takenDateTime = log.Takendatetime,
        status = log.Status,
        note = log.Note
    });
}

    [HttpGet("user/{userId}")]
    public async Task<IActionResult> GetLogsByUser(int userId)
    {
        var logs = await _context.Medicationlogs
            .Join(
                _context.Medications,
                log => log.Medicationid,
                medication => medication.Id,
                (log, medication) => new
                {
                    log,
                    medication
                }
            )
            .Where(x => x.medication.Userid == userId)
            .OrderByDescending(x => x.log.Scheduleddatetime)
            .Select(x => new
            {
                id = x.log.Id,
                medicationId = x.log.Medicationid,
                medicationName = x.medication.Name,
                scheduledDateTime = x.log.Scheduleddatetime,
                takenDateTime = x.log.Takendatetime,
                status = x.log.Status,
                note = x.log.Note
            })
            .ToListAsync();

        return Ok(logs);
    }
}