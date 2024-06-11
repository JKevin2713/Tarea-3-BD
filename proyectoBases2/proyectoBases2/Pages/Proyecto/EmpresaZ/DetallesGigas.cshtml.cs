using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data.SqlClient;
using System.Data;
using System.Text.RegularExpressions;

namespace proyectoBases2.Pages.Proyecto.EmpresaZ
{
    public class DetallesGigasModel : PageModel
    {
        public List<usoDatos> listaDetalleUsoDatos = new List<usoDatos>();
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
                using (SqlCommand command = new SqlCommand("ConsultarGigas", sqlConnection)) // Llamar al procedimiento almacenado
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
                            usoDatos datos = new usoDatos();
                            datos.id = reader.GetInt32(0);
                            datos.Numero = reader.GetInt64(1);
                            datos.montoMegasConsumidas = reader.GetDecimal(2);
                            datos.fecha = reader.GetDateTime(3);


                            // Agregar el objeto empleyee a la lista filtrada
                            listaDetalleUsoDatos.Add(datos);
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
