using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Supabase;

namespace Backend.Services
{
    public interface ISupabaseService
    {
        Client Client { get; }
        Task InitializeAsync();
    }
}