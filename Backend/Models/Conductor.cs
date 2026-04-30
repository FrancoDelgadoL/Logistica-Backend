using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace Backend.Models
{
    [Table("conductor")]
    public class Conductor : BaseModel
    {
        [PrimaryKey("id")]
        public Guid Id { get; set; }
    
        [Column("nombres")]
        public string Nombres { get; set; }
    
        [Column("apellidos")]
        public string Apellidos { get; set; }
    
        [Column("dni")]
        public string Dni { get; set; }
    
        [Column("user_id")]
        public Guid? UserId { get; set; }
    
        [Column("email")]
        public string Email { get; set; }
    
        [Column("estado")]
        public string Estado { get; set; }
    }
}