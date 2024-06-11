using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data.SqlClient;
using System.Data;
using System.Reflection;

namespace proyectoBases2.Pages.Proyecto.CRUD
{
    public class IndexCRUDModel : PageModel
    {

        public List<cliente> listaClientes = new List<cliente>();
        public void OnGet()
        {
            // Cadena de conexión a la base de datos
            string connectionString = "Data Source=LAPTOP-K8CP12F2;Initial Catalog=Tarea4;Integrated Security=True;Encrypt=False";

            // Establecer conexión a la base de datos
            using (SqlConnection sqlConnection = new SqlConnection(connectionString))
            {
                sqlConnection.Open();
                using (SqlCommand command = new SqlCommand("ConsultaClientes", sqlConnection)) // Llamar al procedimiento almacenado
                {
                    command.CommandType = CommandType.StoredProcedure;


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
                            cliente detallesClientes = new cliente();
                            detallesClientes.fechaOperacion = reader.GetDateTime(0);
                            detallesClientes.cedulaCliente = reader.GetInt32(1);
                            detallesClientes.nombreCliente = reader.GetString(2);
                            detallesClientes.numeroCliente = reader.GetInt64(3);
                            detallesClientes.tipoTarifa = reader.GetString(4);
                       
                            // Agregar el objeto empleyee a la lista filtrada
                            listaClientes.Add(detallesClientes);
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
