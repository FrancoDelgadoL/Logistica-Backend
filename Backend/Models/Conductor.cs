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

        [Column("dni")]
        public string Dni { get; set; }

        [Column("nombres")]
        public string Nombres { get; set; }

        [Column("apellidos")]
        public string Apellidos { get; set; }

        [Column("licencia_categoria")]
        public string LicenciaCategoria { get; set; }

        [Column("fecha_vencimiento_licencia")]
        public DateTime FechaVencimientoLicencia { get; set; }

        [Column("telefono")]
        public string Telefono { get; set; }

        [Column("estado")]
        public string Estado { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; }

        [Column("updated_at")]
        public DateTime UpdatedAt { get; set; }
    }
}