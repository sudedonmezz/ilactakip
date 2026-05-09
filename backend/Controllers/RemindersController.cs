using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using IlacTakipApi.Models;

namespace IlacTakipApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class RemindersController : ControllerBase
{
    private readonly AppDbContext _context;

    public RemindersController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet("user/{userId}")]
    public async Task<IActionResult> GetRemindersByUser(int userId)
    {
        var reminders = await _context.Medicationschedules
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
            .Where(x => x.medication.Userid == userId && x.schedule.Isactive == true)
            .Select(x => new
            {
                id = x.schedule.Id,
                medicationId = x.schedule.Medicationid,
                medicationName = x.medication.Name,
                hour = x.schedule.Hour,
                minute = x.schedule.Minute,
                frequencyType = x.schedule.Frequencytype,
                startDate = x.schedule.Startdate,
                endDate = x.schedule.Enddate,
                isActive = x.schedule.Isactive
            })
            .ToListAsync();

        return Ok(reminders);
    }

    [HttpPost]
    public async Task<IActionResult> CreateReminder([FromBody] CreateReminderRequest request)
    {
        var medication = await _context.Medications.FindAsync(request.MedicationId);

        if (medication == null)
        {
            return NotFound(new { message = "İlaç bulunamadı" });
        }

        var reminder = new Medicationschedule
        {
            Medicationid = request.MedicationId,
            Hour = request.Hour,
            Minute = request.Minute,
            Frequencytype = request.FrequencyType,
            Startdate = request.StartDate,
            Enddate = request.EndDate,
            Isactive = true
        };

        _context.Medicationschedules.Add(reminder);
        await _context.SaveChangesAsync();

        return Ok(new
        {
            id = reminder.Id,
            medicationId = reminder.Medicationid,
            medicationName = medication.Name,
            hour = reminder.Hour,
            minute = reminder.Minute,
            frequencyType = reminder.Frequencytype,
            startDate = reminder.Startdate,
            endDate = reminder.Enddate,
            isActive = reminder.Isactive
        });
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteReminder(int id)
    {
        var reminder = await _context.Medicationschedules.FindAsync(id);

        if (reminder == null)
        {
            return NotFound(new { message = "Hatırlatma bulunamadı" });
        }

        reminder.Isactive = false;
        await _context.SaveChangesAsync();

        return Ok(new { message = "Hatırlatma silindi" });
    }
}