using System;
using System.Collections.Generic;
//using System.ComponentModel.DataAnnotations.Schema;(genera amiguedad)
using System.Linq;
using System.Threading.Tasks;
using Supabase.Postgrest.Models;
using Supabase.Postgrest.Attributes;



namespace Backend.Models
{
[Table("roles")]
public class Roles : BaseModel
{
    [PrimaryKey("id")]
    public string Id { get; set; }
    
    [Column("role")]
    public string Role { get; set; }
}
}