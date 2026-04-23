using System.Net;
using System.Text.Json;

namespace IlacTakipApi.Middlewares;

public class ExceptionMiddleware
{
    private readonly RequestDelegate _next;

    public ExceptionMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception)
        {
            context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
            context.Response.ContentType = "application/json";

            var response = new
            {
                message = "Sunucuda bir hata oluştu"
            };

            await context.Response.WriteAsync(JsonSerializer.Serialize(response));
        }
    }
}