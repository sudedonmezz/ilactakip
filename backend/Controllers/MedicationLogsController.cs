using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using IlacTakipApi.Models;

namespace IlacTakipApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MedicationLogsController : ControllerBase
{
    private readonly AppDbContext _context;
    private const int OnTimeToleranceMinutes = 30;

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

        var alreadyLogged = await _context.Medicationlogs
            .FirstOrDefaultAsync(x =>
                x.Medicationid == request.MedicationId &&
                x.Scheduleddatetime == request.ScheduledDateTime
            );

        if (alreadyLogged != null)
        {
            return BadRequest(new
            {
                message = "Bu hatırlatma için zaten kayıt oluşturulmuş."
            });
        }

        var now = DateTime.SpecifyKind(DateTime.Now, DateTimeKind.Unspecified);

        var differenceMinutes = Math.Abs(
            (now - request.ScheduledDateTime).TotalMinutes
        );

        var status = differenceMinutes <= OnTimeToleranceMinutes
            ? "Taken"
            : "Late";

        var log = new Medicationlog
        {
            Medicationid = request.MedicationId,
            Scheduleddatetime = request.ScheduledDateTime,
            Takendatetime = now,
            Status = status,
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
        await CreateMissedLogsForUser(userId);

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

    private async Task CreateMissedLogsForUser(int userId)
    {
        var now = DateTime.SpecifyKind(DateTime.Now, DateTimeKind.Unspecified);

        var schedules = await _context.Medicationschedules
            .Join(
                _context.Medications,
                schedule => schedule.Medicationid,
                medication => medication.Id,
                (schedule, medication) => new
                {
                    schedule,
                    medication
                }
            )
            .Where(x =>
                x.medication.Userid == userId &&
                x.schedule.Isactive == true
            )
            .ToListAsync();

        foreach (var item in schedules)
        {
            var schedule = item.schedule;

            var scheduledDateTime = new DateTime(
                now.Year,
                now.Month,
                now.Day,
                schedule.Hour,
                schedule.Minute,
                0
            );

            if (schedule.Frequencytype == "Daily")
            {
                scheduledDateTime = scheduledDateTime.AddDays(-1);
            }
            else if (schedule.Frequencytype == "Weekly")
            {
                scheduledDateTime = scheduledDateTime.AddDays(-7);
            }
            else if (schedule.Frequencytype == "Once")
            {
                scheduledDateTime = new DateTime(
                    schedule.Startdate.Year,
                    schedule.Startdate.Month,
                    schedule.Startdate.Day,
                    schedule.Hour,
                    schedule.Minute,
                    0
                );
            }
            else
            {
                continue;
            }

            scheduledDateTime = DateTime.SpecifyKind(
                scheduledDateTime,
                DateTimeKind.Unspecified
            );

            if (now < scheduledDateTime.AddHours(24))
            {
                continue;
            }

            var exists = await _context.Medicationlogs.AnyAsync(log =>
                log.Medicationid == schedule.Medicationid &&
                log.Scheduleddatetime == scheduledDateTime
            );

            if (exists)
            {
                continue;
            }

            var missedLog = new Medicationlog
            {
                Medicationid = schedule.Medicationid,
                Scheduleddatetime = scheduledDateTime,
                Takendatetime = null,
                Status = "Missed",
                Note = "Kullanıcı 24 saat içinde alındı olarak işaretlemedi."
            };

            _context.Medicationlogs.Add(missedLog);
        }

        await _context.SaveChangesAsync();
    }
}