using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data.SqlClient;
using System.Data;
using System.Text.RegularExpressions;

namespace proyectoBases2.Pages.Proyecto.EmpresaZ
{
    public class DetallesLlamadasModel : PageModel
    {
        public List<llamada> listaDetalleLlamada = new List<llamada>();
        public string idFactura = "";
        public string Numero = "";
        public string FechaFactura = "";
        public void OnGet()
        {
            idFactura = Request.Query["idFactura"];
            Numero = Request.Query["Numero"];
            FechaFactura = Request.Query["FechaFactura"];
            DateTime fecha = DateTime.ParseExact(FechaFactura, "dd/MM/yyyy H:mm:ss", null);
            // Cadena de conexión a la base de datos
            string connectionString = "Data Source=LAPTOP-K8CP12F2;Initial Catalog=Tarea4;Integrated Security=True;Encrypt=False";

            
            // Establecer conexión a la base de datos
            using (SqlConnection sqlConnection = new SqlConnection(connectionString))
            {
                
                sqlConnection.Open();
                using (SqlCommand command = new SqlCommand("ConsultarLlamadas", sqlConnection)) // Llamar al procedimiento almacenado
                {
                    command.CommandType = CommandType.StoredProcedure;

                    
                    // Agregar parámetro de entrada
                    command.Parameters.AddWithValue("@InNumero", Numero);

                    Console.WriteLine(FechaFactura);
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
                            llamada Llamadas = new llamada();
                            Llamadas.id = reader.GetInt32(0);
                            Llamadas.NumeroDe = reader.GetInt64(1);
                            Llamadas.NumeroA = reader.GetInt64(2);
                            Llamadas.FechaInicio = reader.GetString(3);
                            Llamadas.FechaFin = reader.GetString(4);
                            Llamadas.FechaOperacion = reader.GetDateTime(5);
                            Llamadas.cantMin = reader.GetInt32(6);
                            // Agregar el objeto empleyee a la lista filtrada
                            listaDetalleLlamada.Add(Llamadas);
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
