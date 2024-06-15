using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data.SqlClient;
using System.Data;
using System.Text.RegularExpressions;


namespace proyectoBases2.Pages.Proyecto.CRUD
{
    public class CrearClienteModel : PageModel
    {
        public Clientes Clientes = new Clientes();
        public void OnGet()
        {

        }

        public void OnPost()
        {
            string clienteDoc = Request.Form["identificacion"];
            string nombreCliente = Request.Form["nombre"];

            // Validar los datos ingresados
            if (ValidarNomSal(clienteDoc, nombreCliente) == false)
            {
                OnGet();
            }

            try
            {
                // Cadena de conexión a la base de datos
                string connectionString = "Data Source=LAPTOP-K8CP12F2;Initial Catalog=Tarea4;Integrated Security=True;Encrypt=False";

                // Establecer una conexión con la base de datos utilizando la cadena de conexión
                using (SqlConnection sqlConnection = new SqlConnection(connectionString))
                {
                    // Especificar que el comando es un procedimiento almacenado
                    sqlConnection.Open(); // Abrir la conexión

                    // Asignar los valores validados al objeto infoEmpleyee
                    Clientes.Identificacion = int.Parse(clienteDoc);
                    Clientes.Nombre = nombreCliente;

                    // Crear un comando SQL para llamar al stored procedure "registroEmpleado"
                    using (SqlCommand command = new SqlCommand("CrearCliente", sqlConnection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        // Parámetros de entraada
                        command.Parameters.AddWithValue("@InCedula", Clientes.Identificacion);
                        command.Parameters.AddWithValue("@InNombre", Clientes.Nombre);

                        SqlParameter outResultCodeParam = new SqlParameter("@OutResulTCode", SqlDbType.Int);
                        outResultCodeParam.Direction = ParameterDirection.Output;
                        command.Parameters.Add(outResultCodeParam);

                        command.ExecuteNonQuery();

                    }
                    sqlConnection.Close();
                }
            }
            catch (Exception ex)
            {

                return;
            }
        }

        // Método para validar el nombre y salario ingresados
        public bool ValidarNomSal(string identificacion, string nombre)
        {
            // Verificar que ambos campos no estén vacíos
            if (nombre.Length != 0 || identificacion.Length != 0)
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
