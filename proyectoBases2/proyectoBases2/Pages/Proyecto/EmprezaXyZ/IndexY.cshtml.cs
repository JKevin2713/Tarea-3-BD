using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using static System.Runtime.InteropServices.JavaScript.JSType;
using System.Data.SqlClient;
using System.Data;

namespace proyectoBases2.Pages.Proyecto.EmprezaXyZ
{
    public class IndexYModel : PageModel
    {

        public List<infoEmplesaXyY> infoLlamadasXyY = new List<infoEmplesaXyY>();
        public string Numero = "";
        public string Bandera = "1";
        public void OnGet()
        {
            Numero = Request.Query["Numero"];
            OnPost(Bandera);
        }
        public void OnPost(string Bandera)
        {
            Numero = Request.Query["Numero"];
            // Cadena de conexión a la base de datos
            string connectionString = "Data Source=LAPTOP-K8CP12F2;Initial Catalog=Tarea4;Integrated Security=True;Encrypt=False";

            // Establecer conexión a la base de datos
            using (SqlConnection sqlConnection = new SqlConnection(connectionString))
            {
                sqlConnection.Open();
                using (SqlCommand command = new SqlCommand("ConsultarEmpresaXyY", sqlConnection)) // Llamar al procedimiento almacenado
                {
                    command.CommandType = CommandType.StoredProcedure;


                    // Agregar parámetro de entrada
                    command.Parameters.AddWithValue("@InBandera", Bandera);

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
                            infoEmplesaXyY infoEmplesaXyY = new infoEmplesaXyY();
                            infoEmplesaXyY.id = reader.GetInt32(0);
                            infoEmplesaXyY.FechaCorte = reader.GetDateTime(1);
                            infoEmplesaXyY.totalMinLlamadasEntrantes = reader.GetInt32(2);
                            infoEmplesaXyY.totalMinLlamadasSalientes = reader.GetInt32(3);
                            infoEmplesaXyY.FechaApertura = reader.GetDateTime(4);
                            infoEmplesaXyY.FechaCierre = reader.GetDateTime(5);
                            infoEmplesaXyY.Estado = reader.GetString(6);

                            // Agregar el objeto empleyee a la lista filtrada
                            infoLlamadasXyY.Add(infoEmplesaXyY);
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
