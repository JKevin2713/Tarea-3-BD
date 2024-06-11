using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data.SqlClient;
using System.Data;
using System.Text.RegularExpressions;

namespace proyectoBases2.Pages.Proyecto.CRUD
{
    public class CrearClienteModel : PageModel
    {
        public TipoTarifa cargaTipoTarifa = new TipoTarifa();
        public cliente Cliente = new cliente();
        public void OnGet()
        {
            cargaTipoTarifa.conexion();
        }
        public void OnPost()
        {
            string auxNombre = Request.Form["nombre"];
            string auxIndentificacion = Request.Form["identificacion"];
            string TipoTarifa = Request.Form["tipoTarifa"];


            if (ValidarNom(auxIndentificacion, auxNombre, TipoTarifa) == false)
            {
                OnGet();
            }

            Cliente.nombreCliente = auxNombre;
            Cliente.cedulaCliente = int.Parse(auxIndentificacion);
            Cliente.tipoTarifa = TipoTarifa;

            try
            {
                string connectionString = "Data Source=LAPTOP-K8CP12F2;Initial Catalog=Tarea4;Integrated Security=True;Encrypt=False";

                using (SqlConnection sqlConnection = new SqlConnection(connectionString))
                {
                    sqlConnection.Open();
                    using (SqlCommand command = new SqlCommand("CrearCliente", sqlConnection)) // Llamar al procedimiento almacenado
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        // Agregar parámetro de entrada
                        command.Parameters.AddWithValue("@InCedula", Cliente.cedulaCliente);
                        command.Parameters.AddWithValue("@InNombre", Cliente.nombreCliente);
                        command.Parameters.AddWithValue("@InTipoTarifa", Cliente.tipoTarifa);

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
                Console.WriteLine("no pasa");
            }

        }
        public bool ValidarNom(string identificacion, string nombre, string TipoTarifa)
        {
            // Verificar que ambos campos no estén vacíos
            if ((nombre.Length != 0 || identificacion.Length != 0) && TipoTarifa != "")
            {
                // Utilizar expresiones regulares para verificar el formato del nombre y salario
                if (Regex.IsMatch(nombre, @"^[a-zA-Z\s]+$") && Regex.IsMatch(identificacion, @"^[0-9]+$"))
                {
                    // Convertir el salario a decimal y verificar que sea mayor que cero
                    decimal auxIdentificacion = int.Parse(identificacion);
                    if (auxIdentificacion > 0)
                    {
                        return true;
                    }
                }
            }
            return false;
        }
    }
}
