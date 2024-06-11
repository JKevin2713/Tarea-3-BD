using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using static System.Runtime.InteropServices.JavaScript.JSType;
using System.Data.SqlClient;
using System.Data;

namespace proyectoBases2.Pages.Proyecto.EmprezaXyZ
{
    public class DetalleLlamadasModel : PageModel
    {
        public List<detallesLlamadaXyY> detallesLlamadas = new List<detallesLlamadaXyY>();
        public string Numero = "";
        public string Bandera = "0";
        public string FechaCorte = "";
        public void OnGet()
        {
            FechaCorte = Request.Query["FechaCorte"];
            Numero = Request.Query["Numero"];
            DateTime fecha = DateTime.ParseExact(FechaCorte, "dd/MM/yyyy H:mm:ss", null);

            // Cadena de conexión a la base de datos
            string connectionString = "Data Source=LAPTOP-K8CP12F2;Initial Catalog=Tarea4;Integrated Security=True;Encrypt=False";

            // Establecer conexión a la base de datos
            using (SqlConnection sqlConnection = new SqlConnection(connectionString))
            {

                sqlConnection.Open();
                using (SqlCommand command = new SqlCommand("ConsultaDetalleEmpresaXyY", sqlConnection)) // Llamar al procedimiento almacenado
                {
                    command.CommandType = CommandType.StoredProcedure;


                    // Agregar parámetro de entrada
                    command.Parameters.AddWithValue("@InBandera", Bandera);
                    command.Parameters.AddWithValue("@InFechaCorte", fecha);

                    // Agregar parámetro de salida
                    SqlParameter outParameter = new SqlParameter("@OutResulTCode", SqlDbType.Int);
                    outParameter.Direction = ParameterDirection.Output;
                    command.Parameters.Add(outParameter);

                    // Ejecutar el comando y procesar los resultados
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            // Crear objeto empleyee y llenarlo con datos del resultado de la consulta
                            detallesLlamadaXyY detalles = new detallesLlamadaXyY();
                            detalles.id = reader.GetInt32(0);
                            detalles.FechaCorte = reader.GetDateTime(1);
                            detalles.FechaLlamada = reader.GetDateTime(2);
                            detalles.HoraInicio = reader.GetTimeSpan(3);
                            detalles.HoraFin = reader.GetTimeSpan(4);
                            detalles.Duracion = reader.GetInt32(5);
                            detalles.NumeroDe = reader.GetInt64(6);
                            detalles.NumeroA = reader.GetInt64(7);
                            detalles.TipoLlamada = reader.GetString(8);

                            // Agregar el objeto empleyee a la lista filtrada
                            detallesLlamadas.Add(detalles);
                        }
                    }

                    // Recuperar el valor del parámetro de salida
                    int resultCode = Convert.ToInt32(outParameter.Value);
                    // Manejar el código de resultado según sea necesario
                    Console.WriteLine(resultCode);

                }
                sqlConnection.Close();
            }
        }
    }
}
