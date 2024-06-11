using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data.SqlClient;
using System.Data;
using System.Text.RegularExpressions;

namespace proyectoBases2.Pages.Proyecto.CRUD
{
    public class ModificarModel : PageModel
    {
        public TipoTarifa cargaTipoTarifa = new TipoTarifa();
        public cliente Cliente = new cliente();
        public string message = "";
        public string numeroCliente = "";
        public void OnGet()
        {
            numeroCliente = Request.Query["numeroCliente"];
            cargaTipoTarifa.conexion();
            try
            {
                string connectionString = "Data Source=LAPTOP-K8CP12F2;Initial Catalog=Tarea4;Integrated Security=True;Encrypt=False";

                using (SqlConnection sqlConnection = new SqlConnection(connectionString))
                {
                    sqlConnection.Open();
                    using (SqlCommand command = new SqlCommand("ModificarCliente", sqlConnection)) // Llamar al procedimiento almacenado
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        // Agregar parámetro de entrada
                        command.Parameters.AddWithValue("@InIdNumero", numeroCliente);
                        command.Parameters.AddWithValue("@InNombre", "");
                        command.Parameters.AddWithValue("@InTipoTarifa", 0);
                        command.Parameters.AddWithValue("@InBandera", 0);

                        // Agregar parámetro de salida
                        SqlParameter outParameter = new SqlParameter("@OutResulTCode", SqlDbType.Int);
                        outParameter.Direction = ParameterDirection.Output;
                        command.Parameters.Add(outParameter);

                        // Ejecutar el comando y procesar los resultados
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                Cliente.nombreCliente = reader.GetString(0);
                            }
                        }
                    }
                    sqlConnection.Close();
                }
            }
            catch (Exception ex)
            {
                message = ex.Message;
                Console.WriteLine("no pasa");
            }
        }
        public void OnPost()
        {
            numeroCliente = Request.Query["numeroCliente"];
            string auxNombre = Request.Form["nombre"];
            string TipoTarifa = Request.Form["tipoTarifa"];


            if(ValidarNom(auxNombre, TipoTarifa) == false){

                OnGet();
            }
            Cliente.numeroCliente = long.Parse(numeroCliente);
            Cliente.nombreCliente = auxNombre;
            Cliente.tipoTarifa = TipoTarifa;

            try
            {
                string connectionString = "Data Source=LAPTOP-K8CP12F2;Initial Catalog=Tarea4;Integrated Security=True;Encrypt=False";

                using (SqlConnection sqlConnection = new SqlConnection(connectionString))
                {
                    sqlConnection.Open();
                    using (SqlCommand command = new SqlCommand("ModificarCliente", sqlConnection)) // Llamar al procedimiento almacenado
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        // Agregar parámetro de entrada
                        command.Parameters.AddWithValue("@InIdNumero", Cliente.numeroCliente);
                        command.Parameters.AddWithValue("@InNombre", Cliente.nombreCliente);
                        command.Parameters.AddWithValue("@InTipoTarifa", Cliente.tipoTarifa);
                        command.Parameters.AddWithValue("@InBandera", 1);

                        // Agregar parámetro de salida
                        SqlParameter outParameter = new SqlParameter("@OutResulTCode", SqlDbType.Int);
                        outParameter.Direction = ParameterDirection.Output;
                        command.Parameters.Add(outParameter);

                        command.ExecuteNonQuery(); // Ejecutar el comando

                        int resultCode = Convert.ToInt32(outParameter.Value);

                        Console.WriteLine(outParameter);

                    }
                    sqlConnection.Close();
                }
            }
            catch (Exception ex)
            {
                message = ex.Message;
                Console.WriteLine("no pasa");
            }

        }
        public bool ValidarNom(string nombre, string TipoTarifa)
        {
            // Verificar que ambos campos no estén vacíos
            if ((nombre.Length != 0) && TipoTarifa != "")
            {
                // Utilizar expresiones regulares para verificar el formato del nombre y salario
                if (Regex.IsMatch(nombre, @"^[a-zA-Z\s]+$"))
                {
                    return true;
                }
            }
            return false;
        }
    }
}
