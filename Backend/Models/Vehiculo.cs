using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace API.Models;

[Table("vehiculo")]
public class Vehiculo : BaseModel
{
    [PrimaryKey("id")]
    public Guid Id { get; set; }
    
    [Column("placa")]
    public string Placa { get; set; }
    
    [Column("modelo")]
    public string Modelo { get; set; }
    
    [Column("estado")]
    public string Estado { get; set; }
    
    [Column("user_id")]
    public Guid? UserId { get; set; }
    
    [Column("created_at")]
    public DateTime CreatedAt { get; set; }
    
    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }
}