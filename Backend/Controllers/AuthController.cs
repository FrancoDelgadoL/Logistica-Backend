using Microsoft.AspNetCore.Mvc;
using Supabase;
using Backend.Models;
using API.Models;
using Backend.Services;  // 👈 Agregar

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly Client _supabase;

        public AuthController(ISupabaseService supabaseService)
        {
            _supabase = supabaseService.Client;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] Login request)
        {
            try
            {
                var response = await _supabase.Auth.SignIn(request.Email, request.Password);

                if (response?.User == null)
                {
                    return Unauthorized(new { mensaje = "Credenciales inválidas" });
                }

                var userId = response.User.Id.ToString();
                
                var rolesResult = await _supabase
                    .From<Roles>()
                    .Filter("id", Supabase.Postgrest.Constants.Operator.Equals, userId)
                    .Get();

                var rol = rolesResult.Models.FirstOrDefault()?.Role ?? "CONDUCTOR";

                return Ok(new
                {
                    success = true,
                    access_token = response.AccessToken,
                    user = new
                    {
                        id = response.User.Id.ToString(),
                        email = response.User.Email,
                        rol = rol
                    }
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { mensaje = ex.Message });
            }
        }

        [HttpPost("logout")]
        public async Task<IActionResult> Logout()
        {
            await _supabase.Auth.SignOut();
            return Ok(new { mensaje = "Sesión cerrada" });
        }

        [HttpGet("perfil")]
        public async Task<IActionResult> GetPerfil()
        {
            var user = _supabase.Auth.CurrentUser;

            if (user == null)
                return Unauthorized();

            var rolesResult = await _supabase
                .From<Roles>()
                .Where(r => r.Id.ToString() == user.Id.ToString())
                .Get();

            return Ok(new
            {
                id = user.Id.ToString(),
                email = user.Email,
                rol = rolesResult.Models.FirstOrDefault()?.Role ?? "CONDUCTOR"
            });
        }
    }
}