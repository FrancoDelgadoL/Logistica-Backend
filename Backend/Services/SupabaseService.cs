using System;
using System.Threading.Tasks;
using Supabase;
using Microsoft.Extensions.Configuration;

namespace Backend.Services
{
    public class SupabaseService : ISupabaseService
    {
        public Client Client { get; private set; }

        public SupabaseService(IConfiguration configuration)
        {
            // Leer variables de entorno
            var url = Environment.GetEnvironmentVariable("SUPABASE_URL") 
                      ?? configuration["Supabase:Url"];
            
            var key = Environment.GetEnvironmentVariable("SUPABASE_KEY") 
                      ?? configuration["Supabase:Key"];

            if (string.IsNullOrEmpty(url) || string.IsNullOrEmpty(key))
            {
                throw new Exception("❌ Faltan SUPABASE_URL o SUPABASE_KEY");
            }

            var options = new SupabaseOptions
            {
                AutoRefreshToken = true,
                AutoConnectRealtime = true
            };

            Client = new Supabase.Client(url, key, options);
        }

        public async Task InitializeAsync()
        {
            await Client.InitializeAsync();
        }
    }
}