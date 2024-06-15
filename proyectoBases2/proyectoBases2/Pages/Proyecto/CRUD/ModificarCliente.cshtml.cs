using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data.SqlClient;
using System.Data;
using System.Text.RegularExpressions;

namespace proyectoBases2.Pages.Proyecto.CRUD
{
    public class ModificarClienteModel : PageModel
    {
        public cliente Cliente = new cliente();
        public string message = "";
        public string numeroCliente = "";
        public void OnGet()
        {
            numeroCliente = Request.Query["numeroCliente"];
            try
            {
                string connectionString = "Data Source=LAPTOP-K8CP12F2;Initial Catalog=Tarea4;Integrated Security=True;Encrypt=False";

                using (SqlConnection sqlConnection = new SqlConnection(connectionString))
                {
                    sqlConnection.Open();
                    using (SqlCommand command = new SqlCommand("ModificarContrato", sqlConnection)) // Llamar al procedimiento almacenado
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        // Agregar parámetro de entrada
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
                                Cliente.numeroCliente = reader.GetInt64(0);
                                Cliente.nombreCliente = reader.GetString(1);
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
            string auxNumero = Request.Form["numero"];
            string TipoTarifa = Request.Form["tipoTarifa"];


            if (ValidarNomSal(auxNumero, TipoTarifa) == false)
            {

                OnGet();
            }
            long inNumero = long.Parse(numeroCliente);
            Cliente.tipoTarifa = TipoTarifa;

            try
            {
                string connectionString = "Data Source=LAPTOP-K8CP12F2;Initial Catalog=Tarea4;Integrated Security=True;Encrypt=False";

                using (SqlConnection sqlConnection = new SqlConnection(connectionString))
                {
                    sqlConnection.Open();
                    using (SqlCommand command = new SqlCommand("ModificarContrato", sqlConnection)) // Llamar al procedimiento almacenado
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        // Agregar parámetro de entrada
                        command.Parameters.AddWithValue("@InIdNumero", inNumero);
                        command.Parameters.AddWithValue("@InTipoTarifa", Cliente.tipoTarifa);
                        command.Parameters.AddWithValue("@InBandera", 1);

                        // Agregar parámetro de salida
                        SqlParameter outParameter = new SqlParameter("@OutResulTCode", SqlDbType.Int);
                        outParameter.Direction = ParameterDirection.Output;
                        command.Parameters.Add(outParameter);

                        command.ExecuteNonQuery(); // Ejecutar el comando

                        int resultCode = Convert.ToInt32(outParameter.Value);

                        Console.WriteLine(resultCode);

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
        public bool ValidarNomSal(string numero, string TipoTarifa)
        {
            // Verificar que ambos campos no estén vacíos
            if (numero.Length != 0 || TipoTarifa.Length != 0)
            {
                // Utilizar expresiones regulares para verificar el formato del nombre y salario
                if (Regex.IsMatch(numero, @"^[0-9]+$"))
                {
                    // Convertir el salario a decimal y verificar que sea mayor que cero
                    long auxNumero = long.Parse(numero);
                    if (auxNumero > 0)
                    {
                        return true;
                    }
                }
            }
            return false;
        }
    }
}
