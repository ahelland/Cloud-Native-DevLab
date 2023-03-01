var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

app.MapGet("/time", () =>
{
    var now = DateTime.Now.ToString();
    return now;
});

app.Run();
